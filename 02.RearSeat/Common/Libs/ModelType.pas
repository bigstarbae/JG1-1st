{
    Ver 241130.00: SP3 차종
}
unit ModelType;

interface

uses
    Windows, Sysutils, Classes, IniFiles, SeatType;

const
    MDL_COL_COUNT = 5;    // Strings에 설정할때 갯수

    { 모델 비트 Idx }

    MDL_BIT_SEATS_TYPE = 0;
    MDL_BIT_4P = 0;
    MDL_BIT_5P = 1;
    MDL_BIT_6P = 2;
    MDL_BIT_7P = 3;
    MDL_BIT_SEATS_TYPE_END = 4;
    MDL_BIT_POS_TYPE = 5;
    MDL_BIT_LH = 5;
    MDL_BIT_RH = 6;
    MDL_BIT_POS_TYPE_END = 6;

    // 차종
    MDL_BIT_CAR_TYPE = 8;
    MDL_BIT_JG1 = 8;
    MDL_BIT_SPARE1 = 9;
    MDL_BIT_CAR_TYPE_END = MDL_BIT_SPARE1;
    MDL_BIT_CAR_SUB_TYPE = 12;
    MDL_BIT_STD = 12;
    MDL_BIT_SE = 13;
    MDL_BIT_CAR_SUB_TYPE_END = 13;

    // 옵션
    MDL_BIT_HV_START = 16;
    MDL_BIT_HEAT = 16;
    MDL_BIT_HV = 17;
    MDL_BIT_HVPSU = 18;
    MDL_BIT_SAU = 19;
    MDL_BIT_BUCKLE_START = 21;
    MDL_BIT_WARN_BUCKLE = 21;
    MDL_BIT_ILL_BUCKLE = 22;
    MDL_BIT_CENTER_BUCKLE = 23;

    MDL_BIT_WALKIN = 25;
    MDL_BIT_RELAX = 26;
    MDL_BIT_PE = 27;

function MakeBits(Count: Integer): WORD;

function MakeModelMask: DWORD;
function MakeModelMaskForAP: DWORD;

const
    MDL_MASK = $00000000;

type
    TMdlOptType = (motHVPSU, motSAU, motWarnBuckle, motILLBuckle, motCTRBuckle, motWalkin, motRelax, motPE);

    TModelType = packed record
        mID: Integer;               // 차후 모델만 분리시 확장용
        mDataBits: DWORD;

        constructor Create(DataBits: DWORD; ID: Integer = 0);

        procedure Clear;

        function IsEqual(ModelType: TModelType; Mask: DWORD = $FFFFFFFF): Boolean;
        procedure CopyFrom(SrcDataBits: DWORD; SIdx, Len: Integer);

        procedure SetSeatsType(AType: TSEATS_TYPE); overload;
        procedure SetSeatsType(AType: Integer); overload;
        procedure SetPosType(AType: TPOS_TYPE); overload;
        procedure SetPosType(AType: Integer); overload;
        procedure SetCarType(AType: TCAR_TYPE); overload;
        procedure SetCarType(AType: Integer); overload;
        procedure SetCarTrimType(AType: TCAR_TRIM_TYPE); overload;
        procedure SetCarTrimType(AType: Integer); overload;
        procedure SetHVType(AType: THV_TYPE); overload;
        procedure SetHVType(AType: Integer); overload;
        procedure SetOpt(OptType: TMdlOptType; Val: Boolean);

        function GetSeatsType(): TSEATS_TYPE;
        function GetSeatsTypeToInt(): Integer;
        function GetPosType(): TPOS_TYPE;
        function GetPosTypeToInt(): Integer;
        function GetCarType(): TCAR_TYPE;
        function GetCarTypeToInt(): Integer;
        function GetCarTrimType(): TCAR_TRIM_TYPE;
        function GetCarTrimTypeToInt(): Integer;
        function GetHVType(): THV_TYPE;
        function GetHVTypeToInt(): Integer;
        function GetOpt(OptType: TMdlOptType): Boolean;

        function GetUseMotors: TMTR_TYPE_array;

        function Is4P: Boolean;
        function Is5P: Boolean;
        function Is6P: Boolean;
        function Is7P: Boolean;

        function IsRL: Boolean;
        function IsRR: Boolean;

        function IsHeat: Boolean;
        function IsHV: Boolean;

        function IsHeatRL: Boolean;
        function IsHeatRR: Boolean;
        function IsVentRL: Boolean;
        function IsVentRR: Boolean;

        function IsBlower: Boolean;

        function IsHVPSU: Boolean;
        function IsSAU: Boolean;
        function IsECU: Boolean;

        function IsSE: Boolean;
        function IsSTD: Boolean;

        function IsIMS: Boolean;

        function IsWalkin: Boolean;
        function IsRelax: Boolean;
        function IsPE: Boolean;

        function IsNoneBuckle: Boolean;
        function IsWarnBuckle: Boolean;
        function IsIllBuckle: Boolean;
        function IsCenterBuckle: Boolean;
        function IsBukcle: Boolean;

        function IsSlideMtrExists: Boolean;
        function IsRelaxMtrExists: Boolean;
        function IsTiltMtrExists: Boolean;
        function IsCushTiltMtrExists: Boolean;
        function IsShoulderMtrExists: Boolean;
        function IsReclineMtrExists: Boolean;
        function IsWalkinTiltMtrExists: Boolean;
        function IsHeadRestMtrExists: Boolean;
        function IsLongSlideMtrExists: Boolean;

        function CanRLHeatTest: Boolean;
        function CanRLVentTest: Boolean;
        function CanRRHeatTest: Boolean;
        function CanRRVentTest: Boolean;

        function CanHtrWiringTest: Boolean;

        // 커넥터 객체 찾기 Key용도
        function MakeMainConID: string;
        function MakeMainConName: string;
        function MakeSwConName: string;

        // To Text(Str)
        function ToStr(): string;
        function MakePartName(): string;

        function GetSeatsTypeStr: string;
        function GetPosTypeStr: string;
        function GetCarTypeStr: string;
        function GetCarTrimTypeStr: string;
        function GetHVTypeStr: string;
        function GetBuckleTypeStr: string;
        function GetECUTypeStr: string;
        function GetOptStr(OptType: TMdlOptType): string;

        procedure WriteAsType(Strings: TStrings; StartCol: Integer = 0);      // 모델 사양 표기
        procedure WriteAsOptName(Strings: TStrings; OptTypes: array of TMdlOptType);      // 모델 옵션 표기
    private

    end;

