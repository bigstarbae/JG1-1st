{
	Ver.240912.00
}
unit SubDataBox4Elec;

interface
uses
    BaseDataBox, DataBox, DataUnit, DataUnitOrd;

type
    TSubDataBox4Elec = class(TBaseDataBox)
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
    Log, SysEnv, HVTester, SeatType, ModelUnit, SysUtils, DataUnitHelper;

{ TSubDataBox4Elec }

constructor TSubDataBox4Elec.Create(Parent: TDataBox);
begin
    inherited Create;
    mParent := Parent;

end;

function TSubDataBox4Elec.GetData(AORD: TResultORD; ADigit: integer): double;
begin
    mIsProcessDone := true;

    with mParent do
    begin
        case AORD of
            roHVRL_CTRL, roHVRR_CTRL:
                Result := Ord(Rsbuf.rCurHVPos);
            roHVHeat_CTRL, roHVVent_CTRL:
                Result := ord(Rsbuf.rCurHVTestType);

            roDataOnCurr:
                Result := Rsbuf.CurDatHV.rOnCurr;

            roDataOffCurr:
                Result := Rsbuf.CurDatHV.rOffCurr;

            roDataLedOffBit:
                Result := Rsbuf.CurDatHV.rLedOffBit;

            roDataLedHiBit:
                Result := Rsbuf.CurDatHV.rLedHiBit;

            roDataLedMidBit:
                Result := Rsbuf.CurDatHV.rLedMidBit;

            roDataLedLoBit:
                Result := Rsbuf.CurDatHV.rLedLoBit;

            roDataBuckle:
                Result := Rsbuf.rBuckleVal;

            roDataCTRBuckle:
                Result := Rsbuf.rCenterBuckleVal;


        else
            mIsProcessDone := false;
            Result := 0.0;
        end;

        if ADigit <> 0 then
            Result := StrToFloatDef(Format('%.*f', [ADigit, Result]), Result);
    end;
end;

function TSubDataBox4Elec.GetPResultBuffer: PResult;
begin

end;

function TSubDataBox4Elec.GetResult(ATsMode: TTsORD): boolean;
begin
    mIsProcessDone := true;
    with mParent do
    begin
        case ATsMode of
            tsHeatRL, tsHeatRR:
                Result := GetResult(roRsHeat);
            tsVentRL, tsVentRR:
                Result := GetResult(roRsVent);
            tsHV:
                Result := GetResult(roRsHeat) and GetResult(roRsVent);
            tsBlow:
                Result := GetResult(roRsVent);
            tsFlow:
                Result := GetResult(roRsFlow);
            tsBuckle:
                Result := GetResult(roDataBuckle);
            tsCTRBuckle:
                Result := GetResult(roDataCTRBuckle);
            tsEcuInfo:
                Result := GetResult(roRsTotEcuInfo);
            tsElec:
                Result := GetResult(roRsElec);
        else
            mIsProcessDone := false;
            Result := false;
        end;
    end;
end;

function TSubDataBox4Elec.GetResult(AORD: TResultORD): boolean;
var
    CurHVTestType: THVTestType;
    CurHVPos: THVPosType;
    CurECU: TECU_TYPE;
    HVPosItem: THVPosType;
    ECUItem: TECU_TYPE;
