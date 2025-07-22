unit TsWorkUnit;
{$I myDefine.inc}

interface

uses
    Windows, Sysutils, Graphics, Classes, FaGraphEx, ComCtrls, DataUnit, siAPD,
    TimeCount, DataBox, PopWork, myUtils, ComUnit, KiiMessages, TimeAccumulator,
    PowerSupplyUnit, ModelUnit, TimeChecker, BaseTsWork, BaseDIO, BaseAD, BaseAO,
    BaseCAN, ModelType, IODef, ScannerUnit, DIOChs, Global, SysEnv, SeatType,
    SeatMotor, SeatMotorType, SeatMoveCtrler, SeatIMSCtrler, MotorJogOperator,
    IntervalCaller, SeatConnector, AsyncCalls, Range, DataUnitOrd,
    StateDefineUnit, UDSCarConfig, PeriodicCanData;

const
    MAX_LDIST_COUNT = 2;
    LDIST_IDX_ST01 = 0;
    LDIST_IDX_ST02 = 1;

type
    TCtrlerType = (ctSimul, ctDIO, ctCAN, ctLIN);

    TPwrMtrsMoveType = (pmtEach, pmtGroup, pmtSameTime, pmtInterval);
    // ����, �׷캰, ����, �ð���

    TTsWork = class(TBaseTsWork)
    private
        function GetConnectors(Idx: Integer): TBaseSeatConnector;
        function GetConCount: Integer;
        function BeforeIOSet(DIO: TBaseDIO; Ch: Integer; Value: Boolean): Boolean;
        function CheckPowerStatus: Boolean;
        function IsAllMotorsAtLimit: Boolean;
        function NeedLimitSetting: Boolean;
        procedure CanRead(Sender: TObject);

    protected
        mDBX: TDataBox;

        mNextTsWork: TTsWork; // �� ����

        // ----- ���� �ӽ� ����: ���Ž��� XXXProc�� ������ XXXState�� ���� �ʿ�
        mWorkState: TWorkState;

        mElecState, mLocalState,

        // Sub FSM �Լ���
        mInitState, mFuncState, // ���� �ʱ���ġ ���ĵ��� �Լ����� ���.
        mOutPosState, // ��ǰ ��ġ��
        mSpecChkState, mPopState: Integer;

        mLmtState: Integer;

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
        mOldMtrModelType, // ���� ��Ʈ�ѷ� ���� �� Ÿ��
        mPreModelType, mCurModelType: TModelType;
        mMdlExData: TMdlExData;
        mMdlNo: Integer;
        mCUrModels: PModels;

        // --------------------------------------------------------------------
        // SeatMotor ����

        mMainCon: TSeatConnector;
        mSwCon: TSwConnector;
        mConnectors: TSeatConnectorList;

        mMoveCtrler: array[TMotorOrd] of TDIODirectMoveCtrler; // Factory ��ȯ ����
        mUDSMoveCtrler: TCANUDSMoveCtrler; // ���͵��� ����
        mIMSCtrler: TCANIMSCtrler;  // �Ǵ� TBaseIMSCtrler

        mCurMotor: TSeatMotor;
        mMotors: array[TMotorOrd] of TSeatMotor;
        mMtrSlide, mMtrTilt, mMtrHeight, mMtrLegSupt, mMtrSwivel: TSeatMotor;
        mMtrOper: TSeatMotorOper;

        // --------------------------------------------------------------------

        // ���Ľ� : �� ����� �ݴ� ������ ����� ���͸��� ��� ���� �뵵
        mAlignMotors: array[TMotorOrd] of TSeatMotor;
        mAlignMtrDirs: array[TMotorOrd] of TMotorWayOrd;
        mAlignMtrCount: Integer;

        mFlag: Boolean; // ���� Flag

        // ---------------------------------------------------------------
        // ��� üũ

        mConStatus, mConChkStatus: Boolean; // Ŀ���� ���� ����
        mIsSpecChkOK: Boolean; // Ŀ���� ���� �� ���üũ ����
        mIsCanRcvTimeOut: Boolean;
        mSkipConChk: Boolean; // Ŀ���� üũ ���� ���� ��� ����
        mStartSpecChk: Boolean;

        // LAN DI
        mLDIChs: TLDIChs;
        // LAN DO
        mLDOChs: TLDOChs;

        mDIEventer: TDIEventer;

        mMtrJogDIChs, mMtrJogLDIChs: TMotorJogOperator;

        mConUnboundTC, mDelayTC, mTC, mLocalTC, mSpChkTC, mSwTC, mLmtTC, // BlueLink Chk
        mMtrRunTC, mLmtTc1: TTimeChecker;
        mSpecChkTC: TTimeChecker;
        mCanRcvTC: TTimeChecker;

        mFilter: TAPD3;
        mTmpTime: Double;

        // ----- ������� �ʿ��� ������
        mdstRepeat: Integer; // �Լ������� �˾Ƽ� ������ �ٸ��� ������
        // mdstWay, mdstVtWay: TMotorWayOrd;

        mdstMemRepeat: Integer; // �޸� �ҷ����� �ݺ� ���� Ƚ��.
        mdstNgRepeat: Integer;
        mdstFlag: BYTE;
        mdstResult: Integer;
        mdstStopTime: Double; // 2013.07.04
        // -----

        // -----

        mOldCurr: Double;

        mCycleTime: Double;

        mIsModelLoaded, mIsTesting: Boolean;
        mIsDelivering: Boolean;

        mIsPrnDone: Boolean; // �μ� �Ϸ�
        mIsTestingNG: Boolean; // ���� �� NG, ��� NGó�� Flag

        mIsRearDPos: Boolean; // Slide �Ĺ� ��ǰ ��ġ ���� ���� ����

        mJogDir: TMotorDir;

        mPreDIStr: string; // �ӽ�

        mOldEndPosChk: Boolean;

        mSensorState: array[TMotorDir, 0..1] of Boolean;

        mIAsyncCall: IAsyncCall;
        mMMA: TMinMaxAvg;

        mNGRetry: Integer;

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

        // SPEC üũ  �� �ʱ�ȭ
        function AssignConnector: Boolean;
        function IsSpecChecking: Boolean;
        procedure ShowSpecChkMsg;

        procedure ClearDO;
        procedure SetSpecDO;
        procedure ClearSpecDO;
        procedure ClearElecDOs;

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
        function FSMPushOnOff(Ch, Delay: Integer): Integer;
        function FSMCheck4MotorMove(Dir: TMotorDir): Integer;

        function GetMotors(Mtr: TMotorOrd): TSeatMotor;

        function GetStationID: TStationID;
        function GetName: string; override;
        function GetRsBuf: PResult;
        procedure SetMainCurrZero; override;

        function SlideMtrStopCond(Motor: TSeatMotor): Boolean;
        procedure PollingScanner;

        function MtrJogRunReq(MtrIdx, ChIdx: Integer; Dir: TMotorDir): Boolean;
        procedure MtrJogChStatus(MtrIdx, ChIdx: Integer; IsON: Boolean);

        function FSMJogMove(Dir: TMotorDir): Integer;

        procedure AsyncPushOnOff(Ch, Delay: Integer; PreDelay: Integer = 0);
        function NeedsRetest(Motor: TSeatMotor): Boolean;

    public
        mMsgs, mToDos: array of string;
        mIsAlarmMsg: Boolean;

        constructor Create(StationID: TStationID; AD: TBaseAD; DIO: TBaseDIO; CAN: TBaseCAN; AO: TBaseAO; DevCom: TDevCom);
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

        // �ܺ� ��ġ �� Ch ����
        procedure SetLanDIChs(StartAbsCh: Integer);
        procedure SetLanDOChs(StartAbsCh: Integer);
        procedure InitJogChs;

        procedure LinkNext(TsWork: TTsWork);

        function GetOutVolt: Double;
        function GetOutCurr: Double;

        function GetPowerEnable: Boolean;

        function GetMainCurr: Double;
        function GetMotorCurr(Motor: TMotorOrd): Double;
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


        // --------------------------------
        property StationID: TStationID read GetStationID;
        property DBX: TDataBox read mDBX;

        property DevCom: TDevCom read mDevCom;

        property AD: TBaseAD read mAD;
        property DIO: TBaseDIO read mDIO;
        property CAN: TBaseCAN read mCAN;

        property MainCon: TSeatConnector read mMainCon;
        property SwCon: TSwConnector read mSwCon;

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
    gTsPwrWorks: array[0..ord(High(TStationID))] of TTsWork;

