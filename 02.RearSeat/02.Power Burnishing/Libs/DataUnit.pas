{ Ver.240826.00 }
unit DataUnit;
{
  '▶' '◀' ① ②  ◎ ◆
  Angle : °, ±kgf·cm
  부하는 IN 으로 무부하는 OUT으로 통일...
}

{$INCLUDE myDefine.inc}

interface

uses
    Windows, Sysutils, Graphics, Classes, Messages, FaGraphEx, IniFiles, Range,
    Generics.Collections, Dialogs, myUtils, KiiMessages, Grids, Global, Forms,
    ModelType, SeatMotorType, HVTester, ExtCtrls, DB, CheckLst, SeatType, Spec,
    DataUnitOrd;

type
    // 통신포트 구별자
    TDevComORD = (dcPS_01);

    TDevCanORD = (dcCAN_01, dcCAN_02);

    TStationID = (st_Limit);

    TMsgData = packed record
        mCaption, mMsg1, mMsg2: string;
        mTime: Integer;
        mDlgType: TMsgDlgType;

        procedure Init(Caption, Msg1: string; Msg2: string = '');
    end;

    TTsOrdJudge = packed record
        mTsOrd: TTsORD;
        mJudge: TResultJudge;

        function GetJudgeStr: string;
    end;

    TTsOrdJudgeList = class(TList<TTsOrdJudge>)
    public
        function IndexOf(Item: TTsORD): Integer;
        function Add(Item: TTsOrdJudge): Integer;
    end;


{==============================================================================}
{   Spec                                                                       }
{==============================================================================}

    PMotorSpec = ^TMotorSpec;

    TMotorSpec = packed record  // sizeof=100
        rCurr: TSpec;
        rSpeed: array[TMotorDir] of TSpec;
        rTime: TSpec;
        rStrokeAmount: TSpec;   // 행정량 -> 펄스 or 거리

        rInitNoiseTime, rInitNoise,             // 소음은 Max (이하.)
        rRunNoise, rInitNoiseDev,          // 소음 편차
        rRunNoiseDev, rCurrDev: Single;

        rAngle: array[TMotorDir] of TSpec; // 모터 움직임에 따른 부품 각도 스펙 (리클 전용이나 훗날 모르니까 공용화)

        rREM: array[0..23] of BYTE;

        procedure Init;
    end;

    TAntiPinchSpec = packed record
        rLoad: TSpec;
        rStopCurr, rRisingcurr: Single;

        rREM: array[0..30] of BYTE;

        procedure Init;
    end;


    TSpecs = packed record
        rMotors: array[TMotorOrd] of TMotorSpec;
        rOnCurr: array[THVTestType] of TSpec;
        rOffCurr: array[THVTestType] of TSpec;

        rAntiPinch: array[TAP_TYPE] of TAntiPinchSpec;

        rBuckle: TSpec;

        procedure Init;

        function ToMotorStr(MtrOrd: TMotorOrd; RO: TResultOrd; IsUnit: Boolean = False): string; overload;
        function ToAPStr(APType: TAP_TYPE; RO: TResultOrd; IsUnit: Boolean = False): string; overload;
        function ToStr(RO: TResultOrd; IsUnit: Boolean = False): string; overload;
    end;

    TAlignConstraints = packed record
        rUse: Boolean;
        rDirection: TMotorDir;
        rOperTime: Single;
    end;

    // 모터 작동시  제약 조건, 시간, 거리, 구속전류
    TMotorConstraints = packed record
        rAlign: TAlignConstraints; // 마지막 정렬&납품위치 설정 조건
        rMaxTime: Single; // 작동 알람용 시간
        rStroke: Single; // 속도 계산을 위한 최대 작동 거리.
        rBurnishingCount: Integer;  // 버니싱 횟수 설정

        rMethodIdx: Byte;

        function IsMoveByTime: Boolean;

        case Integer of
            0:
                (rLockedCurr: Single;
                rOperTime: Single;);
            1:
                (mOperItems: array[0..1] of Single;)

    end;

    PMotorConstraints = ^TMotorConstraints;

    TDataSetRWEvent = function(DataSet: TDataSet): Boolean of object;


{==============================================================================}
{   Model                                                                      }
{==============================================================================}

    PModel = ^TModel;

    TModel = packed record // sizeof = 1000
        rIndex: WORD;       // Spec Index를 지정

        rTypes: TModelType;

        rPartName: string[50];
        rPartNo: string[30];
        rLclPartNo: string[30];     // Local PartNo : 납품 회사에서 사용하는 자체적 품번이 있을경우 사용

        rSpecs: TSpecs;

        rSPITypeBits: DWORD;        // Seat Pin Info TypeBits: 핀정보 객체의 ID(Key)역활

        rREM: array[0..280] of BYTE;

        function IsEmpty: Boolean;

        // UI
        procedure Write(Strings: TStrings; StartCol: Integer = 0); overload;

        procedure ReadAsType(PosRG, CarTypeRG, SeatTypeRG, DrvTypeRG: TRadioGroup);
        procedure ReadAsOpt(ChkListBox: TCheckListBox);

        procedure WriteAsType(PosRG, CarTypeRG, SeatTypeRG, DrvTypeRG: TRadioGroup);
        procedure WriteAsOpt(ChkListBox: TCheckListBox);

        // DB
        procedure Read(DataSet: TDataSet; RWEvent: TDataSetRWEvent = nil);
        function Write(DataSet: TDataSet; IsAppend: Boolean = False; RWEvent: TDataSetRWEvent = nil): Boolean; overload;

    end;




{==============================================================================}
{   실적 Data                                                                  }
{==============================================================================}

    PResult = ^TResult;

    TMotorTestItem = packed record
        rTime, rCurr, rSpeed, rInitNoise, rRunNoise, rInitNoiseDev, rRunNoiseDev, rStrokeAmount, rAngle: Single;
        rContinuity: Boolean; // 단순 모터 회로 단락 검사 합불여부

        rREM: array[0..10] of BYTE;

    end;

    TMotorData = packed record // sizeof = 128
        rItems: array[TMotorDir] of TMotorTestItem;
        rLimit: Boolean;
        rREM: array[0..30] of BYTE;

        procedure Clear;
    end;

    PMotorData = ^TMotorData;

    TImsData = packed record // sizeof = ??
        rMEM1, rMEM2, rMEM3, rEasyAccess: Boolean;
        rREM: array[0..12] of BYTE;
    end;

    TMemPosData = packed record
        rOrg, rMove: array[TMotorOrd] of Integer;
    end;

    THVData = packed record // sizeof = ??
        rOnCurr, rOffCurr: Single;
        rLedOffBit, rLedHiBit, rLedMidBit, rLedLoBit: BYTE;
        rREM: array[0..10] of BYTE;
    end;

    PHVData = ^THVData;

    THVDatas = array[THVPosType, THVTestType] of THVData;

    TEcuInfo = packed record
        rPartNo: string[20];
        rSwVer: string[20];
        rHwVer: string[20];

        constructor Create(const APartNo, ASwVer, AHwVer: string);

        function ToStr: string;
        function Equals(const Other: TEcuInfo): Boolean;

        function ComparePartNo(const Target: string): Boolean;
        function CompareSwVer(const Target: string): Boolean;
        function CompareHwVer(const Target: string): Boolean;
    end;

    PEcuInfo = ^TEcuInfo;

    TAntipinchData = packed record
        rLoad, rStopCurr, rRisingCurr: Single;

        rREM: array[0.. 15] of Single;
    end;

    PAntiPinchData = ^TAntipinchData;

    TResult = packed record // sizeof = ??
        rValidity: array[TTsORD] of Boolean; // 단일 합/불 검사
        rExists: array[TTsORD] of Boolean; // 데이타 유/무.
        rTested: array[TTsORD] of Boolean; // 검사대상여부
        rFileTime: Double; // 일일작업시간에 의한 일자 + 실제시간
        rLastTime: Double; // 실제작업일 + 저장시간. -> Lot No 기준

        rLotNo: string[20];     // Serial
        rPalletNO: string[15];

        rModel: TModel;
        rMcNo: BYTE;

        rCurMtr: TMotorOrd;
        rDatMtrs: array[TMotorOrd] of TMotorData;

        rAbnormalSound: Boolean;

        rCurHVPos: THVPosType;
        rCurHVTestType: THVTestType;
        rDatHVs: THVDatas;
        rFlow: Boolean; //풍향계나 레이저 류로 실제 바람이 부는지 체크.

        rDatIMS: TImsData;
        rDatMem1Pos, rDatMem2Pos, rDatMem3Pos, rDatEasyAccPos: TMemPosData;

        rBuckleVal,             // 버클 값(전류)
        rCenterBuckleVal,
        rDatNoise: Single;      // 검사 시간내 소음 체크(옵션)

        rSpareVals: array[0..10] of Single;

        rCurECU: TECU_TYPE;
        rEcuInfoSpec: array[TECU_TYPE] of TEcuInfo;
        rEcuInfo: array[TECU_TYPE] of TEcuInfo;


        rCurAPSeat: TAP_TYPE;
        rDatAPs: array[TAP_TYPE] of TAntipinchData;

        rDTC: Boolean;

        rCycleTime: Double;

        rSeatBCs: string[50];
        rIsRework: Boolean;

        rShowNGDebug: Boolean;

        rBCFilePos: Integer;        // BCResult File Pos.

        rMidPos: Boolean;

        rREM: array[0..442] of BYTE;

        function GetDatCurMtr: PMotorData;
        function GetDatCurHV: PHVData;
        function GetDatCurECU: PEcuInfo;
        function GetDatCurAP: PAntiPinchData;

        procedure Clear(IncModel: Boolean = True);

        procedure SetCurHVIdx(HVPos: THVPosType; HVTestType: THVTestType);

        function ModelToStr(RO: TResultOrd; IsUnit: Boolean = False): string;

        property CurDatMtr: PMotorData read GetDatCurMtr;
        property CurDatHV: PHVData read GetDatCurHV;
        property CurDatECU: PEcuInfo read GetDatCurECU;
        property CurDatAP: PAntiPinchData read GetDatCurAP;

    end;

    // ------------------
    TFaGRAPH_ORD = (faStation1, faStation2);

    pFaGraphEnv = ^TFaGraphEnv;

    pColorList = ^TColorList;

    TColorList = array[0..7] of TColor;

    TFaGraphEnv = packed record // size of 128
        rID: Integer;
        rXMax, rXMin, rXStep, rYMax, rYMin, rYStep: Double;
        rSpecLine: TColorList; // spec Line
        rDataLine: TColorList; // Data Line
        // rModel   : Integer ; // ModelID [1, 2]
        rREM: array[0..11] of BYTE;
    end;

    TSpcEnv = packed record // 36 byte
        rSPCUCL, rSPCLCL, rSPCCL: Double;

        rstdXbar: Integer; // 군크기...
        rMethod: Integer; // 0: Use spec(internal), 1: User Input(External)
        rstdExAver: array[0..7] of Boolean;
    end;

    TDeliveryPos = packed record
        rUse: Boolean;
        rPos: BYTE; //0 : Forw, 1: Back, 2: Time : 최전방, 최후방, 시간(거리)
        rWay: TMotorWayOrd;

        function GetDir(): TMotorWayOrd;
        function GetTime(): Double;
        function InRange(Val: Double; Margin: Double = 0): Boolean;

        case Integer of
            0:
                (rTime: Double;  // 시간 또는 거리
                rMax: Double;
                rTemp: Double);
            1:
                (rMin: Double;
                rMax2: Double;
                rTemp2: Double);
            2:
                (rDist: Double;
                rMax3: Double;
                rTemp3: Double);

    end;    // record 유니온시 end 하나만 !!!   , rTime, rMin, rDist가 같은 공간 다른 이름

    TMotorDeliveryPos = packed record // sizeof 350
        rTypeBits: DWORD;
        rMotors: array[False..True, 0..3] of TDeliveryPos;
        rMEM2: array[0..2] of TDeliveryPos; // 2013.06.20 승,하차문제로 납품위치를 메모리 위치로 사용함.
        rSelect: Boolean; // 2013.06.20 False -> MEM1, True -> MEM2
        rREM: array[0..220] of BYTE;
    end;

    TUsrCount = packed record
        rTime: Double;
        rCount: array[0..1, False..True] of Integer; // 설비번호,양/불
    end;


    // Dir & files
    TUsrDir_ORD = (udHOME, udENV, udGRAPH, udRESULT, udTEMP, udSPC, udRS, udDATA, udGRP_DATA, udGRP);

    TUserChs = (ucHeat, ucVent, ucBuckle, ucAPLoad, ucAPStopCurr, ucAPRisingCurr, ucSP07, ucSP08, ucSP09, ucSP10, ucSP11, ucSP12, ucSP13, ucSP14, ucSP15, ucSP16, ucSP17, ucSP18, ucSP19, ucSP20);

    TOffset = packed record
        rVals: array[TUserChs] of Double;

        function GetHVOffset(HVTestType: THVTestType): Double;
    end;

    TOutPos = packed record
        rType: byte;
        rTime: single;
        rDir4Time: TMotorDir;
    public
        function GetDir(): TMotorDir;
        function GetTime(): single;
    end;

