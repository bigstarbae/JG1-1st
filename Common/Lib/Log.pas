unit Log;

{
  2013.09.01
  Disk acceess 를 CPU 부하가 없을때만 하도록 기능 추가

  Ver.1.9112800 : 멀티스레드 대응 C.S 추가 및  Queue사용 유무 변수 추가

  Ver.201220.00 : Notepad++ 연동 함수 추가

  Ver.220213.00 : 한->영 번역 프로젝트 종속 지원

  Ver.220226.00 : 듀얼 로그창을 위한 Sub Handle 추가

  Ver.241117.00 : 멀티라인 지원, 출력 인터벌 사용 Panel/Debug함수 및 관련 프로퍼티 추가
}
interface

uses
    Windows, Classes, SysUtils, { FileCtrl, } Messages, Forms, shellapi, SyncObjs, Registry, TimeChecker;

type
    TLog = Class
    private

        hMsg: HWND;
        mSubHandle: HWND;

        nSaveMonth:     integer;
        szHomePath:     string;
        mIsWrite:       boolean;
        mIsMilli:       boolean;
        mIsTime:        boolean;
        mList:          TStrings; // 2013.09.01
        mLstTime:       double;
        mIsUseMem:      boolean; // 2013-12-27
        mLogFileName:   string;
        mUniCode:       boolean;

        mCS:            TCriticalSection;
        mUseQueue:      boolean;

        mNPPFilePath:   string;

        mLastErrMSec:   integer;
        mLastErrMsg:    string;

        mEnableDebug:  boolean;
        mUseMultiLine: Boolean;

        mIntervalTC:   TTimeChecker;

        procedure SetPath(const Value: string);

    public
        constructor Create(hdlWnd: HWND; nSave: integer; IsUseMem: boolean = false; IsUniCode: boolean = false);
        destructor Destroy; override;

        procedure Remove;
        procedure Append(const s: string);

        procedure Panel(LogMsg: string); overload;
        procedure PanelHex(const LogMsg; len: integer);

        procedure PanelWithMultiLine(const szFmt: string; const Args: array of const);
        procedure Panel(const szFmt: string; const Args: array of const ); overload;
        procedure Panel(const szFmt: string; const Args: array of const; Interval: Integer); overload;
        procedure Error(const szFmt: string; const Args: array of const );

        procedure DebugWithMultiLine(const szFmt: string; const Args: array of const);
        procedure Debug(const szFmt: string; const Args: array of const );

        procedure ToFiles(const szFmt: string; const Args: array of const );
        procedure AppException(Sender: TObject; E: Exception);

        function LogCount(): integer;
        function GetLineByText(SrchText: string): integer;
        function GetLastErrMsg(WithinMSec: integer = 1000): string; //  WinthinMsec : 인자의 MSEC내에 포함된 에러내역을 리턴, 즉 최근 에러만 필터링 할 경우 사용

        procedure Updates(aCount: integer = 0); // 2013.09.01
        procedure Add(const aFile, Value: string); // 2013.09.01
        procedure SaveToFile(const aFile, Value: string); // 2013.09.01

        property LogHandle: HWND read hMsg write hMsg;
        property SubHandle: HWND read mSubHandle write mSubHandle;

        property IsWrite: boolean read mIsWrite write mIsWrite;
        property IsMilli: boolean read mIsMilli write mIsMilli;
        property IsTime: boolean write mIsTime;
        property UseQueue: boolean read mUseQueue write mUseQueue;
        property Path: string read szHomePath write SetPath;

        property EnableDebug: boolean read mEnableDebug write mEnableDebug;
        property UseMultiLine: Boolean read mUseMultiLine write mUseMultiLine;

        procedure ShowCurLogFile(AHandle: HWND; SrchText: string = '');
    end;


    function GetNPPFilePath: string;

var
    gLog: TLog;

implementation
uses
    StrUtils, LangTran;

function GetNPPFilePath: string;
var
    Reg:    TRegistry;
    Key:    string;
    StrList: TStringList;
