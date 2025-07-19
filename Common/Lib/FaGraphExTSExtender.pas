{
    Ver.211030.00
    - FaGraphEx Thread Safe 기능 Wrapper
    - 기존 FAGrpThreadSafeHelper에서 이름 변경
}
unit FaGraphExTSExtender;

interface

uses
    FaGraphEx, Generics.Collections, MMTimer, TimeChecker, ExtCtrls, TSQueue,
    BaseFSM;

type
    TFAGrpData = packed record
        mSeriesIdx: integer;

        mX, mY: double;

        constructor Create(SeriesIdx: integer; X, Y: double);
    end;

    TFAGrpDataQueue = TTSQueue<TFAGrpData>;

    TFaGraphExTSExtender = class;

    TFaGraphExTSExtenders = array of TFaGraphExTSExtender;

    TFaGraphExTSExtender = class(TBaseFSM)
    protected
        mGraph: TFaGraphEx;
        mQueue: TFAGrpDataQueue;
        mInterval: double;
        mTC: TAccTimeChecker;

        class var
            mMMTimer: TTimer;

        class var
            mGrps: TFaGraphExTSExtenders;

        procedure TimerEventHandler(Sender: TObject);

    public
        constructor Create(Graph: TFaGraphEx; Interval: double = 5);
        destructor Destroy; override;

        procedure Add(SeriesIdx: integer; X, Y: double); overload;
        procedure Add(SeriesIdx: array of integer; X: double; Y: array of double); overload;
        procedure Add(SeriesIdx: array of integer; X, Y: array of double); overload;

        procedure Flush;
        procedure AddToGrp;
        procedure Clear;

        function IsEmpty: Boolean;

        class procedure StopTimer; static;

        property Graph: TFaGraphEx read mGraph write mGraph;
        property Interval: double read mInterval write mInterval; // Data Add interval

    end;

implementation

uses
    SysUtils, Classes, Log;

{ TFaGraphExTSExtender }

procedure TFaGraphExTSExtender.Clear;
begin
    mGraph.Empty;
    mQueue.Clear;
end;

constructor TFaGraphExTSExtender.Create(Graph: TFaGraphEx; Interval: double);
begin

    mGraph := Graph;

    mQueue := TFAGrpDataQueue.Create;

    if not Assigned(mMMTimer) then
    begin
        mMMTimer := TTimer.Create(nil);

        mMMTimer.OnTimer := TimerEventHandler;
        mMMTimer.Interval := 40;
    end;

    mMMTimer.Enabled := false;

    SetLength(mGrps, Length(mGrps) + 1);
    mGrps[Length(mGrps) - 1] := self;

    mInterval := Interval;
    mTC.Start(mInterval);

    mMMTimer.Enabled := true;



end;

destructor TFaGraphExTSExtender.Destroy;
begin

    mGraph := nil;
    if Assigned(mMMTimer) then
    begin
        mMMTimer.Enabled := false;
        mMMTimer.Free;
        mMMTimer := nil;
        mGrps := nil;
    end;

    if Assigned(mQueue) then
    begin
        mQueue.Clear;
        FreeAndNil(mQueue);
    end;

    inherited;
end;

procedure TFaGraphExTSExtender.Flush;
begin
    TThread.Synchronize(nil,
        procedure
        begin
            AddtoGrp;
            mGraph.Repaint;
        end);
end;

function TFaGraphExTSExtender.IsEmpty: Boolean;
begin
    Result := mQueue.Count <= 0;
end;

procedure TFaGraphExTSExtender.Add(SeriesIdx: integer; X, Y: double);
var
    Data: TFAGrpData;
begin
    if not mTC.IsTimeOut then
    begin
        Exit;
    end;

    mTC.Start(mInterval);

    Data := TFAGrpData.Create(SeriesIdx, X, Y);
    mQueue.Enqueue(Data);
end;

procedure TFaGraphExTSExtender.Add(SeriesIdx: array of integer; X, Y: array of double);
var
    i: integer;
    Data: TFAGrpData;
begin

    if not mTC.IsTimeOut then
    begin
        Exit;
    end;

    mTC.Start(mInterval);

    for i := 0 to Length(SeriesIdx) - 1 do
    begin
        Data := TFAGrpData.Create(SeriesIdx[i], X[i], Y[i]);
        mQueue.Enqueue(Data);
    end;

end;

procedure TFaGraphExTSExtender.Add(SeriesIdx: array of integer; X: double; Y: array of double);
var
    i: integer;
    Data: TFAGrpData;
begin
    if not mTC.IsTimeOut then
    begin
        Exit;
    end;

    mTC.Start(mInterval);

    for i := 0 to Length(SeriesIdx) - 1 do
    begin
        Data := TFAGrpData.Create(SeriesIdx[i], X, Y[i]);
        mQueue.Enqueue(Data);
    end;

end;

procedure TFaGraphExTSExtender.AddToGrp;
var
    Data: TFAGrpData;
begin
    if mQueue.Count = 0 then
        Exit;

    while mQueue.Count > 0 do
    begin
        Data := mQueue.Dequeue;
        with Data do
        begin
            mGraph.AddData([mSeriesIdx], [mX], [mY]);
        end
    end;
end;

class procedure TFaGraphExTSExtender.StopTimer;
begin
    mMMTimer.Enabled := false;
end;

procedure TFaGraphExTSExtender.TimerEventHandler(Sender: TObject);
var
    i: integer;
begin
    for i := 0 to Length(mGrps) - 1 do
    begin
        mGrps[i].AddToGrp;
    end;

end;

{ TFAGrpData }

constructor TFAGrpData.Create(SeriesIdx: integer; X, Y: double);
begin
    mSeriesIdx := SeriesIdx;
    mX := X;
    mY := Y;
end;

end.

