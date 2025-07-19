{
	Ver.240912.00
}
unit SubDataBox4Mtr;

interface

uses
    BaseDataBox, DataBox, DataUnitOrd, DataUnit;

type
    TSubDataBox4Mtr = class(TBaseDataBox)
    private
        mParent: TDataBox;

        function GetTag: integer; override;
        procedure SetValidity; override;
        procedure SetExists(AORD: TResultORD; const IsExist: boolean); override;
        function GetUnitStr(AORD: TResultORD): string; override;

    public
        constructor Create(Parent: TDataBox);

        procedure InitData(AReadEnv: boolean = false); override;
        procedure SetDataInit(ATsMode: TTsORD); override;

        function GetPResultBuffer(): PResult; override;

        function IsExists(AORD: TResultORD): boolean; overload; override;
        function IsTested(AORD: TResultORD): boolean; overload; override;

        function GetData(AORD: TResultORD; ADigit: integer = 0): double; overload; override;
        function GetResult(AORD: TResultORD): boolean; overload; override;
        function GetResult(ATsMode: TTsORD): boolean; overload; override;
        function GetResultToATxt(APos: integer; IsUnit: boolean; IsResult: boolean = false): string; override;

        procedure SetData(AORD: TResultORD; const Value: double); overload; override;
        procedure SetData(AORD: TResultORD; const Value: string); overload; override;
        procedure SetData(AORD: TResultORD; const Value: boolean); overload; override;
        procedure SetData(AORD: TResultOrd; const Value: integer); overload; override;
    end;

implementation

uses
    Log, SeatMotorType, ModelUnit, SysEnv, DataUnitHelper, SysUtils, Math;

{ TSubDataBox4Mtr }

constructor TSubDataBox4Mtr.Create(Parent: TDataBox);
begin
    inherited Create;
    mParent := Parent
end;

function TSubDataBox4Mtr.GetData(AORD: TResultORD; ADigit: integer): double;
begin
    mIsProcessDone := true;

    with mParent do
    begin
        case AORD of
            roSlide_CTRL, roTilt_CTRL, roRelax_CTRL, roRecl_CTRL, roTiltUpWalkin_CTRL, roHeadrest_CTRL, roShoulder_CTRL, roLongSlide_CTRL:
                begin
                    Result := Ord(Rsbuf.rCurMtr);
                end;

            roDataFwTime:
                Result := Rsbuf.CurDatMtr.rItems[twForw].rTime;

            roDataBwTime:
                Result := Rsbuf.CurDatMtr.rItems[twBack].rTime;

            roDataFwCurr:
                Result := Rsbuf.CurDatMtr.rItems[twForw].rCurr;

            roDataBwCurr:
                Result := Rsbuf.CurDatMtr.rItems[twBack].rCurr;

            roDataFwSpeed:
                Result := Rsbuf.CurDatMtr.rItems[twForw].rSpeed;

            roDataBwSpeed:
                Result := Rsbuf.CurDatMtr.rItems[twBack].rSpeed;

            roDataFwInitNoise:
                Result := Rsbuf.CurDatMtr.rItems[twForw].rInitNoise;

            roDataBwInitNoise:
                Result := Rsbuf.CurDatMtr.rItems[twBack].rInitNoise;

            roDataFwRunNoise:
                Result := Rsbuf.CurDatMtr.rItems[twForw].rRunNoise;

            roDataBwRunNoise:
                Result := Rsbuf.CurDatMtr.rItems[twBack].rRunNoise;

            roDataFwInitNoiseDev:
                Result := Rsbuf.CurDatMtr.rItems[twForw].rInitNoiseDev;

            roDataBwInitNoiseDev:
                Result := Rsbuf.CurDatMtr.rItems[twBack].rInitNoiseDev;

            roDataFwRunNoiseDev:
                Result := Rsbuf.CurDatMtr.rItems[twForw].rRunNoiseDev;

            roDataBwRunNoiseDev:
                Result := Rsbuf.CurDatMtr.rItems[twBack].rRunNoiseDev;

            roDataFwStrokeAmount:
                Result := Rsbuf.CurDatMtr.rItems[twForw].rStrokeAmount;

            roDataBwStrokeAmount:
                Result := Rsbuf.CurDatMtr.rItems[twBack].rStrokeAmount;

            roDataFwAngle:
                Result := Rsbuf.CurDatMtr.rItems[twForw].rAngle;

            roDataBwAngle:
                Result := Rsbuf.CurDatMtr.rItems[twBack].rAngle;

        else
            mIsProcessDone := false;
            Result := 0.0;
        end;

        if ADigit <> 0 then
            Result := StrToFloatDef(Format('%.*f', [ADigit, Result]), Result);
    end;

