unit HorzGauge;

interface

uses
    Windows, Types, SysUtils, Variants, Classes, Graphics, Controls,
    Generics.Collections, ExtCtrls;

type
    THorzGaugeArea = record
        StartValue: Integer;
        EndValue: Integer;
        AreaColor: TColor;
    end;

    TTickMark = (tmBoth, tmTop, tmBottom);

    TTickStyle = (tsNone, tsRegular, tsThick);

    THorzGauge = class(TGraphicControl)
    private
        FMinValue: Integer;
        FMaxValue: Integer;
        FPosition: Integer;
        FTickMarks: TTickMark;
        FTickStyle: TTickStyle;
        FTickInterval: Integer;

        FThumbWidth: Integer;
        FBarColor, FBackgroundColor: TColor;
        FThumbColor: TColor;
        FThumbBlinkColor: TColor;
        FAreaList: TList<THorzGaugeArea>;
        FThumbBlinkTimer: TTimer;
        FThumbBlinkVisible: Boolean;
        FOnChange: TNotifyEvent;
        procedure SetMinValue(Value: Integer);
        procedure SetMaxValue(Value: Integer);
        procedure SetPosition(Value: Integer);
        procedure SetTickMarks(Value: TTickMark);
        procedure SetTickStyle(Value: TTickStyle);

        procedure SetThumbWidth(Value: Integer);
        procedure SetBackgroundColor(Value: TColor);
        procedure SetThumbColor(Value: TColor);
        procedure SetThumbBlinkColor(Value: TColor);
        procedure ThumbBlinkTimerEvent(Sender: TObject);
        procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
        procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
        procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
        procedure Paint; override;
        procedure SetTickInterval(const Value: Integer);
        procedure SetBarColor(const Value: TColor);
        function IsInArea: Boolean;
    protected
        procedure Change; dynamic;
    public
        constructor Create(AOwner: TComponent); override;
        destructor Destroy; override;

        procedure AddArea(StartValue, EndValue: Integer; AreaColor: TColor);
        procedure RemoveArea(Index: Integer);

    published
        property MinValue: Integer read FMinValue write SetMinValue default 0;
        property MaxValue: Integer read FMaxValue write SetMaxValue default 100;
        property Position: Integer read FPosition write SetPosition default 0;
        property TickMarks: TTickMark read FTickMarks write SetTickMarks default tmBoth;
        property TickStyle: TTickStyle read FTickStyle write SetTickStyle default tsRegular;
        property TickInterval: Integer read FTickInterval write SetTickInterval default 10;

        property ThumbWidth: Integer read FThumbWidth write SetThumbWidth default 20;
        property BarColor: TColor read FBarColor write SetBarColor default clBtnFace;
        property BackgroundColor: TColor read FBackgroundColor write SetBackgroundColor default clWhite;
        property ThumbColor: TColor read FThumbColor write SetThumbColor default clBtnFace;
        property ThumbBlinkColor: TColor read FThumbBlinkColor write SetThumbBlinkColor default clRed;
        property OnChange: TNotifyEvent read FOnChange write FOnChange;
    end;

implementation

uses
    URect;

{ THorzGauge }

constructor THorzGauge.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);
    ControlStyle := ControlStyle + [csReplicatable, csOpaque];
    Width := 400;
    Height := 42;
    FMinValue := 0;
    FMaxValue := 100;
    FPosition := 0;
    FTickMarks := tmTop;
    FTickStyle := tsRegular;
    FTickInterval := 10;

    FThumbWidth := 5;
    FBarColor := clWhite;
    FBackgroundColor := clBtnFace;
    FThumbColor := clBlue;
    FThumbBlinkColor := clRed;
    FAreaList := TList<THorzGaugeArea>.Create;
    FThumbBlinkTimer := TTimer.Create(nil);
    FThumbBlinkTimer.Interval := 500;
    FThumbBlinkTimer.OnTimer := ThumbBlinkTimerEvent;
    FThumbBlinkTimer.Enabled := False;
end;

destructor THorzGauge.Destroy;
begin
    FThumbBlinkTimer.Free;
    FAreaList.Free;
    inherited Destroy;
end;

procedure THorzGauge.SetBackgroundColor(Value: TColor);
begin
    if Value <> FBackgroundColor then
    begin
        FBackgroundColor := Value;
        Invalidate;
    end;

end;

procedure THorzGauge.SetBarColor(const Value: TColor);
begin
    if Value <> FBarColor then
    begin
        FBarColor := Value;
        Invalidate;
    end;
end;

