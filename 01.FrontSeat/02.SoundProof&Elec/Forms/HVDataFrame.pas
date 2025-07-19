unit HVDataFrame;

interface

uses
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, LedArray, ExtCtrls, StdCtrls, Label3D, TransparentPanel, TeEngine,
    Series, TeeProcs, Chart, TimeChecker, HVTester;

type
    THVDatFrame = class(TFrame)
        lblPosName: TLabel;
        pnlCurr: TPanel;
        Label28: TLabel3D;
        lblOnCurr: TLabel3D;
        lblOffCurr: TLabel3D;
        Label29: TLabel3D;
        Label30: TLabel3D;
        lblOnCurrSpec: TLabel3D;
        lblOffCurrSpec: TLabel3D;
        Label3D2: TLabel3D;
        Label3D3: TLabel3D;
        pnlLed: TPanel;
        lblLoLed: TLabel3D;
        ledHI: TLedArray;
        ledLo: TLedArray;
        ledOff: TLedArray;
        lbl1DanLedDec: TLabel3D;
        lblOffLedDec: TLabel3D;
        lbl2DanLedDec: TLabel3D;
        pnlHeader: TPanel;
        lbl3DanLedDec: TLabel3D;
        LedHiLo: TLedArray;
        chtAD: TChart;
        FastLineSeries6: TFastLineSeries;
        tmrPoll: TTimer;
        lblVentSensor: TLabel3D;
        pnlTOP1: TPanel;
        pnlTOP2: TPanel;
        pnlTOP3: TPanel;
        procedure tmrPollTimer(Sender: TObject);
        procedure lblPosNameDblClick(Sender: TObject);
    private
    { Private declarations }
        mLeds: array[0..3] of TLedArray;
        mLblLedDecs: array[0..3] of TLabel3D;
        mCurrState: integer;
        mJudgeOnlyMode: Boolean;
        mPnlOverlays: array[0..2] of TTransparentPanel;

        mHVCtrler: TBaseHVCtrler;
        mTC: TTimeChecker;

    public
    { Public declarations }
        constructor Create(AOwner: TComponent); override;

        procedure Init(HVCtrler: TBaseHVCtrler);

        procedure Clear;

        procedure EnableOpacity(Value: Boolean);

        procedure StartLed(Step: integer);
        procedure StartOnCurr;
        procedure StartOffCurr;

        procedure SetLed(Step: integer; Value: byte; IsOK: boolean);
        procedure SetOnCurrStr(CurrStr: string; IsOK: boolean);
        procedure SetOffCurrStr(CurrStr: string; IsOK: boolean);
        procedure SetCurrSpec(OnSpecStr, OffSpecStr: string);
        procedure SetVentSensor(IsOK: boolean);

        procedure VisibleVentSensor(Visible: boolean);

        procedure ClearValue;

        procedure DisplayCurr(Curr: double);

        procedure SetPosName(Name: string);

        procedure ActiveUI(Active: Boolean);

    end;

implementation

uses
    Math, Global, URect;

{$R *.dfm}

function CenterRect(OuterRect, InnerRect: TRect): TRect;
var
    OffsetX, OffsetY: Integer;
begin
    OffsetX := (OuterRect.Width - InnerRect.Width) div 2;
    OffsetY := (OuterRect.Height - InnerRect.Height) div 2;

    Result := InnerRect;
    Windows.OffsetRect(Result, OuterRect.Left + OffsetX, OuterRect.Top + OffsetY);
end;

{ TFmsHVData }

