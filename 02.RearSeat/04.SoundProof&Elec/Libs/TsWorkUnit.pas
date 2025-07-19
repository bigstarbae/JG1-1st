unit TsWorkUnit;
{$I myDefine.inc}

interface

uses
    Windows, Sysutils, Graphics, Classes, FaGraphEx, ComCtrls, DataUnit,
    DataUnitOrd, siAPD, TimeCount, DataBox, PopWork, myUtils, ComUnit,
    KiiMessages, TimeAccumulator, PowerSupplyUnit, ModelUnit, TimeChecker,
    BaseTsWork, BaseDIO, BaseAD, BaseAO, BaseCAN, ModelType, IODef, ScannerUnit,
    DIOChs, Global, SysEnv, SeatType, SeatMotor, SeatMotorType, SeatMoveCtrler,
    SeatIMSCtrler, MotorJogOperator, IntervalCaller, SeatConnector, AsyncCalls,
    Range, JG1SeatIMSCtrler, PeriodicCanData;

type
    TCtrlerType = (ctSimul, ctDIO, ctCAN, ctLIN);

    TPwrMtrsMoveType = (pmtEach, pmtGroup, pmtSameTime, pmtInterval);
    // ����, �׷캰, ����, �ð���

    TTsWork = class(TBaseTsWork)
    private
        function MtrStopByDPSensor(Motor: TSeatMotor): Boolean;
        function GetConnectors(Idx: Integer): TBaseSeatConnector;
        function CheckPowerStatus: Boolean;
        function GetConCount: Integer;
        function BeforeIOSet(DIO: TBaseDIO; Ch: Integer; Value: Boolean): Boolean;

        procedure SetupCANIDs(ACarType: TCAR_TYPE; AIsRLPos: boolean);

    protected
        mDBX: TDataBox;

        mNextTsWork: TTsWork; // �� ����

        // ----- ���� �ӽ� ����: ���Ž��� XXXProc�� ������ XXXState�� ���� �ʿ�
        mWorkState, mElecState, mLocalState, mInitState, mFuncState, // ���� �ʱ���ġ ���ĵ��� �Լ����� ���.
        mOutPosState, // ��ǰ ��ġ��
        mSpecChkState, mPopState: Integer;
        mLimitChkState: Integer;
        mJogMvState: Integer;
        mJogMtrIdx: TMotorOrd;

        mSubThLoop: Boolean; // ASyncCalls�� ������ Flag

        // ------------------------------------------------------
        // --------------------------------------------------------------------
        // DAQ Dev etc..
        mDevCom: TDevCom; // ���� ������� Comport

        // DAQ Dev etc..

        mLIO, mDIO: TBaseDIO; // BoardIO, gDIO�� ���ӵ��� �ʰ� TTsWork���� ����
        mAD: TBaseAD;
        mAO: TBaseAO;
        mCAN: TBaseCAN;

        // ��ü ���� ���
        mDCPower: TDcPower; // TTsWr
        mPop: TPopSystem;

        // -------------------------------------------------------------------
        // �� ����
        mPreModelType, mCurModelType: TModelType;
        mMdlNo: Integer;

        // --------------------------------------------------------------------
        // SeatMotor ����

        mMainCon: TBaseSeatConnector;
        mConnectors: TSeatConnectorList;

        mMoveCtrler: array[TMotorOrd] of TBaseMoveCtrler; // Factory ��ȯ ����

        mCurMotor: TSeatMotor;
        mMotors: array[TMotorOrd] of TSeatMotor;
        mMtrSlide, mMtrRecline, mMtrCushTilt, mMtrWalkinUpTilt, mMtrShoulder, mMtrRelax, mMtrHeadrest, mMtrLongSlide: TSeatMotor;
        mMtrOper: TSeatMotorOper;
        mUDSMoveCtrler: TCANUDSMoveCtrler;
        mIMSCtrler: TJG1CANIMSCtrler;

        // ---------------------------------------------------------------
        // ��� üũ

        mConStatus, mConChkStatus: Boolean; // Ŀ���� ���� ����
        mIsSpecChkOK: Boolean; // Ŀ���� ���� �� ���üũ ����
        mSkipConChk: Boolean; // Ŀ���� üũ ���� ���� ��� ����
        mStartSpecChk: Boolean;

        // LAN DI
        mLDIChs: TLDIChs;
        // LAN DO
        mLDOChs: TLDOChs;

        mDIEventer: TDIEventer;

        mMtrJogDIChs, mMtrJogLDIChs: TMotorJogOperator;

        mDelayTC, mSpChkTC, mSwTC: TTimeChecker;
        mSpecChkTC: TTimeChecker;
        mCanRcvTC: TTimeChecker;

        mCycleTime: Double;

        mTmpTime: Double;

        mIsModelLoaded, mIsTesting: Boolean;

        mJogDir: TMotorDir;

        mOldEndPosChk: Boolean;

        mIAsyncCall: IAsyncCall;
        mMMA: TMinMaxAvg;

        mCANWDebug, mCANRDebug: Boolean;

        mIsConnected: Boolean;

        mPeriodicCanData: TPeriodicCanData;

        procedure Start; override;
        procedure Stop(IsForce: Boolean = False); override;
        procedure WorkProcess(); override;

        procedure SaveResult();

        procedure SetUsrLog(const szFmt: string; const Args: array of const; IsFile: Boolean = False);

        // POP
        function GetPopDatas(): string;
        function PopWorkProcess: Boolean;
        procedure OnRcvedPopData(Sender: TObject; ACommand: Integer);
        function AnalysysRcvDatas(var RcvData, Value: string): Boolean;

        // Event ó��
        procedure UpdateForm(AStatus: TTsModeORD);

        // �۵�
        procedure RunJogMode;
        procedure LanDIChStatus(Ch: Integer; State: Boolean);
        procedure CheckLimit;

        // SPEC üũ  �� �ʱ�ȭ
        function AssignConnector: Boolean;
        function IsSpecChecking: Boolean;
        procedure ShowSpecChkMsg;

        procedure ClearDO;
        procedure SetSpecDO;
        procedure ClearSpecDO;

        procedure CreateConnectors;
        procedure FreeConnectors;
        procedure FreeGrpHelpers;

        // ���� �˻�  -------------------------------------------------------------------
        // ���� ���� �� ����
        procedure CreateMotors;
        procedure FreeMotors;
        procedure InitMotors;
        procedure StopMotors;

        procedure SeatMotorTestStatus(Motor: TSeatMotor; TestStatus: TSeatMotorTestStatus);

        function FSMCheckSpec: Integer;
        // ���� �ε� �� ��ε� ��ġ�� ������

        function FSMAlignMotor(PwrMoveType: TPwrMtrsMoveType; IsEndPosChk: Boolean = True): Integer;
        function FSMMoveToOutPos: Integer;
        function FSMPushOnOff(Ch, Delay: Integer): Integer;
        function FSMCheck4MotorMove(Dir: TMotorDir): Integer;

        function GetMotors(Mtr: TMotorOrd): TSeatMotor;
        procedure CanRead(Sender: TObject);

        function GetStationID: TStationID;
        function GetName: string; override;
        function GetRsBuf: PResult;
        procedure SetMainCurrZero; override;

        function MtrJogRunReq(MtrIdx, ChIdx: Integer; Dir: TMotorDir): Boolean;
        procedure MtrJogChStatus(MtrIdx, ChIdx: Integer; IsON: Boolean);

        function FSMJogMove(Dir: TMotorDir): Integer;

        procedure AsyncPushOnOff(Ch, Delay: Integer; PreDelay: Integer = 0);
        function NeedsRetest(Motor: TSeatMotor): Boolean;

        procedure CanTrans(CANFrame: TCANFrame; IsSend: Boolean);

    public
        mMsgs, mToDos: array of string;
        mIsAlarmMsg: Boolean;

        constructor Create(StationID: TStationID; CAN: TBaseCAN; AD: TBaseAD; DIO: TBaseDIO; DevCom: TDevCom);
        destructor Destroy; override;

        //
        procedure Initial(IsLoad: Boolean); override;
        procedure CheckModelChange(ID: Integer; ATypeBits, Mask: DWORD); override;

        //
        procedure InitMotorsCtrler(MdlType: TModelType);

        function IsStartChOn: Boolean; override;
        function IsRun: Boolean; override;
        function IsErrorState: Boolean;
        function IsTesting: Boolean;
        function IsPopLinkMode: Boolean;
        function IsStableState: Boolean; // ex> �� �������� ���ŷ(SaveData�� )�۾� �ϱ� �� �������

        function IsElecTestRun: Boolean;
        function IsAuto(): Boolean;

        function IsSpecChkOK: Boolean; override;
        function IsCableConnected(): Boolean;

        // �ܺ� ��ġ �� Ch ����
        procedure SetLanDIChs(StartAbsCh: Integer);
        procedure SetLanDOChs(StartAbsCh: Integer);
        procedure InitJogChs;

        procedure LinkNext(TsWork: TTsWork);

        function GetOutVolt: Double;
        function GetOutCurr: Double;

        function GetPowerEnable: Boolean;

        function GetMainCurr: Double;
        function GetMotorCurr: Double; overload;
        function GetMotorCurr(Motor: TMotorOrd): Double; overload;
        procedure SetMotorCurrPinsToZero;

        procedure SetError(ErrorMsg, ErrorToDo: string);
        procedure ShowError(ErrorMsg, ErrorToDo: string);
        procedure ShowMsg(Msg, ToDo: string); overload;
        procedure ShowMsg(Msgs, ToDos: array of string; IsAlarm: Boolean = False); overload;

        // ���� ����
        procedure ShowProcState; override;
        procedure ShowPopData;

        function GetStateStr(IsSimple: Boolean = False): string; override;
        procedure Write(TV: TTreeView); override;

        procedure SelfTest;

        //
        function GetStationIDStr: string;
        // --------------------------------
        property StationID: TStationID read GetStationID;
        property DBX: TDataBox read mDBX;

        property DevCom: TDevCom read mDevCom;

        property AD: TBaseAD read mAD;
        property DIO: TBaseDIO read mDIO;

        property MainCon: TBaseSeatConnector read mMainCon;

        property Connectors[Idx: Integer]: TBaseSeatConnector read GetConnectors;
        property ConCount: Integer read GetConCount;

        property RsBuf: PResult read GetRsBuf;

        property Motors[Mtr: TMotorOrd]: TSeatMotor read GetMotors;
        property CurMotor: TSeatMotor read mCurMotor;

        property CurModelType: TModelType read mCurModelType;

        property Pop: TPopSystem read mPop;

        property SkipConChk: Boolean read mSkipConChk write mSkipConChk;

        property CanRDebug: Boolean read mCANRDebug write mCANRDebug;
        property CanWDebug: Boolean read mCANWDebug write mCANWDebug;

    end;

