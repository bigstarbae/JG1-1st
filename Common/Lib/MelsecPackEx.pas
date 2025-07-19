unit MelsecPackEx;

{$R-,T-,H+,X+}

//------------------------------------------------------------------------------
//      2004.05.27 by sattler
//      MELSEC-Q 시리즈와 QJ71E71-100 이더넷 모듈 장착시 대응.
//
//      PLC -> Q02HCPU
//      UDP 방식 -> 기본 세팅이며 TCP를 원할 경우 따로 설정해야함.
//      UDP 는 항상 바이너리로만 사용할것(세팅할 수 있는지는 아직 모름) --;
//
//      2007.05.31 by sattler
//      프로토콜 형식  : QnA호환 3E / A호환 1E
//      데이터처리방식 : 바이너리 / ASCII.
//      데이터 종류    : 비트데이터 / 워드데이터.
//      송수신 방식    : 비트단위 / 워드단위.
//      위의 분류에 따라 선택적으로 클래스를 사용.
//------------------------------------------------------------------------------
//
{
    QnA 호환 가능 3E 프로토콜
    [프로토콜]              [길이(BYTE)]  [참조(ASCII전송일때)]
    --------------------------------------------------------------
    서브헤더                4             5000 hex -> string
    --------------------------------------------------------------
    네트웍번호              2             00
    --------------------------------------------------------------
    PLC네트웍번호           2             FF
    --------------------------------------------------------------
    요구상대모듈 I/O번호    4             03FF
    --------------------------------------------------------------
    요구상대모듈 국번호     2             00
    --------------------------------------------------------------
    요구데이터 길이         4             CPU감시 타이머 부터 끝까지의 BYTE 수.
    --------------------------------------------------------------
    CPU감시 타이머          4             0001 (단위가 250ms, 0이면 무한대기임)
    --------------------------------------------------------------
    커맨더                  4             0401 (일괄읽기,일괄쓰기)
    --------------------------------------------------------------
    서브커맨드              4             0000 (워드단위), 0001(비트단위)
    --------------------------------------------------------------
    요구데이터              ? (WRITE 일때 여기에 실어준다)
    --------------------------------------------------------------

    응답
    --------------------------------------------------------------
    서브헤더                4             D000 hex -> string
    --------------------------------------------------------------
    네트웍번호              2             00
    --------------------------------------------------------------
    PLC네트웍번호           2             FF
    --------------------------------------------------------------
    요구상대모듈 I/O번호    4             03FF
    --------------------------------------------------------------
    요구상대모듈 국번호     2             00
    --------------------------------------------------------------
    요구데이터 길이         4             종료코드 부터 끝까지의 BYTE 수.
    --------------------------------------------------------------
    종료코드                4             0000 이면 정상.
    --------------------------------------------------------------
    응답데이터              ?
    --------------------------------------------------------------
    이상종료일때 위의 프레임에 계속해서 다음이 수신됨.
    다음을 [에러정보부] 라고 함.
    --------------------------------------------------------------
    네트웍번호              2
    --------------------------------------------------------------
    PLC번호                 2
    --------------------------------------------------------------
    요구상대모듈 I/O번호    4
    --------------------------------------------------------------
    요구상대모듈 국번호     2
    --------------------------------------------------------------
    커맨드                  4
    --------------------------------------------------------------
    서브커맨드              4
    --------------------------------------------------------------
}
//
interface
uses
  Windows, Messages, SysUtils, Classes ;

const
    //MELSEC COMMAND.
    BUFFER_SIZE   = 2048 ;

type
TModes = (ioREAD, ioWRITE) ;  // write protocol 타입, 응답타입.
TDataTypes = (dtBIT, dtWORD) ; // 데이타 타입
TBatchTypes= (btBIT, btWORD) ; // 송/수신단위
TPlcProtocolType = (ppA, ppQnA) ;
TRwType = (rwBin, rwASCII) ;
TBasePack = class
private
    mBuffer  : array[0..BUFFER_SIZE-1]of BYTE ;
    mRecvBuf : array[0..BUFFER_SIZE-1]of BYTE ;
    mRecvBufCnt : integer ;

    mPLCNO : BYTE ;
    mDeviceName : array[0..1]of Char ;
    mDeviceBeginAddress: integer ;
    mDeviceMaxPoints   : integer ;
    mAcpuTimer : WORD ;
    mDataType  : TDataTypes ;

    mErrorCode    : integer ;
    mAbNormalCode : BYTE ;
    mRecvSubHead  : TModes ;
    mRecvCount    : integer ;
    mBatchType : TBatchTypes;

    function  GetDeviceName: CHAR ;
    procedure SetAcpuTimer(const Value: WORD);
    procedure SetBeginAddress(const Value: integer);
    procedure SetCount(const Value: integer);
    procedure SetDeviceName(const Value: CHAR);
    procedure SetPLCNO(const Value: BYTE);
    procedure SetDataType(const Value: TDataTypes);
    procedure SetBatchType(const Value: TBatchTypes);
    function  ASCIIBitPLCToPC(const ABuf: Ansistring): integer;
    function  ASCIIWordBitPLCToPC(const ABuf: Ansistring): integer;
    function  ASCIIWordPLCToPC(const ABuf: Ansistring): integer;

public
    constructor Create ;
    destructor  Destroy; override ;

    function  GetBuffer(var Buf: array of BYTE): integer ; overload ;
    function  GetError: Ansistring ;

    procedure Initial ;
    procedure SetBitValue(Address: integer; AValue: BYTE) ;
    procedure SetWordValue(Address: integer; AValue: WORD) ;
    function  GetBitValue(Address: integer) : BYTE ;
    function  GetWordValue(Address: integer) : WORD ;
    function  GetWordToStr(Address, ACount: integer): Ansistring ;

published
    property PLCNo: BYTE read mPLCNO write SetPLCNO ;
    property DeviceName: CHAR read GetDeviceName write SetDeviceName ;
    property BeginAddress: integer read mDeviceBeginAddress write SetBeginAddress ;
    property RwCount: integer read mDeviceMaxPoints write SetCount ;
    property ErrorCode: integer read mErrorCode ;
    property AbNormalCode: BYTE read mAbNormalCode ;
    property RecvSubHead : TModes read mRecvSubHead ;
    property AcpuTimer: WORD read mAcpuTimer write SetAcpuTimer ;
    property DataType: TDataTypes read mDataType write SetDataType ;
    property BatchType : TBatchTypes read mBatchType write SetBatchType ;
