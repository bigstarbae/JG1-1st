{
    Ver.20200119.00

    : Ch 크기 및 Ch별 Range등을 유동적으로 설정하게끔 수정
}
unit BoxLibEC;
{$I mydefine.inc}

interface

uses
    Windows, Sysutils, Forms, Range, RatioTable, EtherCatUnit, BaseDAQ, BaseAD,
    BaseCounter;

type
    TReadAdValue = procedure of object;

    TADREAD_ORD = (aoQueWithSpeed, aoReadQueue, aoReadSum, aoReadSumWithSpeed);

    TZERO_ORD = (zo_NONE, zo_CURR);

    TADUnitInfo = packed record
        mDisp: array of double;
        mUnitHi, mUnitLo: array of double;

        constructor Create(BuffLen: integer);
        procedure Deinit;

        function CalcValue(CH: integer; AD: TBaseAD): double;
    end;

    TUserECAD = class(TECAD)
    private
        mUnitInfo: TADUnitInfo;

        function CalcValue(CH: integer): double; override;
    public
        constructor Create(RModules: array of TECModule); overload;
        constructor Create(RModules: array of TECModule; aDisp, aUnitHi, aUnitLo: array of double; aRefer: array of integer); overload;
        destructor Destroy; override;

        function ReadF(CH: integer): double; override;

        procedure Init(Disp, UnitHi, UnitLo: array of double; StartCh: integer = 0; EndCh: integer = 0); overload;
        procedure Init(Disp, UnitHi, UnitLo, Offset: double; StartCh: integer = 0; EndCh: integer = 0); overload;

        function GetRawValue(CH: integer): double; override;

    end;

    TUserADCh = class
    private
        mCh: integer;
        mAD: TBaseAD;
    public
        constructor Create(AD: TBaseAD; CH: integer);
        destructor Destroy; override;

        procedure Initial(ClearAll: boolean = true);
        procedure SetZero;
        procedure ResetZero;
        procedure SetRelease;
        function IsZeroed: boolean;
        function IsRead: boolean;
        function GetValue: double;
        procedure SetOffset(Value: double);

        property CH: integer read mCH;
    end;

    TUserADChArray = array of TUserADCh;

    TManAD = class
    private
        mAD: TBaseAD;
        mnAD: array[0..MAX_AD_CH_COUNT - 1] of TUserADCH;
    public
        constructor Create(AD: TBaseAD);
        destructor Destroy; override;

        function GetItem(CH: integer): TUserADCh;
        function GetItems: TBaseAD;

        function GetItemsByCh(CHs: array of integer): TUserADChArray;

    end;

    TCTUnitInfo = packed record
        mDisp: array of single;
        mDistPerPulse: array of double;

        constructor Create(Disp: array of single; DistPerPulse: array of double);

        function CalcValue(CH: integer; CT: TBaseCounter): double;
    end;

    TUserECCT = class(TECCT)
    private
        mPulseToDistance: array of double;
        mDisp: array of Single;

    public
        constructor Create(SrcIdxs, ResetIdxs: array of integer; APulseToDist: array of double; ADisp: array of single);
        destructor Destroy(); override;

        function GetValue(Ch: integer): double; override;
    end;

    TUserCTCH = class
    private
        mCT: TBaseCounter;
        mCH: integer;
    public
        constructor Create(CT: TBaseCounter; CH: integer);
        destructor Destroy; override;

        procedure SetZero;
        function GetValue: double;
        procedure SetOffset(Value: double);

        property CH: integer read mCH;
    end;

    TManCT = class
    private
        mCT: array of TBaseCounter;
        mnCT: array of TUserCTCH;
    public
        constructor Create(CT: array of TBaseCounter);
        destructor Destroy; override;

        function GetItem(CH: integer): TUserCTCh;
        function GetItems(ACarIndex: integer): TBaseCounter;

        function Count: integer;
    end;

    TUserECAT = class(TECAT)
    private
        mUnitInfo: TADUnitInfo;
    public
        constructor Create(SrcIdxs: array of integer);
        destructor Destroy; override;

        function GetValue(Ch: integer): double; override;
        procedure Init(Disp, UnitHi, UnitLo, Offset: double; StartCh: integer = 0; EndCh: integer = 0); overload;
    end;

