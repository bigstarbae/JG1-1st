﻿unit TsWorkUnit;
{$I myDefine.inc}

interface

uses
    Windows, Sysutils, Graphics, Classes, FaGraphEx, ComCtrls, DataUnit, siAPD,
    TimeCount, DataBox, PopWork, myUtils, ComUnit, KiiMessages, TimeAccumulator,
    PowerSupplyUnit, ModelUnit, TimeChecker, BaseTsWork, BaseDIO, BaseAD, BaseAO,
    BaseCAN, ModelType, IODef, ScannerUnit, DIOChs, Global, SysEnv, SeatType,
    SeatMotor, SeatMotorType, SeatMoveCtrler, SeatIMSCtrler, MotorJogOperator,
    IntervalCaller, SeatConnector, AsyncCalls, Range, ECUVer, ECUVerList,
    BuckleTester, StateDefineUnit, ResistTester, DTCReader, SeatMtrGrpExtender,
    DataUnitOrd, HVTester, HVSimulCtrler, HVCanCtrler, SyncObjs, PeriodicCanData;

const
    MAX_LDIST_COUNT = 2;
    LDIST_IDX_ST01 = 0;
    LDIST_IDX_ST02 = 1;

type
    TCtrlerType = (ctSimul, ctDIO, ctCAN, ctLIN);

    TPwrMtrsMoveType = (pmtEach, pmtGroup, pmtSameTime, pmtInterval);
    // 개별, 그룹별, 동시, 시간차

    TTsWork = class(TBaseTsWork)
    private
        function MtrStopByDPSensor(Motor: TSeatMotor): Boolean;
        function GetConnectors(Idx: Integer): TBaseSeatConnector;
        function GetConCount: Integer;
        function BeforeIOSet(DIO: TBaseDIO; Ch: Integer; Value: Boolean): Boolean;
        function FSMWaitForWeightLoadDone: Integer;

        procedure FreeGrpHelpers;
        function FSMWaitForWeightUnLoadDone: Integer;
        function FSMTestMemory: Integer;
        function FSMTestVentSensor: integer;

    protected
        mDBX: TDataBox;

        mNextTsWork: TTsWork; // 옆 공정

        // ----- 상태 머신 변수: 레거시인 XXXProc는 점진적 XXXState로 변경 필요
        mWorkState: TWorkState;
        mElecState: TElecState;
        mMemTestState: TMemTestState;

        mLocalState,

        // Sub FSM 함수용
        mInitState, mFuncState, mDTCState, // 모터 초기위치 정렬등의 함수에서 사용.
        mOutPosState, // 납품 위치용
        mSpecChkState, mPopState, mVentSensorState: Integer;

        mLimitChkState: Integer;

        mJogMvState: Integer;
        mJogMtrIdx: TMotorOrd;

        mSubThLoop: Boolean; // ASyncCalls용 스레드 Flag

        // ------------------------------------------------------
        // --------------------------------------------------------------------
        // DAQ Dev etc..
        mDevCom: TDevCom; // 진동 측정기용 Comport

        mRetry: integer;

        // DAQ Dev etc..

        mLIO, mDIO: TBaseDIO; // BoardIO, gDIO에 종속되지 않고 TTsWork공정 마다
        mAD: TBaseAD;
        mAO: TBaseAO;
        mAT: TBaseAD;
        mCAN: TBaseCAN;

        // 자체 참조 취득
        mDCPower: TDcPower; // TTsWr
        mPop: TPopSystem;

        mRetryCount: integer;

        // -------------------------------------------------------------------
        // 모델 정보
        mOldMtrModelType, // 모터 컨트롤러 이전 모델 타입
        mPreModelType, mCurModelType: TModelType;
        mCurModels: PModels;
        mMdlExData: TMdlExData;
        mMdlNo: Integer;

        // --------------------------------------------------------------------
        // SeatMotor 관련

        mMainCon: TSeatConnector;
        mExtCon: TSeatConnector;
        mMatCon: TSeatConnector;
        mConnectors: TSeatConnectorList;

        mMoveCtrler: array[TMotorOrd] of TDIODirectMoveCtrler; // Factory 전환 검토
        mUDSMoveCtrler: TCANUDSMoveCtrler; // 모터들이 공유
        mIMSCtrler: TCANIMSCtrler;  // 또는 TBaseIMSCtrler
        mDIOMemCtrler: TDIOMemoryCtrler;
        mIMSSimCtrler: TSimulIMSCtrler;

        mCurMotor: TSeatMotor;
        mMotors: array[TMotorOrd] of TSeatMotor;
        mMtrSlide, mMtrTilt, mMtrHeight, mMtrLegSupt, mMtrSwivel: TSeatMotor;
        mMtrOper: TSeatMotorOper;

        // --------------------------------------------------------------------                   a

        // 정렬시 : 현 방향과 반대 방향인 경우의 모터만을 담는 버퍼 용도
        mAlignMotors: array[TMotorOrd] of TSeatMotor;
        mAlignMtrDirs: array[TMotorOrd] of TMotorWayOrd;
        mAlignMtrCount: Integer;

        mGrpExt: array[TMotorOrd] of TSeatMtrGrpExtender;

        mFlag: Boolean; // 공용 Flag

        // ---------------------------------------------------------------
        // 사양 체크

        mConStatus: Boolean; // 커넥터 접속 상태
        mIsSpecChkOK: Boolean; // 커넥터 접속 및 사양체크 만족
        mIsCanRcvTimeOut: Boolean;
        mSkipConChk: Boolean; // 커넥터 체크 수시 감시 모드 해제
        mStartSpecChk: Boolean;

        // LAN DI
        mLDIChs: TLDIChs;
        // LAN DO
        mLDOChs: TLDOChs;

        mDIEventer: TDIEventer;

        mMtrJogDIChs, mMtrJogLDIChs: TMotorJogOperator;

        mConUnboundTC, mDelayTC, mTC, mLocalTC, mSpChkTC, mSwTC, // BlueLink Chk
        mMtrRunTC, mLmtTc1: TTimeChecker;
        mSpecChkTC: TTimeChecker;
        mCanRcvTC: TTimeChecker;
        mLimtCheckTC: TTimeChecker;

        mFilter: TAPD3;
        mTmpTime: Double;

        // ----- 모터제어에 필요한 변수들
        mdstRepeat: Integer; // 함수내에서 알아서 함으로 다른데 사용금지
        // mdstWay, mdstVtWay: TMotorWayOrd;

        mdstMemRepeat: Integer; // 메모리 불량나면 반복 동작 횟수.
        mdstNgRepeat: Integer;
        mdstFlag: BYTE;
        mdstResult: Integer;
        mdstStopTime: Double; // 2013.07.04
        // -----

        // -----

        // Tester들 추가
        mBuckTester: TBuckleTester;     // 버클 검사
        mAPTTester: TResistTester;      // 앙카피티 저항 검사
        mODSTester: TResistTester;      // ODS 저항 검사

        // ECU 정보 읽기
        mECUVer: TCanECUVer;        // CAN 통신으로 ECU 버전 읽기
        mECUVerList: TECUVerList;   // ECU 버전 리스트 관리.
        mEVItem: PECUVerItem;

        mOldCurr: Double;

        mCycleTime: Double;

        mIsModelLoaded, mIsTesting: Boolean;
        mIsDelivering: Boolean;

        mIsPrnDone: Boolean; // 인쇄 완료
        mIsTestingNG: Boolean; // 측정 중 NG, 즉시 NG처리 Flag

        mIsRearDPos: Boolean; // Slide 후방 납품 위치 센서 받음 유무

        mJogDir: TMotorDir;

        mPreDIStr: string; // 임시

        mOldEndPosChk: Boolean;

        mSensorState: array[TMotorDir, 0..1] of Boolean;

        mIAsyncCall: IAsyncCall;
        mMMA: TMinMaxAvg;

        mNGRetry: Integer;

        mCANWDebug, mCANRDebug: Boolean;

        mIsConnected: Boolean;

        // ─── HV 관련 ───────────────────────────
        mHVTester: THVTester;
        mCurHVTest: THVTest;

        mHVSimCtrlers: array[THVDevType] of THVSimulCtrler;
        mHVCANCtrlers: array[THVDevType] of THVCANCtrler;

        mHVRetryCnt: integer;

        // ─── ??? ───────────────────────────
        mPeriodicCanData: TPeriodicCanData;

        mCS: TCriticalSection;

        function FSMTestElecPart: Integer;

        procedure Start; override;
        procedure Stop(IsForce: Boolean = False); override;
        procedure WorkProcess(); override;

        procedure SaveResult();

        procedure SetUsrLog(const szFmt: string; const Args: array of const; IsFile: Boolean = False);

        function FSMDTCReader: Integer;

        // ─── HV 관련 ───────────────────────────

        procedure InitHVTester;
        procedure InitHVCanSig(MdlType: TModelType);
        procedure CreateHVCtrler;
        procedure CreateHVTester;
        procedure HVTestStatus(HVTest: THVTest; TestStatus: THVTestStatus);

        procedure InitHVCtrler(MdlType: TModelType);


        // POP
        function GetPopDatas(): string;
        function PopWorkProcess: Boolean;
        procedure OnRcvedPopData(Sender: TObject; ACommand: Integer);
        function AnalysysRcvDatas(var RcvData, Value: string): Boolean;

        // Event 처리
        procedure UpdateForm(AStatus: TTsModeORD);

        // 작동
        procedure RunJogMode;
        procedure LanDIChStatus(Ch: Integer; State: Boolean);
        procedure CheckLimit;

        // SPEC 체크  및 초기화
        function AssignConnector: Boolean;
        function IsSpecChecking: Boolean;
        procedure ShowSpecChkMsg;

        procedure ClearDO;
        procedure SetSpecDO;
        procedure ClearSpecDO;
        procedure ClearElecDOs;

        procedure CreateConnectors;
        procedure FreeConnectors;
        procedure FreeGrpExtenders;

        // 모터 검사  -------------------------------------------------------------------
        // 모터 생성 및 제거
        procedure CreateMotors;
        procedure FreeMotors;
        procedure InitMotors;
        procedure StopMotors;

        procedure SeatMotorTestStatus(Motor: TSeatMotor; TestStatus: TSeatMotorTestStatus);

        function FSMCheckSpec: Integer;
        // 부하 로딩 및 언로딩 위치로 보내기

        function FSMAlignMotor(PwrMoveType: TPwrMtrsMoveType; IsEndPosChk: Boolean = True): Integer;
        function FSMMoveToOutPos: Integer;
        function FSMPushOnOff(Ch, Delay: Integer): Integer;
        function FSMCheck4MotorMove(Dir: TMotorDir): Integer;

        function GetMotors(Mtr: TMotorOrd): TSeatMotor;

        function GetStationID: TStationID;
        function GetName: string; override;
        function GetRsBuf: PResult;
        procedure SetMainCurrZero; override;

        function HgtMtrStopCond(Motor: TSeatMotor): boolean;
        function SlideMtrStopCond(Motor: TSeatMotor): Boolean;
        procedure PollingScanner;

        function MtrJogRunReq(MtrIdx, ChIdx: Integer; Dir: TMotorDir): Boolean;
        procedure MtrJogChStatus(MtrIdx, ChIdx: Integer; IsON: Boolean);

        function FSMJogMove(Dir: TMotorDir): Integer;

        procedure AsyncPushOnOff(Ch, Delay: Integer; PreDelay: Integer = 0);
        function NeedsRetest(Motor: TSeatMotor): Boolean;

        procedure ProcessMotorData(Motor: TSeatMotor);

        procedure CanTrans(CANFrame: TCANFrame; IsSend: Boolean);

    public
        mMsgs, mToDos: array of string;
        mIsAlarmMsg: Boolean;
        mMemTestMoveT: double;
        mDTCReader: TDTCReader;

        constructor Create(StationID: TStationID; AD: TBaseAD; DIO: TBaseDIO; AO: TBaseAO; AT: TBaseAD; CAN: TBaseCAN; DevCom: TDevCom);
        destructor Destroy; override;

        procedure CreateGrpExtenders(Grps: array of TFaGraphEx);

        //
        procedure Initial(IsLoad: Boolean); override;
        procedure CheckModelChange(ID: Integer; ATypeBits, Mask: DWORD); override;

        //
        procedure InitMotorsCtrler(MdlType: TModelType);

        // 커넥터 결합 여부 체크 시작용
        procedure StartDevState4SpecChk;

        function IsStartChOn: Boolean; override;
        function IsRun: Boolean; override;
        function IsErrorState: Boolean;
        function IsTesting: Boolean;
        function IsPopLinkMode: Boolean;
        function IsStableState: Boolean; // ex> 옆 공정에서 블록킹(SaveData등 )작업 하기 전 사용하자

        function IsElecTestRun: Boolean;
        function IsAuto(): Boolean;

        function IsSpecChkOK: Boolean; override;

        procedure CanRead(Sender: TObject);

        // 외부 장치 및 Ch 설정
        procedure SetLanDIChs(StartAbsCh: Integer);
        procedure SetLanDOChs(StartAbsCh: Integer);
        procedure InitJogChs;

        procedure LinkNext(TsWork: TTsWork);

        function GetOutVolt: Double;
        function GetOutCurr: Double;

        function GetPowerEnable: Boolean;

        // 실시간 DAQ 값 읽기
        function GetMainCurr: Double;
        function GetMotorCurr(Motor: TMotorOrd): Double;
        function GetDistance1: double;
        function GetSHVUCurr: double;
        function GetNoise: double;
        function GetResistor: Single;

        procedure SetMotorCurrPinsToZero;

        procedure SetError(ErrorMsg, ErrorToDo: string);
        procedure ShowError(ErrorMsg, ErrorToDo: string);
        procedure ShowMsg(Msg, ToDo: string); overload;
        procedure ShowMsg(Msgs, ToDos: array of string; IsAlarm: Boolean = False); overload;

        // 상태 보기
        procedure ShowProcState; override;
        procedure ShowPopData;

        function GetStateStr(IsSimple: Boolean = False): string; override;
        procedure Write(TV: TTreeView); override;

        procedure SelfTest;

        //
        function GetStationIDStr: string;

        function FSMCheckLimit: integer;
        // --------------------------------
        property StationID: TStationID read GetStationID;
        property DBX: TDataBox read mDBX;

        property DevCom: TDevCom read mDevCom;

        property AD: TBaseAD read mAD;
        property DIO: TBaseDIO read mDIO;
        property CAN: TBaseCAN read mCAN;

        property MainCon: TSeatConnector read mMainCon;
        property ExtCon: TSeatConnector read mExtCon;
        property MatCon: TSeatConnector read mMatCon;

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
        property BuckTester: TBuckleTester read mBuckTester;
        property ECUVer: TCanECUVer read mECUVer;
        property ECUVerList: TECUVerList read mECUVerList;

        property CurHVTest: THVTest read mCurHVTest;
        property HVTester: THVTester read mHVTester;
    end;

