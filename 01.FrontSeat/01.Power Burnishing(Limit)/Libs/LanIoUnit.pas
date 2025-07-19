{
    Ver.210213.00
    : 비정규 Pkt처리용 TIrregularPktHandler클래스 TReadIO, TWriteIO에 추가, DataIO대안으로 사용 가능

    Ver.220210.00
    : TPLCAddInfo 기반으로 변경 완료

    Ver.240909.00
    : Read/Write IO로만 사용 (DataIO는 ReadIO로 대체)

    Ver.240923.00
    : 미사용 코드 제거
}

unit LanIoUnit;
{$INCLUDE myDefine.INC}

{
  1. PLC <- [TCP, UDP]  -> PC

  READ/WRITE 함께 사용한다면(비슷한 양)
  포트를 각각 별도의 포트 번호를 할당하고
  만일의 경우를 대비해 1개 이상의 포트를 할당하도록 요구(PLC)하자.

  READ I/O 를 사용하는 포트가 끊어지면(같은 타입일때).
  내부 I/O 버퍼에서 관리대상을 모두 클리어한다.

  WRITE I/O.
  연결되면 현재상태를 다시 전송한다.
  프로그램 종료할때 연결되어 있으면 모두 클리어한 후 종료한다.
}
interface

uses
    Windows, Messages, SysUtils, Classes, MelsecPackEx, KiiMessages,
    UserSocketUnit, KiiBaseUnit,  BaseDIO, Global, PLCAddInfo;

const



    _MAX_USR_IO_COUNT = 2;
    _MAX_IO_DATA_COUNT = 10;

