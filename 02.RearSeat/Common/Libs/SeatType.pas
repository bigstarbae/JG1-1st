unit SeatType;

interface

type
    // 시트 사양 TYPE
    TSEATS_TYPE = (st4P, st5P, st6P, st7P);

    TPOS_TYPE = (ptLH, ptRH);

    TCAR_TYPE = (ctJG1, ctSPARE1);

    TCAR_TRIM_TYPE = (cstSTD, cstSE);

    THV_TYPE = (htNoneHV, htHeat, htHV);

    TBK_TYPE = (btNoneBK, btIO, btILL);

    TMTR_TYPE = (mtSlide, mtRecline, mtCushTilt, mtWalkinTilt, mtRelax, mtShoulder, mtHeadrest, mtLongSlide);

    TMTR_TYPE_array = array of TMTR_TYPE;

    TECU_TYPE = (etHVPSU, etSAU);

    TAP_TYPE = (atSlide, atRecline);

const

    TSEATS_TYPE_STR: array[0 .. 3] of string = ('4P', '5P', '6P', '7P');
    TPOS_TYPE_STR: array [0 .. 1] of string = ('LH', 'RH');
    TCAR_TYPE_STR: array [0 .. 1] of string = ('JG1', '-');
    TCAR_TRIM_TYPE_STR: array [0 .. 1] of string = ('STD', 'SE');
    THV_TYPE_STR: array [0 .. 2] of string = ('NONE H/V', 'HTR', 'HTR/VNT');
    TBUCKLE_TYPE_STR: array [0 .. 2] of string = ('NONE BKL', 'BKL IO', 'BKL ILL');//, _TR('BKL IO/센서'));
    TECU_TYPE_STR: array[0 .. 1] of string = ('HVPSU', 'SAU');



implementation

end.