function GetConnectedSt: TTsWork; // 전극 접속 완료된 공정, 2개가 모두 접속되었다면 첫번째 공정만 리턴

var
    gTsPwrWorks: array[0..ord(High(TStationID))] of TTsWork;

implementation

uses
    Forms, Dialogs, Log, LanIoUnit, LOTNO, Math, Rs232, Work, DataUnitHelper,
    TypInfo, UDSDef, ClipBrd, LangTran, MsgForm, UDSCarConfig, CANFDPreset;

const
    _CAN_TIME_OUT = 0.3; // 일반적인 응답대기
    _RELAY_AFTER_RUN_DELAY = 250;
    _MEM_DELAY = 1.0;

function GetConnectedSt: TTsWork;
var
    i: Integer;
begin
    for i := 0 to ord(High(TStationID)) do
    begin
        if gTsWorks[i].IsSpecChkOK then
        begin
            Exit(gTsPwrWorks[i]);
        end;
    end;

    Result := nil;
end;

{ TTsWork }

constructor TTsWork.Create(StationID: TStationID; AD: TBaseAD; DIO: TBaseDIO; AO: TBaseAO; AT: TBaseAD; CAN: TBaseCAN; DevCom: TDevCom);
var
    i: Integer;
begin
    inherited Create;

    mCS := TCriticalSection.Create;

    mDBX := TDataBox.Create(ord(StationID));
    mStationID := ord(StationID);

    mCurModels := gModels.GetPModels(1);

    mWorkState := _WS_IDLE;

    mAD := AD;
    mDIO := DIO;
    mDIO.OnConfirmBeforeIOSet := BeforeIOSet;
    mLIO := gLanDIO;
    mCAN := CAN;
    mAO := AO;
    mAT := AT;

    mCAN.UseFD := True;
    mCAN.Open(0, 500);

    mDevCom := DevCom;

    mCAN.OnRead.Add(CanRead);
    mCAN.OnTrans := CanTrans;

    mDCPower := gDCPower.Items[ord(StationID)];
    mPop := gPopsys.Items[ord(StationID)];
    mPop.OnRcvData := OnRcvedPopData;

    mFilter := TAPD3.Create;
    mTmpTime := 0;

    CreateConnectors;
    CreateMotors;
    CreateHVTester;

    InitJogChs;

    // 버클 테스터 생성
    mBuckTester := TBuckleTester.Create(mDIO, mAD, -1, -1);
    mAPTTester := TResistTester.Create(0, mAT);
    mODSTester := TResistTester.Create(0, mAT);

    mSubThLoop := True;
    mIsCanRcvTimeOut := True;

    // HI 운전석 기준
    mDTCReader := TDTCReader.Create(mCAN, $706, $726);
    mECUVer := TCanECUVer.Create(mCAN, $706, $726, [evtPartNo, evtOemSW, evtOemHW]);

    mECUVerList := TECUVerList.Create;

    if not mECUVerList.Load(GetEnvPath('ECUVerList.ini')) then
    begin
        gLog.ERROR('ECUVerList.ini 파일 읽기 실패', []);
        // ShowError('ECUVerList.ini 파일이 Env 폴더 경로에 없습니다', 'ECU Ver 목록을 설정에서 재작성 하세요');
    end;

    mPeriodicCanData := TPeriodicCanData.Create(CAN, mCurModelType.GetCarType);

    mLDOChs.Clear(mLIO, []);

    gLog.Panel('%s: Create', [Name]);
end;

procedure TTsWork.CreateConnectors;
begin
    mConnectors := TSeatConnectorList.Create;
    mMainCon := TSeatConnector.Create(mAD, AI_MAIN_CON_VOLT_START);
    mExtCon := TSeatConnector.Create(mAD, AI_B_EXT_CON_VOLT_START);
    mMatCon := TSeatConnector.Create(mAD, AI_MAT_CON_VOLT_START);

    mMainCon.Name := 'MAIN';
    mExtCon.Name := 'BACK.EXT';
    mMatCon.Name := 'HTR.MAT';

    mConnectors.Add(mMainCon);
    mConnectors.Add(mExtCon);
    mConnectors.Add(mMatCon);
end;

destructor TTsWork.Destroy;
var
    i: Integer;
    DevType: THVDevType;
begin

    mSubThLoop := False;

    mDCPower.SetCurr(gSysEnv.rOP.rTest.rCurr, True);
    mDCPower.SetVolt(0, True);

    for i := 0 to mDIO.WChCount - 1 do
    begin
        mDIO.SetIO(_DIO_OUT_START + i, False);
    end;

    gLog.Panel('%s: Destroy', [Name]); // Name에서 mDBX참조하므로 위치 고정!

    FreeAndNil(mDBX);

    FreeMotors;
    FreeConnectors;

    FreeGrpExtenders;

    if Assigned(mPop) then
        mPop.OnRcvData := nil;

    mCAN.OnRead.Remove(CanRead);

    FreeAndNil(mFilter);
    FreeAndNil(mBuckTester);
    FreeAndNil(mAPTTester);
    FreeAndNil(mODSTester);
    FreeAndNil(mDTCReader);
    FreeAndNil(mECUVer);
    FreeAndNil(mECUVerList);
    FreeAndNil(mHVTester);

    FreeAndNil(mDIOMemCtrler);
    FreeAndNil(mIMSSimCtrler);

    for DevType := Low(THVDevType) to High(THVDevType) do
    begin
        if Assigned(mHVSimCtrlers[DevType]) then
            FreeAndNil(mHVSimCtrlers[DevType]);
    end;

    for DevType := Low(THVDevType) to High(THVDevType) do
    begin
        if Assigned(mHVCANCtrlers[DevType]) then
            FreeAndNil(mHVCANCtrlers[DevType]);
    end;

    FreeAndNil(mCS);
    FreeAndNil(mPeriodicCanData);

    inherited;
end;

procedure TTsWork.PollingScanner;
begin

end;

function TTsWork.BeforeIOSet(DIO: TBaseDIO; Ch: Integer; Value: Boolean): Boolean;
begin
    Result := True;

end;

procedure TTsWork.CanRead(Sender: TObject); // 수신되는 Can 패킷이 있으면 주기 송신
var
    PosState: Byte;
begin

    mCanRcvTC.Start(1000);

    with Sender as TBaseCan do
    begin
        case ID of
            $3ED:   // RL
                begin
                end;
            $3EE: // RR
                begin
                end;

            $42C:   // RL 폴딩/언폴딩, 워크인 상태(?)
                begin
                end;
            $42D:    // RR 폴딩/언폴딩, 워크인 상태(?)
                begin
                end;
        end;

        WriteWFrames;
    end;
end;

procedure TTsWork.CanTrans(CANFrame: TCANFrame; IsSend: Boolean);
begin
    if not IsSend then
    begin
        if CANFrame.Compare(0, [$03, $7F, $2F], 3) then
        begin
            gLog.Error('%s: ECU 오류 수신: %s', [Name, CANFrame.ToStr]);
        end;
    end;

    if IsSend and mCANWDebug and gSysEnv.rCanIDFilter.IsWIDExists(CANFrame.mID) then
    begin
        if CANFrame.mLen > 8 then
        begin
            gLog.DebugWithMultiLine('%s SEND: %s:%s%s', [mCAN.Name, IntToHex(CANFrame.mID, 3), sLineBreak, CANFrame.ToHexGridStr]);
        end
        else
        begin
            gLog.Debug('%s SEND: %s', [mCAN.Name, CANFrame.ToStr])
        end;
    end
    else if not IsSend and mCANRDebug and gSysEnv.rCanIDFilter.IsRIDExists(CANFrame.mID) then
    begin
        if CANFrame.mLen > 8 then
        begin
            gLog.DebugWithMultiLine('%s RECV: %s:%s%s', [mCAN.Name, IntToHex(CANFrame.mID, 3), sLineBreak, CANFrame.ToHexGridStr]);
        end
        else
        begin
            gLog.Debug('%s RECV: %s', [mCAN.Name, CANFrame.ToStr]);
        end
    end;
end;

procedure TTsWork.CheckLimit;
begin

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

        // 모델 타입에 따른 커넥터 파일 변경
        case mCurModelType.GetCarType of
            ctJG1:
                begin
                    ConnectorFileName := 'JG1_Connector.json';
                    mCAN.UseFD := true;
                    mCAN.Preset.FromStr(FD_S_POINT_80_PRESET_1);
                    mCAN.Open(0, 500);
                end;
            ctRJ1:
                begin
                    ConnectorFileName := 'RJ1_Connector.json';
                    mCAN.UseFD := true;
                    mCAN.Preset.FromStr(CLASSIC_S_POINT_80_1_PRESET);
                    mCAN.Open(0, 500);
                end;
            ctHI:
                begin
                    ConnectorFileName := 'HI_Connector.json';
                    mCAN.UseFD := true;
                    mCAN.Preset.FromStr(CLASSIC_S_POINT_80_1_PRESET);
                    mCAN.Open(0, 100);
                end;
        end;

        // 해당 모델의 커넥터 파일 로드
        if not gConMan.Load(GetEnvPath(ConnectorFileName)) then
        begin
            gLog.Error('커넥터 정보 파일:%s 열기 실패', [ConnectorFileName]);
            SetError(Format('커넥터 정보 파일 %s 열기 실패', [ConnectorFileName]), Format('Env폴더내 %s 파일이 있는지 확인하세요', [ConnectorFileName]));
            Exit;
        end;

        gLog.Panel('%s: 커넥터 파일 로드 성공: %s', [Name, ConnectorFileName]);

        MdlNo := gModels.FindModel(mCurModelType, Mask);
        if MdlNo > 0 then
        begin
            gLog.Panel('%s: 공정 MODEL %d -> %d(0x%X)', [Name, gModels.GetModelNo(StationID), MdlNo, ATypeBits]);
            mCurModels := gModels.GetPModels(MdlNo);

            gModels.SelectModel(StationID, MdlNo); // 모델 No 설정
            mDBX.SetModel(gModels.CurrentModel(StationID)); // 현 공정에 모델 설정
            RsBuf.rModel.rTypes := mCurModelType; // 모델사양은 공정별로 다르니 별도로 설정, 커넥터 체결확인에 모델참조를 위해 설정해야 함.

            AssignConnector;

            mIsModelChange := True;

            if not IsRun then
                mLIO.SetIO(mLDOChs.mTestReady, False);
            // 계속 ON되는 경우 방지위해 모델 변경시 OFF처리 : 검증 필요

            SendToForm(gUsrMsg, SYS_MODEL, mDBX.Tag); // UI 적용

            //Initial(True);

            gLog.Panel('%s: MODEL : %s', [Name, RsBuf.rModel.rTypes.ToStr()]);
        end
        else
        begin
            mIsModelChange := False;
            gModels.SelectModel(StationID, -1);
            gLog.Panel('%s: 공정 해당 MODEL 없음(0x%X & 0x%X(Mask) = 0x%X)', [Name, ATypeBits, Mask, Mask and ATypeBits]);
        end;

    end;
end;

procedure TTsWork.SetLanDIChs(StartAbsCh: Integer);
begin
    mLDIChs.Init(StartAbsCh);

    with mLDIChs do
    begin
        mDIEventer.Init([mAutoMode, mPopLinkMode, mEmerStop], LanDIChStatus);
    end;
end;

procedure TTsWork.SetLanDOChs(StartAbsCh: Integer);
begin
    mLDOChs.Init(StartAbsCh);
end;

procedure TTsWork.SetMainCurrZero;
begin
    inherited;
  // 메인 전류를 0으로 설정하는 로직
    if Assigned(mAD) then
    begin
        mAD.SetZeros(AI_MAIN_CURR, AI_MAIN_CURR);
        gLog.Debug('%s: 메인 전류 핀 ZERO', [Name]);
    end;

    // 또는 이미 있는 메서드 호출
    // SetMotorCurrPinsToZero;  // 이미 구현된 메서드가 있다면

end;

procedure TTsWork.SetMotorCurrPinsToZero;
begin
    //mAD.SetZeros(AI_MTR_CURR_START, AI_MTR_CURR_START + MAX_SW_PIN_COUNT - 1);

    gLog.Debug('%s: 커넥터 전류 핀 ZERO', [Name]);
end;

