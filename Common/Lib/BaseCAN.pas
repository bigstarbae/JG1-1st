{
  Ver.210409.00
    : MultiCANFrame 지원

  Ver.211031.00
    : SimulCAN: 요청 프레임에 대한 응답 프레임 대응 추가

  - 참고 : 현대 CAN 맵은 Bit 순서가 왼쪽 -> 오른쪽임(PG상 Bit연산시 반전 필요), Btye순서도  BigEndian(왼쪽 -> 오른쪽)

  Ver.211115.00
    : TMultiCANFrame.mDebug 디버그용 Flag 변수 추가

  Ver.220914.00
    : ExtendedID 유무 함수 추가

  Ver.240520.00  by JSJ
    : CANFD 혼용 대비 TCANData array[0..7] of Byte 에서 array[0..63] of Byte로 변경

  Ver.240617.00  by JSJ
    : CRC 계산 함수 추가 및 Write에 Use CRC 가능하게 overload함수 하나 더 추가
      * 사용시 Tswork Initial 부분에 InitAliveCnt 필수.


  Ver.240625.00
    : CAN WQueue 추가: Simul Test만 완료

  Ver.240626.01
    : JSJ 코드 통합 및 개선

  Ver.241203.00
    : TCANSignal.Write: 2Byte 범위 Write 구현

  Ver.250721.00
    : Write Queue 전송시 기본 주기 추가
    : Queue Type TTsListEx로 변경
    : CAN FD Preset 지원

}

unit BaseCAN;

// {$DEFINE _USE_SINGLETON_CAN_MAN}

interface

uses
    Windows, Classes, Generics.Collections, IniFiles, TimeChecker, Deltics.MultiCast, BaseDAQ, MyUtils, TSListEx, CanFDPreset;

const
    CAN_R_DEBUG_LEVEL0 = 0;
    CAN_R_DEBUG_LEVEL1 = 1;
    CAN_R_DEBUG_LEVEL2 = 2;
    MAX_CAN_DATA_LEN = 64;

