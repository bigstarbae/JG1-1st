unit SeatConnectorForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, TeEngine, Series, TeeProcs, Chart, ExtCtrls, Grids, StdCtrls, SeatConnector, Buttons,
  TeeChartUtil, MagneticForm;

type
  TfrmSeatConnector = class(TfrmMagnetic)
    pnlGrp: TPanel;
    chtPinV: TChart;
    Series1: TFastLineSeries;
    Panel2: TPanel;
    pnlSWCon: TPanel;
    sgSwCon: TStringGrid;
    sgWInCushCon: TStringGrid;
    sgWInBackCon: TStringGrid;
    lblSW: TLabel;
    lblWInBack: TLabel;
    Label2: TLabel;
    tmrPoll: TTimer;
    splCon: TSplitter;
    pnlMainCon: TPanel;
    sgMainCon: TStringGrid;
    pnlMainConTitle: TPanel;
    btnGrp: TSpeedButton;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure sgMainConDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure btnGrpClick(Sender: TObject);
    procedure sgSwConDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure sgSwConMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure tmrPollTimer(Sender: TObject);
    procedure sgMainConClick(Sender: TObject);
  private
    { Private declarations }
    mMainCon:   TSeatConnector;
    mSwCon:     TSwConnector;

    mSC:        TScrollChartHelper;

    mPollState: integer;


  public
    { Public declarations }
    class var mIsShow: boolean;

    procedure SetConnector(MainCon: TSeatConnector; SwCon: TSwConnector);

  end;

var
  frmSeatConnector: TfrmSeatConnector;

implementation
uses
    IODef, URect, Types, LangTran;

{$R *.dfm}

const
    FORM_NML_WIDTH = 685;
    FORM_EXT_WIDTH = 1005;

procedure TfrmSeatConnector.FormCreate(Sender: TObject);
begin
    mSC := TScrollChartHelper.Create(chtPinV);


end;

procedure TfrmSeatConnector.FormShow(Sender: TObject);
var
    i: integer;


begin
    mIsShow := true;

    SetMagParentWnd;

    Width := FORM_NML_WIDTH;

    sgMainCon.Cells[0, 0] := 'Pin No.';
    sgMainCon.Cells[1, 0] := _TR('Pin명');
    sgMainCon.Cells[2, 0] := _TR('전압(V)');

    for i := 1 to sgMainCon.RowCount do
    begin
        sgMainCon.Cells[0, i] := IntToStr(i);
    end;

    //--------------------------------
    sgSwCon.Cells[0, 0] := 'Pin No.';
    sgSwCon.Cells[1, 0] := _TR('Pin명');
    sgSwCon.Cells[2, 0] := _TR('전압(V)');
    sgSwCon.Cells[3, 0] := 'Fwd/Up';
    sgSwCon.Cells[4, 0] := 'Bwd/Dn';

    for i := 1 to sgSwCon.RowCount do
    begin
        sgSwCon.Cells[0, i] := IntToStr(i);

    end;

    //--------------------------------

    mSC.Start(10);
end;

procedure TfrmSeatConnector.SetConnector(MainCon: TSeatConnector; SwCon: TSwConnector);
begin
    mMainCon := MainCon;
    mMainCon.WriteAsPinName(sgMainCon.Cols[1], 1);

    if SwCon = nil then
    begin
        sgSwCon.Enabled := false;
    end
    else
    begin
        mSwCon := SwCon;
        mSwCon.WriteAsPinName(sgSwCon.Cols[1], 1);
    end;


end;

function GetInvertColor(Color: TColor): TColor;
begin
    if ((GetRValue(Color) + GetGValue(Color) + GetBValue(Color)) > 384) then
        Result := clBlack
    else
        Result := clWhite;
end;

function IsZeroVal(Val: double): boolean;
begin
    Result := (- 0.2 <= Val) and (Val <= 0.2);
end;

function IsPlusVal(Val: double): boolean;
begin
    Result := Val >= 0.05;
end;

