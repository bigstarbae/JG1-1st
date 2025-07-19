unit IODef;

interface

uses
    Windows, Global, SeatMotorType;

const
    _WORD_PER_ST = 2; // 공정당 LAN WORD
    _LAN_IO_CH_COUNT = (_WORD_PER_ST * 16 * 2); // (In + Out)
    _DIO_CH_COUNT = (204 * 2); // Max(In: 204,  Out: 20) * 2 ; 공정별 DIO 객체 생성함으로 1공정 단위별 갯수

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
    DO_SW_P_COM = _DIO_OUT_START + 2;
    DO_SW_N_COM = _DIO_OUT_START + 3;
    DO_SW_SPARE1 = _DIO_OUT_START + 4;

    // ==================================================================================
    //  모두 켰을경우 최대 저항값 4.2옴 IO를 키는순간 해당(CUSH, BACK)에 저항이 빼지는 형태
    //  Ex) 쿠션 1.2옴 = 1옴과 0.2옴을 제외한 IO를 키면 됨. 4.2 - (2.0 + 0.6 + 0.4)
    // ==================================================================================
    DO_HTRWIRE_CUSH_200mR = _DIO_OUT_START + 12;
    DO_HTRWIRE_CUSH_400mR = _DIO_OUT_START + 13;
    DO_HTRWIRE_CUSH_600mR = _DIO_OUT_START + 14;
    DO_HTRWIRE_CUSH_1000mR = _DIO_OUT_START + 15;
    DO_HTRWIRE_CUSH_2000mR = _DIO_OUT_START + 16;
    DO_HTRWIRE_BACK_200mR = _DIO_OUT_START + 17;
    DO_HTRWIRE_BACK_400mR = _DIO_OUT_START + 18;
    DO_HTRWIRE_BACK_600mR = _DIO_OUT_START + 19;
    DO_HTRWIRE_BACK_1000mR = _DIO_OUT_START + 20;
    DO_HTRWIRE_BACK_2000mR = _DIO_OUT_START + 21;

    DO_JG1_CUSH_MAT = _DIO_OUT_START + 24;
    DO_JG1_BACK_MAT = _DIO_OUT_START + 25;
    DO_JG1_HEAD_MAT = _DIO_OUT_START + 26;
    DO_JG1_SPARE_MAT = _DIO_OUT_START + 27;

    DO_JG1_CAR = _DIO_OUT_START + 36;
    DO_JG1_HOST_CURR_BKL = _DIO_OUT_START + 37;
    DO_JG1_HOST_IO_BKL = _DIO_OUT_START + 38;
    DO_JG1_CENTER_CURR_BKL = _DIO_OUT_START + 39;
    DO_JG1_CENTER_IO_BKL = _DIO_OUT_START + 40;
    DO_JG1_HOST_ILL_BKL =  _DIO_OUT_START + 41;
    DO_JG1_SAU_POWER =  _DIO_OUT_START + 42;

    DO_JG1_BACK_BLOWER = _DIO_OUT_START + 60;
    DO_JG1_HDREST_UD_POWER = _DIO_OUT_START + 71;

    // =================================================================================
    _LAN_OUT_START = _LAN_IO_CH_COUNT div 2;

    // =================================================================================
    // AI
    AI_MAIN_CURR = 0;
    AI_MOTOR_CURR = 1;
    AI_ECU_CURR = 2;
    AI_BUCKLE_CURR = 4;
    AI_NOISE = 5;
    AI_DIST1 = 6;
    AI_DIST2 = 7;

    AI_MAIN_CON_VOLT_START = 8;
    AI_MAIN_CON_VOLT_END = AI_MAIN_CON_VOLT_START + 33;

    AI_CUSHMAT_CON_VOLT_START = AI_MAIN_CON_VOLT_END + 1;
    AI_CUSHMAT_CON_VOLT_END =  AI_CUSHMAT_CON_VOLT_START + 7;

    AI_BACKMAT_CON_VOLT_START = AI_CUSHMAT_CON_VOLT_END + 1;
    AI_BACKMAT_CON_VOLT_END = AI_BACKMAT_CON_VOLT_START + 1;

    AI_HEADMAT_CON_VOLT_START = AI_BACKMAT_CON_VOLT_END + 1;
    AI_HEADMAT_CON_VOLT_END = AI_HEADMAT_CON_VOLT_START + 3;

    AI_BACKBLOWER_CON_VOLT_START = AI_HEADMAT_CON_VOLT_END + 1;
    AI_BACKBLOWER_CON_VOLT_END = AI_BACKBLOWER_CON_VOLT_START + 3;

    AI_HEADMTR_CON_VOLT_START = AI_BACKBLOWER_CON_VOLT_END + 1;
    AI_HEADMTR_CON_VOLT_END = AI_HEADMTR_CON_VOLT_START + 3;

    // =================================================================================
    // AO
    SYS_REF_VOLT = -1; // 시스템 기준 전압 CH(-1 V)


    // 이후 진단 AI  추가 할 것

    // =================================================================================
    // Counter

implementation

end.
