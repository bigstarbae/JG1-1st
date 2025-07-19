{
	Ver.250618.00
}
{$INCLUDE myDefine.inc}

unit SubDataBox4Mtr;

interface

uses
    BaseDataBox, DataBox, DataUnit, DataUnitOrd, SeatMotorType;

type
    TSubDataBox4Mtr = class(TBaseDataBox)
    private
        mParent: TDataBox;

        function GetTag: integer; override;
        procedure SetValidity; override;

    public
        constructor Create(Parent: TDataBox);

        procedure InitData(AReadEnv: Boolean = False); override;
        procedure SetDataInit(ATsMode: TTsORD); override;

        function GetPResultBuffer(): PResult; override;
        procedure SetResult(const AResult; Afpos: integer = -1); override;

        function IsExists(AORD: TResultORD): Boolean; overload; override;
        function IsTested(AORD: TResultORD): Boolean; overload; override;

        function GetData(AORD: TResultORD; ADigit: integer = 0): double; overload; override;
        function GetResult(AORD: TResultORD): Boolean; overload; override;
        function GetResult(ATsMode: TTsORD): Boolean; overload; override;
        function GetResultToATxt(APos: integer; IsUnit: Boolean; IsResult: Boolean = False): string; override;

        procedure SetData(AORD: TResultORD; const Value: double); overload; override;
        procedure SetData(AORD: TResultORD; const Value: string); overload; override;
        procedure SetData(AORD: TResultORD; const Value: Boolean); overload; override;
        procedure SetData(AORD: TResultOrd; const Value: integer); overload; override;
    end;

implementation

uses
    Math, Log, ModelUnit, SysEnv, DataUnitHelper;

{ TSubDataBox4Mtr }

constructor TSubDataBox4Mtr.Create(Parent: TDataBox);
begin
    inherited Create;
    mParent := Parent
end;

function TSubDataBox4Mtr.GetData(AORD: TResultORD; ADigit: integer): double;
begin
    mIsProcessDone := True;

    with mParent do
    begin

        case AORD of
            roDataFwCurr:
                begin
                    Result := RsBuf.rDatMtrs[RsBuf.rCurMtr].rItems[twForw].rCurr;
                end;
            roDataBwCurr:
                begin
                    Result := RsBuf.rDatMtrs[RsBuf.rCurMtr].rItems[twBack].rCurr;
                end;
            roDataFwSpeed:
                begin
                    Result := RsBuf.rDatMtrs[RsBuf.rCurMtr].rItems[twForw].rSpeed;
                end;
            roDataBwSpeed:
                begin
                    Result := RsBuf.rDatMtrs[RsBuf.rCurMtr].rItems[twBack].rSpeed;
                end;

            roDataFwInitNoise:
                begin
                    Result := RsBuf.rDatMtrs[RsBuf.rCurMtr].rItems[twForw].rInitNoise;
                end;
            roDataFwRunNoise:
                begin
                    Result := RsBuf.rDatMtrs[RsBuf.rCurMtr].rItems[twForw].rRunNoise;
                end;
            roDataBwInitNoise:
                begin
                    Result := RsBuf.rDatMtrs[RsBuf.rCurMtr].rItems[twBack].rInitNoise;
                end;
            roDataBwRunNoise:
                begin
                    Result := RsBuf.rDatMtrs[RsBuf.rCurMtr].rItems[twBack].rRunNoise;

                end;

        else
            mIsProcessDone := False;
            Result := 0.0;
        end;
    end;
end;

function TSubDataBox4Mtr.GetPResultBuffer: PResult;
begin
    Result := mParent.GetPResultBuffer;
end;