const
    LED_WIDTH = 16;

procedure TfrmSeatConnector.sgMainConClick(Sender: TObject);
begin
    chtPinV.Title.Text.Text := 'PIN NO: ' + IntToStr(sgMainCon.Row);
    mSC.Start(10);
end;

procedure TfrmSeatConnector.sgMainConDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
var
    FontColor, BkColor: TColor;
    CellStr: string;

    Grid: TStringGrid;
    Val: double;

begin
    Grid := TStringGrid(Sender);
    Grid.Canvas.Font := Grid.Font;


    FontColor := Grid.Font.Color;
    BkColor := Grid.Color;
    CellStr := Grid.Cells[ACol, ARow];


    if ARow = 0 then
    begin
        FontColor := GetInvertColor(Grid.FixedColor);
        BkColor := Grid.FixedColor;
    end
    else
    begin
        case ACol of
            0, 1:
                begin
                    FontColor := clBlack;
                end;
            2:
                begin
                    Val := mMainCon.GetPinVolt(ARow);
                    CellStr := Format('%f', [Val]);

                    if IsPlusVal(Val) then
                        FontColor := clBlue
                    else if IsZeroVal(Val) then
                        FontColor := clBlack
                    else
                        FontColor := clRed
                end;
        end;
    end;

    SetBkMode(Grid.Canvas.Handle, TRANSPARENT);
    Grid.Canvas.Font.Color := FontColor;
    Grid.Canvas.Brush.Color := BkColor;
    Grid.Canvas.FillRect(Rect);
    DrawText(Grid.Canvas.Handle, CellStr, Length(CellStr), Rect, DT_CENTER or DT_VCENTER or DT_SINGLELINE);

end;

procedure TfrmSeatConnector.sgSwConDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
var
    FontColor, BkColor: TColor;
    CellStr: string;
    Ch, StdWSize, LedTDMargin: Integer;
    LedRect: TRect;
    Grid: TStringGrid;
    Val: double;
    PinType:  TPwrSwPinType;
label
    DEFAULT_DRAW;

    function GetRegCellStr(PinType: TPwrSwPinType; Col: integer): string;
    begin
        Result := '';
        case PinType of
            pspNone: ;
        end;
    end;
begin
    Grid := TStringGrid(Sender);
    Grid.Canvas.Font := Grid.Font;

    StdWSize := Round(Rect.Width * 0.04);
    LedTDMargin := Round(Rect.Height * 0.32);
    LedRect := Types.Rect(Round(Rect.Left + StdWSize * 0.8), Rect.Top + LedTDMargin, Round(Rect.Left + LED_WIDTH), Rect.Bottom - LedTDMargin);

    FontColor := Grid.Font.Color;
    BkColor := Grid.Color;
    CellStr := Grid.Cells[ACol, ARow];


    if ARow = 0 then
    begin
        FontColor := GetInvertColor(Grid.FixedColor);
        BkColor := Grid.FixedColor;
    end
    else
    begin
        case ACol of
            0:
                begin
                    FontColor := clBlack;
                end;
            1:
                begin
                    if (TPwrSwPinType(Grid.Objects[ACol, ARow]) = pspNone) or (mSwCon = nil) then
                        goto DEFAULT_DRAW;

                    if mSwCon.IsPinOn(ARow) then
                    begin
                        DrawFrameControl(Grid.Canvas.Handle, Rect, DFC_BUTTON, DFCS_BUTTONPUSH or DFCS_PUSHED);
                        Grid.Canvas.Brush.Color := clRed;

                    end
                    else
                    begin
                        DrawFrameControl(Grid.Canvas.Handle, Rect, DFC_BUTTON, DFCS_BUTTONPUSH);
                        Grid.Canvas.Brush.Color := clGray;
                    end;

                    Grid.Canvas.Rectangle(LedRect.Left, LedRect.Top, LedRect.Right, LedRect.Bottom);
                    SetBkMode(Grid.Canvas.Handle, TRANSPARENT);
                    Grid.Canvas.TextOut(LedRect.Right + 7, Rect.Top + 3, CellStr);
                    Exit;

                end;
            2:
                begin
                    Val := mSwCon.GetPinVolt(ARow);
                    CellStr := Format('%f', [Val]);

                    if IsPlusVal(Val) then
                        FontColor := clBlue
                    else
                        FontColor := clBlack;
                end;
            3, 4:
                begin
                    PinType := TPwrSwPinType(Grid.Objects[1, ARow]);
                    Ch := integer(sgSwCon.Objects[ACol, ARow]);
                    if (PinType = pspNone) then   // (Ch = 0)
                        goto DEFAULT_DRAW;

                    CellStr := GetRegCellStr(PinType, ACol);

                    with mSwCon do
                    begin
                        if DIO.IsIO(Ch) then
                        begin
                            DrawFrameControl(Grid.Canvas.Handle, Rect, DFC_BUTTON, DFCS_BUTTONPUSH or DFCS_PUSHED);
                            Grid.Canvas.Brush.Color := clRed;
                        end
                        else
                        begin
                            DrawFrameControl(Grid.Canvas.Handle, Rect, DFC_BUTTON, DFCS_BUTTONPUSH);
                            Grid.Canvas.Brush.Color := clGray;
                        end;

                        Grid.Canvas.Rectangle(LedRect.Left, LedRect.Top, LedRect.Right, LedRect.Bottom);
                        SetBkMode(Grid.Canvas.Handle, TRANSPARENT);
                        Grid.Canvas.TextOut(LedRect.Right + 7, Rect.Top + 3, CellStr);
                        Exit;
                    end;
                end;
        end;

    end;