implementation

uses
    Forms, Dialogs, Log, LanIoUnit, LOTNO, Math, Rs232, Work, DataUnitHelper,
    TypInfo, UDSDef, ClipBrd, LangTran, MsgForm, PCANBasic;

const
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
        if gTsPwrWorks[i].IsSpecChkOK then
        begin
            Exit(gTsPwrWorks[i]);
        end;
    end;

    Result := nil;
end;

{ TTsWork }

constructor TTsWork.Create(StationID: TStationID; AD: TBaseAD; DIO: TBaseDIO; CAN: TBaseCAN; AO: TBaseAO; DevCom: TDevCom);
var
    i: Integer;
begin
    inherited Create;

    mDBX := TDataBox.Create(ord(StationID));
    mStationID := ord(StationID);

    mWorkState := _WS_IDLE;
    mSpecChkState := 0;

    mAD := AD;
    mDIO := DIO;
    mDIO.OnConfirmBeforeIOSet := BeforeIOSet;
    mLIO := gLanDIO;
    mCAN := CAN;
    mAO := AO;

    mCAN.OnRead.Add(CanRead);

    mDevCom := DevCom;

    mDCPower := gDCPower.Items[ord(StationID)];
    mPop := gPopsys.Items[ord(StationID)];
    mPop.OnRcvData := OnRcvedPopData;

    mFilter := TAPD3.Create;
    mTmpTime := 0;

    CreateConnectors;
    CreateMotors;

    mSubThLoop := True;
    mIsCanRcvTimeOut := True;

    mCUrModels := gModels.GetPModels(1);

    {
      TASyncCalls.Invoke(
      procedure
      var
      TC: TTimeChecker;
      begin

      while mSubThLoop do
      begin
      end;
      end
      ).Forget;
      }

    mLDOChs.Clear(mLIO, []);

    mPeriodicCanData := TPeriodicCanData.Create(CAN, mCurModelType.GetCarType);

    gLog.Panel('%s: Create', [Name]);
end;

procedure TTsWork.CreateConnectors;
begin
    mConnectors := TSeatConnectorList.Create;
    mMainCon := TSeatConnector.Create(mAD, AI_MAIN_CON_VOLT_START);

    mMainCon.Name := 'Main';

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

    mCAN.OnRead.Remove(CanRead);

    FreeAndNil(mDBX);

    FreeMotors;
    FreeConnectors;

    FreeGrpHelpers;

    if Assigned(mPop) then
        mPop.OnRcvData := nil;

    if Assigned(mPeriodicCanData) then
        FreeAndNil(mPeriodicCanData);

    if Assigned(mUDSMoveCtrler) then
        FreeAndNil(mUDSMoveCtrler);

    if Assigned(mIMSCtrler) then
        FreeAndNil(mIMSCtrler);

    FreeAndNil(mFilter);

    inherited;