type

    TDioMonitorDevORD = (devNone, devREAD, devWRITE);
    TNotifyReaded = procedure(Sender: TObject; AStation: integer) of Object;
    TRecievedDatas = procedure(Sender: TObject; AType: integer) of Object;
    TIoChangeEvent = procedure(Sender: TObject; AIO: integer) of Object;


    TDataPackEvent = procedure (Pack: TPackQnA3E_Ascii) of Object ;


    PIrregularPktHandler = ^TIrregularPktHandler;
    TIrregularPktHandler = packed record
    private

        function GetUse: boolean;
        procedure SetUse(const Value: boolean);
    public
        mSendPackEvent:     TDataPackEvent;
        mRecvPackEvent:     TDataPackEvent;

        mOldDevName:        char;
        mOldRwCount:        integer;
        mOldBeginAdd:       integer;
        mOldDataType:       TDataTypes;

        mUse:               boolean;            // SendPack/RecvPackEvent를 사용할 경우


        constructor Create(SendPackEvent: TDataPackEvent; RecvPackEvent: TDataPackEvent);
        procedure SetHandler(SendPackEvent: TDataPackEvent; RecvPackEvent: TDataPackEvent);

        procedure StorePack(Pack: TPackQnA3E_Ascii);
        procedure RestorePack(Pack: TPackQnA3E_Ascii);


        property Use: boolean read GetUse write SetUse;

    end;

    TUserMonitor = class(TKiiBase)
    private
        procedure SetIRPktPeriod(const Value: integer);
    protected
        mwnd: HWND;
        mProc: integer;

        mDIO: TBaseDIO;
        mPack: TPackQnA3E_Ascii;

        mSaveTime: TDateTime;
        mTmpTime, mWriteTime, mReadedTime: double;

        mLastError: string;

        mBeginCH, mChCount: integer;

        mAddInfos:  TPLCAddInfos;

        mIRPktHandler: TIrregularPktHandler;
        mIRPktPeriod: integer;          // 비정규 패킷 전송 주기 ex> 10이라면 9회까지는 정규 1회 비정규

        mEnabled:   boolean;

        function IsYourIO(ACH: integer): boolean;
        procedure SetInit(AWnd: HWND; ATag, ABeginAddr, ABeginCH, ACount: integer; DevName: string); virtual;
    public
        constructor Create(AOwner: TComponent);  overload; override;
        constructor Create(AWnd: HWND; ATag: integer; Parent: TBaseDIO); overload;

        destructor Destroy; override;

        procedure Start;
        procedure Stop;


        function IsRun: boolean;

        property ReadTime: double read mReadedTime;
        property WriteTime: double read mWriteTime;
        property LastError: string read mLastError;
        property ChCount: integer read mChCount;

        property Enabeld: boolean read mEnabled write mEnabled;

        property IRPktHandler: TIrregularPktHandler read mIRPktHandler write mIRPktHandler;
        property IRPktPeriod: integer read mIRPktPeriod write SetIRPktPeriod;

        property AddrInfos: TPLCAddInfos read mAddInfos;
    end;


    TReadIo = class(TUserMonitor)
    private

        mRecieveEvent: TRecievedDatas;


        procedure SetReadIO;

        function SendData: boolean;
        function WorkProcess(Sender: TObject): boolean;
        procedure OnRecieveDatas(Sender: TObject; ADatas: AnsiString);

    public
        procedure IoClear;
        property OnRecievedDatas: TRecievedDatas read mRecieveEvent write mRecieveEvent;

    end;

    TWriteIo = class(TUserMonitor)
    private

        mChanged: integer;

        function SendData: boolean;
        function WorkProcess(Sender: TObject): boolean;
        procedure OnRecieveDatas(Sender: TObject; ADatas: AnsiString);

        procedure SetChanged;
    public
        constructor Create(AOwner: TComponent); override;

        function Count: integer;
    end;



    TRWIO = class

    end;


    TDioMonitor = class(TBaseDIO)           // 컨테이너
    private
        mwnd: HWND;
        mProc: integer;

        mReadIo: TReadIo;
        mWriteIo: TWriteIo;
        mDataRawIO: TBaseDIO;

        mIsReadDIO: boolean;

        function GetItemEx(Idx: TDioMonitorDevORD): TUserMonitor;
        function Reads: boolean; override;
        function GetIRDataPktHandler: PIrregularPktHandler;

    public
        constructor Create(AWnd: HWND; RAddInfos, WAddInfos: array of TPLCAddInfo);
        destructor Destroy; override;

        procedure Start;
        procedure Stop;

        function IsRun: boolean;
        function GetItem(APortType: integer): TObject;

        procedure SetIO(ACH: integer; AValue: boolean); override;
        function IsIO(ACH: integer): boolean; override;

        function  GetChTypeStr(Ch: integer; IsBracket: boolean = true): string; override;

        function  GetModelIo(Index: integer; var Value: WORD): boolean;
        function  GetModelIoAsDWord(Index: integer; var Value: DWORD): boolean;
        procedure SetModelIoAsDWord(Index: integer; Value: DWORD);

        function  GetDataIoAsWord(Idx: integer): WORD;
        procedure SetDataIOAsWord(Idx: integer; Val: WORD);

        procedure SetClearAll;



        procedure WorkProcess(Sender: TObject);

        function  GetModel(): WORD ;

        property Items[Idx: TDioMonitorDevORD]: TUserMonitor read GetItemEx;


        property IRDataPktHandler: PIrregularPktHandler read GetIRDataPktHandler;

        property DataRawIO: TBaseDIO read mDataRawIO;


    end;

    function GetDevName(ADev: TDioMonitorDevORD): string;
    function LEWordsToString(Buffer: array of WORD): AnsiString;   // Little Endian to AnsiString



var
    gLanDio: TDioMonitor;


implementation

uses
    IniFiles, myUtils, Log, Math, DataUnit, SysEnv, LangTran;

// ------------------------------------------------------------------------------
//
// ------------------------------------------------------------------------------


function GetDevName(ADev: TDioMonitorDevORD): string;
begin
    case ADev of
        devNone:
            Result := _TR('구분없음');
        devREAD:
            Result := 'PLC READ_IO';
        devWRITE:
            Result := 'PLC WRITE_IO';
    else
        Result := '';
    end;
