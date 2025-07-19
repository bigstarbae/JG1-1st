{
    Ver.1.9101100
        : TClientSocket -> TTCPBlockSocket로 변경 (NonBlockMode 사용)

    Ver.211118.00
        : GetLoadPort/SetSavePort : Hex 및 Dec지원 overload 함수 추가
}

unit UserSocketUnit;

{$INCLUDE myDefine.INC}

//------------------------------------------------------------------------------
//
// 클라이언트 TCP 소켓을 이용한 통신 프로세서.
//
//    다음을 만든 이유 ------------------------------------------------
//      이더넷을 이용한 통신에서 그 내용이 너무 많아 시간이 지체될 경우
//      포트를 나누어 동시에 작업을 할 수 있다면 속도가 더 빠르지 않을까???
//
// 1. 같은 IP에 여러개의 포트를 생성하여 동시 작업성을 늘리는 기능.
// 2. 생성된 포트는 자체 관리한다.
// 3. 다른 객체가 이용할때는 유휴 포트를 검색하여 포트가 존재할 경우 송신할
//    데이터를 형식에 맞게 넣어 주면 유휴 포트를 이용해 전송해 준다.
// 4. 수신 확인은 클래스의 메소드 포인터를 이용한다, 데이터 형식 참조.
// 5. 송신만 할경우 4번의 포인트에 nil을 지정하면 됨.
// 6. 현재 작업의 우선 순위가 별도로 존재하지 않음.
//
// 2007.02.28
//
// TDIO 의 클래스와 연결되는 기능 변경.
// PLC와 통신은 DI/O, RS232, TCP/IP, UDP의 방식이 있으며
// 각각의 기능에 따라 TDIO 가 동작할 수 있도록 수정.
//
// DI/O     TCP     UDP     RS232
//  |        |       |        |
//  +--------+-------+--------+
//               |
//             TDIO
//
// PortType : 0 은 어떤타입이든 상관없다, > 1 사용자가 지정한 타입 구분.
//------------------------------------------------------------------------------
interface

uses
    Windows, Messages, SysUtils, Classes, MelsecPackEx, Blcksock, ScktComp,
    KiiMessages, TimeChecker;

const
    _NOTIFY_CLOSE = '_SOCKET_CLOSE';
    _MAX_IP = 12;

type
    TNotifyRcvDatas = procedure(Sender: TObject; ADatas: Ansistring) of object;
//------------------------------------------------------------------------------

    TLanEnv = record
        rErWaitTime: double;   // 오류로 연결이 끊어졌을 경우 딜레이 시간
        rWaitTime: double;   // 응답대기 타임아웃
        rConnectTime: double; //ReConnecting Time
        rSendTerm: double; //전송간격
        rReConOfSndFault: boolean; // 3회전송 실패시 재연결 유무
    end;
//------------------------------------------------------------------------------

    TListUseTypes = (utERROR, utDATA, utDATA_READ, utDATA_READED);

    pMelsecAddrList = ^TMelsecAddrList;

    TMelsecAddrList = record
        rMode: TModes;
        rDeviceName: CHAR;
        rBeginAdd: WORD;
        rReadCount: WORD;
        rDataTypes: TDataTypes;
        rBatchType: TBatchTypes;
    // 전송여부, 다음 수순을 찾기위해서...
    // 0 : 전송준비완료, 1 : 전송완료, 2 : 수신확인.
        rFlag: integer;
    // 용도결정
    // 0: ERROR CODE 1: DATA 2: DATA READ시그널, 3: DATA 수신완료시그널
        rUseType: TListUseTypes;
        rUseIt: boolean; // 사용여부, 필요에 따라서 전송하는 것을 구별한다.
    end;

    pSocketData = ^TSocketData;

    TSocketData = record
        rCode: integer;          // 자신의 것을 구별할 수 있도록...
        rNotify: TNotifyRcvDatas;  // 전송된 데이터(READ/WRITE)별로 메소드 분리할것.
        rRcvCount: WORD;           // 받아야 하는 최소갯수
        rUsrRepeat: WORD;
        rRepeat: boolean;        // 수신완료 되더라도 삭제하지 않고 반복한다.
        rNotReturn: boolean;        // 전송만
        rReadOnly: boolean;        // 수신전송
        rWaitTime: double;
        rDatas: string[255]; //rDatas   : array[0..512]of ANSICHAR ;//AnsiString ;
        rTag: Integer;      // ex: Data(Model)패킷 구분 용도

        procedure Init(Code: integer; Notify: TNotifyRcvDatas; Datas: AnsiString);

        case integer of
            0:
                (rLength: WORD);
            1:
                (rDataCount: WORD);

    end;
    //------------------------------------------------------------------------------

    TUserPort = class;
    //------------------------------------------------------------------------------

    TSocketMan = class
    private
        mwnd: HWND;
        mProc: integer;
        mUsrPorts: array of TUserPort;
        mReset: boolean; // Port, IP, 등등의 변경되었을때 작업 여부

        mIndex: integer;
        mpTypeList: array of array of TObject;

        class var
            mUseMsgPumping: boolean;            // 자체 윈도우 메시지 펌핑 사용시, PG내에 Synchronize 사용안할시 필수 적용 할 것

        procedure LoadPortList;
        procedure ClearList;
        function GetPortItem(AIndex: integer): TUserPort;
        function GetIdlePortCount: integer;
        procedure CheckErrorPorts;
    public
        constructor Create(AWnd: HWND; UseMsgPumping: boolean);
        destructor Destroy; override;

        function Count: integer; // TUserPort class Count ;
        procedure Reset; // 작업을 완료한 뒤에 모든 연결을 끊고 세팅을 다시함
        procedure Start;
        procedure Stop;  //종료시에만 호출할것

        function IsOpenPort(APortType: integer; var AIP: string): integer; overload;
        function IsOpenPort(APortType: integer): integer; overload;
        function IsIdlePort(APortType: integer; var AIP: string): integer;
        function IsOpenedPort: integer;
        function GetUserPort(AIndex, APort: integer): TUserPort; overload;
        function GetUserPort(AIP: string; APort: integer): TUserPort; overload;
        function Add(AsndData: TSocketData; IsForce: boolean = false): integer; overload;// return Port Number
        function Add(AIP: string; APort: integer; AsndData: TSocketData; IsForce: boolean = false): integer; overload;// return Port Number
        function IsExists(AData: integer): integer; // rCode exists check
        function GetMessageHandle: HWND;
        function IsExistsUserPort(APortType: integer): integer;
        function GetUserPort(aPortType: integer): TUserPort; overload;

        procedure WorkProcess(Sender: TObject);

        property Items[Index: integer]: TUserPort read GetPortItem;

    end;
