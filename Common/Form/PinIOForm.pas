unit PinIOForm;

interface

uses
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, TeEngine, Series, ExtCtrls, TeeProcs, Chart, Grids, BaseDIO, BaseAD,
    TeeChartUtil, MagneticForm, StdCtrls;

type
    TfrmPinIO = class(TfrmMagnetic)
        sgPinIO: TStringGrid;
        tmrPoll: TTimer;
        sgAIEx: TStringGrid;
        Panel1: TPanel;
        chtPinCV: TChart;
        FastLineSeries6: TFastLineSeries;
        Series1: TFastLineSeries;
        Panel2: TPanel;
        cbxSubFormClose: TCheckBox;
        cbxAutoYScale: TCheckBox;
        procedure FormShow(Sender: TObject);
        procedure FormClose(Sender: TObject; var Action: TCloseAction);
        procedure sgPinIODrawCell(Sender: TObject; ACol, ARow: Integer; ARect: TRect; State: TGridDrawState);
        procedure tmrPollTimer(Sender: TObject);
        procedure FormCreate(Sender: TObject);
        procedure sgPinIOMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
        procedure sgPinIOClick(Sender: TObject);
        procedure sgAIExDrawCell(Sender: TObject; ACol, ARow: Integer; ARect: TRect; State: TGridDrawState);
        procedure sgAIExClick(Sender: TObject);
        procedure cbxAutoYScaleClick(Sender: TObject);
    private
        { Private declarations }
        mAD: TBaseAD;
        mDIO: TBaseDIO;

        mSPinDOCh, mSVoltAICh, mSCurrAICh, mPinCount: integer;

        mSC: TScrollChartHelper;

        mIsPinGrp: boolean;
        mCurRow: integer;       // PIN Grid
        mAICurRow: integer;     // AIEx Grid

        mShowCurr: Boolean;

        function IsAnyDirPinOn: Boolean;
        function IsAnyLinkPinOn: Boolean;

    public
        class var
            mIsShow: boolean;

        { Public declarations }
        procedure InitPinDAQ(DIO: TBaseDIO; AD: TBaseAD; SPinDOCh, SCurrAICh, SVoltAICh, PinCount: integer);
        procedure InitAIExChs(AIChs: array of integer; AIChNames: array of string);

        property ShowCurr: Boolean read mShowCurr write mShowCurr;
    end;

var
    frmPinIO: TfrmPinIO;

implementation

uses
    URect, LangTran;
{$R *.dfm}

procedure TfrmPinIO.FormCreate(Sender: TObject);
begin
    mSC := TScrollChartHelper.Create(chtPinCV);
    mIsPinGrp := true;
    mShowCurr := True;
end;

procedure TfrmPinIO.FormShow(Sender: TObject);
var
    i: Integer;
begin
    //
    mIsShow := true;


    SetMagParentWnd;

    sgPinIO.Cells[0, 0] := 'PIN No.';
    sgPinIO.Cells[1, 0] := _TR('극성');
    sgPinIO.Cells[2, 0] := 'LINK';
    sgPinIO.Cells[3, 0] := _TR('전류(A)');
    sgPinIO.Cells[4, 0] := _TR('전압(V)');
    sgPinIO.Cells[5, 0] := 'REMARK';

    sgAIEx.Cells[0, 0] := 'CH명';
    sgAIEx.Cells[1, 0] := 'VALUE';

    for i := 0 to sgPinIO.RowCount - 1 do
    begin
        sgPinIO.Cells[0, i + 1] := IntToStr(i + 1);

        sgPinIO.Objects[1, i + 1] := TObject(mSPinDoCh + i * 2);
        sgPinIO.Objects[2, i + 1] := TObject(mSPinDoCh + i * 2 + 1);
    end;

    mCurRow := 0;
    sgPinIOClick(sgPinIO);

    mSC.FixYRange := true;

    chtPinCV.LeftAxis.Minimum := -1;
    chtPinCV.RightAxis.Minimum := -1;

    chtPinCV.LeftAxis.Maximum := 15;
    chtPinCV.RightAxis.Maximum := 15;

    mSC.Start(5);

    if sgAIEx.Visible = False then
    begin
        Width := Width - sgAIEx.Width;
    end;

    TLangTran.ChangeCaption(self);
end;

procedure TfrmPinIO.InitAIExChs(AIChs: array of integer; AIChNames: array of string);
var
    i: integer;
begin
    sgAIEx.Visible := true;

    sgAIEx.RowCount := Length(AIChs) + 1;

    for i := 0 to Length(AIChs) - 1 do
    begin
        if AIChNames[i][Length(AIChNames[i])] = '$' then
        begin
            sgAIEx.Objects[0, i + 1] := TObject(1);     // 전류구분 Flag
            SetLength(AIChNames[i], Length(AIChNames[i]) - 1);
        end;

        sgAIEx.Cells[0, i + 1] := AIChNames[i];
        sgAIEx.Objects[1, i + 1] := TObject(AIChs[i]);
    end;

