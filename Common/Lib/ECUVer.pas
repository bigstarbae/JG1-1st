unit ECUVer;

interface
uses
    Classes, BaseFSM, BaseCAN, TimeChecker;

type
    TECUVerType = (evtHkmcSW, evtOemSW, evtOemHW, evtDBC, evtPartNo, evtSW);

    TECUVerCmd = packed record
        mType:      TECUVerType;
        mVal:       byte;
        mIsDone:    boolean;

        constructor Create(AType: TECUVerType; Val: byte);
    end;

    TECUVerCmds = array of TECUVerCmd;

    TBaseECUVer = class(TBaseFSM)
    protected

        mReqID, mRespID:     cardinal;

        mVerStrings: array[TECUVerType] of string;


    public
        constructor Create(ReqID, RespID: cardinal);

        function FSMRead: integer; virtual; abstract;

        property HkmcSW: string read mVerStrings[evtHkmcSW];
        property SW: string read mVerStrings[evtSW];
        property OemSW: string read  mVerStrings[evtOemSW];
        property OemHW: string read  mVerStrings[evtOemHW];
        property DBC: string read  mVerStrings[evtDBC];
        property PartNo: string read  mVerStrings[evtPartNo];
    end;



    TCanECUVer = class(TBaseECUVer)
    protected
        mCAN:           TBaseCAN;

        mReqFrame:      TCANFrame;
        mRespFrame:     TMultiCANFrame;

        mReqCmds:       TECUVerCmds;
        mIdx:           integer;

        mCurVerType:    TECUVerType;

        mTC:            TTimeChecker;

        mEnabled:        Boolean;

        procedure CanRead(Sender: TObject); virtual;

        procedure ClearRespData;
        procedure ParseFromFrame(VerType: TECUVerType; var Frame: TMultiCanFrame);

    public
        constructor Create(CAN: TBaseCAN; ReqID, RespID: cardinal; ReqTypes: array of TECUVerType); overload;
        destructor  Destroy; override;

        function FSMRead: integer; override;

        procedure InitID(ReqID, RespID: cardinal);
        procedure InitReqItems(ReqTypes: array of TECUVerType);

        property Enabled: Boolean Read mEnabled Write mEnabled;

    end;

implementation
uses
    Log, SysUtils;

{ TBaseECUVer }

constructor TBaseECUVer.Create(ReqID, RespID: cardinal);
begin
    mReqID := ReqID;
    mRespID := RespID;
end;


{ TCanECUVer }


constructor TCanECUVer.Create(CAN: TBaseCAN; ReqID, RespID: cardinal; ReqTypes: array of TECUVerType);
var
    i: Integer;
    ReqCmds: TECUVerCmds;

begin

    mCAN := CAN;
    mCAN.OnRead.SyncAdd(CanRead);


    InitID(ReqID, RespID);
    InitReqItems(ReqTypes);

    mReqFrame.mData[0] := $03;          // LEN
    mReqFrame.mData[1] := $22;          // Service ID
    mReqFrame.mData[2] := $F1;          // RDBI(Fix)
    mReqFrame.mData[3] := $87;          // RDBI
    mReqFrame.mData[4] := $AA;
    mReqFrame.mData[5] := $AA;
    mReqFrame.mData[6] := $AA;
    mReqFrame.mData[7] := $AA;

    mReqFrame.mLen := 8;

    inherited Create(ReqID, RespID);

end;

procedure TCanECUVer.InitID(ReqID, RespID: cardinal);
begin
    mReqFrame.mID := ReqID;
    mRespFrame := TMultiCANFrame.Create(ReqID, RespID);
end;

procedure TCanECUVer.InitReqItems(ReqTypes: array of TECUVerType);
var
    i: Integer;

    function GetDefVal: byte;
    begin
        case ReqTypes[i] of
            evtSW:              Result := $B1;
            evtOemSW:           Result := $95;
            evtOemHW:           Result := $93;
            evtDBC:             Result := 0;
            evtPartNo:          Result := $87;    // $87
            evtHkmcSW:          Result := $A0;
        else
            Result := 0;
        end;
    end;
begin
    SetLength(mReqCmds, Length(ReqTypes));
    for i := 0 to Length(mReqCmds) - 1 do
    begin
        mReqCmds[i] := TECUVerCmd.Create(ReqTypes[i], GetDefVal);
    end;
end;

procedure TCanECUVer.ClearRespData;
begin
    mRespFrame.ClearFSM;
    mRespFrame.Clear;
end;

destructor TCanECUVer.Destroy;
begin
    //mCAN.OnRead.SyncRemove(CanRead);
    mReqCmds := nil;

    inherited;
end;

procedure TCanECUVer.CanRead(Sender: TObject);

begin
    if (mState = 0) or not mEnabled  then
        Exit;


    mRespFrame.FSMRun(mCAN);
end;

function IsASCCodeNumber(CharVal:AnsiChar) : Boolean;
begin
    Result := False;
    if ((Byte(CharVal) >= $30) and (Byte(CharVal) <= $39)) then
    begin
        Result := True;
        exit;
    end;
