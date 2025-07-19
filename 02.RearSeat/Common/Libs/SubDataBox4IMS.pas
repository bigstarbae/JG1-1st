{
	Ver.240912.00
}
unit SubDataBox4IMS;

interface
uses
    BaseDataBox, DataBox, DataUnit, DataUnitOrd;

type
    TSubDataBox4IMS = class(TBaseDataBox)
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
    Log, SeatType, SeatMotorType, ModelUnit, SysEnv, DataUnitHelper;

{ TSubDataBox4IMS }

constructor TSubDataBox4IMS.Create(Parent: TDataBox);
begin
    inherited Create;
    mParent := Parent
end;



function TSubDataBox4IMS.GetData(AORD: TResultORD; ADigit: integer): double;
begin
    mIsProcessDone := true;

    with mParent do
    begin

        mIsProcessDone := false;
        Result := 0.0;

    end;
end;

function TSubDataBox4IMS.GetPResultBuffer: PResult;
begin

end;

function TSubDataBox4IMS.GetResult(ATsMode: TTsORD): boolean;
begin
    mIsProcessDone := true;

    with mParent do
    begin

        case ATsMode of
            tsIMS_MEM1:
                Result := GetResult(roRsMem1);

            tsIMS_MEM2:
                Result := GetResult(roRsMem2);

            tsIMS_MEM3:
                Result := GetResult(roRsMem3);

            tsIMS_EasyAccess:
                Result := GetResult(roRsEasyAccess);

            tsLimit:
                Result := GetResult(roRsTotLimit);

            tsLimit_Slide, tsLimit_CushTilt, tsLimit_Relax, tsLimit_Headrest, tsLimit_Recl,
            tsLimit_WalkinUpTilt, tsLimit_Shoulder, tsLimit_LongSlide:
                Result := GetResult(roRsLimit);

        else
            mIsProcessDone := false;
            Result := false;
        end;
    end;
end;

function TSubDataBox4IMS.GetResult(AORD: TResultORD): boolean;
var
    Item: TMotorORD;
    CurMtr: TMotorORD;
begin
    Result := True;
    mIsProcessDone := true;

    CurMtr := Rsbuf.rCurMtr;

    with mParent do
    begin
        case AOrd of
            roRsLimit:
                Result := Rsbuf.CurDatMtr.rLimit;
            roRsTotLimit:
                begin
                    try
                        for Item := Low(TMotorORD) to High(TMotorORD) do
                        begin
                            Rsbuf.rCurMtr := Item;
                            Result := Result and GetResult(roRsLimit);
                        end;
                    finally
                        Rsbuf.rCurMtr := CurMtr;
                    end;
                end;

            roRsMem1:
                Result := Rsbuf.rDatIMS.rMEM1;

            roRsMem2:
                Result := Rsbuf.rDatIMS.rMEM2;

            roRsMem3:
                Result := Rsbuf.rDatIMS.rMEM3;

            roRsEasyAccess:
                Result := Rsbuf.rDatIMS.rEasyAccess;

            roRsIMS:
                Result := GetCompoJudge(
                    [
                        roRsTotLimit, roRsMem1, roRsMem2, roRsMem3, roRsEasyAccess
                    ]
                );
        else
            mIsProcessDone := false;
            Result := false;
        end;
    end;

end;



function TSubDataBox4IMS.GetResultToATxt(APos: integer; IsUnit, IsResult: boolean): string;
begin
    mIsProcessDone := true;


    with mParent do
    begin
        case APos of
            ord(roRsLimit).. ord(roRsIMS):
            begin
                if not IsExists(TResultOrd(APos)) and not IsTested(TResultOrd(APos)) then
                    Exit;

                Result := JUDGE_TXT[GetResult(TResultOrd(APos))];

                if IsResult and IsTested(TResultOrd(APos)) then
                    Result := ARY_TAG[GetResult(TResultOrd(APos))] + Result;
            end;
        else
            mIsProcessDone := false;
        end;
    end;
end;

function TSubDataBox4IMS.GetTag: integer;
begin
    Result := mParent.Tag;
end;

function TSubDataBox4IMS.GetUnitStr(AORD: TResultORD): string;
begin

end;