function GetConnectedSt: TTsWork; // ���� ���� �Ϸ�� ����, 2���� ��� ���ӵǾ��ٸ� ù��° ������ ����

var
    gTsWork: array[0..ord(High(TStationID))] of TTsWork;

implementation

uses
    Forms, Dialogs, Log, LanIoUnit, LOTNO, Math, Rs232, Work, DataUnitHelper,
    TypInfo, UDSDef, ClipBrd, LangTran, MsgForm;

const
    _WS_IDLE = 0;
    _WS_START = 10;
    _WS_WAIT_SPEC_CHK = 14;
    _WS_WAIT_TEST_CURR = 15;
    _WS_ALIGN_MOTOR = 16;
    _WS_DELETE_LIMIT = 20;
    _WS_CHK_LIMIT_STATUS = 21;
    _WS_MOVE_BY_TIME = 22;
    _WS_HALL_SENSOR_TEST = 23;
    _WS_MOVE_TO_LOADING_POS = 30; // ���� �ε���ġ��
    _WS_CHECK_LOADING_POS = 35;
    _WS_WAIT_TEST_SIGN = 40;
    _WS_DELAY_LOAD_RELEASE = 45; // ���ϸ� ��� ���� ���(����������)

    _WS_SET_LIMIT = 50;
    _WS_BURNISHING = 55;
    _WS_MOVE_TO_UNLOADING_POS = 70; // ���� ��ε���ġ��
    _WS_WAIT_UNLOADING_DONE = 75;
    _WS_MOTOR_TEST = 80;
    _WS_ALIGN_MOTOR2 = 85;
    _WS_MOVE_TO_D_POS = 100; // ��ǰ��ġ��
    _WS_MEMORY_TEST = 110;
    _WS_WAIT_ALL_TEST_END = 120;
    _WS_NE_SLIDE_POS = 125;
    _WS_SAVE_DATA = 130;
    _WS_WAIT_POP_SEND = 140;
    _WS_END_OF_TEST = 150; // �Ϸ� ���

    _WS_ERROR = 200; // ���� ����
    _WS_OUTPOS_ER = 205;
    _WS_ERROR_IDLE = 210; // ���� ���

    _WS_ELEC_IDLE = 0;
    _WS_ELEC_START = 1;
    _WS_ELEC_WAIT_CONNECT = 2;
    _WS_ELEC_TEST_HV = 3;
    _WS_ELEC_STOP = 4;
    _WS_ELEC_RUN_VENT = 5;
    _WS_ELEC_ERROR = 100;
    _WS_ELEC_ERROR_IDLE = 101;
    _CAN_TIME_OUT = 0.3; // �Ϲ����� ������
    _RELAY_AFTER_RUN_DELAY = 250;
    _MEM_DELAY = 1.0;

function GetConnectedSt: TTsWork;
var
    i: Integer;
begin
    for i := 0 to ord(High(TStationID)) do
    begin
        if gTsWork[i].IsSpecChkOK then
        begin
            Exit(gTsWork[i]);
        end;
    end;

    Result := nil;
end;

{ TTsWork }

constructor TTsWork.Create(StationID: TStationID; CAN: TBaseCAN; AD: TBaseAD; DIO: TBaseDIO; DevCom: TDevCom);
var
    i: Integer;
begin
    inherited Create;

    mDBX := TDataBox.Create(ord(StationID));
    mStationID := ord(StationID);

    mWorkState := 0;

    mCAN := CAN;

    mAD := AD;
    mDIO := DIO;
    mDIO.OnConfirmBeforeIOSet := BeforeIOSet;
    mLIO := gLanDIO;

    mCAN.OnRead.Add(CanRead);
    mCAN.OnTrans := CanTrans;

    mDevCom := DevCom;

    mDCPower := gDcPower.Items[ord(StationID)];
    mPop := gPopsys.Items[ord(StationID)];
    mPop.OnRcvData := OnRcvedPopData;

    CreateConnectors;
    CreateMotors;

    mSubThLoop := True;

    mLDOChs.Clear(mLIO, []);

    mPeriodicCanData := TPeriodicCanData.Create(CAN, mCurModelType.GetCarType);

    gLog.Panel('%s: Create', [Name]);
end;

procedure TTsWork.CreateConnectors;
begin
    mConnectors := TSeatConnectorList.Create;
    mMainCon := TMainConnector.Create(mAD, AI_MAIN_CON_VOLT_START);

    mMainCon.Title := 'Main';

    mConnectors.Add(mMainCon);
end;

destructor TTsWork.Destroy;
var
    i: Integer;
begin
    mSubThLoop := False;

    for i := 0 to mDIO.WChCount - 1 do
    begin
        mDIO.SetIO(_DIO_OUT_START + i, False);
    end;

    gLog.Panel('%s: Destroy', [Name]); // Name���� mDBX�����ϹǷ� ��ġ ����!

    FreeAndNil(mDBX);

    FreeMotors;
    FreeConnectors;

    FreeGrpHelpers;

    if Assigned(mPeriodicCanData) then
        FreeAndNil(mPeriodicCanData);

    if Assigned(mPop) then
        mPop.OnRcvData := nil;

    inherited;
end;

function TTsWork.BeforeIOSet(DIO: TBaseDIO; Ch: Integer; Value: Boolean): Boolean;
begin
    Result := True;

end;

procedure TTsWork.CanRead(Sender: TObject);
begin
    with Sender as TBaseCan do
    begin
        case ID of
            // ���� ���� CANFD DBC�� ��ý�ȣ 1
            $316, $30B:
                begin
                    mCanRcvTC.Start(1000);
                end;
            // ���� ���� CANFD DBC�� ��ý�ȣ 2
            $317, $30C:
                begin
                    mCanRcvTC.Start(1000);
                end;
        end;
        WriteWFrames;
    end;
end;

procedure TTsWork.CanTrans(CANFrame: TCANFrame; IsSend: Boolean);
begin
    if not IsSend then
    begin
        if CANFrame.mData[1] = $7F then
        begin
            gLog.Error('%s: ECU ���� ����: %s', [Name, CANFrame.ToStr]);
        end;
    end;

    if IsSend and mCanWDebug and gSysEnv.rCanIDFilter.IsWIDExists(CANFrame.mID) then
    begin
        gLog.Debug('%s SEND: %s', [mCAN.Name, CANFrame.ToStr])
    end
    else if not IsSend and mCanRDebug and gSysEnv.rCanIDFilter.IsRIDExists(CANFrame.mID) then
    begin
        gLog.Debug('%s RECV: %s', [mCAN.Name, CANFrame.ToStr]);
    end;
end;

procedure TTsWork.CheckLimit;
begin
{$IFDEF VIRTUALIO}
    Exit;
{$ELSE}
    if IsErrorState or mLIO.IsIO(mLDOChs.mAlarm) or not IsRun then
        Exit;

    case mLimitChkState of
        0:
            begin
            end;
        1:
            begin
            end;
        2:
            begin
            end;
        3:
            begin
            end;
    end;

    Inc(mLimitChkState);
    mLimitChkState := mLimitChkState mod 4;
{$ENDIF}
end;

procedure TTsWork.CheckModelChange(ID: Integer; ATypeBits, Mask: DWORD);
var
    MdlNo: Integer;
