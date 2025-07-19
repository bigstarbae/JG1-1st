unit IODef;

interface

uses
    Windows, Global, SeatMotorType;

const
    _WORD_PER_ST = 2; // 공정당 LAN WORD
    _LAN_IO_CH_COUNT = (_WORD_PER_ST * 16 * 2); // (In + Out)
    _DIO_CH_COUNT = (134 * 2); // Max(In: 134,  Out: 14) * 2 ; 공정별 DIO 객체 생성함으로 1공정 단위별 갯수

    MAX_MODEL_WD_COUNT = 3 * MAX_ST_COUNT;


    // =================================================================================
    // DI

    // 모터 JOG
    DI_SLIDE_MTR_CW = 0;
    DI_SLIDE_MTR_CCW = 1;
    DI_RECL_OR_RELAX_MTR_CW = 2;
    DI_RECL_OR_RELAX_MTR_CCW = 3;
    DI_CUSH_TILT_MTR_CW = 4;
    DI_CUSH_TILT_MTR_CCW = 5;
    DI_WALKIN_TILT_MTR_CW = 6;
    DI_WALKIN_TILT_MTR_CCW = 7;
    DI_SHOULDER_CW = 8;
    DI_SHOULDER_CCW = 9;

    // =================================================================================
    // DO
    _DIO_OUT_START = _DIO_CH_COUNT div 2;

    DO_HW_IGN1 = _DIO_OUT_START;
    DO_HW_IGN2 = _DIO_OUT_START + 1;
    DO_TEST_POWER = _DIO_OUT_START + 2;
    DO_SPEC_CHK_POWER = _DIO_OUT_START + 3;
    DO_JG1_CAR = _DIO_OUT_START + 12;
    DO_JG1_SAU_POWER = _DIO_OUT_START + 13;

    // =================================================================================
    _LAN_OUT_START = _LAN_IO_CH_COUNT div 2;

    // =================================================================================
    // AI
    AI_MAIN_CURR = 0;
    AI_MOTOR_CURR = 1;


    AI_SLIDE_FW_LOAD = 4;
    AI_SLIDE_BW_LOAD = 5;
    AI_RECLINE_FOLD_LOAD = 6;
    AI_RECLINE_UNFOLD_LOAD = 6;

    AI_MAIN_CON_VOLT_START = 8;
    AI_MAIN_CON_VOLT_END = AI_MAIN_CON_VOLT_START + 33;

    AI_NOISE = 100;
    // =================================================================================
    // AO
    SYS_REF_VOLT = -1; // 시스템 기준 전압 CH(-1 V)


    // 이후 진단 AI  추가 할 것

    // =================================================================================
    // Counter

implementation

end.