begin
    mIsProcessDone := true;

    CurHVTestType := Rsbuf.rCurHVTestType;
    CurHVPos := Rsbuf.rCurHVPos;
    CurECU := Rsbuf.rCurECU;

    Result := True;

    with mParent do
    begin
        case AORD of
            roDataOnCurr:
                Result := Rsbuf.rModel.rSpecs.rOnCurr[Rsbuf.rCurHVTestType].IsIn(GetData(AORD));
            roDataOffCurr:
                Result := Rsbuf.rModel.rSpecs.rOffCurr[Rsbuf.rCurHVTestType].IsIn(GetData(AORD));
            roDataLedOffBit:
                Result := GetData(AORD) = $00;
            roDataLedHiBit:
                Result := GetData(AORD) = $07;
            roDataLedMidBit:
                Result := GetData(AORD) = $03;
            roDataLedLoBit:
                Result := GetData(AORD) = $01;
            roDataBuckle, roDataCTRBuckle:
                Result := Rsbuf.rModel.rSpecs.rBuckle.IsIn(GetData(AORD));
            roDataEcuPartNo:
                Result := (Pos(Rsbuf.rEcuInfoSpec[Rsbuf.rCurECU].rPartNo, Rsbuf.rEcuInfo[Rsbuf.rCurECU].rPartNo) > 0)
                    or (Rsbuf.rEcuInfoSpec[Rsbuf.rCurECU].rPartNo = 'MASTER');
            roDataEcuSwVer:
                Result := (Pos(Rsbuf.rEcuInfoSpec[Rsbuf.rCurECU].rSwVer, Rsbuf.rEcuInfo[Rsbuf.rCurECU].rSwVer) > 0)
                    or (Rsbuf.rEcuInfoSpec[Rsbuf.rCurECU].rSwVer = 'MASTER');
            roDataEcuHwVer:
                Result := (Pos(Rsbuf.rEcuInfoSpec[Rsbuf.rCurECU].rHwVer, Rsbuf.rEcuInfo[Rsbuf.rCurECU].rHwVer) > 0)
                    or (Rsbuf.rEcuInfoSpec[Rsbuf.rCurECU].rHwVer = 'MASTER');
            roRsHeatByPos:
                begin
                    try
                        Rsbuf.rCurHVTestType := hvtHeat;

                        Result :=
                            GetCompoJudge(
                                [
                                    roDataOnCurr, roDataOffCurr, roDataLedOffBit,
                                    roDataLedHiBit, roDataLedMidBit, roDataLedLoBit
                                ]
                            );
                    finally
                        Rsbuf.rCurHVTestType := CurHVTestType;
                    end;
                end;
            roRsVentByPos:
                begin
                    try
                        Rsbuf.rCurHVTestType := hvtVent;

                        Result :=
                            GetCompoJudge(
                                [
                                    roDataOnCurr, roDataOffCurr, roDataLedOffBit,
                                    roDataLedHiBit, roDataLedMidBit, roDataLedLoBit,
                                    roRsFlow
                                ]
                            );
                    finally
                        Rsbuf.rCurHVTestType := hvtVent;
                    end;
                end;
            roRsFlow:
                Result := Rsbuf.rFlow;
            roRsHeat:
                begin
                    try
                        if not IsTested(tsDual) then
                        begin
                            Result := GetResult(roRsHeatByPos);
                            Exit;
                        end;

                        for HVPosItem := Low(THVPosType) to High(THVPosType) do
                        begin
                            Rsbuf.rCurHVPos := HVPosItem;
                            Result := Result and GetResult(roRsHeatByPos);
                        end;
                    finally
                        Rsbuf.rCurHVPos := CurHVPos;
                    end;
                end;
            roRsVent:
                begin
                    try
                        if not IsTested(tsDual) then
                        begin
                            Result := GetResult(roRsVentByPos);
                            Exit;
                        end;

                        for HVPosItem := Low(THVPosType) to High(THVPosType) do
                        begin
                            Rsbuf.rCurHVPos := HVPosItem;
                            Result := Result and GetResult(roRsVentByPos);
                        end;
                    finally
                        Rsbuf.rCurHVPos := CurHVPos;
                    end;
                end;
            roRsDTC:
                Result := Rsbuf.rDTC;
            roRsTotBuckle:
                Result := GetResult(roDataBuckle) and GetResult(roDataCTRBuckle);
            roRsEcuInfo:
                Result := GetResult(roDataEcuPartNo) and GetResult(roDataEcuSwVer) and GetResult(roDataEcuHwVer);
            roRsTotEcuInfo:
                begin
                    try
                        for ECUItem := Low(TECU_TYPE) to High(TECU_TYPE) do
                        begin
                            Rsbuf.rCurECU := ECUItem;
                            Result := Result and GetResult(roRsEcuInfo);
                        end;
                    finally
                        Rsbuf.rCurECU := CurECU;
                    end;
                end;

            roRsElec:
                Result := GetCompoJudge(
                                 [
                                    roRsHeat, roRsVent, roRsDTC, roRsTotBuckle, roRsTotEcuInfo, roRsIMS
                                 ]
                            );

        end;
    end;
end;

function TSubDataBox4Elec.GetResultToATxt(APos: integer; IsUnit, IsResult: boolean): string;
var
    i: integer;