begin
    mMdlNo := ID;
    mCurModelType := TModelType.Create(ATypeBits);

    if not mPreModelType.IsEqual(mCurModelType) then
    begin

        mPreModelType := mCurModelType;

        MdlNo := gModels.FindModel(mCurModelType, Mask);
        if MdlNo > 0 then
        begin
            gLog.Panel('%s: ���� MODEL %d -> %d(0x%X)', [Name, gModels.GetModelNo(StationID), MdlNo, ATypeBits]);

            gModels.SelectModel(StationID, MdlNo); // �� No ����
            mDBX.SetModel(gModels.CurrentModel(StationID)); // �� ������ �� ����
            RsBuf.rModel.rTypes := mCurModelType; // �𵨻���� �������� �ٸ��� ������ ����, Ŀ���� ü��Ȯ�ο� �������� ���� �����ؾ� ��.

            AssignConnector;

            IsModelChange := True;

            SendToForm(gUsrMsg, SYS_MODEL, mDBX.Tag); // UI ����

            gLog.Panel('%s: MODEL : %s', [Name, RsBuf.rModel.rTypes.ToStr()]);
        end
        else
        begin
            mIsModelChange := False;
            gModels.SelectModel(StationID, -1);
            gLog.Panel('%s: ���� �ش� MODEL ����(0x%X & 0x%X(Mask) = 0x%X)', [Name, ATypeBits, Mask, Mask and ATypeBits]);
        end;

    end;
end;

function TTsWork.CheckPowerStatus: Boolean;
const
    POWER_CHECK_TIMEOUT = 10000.0; // 10��
begin

    if (GetAccurateTime - mTmpTime) > POWER_CHECK_TIMEOUT then
    begin
        SetError('������ ON ���� �ʾҽ��ϴ�', '�Ŀ����ö��� ��ſ��� �� ���¸� Ȯ���� ���۾��ϼ���');
        gLog.Panel('%s: �Ŀ� Error', [Name]);
        Result := False;
    end;
end;

procedure TTsWork.SetLanDIChs(StartAbsCh: Integer);
begin
    mLDIChs.Init(StartAbsCh);

    with mLDIChs do
    begin

        mDIEventer.Init([mAutoMode, mPopLinkMode, mEmerStop, mConChk], LanDIChStatus);
    end;
end;

procedure TTsWork.SetLanDOChs(StartAbsCh: Integer);
begin
    mLDOChs.Init(StartAbsCh);
end;

procedure TTsWork.SetMainCurrZero;
begin
    inherited;
  // ���� ������ 0���� �����ϴ� ����
    if Assigned(mAD) then
    begin
        mAD.SetZeros(AI_MAIN_CURR, AI_MAIN_CURR);
        gLog.Debug('%s: ���� ���� �� ZERO', [Name]);
    end;

    // �Ǵ� �̹� �ִ� �޼��� ȣ��
    SetMotorCurrPinsToZero;  // �̹� ������ �޼��尡 �ִٸ�

end;

procedure TTsWork.SetMotorCurrPinsToZero;
begin
    mAD.SetZeros(AI_MAIN_CON_VOLT_START, AI_MAIN_CON_VOLT_END);

    gLog.Debug('%s: Ŀ���� ���� �� ZERO', [Name]);
end;

procedure TTsWork.InitJogChs;
begin
    if RsBuf.rModel.rTypes.IsRelaxMtrExists then
    begin
        mMtrJogDIChs.Init(DI_SLIDE_MTR_CW, [mMtrSlide, mMtrRelax, mMtrCushTilt, mMtrWalkinUpTilt, mMtrShoulder], MtrJogChStatus);
        mMtrJogLDIChs.Init(mLDIChs.mSlideFw, [mMtrSlide, mMtrRelax, mMtrCushTilt, mMtrWalkinUpTilt, mMtrShoulder], MtrJogChStatus);
    end
    else
    begin
        mMtrJogDIChs.Init(DI_SLIDE_MTR_CW, [mMtrSlide, mMtrRecline, mMtrCushTilt, mMtrWalkinUpTilt, mMtrShoulder], MtrJogChStatus);
        mMtrJogLDIChs.Init(mLDIChs.mSlideFw, [mMtrSlide, mMtrRecline, mMtrCushTilt, mMtrWalkinUpTilt, mMtrShoulder], MtrJogChStatus);
    end;

    mMtrJogDIChs.OnJogRunReq := MtrJogRunReq;
    mMtrJogLDIChs.OnJogRunReq := MtrJogRunReq;
end;

procedure TTsWork.CreateMotors;
var
    It: TMotorOrd;
begin
    // -----------------------------
    mUDSMoveCtrler := TCANUDSMoveCtrler.Create(mCAN, $732, $73A);

    mMtrOper := TSeatMotorOper.Create(@mLstError, @mLstToDo);

    mMtrSlide := TSeatMotor.Create(tmSlide, mUDSMoveCtrler, mAD, [AI_MOTOR_CURR, AI_MOTOR_CURR, AI_NOISE]);
    mMtrRecline := TSeatMotor.Create(tmRecl, mUDSMoveCtrler, mAD, [AI_MOTOR_CURR, AI_MOTOR_CURR, AI_NOISE]);
    mMtrCushTilt := TSeatMotor.Create(tmCushTilt, mUDSMoveCtrler, mAD, [AI_MOTOR_CURR, AI_MOTOR_CURR, AI_NOISE]);
    mMtrWalkinUpTilt := TSeatMotor.Create(tmWalkinUpTilt, mUDSMoveCtrler, mAD, [AI_MOTOR_CURR, AI_MOTOR_CURR, AI_NOISE]);
    mMtrShoulder := TSeatMotor.Create(tmShoulder, mUDSMoveCtrler, mAD, [AI_MOTOR_CURR, AI_MOTOR_CURR, AI_NOISE]);
    mMtrRelax := TSeatMotor.Create(tmRelax, mUDSMoveCtrler, mAD, [AI_MOTOR_CURR, AI_MOTOR_CURR, AI_NOISE]);
    mMtrHeadrest := TSeatMotor.Create(tmHeadrest, mUDSMoveCtrler, mAD, [AI_MOTOR_CURR, AI_MOTOR_CURR, AI_NOISE]);
    mMtrLongSlide := TSeatMotor.Create(tmLongSlide, mUDSMoveCtrler, mAD, [AI_MOTOR_CURR, AI_MOTOR_CURR, AI_NOISE]);

    mIMSCtrler := TJG1CANIMSCtrler.Create(mCAN, $732, $73A, $12A6);

    mMtrSlide.Name := Name + ' ' + mMtrSlide.Name;
    mMtrRecline.Name := Name + ' ' + mMtrRecline.Name;
    mMtrCushTilt.Name := Name + ' ' + mMtrCushTilt.Name;
    mMtrWalkinUpTilt.Name := Name + ' ' + mMtrWalkinUpTilt.Name;
    mMtrShoulder.Name := Name + ' ' + mMtrShoulder.Name;
    mMtrRelax.Name := Name + ' ' + mMtrRelax.Name;
    mMtrHeadrest.Name := Name + ' ' + mMtrHeadrest.Name;
    mMtrLongSlide.Name := Name + ' ' + mMtrLongSlide.Name;

    // �߰� ���� ���� �Է�.
    mMtrSlide.OnStopCond := nil;
    mMtrRecline.OnStopCond := nil;
    mMtrCushTilt.OnStopCond := nil;
    mMtrWalkinUpTilt.OnStopCond := nil;
    mMtrShoulder.OnStopCond := nil;
    mMtrRelax.OnStopCond := nil;
    mMtrHeadrest.OnStopCond := nil;
    mMtrLongSlide.OnStopCond := nil;

    mMotors[tmSlide] := mMtrSlide;
    mMotors[tmRecl] := mMtrRecline;
    mMotors[tmCushTilt] := mMtrCushTilt;
    mMotors[tmWalkinUpTilt] := mMtrWalkinUpTilt;
    mMotors[tmShoulder] := mMtrShoulder;
    mMotors[tmRelax] := mMtrRelax;
    mMotors[tmHeadrest] := mMtrHeadrest;
    mMotors[tmLongSlide] := mMtrLongSlide;

    for It := Low(TMotorOrd) to MtrOrdHi do
    begin
        mMotors[It].OnTestStatus := SeatMotorTestStatus;
        mMotors[It].IMSCtrler := mIMSCtrler;
    end;
end;

procedure TTsWork.FreeConnectors;
var
    i: Integer;
begin
    for i := 0 to mConnectors.Count - 1 do
        mConnectors[i].Free;

    mConnectors.Free;
end;

procedure TTsWork.FreeGrpHelpers;
var
    It: TMotorOrd;
begin
    for It := Low(TMotorOrd) to MtrOrdHi do
    begin
    end;

end;

procedure TTsWork.FreeMotors;
var
    It: TMotorOrd;
begin
    for It := Low(TMotorOrd) to High(TMotorOrd) do
        FreeAndNil(mMotors[It]);

    FreeAndNil(mMtrOper);

    FreeAndNil(mIMSCtrler);
    FreeAndNil(mUDSMoveCtrler);
end;

procedure TTsWork.InitMotorsCtrler(MdlType: TModelType);
var
    It: TMotorOrd;
begin

    SetupCANIDs(MdlType.GetCarType, MdlType.IsRL);
    mUDSMoveCtrler.SetMotorLIDMap(JG1_2ND_UDS_LID_MAP);

    mIMSCtrler.IsLHPos := RsBuf.rModel.rTypes.IsRL;

    for It := Low(TMotorOrd) to High(TMotorOrd) do
    begin
        mMotors[It].MoveCtrler.Enabled := False;
        mMotors[It].MoveCtrler := mUDSMoveCtrler;
        mMotors[It].IMSCtrler := mIMSCtrler;
        mMotors[It].IsIMS := True;
        mMotors[It].MoveCtrler.Enabled := True;
    end;

end;