implementation

uses
    Math, MyUtils, LangTran;


// ------------------------------------------------------------------------------
function MakeModelMask: DWORD;
var
    i: Integer;
begin
    Result := 0;

    for i := MDL_BIT_SEATS_TYPE to MDL_BIT_SEATS_TYPE_END do
        SetBit(Result, i, True);

    for i := MDL_BIT_POS_TYPE to MDL_BIT_POS_TYPE_END do
        SetBit(Result, i, True);

    for i := MDL_BIT_CAR_TYPE to MDL_BIT_CAR_TYPE_END do
        SetBit(Result, i, True);

    for i := MDL_BIT_CAR_SUB_TYPE to MDL_BIT_CAR_SUB_TYPE do
        SetBit(Result, i, True);

end;
function MakeModelMaskForAP: DWORD;
var
    i: Integer;
begin
    Result := 0;

    for i := MDL_BIT_POS_TYPE to MDL_BIT_POS_TYPE_END do
        SetBit(Result, i, True);

    for i := MDL_BIT_CAR_TYPE to MDL_BIT_CAR_TYPE_END do
        SetBit(Result, i, True);
end;

// ------------------------------------------------------------------------------
function MakeBits(Count: Integer): WORD;
var
    i: Integer;
begin
    Result := 0;
    for i := 0 to Count - 1 do
    begin
        Result := Result + (1 shl i);
    end;
end;
// ------------------------------------------------------------------------------

{ TModelType }

procedure TModelType.SetHVType(AType: THV_TYPE);
begin
    SetBit(mDataBits, MDL_BIT_HEAT, False);
    SetBit(mDataBits, MDL_BIT_HV, False);

    case AType of
        htHeat:
            SetBit(mDataBits, MDL_BIT_HEAT, True);
        htHV:
            SetBit(mDataBits, MDL_BIT_HV, True);
    end;
end;

