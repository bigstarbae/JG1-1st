{
    : V.221004.00

    - CallBack함수를 등록하면 주기적으로 호출
    - 일반 프로시져 및 클래스 메소드 프로시져 지원 추가

    : V.230405.00
    - TIntervalCallerManager 추가

    : V.230801.01
    - Bug 수정

    : V.240131.00
    - SubProc/Func 추가: 등록한 메인Proc -> SubProc 연속 호출용
}
unit IntervalCaller;

interface
uses
    TimeChecker, SysUtils, Generics.Collections;

type
    TICFunc = procedure(Sender: TObject) of object;


    PIntervalCaller = ^TIntervalCaller;
    TIntervalCaller = packed record
    private
        mEnabled: boolean;

        mName: string;
        mTC: TTimeChecker;
        mState,
        mInterval: integer;
        mObject:    TObject;

        mFunc, mSubFunc: TICFunc;
        mProc, mSubProc: TProc;

        procedure SetEnabled(const Value: boolean);
        procedure SetInterval(const Value: integer);

    public
        constructor Create(Func: TICFunc; IntervalMSec: integer; Obj: TObject = nil); overload;
        constructor Create(Proc: TProc; IntervalMSec: integer); overload;

        function FSMRun: integer;

        procedure SetSubFunc(SubFunc: TICFunc);
        procedure SetSubProc(SubProc: TProc);

        property Name: string read mName write mName;
        property Enabled: boolean read mEnabled write SetEnabled;
        property Interval: integer read mInterval write SetInterval;


        property SubFunc: TICFunc read mSubFunc write SetSubFunc;
        property SubProc: TProc read mSubProc write SetSubProc;

    end;

    TIntervalCallerManager = class
    private
        mIdx: integer;
        mItems: TDictionary<string, PIntervalCaller>;
        mList:  TList<PIntervalCaller>;
        function GetItems(Key: string): PIntervalCaller;
        function GetList(Idx: integer): PIntervalCaller;
        function GetEnabled: boolean;
        procedure SetEnabled(const Value: boolean);

    public
        constructor Create;
        destructor Destroy; override;

        procedure Run;

        function Count: integer;

        function Add(Key: string; Func: TICFunc; IntervalMSec: integer; Obj: TObject; Enabled: boolean = false): PIntervalCaller; overload;
        function Add(Key: string; Func: TProc; IntervalMSec: integer; Enabled: boolean = false): PIntervalCaller; overload;

        function IsExists(Key: string): boolean;

        property Items[Key: string]: PIntervalCaller read GetItems; default;
        property List[Idx: integer]: PIntervalCaller read GetList;

        property Enabled: boolean read GetEnabled write SetEnabled;

    end;


var
    gICMan: TIntervalCallerManager;


implementation

{ TIntervalCaller }

constructor TIntervalCaller.Create(Func: TICFunc; IntervalMSec: integer; Obj: TObject);
begin
    mFunc := Func;
    mProc := nil;

    mSubFunc := nil;
    mSubProc := nil;

    mInterval := IntervalMSec;
    Enabled := false;

    mObject := Obj;
end;

constructor TIntervalCaller.Create(Proc: TProc; IntervalMSec: integer);
begin
    mFunc := nil;
    mProc := Proc;
    mSubFunc := nil;
    mSubProc := nil;
    mInterval := IntervalMSec;
    Enabled := false;
end;

function TIntervalCaller.FSMRun: integer;
begin
    Result := 0;

    if not mEnabled then
        Exit;

    case mState of
        0:
            begin
                mTC.Start(mInterval);
                Inc(mState);
            end;
        1:
            if mTC.IsTimeOut then
            begin
                if Assigned(mFunc) then
                    mFunc(mObject);

                if Assigned(mProc) then
                    mProc;

                mTC.Start(mInterval);

                if Assigned(mSubFunc) or Assigned(mSubProc) then
                    Inc(mState)
                else
                    Exit(1);
            end;
        2:
            begin
                if mTC.IsTimeOut then
                begin

                    if Assigned(mSubFunc) then
                        mSubFunc(mObject);

                    if Assigned(mSubProc) then
                        mSubProc;

                    mTC.Start(mInterval);
                    Dec(mState);
                    Exit(1);

                end;
            end;
    end;
end;

procedure TIntervalCaller.SetEnabled(const Value: boolean);
begin
    if mEnabled <> Value then
    begin
        mEnabled := Value;
        if mEnabled then
        begin
            if Assigned(mFunc) then
                mFunc(mObject);

            if Assigned(mProc) then
                mProc;
        end;

        mState := 0;
    end;
end;

procedure TIntervalCaller.SetInterval(const Value: integer);
begin
    if Value <> mInterval then
        mInterval := Value;

end;

procedure TIntervalCaller.SetSubFunc(SubFunc: TICFunc);
begin
    mSubFunc := SubFunc;
end;

procedure TIntervalCaller.SetSubProc(SubProc: TProc);
begin
    mSubProc := SubProc;
end;

{ TIntervalCallerManager }

function TIntervalCallerManager.Add(Key: string; Func: TICFunc; IntervalMSec: integer; Obj: TObject; Enabled: boolean): PIntervalCaller;
begin
    Result := GetItems(Key);
    Result.Create(Func, IntervalMSec, Obj);
    Result.Enabled := Enabled;
end;

function TIntervalCallerManager.Add(Key: string; Func: TProc; IntervalMSec: integer; Enabled: boolean): PIntervalCaller;
begin
    Result := GetItems(Key);
    Result.Create(Func, IntervalMSec);
    Result.Enabled := Enabled;
end;

function TIntervalCallerManager.Count: integer;
begin
    Result := mList.Count;
end;

constructor TIntervalCallerManager.Create;
begin
    mItems := TDictionary<string, PIntervalCaller>.Create;
    mList := TList<PIntervalCaller>.Create;
end;

destructor TIntervalCallerManager.Destroy;
var
    Key: string;
begin
    for Key in mItems.Keys do
        Dispose(mItems[Key]);

    mItems.Free;

    mList.Clear;
    mList.Free;

    inherited;
end;

function TIntervalCallerManager.GetEnabled: boolean;
var
    Key: string;
begin
    for Key in mItems.Keys do
        if not mItems[Key].Enabled then
            Exit(false);

    Result := true;
end;

function TIntervalCallerManager.GetItems(Key: string): PIntervalCaller;
begin
    if mItems.ContainsKey(Key) then
        Result := mItems[Key]
    else
    begin
        New(Result);
        Result.mFunc := nil;
        Result.mProc := nil;
        mItems.Add(Key, Result);
        mList.Add(Result);
        Result := mItems[Key];
    end;
end;

function TIntervalCallerManager.GetList(Idx: integer): PIntervalCaller;
begin
    if Idx < mList.Count then
        Result := mList[Idx]
    else
        raise Exception.Create('GetList: Idx가 범위를 벗어남');
end;

function TIntervalCallerManager.IsExists(Key: string): boolean;
begin
    Result := mItems.ContainsKey(Key);
end;

procedure TIntervalCallerManager.Run;
begin
    if mList.Count = 0 then
        Exit;

    mList[mIdx].FSMRun;
    Inc(mIdx);
    mIdx := mIdx mod mList.Count;
end;

procedure TIntervalCallerManager.SetEnabled(const Value: boolean);
var
    Key: string;
begin
    for Key in mItems.Keys do
        mItems[Key].Enabled := Value;
end;

initialization
    gICMan := TIntervalCallerManager.Create;
finalization

    if Assigned(gICMan) then
    begin
        gICMan.Free;
    end;

end.
