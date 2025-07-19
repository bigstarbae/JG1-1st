{
  Ver. 20200826.00
  Ver. 20220124.00: ResetDev함수 추가 및 Execute내 Read처리에 적용
  Ver. 20240304.00: SOEM 추가 Core 분할
  Ver. 20240911.00: TECAO 개선
}
unit EtherCatUnit;
{$I myDefine.inc}

interface

uses
    Windows, SysUtils, Variants, Classes, Generics.Collections, BaseDAQ, BaseDIO,
    BaseAD, BaseAO, BaseCounter, TLR_TYPES, TLR_RESULTS, STDINT, RCX_USER,
    RCX_PUBLIC, RCX_ERROR, CIFXUSER, CIFXERRORS, ETHERCATMASTER_PUBLIC,
    TimeChecker, Log;

const
    CIFX_COMM_TIME_OUT = 2000;
    CIFX_CH_RESET_TIME_OUT = 5000;
    CIFX_DEV_RESET_TIME_OUT = 5000;
    _RESD_BUFF_SIZE = 200;
    _BOARD_NAME = 'CIFx0';
    TAG_TLR = 0;
    TAG_SOEM = 1;

type
    TECManager = class;

    TECStatus = (ecsStart, ecsRun, ecsStop, ecsError, ecsRetry, ecsErrRetry, ecsModuleErr, ecsNone);

    TNotifyECStatus = procedure(ECManager: TECManager; Status: TECStatus);

    TECModule = packed record
        mIdx,                               // Offset
        mCount: integer;                   // Ch Count or Byte Len이 될수 있음 ex> AD인경우 TECAD.mChSize * mCount가 읽을 갯수

        constructor Create(Idx, ChCount: integer);
    end;

    TEtherCatThread = class(TThread)
    protected
        mECMan: TECManager;
        mState: byte;       // atomic 연산 감안
        procedure Execute; override;
    public
        constructor Create();
        destructor Destroy; override;
    end;

    PECManager = ^TECManager;

    TECRRange = packed record
    private
        mAreaNo, mOffset: cardinal;
        mLen: integer;

    public
        constructor Create(Offset: cardinal; Len: integer); overload;
        constructor Create(AreaNo, Offset: cardinal; Len: integer); overload;
        property Len: Integer read mLen write mLen;
        property Offset: Cardinal read mOffset write mOffset;
    end;

    TBaseECCore = class
    protected
        mTag: Integer;
        mECRRanges: array of TECRRange;
        mECRRangeCount: integer;

        mRInrBuffer: array of byte;
        mRBuffer: array of byte;
        mMOKOffsets: array of byte;

        mRetryCnt: Integer;
        mRetryTC: TTimeChecker;

        mItems: TDAQList;

        mErrModuleOffset: integer;

    public
        constructor Create;
        destructor Destroy; override;

        function IsValid(Status: Cardinal): boolean; virtual;
        function GetErrStr: string; virtual;
        function GetCoreName: string;

        function Open: boolean; virtual;
        function Close: boolean; virtual;
        function IsOpen: boolean; virtual;
        function Reopen(IsDriverClose: boolean = false): boolean; virtual;
        function Resetch(Timeout: integer = -1): boolean; virtual;
        function ResetDev(Timeout: integer = -1): boolean; virtual;
        function Reads(ThreadState: PByte): integer; virtual;
        function ReadBack(Index: integer; const WBuffer: Pointer; Len: integer): boolean; virtual;
        function Write(Index: integer; WData: byte): boolean; virtual;
        function Writes(Index: integer; const WBuffer: Pointer; Len: integer): boolean; virtual;
        function Recovery(var ECStatus: TECStatus): boolean; virtual;

        property ErrModuleOffset: integer read mErrModuleOffset;
        property Tag: integer read mTag;
        property Item: TDAQList read mItems write mItems;
        property RetryCnt: Integer read mRetryCnt;
        property RetryTC: TTimeChecker read mRetryTC;

    end;

    TECTLRCore = class(TBaseECCore)
    private
        mStatus: TLR_RESULT;
        mhDriver: CIFXHANDLE;
        mhChannel: TLR_HANDLE;

    protected
        function IsValid(Status: Cardinal): boolean; override;

        function GetErrStr: string; override;

        function Open: boolean; override;
        function Close: boolean; override;
        function IsOpen: boolean; override;
        function Reopen(IsDriverClose: boolean = false): boolean; override;

        function Resetch(Timeout: integer = CIFX_CH_RESET_TIME_OUT): boolean; override;
        function ResetDev(Timeout: integer = CIFX_DEV_RESET_TIME_OUT): boolean; override;

        function Reads(ThreadState: PByte): integer; override;
        function ReadBack(Index: integer; const WBuffer: Pointer; Len: integer): boolean; override;
        function Write(Index: integer; WData: byte): boolean; override;
        function Writes(Index: integer; const WBuffer: Pointer; Len: integer): boolean; override;
    public
        constructor Create;
        destructor Destroy; override;
    end;

    TECManager = class(TBaseDAQ)
    private
        mCore: TBaseECCore;
        mOnStatus: TNotifyECStatus;
        mECStatus: TECStatus;

        mETCThread: TEtherCatThread;
        mDelay: Boolean;

        class var
            mInstance: TECManager;

        function IsValid(Status: Cardinal): boolean; overload;

        function GetErrStr: string;

        procedure SetBufferLen(BufferLen: integer);
        function GetBufferLen: integer;

        procedure CreateInstance;

        procedure NotifyECStatus(Status: TECStatus);

        procedure SetCore(Core: TBaseECCore);

    public
        class procedure Create;
        class procedure Free;
        class function GetInstance: TECManager;

        procedure FreeInstance;

        function GetCoreName: string;

        function Open: boolean;
        function Close: boolean;
        function IsOpen: boolean;
        function Reopen(IsDriverClose: boolean = false): boolean;

        function ResetCh(Timeout: integer = -1): boolean;
        function ResetDev(Timeout: integer = -1): boolean;

        procedure Start;
        procedure Stop;
        function IsRun: boolean;

        procedure Add(Item: TBaseDAQ; OwnerFree: boolean = false);
        procedure Remove(Item: TBaseDAQ);
        procedure Clear;

        procedure SetReadRanges(Ranges: array of TECRRange);

        procedure SetModuleOKOffsets(OKOffsets: array of integer);

        function Reads: boolean; override;

        function ReadBack(Index: integer; const WBuffer: Pointer; Len: integer): boolean;
        function Write(Index: integer; WData: byte): boolean;
        function Writes(Index: integer; const WBuffer: Pointer; Len: integer): boolean;