end;

function TSubDataBox4Mtr.GetPResultBuffer: PResult;
begin
    Result := mParent.GetPResultBuffer;
end;

function TSubDataBox4Mtr.GetResult(ATsMode: TTsORD): boolean;
var
    CurMtr: TMotorORD;
begin
    mIsProcessDone := true;
    Result := True;

    CurMtr := Rsbuf.rCurMtr;

    with mParent do
    begin
        case ATsMode of
            tsSlide, tsCushTilt, tsRelax, tsHeadrest, tsRecl, tsWalkinUpTilt, tsShoulder, tsLongSlide:
                begin
                    try
                        Rsbuf.rCurMtr := TsOrd2MotorOrd(ATsMode);
                        Result := GetResult(roRsMotor);
                    finally
                        Rsbuf.rCurMtr := CurMtr;
                    end;
                end;

            tsNoise, tsNoiseDev:
                Result := GetResult(roRsTotNoise);

            tsCurr:
                Result := GetResult(roRsTotCurr);

            tsSpeed:
                Result := GetResult(roRsTotSpeed);

            tsStrokeAmount:
                Result := GetResult(roRsStrokeAmount);

            tsAngle:
                Result := GetResult(roRsTotAngle);

            tsContinuity:
                Result := GetResult(roRsTotContinuity);

            tsAbnormalSound:
                Result := GetResult(roRsAbnormalSound);

            tsMotor:
                Result := GetResult(roRsTotMotor);
        else
            mIsProcessDone := False;
            Result := False;
        end;
    end;
end;

function TSubDataBox4Mtr.GetResult(AORD: TResultORD): boolean;
var
    CurMtr, Item: TMotorORD;