end;

function LEWordsToString(Buffer: array of WORD): AnsiString;
var
    Val: WORD;
    i: integer;
begin
    for i := 0 to Length(Buffer) - 1 do
    begin
        Val := Buffer[i];
        if Val = 0 then
            break;
        Result := Result + AnsiChar(Byte(Val)) + Char(Byte(Val shr 8));
    end;
end;

// ------------------------------------------------------------------------------
// {TMonitor}
// ------------------------------------------------------------------------------

const
    MAX_DATA_IO_BUFFER_COUNT = 20;


constructor TDioMonitor.Create(AWnd: HWND; RAddInfos, WAddInfos: array of TPLCAddInfo);
var
    RCHCount,
    i, RCount, WCount, RBuffSize, WBuffSize: integer;
begin

    RCount := Length(RAddInfos);
    WCount := Length(WAddInfos);

    RBuffSize := 0;
    for i := 0 to RCount - 1 do
    begin
        RBuffSize := RBuffSize + RAddInfos[i].mWDLen * 2;
    end;

    WBuffSize := 0;
    for i := 0 to WCount - 1 do
    begin
        WBuffSize := WBuffSize + WAddInfos[i].mWDLen * 2;
    end;

    inherited Create(RBuffSize + WBuffSize);     // IN, OUT

    mWnd := AWnd;
    mProc := 0;

    mReadIo := TReadIo.Create(AWnd, ord(devREAD), Self);

    mWriteIo := TWriteIo.Create(AWnd, ord(devWRITE), Self);

    mDataRawIo := TBaseDIO.Create(MAX_DATA_IO_BUFFER_COUNT * 2);    // Word단위로
//    mDataRawIO.IsBigEndian := True;

    if RCount <= 0 then
        Exit;

    // Read
    RCHCount := 0;
    for i := 0 to  RCount - 1 do
    begin
        mReadIO.AddrInfos.Add(RAddInfos[i]);
        if not RAddInfos[i].mIsDataIOType then
            RCHCount := RCHCount + RAddInfos[i].mWDLen * 16;

    end;
    mReadIO.mBeginCH := RAddInfos[0].mBeginCh;
    mReadIO.mChCount := RBuffSize * 8;



    // Write
    WAddInfos[0].mBeginCh := RCHCount;
    for i := 0 to  WCount - 1 do
    begin
        mWriteIO.AddrInfos.Add(WAddInfos[i]);
    end;
    mWriteIO.mBeginCH := WAddInfos[0].mBeginCh;
    mWriteIO.mChCount := WBuffSize * 8;

end;

destructor TDioMonitor.Destroy;
begin

    if Assigned(mDataRawIO) then
        FreeAndNil(mDataRawIO);

    if Assigned(mWriteIo) then
        FreeAndNil(mWriteIo);
    if Assigned(mReadIo) then
        FreeAndNil(mReadIo);

    inherited Destroy;
end;

procedure TDioMonitor.Start;
begin
    if mProc <> 0 then
        Exit;

    mReadIo.Start;
    mWriteIo.Start;


    mProc := 1;
    gLog.Panel('Start Monitor Manager', []);
end;

procedure TDioMonitor.Stop;
begin
    if mProc = 0 then
        Exit;

    mReadIo.Stop;
    mWriteIo.Stop;


    mProc := 0;
    gLog.Panel('Stop Monitor Manager', []);
end;

function TDioMonitor.IsRun: boolean;
begin
    Result := mProc > 0;
end;


function TDioMonitor.GetChTypeStr(Ch: integer; IsBracket: boolean): string;
begin

    Result := inherited GetChTypeStr(Ch, IsBracket);

end;

function TDioMonitor.GetDataIoAsWord(Idx: integer): WORD;
begin
    if Idx < _MAX_IO_DATA_COUNT then
        Result := mDataRawIO.GetWordData(Idx * 2)
    else
        Result := 0;