end ;

TPackQnA3E = class(TBasePack)
private
    msubHeader : WORD ;
    mNetWorkNO : BYTE ;
    mReqIoNO   : WORD ;
    mReqNO     : BYTE ;

    procedure SetNetWorkNo(const Value: BYTE);
    procedure SetReqIoNo(const Value: WORD);
    procedure SetReqNo(const Value: BYTE);
    procedure SetSubHeader(const Value: WORD);

public
    constructor Create ;

published

    property subHeader : WORD read msubHeader write SetSubHeader ;
    property NetWorkNO : BYTE read mNetWorkNO write SetNetWorkNo ;
    property ReqIoNo : WORD   read mReqIoNo write SetReqIoNo ;
    property ReqNo   : BYTE   read mReqNo write SetReqNo ;
end ;

TPackQnA3E_Bin = class(TPackQnA3E)
private
public
    function Pack(var Buf: array of BYTE; AMode: TModes=ioREAD): integer ;
    function UnPack(const Buf: array of BYTE; ACount:integer): boolean ;
end ;

TPackQnA3E_Ascii = class(TPackQnA3E)
private
public
    function Pack(var Buf: Ansistring; AMode: TModes=ioREAD): integer ;
    function UnPack(const Buf: Ansistring): boolean ;
end ;

TPackA1E_Bin = class(TBasePack)
private
public
    function Pack(var Buf: array of BYTE; AMode: TModes=ioREAD): integer ;
    function UnPack(const Buf: array of BYTE; ACount:integer): boolean ;
end ;

TPackA1E_Ascii = class(TBasePack)
private
public
    function Pack(var Buf: Ansistring; AMode: TModes=ioREAD): integer ;
    function UnPack(const Buf: Ansistring): boolean ;
end ;

    function  CharHexToByte(Hex : AnsiChar) :BYTE ;
    function  ByteToCharHex(Dec : BYTE) : Char;

    function  BitPCToPLC(var Buf: array of BYTE; ACount: integer): integer ;
    function  BitPLCToPC(var Buf: array of Byte; aCount: integer): integer ;
    function  WordPLCToPC(var Buf: array of Byte; aCount: integer): integer ;
    function  WordPCToPLC(var Buf: array of Byte; ACount: integer): integer ;


    function  GetErrorToTxt(ACode, AbNormalCode:integer): string ;

implementation
uses
    myUtils, E71ErCode, Log , LangTran;

const
    _RECV_LENGTH_ERROR = -1 ; //기본적으로 종료코드까지의 데이터가 수신되지 않았습니다.
    _SUB_HEAD_ERROR    = -2 ; //송신한 서브헤더와 수신 헤더가 다릅니다.
    _PLC_NO_ERROR      = -3 ; //송신한 PLC번호와 수신 번호가 다릅니다.
    _REQ_IO_ERROR      = -4 ; //송신한 요구상대모듈I/O번호와 수신번호가 다릅니다.
    _REQ_NO_ERROR      = -5 ; //송신한 요구상대모듈번화 수신번호가 다릅니다.
    _NETWORK_NO_ERROR  = -6 ;
//------------------------------------------------------------------------------
// Utility
//------------------------------------------------------------------------------
function  GetErrorToTxt(ACode, AbNormalCode:integer): String ;
begin
    Result := '' ;
    
    if ACode >= 0 then
    begin
        Result := GetErrorCodeToStr(BYTE(ACode)) ;
        if ACode = $5B then
            Result := Result + '#' + GetAbNoramlCodeToStr(AbNormalCode) ;
    end
    else
    begin
        case ACode of
            _RECV_LENGTH_ERROR :
            begin
                Result := 'Datums are not receive to end code';//_TR('기본적으로 종료코드까지의 데이터가 수신되지 않았습니다.') ;
            end ;
            _SUB_HEAD_ERROR    :
            begin
                Result := 'Not received header of normally act';//_TR('정상동작의 수신 헤더가 아닙니다.') ;
            end ;
            _PLC_NO_ERROR      :
            begin
                Result := 'Not match send PLC No. and received No';//_TR('송신한 PLC번호와 수신 번호가 다릅니다.') ;
            end ;
            _REQ_IO_ERROR      :
            begin
                Result := 'Not match send module I/O and received No';//_TR('송신한 요구상대모듈I/O번호와 수신번호가 다릅니다.') ;
            end ;
            _REQ_NO_ERROR      :
            begin
                Result := 'Not match send module No. and received No';//_TR('송신한 요구상대모듈번오화 수신번호가 다릅니다.') ;
            end ;
            _NETWORK_NO_ERROR  :
            begin
                Result := 'Not match network No. send and receive';//_TR('송신한 네트웍번호와 수신번호가 다릅니다.') ;
            end ;
        end ;
    end ;

    if Result = '' then Result := Format('UNKNOW ERROR', []) ;

    Result := Format('%s(CODE:%sH,AbNormalCode:%d)',[Result, IntToHex(BYTE(ACode), 2), AbNormalCode])
end ;

function GetDeviceCode(ADevice: Ansistring): BYTE ;
begin
    Result := 0 ;
    if Length(ADevice) <> 2 then Exit ;
    case ADevice[1] of
        'B' : Result := $A0 ;
        'C' :
        begin
            case ADevice[2] of
                'C' : Result := $C3 ;
                'N' : Result := $C5 ;
                'S' : Result := $C4 ;
            end ;
        end ;
        'D' :
        begin
            case ADevice[2] of
                'X' : Result := $A2 ;
                'Y' : Result := $A3 ;
            else
                Result := $A8 ;
            end ;
        end ;
        'R' : Result := $AF ;
        'X' : Result := $9C ;
        'Y' : Result := $9D ;
        'M' : Result := $90 ;
        'L' : Result := $92 ;
        'F' : Result := $93 ;
        'W' : Result := $B4 ;
        'S'  :
        begin
            case ADevice[2] of
                'C' : Result := $C6 ;
                'D' : Result := $A9 ;
                'M' : Result := $91 ;
                'N' : Result := $C8 ;
                'S' : Result := $C7 ;
                'W' : Result := $B5 ;
            else
                Result := $98 ;
            end ;
        end ;
        'T' :
        begin
            case ADevice[2] of
                'C' : Result := $C0 ;
                'N' : Result := $C2 ;
                'S' : Result := $C1 ;
            end ;
        end ;
        'V' : Result := $94 ;
        'Z' :
        begin
            case ADevice[2] of
                'R' : Result := $B0 ;
            else
                Result := $CC ;
            end ;
        end ;
    end ;