begin
    mIsProcessDone := true;
    Result := True;

    CurMtr := Rsbuf.rCurMtr;

    with mParent do
    begin

        case AORD of
            roDataFwTime, roDataBwTime:
                Result := Rsbuf.rModel.rSpecs.rMotors[CurMtr].rTime.IsIn(GetData(AORD));

            roDataFwCurr, roDataBwCurr:
                Result := Rsbuf.rModel.rSpecs.rMotors[CurMtr].rCurr.IsIn(GetData(AORD));

            roRsCurr:
                Result := GetResult(roDataFwCurr) and GetResult(roDataBwCurr);

            roRsTotCurr:
                begin
                    try
                        for Item := Low(TMotorORD) to High(TMotorORD) do
                        begin
                            Rsbuf.rCurMtr := Item;
                            Result := Result and GetResult(roRsCurr);
                        end;
                    finally
                        Rsbuf.rCurMtr := CurMtr;
                    end;
                end;

            roDataFwSpeed:
                Result := Rsbuf.rModel.rSpecs.rMotors[CurMtr].rSpeed[twForw].IsIn(GetData(AORD));

            roDataBwSpeed:
                Result := Rsbuf.rModel.rSpecs.rMotors[CurMtr].rSpeed[twForw].IsIn(GetData(AORD));

            roRsSpeed:
                Result := GetResult(roDataFwSpeed) and GetResult(roDataBwSpeed);

            roRsTotSpeed:
                begin
                    try
                        for Item := Low(TMotorORD) to High(TMotorORD) do
                        begin
                            Rsbuf.rCurMtr := Item;
                            Result := Result and GetResult(roRsSpeed);
                        end;
                    finally
                        Rsbuf.rCurMtr := CurMtr;
                    end;
                end;

            roDataFwInitNoise, roDataBwInitNoise:
                Result := Rsbuf.rModel.rSpecs.rMotors[CurMtr].rInitNoise >= GetData(AORD);

            roDataFwRunNoise, roDataBwRunNoise:
                Result := Rsbuf.rModel.rSpecs.rMotors[CurMtr].rRunNoise >= GetData(AORD);

            roDataFwInitNoiseDev, roDataBwInitNoiseDev:
                Result := Rsbuf.rModel.rSpecs.rMotors[CurMtr].rInitNoiseDev >= GetData(AORD);

            roDataFwRunNoiseDev, roDataBwRunNoiseDev:
                Result := Rsbuf.rModel.rSpecs.rMotors[CurMtr].rRunNoiseDev >= GetData(AORD);

            roRsNoise:
                GetCompoJudge(
                    [
                        roDataFwInitNoise, roDataBwInitNoise, roDataFwRunNoise, roDataBwRunNoise,
                        roDataFwInitNoiseDev, roDataBwInitNoiseDev, roDataFwRunNoiseDev, roDataBwRunNoiseDev
                    ]
                );
            roRsTotNoise:
                begin
                    try
                        for Item := Low(TMotorORD) to High(TMotorORD) do
                        begin
                            Rsbuf.rCurMtr := Item;
                            Result := Result and GetResult(roRsNoise);
                        end;
                    finally
                        Rsbuf.rCurMtr := CurMtr;
                    end;
                end;

            roDataFwStrokeAmount, roDataBwStrokeAmount:
                Result := Rsbuf.rModel.rSpecs.rMotors[CurMtr].rStrokeAmount.IsIn(GetData(AORD));

            roRsStrokeAmount:
                Result := GetResult(roDataFwStrokeAmount) and GetResult(roDataBwStrokeAmount);

            roRsTotStrokeAmount:
                begin
                    try
                        for Item := Low(TMotorORD) to High(TMotorORD) do
                        begin
                            Rsbuf.rCurMtr := Item;
                            Result := Result and GetResult(roRsStrokeAmount);
                        end;
                    finally
                        Rsbuf.rCurMtr := CurMtr;
                    end;
                end;

            roDataFwAngle:
                Result := Rsbuf.rModel.rSpecs.rMotors[CurMtr].rAngle[twForw].IsIn(GetData(AORD));

            roDataBwAngle:
                Result := Rsbuf.rModel.rSpecs.rMotors[CurMtr].rAngle[twBack].IsIn(GetData(AORD));

            roRsAngle:
                Result := GetResult(roDataFwAngle) and GetResult(roDataBwAngle);

            roRsTotAngle:
                begin
                    try
                        for Item := Low(TMotorORD) to High(TMotorORD) do
                        begin
                            Rsbuf.rCurMtr := Item;
                            Result := Result and GetResult(roRsAngle);
                        end;
                    finally
                        Rsbuf.rCurMtr := CurMtr;
                    end;
                end;

            roRsFwContinuity:
                Result := Rsbuf.CurDatMtr.rItems[twForw].rContinuity;

            roRsBwContinuity:
                Result := Rsbuf.CurDatMtr.rItems[twBack].rContinuity;

            roRsContinuity:
                Result := GetResult(roRsFwContinuity) and GetResult(roRsBwContinuity);

            roRsTotContinuity:
                begin
                    try
                        for Item := Low(TMotorORD) to High(TMotorORD) do
                        begin
                            Rsbuf.rCurMtr := Item;
                            Result := Result and GetResult(roRsContinuity);
                        end;
                    finally
                        Rsbuf.rCurMtr := CurMtr;
                    end;
                end;

            roRsFwMotor:
                Result :=
                        GetCompoJudge(
                            [
                                roDataFwCurr, roDataFwSpeed, roDataFwInitNoise, roDataFwRunNoise,
                                roDataFwInitNoiseDev, roDataFwRunNoiseDev, roDataFwStrokeAmount, roDataFwAngle, roRsFwContinuity
                            ]
                        );
            roRsBwMotor:
                Result :=
                        GetCompoJudge(
                            [
                                roDataBwCurr, roDataBwSpeed, roDataBwInitNoise, roDataBwRunNoise,
                                roDataBwInitNoiseDev, roDataBwRunNoiseDev, roDataBwStrokeAmount, roDataBwAngle, roRsBwContinuity
                            ]
                        );

            roRsAbnormalSound:
                Result := Rsbuf.rAbnormalSound;

            roRsMotor:
                Result :=
                        GetCompoJudge(
                            [
                                roRsFwMotor, roRsBwMotor, roRsLimit, roRsAbnormalSound
                            ]
                        );
            roRsTotMotor:
                begin
                    try
                        for Item := Low(TMotorORD) to High(TMotorORD) do
                        begin
                            Rsbuf.rCurMtr := Item;
                            Result := Result and GetResult(roRsMotor);
                        end;
                    finally
                        Rsbuf.rCurMtr := CurMtr;
                    end;
                end;

        else
            mIsProcessDone := false;
            Result := false;
        end;
    end;