procedure TSubDataBox4IMS.InitData(AReadEnv: boolean);
begin
    SetDataInit(tsIMS_MEM1);
    SetDataInit(tsIMS_MEM2);
    SetDataInit(tsIMS_MEM3);
    SetDataInit(tsIMS_EasyAccess);
    SetDataInit(tsIMS);

    SetDataInit(tsLimit_Slide);
    SetDataInit(tsLimit_CushTilt);
    SetDataInit(tsLimit_Relax);
    SetDataInit(tsLimit_Headrest);
    SetDataInit(tsLimit_Recl);
    SetDataInit(tsLimit_WalkinUpTilt);
    SetDataInit(tsLimit_Shoulder);
    SetDataInit(tsLimit_LongSlide);
    SetDataInit(tsLimit);
end;

function TSubDataBox4IMS.IsExists(AORD: TResultORD): boolean;
var
    Item: TMotorORD;
    CurMtr: TMotorORD;
begin
    Result := True;
    mIsProcessDone := true;

    CurMtr := Rsbuf.rCurMtr;

    with mParent do
    begin
        case AORD of
            roRsMem1:
                Result := IsExists(tsIMS_MEM1);

            roRsMem2:
                Result := IsExists(tsIMS_MEM2);

            roRsMem3:
                Result := IsExists(tsIMS_MEM3);

            roRsEasyAccess:
                Result := IsExists(tsIMS_EasyAccess);

            roRsLimit:
                Result := IsExists(MotorOrd2TsOrd(Rsbuf.rCurMtr, True));

            roRsTotLimit:
                begin
                    try
                        for Item := Low(TMotorORD) to High(TMotorORD) do
                            Result := Result or IsExists(roRsLimit);
                    finally
                        Rsbuf.rCurMtr := CurMtr;
                    end;
                end;
        end;
    end;

end;

function TSubDataBox4IMS.IsTested(AORD: TResultORD): boolean;
var
    Item: TMotorORD;
    CurMtr: TMotorORD;
begin
    Result := True;
    mIsProcessDone := true;

    CurMtr := Rsbuf.rCurMtr;

    with mParent do
    begin
        case AORD of
            roRsMem1:
                Result := IsTested(tsIMS_MEM1);

            roRsMem2:
                Result := IsTested(tsIMS_MEM2);

            roRsMem3:
                Result := IsTested(tsIMS_MEM3);

            roRsEasyAccess:
                Result := IsTested(tsIMS_EasyAccess);

            roRsLimit:
                Result := IsTested(MotorOrd2TsOrd(Rsbuf.rCurMtr, True));

            roRsTotLimit:
                begin
                    try
                        for Item := Low(TMotorORD) to High(TMotorORD) do
                            Result := Result or IsTested(roRsLimit);
                    finally
                        Rsbuf.rCurMtr := CurMtr;
                    end;
                end;
        end;
    end;
end;

procedure TSubDataBox4IMS.SetData(AORD: TResultORD; const Value: boolean);
begin
    mIsProcessDone := true;

    SetExists(AORD, True);

    with mParent do
    begin
        case AORD of
            roRsLimit:
                Rsbuf.CurDatMtr.rLimit := Value;

            roRsMem1:
                Rsbuf.rDatIMS.rMEM1 := Value;

            roRsMem2:
                Rsbuf.rDatIMS.rMEM2 := Value;

            roRsMem3:
                Rsbuf.rDatIMS.rMEM3 := Value;

            roRsEasyAccess:
                Rsbuf.rDatIMS.rEasyAccess := Value;
        else
            mIsProcessDone := false;
        end;
    end;

end;

procedure TSubDataBox4IMS.SetData(AORD: TResultOrd; const Value: integer);
begin

    with mParent do
    begin

        case AORD of
            roNone: ;
        else
            mIsProcessDone := false;
        end;
    end;

end;

procedure TSubDataBox4IMS.SetDataInit(ATsMode: TTsORD);
var
    Buf: PResult;
