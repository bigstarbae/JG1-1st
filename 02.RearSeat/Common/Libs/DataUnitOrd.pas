unit DataUnitOrd;

interface

type

    // �˻翩��, ���� �˻翩��, �������.
    // �˻��׸� �ȿ� �ΰ� �˻��׸��� ���� ���
    // -> ���� ������ ���� ����Ÿ�� ���� �ִٸ� �ϳ��� ���, �ƴ� ��� ���� �и�.
    TTsORD = (tsNone, tsValidity,

        tsSpecCheck,

        tsResult, // ��ü����

        tsMotor,
        tsSlide, tsCushTilt, tsRelax, tsHeadrest, tsRecl,
        tsWalkinUpTilt, tsShoulder, tsLongSlide,

        tsAbnormalSound, // ���� ����

        tsTime,         // �ð� üũ ����
        tsNoise,        // �����˻翩��
        tsNoiseDev,     // ���� ���� �˻� ����
        tsCurr,         // ������������ �ݵ�� �ӵ��� ���߿� �ϳ��� �־�� �Ѵ�.
        tsSpeed,        // �ӵ���������
        tsStrokeAmount, // ������ ���� ����
        tsAngle,        // ���� �����ӿ� ���� ��ǰ ���� ���� ���� (��Ŭ ���� �����̳�, Ȥ�ø��� ����ȭ)
        tsContinuity,   // �ܼ� ���� ȸ�� �ܶ��˻� ����

        tsElec,

        tsEcuInfo,
        // H/V
        tsHeatRL, tsHeatRR,
        tsVentRL, tsVentRR,

        tsHV,

        tsDual,     // ���� ECU���ƴ� �� ECU���� ���� ���ۿ���

        tsBlow,    // ��ο�
        tsFlow, // �ܺ� ǳ���質 IO��ȣ (���� �ٶ��δ��� üũ��)

        tsBuckle,
        tsCTRBuckle,

        tsAntiPinch_Slide,
        tsAntiPinch_Recl,
        tsAntiPinch,

        tsMidPos,

        tsIMS_MEM1, // IMS
        tsIMS_MEM2, // IMS
        tsIMS_MEM3,
        tsIMS_EasyAccess,  // ������
        tsIMS,

        // ����Ʈ
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

        // ���� ���� : ������ �������� ������ ��!  caseó�� ����
        roSpecTimeLo, roSpecTimeHi, roSpecTimeHiLo,

        // ����
        roSpecCurrLo, roSpecCurrHi, roSpecCurrHiLo,

        // ���ǵ�
        roSpecFwSpeedLo, roSpecFwSpeedHi, roSpecFwSpeedHiLo, roSpecBwSpeedLo,
        roSpecBwSpeedHi, roSpecBwSpeedHiLo,

        // ���� ����
        roSpecInitNoiseTime, roSpecInitNoiseHi, roSpecRunNoiseHi,

        // ���� ���� ����
        roSpecInitNoiseDevHi, roSpecRunNoiseDevHi,

        // ������ ����
        roSpecStrokeAmountLo, roSpecStrokeAmountHi,
        roSpecStrokeAmountHiLo,

        // �鰢�� ����
        roSpecFwAngleLo, roSpecFwAngleHi, roSpecFwAngleHiLo,
        roSpecBwAngleLo, roSpecBwAngleHi, roSpecBwAngleHiLo,

        // ------------------------------------
        // ���� ����Ÿ
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

        roRsNoise, // �� ����
        roRsTotNoise, // ��ü ����

        roRsStrokeAmount, // �� ����
        roRsTotStrokeAmount, // ��ü ���� ���

        roRsAngle, // �� ����
        roRsTotAngle, // ��ü ���� ���

        // �ܼ� ���� ȸ�� �ܶ��˻�
        roRsFwContinuity, roRsBwContinuity,

        roRsContinuity, roRsTotContinuity,

        roRsFwMotor, roRsBwMotor,

        // �ӵ� + ���� + ���� + ������ + ����Ʈ + �鰢��(�ش���׸�)
        roRsMotor, // �� ����
        roRsTotMotor, // ��ü ���� ���

        // ------------------------------------
        roRsAbnormalSound, // ����(����� ����)

        // ------------------------------------
        // ��Ƽ��ġ
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
        roRsEasyAccess, // ������
        roRsIMS,

        // ------------------------------------
        // ����
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

        roRsHeatByPos, // ��Ʈ �¼���
        roRsVentByPos,

        roRsFlow,

        roRsHeat, // ���� ��ü ���
        roRsVent,
        // ------------------------------------

        roRsDTC,

        roRsTotBuckle,

        roRsEcuInfo, // ���� ECU
        roRsTotEcuInfo, // ��ü ECU

        roRsElec, // ���� : ECU + H/V + IMS ��ü ���� + ��Ŭ + DTCŬ����

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
