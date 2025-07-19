{
  22.01.17 : CAN ID 필터링 용도
  23.04.06 : Unused R/WIDs Read/Write(TStirng..) 함수 추가
  24.03.14 : 동기화용 CS 추가
}
unit CanIDFilter;


interface
uses
    Windows, Sysutils, Classes, Generics.Collections, SyncObjs, IniFiles;

type
    TCanIDUseInfo = packed record
        mRUse,
        mWUse: Boolean;
    end;

    TCanIDFilter = class
    protected
        mUnusedRIDs,
        mUnusedWIDs,
        mRIDs,
        mWIDs:      TDictionary<Integer, bool>;
        mCS:        TCriticalSection;

        mSaveUsedIDs:   Boolean;

    public
        constructor Create;
        destructor  Destroy; override;

        procedure AddRID(ID: Integer; Use: Boolean = true);
        procedure AddWID(ID: Integer; Use: Boolean = true);

        procedure AddUnusedRID(ID: Integer; Use: Boolean = true);
        procedure AddUnusedWID(ID: Integer; Use: Boolean = true);


        function IsRIDExists(ID: Integer): Boolean;
        function IsWIDExists(ID: Integer): Boolean;


        procedure Read(RStrings, WStrings: TStrings; StartNo: Integer = 0); overload;
        procedure Write(RStrings, WStrings: TStrings; StartNo: Integer = 0); overload;

        procedure ReadUnused(RStrings, WStrings: TStrings; StartNo: Integer = 0); overload;
        procedure WriteUnused(RStrings, WStrings: TStrings; StartNo: Integer = 0); overload;


        // Ini File 간이 버전
        procedure Read(IniFile: TIniFile); overload;
        procedure Write(IniFile: TIniFile); overload;

        // Ini File Full 저장용
        function Load(FilePath: string): Boolean;
        function Save(FilePath: string): Boolean;

    end;

implementation
uses
    MyUtils, Math;

{ TCanIDFilter }

constructor TCanIDFilter.Create;
begin
    mRIDs :=  TDictionary<Integer, bool>.Create;
    mWIDs :=  TDictionary<Integer, bool>.Create;

    mUnusedRIDs :=  TDictionary<Integer, bool>.Create;
    mUnusedWIDs :=  TDictionary<Integer, bool>.Create;

    mCS :=  TCriticalSection.Create;

end;

destructor TCanIDFilter.Destroy;
begin
    FreeAndNil(mCS);

    mRIDs.Free;
    mWIDs.Free;

    mUnusedRIDs.Free;
    mUnusedWIDs.Free;

end;

procedure TCanIDFilter.AddRID(ID: Integer; Use: Boolean);
begin
    if not mRIDs.ContainsKey(ID) then
        mRIDs.Add(ID, Use);
end;

procedure TCanIDFilter.AddUnusedRID(ID: Integer; Use: Boolean);
begin
    if not mUnusedRIDs.ContainsKey(ID) then
        mUnusedRIDs.Add(ID, Use);
end;

procedure TCanIDFilter.AddUnusedWID(ID: Integer; Use: Boolean);
begin
    if not mUnusedWIDs.ContainsKey(ID) then
        mUnusedWIDs.Add(ID, Use);
end;

procedure TCanIDFilter.AddWID(ID: Integer; Use: Boolean);
begin
    if not mWIDs.ContainsKey(ID) then
        mWIDs.Add(ID, Use);
end;


function TCanIDFilter.IsRIDExists(ID: Integer): Boolean;
begin
    mCS.Acquire;

    try
        if mUnusedRIDs.ContainsKey(ID) then
            Exit(false);

        if mRIDs.Count = 0 then
            Exit(true);

        Result := mRIDs.ContainsKey(ID);

    finally
        mCS.Release;
    end;
end;

function TCanIDFilter.IsWIDExists(ID: Integer): Boolean;
begin
    mCS.Acquire;

    try
        if mUnusedWIDs.ContainsKey(ID) then
            Exit(false);

        if mWIDs.Count = 0 then
            Exit(true);

        Result := mWIDs.ContainsKey(ID);

    finally
        mCS.Release;
    end;

    
end;

function TCanIDFilter.Load(FilePath: string): Boolean;
var
    Str: string;
    TokCount, i, Count: Integer;
    IniFile: TIniFile;
    Tokens: array[0 .. 4] of string;
