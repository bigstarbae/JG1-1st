unit ValueGenerator;

interface
uses
    Windows, SysUtils, Variants, Classes, TeEngine, TeeProcs, Chart, Generics.Collections,
    Series, IniFiles, TimeChecker;

type
    PSimVal = ^TSimVal;

    TSimVal = record
        X, Y: Double;
    end;

    TSimValList = TList<PSimVal>;

    TValueGenerator = class
    private
        mTC: TTimeChecker;
        mVals: TSimValList;

        procedure Load(const FileName: string);
        function CalculateBezier(t: Double; P0, P1, P2, P3: TSimVal): TSimVal;
        function GetCount: Integer;
        function Split(const S: string; const Delimiter: Char): TSimVal;
        function GetVals(Idx: Integer): TSimVal;
        procedure SetVals(Idx: Integer; const Value: TSimVal);

    public
        constructor Create;
        destructor Destroy; override;

        procedure Clear;
        procedure Add(Val: TSimVal);
        procedure Delete(Idx: Integer);

        procedure Assign(SrcVG: TValueGenerator);

        procedure SetZeroX(Val: Double);
        procedure SetZeroY(Val: Double);
        procedure SetScaleMax(MaxX, MaxY: Double);

        function  GetVal(const X: Double; var Y: Double): Boolean;
        procedure UpdateChart(AChart: TChart);

        procedure ReadFromIni(IniFile: TIniFile; const Section: string);
        procedure WriteToIni(IniFile: TIniFile; const Section: string);
        procedure LoadFromIni(const FileName: string; const Section: string);
        procedure SaveToIni(const FileName: string; const Section: string);


        property Count: Integer read GetCount;
        property Vals[Idx: Integer]: TSimVal read GetVals write SetVals; default;
    end;

implementation
uses
    Math;

{ TValueGenerator }

procedure TValueGenerator.Clear;
var
    i: Integer;
begin
    for i := 0 to Count - 1 do
        Dispose(mVals[i]);

    mVals.Clear;
end;

constructor TValueGenerator.Create;
begin
    inherited;

    mVals := TSimValList.Create;

end;

procedure TValueGenerator.Delete(Idx: Integer);
begin
    mVals.Delete(Idx);
end;

destructor TValueGenerator.Destroy;
begin
    Clear;

    mVals.Free;

    inherited;
end;

procedure TValueGenerator.Load(const FileName: string);
var
    F: TextFile;
    S: string;
    P: PSimVal;
begin
    AssignFile(F, FileName);
    Reset(F);
    try
        Clear;
        while not Eof(F) do
        begin
            ReadLn(F, S);
            New(P);
            if TryStrToFloat(Copy(S, 1, Pos(',', S) - 1), P.X) and TryStrToFloat(Copy(S, Pos(',', S) + 1, Length(S)), P.Y) then
            begin
                mVals.Add(P);
            end;
        end;
    finally
        CloseFile(F);
    end;
end;

function TValueGenerator.Split(const S: string; const Delimiter: Char): TSimVal;
var
    DelimiterPos: Integer;
    XStr, YStr: string;
begin
    DelimiterPos := Pos(Delimiter, S);
    if DelimiterPos > 0 then
    begin
        XStr := Copy(S, 1, DelimiterPos - 1);
        YStr := Copy(S, DelimiterPos + 1, Length(S) - DelimiterPos);
        Result.X := StrToFloatDef(XStr, 0); // X
        Result.Y := StrToFloatDef(YStr, 0); // Y
    end
    else
    begin
    // 기본값 설정
        Result.X := 0;
        Result.Y := 0;
    end;
end;

procedure TValueGenerator.LoadFromIni(const FileName: string; const Section: string);
var
    IniFile: TIniFile;

begin
    IniFile := TIniFile.Create(FileName);
    try
        ReadFromIni(IniFile, Section);
    finally
        IniFile.Free;
    end;
end;


procedure TValueGenerator.ReadFromIni(IniFile: TIniFile; const Section: string);
var
    i, ValCount: Integer;
    Values: string;
begin
    mVals.Clear;
    ValCount := IniFile.ReadInteger(Section, 'Count', 0);

    for i := 0 to ValCount - 1 do
    begin
        Values := IniFile.ReadString(Section, Format('P%d', [i]), '');
        Add(Split(Values, ','));
    end;
end;

procedure TValueGenerator.SaveToIni(const FileName: string; const Section: string);
var
    IniFile: TIniFile;

begin
    IniFile := TIniFile.Create(FileName);
    try
        WriteToIni(IniFile, Section);
    finally
        IniFile.Free;
    end;
end;

procedure TValueGenerator.SetVals(Idx: Integer; const Value: TSimVal);
begin
    if Idx < Count then
        mVals[Idx]^ := Value
    else
        raise Exception.Create('TValueGenerator.SetVals Idx 범위 벗어남');
end;

procedure TValueGenerator.SetScaleMax(MaxX, MaxY: Double);
var
    i: Integer;
    ScaleX, ScaleY, RealMaxY: Double;