type
    {
      <ISO-15765-2(ISO-TP) 멀티 프레임 프로토콜 처리>
      # PCI(Protocol Ctrl Info.) : 1번째 바이트
      - PCI Type
      (1) Single : 일반적인 CAN 통신 8byte 데이타 프레임
      0X  : Single frame          : single (4bit) + data length(4bit)               : TX/RX

      (2) Multi : 응답받을 데이타 길이가 8byte보다 큰 경우 (ex: 모터 Limit 상태 읽기)
      1X  : First frame           : first frame(4bit), + data length(4bit + 8bit)   : RX
      2X  : Consecutive frame     : consecutive frame(4bit) + sequence number(4bit) : RX
      3X  : Flow control          : flow control frame(4bit)  + flow state(4bit)    : TX
      - 메시지 길이 : 하위 4bit (X로 표기)

      ex> SF 3BYTE  메시지, 나머지는 패딩 바이트(0xAA or 0x00 or 0xFF)
      0x03, 0x01, 0x02, 0x03, 0xAA, 0xAA, 0xAA, 0xAA

      ex> .. 작성중.

      }

    TCANData = array[0..MAX_CAN_DATA_LEN - 1] of byte;
    // ------------------------------------------------------------------------------

    PCANFrame = ^TCANFrame;

    TCANFrame = packed record
    private
        function GetPropertyData(Idx: Integer): Byte;
        procedure SetPropertyData(Idx: Integer; const Value: Byte);

    public
        mID: Cardinal;
        mData: TCANData;
        mLen: Byte;
        mIntervalMs: integer;

        mTC: TTimeChecker;
        mEnabled: boolean;

        mTag: Byte;

        constructor Create(ID: Cardinal; Len: Integer = 8; Interval: integer = 0); overload;
        constructor Create(ID: Cardinal; Data: TCANData; Len: Integer = 0; Interval: integer = 0); overload;
        constructor Create(ID: Cardinal; Data: array of byte; Len: Integer = 0; Interval: integer = 0); overload;

        function Clone: PCANFrame;

        function FromStr(const Str: string): boolean;
        function FromStrEx(CanFrameStr: string): string;      // 리턴값은 주석, Ex> Fmt : 3E0: 00 00 000055 00 000   //(주석) IGN 신호
        function ToStr: string;
        function ToHexGridStr(Indent: Integer = 1): string;

        function IsExtendedID: boolean;
        function IsEmpty: boolean;
        function IsDiff(Frame: PCANFrame): boolean; overload;
        function IsDiff(Frame: TCANFrame): boolean; overload;

        procedure Assign(Frame: PCANFrame); overload;
        procedure Assign(Frame: TCANFrame); overload;

        procedure SetData(Data: array of byte; Len: Integer = 0); overload;
        procedure SetData(Data: TCANData; Len: Integer = 0); overload;
        procedure SetDataAtOffset(Offset: Integer; PartData: array of Byte);

        function Read(IniFile: TIniFile; Section, Ident: string): boolean;
        function Write(IniFile: TIniFile; Section, Ident: string): boolean; overload;
        procedure Write(Strings: TStrings); overload;

        procedure Clear;
        function CheckInterval: boolean;

        function Compare(Frame: TCANFrame; DataMask: Int64 = -1): boolean; overload;
        function Compare(SrcIdx: integer; CmpDatas: array of byte; CmpLen: integer): boolean; overload;

        property Data[Idx: Integer]: Byte read GetPropertyData write SetPropertyData; default;
    end;

    TCANPFrmList = TList<PCANFrame>;

    TCANFrmList = TList<TCANFrame>;

    TCANTransEvent = procedure(CANFrame: TCANFrame; IsSend: boolean) of object;

    // ------------------------------------------------------------------------------
    TCANFrameType = (ftNone, ftSF, ftFF, ftCF1, ftCF2, ftCF3, ftCF4, ftCF5);        // CF5 까지만 지원

    TBaseCAN = class;

    PMultiCANFrame = ^TMultiCANFrame;

    TMultiCANFrame = packed record // 수신 처리 전용
    private
        mState: integer;

    public
        mType: TCANFrameType;
        mReqID, mRspID: Cardinal;

        mDatas: array of byte;
        mDataLen: integer;

        // Flow Ctrl
        mFCBlockSize, // CF(2X)에서 전송 받을 Block(Frame)갯수, 이 크기 설정에 의해 전체 길이를 분할해서 받을 수 있음 \
        //  ex> 전체길이 24(Byte)라면, FC를 2로 설정시 ->   CF가 연속으로 2회(8x2=16Byte) -> FC -> 나머지 1회(8Byte) 수신,
		//  즉 수신측에서 한번에 처리가능한 소량의 프레임만 나눠서 받는다는 의미
        mFCSepTime: byte; // 프레임사이 대기 시간 (msec단위), 0은 최대한 빨리 CF프레임을 전송하라는 의미

        //
        mTotSeqNum, mSeqNum: byte;

        mDebug: boolean;

    public
        constructor Create(ReqID, RspID: Cardinal; FCBlockSize: byte = 2; FCSepTime: byte = 8);
        procedure Deinit; // 필수 !!!

        procedure ClearFSM;
        procedure Clear;

        procedure GetDatas(Datas: PByte; Len: integer);

        function FrameType(Data: Byte): TCANFrameType;

        function IsDone: boolean;
        function FSMRun(CAN: TBaseCAN): integer;

        function GetStateStr: string;
        function ToStr: string;

        property DataLen: Integer read mDataLen;
    end;

    // ------------------------------------------------------------------------------

    TCANSignal = packed record
        mID: Cardinal;

        mStartByte, mStartBit, mBitLen: integer;
        mIntervalMs: integer;

        mName: string[15];

        mTC: TTimeChecker;

        // 현대 엑셀문서 기준 : 비트 순서는 최상단, 좌 -> 우
        constructor Create(MsgID: Cardinal; StartByte, StartBit, BitLen: integer; IntervalMs: integer = 0); overload;
        // DBC 파일 기준 : 비트 순서 최하단, 우 -> 좌
        constructor Create(MsgID: Cardinal; StartDBCBit, BitLen: integer; IsMotorolaFmt: boolean = true; IntervalMs: integer = 0); overload; //

        function IsExtendedID: boolean;
        function IsEmpty: boolean;
        function Is2ByteData: boolean;

        function GetData(Data: byte; IsRevBits: boolean = false): byte; overload; // Data인자에서 StrtBit과 BitLen의 값을 추출
        function GetData(Data1, Data2: byte; IsRevBits: boolean = false): byte; overload;
        function GetDataAsWord(Data1, Data2: byte; IsRevBits: boolean = false): Word;

        function Read(var Frame: TCANFrame; IsRevBits: boolean = false): byte;
        procedure Write(var Frame: TCANFrame; OnOff: boolean; IsRevBits: boolean = false); overload;
        procedure Write(var Frame: TCANFrame; Val: byte; IsRevBits: boolean = false); overload;

        function ToStr: string;
        function FromStr(Str: string): boolean;

        function FSMCheckInterval: integer;

        function GetSHLVal(IsRev: boolean): integer;
    end;

    // ------------------------------------------------------------------------------
    PCANSignal = ^TCANSignal;

    TCANSigList = TList<TCANSignal>;

    TCANFrameList = TList<TCANFrame>;

    TPCANFrameList = TList<PCANFrame>;

    TPCANFrameThList = TMyThreadList<PCANFrame>;

    TCANIDSigDic = TDictionary<Cardinal, TCANSigList>;

    TCANFrameDic = TDictionary<Cardinal, TCANFrame>;

    TPCANFrameDic = TDictionary<Cardinal, PCANFrame>;

    // ------------------------------------------------------------------------------
    // 싱글톤
    TCANSigManager = class(TDictionary<string, TCANSignal>) // Key는 Name
        mIDDic: TCANIDSigDic; // ID별로 분류된 SignalList

        procedure ClearIDDic;
    public
        constructor Create;
        destructor Destroy; override;

        function Load(FilePath: string): boolean;
        function Save(FilePath: string): boolean;
    end;
    // ------------------------------------------------------------------------------
    // ------------------------------------------------------------------------------

    TCANRWType = (crwtRead, crwtWrite);

    TCANQueueItem = packed record
        mRWType: TCANRWType;
        mCAN: TBaseCAN;
        mFrame: TCANFrame;

        constructor Create(CAN: TBaseCAN; Frame: TCANFrame; RWType: TCANRWType);

        function Execute: Boolean;
    end;

    TCANList = TList<TBaseCAN>;

    TBaseCAN = class(TBaseDAQ)
    private
        function GetWFrames(Index: integer): PCANFrame;
        procedure WriteWFrameOnce; // 주기 만족한 WFrame 1회 전송

        class function GetItems(Index: integer): TBaseCAN; static;
        class var
            mItems: TCANList;

        function GetRFrame: PCANFrame;
        function GetDatas(Index: integer): byte; overload; virtual;
        class procedure SetRQueueing(const Value: Boolean); static;
        class procedure SetWQueueing(const Value: Boolean); static;

        class procedure RunQueueThread; static;
        function GetPreset: PCANFDPreset;
        procedure SetPreset(const Value: PCANFDPreset);

    protected
        mCh, mBaudRate: integer;

        mCmnFrame: TCANFrame;       // 공용 더미
        mCurRFrame: TCANFrame;

        mIdx: integer;

        mEnableWFrameList: boolean;

        mWFrmList: TPCANFrameThList;
        mOnWrite, mOnRead: TMultiCastNotify;

        mCommChkTC: TTimeChecker;

        mOnTrans: TCANTransEvent;

        mWDelay: Integer; //msec

        mLastWRet: Boolean;  // Last Write함수 결과

        mDefaultWriteIntervalMs: Integer;

        mUseFD: Boolean;
        mPreset: TCANFDPreset;

        mNextWriteHighPriority: Boolean;

        class var
            mQueue: TTSListEx<TCANQueueItem>;
        class var
            mRQueueing: Boolean;      // 읽기 Queue처리
        class var
            mWQueueing: Boolean;      // 쓰기 Queue처리, Ex: 이더캣인 경우 고려
        class var
            mRunQueueing: Boolean;    // Thread Loop Flag


        class function AddToWQueue(CAN: TBaseCAN; Frame: TCANFrame): Boolean;
        class function AddToRQueue(CAN: TBaseCAN; Frame: TCANFrame): Boolean;

        procedure Run; virtual;
        procedure SelfRun; virtual;

        function GetID(): Cardinal; virtual;
        procedure InternalReads;// 자손 구현부 Reads에서 호출해줄 것
        procedure InternalWrite(Ret: boolean; const ID: Cardinal; Data: array of byte; Len: integer = 8);// 구현부 Write에서 호출!
        function GetEffectiveWriteInterval(RequestedInterval: Integer): Integer;
    public
        class var
            mRDebug: boolean;
        class var
            mWDebug: boolean;
        class var
            mRDebugLevel: integer;

        constructor Create(IsSelfRun: boolean = false); overload;
        constructor Create(CH: integer; IsSelfRun: boolean = false); overload;
        destructor Destroy; override;

        function IsOpen: boolean; virtual;

        function Open: boolean; overload; virtual;
        function Open(BaudRate: integer): boolean; overload; virtual;
        function Open(Ch, BaudRate: integer): boolean; overload; virtual;
        function OpenFD(Ch, BaudRate: Integer; Preset: TCANFDPreset): Boolean;

        function ReOpen: boolean; virtual; abstract;

        procedure Close; override;

        function IsWIDExists(MsgID: Cardinal): boolean; // 쓰기 프레임 ID 존재 여부?
        procedure SetNextWriteHighPriority; // 큐 사용시 최우선

        // 기본 W/R
        function Write(const ID: Cardinal; Flags: integer; Data: array of byte; Len: integer = 8): boolean; overload; virtual; abstract;
        function Write(const ID: Cardinal; Data: array of byte; Len: integer = 8): boolean; overload;
        function Write(const ID: Cardinal; Data: array of byte; UseCRC: boolean; CRCByteLen: Integer): boolean; overload;
        function Write(Frame: TCANFrame): boolean; overload;
        function Write(Signal: TCANSignal; Val: byte): boolean; overload;

        function WriteAtOffset(const ID: Cardinal; Offset: Integer; PartData: array of Byte): Boolean;

        function WriteFromQueue(Frame: TCANFrame): boolean; overload; virtual;
        function WriteFromQueue(const ID: Cardinal; Flags: integer; Data: array of byte; Len: integer = 8): boolean; overload; virtual;

        procedure Read(var Frame: TCANFrame); overload; virtual; // 현재 수신한 CanFrame읽기 구현
        procedure Read(var Datas: array of byte); overload; virtual;

        // CRC 계산용
        function CalcStandardCRC8(StandardID: Word; FrameDatas: array of Byte): Byte;
        function CalcStandardCRC16(StandardID: Word; FrameDatas: array of Byte): DWord;
        function CalcExtendedCRC16(ExtendedID: DWord; FrameDatas: array of Byte): DWord;

        //
        function IsCommRun(LimitSec: double = 1.0): boolean; // 통신 지속 여부, LimitSec내 수신 패킷이 없으면 false

        // Write Frame
        procedure AddWFrame(Frame: PCANFrame; Enabled: boolean = true); overload;
        function AddWFrame(MsgID: Cardinal; Data: array of byte; IntervalMs: integer; Enabled: boolean = true): PCANFrame; overload;
        function AddWFrame(MsgID: Cardinal; Data: TCANData; IntervalMs: integer; Enabled: boolean = true): PCANFrame; overload;
        function RemoveWFrame(MsgID: Cardinal): boolean; overload;
        function RemoveWFrame(Frame: PCANFrame): boolean; overload;
        function WFrameCount: integer;

        procedure WriteWFrames; // 모든 WFrame 쓰기

        // 수동으로 WFrame들 전송시 사용
        function NextWFrame: PCANFrame; // 순회하면서 WFrame을 얻음
        function WriteNextWFrame: boolean; // 순회하면서 WFrame 전송,  Cyclic Read되는  Frame에 맞춰 전송할때 사용

        procedure GetDatas(Datas: PByte; Len: integer = 8); overload;
        function GetCfgStr: string; virtual;
        function ToStr: string;


        // 데이터 길이를 DLC로 계산
        function CalcDLC(Len: integer): integer;

        // DLC를 데이터 길이로 계산
        function CalcLen(DLC: integer): integer;

        // CANFD로 Enable
        function EnableFD(Enable: boolean): TBaseCAN;

        function Compare(SrcIdx: integer; CmpDatas: array of byte; CmpLen: integer): boolean;

        class function ItemCount: integer;

        procedure SelfTest; override;

        property CH: Integer read mCH write mCH;
        property ID: Cardinal read GetID;
        property Datas[Index: integer]: byte read GetDatas;
        property EnableWFrameList: boolean read mEnableWFrameList write mEnableWFrameList;

        property RFrame: PCANFrame read GetRFrame;
        property WFrames[Index: integer]: PCANFrame read GetWFrames;

        property OnRead: TMultiCastNotify read mOnRead;
        property OnWrite: TMultiCastNotify read mOnWrite;

        property OnTrans: TCANTransEvent read mOnTrans write mOnTrans;

        property WDelay: Integer read mWDelay write mWDelay;

        property LastWRet: Boolean read mLastWRet write mLastWRet;

        property UseFD: Boolean read mUseFD write mUseFD;
        property Preset: PCANFDPreset read GetPreset write SetPreset;

        property DefaultWriteInterval: Integer read mDefaultWriteIntervalMs write mDefaultWriteIntervalMs;


        class property RQueueing: Boolean read mRQueueing write SetRQueueing;
        class property WQueueing: Boolean read mWQueueing write SetWQueueing;

        class property Items[Index: integer]: TBaseCAN read GetItems;
    end;

    // ------------------------------------------------------------------------------
    TSimCANFrameInfo = class
        mReqFrame: TCANFrame;          // 요청 프레임
        mReqFrameMask: byte;               // 요청 프레임에서 몇번째 데이터까지 비교 조건
        mRespFrame: TCANFrame;          // 요청 프레이임에 대한 응답 프레임
    end;

    TSimCANFrameInfoList = TList<TSimCANFrameInfo>;

    TSimulCAN = class(TBaseCAN)
    private
        mCanID: Cardinal;
        mCurWFrame: TCANFrame;
        mSimFrameInfos: TSimCANFrameInfoList;
        mSimFrmInfoIdx: integer;

        function GetID(): Cardinal; override;

    public
        constructor Create(OwnerFree: boolean; IsSelfRun: boolean = false);
        destructor Destroy(); override;
        function IsOpen: boolean; override;

        function Open(BaudRate: integer): boolean; overload; override;
        function Open(Ch, BaudRate: integer): boolean; overload; override;

        function Reads: boolean; override;
        procedure Read(var Frame: TCANFrame); override;

        function Write(const aID: Cardinal; aFlags: integer; aData: array of byte; Count: integer = 8): boolean; override;
        function WriteFromQueue(const ID: Cardinal; Flags: integer; Data: array of byte; Len: integer = 8): boolean; override;

        procedure SetID(ID: cardinal);

        procedure AddSimFrame(ID: cardinal; Data: array of byte; Interval: integer = 200); overload;
        procedure AddSimFrame(ReqFrame, RespFrame: TCANFrame; ReqFrameMask: byte = $FF); overload;   // ReqFrameMask 비교할 데이터 위치 지정,FF는 전체 8byte

        procedure SelfTest;

    end;


    // ------------------------------------------------------------------------------



    // ------------------------------------------------------------------------------

    // 매니저 역할 병행.=> TDAQManager 사용할 것
    TCanThread = class(TThread)
    private
        mState: integer;
        mItems: TCANList;
        procedure Execute(); override;

        function GetItem(Idx: integer): TBaseCAN;
    public
        constructor Create(aPriority: TThreadPriority = tpNormal);
        destructor Destroy(); override;

        procedure Start;
        procedure Stop;

        function Count: integer;

        property Items[Idx: integer]: TBaseCAN read GetItem;

    end;