procedure TTsWork.InitMotors;

    function GetBurnishingCount(MotorORD: TMotorORD): Integer;
    begin
        Result := gSysEnv.rMotor.GetBurnishingEnv(MotorORD).rBurnishingCount;
    end;

var
    MtrOffsets: PMotorOffset;
    Item: TMotorORD;
begin

    // ��纰 ���� ����, Ctrler����,
    InitMotorsCtrler(RsBuf.rModel.rTypes);

    with gModels do
    begin
        MtrOffsets := GetMotorOffset(st_Limit, mMdlNo);

        for Item := Low(TMotorORD) to High(TMotorORD) do
        begin
            mMotors[Item].SetMoveParam(GetMotorLockedCurr(Item, mMdlNo), GetMotorOperateTime(Item, mMdlNo));

            mMotors[Item].SetOffset(MtrOffsets^.rVals[Item][twForw].rCurr, MtrOffsets^.rVals[Item][twBack].rCurr);

            mMotors[Item].Use := mDBX.IsTested(MotorOrd2TsOrd(Item, True));

            mMotors[Item].mTotRepeatCount := GetBurnishingCount(Item);

            if mCurModelType.IsIMS then
                mMotors[Item].IsHLimitSet := mDBX.IsTested(MotorOrd2TsOrd(Item, True));
        end;
    end;

    gLog.Panel('���� ���: S:%s, C.T:%s, W.T:%s, R:%s, Rx:%s, Sh:%s', [BoolToStr(mMotors[tmSlide].Use, True), BoolToStr(mMotors[tmCushTilt].Use, True), BoolToStr(mMotors[tmWalkinUpTilt].Use, True), BoolToStr(mMotors[tmRecl].Use, True), BoolToStr(mMotors[tmRelax].Use, True), BoolToStr(mMotors[tmShoulder].Use, True)]);

end;

procedure TTsWork.LanDIChStatus(Ch: Integer; State: Boolean);
var
    Msg: string;
begin
    if Ch = mLDIChs.mAutoMode then
    begin
        if State then
        begin

        end;
        if not State then
        begin
            mLDOChs.Clear(mLIO, []);
        end;
        UpdateForm(tw_TEST_MODE);
    end;

    if Ch = mLDIChs.mAlarm then
    begin
        if State then
        begin

            UpdateForm(tw_EMERGY);
        end
        else
        begin
            UpdateForm(tw_HIDE_MSG);
        end;
    end;
    if Ch = mLDIChs.mEmerStop then
    begin
        if State then
        begin

            gLog.Panel('%s: ��� ����!!', [Name]);
            UpdateForm(tw_EMERGY);
        end
        else
        begin
            UpdateForm(tw_HIDE_MSG);
        end;
    end;
    if Ch = mLDIChs.mReset then
    begin
        if State then
        begin
            mLDOChs.Clear(mLIO, [mLDOChs.mConChkOK]);
            mLIO.SetIO(mLDIChs.mReset, False);
            UpdateForm(tw_HIDE_MSG);
            gLog.Panel('Reset!');
            mState := 0;
            mSkipConChk := False;
        end;
    end;

    if Ch = mLDIChs.mPopLinkMode then
    begin
        if State then
        begin

        end;

        UpdateForm(tw_POP_LINK_MODE);
    end;

    if Ch = mLDIChs.mConChk then
    begin
        if State then
        begin

            if (mLIO.IsIO(mLDOChs.mOK) or mLIO.IsIO(mLDOChs.mNOK)) and IsAuto then
                mLIO.SetIO(mLDOChs.mConChkOK, True)
            else
                mLIO.SetIO(mLDOChs.mConChkOK, False);

            gLog.Panel('%s: PLC ConChk True', [Name]);
            mSpecChkState := 1;

        end
        else
        begin
            gLog.Panel('%s: PLC ConChk False', [Name]);
            mLIO.SetIO(mLDOChs.mConChkOK, False);
            UpdateForm(tw_HIDE_MSG);
            mSpecChkState := 0;
        end;
    end;
end;

procedure TTsWork.ClearDO;
begin
    ClearSpecDO;
end;

procedure TTsWork.SetSpecDO;
begin
    mDIO.SetIO(DO_JG1_CAR, True);
    mDIO.SetIO(DO_HW_IGN1, True);
    mDIO.SetIO(DO_HW_IGN2, True);
end;

procedure TTsWork.SetupCANIDs(ACarType: TCAR_TYPE; AIsRLPos: boolean);
var
    IDSet: TUDSIDSet;
begin
    if (ACarType < Low(TCAR_TYPE)) or (ACarType > High(TCAR_TYPE)) then
    begin
        gLog.Error('%s: �� �� ���� ���� Ÿ��: %d', [Name, Ord(ACarType)]);
        Exit;
    end;

    IDSet := UDS_ID_CONFIG[AIsRLPos];

    // IMS Controller ����
    mIMSCtrler.ReqID := IDSet.ReqID;
    mIMSCtrler.RespID := IDSet.RespID;
    mIMSCtrler.RCID.Create(IDSet.RCID);
    mIMSCtrler.RDBIID := IDSet.RDBIID;

    // UDS Move Controller ����
    mUDSMoveCtrler.ReqID := IDSet.ReqID;
    mUDSMoveCtrler.RespID := IDSet.RespID;

    gLog.Panel('%s: UDS ID ���� : (Req:%x, Resp:%x)', [Name, mUDSMoveCtrler.ReqID, mUDSMoveCtrler.RespID]);
end;

procedure TTsWork.ClearSpecDO;
begin
    mDIO.SetIO(DO_JG1_CAR, False);
    mDIO.SetIO(DO_HW_IGN1, False);
    mDIO.SetIO(DO_HW_IGN2, False);
end;

procedure TTsWork.LinkNext(TsWork: TTsWork);
begin
    mNextTsWork := TsWork;
    TsWork.mNextTsWork := self;

end;

procedure TTsWork.Initial(IsLoad: Boolean);
var
    It: TMotorOrd;
    DevCom: TDevCom;
begin
{$IFDEF VIRTUALLANIO}
    mLIO.SetIO(mLDIChs.mAutoMode, True);
{$ENDIF}
    ClearFSM;
    mLstError := '';
    mLstToDo := '';

    mFuncState := 0;
    mOutPosState := 0;
    mInitState := 0;

    mMtrOper.ClearFSM;

    {
      DevCom := gDevComs.GetDevCom(GetLaserDistDevComOrd(StationID));
      DevCom.Name := GetDevComName(DevCom.DevID);
      }
{$IFNDEF VIRTUALIO}
    {
      if not DevCom.IsOpen and not DevCom.Open then
      begin
      SetError(Format('%s(COM%d) ��� ��Ʈ ���� ����', [GetDevComName(DevCom.DevID), DevCom.Port]), '��� ��Ʈ�� �輱�� �����ϼ���');
      end;
    }
{$ENDIF}
    mLDOChs.Clear(mLIO, [mLDOChs.mConChkOK]);

    mDBX.InitData(True);

    InitMotors;

    if IsLoad then
    begin

        with mPop do
        begin
            if UsePop and IsConnected and not IsExists and IsPopLinkMode then
            begin
                mPop.ClearRcvDatas();
                mPop.AddData(nil, SYS_REQ_MODEL, '');
                gLog.Panel('POP Data ��û', []);
            end
            else if IsConnected and IsExists then
            begin
                gLog.Panel('POP ���� ����: %s, %s', [GetPartNo, GetLotNo]);
                mDBX.SetData(roPartNo, GetPartNo);
                mDBX.SetData(roLotNo, GetLotNo);
            end;
        end;
    end;

    ClearSpecDO;

    mPeriodicCanData.Init(mCurModelType.GetCarType);

    UpdateForm(tw_INIT);

    if IsPopLinkMode then
        gLog.Panel('%s: initial(%s, %s, %s)', [Name, RsBuf.rModel.rTypes.GetCarTypeStr, mPop.rcvPartNo, mPop.rcvPalletNo])
    else
        gLog.Panel('%s: initial(�ܵ�: %s)', [Name, RsBuf.rModel.rTypes.GetCarTypeStr]);
end;

const
    BklColorCodes: array[0..8] of string = ('O2V', 'O2W', 'O2Q', 'O2R', 'WK', 'YBR', 'NNB', 'RJS', 'VNB');

function IsBuckleBC(BC: string): Boolean;
var
    i: Integer;
begin
    for i := 0 to Length(BklColorCodes) - 1 do
    begin
        if Pos(BklColorCodes[i], BC) > 0 then
            Exit(True);
    end;

    Result := False;
end;

procedure TTsWork.ShowPopData;
begin
    gLog.Panel('%s: %s', [Name, GetPopDatas]);
end;

procedure TTsWork.ShowProcState;
var
    It: TMotorOrd;
begin
    gLog.Panel('%s: mWorkState=%d, mElecState=%d', [Name, mWorkState, mElecState]);
    gLog.Panel('%s: mFuncState=%d, mLocalState=%d', [Name, mFuncState, mLocalState]);

    for It := Low(TMotorOrd) to MtrOrdHi do
        mMotors[It].ShowState;
end;

function TTsWork.IsRun: Boolean;
begin
    Result := (mWorkState > 0);
end;

function TTsWork.IsElecTestRun: Boolean;
begin
    Result := mElecState > 0;
end;

function TTsWork.IsTesting: Boolean;
begin
    Result := (0 < mWorkState) and (mWorkState <= _WS_END_OF_TEST);