constructor THVDatFrame.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);

    mLeds[0] := ledOff;
    mLeds[1] := ledLo;
    mLeds[2] := ledHi;
    mLeds[3] := ledHiLo;

    mLblLedDecs[0] := lblOffLedDec;
    mLblLedDecs[1] := lbl1DanLedDec;
    mLblLedDecs[2] := lbl2DanLedDec;
    mLblLedDecs[3] := lbl3DanLedDec;

    mPnlOverlays[0] := TTransparentPanel.Create(Self);
    mPnlOverlays[0].Parent := pnlHeader;
    mPnlOverlays[0].BoundsRect := pnlHeader.BoundsRect;

    mPnlOverlays[1] := TTransparentPanel.Create(Self);
    mPnlOverlays[1].Parent := pnlCurr;
    mPnlOverlays[1].Align := alClient;

    mPnlOverlays[2] := TTransparentPanel.Create(Self);
    mPnlOverlays[2].Parent := pnlLed;
    mPnlOverlays[2].Align := alClient;

    EnableOpacity(False);
end;

const
    COLOR_LED_BK = $00E3E3E3;

procedure THVDatFrame.ClearValue;

    procedure ClearLbl(ALabel: TLabel3D);
    begin
        with ALabel do
        begin
            Caption := '';
            Color := clWhite;
            Font.Color := clGray;
        end;
    end;

var
    i: integer;
begin
    ClearLbl(lbl3DanLedDec);
    ClearLbl(lbl2DanLedDec);
    ClearLbl(lbl1DanLedDec);
    ClearLbl(lblOffLedDec);

    ledHiLo.OnOff := 0;
    ledHI.OnOff := 0;
    ledLo.OnOff := 0;
    ledOff.OnOff := 0;

    for i := 0 to 3 do
    begin
        mLeds[i].OnOff := 0;
        ClearLbl(mLblLedDecs[i]);
    end;

end;

procedure THVDatFrame.ActiveUI(Active: Boolean);
begin
    if Active then
        lblPosName.Color := $000080FF
    else
        lblPosName.Color := $00493F3D;
end;

procedure THVDatFrame.Clear;

    procedure ClearLbl(ALabel: TLabel3D);
    begin
        with ALabel do
        begin
            Caption := '';
            Color := clWhite;
            Font.Color := clGray;
        end;

        tmrPoll.Enabled := False;

    end;

    procedure ClearColor(ALabel: TLabel3D);
    begin
        with ALabel do
        begin
            Color := clWhite;
            Font.Color := clGray;
        end;

        tmrPoll.Enabled := False;

    end;

var
    i: integer;
begin
    lblOnCurrSpec.Caption := '-';
    lblOffCurrSpec.Caption := '-';

    ClearLbl(lblOnCurr);
    ClearLbl(lblOffCurr);

    ClearLbl(lbl3DanLedDec);
    ClearLbl(lbl2DanLedDec);
    ClearLbl(lbl1DanLedDec);
    ClearLbl(lblOffLedDec);

    ClearColor(lblVentSensor);

    for i := 0 to 3 do
    begin
        mLeds[i].OnOff := 0;
        mLeds[i].OnColor := clLime;
        ClearLbl(mLblLedDecs[i]);
        mLblLedDecs[i].Color := COLOR_LED_BK;
    end;

end;

procedure THVDatFrame.SetCurrSpec(OnSpecStr, OffSpecStr: string);
begin
    lblOnCurrSpec.Caption := OnSpecStr;
    lblOffCurrSpec.Caption := OffSpecStr;
end;

procedure SetDecLbl(Lbl: TLabel3D; LblStr: string; Dec: boolean); overload;
begin
    Lbl.Caption := LblStr;

    if Dec then
    begin
        Lbl.Font.Color := clWhite;
        Lbl.Color := COLOR_OK;
    end
    else
    begin
        Lbl.Font.Color := clWhite;
        Lbl.Color := COLOR_NG;
    end;
end;

procedure SetDecLbl(Lbl: TLabel3D; Dec: boolean); overload;
begin
    if Dec then
    begin
        Lbl.Caption := 'OK';
        Lbl.Font.Color := clWhite;
        Lbl.Color := COLOR_OK;
    end
    else
    begin
        Lbl.Caption := 'NG';
        Lbl.Font.Color := clWhite;
        Lbl.Color := COLOR_NG;
    end;