//---
        procedure Reads4Test;
        procedure SelfTest;

        procedure GetBytes(Idx, Len: integer; var Buffer: array of byte);
        function GetWord(Idx: integer): WORD;
        function GetVal(Idx: integer): SmallInt;
        function GetVal32(Idx: integer): Integer;


        // SIMUL
        function StartByOffset(Offset: integer): boolean;
        function StopByOffset(Offset: integer): boolean;
        procedure StartOrStop(IsStart: boolean; Offsets: array of integer);

        property ErrStr: string read GetErrStr;
        property BufferLen: integer read GetBufferLen write SetBufferLen;

        property OnStatus: TNotifyECStatus read mOnStatus write mOnStatus;
        property ECStatus: TECStatus read mECStatus;

        property Core: TBaseECCore read mCore write SetCore;

        property Delay: Boolean read mDelay write mDelay;
    end;

    TECAD = class(TBaseAD)
    private
        mChSize: integer;
        mRModules: array of TECModule;
        mRModCount, mMaxRange: integer;

        function InternalRead: boolean; override;
        procedure SetResolution(Val: integer); override;

    public
        constructor Create(RModules: array of TECModule; CHSize: integer = 2);
        destructor Destroy; override;

        function IsOpen: boolean; override;
    end;

    TECAO = class(TBaseAO)
    private
        mAOStartCh, mChSize: integer;
        mWModules: array of TECModule;

        mWModCount, mMaxRange: integer;

        function InternalRead: boolean; override;
        procedure SetResolution(Val: integer); override;
    public
        constructor Create(WModules: array of TECModule; StartCH: integer; CHSize: integer = 2);
        destructor Destroy; override;

        procedure SetDigitVolt(ACH, ADigit: WORD);
        procedure SetVolt(ACH: integer; AValue: double); override;

        function IsOpen: boolean; override;
        property MaxModule: integer read mWModCount;
    end;

    TECPWM = class(TBaseAO)
    private
        mWModule: TECModule;
        mWModCount, mMaxRange: integer;

        function InternalRead: boolean; override;
    public
        constructor Create(WModule: TECModule);
        destructor Destroy; override;

        procedure SetDutyRatio(DutyRatio: Double);

        function IsOpen: boolean; override;
    end;


    TECCT = class(TBaseCounter)
    protected
        mSrcIdxs, mResetIdxs: array of integer;

        mDatas: array of Int64;

        function InternalRead(Ch: integer): Int64;
    public
        constructor Create(SrcIdxs, ResetIdxs: array of integer);
        destructor Destroy; override;

        function GetValue(Ch: integer): double; override;
        function GetPulse(Ch: integer): Int64; override;
        function Reads: boolean; override;

        function Reset(Ch: integer): boolean; override;

        function IsOverflow(Ch: integer): boolean; override;

        procedure Clear(); override;
    end;

    AT_TYPES = (ATTemp, ATResistor);

    TECAT = class(TBaseAD)              // Analog Temperature & Resist
    protected
        mSrcIdxs: array of integer;
        mType: array of AT_TYPES;
        mDatas: array of double;

        function InternalRead(Ch: integer): double;
    public
        constructor Create(SrcIdxs: array of integer);
        destructor Destroy; override;

        function Reads: boolean; override;

        function IsOverflow(Ch: integer): boolean;
    end;

implementation

uses
    Math, myUtils, Range, MMSystem;

{ TECManager }

class procedure TECManager.Create;
begin
    raise ENoConstructException.Create('싱글톤 클래스, GetInstance()함수를 사용하세요!');
end;

class procedure TECManager.Free;
begin
    raise Exception.Create('싱글톤 클래스입니다');
end;

class function TECManager.GetInstance: TECManager;
begin
    if mInstance = nil then
    begin
        mInstance := inherited Create;
        mInstance.CreateInstance;

    end;

    Result := mInstance;
end;

function FreeInstanceWpr: boolean;
begin
    TECManager.GetInstance.FreeInstance;
    Result := true;
end;

procedure TECManager.CreateInstance;
begin
    if mInstance.mCore = nil then
        mInstance.SetCore(TECTLRCore.Create);

    BufferLen := _RESD_BUFF_SIZE;

    mECStatus := ecsStop;
end;