begin
    mIsProcessDone := true;
    with mParent do
    begin
        case APos of
            ord(roSpecHeatOnLo) .. ord(roSpecEcuHwVer):
                Result := RsBuf.ModelToStr(TResultOrd(APos), IsUnit);

            ord(roDataOnCurr) .. ord(roDataCTRBuckle):
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
            ord(roDataLedOffBit):
                begin
                    if not IsExists(TResultOrd(APos)) and not IsTested(TResultOrd(APos)) then
                        Exit;

                    for i := 0 to 2 do
                    begin
                        if (Rsbuf.rDatHvs[Rsbuf.rCurHVPos, Rsbuf.rCurHVTestType].rLedOffBit shr i and $01) = $01 then
                        begin
                            Result := Result + '1';
                        end
                        else
                        begin
                            Result := Result + '0';
                        end;
                    end;
                end;
            ord(roDataLedHiBit):
                begin
                    if not IsExists(TResultOrd(APos)) and not IsTested(TResultOrd(APos)) then
                        Exit;

                    for i := 0 to 2 do
                    begin
                        if (Rsbuf.rDatHvs[Rsbuf.rCurHVPos, Rsbuf.rCurHVTestType].rLedHiBit shr i and $01) = $01 then
                        begin
                            Result := Result + '1';
                        end
                        else
                        begin
                            Result := Result + '0';
                        end;
                    end;
                end;

            ord(roDataLedMidBit):
                begin
                    if not IsExists(TResultOrd(APos)) and not IsTested(TResultOrd(APos)) then
                        Exit;

                    for i := 0 to 2 do
                    begin
                        if (Rsbuf.rDatHvs[Rsbuf.rCurHVPos, Rsbuf.rCurHVTestType].rLedMidBit shr i and $01) = $01 then
                        begin
                            Result := Result + '1';
                        end
                        else
                        begin
                            Result := Result + '0';
                        end;
                    end;
                end;
            ord(roDataLedLoBit):
                begin
                    if not IsExists(TResultOrd(APos)) and not IsTested(TResultOrd(APos)) then
                        Exit;

                    for i := 0 to 2 do
                    begin
                        if (Rsbuf.rDatHvs[Rsbuf.rCurHVPos, Rsbuf.rCurHVTestType].rLedLoBit shr i and $01) = $01 then
                        begin
                            Result := Result + '1';
                        end
                        else
                        begin
                            Result := Result + '0';
                        end;
                    end;
                end;

            ord(roDataEcuPartNo):
                begin
                    if not IsExists(TResultORD(APos)) and not IsTested(TResultORD(APos)) then
                        Exit;

                    if not IsExists(TResultORD(APos)) or (abs(GetData(TResultORD(APos))) = 0) then
                        Result := ''
                    else
                        Result := Rsbuf.rEcuInfo[Rsbuf.rCurECU].rPartNo;

                    if IsResult and IsTested(TResultORD(APos)) then
                        Result := ARY_TAG[GetResult(TResultORD(APOS))] + Result;
                end;
            ord(roDataEcuSwVer):
                begin
                    if not IsExists(TResultORD(APos)) and not IsTested(TResultORD(APos)) then
                        Exit;

                    if not IsExists(TResultORD(APos)) or (abs(GetData(TResultORD(APos))) = 0) then
                        Result := ''
                    else
                        Result := Rsbuf.rEcuInfo[Rsbuf.rCurECU].rSwVer;

                    if IsResult and IsTested(TResultORD(APos)) then
                        Result := ARY_TAG[GetResult(TResultORD(APOS))] + Result;
                end;

            ord(roDataEcuHwVer):
                begin
                    if not IsExists(TResultORD(APos)) and not IsTested(TResultORD(APos)) then
                        Exit;

                    if not IsExists(TResultORD(APos)) or (abs(GetData(TResultORD(APos))) = 0) then
                        Result := ''
                    else
                        Result := Rsbuf.rEcuInfo[Rsbuf.rCurECU].rHwVer;

                    if IsResult and IsTested(TResultORD(APos)) then
                        Result := ARY_TAG[GetResult(TResultORD(APOS))] + Result;
                end;
        end;


    end;

end;

function TSubDataBox4Elec.GetTag: integer;
begin
    Result := mParent.Tag;
end;

function TSubDataBox4Elec.GetUnitStr(AORD: TResultORD): string;
begin
    case AORD of
        roDataOnCurr, roDataOffCurr:
            Result := ' A';
        roDataBuckle, roDataCTRBuckle:
            begin
                if Rsbuf.rModel.rTypes.IsWarnBuckle then
                    Result := ' V'
                else
                    Result := ' A';
            end
    else
        Result := '';
    end;
