unit SubDataBox4AP;

interface

uses
    BaseDataBox, DataBox, DataUnitOrd, DataUnit;

type
    TSubDataBox4AP = class(TBaseDataBox)
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
    Log, SeatType, ModelUnit, SysEnv, DataUnitHelper;

{ TSubDataBox4AP }

constructor TSubDataBox4AP.Create(Parent: TDataBox);
begin
    inherited Create;
    mParent := Parent
end;

function TSubDataBox4AP.GetData(AORD: TResultORD; ADigit: integer): double;
begin
    mIsProcessDone := true;

    with mParent do
    begin
        case AORD of
            roAPSlide_CTRL, roAPRecl_CTRL:
                Result := Ord(Rsbuf.rCurAPSeat);

            roDataAntiPinchLoad:
                Result := Rsbuf.CurDatAP.rLoad;

            roDataAntiPinchStopCurr:
                Result := Rsbuf.CurDatAP.rStopCurr;

            roDataAntiPinchRisingCurr:
                Result := Rsbuf.CurDatAP.rRisingCurr;

        else
            mIsProcessDone := false;
            Result := 0.0;
        end;
    end;
end;

function TSubDataBox4AP.GetPResultBuffer: PResult;
begin
    Result := mParent.GetPResultBuffer;
end;

function TSubDataBox4AP.GetResult(ATsMode: TTsORD): boolean;
begin
    mIsProcessDone := true;

    with mParent do
    begin
        case ATsMode of
            tsAntiPinch_Slide, tsAntiPinch_Recl :
                Result := GetResult(roRsAntiPinch);

            tsAntiPinch:
                Result := GetResult(roRsTotAntiPinch);
        else
            mIsProcessDone := false;
            Result := false;
        end;
    end;
end;

function TSubDataBox4AP.GetResult(AORD: TResultORD): boolean;
var
    CurAPSeat, Item: TAP_TYPE;
begin
    mIsProcessDone := true;
    Result := True;

    CurAPSeat := Rsbuf.rCurAPSeat;

    with mParent do
    begin
        case AORD of
            roDataAntiPinchLoad:
                Result := Rsbuf.rModel.rSpecs.rAntiPinch[Rsbuf.rCurAPSeat].rLoad.IsIn(GetData(AORD));

            roDataAntiPinchStopCurr:
                Result := Rsbuf.rModel.rSpecs.rAntiPinch[Rsbuf.rCurAPSeat].rStopCurr >= GetData(AORD);

            roDataAntiPinchRisingCurr:
                Result := Rsbuf.rModel.rSpecs.rAntiPinch[Rsbuf.rCurAPSeat].rRisingcurr <= GetData(AORD);

            roRsAntiPinch:
                Result := GetResult(roDataAntiPinchLoad) and GetResult(roDataAntiPinchStopCurr) and GetResult(roDataAntiPinchRisingCurr);

            roRsTotAntiPinch:
                begin
                    try
                        for Item := Low(TAP_TYPE) to High(TAP_TYPE) do
                        begin
                            Rsbuf.rCurAPSeat := Item;

                            Result := Result and GetResult(roRsAntiPinch);
                        end;
                    finally
                        Rsbuf.rCurAPSeat := CurAPSeat;
                    end;

                end;
        else
            mIsProcessDone := false;
            Result := false;
        end;
    end;

end;

function TSubDataBox4AP.GetResultToATxt(APos: integer; IsUnit, IsResult: boolean): string;
begin
    mIsProcessDone := true;
    with mParent do
    begin
        case Apos of
            ord(roSpecAPLoadLo)..ord(roSpecAPRisingCurrLo):
                Result := RsBuf.ModelToStr(TResultOrd(APos), IsUnit);

            ord(roDataAntiPinchLoad)..orD(roDataAntiPinchRisingCurr):
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
        end;
    end;
end;

function TSubDataBox4AP.GetTag: integer;
begin
    Result := mParent.Tag;
end;

function TSubDataBox4AP.GetUnitStr(AORD: TResultORD): string;
begin
    case AORD of
        roDataAntiPinchLoad:
            Result := ' kgf';

        roDataAntiPinchStopCurr, roDataAntiPinchRisingCurr:
            Result := ' A';
    else
        Result := '';
    end;
end;

