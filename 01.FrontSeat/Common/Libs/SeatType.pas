unit SeatType;

interface

type
    // 시트 사양 TYPE
    TPOS_TYPE = (ptLH, ptRH);
    TDRV_TYPE = (dtLHD, dtRHD);
    TPOS_TYPE_EX = (pteLHP, pteRHP, pteLHD, pteRHD);
    {
     - SLIDE : 2WAY
     - SLIDE + RECL : 4WAY
     - S + R + HEIGHT : 6WAY
     - S + R+ H + TILT : 8WAY
     - S + R + H + T + CUSH.EXT: 10WAY
    }


    TCAR_TYPE = (ctJG1, ctRJ1, ctHI, ctSPARE1, ctSPARE2);
    TCAR_TRIM_TYPE = (cttSTD, cttLONG_S, cttSwivel);


    TECU_TYPE = (rtNoneEcu, rtECU);
    TIMS_TYPE = (rtNoneIms, rtIMS);

    THV_TYPE = (htNoneHV, htHeat, htHV);
    TBuckleTestType = (btNone, btIO, btCurr, btIOCurr);
    TODS_TYPE  = (rtNoneOds, rtODS);
    TANCHORPT_TYPE = (rtACPTNone, rtACPT);

    TBC_PART_TYPE = (bptUnknown, bptECU, bptECU2, bptBuckle, bptHeight, bptWire, bptVentFan, bptODS, bptWkIn);
    TBC_PART_TYPE_ARRAY = array of TBC_PART_TYPE;





const
    TCAR_TYPE_COUNT   = Ord(High(TCAR_TYPE));
    TCAR_TRIM_TYPE_COUNT  = Ord(High(TCAR_TRIM_TYPE));

    TPOS_TYPE_STR: array [0 .. 1] of string = ('LH', 'RH');
    TDRV_TYPE_STR: array [0 .. 1] of string = ('LHD', 'RHD');
    TPOS_TYPE_EX_STR: array [0 .. 3] of string = ('LH', 'RH', 'LHD', 'RHD');
    TFRT_POS_ROLE_STR: array [0 .. 1] of string = ('DRV', 'PSG');


    TCAR_TYPE_STR: array [0 .. TCAR_TYPE_Count] of string = ('JG1', 'RJ1', 'HI', 'SPARE1', 'SPARE2');
    TCAR_TRIM_TYPE_STR: array [0 .. TCAR_TRIM_TYPE_COUNT] of string = ('STD', 'LONG_S', 'Swivel');

    TECU_TYPE_STR: array [0 .. Ord(High(TECU_TYPE))] of string = ('NONE ECU', 'ECU');
    TIMS_TYPE_STR : array[0 .. 1] of string = ('NONE IMS', 'IMS') ;

    TBUCKLE_TYPE_STR: array [0 .. 2] of string = ('NONE BKL', 'BKL IO', 'BKL SNSR');//, _TR('BKL IO/센서'));


    THV_TYPE_STR: array [0 .. 2] of string = ('NONE H/V', 'HTR', 'HTR/VNT');//, 'VNT');

    TBC_PART_TYPE_STR: array [TBC_PART_TYPE] of string = ('UNKNOWN', 'ECU', 'ECU2', 'BUCKLE', 'HEIGHT MTR', 'WIRE', 'VENT FAN', 'ODS', 'WK-IN');
    TSW_STR: array [false .. true] of string = ('OFF', 'ON');

implementation

end.