end ;

function CharHexToByte(Hex : AnsiChar) :BYTE ;
begin
    Result := 0;
    if ((Hex >= '0') and (Hex <= '9')) then Result := (Ord(Hex) - ord('0'))
    else
    if ((Hex >= 'A') and (Hex <= 'F')) then Result := (Ord(Hex) - ord('A') + 10)
    else
    if ((Hex >= 'a') and (Hex <= 'f')) then Result := (Ord(Hex) - ord('a') + 10) ;
end;

function ByteToCharHex(Dec : BYTE) : Char;
begin
    Result := #0;
    if (Dec <= 9)                    then Result := Chr(Ord('0') + Dec)
    else
    if ((Dec >= 10) and (Dec <= 15)) then Result := Chr(Ord('A') + Dec  - 10) ;
end;

function GetValueBit(const Buf: array of BYTE; aIndex: integer): BYTE ;
begin
    Result := Buf[aIndex div 8] ;
    Result := Result shr (aIndex mod 8) ;
    Result := Result and $01 ;
end ;

procedure SetValue4Bit(var Buf:array of BYTE; aIndex, aValue: integer) ;
var
    iTm : integer ;
begin
    if (aIndex mod 2) = 0 then
    begin
        Buf[aIndex div 2] := Buf[aIndex div 2] and $EF ;
        iTm := (aValue shl 4) and $10 ;
    end
    else
    begin
        Buf[aIndex div 2] := Buf[aIndex div 2] and $FE ;
        iTm := aValue and $01 ;
    end ;
    Buf[aIndex div 2] := Buf[aIndex div 2] or iTm ;
end ;
// 4Bit -> 1Bit
function BitPLCToPC(var Buf: array of Byte; ACount: integer): integer ;
var
    i : integer ;
    Tmp : array[0..BUFFER_SIZE-1] of BYTE ;
begin
    Result := 0 ;
    FillChar(Tmp, BUFFER_SIZE, 0);
    Move(Buf, Tmp, ACount+1) ;
    FillChar(Buf, BUFFER_SIZE, 0);

    for i := 0 to ACount -1 do
    begin
        if ((Tmp[i] shl 4) and $01) = $01 then
            Buf[Result div 8] := Buf[Result div 8] or (1 shr Result) ;
        Inc(Result) ;

        if (Tmp[i] and $01) = $01 then
            Buf[Result div 8] := Buf[Result div 8] or (1 shr Result) ;
        Inc(Result) ;
    end ;
    Result := Result div 8 + integer((Result mod 8) > 0);
end ;
// 1Bit -> 4Bit
function BitPCToPLC(var Buf: array of BYTE; ACount: integer): integer ;
var
    i, j : integer ;
    Tmp : array[0..BUFFER_SIZE-1] of BYTE ;
begin
    ACount := (ACount div 8) + integer((ACount mod 8) > 0) ;

    Result := 0 ;
    FillChar(Tmp, BUFFER_SIZE, 0);
    Move(Buf, Tmp, ACount+1) ;

    for i := 0 to ACount -1 do
    begin
        for j := 0 to 7 do
        begin
            Buf[Result] := ((Tmp[i] shl j) and $01) shl 4 ;
            Buf[Result] := Buf[Result] or ((Tmp[i] shl j) and $01) ;
            Inc(Result) ;
        end ;
    end ;
    Result := Result * 2 ;
end;
// PLC DATA L and H --> PC DATA H and L.
function  WordPLCToPC(var Buf: array of Byte; ACount: integer): integer ;
begin
    Result := WordPCToPLC(Buf, ACount) ;
end ;

function  WordPCToPLC(var Buf: array of Byte; ACount: integer): integer ;
var
    i : integer ;
    Tmp : BYTE ;
begin
    Result := 0 ;
    // ACount 는 반드시 데이터 갯수 일것
    for i := 0 to ACount-1 do
    begin
        Tmp        := Buf[i*2+0] ;
        Buf[i*2+0] := Buf[i*2+1] ;
        Buf[i*2+1] := Tmp ;
        Inc(Result) ;
    end ;
    // 갯수는 받은갯수가 아니라 요청한 갯수로 해야 한다.
    Result := (Result div 8) + integer((Result mod 8) > 0) ;
end ;
// 워드단위로 비트데이터 관리
function WordBitPCToPLC(var Buf: array of Byte; aCount: integer): integer ;
var
    i, Val : integer ;
    Tmp : array[0..BUFFER_SIZE-1] of BYTE ;
begin
    Result := 0 ;
    FillChar(Tmp, BUFFER_SIZE, 0);
    Move(Buf, Tmp, ACount+1) ;

    for i := 0 to aCount -1 do
    begin
        Val := GetValueBit(Tmp, i) ;
        SetValue4Bit(Buf, i, Val) ;
        Inc(Result) ;
    end ;
    Result := Result div 2 + integer((Result mod 2) > 0);
end ;

{ TBasePack }

constructor TBasePack.Create;
begin
    FillChar(mBuffer, sizeof(mBuffer), 0) ;
    FillChar(mRecvBuf, sizeof(mRecvBuf), 0) ;
    mRecvBufCnt := 0 ;

    mPLCNO := $FF ;
    mDeviceName[0] := 'D' ;
    mDeviceName[1] := ' ' ;
    mDeviceBeginAddress  := 0 ;
    mDeviceMaxPoints     := 1 ;
    mErrorCode := 0 ;
    mAbNormalCode := 0 ;
    mRecvSubHead := ioREAD ;
    mAcpuTimer := 1 ;
    mDataType  := dtBIT ;
