unit DataBox;
{$INCLUDE myDefine.inc}

interface

uses
    Windows, Sysutils, Classes, Generics.Collections, DataUnit, DataUnitOrd,
    BaseDataBox, MyUtils, ModelType, SeatType, SeatMotorType;

type

    // --------------------------------------------------------------------------------
    // Prj 특화코드 구현 클래스
    // --------------------------------------------------------------------------------

    TDataBox = class(TCompoDataBox)

    protected

        mTag: integer; // 검사에선 Station 구별용

        mBuf: TResult;
        mfPos: integer;
        mOffset: TOffset;
        mMotorOffset: TMotorOffset;

        function GetOffset: POffset; virtual;
        function GetMotorOffst: PMotorOffset;

        function GetTag: integer; override;
        procedure SetTag(Tag: integer); override;

    public

        class var mDebug: Boolean;

        constructor Create(ATag: integer);
        destructor Destroy; override;

        function GetMcNo: BYTE;

        procedure InitData(aReadEnv: Boolean = false); override;
        function SaveData(aSaveTime: Double): Boolean;

        procedure SetModel(const aModel: TModel);
        procedure SetResult(const aResult; afPos: integer = -1); override;
        procedure SetFileTime(SaveTime: TDateTime);

        function GetValidity(): Boolean;
        function GetFileTimes(): TDateTime;
        function GetSaveTimes(): TDateTime;
        function GetGraphTime(): TDateTime;
        function GetModelIndex(): integer;

        function GetPResultBuffer(): PResult; // --> Use to Data input


        // ------------------------------------
        function IsExists(ATsMode: TTsORD): Boolean; overload;
        function IsTested(ATsMode: TTsORD): Boolean; overload;

        function IsExists(AORD: TResultORD): Boolean; override;
        function IsTested(AORD: TResultORD): Boolean; override;

        function GetResult(ATsMode: TTsORD): Boolean; override;
        function GetResult(AORD: TResultORD): Boolean; override;

        function GetData(AORD: TResultORD; ADigit: integer = 0): Double; override;
        function GetResultToATxt(APos: integer; IsUnit: Boolean; IsResult: Boolean = false): string; override;

        procedure SetData(AORD: TResultORD; const Value: Double); overload; override;
        procedure SetData(AORD: TResultORD; const Value: string); overload; override;
        procedure SetData(AORD: TResultORD; const Value: Boolean); overload; override;
        procedure SetData(AORD: TResultORD; const Value: integer); overload; override;

        function GetCompoJudge(ROs: array of TResultORD): Boolean;
        // ------------------------------------


        property DataPos: integer read mfPos;
        property RsBuf: PResult read GetPResultBuffer;

        property Offset: POffset read GetOffset;
        property MotorOffset: PMotorOffset read GetMotorOffst;

    end;

implementation

uses
    Math, ModelUnit, Log, DataUnitHelper, SysEnv, SubDataBox4IMS, SubDataBox4Elec, SubDataBox4Mtr, LangTran;

// ------------------------------------------------------------------------------
//
// ------------------------------------------------------------------------------

constructor TDataBox.Create(ATag: integer);
begin

    inherited Create;

    mDBXList.Add(TSubDataBox4IMS.Create(Self));
    mDBXList.Add(TSubDataBox4Mtr.Create(Self));
    mDBXList.Add(TSubDataBox4Elec.Create(Self));

    mTag := ATag;

    InitData();
end;

destructor TDataBox.Destroy();
begin
    inherited;
end;

procedure TDataBox.InitData(aReadEnv: Boolean);
begin
    mfPos := 0;

    mBuf.Clear(false);

    with mBuf do
    begin
        rValidity[tsValidity] := true;

    end;

    if aReadEnv and Assigned(gModels) then
    begin
        SetModel(gModels.CurrentModel(TStationID(mTag)));
        with mBuf do
        begin
            rLastTime := Now();
            rFileTime := 0;
            rMcNo := BYTE(mTag);
        end;
    end;

    inherited InitData(aReadEnv);

    mOffset := gModels.CurrentOffset(TStationID(mTag));
    mMotorOffset := (gModels.CurrentMtrOffset(TStationID(mTag)))^;