function IsExtendedID(ID: Cardinal): boolean;

    // ------------------------------------------------------------------------------
var
    gCanThread: TCanThread; // 싱글톤으로.

implementation

uses
    StrUtils, Math, SysUtils, Log, TypInfo, AsyncCalls;

function IsExtendedID(ID: Cardinal): boolean;
begin
    Result := (ID and $FFFF8000) > 0;
end;

{ TCANFrame }

constructor TCANFrame.Create(ID: Cardinal; Data: array of byte; Len: Integer; Interval: integer);
var
    CopyLen: Integer;
begin
    Clear;
    mID := ID;

    if Len > 0 then
        mLen := Min(Len, MAX_CAN_DATA_LEN)
    else
        mLen := Min(Length(Data), MAX_CAN_DATA_LEN);

    if Length(Data) > 0 then
        Move(Data[0], mData[0], Min(mLen, Length(Data)));

    mIntervalMs := Interval;
    mTC := TTimeChecker.Create(Interval);
    mEnabled := true;
end;

// Fmt : 3E0: 00 00 000055 00 000   //(주석) IGN 신호
function TCANFrame.FromStrEx(CanFrameStr: string): string;
var
    IdStr, DataStr, HexStr: string;
    ID, Len, i: Integer;
    CmtIdx: Integer;
begin

    Clear;

    if CanFrameStr = '' then
        raise Exception.Create('Invalid CAN Frame: ' + CanFrameStr);

    CmtIdx := Pos('//', CanFrameStr);
    if CmtIdx > 0 then
    begin
        Result := Trim(Copy(CanFrameStr, CmtIdx + 2, Length(CanFrameStr)));
        CanFrameStr := Trim(Copy(CanFrameStr, 1, CmtIdx - 1));
    end;

    if Pos(':', CanFrameStr) = 0 then
        raise Exception.Create('Invalid CAN Frame: ' + CanFrameStr);

    IdStr := Trim(Copy(CanFrameStr, 1, Pos(':', CanFrameStr) - 1));
    DataStr := Trim(Copy(CanFrameStr, Pos(':', CanFrameStr) + 1, Length(CanFrameStr)));

    if (IdStr = '') or (DataStr = '') then
        raise Exception.Create('Invalid CAN Frame: ' + CanFrameStr);

    if not TryStrToInt('$' + IdStr, ID) then
        raise Exception.Create('Invalid CAN Frame: ' + CanFrameStr);

    mID := ID;

    HexStr := StringReplace(DataStr, ' ', '', [rfReplaceAll]);
    HexStr := StringReplace(HexStr, ',', '', [rfReplaceAll]);

    if Length(HexStr) mod 2 <> 0 then
        raise Exception.Create('Invalid CAN Frame: ' + CanFrameStr);

    if Length(HexStr) > MAX_CAN_DATA_LEN * 2 then
        raise Exception.Create('Invalid CAN Frame: ' + CanFrameStr);

    Len := Length(HexStr) div 2;

    mLen := Len;

    for i := 0 to mLen - 1 do
    begin
        mData[i] := StrToInt('$' + Copy(HexStr, i * 2 + 1, 2))
    end;

end;

function TCANFrame.GetPropertyData(Idx: Integer): Byte;
begin
    if Idx < Length(mData) then
        Result := mData[Idx]
    else
        Result := 0;
end;

{
string 지원 형식:
    F.FromStr('797:00 11 22 33 44 AA BB CC');
    F.FromStr('797: 00 11 22 33 44 AA BB CC');

}

function TCANFrame.FromStr(const Str: string): boolean;
var
    n, i, TokCount: integer;
    Tokens: array[0..MAX_CAN_DATA_LEN - 1] of string;
begin
    Result := True;

    try
        FromStrEx(Str);

    except
        Exit(False);

    end;
end;

function TCANFrame.IsDiff(Frame: TCANFrame): boolean;
begin
    Result := (mID <> Frame.mID) or (not CompareMem(@mData[0], @Frame.mData[0], mLen));
end;

function TCANFrame.IsEmpty: boolean;
var
    i: integer;
begin
    for i := 0 to mLen - 1 do
    begin
        if mData[i] <> 0 then
            Exit(false);
    end;

    Result := true;
end;

function TCANFrame.IsExtendedID: boolean;
begin
    Result := BaseCAN.IsExtendedID(mID);
end;


{
1. 일반(Classical) CAN
    - ID:0, 0, 0, 0, 0, 0, 0, 0                 // ID:DATA
    - ID:0, 0, 0, 0, 0, 0, 0, 0:100             // ID:DATA:INTERVAL
2. CAN FD
    - ID:24:0, 0, 0, ..... 0, 0:100            // ID:LEN:DATA:INTERVAL

}
function TCANFrame.Read(IniFile: TIniFile; Section, Ident: string): boolean;
var
    Str: string;
    i, TokCount: integer;
    Tokens: array[0..MAX_CAN_DATA_LEN + 2] of string;
    IsClsCAN: Boolean;
begin
    Result := true;
    try
        Str := IniFile.ReadString(Section, Ident, '');

        TokCount := ParseByDelimiter(Tokens, MAX_CAN_DATA_LEN + 3, Str, ',:');

        if TokCount < 9 then
            Exit(False);

        IsClsCAN := (TokCount = 9) or (TokCount = 10);   // Classical CAN

        Clear;
        mID := HexToInt(Tokens[0]);

        if IsClsCAN then
        begin
            for i := 0 to TokCount - 1 do
            begin
                mData[i] := StrToIntDef('$' + Tokens[1 + i], 0);
            end;

            if TokCount = 10 then
                mIntervalMS := StrToIntDef(Tokens[9], 0);

            mLen := 8;
        end
        else
        begin
            mLen := StrToIntDef('$' + Tokens[1], 0);

            for i := 0 to mLen - 1 do
            begin
                mData[i] := StrToIntDef('$' + Tokens[2 + i], 0);
            end;

            if TokCount = (mLen + 3) then
                mIntervalMS := StrToIntDef(Tokens[mLen + 2], 0);
        end;

    except
        Result := false;
    end;
end;

function TCANFrame.IsDiff(Frame: PCANFrame): boolean;
begin
    Result := IsDiff(Frame^);
end;

constructor TCANFrame.Create(ID: Cardinal; Len: Integer; Interval: integer);
begin
    Clear;
    mID := ID;
    mLen := Len;
    mIntervalMs := Interval;
    mTC := TTimeChecker.Create(Interval);
    mEnabled := true;
    Clear;
end;

constructor TCANFrame.Create(ID: Cardinal; Data: TCANData; Len: Integer; Interval: integer);
begin
    Clear;
    mID := ID;
    mData := Data;
    if Len = 0 then
        mLen := Length(Data)
    else
        mLen := Len;
    mIntervalMs := Interval;
    mTC := TTimeChecker.Create(Interval);
    mEnabled := true;
end;

procedure TCANFrame.Assign(Frame: PCANFrame);
begin
    Assign(Frame^);
end;

procedure TCANFrame.Assign(Frame: TCANFrame);
begin
    mID := Frame.mID;
    mIntervalMs := Frame.mIntervalMs;
    mEnabled := Frame.mEnabled;
    SetData(Frame.mData, Frame.mLen);
end;

function TCANFrame.CheckInterval: boolean;
begin
    if not mEnabled then
        Exit(false);

    Result := false;

    if not mTC.IsStart then
        mTC.Start(mIntervalMs)
    else if mTC.IsTimeOut then
    begin
        mTC.Start(mIntervalMs);
        Exit(true);
    end;
end;

procedure TCANFrame.Clear;
begin
    ZeroMemory(@mData[0], sizeof(TCANData));
    mIntervalMs := 0;

    if mLen = 0 then
        mLen := 8;
end;

function TCANFrame.Clone: PCANFrame;
begin
    Result := New(PCANFrame);
    Move(self, Result^, sizeof(TCANFrame));
end;

function TCANFrame.Compare(SrcIdx: Integer; CmpDatas: array of byte; CmpLen: Integer): boolean;
var
    i: Integer;
begin
    Result := false;
    if (SrcIdx + CmpLen) > mLen then
        Exit;

    for i := 0 to CmpLen - 1 do
    begin
        if mData[SrcIdx + i] <> CmpDatas[i] then
            Exit;
    end;

    Result := true;

end;

function TCANFrame.Compare(Frame: TCANFrame; DataMask: Int64): boolean;
var
    i: integer;
    IsOn: Boolean;
begin
    Result := false;
    if mID <> Frame.mID then
        Exit;

    for i := 0 to mLen - 1 do
    begin
        if i < 64 then
        begin
            IsOn := (DataMask and (Int64(1) shl i)) <> 0;

            if (mData[i] <> Frame.mData[i]) and IsOn then
                Exit;
        end
        else
        begin
            if mData[i] <> Frame.mData[i] then
                Exit;
        end;
    end;

    Result := true;
end;

procedure TCANFrame.SetData(Data: array of byte; Len: Integer);
begin
    mLen := IfThen(Len = 0, Length(Data), Len);

    Move(Data[0], mData[0], min(mLen, sizeof(mData)));
end;

procedure TCANFrame.SetData(Data: TCANData; Len: Integer);
begin
    mLen := IfThen(Len = 0, Length(Data), Len);

    Move(Data[0], mData[0], mLen);
end;

procedure TCANFrame.SetDataAtOffset(Offset: Integer; PartData: array of Byte);
var
    Len: Integer;
begin
    if (Offset < 0) or (Offset >= SizeOf(mData)) then
        Exit;

    Len := Min(SizeOf(mData) - Offset, Length(PartData));

    Move(PartData[0], mData[Offset], Len);
end;

procedure TCANFrame.SetPropertyData(Idx: Integer; const Value: Byte);
begin
    if Idx < Length(mData) then
        mData[Idx] := Value;