//------------------------------------------------------------------------------

    TUserPort = class
    private
        mIndex: integer;
        mHandle: HWND; // 자신의 상태를 알려줄 윈도의 핸들
        mList: TList;

        mProc: integer;
        mRepeat, mUsrRepeat: integer;     //재전송횟수
        mClient: TTCPBlockSocket;
        mStop: boolean;
        mTime, mWriteTime: double;
        mLastError: string;
        mLastMessage: integer;

        mConnectCount: integer;
        //debug
        mLastDatas: Ansistring;
        mStatusEvent: TNotifyStatus;
        mTmpTime, mTermTime: double;
        mWaitTime: double;

        mTC: TTimeChecker;

        //event
        procedure OnUsrSocketConnect();
        procedure OnUsrSocketConnecting();
        procedure OnUsrSocketDisconnect();
        procedure OnUsrSocketError(ErrorEvent: TErrorEvent);
        procedure OnUsrSocketLookup();
        procedure OnUsrSocketRead();
        procedure OnUsrSocketWrite();
        procedure OnSktStatus(Sender: TObject; Reason: THookSocketReason; const Value: string);
        //
        function LoadData(var Value: Ansistring): integer;
        function SendData(AData: Ansistring): boolean;
        procedure SetMessage(ACode: integer);
        procedure ReadedFirstData(ARecieved: boolean; IsForce: boolean = false);
        procedure WorkProcess(Sender: TObject);
        //
        function IsStoped: boolean;
        procedure ClearList;
    public
        constructor Create(AWnd: HWND; AClient: TTCPBlockSocket; AIndex: integer);
        destructor Destroy; override;

        procedure Start;
        procedure Stop;  //작업을 완료하고 접속을 끊음.
        procedure Close; //작업을 완료하지 않고 접속을 끊음

        function IP: string;
        function Port: integer;
        function Count: integer;
        function IsRun: boolean;
        function IsConnected: boolean;
        function Add(AsndData: TSocketData; IsForce: boolean = false): integer; // return Port Number
        function GetLastData: pSocketData;
        function GetLastTxt: string;
        function IsExists(AData: integer): boolean;
        function GetPortType: integer;
        procedure ClearUsrDatas(IsAll: boolean);

        procedure ClearReceiveBuffer;



    // 외부용도로
        property OnStatus: TNotifyStatus read mStatusEvent write mStatusEvent;
        property ReadWriteTime: double read mTermTime;
        property LastError: string read mLastError;
    end;

procedure LoadLanEnv;

procedure SaveLanEnv;

function GetIPToDec(AIP: string): Int64;

function GetLoadPortUse(AIndex: integer): boolean;

function GetLoadIP(AIndex: integer): string;

function GetLoadPort(AIndex: WORD): WORD; overload;

function GetLoadPort(AIndex: WORD; var IsHexVal: boolean): WORD; overload;

function GetLoadPortType(AIndex: integer): integer;

procedure SetSavePortUse(AIndex: integer; AUse: boolean);

procedure SetSaveIP(AIndex: integer; AIP: string);

procedure SetSavePort(AIndex, APort: WORD); overload;

procedure SetSavePort(AIndex, APort: WORD; IsHexVal: boolean); overload;

procedure SetSavePortType(AIndex, AType: integer);
//------------------------------------------------------------------------------

var
    gSocketMan: TSocketMan;
    gLanEnv: TLanEnv;

implementation

uses
    Forms, IniFiles, myUtils, Log;

const
    _NONE_PROC = 0;
    _CONNECTING = 1;
    _CONNECT_WAIT = 2;
    _CHECK_DATA = 3;
    _WRITE_DATA = 4;
    _RESPONSE_WAIT = 5;
    _DELAY_TIME = 6;
    //_FAULT_PROC    = 7 ;
    _WAIT_DISCONNECTED = 7;
    _STOP_PROC = 8;

    //_CHECK_DATA.._RESPONSE_WAIT --> IsRun

var
    lpList: TStrings;
//------------------------------------------------------------------------------

procedure LoadLanEnv;
var
    Ini: TIniFile;
    sTm: string;
begin
    FillChar(gLanEnv, sizeof(TLanEnv), 0);

    sTm := Format('%s\env\LanEnvFile.env', [GetHomeDirectory]);
    if not DirectoryExists(ExtractFileDir(sTm)) then
        ForceDirectories(ExtractFileDir(sTm));

    Ini := TIniFile.Create(sTm);
    try
        with gLanEnv do
        begin
            rErWaitTime := Ini.ReadFloat('TCP_IP', '_ER_WAIT_TIME', 30000); //1분
            rWaitTime := Ini.ReadFloat('TCP_IP', '_WAIT_TIME', 1000.0);   //1초
            rConnectTime := Ini.ReadFloat('TCP_IP', '_CONNECT_TIME', 5000.0);//2초
            rSendTerm := Ini.ReadFloat('TCP_IP', '_SEND_TERM', 0);
            rReConOfSndFault := Ini.ReadBool('TCP_IP', '_RECON_OF_SND_FAULT', true);
        end;
    finally
        Ini.Free;
    end;
end;

procedure SaveLanEnv;
var
    Ini: TIniFile;
    sTm: string;
begin
    sTm := Format('%s\env\LanEnvFile.env', [GetHomeDirectory]);
    if not DirectoryExists(ExtractFileDir(sTm)) then
        ForceDirectories(ExtractFileDir(sTm));

    Ini := TIniFile.Create(sTm);
    try
        with gLanEnv do
        begin
            Ini.WriteFloat('TCP_IP', '_ER_WAIT_TIME', rErWaitTime);
            Ini.WriteFloat('TCP_IP', '_WAIT_TIME', rWaitTime);
            Ini.WriteFloat('TCP_IP', '_CONNECT_TIME', rConnectTime);
            Ini.WriteFloat('TCP_IP', '_SEND_TERM', rSendTerm);
            Ini.WriteBool('TCP_IP', '_RECON_OF_SND_FAULT', rReConOfSndFault);
        end;
    finally
        Ini.Free;
    end;
end;

function GetIPToDec(AIP: string): Int64;
var
    nP: DWORD;
    i, iTm: integer;
    sTm: string;
begin
    Result := -1;

    sTm := '';
    nP := 0;

    for i := 1 to Length(AIP) do
    begin
        if AIP[i] in ['0'..'9'] then
        begin
            sTm := sTm + AIP[i];
        end
        else if AIP[i] in ['.'] then
        begin
            iTm := StrToIntDef(sTm, -1);
            if not (iTm in [0..255]) then
                Exit;

            nP := (nP shl 8) or BYTE(iTm);
            sTm := '';
        end
        else
            Exit;

        if Length(AIP) = i then
        begin
            iTm := StrToIntDef(sTm, -1);
            if not (iTm in [0..255]) then
                Exit;

            nP := (nP shl 8) or BYTE(iTm);
        end;
    end;

    Result := nP;
end;

function GetDecToIP(AVal: DWORD): string;
begin
    Result := Format('%d.%d.%d.%d', [BYTE(AVal shr 24), BYTE(AVal shr 16), BYTE(AVal shr 8), BYTE(AVal)]);
end;

function GetLoadPortUse(AIndex: integer): boolean;
var
    Ini: TIniFile;
    sTm: string;
begin
    sTm := Format('%s\env\LanEnvFile.env', [GetHomeDirectory]);
    if not DirectoryExists(ExtractFileDir(sTm)) then
        ForceDirectories(ExtractFileDir(sTm));

    if AIndex < 1 then
        AIndex := 1;
    Ini := TIniFile.Create(sTm);
    try
        Result := Ini.ReadBool('PORT_LIST', '_USE' + IntToStr(AIndex), false);
    finally
        Ini.Free;
    end;