end;

function TTsWork.IsErrorState: Boolean;
begin
    Result := (mState >= _WS_ERROR);
end;

function TTsWork.IsSpecChecking: Boolean;
begin
    Result := mSpecChkState > 0;
end;

function TTsWork.IsSpecChkOK: Boolean;
begin
    Result := mIsSpecChkOK;
end;

function TTsWork.IsStartChOn: Boolean;
begin
    Result := mLIO.IsIO(mLDIChs.mStart);
end;

procedure TTsWork.UpdateForm(AStatus: TTsModeORD);
begin
    SendToForm(mHandle, ord(AStatus), mDBX.Tag);
end;

function MakeRandVal(Min, Max: Double): Double;
var
    Range: Integer;
begin
    Range := Round((Max - Min) * 10);
    Result := (Min * 10) + random(Range);

    Result := Result / 10;
end;

function HMCBklColorToFCode(HMCBklColor: string): string;
const
    ColorCodes: array[0..4] of string = ('WK', 'YBR', 'NNB', 'RJS', 'VNB');
var
    i: Integer;
begin
    for i := 0 to Length(ColorCodes) - 1 do
    begin
        ;
        if Pos(ColorCodes[i], HMCBklColor) > 0 then
        begin
            Result := Char(65 + i);
            Exit;
        end;
    end;

    Result := '';
end;

function ToHMCBklColor(ColorCode: string): string;
begin
    if (ColorCode = 'O2V') or (ColorCode = 'O2W') then
        Exit('WK')
    else if (ColorCode = 'O2Q') or (ColorCode = 'O2R') then
        Exit('YBR');

    Result := ColorCode;
end;

procedure TTsWork.SaveResult;
var
    IsOK: Boolean;
    CurDate: TDateTime;
    PartNo: string;
begin
    CurDate := Now;

    IsOK := mDBX.GetResult(roNO);
    SetResultCount(mDBX.Tag, IsOK);

    mDBX.SetFileTime(CurDate);

    mDBX.SetData(roPartNo, mPop.GetPartNo);
    mDBX.SetData(roLotNo, mPop.GetLotNo);

    mDBX.SaveData(CurDate);

    UpdateForm(tw_SAVE);
    gLog.ToFiles('%s: saveresult %s, %s, %s', [Name, FormatDateTime('ddddd hh:nn:ss', mDBX.GetSaveTimes), mPop.GetPartNo, mPop.GetLotNo]);
end;

procedure TTsWork.Start;
var
    i: TMotorOrd;
begin
    if IsRun or not IsAuto then
        Exit;

    mWorkState := _WS_START;
    mCycleTime := Now();

    Initial(True);

    UpdateForm(tw_START);

    if Assigned(mOnRunEvent) then
        OnRun(self, True);

    mLIO.SetIO(mLDOChs.mTestReady, True);

    mTmpTime := GetAccurateTime;

    mIsTesting := True;

    gLog.Panel('%s: start', [Name]);

end;

procedure TTsWork.Stop(IsForce: Boolean);
var
    iTm: TTsModeORD;
begin
    StopMotors;

    mPeriodicCanData.Enabled := false;

    mStartSpecChk := False;
    mIsSpecChkOK := False;

    if not IsRun then
        Exit;

    if IsForce or (mWorkState <> _WS_END_OF_TEST) then
    begin
        iTm := tw_STOP;
    end
    else
    begin
        iTm := tw_END;
    end;

    //
    mIsTesting := False;

    mLDOChs.Clear(mLIO, [mLDOChs.mConChkOK, mLDOChs.mOK, mLDOChs.mNOK]);
    ClearDO;


    // --------------------------------------------------------------------------------
    mWorkState := 0;
    mElecState := 0;
    mSpecChkState := 0;

    if Assigned(mOnRunEvent) then
        OnRun(self, False);

    UpdateForm(iTm);

    if iTm = tw_END then
        gLog.Panel('%s: end', [Name])
    else
        gLog.Panel('%s: stop', [Name]);

    gTsFuncProc[mDBX.Tag] := 0;
    gCycleTime[mDBX.Tag] := Now() - mCycleTime;

    if Assigned(mDevCom) then
        mDevCom.Close;

    mSkipConChk := False;
end;

procedure TTsWork.StopMotors;
var
    It: TMotorOrd;
begin
    for It := Low(TMotorOrd) to MtrOrdHi do
        mMotors[It].Stop;
end;

function TTsWork.FSMAlignMotor(PwrMoveType: TPwrMtrsMoveType; IsEndPosChk: Boolean): Integer;
begin
    Result := 0;
    case mFuncState of
        0:
            begin
{$IFDEF _SIMUL_MTR}
                SetSimMtrToEndPos(True);
{$ENDIF}
                mOldEndPosChk := mMtrSlide.IsEndPosChk;
                mMtrOper.EnableEPosChk(IsEndPosChk);

                if RsBuf.rModel.rTypes.IsIMS then
                begin
                    gLog.Panel('%s: IMS ���� ����', [Name]);
                    mFuncState := 5;
                end
                else
                begin
                    case PwrMoveType of
                        pmtEach:
                            begin
                                gLog.Panel('%s: PWR ���� ���� ����', [Name]);
                                mFuncState := 1;
                            end;
                        pmtSameTime:
                            begin
                                gLog.Panel('%s: PWR ���� ���� ����', [Name]);
                                mFuncState := 2;
                            end;

                        pmtGroup:
                            begin
                                gLog.Panel('%s: PWR ���� �׷캰 ����', [Name]);
                                mFuncState := 3;
                            end;
                        pmtInterval:
                            begin
                                gLog.Panel('%s: PWR ���� ���� ����', [Name]);
                                mFuncState := 4;

                            end;
                    end;
                end;
            end;
        1: // PWR ����
            begin
                case mMtrOper.FSMMove(True) of
                    -1:
                        Result := -1;
                    1:
                        begin
                            mFuncState := 0;
                            Result := 1;
                            UpdateForm(tw_INIT_POS_END);
                            mMtrOper.EnableEPosChk(mOldEndPosChk);
                        end;
                end;
            end;
        2:

            begin
                case mMtrOper.FSMMove(False) of
                    -1:
                        Result := -1;
                    1:
                        begin
                            mFuncState := 0;
                            Result := 1;
                            UpdateForm(tw_INIT_POS_END);
                            mMtrOper.EnableEPosChk(mOldEndPosChk);
                        end;
                end;
            end;

        3: // �׷�
            begin
                case mMtrOper.FSMMove([mMtrCushTilt], [mMtrSlide]) of
                    -1:
                        Result := -1;
                    1:
                        begin
                            mFuncState := 0;
                            Result := 1;
                            UpdateForm(tw_INIT_POS_END);
                            mMtrOper.EnableEPosChk(mOldEndPosChk);
                        end;
                end;
            end;
        4: // ����
            begin
                case mMtrOper.FSMMove(0.4) of
                    -1:
                        Result := -1;
                    1:
                        begin
                            mFuncState := 0;
                            Result := 1;
                            UpdateForm(tw_INIT_POS_END);
                            mMtrOper.EnableEPosChk(mOldEndPosChk);
                        end;
                end;

            end;

        5: // IMS ����
            begin
                case mMtrOper.FSMMove(True) of
                    -1:
                        Result := -1;
                    1:
                        begin
                            mFuncState := 0;
                            Result := 1;
                            UpdateForm(tw_INIT_POS_END);
                            mMtrOper.EnableEPosChk(mOldEndPosChk);
                        end;
                end;
            end;
    end;
end;

function TTsWork.FSMCheck4MotorMove(Dir: TMotorDir): Integer;
begin
    Result := 0;
    case mFuncState of
        0:
            begin
                mMtrSlide.ClearFSM;
                mMtrSlide.IsEndPosChk := False; // �������� �̹߻��� ���� �Ǵ� ���� ��� ����
                Inc(mFuncState);
            end;
        1:
            begin
                case mMtrSlide.FSMMove(Dir, 0.5) of
                    -1:
                        begin
                            mMtrSlide.IsEndPosChk := True;
                            mFuncState := 0;
                            Exit(-1);
                        end;
                    1:
                        begin
                            mMtrSlide.IsEndPosChk := True;
                            mFuncState := 0;
                            Exit(1);
                        end;

                end;
            end;
    end;
end;

function TTsWork.MtrStopByDPSensor(Motor: TSeatMotor): Boolean;
begin
    Result := False;

    if Result then
    begin
        gLog.Panel('%s: %s ��ǰ��ġ ���� ����', [Name, Motor.Name]);
    end;
end;

function TTsWork.FSMMoveToOutPos: Integer;
begin
    Result := 0;
    case mFuncState of
        0:
            begin
                mMtrOper.Init([mMtrSlide], [twBack]);
                Inc(mFuncState);
                UpdateForm(tw_DELIVERY_START);
                gLog.Panel('%s: ��ǰ ��ġ ����', [Name]);
            end;
        1:
            begin
                case mMtrOper.FSMMove() of
                    -1:
                        begin
                            mFuncState := 0;
                            Exit(-1);
                        end;
                    1:
                        begin
                            gLog.Panel('%s: ��ǰ ��ġ �Ϸ�');
                            UpdateForm(tw_DELIVERY_END);
                            mFuncState := 0;
                            Exit(1);
                        end;

                end;
            end;
    end;
end;

const
    FOLDING_SW_DELAY = 600;