implementation

uses
    Inifiles, myutils, Math, Log;

const
    READ_AD_COUNT = 3;
    MAX_OFFSET = 0;
    READ_COUNT = 20;
    READ_TIME = 10.0; // 1000 ms unit

    REAL_COUNT = 100;
    REAL_READ = 20;
    MaxTsAD = 250;
    _INT_FILTER = false;
    TInputRange: array[0..8] of TRange = ((
        mMin: -5;
        mMax: 5;
    ), (
        mMin: -2.5;
        mMax: 2.5;
    ), (
        mMin: -1.25;
        mMax: 1.25;
    ), (
        mMin: -0.625;
        mMax: 0.625;
    ), (
        mMin: -10;
        mMax: 10;
    ), (
        mMin: 0;
        mMax: 10;
    ), (
        mMin: 0;
        mMax: 5;
    ), (
        mMin: 0;
        mMax: 2.5;
    ), (
        mMin: 0;
        mMax: 1.25;
    ));



{ TUserECAD }

function TUserECAD.CalcValue(CH: integer): double;
begin
    Result := mUnitInfo.CalcValue(CH, self) + mOffset[CH];
    mValues[CH] := Result;
end;

constructor TUserECAD.Create(RModules: array of TECModule);
begin
    inherited Create(RModules, 2);

    mUnitInfo.Create(mChCount);     // 조상 Create에서 mChcount가 계산됨

end;

constructor TUserECAD.Create(RModules: array of TECModule; aDisp, aUnitHi, aUnitLo: array of double; aRefer: array of integer);
var
    i: integer;
begin

    inherited Create(RModules, 2);

    mUnitInfo.Create(mChCount);     // 조상 Create에서 mChcount가 계산됨

    Init(aDisp, aUnitHi, aUnitLo);

end;

destructor TUserECAD.Destroy;
begin
    mUnitInfo.Deinit;
    inherited;
end;

function TUserECAD.GetRawValue(CH: integer): double;
begin
    with mUnitInfo do
    begin
        Result := (((mUnitHi[CH] - mUnitLo[CH]) * (GetRawData(CH))) / Resolution) + mUnitLo[CH];
        Result := Result * mDisp[CH];
    end;
end;

procedure TUserECAD.Init(Disp, UnitHi, UnitLo, Offset: double; StartCh, EndCh: integer);
var
    i: integer;
begin
    if EndCh <= 0 then
        EndCh := StartCh;

    if EndCh > mMaxChCount - 1 then
        EndCh := mMaxChCount - 1;

    if StartCh > EndCh then
        StartCh := EndCh;

    with mUnitInfo do
    begin
        for i := StartCh to EndCh do
        begin
            mDisp[i] := Disp;
            mUnitHi[i] := UnitHi;
            mUnitLo[i] := UnitLo;
            mOffset[i] := Offset;
            SetRange(i, TInputRange[4]);         // E.Cat +-10V 고정
        end;
    end;

end;

procedure TUserECAD.Init(Disp, UnitHi, UnitLo: array of double; StartCh: integer; EndCh: integer);
var
    i: integer;
begin

    if EndCh <= 0 then
        EndCh := Length(Disp) - 1;

    if EndCh > mMaxChCount - 1 then
        EndCh := mMaxChCount - 1;

    if StartCh > EndCh then
        StartCh := EndCh;

    with mUnitInfo do
    begin
        for i := StartCh to EndCh do
        begin
            mDisp[i] := Disp[i];
            mUnitHi[i] := UnitHi[i];
            mUnitLo[i] := UnitLo[i];
            SetRange(i, TInputRange[4])         // E.Cat +-10V 고정
        end;
    end;

end;

function TUserECAD.ReadF(CH: integer): double;
begin
    Result := GetValue(CH);
end;





//------------------------------------------------------------------------------
{ TUserADCh }
//------------------------------------------------------------------------------
constructor TUserADCh.Create(AD: TBaseAD; CH: integer);
begin
    mCh := CH;
    mAD := AD;
