unit ResistTester;

{$INCLUDE myDefine.inc}

interface

uses
    BaseAD, DataBox, DataUnit, TimeChecker, BaseFSM;

type
    TResistState = (_RST_IDLE, _RST_INIT, _RST_TESTING, _RST_CONNECT_CHECK,
                    _RST_RETRY, _RST_TEST_END);

    TResistTester = class(TBaseFSM)
    private
        mAT: TBaseAD;
        mOffset: Double;
        mCh: Integer;
        mRetry: Integer;
        mMaxRetry: Integer;
        mTC: TTimeChecker;
        mRSTState: TResistState;
        mResistValue: Double;      // 측정된 저항값 저장
        mCheckResult: Integer;     // 체크 결과 저장

    public
        constructor Create(Ch: Integer; AT: TBaseAD);
        destructor Destroy; override;

        // 내부 메서드
        function GetResist: Double;
        function CheckRightResist: Integer;
        function IsCheckOpenLine: Boolean; overload;
        function IsCheckOpenLine(Resist: double): Boolean; overload;
        procedure DecRetryCnt;
        function IsRemainRetryCnt: Boolean;

        // FSM 메서드
        procedure Init;

        // BaseFSM 오버라이드
        function FSMIRun: integer; override;
        procedure FSMStart; override;
        procedure FSMStop; override;
        procedure ClearFSM; override;
        function GetStateStr(IsSimple: boolean = false): string; override;

        // 속성
        property State: TResistState read mRSTState;
        property RetryCnt: Integer read mRetry;
        property TC: TTimeChecker read mTC write mTC;
        property ResistValue: Double read mResistValue;
        property CheckResult: Integer read mCheckResult;
        property MaxRetry: Integer read mMaxRetry write mMaxRetry;
    end;

const
    RESIST_OK = 1;
    RESIST_NG = -1;
    CONNECT_OPEN = -2;
    OPEN_LINE_VALUE = 2140000;

implementation

uses
    SysUtils;

{ TResistTester }

constructor TResistTester.Create(Ch: Integer; AT: TBaseAD);
begin
    inherited Create('ResistTester', nil);
    mCh := Ch;
    mAT := AT;
    mTC := TTimeChecker.Create(0);
    mRSTState := _RST_IDLE;
    mMaxRetry := 3;
    mResistValue := 0;
    mCheckResult := 0;
end;

destructor TResistTester.Destroy;
begin
    inherited;
end;

procedure TResistTester.Init;
begin
    mOffset := 0;
    mRetry := mMaxRetry;
    mRSTState := _RST_IDLE;
    mResistValue := 0;
    mCheckResult := 0;
end;

procedure TResistTester.ClearFSM;
begin
    inherited;
    mRSTState := _RST_IDLE;
    mRetry := mMaxRetry;
    mResistValue := 0;
    mCheckResult := 0;
end;

procedure TResistTester.FSMStart;
begin
    inherited;
    if mRSTState = _RST_IDLE then
    begin
        mRSTState := _RST_INIT;
        mRetry := mMaxRetry;
    end;
end;

procedure TResistTester.FSMStop;
begin
    inherited;
    mRSTState := _RST_IDLE;
end;

function TResistTester.GetStateStr(IsSimple: boolean): string;
const
    StateStr: array[TResistState] of string = (
        'IDLE', 'INIT', 'TESTING', 'CONNECT_CHECK',
        'RETRY', 'TEST_END'
    );
begin
    if IsSimple then
        Result := Format('%s: %s[%d]', [mName, StateStr[mRSTState], mState])
    else
        Result := Format('%s: State=%s[%d], SubState=%d',
                        [mName, StateStr[mRSTState], mState, mSubState]);
end;

procedure TResistTester.DecRetryCnt;
begin
    Dec(mRetry);
end;

function TResistTester.GetResist: double;
begin
{$IFDEF VIRTUALIO}
    Result := (2.2 + random(30) * 0.01) - (random(30) * 0.01);
{$ELSE}
    Result := mAT.GetValue(mCh) + mOffset;
{$ENDIF}
end;

function TResistTester.IsCheckOpenLine: Boolean;
begin
    Result := False;
    if abs(GetResist()) > OPEN_LINE_VALUE then
        Result := True;
end;

function TResistTester.IsCheckOpenLine(Resist: double): Boolean;
begin
    Result := False;
    if abs(Resist) > OPEN_LINE_VALUE then
        Result := True;
end;

function TResistTester.IsRemainRetryCnt: Boolean;
begin
    Result := mRetry >= 0;
end;

function TResistTester.CheckRightResist: Integer;
begin
    mResistValue := GetResist();

    if IsCheckOpenLine(mResistValue) then
    begin
        Result := CONNECT_OPEN;
        Exit;
    end;

    // 여기서는 단순히 저항값만 체크하고 OK/NG 판정은 외부에서 처리
    // 임시로 범위 체크만 수행 (실제 판정 로직은 외부에서)
    if (mResistValue >= 2.0) and (mResistValue <= 2.5) then
        Result := RESIST_OK
    else
        Result := RESIST_NG;
end;

function TResistTester.FSMIRun: integer;
begin
    Result := 0;    // 진행중

    case mRSTState of
        _RST_IDLE:
            begin
                // IDLE 상태에서는 아무것도 하지 않음
            end;

        _RST_INIT:
            begin
                mTC.Start(200);
                mRSTState := _RST_TESTING;
            end;

        _RST_TESTING:
            begin
                if not mTC.IsTimeOut() then
                    Exit;

                mCheckResult := CheckRightResist();
                case mCheckResult of
                    RESIST_OK:
                        begin
                            mRSTState := _RST_TEST_END;
                        end;

                    RESIST_NG:
                        begin
                            mRSTState := _RST_RETRY;
                        end;

                    CONNECT_OPEN:
                        begin
                            mRSTState := _RST_CONNECT_CHECK;
                        end;
                end;
            end;

        _RST_CONNECT_CHECK:
            begin
                if not IsCheckOpenLine() then
                begin
                    mRSTState := _RST_RETRY;
                    mTC.Start(200);
                end;
            end;

        _RST_RETRY:
            begin
                if IsRemainRetryCnt() then
                begin
                    mRSTState := _RST_TESTING;
                    DecRetryCnt();
                    mTC.Start(200);
                end
                else
                begin
                    // 재시도 횟수 초과
                    mRSTState := _RST_TEST_END;
                end;
            end;

        _RST_TEST_END:
            begin
                mRSTState := _RST_IDLE;
                SetState(FSM_STATE_DONE);
                Result := 1;  // 완료
            end;

    end;
end;

end.