end;

procedure TTsWork.CanRead(Sender: TObject);
var
    PosState: Byte;
    i: Integer;
    sData: string;
begin
    mCanRcvTC.Start(1000);
    with Sender as TBaseCAN do
    begin
        case ID of
            $726:
                begin

                end;
            $3ED:   // RL
                begin
                end;
            $3EE: // RR
                begin
                end;
            $42C:   // RL ����/������, ��ũ�� ����(?)
                begin
                end;
            $42D:    // RR ����/������, ��ũ�� ����(?)
                begin
                end;
        end;
        WriteWFrames;
    end;
end;

procedure TTsWork.PollingScanner;
begin

end;

function TTsWork.BeforeIOSet(DIO: TBaseDIO; Ch: Integer; Value: Boolean): Boolean;
begin
    Result := True;

end;

procedure TTsWork.CheckModelChange(ID: Integer; ATypeBits, Mask: DWORD);
var
    MdlNo: Integer;
    ConnectorFileName: string;
begin
    mMdlNo := ID;
    mCurModelType := TModelType.Create(ATypeBits);

    if not mPreModelType.IsEqual(mCurModelType) then
    begin
        mPreModelType := mCurModelType;
        mCAN.Close;

        // �� Ÿ�Կ� ���� Ŀ���� ���� ����
        case mCurModelType.GetCarType of
            ctJG1:
                begin
                    ConnectorFileName := 'JG1_Connector.json';
                    mCAN.UseFD := true;
                    mCAN.PreScaleStr := FD_S_POINT_80_PRESET_1;
                    mCAN.Open(0, 500);
                end;
            ctRJ1:
                begin
                    ConnectorFileName := 'RJ1_Connector.json';
                    mCAN.UseFD := true;
                    mCAN.PreScaleStr := CLASSIC_S_POINT_80_1_PRESET;
                    mCAN.Open(0, 500);
                end;
            ctHI:
                begin
                    ConnectorFileName := 'HI_Connector.json';
                    mCAN.UseFD := true;
                    mCAN.PreScaleStr := CLASSIC_S_POINT_80_1_PRESET;
                    mCAN.Open(0, 100);
                end;
        end;

        // �ش� ���� Ŀ���� ���� �ε�
        if not gConMan.Load(GetEnvPath(ConnectorFileName)) then
        begin
            gLog.Error('Ŀ���� ���� ����:%s ���� ����', [ConnectorFileName]);
            SetError(Format('Ŀ���� ���� ���� %s ���� ����', [ConnectorFileName]), Format('Env������ %s ������ �ִ��� Ȯ���ϼ���', [ConnectorFileName]));
            Exit;
        end;

        gLog.Panel('%s: Ŀ���� ���� �ε� ����: %s', [Name, ConnectorFileName]);

        MdlNo := gModels.FindModel(mCurModelType, Mask);
        if MdlNo > 0 then
        begin
            UpdateForm(tw_INIT);
            gLog.Panel('%s: ���� MODEL %d -> %d(0x%X)', [Name, gModels.GetModelNo(StationID), MdlNo, ATypeBits]);

            gModels.SelectModel(StationID, MdlNo); // �� No ����
            mDBX.SetModel(gModels.CurrentModel(StationID)); // �� ������ �� ����
            RsBuf.rModel.rTypes := mCurModelType; // �𵨻���� �������� �ٸ��� ������ ����, Ŀ���� ü��Ȯ�ο� �������� ���� �����ؾ� ��.

            AssignConnector;

            InitMotors;

            mIsModelChange := True;

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

procedure TTsWork.SetLanDIChs(StartAbsCh: Integer);
begin
    mLDIChs.Init(StartAbsCh);

    with mLDIChs do
    begin
        mDIEventer.Init([mAutoMode, mPopLinkMode, mEmerStop, mWorkProduct], LanDIChStatus);
    end;
end;

procedure TTsWork.SetLanDOChs(StartAbsCh: Integer);
begin
    mLDOChs.Init(StartAbsCh);
end;

function TTsWork.CheckPowerStatus: Boolean;
const
    POWER_CHECK_TIMEOUT = 10000.0; // 10��
begin
    Result := True;
  {
  if not mDCPower.Power then
  begin
    if (GetAccurateTime - mTmpTime) > POWER_CHECK_TIMEOUT then
    begin
      SetError('������ ON ���� �ʾҽ��ϴ�',
               '�Ŀ����ö��� ��ſ��� �� ���¸� Ȯ���� ���۾��ϼ���');
      gLog.Panel('%s: �Ŀ� Error', [Name]);
      Result := False;
    end;
  end;
  }
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
    // SetMotorCurrPinsToZero;  // �̹� ������ �޼��尡 �ִٸ�

end;

procedure TTsWork.SetMotorCurrPinsToZero;
begin
    //mAD.SetZeros(AI_MTR_CURR_START, AI_MTR_CURR_START + MAX_SW_PIN_COUNT - 1);

    gLog.Debug('%s: Ŀ���� ���� �� ZERO', [Name]);
end;

procedure TTsWork.InitJogChs;
begin
    mMtrJogDIChs.Init(DI_SLIDE_MTR_CW, [mMtrSlide, mMtrTilt, mMtrHeight, mMtrLegSupt, mMtrSwivel], MtrJogChStatus);
    mMtrJogLDIChs.Init(mLDIChs.mSlideFw, [mMtrSlide, mMtrTilt, mMtrHeight, mMtrLegSupt, mMtrSwivel], MtrJogChStatus);

    mMtrJogDIChs.OnJogRunReq := MtrJogRunReq;
    mMtrJogLDIChs.OnJogRunReq := MtrJogRunReq;
end;