end;
function IsASCCodeAlphabet(CharVal:AnsiChar) : Boolean;
begin
    Result := False;
    if ((Byte(CharVal) >= $41)) and (Byte(CharVal) <= $5A) then
    begin
        Result := True;
        exit;
    end;
    if ((Byte(CharVal) >= $61) and (Byte(CharVal) <= $7A)) then
    begin
        Result := True;
        exit;
    end;
end;

function ExtractNumAndAlphabet(Str:AnsiString):AnsiString;    //의도 ECU 버전읽을때 마지막에 100? 이런식으로 물은표가 뜬금없이 나와서 제거를 위한코드
var
    i: Integer;
begin

    for i := 1 to Length(Str) do
    begin
        if IsASCCodeNumber(Str[i]) or IsASCCodeAlphabet(Str[i]) or (byte(Str[i]) = $2E{.}) then
        begin
            Str[i] := Str[i];
        end
        else
        begin
            Str[i] := AnsiChar($0);
        end;

    end;
    Result := Str;

end;

function TCanECUVer.FSMRead: integer;
    function IsRespDone: boolean;
    begin
        Result := false;

//        gLog.Debug('RSP:%s', [mRespFrame.ToStr]);
        case mRespFrame.mType of
            ftSF:
                begin
                    Result := mReqFrame.mData[3] = mRespFrame.mDatas[3];
//                     gLog.Debug('SF: %s', [BoolToStr(Result, true)]);
                end;

            ftCF1, ftCF2:
                begin
                    Result :=  mReqFrame.mData[3] = mRespFrame.mDatas[4];
//                    gLog.Debug('CF: %s', [BoolToStr(Result, true)]);
                end;

        end;
    end;

    function ExtractVerStr: AnsiString;
    var
        Str: AnsiString;
    begin
        case mRespFrame.mType of
            ftSF:
                begin
                    SetString(Result, PAnsiChar(@mRespFrame.mDatas[4]), 4);
                    Result := ExtractNumAndAlphabet(Result);

                    //gLog.Debug('SF:%s', [mRespFrame.ToStr]);
                end;

            ftCF1, ftCF2:
                begin
                    SetString(Result, PAnsiChar(@mRespFrame.mDatas[5]), 3);
                    SetString(Str, PAnsiChar(@mRespFrame.mDatas[9]), mRespFrame.DataLen);
                    Result := ExtractNumAndAlphabet(Result + Str);

                    //gLog.Debug('CF:%s', [mRespFrame.ToStr]);
                end;

        end;
    end;

begin
    Result := 0;
    case mState of
        0:
            begin
                mIdx := 0;
                Inc(mState);
            end;
        1:
            begin
                if mIdx >= Length(mReqCmds) then
                begin
                    mState := 0;
                    Exit(1);
                end;
                mCurVerType := mReqCmds[mIdx].mType;
                mReqFrame.mData[3] := mReqCmds[mIdx].mVal;

                mVerStrings[mCurVerType] := '';

                ClearRespData;
                mCAN.Write(mReqFrame);

                //gLog.Debug('REQ:%s', [mReqFrame.ToStr]);

                mTC.Start(3000);
                Inc(mIdx);
                Inc(mState);
            end;
        2:
            begin

                if IsRespDone then
                begin
                    mVerStrings[mCurVerType] := ExtractVerStr;
                    gLog.Panel('ECU INFO %s',[mVerStrings[mCurVerType]]);

                    Inc(mState);
                    mTC.Start(300);
                end;

                if mTC.IsTimeOut then
                begin
                    mState := 0;
                    Exit(-1);   // Retry 여부?
                end;
            end;
        3:
            begin
                if mTC.IsTimeOut then
                    mState := 1;
            end;

    end;
end;


procedure TCanECUVer.ParseFromFrame(VerType: TECUVerType; var Frame: TMultiCanFrame);
var
    i: Integer;

    function DataToStr(var Datas: array of byte; Len: integer): string;
    var
        Idx: integer;
    begin
        Idx := 0;

        while  Datas[Idx] <> $AA do
        begin
            Result := Char(Datas[Idx]);
            Inc(Idx);
            if Idx >= Len then
                break;
        end;
    end;
begin
    if Frame.mDataLen <= 7 then // Single Frame
    begin
        mVerStrings[VerType] := DataToStr(Frame.mDatas[4], 4);
    end
    else
    begin
        mVerStrings[VerType] := DataToStr(Frame.mDatas[5], 3);      // FF
        for i := 1 to Frame.mTotSeqNum do
        begin
            mVerStrings[VerType] := mVerStrings[VerType] + DataToStr(Frame.mDatas[i * 8 + 1], 7);  // CF
        end;
    end;
end;

{ TECUVerCmd }

constructor TECUVerCmd.Create(AType: TECUVerType; Val: byte);
begin
    mType := AType;
    mVal := Val;
    mIsDone := false;
end;

initialization


end.