procedure TTsWork.InitJogChs;
begin
    mMtrJogDIChs.Init(DI_SLIDE_MTR_CW, [mMtrSlide, mMtrHeight, mMtrTilt, mMtrLegSupt, mMtrSwivel], MtrJogChStatus);
    mMtrJogLDIChs.Init(mLDIChs.mSlideFw, [mMtrSlide, mMtrTilt, mMtrHeight, mMtrLegSupt, mMtrSwivel], MtrJogChStatus);

    mMtrJogDIChs.OnJogRunReq := MtrJogRunReq;
    mMtrJogLDIChs.OnJogRunReq := MtrJogRunReq;
end;

procedure TTsWork.CreateMotors;
var
    It: TMotorOrd;
begin
    // -----------------------------
//    mMoveCtrler[tmSlide] := TDIODirectMoveCtrler.Create(mExtCon, pspSlide);
//    mMoveCtrler[tmTilt] := TDIODirectMoveCtrler.Create(mExtCon, pspTilt);
//    mMoveCtrler[tmHeight] := TDIODirectMoveCtrler.Create(mExtCon, pspHeight);
//    mMoveCtrler[tmCushExt] := TDIODirectMoveCtrler.Create(mExtCon, pspCushExt);

    mUDSMoveCtrler := TCANUDSMoveCtrler.Create(mCAN, _UDS_MSG_2GEN_TAGET_PSM_ID, $7AB);

    mMtrSlide := TSeatMotor.Create(tmSlide, mUDSMoveCtrler, mAD, [AI_MOTOR_CURR, AI_MOTOR_CURR, AI_NOISE]);
    mMtrTilt := TSeatMotor.Create(tmTilt, mUDSMoveCtrler, mAD, [AI_MOTOR_CURR, AI_MOTOR_CURR, AI_NOISE]);
    mMtrHeight := TSeatMotor.Create(tmHeight, mUDSMoveCtrler, mAD, [AI_MOTOR_CURR, AI_MOTOR_CURR, AI_NOISE]);
    mMtrLegSupt := TSeatMotor.Create(tmLegSupt, mUDSMoveCtrler, mAD, [AI_MOTOR_CURR, AI_MOTOR_CURR, AI_NOISE]);
    mMtrSwivel := TSeatMotor.Create(tmSwivel, mUDSMoveCtrler, mAD, [AI_MOTOR_CURR, AI_MOTOR_CURR, AI_NOISE]);

    mIMSCtrler := TCANIMSCtrler.Create(mCAN, _UDS_MSG_2GEN_TAGET_PSM_ID, _UDS_MSG_2GEN_RESP_PSM_ID, $12A3);
    mDIOMemCtrler := TDIOMemoryCtrler.Create(mCAN, mDIO, DO_IMS_SET, DO_IMS_SW1, DO_IMS_SW2, _UDS_MSG_2GEN_TAGET_PSM_ID, _UDS_MSG_2GEN_RESP_PSM_ID, $12A3);
    mIMSSimCtrler := TSimulIMSCtrler.Create(mCAN);

    mMtrOper := TSeatMotorOper.Create(@mLstError, @mLstToDo);

    mMtrSlide.Name := Name + ' ' + mMtrSlide.Name;
    mMtrTilt.Name := Name + ' ' + mMtrTilt.Name;
    mMtrHeight.Name := Name + ' ' + mMtrHeight.Name;
    mMtrLegSupt.Name := Name + ' ' + mMtrLegSupt.Name;
    mMtrSwivel.Name := Name + ' ' + mMtrSwivel.Name;

    mMotors[tmSlide] := mMtrSlide;
    mMotors[tmTilt] := mMtrTilt;
    mMotors[tmHeight] := mMtrHeight;
    mMotors[tmLegSupt] := mMtrLegSupt;
    mMotors[tmSwivel] := mMtrSwivel;

    for It := Low(TMotorOrd) to MtrOrdHi do
    begin
        mMotors[It].OnTestStatus := SeatMotorTestStatus;
        mMotors[It].MoveCtrler := mUDSMoveCtrler;
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
        FreeAndNil(mGrpExt[It]);
    end;

end;

procedure TTsWork.CreateGrpExtenders(Grps: array of TFaGraphEx);
var
    It: TMotorOrd;
    i: Integer;
begin
    i := 0;
    for It := Low(TMotorOrd) to MtrOrdHi do
    begin
        gLog.Panel('GrpExt[%s] = Grps[%d] 연결', [GetMotorName(It), i]);
        mGrpExt[It] := TSeatMtrGrpExtender.Create(Grps[i]);
        Inc(i);
    end;
end;

procedure TTsWork.CreateHVCtrler;
begin
    mHVSimCtrlers[hvdHeatDrv] := THVSimulCtrler.Create(3, 1);
    mHVSimCtrlers[hvdVentDrv] := THVSimulCtrler.Create(1.5);
    mHVSimCtrlers[hvdHeatPsg] := THVSimulCtrler.Create(3, 1);
    mHVSimCtrlers[hvdVentPsg] := THVSimulCtrler.Create(1.5);

    // Remote HV Ctrl 사용시 활성
    mHVCANCtrlers[hvdHeatDrv] := THVCmdTypeCanCtrler.Create(mCAN, TCANSignal.Create($08B, 2, 4, 4), TCANSignal.Create($140, 4, 5, 3), mAD, AI_SHVU1);
    mHVCANCtrlers[hvdVentDrv] := THVCmdTypeCanCtrler.Create(mCAN, TCANSignal.Create($08B, 2, 4, 4), TCANSignal.Create($140, 4, 2, 3), mAD, AI_SHVU1);
    mHVCANCtrlers[hvdHeatPsg] := THVCmdTypeCanCtrler.Create(mCAN, TCANSignal.Create($08B, 2, 0, 4), TCANSignal.Create($14C, 3, 3, 4), mAD, AI_SHVU1);
    mHVCANCtrlers[hvdVentPsg] := THVCmdTypeCanCtrler.Create(mCAN, TCANSignal.Create($08B, 2, 0, 4), TCANSignal.Create($14C, 3, 3, 4), mAD, AI_SHVU1);

    mHVCANCtrlers[hvdHeatDrv].Name := 'HTR Drv Ctrler';
    mHVCANCtrlers[hvdVentDrv].Name := 'VNT Drv Ctrler';
    mHVCANCtrlers[hvdHeatPsg].Name := 'HTR Psg Ctrler';
    mHVCANCtrlers[hvdVentPsg].Name := 'VNT Psg Ctrler';
end;

procedure TTsWork.CreateHVTester;
begin
    mHVTester := THVTester.Create(3, 3, True);

    mHVTester.OnStatus := HVTestStatus;
    mHVTester.IsSeqTest := true;

    CreateHVCtrler;
    InitHVCtrler(RsBuf.rModel.rTypes);

end;

procedure TTsWork.FreeGrpExtenders;
var
    It: TMotorOrd;
begin
    for It := Low(TMotorOrd) to MtrOrdHi do
    begin
        FreeAndNil(mGrpExt[It]);
    end;

end;

procedure TTsWork.FreeMotors;
var
    It: TMotorOrd;
begin
    for It := Low(TMotorOrd) to High(TMotorOrd) do
    begin
        FreeAndNil(mMotors[It]);
    end;

    FreeAndNil(mMtrOper);

    FreeAndNil(mMoveCtrler[tmSlide]);
    FreeAndNil(mMoveCtrler[tmTilt]);
    FreeAndNil(mMoveCtrler[tmHeight]);
    FreeAndNil(mMoveCtrler[tmLegSupt]);
    FreeAndNil(mMoveCtrler[tmSwivel]);
    FreeAndNil(mIMSCtrler);
    FreeAndNil(mUDSMoveCtrler);

end;

function MtrOrd2SwPinType(MtrID: TMotorOrd): TPwrSwPinType;
begin
//    case MtrID of
////        tmSlide:
////            Result := pspSlide;
////        tmTilt:
////            Result := pspTilt;
////        tmHeight:
////            Result := pspHeight;
////        tmCushExt:
////            Result := pspCushExt;
//    end
end;

procedure TTsWork.InitMotorsCtrler(MdlType: TModelType);
var
    It: TMotorOrd;
    IsInit, IsIMSChanged, IsDrvPosChanged: boolean;
    IMSCtrler: TCANIMSCtrler;
begin
    IsInit := not mOldMtrModelType.IsIMS and not MdlType.IsIMS;
    IsIMSChanged := (mOldMtrModelType.IsIMS <> MdlType.IsIMS) or IsInit;

    IsInit := not mOldMtrModelType.IsDrvPos and not MdlType.IsDrvPos;
    IsDrvPosChanged := (mOldMtrModelType.IsDrvPos <> MdlType.IsDrvPos) or IsInit;

    mOldMtrModelType := MdlType;

    mMotors[tmSlide].Use := RsBuf.rModel.rTypes.IsSlideExists;
    mMotors[tmTilt].Use := RsBuf.rModel.rTypes.IsTiltExists;
    mMotors[tmHeight].Use := RsBuf.rModel.rTypes.IsHeightExists;
    mMotors[tmLegSupt].Use := RsBuf.rModel.rTypes.IsLegSuptExists;
    mMotors[tmSwivel].Use := RsBuf.rModel.rTypes.isSwivelExists;

{$IFDEF VIRTUALIO}
    IMSCtrler := mIMSSimCtrler;
{$ELSE}
    if MdlType.IsRJ1 and MdlType.IsPsgPos then
    begin
        IMSCtrler := mDIOMemCtrler;
        gLog.Panel('DIOMem Ctrl 셋팅');
    end
    else
        IMSCtrler := mIMSCtrler;
{$ENDIF}

    // IMSCtrler는 1개 인스턴스로 사용, 운전/조수석에 따라 파라미터만 변경
    for It := Low(TMotorOrd) to High(TMotorOrd) do
    begin
        mMotors[It].IsIMS := MdlType.IsIMS;
    end;

    TUDSCarConfigurator.SetupCANIDs(IMSCtrler, mUDSMoveCtrler, MdlType.GetCarType, MdlType.IsDrvPos);
    TUDSCarConfigurator.SetUpUDSMoveData(mUDSMoveCtrler, MdlType.GetCarType, MdlType.IsIMS);

    if mCurModelType.IsRJ1 and (not mCurModelType.IsIMS) then
        mUDSMoveCtrler.AdvenceType := True
    else
        mUDSMoveCtrler.AdvenceType := false;

    if MdlType.IsIMS then
    begin
        if MdlType.IsDrvPos then
            IMSCtrler.RCID.Create($12A3)
        else
            IMSCtrler.RCID.Create($12A5);
    end;

    /// /////////////////////////////////////////
    if not IsIMSChanged then
        Exit;

    if MdlType.IsIMS then
    begin
        for It := Low(TMotorOrd) to High(TMotorOrd) do
        begin

            mMotors[It].MoveCtrler.Enabled := false;
            mMotors[It].MoveCtrler := mUDSMoveCtrler;
            mMotors[It].IMSCtrler := IMSCtrler;
            mMotors[It].MoveCtrler.Enabled := true;
        end;
    end;

end;

procedure TTsWork.InitHVCanSig(MdlType: TModelType);
var
    SwID: Cardinal;
    DrvLedID: Cardinal;
    PsgLedID: Cardinal;
begin
    case MdlType.GetCarType of
        ctJG1:
            ;
        ctRJ1:
            begin
                SwID := $08B;

                if MdlType.IsIMS then
                begin
                    DrvLedID := $140;
                    PsgLedID := $14C;
                    if MdlType.IsDrvPos then
                    begin
                        mHVCANCtrlers[hvdHeatDrv].InitSwSig(SwID, 2, 4, 4);
                        mHVCANCtrlers[hvdVentDrv].InitSwSig(SwID, 2, 4, 4);
                        mHVCANCtrlers[hvdHeatDrv].InitLedSig(DrvLedID, 4, 5, 3);
                        mHVCANCtrlers[hvdVentDrv].InitLedSig(DrvLedID, 4, 2, 3);
                    end
                    else
                    begin
                        mHVCANCtrlers[hvdHeatDrv].InitSwSig(SwID, 2, 0, 4);
                        mHVCANCtrlers[hvdVentDrv].InitSwSig(SwID, 2, 0, 4);
                        mHVCANCtrlers[hvdHeatDrv].InitLedSig(PsgLedID, 3, 5, 3);
                        mHVCANCtrlers[hvdVentDrv].InitLedSig(PsgLedID, 3, 2, 3);
                    end;
                end
                else
                begin
                    DrvLedID := $1A9;
                    PsgLedID := $1AF;
                    if MdlType.IsDrvPos then
                    begin

                        mHVCANCtrlers[hvdHeatDrv].InitLedSig(DrvLedID, 0, 5, 3);
                        mHVCANCtrlers[hvdVentDrv].InitLedSig(DrvLedID, 0, 2, 3);

                    end
                    else
                    begin
                        mHVCANCtrlers[hvdHeatDrv].InitLedSig(PsgLedID, 0, 5, 3);
                        mHVCANCtrlers[hvdVentDrv].InitLedSig(PsgLedID, 0, 2, 3);

                    end;

                end;

            end;

        ctHI:
            begin
                SwID := $08B;
                DrvLedID := $140;
                PsgLedID := $14C;

                if MdlType.IsDrvPos then
                begin
                    mHVCANCtrlers[hvdHeatDrv].InitSwSig(SwID, 2, 4, 4);
                    mHVCANCtrlers[hvdVentDrv].InitSwSig(SwID, 2, 4, 4);
                    mHVCANCtrlers[hvdHeatDrv].InitLedSig(DrvLedID, 0, 5, 3);
                    mHVCANCtrlers[hvdVentDrv].InitLedSig(DrvLedID, 0, 2, 3);

                end
                else
                begin
                    mHVCANCtrlers[hvdHeatDrv].InitSwSig(SwID, 2, 0, 4);
                    mHVCANCtrlers[hvdVentDrv].InitSwSig(SwID, 2, 0, 4);
                    mHVCANCtrlers[hvdHeatDrv].InitLedSig(PsgLedID, 3, 5, 3);
                    mHVCANCtrlers[hvdVentDrv].InitLedSig(PsgLedID, 3, 2, 3);

                end;

                gLog.Panel('HI PE HV Sig 설정 완료');

            end;

    end;