function TSubDataBox4Mtr.GetResult(ATsMode: TTsORD): Boolean;
begin
    mIsProcessDone := True;

    with mParent.RsBuf^ do
    begin

        case ATsMode of
            tsSlide:
                begin
                    rCurMtr := tmSlide;
                    Result := GetResult(roRsMotor);
                end;
            tsTilt:
                begin
                    rCurMtr := tmTilt;
                    Result := GetResult(roRsMotor);
                end;
            tsHeight:
                begin
                    rCurMtr := tmHeight;
                    Result := GetResult(roRsMotor);
                end;
            tsLegSupt:
                begin
                    rCurMtr := tmLegSupt;
                    Result := GetResult(roRsMotor);
                end;

            tsSwivel:
                begin
                    rCurMtr := tmSwivel;
                    Result := GetResult(roRsMotor);
                end;

            tsNOISE:
                Result := GetResult(roRsNoise);

            tsDeviation:
                begin
                    Result := False;
                end;
            tsAbnormalSound:
                begin
                    Result := GetResult(roRsAbnormalSound);
                end;

        else
            mIsProcessDone := False;
            Result := False;
        end;
    end;
end;

function TSubDataBox4Mtr.GetResult(AORD: TResultORD): Boolean;
var
    Mtr: TMotorOrd;
begin

    mIsProcessDone := True;
    Result := True;

    with mParent.RsBuf^ do
    begin
        case AORD of
            roDataFwCurr:
                begin
                    if rTested[tsCurr] then
                        Result := rModel.rSpecs.rMotors[rCurMtr].rCurr.IsIn(rDatMtrs[rCurMtr].rItems[twForw].rCurr)
                    else
                        Result := True;

                    if not Result and rShowNGDebug then
                        gLog.Debug('NG: %s: roDataFwCurr', [GetMotorName(rCurMtr)]);
                end;
            roDataBwCurr:
                begin
                    Result := rModel.rSpecs.rMotors[rCurMtr].rCurr.IsIn(rDatMtrs[rCurMtr].rItems[twBack].rCurr);

                    if not Result and rShowNGDebug then
                        gLog.Debug('NG: %s: roDataBwCurr', [GetMotorName(rCurMtr)]);
                end;

            roRsCurr:
                begin
                    Result := GetResult(roDataFwCurr) and GetResult(roDataBwCurr);
                end;

            roRsTotCurr:
                begin
                    for Mtr := Low(TMotorOrd) to MtrOrdHi do
                    begin

                        if not rTested[MotorOrd2TsOrd(Mtr)] then
                            Continue;

                        rCurMtr := Mtr;
                        Result := GetResult(roRsCurr);
                        if not Result then
                        begin
                            Exit;
                        end;
                    end;
                end;

                //===================


            roDataFwSpeed:
                begin
                    Result := rModel.rSpecs.rMotors[rCurMtr].rSpeed[twForw].IsIn(rDatMtrs[rCurMtr].rItems[twForw].rSpeed);

                    if not Result and rShowNGDebug then
                        gLog.Debug('NG: %s: roDataFwSpeed', [GetMotorName(rCurMtr)]);
                end;
            roDataBwSpeed:
                begin
                    Result := rModel.rSpecs.rMotors[rCurMtr].rSpeed[twBack].IsIn(rDatMtrs[rCurMtr].rItems[twBack].rSpeed);

                    if not Result and rShowNGDebug then
                        gLog.Debug('NG: %s: roDataBwSpeed', [GetMotorName(rCurMtr)]);

                end;

            roRsSpeed:
                begin
                    Result := GetResult(roDataFwSpeed) and GetResult(roDataBwSpeed);
                end;

            roRsTotSpeed:
                begin
                    for Mtr := Low(TMotorOrd) to MtrOrdHi do
                    begin
                        if not rTested[MotorOrd2TsOrd(Mtr)] then
                            Continue;

                        rCurMtr := Mtr;
                        Result := GetResult(roRsSpeed);
                        if not Result then
                        begin
                            Exit;
                        end;
                    end;
                end;

            roDataFwInitNoise:
                begin
                    Result := rDatMtrs[rCurMtr].rItems[twForw].rInitNoise <= rModel.rSpecs.rMotors[rCurMtr].rInitNoise;

                    if not Result and rShowNGDebug then
                        gLog.Debug('NG: %s: roDataFwInitNoise', [GetMotorName(rCurMtr)]);

                end;
            roDataFwRunNoise:
                begin
                    Result := rDatMtrs[rCurMtr].rItems[twForw].rRunNoise <= rModel.rSpecs.rMotors[rCurMtr].rRunNoise;

                    if not Result and rShowNGDebug then
                        gLog.Debug('NG: %s: roDataFwRunNoise', [GetMotorName(rCurMtr)]);

                end;
            roDataBwInitNoise:
                begin
                    Result := rDatMtrs[rCurMtr].rItems[twBack].rInitNoise <= rModel.rSpecs.rMotors[rCurMtr].rInitNoise;

                    if not Result and rShowNGDebug then
                        gLog.Debug('NG: %s: roDataBwInitNoise', [GetMotorName(rCurMtr)]);

                end;
            roDataBwRunNoise:
                begin
                    Result := rDatMtrs[rCurMtr].rItems[twBack].rRunNoise <= rModel.rSpecs.rMotors[rCurMtr].rRunNoise;

                    if not Result and rShowNGDebug then
                        gLog.Debug('NG: %s: roDataBwRunNoise', [GetMotorName(rCurMtr)]);

                end;

            roRsNoise:
                begin
                    Result := GetResult(roDataFwInitNoise) and GetResult(roDataFwRunNoise) and GetResult(roDataBwInitNoise) and GetResult(roDataBwRunNoise);
                end;

            roRsTotNoise:
                begin
                    for Mtr := Low(TMotorOrd) to MtrOrdHi do
                    begin
                        if not rTested[MotorOrd2TsOrd(Mtr)] then
                            continue;

                        rCurMtr := Mtr;
                        Result := GetResult(roRsNoise);
                        if not Result then
                            Exit;
                    end;
                end;
            roRsFwMotor:
                begin
                    Result := GetResult(roDataFwInitNoise) and GetResult(roDataFwRunNoise) and GetResult(roDataFwSpeed) and GetResult(roDataFwCurr);
                end;
            roRsBwMotor:
                begin
                    Result := GetResult(roDataBwInitNoise) and GetResult(roDataBwRunNoise) and GetResult(roDataBwSpeed) and GetResult(roDataBwCurr);
                end;

            roRsMotor:
                begin
                    Result := GetResult(roRsSpeed) and GetResult(roRsNoise) and GetResult(roRsCurr);
                end;

            roRsTotMotor:
                begin
                    Result := GetResult(roRsTotSpeed) and GetResult(roRsTotNoise) and GetResult(roRsTotCurr);
                end;
            //===================================
            roRsAbnormalSound:
                begin
                    Result := RsBuf.rValidity[tsAbnormalSound];
                end;

        else
            mIsProcessDone := False;
            Result := False;
        end;
    end;