procedure TModelType.SetOpt(OptType: TMdlOptType; Val: Boolean);
begin
    case OptType of
        motHVPSU:
            SetBit(mDataBits, MDL_BIT_HVPSU, Val);
        motSAU:
            SetBit(mDataBits, MDL_BIT_SAU, Val);
        motWarnBuckle:
            SetBit(mDataBits, MDL_BIT_WARN_BUCKLE, Val);
        motILLBuckle:
            SetBit(mDataBits, MDL_BIT_ILL_BUCKLE, Val);
        motCTRBuckle:
            SetBit(mDataBits, MDL_BIT_CENTER_BUCKLE, Val);
        motWalkin:
            SetBit(mDataBits, MDL_BIT_WALKIN, Val);
        motRelax:
            SetBit(mDataBits, MDL_BIT_RELAX, Val);
        motPE:
            SetBit(mDataBits, MDL_BIT_PE, Val);
    end;
end;

procedure TModelType.SetPosType(AType: Integer);
begin
    BitOnByIdx(mDataBits, MDL_BIT_POS_TYPE, AType, 2);
end;

procedure TModelType.SetPosType(AType: TPOS_TYPE);
begin
    BitOnByIdx(mDataBits, MDL_BIT_POS_TYPE, Ord(AType), 2);
end;

procedure TModelType.SetSeatsType(AType: TSEATS_TYPE);
begin
    BitOnByIdx(mDataBits, MDL_BIT_SEATS_TYPE, Ord(AType), 4);
end;

function TModelType.ToStr(): string;
begin
    Result := Format('%s, %s, %s, %s:0x%X', [GetCarTypeStr, GetCarTrimTypeStr, GetSeatsTypeStr, GetPosTypeStr, mDataBits]);
end;

procedure TModelType.WriteAsOptName(Strings: TStrings; OptTypes: array of TMdlOptType);
var
    AddLen, i: integer;
begin

    AddLen := Length(OptTypes) - Strings.Count;
    if Strings.Count < Length(OptTypes) then
    begin
        for i := 0 to AddLen - 1 do
        begin
            Strings.Add('');
        end;
    end;

    for i := 0 to Length(OptTypes) - 1 do
    begin
        Strings.Strings[i] := GetOptStr(OptTypes[i]);
        Strings.Objects[i] := TObject(OptTypes[i]);
    end;
end;

procedure TModelType.WriteAsType(Strings: TStrings; StartCol: Integer);
var
    AddLen, i: Integer;
begin

    AddLen := MDL_COL_COUNT - Strings.Count;
    if Strings.Count < MDL_COL_COUNT then
    begin
        for i := 0 to AddLen - 1 do
        begin
            Strings.Add('');
        end;
    end;

    Strings.Strings[StartCol + 0] := GetCarTypeStr;
    Strings.Strings[StartCol + 1] := GetSeatsTypeStr;
    Strings.Strings[StartCol + 2] := GetCarTrimTypeStr;
    Strings.Strings[StartCol + 3] := GetHVTypeStr;
end;

procedure TModelType.SetCarTrimType(AType: TCAR_TRIM_TYPE);
begin
    BitOnByIdx(mDataBits, MDL_BIT_CAR_SUB_TYPE, Ord(AType), 2);
end;

procedure TModelType.SetCarType(AType: TCAR_TYPE);
begin
    BitOnByIdx(mDataBits, MDL_BIT_CAR_TYPE, Ord(AType), 2);
end;

function TModelType.GetPosType: TPOS_TYPE;
var
    PosBit: Integer;
begin
    PosBit := GetOnBitIdx(mDataBits, MDL_BIT_POS_TYPE, 2);

    Result := TPOS_TYPE(Max(0, PosBit));

end;

function TModelType.GetPosTypeStr: string;
begin
    Result := TPOS_TYPE_STR[Integer(GetPosType)];
end;

function TModelType.GetPosTypeToInt: Integer;
begin
    Result := Integer(GetPosType);
end;

function TModelType.GetSeatsType: TSEATS_TYPE;
var
    SeatsBit: Integer;
begin
    SeatsBit := GetOnBitIdx(mDataBits, MDL_BIT_SEATS_TYPE, 4);

    Result := TSEATS_TYPE(Max(0, SeatsBit));
end;

function TModelType.GetSeatsTypeStr: string;
begin
    Result := '';

    Result := TSEATS_TYPE_STR[Integer(GetSeatsType)];
end;

function TModelType.GetSeatsTypeToInt: Integer;
begin
    Result := Integer(GetSeatsType);
end;

function TModelType.CanRLHeatTest: Boolean;
begin
    Result := (IsHeat or IsHV) and IsHVPSU;
end;

function TModelType.CanRLVentTest: Boolean;
begin
    Result := IsHV and IsHVPSU;
end;