end;

procedure TTsWork.InitMotors;
var
    MtrIt: TMotorOrd;
    MtrCnst: TMotorConstraints;
    TimeParam: TSMParam;

    function GetBurnishingCount(Motor: TSeatMotor): Integer;
    begin
        {
        if Motor.IsSLimitSet or not gSysEnv.rUseBurnishing then
            Result := 0
        else
            Result := gSysEnv.rBurCount
        }

        Result := 0;
    end;

begin
    with mDBX do
    begin
        // 사양별 모터 전류, Ctrler설정,
        InitMotorsCtrler(RsBuf.rModel.rTypes);

        TimeParam.mMoveGapTime := 1.5;
        TimeParam.mMoveCheckTime := 1.0;
        TimeParam.mReadDelayTime := 1.0;

        for MtrIt := Low(TMotorOrd) to MtrOrdHi do
        begin
            MtrCnst := mCurModels.rConstraints[MtrIt];

            mGrpExt[MtrIt].Param.Create(mMotors[MtrIt].MoveCurrRange,  // 최소 ~ 구속(LockDir)
                RsBuf.rModel.rSpecs.rMotors[MtrIt].rTime, RsBuf.rModel.rSpecs.rMotors[MtrIt].rCurr, RsBuf.rModel.rSpecs.rMotors[MtrIt].rInitNoiseTime, RsBuf.rModel.rSpecs.rMotors[MtrIt].rInitNoise, RsBuf.rModel.rSpecs.rMotors[MtrIt].rRunNoise, MtrCnst.rStroke);

            mGrpExt[MtrIt].Param.mNoiseExcludeSec.Create(gSysEnv.rSoundProof.rNoiseCollectStart, gSysEnv.rSoundProof.rNoiseCollectEnd);

            mGrpExt[MtrIt].LockedCurr := MtrCnst.rLockedCurr;
            mGrpExt[MtrIt].ShowCurrSpec := IsTested(tsCurr);
            mGrpExt[MtrIt].ShowNoiseSpec := IsTested(tsNoise);

            mMotors[MtrIt].SetMoveParam(MtrCnst.rLockedCurr, MtrCnst.rMaxTime);     // 모터별 구속전류, 구속시간
            mMotors[MtrIt].Use := IsTested(MotorORd2TsOrd(MtrIt));
            mMotors[MtrIt].SetOffset(mCurModels.rMtrOffset[Ord(StationID)].rVals[MtrIt, twForw].rCurr, mCurModels.rMtrOffset[Ord(StationID)].rVals[MtrIt, twBack].rCurr);
            mMotors[MtrIt].mTotRepeatCount := GetBurnishingCount(mMotors[MtrIt]);

            mMotors[MtrIt].OnStopCond := nil;

            mMotors[MtrIt].SetSMParam(TimeParam);

            if mCurModelType.IsIMS then
            begin
                mMotors[MtrIt].IsHLimitSet := false;
            end
        end;

        gLog.Panel('모터 사용: S:%s, T:%s, H:%s, C:%s, SW: %s', [BoolToStr(mMotors[tmSlide].Use, true), BoolToStr(mMotors[tmTilt].Use, true), BoolToStr(mMotors[tmHeight].Use, true), BoolToStr(mMotors[tmLegSupt].Use, true), BoolToStr(mMotors[tmSwivel].Use, true)]);
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
                mDCPower.PowerOFF(True); // 비상정지시
                gLog.Panel('비상 정지!!');
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

            gLog.Panel('%s: 비상 정지!!', [Name]);
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
            if not mDCPower.Power then
                mDCPower.PowerON(True);
            mLDOChs.Clear(mLIO, [mLDOChs.mTestReady]);
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

end;

procedure TTsWork.ClearDO;
var
    i: integer;
begin
    for i := 0 to DO_END do
    begin
        mDIO.SetIO(i, false);
    end;
end;

procedure TTsWork.SetSpecDO;
begin
    mDIO.SetIO(DO_IGN1, true);

    mDIO.SetIO(DO_RJ1_HI_NTC_10K, mCurModelType.IsRJ1 or mCurModelType.IsHI);
    mDIO.SetIO(DO_RJ1_H_MAT, mCurModelType.IsRJ1 and mCurModelType.IsHeatType);
    mDIO.SetIO(DO_RJ1_CCS_MAT, mCurModelType.IsRJ1 and mCurModelType.IsHV);
    mDIO.SetIO(DO_HI_CCS_MAT, mCurModelType.IsHI and mCurModelType.IsHV);
    mDIO.SetIO(DO_JG1_HV_MAT, mCurModelType.IsJG1 and mCurModelType.IsHV);
    mDIO.SetIO(DO_JG1_BACK_EXTN_DRV_PAS, mCurModelType.IsJG1);
    mDIO.SetIO(DO_RJ1_BACK_EXTN_DRV, mCurModelType.IsRJ1 and mCurModelType.IsDrvPos);
    mDIO.SetIO(DO_HI_BACK_EXTN_DRV_PAS, mCurModelType.IsHI);

    mDIO.SetIO(DO_RJ1_HI_CAR, (mCurModelType.IsRJ1) or mCurModelType.IsHI);
    mDIo.SetIO(DO_RJ1_APSM_PASS, mCurModelType.IsRJ1 and mCurModelType.IsPsgPos);
    mDIO.SetIO(DO_JG1_CAR, mCurModelType.IsJG1);
    mDIo.SetIO(DO_CAN_100K, mCurModelType.IsHI or mCurModelType.IsRJ1);
    //mDIO.SetIO(DO_CAN_500K, mCurModelType.IsRJ1 or mCurModelType.IsJG1);

    mDIO.SetIO(DO_APT, true);

    if mCurModelType.IsRJ1 then
    begin
        mDIO.SetIO(DO_HOST_CUSH_02_OHM, true);
        mDIO.SetIO(DO_HOST_CUSH_04_OHM, true);
        mDIO.SetIO(DO_HOST_CUSH_20_OHM, true);
        mDIO.SetIO(DO_HOST_BACK_02_OHM, true);
        mDIO.SetIO(DO_HOST_BACK_04_OHM, true);
        mDIO.SetIO(DO_HOST_BACK_20_OHM, true);
    end;



    //mDIO.SetIO(DO_DMOVE_GND, mCurModelType.IsDirectMoveType);
end;

procedure TTsWork.ClearElecDOs;
begin

end;

procedure TTsWork.ClearSpecDO;
begin
    // mDIO.SetIO(DO_DMOVE_GND, False);
end;

procedure TTsWork.LinkNext(TsWork: TTsWork);
begin
    mNextTsWork := TsWork;
    TsWork.mNextTsWork := self;

end;

procedure TTsWork.InitHVCtrler(MdlType: TModelType);
var
    i: THVDevType;
    CtrlerType: TCtrlerType;
begin
{$IFDEF VIRTUALIO}
    CtrlerType := ctSimul;
{$ELSE}
    CtrlerType := ctCAN;
{$ENDIF}
    case CtrlerType of
        ctSimul:
            begin
                gLog.Panel('%s: HV Simul 설정', [Name]);
                for i := Low(THVDevType) to High(THVDevType) do
                begin
                    mHVSimCtrlers[i].Name := 'SIM' + IntToStr(ord(i));
                    mHVTester.HVTests[i].Ctrler := mHVSimCtrlers[i];
                end;
            end;
        ctDIO:
            begin
                gLog.Panel('%s: HV DIO 설정', [Name]);
                for i := Low(THVDevType) to High(THVDevType) do
                begin
                    //
                end;
            end;

        ctCAN:
            begin

                for i := Low(THVDevType) to High(THVDevType) do
                begin
                    mHVTester.HVTests[i].Ctrler := mHVCANCtrlers[i];
                end;

            end;
        ctLIN:
            begin
            end;
    end;

end;

procedure TTsWork.InitHVTester;
var
    i: THVDevType;
begin
    mHVRetryCnt := 0;

    InitHVCtrler(RsBuf.rModel.rTypes);

    mHVTester.HDrvTest.Use := mCurModelType.IsHeat or mCurModelType.IsVent;
    mHVTester.VDrvTest.Use := mCurModelType.IsVent;
    mHVTester.HPsgTest.Use := false;
    mHVTester.VPsgTest.Use := false;

    mHVTester.SetHCurrRange(TRange.Create(mDBX.GetData(roSpecHeatOnLo), mDBX.GetData(roSpecHeatOnHi)), mDBX.GetData(rospecHeatOffHi));
    mHVTester.SetVCurrRange(TRange.Create(mDBX.GetData(roSpecVentOnLo), mDBX.GetData(roSpecVentOnHi)), mDBX.GetData(rospecVentOffHi));
    mHVTester.SetTestTime(gsysEnv.rElec.rHV.rSwOnDelay, gsysEnv.rElec.rHV.rMaxCollectTime, gsysEnv.rElec.rHV.rBlowReadTime);

    mHVTester.IsSeqTest := true;

    mHVTester.mBeforeStartSec := gsysEnv.rElec.rHV.rTestB4Delay;

    mHVTester.ClearFSM;

    if gSysEnv.rElec.rHV.rUseSwZeroCurr then
        mHVTester.SetZero;

    // 전류 테스트 비활성화
    mHVTester.HDrvTest.UseCurrTest := true;
    mHVTester.VDrvTest.UseCurrTest := true;
    mHVTester.HPsgTest.UseCurrTest := False;
    mHVTester.VPsgTest.UseCurrTest := False;



    // ---------------------------

    if mMainCon.IsEmpty then
        Exit;

end;

procedure TTsWork.Initial(IsLoad: Boolean);
var
    It: TMotorOrd;
    DevCom: TDevCom;
    ReqID, RespID: Cardinal;
begin
{$IFDEF VIRTUALLANIO}
    mLIO.SetIO(mLDIChs.mAutoMode, True);
{$ENDIF}
    ClearDO;
    ClearFSM;
    mLstError := '';
    mLstToDo := '';

    mFuncState := 0;
    mOutPosState := 0;
    mInitState := 0;
    mMemTestState := _MEM_INIT;

    mdstRepeat := 0;
    mdstNgRepeat := 0;

    mIsDelivering := False;

    mIsPrnDone := False;
    mIsTestingNG := False;

    mNGRetry := 0;

    mDTCState := 0;

    mMtrOper.ClearFSM;

    mRetryCount := 0;

    mElecState := _WS_ELEC_IDLE;

    {
      DevCom := gDevComs.GetDevCom(GetLaserDistDevComOrd(StationID));
      DevCom.Name := GetDevComName(DevCom.DevID);
      }
{$IFNDEF VIRTUALIO}
    {
      if not DevCom.IsOpen and not DevCom.Open then
      begin
      SetError(Format('%s(COM%d) 통신 포트 열기 실패', [GetDevComName(DevCom.DevID), DevCom.Port]), '통신 포트및 배선을 점검하세요');
      end;
    }


    if not mCAN.IsOpen then
    begin
        gLog.Panel('CAN이 열리지 않았습니다.');
    end;


{$ENDIF}


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
                gLog.Panel('POP Data 요청', []);
            end
            else if IsConnected and IsExists then
            begin
                gLog.Panel('POP 수신 설정: %s, %s', [GetPartNo, GetLotNo]);
                mDBX.SetData(roPartNo, GetPartNo);
                mDBX.SetData(roLotNo, GetLotNo);
            end;
        end;
    end;

    with RsBuf.rModel.rTypes do
    begin
        ReqID := IfThen(IsDrvPos, $706, $709);

        if IsIMS then
            RespID := IfThen(IsDrvPos, $726, $729)
        else
            RespID := IfThen(IsDrvPos, $763, $764);
    end;

    mECUVer.InitID(ReqID, RespID);
    mDTCReader.InitID(ReqID, RespID);
    mEVItem := mECUVerList.Find('');

    InitHVTester;
    InitHVCanSig(mCurModelType);

    SetMotorCurrPinsToZero;

    if mDBX.IsTested(tsBuckle) then
    begin
        mBuckTester.Init(mDBX.RsBuf.rModel.rTypes.GetBuckleType, TRange.Create(mDBX.RsBuf.rModel.rSpecs.rBuckleCurr.rLo, mDBX.RsBuf.rModel.rSpecs.rBuckleCurr.rHi), gSysEnv.rElec.rBuckle.rChkTime, AI_BUCK_CURR_CH, true);

    end;

    for It := Low(TMotorOrd) to MtrOrdHi do
    begin
        mMotors[It].IGraph := mGrpExt[It];
        mMotors[It].SetZero;
        mMotors[It].ClearFSM;
    end;

    if IsPopLinkMode then
        gLog.Panel('%s: initial(%s, %s, %s)', [Name, RsBuf.rModel.rTypes.GetCarTypeStr, mPop.rcvPartNo, mPop.rcvPalletNo])
    else
        gLog.Panel('%s: initial(단동: %s)', [Name, RsBuf.rModel.rTypes.GetCarTypeStr]);

    mAPTTester.Init;
    mODSTester.Init;
    mPeriodicCanData.Init(mCurModelType.GetCarType);

    mDBX.SetData(roRsAbnormalSound, true);

    UpdateForm(tw_INIT);
end;

