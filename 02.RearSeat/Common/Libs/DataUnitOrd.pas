unit DataUnitOrd;

interface

type

    // 검사여부, 실제 검사여부, 결과판정.
    // 검사항목 안에 부가 검사항목이 많을 경우
    // -> 개별 판정에 대한 데이타가 별도 있다면 하나로 명명, 아닐 경우 별도 분리.
    TTsORD = (tsNone, tsValidity,

        tsSpecCheck,

        tsResult, // 전체판정

        tsMotor,
        tsSlide, tsCushTilt, tsRelax, tsHeadrest, tsRecl,
        tsWalkinUpTilt, tsShoulder, tsLongSlide,

        tsAbnormalSound, // 이음 판정

        tsTime,         // 시간 체크 여부
        tsNoise,        // 소음검사여부
        tsNoiseDev,     // 소음 편차 검사 여부
        tsCurr,         // 전류판정여부 반드시 속도와 둘중에 하나는 있어야 한다.
        tsSpeed,        // 속도판정여부
        tsStrokeAmount, // 행정량 판정 여부
        tsAngle,        // 모터 움직임에 따른 부품 각도 판정 여부 (리클 모터 전용이나, 혹시몰라 공용화)
        tsContinuity,   // 단순 모터 회로 단락검사 여부

        tsElec,

        tsEcuInfo,
        // H/V
        tsHeatRL, tsHeatRR,
        tsVentRL, tsVentRR,

        tsHV,

        tsDual,     // 개별 ECU가아닌 한 ECU에서 듀얼로 동작여부

        tsBlow,    // 블로워
        tsFlow, // 외부 풍량계나 IO신호 (실제 바람부는지 체크용)

        tsBuckle,
        tsCTRBuckle,

        tsAntiPinch_Slide,
        tsAntiPinch_Recl,
        tsAntiPinch,

        tsMidPos,

        tsIMS_MEM1, // IMS
        tsIMS_MEM2, // IMS
        tsIMS_MEM3,
        tsIMS_EasyAccess,  // 승하차
        tsIMS,

        // 리미트
        tsLimit,
        tsLimit_Slide, tsLimit_CushTilt, tsLimit_Relax, tsLimit_Headrest, tsLimit_Recl,
        tsLimit_WalkinUpTilt, tsLimit_Shoulder, tsLimit_LongSlide,

        tsDTC,

        tsPoprcv, tsPopsnd, tsDeviation,

        tsSP34, tsSP35, tsSP36, tsSP37, tsSP38, tsSP39, tsSP40, tsSP41, tsSP42,
        tsSP43, tsSP44, tsSP45, tsSP46, tsSP47, tsSP48, tsSP49, tsSP50);

    // TTypeORD = (toUsrType, toDrvType, toSeatType, toImsType, toCarType, toLumbType, toWorkIntype, toHeatTypeDrv, toHeatTypeAss);

    TResultORD = (roNone, roIndex, roPosType, roDrvType, roWayType,
        roSeatOpType, roCarType, roPosExType,

        roImsType, roHVType, roTestType, roPartName, roPartNo, roLclPartNo,

        roDate, roTime, roDateTime, roPalletNo, roMcNo,

        roLotNo,

        roRsSpecCheck,

        // =====================================
        // Motor Type/Dir CTRL
        roSlide_CTRL, roTilt_CTRL, roRelax_CTRL, roRecl_CTRL,
        roTiltUpWalkin_CTRL, roShoulder_CTRL, roHeadrest_CTRL, roLongSlide_CTRL,

        // =====================================

        // 모터 스펙 : 스펙은 연속으로 나열할 것!  case처리 편의
        roSpecTimeLo, roSpecTimeHi, roSpecTimeHiLo,

        // 전류
        roSpecCurrLo, roSpecCurrHi, roSpecCurrHiLo,

        // 스피드
        roSpecFwSpeedLo, roSpecFwSpeedHi, roSpecFwSpeedHiLo, roSpecBwSpeedLo,
        roSpecBwSpeedHi, roSpecBwSpeedHiLo,

        // 소음 스펙
        roSpecInitNoiseTime, roSpecInitNoiseHi, roSpecRunNoiseHi,

        // 소음 편차 스펙
        roSpecInitNoiseDevHi, roSpecRunNoiseDevHi,

        // 행정량 스펙
        roSpecStrokeAmountLo, roSpecStrokeAmountHi,
        roSpecStrokeAmountHiLo,

        // 백각도 스펙
        roSpecFwAngleLo, roSpecFwAngleHi, roSpecFwAngleHiLo,
        roSpecBwAngleLo, roSpecBwAngleHi, roSpecBwAngleHiLo,

        // ------------------------------------
        // 모터 데이타
        roDataFwTime, roDataBwTime,
        roDataFwCurr, roDataBwCurr,
        roDataFwSpeed, roDataBwSpeed,
        roDataFwInitNoise, roDataFwRunNoise,
        roDataBwInitNoise, roDataBwRunNoise,

        roDataFwInitNoiseDev, roDataFwRunNoiseDev,
        roDataBwInitNoiseDev, roDataBwRunNoiseDev,

        roDataFwStrokeAmount, roDataBwStrokeAmount,
        roDataFwAngle, roDataBwAngle,

        roRsCurr, roRsTotCurr,
        roRsSpeed, roRsTotSpeed,

        roRsNoise, // 현 모터
        roRsTotNoise, // 전체 모터

        roRsStrokeAmount, // 현 모터
        roRsTotStrokeAmount, // 전체 모터 대상

        roRsAngle, // 현 모터
        roRsTotAngle, // 전체 모터 대상

        // 단순 모터 회로 단락검사
        roRsFwContinuity, roRsBwContinuity,

        roRsContinuity, roRsTotContinuity,

        roRsFwMotor, roRsBwMotor,

        // 속도 + 소음 + 전류 + 행정량 + 리미트 + 백각도(해당사항만)
        roRsMotor, // 현 모터
        roRsTotMotor, // 전체 모터 대상

        // ------------------------------------
        roRsAbnormalSound, // 이음(사용자 감지)

        // ------------------------------------
        // 안티핀치
        // ------------------------------------

        // =====================================
        // Motor Type/Dir CTRL
        roAPSlide_CTRL, roAPRecl_CTRL,
        //--------------------------------------------

        roSpecAPLoadLo, roSpecAPLoadHi, roSpecAPLoadHiLo,
        roSpecAPStopCurrHi, roSpecAPRisingCurrLo,

        roDataAntiPinchLoad, roDataAntiPinchStopCurr, roDataAntiPinchRisingCurr,

        roRsAntiPinch, roRsTotAntiPinch,

        // IMS
        roRsLimit, roRsTotLimit,

        roRsMem1, roRsMem2, roRsMem3,
        roRsEasyAccess, // 승하차
        roRsIMS,

        // ------------------------------------
        // 전장
        // ------------------------------------

        // =====================================
        // H/V Type/Dir CTRL
        roHVRL_CTRL, roHVRR_CTRL,

        roHVHeat_CTRL, roHVVent_CTRL,

        // ======================================
        // ECU Type CTRL
        roHVPSU_CTRL, roSAU_CTRL,

        // =====================================

        roSpecHeatOnLo, roSpecHeatOnHi, roSpecHeatOnHiLo, roSpecHeatOffLo,
        roSpecHeatOffHi, roSpecHeatOffHiLo, roSpecVentOnLo, roSpecVentOnHi,
        roSpecVentOnHiLo, roSpecVentOffLo, roSpecVentOffHi, roSpecVentOffHiLo,

        roSpecBuckleLo, roSpecBukcleHi, roSpecBuckleHiLo,

        roSpecEcuPartNo, roSpecEcuSwVer, roSpecEcuHwVer,

        // H/V
        roDataLedOffBit, roDataLedHiBit, roDataLedMidBit, roDataLedLoBit,

        roDataOnCurr, roDataOffCurr,

        roDataBuckle, roDataCTRBuckle,

        roDataEcuPartNo, roDataEcuSwVer, roDataEcuHwVer,

        roRsHeatByPos, // 시트 좌석별
        roRsVentByPos,

        roRsFlow,

        roRsHeat, // 히터 전체 결과
        roRsVent,
        // ------------------------------------

        roRsDTC,

        roRsTotBuckle,

        roRsEcuInfo, // 현재 ECU
        roRsTotEcuInfo, // 전체 ECU

        roRsElec, // 전장 : ECU + H/V + IMS 전체 판정 + 버클 + DTC클리어

        roRsAccessory, roRsSmart,

        roDataRework,

        // ------------------------------------
        roErIndex, roErMcNO,
        // --------
        roGroupBeginTime,

        roGroupEndTime, roGroupTime, roGroupCount,
        // --------
        roErOccurTime, roErReleaseTime,

        roErTime, roErCode, roErText, roPoprcved, roPopsnded,

        roCycleTime, roNO, roRsMidPos

      );

implementation

end.