end;

procedure SetDecLed(Led: TLedArray; Lbl: TLabel3D; IsOK: boolean); overload;
begin
    if IsOK then
    begin
        Lbl.Color := COLOR_LED_BK;
        Led.OnColor := clLime;
    end
    else
    begin
        Lbl.Color := COLOR_NG;
        Led.OnColor := clLime;
    end;
end;

procedure THVDatFrame.SetLed(Step: integer; Value: byte; IsOK: boolean);
var
    Lbl: TLabel3D;
begin
    Step := Min(3, Step);
    mLeds[Step].OnOff := Value;

    if mJudgeOnlyMode then
        SetDecLbl(mLblLedDecs[Step], IsOK)
    else
        SetDecLed(mLeds[Step], mLblLedDecs[Step], IsOK);
end;

procedure THVDatFrame.SetOnCurrStr(CurrStr: string; IsOK: boolean);
begin
    SetDecLbl(lblOnCurr, CurrStr, IsOK);
    mCurrState := 0;

    tmrPoll.Enabled := False;
end;

procedure THVDatFrame.SetPosName(Name: string);
begin
    lblPosName.Caption := Name;
end;

procedure THVDatFrame.SetVentSensor(IsOK: boolean);
begin
    lblVentSensor.Font.Color := clWhite;

    if IsOK then
        lblVentSensor.Color := COLOR_OK
    else
        lblVentSensor.Color := COLOR_NG;

end;

procedure THVDatFrame.SetOffCurrStr(CurrStr: string; IsOK: boolean);
begin
    SetDecLbl(lblOffCurr, CurrStr, IsOK);
    mCurrState := 0;

    tmrPoll.Enabled := False;

end;

procedure THVDatFrame.StartLed(Step: integer);
begin
end;

procedure THVDatFrame.StartOffCurr;
begin
    lblOffCurr.Font.Color := clGray;
    lblOffCurr.Caption := '¢º';
    mCurrState := 2;
end;

procedure THVDatFrame.StartOnCurr;
begin
    lblOnCurr.Font.Color := clGray;
    lblOnCurr.Caption := '¢º';
    mCurrState := 1;

    if Assigned(mHVCtrler) then
    begin
        chtAD.Series[0].Clear;
        mTC.Start;
        tmrPoll.Enabled := True;
    end;
end;

procedure THVDatFrame.tmrPollTimer(Sender: TObject);
begin
    chtAD.Series[0].AddXY(mTC.GetPassTimeAsSec, mHVCtrler.GetCurr);
end;

procedure THVDatFrame.VisibleVentSensor(Visible: boolean);
begin
    lblVentSensor.Visible := Visible;
end;

procedure THVDatFrame.DisplayCurr(Curr: double);
begin
    case mCurrState of
        1:
            begin
                lblOnCurr.Caption := FormatFloat('0.0', Curr) + ' A';
            end;
        2:
            begin
                lblOffCurr.Caption := FormatFloat('0.0', Curr) + ' A';
            end;
    end;
end;

procedure THVDatFrame.EnableOpacity(Value: Boolean);
begin
    mPnlOverlays[0].Visible := Value;
    mPnlOverlays[1].Visible := Value;
    mPnlOverlays[2].Visible := Value;
end;

procedure THVDatFrame.Init(HVCtrler: TBaseHVCtrler);
begin
    mHVCtrler := HVCtrler;

    chtAD.BoundsRect := Rect(pnlCurr.Left, pnlCurr.Top, lblOffLedDec.Left + lblOffLedDec.Width, pnlCurr.Top + pnlCurr.Height + lblOffLedDec.Height);
end;

procedure THVDatFrame.lblPosNameDblClick(Sender: TObject);
begin
    if not Assigned(mHVCtrler) then
        Exit;

    chtAD.Visible := not chtAD.Visible;
end;

end.

