unit CANLogger;

interface

uses
    Windows, Classes, SysUtils, Generics.Collections, BaseCAN, DateUtils;

type
    TCANLogItem = record
        TimeStamp: TDateTime;
        Frame: TCANFrame;
        constructor Create(AFrame: TCANFrame);
    end;

   // TCANIDFilter = set of Cardinal;

    TCANLogger = class
    private
        FQueue: TQueue<TCANLogItem>;
        FFilterIDs: TDictionary<Cardinal, Boolean>;
        FMaxTimeSpan: Integer;      // �ִ� ���� �ð�(��)
        FMaxCount: Integer;         // �ִ� ���� ����
        FSavePath: string;          // ���� ���
        FMaxFiles: Integer;         // ������ �ִ� ���� ��
        FLastCleanupTime: TDateTime;

        procedure CleanupOldEntries;
        procedure CleanupOldFiles;
        function GetFilteredIDCount: Integer;
        function GetItemCount: Integer;
        function CreateLogFileName: string;
    public
        constructor Create(AMaxTimeSpan: Integer = 60; AMaxCount: Integer = 1000);
        destructor Destroy; override;

        // ���͸��� CAN ID �߰�/����
        procedure AddFilterID(ID: Cardinal);
        procedure RemoveFilterID(ID: Cardinal);
        procedure ClearFilterIDs;

        // CAN ������ �߰�
        procedure AddFrame(Frame: TCANFrame);

        // �α� ����
        function SaveToFile(const CustomFileName: string = ''): string;

        // ����
        procedure SetMaxTimeSpan(Seconds: Integer);
        procedure SetMaxCount(Count: Integer);
        procedure SetSavePath(const Path: string);
        procedure SetMaxFiles(Count: Integer);

        // �α� �ʱ�ȭ
        procedure Clear;

        // �Ӽ�
        property FilteredIDCount: Integer read GetFilteredIDCount;
        property ItemCount: Integer read GetItemCount;
        property MaxTimeSpan: Integer read FMaxTimeSpan write SetMaxTimeSpan;
        property MaxCount: Integer read FMaxCount write SetMaxCount;
        property SavePath: string read FSavePath write SetSavePath;
        property MaxFiles: Integer read FMaxFiles write SetMaxFiles;
    end;

implementation

{ TCANLogItem }

constructor TCANLogItem.Create(AFrame: TCANFrame);
begin
    TimeStamp := Now;
    Frame := AFrame;
end;

{ TCANLogger }

constructor TCANLogger.Create(AMaxTimeSpan, AMaxCount: Integer);
begin
    inherited Create;
    FQueue := TQueue<TCANLogItem>.Create;
    FFilterIDs := TDictionary<Cardinal, Boolean>.Create;
    FMaxTimeSpan := AMaxTimeSpan;
    FMaxCount := AMaxCount;
    FSavePath := ExtractFilePath(ParamStr(0)) + 'CANLogs\';
    FMaxFiles := 100;
    FLastCleanupTime := Now;

    // ���� ��ΰ� ������ ����
    if not DirectoryExists(FSavePath) then
        ForceDirectories(FSavePath);
end;

destructor TCANLogger.Destroy;
begin
    FQueue.Free;
    FFilterIDs.Free;
    inherited;
end;

procedure TCANLogger.AddFilterID(ID: Cardinal);
begin
    if not FFilterIDs.ContainsKey(ID) then
        FFilterIDs.Add(ID, True);
end;

procedure TCANLogger.RemoveFilterID(ID: Cardinal);
begin
    if FFilterIDs.ContainsKey(ID) then
        FFilterIDs.Remove(ID);
end;

procedure TCANLogger.ClearFilterIDs;
begin
    FFilterIDs.Clear;
end;

procedure TCANLogger.AddFrame(Frame: TCANFrame);
var
    LogItem: TCANLogItem;
begin
    // ���͸��� ID�� ����
    if (FFilterIDs.Count = 0) or FFilterIDs.ContainsKey(Frame.mID) then
    begin
        LogItem := TCANLogItem.Create(Frame);
        FQueue.Enqueue(LogItem);

        // ������ �׸� ����
        CleanupOldEntries;
    end;
end;

procedure TCANLogger.CleanupOldEntries;
var
    CurrentTime: TDateTime;
    OldestAllowedTime: TDateTime;
    Item: TCANLogItem;
begin
    // �ִ� ���� ���� ó��
    while (FQueue.Count > FMaxCount) and (FQueue.Count > 0) do
        FQueue.Dequeue;

    // �ִ� �ð� ���� ó��
    if FMaxTimeSpan > 0 then
    begin
        CurrentTime := Now;
        OldestAllowedTime := IncSecond(CurrentTime, -FMaxTimeSpan);

        while (FQueue.Count > 0) do
        begin
            Item := FQueue.Peek;
            if Item.TimeStamp < OldestAllowedTime then
                FQueue.Dequeue
            else
                Break;
        end;
    end;