end;

destructor TBasePack.Destroy;
begin

  inherited;
end;

function TBasePack.GetBitValue(Address: integer): BYTE;
var
    iTm : integer ;
begin
    Result := 0 ;
    iTm := abs(Address - mDeviceBeginAddress) ;
    try
        Result := integer(IsBitOn(mBuffer[iTm div 8], iTm mod 8)) ;
        //Result := integer((mBuffer[iTm div 8] and (1 shr (iTm mod 8)))=(1 shr (iTm mod 8)))
    except
        On E:Exception do gLog.ToFiles('TBasePack GetBitValue %s', [E.Message]) ;
    end ;
end;

function TBasePack.GetBuffer(var Buf: array of BYTE): integer;
begin
    Move(mBuffer, Buf, mRecvCount+1) ;
    Result := mRecvCount ;
end;

function TBasePack.GetDeviceName: CHAR ;
begin
    Result := mDeviceName[0] ;
end;

function TBasePack.GetError: Ansistring;
begin
    Result := '' ;
    case mErrorCode of
        $00 : Exit ;
        $5B : Result := GetAbNoramlCodeToStr(mAbNormalCode) ;
    else
        Result := GetErrorCodeToStr(mErrorCode) ;
    end ;
end;

function TBasePack.GetWordToStr(Address, ACount: integer): Ansistring;
var
    i, iTm : integer ;
begin
    iTm := abs(Address - mDeviceBeginAddress) * 2 ;

    Result := '' ;
    try
        for i := 0 to ACount-1 do
        begin
            Result := Result + Chr(mBuffer[iTm]) + Chr(mBuffer[iTm+1]) ;
            Inc(iTm, 2) ;
        end ;
    except
        On E:Exception do gLog.ToFiles('TBasePack GetWordToStr %s', [E.Message]) ;
    end ;
end;

function TBasePack.GetWordValue(Address: integer): WORD;
var
    iTm : integer ;
begin
    Result := 0 ;
    iTm := abs(Address - mDeviceBeginAddress) * 2 ;
    try
        Result := WORD(mBuffer[iTm] shl 8) or mBuffer[iTm+1] ;
    except
        On E:Exception do gLog.ToFiles('TBasePack GetWordValue %s', [E.Message]) ;
    end ;
end;

procedure TBasePack.Initial;
begin
    FillChar(mBuffer, BUFFER_SIZE, 0);
    mErrorCode    := 0 ;
    mAbNormalCode := 0 ;
    mRecvCount    := 0 ;
end;

procedure TBasePack.SetAcpuTimer(const Value: WORD);
begin
    mAcpuTimer := Value ;
end;

procedure TBasePack.SetBatchType(const Value: TBatchTypes);
begin
    mBatchType := Value ;
end;

procedure TBasePack.SetBeginAddress(const Value: integer);
begin
    mDeviceBeginAddress := Value ;
end;

procedure TBasePack.SetBitValue(Address: integer; AValue: BYTE);
var
    iTm : integer ;
begin
    iTm := abs(Address - mDeviceBeginAddress) ;
    try
        mBuffer[iTm div 8] := mBuffer[iTm div 8] or (AValue shl (iTm mod 8)) ;
    except
        On E:Exception do gLog.ToFiles('TBasePack SetBitValue %s', [E.Message]) ;
    end ;
end;

procedure TBasePack.SetCount(const Value: integer);
begin
    mDeviceMaxPoints := Value ;
end;

procedure TBasePack.SetDataType(const Value: TDataTypes);
begin
    mDataType := Value ;
end;

procedure TBasePack.SetDeviceName(const Value: CHAR);
begin
    mDeviceName[0] := Value ;
    mDeviceName[1] := Char($20) ;
end;

procedure TBasePack.SetPLCNO(const Value: BYTE);
begin
    mPLCNO := Value ;
end;

procedure TBasePack.SetWordValue(Address: integer; AValue: WORD);
var
    iTm : integer ;
begin
    iTm := abs(Address - mDeviceBeginAddress) ;
    try
        mBuffer[iTm*2]   := (AValue shr 8) and $FF ;
        mBuffer[iTm*2+1] := BYTE(AValue) ;
    except
        On E:Exception do gLog.ToFiles('TBasePack SetWordValue %s', [E.Message]) ;
    end ;
end;

function  TBasePack.ASCIIBitPLCToPC(const ABuf: Ansistring): integer ;
var
    i : integer ;
begin
    Result := 0 ;
    for i := 0 to Length(ABuf)-1 do
    begin
        SetBitValue(mDeviceBeginAddress+i, CharHexToByte(ABuf[i+1])) ;
        Inc(Result) ;
    end ;
end ;

function  TBasePack.ASCIIWordPLCToPC(const ABuf: Ansistring): integer ;
var
    i, iTm : integer ;
begin
    iTm := 0 ;
    Result := 0 ;
    for i := 1 to Length(ABuf) do
    begin
        if (i mod 4) = 0 then
        begin
            iTm := (iTm shl 4) or CharHexToByte(ABuf[i]) ;
            SetWordValue(mDeviceBeginAddress+Result, WORD(iTm)) ;
            Inc(Result) ;
            iTm := 0 ;
        end
        else
        begin                                        
            iTm := (iTm shl 4) or (CharHexToByte(ABuf[i]) and $0F) ;
        end ;
    end ;
end ;

function  TBasePack.ASCIIWordBitPLCToPC(const ABuf: Ansistring): integer ;
var
    i, iTm : integer ;
begin
    iTm := 0 ;
    Result := 0 ;
    for i := 1 to Length(ABuf) do
    begin
        if (i mod 4) = 0 then
        begin
            iTm := (iTm shl 4) or CharHexToByte(ABuf[i]) ;
            SetWordValue(mDeviceBeginAddress+Result, WORD(iTm)) ;
            Inc(Result) ;
            iTm := 0 ;
        end
        else
        begin
            iTm := (iTm shl 4) or (CharHexToByte(ABuf[i]) and $0F) ;
        end ;
    end ;
end ;

{ TPackQnA3E }

constructor TPackQnA3E.Create;
begin
    inherited ;
    msubHeader := $5000 ;
    mNetWorkNO := $00 ;
    mReqIoNO   := $03FF ;
    mReqNO     := $00 ;