end;

function TSubDataBox4Mtr.GetResultToATxt(APos: integer; IsUnit, IsResult: boolean): string;
begin
    mIsProcessDone := true;
    Result := '';

    with mParent do
    begin
        case APos of

            ord(roSpecTimeLo) .. ord(roSpecBwAngleHiLo):
                Result := RsBuf.ModelToStr(TResultOrd(APos), IsUnit);

            ord(roDataFwTime) .. ord(roDataBwAngle):
                begin
                    if not IsExists(TResultORD(APos)) and not IsTested(TResultORD(APos)) then
                        Exit;

                    if not IsExists(TResultORD(APos)) or (abs(GetData(TResultORD(APos))) = 0) then
                        Result := '--'
                    else
                        Result := GetFloatToStr(GetData(TResultORD(Apos), 1), 1);

                    if IsUnit and (Result <> '--') then
                        Result := Result + GetUnitStr(TResultORD(APos));

                    if IsResult and IsTested(TResultORD(APos)) then
                        Result := ARY_TAG[GetResult(TResultORD(APOS))] + Result;
                end;
        else
            mIsProcessDone := false;
        end;
    end;
end;

function TSubDataBox4Mtr.GetTag: integer;
begin
    Result := mParent.Tag;
end;

function TSubDataBox4Mtr.GetUnitStr(AORD: TResultORD): string;
begin
    case AORD of
        roDataFwTime, roDataBwTime :
            Result := ' s';
        roDataFwCurr, roDataBwCurr :
            Result := ' A';
        roDataFwSpeed, roDataBwSpeed :
            begin
                if RsBuf.rCurMtr In [tmRecl] then
                    Result := ' °/s'
                else
                    Result := ' mm/s';
            end;
        roDataFwInitNoise, roDataFwRunNoise, roDataBwInitNoise, roDataBwRunNoise,
        roDataFwInitNoiseDev, roDataFwRunNoiseDev, roDataBwInitNoiseDev, roDataBwRunNoiseDev:
            Result := ' dB';
        roDataFwStrokeAmount, roDataBwStrokeAmount:
            Result := ' Pulse';
        roDataFwAngle, roDataBwAngle:
            Result := ' °';

    else
        Result := '';
    end;
end;

procedure TSubDataBox4Mtr.InitData(AReadEnv: boolean);
var
    Item: TMotorORD;
begin
    with mParent do
    begin
        for Item := Low(TMotorORD) to High(TMotorORD) do
        begin
            SetDataInit(MotorOrd2TsOrd(Item));
        end;

        SetDataInit(tsMotor);
        SetDataInit(tsTime);
        SetDataInit(tsNoise);
        SetDataInit(tsNoiseDev);
        SetDataInit(tsCurr);
        SetDataInit(tsSpeed);
        SetDataInit(tsStrokeAmount);
        SetDataInit(tsAngle);
        SetDataInit(tsContinuity);
        SetDataInit(tsAbnormalSound);
        SetDataInit(tsMidPos);
    end
end;

