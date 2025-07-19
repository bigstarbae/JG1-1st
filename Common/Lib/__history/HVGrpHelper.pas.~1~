unit HVGrpHelper;

interface

uses
    Windows, sysutils, {$IFNDEF VER150}FileCtrl,{$ENDIF}Classes, Messages,
    FaGraphEx, TimeChecker, Range, Graphics;

Type
    THVGrpHelper = Class

    private
        mIsStart : boolean;
        mGraph : TFaGraphEx;
        mTimeSpec : TRange;
        mCurrSpec : TRange;
        mTC : TTimeChecker;
        mCurrAxisRuler : TFaAxisRuler;
        procedure ReRangeScale(Curr, Offset : double);
        procedure InitScale(CurrAxisMax: double = 0);
        function InitAxisRuler(AxisRuler: TFaAxisRuler; Min, Max, Step: double; Caption: String): TFaAxisRuler;

    public
        constructor Create(Fgraph : TFaGraphEx);
        destructor Destroy;
        procedure Init(Fgraph : TFaGraphEx);
        procedure Clear();
        procedure SetSpec(TimeSpec, CurrSpec: TRange); overload;
        procedure SetSpec(CurrSpec: TRange); overload;
        procedure SetTimeSpecMin;
        procedure SetTimeSpecMax;
        procedure SetCurrAutoScale(Offset: double);
        procedure SetCurrAxisMax(Max: double);
        procedure Add(SWState : boolean; Curr: double);
        procedure FaGraphBeforePaint(Sender : TObject);
        procedure Start;
        procedure Stop;

        function Save(FilePath : String): boolean;
        function Load(FilePath : String): boolean;

        property IsStart : boolean Read mIsStart;
    End;

//    THVDevType = (hvdHeatDrv, hvdHeatAss, hvdVentDrv, hvdVentAss); //To Do HVTester 사용시엔 주석처리 해줘야함!! 필수!!

    TFaGRAPH_ORD = (faHDrv, faHAss, faVDrv, faVAss, faLiftR1, faLiftR1_NOISE,
    faSlide2, faSlide2_NOISE, faLiftF2, faLiftF2_NOISE, faLiftR2, faLiftR2_NOISE,
    faCpk1, faCpk2);

implementation

{ THVGrpHelper }

procedure THVGrpHelper.Add(SWState : boolean; Curr: double);
var
    Value, Sec : double;
begin
    if not mIsStart then Exit;

    if SWState then
    begin
        Value := 1.0;
    end
    else
        Value := 0;

    ReRangeScale(Curr, 2);
    Sec := mTC.GetPassTimeAsSec;

    mGraph.AddData([0], [Sec], [Value]);
    mGraph.AddData([1], [Sec], [Curr]);
end;

procedure THVGrpHelper.Clear();
begin
    mGraph.Empty;
    Init(mGraph);
end;

constructor THVGrpHelper.Create(Fgraph : TFaGraphEx);
begin
    Init(FGraph);
end;

destructor THVGrpHelper.Destroy;
begin
//
end;

procedure THVGrpHelper.FaGraphBeforePaint(Sender: TObject);
var
    dTm: double ;
    Rect: TRect ;
    PenColor,
    BrushColor: TColor ;
    TmpCanvas: TCanvas ;
begin
    //if mTimeSpec.mMin <> 0 then
    begin
        With Sender as TFaGraphEx do
        begin
            GetCanvas(TmpCanvas);
            GetX(0, mTimeSpec.mMin, Rect.Left);
            GetX(0, mTimeSpec.mMax, Rect.Right);
            GetY(1, mCurrSpec.mMin, Rect.Bottom) ; //Index 값은 시리즈 번호를 뜻함(0번이 시간, 1번이 전류)
            GetY(1, mCurrSpec.mMax, Rect.Top);  //todo Index값을 찾아놓자... 왜 1번일때 제대로 나오나?????
            PenColor  := TmpCanvas.Pen.Color ;
            BrushColor:= TmpCanvas.Brush.Color ;
            TmpCanvas.Brush.Color := $00BFFFFF ;
            TmpCanvas.Pen.Color   := $00BFFFFF ;
            TmpCanvas.FillRect(Rect);

            TmpCanvas.Brush.Color := BrushColor ;
            TmpCanvas.Pen.Color := PenColor ;
        end;
    end
   //else
       // Exit;
end;