end;

function TSubDataBox4Mtr.GetResultToATxt(APos: integer; IsUnit, IsResult: Boolean): string;

    procedure InsertResultTag;
    begin
{$IFDEF _VIEWER}
        if IsResult and IsTested(TResultORD(APos)) then
        begin
            Result := ARY_TAG[GetResult(TResultORD(APos))] + Result;
        end;
{$ENDIF}
    end;

begin
    mIsProcessDone := True;

    with mParent do
    begin
        case APos of

            Ord(roSlide_CTRL):
                begin
                    RsBuf.rCurMtr := tmSlide;
                end;
            Ord(roTilt_CTRL):
                begin
                    RsBuf.rCurMtr := tmTilt;
                end;
            Ord(roHeight_CTRL):
                begin
                    RsBuf.rCurMtr := tmHeight;
                end;
            Ord(roLegSupt_CTRL):
                begin
                    RsBuf.rCurMtr := tmLegSupt;
                end;
            Ord(roSwivel_CTRL):
                begin
                    RsBuf.rCurMtr := tmSwivel;
                end;

            // Spec
                ord(rospecCurrLo)..ord(rospecRunNoiseDevHi):
                begin
                    Result := RsBuf.ModelToStr(TResultOrd(APos), IsUnit);    // 모터는 TResult에게 위임(기존 GetModelToTxt)
                end;
            //Data
            ord(roDataFwCurr), ord(roDataBwCurr):

                begin
                    if not IsExists(TResultORD(APos)) and not IsTested(TResultORD(APos)) then
                        Exit;

                    if not IsExists(TResultORD(APos)) or (abs(GetData(TResultORD(APos))) = 999) then
                        Result := '--'
                    else
                        Result := GetFloatToStr(GetData(TResultORD(APos), 1), 1);

                    if IsUnit and (Result <> '--') then
                        Result := Result + ' A';

                    InsertResultTag;
                end;

            ord(roDataFwSpeed), ord(roDataBwSpeed):
                begin
                    if not IsExists(TResultORD(APos)) and not IsTested(TResultORD(APos)) then
                        Exit;

                    if not IsExists(TResultORD(APos)) or (abs(GetData(TResultORD(APos))) = 999) then
                        Result := '--'
                    else
                        Result := GetFloatToStr(GetData(TResultORD(APos), 1), 1);

                    if IsUnit and (Result <> '--') then
                        Result := Result + ' mm/s';

                    InsertResultTag;
                end;

            ord(roDataFwInitNoise), ord(roDataBwInitNoise), ord(roDataFwRunNoise), ord(roDataBwRunNoise):

                begin
                    if not IsExists(TResultORD(APos)) and not IsTested(TResultORD(APos)) then
                        Exit;

                    if not IsExists(TResultORD(APos)) or (abs(GetData(TResultORD(APos))) = 999) then
                        Result := '--'
                    else
                        Result := GetFloatToStr(GetData(TResultORD(APos), 1), 1);

                    if IsUnit and (Result <> '--') then
                        Result := Result + ' dB';

                    InsertResultTag;
                end;

            ord(roRsFwMotor), ord(roRsBwMotor), ord(roRsTotCurr), ord(roRsMotor), ord(roRsTotMotor), ord(roRsNoise), ord(roRsTotNoise), ord(roRsAbnormalSound):
                begin
                    if not IsExists(TResultORD(APos)) and not IsTested(TResultORD(APos)) then
                        Exit;

                    Result := JUDGE_TXT[GetResult(TResultORD(APos))];

                    InsertResultTag;
                end;

            //---------------
                ord(roCycleTime):
                begin
                    if GetData(roCycleTime) = 0 then
                        Exit;
                    Result := GetFloatToStr(GetSeconds(GetData(roCycleTime)), 1);
                end;

        else
            mIsProcessDone := False;
        end;

    end;