end;

procedure TPackQnA3E.SetNetWorkNo(const Value: BYTE);
begin
    mNetWorkNO := Value ;
end;

procedure TPackQnA3E.SetReqIoNo(const Value: WORD);
begin
    mReqIoNO := Value ;
end;

procedure TPackQnA3E.SetReqNo(const Value: BYTE);
begin
    mReqNO := Value ;
end;

procedure TPackQnA3E.SetSubHeader(const Value: WORD);
begin
    msubHeader := Value ;
end;

{ TPackQnA3E_Ascii }

function TPackQnA3E_Ascii.Pack(var Buf: Ansistring; AMode: TModes): integer;
var
    sTm, nW : Ansistring ;
    i, iTm : integer ;
begin
    // SubHeader
    Buf := IntToHex(msubHeader, 4) ;
    // Network Number
    Buf := Buf + IntToHex(mNetWorkNo, 2) ;
    // PLC Network Number
    Buf := Buf + IntToHex(mPLCNO, 2) ;
    // 요구상대모듈 I/O번호
    Buf := Buf + IntToHex(mReqIoNo, 4) ;
    // 요구상대모듈 국번호
    Buf := Buf + IntToHex(mReqNo, 2) ;
    // 전송데이터길이
    //Buf
    // CPU 감시타이머
    sTm := IntToHex(mAcpuTimer, 4) ;
    // 커맨더
    if aMode = ioREAD then sTm := sTm + IntToHex($0401, 4)
    else                   sTm := sTm + IntToHex($1401, 4) ;
    // 서브커맨더
    if mBatchType = btBIT then sTm := sTm + IntToHex($0001, 4)
    else                       sTm := sTm + IntToHex($0000, 4) ;
    //디바이스코드
    sTm := sTm + mDeviceName;//[0]+'*' ;
    //선두디바이스
    sTm := sTm + IntToHex(mDeviceBeginAddress, 6) ;
    //디바이스점수
    nW  := '' ;
    if mBatchType = btBIT then
    begin
        if mDataType = dtBIT then
        begin
            iTm := mDeviceMaxPoints ;
            if AMode = ioWRITE then
            begin
                for i := 0 to iTm-1 do
                begin
                    if GetBitValue(mDeviceBeginAddress+i) = 1 then nW := nW + '1'
                    else                                           nW := nW + '0' ;
                end ;
            end ;
        end
        else
        begin
            iTm := 1 ;
            gLog.Panel('PACK ERROR 배치타입과 데이타타입오류(BIT - WORD)', []) ;
        end ;
    end
    else
    if mDataType = dtBIT then
    begin
        if AMode = ioWRITE then
        begin
            //만일 연이어 데이터에 잘못 기재할 수 있다.
            iTm := (mDeviceMaxPoints div 16);//+integer((mDeviceMaxPoints mod 16) > 0) ;

            for i := 0 to iTm -1 do
            begin
                nW := nW + IntToHex(mBuffer[i*2+1], 2) ;
                nW := nW + IntToHex(mBuffer[i*2+0], 2) ;
            end ;
        end ;
        iTm := (mDeviceMaxPoints div 16)+integer((mDeviceMaxPoints mod 16) > 0) ;
    end
    else
    begin
        iTm := mDeviceMaxPoints ;
        if AMode = ioWRITE then
        begin
            for i := 0 to iTm -1 do
            begin
                nW := nW + IntToHex(mBuffer[i*2+0], 2) ;
                nW := nW + IntToHex(mBuffer[i*2+1], 2) ;
            end ;
        end ;
    end ;
    sTm := sTm + IntToHex(iTm, 4) + nW ;
    // 전송데이터길이
    Buf := Buf + IntToHex(Length(sTm), 4) ;
    Buf := Buf + sTm ;
    //
    Result := Length(Buf) ;
end;

function TPackQnA3E_Ascii.UnPack(const Buf: Ansistring): boolean;
var
    sTm : Ansistring ;
begin
    FillChar(mRecvBuf, sizeof(mRecvBuf), 0) ;
    mRecvBufCnt := Length(Buf) ;
    Move(Buf[1], mRecvBuf, mRecvBufCnt) ;

    sTm := Buf ;
    mErrorCode := 0 ;
    mAbNormalCode := 0 ;

    Result := false ;
    // Length
    if Length(sTm) < 22 then
    begin
        mErrorCode := _RECV_LENGTH_ERROR ;
        Exit ;
    end ;
    //sub Head check
    if 'D000' <> Copy(sTm, 1, 4) then
    begin
        mErrorCode := _SUB_HEAD_ERROR ;
        Exit ;
    end ;
    //network No
    if IntToHex(mNetWorkNO, 2) <> Copy(sTm, 5, 2) then
    begin
        mErrorCode := _NETWORK_NO_ERROR ;
        Exit ;
    end ;
    //Plc No
    if IntToHex(mPLCNO, 2) <> Copy(sTm, 7, 2) then
    begin
        mErrorCode := _PLC_NO_ERROR ;
        Exit ;
    end ;
    //Req I/O No
    if IntToHex(mReqIoNo, 4) <> Copy(sTm, 9, 4) then
    begin
        mErrorCode := _REQ_IO_ERROR ;
        Exit ;
    end ;
    //Req station No
    if IntToHex(mReqNo, 2) <> Copy(sTm, 13, 2) then
    begin
        mErrorCode := _REQ_NO_ERROR ;
        Exit ;
    end ;
    mRecvCount := HexToInt(Copy(sTm, 15, 4)) ;
    mRecvCount := mRecvCount - 4 ;
    //End Code
    mErrorCode := HexToInt(Copy(sTm, 19, 4)) ;
    if mErrorCode <> $00 then
    begin
        Exit ;
    end ;

    Result := true ;
    if mRecvCount <= 0 then Exit ;
    if mErrorCode = 0 then
    begin
        sTm := Copy(sTm, 23, mRecvCount) ;

        if mBatchType = btBIT then mRecvCount := ASCIIBitPLCToPC(sTm)
        else
        if mDataType = dtBIT then mRecvCount := ASCIIWordBitPLCToPC(sTm)
        else                      mRecvCount := ASCIIWordPLCToPC(sTm) ;
    end
    else
    begin
        //EDIT
    end ;