end;

procedure TSubDataBox4Elec.InitData(AReadEnv: boolean);
begin
    SetDataInit(tsEcuInfo);
    SetDataInit(tsHeatRL);
    SetDataInit(tsHeatRR);
    SetDataInit(tsVentRL);
    SetDataInit(tsVentRR);
    SetDataInit(tsHV);
    SetDataInit(tsDual);
    SetDataInit(tsBlow);
    SetDataInit(tsFlow);
    SetDataInit(tsBuckle);
    SetDataInit(tsCTRBuckle);
    SetDataInit(tsDTC);
    SetDataInit(tsElec);

end;

function TSubDataBox4Elec.IsExists(AORD: TResultORD): boolean;
begin
    mIsProcessDone := true;

    with mParent do
    begin
        case AORD of
            roDataOnCurr, roDataOffCurr:
                begin
                    case RsBuf.rCurHVPos of
                        hvpDrv:
                            Result := IsExists(tsHeatRL) or IsExists(tsVentRL);
                        hvpPsg:
                            Result := IsExists(tsHeatRR) or IsExists(tsVentRR);
                    end;
                end;

            roDataLedOffBit, roDataLedHiBit,
            roDataLedMidBit, roDataLedLoBit:
                begin
                    Result := not IsExists(tsBlow);

                    case RsBuf.rCurHVPos of
                        hvpDrv:
                            Result := Result and (IsExists(tsHeatRL) or IsExists(tsVentRL));
                        hvpPsg:
                            Result := Result and (IsExists(tsHeatRR) or IsExists(tsVentRR));
                    end;
                end;

            roRsHeatByPos:
                begin
                    case RsBuf.rCurHVPos of
                        hvpDrv:
                            Result := IsExists(tsHeatRL);
                        hvpPsg:
                            Result := IsExists(tsHeatRR);
                    end;
                end;

            roRsVentByPos:
                begin
                    case RsBuf.rCurHVPos of
                        hvpDrv:
                            Result := IsExists(tsVentRL);
                        hvpPsg:
                            Result := IsExists(tsVentRR);
                    end;
                end;

            roRsHeat:
                Result := IsExists(tsHeatRL) or IsExists(tsHeatRR);

            roRsVent:
                Result := IsExists(tsVentRL) or IsExists(tsVentRR);

            roRsFlow:
                Result := IsExists(tsFlow);

            roDataBuckle, roRsTotBuckle:
                Result := IsExists(tsBuckle);

            roDataCTRBuckle:
                Result := IsExists(tsCTRBuckle);

            roDataEcuPartNo, roDataEcuSwVer, roDataEcuHwVer,
            roRsEcuInfo, roRsTotEcuInfo:
                Result := IsExists(tsEcuInfo);

            roRsDTC:
                Result := IsExists(tsDTC);

            roRsElec:
                Result := IsExists(tsEcuInfo) or IsExists(tsHeatRL) or IsExists(tsHeatRR) or
                IsExists(tsVentRL) or IsExists(tsVentRR) or IsExists(tsFlow) or IsExists(tsBlow) or
                 IsExists(tsBuckle) or IsExists(tsDTC);

        else
            begin
                mIsProcessDone := False;
                Result := False;
            end;
        end;
    end;

end;