procedure TTsWork.CreateMotors;
var
    It: TMotorOrd;
begin
    // IMSCtrler ���� (CAN ���)

    mUDSMoveCtrler := TCANUDSMoveCtrler.Create(mCAN, _UDS_MSG_2GEN_TAGET_PSM_ID, $7AB);

    // Simul ����� ���
{$IFDEF VIRTUALIO}
    mIMSCtrler := TSimulIMSCtrler.Create(mCAN);
{$ELSE}
    mIMSCtrler := TCANIMSCtrler.Create(mCAN, _UDS_MSG_2GEN_TAGET_PSM_ID, _UDS_MSG_2GEN_RESP_PSM_ID);
{$ENDIF}

    mMtrOper := TSeatMotorOper.Create(@mLstError, @mLstToDo);

    mMtrSlide := TSeatMotor.Create(tmSlide, mUDSMoveCtrler, mAD, [AI_MOTOR_CURR, AI_MOTOR_CURR, AI_NOISE]);
    mMtrTilt := TSeatMotor.Create(tmTilt, mUDSMoveCtrler, mAD, [AI_MOTOR_CURR, AI_MOTOR_CURR, AI_NOISE]);
    mMtrHeight := TSeatMotor.Create(tmHeight, mUDSMoveCtrler, mAD, [AI_MOTOR_CURR, AI_MOTOR_CURR, AI_NOISE]);
    mMtrLegSupt := TSeatMotor.Create(tmLegSupt, mUDSMoveCtrler, mAD, [AI_MOTOR_CURR, AI_MOTOR_CURR, AI_NOISE]);
    mMtrSwivel := TSeatMotor.Create(tmSwivel, mUDSMoveCtrler, mAD, [AI_MOTOR_CURR, AI_MOTOR_CURR, AI_NOISE]);

    mMtrSlide.Name := Name + ' ' + mMtrSlide.Name;
    mMtrTilt.Name := Name + ' ' + mMtrTilt.Name;
    mMtrHeight.Name := Name + ' ' + mMtrHeight.Name;
    mMtrLegSupt.Name := Name + ' ' + mMtrLegSupt.Name;
    mMtrSwivel.Name := Name + ' ' + mMtrSwivel.Name;

    mMtrSlide.OnStopCond := nil; // ���� ������ ���� ����

    // �迭�� �Ҵ�
    mMotors[tmSlide] := mMtrSlide;
    mMotors[tmTilt] := mMtrTilt;
    mMotors[tmHeight] := mMtrHeight;
    mMotors[tmLegSupt] := mMtrLegSupt;
    mMotors[tmSwivel] := mMtrSwivel;

    for It := Low(TMotorOrd) to MtrOrdHi do
    begin
        mMotors[It].OnTestStatus := SeatMotorTestStatus;
        mMotors[It].IMSCtrler := mIMSCtrler;
        mMotors[It].MoveCtrler := mUDSMoveCtrler;

        mMotors[It].IsIMS := True;
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
    begin
        FreeAndNil(mMotors[It]);
        FreeAndNil(mMoveCtrler[It]);
    end;

    FreeAndNil(mMtrOper);

end;

function MtrOrd2SwPinType(MtrID: TMotorOrd): TPwrSwPinType;
begin

end;

procedure TTsWork.InitMotorsCtrler(MdlType: TModelType);
var
    It: TMotorOrd;
begin

//    // �������� �ﰢ ����
//    for It := Low(TMotorOrd) to High(TMotorOrd) do
//    begin
//        mMotors[It].MoveCtrler.Enabled := False;
//        mMotors[It].MoveCtrler := mMoveCtrler[It];
//        // mMotors[It].AIChPwrCurr := mSwCon.GetCurrCh(MtrOrd2SwPinType(It));   // ��� �� ��: ���������� Ctrler Curr�� ���� 24.11.11
//        mMotors[It].MoveCtrler.Enabled := True;
//    end;


    mMotors[tmSlide].Use := RsBuf.rModel.rTypes.isSlideExists;
    mMotors[tmTilt].Use := RsBuf.rModel.rTypes.IsTiltExists;
    mMotors[tmHeight].Use := RsBuf.rModel.rTypes.IsHeightExists;
    mMotors[tmLegSupt].Use := RsBuf.rModel.rTypes.IsLegSuptExists;
    mMotors[tmSwivel].Use := RsBuf.rModel.rTypes.IsSwivelExists;

    TUDSCarConfigurator.SetupCANIDs(mIMSCtrler, mUDSMoveCtrler, MdlType.GetCarType, MdlType.IsDrvPos);
    TUDSCarConfigurator.SetUpUDSMoveData(mUDSMoveCtrler, MdlType.GetCarType, MdlType.IsIMS);

    if mCurModelType.IsRJ1 and (not mCurModelType.IsIMS) then
        mUDSMoveCtrler.AdvenceType := true
    else
        mUDSMoveCtrler.AdvenceType := false;

    if MdlType.IsDrvPos then
        mIMSCtrler.RCID.Create($12A3)
    else
        mIMSCtrler.RCID.Create($12A5);

    for It := Low(TMotorOrd) to High(TMotorOrd) do
    begin
        mMotors[It].MoveCtrler.Enabled := false;
        mMotors[It].MoveCtrler := mUDSMoveCtrler;
        mMotors[It].IMSCtrler := mIMSCtrler;
        mMotors[It].MoveCtrler.Enabled := true;
    end;
end;

procedure TTsWork.InitMotors;
var
    MtrIt: TMotorOrd;
    MtrCnst: TMotorConstraints;
    TimeParam: TSMParam;

    function GetBurnishingCount(Motor: TSeatMotor): Integer;
    begin
        Result := RsBuf.rModel.rSpecs.rMotors[Motor.ID].rBrnCount
    end;