end;

function TCANFrame.ToHexGridStr(Indent: Integer): string;
var
    i, ColCount: Integer;
    IndentStr: string;

    function GetIndentStr(IndentCount: Integer; UseSpaceIndent: Boolean): string;
    begin
        if UseSpaceIndent then
            Result := StringOfChar(' ', IndentCount * 4)
        else
            Result := StringOfChar(#9, IndentCount);
    end;

begin
    Result := '';
    ColCount := 0;

    IndentStr := GetIndentStr(Indent, True);

    for i := 0 to mLen - 1 do
    begin
        if ColCount = 0 then
            Result := Result + IndentStr;

        Result := Result + Format('%.2X ', [mData[i]]);
        Inc(ColCount);

        if ColCount = 8 then
        begin
            SetLength(Result, Length(Result) - 1);
            Result := Result + sLineBreak;
            ColCount := 0;
        end;
    end;

    if ColCount > 0 then
    begin
        SetLength(Result, Length(Result) - 1);
    end;
end;

function TCANFrame.ToStr: string;
var
    i: integer;
begin
    Result := IntToHex(mID, 3) + ' : ';

    for i := 0 to mLen - 1 do
    begin
        Result := Result + IntToHex(mData[i], 2);
        if i < mLen - 1 then
            Result := Result + ' ';
    end;

    if mIntervalMs > 0 then
    begin
        Result := Result + ' (' + IntToStr(mIntervalMs) + ' msec)';
    end;
end;

function TCANFrame.Write(IniFile: TIniFile; Section, Ident: string): boolean;
var
    i: integer;
    Str: string;
begin

    Result := true;

    Str := IntToHex(mID, 3) + ' : ';

    if mLen > 8 then
    begin
        Str := Str + IntToHex(mLen, 2) + ' : ';
    end;

    for i := 0 to mLen - 1 do
    begin
        Str := Str + IntToHex(mData[i], 2);
        if i < mLen - 1 then
            Str := Str + ', ';
    end;

    if mIntervalMs > 0 then
    begin
        Str := Str + ':' + IntToStr(mIntervalMs);
    end;

    try
        IniFile.WriteString(Section, Ident, Str);
    except
        Result := false;
    end;

end;

procedure TCANFrame.Write(Strings: TStrings);
var
    i, DiffLen: integer;
begin
    if Strings.Count < mLen + 1 then
    begin
        DiffLen := (mLen + 1) - Strings.Count;
        for i := 0 to DiffLen - 1 do
            Strings.Add('');
    end;

    Strings.Strings[0] := IntToHex(mID, 3);

    for i := 0 to mLen - 1 do
        Strings.Strings[i + 1] := IntToHex(mData[i], 2);

end;

{ TCANSignal }
{
  function ReverseBits(Bits: byte): byte; inline;
  const
  LookUpTable: array [byte] of byte = (0, 128, 64, 192, 32, 160, 96, 224, 16, 144, 80, 208, 48, 176, 112, 240, 8, 136, 72, 200, 40, 168, 104, 232, 24, 152, 88, 216, 56, 184, 120, 248, 4, 132, 68, 196,
  36, 164, 100, 228, 20, 148, 84, 212, 52, 180, 116, 244, 12, 140, 76, 204, 44, 172, 108, 236, 28, 156, 92, 220, 60, 188, 124, 252, 2, 130, 66, 194, 34, 162, 98, 226, 18, 146, 82, 210, 50,
  178, 114, 242, 10, 138, 74, 202, 42, 170, 106, 234, 26, 154, 90, 218, 58, 186, 122, 250, 6, 134, 70, 198, 38, 166, 102, 230, 22, 150, 86, 214, 54, 182, 118, 246, 14, 142, 78, 206, 46, 174,
  110, 238, 30, 158, 94, 222, 62, 190, 126, 254, 1, 129, 65, 193, 33, 161, 97, 225, 17, 145, 81, 209, 49, 177, 113, 241, 9, 137, 73, 201, 41, 169, 105, 233, 25, 153, 89, 217, 57, 185, 121, 249,
  5, 133, 69, 197, 37, 165, 101, 229, 21, 149, 85, 213, 53, 181, 117, 245, 13, 141, 77, 205, 45, 173, 109, 237, 29, 157, 93, 221, 61, 189, 125, 253, 3, 131, 67, 195, 35, 163, 99, 227, 19, 147,
  83, 211, 51, 179, 115, 243, 11, 139, 75, 203, 43, 171, 107, 235, 27, 155, 91, 219, 59, 187, 123, 251, 7, 135, 71, 199, 39, 167, 103, 231, 23, 151, 87, 215, 55, 183, 119, 247, 15, 143, 79,
  207, 47, 175, 111, 239, 31, 159, 95, 223, 63, 191, 127, 255);
  begin
  Result := LookUpTable[Bits];
  end;
}
constructor TCANSignal.Create(MsgID: Cardinal; StartByte, StartBit, BitLen, IntervalMs: integer);
begin
    mID := MsgID;
    mStartByte := StartByte;
    mStartBit := StartBit;
    mBitLen := BitLen;
    mIntervalMs := IntervalMs;
    mTC := TTimeChecker.Create(IntervalMs);
end;

constructor TCANSignal.Create(MsgID: Cardinal; StartDBCBit, BitLen: integer; IsMotorolaFmt: boolean; IntervalMs: integer);
begin
    mID := MsgID;

    if IsMotorolaFmt then  // ex> IK/CK : 우하단이 0번 시작 비트
    begin
        mStartByte := 7 - (StartDBCBit div 8);
//        mStartBit := 8 - ((StartDBCBit mod 8) + BitLen);      // IsRevBits = false로 디폴트로 사용할때 차후 삭제!!
        mStartBit := (StartDBCBit mod 8);
    end
    else
    begin             // ex> NX4 : 우상단이 0번
        mStartByte := (StartDBCBit div 8);
        mStartBit := (StartDBCBit mod 8);
    end;
    mBitLen := BitLen;
    mIntervalMs := IntervalMs;
    mTC := TTimeChecker.Create(IntervalMs);
end;

const
    cByteMask: array[0..7] of byte = ($01, $03, $07, $0F, $1F, $3F, $7F, $FF);
    cWordMask: array[0..15] of Word = ($0001, $0003, $0007, $000F, $001F, $003F, $007F, $00FF, $01FF, $03FF, $07FF, $0FFF, $1FFF, $3FFF, $7FFF, $FFFF);

function TCANSignal.GetDataAsWord(Data1, Data2: byte; IsRevBits: boolean): Word;
var
    i, NextBitLen: integer;
    WData: Word;
begin

    if IsRevBits then
    begin
        WData := Data2 or (Data1 shl 8);
        Result := (WData shr (16 - (mStartBit + mBitLen))) and cWordMask[mBitLen - 1];
    end
    else
    begin
        WData := Data1 or (Data2 shl 8);
        Result := (WData shr mStartBit) and cWordMask[mBitLen - 1];
    end;

end;

function TCANSignal.GetData(Data1, Data2: byte; IsRevBits: boolean): byte;
var
    i, NextBitLen: integer;
    WData: Word;
begin

    if IsRevBits then
    begin
        WData := Data2 or (Data1 shl 8);
        Result := (WData shr (16 - (mStartBit + mBitLen))) and cByteMask[mBitLen - 1];
    end
    else
    begin
        WData := Data1 or (Data2 shl 8);
        Result := (WData shr mStartBit) and cByteMask[mBitLen - 1];
    end;

end;

function TCANSignal.GetData(Data: byte; IsRevBits: boolean): byte;
begin
    if IsRevBits then
        Result := (Data shr (8 - (mStartBit + mBitLen))) and cByteMask[mBitLen - 1]
    else
        Result := (Data shr mStartBit) and cByteMask[mBitLen - 1];
end;

function TCANSignal.Is2ByteData: boolean;
begin
    Result := ((mStartBit + mBitLen) mod 8) > 0;
end;

function TCANSignal.IsEmpty: boolean;
begin
    Result := (mID = 0) or (mBitLen = 0);
end;

function TCANSignal.IsExtendedID: boolean;
begin
    Result := BaseCAN.IsExtendedID(mID);
end;

function TCANSignal.Read(var Frame: TCANFrame; IsRevBits: boolean): byte;
var
    i: integer;
begin
    if Is2ByteData then
    begin
        Result := GetData(Frame.mData[mStartByte], Frame.mData[mStartByte + 1], IsRevBits);
    end
    else
    begin
        Result := GetData(Frame.mData[mStartByte], IsRevBits);
    end;
end;

function TCANSignal.ToStr: string;
begin
    Result := Format('%d, %s, %d, %d, %d', [mID, mName, mStartByte, mStartBit, mBitLen]);
end;

function TCANSignal.FromStr(Str: string): boolean;
var
    Tokens: array[0..9] of string;
    TokCount: integer;
begin
    TokCount := ParseByDelimiter(Tokens, 10, Str, ',');
    if TokCount = 5 then
    begin
        mID := StrToInt(Tokens[0]);
        mName := Tokens[1];
        mStartByte := StrToInt(Tokens[2]);
        mStartBit := StrToInt(Tokens[3]);
        mBitLen := StrToInt(Tokens[4]);
    end;

    Result := TokCount = 5;
end;

function TCANSignal.FSMCheckInterval: integer;
begin
    if not mTC.IsStart then
        mTC.Start(mIntervalMs)
    else if mTC.IsTimeOut then
    begin
        mTC.Start(mIntervalMs);
        Exit(1);
    end;
    Result := 0;
end;

function TCANSignal.GetSHLVal(IsRev: boolean): integer;
begin
    if IsRev then
        Result := 8 - mStartBit - mBitLen
    else
        Result := mStartBit;
end;

procedure TCANSignal.Write(var Frame: TCANFrame; Val: byte; IsRevBits: boolean);
var
    ShiftedVal: word;
    Mask: word;
    MaxVal: word;
begin
  // mBitLen에 맞는 최대값 계산
    MaxVal := (1 shl mBitLen) - 1;

  // Val 값이 mBitLen을 초과하면 최대값으로 제한
    if Val > MaxVal then
    begin
        Val := MaxVal;
    end;

    Frame.mID := mID;
    ShiftedVal := Val shl GetSHLVal(IsRevBits);

    if Is2ByteData then
    begin
        Mask := ((1 shl mBitLen) - 1) shl mStartBit;
        Frame.mData[mStartByte] := Frame.mData[mStartByte] or (ShiftedVal and $FF);
        Frame.mData[mStartByte + 1] := Frame.mData[mStartByte + 1] or ((ShiftedVal shr 8) and $FF);
    end
    else
    begin
        Mask := ((1 shl mBitLen) - 1) shl mStartBit;
        Frame.mData[mStartByte] := (Frame.mData[mStartByte] and not Mask) or (ShiftedVal and $FF);
    end;
end;

procedure TCANSignal.Write(var Frame: TCANFrame; OnOff, IsRevBits: boolean);
begin
    Frame.mID := mID;
    if IsRevBits then
    begin
        if OnOff then
            Frame.mData[mStartByte] := BitOn(Frame.mData[mStartByte], 7 - mStartBit)
        else
            Frame.mData[mStartByte] := bitoff(Frame.mData[mStartByte], 7 - mStartBit);
    end
    else
    begin
        if OnOff then
            Frame.mData[mStartByte] := BitOn(Frame.mData[mStartByte], mStartBit)
        else
            Frame.mData[mStartByte] := bitoff(Frame.mData[mStartByte], mStartBit);
    end;

end;

{ TCANSigManager }

var
    gCANSigManager: TCANSigManager;

constructor TCANSigManager.Create;
begin
{$IFDEF _USE_SINGLETON_CAN_MAN}
    if gCANSigManager <> nil then
        Abort
    else
        gCANSigManager := Self;
{$ENDIF}
    mIDDic := TCANIDSigDic.Create;

end;

destructor TCANSigManager.Destroy;
var
    Key: Cardinal;
begin
    if gCANSigManager = Self then
        gCANSigManager := nil;

    for Key in mIDDic.Keys do
    begin
        if Assigned(mIDDic.Items[Key]) then
            mIDDic.Items[Key].Free;
    end;

    inherited;
end;

procedure TCANSigManager.ClearIDDic;
var
    Key: Cardinal;
begin
    for Key in mIDDic.Keys do
    begin
        if Assigned(mIDDic.Items[Key]) then
            mIDDic.Items[Key].Clear;
    end;

end;

function TCANSigManager.Load(FilePath: string): boolean;
var
    SigCount, i: integer;
    Sig: TCANSignal;
    Str: string;
    IniFile: TIniFile;
begin
    if FileExists(FilePath) then
        Exit(false);

    try
        IniFile := TIniFile.Create(FilePath);
        SigCount := IniFile.ReadInteger('SIG.LIST', 'COUNT', 0);
        Clear;
        ClearIDDic;
        for i := 0 to SigCount - 1 do
        begin
            Str := IniFile.ReadString('SIG.LIST', IntToStr(i + 1), '');
            Sig.FromStr(Str);
            Add(Sig.mName, Sig);

            if not mIDDic.ContainsKey(Sig.mID) then
            begin
                mIDDic.Add(Sig.mID, TCANSigList.Create);
            end;
            mIDDic.Items[Sig.mID].Add(Items[Sig.mName]);
        end;

    finally
        IniFile.Free;
    end;

    Result := true;
end;

function TCANSigManager.Save(FilePath: string): boolean;
var
    Key: string;
    i: integer;
    IniFile: TIniFile;
begin
    if FileExists(FilePath) then
        Exit(false);

    try
        IniFile := TIniFile.Create(FilePath);

        IniFile.WriteInteger('SIG.LIST', 'COUNT', Count);
        i := 1;
        for Key in Keys do
        begin
            IniFile.WriteString('SIG.LIST', IntToStr(i), Items[Key].ToStr);
            Inc(i);
        end;

    finally
        IniFile.Free;
    end;

    Result := true;

end;

{ TBaseCAN }

constructor TBaseCAN.Create(IsSelfRun: boolean);
begin

    mOnRead := TMultiCastNotify.Create(Self);
    mOnWrite := TMultiCastNotify.Create(Self);
    mWFrmList := TPCANFrameThList.Create;

    TBaseCAN.mItems.Add(Self);

    mCurRFrame.Clear;

    EnableFD(False);

    mDefaultWriteIntervalMs := 200;

    if IsSelfRun then
    begin
        if not Assigned(gCanThread) then
            gCanThread := TCanThread.Create();

        gCanThread.mState := 0;
        mOwnerFree := true;
        gCanThread.mItems.Add(Self);
        gCanThread.mState := 1;

        if gCanThread.Suspended then
            gCanThread.Start;
    end;
end;

constructor TBaseCAN.Create(CH: integer; IsSelfRun: boolean);
begin
    mCh := CH;
    Create(IsSelfRun)
end;

destructor TBaseCAN.Destroy;
var
    i: integer;
begin

    WQueueing := False;

    if IsOpen then
        Close;

    if Assigned(mOnRead) then // mOnRead를 Flag로 사용..
    begin
        if Assigned(gCanThread) then
            gCanThread.Terminate;
    end;

    if Assigned(mOnRead) then
    begin
        mOnRead.Disable;
        FreeAndNil(mOnRead);
    end;

    if Assigned(mOnWrite) then
    begin
        mOnWrite.Disable;
        FreeAndNil(mOnWrite);
    end;

    if not Assigned(mWFrmList) then
        Exit;

    with mWFrmList.LockList do
    begin
        try
            for i := 0 to Count - 1 do
            begin
                Dispose(Items[i]);
            end;

        finally
            mWFrmList.UnlockList;
            FreeAndNil(mWFrmList);
        end;
    end

end;

function TBaseCAN.EnableFD(Enable: boolean): TBaseCAN;
begin
    mUseFD := Enable;
    Result := Self;
end;

function TBaseCAN.CalcDLC(Len: integer): integer;
begin
    case Len of
        0..8:
            Result := Len;
        9..12:
            Result := 9;
        13..16:
            Result := 10;
        17..20:
            Result := 11;
        21..24:
            Result := 12;
        25..32:
            Result := 13;
        33..48:
            Result := 14;
        49..64:
            Result := 15;
    end;
end;

function TBaseCAN.CalcLen(DLC: integer): integer;
begin
    case DLC of
        0..8:
            Result := 8;
        9:
            Result := 12;
        10:
            Result := 16;
        11:
            Result := 20;
        12:
            Result := 24;
        13:
            Result := 32;
        14:
            Result := 48;
        15:
            Result := 64;
    end;
end;

{
//////////////////////////////
    Standard ID CAN CRC8 계산 조건

    CRC 다항식  : 0x1D
    초기 값     : 0x00
    XOR 값      : 0xFF
    데이터 ID   : 메세지 ID + 0xF800

//////////////////////////////
}

function TBaseCAN.CalcStandardCRC8(StandardID: Word; FrameDatas: array of Byte): Byte;
var
    Buffer: array[0..8] of Byte;
    i, j: integer;
    DataID: Word;
    Polynomial: Byte;
begin
    DataID := StandardID + $F800;

    Polynomial := $1D;

    Buffer[0] := DataID and $FF;
    Buffer[1] := (DataID shr 8) and $FF;

    System.Move(FrameDatas[1], Buffer[2], 7);

    Result := 0;
    for i := 0 to Length(Buffer) - 1 do
    begin
        Result := Result xor Buffer[i];
        for j := 0 to 7 do
        begin
            if (Result and $80) <> 0 then
                Result := (Result shl 1) xor Polynomial
            else
                Result := Result shl 1;
        end;
    end;
    Result := (Result and $FF) xor $FF;
end;

{
//////////////////////////////
    Standard ID CAN(Normal, FD) CRC16 계산 조건

    CRC 다항식  : 0x1021
    초기 값     : 0xFFFF
    XOR 값      : 0x0000(없음)
    데이터 ID   : 메세지 ID + 0xF800

//////////////////////////////
}
function TBaseCAN.CalcStandardCRC16(StandardID: Word; FrameDatas: array of Byte): DWord;
var
    Buffer: array[0..63] of byte;
    i, j: integer;
    DataID: Word;
    Polynomial: Word;
begin
    FillChar(Buffer, Sizeof(Buffer), 0);

    DataID := StandardID + $F800;

    Polynomial := $1021;

    System.Move(FrameDatas[2], Buffer[2], Length(FrameDatas) - 2);

    Buffer[Length(FrameDatas) - 2] := DataID and $FF;
    Buffer[Length(FrameDatas) - 1] := (DataID shr 8) and $FF;

    Result := $FFFF;

    for i := 0 to Length(FrameDatas) - 1 do
    begin
        Result := Result xor (Buffer[i] shl 8);
        for j := 0 to 7 do
        begin
            if ((Result and $8000) <> 0) then
                Result := (Result shl 1) xor Polynomial
            else
                Result := Result shl 1;
        end;
    end;

end;

{
//////////////////////////////
    Extended ID CAN(Normal, FD) CRC16 계산 조건


    Extended ID 추출 :
      예시) Extended ID가 0x08000163 일 때의 계산

          STDID : 0x08000163의 4~6번째 바이트 001을 취해야함.

    이후, StandardCRC16으로 계산하면 됨.

//////////////////////////////
}
function ExtractBytes(Value: Cardinal; StartBit, BitCount: Integer): Cardinal;
begin
    // 오른쪽으로 필요한 만큼 시프트
    Value := Value shr StartBit;

    // 하위 BitCount 비트를 마스크하여 추출
    Result := Value and ((1 shl BitCount) - 1);