end;

function GetLoadIP(AIndex: integer): string;
var
    Ini: TIniFile;
    sTm: string;
begin
    sTm := Format('%s\env\LanEnvFile.env', [GetHomeDirectory]);
    if not DirectoryExists(ExtractFileDir(sTm)) then
        ForceDirectories(ExtractFileDir(sTm));

    if AIndex < 1 then
        AIndex := 1;
    Ini := TIniFile.Create(sTm);
    try
        Result := Ini.ReadString('PORT_LIST', '_HOST_IP' + IntToStr(AIndex), '192.168.1.11');
        if not Ini.ValueExists('PORT_LIST', '_HOST_IP' + IntToStr(AIndex)) then
        begin
            Ini.WriteString('PORT_LIST', '_HOST_IP' + IntToStr(AIndex), Result);
        end;
    finally
        Ini.Free;
    end;
end;

function GetLoadPort(AIndex: WORD): WORD;
var
    Ini: TIniFile;
    sTm: string;
begin
    sTm := Format('%s\env\LanEnvFile.env', [GetHomeDirectory]);
    if not DirectoryExists(ExtractFileDir(sTm)) then
        ForceDirectories(ExtractFileDir(sTm));

    if AIndex < 1 then
        AIndex := 1;
    Ini := TIniFile.Create(sTm);
    try
        Result := Ini.ReadInteger('PORT_LIST', '_PORT' + IntToStr(AIndex), $FFF + AIndex);
        if not Ini.ValueExists('PORT_LIST', '_PORT' + IntToStr(AIndex)) then
        begin
            Ini.WriteInteger('PORT_LIST', '_PORT' + IntToStr(AIndex), Result);
        end;
    finally
        Ini.Free;
    end;
end;

function GetLoadPort(AIndex: WORD; var IsHexVal: boolean): WORD;
var
    Ini: TIniFile;
    sTm: string;
begin
    sTm := Format('%s\env\LanEnvFile.env', [GetHomeDirectory]);
    if not DirectoryExists(ExtractFileDir(sTm)) then
        ForceDirectories(ExtractFileDir(sTm));

    if AIndex < 1 then
        AIndex := 1;
    Ini := TIniFile.Create(sTm);
    try
        //Result := Ini.ReadInteger('PORT_LIST', '_PORT'+IntToStr(AIndex), $FFF+Aindex) ;
        sTm := Ini.ReadString('PORT_LIST', '_PORT' + IntToStr(AIndex), '$FFF' + IntToStr(AIndex));

        IsHexVal := Pos('$', sTm) > 0;
        Result := StrToIntDef(sTm, -1);

        if not Ini.ValueExists('PORT_LIST', '_PORT' + IntToStr(AIndex)) then
        begin
            Ini.WriteInteger('PORT_LIST', '_PORT' + IntToStr(AIndex), Result);
        end;
    finally
        Ini.Free;
    end;
end;

function GetLoadPortType(AIndex: integer): integer;
var
    Ini: TIniFile;
    sTm: string;
begin
    sTm := Format('%s\env\LanEnvFile.env', [GetHomeDirectory]);
    if not DirectoryExists(ExtractFileDir(sTm)) then
        ForceDirectories(ExtractFileDir(sTm));

    if AIndex < 1 then
        AIndex := 1;
    Ini := TIniFile.Create(sTm);
    try
        Result := Ini.ReadInteger('PORT_LIST', '_TYPE' + IntToStr(AIndex), 0);
        if not Ini.ValueExists('PORT_LIST', '_TYPE' + IntToStr(AIndex)) then
        begin
            Ini.WriteInteger('PORT_LIST', '_TYPE' + IntToStr(AIndex), 0);
        end;
    finally
        Ini.Free;
    end;
end;

procedure SetSavePortUse(AIndex: integer; AUse: boolean);
var
    Ini: TIniFile;
    sTm: string;
begin
    sTm := Format('%s\env\LanEnvFile.env', [GetHomeDirectory]);
    if not DirectoryExists(ExtractFileDir(sTm)) then
        ForceDirectories(ExtractFileDir(sTm));

    if AIndex < 1 then
        AIndex := 1;
    Ini := TIniFile.Create(sTm);
    try
        Ini.WriteBool('PORT_LIST', '_USE' + IntToStr(AIndex), AUse);
    finally
        Ini.Free;
    end;
end;

procedure SetSaveIP(AIndex: integer; AIP: string);
var
    Ini: TIniFile;
    sTm: string;
begin
    sTm := Format('%s\env\LanEnvFile.env', [GetHomeDirectory]);
    if not DirectoryExists(ExtractFileDir(sTm)) then
        ForceDirectories(ExtractFileDir(sTm));

    if AIndex < 1 then
        AIndex := 1;
    Ini := TIniFile.Create(sTm);
    try
        Ini.WriteString('PORT_LIST', '_HOST_IP' + IntToStr(AIndex), AIP);
    finally
        Ini.Free;
    end;
end;

procedure SetSavePort(AIndex, APort: WORD);
var
    Ini: TIniFile;
    sTm: string;
begin
    sTm := Format('%s\env\LanEnvFile.env', [GetHomeDirectory]);
    if not DirectoryExists(ExtractFileDir(sTm)) then
        ForceDirectories(ExtractFileDir(sTm));

    if AIndex < 1 then
        AIndex := 1;
    Ini := TIniFile.Create(sTm);
    try
        Ini.WriteInteger('PORT_LIST', '_PORT' + IntToStr(AIndex), APort);
    finally
        Ini.Free;
    end;
end;

procedure SetSavePort(AIndex, APort: WORD; IsHexVal: boolean);
var
    Ini: TIniFile;
    sTm: string;
begin
    sTm := Format('%s\env\LanEnvFile.env', [GetHomeDirectory]);
    if not DirectoryExists(ExtractFileDir(sTm)) then
        ForceDirectories(ExtractFileDir(sTm));

    if AIndex < 1 then
        AIndex := 1;
    Ini := TIniFile.Create(sTm);
    try
        if IsHexVal then
            Ini.WriteString('PORT_LIST', '_PORT' + IntToStr(AIndex), '$' + IntToHex(APort, 4))
        else
            Ini.WriteInteger('PORT_LIST', '_PORT' + IntToStr(AIndex), APort);
    finally
        Ini.Free;
    end;
end;

procedure SetSavePortType(AIndex, AType: integer);
var
    Ini: TIniFile;
    sTm: string;
begin
    sTm := Format('%s\env\LanEnvFile.env', [GetHomeDirectory]);
    if not DirectoryExists(ExtractFileDir(sTm)) then
        ForceDirectories(ExtractFileDir(sTm));

    if AIndex < 1 then
        AIndex := 1;
    Ini := TIniFile.Create(sTm);
    try
        Ini.WriteInteger('PORT_LIST', '_TYPE' + IntToStr(AIndex), AType);
    finally
        Ini.Free;
    end;