procedure TECManager.FreeInstance;
begin
    Stop;

    if Assigned(mETCThread) and not mETCThread.ExternalThread then
        mETCThread.Terminate;

    Close;

    if mOwnerFree then
        Clear;

    if Assigned(mCore) then
        FreeAndNil(mCore);

    inherited Free;

    mInstance := nil;
end;

procedure TECManager.Add(Item: TBaseDAQ; OwnerFree: boolean);
begin
    if OwnerFree then
    begin
        mOwnerFree := true;         // 자식들 자동 삭제 하나라도 있으면 자동 삭제 조건 살림.
    end;

    Item.OwnerFree := OwnerFree;
    mCore.Item.Add(Item);
end;

procedure TECManager.Remove(Item: TBaseDAQ);
var
    i: integer;
begin
    for i := 0 to mCore.Item.Count - 1 do
    begin
        if mCore.Item[i] = Item then
        begin
            mCore.Item.Delete(i);
            Break;
        end;
    end;
end;

function TECManager.Reopen(IsDriverClose: boolean): boolean;
begin
    Result := mCore.Reopen(IsDriverClose);
end;

function TECManager.ResetCh(Timeout: integer): boolean;
begin
    if Timeout = -1 then
        Result := mCore.Resetch
    else
        Result := mCore.Resetch(Timeout);
end;

function TECManager.ResetDev(Timeout: integer): boolean;
begin
    if Timeout = -1 then
        Result := mCore.ResetDev
    else
        Result := mCore.ResetDev(Timeout);
end;

procedure TECManager.SelfTest;
var
    i: integer;
begin
    for i := 0 to mCore.Item.Count - 1 do
    begin
        gLog.Panel('Ethercat: Item: %s', [mCore.Item[i].Name]);
    end;
end;

procedure TECManager.Clear;
var
    i: Integer;
begin
    for i := 0 to mCore.Item.Count - 1 do
    begin
        if Assigned(mCore.Item[i]) then
        begin
            if mCore.Item[i].OwnerFree then
                mCore.Item[i].Free;
        end;
    end;

    mCore.Item.Clear;
end;

function TECManager.Close: boolean;
begin
    Result := mCore.Close;
end;

function TECManager.GetBufferLen: integer;
begin
    Result := Length(mCore.mRBuffer);
end;

procedure TECManager.GetBytes(Idx, Len: integer; var Buffer: array of byte);
begin
    Move(mCore.mRBuffer[Idx], Buffer, Len);
end;

function TECManager.GetCoreName: string;
begin
    Result := mCore.GetCoreName;
end;

function TECManager.GetErrStr: string;
begin
    Result := mCore.GetErrStr;
end;

function TECManager.GetVal(Idx: integer): SmallInt;
begin
    Move(mCore.mRBuffer[Idx], Result, 2);
     //-- LS SWAP , BNR NO SWAP
end;

function TECManager.GetVal32(Idx: integer): Integer;
var
    DWTemp: Integer;
begin
//    EnterCriticalSection;  // 32bit 연산이라 Atomic 처리가 안될 경우 동기화 처리 필요, TRtlCriticalSection 간편히API로 사용할것
    CopyMemory(@DWTemp, @mCore.mRBuffer[Idx], 4);
//    LeaveCriticalSection;

    Result := DWTemp;
end;

function TECManager.GetWord(Idx: integer): WORD;
begin
    CopyMemory(@Result, @mCore.mRBuffer[Idx], 2);
end;

function TECManager.IsOpen: boolean;
begin
    Result := mCore.IsOpen;
end;

function TECManager.IsRun: boolean;
begin
    Result := mECStatus = ecsRun;
end;

function TECManager.IsValid(Status: Cardinal): boolean;
begin
    Result := mCore.IsValid(Status);
end;

function TECManager.Open: boolean;
begin
    Result := mCore.Open;
end;

function TECManager.ReadBack(Index: integer; const WBuffer: Pointer; Len: integer): boolean;
begin
    Result := mCore.ReadBack(Index, WBuffer, Len);
end;

function TECManager.Reads: boolean;
begin
    case mCore.Reads(@mETCThread.mState) of
        -1:
            begin
                NotifyECStatus(ecsModuleErr);
                Result := False;
            end;
        0:
            Result := False;
        1:
            Result := True;
    end;
end;

procedure TECManager.Reads4Test;
var
    i: integer;
begin
    for i := 0 to mCore.Item.Count - 1 do
    begin
        mCore.Item[i].Reads;
        //gLog.Panel('Ethercat: %s Read ..', [Item[i].Name]);
    end;
end;

procedure TECManager.SetBufferLen(BufferLen: integer);
begin
    self.SetReadRanges([TECRRange.Create(0, 0, BufferLen)]);
end;

procedure TECManager.SetCore(Core: TBaseECCore);
var
    BufferLen: Integer;
begin
    BufferLen := 0;

    if Assigned(mCore) then
    begin
        BufferLen := GetBufferLen();
        FreeAndNil(mCore);
    end;

    if not Assigned(mCore) then
    begin
        mCore := Core;
        SetBufferLen(BufferLen);
    end;
end;

procedure TECManager.SetModuleOKOffsets(OKOffsets: array of integer);
var
    i: Integer;
begin
    SetLength(mCore.mMOKOffsets, Length(OKOffsets));

    for i := 0 to Length(mCore.mMOKOffsets) - 1 do
    begin
        mCore.mMOKOffsets[i] := OKOffsets[i];
    end;