end;

function TBaseCAN.CalcExtendedCRC16(ExtendedID: DWord; FrameDatas: array of Byte): DWord;
var
    StandardID: Word;
begin
    StandardID := Word(ExtractBytes(ExtendedID, 8, 12)); // 4 ~ 6번째 바이트를 취하기 위한 마스킹

    Result := CalcStandardCRC16(StandardID, FrameDatas);
end;

procedure TBaseCAN.Close;
begin
//    raise Exception.Create('TBaseCAN.Close 구현 안됨');
end;

function TBaseCAN.Compare(SrcIdx: integer; CmpDatas: array of byte; CmpLen: integer): boolean;
var
    i: integer;
begin
    Result := false;
    if (SrcIdx + CmpLen) > mCurRFrame.mLen then
        Exit;

    for i := 0 to CmpLen - 1 do
    begin
        if Datas[SrcIdx + i] <> CmpDatas[i] then
            Exit;
    end;

    Result := true;

end;

class function TBaseCAN.ItemCount: integer;
begin
    Result := mItems.Count;
end;

function TBaseCAN.GetCfgStr: string;
begin
    Result := Format('BaudRate:%d', [mBaudRate]);

    if mUseFD then
        Result := Result + ' FD';
end;

procedure TBaseCAN.GetDatas(Datas: PByte; Len: integer);
begin
    if Len <= mCurRFrame.mLen then
        Move(mCurRFrame.mData, Datas^, Len);
