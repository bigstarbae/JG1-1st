{
    24.08: Melsec용
}
unit PLCAddInfo;

interface
uses
    Generics.Collections, MelsecPackEx, BaseDIO;


type
    PPLCAddInfo = ^TPLCAddInfo;
    TPLCAddInfo = packed record
        mID:        Byte;           // 구분 Tag 용도 ex> 파트넘버, 바코드 or 툴 데이터
        mDevName:   Char;
        mAdd:       Integer;
        mWDLen:     Integer;
        mDataType:  TDataTypes;

        mBeginCh:   Integer;        // Read/Write Bit단위 시작 Idx
        mIsDataIOType: Boolean;       // TDioMonitorDevORD.devDATA 인가?

        constructor Create(DataType: TDataTypes; DevName: Char; Add, WDLen: Integer; ID: Integer = 0; IsDataIOType: Boolean = False);

        function    IsEmpty: boolean;
        procedure   Clear;
    end;


    PPLCAddInfoList = TList<PPLCAddInfo>;
    TPLCAddInfoArray = array of TPLCAddInfo;

    TPLCAddInfos = class
    private
        mItems:         PPLCAddInfoList;
        mIdx:           Integer;
        mCycling:       boolean;

    public
        constructor Create(Cycling: boolean = true); overload;
        constructor Create(Items: array of TPLCAddInfo; Cycling: boolean = true); reintroduce; overload;
        destructor  Destroy; override;


        procedure Reset;

        function CurItem: PPLCAddInfo;
        function Next:PPLCAddInfo;

        function Add(AddInfo: TPLCAddInfo): PPLCAddInfo; overload;
        function Add(DataType: TDataTypes; DevName: Char; Add, WDLen: Integer; ID: Integer = 0): PPLCAddInfo; overload;

        function Count: Integer;

        property IsCycling: boolean read mCycling write mCycling;
    end;

implementation

{ TPLCAddInfo }


procedure TPLCAddInfo.Clear;
begin
    mAdd := 0;
    mWDLen := 0;
end;

constructor TPLCAddInfo.Create(DataType: TDataTypes; DevName: Char; Add, WDLen: Integer; ID: Integer; IsDataIOType: Boolean);
begin
    mID := ID;
    mDataType := DataType;
    mDevName := DevName;
    mAdd := Add;
    mWDLen := WDLen;
    mBeginCh := 0;
    mIsDataIOType := IsDataIOType;
end;

function TPLCAddInfo.IsEmpty: boolean;
begin
    Result := (mAdd = 0) or (mWDLen = 0);
end;

{ TPLCAddInfos }
constructor TPLCAddInfos.Create(Cycling: boolean);
begin
    mItems := PPLCAddInfoList.Create;
    mCycling := Cycling;
end;

constructor TPLCAddInfos.Create(Items: array of TPLCAddInfo; Cycling: boolean);
var
    i, ItemCount: Integer;
begin
    TPLCAddInfos.Create;

    ItemCount := Length(Items);

    for i := 0 to ItemCount - 1 do
    begin
        Add(Items[i]);
    end;

    mCycling := Cycling;

end;


destructor TPLCAddInfos.Destroy;
var
    i: PPLCAddInfo;
begin
    for i in mItems do
    begin
        Dispose(i);
    end;

    mItems.Free;
end;

function TPLCAddInfos.CurItem: PPLCAddInfo;
begin
    if Count = 0 then
        Exit(nil);

    Result := mItems[mIdx];
end;


function TPLCAddInfos.Next: PPLCAddInfo;
begin
    if mIdx < Count - 1 then
    begin
        Inc(mIdx);
        Result := mItems[mIdx]
    end
    else
    begin
        if mCycling then
        begin
            mIdx := 0;
            Exit(mItems[mIdx]);
        end;
        Result := nil;
    end;
end;

function TPLCAddInfos.Add(AddInfo: TPLCAddInfo): PPLCAddInfo;
var
    RBeginCh, i,
    LastIdx: integer;
begin
    New(Result);
    Move(ADdInfo, Result^, sizeof(TPLCAddInfo));

    mItems.Add(Result);

    if Count > 1 then
    begin
        RBeginCh := 0;

        for i := 0 to Count - 1 do
        begin
            if not mItems[i].mIsDataIOType then
                RBeginCh := RBeginCh + mItems[i].mWDLen * 16;
        end;
        mItems[Count - 1].mBeginCh := RBeginCh;
    end;
end;



function TPLCAddInfos.Add(DataType: TDataTypes; DevName: Char; Add, WDLen, ID: Integer): PPLCAddInfo;
begin
    Result := Self.Add(TPLCAddInfo.Create(DataType, DevName, Add, WDLen, ID));
end;


procedure TPLCAddInfos.Reset;
begin
    mIdx := 0;
end;


function TPLCAddInfos.Count: Integer;
begin
    Result := mItems.Count;
end;

end.