end;
//------------------------------------------------------------------------------
// TSocketMan
//------------------------------------------------------------------------------

constructor TSocketMan.Create(AWnd: HWND; UseMsgPumping: boolean);
begin
    mwnd := AWnd;
    mProc := 0;
    //mCurIndex := 0 ;
    mReset := false;

    mUseMsgPumping := UseMsgPumping;

    LoadPortList;
end;
//------------------------------------------------------------------------------

destructor TSocketMan.Destroy;
begin
    ClearList;
end;
//------------------------------------------------------------------------------

procedure TSocketMan.LoadPortList;
var
    i, j: integer;
    cltsocket: TTCPBlockSocket;
    IsHexVal, bTm: boolean;
begin
    ClearList;

    for i := 0 to _MAX_IP - 1 do
    begin
        if not GetLoadPortUse(i + 1) then
            Continue;
        SetLength(mUsrPorts, Length(mUsrPorts) + 1);

        cltsocket := TTCPBlockSocket.Create();

        with cltsocket do
        begin
            IP := GetLoadIP(i + 1);
            Port := GetLoadPort(i + 1, IsHexVal);
            if IsHexVal then
            begin

            end;
            Tag := GetLoadPortType(i + 1);
            NonBlockMode := true;

        end;
        mUsrPorts[Length(mUsrPorts) - 1] := TUserPort.Create(mWnd, cltsocket, i + 1);
        //
        bTm := false;
        for j := 0 to Length(mpTypeList) - 1 do
        begin
            with TUserPort(mpTypeList[j][0]) do
            begin
                if GetPortType = mUsrPorts[Length(mUsrPorts) - 1].GetPortType then
                begin
                    SetLength(mpTypeList[j], Length(mpTypeList[j]) + 1);
                    mpTypeList[j][Length(mpTypeList[j]) - 1] := mUsrPorts[Length(mUsrPorts) - 1];
                    bTm := true;
                    Break;
                end;
            end;
        end;

        if not bTm then
        begin
            SetLength(mpTypeList, Length(mpTypeList) + 1);
            SetLength(mpTypeList[Length(mpTypeList) - 1], 1);
            mpTypeList[Length(mpTypeList) - 1][0] := mUsrPorts[Length(mUsrPorts) - 1];
        end;
    end;
end;
//------------------------------------------------------------------------------

procedure TSocketMan.ClearList;
var
    i: integer;
begin
    for i := 0 to Length(mpTypeList) - 1 do
    begin
        if Length(mpTypeList[i]) > 0 then
            SetLength(mpTypeList[i], 0);
    end;
    if Length(mpTypeList) > 0 then
        SetLength(mpTypeList, 0);
    //
    for i := 0 to Length(mUsrPorts) - 1 do
    begin
        if Assigned(mUsrPorts[i]) then
        begin
            if mUsrPorts[i].IsRun then
                mUsrPorts[i].Close;
            FreeAndNil(mUsrPorts[i]);
        end;
    end;
    if Length(mUsrPorts) > 0 then
        SetLength(mUsrPorts, 0);
end;
//------------------------------------------------------------------------------

procedure TSocketMan.CheckErrorPorts;
var
    i, Cnt: integer;
begin
    if Length(mpTypeList) <= 0 then
        Exit;

    Inc(mIndex);
    mIndex := mIndex mod Length(mpTypeList);

    Cnt := 0;
    for i := 0 to Length(mpTypeList[mIndex]) - 1 do
    begin
        with TUserPort(mpTypeList[mIndex, i]) do
        begin
            //정상동작중, 연결중 --> Exit
            if IsRun then
                Exit
            else if IsStoped then
                Inc(Cnt);
        end;
    end;
    //RESET
    if Cnt = 0 then
    begin
        with TUserPort(mpTypeList[mIndex, 0]) do
            Start;
    end
    else
    //아직 정상적인 포트가 남아있다면 해당 포트 START
        if Cnt <> Length(mpTypeList[mIndex]) then
    begin
        for i := 0 to Length(mpTypeList[mIndex]) - 1 do
        begin
            with TUserPort(mpTypeList[mIndex, i]) do
            begin
                if not IsRun and not IsStoped then
                begin
                    Start;
                    Exit;
                end;
            end;
        end;
    end
    else
    //모두가 오류로 정지상태 모두 리셋처리.
    begin
        for i := 0 to Length(mpTypeList[mIndex]) - 1 do
        begin
            with TUserPort(mpTypeList[mIndex, i]) do
                Stop;
        end;
        with TUserPort(mpTypeList[mIndex, 0]) do
            Start;
    end;
end;
//------------------------------------------------------------------------------

function TSocketMan.Count: integer; // TUserPort class Count ;
begin
    Result := Length(mUsrPorts);
end;
//------------------------------------------------------------------------------

procedure TSocketMan.Reset; // 작업을 완료한 뒤에 모든 연결을 끊고 세팅을 다시함
var
    i: integer;
begin
    if Count <= 0 then
    begin
        ClearList;
        LoadPortList;
        //Start
        for i := 0 to Length(mUsrPorts) - 1 do
        begin
            mUsrPorts[i].Start;
        end;
        mReset := false;
    end;

    mReset := true;
    for i := 0 to Length(mUsrPorts) - 1 do
        mUsrPorts[i].Stop;
end;
//------------------------------------------------------------------------------

procedure TSocketMan.Start;
var
    i: integer;
begin
    if mProc = 0 then
    begin
        mProc := 1;
        {//2008.02.26
        for i := 0 to Length(mUsrPorts)-1 do
        begin
            mUsrPorts[i].Start ;
        end ;
        }
        for i := 0 to Length(mpTypeList) - 1 do
        begin
            TUserPort(mpTypeList[i][0]).Start;
        end;
        mIndex := 0;
        gLog.Panel('Start Socket Manager');
    end;
end;
//------------------------------------------------------------------------------

procedure TSocketMan.Stop;  //종료시에만 호출할것
var
    i: integer;
begin
    if mProc <> 0 then
    begin
        mProc := 0;
        for i := 0 to Length(mUsrPorts) - 1 do
        begin
            mUsrPorts[i].Close;
        end;
        gLog.Panel('Stop Socket Manager');
    end;
end;
//------------------------------------------------------------------------------

function TSocketMan.GetIdlePortCount: integer;
var
    i: integer;
begin
    Result := 0;
    for i := 0 to Length(mUsrPorts) - 1 do
    begin
        if Assigned(mUsrPorts[i]) and (mUsrPorts[i].Count = 0) then
        begin
            Inc(Result);
        end;
    end;
end;
//------------------------------------------------------------------------------

function TSocketMan.IsIdlePort(APortType: integer; var AIP: string): integer;
var
    i: integer;
begin
    Result := 0;
    for i := 0 to Length(mUsrPorts) - 1 do
    begin
        if Assigned(mUsrPorts[i]) and mUsrPorts[i].IsConnected and ((mUsrPorts[i].GetPortType = APortType) or (mUsrPorts[i].GetPortType = 0)) and (mUsrPorts[i].Count = 0) then
        begin
            AIP := mUsrPorts[i].IP;
            Result := mUsrPorts[i].Port;
            Break;
        end;
    end;
