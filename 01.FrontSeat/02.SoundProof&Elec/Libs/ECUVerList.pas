unit ECUVerList;


interface
uses
    Classes;

const
    MAX_ECU_VER_ITEM_COUNT  = 100;


type
    PECUVerItem = ^TECUVerItem;
    TECUVerItem = packed record
        mPartNo:        string;
        mECUPartNo:     string;
        mECUSWVer:      string;
        mECUHWVer:      string;

        function IsEmpty: Boolean;

        function MatchSWVer(SWVer: string): boolean;
        function MatchHWVer(HWVer: string): boolean;
        function MatchPartNo(PartNo: string): boolean;
    end;

    TECUVerList = class
    public
        mItems: array[0 .. MAX_ECU_VER_ITEM_COUNT - 1] of TECUVerItem;
        mIndexSelect: integer;

        function Load(FilePath: string): boolean;
        function Save(FilePath: string): boolean;

        function FindIdx(PartNo: string): integer;
        function Find(PartNo: string): PECUVerItem;

        function ContactEcuVerItem: TECUVerItem;

        procedure SetItem(Idx: integer; PartNo, ECUPartNo, ECUSWVer, ECUHWVer: string);
    end;

implementation
uses
    MyUtils, SysUtils, FastIniFile;

{ TECUVerItem }

function TECUVerItem.IsEmpty: Boolean;
begin
    Result := mECUPartNo = '';
end;

function TECUVerItem.MatchHWVer(HWVer: string): boolean;
begin
    Result := mECUHWVer = Trim(HWVer);
end;

function TECUVerItem.MatchPartNo(PartNo: string): boolean;
begin
    Result := mECUPartNo = Trim(PartNo);
end;

function TECUVerItem.MatchSWVer(SWVer: string): boolean;
begin
    Result := mECUSWVer = Trim(SWVer);
end;

{ TECUVerList }
var
    gDummyItem: TECUVerItem;

function TECUVerList.Find(PartNo: string): PECUVerItem;
var
    Idx: integer;
begin
    Idx := FindIdx(PartNo);
    mIndexSelect := Idx;
    if Idx < 0 then
        Result := @gDummyItem
    else
        Result := @mItems[Idx];

end;

function TECUVerList.FindIdx(PartNo: string): integer;
var
    i: integer;
begin
    for i := 0 to MAX_ECU_VER_ITEM_COUNT - 1 do
    begin
        if mItems[i].mPartNo = Trim(PartNo) then
        begin
            Exit(i);
        end;
    end;

    Result := -1;
end;

function TECUVerList.Load(FilePath: string): boolean;
var
    i, TokCount: integer;
    IniFile: TFastIniFile;
    Str: string;
    Tokens: array[0 .. 5] of string;
begin

    Result := true;

    IniFile := TFastIniFile.Create(FilePath);

    try
        for i := 0 to MAX_ECU_VER_ITEM_COUNT - 1 do
        begin
            Str := IniFile.ReadString('ECU VER INFO', IntToStr(i + 1), '');

            if Str = '' then
                Exit;

            if ParseByDelimiter(Tokens, 4, Str, ',') <> 4 then
                continue;
            mItems[i].mPartNo := Tokens[0];
            mItems[i].mECUPartNo := Tokens[1];
            mItems[i].mECUSwVer := Tokens[2];
            mItems[i].mECUHWVer := Tokens[3];
        end;

    finally
        IniFile.Free;
    end;
end;

function TECUVerList.Save(FilePath: string): boolean;
var
    i: integer;
    Str: string;
    IniFile: TFastIniFile;
begin

    Result := true;

    IniFile := TFastIniFile.Create(FilePath);

    try
        for i := 0 to MAX_ECU_VER_ITEM_COUNT - 1 do
        begin
            //if mItems[i].mPartNo = '' then Exit;

            Str := Format('%s, %s, %s, %s', [mItems[i].mPartNo, mItems[i].mECUPartNo, mItems[i].mECUSwVer, mItems[i].mECUHwVer]);

            IniFile.WriteString('ECU VER INFO', IntToStr(i + 1), Str);

        end;

    finally
        IniFile.Free;
    end;

end;

function TECUVerList.ContactEcuVerItem: TECUVerItem;
begin
    if (mIndexSelect < 0) or (mIndexSelect > 100) then // 의도 mIdx 정해져있지 않을경우 대비. 이거 없으면 엑세스 오류날수 있으므로.
        Result := mItems[0];
    Result := mItems[mIndexSelect];
end;

procedure TECUVerList.SetItem(Idx: integer; PartNo, ECUPartNo, ECUSWVer, ECUHWVer: string);
begin
    if Idx < MAX_ECU_VER_ITEM_COUNT then
    begin
        mItems[Idx].mPartNo := PartNo;
        mItems[Idx].mECUPartNo := ECUPartNo;
        mItems[Idx].mECUSWVer := ECUSWVer;
        mItems[Idx].mECUHWVer := ECUHWVer;
    end;

end;

end.
