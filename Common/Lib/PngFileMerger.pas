unit PngFileMerger;

interface

uses
    SysUtils, Classes, PngImage;



type
    TPngFilePos = packed record
        mIdx,
        mPos: Integer;
    end;

    TPngFileMerger = class
    public
        class function  ReadHeader(const MergedFileName: string): TArray<Integer>;
        class function  GetPngCount(const MergedFileName: string): Integer;
        class function  CreatePngFromMergedFile(const MergedFileName: string; Index: Integer): TPngImage;
        class function  AddPngToMergedFile(const PngFileName, MergedFileName: string): TPngFilePos;
        class procedure MergePngFiles(const FolderPath, OutputFileName: string);
        class procedure ExtractPngFromMergedFile(const MergedFileName: string; Index: Integer; const OutputPngFile: string);

    end;

implementation

uses
    IOUtils, Types;

{ TPngFileMerger }

const
    MAX_PNG_FILE_COUNT = 50;
    HEADER_SIZE = MAX_PNG_FILE_COUNT * SizeOf(Integer);

class function TPngFileMerger.ReadHeader(const MergedFileName: string): TArray<Integer>;
var
    MergedFile: TFileStream;
    IndexTable: array[0..MAX_PNG_FILE_COUNT - 1] of Integer;
    i: Integer;
begin
    MergedFile := TFileStream.Create(MergedFileName, fmOpenRead);
    try
    // ���� ���̺� �б�
        MergedFile.ReadBuffer(IndexTable, HEADER_SIZE);

    // TArray<Integer>�� ��ȯ�Ͽ� ��ȯ
        SetLength(Result, MAX_PNG_FILE_COUNT);
        for i := 0 to MAX_PNG_FILE_COUNT - 1 do
            Result[i] := IndexTable[i];
    finally
        MergedFile.Free;
    end;
end;

class procedure TPngFileMerger.MergePngFiles(const FolderPath, OutputFileName: string);
var
    FileList: TStringList;
    PngFiles: TStringDynArray;
    OutputFile: TFileStream;
    IndexTable: array[0..MAX_PNG_FILE_COUNT - 1] of Integer;
    FileIndex, Position: Integer;
    InputFile: TFileStream;
    Buffer: TBytes;
    i: Integer;
begin
    FileList := TStringList.Create;
    OutputFile := TFileStream.Create(OutputFileName, fmCreate);
    try
    // ���� ���� PNG ���� ��� �б�
        PngFiles := TDirectory.GetFiles(FolderPath, '*.png');

        for i := 0 to Length(PngFiles) - 1 do
            FileList.Add(PngFiles[i]);

        if FileList.Count > MAX_PNG_FILE_COUNT then
            raise Exception.CreateFmt('�ִ� %d���� ���ϸ� �����մϴ�.', [MAX_PNG_FILE_COUNT]);

    // ���� ���̺� �ʱ�ȭ �� ���
        FillChar(IndexTable, SizeOf(IndexTable), -1);
        OutputFile.WriteBuffer(IndexTable, HEADER_SIZE);

    // PNG ������ �ϳ��� �����ϰ� ��ġ ���
        Position := HEADER_SIZE;
        for FileIndex := 0 to FileList.Count - 1 do
        begin
            IndexTable[FileIndex] := Position;
            InputFile := TFileStream.Create(FileList[FileIndex], fmOpenRead);
            try
                SetLength(Buffer, InputFile.Size);
                InputFile.ReadBuffer(Buffer[0], Length(Buffer));
                OutputFile.WriteBuffer(Buffer[0], Length(Buffer));
                Position := Position + Length(Buffer);
            finally
                InputFile.Free;
            end;
        end;

    // ���� ���̺� ������Ʈ
        OutputFile.Position := 0;
        OutputFile.WriteBuffer(IndexTable, HEADER_SIZE);
    finally
        OutputFile.Free;
        FileList.Free;
    end;
end;

class function  TPngFileMerger.AddPngToMergedFile(const PngFileName, MergedFileName: string): TPngFilePos;
var
    MergedFile: TFileStream;
    IndexTable: array[0..MAX_PNG_FILE_COUNT - 1] of Integer;
    Position, NewIndex: Integer;
    InputFile: TFileStream;
    Buffer: TBytes;
begin
    Result.mIdx := -1;
    Result.mPos := 0;

    MergedFile := TFileStream.Create(MergedFileName, fmOpenReadWrite);
    try
    // ���� ���̺� �б�
        MergedFile.ReadBuffer(IndexTable, HEADER_SIZE);

    // ���ο� ��ġ ���
        NewIndex := -1;
        for Position := 0 to MAX_PNG_FILE_COUNT - 1 do
        begin
            if IndexTable[Position] = -1 then
            begin
                NewIndex := Position;
                Break;
            end;
        end;

        if NewIndex = -1 then
            raise Exception.Create('���� ���̺��� ���� á���ϴ�.');

    // ���� ������ �̵��Ͽ� �߰�
        MergedFile.Position := MergedFile.Size;
        IndexTable[NewIndex] := MergedFile.Position;
        Result.mIdx := NewIndex;
        Result.mPos := MergedFile.Position;

        InputFile := TFileStream.Create(PngFileName, fmOpenRead);
        try
            SetLength(Buffer, InputFile.Size);
            InputFile.ReadBuffer(Buffer[0], Length(Buffer));
            MergedFile.WriteBuffer(Buffer[0], Length(Buffer));
        finally
            InputFile.Free;
        end;

    // ���� ���̺� ������Ʈ
        MergedFile.Position := 0;
        MergedFile.WriteBuffer(IndexTable, HEADER_SIZE);
    finally
        MergedFile.Free;
    end;