procedure TTsWork.ShowPopData;
begin
    gLog.Panel('%s: %s', [Name, GetPopDatas]);
end;

procedure TTsWork.ShowProcState;
var
    It: TMotorOrd;
begin
    gLog.Panel('%s: mWorkState=%d, mElecState=%d', [Name, Ord(mWorkState), ord(mElecState)]);
    gLog.Panel('%s: mFuncState=%d, mLocalState=%d', [Name, ord(mFuncState), ord(mLocalState)]);

    for It := Low(TMotorOrd) to MtrOrdHi do
        mMotors[It].ShowState;
end;

function TTsWork.IsRun: Boolean;
begin
    Result := (mWorkState > _WS_IDLE);
end;

function TTsWork.IsElecTestRun: Boolean;
begin
    Result := mElecState > _WS_ELEC_IDLE;
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
    SaveGraphDatas(mDBX.GetGraphTime, mGrpExt[tmSlide].Graph);
    SaveGraphDatas(mDBX.GetGraphTime, mGrpExt[tmTilt].Graph);
    SaveGraphDatas(mDBX.GetGraphTime, mGrpExt[tmHeight].Graph);
    SaveGraphDatas(mDBX.GetGraphTime, mGrpExt[tmLegSupt].Graph);
    SaveGraphDatas(mDBX.GetGraphTime, mGrpExt[tmSwivel].Graph);

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
    mSpecChkState := 1;

    mTmpTime := GetAccurateTime;

    mIsTesting := True;

    if not mDCPower.Power then
        mDCPower.PowerON();

    gLog.Panel('%s: start', [Name]);

end;

procedure TTsWork.StartDevState4SpecChk;
begin
    mStartSpecChk := True;
    SetSpecDO;
    mDCPower.SetCurr(gSysEnv.rOP.rTest.rSpecCurr);
    mDCPower.SetVolt(gSysEnv.rOP.rTest.rVolt);
    mSpecChkTC.Start(1000 * 5);
    UpdateForm(tw_SPEC_CHK_START);
    gLog.Panel('%s: 사양 DO 및 최소 대기 전류 설정: %0.1f(A)..', [Name, gSysEnv.rOP.rTest.rSpecCurr]);
end;

procedure TTsWork.Stop(IsForce: Boolean);
var
    iTm: TTsModeORD;
begin
    mPeriodicCanData.Enabled := False;

    if mConStatus then
        StopMotors;

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

    mLDOChs.Clear(mLIO, [mLDOChs.mTestReady, mLDOChs.mOK, mLDOChs.mNOK]);
    ClearDO;

    mDCPower.SetCurr(gSysEnv.rOP.rTest.rSpecCurr);

    // --------------------------------------------------------------------------------
    mWorkState := _WS_IDLE;
    mElecState := _WS_ELEC_IDLE;
    mSpecChkState := 0;
    mBuckTester.FSMStop;
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

    gDCPower.Items[0].PowerOFF(true);

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
                    gLog.Panel('%s: IMS 모터 정렬', [Name]);
                    mFuncState := 5;
                end
                else
                begin
                    case PwrMoveType of
                        pmtEach:
                            begin
                                gLog.Panel('%s: PWR 모터 개별 정렬', [Name]);
                                mFuncState := 1;
                            end;
                        pmtSameTime:
                            begin
                                gLog.Panel('%s: PWR 모터 동시 정렬', [Name]);
                                mFuncState := 2;
                            end;

                        pmtGroup:
                            begin
                                gLog.Panel('%s: PWR 모터 그룹별 정렬', [Name]);
                                mFuncState := 3;
                            end;
                        pmtInterval:
                            begin
                                gLog.Panel('%s: PWR 모터 시차 정렬', [Name]);
                                mFuncState := 4;

                            end;
                    end;
                end;
            end;
        1: // PWR 개별
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

        3: // 그룹
            begin
                case mMtrOper.FSMMove([mMtrTilt, mMtrHeight], [mMtrSlide, mMtrLegSupt]) of
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
        4: // 시차
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

        5: // IMS 개별
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
                mMtrSlide.IsEndPosChk := False; // 구속전류 미발생을 끝단 판단 조건 잠시 무시
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

function TTsWork.FSMCheckLimit: integer;
var
    MtrIt: TMotorORD;
begin
    Result := 0;
    case mFuncState of
        0:  // Routine Control Enable
            begin
                if mIMSCtrler.EnableRCReq then
                begin
                    gLog.Panel('%s: Routine Control Enable 요청', [Name]);
                    mDelayTC.Start(200); // 차종에 따라 딜레이 필요
                    Inc(mFuncState);
                end
                else
                begin
                    gLog.Error('%s: RC Enable 요청 실패', [Name]);
                    SetError('리미트 활성화 실패', 'CAN 통신을 확인하세요');
                end;
            end;

        1:  // Enable 후 대기
            begin
                if mDelayTC.IsTimeOut then
                begin
                    Inc(mFuncState);
                end;
            end;

        2:  // 리미트 상태 요청
            begin
                if mIMSCtrler.ReqLimit then
                begin
                    gLog.Panel('%s: 리미트 상태 요청', [Name]);
                    mDelayTC.Start(1000); // 응답 대기 타임아웃
                    Inc(mFuncState);
                end
                else
                begin
                    gLog.Error('%s: 리미트 요청 실패', [Name]);
                    SetError('리미트 요청 실패', 'CAN 통신을 확인하세요');
                end;
            end;

        3:  // 응답 대기
            begin
                if mIMSCtrler.IsLimitRespDone then
                begin
                        // 리미트 데이터 처리
                    mIMSCtrler.ProcessLimitDone;

                    // 각 모터의 리미트 상태 확인
                    gLog.Panel('%s: 리미트 상태 - S:%d, T:%d, H:%d, L:%d', [Name, Ord(mIMSCtrler.GetLimitStatus(tmSlide)), Ord(mIMSCtrler.GetLimitStatus(tmTilt)), Ord(mIMSCtrler.GetLimitStatus(tmHeight)), Ord(mIMSCtrler.GetLimitStatus(tmLegSupt))]);

                    mFuncState := 0;
                    Exit(1);
                end
                else if mDelayTC.IsTimeOut then
                begin
                    gLog.Error('%s: 리미트 응답 타임아웃', [Name]);
                    SetError('리미트 응답 없음', 'CAN 통신을 확인하세요');
                    Exit(-1);
                end;
            end;
    end;

end;

function TTsWork.MtrStopByDPSensor(Motor: TSeatMotor): Boolean;
begin
    Result := False;
    {
      if Motor.ID = tmSlide then
      begin
      Result := mDIO.IsIO(DI_OUTPOS_SENSOR_LH);
      end
      else
      begin
      Result := mDIO.IsIO(DI_OUTPOS_SENSOR_RH);
      end;
      }
    if Result then
    begin
        gLog.Panel('%s: %s 납품위치 센서 검출', [Name, Motor.Name]);
    end;
end;

function TTsWork.FSMMoveToOutPos: Integer;
begin
    Result := 0;
    case mFuncState of
        0:
            begin
                mMtrOper.Init([mMtrHeight], [twBack]);
                Inc(mFuncState);
                UpdateForm(tw_DELIVERY_START);
                gLog.Panel('%s: 납품 위치 시작', [Name]);
                mMtrHeight.OnStopCond := HgtMtrStopCond;

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
                            gLog.Panel('%s: 납품 위치 완료');
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
    if UpperCase(mMainCon.ID) = CurModelType.MakeMainConID then
        Exit(True);

    Result := False;

    if not gConMan.AssignByID(CurModelType.MakeMainConID, mMainCon) then
    begin
        gLog.Error('선택 모델 메인 커넥터 정보 없음', []);
        SetError('선택 모델 메인 커넥터 정보 없음', '선택 모델 사양이나 Env폴더내 파일이 있는지  확인 하세요');
        Exit;
    end;

    if not gConMan.AssignByID(CurModelType.MakeBackExtConID, mExtCon) then
    begin
        gLog.Error('선택 모델 백 스위치 커넥터 정보 없음', []);
        SetError('선택 모델 스위치 커넥터 정보 없음', '선택 모델 사양이나 Env폴더내 파일이 있는지 확인 하세요');
        Exit;
    end;

    if not gConMan.AssignByID(CurModelType.MakeHtrMatConID, mMatCon) then
    begin
        gLog.Error('선택 모델 히터 MAT 커넥터 정보 없음', []);
        SetError('선택 모델 스위치 커넥터 정보 없음', '선택 모델 사양이나 Env폴더내 파일이 있는지 확인 하세요');
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
    Result := true;

//    if not mIsSpecChkOK then
//    begin
//        Exit(False);
//    end;
//{$IFDEF VIRTUALIO}
//    Result := True;
//{$ELSE}
//    Result := (gSysEnv.rOP.rTest.rCurr * 0.9) <= mDCPower.Curr;
//{$ENDIF}
    gLog.Debug('MtrJog: MtrJogRunReq. Result:%s', [BoolToStr(Result, True)]);
end;

// UI 메시지 처리 및 실적 저장.

function AvgToIdx(Avg: Boolean): Integer;
begin
    if Avg then
        Result := 2
    else
        Result := 1;
end;

// 전류 , 속도, 소음 NG시
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
    gLog.Panel('SeatMotorTestStatus 호출: %s - Status: %d', [Motor.Name, Ord(TestStatus)]);

    if not IsRun then
    begin
        gLog.Panel('IsRun = False로 인해 종료');
        Exit;
    end;

    mCurMotor := Motor;
    mDBX.RsBuf.rCurMtr := Motor.ID;

    case TestStatus of
        msStart: // 작동 시작
            begin
                UpdateForm(tw_MTR_TEST_START);
            end;
        msStop: // 작동 정지 & 실적 저장 처리 (블럭킹 처리라 Invoke사용)
            begin
                ProcessMotorData(Motor)
            end;

        msLimitSetStart: // IMS 리미트 설정 시작
            begin
                // UpdateForm(tw_LIMIT_SET);
            end;

        msLimitReaded: // IMS 리미트 읽음
            begin
                UpdateForm(tw_LIMIT_READED);
            end;

        msTestEnd: // 시험 종료, 재측정 판단
            begin
                // 전류 , 속도, 소음 NG시
                if NeedsRetest(Motor) then
                begin
                    Motor.IsRetest := True;
                end;
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
            begin

            end;
        1:
            begin
                mDCPower.PowerON(true);

                gLog.Panel('%s : 파워 ON', [Name]);

                Inc(mSpecChkState);
                mspChkTC.Start(1000);

            end;
        2:
            begin
                if not mSpChkTC.IsTimeOut then
                    Exit;

                mDCPower.SetCurr(gSysEnv.rOP.rTest.rSpecCurr);
                mDCPower.SetVolt(gSysEnv.rOP.rTest.rVolt);

                UpdateForm(tw_SPEC_CHK_START);
                mSpChkTC.Start(10 * 1000);
                Inc(mSpecChkState);

                gLog.Panel('%s: 사양 점검 전류 설정: %0.1f(A)', [Name, gSysEnv.rOP.rTest.rSpecCurr]);
            end;
        3:
            begin

                // 메인 전류가 설정상의 50%이하이면 정상 아니면 쇼트 발생 (커넥터 이종 삽입 등..)
                if GetMainCurr <= (gSysEnv.rOP.rTest.rSpecCurr * 0.5) then
                begin
                    Inc(mSpecChkState);
                end
                else
                begin
                    gLog.Panel('%s: 설정 전류 50%% 이상 감지 Error(%.1f(A) > %.1f(A)', [Name, GetMainCurr, (gSysEnv.rOP.rTest.rSpecCurr * 0.5)]);
                    SetError('사양 체크 전류 이상 ERROR', '커넥터 쇼트, 이종 체결, 통전 블럭 접촉 불량 여부 또는 올바른 사양인지 확인 하세요.');
                    mIsSpecChkOK := False;

                    mSpecChkState := 0;
                    Exit(-1);
                end;

                if mSpChkTC.IsTimeOut then
                begin
                    // TO DO : NG 결과 디테일 처리 유무..
                    SetError('사양 체크 설정 전류 ERROR', '파워 전원ON 확인여부를 점검 하세요');
                    mSpecChkState := 0;
                    Exit(-1);
                end;
            end;
        4:
            begin
                mDCPower.SetCurr(gSysEnv.rOP.rTest.rCurr);
                mDCPower.SetVolt(gSysEnv.rOP.rTest.rVolt);

                SetSpecDO;

                mDelayTC.Start(2000);
                Inc(mSpecChkState);

            end;
        5:
            begin
            {$IFDEF VIRTUALLANIO}
                mIsSpecChkOK := True;
                mLIO.SetIO(mLDOChs.mTestReady, True);
                mSpecChkState := 0;
                UpdateForm(tw_SPEC_CHK_END);
                Exit(1);
            {$ENDIF}
                if not mDelayTC.IsTimeOut then
                    Exit;
                //if mMatCon.IsConnected then
                Inc(mSpecChkState);
                mIsConnected := true;
            end;
        6:
            begin
                if (mDCPower.Curr <> gSysEnv.rOP.rTest.rCurr) then
                begin
                    mDCPower.SetCurr(gSysEnv.rOP.rTest.rCurr);
                    mDCPower.SetVolt(gSysEnv.rOP.rTest.rVolt);

                    gLog.Panel('%s: 시험 전류 %0.1f(A) 설정', [Name, gSysEnv.rOP.rTest.rCurr]);
                end;

                Inc(mSpecChkState);
            end;
        7:
            begin
                if (gSysEnv.rOP.rTest.rCurr * 0.9) <= mDCPower.Curr then
                begin
                    mIsSpecChkOK := True;

                    gLog.Panel('%s: 시험 전류 %0.1f(A) 설정 완료', [Name, mDCPower.Curr]);
                    mSpecChkState := 0;
                    mSkipConChk := True;
                    UpdateForm(tw_SPEC_CHK_END);
                    mLIO.SetIO(mLDOChs.mTestReady, mIsConnected);
                    Exit(1);
                end
                else
                begin
                    if mOldCurr <> mDCPower.Curr then
                    begin
                        // gLog.Panel('%s: 전류 %0.1f(A) 설정 미달', [Name, mOldCurr]);
                        mOldCurr := mDCPower.Curr;
                    end;

                end;

            end;
    end;