procedure THVGrpHelper.Init(Fgraph: TFaGraphEx);
begin
    mGraph := Fgraph;

    if mGraph.Axis.Count = 3 then
    begin
        InitScale();
    end
    else if mGraph.Axis.Count = 0 then
    begin
        mGraph.GridStyle := psDot;
        mGraph.MaxDatas := 1000000;
        mGraph.Zoom := True;
        InitAxisRuler(mGraph.Axis.Add, 0, 10, 1, 'Time(Sec)').Align := aaBottom;
        InitAxisRuler(mGraph.Axis.Add, -1, 2, 1, 'DI').Align := aaLeft;
        mCurrAxisRuler := mGraph.Axis.Add;
        InitAxisRuler(mCurrAxisRuler, 0, 10, 1, 'Curr(A)').Align := aaRight;
    end
    else
        Exit;

    if Fgraph.Series.Count = 0 then
    begin
        Fgraph.Series.Add.Visible := True;
        Fgraph.Series.Items[Fgraph.Series.Count - 1].AxisX := 0;
        Fgraph.Series.Items[Fgraph.Series.Count - 1].AxisY := 1;
        Fgraph.Series.Items[Fgraph.Series.Count - 1].ShareX := 0;
        Fgraph.Series.Items[Fgraph.Series.Count - 1].ShareY := 1;
        Fgraph.Series.Items[Fgraph.Series.Count - 1].LineColor := clRed;

        Fgraph.Series.Add.Visible := True;
        Fgraph.Series.Items[Fgraph.Series.Count - 1].AxisX := 0;
        Fgraph.Series.Items[Fgraph.Series.Count - 1].AxisY := 2;
        Fgraph.Series.Items[Fgraph.Series.Count - 1].ShareX := 0;
        Fgraph.Series.Items[Fgraph.Series.Count - 1].ShareY := 2;
        Fgraph.Series.Items[Fgraph.Series.Count - 1].LineColor := clBlue;
        mGraph.ZoomSerie := 1;
    end;

    mGraph.OnBeforePaint := FaGraphBeforePaint;
end;

function THVGrpHelper.InitAxisRuler(AxisRuler: TFaAxisRuler; Min, Max,
  Step: double; Caption: String): TFaAxisRuler;
begin
    AxisRuler.Min := Min;
    AxisRuler.Max := Max;
    AxisRuler.Step := Step;
    AxisRuler.Caption := Caption;
    AxisRuler.ShowSubTick := False;

    Result := AxisRuler;
end;

procedure THVGrpHelper.InitScale(CurrAxisMax : double);
var
    i : integer;
begin
    for I := 0 to mGraph.Axis.Count - 1 do
    begin
        if mGraph.Axis.Items[i].Align = aaLeft then
        begin
            mCurrAxisRuler := mGraph.Axis.Items[i];
            mCurrAxisRuler.Min := 0;
            mCurrAxisRuler.Decimal := 1;
            if CurrAxisMax = 0 then
            begin
                mCurrAxisRuler.Max := 6;
                mCurrAxisRuler.Step := 1;
            end
            else
            begin
                SetCurrAxisMax(CurrAxisMax);
            end;
            break;
        end
        else if mGraph.Axis.Items[i].Align = aaBottom then
        begin
            mGraph.Axis.Items[i].Min := 0;
            mGraph.Axis.Items[i].Max := 6;
            mGraph.Axis.Items[i].Step := 1;  //todo align 위치 찾으면 그때 이닛
        end;
    end;
end;

function THVGrpHelper.Load(FilePath: String): boolean;
begin
    Result := False;
end;

function THVGrpHelper.Save(FilePath: String): boolean;
begin
    Result := False;
end;

procedure THVGrpHelper.ReRangeScale(Curr, Offset: double);
begin
    if not Assigned(mCurrAxisRuler) then Exit;

    if Curr > mCurrAxisRuler.Max then
    begin
         mCurrAxisRuler.Max := Curr + Offset;
    end;
end;

procedure THVGrpHelper.SetSpec(TimeSpec, CurrSpec: TRange);
begin
    mTimeSpec := TimeSpec;
    mCurrSpec := CurrSpec;
end;

procedure THVGrpHelper.SetCurrAutoScale(Offset: double);
var
    i : integer;
    Val : double;
    Max : double;
begin
    Max := -9999;

    for I := 0 to mGraph.FSdShare.GetMaxIndex(1) - 1 do
    begin
        mGraph.FSdShare.GetData(1, i, Val);
        if Val > Max then
        begin
            Max := Val;
        end;
    end;

    mCurrAxisRuler.Max := Max + Offset;

    if mCurrAxisRuler.Max < 2 then
        mCurrAxisRuler.Decimal := 1;

    mCurrAxisRuler.Step := mCurrAxisRuler.Max / 5;
end;

procedure THVGrpHelper.SetCurrAxisMax(Max: double);
begin
    mCurrAxisRuler.Max := Round(Max + 0.5);
    mCurrAxisRuler.Step := mCurrAxisRuler.Max / 5;
end;

procedure THVGrpHelper.SetSpec(CurrSpec: TRange);
begin
    mCurrSpec := CurrSpec;
end;

procedure THVGrpHelper.SetTimeSpecMax;
begin
    mTimeSpec.mMax := mTc.GetPassTimeAsSec;
end;

procedure THVGrpHelper.SetTimeSpecMin;
begin
    mTimeSpec.mMin := mTc.GetPassTimeAsSec;
end;

procedure THVGrpHelper.Start;
begin
    mGraph.Empty;
    InitScale(mCurrAxisRuler.Max);
    mIsStart := True;
    mTC.Start;
end;

procedure THVGrpHelper.Stop;
begin
    mIsStart := False;
    mTC.Stop;
    mGraph.Invalidate;
end;

end.