begin
    IniFile := TIniFile.Create(FilePath);

    try

        Count := IniFile.ReadInteger('RIDs', 'COUNT', 0);

        if Count > 0 then
            mRIDs.Clear;
        for i:= 0 to Count - 1 do
        begin
            Str := IniFile.ReadString('RIDs', IntToStr(i + 1), '');
            TokCount := ParseByDelimiter(Tokens, TokCount, Str, ',');
            if TokCount = 2 then
            begin
                AddRID(StrToInt(Tokens[0]), StrToBool(Tokens[1]));
            end;
        end;

        Count := IniFile.ReadInteger('WIDs', 'COUNT', 0);

        if Count > 0 then
            mWIDs.Clear;
        for i:= 0 to Count - 1 do
        begin
            Str := IniFile.ReadString('WIDs', IntToStr(i + 1), '');
            TokCount := ParseByDelimiter(Tokens, TokCount, Str, ',');
            if TokCount = 2 then
            begin
                AddWID(StrToInt(Tokens[0]), StrToBool(Tokens[1]));
            end;
        end;



    finally
        IniFile.Free;
    end;

end;




function TCanIDFilter.Save(FilePath: string): Boolean;
var
    Str: string;
    n, Key: Integer;
    IniFile: TIniFile;
begin
    IniFile := TIniFile.Create(FilePath);

    try
        IniFile.WriteInteger('RIDs', 'COUNT', mRIDs.Count);
        IniFile.WriteInteger('WIDs', 'COUNT', mWIDs.Count);

        n := 1;
        for Key in mRIDs.Keys do
        begin
            Str := '$' + IntToHex(Key, 4) + ', ' + BoolToStr(mRIDs[Key], true);
            IniFile.WriteString('RIDs', IntToStr(n), Str);
            Inc(n);
        end;
        n := 1;
        for Key in mWIDs.Keys do
        begin
            Str := '$' + IntToHex(Key, 4) + ', ' + BoolToStr(mWIDs[Key], true);
            IniFile.WriteString('WIDs', IntToStr(n), Str);
            Inc(n);
        end;

    finally
        IniFile.Free;
    end;

end;

procedure TCanIDFilter.Read(IniFile: TIniFile);
var
    Str: string;
    TokCount, i: Integer;
    Tokens: array[0 .. 99] of string;

begin
    Str := IniFile.ReadString('CAN FILTER', 'USED CAN R.IDs', '');
    TokCount := Min(99, ParseByDelimiter(Tokens, 98, Str, ','));

    for i := 0 to TokCount - 1 do
    begin
        AddRID(StrToInt(Tokens[i]), true);
    end;

    Str := IniFile.ReadString('CAN FILTER', 'USED CAN W.IDs', '');
    TokCount := Min(99, ParseByDelimiter(Tokens, 98, Str, ','));

    for i := 0 to TokCount - 1 do
    begin
        AddWID(StrToInt(Tokens[i]), true);
    end;

    //----------------------------------------------------------


    Str := IniFile.ReadString('CAN FILTER', 'UNUSED CAN R.IDs', '');
    TokCount := Min(99, ParseByDelimiter(Tokens, 98, Str, ','));

    for i := 0 to TokCount - 1 do
    begin
        if not mUnusedRIDs.ContainsKey(StrToInt(Tokens[i])) then
            mUnusedRIDs.Add(StrToInt(Tokens[i]), true);
    end;


    Str := IniFile.ReadString('CAN FILTER', 'UNUSED CAN W.IDs', '');
    TokCount := Min(99, ParseByDelimiter(Tokens, 98, Str, ','));

    for i := 0 to TokCount - 1 do
    begin
        if not mUnusedWIDs.ContainsKey(StrToInt(Tokens[i])) then
            mUnusedWIDs.Add(StrToInt(Tokens[i]), true);
    end;


end;



procedure TCanIDFilter.Write(IniFile: TIniFile);
var
    Key: Integer;
    Str: string;