end;

destructor TUserADCh.Destroy;
begin
    inherited;
end;

function TUserADCh.GetValue: double;
begin
    Result := mAD.GetValue(mCH);
end;

procedure TUserADCh.Initial(ClearAll: boolean);
begin
    if ClearAll then
    begin
        //mAD.InitialAD(mCH);
        Exit;
    end;

    with mAD do
    begin
        ResetZero(mCh);
    end;
end;

procedure TUserADCh.SetOffset(Value: double);
begin
    mAD.SetOffset(mCH, Value);
end;

procedure TUserADCh.SetZero;
begin
    mAD.SetZero(mCH);
end;

procedure TUserADCh.ResetZero;
begin
    mAD.ResetZero(mCH);
end;

procedure TUserADCh.SetRelease;
begin
    mAD.ResetZero(mCH);
end;

function TUserADCh.IsRead: boolean;
begin
    Result := mAD.IsRead(mCH);
end;

function TUserADCh.IsZeroed: boolean;
begin
    Result := mAD.IsZero(mCh);
end;

//------------------------------------------------------------------------------
{ TManAD }
//------------------------------------------------------------------------------
constructor TManAD.Create(AD: TBaseAD);
begin
    mAD := AD;
end;

destructor TManAD.Destroy;
var
    i: integer;
begin
    for i := 0 to MAX_AD_CH_COUNT - 1 do
    begin
        if Assigned(mnAD[i]) then
            FreeAndNil(mnAD[i]);
    end;
    if Assigned(mAD) then
        FreeAndNil(mAD);
    mAD := nil;
    inherited;
end;

function TManAD.GetItem(CH: integer): TUserADCh;
begin
    if not Assigned(mnAD[CH]) then
        mnAD[CH] := TUserADCh.Create(mAD, CH);
    Result := mnAD[CH];
end;

function TManAD.GetItems: TBaseAD;
begin
    Result := mAD;
end;

function TManAD.GetItemsByCh(CHs: array of integer): TUserADChArray;
var
    i: integer;
begin
    SetLength(Result, Length(CHs));

    for i := 0 to Length(CHs) - 1 do
    begin
        Result[i] := GetItem(CHs[i]);
    end;

end;



{ TUserCTCH }

constructor TUserCTCH.Create(CT: TBaseCounter; CH: integer);
begin
    mCH := CH;
    mCT := CT;
end;

destructor TUserCTCH.Destroy;
begin

    inherited;
end;

function TUserCTCH.GetValue: double;
begin
    Result := mCT.GetValue(mCH);
end;

procedure TUserCTCH.SetOffset(Value: double);
begin
    mCT.SetOffset(mCH, Value);
end;

procedure TUserCTCH.SetZero;
begin
    mCT.SetZero(mCH);
end;

{ TManCT }

function TManCT.Count: integer;
begin
    Result := Length(mCT);
end;

constructor TManCT.Create(CT: array of TBaseCounter);
var
    i: integer;
begin
    SetLength(mCT, Length(CT));
    for i := 0 to Length(CT) - 1 do
        mCT[i] := CT[i];
end;

destructor TManCT.Destroy;
var
    i: integer;
begin
    for i := 0 to Length(mnCT) - 1 do
    begin
        if Assigned(mnCT[i]) then
            FreeAndNil(mnCT[i]);
    end;
    for i := 0 to Length(mCT) - 1 do
    begin
        if Assigned(mCT[i]) then
        begin
            FreeAndNil(mCT[i]);
        end;
    end;
end;

function TManCT.GetItem(CH: integer): TUserCTCh;
var
    i: integer;
begin
    Result := nil;
    if (CH div 4) >= Length(mCT) then
        Exit;

    for i := 0 to Length(mnCT) - 1 do
    begin
        if mnCT[i].CH = CH then
        begin
            Result := mnCT[i];
            Exit;
        end;
    end;
    SetLength(mnCT, Length(mnCT) + 1);
    mnCT[Length(mnCT) - 1] := TUserCTCh.Create(mCT[CH div 4], CH);
    Result := mnCT[Length(mnCT) - 1];