function TModelType.CanHtrWiringTest: Boolean;
begin
    // 개별 ECU + 메뉴얼 없음.
    Result := False;
end;

function TModelType.CanRRHeatTest: Boolean;
begin
    Result := (IsHeat or IsHV) and IsHVPSU;
end;

function TModelType.CanRRVentTest: Boolean;
begin
    Result := IsHV and IsHVPSU;
end;

procedure TModelType.Clear;
begin
    mDataBits := 0;
end;

procedure TModelType.CopyFrom(SrcDataBits: DWORD; SIdx, Len: Integer);
var
    i: Integer;
begin
    for i := 0 to Len - 1 do
    begin
        SetBit(mDataBits, SIdx + i, IsBitOn(SrcDataBits, SIdx + i));
    end;
end;

constructor TModelType.Create(DataBits: DWORD; ID: Integer);
begin
    mDataBits := DataBits;
    mID := ID;
end;

function TModelType.Is4P: Boolean;
begin
    Result := GetSeatsType = st4P;
end;

function TModelType.Is5P: Boolean;
begin
    Result := GetSeatsType = st5P;
end;

function TModelType.Is6P: Boolean;
begin
    Result := GetSeatsType = st6P;
end;

function TModelType.Is7P: Boolean;
begin
    Result := GetSeatsType = st7P;
end;

function TModelType.IsBlower: Boolean;
begin
    // ALL 개별 HVECU
    Result := False;
end;

function TModelType.IsBukcle: Boolean;
begin
    Result := IsNoneBuckle or IsWarnBuckle or IsIllBuckle or IsCenterBuckle;
end;

function TModelType.IsCushTiltMtrExists: Boolean;
begin
    Result := GetSeatsType in [st4P, st6P];
end;

function TModelType.IsECU: Boolean;
begin
    Result := IsHVPSU or IsSAU;
end;

function TModelType.IsEqual(ModelType: TModelType; Mask: DWORD): Boolean;
begin
    Result := ((mDataBits and Mask) = (ModelType.mDataBits and Mask))
end;

function TModelType.IsHeadRestMtrExists: Boolean;
begin
    Result := GetSeatsType in [st4P, st6P];
end;

function TModelType.IsHeat: Boolean;
begin
    Result := GetHVType in [htHeat, htHV];
end;

function TModelType.IsHeatRL: Boolean;
begin
    Result := IsHeat and IsRL;
end;

function TModelType.IsHeatRR: Boolean;
begin
    Result := IsHeat and IsRR;
end;

function TModelType.IsHV: Boolean;
begin
    Result := GetHVType = htHV;
end;

function TModelType.IsHVPSU: Boolean;
begin
    Result := IsBitOn(mDataBits, MDL_BIT_HVPSU);
end;

function TModelType.IsILLBuckle: Boolean;
begin
    Result := IsBitOn(mDataBits, MDL_BIT_ILL_BUCKLE);
end;

function TModelType.IsIMS: Boolean;
begin
    // ALL IMS
    Result := True;
end;

function TModelType.IsWarnBuckle: Boolean;
begin
    Result := IsBitOn(mDataBits, MDL_BIT_WARN_BUCKLE);
end;

function TModelType.IsCenterBuckle: Boolean;
begin
    Result := IsBitOn(mDataBits, MDL_BIT_CENTER_BUCKLE);
end;

function TModelType.IsLongSlideMtrExists: Boolean;
begin
    Result := (GetSeatsType = st6P) and IsSE;
end;

function TModelType.IsNoneBuckle: Boolean;
begin
    Result := (not IsWarnBuckle) and (not IsIllBuckle);
end;

function TModelType.IsPE: Boolean;
begin
    Result := IsBitOn(mDataBits, MDL_BIT_PE);
end;

function TModelType.IsReclineMtrExists: Boolean;
begin
    Result := GetSeatsType in [st5P, st6P, st7P];
end;

function TModelType.IsRelax: Boolean;
begin
    Result := IsBitOn(mDataBits, MDL_BIT_RELAX);
end;

function TModelType.IsRelaxMtrExists: Boolean;
begin
    Result := (GetSeatsType = st4P) and IsRelax;
end;

function TModelType.IsRL: Boolean;
begin
    Result := GetPosType = ptLH;
end;

function TModelType.IsRR: Boolean;
begin
    Result := GetPosType = ptRH;
end;

function TModelType.IsSAU: Boolean;
begin
    Result := IsBitOn(mDataBits, MDL_BIT_SAU);