end;
//------------------------------------------------------------------------------

function TSocketMan.IsOpenPort(APortType: integer; var AIP: string): integer;
var
    i: integer;
begin
    AIP := '';
    Result := 0;
    for i := 0 to Length(mUsrPorts) - 1 do
    begin
        if Assigned(mUsrPorts[i]) and mUsrPorts[i].IsConnected and ((mUsrPorts[i].GetPortType = APortType) or (mUsrPorts[i].GetPortType = 0)) then
        begin
            Result := mUsrPorts[i].Port;
            AIP := mUsrPorts[i].IP;
            Break;
        end;
    end;
end;
//------------------------------------------------------------------------------

function TSocketMan.IsOpenPort(APortType: integer): integer;
var
    i: integer;
begin
    Result := 0;
    for i := 0 to Length(mUsrPorts) - 1 do
    begin
        if Assigned(mUsrPorts[i]) and mUsrPorts[i].IsConnected and (mUsrPorts[i].GetPortType = APortType) then
        begin
            Result := mUsrPorts[i].Port;
            Break;
        end;
    end;
end;
//------------------------------------------------------------------------------

function TSocketMan.IsExistsUserPort(APortType: integer): integer;
var
    i: integer;
begin
    Result := 0;
    for i := 0 to Length(mUsrPorts) - 1 do
    begin
        if Assigned(mUsrPorts[i]) and (mUsrPorts[i].GetPortType = APortType) then
        begin
            Result := mUsrPorts[i].Port;
            Break;
        end;
    end;
end;
//------------------------------------------------------------------------------

function TSocketMan.IsOpenedPort: integer;
var
    i: integer;
begin
    Result := 0;
    for i := 0 to Length(mUsrPorts) - 1 do
    begin
        if Assigned(mUsrPorts[i]) and mUsrPorts[i].IsConnected then
        begin
            Inc(Result);
        end;
    end;
end;
//------------------------------------------------------------------------------

function TSocketMan.GetUserPort(AIndex, APort: integer): TUserPort;
var
    i: integer;
begin
    Result := nil;
    for i := 0 to Length(mUsrPorts) - 1 do
    begin
        if Assigned(mUsrPorts[i]) and (mUsrPorts[i].mIndex = AIndex) and (mUsrPorts[i].Port = APort) then
        begin
            Result := mUsrPorts[i];
            Break;
        end;
    end;
end;
//------------------------------------------------------------------------------

function TSocketMan.GetUserPort(AIP: string; APort: integer): TUserPort;
var
    i: integer;
begin
    Result := nil;
    for i := 0 to Length(mUsrPorts) - 1 do
    begin
        if Assigned(mUsrPorts[i]) and (mUsrPorts[i].Port = APort) and (mUsrPorts[i].IP = AIP) then
        begin
            Result := mUsrPorts[i];
            Break;
        end;
    end;
end;
//------------------------------------------------------------------------------

function TSocketMan.GetUserPort(aPortType: integer): TUserPort;
var
    i: integer;
begin
    Result := nil;
    for i := 0 to Length(mUsrPorts) - 1 do
    begin
        if Assigned(mUsrPorts[i]) and (mUsrPorts[i].GetPortType = aPortType) then
        begin
            Result := mUsrPorts[i];
            Break;
        end;
    end;
end;
//------------------------------------------------------------------------------

function TSocketMan.GetPortItem(AIndex: integer): TUserPort;
begin
    Result := nil;
    if Length(mUsrPorts) > AIndex then
        Result := mUsrPorts[AIndex];
end;
//------------------------------------------------------------------------------

function TSocketMan.Add(AsndData: TSocketData; IsForce: boolean): integer; // return Port Number
var
    nP: string;
begin
    nP := '';
    Result := IsIdlePort(0, nP);
    if (Result <= 0) and not IsForce then
    begin
        Exit;
    end
    else if (Result <= 0) and IsForce then
    begin
        with GetPortItem(0) do
        begin
            Result := Port;
            nP := IP;
        end;
    end;

    if Result <= 0 then
    begin
        gLog.ToFiles('DEBUG TSocketMan ADD1 Error', []);
        Exit;
    end;
    with GetUserPort(nP, Result) do
        Result := Add(AsndData);
end;
//------------------------------------------------------------------------------

function TSocketMan.Add(AIP: string; APort: integer; AsndData: TSocketData; IsForce: boolean): integer;
var
    nUsr: TUserPort;
begin
    Result := 0;

    nUsr := GetUserPort(AIP, APort);
    if not Assigned(nUsr) or not nUsr.IsConnected or ((nUsr.Count > 0) and not IsForce) then
    begin
        gLog.ToFiles('DEBUG TSocketMan ADD2 Error', []);
        Exit;
    end;

    Result := nUsr.Add(AsndData, IsForce);
end;
//------------------------------------------------------------------------------

function TSocketMan.IsExists(AData: integer): integer;
var
    i: integer;
begin
    Result := 0;
    for i := 0 to Length(mUsrPorts) - 1 do
    begin
        if Assigned(mUsrPorts[i]) and mUsrPorts[i].IsExists(AData) then
        begin
            Result := mUsrPorts[i].Port;
            Break;
        end;
    end;
end;
//------------------------------------------------------------------------------

procedure TSocketMan.WorkProcess(Sender: TObject);
var
    i: integer;
begin
    if (mProc <= 0) or (Count <= 0) then
        Exit;

    try
        for i := 0 to Length(mUsrPorts) - 1 do
        begin
            if Assigned(mUsrPorts[i]) then
            begin
                mUsrPorts[i].WorkProcess(Sender);
            end;
        end;
    except
        on E: Exception do
        begin
            gLog.Panel('TSOCKETMAN WORKPROCESS %s', [E.Message]);
        end;
    end;
    //
    case mProc of
        0:
            ;
        1: //RESET
            begin
                if mReset and ((Length(mUsrPorts) <= 0) or (GetIdlePortCount = Length(mUsrPorts))) then
                begin
                    ClearList;
                    LoadPortList;
                    mReset := false;
                    gLog.Panel('USER PORT RESET....');
                end;
                Inc(mProc);
            end;
        2:
            begin
                Inc(mProc);
            end;
        3:
            begin
                CheckErrorPorts;
                Inc(mProc);
            end;
        4:
            begin
                Inc(mProc);
            end;
        5:
            begin
                mProc := 1;
            end;
    end;
end;

function TSocketMan.GetMessageHandle: HWND;
begin
    Result := mwnd;
end;
//------------------------------------------------------------------------------
// TUserPort
//------------------------------------------------------------------------------

constructor TUserPort.Create(AWnd: HWND; AClient: TTCPBlockSocket; AIndex: integer);
begin
    mHandle := AWnd;

    mIndex := AIndex;
    mList := TList.Create;
    mProc := 0;
    mRepeat := 0;
    mUsrRepeat := 3;
    mTime := 0;
    mStop := false;
    mLastError := '';

    mClient := AClient;
    //mClient.Socket.Handle := AWnd;

    if not Assigned(mClient) then
        Exit;

    with mClient do
    begin
        OnStatus := OnSktStatus;
        SocksTimeout := 20;
        NonblockSendTimeout := 60;
    end;