end;

procedure TECManager.SetReadRanges(Ranges: array of TECRRange);
var
    i, SuLen, MaxLen: integer;
begin
    MaxLen := -999;
    SuLen := 0;

    if Length(Ranges) <= mCore.mECRRangeCount then
    begin
        mCore.mECRRangeCount := Length(Ranges);
    end
    else
    begin
        mCore.mECRRanges := nil;
        mCore.mECRRangeCount := Length(Ranges);
        SetLength(mCore.mECRRanges, mCore.mECRRangeCount);
    end;

    for i := 0 to mCore.mECRRangeCount - 1 do
    begin
        mCore.mECRRanges[i] := Ranges[i];

        SuLen := SuLen + Ranges[i].Len;
        if MaxLen < Ranges[i].Len then
            MaxLen := Ranges[i].Len;
    end;

    if Length(mCore.mRBuffer) < SuLen then
    begin
        mCore.mRBuffer := nil;
        SetLength(mCore.mRBuffer, SuLen);
    end;

    if Length(mCore.mRInrBuffer) < MaxLen then
    begin
        mCore.mRInrBuffer := nil;
        SetLength(mCore.mRInrBuffer, MaxLen);
    end;
end;

procedure TECManager.NotifyECStatus(Status: TECStatus);
begin
    if mECStatus = Status then
        Exit;

    mECStatus := Status;
    if Assigned(mOnStatus) then
        mOnStatus(self, Status);

end;

procedure TECManager.Start;
begin
    if not Assigned(mETCThread) and TECManager.GetInstance.IsOpen then
    begin
        mETCThread := TEtherCatThread.Create;
    end
    else
    begin
        Exit;
    end;

    mETCThread.mState := 1;
    mETCThread.Resume;
    NotifyECStatus(ecsStart);
end;

function TECManager.StartByOffset(Offset: integer): boolean;
begin
{$IFDEF VIRTUALIO}
    Result := xStartByOffset(Offset);
{$ELSE}
    Result := true;
{$ENDIF}
end;

function TECManager.StopByOffset(Offset: integer): boolean;
begin
{$IFDEF VIRTUALIO}
    Result := xStopByOffset(Offset);
{$ELSE}
    Result := true;
{$ENDIF}
end;

procedure TECManager.StartOrStop(IsStart: boolean; Offsets: array of integer);
var
    i: Integer;
begin
    for i := 0 to Length(Offsets) - 1 do
    begin
        if IsStart then
            StartByOffset(Offsets[i])
        else
            StopByOffset(Offsets[i])
    end;
end;

procedure TECManager.Stop;
begin
    if Assigned(mETCThread) then
    begin
        mETCThread.mState := 0;
        NotifyECStatus(ecsStop);
    end;
end;

function TECManager.Writes(Index: integer; const WBuffer: Pointer; Len: integer): boolean;
begin
    mCore.Writes(Index, WBuffer, Len);
end;

function TECManager.Write(index: integer; WData: byte): boolean;
begin
    Result := mCore.Write(index, WData);
end;

{ TEtherCatThread }

constructor TEtherCatThread.Create();
begin
    inherited Create(true);

    mECMan := TECManager.GetInstance;
    FreeOnTerminate := true;

    Priority := tpHighest;
end;

destructor TEtherCatThread.Destroy;
begin

    inherited;
end;

const
    _EC_RETRY_COUNT = 5;

procedure MicroSleep(Microseconds: Int64);
var
    Frequency, StartCount, EndCount, NowCount: Int64;
    TargetTicks: Int64;
begin
    QueryPerformanceFrequency(Frequency);
    QueryPerformanceCounter(StartCount);

    TargetTicks := (Frequency * Microseconds) div 1000000;
    EndCount := StartCount + TargetTicks;

  // 1ms 미만 남은 경우 루프를 통해 기다림
    while QueryPerformanceCounter(NowCount) and (EndCount - NowCount > Frequency div 1000) do
    begin
        Sleep(1);  // 1ms 단위로 잠시 대기
    end;

  // 루프를 통해 나머지 시간 대기
    while QueryPerformanceCounter(NowCount) and (NowCount < EndCount) do
        ;
end;

procedure TEtherCatThread.Execute;
var
    RetryCnt, StartTime, LoopCount: int64;
    TC: TTimeChecker;
    ECStatus: TECStatus;