end;


function TDioMonitor.GetItemEx(Idx: TDioMonitorDevORD): TUserMonitor;
begin
    case Idx of
        devREAD:
            Result := mReadIo;
        devWRITE:
            Result := mWriteIo;
    else
        Result := nil;
    end;
end;



function TDioMonitor.GetIRDataPktHandler: PIrregularPktHandler;
begin

end;

function TDioMonitor.GetItem(APortType: integer): TObject;
begin
    Result := nil;
    case APortType of
        ord(devREAD):
            Result := mReadIo;
        ord(devWRITE):
            Result := mWriteIo;
    end;
end;

function TDioMonitor.IsIO(ACH: integer): boolean;
begin
    Result := inherited IsIO(ACH);
end;

procedure TDioMonitor.SetIO(ACH: integer; AValue: boolean);
begin
{$IFDEF VIRTUALLANIO}
    inherited SetIO(ACH, AValue);
{$ELSE}

    if not Items[devRead].Enabeld and Items[devRead].IsYourIO(ACH) then
    begin
        inherited SetIO(ACH, AValue);
        Exit;
    end;


    with TWriteIO(Items[devWRITE]) do
    begin
        if IsYourIO(ACH) then
        begin
            if Tag In [ord(devWRITE)] then
            begin
                inherited SetIO(ACH, AValue);
                SetChanged;
            end;
        end;
    end;
{$ENDIF}
end;


function TDioMonitor.Reads: boolean;
begin
    WorkProcess(nil);
    Result := true;
end;



procedure TDioMonitor.WorkProcess(Sender : TObject) ;
begin
    case mProc of
        0 : Exit ;
        1 :
        begin
            if mReadIO.WorkProcess(Sender)  then
                Inc(mProc) ;
        end ;
        2 :
        begin
            if mWriteIO.WorkProcess(Sender) then
                mProc := 1;

        end ;

    else
        gLog.Panel('TMONITOR PROCESSOR ERROR(%d)', [mProc]) ;
        mProc := 1 ;
    end ;
end;


procedure TDioMonitor.SetClearAll;
begin

    Clear;
    mReadIo.Stop;
    //mDataIo.Stop;


    mWriteIo.SetChanged;
end;

procedure TDioMonitor.SetDataIOAsWord(Idx: integer; Val: WORD);
begin
    mDataRawIO.SetWordData(Idx * 2, Val);
end;

function TDioMonitor.GetModel: WORD;
begin
    Result:= mDataRawIo.GetWordData(0);
end;

function TDioMonitor.GetModelIo(Index: integer; var Value: WORD): boolean;
begin
    Value := mDataRawIo.GetWordData(Index * 2);
    Result := Value > 0;
end;

function TDioMonitor.GetModelIoAsDWord(Index: integer; var Value: DWORD): boolean;
var
    Hi, Lo: WORD;
begin
    Lo := mDataRawIo.GetWordData(Index * 2);
    Hi := mDataRawIo.GetWordData((Index + 1) * 2);

    Value := ((Hi shl 16) and $FFFF0000) or (Lo and $FFFF);
    Result := Value > 0;
end;

procedure TDioMonitor.SetModelIoAsDWord(Index: integer; Value: DWORD);
begin
    mDataRawIo.SetWordData(Index * 2, $FFFF and Value);
    mDataRawIo.SetWordData((Index + 1) * 2, $FFFF and  (Value shr 16));
end;

// ------------------------------------------------------------------------------
// { TUserMonitor }
// ------------------------------------------------------------------------------
constructor TUserMonitor.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);
    mLastError := '';
    mTmpTime := 0;
    mWriteTime := 0;
    mReadedTime := 0;

    mBeginCH := 0;
    mChCount := 0;

    mAddInfos := TPLCAddInfos.Create(true);

    mPack := TPackQnA3E_Ascii.Create;
    with mPack do
    begin
        PLCNo := $FF;
        AcpuTimer := $08;
        DataType  := dtBIT ;
        BatchType := btWORD;
    end;

    mEnabled := true;