end;

function TBaseCAN.GetEffectiveWriteInterval(RequestedInterval: Integer): Integer;
begin
    if RequestedInterval <= 0 then
        Result := mDefaultWriteIntervalMs
    else
        Result := Max(1, Min(RequestedInterval, 3000));
end;

function TBaseCAN.GetDatas(Index: integer): byte;
begin
    Result := mCurRFrame.mData[Index];
end;

function TBaseCAN.GetID: Cardinal;
begin
    Result := mCurRFrame.mID;
end;

class function TBaseCAN.GetItems(Index: integer): TBaseCAN;
begin
    Result := mItems[Index];
end;

function TBaseCAN.GetPreset: PCANFDPreset;
begin
    Result := @mPreset;
end;

function TBaseCAN.GetRFrame: PCANFrame;
begin
    Result := @mCurRFrame;
end;

function TBaseCAN.GetWFrames(Index: integer): PCANFrame;
begin
    Result := nil;

    with mWFrmList.LockList do
    begin
        try
            if Index < Count then
                Result := Items[Index];

        finally
            mWFrmList.UnlockList;
        end;
    end;

end;

function TBaseCAN.Write(Frame: TCANFrame): boolean;
begin
    Result := Write(Frame.mID, Frame.mData, Frame.mLen);
end;

function TBaseCAN.WFrameCount: integer;
begin
    with mWFrmList.LockList do
    begin
        try
            Result := Count;
        finally
            mWFrmList.UnlockList;
        end;
    end;
end;

function TBaseCAN.Write(Signal: TCANSignal; Val: byte): boolean;
var
    Frame: TCANFrame;
begin
    Signal.Write(Frame, Val);
    Result := Write(Frame);
end;

function TBaseCAN.WriteAtOffset(const ID: Cardinal; Offset: Integer; PartData: array of Byte): Boolean;
begin
    mCmnFrame.SetDataAtOffset(Offset, PartData);

    Result := Write(mCmnFrame);
end;

function TBaseCAN.Write(const ID: Cardinal; Data: array of byte; UseCRC: boolean; CRCByteLen: Integer): boolean;
var
    CRC: DWord;
begin
    if UseCRC then
    begin
        case CRCByteLen of
            0:
                ;
            1:
                Data[0] := CalcStandardCRC8(ID, Data);
            2:
                begin
                    if IsExtendedID(ID) then
                        CRC := CalcExtendedCRC16(ID, Data)
                    else
                        CRC := CalcStandardCRC16(ID, Data);

                    Data[0] := CRC and $FF;
                    Data[1] := (CRC shr 8) and $FF;
                end;
        end;
    end;

    Result := Write(ID, Data, Length(Data));
end;

function TBaseCAN.WriteFromQueue(const ID: Cardinal; Flags: integer; Data: array of byte; Len: integer): boolean;
begin
    Result := False;
end;

function TBaseCAN.WriteFromQueue(Frame: TCANFrame): boolean;
begin
    Result := WriteFromQueue(Frame.mID, IfThen(Frame.IsExtendedID, 4, 0), Frame.mData, Frame.mLen);
end;

function TBaseCAN.Write(const ID: Cardinal; Data: array of byte; Len: integer): boolean;
begin

    if mWQueueing then
    begin
        if mNextWriteHighPriority then
        begin
            mNextWriteHighPriority := False;
            mQueue.PushFrontWithEvent(TCANQueueItem.Create(Self, TCANFrame.Create(ID, Data, Len), crwtWrite));
        end
        else
            AddToWQueue(Self, TCANFrame.Create(ID, Data, Len));

        Result := True;
    end
    else
        Result := Write(ID, IfThen(IsExtendedID(ID), 4, 0), Data, Len);
end;

function TBaseCAN.WriteNextWFrame: boolean;
begin
    Result := Write(WFrames[mIdx]^);
    mIdx := mIdx mod WFrameCount;
end;

function TBaseCAN.IsCommRun(LimitSec: double): boolean;
begin
    Result := not mCommChkTC.IsTimeOut;
end;

function TBaseCAN.IsOpen: boolean;
begin
    Result := false;
end;

procedure TBaseCAN.WriteWFrameOnce;
begin
    with mWFrmList.LockList do
    begin
        try
            if Count = 0 then
                Exit;

            if Items[mIdx].CheckInterval then
            begin
                Write(Items[mIdx]^);
            end;
            Inc(mIdx);

            mIdx := mIdx mod Count;

        finally
            mWFrmList.UnlockList;
        end;
    end;
end;

procedure TBaseCAN.WriteWFrames;
var
    i: integer;
begin
    if not mEnableWFrameList then
        Exit;

    with mWFrmList.LockList do
    begin
        try
            for i := 0 to Count - 1 do
            begin
                if Items[i].CheckInterval then
                begin
                    Write(Items[i]^);
                end;
            end;

        finally
            mWFrmList.UnlockList;
        end;
    end;
end;

procedure TBaseCAN.Run;
begin

    if not IsOpen then
        Exit;

    if Reads() then
        if not mEnableWFrameList then
            Exit;

    WriteWFrames;

end;

procedure TBaseCAN.SelfRun;
begin
    if Assigned(gCanThread) then
        gCanThread.Start;
end;

procedure TBaseCAN.SelfTest;
begin
end;

class procedure TBaseCAN.RunQueueThread;
var
    QItem: TCANQueueItem;
begin
    if not Assigned(mQueue) then
        mQueue := TTSListEx<TCANQueueItem>.Create;

    TAsyncCalls.Invoke(
        procedure
        begin
            while mRunQueueing do
            begin
                if not mQueue.WaitAndPop(QItem) then
                    break;

                QItem.Execute;

                while mQueue.Pop(QItem) do
                begin
                    QItem.Execute;
                end;
            end;

            FreeAndNil(TBaseCAN.mQueue);

        end).Forget;
end;

procedure TBaseCAN.SetNextWriteHighPriority;
begin
    mNextWriteHighPriority := True;
end;

procedure TBaseCAN.SetPreset(const Value: PCANFDPreset);
begin
    mPreset := Value^;
end;

class procedure TBaseCAN.SetRQueueing(const Value: Boolean);
begin
    if mRQueueing = Value then
        Exit;

    mRQueueing := Value;

    if not mWQueueing and not mRQueueing then
    begin
        mRunQueueing := False;
        mQueue.Close;
    end
    else if (mWQueueing or mRQueueing) and not mRunQueueing then
    begin
        mRunQueueing := True;
        RunQueueThread;
    end;

end;

class procedure TBaseCAN.SetWQueueing(const Value: Boolean);
begin
    if mWQueueing = Value then
        Exit;

    mWQueueing := Value;

    if not mWQueueing and not mRQueueing then
    begin
        mRunQueueing := False;
        mQueue.Close;
    end
    else if (mWQueueing or mRQueueing) and not mRunQueueing then
    begin
        mRunQueueing := True;
        RunQueueThread;
    end;

end;

function TBaseCAN.ToStr: string;
begin
    Result := mCurRFrame.ToStr;
end;

function TBaseCAN.IsWIDExists(MsgID: Cardinal): boolean;
var
    i: integer;
begin
    with mWFrmList.LockList do
    begin
        try
            for i := 0 to Count - 1 do
            begin
                if Items[i].mID = MsgID then
                begin
                    Exit(true);
                end;
            end;

        finally
            mWFrmList.UnlockList;
        end;
    end;

    Result := false;
end;

function TBaseCAN.Open(): boolean;
begin
    //raise Exception.Create('TBaseCAN.Open 구현 안됨');
    Result := Open(mBaudRate);
    if Result then
        gLog.Panel('OPEN BaudRate : %d', [mBaudRate]);
end;

function TBaseCAN.Open(Ch, BaudRate: integer): boolean;
begin
    //raise Exception.Create('TBaseCAN.Open(Ch, BaudRate) 구현 안됨');
    mCh := Ch;
    Result := Open(BaudRate);
end;

function TBaseCAN.OpenFD(Ch, BaudRate: Integer; Preset: TCANFDPreset): Boolean;
begin
    mUseFD := True;
    mPreset := Preset;
    Result := Open(Ch, BaudRate);
end;

function TBaseCAN.Open(BaudRate: integer): boolean;
begin
    raise Exception.Create('TBaseCAN.Open(BaudRate) 구현 안됨');
    Result := false;
end;

procedure TBaseCAN.AddWFrame(Frame: PCANFrame; Enabled: boolean);
begin
    Frame.mEnabled := Enabled;

    if not IsWIDExists(Frame.mID) then
        mWFrmList.Add(Frame);

    mEnableWFrameList := true;

end;

class function TBaseCAN.AddToRQueue(CAN: TBaseCAN; Frame: TCANFrame): Boolean;
begin
    mQueue.PushWithEvent(TCANQueueItem.Create(CAN, Frame, crwtRead));
    Result := True;