begin
    if (MaxX <= 0) or (MaxY <= 0) then
        raise Exception.Create('Scale max values must be positive');

    SetZeroX(mVals[0].X);
    SetZeroY(mVals[0].Y);

    RealMaxY := -999999;
    for i := 0 to Count - 1 do
    begin
        if mVals[i].Y > RealMaxY then
            RealMaxY := mVals[i].Y;
    end;

    ScaleX := MaxX / mVals[Count - 1].X;
    ScaleY := MaxY / RealMaxY;

    for i := 0 to Count - 1 do
    begin
        mVals[i].X := mVals[i].X * ScaleX;
        mVals[i].Y := mVals[i].Y * ScaleY;
    end;

end;

procedure TValueGenerator.SetZeroX(Val: Double);
var
    i: Integer;
begin
    for i := 0 to Count - 1 do
    begin
        mVals[i].X := mVals[i].X - Val;
    end;
end;

procedure TValueGenerator.SetZeroY(Val: Double);
var
    i: Integer;
begin
    for i := 0 to Count - 1 do
    begin
        mVals[i].Y := mVals[i].Y - Val;
    end;
end;

procedure TValueGenerator.Add(Val: TSimVal);
var
    PVal: PSimVal;
begin
    New(PVal);
    PVal^ := Val;
    mVals.Add(PVal);
end;

procedure TValueGenerator.Assign(SrcVG: TValueGenerator);
var
    i: Integer;
begin
    Clear;
    for i := 0 to SrcVG.Count - 1 do
        Add(SrcVG[i]);
end;

function TValueGenerator.CalculateBezier(t: Double; P0, P1, P2, P3: TSimVal): TSimVal;
begin
    Result.X := Power(1 - t, 3) * P0.X + 3 * Power(1 - t, 2) * t * P1.X + 3 * (1 - t) * Power(t, 2) * P2.X + Power(t, 3) * P3.X;

    Result.Y := Power(1 - t, 3) * P0.Y + 3 * Power(1 - t, 2) * t * P1.Y + 3 * (1 - t) * Power(t, 2) * P2.Y + Power(t, 3) * P3.Y;
end;

function TValueGenerator.GetCount: Integer;
begin
    Result := mVals.Count;
end;

function TValueGenerator.GetVals(Idx: Integer): TSimVal;
begin
    if Idx < Count then
        Result := mVals[Idx]^
    else
        raise Exception.Create('TValueGenerator.GetVals Idx 범위 벗어남');

end;

function TValueGenerator.GetVal(const X: Double; var Y: Double): Boolean;
var
    I, StartIndex: Integer;
    t: Double;
    P0, P1, P2, P3, BezierPoint: TSimVal;
begin
    Result := True;
  // Find the interval where X falls
    StartIndex := -1;
    for I := 0 to Count - 2 do
    begin
        if (X >= mVals[I].X) and (X <= mVals[I + 1].X) then
        begin
            StartIndex := I;
            Break;
        end;
    end;

    if StartIndex = -1 then
    begin
    // X is out of range, return the Y of the closest point
        if X < mVals[0].X then
            Y := mVals[0].Y
        else
        begin
            Y := mVals[Count - 1].Y;
            Result := False;
        end;
    end
    else
    begin
    // Calculate Bezier curve
        P0 := mVals[StartIndex]^;
        P3 := mVals[StartIndex + 1]^;

    // Calculate control points (you may want to adjust this for smoother curves)
        P1.X := P0.X + (P3.X - P0.X) / 3;
        P1.Y := P0.Y;
        P2.X := P0.X + 2 * (P3.X - P0.X) / 3;
        P2.Y := P3.Y;

    // Calculate t (0 <= t <= 1)
        t := (X - P0.X) / (P3.X - P0.X);

    // Get point on Bezier curve
        BezierPoint := CalculateBezier(t, P0, P1, P2, P3);

        Y := BezierPoint.Y;
    end;
end;

procedure TValueGenerator.UpdateChart(AChart: TChart);
var
    I: Integer;
    LineSeries: TLineSeries;
    PointSeries: TPointSeries;
    X, Y: Double;
    BezierSeries: TLineSeries;
begin
    AChart.SeriesList.Clear;

  // Create series for Bezier curve
    BezierSeries := TLineSeries.Create(AChart);
    BezierSeries.ParentChart := AChart;
    BezierSeries.Title := 'Bezier Curve';


  // Create series for original points
    PointSeries := TPointSeries.Create(AChart);
    PointSeries.ParentChart := AChart;
    PointSeries.Title := 'Original Points';
    PointSeries.Pointer.Style := psCircle;

  // Add original points and calculate Bezier curve
    for I := 0 to Count - 1 do
    begin
        PointSeries.AddXY(mVals[I].X, mVals[I].Y);

        if I < Count - 1 then
        begin
            X := mVals[I].X;
            while X <= mVals[I + 1].X do
            begin
                if not GetVal(X, Y) then
                    Exit;

                BezierSeries.AddXY(X, Y);
                X := X + (mVals[I + 1].X - mVals[I].X) / 100; // 100 points between each original point

            end;
        end;
    end;

    AChart.Repaint;
end;


procedure TValueGenerator.WriteToIni(IniFile: TIniFile; const Section: string);
var
    i: Integer;
begin
    IniFile.WriteInteger(Section, 'Count', Count);
    for i := 0 to Count - 1 do
    begin
        IniFile.WriteString(Section, Format('P%d', [i]), Format('%.2f,%.2f', [mVals[i].X, mVals[i].Y]));
    end;
end;

end.