end;

function TModelType.IsSE: Boolean;
begin
    Result := GetCarTrimType = cstSE;
end;

function TModelType.IsShoulderMtrExists: Boolean;
begin
    Result := GetSeatsType = st4P;
end;

function TModelType.IsSlideMtrExists: Boolean;
begin
    Result := not IsLongSlideMtrExists;
end;

function TModelType.IsSTD: Boolean;
begin
    Result := GetCarTrimType = cstSTD;
end;

function TModelType.IsTiltMtrExists: Boolean;
begin
    Result := (GetSeatsType in [st4P, st6P]) or (Is7P and IsRR);
end;

function TModelType.IsVentRL: Boolean;
begin
    Result := IsHV and IsRL;
end;

function TModelType.IsVentRR: Boolean;
begin
    Result := IsHV and IsRR;
end;

function TModelType.IsWalkin: Boolean;
begin
    Result := IsBitOn(mDataBits, MDL_BIT_WALKIN);
end;

function TModelType.IsWalkinTiltMtrExists: Boolean;
begin
    Result := (GetSeatsType in [st6P, st7P]) and IsWalkin;
end;

function TModelType.MakeMainConID: string;
begin
    Result := '';

    if IsSE then
        Result := Result +'JG1SE'
    else
        Result := 'JG1';


    Result := Result + ':' + GetSeatsTypeStr + ':' + GetPosTypeStr;
end;

function TModelType.MakeMainConName: string;
begin
    Result := '';

    if IsSE then
        Result := Result +'JG1SE'
    else
        Result := 'JG1';


    Result := Result + ' ' + GetSeatsTypeStr + ' ' + GetPosTypeStr;
end;

function TModelType.MakePartName: string;
begin
    //IMS + EXT + L/S(MorA) + W/I + WM + VT + ODS + B_W/S + NA
    Result := '';
//    if IsIMS then
//        Result := Result + 'IMS+';
//    if IsExt then
//        Result := Result + 'EXT+';
//    if IsBolster and IsLSupt then
//        Result := Result + 'L/S(A)+'
//    else if IsLSupt then
//        Result := Result + 'L/S(M)+';
//    if IsWalkIn then
//        Result := Result + 'W/I+';
//    if GetHVType = htHeat then
//        Result := Result + 'WM+'
//    else if GetHVType = htHV then
//        Result := Result + 'WM+VT+';
//    if IsPODS then
//        Result := Result + 'ODS+';
//    if GetBuckleType = btNone then
//        Result := Result + 'B_NO_W/S+'
//    else if GetBuckleType = btIO then
//        Result := Result + 'B_W/S+'
//    else if GetBuckleType = btCurr then
//        Result := Result + 'B_W/O+';
//    if IsNorAM then
//        Result := Result + 'NA+';

    Delete(Result, Length(Result), 1);
end;

function TModelType.MakeSwConName: string;
begin
    Result := '';
end;

function TModelType.GetHVType: THV_TYPE;
var
    HVBit: Integer;
begin
    HVBit := GetOnBitIdx(mDataBits, MDL_BIT_HV_START, 2);

    if HVBit < 0 then
    begin
        Result := htNoneHV;
        Exit;
    end;

    Result := THV_TYPE(Max(0, HVBit) + 1);
end;

function TModelType.GetCarTrimType: TCAR_TRIM_TYPE;
var
    CarSubBit: Integer;
begin
    CarSubBit := GetOnBitIdx(mDataBits, MDL_BIT_CAR_SUB_TYPE, 2);

    Result := TCAR_TRIM_TYPE(Max(0, CarSubBit));
end;

function TModelType.GetCarTrimTypeStr: string;
begin
    Result := TCAR_TRIM_TYPE_STR[Integer(GetCarTrimType)];
end;

function TModelType.GetCarTrimTypeToInt: Integer;
begin
    Result := Integer(GetCarTrimType);
end;

function TModelType.GetCarType: TCAR_TYPE;
var
    CarBit: Integer;
begin
    CarBit := GetOnBitIdx(mDataBits, MDL_BIT_CAR_TYPE, 2);

    Result := TCAR_TYPE(Max(0, CarBit));
end;

function TModelType.GetCarTypeStr: string;
begin
    Result := TCAR_TYPE_STR[Integer(GetCarType)];

    case GetCarTrimType of
        cstSE:
            Result := Result + 'SE';
    end;

    if IsPE then
        Result := Result + '(PE)';