end;

constructor TUserMonitor.Create(AWnd: HWND; ATag: integer; Parent: TBaseDIO);
begin
    Create(nil);

    mDIO := Parent;

    mWnd := AWnd;
    Tag := ATag;

    mEnabled := true;
end;



destructor TUserMonitor.Destroy;
begin
    FreeAndNil(mAddInfos);
    FreeAndNil(mPack);
    inherited Destroy;
end;

procedure TUserMonitor.SetInit(AWnd: HWND; ATag, ABeginAddr, ABeginCH, ACount: integer; DevName: string);
begin

    mwnd := AWnd;
    Tag := ATag;

    mBeginCH := ABeginCH;
    mChCount := ACount;
    // -------------------------------
    // PLC 주고받은 주소 세팅.
    // READ / WRITE 용도별로 세팅할것.
    // 데이터는 비트만 하도록 한다.
    // 코드의 워드데이터는 확인못함.
    // 비트데이타는 비트,워드일괄 읽기/쓰기 모두 확인함.
    // -------------------------------

    if not Assigned(mPack) then
        mPack := TPackQnA3E_Ascii.Create;

    with mPack do
    begin
        PLCNo := $FF;
        AcpuTimer := $08;
        DataType  := dtBIT ;
        DeviceName := DevName[1];
        BatchType := btWORD;
        RwCount := ACount;
        BeginAddress := ABeginAddr;
    end;

    mAddInfos.Add(mPack.DataType, DevName[1], ABeginAddr, ACount div 16, ATag);

    mIRPktHandler.StorePack(mPack);
end;

procedure TUserMonitor.SetIRPktPeriod(const Value: integer);
begin
    if Value <= 1 then
        mIRPktPeriod := 2
    else
        mIRPktPeriod := Value;
end;

procedure TUserMonitor.Start;
begin
    if mProc = 0 then
    begin
        mProc := 1;
        gLog.Panel('%s START', [GetDevName(TDioMonitorDevORD(Tag))]);
    end;
end;

procedure TUserMonitor.Stop;
begin
    if mProc <> 0 then
    begin
        mProc := 0;
        gLog.Panel('%s STOP', [GetDevName(TDioMonitorDevORD(Tag))]);
    end;
end;

function TUserMonitor.IsRun: boolean;
begin
    Result := mProc > 0;
end;

function TUserMonitor.IsYourIO(ACH: integer): boolean;
begin
    // 내부적으로만 사용하는 I/O 때문에 다음과 같이
    Result := (mBeginCH <= ACH) and ((mBeginCH + mChCount) > ACH);
end;

// ------------------------------------------------------------------------------
// { TReadIo }
// ------------------------------------------------------------------------------


procedure InitPack(PlcAddInfo: PPlcAddInfo; Pack: TPackQnA3E_Ascii);
begin
    Pack.DeviceName := PlcAddInfo.mDevName;
    Pack.BeginAddress := PlcAddInfo.mAdd;
    if Pack.DataType = dtBIT then
        Pack.RwCount := PlcAddInfo.mWDLen * 16
    else
        Pack.RwCount := PlcAddInfo.mWDLen;
end;

function TReadIo.SendData: boolean;
var
    Cnt, nPort: integer;
    Buf: TSocketData;
    nP: string;
    sTm: AnsiString;