function TTsWork.FSMJogMove(Dir: TMotorDir): Integer;
begin
    Result := 0;
    case mJogMvState of
        0:
            ;

        1:
            case mMotors[mJogMtrIdx].MoveCtrler.FSMMove(mMotors[mJogMtrIdx].ID, Dir) of

                1, -1:
                    begin
                        mJogMvState := 0;
                        Exit(1);
                    end;

            end;
        2:

            case mMotors[mJogMtrIdx].MoveCtrler.FSMStop(mMotors[mJogMtrIdx].ID, Dir) of
                1, -1:
                    begin
                        mJogMvState := 0;
                        Exit(1);
                    end;
            end;

    end;
end;

function TTsWork.FSMPushOnOff(Ch, Delay: Integer): Integer;
begin
    Result := 0;

    case mLocalState of
        0:
            begin
                mDIO.SetIO(Ch, True);
                mSwTC.Start(Delay);
                Inc(mLocalState);
            end;
        1:
            begin
                if mSwTC.IsTimeOut() then
                begin
                    mLocalState := 0;
                    mDIO.SetIO(Ch, False);
                    Exit(1);
                end;
            end;
    end;

end;

function TTsWork.AssignConnector: Boolean;
begin
    if UpperCase(mMainCon.Name) = CurModelType.MakeMainConName then
        Exit(True);

    Result := False;

    if not gConMan.AssignByID(CurModelType.MakeMainConID, mMainCon) then
    begin
        gLog.Error('���� �� ���� Ŀ���� ���� ����', []);
        SetError('���� �� ���� Ŀ���� ���� ����', '���� �� ����̳� Env������ JG1_Connector.json ������ �ִ���  Ȯ�� �ϼ���');
        Exit;
    end;

    UpdateForm(tw_CON_INFO_LOADED);

    Result := True;
end;

procedure TTsWork.AsyncPushOnOff(Ch, Delay: Integer; PreDelay: Integer);
begin
    TAsyncCalls.Invoke(
        procedure
        begin
            Sleep(PreDelay);
            mDIO.SetIO(Ch, True);
            Sleep(Delay);
            mDIO.SetIO(Ch, False);
        end).Forget;

end;

procedure TTsWork.MtrJogChStatus(MtrIdx, ChIdx: Integer; IsON: Boolean);
begin

end;

function TTsWork.MtrJogRunReq(MtrIdx, ChIdx: Integer; Dir: TMotorDir): Boolean;
begin
    gLog.Debug('MtrJog: SpecChkState:%d, SpecChkOk:%s', [mSpecChkState, BoolToStr(mIsSpecChkOK, True)]);

    if not mIsSpecChkOK then
        Exit(False);

    Result := True;

    gLog.Debug('MtrJog: MtrJogRunReq. Result:%s', [BoolToStr(Result, True)]);
end;

// UI �޽��� ó�� �� ���� ����.
function AvgToIdx(Avg: Boolean): Integer;
begin
    if Avg then
        Result := 2
    else
        Result := 1;
end;

// ���� , �ӵ�, ���� NG��
function TTsWork.NeedsRetest(Motor: TSeatMotor): Boolean;
begin
    Result := False;
end;

procedure TTsWork.SeatMotorTestStatus(Motor: TSeatMotor; TestStatus: TSeatMotorTestStatus);
var
    Msg: Integer;
    ROrd: TResultOrd;
    MtrIt: TMotorOrd;
begin
    if not IsRun then
        Exit;

    mCurMotor := Motor;

    case TestStatus of
        msStart: // �۵� ����
            begin

            end;
        msStop: // �۵� ���� & ���� ���� ó��
            begin

            end;

        msTestEnd: // ���� ����, ������ �Ǵ�
            begin

            end;

        msBurnishStart:
            begin

            end;
        msBurnishEnd:
            begin

            end;

        msBurnishCycle:
            begin
                UpdateForm(tw_BURNISHING_CYCLE);
            end;

        msLimitSetStart:
            begin

            end;

        msLimitSetEnd:
            begin

            end;

        msError: //
            begin

            end;
    end;
end;

procedure TTsWork.RunJogMode;
begin

    if IsAuto then
        Exit;

    mMtrJogDIChs.Run(mDIO);
    mMtrJogLDIChs.Run(mLIO);
end;

const
    LOW_CURR_SETTING_TIMEOUT = 5;
    CON_CHK_TIMEOUT = LOW_CURR_SETTING_TIMEOUT + 2;

function TTsWork.FSMCheckSpec: Integer;

    function IsTestDone: Boolean;
    begin
        Result := (mLIO.IsIO(mLDOChs.mOK) or mLIO.IsIO(mLDOChs.mNOK)) and IsAuto;
    end;

begin

    Result := 0;

    case mSpecChkState of
        0:
            ;
        1:
            begin
                if IsTestDone then
                begin
                    UpdateForm(tw_CHK_DISCONNECT);
                    gLog.Panel('%s: Ŀ��Ʈ ���� ��ȣ ����', [Name]);
                    mLIO.SetIO(mLDOChs.mConChkOK, True);
                end
                else
                begin
                    gLog.Panel('%s: Ŀ��Ʈ ü�� ��ȣ ����', [Name]);
                    mLIO.SetIO(mLDOChs.mConChkOK, False);
                end;

                mPeriodicCanData.SetIgn(true);
                UpdateForm(tw_SPEC_CHK_START);
                mSpChkTC.Start(150 * 1000);
                Inc(mSpecChkState);

                gLog.Panel('%s: ��� ���� ���� ����: %0.1f(A)', [Name, gSysEnv.rOP.rTest.rSpecCurr]);
            end;

        2:
            begin
{$IFDEF VIRTUALLANIO}
                mIsSpecChkOK := True;
                mLIO.SetIO(mLDOChs.mConChkOK, True);
                mSpecChkState := 0;
                UpdateForm(tw_SPEC_CHK_END);
                Exit(1);
{$ENDIF}
                // ���� ������ �������� 50%�����̸� ���� �ƴϸ� ��Ʈ �߻� (Ŀ���� ���� ���� ��..)
                if GetMainCurr <= (gSysEnv.rOP.rTest.rSpecCurr * 0.5) then
                begin
                    Inc(mSpecChkState);
                end
                else
                begin
                    gLog.Panel('%s: ���� ���� 50% �̻� ���� Error(%.1f(A) > %.1f(A)', [Name, mAD.GetValue(AI_MAIN_CURR), (gSysEnv.rOP.rTest.rSpecCurr * 0.5)]);
                    SetError('��� üũ ���� �̻� ERROR', 'Ŀ���� ��Ʈ, ���� ü��, ���� �� ���� �ҷ� ���� �Ǵ� �ùٸ� ������� Ȯ�� �ϼ���.');
                    mIsSpecChkOK := False;

                    mSpecChkState := 0;
                    Exit(-1);
                end;

                if mSpChkTC.IsTimeOut then
                begin
                    // TO DO : NG ��� ������ ó�� ����..
                    SetError('��� üũ ���� ���� ERROR', '�Ŀ� ����ON Ȯ�ο��θ� ���� �ϼ���');
                    mSpecChkState := 0;
                    Exit(-1);
                end;
            end;
        3:
            begin

                Inc(mSpecChkState);
                mDelayTC.Start(10000);
                SetSpecDO;

            end;
        4:
            begin
{$IFDEF VIRTUALLANIO}
                mIsSpecChkOK := True;
                mLIO.SetIO(mLDOChs.mConChkOK, True);
                mSpecChkState := 0;
                UpdateForm(tw_SPEC_CHK_END);
                Exit(1);
{$ENDIF}
                mIsConnected := IsCableConnected();

                if IsTestDone then
                begin
                    if mIsConnected then
                    begin
                        if not mDelayTC.IsTimeOut() then
                            Exit;
                    end;
                end
                else
                begin
                    if not mIsConnected then
                    begin
                        if not mDelayTC.IsTimeOut() then
                            Exit;
                    end;
                end;

                if IsTestDone then
                begin
                    if mIsConnected then
                    begin
                        ShowError('Ŀ���� ����', 'Ŀ���͸� �����ϼ���');
                        mSpecChkState := 100;
                        mDelayTC.Start(15000);
                        mPeriodicCanData.SetIgn(false);
                        Exit(-1);
                    end;

                    mPeriodicCanData.SetIgn(false);
                    mLDOChs.Clear(mLIO, []);
                end
                else
                begin
                    if mIsConnected then
                    begin
                        Inc(mSpecChkState);
                        mPeriodicCanData.SetIgn(false);
                    end
                    else
                    begin
                        SetError('��� üũ ERROR', 'Ŀ���� ������ �������� �ʽ��ϴ� TIMEOUT');
                        mSpecChkState := 0;
                        mPeriodicCanData.SetIgn(false);
                        Exit(-1);
                    end;
                end;

            end;

        5:
            begin
                gLog.Panel('%s: ���� ���� %0.1f(A) ����', [Name, gSysEnv.rOP.rTest.rCurr]);
                Inc(mSpecChkState);
            end;
        6:
            begin
                mIsSpecChkOK := True;

                InitMotorsCtrler(RsBuf.rModel.rTypes);

                gLog.Panel('%s: ���� ���� %0.1f(A) ���� �Ϸ�', [Name, gSysEnv.rOP.rTest.rCurr]);
                mSpecChkState := 0;
                mSkipConChk := True;
                UpdateForm(tw_SPEC_CHK_END);
                mLIO.SetIO(mLDOChs.mConChkOK, mIsConnected);
                Exit(1);

            end;
        100:
            begin
                mIsConnected := True;

                if not mIsConnected then
                begin
                    mLDOChs.Clear(mLIO, []);
                    UpdateForm(tw_HIDE_MSG);
                    mSpecChkState := 0;
                end;

                if mDelayTC.IsTimeOut() then
                begin
                    SetError('Ŀ���� ���� TIMEOUT', 'Ŀ���� ������ �����ʰ� TIMEOUT �ð��� �������ϴ�.');
                end;
            end;
    end;