end;

procedure TCANLogger.CleanupOldFiles;
var
    SearchRec: TSearchRec;
    FileList: TStringList;
    i: Integer;
    FilePath: string;
begin
    // ������ ���� �ð����κ��� 1�ð� �̳��� ���� ����
    if MinutesBetween(Now, FLastCleanupTime) < 60 then
        Exit;

    FLastCleanupTime := Now;

    if not DirectoryExists(FSavePath) then
        Exit;

    FileList := TStringList.Create;
    try
        // �α� ���� ��� ����
        if FindFirst(FSavePath + '*.log', faAnyFile, SearchRec) = 0 then
        begin
            repeat
                FileList.Add(SearchRec.Name);
            until FindNext(SearchRec) <> 0;
            SysUtils.FindClose(SearchRec); // SysUtils ������ FindClose ����� ȣ��
        end;

        // ���� ���� (���� ������ ������ �տ� ������)
        FileList.Sort;

        // �ִ� ���� ���� �ʰ��ϴ� ������ ���� ����
        while FileList.Count > FMaxFiles do
        begin
            FilePath := FSavePath + FileList[0];
            if FileExists(FilePath) then
                SysUtils.DeleteFile(PChar(FilePath)); // PChar�� ��ȯ�Ͽ� ȣ��
            FileList.Delete(0);
        end;
    finally
        FileList.Free;
    end;
end;

function TCANLogger.SaveToFile(const CustomFileName: string): string;
var
    FileName: string;
    LogFile: TextFile;
    Item: TCANLogItem;
    TempQueue: TQueue<TCANLogItem>;
    i, Count: Integer;
begin
    if FQueue.Count = 0 then
    begin
        Result := '';
        Exit;
    end;

    // ���� �̸� ����
    if CustomFileName <> '' then
        FileName := FSavePath + CustomFileName
    else
        FileName := FSavePath + CreateLogFileName;

    Result := FileName;

    // ���丮 Ȯ��
    if not DirectoryExists(ExtractFilePath(FileName)) then
        ForceDirectories(ExtractFilePath(FileName));

    // �ӽ� ť�� ���� (���� ������ ����)
    TempQueue := TQueue<TCANLogItem>.Create;
    try
        Count := FQueue.Count;
        for i := 0 to Count - 1 do
        begin
            Item := FQueue.Dequeue;
            TempQueue.Enqueue(Item);
            FQueue.Enqueue(Item);
        end;

        // ���Ͽ� ����
        AssignFile(LogFile, FileName);
        Rewrite(LogFile);
        try
            Writeln(LogFile, '// CAN Log - ' + FormatDateTime('yyyy-mm-dd hh:nn:ss', Now));
            Writeln(LogFile, '// Total Frames: ' + IntToStr(TempQueue.Count));
            Writeln(LogFile);

            Count := TempQueue.Count;
            for i := 0 to Count - 1 do
            begin
                Item := TempQueue.Dequeue;
                Writeln(LogFile, FormatDateTime('hh:nn:ss.zzz', Item.TimeStamp) + ' - ' + Item.Frame.ToStr);
            end;
        finally
            CloseFile(LogFile);
        end;

        // ������ ���� ����
        CleanupOldFiles;
    finally
        TempQueue.Free;
    end;
end;

function TCANLogger.CreateLogFileName: string;
begin
    Result := FormatDateTime('yyyymmdd-hhnn', Now) + '.log';
end;

procedure TCANLogger.Clear;
begin
    FQueue.Clear;
end;

function TCANLogger.GetFilteredIDCount: Integer;
begin
    Result := FFilterIDs.Count;
end;

function TCANLogger.GetItemCount: Integer;
begin
    Result := FQueue.Count;
end;

procedure TCANLogger.SetMaxTimeSpan(Seconds: Integer);
begin
    if Seconds < 0 then
        Seconds := 0;

    FMaxTimeSpan := Seconds;
    CleanupOldEntries;
end;

procedure TCANLogger.SetMaxCount(Count: Integer);
begin
    if Count < 1 then
        Count := 1;

    FMaxCount := Count;
    CleanupOldEntries;
end;

procedure TCANLogger.SetSavePath(const Path: string);
var
    NewPath: string;
begin
    NewPath := IncludeTrailingPathDelimiter(Path);

    if NewPath <> FSavePath then
    begin
        FSavePath := NewPath;

        // ��ΰ� ������ ����
        if not DirectoryExists(FSavePath) then
            ForceDirectories(FSavePath);
    end;
end;

procedure TCANLogger.SetMaxFiles(Count: Integer);
begin
    if Count < 1 then
        Count := 1;

    FMaxFiles := Count;
    CleanupOldFiles;
end;

end.