function TSubDataBox4Mtr.IsExists(AORD: TResultORD): boolean;
var
    CurMtrORD: TTsORD;
    ContinuityTestMotor: Boolean;
begin
    mIsProcessDone := true;

    CurMtrORD := MotorOrd2TsOrd(Rsbuf.rCurMtr);

    ContinuityTestMotor := CurMtrORD in [tsHeadrest];

    with mParent do
    begin
        case AORD of
            roDataFwCurr, roDataBwCurr, roRsCurr:
                Result := IsExists(CurMtrORD) and IsExists(tsCurr) and (not ContinuityTestMotor);

            roRsTotCurr:
                Result := IsExists(tsMotor) and IsExists(tsCurr);

            roDataFwSpeed, roDataBwSpeed, roRsSpeed:
                Result := IsExists(CurMtrORD) and IsExists(tsSpeed) and (not ContinuityTestMotor);

            roRsTotSpeed:
                Result := IsExists(tsMotor) and IsExists(tsSpeed);

            roDataFwInitNoise, roDataFwRunNoise, roDataBwInitNoise, roDataBwRunNoise, roRsNoise:
                Result := IsExists(CurMtrORD) and IsExists(tsNoise) and (not ContinuityTestMotor);

            roRsTotNoise:
                Result := IsExists(tsMotor) and IsExists(tsNoise);

            roDataFwInitNoiseDev, roDataFwRunNoiseDev, roDataBwInitNoiseDev, roDataBwRunNoiseDev:
                Result := IsExists(CurMtrORD) and IsExists(tsNoiseDev) and (not ContinuityTestMotor);

            roDataFwStrokeAmount, roDataBwStrokeAmount, roRsStrokeAmount:
                Result := IsExists(CurMtrORD) and IsExists(tsStrokeAmount) and (not ContinuityTestMotor);

            roRsTotStrokeAmount:
                Result := IsExists(tsMotor) and IsExists(tsStrokeAmount) and (not ContinuityTestMotor);

            roDataFwAngle, roDataBwAngle, roRsAngle:
                Result := IsExists(CurMtrORD) and IsExists(tsAngle) and (not ContinuityTestMotor);

            roRsTotAngle:
                Result := IsExists(tsMotor) and IsExists(tsAngle);

            roRsFwContinuity, roRsBwContinuity, roRsContinuity:
                Result := IsExists(CurMtrORD) and IsExists(tsContinuity) and ContinuityTestMotor;

            roRsTotContinuity:
                Result := IsExists(tsMotor) and IsExists(tsContinuity);

            roRsFwMotor, roRsBwMotor, roRsMotor:
                Result := IsExists(CurMtrORD);

            roRsTotMotor:
                Result := IsExists(tsMotor);

            roRsAbnormalSound:
                Result := IsTested(tsAbnormalSound);
        else
            mIsProcessDone := false;
        end;
    end;
end;

function TSubDataBox4Mtr.IsTested(AORD: TResultORD): boolean;
var
    CurMtrORD: TTsORD;
    ContinuityTestMotor: Boolean;