begin
    timeBeginPeriod(1);
    RetryCnt := 0;
    StartTime := int64(GetTickCount64);
    LoopCount := 0;
    ECStatus := ecsNone;
    while not Terminated do
    begin
        case mState of
            0:
                ;

            1:
                if mECMan.Reads then
                begin
                    if mECMan.Core.Tag = TAG_SOEM then
                        MicroSleep(300);

                    if mECMan.mECStatus <> ecsRun then
                    begin
                        RetryCnt := 0;
                        mECMan.NotifyECStatus(ecsRun);
                    end;
                end
                else
                begin
                    // mStatus에서 에러 종류를 식별하여 무시하고 진행할지 판단 코드 검토
                    if mECMan.Core.Tag = TAG_TLR then
                    begin
                        Inc(RetryCnt);
                        if RetryCnt < _EC_RETRY_COUNT then                    // N회는 딜레이 후 조치없이 재시도
                        begin
                            mECMan.NotifyECStatus(ecsRetry);
                            TC.Start(1500);
                        end
                        else if RetryCnt < _EC_RETRY_COUNT + 1 then           // 마지막(N + 1) 재시도는 Reset
                        begin
                            mECMan.NotifyECStatus(ecsRetry);
                            mECMan.ResetCh(CIFX_CH_RESET_TIME_OUT);     // 블록킹된다면 상태를 변경안함 검토
                            TC.Start(7000);                             // 참조: 장치관리자 cifX Test App내 Reset의 디폴트 TO는 10초

                        end
                        else if RetryCnt = _EC_RETRY_COUNT + 1 then
                        begin
                            mECMan.NotifyECStatus(ecsError);            // N + 2회 이상일시 Error 통보
                            TC.Start(1500);
                        end
                        else
                        begin
                            mECMan.NotifyECStatus(ecsRetry);            // 에러 통보후 주기적  Reads 진행
                            TC.Start(5000);
                        end;

                        if RetryCnt >= 8223372036854775807 then
                            RetryCnt := 0;

                        Inc(mState);
                    end
                    else
                    begin
                        if mECMan.Core.Recovery(ECStatus) then
                        begin
                            Inc(mState);
                            mECMan.NotifyECStatus(ECStatus);
                        end;
                    end;
                end;
            2:
                begin
                    if TC.IsTimeOut then
                    begin
                        mState := 1;
                    end;
                end;
        end;

        if mECMan.mDelay then
        begin
            WaitForSingleObject(Handle, 1);
        end
        else
        begin
            Inc(LoopCount);
            if int64(GetTickCount64) - StartTime >= 1000 then
            begin
                StartTime := int64(GetTickCount64);

                {
                gLog.IsWrite := false;
                gLog.Panel('LoopCNT : %d',[LoopCount]);
                gLog.IsWrite := true;
                }

                WaitForSingleObject(Handle, 1);
                LoopCount := 0;
            end;
        end;
    end;

    timeEndPeriod(1);
end;



{ TECAD }

constructor TECAD.Create(RModules: array of TECModule; CHSize: integer);
var
    i: Integer;
begin

    mRModCount := Length(RModules);
    SetLength(mRModules, mRModCount);

    mChCount := 0;
    for i := 0 to mRModCount - 1 do
    begin
        mRModules[i] := RModules[i];
        mChCount := mChCount + mRModules[i].mCount;
    end;

    inherited Create(mChCount);

    mCHSize := CHSize;
    Resolution := Round(Power(2.0, CHSize * 8.0)); //65536 ;
end;

destructor TECAD.Destroy;
begin

    inherited;
end;

function TECAD.InternalRead: boolean;
var
    Ch, i, j: integer;
begin
    Ch := 0;
    for i := 0 to mRModCount - 1 do
    begin
        for j := 0 to mRModules[i].mCount - 1 do
        begin
            mDatas[Ch] := TECManager.GetInstance.GetVal(mRModules[i].mIdx + (j * mChSize)) + mMaxRange;   // mMaxRange는 음수값 처리 (아래 SetResolutin 주석 참조)
            Inc(Ch);
        end;
    end;
end;

function TECAD.IsOpen: boolean;
begin
    Result := TECManager.GetInstance.IsOpen;
end;

procedure TECAD.SetResolution(Val: integer);
begin
    mResolution := Val;
    // AI값이 -32768 ~ 32768로 읽힘(일반적인값은 16bit라면 0 ~ 65536), 따라서 0부터 시작위해 mMaxRange값을 더함..
    mMaxRange := Val div 2;
end;


{ TECAO }

constructor TECAO.Create(WModules: array of TECModule; StartCH: integer; CHSize: integer);
var
    i: Integer;
    dTm: double;
begin
    mWModCount := Length(WModules);
    SetLength(mWModules, mWModCount);

    mChCount := 0;


    for i := 0 to mWModCount - 1 do
    begin
        mWModules[i] := WModules[i];
        mChCount := mChCount + mWModules[i].mCount;
    end;

    mAOStartCh := StartCH;

    inherited Create(mChCount);

    mCHSize := CHSize;

    for i := 0 to mChCount - 1 do
        SetRange(i, TRange.Create(-10, 10));

    Resolution := Round(Power(2.0, CHSize * 8.0) - 1); // 65536 17bit 라서 bit 1개를 빼자!!
end;

destructor TECAO.Destroy;
begin

    inherited;
end;
{
function TECAO.InternalRead: boolean;
var
    iDx, Ch, i, j: integer;
//    WBuffer: array of byte; // 읽어 들이고 싶은만큼 설정하기...
    wTm: WORD;
begin
    Result := True;
    Ch := 0;

//    SetLength(WBuffer, 2);     // 메모리 부하 => 제거 필요! by E.S

    for i := 0 to mWModCount - 1 do
    begin
        for j := 0 to mWModules[i].mCount - 1 do
        begin
            TECManager.GetInstance.ReadBack((mWModules[i].mIdx + j) * 2, @wTm, 2);


//            TECManager.GetInstance.ReadBack((mWModules[i].mIdx + j) * 2, WBuffer, 2); // 제거 확인 필요
//            wTm := (WBuffer[0] or (WBuffer[1] shl 8));   // 제거 확인 필요

            if mTyp[Ch] = aoVolt then
                wTm := wTm + mMaxRange;

            mDatas[Ch] := wTm;

            Inc(Ch);
        end;
    end;
end;
}

function TECAO.InternalRead: boolean;
begin
    // ReadBack 필요성 없음
    Result := True;
end;