function TSubDataBox4Elec.IsTested(AORD: TResultORD): boolean;
begin
    mIsProcessDone := true;

    with mParent do
    begin
        case AORD of
            roDataOnCurr, roDataOffCurr:
                begin
                    case RsBuf.rCurHVPos of
                        hvpDrv:
                            Result := IsTested(tsHeatRL) or IsTested(tsVentRL);
                        hvpPsg:
                            Result := IsTested(tsHeatRR) or IsTested(tsVentRR);
                    end;
                end;

            roDataLedOffBit, roDataLedHiBit,
            roDataLedMidBit, roDataLedLoBit:
                begin
                    Result := not IsTested(tsBlow);

                    case RsBuf.rCurHVPos of
                        hvpDrv:
                            Result := Result and (IsTested(tsHeatRL) or IsTested(tsVentRL));
                        hvpPsg:
                            Result := Result and (IsTested(tsHeatRR) or IsTested(tsVentRR));
                    end;
                end;

            roRsHeatByPos:
                begin
                    case RsBuf.rCurHVPos of
                        hvpDrv:
                            Result := IsTested(tsHeatRL);
                        hvpPsg:
                            Result := IsTested(tsHeatRR);
                    end;
                end;

            roRsVentByPos:
                begin
                    case RsBuf.rCurHVPos of
                        hvpDrv:
                            Result := IsTested(tsVentRL);
                        hvpPsg:
                            Result := IsTested(tsVentRR);
                    end;
                end;

            roRsHeat:
                Result := IsTested(tsHeatRL) or IsTested(tsHeatRR);

            roRsVent:
                Result := IsTested(tsVentRL) or IsTested(tsVentRR);

            roRsFlow:
                Result := IsTested(tsFlow);

            roDataBuckle, roRsTotBuckle:
                Result := IsTested(tsBuckle);

            roDataCTRBuckle:
                Result := IsTested(tsCTRBuckle);

            roDataEcuPartNo, roDataEcuSwVer, roDataEcuHwVer,
            roRsEcuInfo, roRsTotEcuInfo:
                Result := IsTested(tsEcuInfo);

            roRsDTC:
                Result := IsTested(tsDTC);

            roRsElec:
                Result := IsTested(tsEcuInfo) or IsTested(tsHeatRL) or IsTested(tsHeatRR) or
                IsTested(tsVentRL) or IsTested(tsVentRR) or IsTested(tsFlow) or IsTested(tsBlow) or
                IsTested(tsBuckle) or IsTested(tsDTC);

        else
            begin
                mIsProcessDone := False;
                Result := False;
            end;
        end;
    end;

end;

procedure TSubDataBox4Elec.SetData(AORD: TResultOrd; const Value: integer);
var
    Buf: PResult;
begin
    mIsProcessDone := true;


    SetExists(AORD, True);

    with mParent.RsBuf^ do
    begin
        case AORD of
            roHVRL_CTRL, roHVRR_CTRL:
                rCurHVPos := THVPosType(Value);

            roHVHeat_CTRL, roHVVent_CTRL:
                rCurHVTestType := THVTestType(Value);

            roHVPSU_CTRL, roSAU_CTRL:
                rCurECU := TECU_TYPE(Value);

            roDataLedOffBit:
                CurDatHV.rLedOffBit := BYTE(Value);

            roDataLedHiBit:
                CurDatHV.rLedHiBit := BYTE(Value);

            roDataLedMidBit:
                CurDatHV.rLedMidBit := BYTE(Value);

            roDataLedLoBit:
                CurDatHV.rLedLoBit := Byte(Value);
        else
            mIsProcessDone := false;
        end;
    end;

end;

procedure TSubDataBox4Elec.SetDataInit(ATsMode: TTsORD);
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
            tsEcuInfo:
                Buf.rTested[ATsMode] := Buf.rModel.rTypes.IsECU and gSysEnv.rElec.rECU.rUseVer;
            tsHeatRL:
                Buf.rTested[ATsMode] := Buf.rModel.rTypes.IsHeatRL and gSysEnv.rElec.rHV.rUseHeat;
            tsHeatRR:
                Buf.rTested[ATsMode] := Buf.rModel.rTypes.IsHeatRR and gSysEnv.rElec.rHV.rUseHeat;
            tsVentRL:
                Buf.rTested[ATsMode] := Buf.rModel.rTypes.IsVentRL and gSysEnv.rElec.rHV.rUseVent;
            tsVentRR:
                Buf.rTested[ATsMode] := Buf.rModel.rTypes.IsVentRR and gSysEnv.rElec.rHV.rUseVent;
            tsHV:
                Buf.rTested[ATsMode] := Buf.rModel.rTypes.IsHV;
            tsDual:
                Buf.rTested[ATsMode] := False;  // 각 시트 독립 SHVU
            tsBlow:
                Buf.rTested[ATsMode] := False;  // 각 시트 독립 SHVU 블로워 테스트 없음.
            tsFlow:
                Buf.rTested[ATsMode] := (IsTested(tsVentRL) or IsTested(tsVentRR)) and gSysEnv.rElec.rHV.rUseSenseVent;
            tsBuckle:
                Buf.rTested[ATsMode] := Buf.rModel.rTypes.IsBukcle and (gSysEnv.rElec.rBuckle.rUseCurr or gSysEnv.rElec.rBuckle.rUseIO or gSysEnv.rElec.rBuckle.rUseILL);
            tsCTRBuckle:
                Buf.rTested[ATsMode] := Buf.rModel.rTypes.IsCenterBuckle and (gSysEnv.rElec.rBuckle.rUseCurr or gSysEnv.rElec.rBuckle.rUseIO or gSysEnv.rElec.rBuckle.rUseILL);
            tsDTC:
                Buf.rTested[ATsMode] := True; // DTC 무조건 소거
            tsElec:
                Buf.rTested[ATsMode] := IsTested(tsEcuInfo) or IsTested(tsHV) or IsTested(tsBlow) or IsTested(tsFlow) or IsTested(tsBuckle) or IsTested(tsCTRBuckle) or IsTested(tsDTC);
        else
            mIsProcessDone := false;
            gLog.Panel('SubDataBox4Elec.SetDataInit:%s(%d) 처리 누락', [GetTsOrdName(ATsMode), Ord(ATsMode)]);
        end;
    end;