procedure TSubDataBox4AP.InitData(AReadEnv: boolean);
begin
    SetDataInit(tsAntiPinch_Slide);
    SetDataInit(tsAntiPinch_Recl);
    SetDataInit(tsAntiPinch);
end;

function TSubDataBox4AP.IsExists(AORD: TResultORD): boolean;
var
    CurAP: TAP_TYPE;
    Item: TAP_TYPE;
begin
    mIsProcessDone := true;

    CurAP := Rsbuf.rCurAPSeat;

    with mParent do
    begin
        case AORD of
            roDataAntiPinchLoad, roDataAntiPinchStopCurr,
            roDataAntiPinchRisingCurr, roRsAntiPinch:
                begin
                    case Rsbuf.rCurAPSeat of
                        atSlide:
                            Result := IsExists(tsAntiPinch_Slide);
                        atRecline:
                            Result := IsExists(tsAntiPinch_Recl);
                    end;
                end;
            roRsTotAntiPinch:
                    Result := IsExists(tsAntiPinch_Slide) or IsExists(tsAntiPinch_Recl);
        else
            mIsProcessDone := false;
        end;
    end;
end;

function TSubDataBox4AP.IsTested(AORD: TResultORD): boolean;
var
    CurAP: TAP_TYPE;
    Item: TAP_TYPE;
begin
    mIsProcessDone := true;

    CurAP := Rsbuf.rCurAPSeat;

    with mParent do
    begin
        case AORD of
            roDataAntiPinchLoad, roDataAntiPinchStopCurr,
            roDataAntiPinchRisingCurr, roRsAntiPinch:
                begin
                    case Rsbuf.rCurAPSeat of
                        atSlide:
                            Result := IsTested(tsAntiPinch_Slide);
                        atRecline:
                            Result := IsTested(tsAntiPinch_Recl);
                    end;
                end;
            roRsTotAntiPinch:
                    Result := IsTested(tsAntiPinch_Slide) or IsTested(tsAntiPinch_Recl);
        else
            mIsProcessDone := false;
        end;
    end;
end;

procedure TSubDataBox4AP.SetData(AORD: TResultORD; const Value: boolean);

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

procedure TSubDataBox4AP.SetData(AORD: TResultOrd; const Value: integer);
begin

    with mParent do
    begin

        case AORD of
            roAPSlide_CTRL, roAPRecl_CTRL:
                Rsbuf.rCurAPSeat := TAP_TYPE(Value);
            roNone:
                ;
        else
            mIsProcessDone := false;
        end;
    end;

end;

procedure TSubDataBox4AP.SetDataInit(ATsMode: TTsORD);
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
            tsAntiPinch_Slide:
                Buf.rTested[ATsMode] := Buf.rModel.rTypes.IsSlideMtrExists and gSysEnv.rAntipinch.rUseSlide;

            tsAntiPinch_Recl:
                Buf.rTested[ATsMode] := Buf.rModel.rTypes.IsReclineMtrExists and gSysEnv.rAntipinch.rUseRecl;

            tsAntiPinch:
                Buf.rTested[ATsMode] := IsTested(tsAntiPinch_Slide) or IsTested(tsAntiPinch_Recl);
        else
            mIsProcessDone := false;
            gLog.Panel('SubDataBox4AP.SetDataInit:%s(%d) 처리 누락', [GetTsOrdName(ATsMode), Ord(ATsMode)]);
        end;
    end;

end;

procedure TSubDataBox4AP.SetExists(AORD: TResultORD; const IsExist: boolean);
begin
  inherited;

end;

procedure TSubDataBox4AP.SetData(AORD: TResultORD; const Value: double);

begin
    mIsProcessDone := true;

    with mParent do
    begin
        case AORD of

            roDataAntiPinchLoad:
                Rsbuf.CurDatAP.rLoad := Value + mParent.Offset.rVals[ucAPLoad];

            roDataAntiPinchStopCurr:
                Rsbuf.CurDatAP.rStopCurr := Value + mParent.Offset.rVals[ucAPStopCurr];

            roDataAntiPinchRisingCurr:
                Rsbuf.CurDatAP.rRisingCurr := Value + mParent.Offset.rVals[ucAPRisingCurr];
        else
            mIsProcessDone := false;
        end;
    end;

end;

procedure TSubDataBox4AP.SetData(AORD: TResultORD; const Value: string);
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

procedure TSubDataBox4AP.SetValidity;
begin

end;

end.