begin
    Result := false;
    nPort := gSocketMan.IsIdlePort(Tag, nP);
    if not Assigned(mPack) or (nPort <= 0) then
        Exit;

    mPack.Initial;


    if mIRPktHandler.Use then                  // 비정규 패킷 송신
    begin
        mIRPktHandler.mSendPackEvent(mPack);
    end
    else
    begin
        InitPack(mAddInfos.CurItem, mPack);
    end;


    Cnt := mPack.Pack(sTm, ioREAD);
    FillChar(Buf, sizeof(TSocketData), 0);
    with Buf do
    begin
        rCode := Handle;
        rNotify := OnRecieveDatas;
        rDatas := sTm;
        rRepeat := false;
        rNotReturn := false;
    end;
    Result := gSocketMan.Add(nP, nPort, Buf) > 0;

    mWriteTime := GetAccurateTime - mTmpTime;
    mTmpTime := GetAccurateTime;
end;

type
    TUsrWord = packed record
        rHi, rLo: BYTE;
    end;

procedure TReadIo.SetReadIO;
var
    i, x, PortIDx, Cnt, WordLen : integer;
    DestCh, Data : WORD;
    Tmp: BYTE;
    DIO: TBaseDIO;
begin

{$IFDEF VIRTUALLANIO}
    Exit;
{$ENDIF}

    Cnt := 0;
    PortIdx := mAddInfos.CurItem.mBeginCh;
    WordLen := mAddInfos.CurItem.mWDLen;

    if mAddInfos.CurItem.mIsDataIOType then
    begin
        DIO := TDioMonitor(mDIO).DataRawIO;
        //DIO.IsBigEndian := True;
        for i := 0 to WordLen - 1 do
        begin
            Data := mPack.GetWordValue(mPack.BeginAddress + i);
            DIO.SetDataAsWord(i, Data);
        end;
        //DIO.IsBigEndian := False;
    end
    else
    begin
        PortIdx := mAddInfos.CurItem.mBeginCh;

        for i := 0 to WordLen - 1 do
        begin
            DestCh := mPack.GetWordValue(mPack.BeginAddress + i);
            for x := 0 to 1 do
            begin
                if x = 0 then
                    Tmp := BYTE(DestCh)
                else
                    Tmp := BYTE(DestCh shr 8);

                if mDIO.GetBuffer(PortIDx div 8) <> Tmp then
                begin
                    mDIO.SetBuffer(PortIDx div 8, Tmp);
                    Inc(Cnt);
                end;
                Inc(PortIDx, 8);
            end;
            if PortIDx >= (PortIDx + mChCount) then
                Break;
        end;

    end;


    mAddInfos.Next;

    if Cnt <= 0 then
        Exit;
    if Assigned(mRecieveEvent) then
        OnRecievedDatas(Self, Tag);
end;

procedure TReadIo.OnRecieveDatas(Sender: TObject; ADatas: AnsiString);
var
    sTm: string;
begin
    if not Assigned(mPack) then
    begin
        if mProc = 3 then
            mProc := 4;
        Exit;
    end;

    if ADatas = _NOTIFY_CLOSE then
    begin
        if mProc = 3 then
            mProc := 4;
    end
    else if mPack.UnPack(ADatas) then
    begin
        mSaveTime := Now;

        if mIRPktHandler.Use then                  // 비정규 패킷 처리
        begin
            mIRPktHandler.mRecvPackEvent(mPack);   // 외부 핸들러에게 처리 맡김
            mIRPktHandler.Use := false;
            mIRPktHandler.RestorePack(mPack);      // 원래 하던 일 복원

        end
        else
        begin
            try
                SetReadIO;
            except
                On E: Exception do
                begin
                    gLog.ToFiles('%s (1002)', [E.Message]);
                end;
            end;
        end;
        if mProc = 3 then
            mProc := 4;
        mReadedTime := GetAccurateTime - mTmpTime;
    end
    else
    begin
        if mProc = 3 then
            mProc := 4;
        sTm := GetErrorToTxt(mPack.ErrorCode, mPack.AbNormalCode);
        if sTm <> mLastError then
        begin
            mLastError := sTm;
            SendToForm(mwnd, SYS_PLC_ERROR, Tag);
        end;
        //gLog.ToFiles('READ IO 수신데이터(ERROR): %s-', [ADatas, sTm]) ;
    end;
