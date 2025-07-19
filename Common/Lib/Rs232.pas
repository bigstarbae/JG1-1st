unit Rs232;

interface
uses
  Windows, SysUtils ;

const
    NULL    = #00 ;
    SOH     = #01 ;
	STX		= #02 ;
	ETX		= #03 ;
	EOT		= #04 ;
	ENQ		= #05 ;
	ACK		= #06 ;
    BEL     = #07 ;
    BS      = #08 ;
	HT      = #09 ;
    TAB     = #09 ;
    LF      = #10 ;
    VT      = #11 ;
    FF      = #12 ;
    CR      = #13 ;
    SO      = #14 ;
    SI      = #15 ;
    DLE     = #16 ;
    DC1     = #17 ;
    DC2     = #18 ;
    DC3     = #19 ;
	DC4     = #20 ;
    NAK     = #21 ;
    SYN     = #22 ;
    ETB     = #23 ;
    CAN     = #24 ;
    EM      = #25 ;
    SUB     = #26 ;
	ESC     = #27 ;
	FS      = #28 ;
	GS      = #29 ;
	RS      = #30 ;
	US      = #31 ;

//    CR  = Char($0D);
//    LF  = Char($0A);
    //ACK = Char($06);
    //NAK = Char($15);
//    STX = Char($02);
//    ETX = Char($03);

    ERROR_PORT_OPEN  = -100;
    ERROR_FRAME_READ = -101;
    ERROR_LENGTH     = -102;
    ERROR_PORT_WRITE = -103;

    dcb_Binary              = $00000001;
    dcb_ParityCheck         = $00000002;
    dcb_OutxCtsFlow         = $00000004;
    dcb_OutxDsrFlow         = $00000008;
    dcb_DtrControlMask      = $00000030;
    dcb_DtrControlDisable   = $00000000;
    dcb_DtrControlEnable    = $00000010;
    dcb_DtrControlHandshake = $00000020;
    dcb_DsrSensivity        = $00000040;
    dcb_TXContinueOnXoff    = $00000080;
    dcb_OutX                = $00000100;
    dcb_InX                 = $00000200;
    dcb_ErrorChar           = $00000400;
    dcb_NullStrip           = $00000800;
    dcb_RtsControlMask      = $00003000;
    dcb_RtsControlDisable   = $00000000;
    dcb_RtsControlEnable    = $00001000;
    dcb_RtsControlHandshake = $00002000;
    dcb_RtsControlToggle    = $00003000;
    dcb_AbortOnError        = $00004000;
    dcb_Reserveds           = $FFFF8000;

    _ASCII_TXT : array[0..31]of string
        = (
            'NULL',
            'SOH',
            'STX',
            'ETX',
            'EOT',
            'ENQ',
            'ACK',
            'BEL',
            'BS',
            'TAB',
            'LF',
            'VT',
            'FF',
            'CR',
            'SO',
            'SI',
            'DLE',
            'DC1',
            'DC2',
            'DC3',
            'DC4',
            'NAK',
            'SYN',
            'ETB',
            'CAN',
            'EM',
            'SUB',
            'ESC',
            'FS',
            'GS',
            'RS',
            'US'
           ) ;