end;

function TDataBox.SaveData(aSaveTime: Double): Boolean;
var
    fh: integer;
    sTm: string;
begin
    Result := false;

    with mBuf do
    begin
        rValidity[tsSlide] := GetResult(tsSlide);
//        rValidity[tsTilt] := GetResult(tsTilt);
        rValidity[tsLimit] := GetResult(tsLimit);
    end;

    gLog.ToFiles('%s(%s) savedata Pos:%d', [GetStationName(TStationID(mTag)), GetResultToATxt(ord(roNO), false, false), mfPos]);

    sysEnvUpdates;

    with mBuf do
    begin
        rValidity[tsValidity] := true;
        SetFileTime(aSaveTime);
        rValidity[tsResult] := GetResult(roNO);
    end;

    sTm := GetResultFileName(mBuf.rFileTime);
    if FileExists(sTm) then
        fh := FileOpen(sTm, fmOpenWrite or fmShareDenyNone)
    else
        fh := FileCreate(sTm);
    if fh < 0 then
        Exit;
    try
        if mfPos > 0 then
            FileSeek(fh, (mfPos - 1) * sizeof(TResult), 0)
        else
            FileSeek(fh, 0, 2);
        Result := FileWrite(fh, mBuf, sizeof(TResult)) = sizeof(TResult);
        mfPos := FileSeek(fh, 0, 1) div sizeof(TResult);
    finally
        FileClose(fh);
    end;

    gLog.Panel('SAVE DATA: %s', [sTm]);
end;

procedure TDataBox.SetModel(const aModel: TModel);
var
    ModelType: TModelType;
begin
    with mBuf do
    begin
        ModelType := rModel.rTypes;
        rModel := aModel;
        rModel.rTypes := ModelType;
    end;
end;

function TDataBox.GetValidity(): Boolean;
begin
    with mBuf do
        Result := rValidity[tsValidity];
end;

function TDataBox.GetFileTimes(): TDateTime;
begin
    with mBuf do
        Result := rFileTime;
end;

function TDataBox.GetSaveTimes(): TDateTime;
begin
    with mBuf do
        Result := rLastTime;
end;

function TDataBox.GetTag: integer;
begin
    Result := mTag;
end;

function TDataBox.GetGraphTime(): TDateTime;
begin
    with mBuf do
        Result := rFileTime;
end;

function TDataBox.GetModelIndex: integer;
begin
    with mBuf do
        Result := rModel.rIndex;
end;

function TDataBox.GetMotorOffst: PMotorOffset;
begin
    Result := @mMotorOffset;
end;

function TDataBox.GetPResultBuffer(): PResult;
begin
    Result := @mBuf;
end;

function TDataBox.IsTested(ATsMode: TTsORD): Boolean;
begin
    Result := mBuf.rTested[ATsMode];
end;

function TDataBox.IsExists(ATsMode: TTsORD): Boolean;
begin
    Result := mBuf.rExists[ATsMode];
end;

function TDataBox.GetResultToATxt(APos: integer; IsUnit: Boolean; IsResult: Boolean): string;
var
    bTm: Boolean;