begin
    with mDBX do
    begin
        // ��纰 ���� ����, Ctrler����,
        InitMotorsCtrler(RsBuf.rModel.rTypes);

        for MtrIt := Low(TMotorOrd) to MtrOrdHi do
        begin
            MtrCnst := mCurModels.rConstraints[MtrIt];
            mMotors[MtrIt].mTotRepeatCount := GetBurnishingCount(mMotors[MtrIt]);
            mMotors[MtrIt].IsSLimitSet := mCurModelType.IsIMS;
            mMotors[MtrIt].SetMoveParam(8, 40);

        end;

        gLog.Panel('���� ���: Sldie:%s, Tilt:%s, Hgt:%s, Cush:%s, Swivel:%s', [BoolToStr(mMotors[tmSlide].Use, True), BoolToStr(mMotors[tmTilt].Use, True), BoolToStr(mMotors[tmHeight].Use, True), BoolToStr(mMotors[tmLegSupt].Use, True), BoolToStr(mMotors[tmSwivel].Use, True)]);
    end;
end;

function TTsWork.SlideMtrStopCond(Motor: TSeatMotor): Boolean;
begin
    Result := True;
{$IFDEF VIRTUALIO}
    Exit;
{$ENDIF}
end;

procedure TTsWork.LanDIChStatus(Ch: Integer; State: Boolean);
var
    Msg: string;
begin

    if not State then
    begin
        UpdateForm(tw_HIDE_MSG);
    end;

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
            if mDCPower <> nil then
            begin
                // mDIO.SetIO(DO_SPEC_MX5A, False);
                mDCPower.PowerOFF(True); // ���������
                gLog.Panel('��� ����!!');
            end;

            UpdateForm(tw_EMERGY);
        end
        else
        begin

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

        end;
    end;
    if Ch = mLDIChs.mReset then
    begin
        if State then
        begin
//            if not mDCPower.Power then
//                mDCPower.PowerON(True);
            //mLDOChs.Clear(mLIO, [mLDOChs.mConChkOK]);
            // mLIO.SetIO(mLDIChs.mReset, False);
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

    if Ch = mLDIChs.mWorkProduct then
    begin
        if State then
            UpdateForm(tw_PDT_LOADED);
    end;
end;

procedure TTsWork.ClearDO;
begin
    ClearElecDOs;
    ClearSpecDO;
end;

procedure TTsWork.SetSpecDO;
begin
    mDIO.SetIO(DO_IGN1, true);
    mDIO.SetIO(DO_CAN_100K, mCurModelType.IsHI or mCurModelType.IsRJ1);
    mDIO.SetIO(DO_CAN_500K, mCurModelType.IsJG1);
    mDIO.SetIO(DO_SPEC_CHCEK_PW, true);
    mDIO.SetIO(DO_JG1_CAR, mCurModelType.IsJG1);
    mDIO.SetIO(DO_RJ1_HI_CAR, mCurModelType.IsHI or mCurModelType.IsRJ1);
    mDIO.SetIO(DO_RJ1_HI_PASS_SW, mCurModelType.IsPsgPos and (mCurModelType.IsHI or mCurModelType.IsRJ1));
end;

procedure TTsWork.ClearElecDOs;
begin

end;

procedure TTsWork.ClearSpecDO;
begin
    mDIO.SetIO(DO_IGN1, false);
    mDIO.SetIO(DO_SPEC_CHCEK_PW, false);
    mDIO.SetIO(DO_TEST_PW, false);
    mDIO.SetIO(DO_CAN_100K, false);
    mDIO.SetIO(DO_CAN_500K, false);
    mDIO.SetIO(DO_RJ1_HI_CAR, false);
    mDIO.SetIO(DO_JG1_CAR, false);
    mDIO.SetIO(DO_RJ1_HI_PASS_SW, false);
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

    mWorkState := _WS_START;
    mSpecChkState := 1;
    mFuncState := 0;
    mOutPosState := 0;
    mInitState := 0;

    mdstRepeat := 0;
    mdstNgRepeat := 0;

    mIsDelivering := False;

    mIsPrnDone := False;
    mIsTestingNG := False;

    mNGRetry := 0;

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
    //mLDOChs.Clear(mLIO, [mLDOChs.mTestReady]);

    mDBX.InitData(True);

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

    SetMotorCurrPinsToZero;

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
    gLog.Panel('%s: mWorkState=%d', [Name, Ord(mWorkState)]);
    gLog.Panel('%s: mFuncState=%d, mLocalState=%d', [Name, mFuncState, mLocalState]);

    for It := Low(TMotorOrd) to MtrOrdHi do
        mMotors[It].ShowState;
end;

function TTsWork.IsRun: Boolean;
begin
    Result := (mWorkState > _WS_IDLE);
end;

function TTsWork.IsElecTestRun: Boolean;
begin
    Result := mElecState > 0;
end;

function TTsWork.IsTesting: Boolean;
begin
    Result := (_WS_IDLE < mWorkState) and (mWorkState <= _WS_END_OF_TEST);
end;

