{
    240919.00
}
unit KiiMessages;

interface
uses
    messages ;

const

    WM_SYS_CODE = WM_USER+30501 ;               // 실제 윈도우 메시지는 WM_SYS_CODE 1개만 사용됨 !!!!
    SYS_CODE =   WM_SYS_CODE;

    WM_BC_READED = WM_USER + 1000;          // DataViewr같은 다른 프로그램에 바코드 데이타  전달

    {wParam}   // tw_XXX 계열이 wParam(awCode)에 실리기도 함.

    SYS_GRAPH       = WM_SYS_CODE+101 ;
    SYS_BASE        = WM_SYS_CODE+102 ; // 기본 Reference 변경
    SYS_COUNT_UPDATES = WM_SYS_CODE+103 ; // 단위변경 kgf -> User Unit or User Unit -> Kgf
    SYS_CPK         = WM_SYS_CODE+104 ;  // CPK setting changed
    SYS_CPK_UPDATES = WM_SYS_CODE+105 ;
    SYS_PORT        = WM_SYS_CODE+106 ; // Port 가 하나라도 변경되면 전송. 메인work에서 한꺼번에 변경.
    SYS_PORT_END    = WM_SYS_CODE+107 ;
    SYS_DEL         = WM_SYS_CODE+108 ;
    SYS_LABEL       = WM_SYS_CODE+109 ;
    SYS_IO_CHANGED  = WM_SYS_CODE+110 ;
    SYS_CLOSE_CLICK = WM_SYS_CODE+111 ; //메인화면에서 단축키가 안먹힐때 해당객체 키다운에서...
    SYS_UPDATES     = WM_SYS_CODE+112 ; //Notify Form Increase Event
    SYS_OFFSET      = WM_SYS_CODE+113 ;
    SYS_PING        = WM_SYS_CODE+114 ;  // START : 0 ALINE : 1 DEAD : 2
    SYS_UDP         = WM_SYS_CODE+115 ;  // WRITE : 0 READ  : 1 END  : 2

    SYS_CLOSE       = WM_SYS_CODE+118 ;
    SYS_ERROR       = WM_SYS_CODE+119 ;
    SYS_MODEL       = WM_SYS_CODE+120 ;
    SYS_INSPECTOR   = WM_SYS_CODE+121 ;
    SYS_FORM_CALL   = WM_SYS_CODE+122 ;
    SYS_LAN_PORT_CHANGED = WM_SYS_CODE+123 ;

    SYS_PORT_NOTIFY = WM_SYS_CODE+2222 ; // 각포트의 상태 전송 PortNumber + Status(0 Close/1 Open/2 Error)

    SYS_USERCOM     = WM_SYS_CODE+2048 ;
    SYS_USER_MESSAGE= WM_SYS_CODE+4096 ; // 프로젝트에 국한하여 사용할 경우 이 번호 다음부터

    //---------------------------------------------------------------------------------------------
    SYS_VISIBLE_LOG   = SYS_USER_MESSAGE + 4 ;
    //TCP/IP or UDP/IP
    SYS_CONNECTED     = SYS_USER_MESSAGE + 7 ;
    SYS_CONNECTING    = SYS_USER_MESSAGE + 8 ;
    SYS_DISCONNECTED  = SYS_USER_MESSAGE + 9 ;
    SYS_TCP_ERROR     = SYS_USER_MESSAGE + 10 ;
    SYS_TCP_READ      = SYS_USER_MESSAGE + 11 ;
    SYS_TCP_WRITE     = SYS_USER_MESSAGE + 12 ;

    SYS_LIST_UPDATE   = SYS_USER_MESSAGE + 15 ;

    SYS_RCV_ERROR     = SYS_USER_MESSAGE + 17 ;
    SYS_PLC_ERROR     = SYS_USER_MESSAGE + 18 ;

    SYS_ZERO_END      = SYS_USER_MESSAGE + 20 ; // 수동 제로를 할때
    SYS_TS_PROCESS    = SYS_USER_MESSAGE + 21 ; // 프로세스의 진행절차를 이벤트로
    SYS_MK_PROCESS    = SYS_USER_MESSAGE + 22 ; // 마킹
    SYS_RUN_MODE      = SYS_USER_MESSAGE + 23 ;

    SYS_PALLET_CHANGED  = SYS_USER_MESSAGE + 24 ;
    SYS_RFID_CHANGED    = SYS_USER_MESSAGE + 25 ;
    SYS_PALLET_MOVED    = SYS_USER_MESSAGE + 26 ;

    SYS_SAVE_DATA       = SYS_USER_MESSAGE + 27 ;
    SYS_UPDATE_NG       = SYS_USER_MESSAGE + 28 ;

    SYS_CAN_OPEN        = SYS_USER_MESSAGE + 29 ;
    SYS_CAN_CLOSE       = SYS_USER_MESSAGE + 30 ;
    SYS_CAN_READ        = SYS_USER_MESSAGE + 31 ;
    SYS_CAN_WRITE       = SYS_USER_MESSAGE + 32 ;
    SYS_CAN_ERROR       = SYS_USER_MESSAGE + 33 ;

    SYS_POP_CONNECTED    = SYS_USER_MESSAGE + 34 ;
    SYS_POP_CONNECTING   = SYS_USER_MESSAGE + 35 ;
    SYS_POP_DISCONNECTED = SYS_USER_MESSAGE + 36 ;
    SYS_POP_ERROR        = SYS_USER_MESSAGE + 37 ;
    SYS_POP_READ         = SYS_USER_MESSAGE + 38 ;
    SYS_POP_WRITE        = SYS_USER_MESSAGE + 39 ;
    SYS_ETHERNET_ERROR   = SYS_USER_MESSAGE + 40 ;
    SYS_POP_CHANGE       = SYS_USER_MESSAGE + 41 ;
    SYS_POP_LIST_UPDATE  = SYS_USER_MESSAGE + 42 ;
    SYS_POP_READY        = SYS_USER_MESSAGE + 43 ;
    SYS_POP_RCV_ERROR    = SYS_USER_MESSAGE + 44 ;
    SYS_POP_RCV_MODEL    = SYS_USER_MESSAGE + 45 ;
    SYS_POP_MESSAGES     = SYS_USER_MESSAGE + 46 ;


    SYS_MSG_ERR          = SYS_USER_MESSAGE + 50 ;
    SYS_MSG_NOTIFY       = SYS_USER_MESSAGE + 51 ;

    SYS_ECAT_STATUS      = SYS_USER_MESSAGE + 52;
    SYS_SCAN_STATUS      = SYS_USER_MESSAGE + 53;
    SYS_LIN_STATUS      = SYS_USER_MESSAGE  + 54;



type
    //EVENT
    TNotifyStatus = procedure (Sender:TObject; AStatus: integer)of Object ;
    TNotifyRun = procedure(Sender: TObject; AIsRun: boolean) of Object;
    TNotifyDevCom = procedure(Sender: TObject; ADatas: string) of Object;
    TNotifyProcEvent = procedure(Sender: TObject; AStatus: integer; ADatas: string) of Object;


implementation

end.