end;

class function TBaseCAN.AddToWQueue(CAN: TBaseCAN; Frame: TCANFrame): Boolean;
begin
    mQueue.PushWithEvent(TCANQueueItem.Create(CAN, Frame, crwtWrite));
    Result := True;
end;

function TBaseCAN.AddWFrame(MsgID: Cardinal; Data: TCANData; IntervalMs: integer; Enabled: boolean): PCANFrame;
var
    CANFrame: PCANFrame;
begin
    CANFrame := new(PCANFrame);
    CANFrame^ := TCANFrame.Create(MsgID, Data, IntervalMs);
    CANFrame^.mEnabled := Enabled;

    if not IsWIDExists(MsgID) then
        mWFrmList.Add(CANFrame);

    mEnableWFrameList := true;

    Result := CANFrame;
end;

function TBaseCAN.AddWFrame(MsgID: Cardinal; Data: array of byte; IntervalMs: integer; Enabled: boolean): PCANFrame;
var
    CANFrame: PCANFrame;
begin
    CANFrame := new(PCANFrame);
    CANFrame^ := TCANFrame.Create(MsgID, Data, IntervalMs);
    CANFrame^.mEnabled := Enabled;

    if not IsWIDExists(MsgID) then
        mWFrmList.Add(CANFrame);

    mEnableWFrameList := true;

    Result := CANFrame;
end;

function TBaseCAN.NextWFrame: PCANFrame;
begin
    Result := WFrames[mIdx];
    mIdx := mIdx mod WFrameCount;
end;

procedure TBaseCAN.Read(var Frame: TCANFrame);
begin
    if mRQueueing then
    begin
        mCurRFrame := Frame;  //Queue에 있는 실제 CAN Data를 받아온다
        InternalReads;
    end
    else
    begin
        Frame := mCurRFrame;
    end;
end;

procedure TBaseCAN.Read(var Datas: array of byte);
begin
    Move(mCurRFrame.mData, Datas[0], mCurRFrame.mLen);
end;

procedure TBaseCAN.InternalReads;
begin

    if Assigned(mOnTrans) then
    begin
        mOnTrans(mCurRFrame, false);
    end;

    if Assigned(mOnRead) then
    begin
        mOnRead.DoEvent;
    end;

    if mCurRFrame.mID > 1 then   // PEAK Can ID가 CAN이 미연결시에도 01 ID로 수신될때가 있음, 검토!
        mCommChkTC.Start(1000);

    if mRDebug then
    begin
        gLog.Panel('CH%d Rcv: %s', [mCh, mCurRFrame.ToStr]);
    end;

//    WriteWFrames; // 이 코드 활성시 검증 필요
{
     연속 프레임 쓰기 방법론
     1) 위 코드 활성화
     2) CanRead인 CallBack에서 WriteWFrames
     3) 장치 특화: HVCanCtler에서 AddCyWFrame 유사하게 구현
}
end;

function TBaseCAN.RemoveWFrame(Frame: PCANFrame): boolean;
begin
    Result := true;
    try
        mIdx := 0;
        mWFrmList.Remove(Frame);
        Dispose(Frame);
    finally
        mEnableWFrameList := mWFrmList.Count > 0;
    end;
end;

function TBaseCAN.RemoveWFrame(MsgID: Cardinal): boolean;
var
    i: integer;
    FrameList: TList<PCANFrame>;
begin
    Result := true;
    try
        mIdx := 0;
        FrameList := mWFrmList.LockList;
        for i := 0 to FrameList.Count - 1 do
        begin
            if FrameList.Items[i].mID = MsgID then
            begin
                FrameList.Items[i].mEnabled := false;
                Dispose(FrameList.Items[i]);
                FrameList.Delete(i);
                Exit(true);
                break;
            end;
        end;
    finally

        mEnableWFrameList := FrameList.Count > 0;
        mWFrmList.UnlockList;
    end;

end;

procedure TBaseCAN.InternalWrite(Ret: boolean; const ID: Cardinal; Data: array of BYTE; Len: integer);
var
    TempID: Word;
    SIdx: integer;

    function GetWDataStr: string;
    var
        i: integer;
    begin
        Result := Result + Format('%.x : ', [ID]);
        for i := 0 to Len - 1 do
        begin
            Result := Result + Format('%.2x ', [Data[i]]);
        end;

    end;

begin
    mLastWRet := Ret;

    if Assigned(mOnTrans) then
    begin
        mOnTrans(TCANFrame.Create(ID, Data, Len), true);
    end;

    if Assigned(mOnWrite) then
        mOnWrite.DoEvent;

    if mWDebug then
    begin
        gLog.Panel('CH%d Snd: %s(%s)', [mCH, GetWDataStr, IfThen(Ret, 'OK', 'FAIL')]);
    end;

    if not Ret then
        gLog.Error('CH%d Snd: %s(FAIL)', [mCH, GetWDataStr]);

end;

{ TCanThread }

function TCanThread.Count: integer;
begin
    Result := mItems.Count;
end;

constructor TCanThread.Create(aPriority: TThreadPriority);
begin
    mItems := TCANList.Create;

    inherited Create(false);

    Priority := aPriority;
    FreeOnTerminate := true;
end;

destructor TCanThread.Destroy;
var
    i: integer;
begin
    mState := 0;

    for i := 0 to mItems.Count - 1 do
    begin
        if mItems[i].OwnerFree then
            mItems[i].Free;
    end;

    if Assigned(mItems) then
        FreeAndNil(mItems);

    inherited;
end;

procedure TCanThread.Execute;
var
    Idx: integer;
begin

    if mItems.Count = 0 then
        Exit;

    Idx := 0;
    while not Terminated do
    begin

        case mState of
            0:
                begin

                end;
            1:
                begin

                    mItems[Idx].Run;
                    Inc(Idx);
                    Idx := Idx mod mItems.Count;

                end;
        end;

        Sleep(1);
    end;
end;

function TCanThread.GetItem(Idx: integer): TBaseCAN;
begin
    Result := mItems[Idx];
end;

procedure TCanThread.Start;
begin
    mState := 1;
end;

procedure TCanThread.Stop;
begin
    mState := 0;
end;

{ TSimulCAN }

constructor TSimulCAN.Create(OwnerFree: boolean; IsSelfRun: boolean);
begin
    mOwnerFree := OwnerFree;
    mSimFrameInfos := TSimCANFrameInfoList.Create;
    inherited Create(IsSelfRun);

end;

destructor TSimulCAN.Destroy;
var
    i: integer;
begin

    for i := 0 to mSimFrameInfos.Count - 1 do
    begin
        mSimFrameInfos.Items[i].Free;
    end;

    mSimFrameInfos.Clear;
    mSimFrameInfos.Free;

    inherited;
end;

function TSimulCAN.GetID: Cardinal;
begin
    if mSimFrameInfos.Count > 0 then
        Result := mCurRFrame.mID
    else
        Result := mCanID;
end;

procedure TSimulCAN.Read(var Frame: TCANFrame);
begin
    if mSimFrameInfos.Count > 0 then
    begin
        Frame := mCurRFrame;
        Exit;
    end;

    Frame.mID := mCanID;
    Inc(mCanID);
    mCanID := mCanID mod 5;
    Frame.SetData([1, 2, 3, 4, 5, 6, 7, 8]);

end;

function TSimulCAN.Reads: boolean;
var
    i: integer;
begin
    Result := true;

    if mSimFrameInfos.Count > 0 then
    begin

        if mCurWFrame.mID <> 0 then
        begin
            for i := 0 to mSimFrameInfos.Count - 1 do
            begin
                if mSimFrameInfos[i].mReqFrame.Compare(mCurWFrame) then   // 요청 프레임이 등록 되어 있다면  응답해줌
                begin
                    mCurWFrame.Clear;
                    mCurRFrame := mSimFrameInfos[i].mRespFrame;

                    // TO DO: 가령 멀티 프레임이라면  mSimFrameInfos에 추가하고  1회성 명시하는 요Flag 설정하는 함수 필
                    //AddFrameAsMFrameResp($7AB, [$22, ...]);

                    InternalReads;

                    Exit;
                end;
            end;
        end;

        // 요청 -> 응답쌍이 아닌 일반 Frame 시간 간격으로 전송
        if (mSimFrameInfos[mSimFrmInfoIdx].mRespFrame.mEnabled) and (mSimFrameInfos[mSimFrmInfoIdx].mRespFrame.CheckInterval) then
        begin
            mCurRFrame := mSimFrameInfos[mSimFrmInfoIdx].mRespFrame;
            InternalReads;
        end
        else
        begin
            mCurRFrame.mID := 0;
            mCurRFrame.Clear;

        end;

        Inc(mSimFrmInfoIdx);
        mSimFrmInfoIdx := mSimFrmInfoIdx mod mSimFrameInfos.Count;

    end;
end;

procedure TSimulCAN.SelfTest;
begin
    {
    Ret := mSimFrameInfos[0].mReqFrame.Compare(TCANFrame.Create($797, [4, $31, 3, $12, $A3, 0, 0, 0])) ;
    Ret := mSimFrameInfos[1].mReqFrame.Compare(TCANFrame.Create($797, [4, $31, 3, $12, $A3, 0, 0, 0])) ;
    Ret := mSimFrameInfos[2].mReqFrame.Compare(TCANFrame.Create($797, [4, $31, 3, $12, $A3, 0, 0, 0])) ;
    }
end;

procedure TSimulCAN.SetID(ID: cardinal);
begin
    mCanID := ID;
end;

procedure TSimulCAN.AddSimFrame(ID: cardinal; Data: array of byte; Interval: integer);
var
    FrameInfo: TSimCANFrameInfo;
begin
    FrameInfo := TSimCANFrameInfo.Create;
    FrameInfo.mRespFrame := TCANFrame.Create(ID, Data, Length(Data), Interval);
    FrameInfo.mRespFrame.mEnabled := true;
    mSimFrameInfos.Add(FrameInfo);