begin
    mIsProcessDone := true;
    Result := '';
    case APos of
        ord(roNone):
            Exit;
        ord(roIndex), ord(roPosType), ord(roPosExType), ord(roDrvType),
        ord(roWayType), ord(roSeatOpType), ord(roImsType),
        ord(roCarType), ord(roPartName), ord(roPartNo), ord(roLclPartNo):
            Result := RsBuf.ModelToStr(TResultOrd(APos), IsUnit);

        ord(roTestType):
            begin
            end;
        ord(roDate):
            Result := FormatDateTime('ddddd', GetSaveTimes);
        ord(roTime):
            Result := FormatDateTime('hh:nn:ss', GetSaveTimes);
        ord(roDateTime):
            begin
                Result := FormatDateTime('ddddd hh:nn:ss', GetSaveTimes);
            end;
        ord(roPalletNO):
            Result := string(mBuf.rPalletNO);
        ord(roMcNO):
            begin
                if mBuf.rMcNo = 0 then
                    Result := '#' + IntToStr(gSysEnv.rOP.rStNo)
                else
                    Result := '#' + IntToStr(gSysEnv.rOP.rStNo + 1);
            end;

        ord(roLotNo):
            begin
                Result := mBuf.rLotNo;
            end;
        ord(roNO):
            begin
                bTm := GetResult(TResultORD(APos));
                Result := JUDGE_TXT[bTm];
                if IsResult then
                    Result := Format('%s%s', [ARY_TAG[bTm], Result]);
            end;


        ord(roDataRework):
            if mBuf.rIsRework then
                Result := '○'
            else
                Result := '';

    else

        Result := inherited GetResultToATxt(APos, IsUnit, IsResult);

        if not mIsProcessDone then
        begin
            gLog.Debug('func GetResultToATxt Error(%d)', [APos]);
        end;
    end;
end;

function TDataBox.GetData(AORD: TResultORD; ADigit: integer): Double;
var
    dTm: Double;
begin
    mIsProcessDone := true;

    case AORD of
        roNone:
            Result := 0;



    else
        Result := inherited GetData(AORD);

        if not mIsProcessDone then
            gLog.Debug('func GetData Error(%s:%d)', [GetResultORDName(AORD), ord(AORD)]);
    end;

    if (ADigit = 0) or (Result = 0) then
        Exit;

    dTm := Result;
    Result := StrToFloatDef(Format('%.*f', [ADigit, dTm]), dTm);

    { dTm := Power(10.0, ADigit) ;
      Result := Trunc(Result * dTm) / dTm ; }
end;

function TDataBox.GetResult(ATsMode: TTsORD): Boolean;
begin
    mIsProcessDone := true;
    case ATsMode of
        tsResult:
            Result := GetResult(roNO);
    else

        Result := inherited GetResult(ATsMode);
        if not mIsProcessDone then
            gLog.Debug('func GetResult2(%d)', [ord(ATsMode)]);
    end;
end;

function TDataBox.GetResult(AORD: TResultORD): Boolean;
begin
    mIsProcessDone := true;
    Result := true;
    if not IsTested(AORD) then
        Exit;

    case AORD of


        roRsSpecCheck:
            begin
                Result := mBuf.rValidity[tsSpecCheck];
            end;

        roNO:
            begin
                 Result := GetCompoJudge([

                    roRsTotMotor, roRsAbnormalSound,
                    roRsElec, roRsIMS

                 ]);
            end;
    else
        Result := inherited GetResult(AORD);

        if not mIsProcessDone then
            gLog.Debug('func GetResult1(%d)', [ord(AORD)]);
    end;
end;

function TDataBox.GetCompoJudge(ROs: array of TResultORD): Boolean;
var
    i: integer;
begin
    for i := 0 to Length(ROs) - 1 do
    begin
        if not GetResult(ROs[i]) then
        begin
{$IFNDEF _VIEWER}
            if mDebug then
                gLog.Panel('Judge NG: %s', [GetResultOrdName(ROs[i])]);   // Viewer에서 호출 될때 Log를 넣으면 출력 스케일이 커지는 문제 발생??
{$ENDIF}
            Exit(false);
        end
        else
        begin
            //gLog.Panel('Judge OK: %s', [GetResultOrdName(ROs[i])]);   // Viewer에서 호출 될때 Log를 넣으면 출력 스케일이 커지는 문제 발생??
        end;

    end;
    Result := true;
end;


function TDataBox.IsExists(AORD: TResultORD): Boolean;
begin
    Result := false;
    case AORD of
        roPoprcved:
            Result := IsExists(tsPoprcv);
        roPopsnded:
            Result := IsExists(tsPopsnd);
    else
        Result := inherited IsExists(AORD);
        if not mIsProcessDone then
        begin
            gLog.Debug('func TDataBox.IsExists Error(%d)', [integer(AORD)]);
        end;
    end;
