unit JG1SeatIMSCtrler;

interface

uses
    SeatIMSCtrler, SeatMotorType, BaseCAN;

type
    TJG1CANIMSCtrler = class(TCANIMSCtrler)
    private
        function GetRCOpt(RCOpt: TRCOPt): byte;
        function MotorORD2RCOpt(MotorORD: TMotorORD; IsDelete: Boolean = false): TRCOpt;

    protected
        function IsRCGetRespDone: boolean; override;

        // 통신 요청
        function ReqPos(): boolean; override;
        function ReqEasyAccess(): boolean; override;

        function SetLimit(MotorID: TMotorOrd): boolean; override;

        // 승하차 조건 명령
        function SetIgnSw(Value: boolean): boolean; override;
        function SetDrvDoorOpenSw(Value: boolean): boolean; override;
        function SetVehicleSpeed(Speed: byte = 0): Boolean; override;

        function KeyOn: integer; override;
        function KeyOff: Integer; override;

        // 위치 설정
        function StartMemSet(Value: boolean): boolean; override;
        function SetMemP1(Value: boolean): boolean; override; // 설정 및 동작(Go)
        function SetMemP2(Value: boolean): boolean; override;
        function SetMemP3(Value: boolean): boolean; override;



        function SetIMS1(Value: boolean): boolean;
        function SetIMS2(Value: boolean): boolean;
        function SetIMS3(Value: boolean): boolean;

        // CANFD 통합 DBC에 신규 추가된 기능. BDC 중앙컨트롤러에서 모든 ECU에 내리는 명령인듯.
        function SetSmartIMS(Value: boolean): boolean;
        function SetAllSeatIMS1(Value: boolean): boolean;
        function SetAllSeatIMS2(Value: boolean): boolean;
        function SetAllSeatIMS3(Value: boolean): boolean;

    public
    end;

implementation

uses
    UDSDef, Log, SysUtils, myUtils;

{ TJG1CANIMSCtrler }
function TJG1CANIMSCtrler.GetRCOpt(RCOpt: TRCOPt): byte;
var
    AddByte: Byte;
begin
    AddByte := Byte(RCOpt);
    Result := $40 + AddByte;

    // 불편하게 shoulder쪽부터는 안붙여놓고 띄어놓음;
    if ord(RCOpt) >= ord(rcoShoulderLimit) then
    begin
        AddByte := AddByte - Byte(rcoShoulderLimit);
        Result := $5C + AddByte;
    end;

    case RCOpt of
        rcoEEPROMClear:
            Result := $B0;
    end;
end;

function TJG1CANIMSCtrler.IsRCGetRespDone: boolean;
begin
    // 멀티프레임이 나뉘진 않음.
    Result := (mMFrame.mDatas[2] = $71) and (mMFrame.mDatas[3] = $03);
end;

function TJG1CANIMSCtrler.KeyOff: Integer;
begin
    SetVehicleSpeed(0);
    SetDrvDoorOpenSw(False);
    SetIgnSw(True);
    Result := 1;
end;

function TJG1CANIMSCtrler.KeyOn: integer;
begin
    SetVehicleSpeed(0);
    SetDrvDoorOpenSw(True);
    SetIgnSw(False);
    Result := 1;
end;

function TJG1CANIMSCtrler.MotorORD2RCOpt(MotorORD: TMotorORD; IsDelete: Boolean): TRCOpt;
var
    RCOptDeleteOrd: Integer;
begin
    Result := rcoAllLimit;
    case MotorORD of
        tmSlide:
            Result := rcoSlideLimit;
        tmRecl:
            Result := rcoReclLimit;
        tmCushTilt:
            Result := rcoTiltLimit;
        tmWalkinUpTilt:
            Result := rcoWalkinUpTiltLimit;
        tmShoulder:
            Result := rcoShoulderLimit;
        tmRelax:
            Result := rcoRelaxLimit;
        tmHeadrest:
            Result := rcoHeadRestLimit;
    end;

    if IsDelete then
    begin
        RCOptDeleteOrd := ord(Result) + 1;
        Result := TRCOpt(RCOptDeleteOrd);
    end;
end;

function TJG1CANIMSCtrler.ReqEasyAccess: boolean;
begin
    ClearRespData;
    Result := mCAN.Write(mReqID, 0, [$04, _UDS_RDBI_REQ_SID, mRDBIID, _UDS_RDBI_EASY_ACCESS, 0, 0, 0, 0], 8); // TO DO
end;

function TJG1CANIMSCtrler.ReqPos: boolean;
begin
    ClearRespData;

    Result := mCAN.Write(mReqID, 0, [$03, _UDS_RDBI_REQ_SID, mRDBIID, 3, 0, 0, 0, 0], 8);
end;

function TJG1CANIMSCtrler.SetAllSeatIMS1(Value: boolean): boolean;
var
    DataFrame: array[0..31] of Byte;
begin
    FillChar(DataFrame, SizeOf(DataFrame), 0);

    DataFrame[0] := $FF;
    DataFrame[1] := $FF;

    if mIsLHPos then
    begin
        if Value then
            DataFrame[10] := $48;
    end
    else
    begin
        if Value then
            DataFrame[11] := $48;
    end;

    Result := mCAN.Write(_FD_BDC_MEM_ID, DataFrame, Length(DataFrame));
end;


function TJG1CANIMSCtrler.SetAllSeatIMS2(Value: boolean): boolean;
var
    DataFrame: array[0..31] of Byte;
begin
    FillChar(DataFrame, SizeOf(DataFrame), 0);

    DataFrame[0] := $FF;
    DataFrame[1] := $FF;

    if mIsLHPos then
    begin
        if Value then
            DataFrame[10] := $50;
    end
    else
    begin
        if Value then
            DataFrame[11] := $50;
    end;

    Result := mCAN.Write(_FD_BDC_MEM_ID, DataFrame, Length(DataFrame));