end;

procedure TTsWork.ShowSpecChkMsg;
begin
    if not gModels.IsModelLoaded then
    begin
        ShowMsg(['�� ���� ����', '���� �������� �ʾҽ��ϴ�'], ['�� �޴��� ����ǰ ����� ��ϵǾ����� Ȯ�� �ϼ���'], True);
        gLog.Error('��� üũ: �� ���� ����', []);

        Exit;
    end;
end;

procedure TTsWork.ShowMsg(Msg, ToDo: string);
begin
    mLstError := Msg;
    mLstToDo := ToDo;

    UpdateForm(tw_MSG);
end;

procedure TTsWork.ShowError(ErrorMsg, ErrorToDo: string);
begin
    mLstError := ErrorMsg;
    mLstToDo := ErrorToDo;

    UpdateForm(tw_ERROR);
end;

procedure TTsWork.ShowMsg(Msgs, ToDos: array of string; IsAlarm: Boolean);
begin
    mIsAlarmMsg := IsAlarm;

    SetLength(mMsgs, Length(Msgs));
    SetLength(mToDos, Length(ToDos));

    Move(Msgs[0], mMsgs[0], sizeof(Msgs));
    Move(Msgs[0], mToDos[0], sizeof(ToDos));

    UpdateForm(tw_MSG2);
end;

procedure TTsWork.SetError(ErrorMsg, ErrorToDo: string);
begin

    mLstError := ErrorMsg;
    mLstToDo := ErrorToDo;

    mWorkState := _WS_ERROR;
end;

procedure TTsWork.WorkProcess();
var
    bTm: Boolean;
    DIStr: string;

    function GetDIStr(StartCh, EndCh: Integer): string;
    var
        i: Integer;
    begin
        for i := StartCh to EndCh do
        begin
            Result := Result + BoolToStr(mDIO.IsIO(i), True) + '  ';
        end;
    end;

    function IsNextTsWorkStable: Boolean;
    begin
        Result := True;
        if Assigned(mNextTsWork) then
            Result := mNextTsWork.IsStableState;
    end;

begin

    FSMCheckSpec;

    RunJogMode;

    mDIEventer.Run(mLIO);

    mPeriodicCanData.Run;

    case mWorkState of
        _WS_IDLE:
            ;
        _WS_START:
            begin
{$IFNDEF VIRTUALLANIO}

                if not mIsSpecChkOK then
                    Exit;

                if not CheckPowerStatus then
                    Exit;
{$ENDIF}
                mMtrOper.Init([mMtrSlide, mMtrRecline, mMtrCushTilt, mMtrWalkinUpTilt, mMtrShoulder, mMtrRelax], [twBack, twBack, twForw, twForw, twForw, twForw]);
                mMtrOper.ClearFSM;
                mFuncState := 0;
                mWorkState := _WS_DELETE_LIMIT;

                mPeriodicCanData.SetIgn(true);
                mPeriodicCanData.SetSpeedZero(true);

                gLog.Panel('%s: ����Ʈ ���� ����', [Name]);
            end;

        _WS_DELETE_LIMIT:
            begin
                case FSMAlignMotor(pmtInterval) of
                    -1:
                        begin
                            SetError(mMtrOper.CurMotor.mLstError, mMtrOper.CurMotor.mLstToDo);
                        end;
                    1:
                        begin
                            mFuncState := 0;
                            mWorkState := _WS_WAIT_TEST_SIGN;
                        end;
                end;
            end;
        _WS_WAIT_TEST_SIGN:
            begin
                mMtrOper.ClearFSM;
                mFuncState := 0;
                mWorkState := _WS_BURNISHING;
                mDelayTC.Start(gSysEnv.rSoundProof.rWaitA4WeightLoading * 1000);
                UpdateForm(tw_BURNISHING_START);
                gLog.Panel('%s: ���Ͻ� ����', [Name]);
            end;

        _WS_BURNISHING:
            begin
                case mMtrOper.FSMBurnishing(False) of
                    -1:
                        begin
                            SetError('Burnishing: ' + mMtrOper.CurMotor.mLstError, mMtrOper.CurMotor.mLstToDo);
                        end;
                    1:
                        begin
                            gLog.Panel('%s: ���Ͻ� �Ϸ�', [Name]);
                            UpdateForm(tw_BURNISHING_END);
                            mMtrOper.ClearFSM;
                            mFuncState := 0;
                            mWorkState := _WS_ALIGN_MOTOR2;
                            mMtrOper.Init([mMtrSlide], [twBack]);
                        end;
                end;
            end;

        _WS_ALIGN_MOTOR2:
            begin
                case FSMAlignMotor(pmtInterval) of
                    -1:
                        begin
                            SetError(mMtrOper.CurMotor.mLstError, mMtrOper.CurMotor.mLstToDo);
                        end;
                    1:
                        begin
                            mWorkState := _WS_WAIT_ALL_TEST_END;
                            mFuncState := 0;
                        end;
                end;
            end;

        _WS_WAIT_ALL_TEST_END:
            begin
                UpdateForm(tw_SAVE);

                mLIO.SetIO(mLDOChs.mConChkOK, True);
                mLIO.SetIO(mLDOChs.mOK, True);
                mLIO.SetIO(mLDOChs.mNOK, False);

                mPopState := 0;
                mFuncState := 0;
                mWorkState := _WS_END_OF_TEST;
            end;

        _WS_SAVE_DATA:
            begin
            end;

        _WS_WAIT_POP_SEND:
            begin

            end;

        _WS_END_OF_TEST:
            begin

            end;

        _WS_END_OF_TEST + 1:
            ;

        _WS_ERROR:
            begin

                if mLstError <> '' then
                    gLog.Error('%s: Err �޽���: %s', [Name, mLstError]);
                gLog.Panel('%s: Err ���½�: %s', [Name, GetStateStr]);
                gLog.Panel('%s: Err ���½�: ���� ����:%f(V), ���� ����:%f(A), ���� ����: %f(A)', [Name, GetOutVolt, GetOutCurr, GetMainCurr]);

                StopMotors;

                mLIO.SetIO(mLDOChs.mAlarm, True);

                mWorkState := _WS_ERROR_IDLE;

                UpdateForm(tw_ERROR);
            end;

        _WS_ERROR_IDLE:
            ;
    else
        mLstError := '��� ���μ��� ����';
        mLstToDo := '���α׷��� �ٽ� �����ϼ���';
        gLog.Panel('%s: ������μ��� ���� %d', [Name, mWorkState]);

        UpdateForm(tw_ERROR);
        mWorkState := _WS_ERROR;
    end;
end;

procedure TTsWork.Write(TV: TTreeView);
var
    RootNode, CurNode: TTreeNode;
    MtrIt: TMotorOrd;
begin
    TV.Items.Clear;

    RootNode := TV.Items.AddObject(nil, Name, self);

    for MtrIt := Low(TMotorOrd) to MtrOrdHi do
    begin
        if not Assigned(mMotors[MtrIt].OnTestStatus) then
            continue; // �����ϴ� ���� �ɷ����� ex>CushExt

        CurNode := TV.Items.AddChildObject(RootNode, mMotors[MtrIt].Name, mMotors[MtrIt]);
        TV.Items.AddChildObject(CurNode, mMotors[MtrIt].MoveCtrler.Name, mMotors[MtrIt].MoveCtrler);
        TV.Items.AddChildObject(CurNode, mMotors[MtrIt].IMSCtrler.Name, mMotors[MtrIt].IMSCtrler);
    end;

    RootNode.Expand(True);

end;

function TTsWork.IsPopLinkMode: Boolean;
begin
    Result := mLIO.IsIO(mLDIChs.mPopLinkMode);
end;

function TTsWork.GetPowerEnable: Boolean;
begin
    Result := mDCPower.GetComStatus; // Power ;
end;

function TTsWork.GetRsBuf: PResult;
begin
    Result := mDBX.RsBuf;
end;

function TTsWork.GetStateStr(IsSimple: Boolean): string;
begin
    Result := inherited GetStateStr + Format(' mWorkState=%d, mSpecChkState=%d, mElecState=%d, mFuncState=%d', [mWorkState, mSpecChkState, mElecState, mFuncState]);
end;

function TTsWork.GetStationID: TStationID;
begin
    Result := TStationID(mDBX.Tag);
end;

function TTsWork.GetStationIDStr: string;
begin
    if gSysEnv.rOP.rStGroupNo <= 1 then
        Result := Format('#%d', [gSysEnv.rOP.rStNo + ord(StationID)])
    else
        Result := Format('#%d-%d', [gSysEnv.rOP.rStNo + ord(StationID), gSysEnv.rOP.rStGroupNo - 1]);

end;