begin

    Result := '';
    StrList := nil;
    Reg := TRegistry.Create(KEY_READ or KEY_WOW64_64KEY);
    try
        Reg.RootKey := HKEY_CLASSES_ROOT;
        Key := 'Applications\notepad++.exe\shell\open\command';
        if (Reg.KeyExists(Key)) then
        begin
            if Reg.OpenKey(Key, false) then
            begin
                Result := Reg.GetDataAsString(Reg.ReadString(Key));

                if Result <> '' then
                begin
                    StrList := TStringList.Create;
                    StrList.Delimiter := '"';
                    StrList.DelimitedText := Result;
                    if StrList.Count > 1 then
                    begin
                        Result := StrList.Strings[0];
                    end;
                end;
            end;
        end;
    finally
        if Assigned(StrList) then
            StrList.Free;
        Reg.Free;
    end;
end;


// ---------------------------------------------------------------------------
constructor TLog.Create(hdlWnd: HWND; nSave: integer; IsUseMem: boolean; IsUniCode: boolean);
begin
    hMsg := hdlWnd;
    nSaveMonth := nSave;
    mIsWrite := true;
    mIsMilli := false;
    mIsTime := true;
    mList := TStringList.Create;
    mIsUseMem := IsUseMem;
    mUniCode := IsUniCode;

    mNPPFilePath :=  GetNPPFilePath;

    mCS := TCriticalSection.Create;

    mEnableDebug := true;

    szHomePath := ExtractFileDir(ParamStr(0)) + '\Log';
    if not DirectoryExists(szHomePath) then
        CreateDir(szHomePath);
    Remove;

    mIntervalTC.Start(10);
end;

procedure TLog.SetPath(const Value: string);
begin
    szHomePath := Value;
    if not DirectoryExists(szHomePath) then
        CreateDir(szHomePath);

end;

// ---------------------------------------------------------------------------
procedure TLog.AppException(Sender: TObject; E: Exception);
begin

    Application.ShowException(E);
    ToFiles('Exception: %s', [E.Message]);
end;

// ---------------------------------------------------------------------------
procedure TLog.Remove;
var
    i: integer;
    // done : integer;
    yy, mm, dd: word;
    SearchFile: TSearchRec;
    szMask, name: Ansistring;