end;

function TDataBox.IsTested(AORD: TResultORD): Boolean;
begin
    mIsProcessDone := true;
    Result := true;
    case AORD of
        roNone: ;
        roNo:
            begin
                Result := True;
            end
    else


        Result := inherited IsTested(AORD);
        if not mIsProcessDone then
            gLog.Debug('func IsTested(%s:%d)', [GetResultORDName(AORD), ord(AORD)]);
    end;
end;

function TDataBox.GetMcNo: BYTE;
begin
    Result := mBuf.rMcNo;
end;

// ------------------------------------------------------------------------------
{ TDataBox }
// ------------------------------------------------------------------------------

function TDataBox.GetOffset: POffset;
begin
    Result := @mOffset;
end;

procedure TDataBox.SetData(AORD: TResultORD; const Value: Double);
begin
    mIsProcessDone := true;

    case AORD of

        roCycleTime:
            mBuf.rCycleTime := Value;


    else
        inherited SetData(AORD, Value);
        if not mIsProcessDone then
            gLog.Debug('func SetData1(%s:%d)', [GetResultORDName(AORD), ord(AORD)]);
    end;
end;

procedure TDataBox.SetData(AORD: TResultORD; const Value: integer);
begin
    mIsProcessDone := true;
    case AORD of
        roCarType:
            mBuf.rModel.rTypes.SetCarType(mBuf.rModel.rTypes.GetCarType);
        roPosType:
            mBuf.rModel.rTypes.SetPosType(mBuf.rModel.rTypes.GetPosType);
    else
        inherited SetData(AORD, Value);
        if not mIsProcessDone then
            gLog.ToFiles('func SetData(int)(%d)', [ord(AORD)]);
    end;
end;

procedure TDataBox.SetFileTime(SaveTime: TDateTime);
begin
    mBuf.rLastTime := SaveTime;
    // 일일작업시간에 의한 일자 + 실제시간 저장시간
    if mBuf.rFileTime = 0 then
    begin
        mBuf.rFileTime := GetOneDayTime(mBuf.rLastTime);
        mfPos := 0;
    end;

end;

procedure TDataBox.SetData(AORD: TResultORD; const Value: Boolean);
begin
    mIsProcessDone := true;
    case AORD of

        roRsSpecCheck:
            begin
                mBuf.rExists[tsSpecCheck] := true;
                mBuf.rValidity[tsSpecCheck] := Value;
                mBuf.rTested[tsSpecCheck] := true;
            end;

        roPopsnded:
            mBuf.rExists[tsPopsnd] := Value;
    else

        inherited SetData(AORD, Value);

        if not mIsProcessDone then
            gLog.Debug('func SetData2(%d)', [ord(AORD)]);
    end;
end;

procedure TDataBox.SetData(AORD: TResultORD; const Value: string);
begin
    mIsProcessDone := true;
    case AORD of
        roPartName:
            mBuf.rModel.rPartName := ShortString(Value);
        roPartNo:
            mBuf.rModel.rPartNo := ShortString(Value);

        roPalletNO:
            begin
                mBuf.rPalletNO := ShortString(Value);
                mBuf.rExists[tsPoprcv] := Value <> '';
            end;

        roLclPartNo:
            mBuf.rModel.rLclPartNo := Value;

        roLotNo:
            mBuf.rLotNo := ShortString(Value);
    else

        inherited SetData(AORD, Value);
        if not mIsProcessDone then
            gLog.Debug('func SetData3(%d)', [ord(AORD)]);
    end;
end;


procedure TDataBox.SetResult(const aResult; afPos: integer);
var
    nB: TResult;
begin

    Move(aResult, mBuf, sizeof(TResult));
    mfPos := afPos;
end;


procedure TDataBox.SetTag(Tag: integer);
begin
    mTag := Tag;
end;

end.