end;

procedure TTsWork.ShowSpecChkMsg;
begin
    if not gModels.IsModelLoaded then
    begin
        ShowMsg(['모델 설정 오류', '모델이 설정되지 않았습니다'], ['모델 메뉴에 현제품 사양이 등록되었는지 확인 하세요'], True);
        gLog.Error('사양 체크: 모델 설정 오류', []);

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
    I: Integer;

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

    // Elec 검사 추가

    if FSMTestElecPart < 0 then
    begin
        if mCurModelType.IsHV or mCurModelType.IsHeatType then
            mElecState := _WS_ELEC_IDLE
        else
            mElecState := _WS_ELEC_END;

        if mLstError = '' then
            SetError('Elec.Part test error!', 'Check the cable or product')
        else
            SetError(mLstError, 'Check the cable or product');
    end;

    case mWorkState of
        _WS_IDLE:
            ;
        _WS_START:
            begin


{$IFNDEF VIRTUALLANIO}

                if not mDCPower.Power then
                begin
                    if (GetAccurateTime - mTmpTime) > 10000.0 then
                    begin
                        SetError('전원이 ON 되지 않았습니다', '파워서플라이 통신연결 및 상태를 확인후 재작업하세요');
                        gLog.Panel('%s: 파워 Error', [Name]);
                    end;
                    Exit;
                end;
//
//
//                if (GetNoise < 20) or (GetNoise > 990) then
//                begin
//                    SetError(Format(_TRNS('소음센서값:%f db,  기준치(%f db) 이하거나 오류 입니다'), [GetNoise, 20]), '센서 연결 및 전원을 확인 하세요');
//                    gLog.Error('%s: 소음센서값:%f db,  기준치(%f db) 이하, 센서 이상 체크', [Name, GetNoise, 20]);
//                    Exit;
//                end;

                if not mIsSpecChkOK then
                    Exit;

{$ENDIF}
                mMtrOper.Init([mMtrSlide, mMtrTilt, mMtrHeight, mMtrLegSupt, mMtrSwivel], [twBack, twBack, twForw, twBack, twBack]);
                mMtrOper.ClearFSM;

                mdstRepeat := 0;
                mFuncState := 0;

                gLog.Panel('%s: ECU 정보 읽기 시작', [Name]);
                mECUVer.ClearFSM;
                mECUVer.Enabled := True;
                UpdateForm(tw_ECU_INFO_START);
                mTC.Start(3000);
                mPeriodicCanData.SetIgn(true);
                mLIO.SetIO(mLDOChs.mTestReady, false);

                mWorkState := _WS_READ_ECU_VER;

            end;

        _WS_READ_ECU_VER:
            begin
                if not mTC.IsTimeOut then
                    Exit;

                case mECUVer.FSMReadWithRetry(3) of
                    -1:
                        begin
                            if mECUVer.RetryCount > mECUVer.MaxRetry then
                            begin
                                SetError('ECU Ver. 읽기 실패', '커넥터 연결 또는 제품 사양을 확인 하세요(CAN 통신)');
                                gLog.Panel('%s : ECU 정보 읽기- 실패', [Name]);
                            end
                            else
                            begin
                                mECUVer.ClearFSM;
                                gLog.Panel('ECU 정보 읽기- 재시도(%d)', [mECUVer.RetryCount]);
                                mTC.Start(1000);
                            end;
                            mWorkState := _WS_CHK_LIMIT_STATUS_BEFORE
                        end;
                    1:
                        begin
                            mEVItem := mECUVerList.Find(mPop.GetPartNo);

                            {
                            if mEVItem.IsEmpty then
                            begin
                                SetError(mPop.GetPartNo + ' 해당하는 ECU 정보가 없습니다', 'ECU 정보를 [검사설정 -> ECU Ver 설정]란에서 입력 하세요');
                                Exit;
                            end;
                            }

                            mDBX.SetData(roDataEcuPartNo, Trim(mECUVer.PartNo));
                            mDBX.SetData(roDataEcuHwVer, Trim(ECUVer.OemHW));
                            mDBX.SetData(roDataEcuSwVer, Trim(ECUVer.OemSW));

                            mDBX.SetData(roRsEcuPartNo, mEVItem.MatchPartNo(mECUVer.PartNo));
                            mDBX.SetData(roRsEcuHwVer, mEVItem.MatchHWVer(mECUVer.OemHW));
                            mDBX.SetData(roRsEcuSwVer, mEVItem.MatchSWVer(mECUVer.OemSW));

                            UpdateForm(tw_ECU_INFO_END);

                            //gLog.Panel('설정 ECU Ver:%s, %s', [mEVItem.mECUSWVer, mEVItem.mECUPartNo]);
                            gLog.Panel('[읽은 ECU 정보] PartNo: %s, HWVer: %s, SWVer: %s', [mECUVer.PartNo, mECUVer.oemHW, mECUVer.oemSW]);

                            if mCurModelType.IsIMS then
                            begin
                                mWorkState := _WS_CHK_LIMIT_STATUS_BEFORE;
                                gLog.Panel('리미트 확인 시작');
                            end
                            else
                            begin
                                mWorkState := _WS_MOVE_TO_LOADING_POS;
                                gLog.Panel('모터 웨이트 로딩 위치로 이동');
                            end;

                            mPeriodicCanData.SetIgn(false);

                        end;

                end;

            end;

        _WS_CHK_LIMIT_STATUS_BEFORE:
            begin
                case mMtrSlide.FSMReadLimitStatus of
                    -1:
                        begin
                            SetError('리미트 설정 확인 실패', '장비를 점검하세요');
                            mWorkState := _WS_MOVE_TO_LOADING_POS;

                            gLog.Panel('리미트 설정 확인 실패');
                        end;
                    1:
                        begin
                            mWorkState := _WS_MOVE_TO_LOADING_POS;
                            mFuncState := 0;
                            gLog.Panel('시작 전 리미트 설정 확인 완료');
                        end;
                end;
            end;

        _WS_MOVE_TO_LOADING_POS:    // 웨이트 안착을 위한 정렬 : 최후방까지 후진
            begin

                case FSMAlignMotor(pmtEach, true) of
                    -1:
                        begin
                            SetError('모터 정렬: ' + mMtrOper.CurMotor.mLstError, mMtrOper.CurMotor.mLstToDo);
                            gLog.Panel('모터 정렬 실패 ');
                            mWOrkState := _WS_WEIGHT_LOADING;
                        end;
                    1:
                        begin
                            gLog.Panel('%s: 웨이트 안착 위치 완료', [Name]);

                            mFuncState := 0;

                            if gSysEnv.rMotor.CanBurnish then
                            begin
                                gLog.Panel('%s: 버니싱 시작', [Name]);
                                mWorkState := _WS_BURNISHING;
                                UpdateForm(tw_BURNISHING_START);

                            end
                            else
                            begin
                                mLIO.SetIO(mLDOChs.mWeightLodingReq, True);
                                //mWorkState := _WS_WEIGHT_LOADING;
                                mWorkState := _WS_MEMORY_TEST;
                            end;
                        end;
                end;
            end;

        _WS_BURNISHING:
            begin

                case mMtrOper.FSMBurnishing(False) of
                    -1:
                        begin
                            SetError('버니싱: ' + mMtrOper.CurMotor.mLstError, mMtrOper.CurMotor.mLstToDo);
                        end;
                    1:
                        begin
                            UpdateForm(tw_BURNISHING_END);
                            mLIO.SetIO(mLDOChs.mTestReady, True);
                            mFuncState := 0;
                            mWorkState := _WS_WEIGHT_LOADING;

                        end;
                end;
            end;

        _WS_WEIGHT_LOADING:
            begin

                case FSMWaitForWeightLoadDone of
                    -1:
                        begin
                            SetError('웨이트 안착 실패', '장비를 점검하세요');
                            gLog.Panel('웨이트 안착 실패');
                        end;
                    1:
                        begin
                            mFuncState := 0;
                            mWorkState := _WS_MOTOR_TEST;
                            mMtrOper.ClearFSM;
                            mMtrOper.ReverseMotorsDir;
                            mLIO.SetIO(mLDOChs.mWeightLodingReq, false);

                            UpdateForm(tw_MEAS_START);
                            gLog.Panel('%s: 모터 검사 시작', [Name]);

                        end;
                end;
            end;

        _WS_MOTOR_TEST:
            begin
                case mMtrOper.FSMTest(true, MtrOrdHi) of
                    -1:
                        begin
                            SetError(mMtrOper.CurMotor.mLstError, mMtrOper.CurMotor.mLstToDo);
                        end;
                    1:
                        begin
                            gLog.Panel('%s: 모터 검사 완료', [Name]);
                            mMtrOper.ClearFSM;
                            mFuncState := 0;

                            if mCurModelType.IsIMS then
                            begin
                                mWorkState := _WS_CHK_LIMIT_STATUS_END;
                                gLog.Panel('종료 후 리미트 설정 확인 완료');

                            end
                            else
                            begin
                                mWorkState := _WS_DTC_CLEAR;
                                gLog.Panel('DTC 클리어 시작 ');

                            end;

                        end;
                end;
            end;

        _WS_CHK_LIMIT_STATUS_END:
            begin
                case mMtrSlide.FSMReadLimitStatus of
                    -1:
                        begin
                            SetError('리미트 설정 확인 실패', '장비를 점검하세요');

                            gLog.Panel('리미트 설정 확인 실패');
                        end;
                    1:
                        begin

                            mWorkState := _WS_MOVE_TO_UNLOADING_POS;

                            for MtrIt := Low(TMotorORD) to High(TMotorORD) do
                            begin
                                mDBX.RsBuf.rCurMtr := MtrIt;
                                mDBX.SetData(roRsLimit, mMotors[MtrIt].IMSCtrler.GetLimit(MtrIt));
                            end;

                            if mCurModelType.IsIMS then
                            begin
                                mMemTestState := _MEM_INIT;
                                gLog.Panel('언로딩 완료 :메모리 테스트 시작 ');
                                mWorkState := _WS_MEMORY_TEST;

                            end
                            else
                            begin
                                mWorkState := _WS_DTC_CLEAR;
                                gLog.Panel('DTC 클리어 시작 ');

                            end;

                            UpdateForm(tw_LIMIT_READED);

                            gLog.Panel('종료 후 리미트 설정 확인 완료');
                        end;
                end;
            end;

        _WS_MEMORY_TEST:
            begin
                case FSMTestMemory of
                    -1:
                        begin
                            SetError('메모리 테스트 실패', '제품 상태를 확인하세요');
                            mWorkState := _WS_WAIT_ALL_TEST_END;
                            UpdateForm(tw_MEMORY_END);
                        end;
                    1:
                        begin
                            gLog.Panel('%s: 메모리 테스트 완료', [Name]);
                            // MEM1, MEM2 결과는 이미 저장됨
                            mWorkState := _WS_DTC_CLEAR;
                            UpdateForm(tw_MEMORY_END);
                        end;
                end;

            end;

        _WS_DTC_CLEAR:
            begin
                case FSMDTCReader of
                    -1:
                        begin
                            mDBX.SetData(roRsDTCClear, false);
                            UpdateForm(tw_DTC_CLEAR_END);
                            mWorkState := _WS_MOVE_TO_UNLOADING_POS;
                            mElecState := _WS_ELEC_START;
                        end;
                    1:
                        begin
                            mDBX.SetData(roRsDTCClear, true);
                            UpdateForm(tw_DTC_CLEAR_END);
                            mWorkState := _WS_MOVE_TO_UNLOADING_POS;
                            mElecState := _WS_ELEC_START;

                            // FSMAlignMotor 호출 전에 모터 방향을 언로딩 위치로 명확하게 재설정
                            mFuncState := 0;
                            mMtrOper.Init([mMtrSlide, mMtrTilt, mMtrHeight, mMtrLegSupt, mMtrSwivel], [twBack, twBack, twForw, twBack, twBack]);
                            mMtrOper.ClearFSM;
                        end;
                end;

            end;

        _WS_MOVE_TO_UNLOADING_POS:
            begin
                case FSMAlignMotor(pmtEach, True) of
                    -1:
                        SetError('모터 언로딩 위치 정렬: ' + mMtrOper.CurMotor.mLstError, mMtrOper.CurMotor.mLstToDo);
                    1:
                        begin
                            gLog.Panel('%s: 모터 언로딩 위취 정렬 완료', [Name]);
                            mWorkState := _WS_WEIGHT_UNLOADING;
                            mLIO.SetIO(mLDOChs.mWeightUnLodingReq, true);
                            UpdateForm(tw_UNLOADING);
                        end;
                end;
            end;

        _WS_WEIGHT_UNLOADING:
            begin
                if mLIO.IsIO(mLDIChs.mWeightUnLodingOK) then
                begin
                    mMtrOper.ClearFSM;
                    mFuncState := 0;
                    mLIO.SetIO(mLDOChs.mWeightUnLodingReq, false);

                    gLog.Panel('%s: 웨이트 언로딩 완료, 납품 위치 센서 요청 ', [Name]);

                    mWorkState := _WS_REQ_D_POS_SENSOR;
                    mFuncState := 0;
                    mLIO.SetIO(mLDOChs.mReqDPosSensorReady, true);

                end;
            end;

        _WS_REQ_D_POS_SENSOR:
            begin
                if mLIO.IsIO(mLDIChs.mDPosSensorReady) then
                begin
                    mWorkState := _WS_MOVE_TO_D_POS;
                    mLIO.SetIO(mLDOChs.mReqDPosSensorReady, false);

                    gLog.Panel('%s: 납품 위치 센서 확인 완료 , 납품 위치로 이동 시작', [Name]);

                end;

            end;

        _WS_MOVE_TO_D_POS:
            begin
                case FSMMoveToOutPos of
                    -1:
                        begin
                            SetError('납품위치 이상', '모터 상태나 납품위치 센서를 점검하세요');
                        end;
                    1:
                        begin
                            //mLIO.SetIO(mLDOChs.mDPosMoveDone, True);

                            mFuncState := 0;
                            mWorkState := _WS_WAIT_ALL_TEST_END;
                            mLIO.SetIO(mLDOChs.mReqDPosSensorRelease, true);
                            gLog.Panel('%s: 납품 위치 이동 완료 , 납품 위치로 이동 시작', [Name]);

                        end;
                end;
            end;

        _WS_WAIT_ALL_TEST_END:
            begin
                if not mLIO.IsIO(mLDIChs.mDPosSensorReleased) then
                    Exit;

                mLIO.SetIO(mLDOChs.mReqDPosSensorRelease, false);

                if (mElecState = _WS_ELEC_END) and IsNextTsWorkStable then
                begin
                    mWorkState := _WS_SAVE_DATA;
                end
            end;

        _WS_SAVE_DATA:
            begin
                TDataBox.mDebug := True;
                bTm := mDBX.GetResult(roNO);
                TDataBox.mDebug := False;

                mLIO.SetIO(mLDOChs.mOK, bTm);
                mLIO.SetIO(mLDOChs.mNOK, not bTm);

                SaveResult();

                mPopState := 0;
                mFuncState := 0;
                mWorkState := _WS_WAIT_POP_SEND;

            end;

        _WS_WAIT_POP_SEND:
            begin
                if not PopWorkProcess() then
                    Exit;

                mPop.Initial;
                mWorkState := _WS_STOP_PWR;
            end;

        _WS_STOP_PWR:
            begin
                gDCPower.Items[0].PowerOFF(true);
                mWorkState := _WS_END_OF_TEST;

            end;

        _WS_END_OF_TEST:
            begin

            end;

        _WS_ERROR:
            begin

                if mLstError <> '' then
                    gLog.Error('%s: Err 메시지: %s', [Name, mLstError]);
                gLog.Panel('%s: Err 상태시: %s', [Name, GetStateStr]);
                gLog.Panel('%s: Err 상태시: 설정 전압:%f(V), 설정 전류:%f(A), 메인 전류: %f(A)', [Name, GetOutVolt, GetOutCurr, GetMainCurr]);

                StopMotors;
                ClearElecDOs;
                mDCPower.SetCurr(1.0);

                mLIO.SetIO(mLDOChs.mAlarm, True);

                mWorkState := _WS_ERROR_IDLE;

                UpdateForm(tw_ERROR);
            end;

        _WS_ERROR_IDLE:
            ;
    else
        mLstError := '모듈 프로세서 오류';
        mLstToDo := '프로그램을 다시 시작하세요';
        gLog.Panel('%s: 모듈프로세서 오류 %d', [Name, Ord(mWorkState)]);

        UpdateForm(tw_ERROR);
        mWorkState := _WS_ERROR;
    end;