function TECAO.IsOpen: boolean;
begin
    Result := TECManager.GetInstance.IsOpen;
end;
{
procedure TECAO.SetDigitVolt(ACH, ADigit: integer);
var
    Ch, iDx, i, j: integer;
begin
    for i := 0 to mWModCount - 1 do
    begin
        iDx := (mWModules[i].mIdx + mWModules[i].mCount - 1);
        if iDx < ACH then
            Continue;

        Ch := mWModules[i].mIdx + (ACH * mChSize);
        TECManager.GetInstance.Write(Ch, ADigit);
        inc(Ch);
        TECManager.GetInstance.Write(Ch, ADigit shr 8);
        gLog.Panel('DIGIT VOLT CH%d DIGIT:%d IDX:%d', [ACH, ADigit, mWModules[i].mIdx + i]);
    end;

end;
}
procedure TECAO.SetDigitVolt(ACH, ADigit: WORD);
var
    i, ChSum, Offset, ModuleIdx: integer;
begin
   // TO DO 임시 코드
    if ACH >= mChCount then
        Exit;

    ChSum := 0;
    ModuleIdx := 0;
    for i := 0 to mWModCount - 1 do
    begin
        ChSum := ChSum + mWModules[i].mCount;
        if ACH >= ChSum then
        begin
            ModuleIdx := i + 1;
            break;
        end;
    end;

    Offset := mWModules[ModuleIdx].mIdx + (ACH * mChSize);

    TECManager.GetInstance.Write(Offset, ADigit);
    TECManager.GetInstance.Write(Offset + 1, ADigit shr 8);

end;

procedure TECAO.SetResolution(Val: integer);
begin
    mResolution := Val;
    // AI값이 -32768 ~ 32768로 읽힘(일반적인값은 16bit라면 0 ~ 65536), 따라서 0부터 시작위해 mMaxRange값을 더함..
    mMaxRange := Val div 2;
end;

procedure TECAO.SetVolt(ACH: integer; AValue: double);
var
    Val: integer;
begin
    Val := AnalogToDigital(ACH, AValue);
    //gLog.Panel('SetVolt %d',[VAl]);
    SetDigitVolt(ACH, Val);
end;
{ TECModule }

constructor TECModule.Create(Idx, ChCount: integer);
begin
    mIdx := Idx;
    mCount := ChCount;
end;

{ TECCT }
constructor TECCT.Create(SrcIdxs, ResetIdxs: array of integer);
var
    i: integer;
begin
    inherited Create(Length(SrcIdxs));

    SetLength(mSrcIdxs, mChCount);
    SetLength(mResetIdxs, mChCount);
    SetLength(mDatas, mChCount);

    for i := 0 to mChCount - 1 do
    begin
        mSrcIdxs[i] := SrcIdxs[i];
        mResetIdxs[i] := ResetIdxs[i];
    end;

end;

destructor TECCT.Destroy;
var
    i: integer;
begin

    for i := 0 to mChCount - 1 do
    begin
        Reset(i);
    end;

    mSrcIdxs := nil;
    mResetIdxs := nil;

    inherited;
end;

function TECCT.GetPulse(Ch: integer): Int64;
begin

    if mZeroFlag[Ch] then
    begin
        mZeroData[Ch] := TECManager.GetInstance.GetVal32(mSrcIdxs[Ch]);
        mZeroFlag[Ch] := false;
    end;

    Result := TECManager.GetInstance.GetVal32(mSrcIdxs[Ch]) - mZeroData[Ch];        // GetVal32() --> 32bit 해상도 사용시

    // InternalRead 할 경우 아래 활성
    //Result := mDatas[Ch];
end;

function TECCT.GetValue(Ch: integer): double;
begin
  //--값
    Result := 0;
end;

function TECCT.InternalRead(Ch: integer): Int64;
begin
    if mZeroFlag[Ch] then
    begin
        mZeroData[Ch] := TECManager.GetInstance.GetVal32(mSrcIdxs[Ch]);
        mZeroFlag[Ch] := false;
    end;

    Result := TECManager.GetInstance.GetVal32(mSrcIdxs[Ch]) - mZeroData[Ch];        // GetVal32() --> 32bit 해상도 사용시
end;

function TECCT.IsOverflow(Ch: integer): boolean;
begin
    Result := GetPulse(Ch) > 1000000;
end;

procedure TECCT.Clear;
var
    i: integer;
begin
    for i := 0 to mChCount - 1 do
        SetZero(i);
end;

function TECCT.Reads: boolean;
var
    i: integer;
begin
    for i := 0 to mChCount - 1 do
    begin
        mDatas[i] := GetPulse(i);
//        mDatas[i] := InternalRead(i);
    end;

end;

function TECCT.Reset(Ch: integer): boolean;
begin

    if TECManager.GetInstance.Write(mResetIdxs[Ch], $01) then
    begin
        Sleep(300);
        Result := TECManager.GetInstance.Write(mResetIdxs[Ch], $00)
    end
    else
        Exit(false);
end;

{ TECTLRCore }

function TECTLRCore.Open: boolean;
begin
    if (IsValid(xDriverOpen(@mhDriver))) then
    begin
        if Assigned(gLog) then
            gLog.Panel('Ethercat: Driver Open OK!');

        if (IsValid(xChannelOpen(mhDriver, @(Ansistring(_BOARD_NAME))[1], 0, mhChannel))) then
        begin
            if Assigned(gLog) then
                gLog.Panel('Ethercat: Channel:0 Open OK!');
            Exit(true);
        end;
    end;

    Result := false;