procedure THorzGauge.SetMaxValue(Value: Integer);
begin
    if Value <> FMaxValue then
    begin
        FMaxValue := Value;
        Invalidate;
    end;
end;

procedure THorzGauge.SetMinValue(Value: Integer);
begin
    if Value <> FMinValue then
    begin
        FMinValue := Value;
        Invalidate;
    end;
end;

procedure THorzGauge.SetPosition(Value: Integer);
begin
    if Value <> FPosition then
    begin
        FPosition := Value;
        FThumbBlinkTimer.Enabled := IsInArea;
        if not FThumbBlinkTimer.Enabled then
            FThumbBlinkVisible := False;

        Change;
        Invalidate;
    end;

end;

procedure THorzGauge.SetThumbColor(Value: TColor);
begin
    if Value <> FThumbColor then
    begin
        FThumbColor := Value;
        Invalidate;
    end;
end;

procedure THorzGauge.SetThumbWidth(Value: Integer);
begin
    if Value <> FThumbWidth then
    begin
        FThumbWidth := Value;
        Invalidate;
    end;

end;

procedure THorzGauge.SetTickInterval(const Value: Integer);
begin
    if Value <> FTickInterval then
    begin
        FTickInterval := Value;
        Invalidate;
    end;
end;

procedure THorzGauge.SetTickMarks(Value: TTickMark);
begin
    if Value <> FTickMarks then
    begin
        FTickMarks := Value;
        Invalidate;
    end;

end;

procedure THorzGauge.SetTickStyle(Value: TTickStyle);
begin
    if Value <> FTickStyle then
    begin
        FTickStyle := Value;
        Invalidate;
    end;

end;

procedure THorzGauge.SetThumbBlinkColor(Value: TColor);
begin
    if Value <> FThumbBlinkColor then
    begin
        FThumbBlinkColor := Value;
        Invalidate;
    end;
end;

procedure THorzGauge.AddArea(StartValue, EndValue: Integer; AreaColor: TColor);
var
    Area: THorzGaugeArea;
begin
    Area.StartValue := StartValue;
    Area.EndValue := EndValue;
    Area.AreaColor := AreaColor;
    FAreaList.Add(Area);
    Invalidate;
end;

procedure THorzGauge.RemoveArea(Index: Integer);
begin
    if (Index >= 0) and (Index < FAreaList.Count) then
    begin
        FAreaList.Delete(Index);
        Invalidate;
    end;
end;

procedure THorzGauge.ThumbBlinkTimerEvent(Sender: TObject);
begin
    FThumbBlinkVisible := not FThumbBlinkVisible;
    Invalidate;
end;

procedure THorzGauge.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
    Area: THorzGaugeArea;
begin
    inherited;
    if Button = mbLeft then
    begin
        SetPosition(Round(FMinValue + (FMaxValue - FMinValue) * (X / Width)));
        for Area in FAreaList do
        begin
            if (FPosition >= Area.StartValue) and (FPosition <= Area.EndValue) then
            begin
                FThumbBlinkTimer.Enabled := True;
                Exit;
            end;
        end;
        FThumbBlinkTimer.Enabled := False;
    end;
end;

function THorzGauge.IsInArea: Boolean;
var
    Area: THorzGaugeArea;
begin
    for Area in FAreaList do
    begin
        if (FPosition >= Area.StartValue) and (FPosition <= Area.EndValue) then
        begin
            FThumbBlinkTimer.Enabled := True;
            Exit(True);
        end;
    end;
    Result := False;
end;

procedure THorzGauge.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
    inherited;
    if ssLeft in Shift then
    begin
        SetPosition(Round(FMinValue + (FMaxValue - FMinValue) * (X / Width)));
    end;
end;

procedure THorzGauge.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
    Area: THorzGaugeArea;
begin
    inherited;
    if Button = mbLeft then
    begin
        SetPosition(Round(FMinValue + (FMaxValue - FMinValue) * (X / Width)));
    end;
end;

procedure THorzGauge.Paint;
var
    R: TRect;
    TextHMargin, TextVMargin, TickCount, I: Integer;
    TickStep: Single;
    TickText: string;
    Area: THorzGaugeArea;
    Ratio: Double;