end;

function TManCT.GetItems(ACarIndex: integer): TBaseCounter;
begin
    Result := nil;
    if Length(mCT) <= ACarIndex then
        Exit;
    Result := mCT[ACarIndex];
end;


{ TADUnitInfo }

function TADUnitInfo.CalcValue(Ch: integer; AD: TBaseAD): double;
begin
    Result := (((mUnitHi[Ch] - mUnitLo[Ch]) * (AD.GetDigital(Ch))) / AD.Resolution) + mUnitLo[Ch];
    Result := Result * mDisp[Ch];
end;

constructor TADUnitInfo.Create(BuffLen: integer);
begin
    SetLength(mDisp, BuffLen);
    SetLength(mUnitLo, BuffLen);
    SetLength(mUnitHi, BuffLen);
end;

procedure TADUnitInfo.Deinit;
begin
    mDisp := nil;
    mUnitHi := nil;
    mUnitLo := nil;
end;

{ TCTUnitInfo }

constructor TCTUnitInfo.Create(Disp: array of single; DistPerPulse: array of double);
var
    i: integer;
begin
    SetLength(mDisp, Length(Disp));
    SetLength(mDistPerPulse, Length(Disp));

    CopyMemory(@mDisp[0], @Disp[0], sizeof(single) * Length(Disp));
    CopyMemory(@mDistPerPulse[0], @DistPerPulse[0], sizeof(double) * Length(DistPerPulse));
end;

function TCTUnitInfo.CalcValue(CH: integer; CT: TBaseCounter): double;
begin
    Result := CT.GetValue(CH) * mDistPerPulse[CH] * mDisp[CH];
end;



{ TUserECCT }

constructor TUserECCT.Create(SrcIdxs, ResetIdxs: array of integer; APulseToDist: array of double; ADisp: array of single);
var
    i: integer;
begin
    inherited Create(SrcIdxs, ResetIdxs);
    //mUnitInfo.Create(APulseToDist,ADisp);
    SetLength(mPulseToDistance, Length(SrcIdxs));
    SetLength(mDisp, Length(SrcIdxs));

    for i := 0 to Length(mPulseToDistance) - 1 do
    begin
        mPulseToDistance[i] := APulseToDist[i];
    end;

    for i := 0 to Length(mDisp) - 1 do
    begin
        mDisp[i] := ADisp[i];
    end;

end;

destructor TUserECCT.Destroy;
begin
    mPulseToDistance := nil;
    mDisp := nil;
    inherited Destroy;

end;

function TUserECCT.GetValue(Ch: integer): double;
begin
    Result := mDatas[Ch] * mPulseToDistance[Ch] * mDisp[Ch] + mOffset[Ch];    //mUnitInfo.CalcValue(Ch, Self);
end;

{ TUserECAT }

constructor TUserECAT.Create(SrcIdxs: array of integer);
begin
    inherited Create(SrcIdxs);

    mUnitInfo.Create(mMaxChCount);
    mResolution := 1000; // AT 카드 기본 Input Filter에 해당하는 Resolution 값.
end;

destructor TUserECAT.Destroy;
begin

    inherited;
end;

function TUserECAT.GetValue(Ch: integer): double;
begin
    Result := mDatas[Ch] + mOffset[Ch];
end;

procedure TUserECAT.Init(Disp, UnitHi, UnitLo, Offset: double; StartCh, EndCh: integer);
var
    i: Integer;
begin
    if EndCh <= 0 then
        EndCh := StartCh;

    if EndCh > mMaxChCount - 1 then
        EndCh := mMaxChCount - 1;

    if StartCh > EndCh then
        StartCh := EndCh;

    with mUnitInfo do
    begin
        for i := StartCh to EndCh do
        begin
            mDisp[i] := Disp;
            mUnitHi[i] := UnitHi;
            mUnitLo[i] := UnitLo;
            mOffset[i] := Offset;
            SetRange(i, TInputRange[4]);
        end;
    end;

end;

initialization

finalization

end.