end;

function TModelType.GetCarTypeToInt: Integer;
begin
    Result := Integer(GetCarType);
end;

function TModelType.GetECUTypeStr: string;
begin
    Result := '';

    if IsHVPSU then
        Result := 'HVPSU';

    if IsSAU then
        Result := 'SAU';
end;

function TModelType.GetUseMotors: TMTR_TYPE_array;
var
    ResultList: TMTR_TYPE_array;
    Count: Integer;
begin
    Count := 0;
    SetLength(ResultList, 9);

    if IsSlideMtrExists then
    begin
        ResultList[Count] := mtSlide;
        Inc(Count);
    end;

    if IsReclineMtrExists then
    begin
        ResultList[Count] := mtRecline;
        Inc(Count);
    end;

    if IsCushTiltMtrExists then
    begin
        ResultList[Count] := mtCushTilt;
        Inc(Count);
    end;

    if IsWalkinTiltMtrExists then
    begin
        ResultList[Count] := mtWalkinTilt;
        Inc(Count);
    end;

    if IsRelaxMtrExists then
    begin
        ResultList[Count] := mtRelax;
        Inc(Count);
    end;

    if IsShoulderMtrExists then
    begin
        ResultList[Count] := mtShoulder;
        Inc(Count);
    end;

    if IsHeadRestMtrExists then
    begin
        ResultList[Count] := mtHeadrest;
        Inc(Count);
    end;

    if IsLongSlideMtrExists then
    begin
        ResultList[Count] := mtLongSlide;
        Inc(Count);
    end;

    SetLength(ResultList, Count); // 사용한 만큼만 잘라서 반환
    Result := ResultList;
end;

function TModelType.GetBuckleTypeStr: string;
begin
    Result := '';

    if IsNoneBuckle then
        Result := 'NONE BUCKLE';

    if IsWarnBuckle then
        Result := 'WARN BUCKLE';

    if IsIllBuckle then
        Result := 'ILL BUCKLE';

    if IsCenterBuckle then
        Result := Result + '(CTR)';

end;

function TModelType.GetHVTypeStr: string;
begin
    Result := THV_TYPE_STR[Integer(GetHVType)];
end;

function TModelType.GetHVTypeToInt: Integer;
begin
    Result := Integer(GetHVType);
end;

function TModelType.GetOpt(OptType: TMdlOptType): Boolean;
begin
    Result := False;

    case OptType of
        motHVPSU:
            Result := IsHVPSU;
        motSAU:
            Result := IsSAU;
        motWarnBuckle:
            Result := IsWarnBuckle;
        motILLBuckle:
            Result := IsILLBuckle;
        motCTRBuckle:
            Result := IsCenterBuckle;
        motWalkin:
            Result := IsWalkin;
        motRelax:
            Result := IsRelax;
        motPE:
            Result := IsPE;
    end;
end;

function TModelType.GetOptStr(OptType: TMdlOptType): string;
begin
    case OptType of
        motHVPSU:
            Result := 'HVPSU';
        motSAU:
            Result := 'SAU';
        motWarnBuckle:
            Result := 'WARN BUCKLE';
        motILLBuckle:
            Result := 'ILL BUCKLE';
        motCTRBuckle:
            Result := 'CENTER BUCKLE';
        motWalkin:
            Result := 'WALKIN';
        motRelax:
            Result := 'RELAX';
        motPE:
            Result := 'PE';
    end;
end;

procedure TModelType.SetSeatsType(AType: Integer);
begin
    BitOnByIdx(mDataBits, MDL_BIT_SEATS_TYPE, AType, 4);
end;

procedure TModelType.SetCarTrimType(AType: Integer);
begin
    BitOnByIdx(mDataBits, MDL_BIT_CAR_SUB_TYPE, AType, 2);
end;

procedure TModelType.SetCarType(AType: Integer);
begin
    BitOnByIdx(mDataBits, MDL_BIT_CAR_TYPE, AType, 2);
end;

procedure TModelType.SetHVType(AType: Integer);
begin
    SetBit(mDataBits, MDL_BIT_HEAT, False);
    SetBit(mDataBits, MDL_BIT_HV, False);

    case AType of
        ord(htHeat):
            SetBit(mDataBits, MDL_BIT_HEAT, True);
        ord(htHV):
            SetBit(mDataBits, MDL_BIT_HV, True);
    end;
end;

end.