end;


function TJG1CANIMSCtrler.SetAllSeatIMS3(Value: boolean): boolean;
var
    DataFrame: array[0..31] of Byte;
begin
    FillChar(DataFrame, SizeOf(DataFrame), 0);

    DataFrame[0] := $FF;
    DataFrame[1] := $FF;

    if mIsLHPos then
    begin
        if Value then
            DataFrame[10] := $58;
    end
    else
    begin
        if Value then
            DataFrame[11] := $58;
    end;

    Result := mCAN.Write(_FD_BDC_MEM_ID, DataFrame, Length(DataFrame));
end;


function TJG1CANIMSCtrler.SetDrvDoorOpenSw(Value: boolean): boolean;
var
    DataFrame: array[0..31] of Byte;
begin
    FillChar(DataFrame, SizeOf(DataFrame), 0);

    DataFrame[0] := $FF;
    DataFrame[1] := $FF;

    if mIsLHPos then
    begin
        if Value then
            DataFrame[10] := $60
        else
            DataFrame[10] := $68;
    end
    else
    begin
        if Value then
            DataFrame[11] := $60
        else
        begin
            DataFrame[11] := $68;
        end;
    end;

    Result := mCAN.Write(_FD_GET_ONOFF_BDC_ID, DataFrame, Length(DataFrame));
end;

function TJG1CANIMSCtrler.SetIgnSw(Value: boolean): boolean;
var
    DataFrame: array[0..31] of Byte;
begin
    FillChar(DataFrame, SizeOf(DataFrame), 0);

    DataFrame[0] := $FF;
    DataFrame[1] := $FF;
    DataFrame[5] := $01;            // P단
    if Value then
        DataFrame[3] := $51         // Ign 1,2 And KeyIn
    else
        DataFrame[3] := $50;        // Ign 1,2 And KeyOut

    Result := mCAN.Write(_FD_C_IGNSW_BDC_ID, DataFrame, Length(DataFrame));
end;

function TJG1CANIMSCtrler.SetIMS1(Value: boolean): boolean;
var
    DataFrame: array[0..31] of Byte;
begin
    FillChar(DataFrame, SizeOf(DataFrame), 0);

    DataFrame[0] := $FF;
    DataFrame[1] := $FF;

    if mIsLHPos then
    begin
        if Value then
            DataFrame[10] := $28;
    end
    else
    begin
        if Value then
            DataFrame[11] := $28;
    end;

    Result := mCAN.Write(_FD_BDC_MEM_ID, DataFrame, Length(DataFrame));
end;

function TJG1CANIMSCtrler.SetIMS2(Value: boolean): boolean;
var
    DataFrame: array[0..31] of Byte;
begin
    FillChar(DataFrame, SizeOf(DataFrame), 0);

    DataFrame[0] := $FF;
    DataFrame[1] := $FF;

    if mIsLHPos then
    begin
        if Value then
            DataFrame[10] := $30;
    end
    else
    begin
        if Value then
            DataFrame[11] := $30;
    end;

    Result := mCAN.Write(_FD_BDC_MEM_ID, DataFrame, Length(DataFrame));
end;

function TJG1CANIMSCtrler.SetIMS3(Value: boolean): boolean;
var
    DataFrame: array[0..31] of Byte;
begin
    FillChar(DataFrame, SizeOf(DataFrame), 0);

    DataFrame[0] := $FF;
    DataFrame[1] := $FF;

    if mIsLHPos then
    begin
        if Value then
            DataFrame[10] := $38;
    end
    else
    begin
        if Value then
            DataFrame[11] := $38;
    end;

    Result := mCAN.Write(_FD_BDC_MEM_ID, DataFrame, Length(DataFrame));
end;

function TJG1CANIMSCtrler.SetLimit(MotorID: TMotorOrd): boolean;
var
    MotorType, Len: byte;
begin
    ClearRespData;

    Len := $05;

    MotorType := GetRCOpt(MotorORD2RCOpt(MotorID));

    Result := WriteRountineCtrl(_UDS_RC_SET, MotorType, Len);
end;

function TJG1CANIMSCtrler.StartMemSet(Value: boolean): boolean;
begin
    SetSmartIMS(Value);
end;

function TJG1CANIMSCtrler.SetMemP1(Value: boolean): boolean;
begin
    SetAllSeatIMS1(Value);
end;

function TJG1CANIMSCtrler.SetMemP2(Value: boolean): boolean;
begin
    SetAllSeatIMS2(Value);
end;

function TJG1CANIMSCtrler.SetMemP3(Value: boolean): boolean;
begin
    SetAllSeatIMS3(Value);
end;


function TJG1CANIMSCtrler.SetSmartIMS(Value: boolean): boolean;
var
    DataFrame: array[0..31] of Byte;
begin
    FillChar(DataFrame, SizeOf(DataFrame), 0);

    DataFrame[0] := $FF;
    DataFrame[1] := $FF;

    if mIsLHPos then
    begin
        if Value then
            DataFrame[10] := $40;
    end
    else
    begin
        if Value then
            DataFrame[11] := $40;
    end;

    Result := mCAN.Write(_FD_BDC_MEM_ID, DataFrame, Length(DataFrame));
end;

function TJG1CANIMSCtrler.SetVehicleSpeed(Speed: byte): boolean;
var
    DataFrame: array[0..15] of Byte;
begin
    FillChar(DataFrame, SizeOf(DataFrame), 0);

    DataFrame[0] := $FF;
    DataFrame[1] := $FF;

    Result := mCAN.Write(_FD_C_VehicSpd_ID, DataFrame, Length(DataFrame));
end;


end.