function TTsWork.GetConCount: Integer;
begin
    Result := mConnectors.Count;
end;

function TTsWork.GetConnectors(Idx: Integer): TBaseSeatConnector;
begin
    if Idx < mConnectors.Count then
    begin
        Result := mConnectors[Idx];
    end
    else
    begin
        raise EListError.CreateFmt('TTsWork.GetConnectors: Idx %d�� ���� ��� (0..%d)', [Idx, mConnectors.Count - 1]);
    end;
end;

function TTsWork.GetOutCurr: Double;
begin
    Result := mDCPower.GetOutCurr;
end;

function TTsWork.GetOutVolt: Double;
begin
    Result := mDCPower.GetOutVolt;
end;

function TTsWork.GetPopDatas: string;
var
    i: Integer;
    stm: string;
begin
    Result := '';
    for i := 0 to Length(PopDataORD) - 1 do
    begin
        stm := mDBX.GetResultToATxt(ord(PopDataORD[i]), False, False);
        if (stm = '--') then
            stm := '';
        if i = 0 then
            Result := stm
        else
            Result := Result + _TOKEN + stm;
    end;
end;

procedure TTsWork.OnRcvedPopData(Sender: TObject; ACommand: Integer);
begin
    case ACommand of
        SYS_CMD_RCV_MODEL: // 14
            begin
                with Sender as TPopSystem do
                begin
                    mDBX.SetData(roPartNo, mPop.GetPartNo);
                    mDBX.SetData(roLotNo, mPop.GetLotNo);

                    UpdateForm(tw_POP_RCVD_MODEL);
                    gLog.Panel('%s: %s, %s, %s', [Name, mPop.GetPartNo, mPop.GetLotNo, GetWorkInfo]);
                    if rcvWorkType = '0' then
                    begin
                        {
                          if rcvWorkDetail = '1' then
                          ShowError(Format(_TRNS('LOT NO: %s�� �����Ͱ� �����ϴ�'), [rcvLotNo]), 'SEAT ������ Ȯ�� �ϼ���')
                          else
                          begin
                          ShowError(Format(_TRNS('LOT NO: %s - #%d CELL �������� NG �߻��� ��ǰ�Դϴ�'), [rcvLotNo, StrToInt(rcvWorkDetail) - 2]), '�۾��� �� �����ϴ�');
                          end;
                          }
                        // �۾� ���� ���� ǥ�� �Ǵ� ���� �� POP �۽� �� ��??
                        // UpdateForm(tw_HIDE_MSG);
                    end
                    else if rcvWorkType = '1' then
                    begin
                        {
                          if not RsBuf.rModel.rTypes.IsLimit then
                          begin
                          ShowMsg('������ ��ǰ�Դϴ�', '���� ���̺�� ������ S/W ���̺��� ��������');
                          end;
                          }
                    end
                    else if rcvWorkType = '2' then
                        RsBuf.rIsRework := True;

                end;
                SendToForm(mHandle, SYS_POP_RCV_MODEL, mDBX.Tag);
            end;
        SYS_CMD_RCV_ACK:
            begin
                if mPopState = 2 then
                begin
                    mDBX.SetData(roPopsnded, True);
                    mDBX.SaveData(mDBX.GetSaveTimes);

                    mPopState := 3;
                    gLog.Panel('%s: (PC)POP�����۾��Ϸ�Ȯ��', [Name]);
                end;
            end;
        SYS_POP_CONNECTED, SYS_POP_CONNECTING, SYS_POP_DISCONNECTED, SYS_CMD_RCV_ERROR:
            begin
                if mPopState = 2 then
                begin
                    mPopState := 3;
                    gLog.Panel('%s: (PC)POP�����۾�����', [Name]);
                end;
            end;
        // SYS_CMD_RCV_NAK
    end;
end;

function TTsWork.GetMotorCurr(Motor: TMotorOrd): Double;
begin
    Result := mMotors[Motor].GetCurr;
end;

function TTsWork.GetMotorCurr: Double;
begin
    Result := mAD.GetValue(AI_MOTOR_CURR);
end;

function TTsWork.GetMotors(Mtr: TMotorOrd): TSeatMotor;
begin
    Result := mMotors[Mtr];
end;

function TTsWork.GetName: string;
begin
    Result := GetStationName(StationID);
end;

function TTsWork.GetMainCurr: Double;
begin
{$IFDEF VIRTUALIO}
    Result := 10 + random(30) * 0.01;
{$ELSE}
    Result := mAD.GetValue(AI_MAIN_CURR);
{$ENDIF}
end;

function TTsWork.PopWorkProcess: Boolean;
const
    _ONOFF: array[False..True] of string = ('OFF', 'ON');
var
    stm: string;
begin
    Result := False;
    case mPopState of
        0:
            begin

                if not mPop.IsConnected or mPop.NotsndResult then
                begin
                    mPopState := 4;
                    gLog.Panel('(PC)POP�����۾����(POP: %s, IO: %s, �۾�: %s, PalletNO: %s)', [_ONOFF[mPop.IsConnected], _ONOFF[IsPopLinkMode], _ONOFF[IsRun], mDBX.GetResultToATxt(ord(roPalletNO), False, False)]);

                    if not IsPopLinkMode then
                    begin
                        gLog.Panel('�������: �ܵ��������.');
                    end
                    else if not mPop.IsConnected then
                    begin
                        gLog.Panel('�������: POP�� ������� �ʾҽ��ϴ�.');
                    end
                    else if mPop.NotsndResult then
                    begin
                        gLog.Panel('�������: POP �۾���� ���� ON');
                    end
                    else if mDBX.IsExists(roPoprcved) then
                    begin
                        gLog.Panel('�������: POP �����۾��� ����� �ƴմϴ�.');
                    end
                    else if mDBX.GetResultToATxt(ord(roPalletNO), False, False) = '' then
                    begin
                        gLog.Panel('�������: POP ���ŵ� �ȷ�ƮNO�� �����ϴ�.');
                    end;

                    UpdateForm(tw_POP_PASS);
                    Result := True;
                    Exit;
                end;
                stm := GetPopDatas();
                if mPop.AddData(OnRcvedPopData, SYS_CMD_WRITE_DATA, stm) then
                begin
                    mPopState := 2;
                    UpdateForm(tw_POP_START);
                    gLog.Panel('%s: (PC)POP���۵������߰�: %s', [Name, stm]);
                end
                else
                begin
                    mPopState := 3;
                    gLog.Panel('%s: (PC)POP���۵���Ÿ�߰�����: %s', [Name, stm]);
                end;
            end;
        2:
            ;
        3:
            begin
                Inc(mPopState);
                Result := True;

                UpdateForm(tw_POP_END);
            end;
    end;
end;

function TTsWork.IsAuto: Boolean;
begin
    Result := mLIO.IsIO(mLDIChs.mAutoMode);
end;

function TTsWork.IsCableConnected: Boolean;
begin
    Result := not mCanRcvTC.IsTimeOut();
end;

procedure TTsWork.SelfTest;
begin

    Exit;

    ShowMsg(['�׽�Ʈ �޽���' + Name], ['(1) �ùٸ� ���(�� ����)�ΰ���? POP ������ Ȯ���� �ּ���'], True);

    Exit;

    ShowMsg(['�׽�Ʈ �޽���'], ['(1) �ùٸ� ���(�� ����)�ΰ���? POP ������ Ȯ���� �ּ���', '(2) ��ǰ - �ȷ�Ʈ�� ���̺���� ����� ���� �Ǿ�����?'#13'���̺� ������ Ȯ���ϼ���', '(3) ���� ���� �� �ɻ��°� ��ȣ�Ѱ���?', '(4) ��Ƽ����'#13'�׽�Ʈ�Դϴ�'], True);
end;

procedure TTsWork.SetUsrLog(const szFmt: string; const Args: array of const; IsFile: Boolean);
begin
    if not IsFile then
        gLog.Panel(GetDevComName(mDevCom.DevID) + ' ' + szFmt, Args)
    else
        gLog.ToFiles(GetDevComName(mDevCom.DevID) + ' ' + szFmt, Args);

    if mLogHandle <= 32 then
        Exit;
    ToPanel(mLogHandle, GetDevComName(mDevCom.DevID) + ' ' + szFmt, Args);
end;

function TTsWork.AnalysysRcvDatas(var RcvData, Value: string): Boolean;
const
    _HEAD = '!';
    _TAIL = '#';
var
    stm: string;
    nH, nT: Integer;
begin
    Result := False;
    if Length(Trim(RcvData)) <= 0 then
        Exit;

    nH := Pos(_HEAD, RcvData);
    nT := Pos(_TAIL, RcvData);

    if (nH > 0) and (nT > 0) and (nH < nT) then
    begin
        stm := RcvData;
        Value := Copy(RcvData, nH + 1, nT - nH - 1);
        Delete(RcvData, 1, nT);
        SetUsrLog('UnPack RCV: %s, DAT: %s, REM: %s', [stm, Value, RcvData]);

        Result := True;
    end
    else if (nH <= 0) and (nT > 0) then
    begin
        Delete(RcvData, 1, nT);
    end
    else if (nH <= 0) and (nT <= 0) then
    begin
        RcvData := '';
    end;
end;

function TTsWork.IsStableState: Boolean;
begin
    Result := mWorkState <> _WS_MOVE_TO_D_POS;
end;

// ------------------------------------------------------------------------------

end.