end;
//------------------------------------------------------------------------------

destructor TUserPort.Destroy;
begin
    ClearList;

    if Assigned(mClient) then
    begin
        with mClient do
        begin
        end;
        FreeAndNil(mList);

        mClient.Close;

        FreeAndNil(mClient);
    end;
end;
//------------------------------------------------------------------------------

procedure TUserPort.ClearList;
var
    i: integer;
begin
    for i := Count - 1 downto 0 do
        ReadedFirstData(false, true);
end;

procedure TUserPort.ClearReceiveBuffer;
begin
    try
        if mClient.WaitingData > 0 then
        begin
            mClient.Purge;
            gLog.ToFiles('포트 %x: 수신 버퍼 비움, 대기 데이터: %d 바이트', [Port, mClient.WaitingData]);
        end;
    except
        on E: Exception do
        begin
            gLog.ToFiles('수신 버퍼 비우기 오류: %s', [E.Message]);
        end;
    end;
end;

//------------------------------------------------------------------------------

procedure TUserPort.OnSktStatus(Sender: TObject; Reason: THookSocketReason; const Value: string);
begin
    case Reason of
        HR_ResolvingBegin:
            ;
        HR_ResolvingEnd:
            ;
        HR_SocketCreate:
            ;
        HR_SocketClose:
            begin

            end;
        HR_Bind:
            ;
        HR_Connect:
            begin
            end;
        HR_CanRead:
            ;
        HR_CanWrite:
            ;
        HR_Listen:
            ;
        HR_Accept:
            ;
        HR_ReadCount:
            begin

            end;

        HR_WriteCount:
            begin

            end;
        HR_Wait:
            ;
        HR_Error:
            begin

                case mClient.LastError of
                    10060:
                        ; // timeout
                    10101,  // 정상 종료
                    10050..10054: // Network down
                        begin
                            mClient.Close;
                            OnUsrSocketDisconnect;
                        end;

                end;

            end;

    end;
end;

procedure TUserPort.OnUsrSocketConnect();
var
    i: integer;
    sTm: string;
begin
    mProc := _CHECK_DATA;

    sTm := Format('IP:%s, PORT:%x', [IP, mClient.Port]);
    for i := lpList.Count - 1 downto 0 do
    begin
        if Pos(sTm, lpList.Strings[i]) > 0 then
        begin
            lpList.Delete(i);
        end;
    end;

    SetMessage(SYS_CONNECTED);
    //2009.02.20 접속이 성공하더라도 바로 끊어질 수 있다, 서버에서 강제로 끊음.
    //이럴때 다음 포트로 작업을 해야하는데, 그 작업을 할 수 없다.
    //mConnectCount := 0 ;
    gLog.Panel('CONNECTED : %x', [Port]);
end;
//------------------------------------------------------------------------------

procedure TUserPort.OnUsrSocketConnecting();
begin
    SetMessage(SYS_CONNECTING);
    gLog.ToFiles('CONNECTING....... %x', [Port]);
end;
//------------------------------------------------------------------------------

procedure TUserPort.OnUsrSocketDisconnect();
begin
    SetMessage(SYS_DISCONNECTED);
    gLog.Panel('DISCONNECTED %x', [Port]);

    ClearList;

    mClient.Close;
    mProc := _WAIT_DISCONNECTED;//_FAULT_PROC ;//_DELAY_TIME ;
    mTime := GetAccurateTime;
end;
//------------------------------------------------------------------------------

procedure TUserPort.OnUsrSocketError(ErrorEvent: TErrorEvent);
var
    sTm: string;
begin
    sTm := '';
    case ErrorEvent of
        eeGeneral:
            begin
                sTm := 'The socket received an error message that does not fit into any of the following categories.';
            end;
        eeSend:
            begin
                sTm := 'An error occurred when trying to write to the socket connection.';
            end;
        eeReceive:
            begin
                sTm := 'An error occurred when trying to read from the socket connection.';
            end;
        eeConnect:
            begin
                sTm := 'A connection request that was already accepted could not be completed.';
            end;
        eeDisconnect:
            begin
                sTm := 'An error occurred when trying to close a connection.';
            end;
        eeAccept:
            begin
                sTm := 'A problem occurred when trying to accept a client connection request.';
            end;
    else
        sTm := 'Unknown Code';
    end;
    sTm := Format('IP:%s, 포트:%x %s (ErrorCode: %d)', [IP, mClient.Port, sTm, mClient.LastError]);

    if mLastError <> sTm then
    begin
        mLastError := sTm;
        gLog.ToFiles('%s', [mLastError]);
        SetMessage(SYS_TCP_ERROR);
        if lpList.IndexOf(sTm) < 0 then
        begin
            lpList.Add(sTm);
            SetMessage(SYS_TCP_ERROR);
        end;
    end;

    ClearReceiveBuffer;
    //에러를 죽이고 반드시 끊어야 한다네.
    mProc := _WAIT_DISCONNECTED;
    mClient.Close;
    mTime := GetAccurateTime;
end;
//------------------------------------------------------------------------------

procedure TUserPort.OnUsrSocketLookup();
begin
end;
//------------------------------------------------------------------------------

procedure TUserPort.OnUsrSocketRead();
var
    Buf: ShortString;
begin
    mTermTime := GetAccurateTime - mTmpTime;

    try
        mLastDatas := mClient.RecvBufferStr(mClient.WaitingData, 100);
    except
        OnUsrSocketError(eeReceive);
        Exit;
    end;


    {$IFDEF DEBUG_LEVEL2}
    Buf := ShortString(mLastDatas);
    gLog.Panel('수신데이터(%x) : %s', [Port, mLastDatas]);
    gLog.PanelHex(Buf[1], Length(Buf));
    {$ENDIF}

    if mProc = _RESPONSE_WAIT then
    begin
        ReadedFirstData(true);
        mTime := GetAccurateTime;
        mProc := _DELAY_TIME;
    end
    else if Count > 0 then
    begin
        with pSocketData(mList.Items[0])^ do
        begin
            if rReadOnly then
            begin
                ReadedFirstData(true);
                mTime := GetAccurateTime;
            end;
        end;
    end;

    mLastError := '';
    SetMessage(SYS_TCP_READ);

    if Assigned(mStatusEvent) then
        OnStatus(Self, SYS_TCP_READ);
end;
//------------------------------------------------------------------------------

procedure TUserPort.OnUsrSocketWrite();
begin
    mTmpTime := GetAccurateTime;

    SetMessage(SYS_TCP_WRITE);
    {$IFDEF DEBUG_LEVEL2}
    gLog.ToFiles('WRITE %x', [Port]);
    {$ENDIF}
    if Assigned(mStatusEvent) then
        OnStatus(Self, SYS_TCP_WRITE);
end;
//------------------------------------------------------------------------------

