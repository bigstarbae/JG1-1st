unit UDSDef;

interface

uses
    SeatType, SeatMoveCtrler, SeatMotorType;

const

{


--------------------------------------------------------
    UDS ����: Limit, Pos, ���� �۵� ���� ���� ��ɵ�
--------------------------------------------------------
Ex> req command : http://hoyoung2.blogspot.com/2013/11/can-protocols.html
    ISO 15765-2 : VectorDiagnosticsSeminar.pdf ����

0. ������ ����
  - ª�� �޽��� : SF(Single Frame) :
  - �� �޽���   : FF(First Frame) ���� CF(Consecutive Frame)  : CAN Multi Frame


1. ���� �׸� : PSM (Power Seat Module)
  - CAN MSG ID (������, ��/�ļ� ���� �ٸ�)
    . REQ : 0x706,	.
    . RESP : 0x726

    # ����� ��� Type �Ǻ�
    - PCI(Protocol Control Information) bits : ���� 1Byte�� 7~4bit��  Frame Type�� ����,
        0:  single (4bit) + data length(4bit)
        1: first frame(4bit), + data length(4bit + 8bit)
        2: consecutive frame(4bit) + sequence number(4bit)
        3: flow control frame(4bit)  + flow state(4bit)


2. ��ġ �б�(RDBI: Read Data By ID) : Req ID 0x22, Resp 0x62
 - REQ  : 706 : 04 22 B4 02 00 00 00 00     // SF:
 - RES  : 726 : 10 0E 62 B4 02 F0 00 00 	// FF: 1, 2��° Byte�� ��ģ 12bit 0x00E�� ���� , 3��° 0x62 �б� ����(Positive Response Message ID)  FF
 - REQ 	: 706 : 30 08 08 AA AA AA AA AA 	// FC: Flow Ctrl ����
 - RES  : 726 : 21 00 xx yy zz 00 00 00     // CF: ���� �ΰ��� �Բ� �����($21, $22�� �Ǻ�)
          726 : 22 00 00 00 00 00 00 00 00         `

3. LIMIT ���� �б� (RC: Routine Control)  : Req ID 0x31, Resp 0x71
 - REQ : 706 : 05 31 02 12 A3 00 00 00		// SF:3��° ����Ʈ :  01: ����, 02 : ����, 	03 : ���� �б��; 4,5����Ʈ: RC ID, 6 ����Ʈ :�ɼ�
 - RES : 726 : 10 08 71 02 12 A3 01 01		// FF:2���� 0x08: ���� ������ ���� ������ ����, 3��° 0x71(Positive Response Message ID) : LIMIT ����, 7��° �����̵� 8��° ��Ŭ���̳�(���� ��)
 - REQ : 706 : 30 08 08 AA AA AA AA AA		// FC:
 - RES : 726 : 21 01 01 00 00 00 00 00		// CF:2��° ƿƮ, 3��° ����Ʈ


4. ���� ���� (IOCBI : Input output Control By Local ID of DPSU, APSU)
   706 :05 2F B4 01 03 00 00 00 -> SLIDE START
   706 :05 2F B4 01 00 00 00 00 -> SLIDE STOP
        |  |  |     |
        |  |  |     START, STOP = 00
        |  |  B4 PSM DID, 01 ���� ����.
        |  IO �������� ID.
        ��ȿ������ 2F ���� 03 (START/STOP) ���� 5��.


--------------------------------------------------------
    �������:
--------------------------------------------------------
    IBU: Integrated Body Unit
    PSM: Power Seat Module
    CGW : Central Gateway
    SJB : Smart Junction Box
    BCM : Body Control Module
    RDBI : Read Data By Id
    IOCBI : Input Output Control By Identifier
    RC: Routine Control


    // DBC �� ������Ʈ
    DPSS: Driver Power Seat Switch, ������ ���� �۵�(��,����) ����
    DPSU: Driver Power Seat Unit, ������ ����, ��ǳ ���� ����

    APSS: Assist Power Seat Switch, ������ ���� �۵� ����
    APSU:  Assist Power Seat Unit, ������ ����, ��ǳ ���� ����
    ALU: Assist Lumbar Unit
    RLHVU/RLHU : Rear LH Heater + Ventilation Unit / Rear LH Heater Unit
    RRHVU/RRHU : Rear RH Heater + Ventilation Unit / Rear RH Heater Unit
    RRPSU : Rear RH Power Seat Unit
    RARS : Rear ArmRest Switch


    // CAN MSG/DATA ID
    SID = Service ID
    LID = Local ID
    DID = Data ID

}
    //-------------------------------------
    // CAN MSG ID
    //-------------------------------------

    // 1��

    // 2���� CAN
    _1ST_UDS_MSG_2GEN_TARGET_PSM_ID = $706;  //BCM -> PSM ���� �����ϴ� ID
    _1ST_UDS_MSG_2GEN_RESP_PSM_ID = $726;  //���� ID.

    _1ST_UDS_MSG_2GEN_TARGET_APSM_ID = $709;
    _1ST_UDS_MSG_2GEN_RESP_APSM_ID = $729;


    // 3���� CAN
    _1ST_UDS_MSG_3GEN_TARGET_PSM_ID = $7A3;  //BCM -> PSM ���� �����ϴ� ID
    _1ST_UDS_MSG_3GEN_RESP_PSM_ID = $7AB;  //���� ID.

    _1ST_UDS_MSG_3GEN_TARGET_APSM_ID = $797;  //BCM -> PSM ���� �����ϴ� ID
    _1ST_UDS_MSG_3GEN_RESP_APSM_ID = $79F;  //���� ID.


    // 2��

    // 3���� CAN
    _2ND_UDS_MSG_3GEN_TARGET_RLPSM_ID = $732;
    _2ND_UDS_MSG_3GEN_RESP_RLPSM_ID = $73A;

    _2ND_UDS_MSG_3GEN_TARGET_RRPSM_ID = $731;
    _2ND_UDS_MSG_3GEN_RESP_RRPSM_ID = $739;


    // IO CTRL : ���� �۵� CMD
    _UDS_IOCBI_REQ_SID = $2F;           // Request Service ID
    _UDS_IOCBI_RESP_SID = $6F;
    _UDS_IOCBI_START = $03;
    _UDS_IOCBI_STOP = $00;
    //----------
    // Ex> ���� ��ġ Ȯ��
    //----------
    // 706 04 22 B4 02 00 00 00 00
    //     |  |  B4 PSM DID, 02 ���� ��ġ �䱸.
    //     |  ����� ID.
    //     ��ȿ������ 22 ����  4��.
    // ����
    // 726 10 XX 62 B4 02 F0 00 00
    //            |
    //            ��ġ ��û�� ���� ���� �� ������ ���� Ȯ�� ����� ����.
    // Ȯ���� �����ϸ� ������ ���� 2���� ���ŵ�.
    // 726 21 00 xx yy zz 00 00 00
    // 726 22 00 00 00 00 00 00 00
    // xx -> Lift R, yy -> Lift F, zz -> SLIDE.
    // SLIDE �� Ȯ���ߴµ� ������� ���Ĺ�(����Ʈ ��������) �� 112 ���̰� ��.


    //-------------------------------------
    // ��ġ �б� ����
    // RDBI : Read Data By ID

    _UDS_RDBI_2GEN_DID_DRV = $B4;         // 1��: LHD:$B4,  RH:$B7     2��: RL:$BA, RR:$BB
    _UDS_RDBI_2GEN_DID_PSG = $B7;
    _UDS_RDBI_2GEN_DID_RL = $BA;          // 2��
    _UDS_RDBI_2GEN_DID_RR = $BB;

    _UDS_RDBI_3GEN_DID = $B1;           // 3���� ����.

    // CMD
    _UDS_RDBI_REQ_SID = $22;
    _UDS_RDBI_RESP_SID = $62;
    _UDS_RDBI_EASY_ACCESS = $01;
    _UDS_RDBI_POSITION = $02;

    //-------------------------------------
    //LIMIT ����
    //Routine Control   : ���� �۵�
    _UDS_RC_REQ_SID = $31;
    _UDS_RC_RESP_SID = $71;

    // RC TYPE (Limit)
    // Limit CMD
    _UDS_RC_SET = $01;
    _UDS_RC_CLEAR = $02;
    _UDS_RC_GET = $03;

    _UDS_RC_2GEN_OP_ALL_LMT_CLEAR = $80;
    _UDS_RC_3GEN_OP_ALL_LMT_CLEAR = $41;

    _UDS_RC_3GEN_EEPROM_CLEAR = $B0;

    _UDS_RC_OP_REQ_ENABLE = $F0;


    // 1�� ������ ������
    _UDS_RC_DID_DRV = $12A3;
    _UDS_RC_DID_HI = $12;
    _UDS_RC_DID_LO = $A3;          // ����/������, �������� �޶���.

    _UDS_RC_DID_PSG = $12A5;
    _UDS_RC_DID_HI_PSG = $12;
    _UDS_RC_DID_LO_PSG = $A5;


    // 2�� ������ ������
    _UDS_RC_DID_RL = $12A6;
    _UDS_RC_DID_HI_RL = $12;
    _UDS_RC_DID_LO_RL = $A6;


    _UDS_RC_DID_RR = $12A7;
    _UDS_RC_DID_HI_RR = $12;
    _UDS_RC_DID_LO_RR = $A7;


    // RC 2���� OPTION
    _UDS_RC_OP_2GEN_ALL = $00;
    _UDS_RC_OP_2GEN_SLIDE = $01;
    _UDS_RC_OP_2GEN_LiftF = $03;
    _UDS_RC_OP_2GEN_LiftR = $04;
    _UDS_RC_OP_2GEN_CUSH_EXT = $06;

    // RC 3���� OPTION
    // 3����� ���� BYTE + 1 �� �������.
    _UDS_RC_OP_3GEN_ALL_SET = $40;
    _UDS_RC_OP_3GEN_RECL_SET = $42;
    _UDS_RC_OP_3GEN_SLIDE_SET = $44;
    _UDS_RC_OP_3GEN_CUSHTILT_SET = $46;
    _UDS_RC_OP_3GEN_HEIGHT_SET = $48;
    _UDS_RC_OP_3GEN_RELAX_SET = $4A;
    _UDS_RC_OP_3GEN_CUSHEXT_SET = $4C;
    _UDS_RC_OP_3GEN_LEG_SET = $4E;
    _UDS_RC_OP_3GEN_LEGEXT_SET = $50;
    _UDS_RC_OP_3GEN_FOOT_SET = $52;
    _UDS_RC_OP_3GEN_HEAD_SET = $54;
    _UDS_RC_OP_3GEN_HEADEXT_SET = $56;
    _UDS_RC_OP_3GEN_MONITOR_SET = $58;
    _UDS_RC_OP_3GEN_SHOULDER_SET = $5C;
    _UDS_RC_OP_3GEN_WALKINUPTILT_SET = $5E;

    //  LIMIT ����
    _UDS_RC_LIMIT_NO = $01;
    _UDS_RC_LIMIT_OK = $02;
    _UDS_RC_LIMIT_UNKNOWN = $03;
    _UDS_RC_LIMIT_DO = $11;
    _UDS_RC_LIMIT_OKANDWAIT = $12;

    // CanData �迭���� ��ġ
    _UDS_RESP_IDX_ID = 2;
    _UDS_RESP_IDX_CF_ID = 8;
    _UDS_RESP_IDX_CF_ID2 = 16;


    _UDS_RESP_IDX_POS_LIFT_R = 10;
    _UDS_RESP_IDX_POS_LIFT_F = 11;
    _UDS_RESP_IDX_POS_SLIDE = 12;
    _UDS_RESP_IDX_POS_RECL = 13;
    _UDS_RESP_IDX_POS_HEAD_REST = 14;
    _UDS_RESP_IDX_POS_EXT = 15;



    _UDS_RC_RESP_IDX_LIMIT_SLIDE = 6;
    _UDS_RC_RESP_IDX_LIMIT_CUSHTILT = 7;
    _UDS_RC_RESP_IDX_LIMIT_HEIGHT = 8;
    _UDS_RC_RESP_IDX_LIMIT_RELAX = 9;
    _UDS_RC_RESP_IDX_LIMIT_CUSHEXT = 10;
    _UDS_RC_RESP_IDX_LIMIT_LEGREST = 11;
    _UDS_RC_RESP_IDX_LIMIT_LEGEXT = 12;
    _UDS_RC_RESP_IDX_LIMIT_HEADREST = 14;
    _UDS_RC_RESP_IDX_LIMIT_RECLINE = 17;
    _UDS_RC_RESP_IDX_LIMIT_WALKINUPTILT = 19;
    _UDS_RC_RESP_IDX_LIMIT_SHOULDER = 20;

    UDS_USE_RC_RESP_IDXS: array[TMotorORD] of Integer = (
        _UDS_RC_RESP_IDX_LIMIT_SLIDE,
        _UDS_RC_RESP_IDX_LIMIT_RECLINE,
        _UDS_RC_RESP_IDX_LIMIT_CUSHTILT,
        _UDS_RC_RESP_IDX_LIMIT_WALKINUPTILT,
        _UDS_RC_RESP_IDX_LIMIT_SHOULDER,
        _UDS_RC_RESP_IDX_LIMIT_RELAX,
        _UDS_RC_RESP_IDX_LIMIT_HEADREST,
        _UDS_RC_RESP_IDX_LIMIT_SLIDE
  );


    _UDS_NAK_RESP = $7F;
    _UDS_REQ_FC_DATA: array[0..7] of BYTE = ($30, $08, $08, $AA, $AA, $AA, $AA, $AA);
    _UDS_REQ_CF_RESP = $21;
    _UDS_REQ_CF_RESP2 = $22;

    //-------------------------------------
    // MEMORY (FD ���� CAN ���� ���)
    _DDM_MEM_ID = $121;          // �ñ׳θ�: C_DrvIMSSW1, C_DrvIMSSW2, C_DrvIMSSWSet
    _DDM_MEM_ID2 = $402;          // �ñ׳θ�: IMS_DrvrImsSw1Sta, IMS_DrvrImsSw2Sta, IMS_DrvrImsSwSet

    _DDM_MEM_ENABLE1 = $80 or $40;    //ENABLE = $80
    _DDM_MEM_ENABLE2 = $80 or $20;
    _DDM_MEM_PLAY1 = $80 or $10;
    _DDM_MEM_PLAY2 = $80 or $08;

    // MEMORY (FD ���� CAN)
    _FD_BDC_MEM_ID = $3DA;
    _FD_BDC_MEM_ENABLE_ID = $30B;
    _FD_BDC_MEM_PLAY_RESP_ID = $178;

    _FD_BDC_MEM_ENABLE1 = $10;
    _FD_BDC_MEM_ENABLE2 = $40;
    _FD_BDC_MEM_ENABLE3 = $01;

    _FD_BDC_MEM_PLAY1 = $01;
    _FD_BDC_MEM_PLAY2 = $02;
    _FD_BDC_MEM_PLAY3 = $03;

    //-------------------------------------
    // Easy Access / �̱״ϼ� ����  (FD ���� CAN ���� ���)
    // �Ʒ� CanMsg ID�� �������� �޶����� ������ ��ġ/���� ���� �޶����� ������ �ϰ�, ��ӹ��� Ŭ������ ���� ������ ��!

    // CAN ID
    _KEY_LESS_BCM_ID = $168;
    _C_IGNSW_BCM_ID = $3E0;

    _KEY_LESS_BCM_ID2 = $411;       // ������� �߼� ID


    _C_VehicSpd_ID = $510;
    _C_DE_VehicSpd_ID = $589;
    _C_Auth_ID = $111;


    //
    _KEY_LESS_DE_DR_OPEN = $20;
    _KEY_LESS_DR_OPEN = $10;
    _KEY_LESS_DR_CLOSE = $00;


    //KeyOFF
    _C_IGNSW_KEYOFF = $00; //4th BYTE
    _C_IGNSW_KEYIN = $18;
    _CIGNSW1_KEYOFF = $00;
    _CIGNSW1_KEYIN = $80;
    _CIGNSW2_KEYOFF = $00;
    _CIGNSW2_KEYIN = $40;

    //
    _C_P_POS_ON = $04; //6th BYTE

    //
    _C_AuthState = $40;

    // Easy Access / �̱״ϼ� ���� (FD ���� CAN)
    _FD_KEY_LESS_BDC_ID = $3D1;
    _FD_GET_ONOFF_BDC_ID = $3DA;

    _FD_C_IGNSW_BDC_ID = $3D1;
    _FD_C_IGN3SW_PDC_ID = $3E0;

    _FD_C_VehicSpd_ID = $1AA;

    _FD_C_IGNSW_KEYOFF = $00;
    _FD_C_IGNSW_KEYIN = $01;
    _FD_C_IGNSW1_KEYOFF = $10;
    _FD_C_IGNSW1_KEYIN = $11;
    _FD_C_IGNSW2_KEYOFF = $40;
    _FD_C_IGNSW2_KEYIN = $41;
    _FD_C_IGNSW12_KEYOFF = $50;
    _FD_C_IGNSW12_KEYIN = $51;

    _FD_C_P_POS_ON = $01;


type
    TUDSIDSet = record
        ReqID: Cardinal;
        RespID: Cardinal;
        RCID: Cardinal;
        RDBIID: Cardinal;
    end;

const
    UDS_ID_CONFIG: array[Boolean] of TUDSIDSet =
    (
        (
        ReqID: _2ND_UDS_MSG_3GEN_TARGET_RRPSM_ID;
        RespID: _2ND_UDS_MSG_3GEN_RESP_RRPSM_ID;
        RCID: _UDS_RC_DID_RR;
        RDBIID: _UDS_RDBI_3GEN_DID;
        ),
        (
        ReqID: _2ND_UDS_MSG_3GEN_TARGET_RLPSM_ID;
        RespID: _2ND_UDS_MSG_3GEN_RESP_RLPSM_ID;
        RCID: _UDS_RC_DID_RL;
        RDBIID: _UDS_RDBI_3GEN_DID;
        )
    );

    // JG1 ������ ���� ID ��
  JG1_2ND_UDS_LID_MAP: TMotorLIDMap = (
    $41,    // tmRecl
    $43,    // tmSlide
    $45,    // tmCushTilt
    $49,    // tmRelax
    $55,    // tmHeadrest
    $59,    // tmShoulder
    $5B,    // tmWalkinUpTilt
    $00     // tmLongSlide (���� ������)
  );



implementation

end.