end;

function TECTLRCore.Close: boolean;
var
    Ret1: boolean;
begin
    if not IsOpen then
        Exit(false);

    Ret1 := IsValid(xChannelClose(mhChannel));
    Result := IsValid(xDriverClose(mhDriver)) and Ret1;

    if Result then
    begin
        if Assigned(gLog) then
            gLog.Panel('Ethercat: Close Driver!', []);
    end;
end;

constructor TECTLRCore.Create;
begin
    mTag := TAG_TLR;
    inherited Create;
end;

destructor TECTLRCore.Destroy;
begin
    inherited Destroy;
end;

function TECTLRCore.GetErrStr: string;
begin
    Result := GetCIFXErrStr(mStatus);
end;

function TECTLRCore.IsOpen: boolean;
begin
    Result := (mhDriver <> nil) and (mhChannel <> nil);
end;

function TECTLRCore.IsValid(Status: Cardinal): boolean;
var
    ErrStr: string;
begin
    mStatus := Dword(Status);
    if mStatus <> Dword(CIFX_NO_ERROR) then
    begin
        ErrStr := GetErrStr;
        if ErrStr <> '' then
        begin
            if Assigned(gLog) then
                gLog.Error('EtherCat Error: %s', [ErrStr]);
        end;
        Exit(false);
    end;

    Result := true;
end;

function TECTLRCore.ReadBack(Index: integer; const WBuffer: Pointer; Len: integer): boolean;
begin
    if not IsOpen then
        Exit(false);

    if (IsValid(xChannelIOReadSendData(mhChannel, 0, Index, Len, WBuffer))) then
    begin
        Exit(true);
    end
    else if Assigned(gLog) then
        gLog.Panel('Ethercat: xChannelIOReadSendData fail');
    Result := false;
end;

function TECTLRCore.Reads(ThreadState: PByte): integer;
var
    i, j, TarIdx: integer;
    TC: TTimeChecker;
begin
    Result := 0;
    TarIdx := 0;

    for j := 0 to mECRRangeCount - 1 do
    begin
        if (IsValid(xChannelIORead(mhChannel, mECRRanges[j].mAreaNo, mECRRanges[j].mOffset, mECRRanges[j].mLen, @mRInrBuffer[0], mECRRanges[j].mLen))) then
        begin
            CopyMemory(@mRBuffer[TarIdx], @mRInrBuffer[0], mECRRanges[j].mLen);
            TarIdx := TarIdx + mECRRanges[j].mLen;

            for i := 0 to mItems.Count - 1 do
            begin
                if ThreadState^ = 0 then
                    break;    // 외부에서 Stop시 바로 탈출위해.

                mItems[i].Reads;
                //gLog.Panel('ECT: %s Read ..', [mItems[i].Name]);
            end;

            // Module OK 체크
            for i := 0 to Length(mMOKOffsets) - 1 do
            begin
                if mRBuffer[mMOKOffsets[i]] = 0 then
                begin
                    gLog.Error('ECT: ModuleOk(%d) Error', [mMOKOffsets[i]]);
                    mErrModuleOffset := mMOKOffsets[i];
                    Exit(-1);
                end;
            end;
            Exit(1);
        end;
    end;

end;

function TECTLRCore.Reopen(IsDriverClose: boolean): boolean;
begin
    Result := true;

    if IsDriverClose then
    begin
        Result := IsValid(xChannelClose(mhChannel));
        if IsDriverClose and Result then
            Result := IsValid(xDriverClose(mhDriver));
    end;

    if Result then
    begin
        if IsDriverClose then
            Result := IsValid(xDriverOpen(@mhDriver));

        if Result then
            Result := IsValid(xChannelOpen(mhDriver, @(Ansistring(_BOARD_NAME))[1], 0, mhChannel));
    end;
end;

function TECTLRCore.Resetch(Timeout: integer): boolean;
begin
    if Assigned(gLog) then
        gLog.Panel('Ethercat: Ch. Reset');
    Result := IsValid(xChannelReset(mhChannel, CIFX_SYSTEMSTART, Timeout));
end;

function TECTLRCore.ResetDev(Timeout: integer): boolean;
begin
    if Assigned(gLog) then
        gLog.Panel('Ethercat: Dev. Reset');

    Result := IsValid(xSysdeviceReset(mhChannel, Timeout));
end;

function TECTLRCore.Write(Index: integer; WData: byte): boolean;
begin
    if not IsOpen then
        Exit(false);

    if (IsValid(xChannelIOWrite(mhChannel, 0, Index, SizeOf(WData), @WData, 5))) then
    begin
        Exit(true);
    end
    else
    begin
       // gLog.Panel('Ethercat: xChannelIOWrite fail');
    end;

    Result := false;
end;

function TECTLRCore.Writes(Index: integer; const WBuffer: Pointer; Len: integer): boolean;
begin
    if not IsOpen then
        Exit(false);

    if (IsValid(xChannelIOWrite(mhChannel, 0, Index, Len, WBuffer, 5 * Len))) then
    begin
        Exit(true);
    end
    else
    begin
        if Assigned(gLog) then
            gLog.Panel('Ethercat: xChannelIOWrite fail!');
    end;

    Result := false;
end;

{ TECRRange }

constructor TECRRange.Create(Offset: cardinal; Len: integer);
begin
    Create(0, Offset, Len);
end;