begin
    mIsProcessDone := true;

    CurMtrORD := MotorOrd2TsOrd(Rsbuf.rCurMtr);

    ContinuityTestMotor := CurMtrORD in [tsHeadrest];

    with mParent do
    begin
        case AORD of
            roDataFwCurr, roDataBwCurr, roRsCurr:
                Result := IsTested(CurMtrORD) and IsTested(tsCurr) and (not ContinuityTestMotor);

            roRsTotCurr:
                Result := IsTested(tsMotor) and IsTested(tsCurr);

            roDataFwSpeed, roDataBwSpeed, roRsSpeed:
                Result := IsTested(CurMtrORD) and IsTested(tsSpeed) and (not ContinuityTestMotor);

            roRsTotSpeed:
                Result := IsTested(tsMotor) and IsTested(tsSpeed);

            roDataFwInitNoise, roDataFwRunNoise, roDataBwInitNoise, roDataBwRunNoise, roRsNoise:
                Result := IsTested(CurMtrORD) and IsTested(tsNoise) and (not ContinuityTestMotor);

            roRsTotNoise:
                Result := IsTested(tsMotor) and IsTested(tsNoise);

            roDataFwInitNoiseDev, roDataFwRunNoiseDev, roDataBwInitNoiseDev, roDataBwRunNoiseDev:
                Result := IsTested(CurMtrORD) and IsTested(tsNoiseDev) and (not ContinuityTestMotor);

            roDataFwStrokeAmount, roDataBwStrokeAmount, roRsStrokeAmount:
                Result := IsTested(CurMtrORD) and IsTested(tsStrokeAmount) and (not ContinuityTestMotor);

            roRsTotStrokeAmount:
                Result := IsTested(tsMotor) and IsTested(tsStrokeAmount);

            roDataFwAngle, roDataBwAngle, roRsAngle:
                Result := IsTested(CurMtrORD) and IsTested(tsAngle) and (not ContinuityTestMotor);

            roRsTotAngle:
                Result := IsTested(tsMotor) and IsTested(tsAngle);

            roRsFwContinuity, roRsBwContinuity, roRsContinuity:
                Result := IsTested(CurMtrORD) and IsTested(tsContinuity) and ContinuityTestMotor;

            roRsTotContinuity:
                Result := IsTested(tsMotor) and IsTested(tsContinuity);

            roRsFwMotor, roRsBwMotor, roRsMotor:
                Result := IsTested(CurMtrORD);

            roRsTotMotor:
                Result := IsTested(tsMotor);

            roRsAbnormalSound:
                Result := IsTested(tsAbnormalSound);
        else
            mIsProcessDone := false;
        end;
    end;
end;

procedure TSubDataBox4Mtr.SetData(AORD: TResultORD; const Value: boolean);
var
    Buf: PResult;
    DatMtr : TMotorData;
begin
    mIsProcessDone := true;
    Buf := mParent.GetPResultBuffer;

    DatMtr := Rsbuf.rDatMtrs[Rsbuf.rCurMtr];

    SetExists(AORD, true);

    with mParent do
    begin

        case AORD of

            roRsAbnormalSound:
                Buf.rAbnormalSound := Value;

            roRsFwContinuity:
                DatMtr.rItems[twForw].rContinuity := Value;

            roRsBwContinuity:
                DatMtr.rItems[twBack].rContinuity := Value;

        else
            mIsProcessDone := false;

        end;
    end;

end;

procedure TSubDataBox4Mtr.SetData(AORD: TResultOrd; const Value: integer);
begin

    with mParent do
    begin

        case AORD of
            roSlide_CTRL, roTilt_CTRL, roRelax_CTRL,
            roRecl_CTRL, roTiltUpWalkin_CTRL, roShoulder_CTRL,
            roHeadrest_CTRL, roLongSlide_CTRL:
                RsBuf.rCurMtr := TMotorOrd(Value);
        else
            mIsProcessDone := false;
        end;
    end;

end;

procedure TSubDataBox4Mtr.SetDataInit(ATsMode: TTsORD);
var
    Buf: PResult;