end;

procedure TReadIo.IoClear;
var
    i: integer;
begin
    for i := (mBeginCH div 8) to ((mBeginCH div 8) + (mChCount div 8)) - 1 do
    begin
        if mDIO.Buffer[i] > 0 then
        begin

{$IFNDEF VIRTUALLANIO}
            mDIO.Clear;
            gLog.ToFiles('READ IO : 포트가 끊어졌거나 열여 있는 포트가 없음 IO Clear', []);
{$ENDIF}
            Exit;
        end;
    end;
end;

var
    gIRPktCount: integer;

function TReadIo.WorkProcess(Sender: TObject): boolean;
var
    sTm: string;
begin
    if not mEnabled  then Exit(true);

    case mProc of
        0:
            ;
        1: // 포트오픈체크 및 전송데이터 중복확인
            begin
                if gSocketMan.IsIdlePort(Tag, sTm) > 0 then
                    Inc(mProc)
                else
                    mProc := 4;
            end;
        2: // 데이터 전송
            begin
                if SendData then
                    mProc := 3
                else
                    mProc := 4;
            end;
        3:
            ; // 수신대기
        4: //
            begin
                if mIRPktPeriod > 0 then			// 비정규 패킷 주기에 따라 활성화
                begin
                    gIRPktCount := gIRPktCount mod mIRPktPeriod;
                    if gIRPktCount = 0 then
                    begin
                        mIRPktHandler.Use := true;
                    end;
                    Inc(gIRPktCount);
                end;


                mProc := 1;
                Exit(true);
            end
    else
            gLog.Panel('%s PROCESS ERROR %d', [GetDevName(TDioMonitorDevORD(Tag)), mProc]);
            mProc := 1;
    end;

    Result := false;
end;
//------------------------------------------------------------------------------
{ TWriteIo }
//------------------------------------------------------------------------------

constructor TWriteIo.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);
    mChanged := 0;
end;

procedure TWriteIo.OnRecieveDatas(Sender: TObject; ADatas: AnsiString);
var
    sTm:  string;
begin
    if not Assigned(mPack) then
    begin
        if mProc = 3 then
            mProc := 4;
        Exit;
    end;

    if ADatas = _NOTIFY_CLOSE then
    begin
        if mProc = 3 then
            mProc := 4;
    end
    else if mPack.UnPack(ADatas) then
    begin
        mSaveTime := Now;

        if mIRPktHandler.Use then            // 비정규 패킷 처리중이면
        begin
            mIRPktHandler.mRecvPackEvent(mPack);   // 외부 핸들러에게 처리 맡김
            mIRPktHandler.Use := false;
            mIRPktHandler.RestorePack(mPack);      // 원래 하던 일 복원
        end
        else
        begin
            mAddInfos.Next;
        end;

        if mProc = 3 then
            mProc := 4;
        mReadedTime := GetAccurateTime - mTmpTime;
    end
    else
    begin
        if mProc = 3 then
            mProc := 4;
        sTm := GetErrorToTxt(mPack.ErrorCode, mPack.AbNormalCode);
        if sTm <> mLastError then
        begin
            mLastError := sTm;
            SendToForm(mwnd, SYS_PLC_ERROR, Tag);
        end;
        gLog.ToFiles('WRITE IO 수신데이터(ERROR): %s', [ADatas]);
    end;
end;

function TWriteIo.WorkProcess(Sender: TObject): boolean;
begin

    case mProc of
        0:
            ;
        1: // 포트오픈체크 및 전송데이터 중복확인
            begin
                if (mChanged > 0) and (gSocketMan.IsOpenedPort > 0) and (gSocketMan.IsExists(Handle) = 0) then
                begin
                    Inc(mProc);
                end
                else
                    Exit(true);
            end;
        2: // 데이터 전송
            begin
                if SendData then
                    mProc := 3
                else
                    mProc := 4;
            end;
        3:
            ; // 수신대기
        4: //
            begin
                mProc := 1;
                Exit(true);
            end;
    else
        gLog.Panel('%s PROCESS ERROR %d', [GetDevName(TDioMonitorDevORD(Tag)), mProc]);
        mProc := 1;
    end;

    Result := false;