constructor TECRRange.Create(AreaNo, Offset: cardinal; Len: integer);
begin
    mAreaNo := AreaNo;
    mOffset := Offset;
    mLen := Len;
end;

{ TBaseECCore }
function TBaseECCore.Close: boolean;
begin
    raise Exception.Create('EtherCat Core Close 미구현');
end;

constructor TBaseECCore.Create;
begin
    mItems := TDAQList.Create;
end;

destructor TBaseECCore.Destroy;
begin
    if Assigned(mItems) then
        FreeAndNil(mItems);

    mRInrBuffer := nil;
    mRBuffer := nil;
    mMOKOffsets := nil;

    mECRRanges := nil;
    inherited;
end;

function TBaseECCore.GetCoreName: string;
begin
    case mTag of
        0:
            Result := 'TLRCore';
        1:
            Result := 'SOEMCore';
    end;
end;

function TBaseECCore.Recovery(var ECStatus: TECStatus): boolean;
begin
    raise Exception.Create('Recovery 미구현');
end;

function TBaseECCore.GetErrStr: string;
begin
    raise Exception.Create('EtherCat Core GetErrStr 미구현');
end;

function TBaseECCore.IsOpen: boolean;
begin
    raise Exception.Create('EtherCat Core IsOpen 미구현');
end;

function TBaseECCore.IsValid(Status: Dword): boolean;
begin
    raise Exception.Create('EtherCat Core IsValid 미구현');
end;

function TBaseECCore.Open: boolean;
begin
    raise Exception.Create('EtherCat Core Open 미구현');
end;

function TBaseECCore.ReadBack(Index: integer; const WBuffer: Pointer; Len: integer): boolean;
begin
    raise Exception.Create('EtherCat Core ReadBack 미구현');
end;

function TBaseECCore.Reads(ThreadState: PByte): integer;
begin
    raise Exception.Create('EtherCat Core Reads 미구현');
end;

function TBaseECCore.Reopen(IsDriverClose: boolean): boolean;
begin
    raise Exception.Create('EtherCat Core ReOpen 미구현');
end;

function TBaseECCore.Resetch(Timeout: integer): boolean;
begin
    raise Exception.Create('EtherCat Core Resetch 미구현');
end;

function TBaseECCore.ResetDev(Timeout: integer): boolean;
begin
    raise Exception.Create('EtherCat Core ResetDev 미구현');
end;

function TBaseECCore.Write(Index: integer; WData: byte): boolean;
begin
    raise Exception.Create('EtherCat Core Write 미구현');
end;

function TBaseECCore.Writes(Index: integer; const WBuffer: Pointer; Len: integer): boolean;
begin
    raise Exception.Create('EtherCat Core Writes 미구현');
end;


{ TECAT }
constructor TECAT.Create(SrcIdxs: array of integer);
var
    i: integer;
begin
    inherited Create(Length(SrcIdxs));

    SetLength(mSrcIdxs, mMaxChCount);
    SetLength(mDatas, mMaxChCount);

    for i := 0 to mMaxChCount - 1 do
        mSrcIdxs[i] := SrcIdxs[i];

end;

destructor TECAT.Destroy;
begin
    mSrcIdxs := nil;
    mDatas := nil;

    inherited Destroy;
end;

function TECAT.InternalRead(Ch: integer): double;
begin
    Result := TECManager.mInstance.GetVal32(mSrcIdxs[Ch]) / mResolution;
end;

function TECAT.IsOverflow(Ch: integer): boolean;
var
    ReadData: Double;
begin
    ReadData := InternalRead(Ch);

    if mType[Ch] = ATTemp then
        Result := (ReadData < -200) or (ReadData > 850)
    else
        Result := (ReadData < 0.5) or (ReadData > 390);
end;

function TECAT.Reads: boolean;
var
    i: integer;
begin
    for i := 0 to mMaxChCount - 1 do
    begin
        mDatas[i] := InternalRead(i);
    end;
end;

{ TECPWM }

constructor TECPWM.Create(WModule: TECModule);
var
    i: Integer;
    dTm: double;
begin
    mChCount := 1;
    mWModule := WModule;

    inherited Create(mChCount);
end;
destructor TECPWM.Destroy;
begin

  inherited;
end;

function TECPWM.InternalRead: boolean;
begin
    Result := True;
end;

function TECPWM.IsOpen: boolean;
begin
    Result := TECManager.GetInstance.IsOpen;
end;


procedure TECPWM.SetDutyRatio(DutyRatio: Double);
var
    Offset: integer;
    Value: integer;
begin
    if DutyRatio < 0 then
    begin
        gLog.Panel('듀티비 셋팅을 음수로 지정하였습니다. 설정 듀티비 : %0.1f', [DutyRatio]);
        Exit;
    end;

    if DutyRatio > 100 then
    begin
        gLog.Panel('듀티비는 100%를 초과할 수 없습니다. 설정 듀티비 : %0.1f', [DutyRatio]);
        Exit;
    end;


    Offset := mWModule.mIdx;

    Value := Trunc(DutyRatio * 10);

    TECManager.GetInstance.Write(Offset, Value);
    TECManager.GetInstance.Write(Offset + 1, Value shr 8);
end;

initialization
    AddTerminateProc(FreeInstanceWpr);


finalization
    if Assigned(TECManager.mInstance) then
    begin
        if not TECManager.mInstance.OwnerFree then
            TECManager.mInstance.FreeInstance;
    end;

end.