type
  TCommPorts = ( COM__1, COM__2, COM__3, COM__4, COM__5, COM__6, COM__7, COM__8, COM__9, COM__10,
                 COM__11, COM__12, COM__13, COM__14);

    {BurdRate
        CBR_110 	CBR_19200
        CBR_300 	CBR_38400
        CBR_600 	CBR_56000
        CBR_1200	CBR_57600
        CBR_2400	CBR_115200
        CBR_4800	CBR_128000
        CBR_9600	CBR_256000
        CBR_14400

    Parity
        NOPARITY = 0;
        ODDPARITY = 1;
        EVENPARITY = 2;
        MARKPARITY = 3;
        SPACEPARITY = 4;

    StopBits
        ONESTOPBIT = 0;
        ONE5STOPBITS = 1;
        TWOSTOPBITS = 2;

    DataBit
         5,6,7,8}
    TFrame = record
        Frame : array[0..11] of Char;
        Idx   : integer;
        Len   : integer;
    end;


    TRS232 = Class
	private
		hCom         : THandle ;
        mManualFlow  : Boolean;

        mSTX         : TFrame;
        mETX         : TFrame;
        mStartTime   : integer;

        function IsFrame(var f : TFrame; cRead : Char) : Boolean;
	public
		constructor Create();//dwPort     : TCommPorts;
                           //dwBaudRate : WORD;
                           //dwDataBit  : WORD;
                           //dwParity   : WORD;
                           //dwStopBIt  : WORD;
                           //dHwHand    : Boolean;
                           //dwManual   : Boolean;
                           //dwbuffsize : WORD);
        destructor Destroy; override;

		function Open(dwPort     : TCommPorts;
                      dwBaudRate : DWORD;
                      dwDataBit  : WORD;
                      dwParity   : WORD;
                      dwStopBIt  : WORD;
                      dwbuffsize : WORD;
                      dHwHand    : Boolean) : boolean;
        procedure Close();
        function  ComRead(var ReadChar: Char):integer;
        function  ComTRead(var Buff; nRead, Time:DWORD): integer;
        function  ComNRead(var Buff; nNum : integer; var nInQueu : integer):integer;
        function  ComReadFrame(var Buff ; pSTX, pETX : PChar; Time : DWORD; Mode : Boolean):integer; overload;
        function  ComReadFrame(var Buff; Time : DWORD; MaxLen : integer) : boolean; overload;
        function  ComWrite(const pBuff; nToWrite : DWORD):integer;
        function  ComWrites(const pBuff; nWrite : DWORD):integer;

        procedure SetReadTimeOut(dwTimeout,dwInterval:DWORD);
        function  GetInQue(): integer;
        function  GetOutQue(): integer ;
        procedure ClearBuff(bin, bOut : Boolean);
        function  ReadyReceveDate() : Boolean;
        function  IsOpen() : Boolean;

        procedure SetStxEtx(stx, etx : string);
        procedure ClearFrame();

        procedure SetDTREx(State : boolean);
        procedure ClearToSend(bFlag : Boolean);
    end;

implementation
uses
    Log ;

//---------------------------------------------------------------------------
constructor TRS232.Create();//dwPort     : TCommPorts;
                          //dwBaudRate : WORD;
                          //dwDataBit  : WORD;
                          //dwParity   : WORD;
                          //dwStopBIt  : WORD;
                          //dHwHand    : Boolean;
                          //dwManual   : Boolean;
                          //dwbuffsize : WORD);