function TUserPort.SendData(AData: Ansistring): boolean;
begin
    mTmpTime := GetAccurateTime;

    Result := true;
    mLastDatas := AData;

    if not mClient.IsConnected then
        Exit;

    try
        mClient.SendString(mLastDatas);
        OnUsrSocketWrite();
    except
        on E: Exception do
        begin
            OnUsrSocketError(eeSend);
            gLog.ToFiles('SENDDATA %s', [E.Message]);
            Result := false;
        end;
    end;

    Inc(mRepeat);

    if Result then
    begin
        SetMessage(SYS_TCP_WRITE);
        if Assigned(mStatusEvent) then
            OnStatus(Self, SYS_TCP_WRITE);
    end;

    {$IFDEF DEBUG_LEVEL2}
    gLog.Panel('SEND: %s', [mLastDatas]);
    {$ENDIF}
end;
//------------------------------------------------------------------------------

procedure TUserPort.SetMessage(ACode: integer);
begin
    //EDIT if mLastMessage = ACode then Exit ;

    SendToForm(mHandle, ACode, (mIndex shl 16) or WORD(Port));

    mLastMessage := ACode;
end;
//------------------------------------------------------------------------------

function TUserPort.LoadData(var Value: Ansistring): integer;
var
    i: integer;
begin
    mWaitTime := gLanEnv.rWaitTime;
    mUsrRepeat := 3;

    Result := -1;
    if (Count <= 0) then
        Exit;

    with pSocketData(mList.Items[0])^ do
    begin
        if rWaitTime > 0 then
            mWaitTime := rWaitTime;
        if rUsrRepeat > 0 then
            mUsrRepeat := rUsrRepeat;

        if rReadOnly then
        begin
            Result := 0;
            Exit;
        end;
        Value := '';
        if rLength > 0 then
        begin
            for i := 0 to rLength - 1 do
            begin
                Value := Value + rDatas[i];
            end;
        end
        else
            Value := rDatas;
        if Value = '' then
            Exit;
        Result := 1;
        {$IFDEF DEBUG_LEVEL3}
        gLog.ToFiles('LOAD DATA: %d', [rCode]);
        {$ENDIF}
        if rNotReturn then
        begin
            Result := 2;
            try
                Dispose(mList.Items[0]);
                mList.Delete(0);
            finally
            end;
        end;
    end;
end;
//------------------------------------------------------------------------------

procedure TUserPort.WorkProcess(Sender: TObject);
var
    sTm: Ansistring;
begin

    case mProc of
        _NONE_PROC:
            ;
        _CONNECTING:
            begin
                Inc(mProc);
                Inc(mConnectCount);
                mTime := GetAccurateTime;

                ClearReceiveBuffer;

                if mClient.IP = '' then
                begin
                    gLog.Panel('PLC 연결 IP 입력 오류!!!'); //'PLC IP Input Error'
                    mProc := _WAIT_DISCONNECTED;// _FAULT_PROC ;
                    mClient.Close;
                    Exit;
                end;
            //
                try
                    gLog.Panel('%s 접속시도(0x%x)...', [mClient.IP, mClient.Port]);//'%s try connect(%x)'
                    if not mClient.IsConnected then
                        mClient.ConnectNB;
                    OnUsrSocketConnecting();
                    mProc := _CONNECT_WAIT;
                    mTC.Start(_DELAY_TIME * 1000);
                finally

                end;

            end;
        _CONNECT_WAIT:
            begin
                if mTC.IsTimeOut then
                begin
                    mProc := _CONNECTING;
                end;

                if mClient.IsConnected then
                begin
                    OnUsrSocketConnect;
                end;

            end;
        _CHECK_DATA:
            begin
                SetMessage(SYS_POP_READY);

                if (mList.Count > 0) then
                begin
                    mRepeat := 0;
                    Inc(mProc);
                end
                else if mStop then
                    mProc := _STOP_PROC
                else
                    mProc := _DELAY_TIME;

                mTime := GetAccurateTime;
            end;
        _WRITE_DATA:
            begin

                case LoadData(sTm) of
                    0:
                        begin
                            mProc := _DELAY_TIME;
                            mWriteTime := GetAccurateTime;
                            Exit;
                        end;
                    1:
                        begin
                            ClearReceiveBuffer;//   전송 전에 버퍼 삭제
                            if SendData(sTm) then
                            begin
                                mWriteTime := GetAccurateTime;
                                Inc(mProc);
                                Exit;
                            end;
                        end;
                    2:
                        begin
                            SendData(sTm);
                            mProc := _DELAY_TIME;
                            mWriteTime := GetAccurateTime;
                            Exit;
                        end;
                end;

                mProc := _WAIT_DISCONNECTED;
                mClient.Close;
                gLog.Panel('전송 실패 혹은 데이터 오류...');
            end;
        _RESPONSE_WAIT:
            begin
                // 대기 데이터가 있으면 읽기 처리
                if mClient.WaitingData > 0 then
                begin
                    OnUsrSocketRead();
                    Exit;
                end;
                // 타임아웃 처리
                if (GetAccurateTime - mWriteTime) > mWaitTime then
                begin
                    if mRepeat >= mUsrRepeat then
                    begin
                        //무응답처리  - 현재 요청 폐기
                        ReadedFirstData(false);
                        ClearReceiveBuffer;

                        //
                        if gLanEnv.rReConOfSndFault then
                        begin
                            mProc := _WAIT_DISCONNECTED;
                            mClient.Close;
                            gLog.Panel('응답 회수 %d회 재 연결...', [mUsrRepeat]);
                        end
                        else
                        begin
                            mProc := _DELAY_TIME;
                            gLog.Panel('응답 회수 %d회 -> 전송 오류 처리...', [mUsrRepeat]);
                        end;

                        SetMessage(SYS_RCV_ERROR);
                        mTime := GetAccurateTime;
                    end
                    else
                    begin
                        ClearReceiveBuffer;
                        mProc := _WRITE_DATA;
                        gLog.Panel('무응답(%x), %d회 재 전송...', [Port, mRepeat]);
                    end;
                end;
            end;
        _DELAY_TIME:
            begin
                if mClient.IsConnected and ((GetAccurateTime - mTime) > gLanEnv.rSendTerm) then
                begin
                    mProc := _CHECK_DATA;
                end
                else if not mClient.IsConnected and ((GetAccurateTime - mTime) > gLanEnv.rConnectTime) then
                begin
                    mProc := _CONNECTING;
                end;
            end;
        _WAIT_DISCONNECTED:
            begin
                if mConnectCount >= 3 then
                begin
                    mProc := _STOP_PROC;
                    gLog.Panel('연속 3회 이상 연결실패로 동작정지(%x).', [Port]);
                    Exit;
                end;

                if (GetAccurateTime - mTime) > gLanEnv.rErWaitTime then
                begin
                    mProc := _CONNECTING;
                end;
            end;
        _STOP_PROC:
            ;
    else
        gLog.Panel('TUserPort PROCESS FAULT : %d', [mProc]);
        //if mClient.Active then mClient.Socket.Close ;
        mProc := _WAIT_DISCONNECTED;// _FAULT_PROC ;
        mClient.Close;
        mTime := GetAccurateTime;
    end;
end;
//------------------------------------------------------------------------------