end;

function TSubDataBox4Mtr.GetTag: integer;
begin
    Result := mParent.Tag;
end;

procedure TSubDataBox4Mtr.InitData(AReadEnv: Boolean);
var
    Buf: PResult;
    IsMemTest: Boolean;
begin

    SetDataInit(tsSlide);
    SetDataInit(tsTilt);
    SetDataInit(tsHeight);
    SetDataInit(tsLegSupt);
    SetDataInit(tsSwivel);

    SetDataInit(tsNOISE);
    SetDataInit(tsAbnormalSound);

    Buf := mParent.GetPResultBuffer;

    with mParent do
    begin
        Buf.rTested[tsSlide] := true;
        Buf.rTested[tsTilt] := Buf.rModel.rTypes.IsTiltExists;
        Buf.rTested[tsHeight] := Buf.rModel.rTypes.IsHeightExists;
        Buf.rTested[tsLegSupt] := Buf.rModel.rTypes.IsLegSuptExists;
        Buf.rTested[tsNoise] := True; //gSysEnv.rUseNoiseTest;
        Buf.rTested[tsCURR] := True; // gSysEnv.rUseCurrTest;
        Buf.rTested[tsSPEED] := True;
        Buf.rTested[tsDeviation] := False; //gsysEnv.rUseDeviation;

    end;
end;

function TSubDataBox4Mtr.IsExists(AORD: TResultORD): Boolean;
begin
    mIsProcessDone := True;
    with mParent do
    begin

        case AORD of
            roRsFwMotor, roRsBwMotor, roRsMotor, roDataFwCurr, roDataBwCurr, roDataFwSpeed, roDataBwSpeed:
                Result := IsExists(MotorOrd2TsOrd(RsBuf.rCurMtr));

            roDataFwInitNoise, roDataBwInitNoise, roDataFwRunNoise, roDataBwRunNoise:
                Result := IsExists(MotorOrd2TsOrd(RsBuf.rCurMtr)) and IsExists(tsNOISE);

            roRsAbnormalSound:
                begin
                    Result := IsExists(tsAbnormalSound);
                end;

            roNo:
                begin
                    Result := IsExists(tsSlide) or IsExists(tsTilt) or IsExists(tsHeight) or IsExists(tsLegSupt) or IsExists(tsSwivel) or IsExists(tsNoise);
                end
        else
            mIsProcessDone := False;
        end;
    end;