end;

function TTsWork.FSMWaitForWeightLoadDone: Integer;
begin
    Result := 0;

    case mFuncState of
        0:
            begin

                if mLIO.IsIO(mLDIChs.mWeightLodingOK) then
                begin
                    Inc(mFuncState);
                    mDelayTC.Start(gSysEnv.rSoundProof.rWaitB4WeightUnLoading * 1000);
                    gLog.Panel('%s: 모터 검사 시작 신호 ON', [Name])
                end;
            end;
        1:
            begin
                if mTC.IsTimeOut() then
                begin
                    mFuncState := 0;
                    Exit(1);
                end;
            end;
        2:
            begin

            end;
    end;
end;

function TTsWork.FSMWaitForWeightUnLoadDone: Integer;
begin
    Result := 0;

    case mFuncState of
        0:
            begin

                if mLIO.IsIO(mLDIChs.mWeightUnLodingOK) then
                begin
                    Inc(mFuncState);
                    mDelayTC.Start(gSysEnv.rSoundProof.rWaitB4WeightUnLoading * 1000);
                    gLog.Panel('%s: 웨이트 언로딩 완료: 메모리 검사 시작', [Name])
                end;
            end;
        1:
            begin
                if mTC.IsTimeOut() then
                begin
                    mFuncState := 0;
                    Exit(1);
                end;
            end;
        2:
            begin

            end;
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
            continue; // 사용안하는 모터 걸러내기 ex>CushExt

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

function TTsWork.GetSHVUCurr: double;
begin
    Result := mAD.GetValue(AI_SHVU1);
end;

function TTsWork.GetStateStr(IsSimple: Boolean): string;
begin
    Result := inherited GetStateStr + Format(' mWorkState=%d, mSpecChkState=%d, mElecState=%d, mFuncState=%d', [ord(mWorkState), Ord(mSpecChkState), ord(mElecState), ord(mFuncState)]);
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

function TTsWork.HgtMtrStopCond(Motor: TSeatMotor): boolean;
begin
    Result := False; // 기본적으로는 정지하지 않음

    if Motor.ID = tmHeight then
    begin
        if GetDistance1 > 75 then
        begin
            Result := True; // 센서가 감지되면 True를 반환하여 모터를 정지
        end;
    end;

end;

procedure TTsWork.HVTestStatus(HVTest: THVTest; TestStatus: THVTestStatus);
var
    RO: TResultORD;

    function HVStepToRO(Step: Integer): TResultOrd;
    begin
        case Step of
            3:
                Result := roDatLedHiBit;
            2:
                Result := roDatLedMidBit;
            1:
                Result := roDatLedLoBit;
        else
            Result := roDatLedOffBit;
        end;
    end;