begin
    mLstTime := Now();
    DecodeDate(Now(), yy, mm, dd);

    // nSaveMonth 개월분 보관
    for i := 0 to nSaveMonth - 1 do
    begin
        dec(mm);
        if (mm = 0) then
        begin
            dec(yy);
            mm := 12;
        end
    end;

    name := Format('%.4d%.2d%.2d.LOG', [yy, mm, dd]);
    szMask := szHomePath + '\*.log';

    if FindFirst(szMask, faArchive, SearchFile) = 0 then
    begin
        repeat
            if SearchFile.Name < name then
            begin
                DeleteFile(szHomePath + '\' + SearchFile.Name);
            end;
        until FindNext(SearchFile) <> 0;
        FindClose(SearchFile);
    end;
end;

procedure TLog.SaveToFile(const aFile, Value: string);
var
    fd: integer;
    Dat: String;
    Dat2: Ansistring;
    Bom: word;
begin
    if not DirectoryExists(ExtractFileDir(aFile)) then
    begin
        ForceDirectories(ExtractFileDir(aFile));
    end;

    Bom := 0;
    if FileExists(aFile) then
    begin
        fd := FileOpen(aFile, fmOpenWrite or fmShareDenyNone);
    end
    else
    begin
        fd := FileCreate(aFile);
        if mUniCode then
            Bom := $FEFF;
    end;
    if (fd < 0) then
        Exit;

    if Bom <> 0 then
        FileWrite(fd, Bom, sizeof(word));
    FileSeek(fd, 0, FILE_END);

    if mUniCode then
    begin
        Dat := Value + #13 + #10;
        FileWrite(fd, PWideChar(Dat)^, Length(Dat) * sizeof(WideChar));
    end
    else
    begin
        Dat2 := Value + #13 + #10;
        FileWrite(fd, Dat2[1], Length(Dat2));
    end;

    FileClose(fd);
end;

// ---------------------------------------------------------------------------
procedure TLog.Add(const aFile, Value: string);
begin
    mCS.Acquire;
    try
        mList.Add(aFile + '@@' + Value);
        if (mList.Count > 255) or not mIsUseMem then
        begin
            Updates(1);
        end;
    finally
        mCS.Release;
    end;
end;

procedure TLog.Append(const s: string);
var
    yy, mm, dd: word;
begin
    if not mIsWrite then
    begin
        Exit;
    end;
    DecodeDate(Now(), yy, mm, dd);

    if mUseQueue then
        Add(Format('%s\%.4d%.2d%.2d.LOG', [szHomePath, yy, mm, dd]), s)
    else
    begin
        mLogFileName := Format('%s\%.4d%.2d%.2d.LOG', [szHomePath, yy, mm, dd]);
        SaveToFile(mLogFileName, s);
    end;

end;

// ---------------------------------------------------------------------------
procedure TLog.PanelHex(const LogMsg; len: integer);
var
    i: integer;
    s: Ansistring;
begin
    s := '';
    for i := 0 to len - 1 do
        s := s + IntToHex(TByteArray(LogMsg)[i], 2) + ' ';
    Panel('%s', [s]);
end;

procedure TLog.PanelWithMultiLine(const szFmt: string; const Args: array of const);
begin
    mUseMultiLine := True;
    Panel(szFmt, Args);
    mUseMultiLine := False;
end;

// ---------------------------------------------------------------------------
procedure TLog.Panel(LogMsg: string);
begin
    Panel('%s', [LogMsg]);
end;


function AddToListBox(ListBoxHandle: HWND; const Text: string): Integer;
var
    StartPos, EndPos: Integer;
    Line: string;
begin
    Result := 0;
    StartPos := 1;

    while StartPos <= Length(Text) do
    begin
        EndPos := PosEx(sLineBreak, Text, StartPos);
        if EndPos = 0 then
            EndPos := Length(Text) + 1;

        Line := Copy(Text, StartPos, EndPos - StartPos);

        if Line <> '' then
        begin
            SendMessage(ListBoxHandle, LB_ADDSTRING, 0, LPARAM(PWideChar(Line)));
            Inc(Result);
        end;

        StartPos := EndPos + Length(sLineBreak);
    end;
end;



// ---------------------------------------------------------------------------
procedure TLog.Panel(const szFmt: string; const Args: array of const );
var
    msg: TMSG;
    nCount: integer;
    szMessage, s2: string;
    hh, mm, ss, ms: word;

    procedure ProcessMsg(Handle: HWND);
    begin
        while true do
        begin
            nCount := integer(SendMessage(Handle, LB_GETCOUNT, 0, 0));
            if (nCount < 100) then
                break;
            SendMessage(Handle, LB_DELETESTRING, 0, 0);
        end;

        if mIsTime then
        begin
            if mUseMultiLine then
                AddToListBox(Handle, szMessage)
            else
                SendMessage(Handle, LB_ADDSTRING, 0, DWORD(PWideChar(szMessage)))
        end
        else
        begin
            SendMessage(Handle, LB_ADDSTRING, 0, DWORD(PWideChar(s2)));
        end;
        nCount := integer(SendMessage(Handle, LB_GETCOUNT, 0, 0));
        SendMessage(Handle, LB_SETCURSEL, nCount - 1, 0);
        // SetFocus(Handle);

        while (PeekMessage(msg, Handle, 0, 0, PM_REMOVE)) do
        begin
            TranslateMessage(msg);
            DispatchMessage(msg);
        end;

    end;

begin
    try
        {
        if IsHan(szFmt) then            // 한글일 경우만 체크하는 이유는 번역문이 없을 경우 영문도 저장됨.
            s2 := Format(_TR(szFmt), Args)  // Log도 번역 사용할 경우... 주석 제거
        else
        }
            s2 := Format(szFmt, Args);
    except
        s2 := 'log func panel: ' + szFmt;
    end;
    DecodeTime(Now(), hh, mm, ss, ms);
    try
        if mIsMilli then
            szMessage := Format('[%.2d:%.2d:%.2d:%.3d] %s', [hh, mm, ss, ms, s2])
        else
            szMessage := Format('[%.2d:%.2d:%.2d] %s', [hh, mm, ss, s2]);
    except
        On E: Exception do
            szMessage := 'Log func Panel ' + szFmt + E.Message;
    end;

    ProcessMsg(hMsg);

    if mSubHandle <> 0 then
        ProcessMsg(mSubHandle);

    Append(szMessage);
end;

// ---------------------------------------------------------------------------
procedure TLog.Error(const szFmt: string; const Args: array of const );
begin
    try
        mLastErrMsg := Format(szFmt, Args);
    except
        mLastErrMsg := 'Log func Error: ' + szFmt;
    end;

    mLastErrMSec := integer(GetTickCount);


    Panel('ERROR: %s', [mLastErrMsg]);
end;



function TLog.GetLastErrMsg(WithinMSec: integer): string;
begin
    if (integer(GetTickCount) - mLastErrMSec) <= WithinMSec then
    begin
        Exit(mLastErrMsg);
    end;

    Result := '';
end;

function TLog.GetLineByText(SrchText: string): integer;
var
    LineStr: string;
    TxtFile: TextFile;
begin
    Result := 1;

    AssignFile(TxtFile, mLogFileName);
    Reset(TxtFile);

    while not Eof(TxtFile) do
    begin
        ReadLn(TxtFile, LineStr);
        if Pos(SrchText, LineStr) > 0 then
        begin
            Exit(Result);
        end;
        Inc(Result);
    end;

    CloseFile(TxtFile);
end;

// ---------------------------------------------------------------------------
procedure TLog.Debug(const szFmt: string; const Args: array of const );
var
    szMessage: string;
begin
    if not mEnableDebug then
        Exit;

    try
        szMessage := Format(szFmt, Args);
    except
        szMessage := 'Log func Debug ' + szFmt;
    end;

    Panel('DEBUG: %s', [szMessage]);
end;

procedure TLog.DebugWithMultiLine(const szFmt: string; const Args: array of const);
begin
    mUseMultiLine := True;
    Debug(szFmt, Args);
    mUseMultiLine := False;
end;

destructor TLog.Destroy;
begin

    Updates();
    if Assigned(mList) then
        FreeAndNil(mList);

    FreeAndNil(mCS);

    inherited;
end;

// ---------------------------------------------------------------------------
procedure TLog.ToFiles(const szFmt: string; const Args: array of const );
var
    szMessage, s2: string;
    hh, mm, ss, ms: word;
begin
    try
        s2 := Format(szFmt, Args);
    except
        s2 := 'log func tofiles: ;\' + szFmt;
    end;

    DecodeTime(Now(), hh, mm, ss, ms);
    try
        if mIsMilli then
            szMessage := Format('[%.2d:%.2d:%.2d:%.3d] %s', [hh, mm, ss, ms, s2])
        else
            szMessage := Format('[%.2d:%.2d:%.2d] %s', [hh, mm, ss, s2]);
    except
        On E: Exception do
            szMessage := 'Log func ToFiles ' + szFmt + E.Message;
    end;

    Append(szMessage);
end;

procedure TLog.Updates(aCount: integer);
var
    i, Cnt: integer;
    sTm: String;
begin
    if not mUseQueue then
        Exit;

    mCS.Acquire;

    try
        Cnt := 0;
        for i := 0 to mList.Count - 1 do
        begin
            sTm := mList.Strings[0];
            mList.Delete(0);
            mLogFileName := Copy(sTm, 1, Pos('@@', sTm) - 1);
            sTm := Copy(sTm, Pos('@@', sTm) + 2, Length(sTm) - Pos('@@', sTm) - 1);
            SaveToFile(mLogFileName, sTm);
            Inc(Cnt);
            if (aCount > 0) and (aCount < Cnt) then
                break;
        end;

        if Trunc(Now) = Trunc(mLstTime) then
            Exit;
        Remove;

    finally
        mCS.Release;
    end;

end;

// ---------------------------------------------------------------------------
function TLog.LogCount: integer;
begin
    Result := mList.Count;
end;

procedure TLog.ShowCurLogFile(AHandle: HWND; SrchText: string);
var
    Param: string;
begin
    Updates();

    if (mNPPFilePath <> '') and (SrchText <> '') then
    begin
        Param := mLogFileName + Format(' -n%d', [GetLineByText(SrchText)]);
        ShellExecute(AHandle, 'open', PChar(mNPPFilePath), PChar(Param), nil, SW_SHOWNORMAL);
    end
    else
        ShellExecute(AHandle, 'open', PChar(mLogFileName), nil, nil, SW_SHOWNORMAL);

end;


procedure TLog.Panel(const szFmt: string; const Args: array of const; Interval: Integer);
begin
    if mIntervalTC.IsTimeOut then
    begin
        Panel(szFmt, Args);
        mIntervalTC.Start(Interval);
    end;
end;

end.