begin
    inherited Paint;

    R := ClientRect;

    Canvas.Brush.Color := FBackgroundColor;
    Canvas.FillRect(R);

    TextHMargin := Round(Canvas.TextHeight('0'));
    TextVMargin := Round(Canvas.TextHeight('1'));

    InflateRect(R, -TextHMargin, 0);

    case FTickMarks of
        tmBoth, tmBottom:
            begin
                R.Top := R.Top + TextVMargin;
                R.Bottom := R.Bottom - Round(TextVMargin * 1.5);
            end;
        tmTop:
            begin
                R.Top := R.Top + Round(TextVMargin * 1.5);
                R.Bottom := R.Bottom - TextVMargin
            end;
    end;

  // Draw background
    Canvas.Brush.Color := FBarColor;
    Canvas.FillRect(R);

  // Draw areas
    Ratio := R.Width / (FMaxValue - FMinValue);

    for Area in FAreaList do
    begin
        Canvas.Brush.Color := Area.AreaColor;
        Canvas.FillRect(Rect(R.Left + Round((Area.StartValue - FMinValue) * Ratio), R.Top, R.Left + Round((Area.EndValue - FMinValue) * Ratio), R.Bottom));
    end;

    Canvas.Brush.Color := clGray;
    Canvas.FrameRect(Rect(R.Left, R.Top, R.Right + 1, R.Bottom));

  // Draw ticks
    if FTickStyle <> tsNone then
    begin

        TickCount := Abs(FMaxValue - FMinValue);
        TickStep := R.Width / TickCount;

        SetBkMode(Canvas.Handle, TRANSPARENT);
        Canvas.Pen.Color := clBlack;
        for I := 0 to TickCount do
        begin
            if (I mod FTickInterval = 0) then
            begin
                if FTickMarks = tmBoth then
                begin
                    Canvas.MoveTo(R.Left + Round(I * TickStep), R.Top);
                    Canvas.LineTo(R.Left + Round(I * TickStep), R.Top + 10);
                    Canvas.MoveTo(R.Left + Round(I * TickStep), R.Bottom);
                    Canvas.LineTo(R.Left + Round(I * TickStep), R.Bottom - 10);
                    TickText := IntToStr(Round(FMinValue + I * (FMaxValue - FMinValue) / TickCount));
                    Canvas.TextOut(R.Left + Round(I * TickStep) - Canvas.TextWidth(TickText) div 2, R.Bottom + 5, TickText);
                end
                else if FTickMarks = tmTop then
                begin
                    Canvas.MoveTo(R.Left + Round(I * TickStep), R.Top);
                    Canvas.LineTo(R.Left + Round(I * TickStep), R.Top + 10);
                    TickText := IntToStr(Round(FMinValue + I * (FMaxValue - FMinValue) / TickCount));
                    Canvas.TextOut(R.Left + Round(I * TickStep) - Canvas.TextWidth(TickText) div 2, R.Top - 20, TickText);
                end
                else if FTickMarks = tmBottom then
                begin
                    Canvas.MoveTo(R.Left + Round(I * TickStep), R.Bottom);
                    Canvas.LineTo(R.Left + Round(I * TickStep), R.Bottom - 10);
                    TickText := IntToStr(Round(FMinValue + I * (FMaxValue - FMinValue) / TickCount));
                    Canvas.TextOut(R.Left + Round(I * TickStep) - Canvas.TextWidth(TickText) div 2, R.Bottom + 5, TickText);
                end;
            end;
        end;
    end;

    if FTickMarks in [tmBottom, tmBoth] then
    begin
        Canvas.Polygon([Point(R.Left + Round((FPosition - FMinValue) * Ratio),
        R.Top - 1),
        Point(R.Left + Round((FPosition - FMinValue) * Ratio) - 5, R.Top - 11),
        Point(R.Left + Round((FPosition - FMinValue) * Ratio) + 5, R.Top - 11)]);
    end
    else if FTickMarks = tmTop then
    begin
        Canvas.Polygon([Point(R.Left + Round((FPosition - FMinValue) * Ratio), R.Bottom + 1),
            Point(R.Left + Round((FPosition - FMinValue) * Ratio) - 5, R.Bottom + 11),
            Point(R.Left + Round((FPosition - FMinValue) * Ratio) + 5, R.Bottom + 11)]);
    end;


    // Draw thumb
    if FThumbBlinkVisible then
        Canvas.Brush.Color := FThumbBlinkColor
    else
        Canvas.Brush.Color := FThumbColor;

    Canvas.FillRect(Rect(R.Left + Round((FPosition - FMinValue) * Ratio) - FThumbWidth div 2, R.Top, R.Left + Round((FPosition - FMinValue) * Ratio) + FThumbWidth div 2, R.Bottom));

end;

procedure THorzGauge.Change;
begin
    if Assigned(FOnChange) then
        FOnChange(Self);
end;

end.