end;

procedure TfrmPinIO.InitPinDAQ(DIO: TBaseDIO; AD: TBaseAD; SPinDOCh, SCurrAICh, SVoltAICh, PinCount: integer);
begin
    mDIO := DIO;
    mAD := AD;

    mSPinDOCh := SPinDOCh;
    mSVoltAICh := SVoltAICh;
    mSCurrAICh := SCurrAICh;
    mPinCount := PinCount;

    sgPinIO.RowCount := mPinCount + 1;

    tmrPoll.Enabled := true;
end;

function TfrmPinIO.IsAnyDirPinOn: Boolean;
var
    i: Integer;
begin
    Result := False;
    for i := 0 to mPinCount - 1 do
    begin
        if mDIO.IsIO(mSPinDoCh + i * 2) then
            Exit(True);
    end;

end;

function TfrmPinIO.IsAnyLinkPinOn: Boolean;
var
    i: Integer;
begin
    Result := False;
    for i := 0 to mPinCount - 1 do
    begin
        if mDIO.IsIO(mSPinDoCh + i * 2 + 1) then
            Exit(True);
    end;
end;

procedure TfrmPinIO.cbxAutoYScaleClick(Sender: TObject);
begin
    mSC.FixYRange := not cbxAutoYScale.Checked;

    chtPinCV.LeftAxis.Minimum := -1;
    chtPinCV.RightAxis.Minimum := -1;

    chtPinCV.LeftAxis.Maximum := 15;
    chtPinCV.RightAxis.Maximum := 15;

end;

procedure TfrmPinIO.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    tmrPoll.Enabled := false;

    mSC.Free;

    mIsShow := false;

    if cbxSubFormClose.Checked then
        CloseChilds;

    Action := caFree;

    inherited;
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
    Result := (-0.2 <= Val) and (Val <= 0.2);
end;

function IsPlusVal(Val: double): boolean;
begin
    Result := Val >= 0.1;
end;



procedure TfrmPinIO.sgAIExDrawCell(Sender: TObject; ACol, ARow: Integer; ARect: TRect; State: TGridDrawState);
var
    FontColor, BkColor: TColor;
    CellStr: string;
    IsCurr, Ch: Integer;
    Grid: TStringGrid;
    Val: double;
const
    ON_FONT_COLORS: array[0..1] of TColor = (clBlue, clRed);
begin
    Grid := TStringGrid(Sender);
    Grid.Canvas.Font := Grid.Font;

    BkColor := Grid.Color;
    CellStr := Grid.Cells[ACol, ARow];
    FontColor := Grid.Font.Color;

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
                    BkColor := clBtnFace;
                    FontColor := clBlack;
                end;
            1:
                begin

                    Ch := integer(Grid.Objects[ACol, ARow]);
                    IsCurr := integer(Grid.Objects[0, ARow]);
                    Val := mAD.GetValue(Ch);
                    CellStr := Format('%f', [Val]);
                    if IsPlusVal(Val) then
                        FontColor := ON_FONT_COLORS[IsCurr]
                    else
                        FontColor := clBlack;
                end;
        end;
    end;

    SetBkMode(Grid.Canvas.Handle, TRANSPARENT);
    Grid.Canvas.Font.Color := FontColor;
    Grid.Canvas.Brush.Color := BkColor;
    Grid.Canvas.FillRect(ARect);

    if (ACol = 0) and (ARow > 0) then
    begin
        CellStr := ' ' + CellStr;
        DrawText(Grid.Canvas.Handle, CellStr, Length(CellStr), ARect, DT_LEFT or DT_VCENTER or DT_SINGLELINE)
    end
    else
        DrawText(Grid.Canvas.Handle, CellStr, Length(CellStr), ARect, DT_CENTER or DT_VCENTER or DT_SINGLELINE);

end;

procedure TfrmPinIO.sgPinIOClick(Sender: TObject);
begin

    mIsPinGrp := true;
    chtPinCV.Title.Text.Text := 'PIN NO: ' + IntToStr(sgPinIO.Row);
    chtPinCV.Series[0].Visible := true;
    chtPinCV.Series[1].Visible := true;

    if mCurRow > 0 then
    begin
        sgPinIO.Cells[0, mCurRow] := IntToStr(mCurRow);
    end;

    mCurRow := sgPinIO.Row;

    sgPinIO.Cells[0, mCurRow] := Format('【%d】', [mCurRow]);

    mSC.Start(5);
end;

procedure TfrmPinIO.sgAIExClick(Sender: TObject);
begin
    mIsPinGrp := false;

    mAICurRow := sgAIEx.Row;

    chtPinCV.Title.Text.Text := sgAIEx.Cells[0, mAICurRow];

    if integer(sgAIEx.Objects[0, mAICurRow]) = 1 then
    begin
        chtPinCV.Series[0].Visible := true;
        chtPinCV.Series[1].Visible := false;
    end
    else
    begin
        chtPinCV.Series[0].Visible := false;
        chtPinCV.Series[1].Visible := true;
    end;

    mSC.Start(5);