end;

function TSubDataBox4Mtr.IsTested(AORD: TResultORD): Boolean;
begin
    mIsProcessDone := True;

    with mParent do
    begin

        case AORD of
            roRsSpecCheck:
                begin
                    Result := IsTested(tsSpecCheck);
                end;

            roDataFwSpeed, roDataBwSpeed:
                begin
                    Result := IsTested(MotorOrd2TsOrd(RsBuf.rCurMtr)) and IsTested(tsSpeed);
                end;
            roDataFwCurr, roDataBwCurr:
                begin
                    Result := IsTested(MotorOrd2TsOrd(RsBuf.rCurMtr)) and IsTested(tsCurr);
                end;

            roDataFwInitNoise, roDataBwInitNoise, roDataFwRunNoise, roDataBwRunNoise:
                begin
                    Result := IsTested(MotorOrd2TsOrd(RsBuf.rCurMtr)) and IsTested(tsNoise);
                end;

            roRsTotNoise, roRsNoise:
                Result := IsTested(tsNoise);

            roRsAbnormalSound:
                Result := IsTested(tsAbnormalSound);

            roRsFwMotor, roRsBwMotor, roRsMotor:
                begin
                    Result := IsTested(MotorOrd2TsOrd(RsBuf.rCurMtr));

                end;

            roRsTotMotor:
                Result := IsTested(tsSlide) or IsTested(tsTilt) or IsTested(tsHeight) or IsTested(tsLegSupt) or IsTested(tsSwivel);

            roRsWalkIn:
                Result := IsTested(tsWalkIn);

        else
            mIsProcessDone := False;

        end;
    end;
end;

procedure TSubDataBox4Mtr.SetData(AORD: TResultORD; const Value: Boolean);
var
    Buf: PResult;
begin
    mIsProcessDone := True;
    Buf := mParent.GetPResultBuffer;

    with mParent do
    begin

        case AORD of

            roRsAbnormalSound:
                begin
                    Buf.rValidity[tsAbnormalSound] := Value;
                    Buf.rExists[tsAbnormalSound] := True;
                    Buf.rTested[tsAbnormalSound] := True;
                end;

            roRsWalkIn:
                begin
                    Buf.rValidity[tsWalkIn] := Value;
                    Buf.rExists[tsWalkIn] := True;
                    Buf.rTested[tsWalkIn] := True;
                end;

            roRsMidPos:
                begin
                    Buf.rValidity[tsMidPos] := Value;
                    Buf.rExists[tsMidPos] := True;
                    Buf.rTested[tsMidPos] := True;
                end;

        else
            mIsProcessDone := False;

        end;
    end;

end;

procedure TSubDataBox4Mtr.SetData(AORD: TResultOrd; const Value: integer);
begin

    with mParent do
    begin

        case AORD of
            roNone:
                ;
            roSlide_CTRL:
                RsBuf.rCurMtr := tmSlide;

            roTilt_CTRL:
                RsBuf.rCurMtr := tmTilt;

            roHeight_CTRL:
                RsBuf.rCurMtr := tmHeight;

            roLegSupt_CTRL:
                RsBuf.rCurMtr := tmLegSupt;

            roSwivel_CTRL:
                RsBuf.rCurMtr := tmSwivel;


        else
            mIsProcessDone := False;
        end;
    end;

end;

procedure TSubDataBox4Mtr.SetDataInit(ATsMode: TTsORD);
var
    Buf: PResult;