end;

class procedure TPngFileMerger.ExtractPngFromMergedFile(const MergedFileName: string; Index: Integer; const OutputPngFile: string);
var
    MergedFile: TFileStream;
    IndexTable: array[0..MAX_PNG_FILE_COUNT - 1] of Integer;
    StartPos, EndPos: Integer;
    Buffer: TBytes;
    OutputFile: TFileStream;
    i: Integer;
begin
    if (Index < 0) or (Index >= MAX_PNG_FILE_COUNT) then
        raise Exception.CreateFmt('��ȿ���� ���� �ε����Դϴ�: %d', [Index]);

    MergedFile := TFileStream.Create(MergedFileName, fmOpenRead);
    try
    // ���� ���̺� �б�
        MergedFile.ReadBuffer(IndexTable, HEADER_SIZE);
        StartPos := IndexTable[Index];

        if StartPos = -1 then
            raise Exception.CreateFmt('�ε��� %d�� ���� PNG ������ �������� �ʽ��ϴ�.', [Index]);

    // ���� ������ ���� ��ġ�� ã�Ƽ� ���� ���
        EndPos := MergedFile.Size;
        for i := Index + 1 to MAX_PNG_FILE_COUNT - 1 do
        begin
            if IndexTable[i] <> -1 then
            begin
                EndPos := IndexTable[i];
                Break;
            end;
        end;

    // PNG ������ �б�
        MergedFile.Position := StartPos;
        SetLength(Buffer, EndPos - StartPos);
        MergedFile.ReadBuffer(Buffer[0], Length(Buffer));

    // ��� ���Ϸ� ����
        OutputFile := TFileStream.Create(OutputPngFile, fmCreate);
        try
            OutputFile.WriteBuffer(Buffer[0], Length(Buffer));
        finally
            OutputFile.Free;
        end;
    finally
        MergedFile.Free;
    end;
end;

class function TPngFileMerger.GetPngCount(const MergedFileName: string): Integer;
var
    Header: TArray<Integer>;
    i: Integer;
begin
    Result := 0;
    Header := ReadHeader(MergedFileName);

    if Length(Header) = 0 then
        Exit;

    Result := 0;
    for i := 0 to Length(Header) - 1 do
    begin
        if Header[i] < 0 then
            Exit;
        Inc(Result);
    end;
end;

class function TPngFileMerger.CreatePngFromMergedFile(const MergedFileName: string; Index: Integer): TPngImage;
var
    MergedFile: TFileStream;
    ByteStream: TBytesStream;
    IndexTable: array[0..MAX_PNG_FILE_COUNT - 1] of Integer;
    StartPos, EndPos: Integer;
    Buffer: TBytes;
    PngImage: TPngImage;
    i: Integer;
begin

    if (Index < 0) {or (Index >= MAX_PNG_FILE_COUNT)} then
    begin
        Index := 0;
     //   raise Exception.CreateFmt('��ȿ���� ���� �ε����Դϴ�: %d', [Index]);
    end;

    MergedFile := TFileStream.Create(MergedFileName, fmOpenRead);
    try
    // ���� ���̺� �б�
        MergedFile.ReadBuffer(IndexTable, HEADER_SIZE);

        for i := 0 to MAX_PNG_FILE_COUNT - 1 do
        begin
            if IndexTable[i] < 0 then
            begin
                Index := Index mod i;           // Index over�� ��ȯ
                Break;
            end;
        end;


        StartPos := IndexTable[Index];
        if StartPos = -1 then
            raise Exception.CreateFmt('�ε��� %d�� ���� PNG ������ �������� �ʽ��ϴ�.', [Index]);


        // ���� ������ ���� ��ġ�� ã�Ƽ� ���� ���
        EndPos := MergedFile.Size;
        for i := Index + 1 to MAX_PNG_FILE_COUNT - 1 do
        begin
            if IndexTable[i] <> -1 then
            begin
                EndPos := IndexTable[i];
                Break;
            end;
        end;


    // PNG ������ �б�
        MergedFile.Position := StartPos;
        SetLength(Buffer, EndPos - StartPos);
        MergedFile.ReadBuffer(Buffer[0], Length(Buffer));

    // TPngImage�� ��ȯ
        PngImage := TPngImage.Create;
        try
            ByteStream := TBytesStream.Create(Buffer);
            PngImage.LoadFromStream(ByteStream);
            Result := PngImage;
        except
            PngImage.Free;
            raise;
        end;
    finally
        SetLength(Buffer, 0);
        ByteStream.Free;
        MergedFile.Free;
    end;
end;

end.