end;

{ TPackQnA3E_Bin }

function TPackQnA3E_Bin.Pack(var Buf: array of BYTE;
  AMode: TModes): integer;
var
    i, iTm : integer ;
begin
    if aMode = ioREAD then
    begin
        // SubHeader
        Buf[0] := BYTE(msubHeader shr 8) ;
        Buf[1] := BYTE(msubHeader) ;
        // Network Number
        Buf[2] := mNetWorkNO ;
        // PLC Network Number
        Buf[3] := mPLCNO ;
        // 요구상대모듈 I/O번호
        Buf[4] := BYTE(mReqIoNo) ;
        Buf[5] := BYTE(mReqIoNo shr 8) ;
        // 요구상대모듈 국번호
        Buf[6] := mReqNo ;
        // 전송데이터길이
        Buf[7] := 0 ;
        Buf[8] := 0 ;
        // CPU 감시타이머
        Buf[9] := BYTE(mAcpuTimer) ;
        Buf[10] := BYTE(mAcpuTimer shr 8) ;
        // 커맨더
        Buf[11] := $01 ;
        Buf[12] := $04 ;
        // 서브커맨더
        if mBatchType = btBIT then
        begin
            Buf[13] := $01 ;
            Buf[14] := $00 ;
        end
        else
        begin
            Buf[13] := $00 ;
            Buf[14] := $00 ;
        end ;
        //선두디바이스
        Buf[15] := BYTE(mDeviceBeginAddress) ;
        Buf[16] := BYTE(mDeviceBeginAddress shr 8)  ;
        Buf[17] := BYTE(mDeviceBeginAddress shr 16) ;
        //디바이스코드
        Buf[18] := GetDeviceCode(mDeviceName) ;
        //디바이스점수
        Buf[19] := BYTE(mDeviceMaxPoints) ;
        Buf[20] := BYTE(mDeviceMaxPoints shr 8) ;
        Result  := 21 ;
        // 전송데이터길이
        Buf[7] := BYTE(Result-9) ;
        Buf[8] := BYTE((Result-9) shr 8) ;
    end
    else
    begin
        // SubHeader
        Buf[0] := BYTE(msubHeader shr 8) ;
        Buf[1] := BYTE(msubHeader) ;
        // Network Number
        Buf[2] := mNetWorkNO ;
        // PLC Network Number
        Buf[3] := mPLCNO ;
        // 요구상대모듈 I/O번호
        Buf[4] := BYTE(mReqIoNo) ;
        Buf[5] := BYTE(mReqIoNo shr 8) ;
        // 요구상대모듈 국번호
        Buf[6] := mReqNo ;
        // 전송데이터길이
        Buf[7] := 0 ;
        Buf[8] := 0 ;
        // CPU 감시타이머
        Buf[9] := BYTE(mAcpuTimer) ;
        Buf[10] := BYTE(mAcpuTimer shr 8) ;
        // 커맨더
        Buf[11] := $01 ;
        Buf[12] := $04 ;
        // 서브커맨더
        if mBatchType = btBIT then
        begin
            Buf[13] := $01 ;
            Buf[14] := $00 ;
        end
        else
        begin
            Buf[13] := $00 ;
            Buf[14] := $00 ;
        end ;
        //선두디바이스
        Buf[15] := BYTE(mDeviceBeginAddress) ;
        Buf[16] := BYTE(mDeviceBeginAddress shr 8)  ;
        Buf[17] := BYTE(mDeviceBeginAddress shr 16) ;
        //디바이스코드
        Buf[18] := GetDeviceCode(mDeviceName) ;
        //
        if mBatchType = btBIT then
        begin
            if mDataType = dtBIT then
            begin
                //디바이스점수
                Buf[19] := BYTE(mDeviceMaxPoints) ;
                Buf[20] := BYTE(mDeviceMaxPoints shr 8) ;
                Result  := 21 ;
                //전송데이타
                for i := 0 to mDeviceMaxPoints-1 do
                begin
                    Buf[Result] := GetBitValue(mDeviceBeginAddress+i) ;
                    Inc(Result) ;
                end ;
            end
            else
            begin
                Result := 0 ;
                gLog.Panel('PACK ERROR 배치타입과 데이타타입오류(BIT - WORD)', []) ;
                Exit ;
            end ;
        end
        else
        begin
            if mDataType = dtBIT then
            begin
                //디바이스점수
                iTm := (mDeviceMaxPoints div 16)
                        + integer((mDeviceMaxPoints mod 16) > 0) ;

                Buf[19] := BYTE(iTm) ;
                Buf[20] := BYTE(iTm shr 8) ;
                Result  := 21 ;
                //전송데이타
                iTm := (mDeviceMaxPoints div 8)
                       + integer((mDeviceMaxPoints mod 8) > 0) ;
                for i := 0 to iTm-1 do
                begin
                    Buf[Result] := mBuffer[i] ;
                    Inc(Result) ;
                end ;
            end
            else
            begin
                //디바이스점수
                Buf[19] := BYTE(mDeviceMaxPoints) ;
                Buf[20] := BYTE(mDeviceMaxPoints shr 8) ;
                Result  := 21 ;
                for i := 0 to mDeviceMaxPoints-1 do
                begin
                    Buf[Result] := mBuffer[i*2+0] ;
                    Inc(Result) ;
                    Buf[Result] := mBuffer[i*2+1] ;
                    Inc(Result) ;
                end ;
            end ;
        end ;
        // 전송데이터길이
        Buf[7] := BYTE(Result-9) ;
        Buf[8] := BYTE((Result-9) shr 8) ;
    end ;
end;