begin
    mIsProcessDone := True;
    Buf := mParent.GetPResultBuffer;

    with mParent do
    begin
        case ATsMode of
            tsSlide, tsTilt, tsHeight, tsLegSupt, tsSwivel:
                begin
                    Buf.rValidity[ATsMode] := False;
                    Buf.rExists[ATsMode] := False;
                    with Buf.rDatMtrs[TsOrd2MotorOrd(ATsMode)] do
                    begin
                        Clear;
                    end;
                end;

            tsNoise:
                begin
                    Buf.rValidity[tsNoise] := False;
                    Buf.rExists[tsNoise] := False;
                    Buf.rDatNoise := -999;
                end;

            tsAbnormalSound:
                begin
                    Buf.rValidity[ATsMode] := False;
                    Buf.rExists[ATsMode] := False;
                    Buf.rTested[ATsMode] := False;
                end;

            tsWalkIn:
                begin
                    Buf.rValidity[ATsMode] := False;
                    Buf.rExists[ATsMode] := False;
                    Buf.rTested[ATsMode] := False;
                end;

        else
            mIsProcessDone := False;
            gLog.Panel('SubDataBox4Mtr.SetDataInit:%s(%d) 처리 누락', [GetTsOrdName(ATsMode), Ord(ATsMode)]);
        end;
    end;

end;

procedure TSubDataBox4Mtr.SetData(AORD: TResultORD; const Value: double);
begin
    mIsProcessDone := True;

    with mParent.RsBuf^ do
    begin

        case AORD of
            roDataFwCurr:
                begin
                    rDatMtrs[rCurMtr].rItems[twForw].rCurr := Value;
                    rExists[MotorOrd2TsOrd(rCurMtr)] := True;
                end;

            roDataBwCurr:
                begin
                    rDatMtrs[rCurMtr].rItems[twBack].rCurr := Value;
                    rExists[MotorOrd2TsOrd(rCurMtr)] := True;
                end;

            roDataFwSpeed:
                begin
                    rDatMtrs[rCurMtr].rItems[twForw].rSpeed := Max(0, Value + mParent.MotorOffset.rVals[rCurMtr, twForw].rSpeed);
                    rExists[MotorOrd2TsOrd(rCurMtr)] := True;
                end;

            roDataBwSpeed:
                begin
                    rDatMtrs[rCurMtr].rItems[twBack].rSpeed := Max(0, Value + mParent.MotorOffset.rVals[rCurMtr, twBack].rSpeed);
                    rExists[MotorOrd2TsOrd(rCurMtr)] := True;
                end;

            roDataFwInitNoise:
                begin
                    rDatMtrs[rCurMtr].rItems[twForw].rInitNoise := Value + mParent.MotorOffset.rVals[rCurMtr, twForw].rInitNoise;
                    rExists[tsNoise] := True;
                end;
            roDataBwInitNoise:
                begin
                    rDatMtrs[rCurMtr].rItems[twBack].rInitNoise := Value + mParent.MotorOffset.rVals[rCurMtr, twBack].rInitNoise;
                    rExists[tsNoise] := True;
                end;
            roDataFwRunNoise:
                begin
                    rDatMtrs[rCurMtr].rItems[twForw].rRunNoise := Value + mParent.MotorOffset.rVals[rCurMtr, twForw].rRunNoise;
                    rExists[tsNoise] := True;
                end;
            roDataBwRunNoise:
                begin
                    rDatMtrs[rCurMtr].rItems[twBack].rRunNoise := Value + mParent.MotorOffset.rVals[rCurMtr, twBack].rRunNoise;
                    rExists[tsNoise] := True;
                end;
        else
            mIsProcessDone := False;

        end;
    end;

end;

procedure TSubDataBox4Mtr.SetData(AORD: TResultORD; const Value: string);
begin

    with mParent do
    begin
        case AORD of
            roNone:
                ;
        else
            mIsProcessDone := False;
        end;
    end;

end;

procedure TSubDataBox4Mtr.SetResult(const AResult; Afpos: integer);
begin

end;

procedure TSubDataBox4Mtr.SetValidity;
begin
    with mParent do
    begin

        RsBuf.rValidity[tsSlide] := GetResult(tsSlide);
        RsBuf.rValidity[tsTilt] := GetResult(tsTilt);
        RsBuf.rValidity[tsHeight] := GetResult(tsHeight);
        RsBuf.rValidity[tsLegSupt] := GetResult(tsLegSupt);
        RsBuf.rValidity[tsSwivel] := GetResult(tsSwivel);

    end;
end;

end.