begin
    mCurHVTest := HVTest;
    mDBX.RsBuf.rCurHVPos := HVTest.PosType;
    mDBX.RsBuf.rCurHVTestType := HVTest.TestType;

    case TestStatus of
        hvsTestStart:
            UpdateForm(tw_HV_TEST_START);
        hvsStepStart:
            begin
                UpdateForm(tw_HV_STEP_START);
            end;
        hvsStepEnd:
            begin
                RO := HVStepToRO(HVTest.CurStep);
                mDBX.SetData(RO, HVTest.GetCurLedData); // LED Bit Data 설정

                if HVTest.UseCurrTest then
                begin
                    if HVTest.CurStep = HVTest.CurrRStep then // 설정한 단에서 ON 전류 설정
                    begin
                        mDBX.SetData(roDatOnCurr, HVTest.MaxCurr);

                    end
                    else if HVTest.CurStep = 0 then // 0단에서 OFF전류 설정
                    begin
                        mDBX.SetData(roDatOffCurr, Max(0, HVTest.OffCurr));
                    end;

                    // H/V NG발생시 중단 여부
                    //if not mDBX.GetResult(roDatHeatOnCurrDrv) and gsysEnv.rIsNGStop then
                    //begin
                    //    mHVTester.FSMStop;
                        //mElecState := _PROC_ELEC_STOP;    임시
                    //end;
                end;

                UpdateForm(tw_HV_STEP_END);
            end;

        hvsTestEnd:
            begin
                // if HVTest.PosType = hvpPsg then
                if HVTest.DevType = hvdVentDrv then
                    UpdateForm(tw_HV_TEST_END);

                // HEAT LED NG시 재시험  임시
                {
                if not HVTest.UseCurrTest then
                begin
                    RO := GetLedRsRO(HVTest.DevType);
                    HVTest.IsRetest := not mDBX.GetResult(RO) and (mHVRetryCnt < 2);
                    if HVTest.IsRetest then
                    begin
                        UpdateForm(tw_HV_TEST_START);
                        Inc(mHVRetryCnt);
                    end;

                end;
                 }
            end;
    end;

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
        raise EListError.CreateFmt('TTsWork.GetConnectors: Idx %d가 범위 벗어남 (0..%d)', [Idx, mConnectors.Count - 1]);
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
        if i = ord(roRsAbnormalSound) then
            Result := Result;

        if IsCtrlRO(PopDataORD[i]) then
        begin
            mDBX.SetData(PopDataOrd[i], -1);
            continue;
        end;

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
                          ShowError(Format(_TRNS('LOT NO: %s의 데이터가 없습니다'), [rcvLotNo]), 'SEAT 정보를 확인 하세요')
                          else
                          begin
                          ShowError(Format(_TRNS('LOT NO: %s - #%d CELL 공정에서 NG 발생한 제품입니다'), [rcvLotNo, StrToInt(rcvWorkDetail) - 2]), '작업할 수 없습니다');
                          end;
                          }
                        // 작업 유무 에러 표시 또는 진행 후 POP 송신 안 함??
                        // UpdateForm(tw_HIDE_MSG);
                    end
                    else if rcvWorkType = '1' then
                    begin
                        {
                          if not RsBuf.rModel.rTypes.IsLimit then
                          begin
                          ShowMsg('직구동 제품입니다', '메인 케이블과 직구동 S/W 케이블을 꽂으세요');
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
                    gLog.Panel('%s: (PC)POP전송작업완료확인', [Name]);
                end;
            end;
        SYS_POP_CONNECTED, SYS_POP_CONNECTING, SYS_POP_DISCONNECTED, SYS_CMD_RCV_ERROR:
            begin
                if mPopState = 2 then
                begin
                    mPopState := 3;
                    gLog.Panel('%s: (PC)POP전송작업실패', [Name]);
                end;
            end;
        // SYS_CMD_RCV_NAK
    end;
end;

function TTsWork.GetMotorCurr(Motor: TMotorOrd): Double;
begin
{$IFDEF _USE_PWS_CURR}
    Result := gDcPower.Items[0].MeasCurr;
    Exit;
{$ENDIF}
    Result := mMotors[Motor].GetCurr;

end;

function TTsWork.GetMotors(Mtr: TMotorOrd): TSeatMotor;
begin
    // TMotorOrd는 이미 타입 안전하므로 범위 체크 생략 가능
    if not Assigned(mMotors[Mtr]) then
    begin
        ShowMessage(Format('모터[%d]가 초기화되지 않음', [Ord(Mtr)]));
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
{$IFDEF VIRTUALIO}
    Result := random * 0.5;
{$ELSE}
    Result := mAD.GetValue(AI_MAIN_CURR);
{$ENDIF}
end;

function TTsWork.GetResistor: Single;
begin
    Result := mAT.GetValue(0);
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
                stm := GetPopDatas();
                gLog.Panel(stm);

                if not mPop.IsConnected or mPop.NotsndResult then
                begin
                    mPopState := 4;
                    gLog.Panel('(PC)POP전송작업통과(POP: %s, IO: %s, 작업: %s, PalletNO: %s)', [_ONOFF[mPop.IsConnected], _ONOFF[IsPopLinkMode], _ONOFF[IsRun], mDBX.GetResultToATxt(ord(roPalletNO), False, False)]);

                    if not IsPopLinkMode then
                    begin
                        gLog.Panel('통과이유: 단독운전모드.');
                    end
                    else if not mPop.IsConnected then
                    begin
                        gLog.Panel('통과이유: POP과 연결되지 않았습니다.');
                    end
                    else if mPop.NotsndResult then
                    begin
                        gLog.Panel('통과이유: POP 작업통과 설정 ON');
                    end
                    else if mDBX.IsExists(roPoprcved) then
                    begin
                        gLog.Panel('통과이유: POP 수신작업된 사양이 아닙니다.');
                    end
                    else if mDBX.GetResultToATxt(ord(roPalletNO), False, False) = '' then
                    begin
                        gLog.Panel('통과이유: POP 수신된 팔레트NO가 없습니다.');
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
                    gLog.Panel('%s: (PC)POP전송데이터추가: %s', [Name, stm]);
                end
                else
                begin
                    mPopState := 3;
                    gLog.Panel('%s: (PC)POP전송데이타추가실패: %s', [Name, stm]);
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

procedure TTsWork.ProcessMotorData(Motor: TSeatMotor);
begin
    mGrpExt[Motor.ID].BeginDataProcessing; // 위치 Fix!!


    TAsyncCalls.Invoke(
        procedure
        var
            GrpData: TSMGrpData;
            InitNoiseVal, RunNoiseVal: Double;  // ← 변수 선언 추가
        begin
            mCS.Enter;        // Invoke에서 동시에 호출시 재진입 금지
            try

                mGrpExt[Motor.ID].FindData(Motor.Dir, @GrpData);

                mDBX.SetData(GetDataRO('Speed', Motor.Dir), GrpData.mSpeed);
                mDBX.SetData(GetDataRO('Curr', Motor.Dir), GrpData.mCurr.GetVal(matMax)); // Max 취함
                mDBX.SetData(GetDataRO('InitNoise', Motor.Dir), GrpData.mInitNoise.GetVal(gSysEnv.rSoundProof.rNoiseResultType));
                mDBX.SetData(GetDataRO('RunNoise', Motor.Dir), GrpData.mRunNoise.GetVal(gSysEnv.rSoundProof.rNoiseResultType));

                mCurMotor := Motor;
                UpdateForm(tw_MTR_TEST_STOP);

                if not mDBX.GetResult(roRsMotor) and gSysEnv.rSoundProof.rStopOnNG then
                begin
                    mIsTestingNG := True;
                    mFuncState := 0;
                    mWorkState := _WS_MOVE_TO_UNLOADING_POS;
                end;
            finally
                mGrpExt[Motor.ID].EndDataProcessing;
                mCS.Leave;
            end;

        end).Forget;

end;

function TTsWork.IsAuto: Boolean;
begin
    Result := mLIO.IsIO(mLDIChs.mAutoMode);
end;

function TTsWork.GetNoise: double;
begin
    Result := mAD.GetValue(AI_NOISE);
end;

function TTsWork.GetDistance1: double;
begin
    Result := Abs(mAD.GetValue(AI_DISTANCE1));
end;

procedure TTsWork.SelfTest;
begin

    Exit;

    ShowMsg(['테스트 메시지' + Name], ['(1) 올바른 사양(모델 정보)인가요? POP 설정을 확인해 주세요'], True);

    Exit;

    ShowMsg(['테스트 메시지'], ['(1) 올바른 사양(모델 정보)인가요? POP 설정을 확인해 주세요', '(2) 제품 - 팔레트간 케이블들이 제대로 장착 되었나요?'#13'케이블 접불을 확인하세요', '(3) 전극 결합 및 핀상태가 양호한가요?', '(4) 멀티라인'#13'테스트입니다'], True);
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

function TtsWork.FSMTestVentSensor: integer;
begin
    Result := 0;

    case mVentSensorState of
        0:
            begin
                if mLIO.IsIO(mLDIChs.mVentSensor) then
                begin
                    gLog.Panel('통풍 센서 감지 성공');
                    mDBX.SetData(roRsFlowTest, true);
                    Inc(mVentSensorState);
                end
                else
                begin
                    mDBX.SetData(roRsFlowTest, false);
                end;

            end;
        1:
            begin

            end;

    end;

end;

function TTsWork.FSMTestElecPart: Integer;
begin
    Result := 0;
    case mElecState of
        _WS_ELEC_IDLE:
            ;
        _WS_ELEC_START:
            begin
                mPeriodicCanData.HVEnables(true);

                mHVTester.FSMStart;

                mElecState := _WS_ELEC_TEST_HV;
                mVentSensorState := 0;

            end;
        _WS_ELEC_TEST_HV:
            begin
                case mHVTester.FSMIRun of
                    -1:
                        begin
                            mElecState := _WS_ELEC_BUCKLE_START;
                            gLog.Error('H/V 검사 오류', []);

                            Exit(-1);
                        end;
                    1:
                        begin
//                            if mDBX.IsTested(tsJigBlow) then
//                            begin
//                                if mJigVentChkState < 3 then
//                                    mJigVentChkState := 3;
//                            end;

                            if mCurModelType.IsBuckle then
                            begin

                                mElecState := _WS_ELEC_BUCKLE_START;
                                gLog.Panel('H/V Test 완료');
                            end
                            else if mCurModelType.IsAnchorPT then
                            begin
                                mElecState := _WS_ELEC_APT_TEST;

                            end
                            else
                            begin
                                mElecState := _WS_ELEC_END;

                            end;
                        end;
                end;

                FSMTestVentSensor;

            end;

        _WS_ELEC_BUCKLE_START:
            begin

                if mDBX.IsTested(tsBuckle) then
                begin
                    gLog.Panel('%s: 버클 검사 시작', [Name]);
                    UpdateForm(tw_BUCK_TEST_START);
                    mBuckTester.FSMStart;
                    mElecState := _WS_ELEC_BUCKLE_TEST;
                end
                else
                begin
                    mElecState := _WS_ELEC_APT_TEST;
                end;

            end;

        _WS_ELEC_BUCKLE_TEST:
            begin
                case mBuckTester.FSMIRun of
                    -1, 1:
                        begin
                            mDBX.SetData(roRsBuckle, mBuckTester.IsOK);
                            if mBuckTester.TestType = btcurr then
                                mDBX.SetData(roDatBuckle, mBuckTester.Curr);
                            gLog.Panel('%s: 버클 검사 종료', [Name]);
                            UpdateForm(tw_BUCK_TEST_END);
                        end;
                end;

                if mBuckTester.IsStop then
                begin

                end;
            end;

        _WS_ELEC_APT_TEST:
            begin
                if mAPTTester.State = _RST_IDLE then
                begin
                    mAPTTester.FSMStart;
                    UpdateForm(tw_APT_START);
                end;

                case mAPTTester.FSMIRun of
                    -1: // 실패 (에러)
                        begin
                            mDBX.SetData(roDatAncPT, mAPTTester.ResistValue);
                            mDBX.SetData(roRsAncPT, False);
                            UpdateForm(tw_APT_END);
                            mElecState := _WS_ELEC_END;
                        end;
                    1: // 완료
                        begin
                            mDBX.SetData(roDatAncPT, mAPTTester.ResistValue);
                            mDBX.SetData(roRsAncPT, True);
                            gLog.Panel('%s: Anchor PT 테스트 완료 - OK (%.2f)', [Name, mAPTTester.ResistValue]);
                            mElecState := _WS_ELEC_END;
                            UpdateForm(tw_APT_END);

                        end;
                end;

            end;

        _WS_ELEC_END:
            mPeriodicCanData.HVEnables(false);

        _WS_ELEC_RUN_VENT:
            ;
        _WS_ELEC_ERROR:
            mPeriodicCanData.HVEnables(false);

        _WS_ELEC_ERROR_IDLE:
            ;
    end;

end;

const
            MEM_TEST_DELAY = 200;          // 지연 시간 (ms)
            MEM_MOVE_TIME = 2.5;           // 메모리 위치 이동 시간 (초)
            MEM_CURR_THRESHOLD = 0.3;      // 동작 감지용 전류 임계값 (A, 검토 필요)
            MEM_CURR_CHECK_TIME = 3.0;     // 전류 체크 최대 시간 (초, 3초로 설정)
            FAST_MONITOR_INTERVAL = 50;    // 빠른 모니터링 간격 (ms)
            FAST_MONITOR_COUNT = 40;       // 빠른 모니터링 최대 횟수 (2초相当)


function TTsWork.FSMTestMemory: Integer;
begin
    Result := 0; // 진행 중

    case mMemTestState of
        _MEM_INIT:
            begin
                gLog.Panel('%s: 메모리 테스트 초기화 (mMemTestState=%d)', [Name, Ord(mMemTestState)]);
                mPeriodicCanData.MemoryEnables(True); // IGN ON 등 활성화

                mMMA.Clear;
                mFuncState := 0; // 서브 FSM 초기화
                mLocalState := 0; // 카운터 초기화
                mTC.Stop;        // 타이머 초기화

                UpdateForm(tw_MEMORY_START);

                if not mCurModelType.IsIMS then
                begin
                    gLog.Panel('%s: 비IMS 사양 - 메모리 테스트 스킵', [Name]);
                    mMemTestState := _MEM_TEST_END;
                    Exit;
                end;

                mMemTestState := _MEM_MOVE_FOR_MEM1;
                gLog.Panel('%s: 첫 번째 전진 2.5초 시작 (MEM1 위치)', [Name]);
                UpdateForm(tw_MEM1_ARRANGE);

                mMtrSlide.ClearFSM;
            end;

        _MEM_MOVE_FOR_MEM1:
            begin
                case mMtrSlide.FSMMove(twForw, MEM_MOVE_TIME) of
                    -1:
                        begin
                            gLog.Error('%s: 첫 번째 전진 (MEM1 위치) 실패', [Name]);
                            mMemTestState := _MEM_ERROR;
                        end;
                    1:
                        begin
                            gLog.Panel('%s: 첫 번째 전진 완료 (MEM1 위치)', [Name]);
                            mMemTestState := _MEM_SAVE_MEM1;
                            UpdateForm(tw_MEM1_SAVE);
                        end;
                end;
            end;

        _MEM_SAVE_MEM1:
            begin
                case mMtrSlide.IMSCtrler.FSMSaveMemP1 of
                    -1:
                        begin
                            gLog.Error('%s: MEM1 저장 실패', [Name]);
                            mMemTestState := _MEM_ERROR;
                        end;
                    1:
                        begin
                            gLog.Panel('%s: MEM1 저장 완료', [Name]);
                            mTC.Start(1000);
                            mMemTestState := _MEM_MOVE_FOR_MEM2;
                            gLog.Panel('%s: 두 번째 전진 2.5초 시작 (MEM2 위치)', [Name]);
                            UpdateForm(tw_MEM2_ARRANGE);
                            mMtrSlide.ClearFSM;
                        end;
                end;
            end;

        _MEM_MOVE_FOR_MEM2:
            begin
                if not mTC.IsTimeOut then
                begin
                    Exit;
                end;

                case mMtrSlide.FSMMove(twForw, MEM_MOVE_TIME) of
                    -1:
                        begin
                            gLog.Error('%s: 두 번째 전진 (MEM2 위치) 실패', [Name]);
                            mMemTestState := _MEM_ERROR;
                        end;
                    1:
                        begin
                            gLog.Panel('%s: 두 번째 전진 완료 (MEM2 위치)', [Name]);
                            mMemTestState := _MEM_SAVE_MEM2;
                            UpdateForm(tw_MEM2_SAVE);
                        end;
                end;
            end;

        _MEM_SAVE_MEM2:
            begin
                case mMtrSlide.IMSCtrler.FSMSaveMemP2 of
                    -1:
                        begin
                            gLog.Error('%s: MEM2 저장 실패', [Name]);
                            mMemTestState := _MEM_ERROR;
                        end;
                    1:
                        begin
                            gLog.Panel('%s: MEM2 저장 완료', [Name]);
                            mTC.Start(2000);
                            mMemTestState := _MEM_PLAY_MEM1;
                            UpdateForm(tw_MEM1_PLAY);
                            mFuncState := 0; // FSMPlayAndCheckMemory 초기화
                        end;
                end;
            end;

        _MEM_PLAY_MEM1:
            begin
                if not mTC.IsTimeOut then
                begin
                    Exit;
                end;

                case mMtrSlide.IMSCtrler.FSMPlayMemP1 of
                    -1:
                        begin
                            gLog.Error('%s: MEM1 플레이 실패', [Name]);
                            mMemTestState := _MEM_ERROR;
                        end;
                    1:
                        begin
                            gLog.Panel('%s: MEM1 플레이 및 감지 완료', [Name]);
                            mTC.Start(2000);
                            mMemTestState := _MEM_PLAY_MEM2;
                            UpdateForm(tw_MEM2_PLAY);
                            mFuncState := 0;
                        end;
                end;
            end;

        _MEM_PLAY_MEM2:
            begin
                if not mTC.IsTimeOut then
                begin
                    Exit;
                end;


                case mMtrSlide.IMSCtrler.FSMPlayMemP2 of
                    -1:
                        begin
                            gLog.Error('%s: MEM2 플레이 실패', [Name]);
                            mMemTestState := _MEM_ERROR;
                        end;
                    1:
                        begin
                            gLog.Panel('%s: MEM2 플레이 및 감지 완료', [Name]);
                            mMemTestState := _MEM_TEST_END;
                        end;
                end;
            end;

        _MEM_TEST_END:
            begin
                gLog.Panel('%s: 메모리 테스트 전체 완료', [Name]);
                mPeriodicCanData.MemoryEnables(False);
                UpdateForm(tw_MEMORY_END);
                mMemTestState := _MEM_INIT;
                mFuncState := 0;
                mLocalState := 0;
                mTC.Stop;
                Result := 1; // 전체 완료
            end;

        _MEM_ERROR:
            begin
                gLog.Error('%s: 메모리 테스트 에러 발생', [Name]);
                mPeriodicCanData.MemoryEnables(False);
                mMemTestState := _MEM_INIT;
                mFuncState := 0;
                mLocalState := 0;
                mTC.Stop;
                mLstError := '메모리 테스트 에러';
                mLstToDo := '제품 및 장비 상태 확인';
                Result := -1; // 에러
            end;
    end;
end;

function TTsWork.FSMDTCReader: integer;
begin
    Result := 0;

    case mDTCState of
        0:
            begin
                mRetryCount := 0;
                mDTCReader.ClearFSM;
                Inc(mDTCState);
            end;
        1:
            begin

                case mDTCReader.FSMClear of
                    -1:
                        begin
                            gLog.Error('DTC 삭제 응답 오류', []);
                            mDTCState := 0;
                            Exit(-1);
                        end;
                    1:
                        begin
                            gLog.Panel('DTC 삭제 전송 완료');
                            mDTCReader.ClearFSM;
                            Sleep(300);
                            Inc(mDTCState);
                        end;
                end;
            end;
        2:
            begin
                if mCurModelType.IsHI then
                    Exit(1);

                case mDTCReader.FSMRead of
                    -1:
                        begin
                            Inc(mRetryCount);
                            if mRetryCount > 3 then
                            begin
                                mDTCState := 0;
                                Exit(-1);
                            end
                            else
                            begin
                                Inc(mDTCState);
                                gLog.Panel('DTC Clear - 재시도(%d)', [mRetrycount]);
                                mDelayTC.Start(1000);
                            end;

                        end;
                    1:
                        begin
                            gLog.Panel('DTC 제거 확인 OK: %s', [mDTCReader.CurFrame.ToStr]);
                            mDTCState := 0;
                            Exit(1);

                        end;
                end;

            end;
        3:
            begin
                if mDelayTC.IsTimeOut then
                begin
                    mDTCReader.ClearFSM;
                    mDTCState := 1;
                end;
            end;
    end;
end;

end.