function TPackQnA3E_Bin.UnPack(const Buf: array of BYTE; ACount:integer): boolean;
begin
    FillChar(mBuffer, sizeof(mBuffer), 0) ;
    FillChar(mRecvBuf, sizeof(mRecvBuf), 0) ;

    mRecvBufCnt := ACount ;
    Move(Buf, mRecvBuf, mRecvBufCnt) ;

    mErrorCode := 0 ;
    mAbNormalCode := 0 ;
    Result := false ;
    //Receieve Length
    if ACount < 11 then
    begin
        mErrorCode := _RECV_LENGTH_ERROR ;
        Exit ;
    end ;
    //sub Head check
    if $D000 <> (Buf[0] shl 8 or Buf[1]) then
    begin
        mErrorCode := _SUB_HEAD_ERROR ;
        Exit ;
    end ;
    //network No
    if mNetWorkNO <> Buf[2] then
    begin
        mErrorCode := _NETWORK_NO_ERROR ;
        Exit ;
    end ;
    //Plc No
    if mPLCNO <> Buf[3] then
    begin
        mErrorCode := _PLC_NO_ERROR ;
        Exit ;
    end ;
    //Req I/O No
    if mReqIoNo <> (Buf[5] shl 8 or Buf[4]) then
    begin
        mErrorCode := _REQ_IO_ERROR ;
        Exit ;
    end ;
    //Req station No
    if mReqNo <> Buf[6] then
    begin
        mErrorCode := _REQ_NO_ERROR ;
        Exit ;
    end ;
    mRecvCount := Buf[8] shl 8 or Buf[7] ;
    mRecvCount := mRecvCount - 2 ;
    //End Code
    mErrorCode := Buf[10] shl 8 or Buf[9] ;
    if mErrorCode <> $00 then
    begin
        Exit ;
    end ;
    if mRecvCount <= 0 then Exit ;

    Move(Buf[11], mBuffer, mRecvCount) ;
    if mDataType = dtWORD then WordPLCToPC(mBuffer, mRecvCount)
    else                       BitPLCToPC(mBuffer, mRecvCount) ;
    Result := true ;
end;

{ TPackA1E_Ascii }

function TPackA1E_Ascii.Pack(var Buf: Ansistring; AMode: TModes): integer;
var
    i, j, Cnt : integer ;
begin
    if aMode = ioREAD then
    begin
        // SubHeader
        if mBatchType = btBIT then Buf := IntToHex($00, 2)
        else                       Buf := IntToHex($01, 2) ;
        // PC NO
        Buf := Buf + IntToHex(mPLCNO, 2) ;
        // ACPUT Timer
        Buf := Buf + IntToHex(mAcpuTimer, 4) ;
        // Device Name
        Buf := Buf + IntToHex(BYTE(mDeviceName[0]), 2) ;
        Buf := Buf + IntToHex(BYTE(mDeviceName[1]), 2) ;
        // Head Device No
        Buf := Buf + IntToHex(mDeviceBeginAddress, 8);
        // Point Count
        if (mBatchType = btWORD) and (mDataType = dtBIT) then
            Buf := Buf + IntToHex(mDeviceMaxPoints div 16, 2) 
        else
            Buf := Buf + IntToHex(mDeviceMaxPoints, 2) ;
        // ETX
        Buf := Buf + IntToHex($00, 2) ;
    end
    else
    begin
        // SubHeader
        if mBatchType = btBIT then Buf := IntToHex($02, 2)
        else                       Buf := IntToHex($03, 2) ;
        // PC NO
        Buf := Buf + IntToHex(mPLCNO, 2) ;
        // ACPUT Timer
        Buf := Buf + IntToHex(mAcpuTimer, 4) ;
        // Device Name
        Buf := Buf + IntToHex(BYTE(mDeviceName[0]), 2) ;
        Buf := Buf + IntToHex(BYTE(mDeviceName[1]), 2) ;
        // Head Device No
        Buf := Buf + IntToHex(mDeviceBeginAddress, 8);
        //
        if mBatchType = btBIT then
        begin
            // Point Count
            Buf := Buf + IntToHex(mDeviceMaxPoints, 2) ;
            // ETX
            Buf := Buf + IntToHex($00, 2) ;
            // 전송데이터
            Cnt := (mDeviceMaxPoints div 8)
                   + integer((mDeviceMaxPoints mod 8) > 0) ;

            Result := 0 ;
            for i := 0 to Cnt -1 do
            begin
                for j := 0 to 7 do
                begin
                    Buf := Buf + IntToStr(integer((mBuffer[i] shl j) and $01 = $01)) ;
                    Inc(Result) ;

                    if Result = mDeviceBeginAddress then Break ;
                end ;
            end ;
        end
        else
        //워드단위 에 비트데이터 전송
        if mDataType = dtBIT then
        begin
            // Point Count
            Cnt := (mDeviceMaxPoints div 16)
                    + integer((mDeviceMaxPoints mod 16) > 0) ;
            Buf := Buf + IntToHex(Cnt, 2) ;
            // ETX
            Buf := Buf + IntToHex($00, 2) ;
            // 전송데이터
            Cnt := (mDeviceMaxPoints div 8)
                   + integer((mDeviceMaxPoints mod 8) > 0) ;

            for i := 0 to Cnt -1 do
            begin
                Buf := Buf + IntToHex(mBuffer[i*2+1], 2) ;
                Buf := Buf + IntToHex(mBuffer[i*2+0], 2) ;
            end ;
        end
        else
        begin
            Cnt := mDeviceMaxPoints ;
            for i := 0 to Cnt-1 do
            begin
                Buf := Buf + IntToHex(mBuffer[i*2+0], 2) ;
                Buf := Buf + IntToHex(mBuffer[i*2+1], 2) ;
            end ;
        end ;
    end ;
    Result := Length(Buf) ;
end;

function TPackA1E_Ascii.UnPack(const Buf: Ansistring): boolean;
var
    sTm : Ansistring ;
    revHead : integer ;