end;

procedure TSimulCAN.AddSimFrame(ReqFrame, RespFrame: TCANFrame; ReqFrameMask: byte);
var
    FrameInfo: TSimCANFrameInfo;
begin
    FrameInfo := TSimCANFrameInfo.Create;

    FrameInfo.mReqFrameMask := ReqFrameMask;
    FrameInfo.mReqFrame := ReqFrame;
    RespFrame.mEnabled := false;
    FrameInfo.mRespFrame := RespFrame;

    mSimFrameInfos.Add(FrameInfo);
end;

function TSimulCAN.IsOpen: boolean;
begin
    Result := true;
end;

function TSimulCAN.Open(BaudRate: integer): boolean;
begin

    Result := true;
end;

function TSimulCAN.Open(Ch, BaudRate: integer): boolean;
begin
    Result := true;
end;

function TSimulCAN.Write(const aID: Cardinal; aFlags: integer; aData: array of byte; Count: integer): boolean;
begin
    if mWQueueing then
    begin
        TBaseCAN.AddToWQueue(Self, TCANFrame.Create(aID, aData, mWDelay));
        Exit;
    end;

    mCurWFrame := TCANFrame.Create(aID, aData);
    //gLog.Debug('%s', [mCurWFrame.ToStr]);
    InternalWrite(true, aID, aData, Count);
    Result := true;
end;

function TSimulCAN.WriteFromQueue(const ID: Cardinal; Flags: integer; Data: array of byte; Len: integer): boolean;
begin
    mCurWFrame := TCANFrame.Create(ID, Data);

    InternalWrite(true, ID, Data, Len);
    Result := true;

end;

{ TMulCANFrame }

procedure TMultiCANFrame.Clear;
var
    i: integer;
begin
    // FillChar(mDatas, sizeof(mDatas), 0) ;
    for i := 0 to Length(mDatas) - 1 do
        mDatas[i] := 0;

end;

constructor TMultiCANFrame.Create(ReqID, RspID: Cardinal; FCBlockSize, FCSepTime: byte);
begin
    mReqID := ReqID;
    mRspID := RspID;

    mFCBlockSize := FCBlockSize;
    mFCSepTime := FCSepTime;

    // 블록사이즈란 FC송신 간격 사이에 전송받을 프레임수를 지칭 추정
    // 0으로 설정시 FC 관계없이 보내라는 의미. 단 이런 경우 받을 CF 갯수를 FF의 DataLength에서 계산 해야함.
    mSeqNum := 1;
    mTotSeqNum := mFCBlockSize;

    if mTotSeqNum <> 0 then // 0일때는 FF 수신해서  mDatas 버퍼 생성
        SetLength(mDatas, (mTotSeqNum + 1) * 8); // +1은 FF 저장용

end;

procedure TMultiCANFrame.Deinit;
begin
    mDatas := nil;
end;

{
    REQ: SF
    RES: FF
    REQ: FC
    RES: CF1
    RES: CF2 ...

}

function TMultiCANFrame.FrameType(Data: Byte): TCANFrameType;
begin
    Result := ftSF;

    case Data and $F0 of
        $00:
            Result := ftSF;
        $10:
            Result := ftFF;
        $20:
            begin
                case Data of
                    $21:
                        Result := ftCF1;
                    $22:
                        Result := ftCF2;
                    $23:
                        Result := ftCF3;
                    $24:
                        Result := ftCF4;
                    $25:
                        Result := ftCF5;

                end;
            end;
    end;
end;

function TMultiCANFrame.FSMRun(CAN: TBaseCAN): integer;
var
    TotSeqNum: integer;
begin

    if mDebug and (TBaseCAN.mRDebugLevel = CAN_R_DEBUG_LEVEL0) then
    begin
        gLog.Debug('MCANFrame: CH%d Rcv: %s', [CAN.mCh, CAN.RFrame.ToStr]);
    end;

    if CAN.ID <> mRspID then
        Exit(0);

    case mState of
        0:
            begin
                mType := FrameType(CAN.Datas[0]);
                case CAN.Datas[0] of // PCI(Protocol Ctrl Info.) 체크
                    $10: // First Frame
                        begin
                            mDataLen := ((CAN.Datas[0] and $0F) shl 8) or CAN.Datas[1];
                            TotSeqNum := ((mDataLen - 6) div 7); // CF 갯수 계산, -6은 First Frame 데이터 제외, 7이 분모인것은 PCI(첫번째바이트) 제외

                            if ((mDataLen - 6) mod 7) <> 0 then
                                Inc(TotSeqNum);

                            mSeqNum := 1;
                            {
                            mTotSeqNum := TotSeqNum;
                            CAN.GetDatas(@mDatas[0]);
                        	}
                            if (0 < mTotSeqNum) and (mTotSeqNum >= TotSeqNum) then
                            begin
                                mTotSeqNum := TotSeqNum; // 기존 mTotSeqNum보다 작은 경우 감안해서 받을 프레임 갯수 늘 재설정.
                                CAN.GetDatas(@mDatas[0]);
                            end
                            else
                            begin
                                mDatas := nil;
                                mTotSeqNum := TotSeqNum;
                                SetLength(mDatas, (mTotSeqNum + 1) * 8); // +1은 First Frame 저장용
                                CAN.GetDatas(@mDatas[0]);
                            end;

                            if mDebug then
                                gLog.Debug('CH%d: %X CF(1/%d) 수신 시작: %s', [CAN.mCh, CAN.ID, mTotSeqNum, ToStr]);


                            // Flow Ctrl
                            CAN.SetNextWriteHighPriority;
                            CAN.Write(mReqID, 0, [$30, mFCBlockSize, mFCSepTime, $AA, $AA, $AA, $AA, $AA], 8);
                        end
                else
                    if CAN.Datas[0] = ($20 + mSeqNum) then // Consecutive Frame
                    begin
                        CAN.GetDatas(@mDatas[mSeqNum * 8]);

                        if mSeqNum >= mTotSeqNum then
                        begin
                            if mDebug then
                                gLog.Debug('CH%d: %X CF(%d/%d) 수신 완료(%s): %s', [CAN.mCh, CAN.ID, mSeqNum, mTotSeqNum, GetEnumName(TypeInfo(TCANFrameType), Ord(mType)),
                                    ToStr]);

                            Inc(mState);
                            Exit(1);
                        end;

                        if mDebug then
                            gLog.Debug('CH%d: %X CF(%d/%d) 수신: %s', [CAN.mCh, CAN.ID, mSeqNum, mTotSeqNum, ToStr]);

                        Inc(mSeqNum);
                    end
                    else {if (CAN.Datas[0] and $20) <> $20 then }// Single Frame 단일 프레임; 멀티 프레임 처리 중,  단일 프레임 수신시 완료처리??
                    begin
                        if Length(mDatas) = 0 then
                            SetLength(mDatas, 8);

                        mDataLen := CAN.Datas[0] and $0F;
                        CAN.GetDatas(@mDatas[0]);

                        if mDebug then
                            gLog.Panel('CH%d: %X SF 수신: %s', [CAN.mCh, CAN.ID, ToStr]);

                    end;
                end;
            end;

        1:
            begin
                // 수신 완료 상태.
            end;
    end;

    Result := 0;
end;

procedure TMultiCANFrame.ClearFSM;
begin
    mState := 0;
    mType := ftNone;
end;

procedure TMultiCANFrame.GetDatas(Datas: PByte; Len: integer);
begin
    Move(mDatas[0], Datas^, min(Length(mDatas), Len));
end;

function TMultiCANFrame.GetStateStr: string;
begin
    Result := Format('MultiCANFrame(%X): mState=%d, CF(%d/%d)', [mRspID, mState, mSeqNum, mTotSeqNum]);
end;

function TMultiCANFrame.IsDone: boolean;
begin
    Result := (mState >= 1);
end;

function TMultiCANFrame.ToStr: string;
var
    i: integer;
begin
    Result := Format('%.x', [mRspID]) + ' : ';

    for i := 0 to Length(mDatas) - 1 do
    begin
        Result := Result + Format('%.2x ', [mDatas[i]]);
    end
end;


{ TCANQueueItem }

constructor TCANQueueItem.Create(CAN: TBaseCAN; Frame: TCANFrame; RWType: TCANRWType);
begin
    mRWType := RWType;
    mCAN := CAN;
    mFrame := Frame;

end;

function TCANQueueItem.Execute: Boolean;
begin
    if mRWType = crwtRead then
    begin
        mCAN.Read(mFrame);
        {
         구현하는 쪽에서는
             - Reads에서        RQueueing 에따라 Push
            - Read(Frame)에서  RQueueing = True일시 InternalRead만 호출 구현, 원래 의도인 인자 Frame을 얻기 보다 건네주는 의미
        }
    end
    else
    begin
        Result := mCAN.WriteFromQueue(mFrame);
        if mFrame.mIntervalMs >= 0 then
            Sleep(mCAN.GetEffectiveWriteInterval(mFrame.mIntervalMs));
    end;

end;

initialization

{$IFDEF _USE_SINGLETON_CAN_MAN}
    TCANSigManager.Create;
{$ENDIF}
    TBaseCAN.mItems := TCANList.Create;
    TBaseCAN.mRDebugLevel := CAN_R_DEBUG_LEVEL2;

    if not Assigned(TBaseCAN.mQueue) then
        TBaseCAN.mQueue := TTSListEx<TCANQueueItem>.Create;


finalization
    if Assigned(TBaseCAN.mQueue) then
    begin
        TBaseCAN.mQueue.Clear;
        TBaseCAN.mRunQueueing := False;
        FreeAndNil(TBaseCAN.mQueue);
    end;


{$IFDEF _USE_SINGLETON_CAN_MAN}
    if Assigned(gCANSigManager) then
        gCANSigManager.Free;
{$ENDIF}


    if Assigned(TBaseCAN.mItems) then
    begin
        TBaseCAN.mItems.Clear;
        TBaseCAN.mItems.Free;
    end;

end.