begin
	hCom        := INVALID_HANDLE_VALUE ;
    mManualFlow := false;
    {
    if (not dHwHand) and dwManual then mManualFlow := true;

    Open(dwPort, dwBaudRate, dwDataBit, dwParity, dwStopBIt, dwbuffsize, dHwHand);
    }
    FillChar(mSTX, sizeof(mSTX), #0);
    FillChar(mETX, sizeof(mETX), #0);
end;
//---------------------------------------------------------------------------
destructor TRS232.Destroy;
begin
    Close();
end;
//---------------------------------------------------------------------------
procedure TRS232.Close();
begin
    if hCom <> INVALID_HANDLE_VALUE then
    begin
        CloseHandle(hCom);
        hCom := INVALID_HANDLE_VALUE;
        //hCom := THandle(FILE_OPEN_ERROR);
    end;
end;
//---------------------------------------------------------------------------
procedure TRS232.SetDTREx(State : boolean);
begin
    if not State then EscapeCommFunction(hCom, SETDTR)
    else              EscapeCommFunction(hCom, CLRDTR);
end;
//---------------------------------------------------------------------------
procedure TRS232.ClearToSend(bFlag : Boolean);
begin
    if bFlag then EscapeCommFunction(hCom, SETRTS)
    else          EscapeCommFunction(hCom, CLRRTS);
end;
//---------------------------------------------------------------------------
function TRS232.Open(dwPort : TCommPorts;
		              dwBaudRate : DWORD;
		              dwDataBit  : WORD;
		              dwParity   : WORD;
		              dwStopBIt  : WORD;
	    	          dwbuffsize : WORD;
		              dHwHand    : Boolean) : boolean;
var
    ComName    : array[0..15]of CHAR;
    lpCommProp : PCOMMPROP ;
    dcb        : TDCB;
begin
    result := false;

    if IsOpen() then Close();

    StrCopy(@ComName, PChar(Format('\\.\COM%d', [Ord(dwPort) + 1])));
    try
        hCom := CreateFile(ComName,
                           GENERIC_READ or GENERIC_WRITE,
                           0,
                           Nil,
                           OPEN_EXISTING,
                           0,
                           0);
    except
        hCom := INVALID_HANDLE_VALUE ;
    end ;
    if not IsOpen() then Exit;
    //if (hCom = THandle(FILE_OPEN_ERROR)) then Exit;

    if not SetupComm(hCom, dwbuffsize, dwbuffsize) then
    begin
        CloseHandle(hCom);
        hCom := INVALID_HANDLE_VALUE;
        //hCom := THandle(FILE_OPEN_ERROR);
        exit;
    end;

    Getmem(lpCommProp,1000);
    GetCommProperties(hCom, lpCommProp^);
    GetCommState(hCom, dcb);


    dcb.BaudRate := dwBaudRate ;
    dcb.ByteSize := BYTE(dwDataBit) ;
    {
    if ((lpCommProp^.dwSettableBaud and dwBaudRate)=dwBaudRate) then
       dcb.BaudRate := dwBaudRate
    else CloseHandle(hCom);
    if ((lpCommProp^.wSettableData and dwDataBit)=dwDataBit) then
        dcb.ByteSize := BYTE(dwDataBit)
    else CloseHandle(hCom);
    }
    dcb.StopBits := BYTE(dwStopBIt);
    dcb.Parity   := BYTE(dwParity);


    dcb.Flags := dcb_Binary;
    dcb.Flags := dcb.Flags or dcb_DtrControlEnable;

    if dHwHand then
    begin
      dcb.Flags := dcb.Flags or dcb_OutxCtsFlow or dcb_RtsControlHandshake;
      dcb.Flags := dcb.Flags or dcb_OutX or dcb_InX;
    end;

    dcb.XONLim := 100;
    dcb.XOFFLim := 1;

    if (not SetCommState(hCom, dcb)) then
    begin
        CloseHandle(hCom);
        hCom := INVALID_HANDLE_VALUE;
        //hCom := THandle(FILE_OPEN_ERROR);
        exit;
    end;

    FreeMem(lpCommProp);

    ClearBuff(true, true);
    SetReadTimeOut(0, MAXDWORD);

    result := IsOpen();
    //result := hCom <> THandle(FILE_OPEN_ERROR);
end;
//---------------------------------------------------------------------------
function  TRS232.GetInQue(): integer;
var
    dwError   : DWORD;
    ComStatus : TCOMSTAT;
begin
    ClearCommError(hCom, dwError, @ComStatus);
    try
        result := ComStatus.cbInQue;
    except
        Result := 0 ;
    end;
end;

function  TRS232.GetOutQue(): integer ;
var
    dwError   : DWORD;
    ComStatus : TCOMSTAT;
begin
    ClearCommError(hCom, dwError, @ComStatus);
    try
        result := ComStatus.cbOutQue
    except
        Result := 0 ;
    end;
end;
//---------------------------------------------------------------------------
function  TRS232.ReadyReceveDate() : Boolean;
var
    dwStatus : DWORD;
begin
    result := false;
    dwStatus := MS_CTS_ON;
    mStartTime  := GetTickCount();
    EscapeCommFunction(hCom, CLRRTS);

    while (dwStatus <> MS_CTS_ON) do
	begin
		GetCommModemStatus(hCom, dwStatus);
		dwStatus := dwStatus and MS_CTS_ON;
		if ((integer(GetTickCount()) - mStartTime) > 100) then exit;
	end;
    result := true;
end;
//---------------------------------------------------------------------------
procedure TRS232.ClearBuff(bIn, bOut : Boolean);
var
    dwFlag : DWord;
begin
    dwFlag := 0;
    if bin  then dwFlag := PURGE_RXABORT or PURGE_RXCLEAR;
    if bOut then dwFlag := dwFlag or PURGE_TXABORT or PURGE_TXCLEAR;

    PurgeComm(hCom, dwFlag);
end;
//---------------------------------------------------------------------------
procedure TRS232.SetReadTimeOut(dwTimeout,dwInterval:DWORD);
var
    timeout : TCOMMTIMEOUTS ;
begin
    GetCommTimeouts(hCom, timeout);
    if (timeout.ReadIntervalTimeout <> dwInterval) or
       (timeout.ReadTotalTimeoutConstant <> dwTimeout) then
    begin
        timeout.ReadIntervalTimeout      := dwInterval;
        timeout.ReadTotalTimeoutConstant := dwTimeout;
        timeout.WriteTotalTimeoutConstant:= 50;
        timeout.WriteTotalTimeoutMultiplier:= 5;
        SetCommTimeouts(hCom, timeout);
    end;
    GetCommTimeouts(hCom, timeout);
end;
//---------------------------------------------------------------------------
function  TRS232.ComRead(var ReadChar: Char):integer;
var
    nByteRead : DWORD;
begin
    result := -1;
    if mManualFlow then ClearToSend(true);
    if not IsOpen() then exit;
    //if (hCom = THandle(FILE_OPEN_ERROR)) then exit;
    if GetInQue() = 0 then Exit;

    if ReadFile(hCom, ReadChar, 1, nByteRead, nil) then result := nByteRead;
    if mManualFlow then ClearToSend(false);
end;
//---------------------------------------------------------------------------
function  TRS232.ComTRead(var Buff ; nRead, Time:DWORD): integer;
var
    nByteRead, nToRead : DWORD;
begin
    result := -1;

    if mManualFlow then ClearToSend(true);
    //if High(TByteArray(Buff)) < nRead then exit;

    nToRead    := 0;
    mStartTime := integer(GetTickCount);
    while ((integer(GetTickCount) - mStartTime) <= integer(Time)) do
    begin
        nToRead := GetInQue();
        if (nToRead >= nRead) then break;
    end;
    if nToRead > 0 then
    	if (ReadFile(hCom, Buff,nRead,nByteRead,nil)) then result := nByteRead;

    if mManualFlow then ClearToSend(false);
end;
//---------------------------------------------------------------------------
function  TRS232.ComNRead(var Buff; nNum : integer; var nInQueu : integer):integer;
var
    wTm, nByteRead : DWORD;
begin
    result := 0;

    if mManualFlow then ClearToSend(true);
    //if High(TByteArray(Buff)) < nNum then exit;

    nInQueu := GetInQue() ;
    //if (nInQueu < nNum) or (nNum < 1) then exit;
    if (nInQueu <= 0) or (nNum < 1) then Exit ;

    if nInQueu > nNum then wTm := nNum
    else                   wTm := nInQueu ;
    if ReadFile(hCom, Buff, wTm{nInQueu}, nByteRead, nil) then result := nByteRead;

    if mManualFlow then ClearToSend(false);
end;
//---------------------------------------------------------------------------
function  TRS232.ComReadFrame(var Buff; pSTX, pETX:PChar; Time:DWORD; Mode : Boolean):integer;
var
    ReadChar : char;
    nByteRead, nTotalRead : DWORD;
    IsFindSTX, IsFirst : Boolean;
begin
    result := -1;

    if (GetInQue() = 0) then exit;

    nTotalRead := 0 ;
    nByteRead  := 0 ;
    IsFindSTX  := False;
    IsFirst    := True;
    mStartTime := integer(GetCurrentTime);

    while ((integer(GetCurrentTime) - mStartTime) < integer(Time)) do
    begin
        ReadChar := #0;
        try
        nByteRead := ComRead(ReadChar);
        except
            On E: Exception do gLog.Panel('%s->%s', [E.Message, ReadChar]) ;
        end ;
        if (nByteRead < 1) then
        begin
            if (nTotalRead < 1) or IsFirst then exit;
        end
        else
        begin
            IsFirst := False;
            if not IsFindSTX then
            begin
                if (pSTX <> nil) then
                begin
                    if (pSTX^ = ReadChar)        then IsFindSTX := True;
                    if not IsFindSTX or (not Mode) then continue;
                end
                else
                    IsFindSTX := True;
            end;
            if (pETX <> nil) and (pETX^ = ReadChar) then
            begin
                if Mode then
                begin
                    TByteArray(Buff)[nTotalRead] := BYTE(ReadChar);
                    Inc(nTotalRead);
                end;
                break;
            end;
            TByteArray(Buff)[nTotalRead] := BYTE(ReadChar);
            Inc(nTotalRead);
        end;
    end;

    TByteArray(Buff)[nTotalRead] := 0;
    result := nTotalRead;
end;
//---------------------------------------------------------------------------
function  TRS232.ComReadFrame(var Buff; Time : DWORD; MaxLen : integer) : boolean;
var
    nIdx, nRead : integer;
    rdChar : char;
    IsSTX  : Boolean;
begin
    result := false;
    if (GetInQue() = 0) then exit;

    nIdx       := 0;
    IsSTX      := False;
    mStartTime := integer(GetCurrentTime);
    TByteArray(Buff)[nIdx] := 0;

    while ((integer(GetCurrentTime) - mStartTime) < integer(Time)) do
    begin
        nRead := ComRead(rdChar);

        if (nRead > 0) then
        begin
            if MaxLen <= nIdx then break;

            if not IsSTX then
            begin
                IsSTX := IsFrame(mSTX, rdChar);
            end
            else
            begin
                if IsFrame(mETX, rdChar) then
                begin
                    break;
                end;
                TByteArray(Buff)[nIdx] := BYTE(rdChar);
                Inc(nIdx);
            end;
        end;
    end;


    result := (mSTX.Len = mSTX.Idx) and (mETX.Len = mETX.Idx) ;

    if result and (nIdx > 0) then TByteArray(Buff)[nIdx] := 0;
    ClearFrame();
end;
//---------------------------------------------------------------------------
function  TRS232.ComWrite(const pBuff; nToWrite:DWORD):integer;
var
    dwWriteByte, dwBytes: DWORD ;
begin
    result := -1;
    dwBytes := 0 ;

    if mManualFlow then
    begin
        if not ReadyReceveDate() then exit;
    end;
    GetInQue();

    repeat
        SetLastError(0) ;
        WriteFile(hCom, TByteArray(pBuff)[dwBytes], nToWrite - dwBytes, dwWriteByte, nil);

        if (dwWriteByte = 0) then
        begin
            if (GetLastError() <> 0) then
            begin
                result := -1;
                exit;
            end ;
        end
        else
            dwBytes := dwBytes + dwWriteByte ;
    until (dwBytes >= nToWrite) ;

    Result := dwBytes ;
end;
//---------------------------------------------------------------------------
function  TRS232.ComWrites(const pBuff; nWrite : DWORD) : integer;
var
    nByteWrite : DWORD;
begin
    result := -1;
    nByteWrite := 0;

    //if (High(TByteArray(pBuff)) < nWrite) then exit;
    if ((not IsOpen()) or (nWrite=0)) then exit;
    //if ((hCom = THandle(FILE_OPEN_ERROR)) or (nWrite=0)) then exit;

    if mManualFlow then
    begin
        if not ReadyReceveDate() then exit;
    end;
    if (WriteFile(hCom, pBuff, nWrite, nByteWrite, nil)) then result := nByteWrite;
end;


//---------------------------------------------------------------------------
function  TRS232.IsOpen() : Boolean;
begin
    result := (hCom <> INVALID_HANDLE_VALUE);
end;
//---------------------------------------------------------------------------
procedure TRS232.SetStxEtx(stx, etx : string);
begin
    StrPCopy(mSTX.Frame, stx);
    StrPCopy(mETX.Frame, etx);

    mSTX.Len := Length(stx) ;
    mETX.Len := Length(etx) ;
end;
//---------------------------------------------------------------------------
procedure TRS232.ClearFrame();
begin
    mSTX.Idx := 0;
    mETX.Idx := 0;
end;
//---------------------------------------------------------------------------
function TRS232.IsFrame(var f : TFrame; cRead : Char) : Boolean;
begin
    if (f.Len > 0) then
    begin
        if (cRead = f.Frame[0]) then f.Idx := 0;
        if (cRead = f.Frame[f.Idx]) then Inc(f.Idx)
        else
        begin
            f.Idx := 0;
            //if (cRead = f.Frame[f.Idx]) then Inc(f.Idx);
        end;
    end;
    result := (f.Idx = f.Len);

{    if result then
    begin
        gLog.Panel(9, 9, 9, 'Frame Ok' + cRead);
    end;}
end;

end.