begin
    mIsProcessDone := true;
    Buf := mParent.GetPResultBuffer;

    with mParent do
    begin

        Buf.rValidity[ATsMode] := false;
        Buf.rExists[ATsMode] := false;

        case ATsMode of

            tsIMS_MEM1:
                Buf.rTested[ATsMode] := Buf.rModel.rTypes.IsHVPSU and (gSysEnv.rIMS.rMem.Car.rUseMem and gSysEnv.rIMS.rMem.Car.rUseMem1);

            tsIMS_MEM2:
                Buf.rTested[ATsMode] := Buf.rModel.rTypes.IsHVPSU and (gSysEnv.rIMS.rMem.Car.rUseMem and gSysEnv.rIMS.rMem.Car.rUseMem2);

            tsIMS_MEM3:
                Buf.rTested[ATsMode] := Buf.rModel.rTypes.IsHVPSU and (gSysEnv.rIMS.rMem.Car.rUseMem and gSysEnv.rIMS.rMem.Car.rUseMem3);

            tsIMS_EasyAccess:
                Buf.rTested[ATsMode] := Buf.rModel.rTypes.IsHVPSU and gSysEnv.rIMS.rMem.Car.rUseEasyAcc;

            tsIMS:
                Buf.rTested[ATsMode] := IsTested(tsIMS_MEM1) or IsTested(tsIMS_MEM2) or IsTested(tsIMS_MEM3) or IsTested(tsIMS_EasyAccess);

            tsLimit_Slide:
                begin
                    Buf.rTested[ATsMode] := Buf.rModel.rTypes.IsHVPSU and Buf.rModel.rTypes.IsSlideMtrExists;
                    Buf.rDatMtrs[tmSlide].rLimit := false;
                end;

            tsLimit_CushTilt:
                begin
                    Buf.rTested[ATsMode] := Buf.rModel.rTypes.IsHVPSU and Buf.rModel.rTypes.IsCushTiltMtrExists;
                    Buf.rDatMtrs[tmCushTilt].rLimit := false;
                end;

            tsLimit_Relax:
                begin
                    Buf.rTested[ATsMode] := Buf.rModel.rTypes.IsHVPSU and Buf.rModel.rTypes.IsRelaxMtrExists;
                    Buf.rDatMtrs[tmRelax].rLimit := false;
                end;

            tsLimit_Headrest:
                begin
                    Buf.rTested[ATsMode] := false; // 헤드레스트 모터만 있어서 리미트 안함.
                    Buf.rDatMtrs[tmHeadrest].rLimit := false;
                end;

            tsLimit_Recl:
                begin
                    Buf.rTested[ATsMode] := Buf.rModel.rTypes.IsHVPSU and Buf.rModel.rTypes.IsReclineMtrExists;
                    Buf.rDatMtrs[tmRecl].rLimit := false;
                end;

            tsLimit_WalkinUpTilt:
                begin
                    Buf.rTested[ATsMode] := Buf.rModel.rTypes.IsHVPSU and Buf.rModel.rTypes.IsWalkinTiltMtrExists;
                    Buf.rDatMtrs[tmWalkinUpTilt].rLimit := false;
                end;

            tsLimit_Shoulder:
                begin
                    Buf.rTested[ATsMode] := Buf.rModel.rTypes.IsHVPSU and Buf.rModel.rTypes.IsShoulderMtrExists;
                    Buf.rDatMtrs[tmShoulder].rLimit := false;
                end;

            tsLimit_LongSlide:
                begin
                    Buf.rTested[ATsMode] := false;     // 롱슬라이드 사용안함.
                    Buf.rDatMtrs[tmLongSlide].rLimit := false;
                end;

            tsLimit:
                begin
                    Buf.rTested[ATsMode] := true;
                end;


        else
            mIsProcessDone := false;
            gLog.Panel('SubDataBox4IMS.SetDataInit:%s(%d) 처리 누락', [GetTsOrdName(ATsMode), Ord(ATsMode)]);
        end;
    end;

end;

procedure TSubDataBox4IMS.SetExists(AORD: TResultORD; const IsExist: boolean);
begin
    inherited;
    case AORD of
        roRsLimit:
            Rsbuf.rExists[MotorOrd2TsOrd(Rsbuf.rCurMtr, True)] := IsExist;

        roRsMem1:
            Rsbuf.rExists[tsIMS_MEM1] := IsExist;

        roRsMem2:
            Rsbuf.rExists[tsIMS_MEM2] := IsExist;

        roRsMem3:
            Rsbuf.rExists[tsIMS_MEM3] := IsExist;

        roRsEasyAccess:
            Rsbuf.rExists[tsIMS_EasyAccess] := IsExist;

    end;
end;

procedure TSubDataBox4IMS.SetValidity;
begin

end;

procedure TSubDataBox4IMS.SetData(AORD: TResultORD; const Value: double);
var
    Buf: PResult;
begin
    mIsProcessDone := true;
    Buf := mParent.GetPResultBuffer;

    with mParent do
    begin

        case AORD of

            roNone: ;
        else
            mIsProcessDone := false;

        end;
    end;

end;

procedure TSubDataBox4IMS.SetData(AORD: TResultORD; const Value: string);
begin

    with mParent do
    begin
        case AORD of
            roNone: ;
        else
            mIsProcessDone := false;
        end;
    end;

end;


end.