function TTsWork.IsErrorState: Boolean;
begin
    Result := (mWorkState >= _WS_ERROR);
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

    if not mDCPower.Power then
        mDCPower.PowerON();

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
    mIsDelivering := False;

    mLDOChs.Clear(mLIO, [mLDOChs.mOK, mLDOChs.mNOK]);
    ClearDO;

    //mDCPower.SetCurr(gSysEnv.rOP.rTest.rSpecCurr);

    // --------------------------------------------------------------------------------
    mWorkState := _WS_IDLE;
    mElecState := 0;
    mSpecChkState := 0;

    mDCPower.Clear;

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
                case mMtrOper.FSMMove([mMtrTilt, mMtrHeight], [mMtrSlide, mMtrLegSupt, mMtrSwivel]) of
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
    if UpperCase(mMainCon.ID) = CurModelType.MakeMainConID then
        Exit(True);

    Result := False;

    if not gConMan.AssignByID(CurModelType.MakeMainConID, mMainCon) then
    begin
        gLog.Error('���� �� ���� Ŀ���� ���� ����', []);
        SetError('���� �� ���� Ŀ���� ���� ����', '���� �� ����̳� Env������ ������ �ִ���  Ȯ�� �ϼ���');
        Exit;
    end;

//    if not gConMan.AssignByID(CurModelType.MakeSwConID, mSwCon) then
//    begin
//        gLog.Error('���� �� ����ġ Ŀ���� ���� ����', []);
//        SetError('���� �� ����ġ Ŀ���� ���� ����', '���� �� ����̳� Env������ ������ �ִ��� Ȯ�� �ϼ���');
//        Exit;
//    end;

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
    {
      if IsOn and (not mIsAutoMode) and (mSpecChkState = 0) and (not mIsSpecChkOK) then
      begin
      mSpecChkState := 1;
      end;
      }
end;

function TTsWork.MtrJogRunReq(MtrIdx, ChIdx: Integer; Dir: TMotorDir): Boolean;
begin
    gLog.Debug('MtrJog: SpecChkState:%d, SpecChkOk:%s', [mSpecChkState, BoolToStr(mIsSpecChkOK, True)]);

//    if not mIsSpecChkOK then
//    begin
//        Exit(False);
//    end;
{$IFDEF VIRTUALIO}
    Result := True;
{$ELSE}
    Result := (gSysEnv.rOP.rTest.rCurr * 0.9) <= mDCPower.Curr;
{$ENDIF}
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

function TTsWork.NeedLimitSetting: Boolean;
var
    It: TMotorOrd;