DEFAULT_DRAW:

    SetBkMode(Grid.Canvas.Handle, TRANSPARENT);
    Grid.Canvas.Font.Color := FontColor;
    Grid.Canvas.Brush.Color := BkColor;
    Grid.Canvas.FillRect(Rect);
    DrawText(Grid.Canvas.Handle, CellStr, Length(CellStr), Rect, DT_CENTER or DT_VCENTER or DT_SINGLELINE);

end;

procedure TfrmSeatConnector.btnGrpClick(Sender: TObject);
begin
    if pnlGrp.Visible then
    begin
        btnGrp.Caption := 'GRAPH ▶';
        splCon.Visible := false;
        pnlGrp.Visible := false;
        Width := FORM_NML_WIDTH;
    end
    else
    begin
        btnGrp.Caption := 'GRAPH ◀';
        splCon.Visible := true;
        pnlGrp.Visible := true;
        Width := FORM_EXT_WIDTH;
    end;


end;

procedure TfrmSeatConnector.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    mSC.Free;

    CloseChilds;

    mIsShow := false;

    Action := caFree;

    inherited;
end;


procedure TfrmSeatConnector.sgSwConMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
    Ch, Col, Row: integer;
begin

    sgSwCon.MouseToCell(X, Y, Col, Row);


    if Row > 0 then
    begin
        case Col of
            1:
                begin
                    if TPwrSwPinType(sgSwCon.Objects[Col, Row]) = pspNone then
                        Exit;

                    if mSwCon.IsPinOn(Row) then
                        mSwCon.PinSwOff(Row)
                    else
                        mSwCon.PinSwOn(Row);
                end;
            3, 4:
                begin
                    Ch := integer(sgSwCon.Objects[Col, Row]);
                    if Ch = 0 then
                        Exit;
                    mSwCon.DIO.SetIO(Ch, not mSwCon.DIO.IsIO(Ch));
                end;
        end;
    end;

end;

procedure TfrmSeatConnector.tmrPollTimer(Sender: TObject);
begin

    case mPollState of
        0:
            begin
                sgMainCon.Repaint;
                Inc(mPollState);
            end;
        1:
            begin
                sgSwCon.Repaint;
                mPollState := 0;
            end;

    end;


    mSC.Add([mMainCon.GetPinVolt(sgMainCon.Row)]);
end;

end.