procedure TUserPort.Start;
begin
    if mProc in [_NONE_PROC, _STOP_PROC] then
    begin
        mRepeat := 0;
        mLastError := '';
        mLastMessage := 0;
        mProc := _CONNECTING;
        mConnectCount := 0;
        gLog.Panel('start port processor(%s:%x)', [IP, Port]);
    end;
end;
//------------------------------------------------------------------------------

procedure TUserPort.Stop; //작업을 완료하고 접속을 끊음.
begin
    if IsConnected then
        mStop := true
    else
        mProc := _STOP_PROC;
end;
//------------------------------------------------------------------------------

procedure TUserPort.Close; //작업을 완료하지 않고 접속을 끊음
begin
    if mProc <> _NONE_PROC then
    begin
        mClient.Close;

        mProc := _NONE_PROC;
        gLog.Panel('stop port processor(%s:%x)', [IP, Port]);
    end;
end;
//------------------------------------------------------------------------------

function TUserPort.IP: string;
begin
    Result := mClient.IP
end;
//------------------------------------------------------------------------------

function TUserPort.Port: integer;
begin
    Result := mClient.Port;
end;
//------------------------------------------------------------------------------

function TUserPort.Count: integer;
begin
    Result := mList.Count;
end;
//------------------------------------------------------------------------------

function TUserPort.IsRun: boolean;
begin
    //Result := mProc In[_CHECK_DATA.._RESPONSE_WAIT] ;
    Result := mProc in [_NONE_PROC + 1.._STOP_PROC - 1];
end;
//------------------------------------------------------------------------------

function TUserPort.IsConnected: boolean;
begin
    Result := mClient.IsConnected;
end;
//------------------------------------------------------------------------------

function TUserPort.Add(AsndData: TSocketData; IsForce: boolean): integer; // return Port Number
var
    {$IFDEF DEBUG_LEVEL3}
    i: integer;
    {$ENDIF}
    pBuf: pSocketData;
begin
    Result := 0;
    if not IsConnected or mStop or (mProc in [_NONE_PROC, _STOP_PROC]) then
        Exit;

    New(pBuf);
    Move(AsndData, pBuf^, sizeof(TSocketData));
    //CopyMemory(pBuf, @AsndData, sizeof(TSocketData)) ;
    if IsForce then
        mList.Insert(0, pBuf)
    else
        mList.Add(pBuf);
    Result := mClient.Port;

    //SetMessage(SYS_LIST_UPDATE) ;
    {$IFDEF DEBUG_LEVEL3}
    for i := 0 to Count - 1 do
    begin
        pBuf := mList.Items[i];
        with pBuf^ do
        begin
            gLog.ToFiles('ADD SOCKE BUFFER %d(%d)', [mList.Count, i]);
            gLog.ToFiles(' HANDLE %d', [rCode]);
            gLog.ToFiles(' DATAS %s', [rDatas]);
            gLog.ToFiles(' REPEAT %d', [integer(rRepeat)]);
        end;
    end;
    {$ENDIF}
end;
//------------------------------------------------------------------------------

function TUserPort.GetLastData: pSocketData;
begin
    if Count > 0 then
        Result := mList.Items[0]
    else
        Result := nil;
end;
//------------------------------------------------------------------------------

function TUserPort.GetLastTxt: string;
begin
    Result := mLastDatas;
end;
//------------------------------------------------------------------------------

function TUserPort.GetPortType: integer;
begin
    Result := mClient.Tag;
end;
//------------------------------------------------------------------------------

function TUserPort.IsExists(AData: integer): boolean;
var
    i: integer;
begin
    Result := false;
    for i := 0 to Count - 1 do
    begin
        with pSocketData(mList.Items[i])^ do
        begin
            if rCode = AData then
            begin
                Result := true;
                Break;
            end;
        end;
    end;
end;
//------------------------------------------------------------------------------

procedure TUserPort.ReadedFirstData(ARecieved: boolean; IsForce: boolean);
var
    {$IFDEF DEBUG_LEVEL3}        i: integer; {$ENDIF}
    sTm: Ansistring;
    pBuf: pSocketData;
begin
    if Count > 0 then
    begin
        pBuf := mList.Items[0];
        with pBuf^ do
        begin
            if ARecieved then
                sTm := mLastDatas
            else if IsForce then
                sTm := _NOTIFY_CLOSE
            else
                sTm := '';
            try
                try
                    if Assigned(rNotify) and (not rNotReturn or IsForce) then
                        rNotify(Self, sTm);
                except
                    on E: Exception do
                        gLog.ToFiles('ReadedFirstData %s', [E.Message]);
                end;
            finally
            end;
        end;
        //
        if Assigned(mStatusEvent) then
            OnStatus(Self, SYS_TCP_READ);
        //
        if pBuf^.rRepeat and not IsForce then
        begin
            if mList.Count > 1 then
                mList.Move(0, mList.Count - 1);
            Exit;
        end;
        //DEBUG
        {$IFDEF DEBUG_LEVEL3}
        with pBuf^ do
        begin
            gLog.ToFiles('DELETE SOCKE BUFFER %d', [mList.Count]);
            gLog.ToFiles(' HANDLE %d', [rCode]);
            gLog.ToFiles(' DATAS %s', [rDatas]);
            gLog.ToFiles(' REPEAT %d', [integer(rRepeat)]);
        end;
        {$ENDIF}
        //-------------------------
        try
            Dispose(pBuf);
        except
            on E: Exception do
                gLog.Panel('TUserPort ReadedFirstData %s', [E.Message]);
        end;
        mList.Delete(0);
    end;
    {$IFDEF DEBUG_LEVEL3}
    for i := 0 to Count - 1 do
    begin
        pBuf := mList.Items[i];
        with pBuf^ do
        begin
            gLog.ToFiles('SOCKE BUFFER %d(%d)', [mList.Count, i]);
            gLog.ToFiles(' HANDLE %d', [rCode]);
            gLog.ToFiles(' DATAS %s', [rDatas]);
            gLog.ToFiles(' REPEAT %d', [integer(rRepeat)]);
        end;
    end;
    {$ENDIF}
end;

function TUserPort.IsStoped: boolean;
begin
    Result := mProc = _STOP_PROC;
end;

procedure TUserPort.ClearUsrDatas(IsAll: boolean);
var
    i: integer;
    pBuf: pSocketData;
begin
    for i := Count - 1 downto 0 do
    begin
        pBuf := mList.Items[i];
        if pBuf^.rReadOnly or IsAll then
        begin
            try
                Dispose(pBuf);
            except
                on E: Exception do
                    gLog.Panel('TUserPort ReadedFirstData %s', [E.Message]);
            end;
            mList.Delete(i);
        end;
    end;
end;


{ TSocketData }

procedure TSocketData.Init(Code: integer; Notify: TNotifyRcvDatas; Datas: AnsiString);
begin
    FillChar(self, sizeof(TSocketData), 0);

    if Code <> 0 then
        rCode := Code;

    rNotify := Notify;
    rDatas := Datas;

    rRepeat := false;
    rNotReturn := false;
end;

initialization
    LoadLanEnv;
    lpList := TStringList.Create;


finalization
    SaveLanEnv;
    if Assigned(lpList) then
        FreeAndNil(lpList);

end.