begin
    Result := False;

  // IMS �����̰� ����Ʈ ������ �ʿ��� ���
    if RsBuf.rModel.rTypes.IsIMS then
    begin
        Result := True;

    end;
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
        msStop: // �۵� ���� & ���� ���� ó�� (��ŷ ó���� Invoke���)
            begin
            end;

        msTestEnd: // ���� ����, ������ �Ǵ�
            begin

            end;

        msBurnishStart:
            begin

            end;
        msBurnishStop:
            begin

            end;

        msBurnishCycle:
            begin
                UpdateForm(tw_BURNISHING_CYCLE);
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
begin

    Result := 0;

    case mSpecChkState of
        0:
            ;
        1:
            begin
                UpdateForm(tw_SPEC_CHK_START);
                mDIO.SetIO(DO_SPEC_CHCEK_PW, true);
                SetSpecDO;

                mSpChkTC.Start(150 * 1000);
                Inc(mSpecChkState);

                gLog.Panel('%s: ��� ���� ���� ����: %0.1f(A)', [Name, gsysEnv.rOP.rTest.rSpecCurr]);
            end;
        2:
            begin
{$IFDEF VIRTUALLANIO}
                mIsSpecChkOK := True;
                mLIO.SetIO(mLDOChs.mTestReady, True);
                mSpecChkState := 0;
                UpdateForm(tw_SPEC_CHK_END);
                Exit(1);
{$ENDIF}
                // ���� ������ �������� 50%�����̸� ���� �ƴϸ� ��Ʈ �߻� (Ŀ���� ���� ���� ��..)
                if GetMainCurr <= (gsysEnv.rOP.rTest.rSpecCurr * 0.5) then
                begin
                    Inc(mSpecChkState);
                    mDIO.SetIO(DO_SPEC_CHCEK_PW, false);
{$IFDEF _USE_PWS_CURR}
                    gDCPower.Items[0].SetCurr(30);
{$ENDIF}
                end
                else
                begin
                    gLog.Panel('%s: ���� ���� 50% �̻� ���� Error(%.1f(A) > %.1f(A)', [Name, mAD.GetValue(AI_MAIN_CURR), (gsysEnv.rOP.rTest.rSpecCurr * 0.5)]);
                    SetError('��� üũ ���� �̻� ERROR', 'Ŀ���� ��Ʈ, ���� ü��, ���� �� ���� �ҷ� ���� �Ǵ� �ùٸ� ������� Ȯ�� �ϼ���.');
                    mIsSpecChkOK := False;
                    ClearSpecDO;

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
                mDelayTC.Start(1000);
                mDIO.SetIO(DO_TEST_PW, true);
            end;
        4:
            begin
                if not mDelayTC.IsTimeOut then
                    Exit;

                mIsSpecChkOK := True;

                mSpecChkState := 0;

                UpdateForm(tw_SPEC_CHK_END);

                Exit(1);

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
    MtrIt: TMotorORD;

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
                // ���� ���� üũ
                //if not CheckPowerStatus then
                //    Exit;

                if not mIsSpecChkOK then
                    Exit;
{$ENDIF}

                mMtrOper.Init([mMtrSlide, mMtrHeight, mMtrTilt, mMtrLegSupt, mMtrSwivel], [twBack, twForw, twBack, twBack, twBack]);
                mMtrOper.ClearFSM;
                mdstRepeat := 0;
                mFuncState := 0;
                mWorkState := _WS_DELETE_LIMIT;

                gLog.Panel('%s: ����Ʈ ���� ����', [Name]);

                mPeriodicCanData.SetIgn(true);
                mLIO.SetIO(mLDOChs.mTestReady, false);

                if mCurModelType.IsIMS then
                begin
                    mWorkState := _WS_DELETE_LIMIT;
                    gLog.Panel('%s: ����Ʈ ���� ����', [Name]);
                end
                else
                begin
                    mWorkState := _WS_ALIGN_LODING_POS;
                    gLog.Panel('%s: ���� �ε� ��ġ ���� ����', [Name]);
                end;
            end;

        _WS_DELETE_LIMIT:
            begin

                case mMtrSlide.FSMDeleteLimit(0) of
                    -1:
                        begin
                            gLog.panel('%s : ����Ʈ ���� ����, ���� ���� ����', [Name]);
                            mWorkState := _WS_ALIGN_LODING_POS;

                        end;
                    1:
                        begin
                            mWorkState := _WS_ALIGN_LODING_POS;
                            mIMSCtrler.EnableRCReq;
                            mDelayTC.Start(2000);
                            UpdateForm(tw_LIMIT_READED);

                            gLog.Panel('%s: ����Ʈ ���� �Ϸ�, ����Ʈ �ε� ��ġ ���� ����', [Name]);

                        end;

                end;

            end;

        _WS_ALIGN_LODING_POS:
            begin
                if not mDelayTC.IsTimeOut then
                    Exit;

                case FSMAlignMotor(pmtEach) of
                    -1:
                        begin
                            SetError(mMtrOper.CurMotor.mLstError, mMtrOper.CurMotor.mLstToDo);

                            gLog.Panel('%s : ���� ���� ����', [Name]);
                        end;
                    1:
                        begin
                            mFuncState := 0;
                            mWorkState := _WS_WAIT_WEIGHT_LOADING;
                            mLIO.SetIO(mLDOChs.mLoadReqWeight, true);
                            mDelayTC.Start(20000);

                            gLog.Panel('���� ���� �Ϸ�, ����Ʈ �ε� ���');

                        end;
                end;
            end;

        _WS_WAIT_WEIGHT_LOADING:
            begin
                if mDelayTC.IsTimeOut then
                begin
                    SetError('����Ʈ �ε� �ð� ���� ', '����Ʈ �ε� ������ Ȯ���� �ּ���');
                end
                else
                begin
                    if mLIO.IsIO(mLDIChs.mLoadDoneWeight) then
                    begin
                        mLIO.SetIO(mLDOChs.mLoadReqWeight, false);
                        mMtrOper.InitBurnishing([mMtrSlide, mMtrTilt, mMtrHeight, mMtrLegSupt, mMtrSwivel], [mMtrSlide.mTotRepeatCount, mMtrTilt.mTotRepeatCount, mMtrHeight.mTotRepeatCount, mMtrLegSupt.mTotRepeatCount, mMtrSwivel.mTotRepeatCount]);

                        if NeedLimitSetting then
                        begin
                            //IMS ���ʹ� ����Ʈ ����
                            mWorkState := _WS_SET_LIMIT_1;
                            mLmtState := 0;
                            gLog.Panel('%s: ����Ʈ �ε� �Ϸ�, ����Ʈ ���� ����', [Name]);

                        end
                        else
                        begin
                            mWorkState := _WS_BURNISHING;
                            gLog.Panel('%s: ����Ʈ �ε� �Ϸ�, ���Ͻ� ����', [Name]);

                        end;
                    end;

                end;

            end;

        _WS_BURNISHING:
            begin
                // �Ϲ� ���ʹ� ���Ͻ�
                case mMtrOper.FSMBurnishing(True) of
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
                            mWorkState := _WS_MOVE_TO_UNLOADING_POS;
                            mMtrOper.Init([mMtrSlide], [twBack]);
                            mLmtState := 0;
                            mDelayTC.Start(1000);
                        end;
                end;
            end;

        _WS_SET_LIMIT_1:
            begin
                if mLmtState = 0 then
                begin
                    // ����Ʈ ������ ���� �ʱ�ȭ
                    UpdateForm(tw_LIMIT_START);
                    mMtrOper.InitLimit([mMtrSlide, mMtrHeight, mMtrSwivel, mMtrTilt, mMtrLegSupt], [1, 1, 1, 1, 1]);
                    mMtrOper.ClearFSM;
                    mLmtState := 1;
                end;



                // FSMSetLimit �Ǵ� FSMSetLimitEx ���
                case mMtrOper.FSMSetLimit(false, 3) of
                    -1:
                        begin
                            SetError('����Ʈ ���� ����', '���� �� CAN ����� Ȯ���� �ּ���.');
                            gLog.Panel('����Ʈ ���� ����');
                        end;

                    1:
                        begin
                            UpdateForm(tw_LIMIT_DONE);
                            mWorkState := _WS_READ_LIMIT;

                            mLmtState := 0;
                        end;

                end;

                if mDelayTC.IsTimeOut(1000) then
                begin
                    UpdateForm(tw_LIMIT_READED);
                end;

            end;

        _WS_SET_LIMIT_2:
            begin
                if mLmtState = 0 then
                begin
                    // ����Ʈ ������ ���� �ʱ�ȭ
                    UpdateForm(tw_LIMIT_START);
                    mMtrOper.InitLimit([mMtrTilt, mMtrLegSupt], [1, 1]);
                    mMtrOper.ClearFSM;
                    mLmtState := 1;
                end;

                // FSMSetLimit �Ǵ� FSMSetLimitEx ���
                case mMtrOper.FSMSetLimit(false, 3) of
                    -1:
                        begin
                            SetError('����Ʈ ���� ����', '���� �� CAN ����� Ȯ���� �ּ���.');
                            gLog.Panel('����Ʈ ���� ����');
                        end;

                    1:
                        begin
                            UpdateForm(tw_LIMIT_DONE);

                            mWorkState := _WS_READ_LIMIT;
                            gLog.Panel('����Ʈ ���� ����');
                        end;

                end;

                if mDelayTC.IsTimeOut(1000) then
                begin
                    UpdateForm(tw_LIMIT_READED);
                end;

            end;

        _WS_READ_LIMIT:
            begin
                case mMtrSlide.FSMReadLimitStatus of
                    -1:
                        begin
                            gLog.Panel('����Ʈ ���� Ȯ�� ����, ���� �� CAN ������ Ȯ���ϼ���');
                            mWorkState := _WS_MOVE_TO_UNLOADING_POS;
                        end;
                    1:
                        begin
                            mWorkState := _WS_MOVE_TO_UNLOADING_POS;
                            mFuncState := 0;

                            mMtrOper.Init([mMtrSlide, mMtrHeight, mMtrTilt, mMtrLegSupt, mMtrSwivel], [twBack, twForw, twBack, twBack, twBack]);
                            mMtrOper.ClearFSM;
                            gLog.Panel('����Ʈ ���� Ȯ�� �Ϸ�, ���� ���� ����');
                        end;
                end;

            end;

        _WS_MOVE_TO_UNLOADING_POS:
            begin
                case FSMAlignMotor(pmtEach) of
                    -1:
                        begin
                            SetError(mMtrOper.CurMotor.mLstError, mMtrOper.CurMotor.mLstToDo);
                        end;
                    1:
                        begin
                            mWorkState := _WS_WAIT_UNLOADING_DONE;
                            mFuncState := 0;
                            mLIO.SetIO(mLDOChs.mUnLoadReqWeight, true);
                            mDelayTC.Start(20000);
                        end;
                end;
            end;

        _WS_WAIT_UNLOADING_DONE:
            begin
                if mDelayTC.IsTimeOut then
                    SetError('����Ʈ ��ε� �ð� ���� ', '����Ʈ �ε� ������ Ȯ���� �ּ���')
                else
                begin
                    if mLIO.IsIO(mLDIChs.mUnLoadDoneWeight) then
                    begin
                        mLIO.SetIO(mLDOChs.mUnLoadReqWeight, false);

                        gLog.Panel('%s: ����Ʈ ��ε� �Ϸ�, ECU ���� ��� ����', [Name]);

                        mDelayTC.Start(5000);


                        mWorkState := _WS_WAIT_ECU_SAVE_TIME;

                    end;

                end;

            end;

        _WS_WAIT_ECU_SAVE_TIME:
            begin
                if mDelayTC.IsTimeOut then
                begin
                    mWorkState := _WS_WAIT_ALL_TEST_END;


                end;

            end;



        _WS_WAIT_ALL_TEST_END:
            begin
                UpdateForm(tw_SAVE);

                mLIO.SetIO(mLDOChs.mOK, True);
                mLIO.SetIO(mLDOChs.mNOK, False);
                mLIO.SetIO(mLDOChs.mTestReady, False);

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

        _WS_ERROR:
            begin

                if mLstError <> '' then
                    gLog.Error('%s: Err �޽���: %s', [Name, mLstError]);
                gLog.Panel('%s: Err ���½�: %s', [Name, GetStateStr]);
                gLog.Panel('%s: Err ���½�: ���� ����:%f(V), ���� ����:%f(A), ���� ����: %f(A)', [Name, GetOutVolt, GetOutCurr, GetMainCurr]);

                StopMotors;
                ClearElecDOs;
                //mDCPower.SetCurr(1.0);

                mLIO.SetIO(mLDOChs.mAlarm, True);

                mWorkState := _WS_ERROR_IDLE;

                UpdateForm(tw_ERROR);
            end;

        _WS_ERROR_IDLE:
            ;
    else
        mLstError := '��� ���μ��� ����';
        mLstToDo := '���α׷��� �ٽ� �����ϼ���';
        gLog.Panel('%s: ������μ��� ���� %d', [Name, Ord(mWorkState)]);

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
    Result := inherited GetStateStr + Format(' mWorkState=%d, mSpecChkState=%d, mElecState=%d, mFuncState=%d', [Ord(mWorkState), mSpecChkState, mElecState, mFuncState]);