{==============================================================================}
{   TModels (모델 세부 데이터)                                                 }
{==============================================================================}

    TMotorOffsetItem = packed record
        rSpeed, rCurr,
        rInitNoise, rRunNoise,
        rStrokeAmount, rAngle: Single;

        rREM: array[0..10] of BYTE;
    end;


    TMotorOffset = packed record
        rVals: array[TMotorOrd, TMotorDir] of TMotorOffsetItem;
    end;

    PModels = ^TModels;

    POffset = ^TOffset;
    PMotorOffset = ^TMotorOffset;

    TModels = packed record // sizeof = ??
        rIndex: WORD;

        rTypes: TModelType;
        rPartName: string[63];
        rPartNo: string[63];

        rSpecs: TSpecs;
        rConstraints: array[TMotorOrd] of TMotorConstraints;

        rMtrOffset: array[0..MAX_ST_COUNT - 1] of TMotorOffset; // 설비별 분리
        rOffset: array[0..MAX_ST_COUNT - 1] of TOffset; // 설비별 분리


        rOutPos: array[TMotorOrd] of TOutPos;  // 배출 위치

        rRearSensorIdx: byte;            // 후방 정지 센서 Idx

        rREM: array[0..940] of BYTE;

    end;

    TOutPosInfo = packed record
        mType: Integer;                // 예비용 : 레이저? 끝단?
        mSensorIdx: Integer;                // 사용할 레이저 센서 Idx : 0:#13 1:#14 2: 모두
        mSpec: array[0..1] of TRange;           // 납품위치 레이저 거리 SPEC
        mDirs: array[TMotorOrd] of TMotorDir;     // 모터별 끝단 납품 위치

        function IsIn(Dis1, Dis2: Double): Boolean;
    end;

    TMdlExData = packed record
        mID: Integer;
        mTypeBits: DWORD;
        mOutPosInfos: array[TStationID] of TOutPosInfo;

        mSpare: array[0..20] of byte;

        constructor Create(ID: Integer; TypeBits: DWORD);
        function Write(FileHandle: Integer): Boolean;
        function ToKeyStr: string;
    end;


    // --------------------------------
    TTsModeORD = (tw_NONE, tw_INIT, tw_TEST_MODE, tw_POP_LINK_MODE, tw_POP_RCVD_MODEL, tw_PDT_LOADED, tw_START, tw_STOP, tw_END, tw_SAVE, tw_ARRANGE, tw_CON_CHK, tw_SPEC_CHK_START, tw_SPEC_CHK_END, tw_CHK_DISCONNECT, tw_FP_START, tw_FP_END, tw_INIT_POS_START, tw_INIT_POS_END, tw_CHECK_LOAD_RELEASE, tw_MEAS_START, tw_MEAS_STOP, tw_BURNISHING_START, tw_BURNISHING_CYCLE, tw_BURNISHING_END, tw_UNLOADING, tw_CHECK_ALL_TEST_END, tw_DELIVERY_START, tw_DELIVERY_END, tw_DELIVERY_PASS, tw_ERROR, tw_EMERGY, tw_ALARM, tw_STATUS, tw_MSG, tw_MSG2, tw_POP_PASS, tw_POP_START, tw_POP_END, tw_POWER_CHECK, tw_OTHER_PROC_END_CHECK,
            // -------------------------------
            // 모터
        tw_MTR_TEST_START, tw_MTR_TEST_STOP, tw_LIMIT_START, tw_LIMIT_READED, tw_LIMIT_DONE, tw_MOTOR_INIT,
            // -------------------------------
            // 메모리 검사
        tw_MEMORY_START, tw_MEMORY_END, tw_MEM1_PLAY, tw_MEM1_SAVE, tw_MEM1_ARRANGE, tw_MEM2_PLAY, tw_MEM2_SAVE, tw_MEM2_ARRANGE, tw_KEY_ON, tw_KEY_OFF, tw_KEY_ARRANGE,
            // -------------------------------
            //HV 검사
        tw_HV_TEST_START, tw_HV_STEP_START, tw_HV_STEP_END, tw_HV_TEST_END, tw_BLOW_START, tw_BLOW_END, tw_FAN_4_NOISE_START, tw_FAN_4_NOISE_END,
            // -------------------------------
        tw_BUCK_TEST_START, tw_BUCK_TEST_END, tw_BLUE_LINK, tw_HALL_SENSOR, tw_ABNML_SOUND, // 이음
        tw_BC_READED, tw_MECH_BC_READED, tw_PART_BC_READED, tw_MID_POS_OK, tw_CON_INFO_LOADED,     // 커넥터 정보 읽음
        tw_HIDE_MSG);

const
    umtWarning = mtWarning;
    umtError = mtError;
    umtInformation = mtInformation;
    umtConfirmation = mtConfirmation;
    umtCustom = mtCustom;
    _CO_SYMBOL = 'DAEWON.CO.LTD,.';

    { Graph Env }
    USR_COLOR = $00E0CBC5;
    ENV_FILE = 'Reference.ini';
    DIR_ENV = '\Env';
    DIR_RESULT = '\Result';
    DIR_SPC = '\SPC';
    DIR_TEMP = '\Temp';
    FILE_GRP = 'graph.env';
    FILE_HW = 'hardware.env';
    NG_TAG = '$';
    OK_TAG = '@';

    ARY_TAG: array[False..True] of string = (NG_TAG, OK_TAG);
    JUDGE_COLOR: array[False..True] of TColor = (clRed, COLOR_OK);
    JUDGE_COLOR2: array[False..True] of TColor = (clRed, clBlue);
    JUDGE_TXT: array[False..True] of string = ('NG', 'OK');
    OnNOff: array[False..True] of string = ('OFF', 'ON');
    GRP_EXT: array[ord(Low(TFaGRAPH_ORD))..ord(High(TFaGRAPH_ORD))] of string = ('공정1', '공정2');


    { 그래프 색상 구별 갯수 }
    ARY_DATA_LINE_COUNT: array[TFaGRAPH_ORD] of Integer = (4, 4);
    ARY_SPEC_LINE_COUNT: array[TFaGRAPH_ORD] of Integer = (4, 4);
    // 스펙 색상 : 2공정, 모터별 4

    DataGridORD: array[0..105] of TResultORD = (roIndex, roDate, roTime, roPartName, roCarType, roWayType, roPartNO, roLotNo, roMcNo, roNo,

        //--------------------------
        roRsAbnormalSound,


        //--------------------------
        // Slide
        roSpecFwSpeedHiLo,    // 전진 속도 스펙
        roDataFwSpeed,        // 전진 속도
        roSpecBwSpeedHiLo,    // 후진 속도 스펙
        roDataBwSpeed,        // 후진 속도
        roSpecInitNoiseHi,  // 초기 소음 소음 스펙
        roDataFwInitNoise,    // 전진 초기 소음
        roDataBwInitNoise,    // 후진 초기 소음
        roSpecRunNoiseHi,   // 작동 소음 스펙
        roDataFwRunNoise,     // 전진 작동 소음
        roDataBwRunNoise,     // 후진 작동 소음
        roSpecCurrHiLo,    // 전류 스펙
        roDataFwCurr,     // 전진 전류
        roDataBwCurr,     // 후진 전류
        roRsLimit,

        //--------------------------
        // Tilt
        roSpecFwSpeedHiLo,    // 전진 속도 스펙
        roDataFwSpeed,        // 전진 속도
        roSpecBwSpeedHiLo,    // 후진 속도 스펙
        roDataBwSpeed,        // 후진 속도
        roSpecInitNoiseHi,  // 초기 소음 소음 스펙
        roDataFwInitNoise,    // 전진 초기 소음
        roDataBwInitNoise,    // 후진 초기 소음
        roSpecRunNoiseHi,   // 작동 소음 스펙
        roDataFwRunNoise,     // 전진 작동 소음
        roDataBwRunNoise,     // 후진 작동 소음
        roSpecCurrHiLo,    // 전류 스펙
        roDataFwCurr,     // 전진 전류
        roDataBwCurr,     // 후진 전류
        roRsLimit,

        //--------------------------
        // Height
        roSpecFwSpeedHiLo,    // 전진 속도 스펙
        roDataFwSpeed,        // 전진 속도
        roSpecBwSpeedHiLo,    // 후진 속도 스펙
        roDataBwSpeed,        // 후진 속도
        roSpecInitNoiseHi,  // 초기 소음 소음 스펙
        roDataFwInitNoise,    // 전진 초기 소음
        roDataBwInitNoise,    // 후진 초기 소음
        roSpecRunNoiseHi,   // 작동 소음 스펙
        roDataFwRunNoise,     // 전진 작동 소음
        roDataBwRunNoise,     // 후진 작동 소음
        roSpecCurrHiLo,    // 전류 스펙
        roDataFwCurr,     // 전진 전류
        roDataBwCurr,     // 후진 전류
        roRsLimit,

        //--------------------------
        // LegSupt
        roSpecFwSpeedHiLo,    // 전진 속도 스펙
        roDataFwSpeed,        // 전진 속도
        roSpecBwSpeedHiLo,    // 후진 속도 스펙
        roDataBwSpeed,        // 후진 속도
        roSpecInitNoiseHi,  // 초기 소음 소음 스펙
        roDataFwInitNoise,    // 전진 초기 소음
        roDataBwInitNoise,    // 후진 초기 소음
        roSpecRunNoiseHi,   // 작동 소음 스펙
        roDataFwRunNoise,     // 전진 작동 소음
        roDataBwRunNoise,     // 후진 작동 소음
        roSpecCurrHiLo,    // 전류 스펙
        roDataFwCurr,     // 전진 전류
        roDataBwCurr,     // 후진 전류
        roRsLimit,

        //--------------------------
        // Swivel
        roSpecFwSpeedHiLo,    // 전진 속도 스펙
        roDataFwSpeed,        // 전진 속도
        roSpecBwSpeedHiLo,    // 후진 속도 스펙
        roDataBwSpeed,        // 후진 속도
        roSpecInitNoiseHi,  // 초기 소음 소음 스펙
        roDataFwInitNoise,    // 전진 초기 소음
        roDataBwInitNoise,    // 후진 초기 소음
        roSpecRunNoiseHi,   // 작동 소음 스펙
        roDataFwRunNoise,     // 전진 작동 소음
        roDataBwRunNoise,     // 후진 작동 소음
        roSpecCurrHiLo,    // 전류 스펙
        roDataFwCurr,     // 전진 전류
        roDataBwCurr,     // 후진 전류
        roRsLimit,

        //--------------------------
        // IMS
        roRsMem1, roRsMem2, roRsEasyAccess, // 승하차
        roRsIMS,

        //--------------------------
        // H/V
        // Drv Htr
        roSpecHeatOnHiLo, roDataOnCurr, roSpecHeatOffHiLo, roDataOffCurr,
        // Drv Vnt
        roSpecHeatOnHiLo, roDataOnCurr, roSpecHeatOffHiLo, roDataOffCurr,
        // Ass Htr
        roSpecHeatOnHiLo, roDataOnCurr, roSpecHeatOffHiLo, roDataOffCurr,
        // Ass Vnt
        roSpecHeatOnHiLo, roDataOnCurr, roSpecHeatOffHiLo, roDataOffCurr,


        // 버클
        roSpecBuckleHiLo, roDataBuckle,


        // ECU Info
        roDataEcuPartNo, roDataEcuSwVer, roDataEcuHwVer);
    PopDataORD: array[0..10] of TResultORD = (roIndex, roDate, roTime, roPartNo, roLotNo, roNo, roNone, roNone, roNone, roNone,
        // ---------------------------------------------------
        // 모터 검사
        // ---------------------------------------------------

                // 이음
        roRsAbnormalSound);