begin
    mIsProcessDone := true;
    Buf := mParent.GetPResultBuffer;

    with mParent do
    begin
        Buf.rValidity[ATsMode] := False;
        Buf.rExists[ATsMode] := False;

        case ATsMode of
            tsSlide:
                begin
                    Buf.rTested[ATsMode] := Buf.rModel.rTypes.IsSlideMtrExists;
                    Buf.rDatMtrs[tmSlide].Clear;
                end;
            tsCushTilt:
                begin
                    Buf.rTested[ATsMode] := Buf.rModel.rTypes.IsCushTiltMtrExists;
                    Buf.rDatMtrs[tmCushTilt].Clear;
                end;
            tsRelax:
                begin
                    Buf.rTested[ATsMode] := Buf.rModel.rTypes.IsRelaxMtrExists;
                    Buf.rDatMtrs[tmRelax].Clear;
                end;
            tsRecl:
                begin
                    Buf.rTested[ATsMode] := Buf.rModel.rTypes.IsReclineMtrExists;
                    Buf.rDatMtrs[tmRecl].Clear;
                end;
            tsWalkinUpTilt:
                begin
                    Buf.rTested[ATsMode] := Buf.rModel.rTypes.IsWalkinTiltMtrExists;
                    Buf.rDatMtrs[tmWalkinUpTilt].Clear;
                end;
            tsShoulder:
                begin
                    Buf.rTested[ATsMode] := Buf.rModel.rTypes.IsShoulderMtrExists;
                    Buf.rDatMtrs[tmShoulder].Clear;
                end;
            tsHeadrest:
                begin
                    Buf.rTested[ATsMode] := Buf.rModel.rTypes.IsHeadRestMtrExists;
                    Buf.rDatMtrs[tmHeadrest].Clear;
                end;
            tsLongSlide:
                begin
                    Buf.rTested[ATsMode] := False; // 더미 롱슬라이드 사용안함.
                    Buf.rDatMtrs[tmLongSlide].Clear;
                end;
            tsAbnormalSound:
                begin
                    Buf.rTested[ATsMode] := True; // 이음체크 선택없이 사용.
                end;
            tsMotor:
                begin
                    Buf.rTested[ATsMode] := IsTested(tsSlide) or IsTested(tsCushTilt) or IsTested(tsRelax) or
                                            IsTested(tsRecl) or IsTested(tsWalkinUpTilt) or IsTested(tsShoulder);
                end;
            tsTime:
                begin
                    Buf.rTested[ATsMode] := True; // 모터 시간 무조건 수집
                end;
            tsNoise:
                begin
                    Buf.rTested[ATsMode] := IsTested(tsMotor) and gSysEnv.rSoundProof.rUseNoise;
                end;
            tsNoiseDev:
                begin
                    Buf.rTested[ATsMode] := False;  // 소음 편차 사용 안함. 필요시 활성화
                end;
            tsCurr:
                begin
                    Buf.rTested[ATsMode] := IsTested(tsMotor) and gSysEnv.rSoundProof.rUseCurr;
                end;
            tsSpeed:
                begin
                    Buf.rTested[ATsMode] := IsTested(tsMotor) and gSysEnv.rSoundProof.rUseSpeed;
                end;
            tsStrokeAmount:
                begin
                    Buf.rTested[ATsMode] := IsTested(tsMotor) and gSysEnv.rSoundProof.rUseStrokeAmount;
                end;
            tsAngle:
                begin
                    Buf.rTested[ATsMode] := IsTested(tsRecl) and (gSysEnv.rBackAngle.rUseFolding or gSysEnv.rBackAngle.rUseRearMost);
                end;
            tsContinuity:
                begin
                    Buf.rTested[ATsMode] := IsTested(tsHeadrest);
                end;
            tsMidPos:
                begin
                    Buf.rTested[ATsMode] := True; // 무조건 정렬
                end;
        end;
    end;

end;

procedure TSubDataBox4Mtr.SetExists(AORD: TResultORD; const IsExist: boolean);
var
    Buf: PResult;
    CurMtrORD: TTsORD;
begin
    CurMtrORD := MotorOrd2TsOrd(Rsbuf.rCurMtr);

    Rsbuf.rExists[CurMtrORD] := IsExist;

    case AORD of
        roDataFwTime, roDataBwTime:
            Rsbuf.rExists[tsTime] := IsExist;

        roDataFwCurr, roDataBwCurr:
            Rsbuf.rExists[tsCurr] := IsExist;

        roDataFwSpeed, roDataBwSpeed:
            Rsbuf.rExists[tsSpeed] := IsExist;

        roDataFwInitNoise, roDataFwRunNoise, roDataBwInitNoise, roDataBwRunNoise:
            Rsbuf.rExists[tsNoise] := IsExist;

        roDataFwInitNoiseDev, roDataFwRunNoiseDev, roDataBwInitNoiseDev, roDataBwRunNoiseDev:
            Rsbuf.rExists[tsNoiseDev] := IsExist;

        roDataFwStrokeAmount, roDataBwStrokeAmount:
            Rsbuf.rExists[tsStrokeAmount] := IsExist;

        roDataFwAngle, roDataBwAngle:
            RsBuf.rExists[tsAngle] := IsExist;

        roRsFwContinuity, roRsBwContinuity:
            RsBuf.rExists[tsContinuity] := IsExist;

        roRsAbnormalSound:
            Rsbuf.rExists[tsAbnormalSound] := IsExist;

    else

    end;