end;

function TTsWork.GetStationID: TStationID;
begin
    Result := TStationID(mDBX.Tag);
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
        // Pos('roDat', GetResultOrdName(PopDataORD[i])) > 0);
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
                if not mDCPower.Power then
                begin
                    mDCPower.PowerON();
                end;
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

function TTsWork.GetMotors(Mtr: TMotorOrd): TSeatMotor;
begin
    // TMotorOrd�� �̹� Ÿ�� �����ϹǷ� ���� üũ ���� ����
    if not Assigned(mMotors[Mtr]) then
    begin
        ShowMessage(Format('����[%d]�� �ʱ�ȭ���� ����', [Ord(Mtr)]));
        Result := nil;
        Exit;
    end;

    Result := mMotors[Mtr];
end;

function TTsWork.GetName: string;
begin
    Result := GetStationName(StationID);
end;

function TTsWork.GetMainCurr: Double;
begin
{$IFDEF _USE_PWS_CURR}
    Result := gDcPower.Items[0].MeasCurr;
    Exit;

{$ENDIF}
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

function TTsWork.IsAllMotorsAtLimit: Boolean;
var
    It: TMotorOrd;
begin
    Result := True;

    for It := Low(TMotorOrd) to MtrOrdHi do
    begin
        if mMotors[It].Use and mMotors[It].IsSLimitSet then
        begin
            if mMotors[It].LimitStatus <> lsDone then
            begin
                Result := False;
                Exit;
            end;
        end;
    end;
end;

function TTsWork.IsAuto: Boolean;
begin
    Result := mLIO.IsIO(mLDIChs.mAutoMode);
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