end;

procedure TSubDataBox4Elec.SetExists(AORD: TResultORD; const IsExist: boolean);
begin
    inherited;
    case AORD of
        roDataOnCurr, roDataOffCurr, roDataLedOffBit, roDataLedHiBit, roDataLedMidBit, roDataLedLoBit:
            begin
                if Rsbuf.rCurHVPos = hvpDrv then
                begin
                    if Rsbuf.rCurHVTestType = hvtHeat then
                        Rsbuf.rExists[tsHeatRL] := IsExist
                    else
                        Rsbuf.rExists[tsVentRL] := IsExist;
                end
                else
                begin
                    if Rsbuf.rCurHVTestType = hvtHeat then
                        Rsbuf.rExists[tsHeatRR] := IsExist
                    else
                        Rsbuf.rExists[tsVentRR] := IsExist;
                end;
            end;

        roDataBuckle:
            Rsbuf.rExists[tsBuckle] := IsExist;

        roDataCTRBuckle:
            Rsbuf.rExists[tsCTRBuckle] := IsExist;

         roRsFlow:
            Rsbuf.rExists[tsFlow] := IsExist;

         roRsDTC:
            Rsbuf.rExists[tsDTC] := IsExist;

         roDataEcuPartNo, roDataEcuSwVer, roDataEcuHwVer:
            Rsbuf.rExists[tsEcuInfo] := IsExist;
    end;

end;

procedure TSubDataBox4Elec.SetValidity;
begin

end;

procedure TSubDataBox4Elec.SetData(AORD: TResultORD; const Value: boolean);
begin
    mIsProcessDone := true;

    SetExists(AORD, True);

    with mParent.RsBuf^ do
    begin
        case AORD of
            roRsFlow:
                rFlow := Value;
            roRsDTC:
                rDTC := Value;
        else
            mIsProcessDone := False;
        end;
    end;

end;

procedure TSubDataBox4Elec.SetData(AORD: TResultORD; const Value: double);
begin
    mIsProcessDone := true;

    SetExists(AORD, True);

    with mParent.RsBuf^ do
    begin
        case AORD of
            roDataOnCurr:
                rDatHVs[rCurHVPos, rCurHVTestType].rOnCurr := Value + mParent.Offset.GetHVOffset(rCurHVTestType);

            roDataOffCurr:
                rDatHVs[rCurHVPos, rCurHVTestType].rOffCurr := Value + mParent.Offset.GetHVOffset(rCurHVTestType);

            roDataBuckle:
                rBuckleVal := Value + mParent.Offset.rVals[ucBuckle];

            roDataCTRBuckle:
                rCenterBuckleVal := Value + mParent.Offset.rVals[ucBuckle];


        else
            mIsProcessDone := false;
        end;
    end;
end;

procedure TSubDataBox4Elec.SetData(AORD: TResultORD; const Value: string);
begin
    mIsProcessDone := true;

    SetExists(AORD, True);

    with mParent.RsBuf^ do
    begin
        case AORD of
            roDataEcuPartNo:
                CurDatECU.rPartNo := Value;
            roDataEcuSwVer:
                CurDatECU.rSwVer := Value;
            roDataEcuHwVer:
                CurDatECU.rHwVer := Value;
        end;
    end;

end;



end.
                