end;

function TWriteIo.SendData: boolean;
var
    i, Cnt, nPort: integer;
    nP: string;
    sTm: AnsiString;
    Buf: TSocketData;

begin
    Result := false;
    nPort := gSocketMan.IsIdlePort(Tag, nP);
    if not Assigned(mPack) or (nPort <= 0) then
        Exit;

    if mIRPktHandler.Use then                  // 비정규 패킷 송신
    begin
        mPack.Initial ;
        mIRPktHandler.mSendPackEvent(mPack);
        Cnt := mPack.Pack(sTm, ioWRITE);
    end
    else
    begin

        mPack.Initial;
        InitPack(mAddInfos.CurItem, mPack);
        for i := 0 to mPack.RwCount - 1 do
        begin
            mPack.SetBitValue(mPack.BeginAddress + i, mDIO.GetIO(mAddInfos.CurItem.mBeginCH + i));
        end;
        Cnt := mPack.Pack(sTm, ioWRITE);
    end;

    FillChar(Buf, sizeof(TSocketData), 0);
    with Buf do
    begin
        rCode := Handle;
        rNotify := OnRecieveDatas;
        rDatas := sTm;
        // StrLCopy(rDatas, PChar(sTm), Cnt) ;
        // rDatas[Cnt] := #0 ;
        rRepeat := false;
    end;

    Result := gSocketMan.Add(nP, nPort, Buf) > 0;
    // if Result and (mChanged > 0) then Dec(mChanged) ;

    mWriteTime := GetAccurateTime - mTmpTime;
    mTmpTime := GetAccurateTime;

end;

procedure TWriteIo.SetChanged;
begin
    mChanged := 1;
    // Inc(mChanged) ;
    // if mChanged > 10 then mChanged := 10 ;
end;

function TWriteIo.Count: integer;
var
    nPort: integer;
    nIP: string;
begin
    Result := 0;
    nPort := gSocketMan.IsOpenPort(Tag, nIP);
    if (nPort <= 0) or (nIP = '') then
        Exit;

    Result := mChanged;
end;

// ------------------------------------------------------------------------------



{ TIrregularPktHandler }

constructor TIrregularPktHandler.Create(SendPackEvent: TDataPackEvent; RecvPackEvent: TDataPackEvent);
begin
    SetHandler(SendPackEvent, RecvPackEvent);
end;


function TIrregularPktHandler.GetUse: boolean;
begin
      Result := mUse and Assigned(mSendPackEvent) and Assigned(mRecvPackEvent);
end;


procedure TIrregularPktHandler.StorePack(Pack: TPackQnA3E_Ascii);
begin
    mOldDevName := Pack.DeviceName;
    mOldBeginAdd := Pack.BeginAddress;
    mOldRwCount := Pack.RwCount;
    mOldDataType := Pack.DataType;
end;

procedure TIrregularPktHandler.RestorePack(Pack: TPackQnA3E_Ascii);
begin
    Pack.Initial;
    Pack.DeviceName := mOldDevName;
    Pack.BeginAddress := mOldBeginAdd;
    Pack.RwCount := mOldRwCount;
    Pack.DataType := mOldDataType;
end;

procedure TIrregularPktHandler.SetHandler(SendPackEvent: TDataPackEvent; RecvPackEvent: TDataPackEvent);
begin
    mSendPackEvent := SendPackEvent;
    mRecvPackEvent := RecvPackEvent;
end;

procedure TIrregularPktHandler.SetUse(const Value: boolean);
begin
    mUse := Value;

end;

end.