end;

procedure TfrmPinIO.sgPinIODrawCell(Sender: TObject; ACol, ARow: Integer; ARect: TRect; State: TGridDrawState);

    function MPos(StartPos, Len1, Len2: Integer): Integer;
    begin
        Result := StartPos + (Len1 - Len2) div 2;
    end;

var
    FontColor, BkColor: TColor;
    CellStr: string;
    Ch, StdWSize, LampTDMargin: Integer;
    LampRect: TRect;
    Grid: TStringGrid;
    Val: double;
begin
    Grid := TStringGrid(Sender);
    Grid.Canvas.Font := Grid.Font;

    StdWSize := Round(ARect.Width / 10);
    LampTDMargin := Round(ARect.Height * 0.32);
    LampRect := Rect(Round(ARect.Left + StdWSize * 1.5), ARect.Top + LampTDMargin, Round(ARect.Left + StdWSize * 4.0), ARect.Bottom - LampTDMargin);

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
            1, 2:
                begin
                    Ch := integer(Grid.Objects[ACol, ARow]);
                    if mDIO.IsIO(Ch) then
                    begin
                        DrawFrameControl(Grid.Canvas.Handle, ARect, DFC_BUTTON, DFCS_BUTTONPUSH or DFCS_PUSHED);
                        Grid.Canvas.Brush.Color := clRed;
                        CellStr := 'ON';

                    end
                    else
                    begin
                        DrawFrameControl(Grid.Canvas.Handle, ARect, DFC_BUTTON, DFCS_BUTTONPUSH);
                        Grid.Canvas.Brush.Color := clGray;
                        CellStr := 'OFF';
                    end;

                    Grid.Canvas.Rectangle(LampRect.Left, LampRect.Top, LampRect.Right, LampRect.Bottom);
                    SetBkMode(Grid.Canvas.Handle, TRANSPARENT);
                    Grid.Canvas.TextOut(LampRect.Right + 7, ARect.Top + 3, CellStr);
                    Exit;
                end;
            3:
                begin
                    if mShowCurr then
                    begin
                        Val := mAD.GetValue(mSCurrAICh + (ARow - 1));
                        CellStr := Format('%f', [Val]);
                        if IsPlusVal(Val) then
                            FontColor := clRed
                        else
                            FontColor := clBlack;
                    end
                    else
                    begin
                        CellStr := '';
                    end;
                end;

            4:
                begin
                    Val := mAD.GetValue(mSVoltAICh + (ARow - 1));
                    CellStr := Format('%f', [Val]);

                    if IsPlusVal(Val) then
                        FontColor := clBlue
                    else
                        FontColor := clBlack;
                end;
        end;

    end;

    SetBkMode(Grid.Canvas.Handle, TRANSPARENT);
    Grid.Canvas.Font.Color := FontColor;
    Grid.Canvas.Brush.Color := BkColor;
    Grid.Canvas.FillRect(ARect);
    DrawText(Grid.Canvas.Handle, CellStr, Length(CellStr), ARect, DT_CENTER or DT_VCENTER or DT_SINGLELINE);

end;

procedure TfrmPinIO.sgPinIOMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
    Ch, Col, Row: integer;
begin
    sgPinIO.MouseToCell(X, Y, Col, Row);

    if Row > 0 then
    begin
        case Col of
            1, 2:
                begin

                    if Col = 1 then
                    begin
                        if IsAnyLinkPinOn then
                        begin
                            ShowMessage('LINK PIN을 먼저 OFF하세요');
                            Exit;
                        end;
                    end
                    else
                    begin
                        if not IsAnyDirPinOn then
                        begin
                            ShowMessage('극성 PIN을 먼저 ON하세요');
                            Exit;
                        end;
                    end;

                    Ch := integer(sgPinIO.Objects[Col, Row]);
                    mDIO.SetIO(Ch, not mDIO.IsIO(Ch));
                end;
        end;
    end;

end;

procedure TfrmPinIO.tmrPollTimer(Sender: TObject);
var
    CH: integer;
begin
    //
    sgPinIO.Repaint;

    sgAIEx.Repaint;

    if mIsPinGrp then
    begin
        mSC.Add([mAD.GetValue(mSCurrAICh + sgPinIO.Row - 1), mAD.GetValue(mSVoltAICh + sgPinIO.Row - 1)])
    end
    else
    begin
        CH := integer(sgAIEx.Objects[1, mAICurRow]);
        if integer(sgAIEx.Objects[0, mAICurRow]) = 1 then
            mSC.Add([mAD.GetValue(CH), 0])
        else
            mSC.Add([0, mAD.GetValue(CH)]);
    end;

end;

end.