end;

procedure TSubDataBox4Mtr.SetData(AORD: TResultORD; const Value: double);
var
    Buf: PResult;
    DatMtr : TMotorData;
begin
    mIsProcessDone := true;
    Buf := mParent.GetPResultBuffer;


    DatMtr := Rsbuf.rDatMtrs[Rsbuf.rCurMtr];

    SetExists(AORD, true);

    with mParent.RsBuf^ do
    begin
        case AORD of
            roDataFwTime:
                DatMtr.rItems[twForw].rTime := Value;
            roDataBwTime:
                DatMtr.rItems[twBack].rTime := Value;
            roDataFwCurr:
                DatMtr.rItems[twForw].rCurr := Value;
            roDataBwCurr:
                DatMtr.rItems[twBack].rCurr := Value;
            roDataFwSpeed:
                DatMtr.rItems[twForw].rSpeed := Max(0, Value + mParent.MotorOffset.rVals[rCurMtr, twForw].rSpeed);
            roDataBwSpeed:
                DatMtr.rItems[twBack].rSpeed := Max(0, Value + mParent.MotorOffset.rVals[rCurMtr, twBack].rSpeed);
            roDataFwInitNoise:
                DatMtr.rItems[twForw].rInitNoise := Max(0, Value + mParent.MotorOffset.rVals[rCurMtr, twForw].rInitNoise);
            roDataFwRunNoise:
                DatMtr.rItems[twForw].rRunNoise := Max(0, Value + mParent.MotorOffset.rVals[rCurMtr, twForw].rRunNoise);
            roDataBwInitNoise:
                DatMtr.rItems[twBack].rInitNoise := Max(0, Value + mParent.MotorOffset.rVals[rCurMtr, twBack].rInitNoise);
            roDataBwRunNoise:
                DatMtr.rItems[twBack].rRunNoise := Max(0, Value + mParent.MotorOffset.rVals[rCurMtr, twBack].rRunNoise);
            roDataFwInitNoiseDev:
                DatMtr.rItems[twForw].rInitNoiseDev := Max(0, Value + mParent.MotorOffset.rVals[rCurMtr, twForw].rInitNoise);
            roDataFwRunNoiseDev:
                DatMtr.rItems[twForw].rRunNoiseDev := Max(0, Value + mParent.MotorOffset.rVals[rCurMtr, twForw].rRunNoise);
            roDataBwInitNoiseDev:
                DatMtr.rItems[twBack].rInitNoiseDev := Max(0, Value + mParent.MotorOffset.rVals[rCurMtr, twBack].rInitNoise);
            roDataBwRunNoiseDev:
                DatMtr.rItems[twBack].rRunNoiseDev := Max(0, Value + mParent.MotorOffset.rVals[rCurMtr, twBack].rRunNoise);
            roDataFwStrokeAmount:
                DatMtr.rItems[twForw].rStrokeAmount := Max(0, Value + mParent.MotorOffset.rVals[rCurMtr, twForw].rStrokeAmount);
            roDataBwStrokeAmount:
                DatMtr.rItems[twBack].rStrokeAmount := Max(0, Value + mParent.MotorOffset.rVals[rCurMtr, twBack].rStrokeAmount);
            roDataFwAngle:
                DatMtr.rItems[twForw].rAngle := Max(0, Value + mParent.MotorOffset.rVals[rCurMtr, twForw].rAngle);
            roDataBwAngle:
                DatMtr.rItems[twBack].rAngle := Max(0, Value + mParent.MotorOffset.rVals[rCurMtr, twBack].rAngle);
        else
            mIsProcessDone := false;
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
            mIsProcessDone := false;
        end;
    end;

end;

procedure TSubDataBox4Mtr.SetValidity;
begin

end;

end.