begin

    if mRIDs.Count > 0 then
    begin
        for Key in mRIDs.Keys do
        begin
            Str := Str + '$' + IntToHex(Key, 4) + ', '
        end;
        Delete(Str, Length(Str) - 1, 2);
    end;

    IniFile.WriteString('CAN FILTER', 'USED CAN R.IDs', Str);

    Str := '';
    if mWIDs.Count > 0 then
    begin
        for Key in mWIDs.Keys do
        begin
            Str := Str + '$' + IntToHex(Key, 4) + ', '
        end;
        Delete(Str, Length(Str) - 1, 2);
    end;

    IniFile.WriteString('CAN FILTER', 'USED CAN W.IDs', Str);

    // -----------------------------------------------
    Str := '';
    if mUnusedRIDs.Count > 0 then
    begin
        for Key in mUnusedRIDs.Keys do
        begin
            Str := Str + '$' + IntToHex(Key, 4) + ', '
        end;
        Delete(Str, Length(Str) - 1, 2);
    end;

    IniFile.WriteString('CAN FILTER', 'UNUSED CAN R.IDs', Str);

    Str := '';
    if mUnusedWIDs.Count > 0 then
    begin
        for Key in mUnusedWIDs.Keys do
        begin
            Str := Str + '$' + IntToHex(Key, 4) + ', '
        end;
        Delete(Str, Length(Str) - 1, 2);
    end;

    IniFile.WriteString('CAN FILTER', 'UNUSED CAN W.IDs', Str);


end;




procedure TCanIDFilter.WriteUnused(RStrings, WStrings: TStrings; StartNo: Integer);
var
    n, Key: Integer;
begin
    n := StartNo;
    for Key in mUnusedRIDs.Keys do
    begin
        if n >= RStrings.Count then
            RStrings.Add('');

        RStrings.Strings[n] := '$' + IntToHex(Key, 4);
        RStrings.Objects[n] := TObject(mUnusedRIDs[Key]);
        Inc(n);
    end;

    n := StartNo;
    for Key in mUnusedWIDs.Keys do
    begin
        if n >= WStrings.Count then
            WStrings.Add('');

        WStrings.Strings[n] := '$' + IntToHex(Key, 4);
        WStrings.Objects[n] := TObject(mUnusedWIDs[Key]);
        Inc(n);
    end;

end;

procedure TCanIDFilter.Read(RStrings, WStrings: TStrings; StartNo: Integer);
var
    i: Integer;
begin
    mRIDs.Clear;
    for i := StartNo to RStrings.Count - 1 do
    begin
        if RStrings.Strings[i] <> '' then
        begin
            if Pos('$', RStrings.Strings[i]) <= 0 then
                RStrings.Strings[i] := '$' + RStrings.Strings[i];

            AddRID(StrToInt(RStrings.Strings[i]), Boolean(RStrings.Objects[i]));
        end;
    end;

    mWIDs.Clear;
    for i := StartNo to WStrings.Count - 1 do
    begin
        if WStrings.Strings[i] <> '' then
        begin
            if Pos('$', WStrings.Strings[i]) <= 0 then
                WStrings.Strings[i] := '$' + WStrings.Strings[i];

            AddWID(StrToInt(WStrings.Strings[i]), Boolean(WStrings.Objects[i]));
        end;
    end;

end;

procedure TCanIDFilter.ReadUnused(RStrings, WStrings: TStrings; StartNo: Integer);
var
    i: Integer;
begin
    mUnusedRIDs.Clear;
    for i := StartNo to RStrings.Count - 1 do
    begin
        if RStrings.Strings[i] <> '' then
        begin
            if Pos('$', RStrings.Strings[i]) <= 0 then
                RStrings.Strings[i] := '$' + RStrings.Strings[i];

            AddUnusedRID(StrToInt(RStrings.Strings[i]), Boolean(RStrings.Objects[i]));
        end;
    end;

    mUnusedWIDs.Clear;
    for i := StartNo to WStrings.Count - 1 do
    begin
        if WStrings.Strings[i] <> '' then
        begin
            if Pos('$', WStrings.Strings[i]) <= 0 then
                WStrings.Strings[i] := '$' + WStrings.Strings[i];

            AddUnusedWID(StrToInt(WStrings.Strings[i]), Boolean(WStrings.Objects[i]));
        end;
    end;
end;

procedure TCanIDFilter.Write(RStrings, WStrings: TStrings; StartNo: Integer);
var
    n, Key: Integer;
begin
    n := StartNo;
    for Key in mRIDs.Keys do
    begin
        if n >= RStrings.Count then
            RStrings.Add('');

        RStrings.Strings[n] := '$' + IntToHex(Key, 4);
        RStrings.Objects[n] := TObject(mRIDs[Key]);
        Inc(n);
    end;

    n := StartNo;
    for Key in mWIDs.Keys do
    begin
        if n >= WStrings.Count then
            WStrings.Add('');

        WStrings.Strings[n] := '$' + IntToHex(Key, 4);
        WStrings.Objects[n] := TObject(mWIDs[Key]);
        Inc(n);
    end;

end;

end.