procedure sysEnvUpdates;

function GetUsrDir(aType: TUsrDir_ORD; aSrc: TDatetime; IsCreate: Boolean = True): string; // result is Home\%s\%s...

function GetResultFileName(ATime: TDatetime; IsCreate: Boolean = True): string; overload;

function GetResultFileName(aTime: TDateTime; Ext: string; IsCreate: Boolean = True): string; overload;

function GetTempFileName(aName: string; IsCreate: Boolean = True): string;

procedure CheckFolder(aDir: string);

function GetOneDayTime(const ATime: TDatetime): TDatetime;

function GetPPM(aOK, aNG: Double): Double;

function GetOkRate(aOK, aNG: Integer): Double;

function GetNgRate(aOK, aNG: Integer): Double;

function IsTxtInList(List: TStrings; const Txt: string): Boolean;

function Load(const Filename: string; aGraphEx: TFaGraphEx; aShareCount: Integer): Boolean;

function Save(const Filename: string; aGraphEx: TFaGraphEx; aShareCount: Integer): Boolean;

function GetErShowTime: Integer;

procedure SetErShowTime(ATime: Integer);
// Graph BackGround Image File name

function GetFloatToStr(aValue: Double): string; overload;

function GetFloatToStr(aValue: Double; aDigit: Integer): string; overload;

function GetDipValue(aValue: Double): Double;
// Count

procedure SetResultReset;
// procedure SetDecCount(AResult: Boolean) ;

procedure SetResultCount(Index: Integer; AResult: Boolean);

function GetResultCount(Index: Integer; AResult: Boolean): Integer; overload;
// Graph

function IsCpkGraphIndex(AIndex: Integer): Boolean;

function GetGrpEnv(aGrp: Integer): TFaGraphEnv;

function SetGrpEnv(aBuf: TFaGraphEnv): Boolean;

function GetGraphLineName(aSection: string; aSubIndex: Integer; IsData: Boolean): string;

procedure SetGraphLineName(aSection, aName: string; aSubIndex: Integer; IsData: Boolean);
// Newer

procedure UsrGraphInitial(aGraphEx: TFaGraphEx; gtValue: TGraphType; IsClear: Boolean);

procedure SaveGraphDatas(const ATime: Double; aGraph: TFaGraphEx);

procedure LoadGraphDatas(const ATime: Double; aGraph: TFaGraphEx);

procedure DrawUsrGraphDatas(ATitle: string; ACanvas: TCanvas; ADatas: TPoint; AstdPos: TRect; X, Y: string; AOrd: Integer);

procedure SetErrorTxt(ACaption, AError, ATodo: string; DlgType: TMsgDlgType = mtError);

function GetStationName(StationID: TStationID): string;

function GetDevComName(ADevComID: TDevComORD): string;

function GetCompTime(sTime, eTime, ATime: Double): Boolean;

function GetCanDevName(aDevCanID: TDevCanORD): string;

procedure GetStNamesNCarNames(StNames, CarNames: TStrings);

function GetSeconds(ATime: TDatetime): Double;

function GetDateToSec(ATime: TDatetime): Double;

function GetTimeToSec(ATime: TDatetime): Double;

procedure DrawTLeft(Canvas: TCanvas; X, Y, w, h: Integer);

procedure DrawTRight(Canvas: TCanvas; X, Y, w, h: Integer);

function SetGraphFileDelete(stdTime: TDatetime): Boolean;

function GetMinutes(ATime: TDatetime): Double;

function GetDateToMin(ATime: TDatetime): Double;

function GetTimeToMin(ATime: TDatetime): Double;

procedure SaveGridColWidths(AGrid: TStringGrid; aName: string);

procedure LoadGridColwidths(AGrid: TStringGrid; aName: string);

function ToHexLog(const LogMsg; len: Integer): string;

function LoadDeviceNumber(DevName: string): Integer;

procedure SaveDeviceNumber(DevName: string; Value: Integer);

// procedure SaveDeliveryPos;

procedure SaveUsrDeliveryPos(const aBuf: TMotorDeliveryPos);

function LoadUsrDeliveryPos(const TypeBits: DWORD): TMotorDeliveryPos;

function JudgeToStr(Dec: TResultJudge): string;

function BoolToJudge(Val: Boolean): TResultJudge;

function MotorOrd2TsOrd(Mtr: TMotorOrd; IsLimit: Boolean = false): TTsORD;

function TsOrd2MotorOrd(Ts: TTsORD): TMotorOrd;

function IsBwdRO(RO: TResultOrd): Boolean;

function ResultOrd2TsOrd(RO: TResultORD): TTsORD;


// ------------------------------------------------------------

var
    gMsgData: TMsgData;
    gUsrMsg: HWND = 0;

    // 부하 언로딩 조건-> 1= 검사한다, 2=완료
    // 둘중 하나가 0 이고 나머지는 2이다, 둘다 2이다.
    gTsFuncProc: array[0..1] of BYTE;
    gDioReferwnd: HWND = 0;
    gCycleTime: array[0..1] of Double;
    gCanDebugMode: Boolean = False;
    gPwrDebugMode: Boolean = False;
    gsysRunMode: Boolean = False;

implementation

uses
    Math, StdCtrls, RS232, Log, UserComLibEx, ErrorForm, UserTool, DateUtils,
    ModelUnit, KiiFaGraphDB, DataUnitHelper, SysEnv, SeatTypeUI, LangTran;

const
    INT_GRP_ENV: TFaGraphEnv = (
        rXMax: 100;
        rXMin: 0;
        rXStep: 20;
        rYMax: 5;
        rYMin: 0;
        rYStep: 1;
        rSpecLine: ($00FFA6A6, $00FFA6A6, $00FFA6A6, $00FFA6A6, $00FFA6A6, $00FFA6A6, $00FFA6A6, $00FFA6A6);
        // spec Line
        rDataLine: (clRed, clBlue, clMaroon, clOlive, clNavy, clPurple, clTeal, clSilver); // Data Line
    );
    INT_SPC_ENV: TSpcEnv = (
        rSPCUCL: 4;
        rSPCLCL: 0;
        rSPCCL: 2;
        rstdXbar: 2; // 군크기...
        rMethod: 0;
    );

var
    lpUsrCount: TUsrCount;
    lpUsrstdDate: TDatetime = 0;

    // ------------------------------------------------------------------------------
    //
    // ------------------------------------------------------------------------------
procedure UsrLogApped(Value: string);
var
    fd: Integer;
    yy, mm, dd: WORD;
    sTm: string;
begin
    DecodeDate(Now(), yy, mm, dd);
    sTm := GetUsrDir(udHOME, Now()) + '\LOG\' + Format('%.4d%.2d%.2d.LOG', [yy, mm, dd]);
    if FileExists(sTm) then
        fd := FileOpen(sTm, fmOpenWrite)
    else
        fd := FileCreate(sTm);

    sTm := Value + #13 + #10;
    FileSeek(fd, 0, FILE_END);
    FileWrite(fd, PChar(sTm)^, Length(sTm) * sizeof(Char));
    FileClose(fd);
end;

function GetPPM(aOK, aNG: Double): Double;
var
    dTm: Double;
begin
    // 불량율 : (aNG/aOK)*100
    // PPM    : 불량율 * 100만
    // 2005.06.03
    dTm := aOK + aNG;
    if dTm = 0 then
        Result := 0.0
    else
        Result := (aNG / dTm) * 1000000;
end;

function GetOkRate(aOK, aNG: Integer): Double;
var
    dTm: Double;
begin
    dTm := aOK + aNG;
    if dTm = 0 then
        Result := 0.0
    else
        Result := (aOK / dTm) * 100.0;
end;

function GetNgRate(aOK, aNG: Integer): Double;
var
    dTm: Double;
begin
    dTm := aOK + aNG;
    if dTm = 0 then
        Result := 0.0
    else
        Result := (aNG / dTm) * 100.0;
end;

procedure LoadLastCount;
var
    sTm: string;
    Ini: TIniFile;
begin
    sTm := Format('%s\%s', [GetUsrDir(udENV, Now()), ENV_FILE]);
    Ini := TIniFile.Create(sTm);
    try
        with Ini do
        begin
            lpUsrCount.rCount[0, False] := Ini.ReadInteger('COUNT', '#1 OK', 0);
            lpUsrCount.rCount[0, True] := Ini.ReadInteger('COUNT', '#1 NG', 0);
            lpUsrCount.rCount[1, False] := Ini.ReadInteger('COUNT', '#2 OK', 0);
            lpUsrCount.rCount[1, True] := Ini.ReadInteger('COUNT', '#2 NG', 0);
            lpUsrCount.rTime := Ini.ReadFloat('COUNT', 'TIME', GetOneDayTime(Now()));

        end;
    finally
        Ini.Free;
    end;
end;

procedure SaveCount;
var
    sTm: string;
    Ini: TIniFile;
begin
    sTm := Format('%s\%s', [GetUsrDir(udENV, Now()), ENV_FILE]);
    Ini := TIniFile.Create(sTm);
    try
        with Ini do
        begin
            Ini.WriteInteger('COUNT', '#1 OK', lpUsrCount.rCount[0, False]);
            Ini.WriteInteger('COUNT', '#1 NG', lpUsrCount.rCount[0, True]);
            Ini.WriteInteger('COUNT', '#2 OK', lpUsrCount.rCount[1, False]);
            Ini.WriteInteger('COUNT', '#2 NG', lpUsrCount.rCount[1, True]);
            Ini.WriteFloat('COUNT', 'TIME', lpUsrCount.rTime);

        end;
    finally
        Ini.Free;
    end;
end;

// MainTimer, DataBox save 호출시.
procedure sysEnvUpdates;
begin
    if Trunc(gSysEnv.rOP.rLoadTime) <> Trunc(Now()) then
    begin
        gSysEnv.rOP.rLoadTime := Now;
        gSysEnv.rOP.rLotNo := 0;
        gSysEnv.Save(eiOP);
    end;

    with lpUsrCount do
    begin
        if Trunc(rTime) <> Trunc(GetOneDayTime(Now())) then
        begin
            rTime := GetOneDayTime(Now());
            rCount[0, False] := 0;
            rCount[0, True] := 0;
            rCount[1, False] := 0;
            rCount[1, True] := 0;

            SaveCount();

            SendToForm(gUsrMsg, SYS_COUNT_UPDATES, 0);
            SendToForm(gUsrMsg, SYS_CPK, 0);
        end;
    end;