begin
    FillChar(mRecvBuf, sizeof(mRecvBuf), 0) ;
    mRecvBufCnt := Length(Buf) ;
    Move(Buf[1], mRecvBuf, mRecvBufCnt) ;
    //StrLCopy(@mRecvBuf[0], PChar(Buf), mRecvBufCnt) ;

    sTm := Buf ;
    mErrorCode := 0 ;
    mAbNormalCode := 0 ;

    Result := false ;
    // subHeader
    if (sTm = '') or (Length(sTm) < 4) then Exit ;
    revHead := HexToInt(Copy(sTm, 1, 2)) ;
    case revHead of
        $80, $81 : // Read Response
        begin
            mRecvSubHead := ioREAD ;
            if revHead = $80 then mBatchType := btBIT
            else                  mBatchType := btWORD ;
            // Complete Code
            mErrorCode := HexToInt(Copy(sTm, 3, 2)) ;
            if mErrorCode = $00 then
            begin
                sTm := Copy(sTm, 5, Length(sTm)-4) ;
                mRecvCount := Length(Buf) ;
                // Read Datas
                if revHead = $80 then
                    mRecvCount := ASCIIBitPLCToPC(sTm)
                else
                if mDataType = dtBIT then
                    mRecvCount := ASCIIWordBitPLCToPC(sTm)
                else
                    mRecvCount := ASCIIWordPLCToPC(sTm) ;

                Result := true ;
            end
            else
            begin
                // abNormal Code
                if (mErrorCode = $5B) and (Length(sTm) >= 6) then
                    mAbNormalCode := HexToInt(Copy(sTm, 5, 2)) ;
            end ;
        end ;
        $82, $83 : // Write Response
        begin
            mRecvSubHead := ioWRITE ;
            mErrorCode   := HexToInt(Copy(sTm, 3, 2)) ;
            if mErrorCode = $00 then Result := true
            else
            begin
                if (mErrorCode = $5B) and (Length(sTm) >= 6) then
                    mAbNormalCode := HexToInt(Copy(sTm, 5, 2)) ;
            end ;
        end ;
    else
        mErrorCode := _SUB_HEAD_ERROR ;
    end ;
end;

{ TPackA1E_Bin }

function TPackA1E_Bin.Pack(var Buf: array of BYTE; AMode: TModes): integer;
var
    Cnt : integer ;
begin
    if aMode = ioREAD then
    begin
        // SubHeader
        if mBatchType = btBIT then Buf[0] := $00
        else                       Buf[0] := $01 ;
        // PC NO
        Buf[1] := mPLCNO ;
        // ACPUT Timer
        Buf[2] := BYTE(mAcpuTimer) ;
        Buf[3] := BYTE(mAcpuTimer shl 8) ;
        // Head Device No
        Buf[4] := BYTE(mDeviceBeginAddress) ;
        Buf[5] := BYTE(mDeviceBeginAddress shr 8)  ;
        Buf[6] := BYTE(mDeviceBeginAddress shr 16) ;
        Buf[7] := BYTE(mDeviceBeginAddress shr 24) ;
        // Device Name
        Buf[8] := BYTE(mDeviceName[1]) ;
        Buf[9] := BYTE(mDeviceName[0]) ;
        // Point Count
        Buf[10] := mDeviceMaxPoints ;
        // ETX
        Buf[11] := $00 ;
        Result  := 12 ;
    end
    else
    begin
        // SubHeader
        if mBatchType = btBIT then Buf[0] := $02
        else                       Buf[0] := $03 ;
        // PC NO
        Buf[1] := mPLCNO ;
        // ACPUT Timer
        Buf[2] := BYTE(mAcpuTimer) ;
        Buf[3] := BYTE(mAcpuTimer shl 8) ;
        // Head Device No
        Buf[4] := BYTE(mDeviceBeginAddress) ;
        Buf[5] := BYTE(mDeviceBeginAddress shr 8)  ;
        Buf[6] := BYTE(mDeviceBeginAddress shr 16) ;
        Buf[7] := BYTE(mDeviceBeginAddress shr 24) ;
        // Device Name
        Buf[8] := BYTE(mDeviceName[1]) ;
        Buf[9] := BYTE(mDeviceName[0]) ;
        // Point Count
        Buf[10] := mDeviceMaxPoints ;
        // ETX
        Buf[11] := $00 ;
        Result  := 12 ;
        // WriteDatas
        if mBatchType = btBIT then
        begin
            Cnt := BitPCToPLC(mBuffer, mDeviceMaxPoints) ;
        end
        else // word type
        if mDataType = dtBIT then
        begin
            Cnt := (mDeviceMaxPoints div 8)
                    + integer((mDeviceMaxPoints mod 8) > 0) ;
        end
        else
        if mDataTYpe = dtWORD then
        begin
            Cnt := WordPCToPLC(mBuffer, mDeviceMaxPoints) ;
        end
        else Exit ;

        Move(mBuffer, Buf[12], Cnt) ;
        //CopyMemory(@Buf[12], @mBuffer, Cnt) ;
        Result := Result + Cnt ;
    end ;
end;

function TPackA1E_Bin.UnPack(const Buf: array of BYTE; ACount:integer): boolean;
begin
    FillChar(mBuffer, sizeof(mBuffer), 0) ;
    FillChar(mRecvBuf, sizeof(mRecvBuf), 0) ;

    mRecvBufCnt := ACount ;
    Move(Buf, mRecvBuf, mRecvBufCnt) ;

    mErrorCode := 0 ;
    mAbNormalCode := 0 ;

    Result := false ;
    // subHeader
    case Buf[0] of
        $80, $81 : // Read Response
        begin
            mRecvSubHead := ioREAD ;
            // Complete Code
            if Buf[1] = $00 then
            begin
                mRecvCount := ACount-2 ;
                Move(Buf[2], mBuffer, mRecvCount) ;
                //CopyMemory(@mBuffer, @Buf[2], mRecvCount) ;
                // Read Datas
                if Buf[0] = $80 then BitPLCToPC(mBuffer, mRecvCount)
                else
                if mDataType = dtWORD then WordPLCToPC(mBuffer, mRecvCount) ;

                //if mDeviceMaxPoints > mRecvCount then
                //    mDeviceMaxPoints := mRecvCount ;
                
                Result := true ;
            end
            else
            begin
                mErrorCode    := Buf[1] ;
                // abNormal Code
                if mErrorCode = $5B then mAbNormalCode := Buf[2] ;
            end ;
        end ;
        $82, $83 : // Write Response
        begin
            mRecvSubHead := ioWRITE ;
            if Buf[1] = $00 then Result := true
            else
            begin
                mErrorCode    := Buf[1] ;
                if mErrorCode = $5B then mAbNormalCode := Buf[2] ;
            end ;
        end ;
    else
        mErrorCode := _SUB_HEAD_ERROR ;
    end ;
end;

end.