end;

function GetUsrDir(aType: TUsrDir_ORD; aSrc: TDatetime; IsCreate: Boolean): string;
begin
    case aType of
        udHOME:
            Result := GetHomeDirectory;
        udENV:
            Result := GetUsrDir(udHOME, aSrc) + DIR_ENV;
        udGRAPH:
            Result := GetUsrDir(udRESULT, aSrc) + Format('\%s', [FormatDateTime('yyyymmdd', aSrc)]);
        udRESULT:
            begin
                Result := GetUsrDir(udRS, aSrc, IsCreate);
                Result := Format('%s\%s', [Result, FormatDateTime('yyyymm', aSrc)]);
            end;
        udTEMP:
            Result := GetUsrDir(udHOME, aSrc) + DIR_TEMP;
        udSPC:
            Result := GetUsrDir(udHOME, aSrc) + DIR_SPC;
        udRS:
            Result := GetUsrDir(udDATA, aSrc) + DIR_RESULT;
        udDATA:
            begin
                if gSysEnv.rOP.rResultDir <> '' then
                    Result := string(gSysEnv.rOP.rResultDir)
                else
                    Result := GetUsrDir(udHOME, aSrc);
            end;
        udGRP_DATA:
            begin
                if gSysEnv.rOP.rGraphDir <> '' then
                    Result := string(gSysEnv.rOP.rGraphDir)
                else
                    Result := GetUsrDir(udDATA, aSrc);
            end;
        udGRP:
            Result := GetUsrDir(udGRP_DATA, aSrc) + DIR_RESULT;
    end;

    if IsCreate and not DirectoryExists(Result) then
        ForceDirectories(Result);
end;

function GetTempFileName(aName: string; IsCreate: Boolean): string;
begin
    Result := Format('%s\%s', [GetUsrDir(udTEMP, Now(), IsCreate), aName]);
end;

function GetResultFileName(ATime: TDatetime; IsCreate: Boolean = True): string;
begin
    Result := Format('%s\%s.dat', [GetUsrDir(udRESULT, ATime, IsCreate), FormatDateTime('yyyymmdd', ATime)]);
end;

function GetResultFileName(aTime: TDateTime; Ext: string; IsCreate: Boolean): string;
begin
    Result := Format('%s\%s.%s', [GetUsrDir(udRESULT, aTime, IsCreate), FormatDateTime('yyyymmdd', aTime), Ext]);
end;

procedure CheckFolder(aDir: string);
var
    i: Integer;
    sTm: string;
begin
    sTm := '';
    for i := 1 to Length(aDir) do
    begin
        if (Length(sTm) > 0) and (aDir[i] = '\') and (aDir[i - 1] <> ':') then
            if not DirectoryExists(sTm) then
                ForceDirectories(sTm);

        sTm := sTm + aDir[i];
    end;
end;

function IsCpkGraphIndex(AIndex: Integer): Boolean;
begin
    Result := False;
    //Result := AIndex In [ord(faCpk1) .. ord(faCpk2)];
end;

function InitGrpEnv(Buf: TFaGraphEnv): TFaGraphEnv;
var
    i: Integer;
begin
    Move(Buf, Result, sizeof(TFaGraphEnv));
    with Result do
    begin
        rXMax := 100;
        rXMin := 0;
        rXStep := 10.0;
        rYMax := 100.0;
        rYMin := 0.0;
        rYStep := 10.0;

        for i := 0 to 7 do
        begin
            rSpecLine[i] := INT_GRP_ENV.rSpecLine[i];
            rDataLine[i] := INT_GRP_ENV.rDataLine[i];
        end;
    end;
end;

function LoadGrp(FileHandle, ID: Integer; var Buf: TFaGraphEnv): Boolean;
begin
    Result := False;
    FileSeek(FileHandle, 0, 0);
    while FileRead(FileHandle, Buf, sizeof(TFaGraphEnv)) = sizeof(TFaGraphEnv) do
    begin
        if Buf.rID = ID then
        begin
            Result := True;
            Break;
        end;
    end;
end;

function GetGrpEnv(aGrp: Integer): TFaGraphEnv;
label
    _INIT_GRP;
var
    sTm: string;
    fh, iTm: Integer;
begin
    sTm := Format('%s\%s', [GetUsrDir(udENV, Now()), FILE_GRP]);

    fh := 0;
    if FileExists(sTm) then
        fh := FileOpen(sTm, fmOpenRead);
    if fh <= 0 then
        goto _INIT_GRP;

    iTm := FileSeek(fh, 0, 2);
    if (iTm > 0) and ((iTm mod sizeof(TFaGraphEnv)) <> 0) then
    begin
        FileClose(fh);
        RenameFile(sTm, ChangeFileExt(sTm, '.' + FormatDateTime('yymmdd', Now)));
        gLog.ToFiles('GraphEnv File 크기이상 이름변경함.', []);
        goto _INIT_GRP;
    end;

    if not LoadGrp(fh, aGrp, Result) then
    begin
        FileClose(fh);
        goto _INIT_GRP;
    end;
    FileClose(fh);
    Exit;

_INIT_GRP:
    Result.rID := aGrp;
    Result := InitGrpEnv(Result);
end;

function SetGrpEnv(aBuf: TFaGraphEnv): Boolean;
var
    sTm: string;
    fh, iTm: Integer;
    Buf: TFaGraphEnv;
begin
    Result := False;
    sTm := Format('%s\%s', [GetUsrDir(udENV, Now()), FILE_GRP]);

    if FileExists(sTm) then
        fh := FileOpen(sTm, fmOpenReadWrite)
    else
        fh := FileCreate(sTm);
    if fh <= 0 then
        Exit;

    iTm := FileSeek(fh, 0, 2);
    if (iTm > 0) and ((iTm mod sizeof(TFaGraphEnv)) <> 0) then
    begin
        FileClose(fh);
        RenameFile(sTm, ChangeFileExt(sTm, '.' + FormatDateTime('yymmdd', Now)));
        gLog.ToFiles('GraphEnv File 크기이상 이름변경함.', []);
        fh := FileCreate(sTm);
    end;

    if not LoadGrp(fh, aBuf.rID, Buf) then
        FileSeek(fh, 0, 2)
    else
        FileSeek(fh, -sizeof(TFaGraphEnv), 1);

    Result := FileWrite(fh, aBuf, sizeof(TFaGraphEnv)) = sizeof(TFaGraphEnv);
    FileClose(fh);
end;

function GetOneDayTime(const ATime: TDatetime): TDatetime;
begin
    Result := ATime;
    with gSysEnv do
        if Frac(ATime) < Frac(rOP.rWorkTime) then
            Result := Result - 1;
end;

function IsTxtInList(List: TStrings; const Txt: string): Boolean;
var
    i: Integer;
begin
    Result := False;
    for i := 0 to List.Count - 1 do
    begin
        if List.Strings[i] = '' then
            Continue;
        if Pos(List.Strings[i], Txt) > 0 then
        begin
            Result := True;
            Break;
        end;
    end;
end;

function Load(const Filename: string; aGraphEx: TFaGraphEx; aShareCount: Integer): Boolean;
var
    fsLoad: TFileStream;
begin
    Result := False;

    if not FileExists(Filename) then
        Exit;

    fsLoad := TFileStream.Create(Filename, fmOpenRead);
    if fsLoad <> nil then
    begin
        try
            aGraphEx.BeginUpdate();
            aGraphEx.Load(fsLoad, aShareCount);
            aGraphEx.EndUpdate();
        finally
            fsLoad.Free;
            Result := True;
        end;
    end;
end;

function Save(const Filename: string; aGraphEx: TFaGraphEx; aShareCount: Integer): Boolean;
var
    fsSave: TFileStream;
begin
    Result := False;
    if FileExists(Filename) then
        DeleteFile(Filename);

    fsSave := TFileStream.Create(Filename, fmCreate);
    if fsSave <> nil then
    begin
        try
            aGraphEx.Save(fsSave, aShareCount);
        finally
            fsSave.Free;
            Result := True;
        end;
    end;
end;

function GetErShowTime: Integer;
var
    IniFile: TIniFile;
begin
    IniFile := TIniFile.Create(GetIniFiles);
    try
        Result := IniFile.ReadInteger('_ERROR', 'CLOSE_TIME', 360);
    finally
        IniFile.Free;
    end;
end;

procedure SetErShowTime(ATime: Integer);
var
    IniFile: TIniFile;
begin
    IniFile := TIniFile.Create(GetIniFiles);
    try
        IniFile.WriteInteger('_ERROR', 'CLOSE_TIME', ATime);
    finally
        IniFile.Free;
    end;
end;

function GetStrToFileName(aTxt: string): string;
var
    i: Integer;
begin
    Result := '';
    for i := 1 to Length(aTxt) do
    begin
        if aTxt[i] in ['/', '\', ';', '*', '?', '<', '>', '|'] then
            Result := Result + '-'
        else
            Result := Result + aTxt[i];
    end;
end;

function GetFloatToStr(aValue: Double): string;
begin
    Result := GetFloatToStr(aValue, gSysEnv.rOP.rWidth);
end;

function GetFloatToStr(aValue: Double; aDigit: Integer): string;
var
    i, iTm: Integer;
begin
    Result := FloatToStr(aValue);
    if aDigit <= 0 then
        Exit;

    iTm := Pos('.', Result);
    if iTm > 0 then
    begin
        if (Length(Result) - iTm) > aDigit then
        begin
            Result := Copy(Result, 1, iTm + aDigit);
            Exit;
        end
        else
        begin
            iTm := aDigit - (Length(Result) - iTm);
        end;
    end
    else
    begin
        Result := Result + '.';
        iTm := aDigit;
    end;

    for i := 0 to iTm - 1 do
        Result := Result + '0';
end;

function GetFloatToUserData(aValue: Double): Double;
var
    stdUnit: Double;
begin
    stdUnit := Power(10.0, gSysEnv.rOP.rWidth);
    Result := Trunc(stdUnit * aValue) / stdUnit;
end;

function GetDipValue(aValue: Double): Double;
begin
    Result := Round(aValue * Power(10.0, gSysEnv.rOP.rWidth)) / Power(10.0, gSysEnv.rOP.rWidth);
end;

procedure SetResultReset;
begin
    with lpUsrCount do
    begin
        rCount[0, True] := 0;
        rCount[0, False] := 0;
        rCount[1, True] := 0;
        rCount[1, False] := 0;
    end;
    SaveCount();
    SendToForm(gUsrMsg, SYS_COUNT_UPDATES, 0);
end;

procedure SetResultCount(Index: Integer; AResult: Boolean);
begin
    with lpUsrCount do
    begin
        Inc(rCount[Index, AResult]);
    end;
    SaveCount();
    SendToForm(gUsrMsg, SYS_COUNT_UPDATES, 0);
end;

function GetResultCount(Index: Integer; AResult: Boolean): Integer;
begin
    with lpUsrCount do
        Result := rCount[Index, AResult];
end;

const
    KEY_HEAD: array[False..True] of string = ('_SPEC', '_DATA');

function GetGraphLineName(aSection: string; aSubIndex: Integer; IsData: Boolean): string;
var
    Ini: TIniFile;
    sTm, Key: string;
begin
    sTm := Format('%s\GraphLine.env', [GetUsrDir(udENV, Now(), True)]);
    Ini := TIniFile.Create(sTm);
    Key := Format('%s%d', [KEY_HEAD[IsData], aSubIndex]);
    try
        Result := Ini.ReadString(aSection, Key, Copy(Key, 2, Length(Key) - 1));
    finally
        Ini.Free;
    end;
end;

procedure SetGraphLineName(aSection, aName: string; aSubIndex: Integer; IsData: Boolean);
var
    Ini: TIniFile;
    sTm, Key: string;
begin
    sTm := Format('%s\GraphLine.env', [GetUsrDir(udENV, Now(), True)]);
    Ini := TIniFile.Create(sTm);
    Key := Format('%s%d', [KEY_HEAD[IsData], aSubIndex]);
    try
        Ini.WriteString(aSection, Key, aName);
    finally
        Ini.Free;
    end;
end;

procedure UsrGraphInitial(aGraphEx: TFaGraphEx; gtValue: TGraphType; IsClear: Boolean);

    function GetCommaPos(aValue: Double; AUnit: Integer): WORD;
    var
        i: Integer;
        sTm: string;
    begin
        Result := 0;
        if Frac(aValue) = 0 then
            Exit;

        sTm := Format('%0.*f', [AUnit, aValue]);
        sTm := Copy(sTm, Pos('.', sTm) + 1, Length(sTm) - Pos('.', sTm));

        for i := Length(sTm) downto 1 do
        begin
            if sTm[i] <> '0' then
            begin
                Result := i;
                Break;
            end;
        end;
    end;

var
    i: Integer;
    grpEnv: TFaGraphEnv;
begin
    try
        with aGraphEx do
        begin
            grpEnv := GetGrpEnv(Tag);

            BeginUpdate();

            GraphType := gtValue;
            Zoom := False;
            // ZoomSerie := 0 ;

            if GraphType = gtNormal then
                GridDraw := [ggHori]//[ggVert, ggHori]
            else
                GridDraw := [ggHori];

            if IsClear then
                Empty();
            // GraphORD, ALine, AIndex
            with Axis do
            begin
                // Items[0].Scale   := asNormal ;
                Items[0].Min := grpEnv.rXMin;
                Items[0].Max := grpEnv.rXMax;
                Items[0].Step := grpEnv.rXStep;
                Items[0].Decimal := GetCommaPos(grpEnv.rXStep, 3);

                // Items[1].Scale   := asNormal ;
                Items[1].Min := grpEnv.rYMin;
                Items[1].Max := grpEnv.rYMax;
                Items[1].Step := grpEnv.rYStep;
                Items[1].Decimal := GetCommaPos(grpEnv.rYStep, 3);

                if (Count > 2) and (Tag in [ord(faStation1), ord(faStation2)]) then
                begin
                    with GetGrpEnv(Tag + 1) do
                    begin
                        Items[2].Min := rYMin;
                        Items[2].Max := rYMax;
                        Items[2].Step := rYStep;
                        Items[2].Decimal := GetCommaPos(rYStep, 3);
                    end;
                end;
            end;

            for i := 0 to Series.Count - 1 do
            begin
                Series.Items[i].Visible := True;
                Series.Items[i].LineColor := grpEnv.rDataLine[i mod 8];
                Series.Items[i].PointColor := Series.Items[i].LineColor;
            end;
            EndUpdate();
        end;
    except
        gLog.ToFiles('EXCEPTION: UsrGraphInitial', []);
    end;
end;

procedure SaveGraphDatas(const ATime: Double; aGraph: TFaGraphEx);
begin
    if aGraph.FSdShare.GetMaxIndex(0) <= 0 then
        Exit;
    gKiiDB.Add(ATime, aGraph, aGraph.Series.Count * 2);
end;

procedure LoadGraphDatas(const ATime: Double; aGraph: TFaGraphEx);
var
    KiiDB: TKiiGraphDB;
begin
    KiiDB := TKiiGraphDB.Create(stHour, GetUsrDir(udRS, Now(), False));
    try
        KiiDB.Load(ATime, aGraph, aGraph.Series.Count * 2);
    finally
        FreeAndNil(KiiDB);
    end;
end;

procedure DrawUsrGraphDatas(ATitle: string; ACanvas: TCanvas; ADatas: TPoint; AstdPos: TRect; X, Y: string; AOrd: Integer);
var
    Tmp: TArrowMark;
    fs: Integer;
    sTm: string;
begin
    with ACanvas do
    begin
        SetTextAlign(Handle, TA_CENTER or TA_TOP);
        fs := Font.Size;
        Font.Size := Trunc(fs * 0.9);
        sTm := Format('%s' + #13 + '%s %s', [ATitle, X, Y]);

        case AOrd of
            0:
                Tmp := amTopLeft;
        else
            Tmp := amBottomRight;
        end;

        DrawArrowMark(ACanvas, Tmp, ADatas.X, ADatas.Y, sTm, clNavy, clBlack, True, []);

        Font.Size := fs;
    end;
end;

procedure SetErrorTxt(ACaption, AError, ATodo: string; DlgType: TMsgDlgType);
begin

    if not Assigned(frmError) then
        Exit;

    gMsgData.mCaption := ACaption;
    gMsgData.mMsg1 := AError + #13 + ATodo;
    gMsgData.mTime := GetErShowTime;
    gMsgData.mDlgType := DlgType;

    SendToForm(gUsrMsg, SYS_MSG_ERR, 0);
    {
    try
        frmError.SetFrm(ACaption, AError + #13 + ATodo, GetErShowTime, True, DlgType);
    except
    end;
    }
end;

function GetDevComName(ADevComID: TDevComORD): string;
begin
    case ADevComID of
        dcPS_01:
            Result := 'Pwr.Sply1';

    else
        Result := '';
    end;
end;

function GetCanDevName(aDevCanID: TDevCanORD): string;
begin
    case aDevCanID of
        dcCAN_01:
            Result := 'CAN#1';
    else
        Result := 'CAN#2';
    end;
end;

function GetCompTime(sTime, eTime, ATime: Double): Boolean;
begin
    sTime := Frac(sTime);
    eTime := Frac(eTime);
    ATime := Frac(ATime);

    if sTime < eTime then
        Result := (sTime <= ATime) and (ATime <= eTime)
    else
        Result := not ((eTime <= ATime) and (ATime <= sTime));
end;

function GetTimeToSec(ATime: TDatetime): Double;
var
    hh, nn, ss, zz: WORD;
begin
    Result := ATime;

    DecodeTime(Result, hh, nn, ss, zz);
    Result := hh * 3600;
    Result := Result + (nn * 60);
    Result := Result + ss;
    Result := Result + (Round(zz / 100) / 10);
end;

function GetDateToSec(ATime: TDatetime): Double;
begin
    Result := ATime;
    Result := Trunc(Result) * SecsPerDay;
end;

function GetSeconds(ATime: TDatetime): Double;
begin
    Result := ATime;
    if Result <= 0 then
    begin
        Result := 0;
        Exit;
    end
    else if (Result > 0) and (Result < 1) then
    begin
        Result := GetTimeToSec(ATime);
    end
    else
    begin
        Result := GetTimeToSec(ATime) + GetDateToSec(ATime);
    end;
end;

procedure DrawTLeft(Canvas: TCanvas; X, Y, w, h: Integer);
begin
    with Canvas do
    begin
        w := (w shr 1) shl 1;
        h := (h shr 1) shl 1;

        Polygon([Point(X - w, Y), Point(X + w, Y - h), Point(X + w, Y + h)]);
    end;
end;

procedure DrawTRight(Canvas: TCanvas; X, Y, w, h: Integer);
begin
    with Canvas do
    begin
        w := (w shr 1) shl 1;
        h := (h shr 1) shl 1;

        Polygon([Point(X + w, Y), Point(X - w, Y - h), Point(X - w, Y + h)]);
    end;
end;

function GetOldestFolder(Astd, ADest: string): string;
var
    sTm: string;
    done: Integer;
    srFile: TSearchRec;
begin
    Result := Astd;
    done := Sysutils.FindFirst(ADest + '\*.*', faDirectory, srFile);
    try
        while done = 0 do
        begin
            if (srFile.Name[1] <> '.') and ((srFile.Attr and faDirectory) = faDirectory) then
            begin
                sTm := ADest + '\' + srFile.Name;
                if Length(Astd) <> Length(sTm) then
                begin
                    sTm := GetOldestFolder(Astd, sTm);
                end;

                if Result > sTm then
                begin
                    Result := sTm;
                end;
            end;
            done := Sysutils.FindNext(srFile);
        end;
    finally
        Sysutils.FindClose(srFile);
    end;
end;

function SetGraphFileDelete(stdTime: TDatetime): Boolean;
var
    sTm, grpFile, Dest: string;
    KiiDB: TKiiGraphDB;
begin
    Result := False;
    sTm := GetUsrDir(udGRP, stdTime, False);
    if not DirectoryExists(sTm) then
        Exit;

    try
        KiiDB := TKiiGraphDB.Create(stHour, GetUsrDir(udGRP, Now, True));
        grpFile := KiiDB.GetGraphFileName(stdTime, False);
        Dest := GetOldestFolder(ExtractFileDir(grpFile), sTm);
        if Dest = ExtractFileDir(grpFile) then
            Exit;
        Zap(Dest);
        gLog.ToFiles('start Del old graph file: %s', [Dest]);
        RemoveDir(Dest);
        gLog.ToFiles('end Del old graph file: %s', [Dest]);
    finally
        FreeAndNil(KiiDB);
    end;
    Result := True;
end;

function GetTimeToMin(ATime: TDatetime): Double;
var
    hh, nn, ss, zz: WORD;
begin
    Result := ATime;

    DecodeTime(Result, hh, nn, ss, zz);
    Result := hh * 60;
    Result := Result + nn;
    if ss > 0 then
    begin
        nn := Length(IntToStr(ss));
        Result := Result + ss / Power(10, nn);
    end
    else
        Result := Result;
    ;
end;

function GetDateToMin(ATime: TDatetime): Double;
begin
    Result := ATime;
    Result := Trunc(Result) * MinsPerDay;
end;

function GetMinutes(ATime: TDatetime): Double;
begin
    Result := ATime;
    if Result <= 0 then
    begin
        Result := 0;
        Exit;
    end
    else if (Result > 0) and (Result < 1) then
    begin
        Result := GetTimeToMin(ATime);
    end
    else
    begin
        Result := GetTimeToMin(ATime) + GetDateToMin(ATime);
    end;
end;

procedure SaveGridColWidths(AGrid: TStringGrid; aName: string);
var
    i: Integer;
    sTm: string;
begin
    sTm := Format('%s\GridWidths.env', [GetUsrDir(udENV, Now, False)]);
    with TIniFile.Create(sTm) do
    begin
        try
            for i := 0 to AGrid.ColCount - 1 do
            begin
                WriteInteger(aName, 'COL_' + IntToStr(i), AGrid.ColWidths[i]);
            end;
        finally
            Free;
        end;
    end;
end;

procedure LoadGridColwidths(AGrid: TStringGrid; aName: string);
var
    i: Integer;
    sTm: string;
begin
    sTm := Format('%s\GridWidths.env', [GetUsrDir(udENV, Now, False)]);
    if not FileExists(sTm) then
        Exit;
    with TIniFile.Create(sTm) do
    begin
        try
            for i := 0 to AGrid.ColCount - 1 do
            begin
                AGrid.ColWidths[i] := ReadInteger(aName, 'COL_' + IntToStr(i), 100);
            end;
        finally
            Free;
        end;
    end;
end;

function ToHexLog(const LogMsg; len: Integer): string;
var
    i: Integer;
begin
    Result := '';
    for i := 0 to len - 1 do
        Result := Result + IntToHex(TByteArray(LogMsg)[i], 2) + ' ';
end;

function GetStationName(StationID: TStationID): string;
begin
    {
    if gSysEnv.rStGroupNo <= 1 then
        Result := Format('#%d', [gSysEnv.rStNo + Ord(StationID)])
    else
        Result := Format('#%d-%d', [gSysEnv.rStNo + Ord(StationID), gSysEnv.rStGroupNo - 1]);
    }
    Result := Format('%dth', [gSysEnv.rOP.rStNo + Ord(StationID)]);
    //Result := '';
end;

procedure GetStNamesNCarNames(StNames, CarNames: TStrings);
var
    i: Integer;
    j: TCAR_TYPE;
begin
    if StNames <> nil then
    begin
        StNames.Clear;
        for i := 0 to MAX_ST_COUNT - 1 do
        begin
            StNames.Add(GetStationName(TStationID(i)));
        end;
    end;

    if CarNames <> nil then
    begin
        CarNames.Clear;
        for j := Low(TCAR_TYPE) to High(TCAR_TYPE) do
        begin
            CarNames.Add(TCAR_TYPE_STR[Ord(j)]);
        end;

    end;
end;

procedure SaveUsrDeliveryPos(const aBuf: TMotorDeliveryPos);
var
    sTm: string;
    fh, iDx: Integer;
    Buf: TMotorDeliveryPos;
begin
    iDx := 0;
    sTm := Format('%s\MotorDeliveryPos.dat', [GetUsrDir(udENV, Now())]);
    if FileExists(sTm) then
    begin
        fh := FileOpen(sTm, fmOpenRead);
        try
            while FileRead(fh, Buf, sizeof(TMotorDeliveryPos)) = sizeof(TMotorDeliveryPos) do
            begin
                if Buf.rTypeBits = aBuf.rTypeBits then
                begin
                    iDx := FileSeek(fh, 0, 1) div sizeof(TMotorDeliveryPos);
                    Break;
                end;
            end;
        finally
            FileClose(fh);
        end;
    end;

    sTm := Format('%s\MotorDeliveryPos.dat', [GetUsrDir(udENV, Now())]);
    if not FileExists(sTm) then
        fh := FileCreate(sTm)
    else
        fh := FileOpen(sTm, fmOpenWrite);
    try
        if iDx > 0 then
            FileSeek(fh, (iDx - 1) * sizeof(TMotorDeliveryPos), 0)
        else
            FileSeek(fh, 0, 2);
        FileWrite(fh, aBuf, sizeof(TMotorDeliveryPos));
    finally
        FileClose(fh);
    end;
end;

function LoadUsrDeliveryPos(const TypeBits: DWORD): TMotorDeliveryPos;
var
    sTm: string;
    fh: Integer;
begin
    FillChar(Result, sizeof(TMotorDeliveryPos), 0);
    sTm := Format('%s\MotorDeliveryPos.dat', [GetUsrDir(udENV, Now())]);
    if FileExists(sTm) then
    begin
        fh := FileOpen(sTm, fmOpenRead);
        try
            while FileRead(fh, Result, sizeof(TMotorDeliveryPos)) = sizeof(TMotorDeliveryPos) do
            begin
                if Result.rTypeBits = TypeBits then
                    Break
                else
                    Result.rTypeBits := 0;
            end;
        finally
            FileClose(fh);
        end;
    end;

    if Result.rTypeBits = 0 then
    begin
        Result.rTypeBits := TypeBits;
        Result.rMotors[False, 0].rPos := 0;
        Result.rMotors[False, 0].rTime := 2.0;
        Result.rMotors[False, 1].rPos := 0;
        Result.rMotors[False, 1].rTime := 2.0;
        Result.rMotors[False, 2].rPos := 0;
        Result.rMotors[False, 2].rTime := 2.0;

        Result.rMotors[True, 0].rPos := 0;
        Result.rMotors[True, 0].rTime := 2.0;
        Result.rMotors[True, 1].rPos := 0;
        Result.rMotors[True, 1].rTime := 2.0;
        Result.rMotors[True, 2].rPos := 0;
        Result.rMotors[True, 2].rTime := 2.0;
    end;
end;

function LoadDeviceNumber(DevName: string): Integer;
var
    sTm: string;
    Ini: TIniFile;
begin
    sTm := Format('%s\DeviceInfo.ini', [GetUsrDir(udENV, Now())]);
    Ini := TIniFile.Create(sTm);
    try
        Result := Ini.ReadInteger(DevName, 'DEV NUMBER', 0);
        if not Ini.SectionExists(DevName) then
        begin
            Ini.WriteInteger(DevName, 'DEV NUMBER', Result);
        end;
    finally
        Ini.Free;
    end;
end;

procedure SaveDeviceNumber(DevName: string; Value: Integer);
var
    sTm: string;
    Ini: TIniFile;
begin
    sTm := Format('%s\DeviceInfo.ini', [GetUsrDir(udENV, Now())]);
    Ini := TIniFile.Create(sTm);
    try
        Ini.WriteInteger(DevName, 'DEV NUMBER', Value);
    finally
        Ini.Free;
    end;
end;

function JudgeToStr(Dec: TResultJudge): string;
begin
    case Dec of
        rjNone:
            Result := 'None';
        rjOK:
            Result := JUDGE_TXT[True];
        rjNG:
            Result := JUDGE_TXT[False];
    end;

end;

function BoolToJudge(Val: Boolean): TResultJudge;
begin
    if Val then
        Exit(rjOK);

    Exit(rjNG);
end;

function MotorOrd2TsOrd(Mtr: TMotorOrd; IsLimit: Boolean): TTsORD;
begin
    if IsLimit then
    begin
        case Mtr of
            tmSlide:
                Result := tsLimit_Slide;
            tmRecl:
                Result := tsLimit_Recl;
            tmCushTilt:
                Result := tsLimit_CushTilt;
            tmWalkinUpTilt:
                Result := tsLimit_WalkinUpTilt;
            tmShoulder:
                Result := tsLimit_Shoulder;
            tmRelax:
                Result := tsLimit_Relax;
            tmHeadrest:
                Result := tsLimit_Headrest;
            tmLongSlide:
                Result := tsLimit_LongSlide;

        else
            raise Exception.CreateFmt('Invalid Limit TMotorORD value: %d', [Ord(Mtr)]);
        end;
    end
    else
    begin
        case Mtr of
            tmSlide:
                Result := tsSlide;
            tmRecl:
                Result := tsRecl;
            tmCushTilt:
                Result := tsCushTilt;
            tmWalkinUpTilt:
                Result := tsWalkinUpTilt;
            tmShoulder:
                Result := tsShoulder;
            tmRelax:
                Result := tsRelax;
            tmHeadrest:
                Result := tsHeadrest;
            tmLongSlide:
                Result := tsLongSlide;
        else
            raise Exception.CreateFmt('Invalid TMotorORD value: %d', [Ord(Mtr)]);
        end;
    end;
end;

function TsOrd2MotorOrd(Ts: TTsOrd): TMotorOrd;
begin
    case Ts of
        tsSlide, tsLimit_Slide:
            Result := tmSlide;
        tsRecl, tsLimit_Recl:
            Result := tmRecl;
        tsCushTilt, tsLimit_CushTilt:
            Result := tmCushTilt;
        tsWalkinUpTilt, tsLimit_WalkinUpTilt:
            Result := tmWalkinUpTilt;
        tsShoulder, tsLimit_Shoulder:
            Result := tmShoulder;
        tsRelax, tsLimit_Relax:
            Result := tmRelax;
        tsLongSlide, tsLimit_LongSlide:
            Result := tmLongSlide;
    else
        raise Exception.CreateFmt('Invalid TTsOrd value: %d', [Ord(Ts)]);
    end;
end;

function IsBwdRO(RO: TResultOrd): Boolean;
begin
    Result := RO in [roDataBwCurr, roDataBwSpeed, roDataBwInitNoise, roDataBwRunNoise, roDataBwInitNoiseDev, roDataBwRunNoiseDev, roDataBwAngle, roDataBwStrokeAmount];
end;

function ResultOrd2TsOrd(RO: TResultORD): TTsORD;
begin
    Result := tsNone;
    case RO of
        roDataFwTime, roDataBwTime:
        begin
            Result := tsTime;
        end;

        roDataFwCurr,
        roDataBwCurr,
        roRsCurr,
        roRsTotCurr:
        begin
            Result := tsCurr;
        end;

        roDataFwSpeed,
        roDataBwSpeed,
        roRsSpeed,
        roRsTotSpeed:
        begin
            Result := tsSpeed;
        end;

        roDataFwInitNoise,
        roDataFwRunNoise,
        roDataBwInitNoise,
        roDataBwRunNoise,
        roDataFwInitNoiseDev,
        roDataFwRunNoiseDev,
        roDataBwInitNoiseDev,
        roDataBwRunNoiseDev,
        roRsNoise,
        roRsTotNoise:
        begin
            Result := tsNoise;
        end;

        roDataFwStrokeAmount,
        roDataBwStrokeAmount,
        roRsStrokeAmount,
        roRsTotStrokeAmount:
        begin
            Result := tsStrokeAmount;
        end;

        roRsLimit:
        begin
            Result := tsLimit;
        end;

        roDataFwAngle,
        roDataBwAngle,
        roRsAngle,
        roRsTotAngle:
        begin
            Result := tsAngle;
        end;

        roRsAbnormalSound:
        begin
            Result := tsAbnormalSound;
        end;

        roRsFwMotor,
        roRsBwMotor,
        roRsMotor,
        roRsTotMotor:
        begin
            Result := tsMotor;
        end;

        roDataAntiPinchLoad,
        roDataAntiPinchStopCurr,
        roDataAntiPinchRisingCurr,
        roRsAntiPinch,
        roRsTotAntiPinch:
        begin
            Result := tsAntiPinch;
        end;

        roDataEcuPartNo,
        roDataEcuSwVer,
        roDataEcuHwVer,
        roRsEcuInfo,
        roRsTotEcuInfo:
        begin
            Result := tsEcuInfo;
        end;

        roDataBuckle,
        roDataCTRBuckle,
        roRsTotBuckle:
        begin
            Result := tsBuckle;
        end;

        roRsMem1,
        roRsMem2,
        roRsMem3,
        roRsEasyAccess,
        roRsIMS:
        begin
            Result := tsIMS;
        end;

        roDataOnCurr,
        roDataOffCurr,
        roDataLedOffBit,
        roDataLedHiBit,
        roDataLedMidBit,
        roDataLedLoBit,
        roRsHeatByPos,
        roRsVentByPos,
        roRsHeat,
        roRsVent:
        begin
            Result := tsHV;
        end;

        roRsFlow:
        begin
            Result := tsFlow;
        end;


        roRsDTC:
        begin
            Result := tsDTC;
        end;

        roRsElec:
        begin
            Result := tsElec;
        end;

        roRsMidPos:
        begin
            Result := tsMidPos;
        end;
    end;
end;

//------------------------------------------------------------------------------
{ TDeliveryPos }

function TDeliveryPos.GetDir: TMotorWayOrd;
begin
    case rPos of
        0:
            Result := twForw;
        1:
            Result := twBack;
        2:
            Result := rWay;
    end;
end;

function TDeliveryPos.InRange(Val, Margin: Double): Boolean;
begin
    Result := ((rMin - Margin) <= Val) and (Val <= (rMax + Margin));
end;

function TDeliveryPos.GetTime: Double;
begin
    case rPos of
        0:
            Result := 0;
        1:
            Result := 0;
        2:
            Result := rTime;
    end;
end;


{ TModel }

function TModel.IsEmpty: Boolean;
begin
    Result := rIndex <= 0;
end;

procedure TModel.Read(DataSet: TDataSet; RWEvent: TDataSetRWEvent);
begin
    rIndex := 0;            // Spec 설정 유무용 Flag로 사용

    rPartNo := DataSet.FieldByName('part_no').AsString;
    rLclPartNo := DataSet.FieldByName('lcl_part_no').AsString;
    rPartName := DataSet.FieldByName('part_name').AsString;
    rTypes.mDataBits := DataSet.FieldByName('type_bits').AsLargeInt;
    rSPITypeBits := DataSet.FieldByName('spi_type_bits').AsLargeInt;

    if Assigned(RWEvent) then
        RWEvent(DataSet);
end;

procedure TModel.ReadAsOpt(ChkListBox: TCheckListBox);
begin
    SeatTypeUI.ReadAsOpt(rTypes, ChkListBox);
end;

procedure TModel.ReadAsType(PosRG, CarTypeRG, SeatTypeRG, DrvTypeRG: TRadioGroup);
begin
    //SeatTypeUI.ReadAsType(rTypes, PosRG, CarTypeRG, SeatTypeRG, DrvTypeRG);
end;

function TModel.Write(DataSet: TDataSet; IsAppend: Boolean; RWEvent: TDataSetRWEvent): Boolean;
begin
    Result := True;
    try

        if IsAppend then
            DataSet.Append
        else
            DataSet.Edit;

        DataSet.FieldByName('part_no').AsString := rPartNo;
        DataSet.FieldByName('lcl_part_no').AsString := rLclPartNo;
        DataSet.FieldByName('part_name').AsString := rPartName;
        DataSet.FieldByName('type_bits').AsLargeInt := rTypes.mDataBits;
        DataSet.FieldByName('spi_type_bits').AsLargeInt := rSPITypeBits;

        if Assigned(RWEvent) then
        begin
            if not RWEvent(DataSet) then
            begin
                Exit(False);
            end;
        end;

        DataSet.Post;

        if IsAppend then
            DataSet.Last;

    except
        on e: EDatabaseError do
        begin
            gLog.Panel(e.ToString);
            ShowMessage(e.ToString);
            DataSet.Cancel;
            Exit(False);
        end;
    end;

end;

procedure TModel.Write(Strings: TStrings; StartCol: Integer);
var
    MT: TModelType;
begin
    Strings.Strings[StartCol + 0] := rPartNo;
    Strings.Strings[StartCol + 1] := rLclPartNo;
    rTypes.WriteAsType(Strings, 2);
end;

procedure TModel.WriteAsOpt(ChkListBox: TCheckListBox);
begin
    SeatTypeUI.WriteAsOpt(rTypes, ChkListBox);
end;

procedure TModel.WriteAsType(PosRG, CarTypeRG, SeatTypeRG, DrvTypeRG: TRadioGroup);
begin
    //SeatTypeUI.WriteAsType(rTypes, PosRG, CarTypeRG, SeatTypeRG, DrvTypeRG);
end;


{ TMotorData }

procedure TMotorData.Clear;
begin
    FillChar(rItems[twForw], Sizeof(TMotorTestItem), 0);
    FillChar(rItems[twBack], Sizeof(TMotorTestItem), 0);
    rLimit := False;
end;


{ TMsgData }

procedure TMsgData.Init(Caption, Msg1, Msg2: string);
begin
    mCaption := Caption;
    mMsg1 := Msg1;
    mMsg2 := Msg2;
end;

{ TMdlExData }

constructor TMdlExData.Create(ID: Integer; TypeBits: DWORD);
begin
    mID := ID;
    mTypeBits := TypeBits;
end;

function TMdlExData.ToKeyStr: string;
begin
    Result := Format('%d.%X', [mID, mTypeBits]);
end;

function TMdlExData.Write(FileHandle: Integer): Boolean;
begin
    Result := FileWrite(FileHandle, self, sizeof(TMdlExData)) = sizeof(TMdlExData);
end;


{ TTsOrdJudge }

function TTsOrdJudge.GetJudgeStr: string;
begin
    Result := JudgeToStr(mJudge);
end;

{ TTsOrdJudgeList }

function TTsOrdJudgeList.Add(Item: TTsOrdJudge): Integer;
begin
    Result := inherited Add(Item);
end;

function TTsOrdJudgeList.IndexOf(Item: TTsORD): Integer;
var
    i: Integer;
begin
    for i := 0 to Self.Count - 1 do
    begin
        if Items[i].mTsOrd = Item then
            Exit(i);
    end;

    Result := -1;
end;


{ TMotorSpec }

procedure TMotorSpec.Init;
begin
    rCurr.mUnitStr := 'A';
    rSpeed[twForw].mUnitStr := '°/mm';
    rSpeed[twBack].mUnitStr := '°/mm';
    rTime.mUnitStr := 's';
    rStrokeAmount.mUnitStr := 'pulse';
end;

const
    FORMAT_SPEED = '0.0';
    FORMAT_STROKE = '0.0';
    FORMAT_ANGLE = '0.0';

{ TSpecs }
function TSpecs.ToMotorStr(MtrOrd: TMotorOrd; RO: TResultOrd; IsUnit: Boolean): string;
begin
    case RO of
        roSpecCurrLo:
            begin
                rMotors[MtrOrd].rCurr.mShowUnit := IsUnit;
                Result := rMotors[MtrOrd].rCurr.ToMinStr;
            end;
        roSpecCurrHi:
            begin
                rMotors[MtrOrd].rCurr.mShowUnit := IsUnit;
                Result := rMotors[MtrOrd].rCurr.ToMaxStr;
            end;

        roSpecCurrHiLo:
            begin
                rMotors[MtrOrd].rCurr.mShowUnit := IsUnit;
                Result := rMotors[MtrOrd].rCurr.ToStr;
            end;

        roSpecTimeLo:
            begin
                rMotors[MtrOrd].rTime.mShowUnit := IsUnit;
                Result := rMotors[MtrOrd].rTime.ToMinStr;
            end;

        roSpecTimeHi:
            begin
                rMotors[MtrOrd].rTime.mShowUnit := IsUnit;
                Result := rMotors[MtrOrd].rTime.ToMaxStr;
            end;

        roSpecTimeHiLo:
            begin
                rMotors[MtrOrd].rTime.mShowUnit := IsUnit;
                Result := rMotors[MtrOrd].rTime.ToStr;
            end;

        roSpecFwSpeedLo:
            begin
                rMotors[MtrOrd].rSpeed[twForw].mShowUnit := IsUnit;
                Result := rMotors[MtrOrd].rSpeed[twForw].ToMinStr(FORMAT_SPEED, '°/s'); // mUnitStr[3] 버퍼 짤리는 이유로 직접 Unit명시
            end;

        roSpecFwSpeedHi:
            begin
                rMotors[MtrOrd].rSpeed[twForw].mShowUnit := IsUnit;
                Result := rMotors[MtrOrd].rSpeed[twForw].ToMaxStr(FORMAT_SPEED, '°/s');
            end;

        roSpecFwSpeedHiLo:
            begin
                rMotors[MtrOrd].rSpeed[twForw].mShowUnit := IsUnit;
                Result := rMotors[MtrOrd].rSpeed[twForw].ToStrWithUnit(FORMAT_SPEED, '°/s');  // mUnitStr[3] 버퍼 짤리는 이유로 직접 Unit명시
            end;
        roSpecBwSpeedLo:
            begin
                rMotors[MtrOrd].rSpeed[twBack].mShowUnit := IsUnit;
                Result := rMotors[MtrOrd].rSpeed[twBack].ToMinStr(FORMAT_SPEED, '°/s');
            end;

        roSpecBwSpeedHi:
            begin
                rMotors[MtrOrd].rSpeed[twBack].mShowUnit := IsUnit;
                Result := rMotors[MtrOrd].rSpeed[twBack].ToMaxStr(FORMAT_SPEED, '°/s');
            end;

        roSpecBwSpeedHiLo:
            begin
                rMotors[MtrOrd].rSpeed[twBack].mShowUnit := IsUnit;
                Result := rMotors[MtrOrd].rSpeed[twBack].ToStrWithUnit(FORMAT_SPEED, '°/s');
            end;

        roSpecInitNoiseHi:
            begin
                Result := '~ ' + FormatFloat('0.0', rMotors[MtrOrd].rInitNoise);
                if IsUnit then
                    Result := Result + ' dB';
            end;
        roSpecRunNoiseHi:
            begin
                Result := '~ ' + FormatFloat('0.0', rMotors[MtrOrd].rRunNoise);
                if IsUnit then
                    Result := Result + ' dB';
            end;

        roSpecInitNoiseDevHi:
            begin
                Result := '~ ' + FormatFloat('0.0', rMotors[MtrOrd].rInitNoiseDev);
                if IsUnit then
                    Result := Result + ' dB';
            end;

        roSpecRunNoiseDevHi:
            begin
                Result := '~ ' + FormatFloat('0.0', rMotors[MtrOrd].rRunNoiseDev);
                if IsUnit then
                    Result := Result + ' dB';
            end;

        roSpecStrokeAmountLo:
            begin
                rMotors[MtrOrd].rStrokeAmount.mShowUnit := IsUnit;
                Result := rMotors[MtrOrd].rStrokeAmount.ToMinStr(FORMAT_STROKE, 'pulse');
            end;

        roSpecStrokeAmountHi:
            begin
                rMotors[MtrOrd].rStrokeAmount.mShowUnit := IsUnit;
                Result := rMotors[MtrOrd].rStrokeAmount.ToMaxStr(FORMAT_STROKE, 'pulse');
            end;

        roSpecStrokeAmountHiLo:
            begin
                rMotors[MtrOrd].rStrokeAmount.mShowUnit := IsUnit;
                Result := rMotors[MtrOrd].rStrokeAmount.ToStrWithUnit(FORMAT_STROKE, 'pulse');
            end;

        roSpecFwAngleLo:
            begin
                rMotors[MtrOrd].rAngle[twForw].mShowUnit := IsUnit;
                Result := rMotors[MtrOrd].rAngle[twForw].ToMinStr(FORMAT_ANGLE, '°');
            end;

        roSpecFwAngleHi:
            begin
                rMotors[MtrOrd].rAngle[twForw].mShowUnit := IsUnit;
                Result := rMotors[MtrOrd].rAngle[twForw].ToMaxStr(FORMAT_ANGLE, '°');
            end;

        roSpecFwAngleHiLo:
            begin
                rMotors[MtrOrd].rAngle[twForw].mShowUnit := IsUnit;
                Result := rMotors[MtrOrd].rAngle[twForw].ToStrWithUnit(FORMAT_ANGLE, '°');
            end;

        roSpecBwAngleLo:
            begin
                rMotors[MtrOrd].rAngle[twBack].mShowUnit := IsUnit;
                Result := rMotors[MtrOrd].rAngle[twBack].ToMinStr(FORMAT_ANGLE, '°');
            end;

        roSpecBwAngleHi:
            begin
                rMotors[MtrOrd].rAngle[twBack].mShowUnit := IsUnit;
                Result := rMotors[MtrOrd].rAngle[twBack].ToMaxStr(FORMAT_ANGLE, '°');
            end;

        roSpecBwAngleHiLo:
            begin
                rMotors[MtrOrd].rAngle[twBack].mShowUnit := IsUnit;
                Result := rMotors[MtrOrd].rAngle[twBack].ToStrWithUnit(FORMAT_ANGLE, '°');
            end;
    end;
end;

procedure TSpecs.Init;
var
    Mtr: TMotorOrd;
begin
    for Mtr := Low(TMotorOrd) to MtrOrdHi do
        rMotors[Mtr].Init;

end;

const
    FORMAT_LOAD = '0.0';

function TSpecs.ToAPStr(APType: TAP_TYPE; RO: TResultOrd; IsUnit: Boolean): string;
begin
    case RO of
        roSpecAPLoadLo:
            begin
                rAntiPinch[APType].rLoad.mShowUnit := IsUnit;
                Result := rAntiPinch[APType].rLoad.ToMinStr(FORMAT_LOAD, 'kgf');
            end;
        roSpecAPLoadHi:
            begin
                rAntiPinch[APType].rLoad.mShowUnit := IsUnit;
                Result := rAntiPinch[APType].rLoad.ToMaxStr(FORMAT_LOAD, 'kgf');
            end;
        roSpecAPLoadHiLo:
            begin
                rAntiPinch[APType].rLoad.mShowUnit := IsUnit;
                Result := rAntiPinch[APType].rLoad.ToStrWithUnit(FORMAT_LOAD, 'kgf');
            end;
        roSpecAPStopCurrHi:
            begin
                Result := FloatToStr(rAntiPinch[APType].rStopCurr) + ' A';
            end;
        roSpecAPRisingCurrLo:
            begin
                Result := FloatToStr(rAntiPinch[APType].rRisingcurr) + ' A';
            end;
    end;
end;

const
    FORMAT_HEAT = '0.0';
    FORMAT_VENT = '0.0';
    FORMAT_BUCKLE = '0.0';

function TSpecs.ToStr(RO: TResultOrd; IsUnit: Boolean): string;
begin
    case RO of
        roSpecHeatOnLo:
            begin
                rOnCurr[hvtHeat].mShowUnit := IsUnit;
                Result := rOnCurr[hvtHeat].ToMinStr(FORMAT_HEAT, 'A');
            end;
        roSpecHeatOnHi:
            begin
                rOnCurr[hvtHeat].mShowUnit := IsUnit;
                Result := rOnCurr[hvtHeat].ToMaxStr(FORMAT_HEAT, 'A');
            end;
        roSpecHeatOnHiLo:
            begin
                rOnCurr[hvtHeat].mShowUnit := IsUnit;
                Result := rOnCurr[hvtHeat].ToStrWithUnit(FORMAT_HEAT, 'A');
            end;
        roSpecHeatOffLo:
            begin
                rOffCurr[hvtHeat].mShowUnit := IsUnit;
                Result := rOffCurr[hvtHeat].ToMinStr(FORMAT_HEAT, 'A');
            end;
        roSpecHeatOffHi:
            begin
                rOffCurr[hvtHeat].mShowUnit := IsUnit;
                Result := rOffCurr[hvtHeat].ToMaxStr(FORMAT_HEAT, 'A');
            end;
        roSpecHeatOffHiLo:
            begin
                rOffCurr[hvtHeat].mShowUnit := IsUnit;
                Result := rOffCurr[hvtHeat].ToStrWithUnit(FORMAT_HEAT, 'A');
            end;
        roSpecVentOnLo:
            begin
                rOnCurr[hvtVent].mShowUnit := IsUnit;
                Result := rOnCurr[hvtVent].ToMinStr(FORMAT_VENT, 'A');
            end;
        roSpecVentOnHi:
            begin
                rOnCurr[hvtVent].mShowUnit := IsUnit;
                Result := rOnCurr[hvtVent].ToMaxStr(FORMAT_VENT, 'A');
            end;
        roSpecVentOnHiLo:
            begin
                rOnCurr[hvtVent].mShowUnit := IsUnit;
                Result := rOnCurr[hvtVent].ToStrWithUnit(FORMAT_VENT, 'A');
            end;
        roSpecVentOffLo:
            begin
                rOffCurr[hvtVent].mShowUnit := IsUnit;
                Result := rOffCurr[hvtVent].ToMinStr(FORMAT_VENT, 'A');
            end;
        roSpecVentOffHi:
            begin
                rOffCurr[hvtVent].mShowUnit := IsUnit;
                Result := rOffCurr[hvtVent].ToMaxStr(FORMAT_VENT, 'A');
            end;
        roSpecVentOffHiLo:
            begin
                rOffCurr[hvtVent].mShowUnit := IsUnit;
                Result := rOffCurr[hvtVent].ToStrWithUnit(FORMAT_VENT, 'A');
            end;
        roSpecBuckleLo:
            begin
                rBuckle.mShowUnit := IsUnit;
                Result := rBuckle.ToMinStr(FORMAT_BUCKLE, 'V');
            end;
        roSpecBukcleHi:
            begin
                rBuckle.mShowUnit := IsUnit;
                Result := rBuckle.ToMaxStr(FORMAT_BUCKLE, 'V');
            end;
        roSpecBuckleHiLo:
            begin
                rBuckle.mShowUnit := IsUnit;
                Result := rBuckle.ToStrWithUnit(FORMAT_BUCKLE, 'V');
            end;
    end;
end;

{ TEcuInfo }

constructor TEcuInfo.Create(const APartNo, ASwVer, AHwVer: string);
begin
    rPartNo := APartNo;
    rSwVer := ASwVer;
    rHwVer := AHwVer;
end;

function TEcuInfo.ToStr: string;
begin
    Result := Format('PartNo: %s, SwVer: %s, HwVer: %s', [rPartNo, rSwVer, rHwVer]);
end;

function TEcuInfo.Equals(const Other: TEcuInfo): Boolean;
begin
    Result := ComparePartNo(Other.rPartNo) and CompareSwVer(Other.rSwVer) and CompareHwVer(Other.rHwVer);
end;

function TEcuInfo.ComparePartNo(const Target: string): Boolean;
begin
    Result := (Pos('MASTER', rPartNo) > 0) or (Pos(Target, rPartNo) > 0);
end;

function TEcuInfo.CompareSwVer(const Target: string): Boolean;
begin
    Result := (Pos('MASTER', rSwVer) > 0) or (Pos(Target, rSwVer) > 0);
end;

function TEcuInfo.CompareHwVer(const Target: string): Boolean;
begin
    Result := (Pos('MASTER', rHwVer) > 0) or (Pos(Target, rHwVer) > 0);
end;


{ TResult }

procedure TResult.Clear(IncModel: Boolean);
var
    TempMdl: TModel;
begin

    Move(rModel, TempMdl, sizeof(TModel));
    ZeroMemory(@self, sizeof(TResult));

    if not IncModel then
        Move(TempMdl, RModel, sizeof(TModel));

    rBCFilePos := -1;
end;

function TResult.GetDatCurAP: PAntiPinchData;
begin
    Result := @rDatAPs[rCurAPSeat];
end;

function TResult.GetDatCurECU: PEcuInfo;
begin
    Result := @rEcuInfo[rCurECU];
end;

function TResult.GetDatCurHV: PHVData;
begin
    Result := @rDatHvs[rCurHVPos, rCurHVTestType];
end;

function TResult.GetDatCurMtr: PMotorData;
begin
    REsult := @rDatMtrs[rCurMtr];
end;

function TResult.ModelToStr(RO: TResultOrd; IsUnit: Boolean): string;
begin
    with rModel do
    begin
        case RO of
            roIndex:
                Result := Format('%0.2d', [rIndex]);

            roPosType:
                Result := TPOS_TYPE_STR[BYTE(rTypes.GetPosType)];
            roPosExType:
                Result := rTypes.GetPosTypeStr;
            roCarType:
                Result := TCAR_TYPE_STR[BYTE(rTypes.GetCarType)];
            roPartName:
                Result := rPartName;
            roPartNo:
                Result := rPartNo;
            roLclPartNo:
                Result := string(rLclPartNo);
            // 모터 스펙
            roSpecCurrLo, roSpecCurrHi, roSpecCurrHiLo,
            roSpecTimeLo, roSpecTimeHi, roSpecTimeHiLo,
            roSpecFwSpeedLo, roSpecFwSpeedHi, roSpecFwSpeedHiLo,
            roSpecBwSpeedLo, roSpecBwSpeedHi, roSpecBwSpeedHiLo,
            roSpecInitNoiseHi, roSpecInitNoiseDevHi,
            roSpecRunNoiseHi, roSpecRunNoiseDevHi,
            roSpecStrokeAmountLo, roSpecStrokeAmountHi, roSpecStrokeAmountHiLo,
            roSpecFwAngleLo, roSpecFwAngleHi, roSpecFwAngleHiLo,
            roSpecBwAngleLo, roSpecBwAngleHi, roSpecBwAngleHiLo:
                begin
                    Result := rModel.rSpecs.ToMotorStr(rCurMtr, RO, IsUnit);
                end;

            // 안티핀치 스펙
            roSpecAPLoadLo, roSpecAPLoadHi, roSpecAPLoadHiLo,
            roSpecAPStopCurrHi, roSpecAPRisingCurrLo:
                begin
                    Result := rModel.rSpecs.ToAPStr(rCurAPSeat, RO, IsUnit);
                end;

            // 전장 스펙
            roSpecHeatOnLo, roSpecHeatOnHi, roSpecHeatOnHiLo,
            roSpecHeatOffLo, roSpecHeatOffHi, roSpecHeatOffHiLo,
            roSpecVentOnLo, roSpecVentOnHi, roSpecVentOnHiLo,
            roSpecVentOffLo, roSpecVentOffHi, roSpecVentOffHiLo,
            roSpecBuckleLo, roSpecBukcleHi, roSpecBuckleHiLo:
                begin
                    Result := rModel.rSpecs.ToStr(RO, IsUnit);
                end;

        end;
    end;
end;

procedure TResult.SetCurHVIdx(HVPos: THVPosType; HVTestType: THVTestType);
begin
    rCurHVPos := HVPos;
    rCurHVTestType := HVTestType;
end;

{ TOutPosInfo }

function TOutPosInfo.IsIn(Dis1, Dis2: Double): Boolean;
begin
    case mSensorIdx of
        0:
            Result := mSpec[0].IsIn(Dis1);
        1:
            Result := mSpec[1].IsIn(Dis2);
        2:
            Result := mSpec[0].IsIn(Dis1) or mSpec[1].IsIn(Dis2);
        3:
            Result := mSpec[0].IsIn(Dis1) and mSpec[1].IsIn(Dis2);
    else
        Result := mSpec[0].IsIn(Dis1);
    end;
end;

{ TOutPos }

function TOutPos.GetDir: TMotorDir;
begin
    case rType of
        0:
            Result := twForw;
        1:
            Result := twBack;
        2:
            Result := rDir4Time;
    else
        Result := twBack;
    end;
end;

function TOutPos.GetTime: single;
begin
    case rType of
        2:
            Result := rTime;
    else
        Result := 0.0;
    end;

end;

{ TMotorConstraints }

function TMotorConstraints.IsMoveByTime: Boolean;
begin
    Result := rMethodIdx = 1;
end;

{ TAntiPinchSpec }

procedure TAntiPinchSpec.Init;
begin
    rLoad.mUnitStr := 'Kgf';

end;

{ TOffset }

function TOffset.GetHVOffset(HVTestType: THVTestType): Double;
begin
    case HVTestType of
        hvtHeat:
            Result := rVals[ucHeat];
        hvtVent:
            Result := rVals[ucVent];
    end;
end;



initialization
    gSysEnv.LoadAll;

    gSysEnv.rOP.rVer := '250227.00';

    TLangTran.Init(ltKor, TLangType(gSysEnv.rOP.rLanguage));

{$IFNDEF _VIEWER}
    lpUsrstdDate := EncodeDate(2014, 06, 01);
    LoadLastCount;



    // LoadDeliveryPos ;
    gCycleTime[0] := 0;
    gCycleTime[1] := 0;


{$ENDIF}

end.

