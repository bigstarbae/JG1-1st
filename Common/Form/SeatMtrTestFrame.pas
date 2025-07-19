{
  : 모터 전류, 속도, 소음  UI Frame


    << Seat Motor FaGraph Series Idx >>

    Series Idx          Data Idx
    ------------------------------
      0 : 전진 Noise    0 : 시간
                        1 : Noise

      1 : 후진 Noise    2 : 시간
                        3 : Noise

      2 : 전진 전류     4 : 시간
                        5 : 전류

      3 : 후진 전류     6 : 시간
                        7 : 전류

}


unit SeatMtrTestFrame;

interface

uses
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, Grids, StdCtrls, ExtCtrls, GridHead, FaGraphEx, Label3D,
    FaGraphExLegend, Range, Global, DataBox, DataUnit, DataUnitOrd,
    SeatMotorType, TransparentPanel, Buttons;

type
    TCellDec = (cdNone, cdOK, cdNG);

    TViewMode = (vmData, vmGrp, vmGrpData);

    TSpecStrs = array[0..4] of string;

    TSeatMtrTestFrme = class(TFrame)
        pnlBase: TPanel;
        pnlTop: TPanel;
        shpTopLine: TShape;
        pnlLegend: TPanel;
        pnlData: TPanel;
        sgData: TStringGrid;
        lblCaption: TLabel;
        sbtnViewMode: TSpeedButton;
        pnlGrp: TPanel;
        grpData: TFaGraphEx;
        Splitter: TSplitter;
        procedure sgDataDrawCell(Sender: TObject; ACol, ARow: Integer; CellRect: TRect; State: TGridDrawState); // 전류 포함시
        procedure FrameResize(Sender: TObject);
        procedure sbtnViewModeClick(Sender: TObject);
        procedure pnlDataResize(Sender: TObject);
    private
        { Private declarations }

        mOldTitleColor: TColor;
        mDefGridFontSize: Integer;
        mStdCellSize: integer;

        mLegend: TLegend;
        mGridHeader: TGridTitle;

        mViewMode: TViewMode;

        mOverlayPnls: array[0..1] of TTransparentPanel;

        procedure CalcGridSize;
        procedure LegendClick(Graph: TFaGraphEx; Item: TLegendItem; Button: TMouseButton);

    public
        { Public declarations }
        constructor Create(AOwner: TComponent); override;
        destructor Destroy; override;

        procedure Init(Model: TModel; MtrID: TMotorOrd; HideCurr, HidePulse, HideBackAngle: Boolean; HideLimit: Boolean = False);

        procedure SetDirStr(UpDn: boolean);
        procedure SetCells(ACol, ARow: integer; Text: string; Judge: TResultJudge); overload;
        procedure SetCells(ACol, ARow: integer; Box: TDataBox; RO: TResultOrd); overload;

        procedure ClearGrid;
        procedure UpdateGraph(IsClear: boolean);
        procedure SetLegendColor;

        procedure ActiveUI(Active: boolean);
        procedure SetUIState(State: TTestState);

        procedure EnableOpaque(IsEnabled: Boolean);

        procedure SetViewMode(ViewMode: TViewMode);

        property Graph: TFaGraphEx read grpData;
        property Legend: TLegend read mLegend;
        property Header: TGridTitle read mGridHeader;

    end;

procedure GradFillRect(Grid: TStringGrid; CellRect: TRect; GradStep: Integer);

implementation

uses
    TypInfo, MyUtils, GridUtils, uRect, DataUnitHelper, Math, SysEnv, LangTran;
{$R *.dfm}

constructor TSeatMtrTestFrme.Create(AOwner: TComponent);
var
    Gap: integer;
begin
    inherited;

    mLegend := TLegend.Create(self);
    mLegend.Parent := pnlLegend;
    mLegend.Init(grpData);
    mLegend.ShowBorder := false;
    mLegend.Align := alRight;
//    mLegend.TextColor := clWhite;

    mLegend.Top := 0;
    mLegend.Height := pnlLegend.Height;
    mStdCellSize := 90;
    mLegend.Width := mStdCellSize * 4;
    mLegend.OnClick := LegendClick;

    mGridHeader := TGridTitle.Create(sgData, 8, 3);
    mGridHeader.SetHeads(0, 0, 1, 3, false, _TR('방향'));
    mGridHeader.SetHeads(0, 0, 1, 3, false, _TR('방향'));
    mGridHeader.SetHeads(0, 0, 1, 3, false, _TR('방향'));
    mGridHeader.SetHeads(1, 0, 1, 1, true, _TR('속도(mm(°)/s)'));
    mGridHeader.SetHeads(1, 1, 1, 1, true, '1');
    mGridHeader.SetHeads(1, 2, 1, 1, false, '2');
    mGridHeader.SetHeads(2, 0, 1, 2, false, _TR('전류(A)'));
    mGridHeader.SetHeads(2, 0, 1, 2, true, _TR('전류(A)'));
    mGridHeader.SetHeads(2, 2, 1, 1, false, '3');
    mGridHeader.SetHeads(3, 0, 2, 1, true, _TR('소음(dB)'));
    mGridHeader.SetHeads(3, 1, 1, 1, true, _TR('초기'));
    mGridHeader.SetHeads(3, 2, 1, 1, false, '1');
    mGridHeader.SetHeads(3, 0, 2, 1, true, _TR('소음(dB)'));
    mGridHeader.SetHeads(4, 1, 1, 1, true, _TR('작동'));
    mGridHeader.SetHeads(4, 2, 1, 1, false, '2');
    mGridHeader.SetHeads(5, 0, 1, 1, false, _TR('위치'));
    mGridHeader.SetHeads(5, 1, 1, 1, false, '4');
    mGridHeader.SetHeads(5, 2, 1, 1, false, '5');
    mGridHeader.SetHeads(6, 0, 1, 1, False, _TR('백각도'));
    mGridHeader.SetHeads(6, 1, 1, 1, False, '6');
    mGridHeader.SetHeads(6, 2, 1, 1, False, '7');
    mGridHeader.SetHeads(7, 0, 1, 3, false, 'LIMIT');
    mGridHeader.SetHeads(7, 0, 1, 3, false, 'LIMIT');
    mGridHeader.SetHeads(7, 0, 1, 3, false, 'LIMIT');
    mGridHeader.FixedLineColor := clSilver;
    mGridHeader.Colors[1, 1] := COLOR_SPEC;
    mGridHeader.Colors[1, 2] := COLOR_SPEC;
    mGridHeader.Colors[2, 2] := COLOR_SPEC;
    mGridHeader.Colors[3, 2] := COLOR_SPEC;
    mGridHeader.Colors[4, 2] := COLOR_SPEC;
    mGridHeader.Colors[5, 1] := COLOR_SPEC;
    mGridHeader.Colors[5, 2] := COLOR_SPEC;
    mGridHeader.Colors[6, 1] := COLOR_SPEC;
    mGridHeader.Colors[6, 2] := COLOR_SPEC;

    mGridHeader.GradStep := 20;
    mGridHeader.TextBold := fsBold in sgData.Font.Style;

    sgData.FixedColor := $00F4F4F4; //$00E0E0E0;


    mOverlayPnls[0] := TTransparentPanel.Create(Self);
    mOverlayPnls[0].Parent := sgData;
    mOverlayPnls[0].BoundsRect := Bounds(0, 0, sgData.Width, sgData.Height);

    EnableOpaque(False);

    SetDirStr(False);

    mViewMode := Low(TViewMode);

    UpdateGraph(True);

    if sgData.Font.Size > 0 then
        mDefGridFontSize := sgData.Font.Size
    else
        mDefGridFontSize := 10;  // 기본값 설정

    mOldTitleColor := lblCaption.Color;

    SetViewMode(mViewMode);
end;

destructor TSeatMtrTestFrme.Destroy;
begin
    mGridHeader.Free;
    inherited;
end;

procedure TSeatMtrTestFrme.EnableOpaque(IsEnabled: Boolean);
begin
    mOverlayPnls[0].Visible := IsEnabled;
    mLegend.Visible := not IsEnabled;

    if IsEnabled then
    begin
        SetViewMode(vmData);
    end;

    sbtnViewMode.Enabled := not IsEnabled;
end;

procedure TSeatMtrTestFrme.LegendClick(Graph: TFaGraphEx; Item: TLegendItem; Button: TMouseButton);
var
    GrpEnv: TFaGraphEnv;
begin
    if Button = mbLeft then
    begin
        GrpEnv := GetGrpEnv(Graph.Tag);
        if GrpEnv.rDataLine[Item.mID] <> Item.mColor then
        begin
            GrpEnv.rDataLine[Item.mID] := Item.mColor;
            SetGrpEnv(GrpEnv);
        end;
    end;
end;

procedure TSeatMtrTestFrme.pnlDataResize(Sender: TObject);
begin
    CalcGridSize;
end;

procedure TSeatMtrTestFrme.sbtnViewModeClick(Sender: TObject);
begin
    if mViewMode < High(TViewMode) then
        mViewMode := Succ(mViewMode)
    else
        mViewMode := Low(TViewMode);

    SetViewMode(mViewMode);
end;

procedure GradFillRect(Grid: TStringGrid; CellRect: TRect; GradStep: Integer);
var
    FixedBColor: TColor;
begin
    FixedBColor := IncRGB(Grid.FixedColor, GradStep);
    GradientFillRect(Grid.Canvas.Handle, CellRect, FixedBColor, Grid.FixedColor, true);
end;

procedure TSeatMtrTestFrme.SetDirStr(UpDn: boolean);
begin
    if UpDn then
    begin
        sgData.Cells[0, 1] := _TR('상승');
        sgData.Cells[0, 2] := _TR('하강');

        mLegend.Items[0].mCaption := _TR('상승소음');
        mLegend.Items[1].mCaption := _TR('하강소음');

        mLegend.Items[2].mCaption := _TR('상승전류');
        mLegend.Items[3].mCaption := _TR('하강전류');

    end
    else
    begin
        sgData.Cells[0, 1] := _TR('전진');
        sgData.Cells[0, 2] := _TR('후진');

        mLegend.Items[0].mCaption := _TR('전진소음');
        mLegend.Items[1].mCaption := _TR('후진소음');

        mLegend.Items[2].mCaption := _TR('전진전류');
        mLegend.Items[3].mCaption := _TR('후진전류');
    end;

end;

procedure TSeatMtrTestFrme.FrameResize(Sender: TObject);
begin

//    mOldTitleColor := lblCaption.Color;
//    mDefGridFontSize := sgData.Font.Size;

    mLegend.Left := pnlLegend.Width - (mLegend.Width + 10);

    CalcGridSize;

end;

procedure TSeatMtrTestFrme.SetUIState(State: TTestState);
begin
    case State of
        tsNoUse:
            lblCaption.Color := COLOR_NO_USE;
        tsNormal:
            lblCaption.Color := mOldTitleColor;
        tsActive:
            lblCaption.Color := COLOR_ACTIVE
    end;
end;

procedure TSeatMtrTestFrme.sgDataDrawCell(Sender: TObject; ACol, ARow: Integer; CellRect: TRect; State: TGridDrawState);
var
    Grid: TStringGrid;
    Text: string;
    OldColor, TextColor, BkColor: TColor;
    FontSize: integer;
    IsBold: Boolean;
    LimitCol: Integer;

    function GetBkColor: TColor;
    begin
        if ARow = 1 then
            Exit(clWhite);
        Exit($00FAF7EF);
    end;

    procedure GetJudgeColors(ACol, ARow: Integer; out TextColor, BkColor: TColor);
    var
        Judge: TResultJudge;
    begin
        Judge := TResultJudge(Grid.Objects[ACol, ARow]);
        if Judge = rjNG then
        begin
            TextColor := clWhite;
            BkColor := COLOR_NG;
        end
        else if Judge = rjOK then
        begin
            TextColor := clWhite;
            BkColor := COLOR_OK;
        end
        else
        begin
            TextColor := clBlack;
            BkColor := GetBkColor;
        end;
    end;

begin
    Grid := TStringGrid(Sender);
    LimitCol := Grid.ColCount - 1;
    if Grid.ColWidths[LimitCol] <= 0 then
        Exit;

    Text := Grid.Cells[ACol, ARow];

    if (ACol = LimitCol) and (ARow = 1) then
    begin
        GetJudgeColors(ACol, ARow, TextColor, BkColor);
        Grid.Canvas.Font.Style := [fsBold];
        Grid.Canvas.Font.Size := mDefGridFontSize + 1;
        MergeCells(Grid, LimitCol, 1, LimitCol, 2, Text, TextColor, BkColor);
        Grid.Canvas.Font.Style := [];
        Exit;
    end
    else if (ACol = LimitCol) and (ARow = 2) then
    begin
        Exit;
    end;

    if mGridHeader.DrawGridHead(Grid, ACol, ARow, CellRect, State) then
        Exit;

    IsBold := False;

    TextColor := clBlack;
    OldColor := Grid.Canvas.Font.Color;

    if (ACol = 0) or (ARow = 0) then
    begin
        GradFillRect(Grid, CellRect, mGridHeader.GradStep);
        FontSize := mDefGridFontSize;
        IsBold := mGridHeader.TextBold;
    end
    else
    begin
        FontSize := mDefGridFontSize + 1;
        IsBold := True;
        GetJudgeColors(ACol, ARow, TextColor, BkColor);
        Grid.Canvas.Brush.Color := BkColor;
        Grid.Canvas.FillRect(CellRect);
    end;

    if IsBold then
        Grid.Canvas.Font.Style := [fsBold]
    else
        Grid.Canvas.Font.Style := [];

    Grid.Canvas.Font.Size := FontSize;
    Grid.Canvas.Font.Color := TextColor;
    SetBkMode(Grid.Canvas.Handle, TRANSPARENT);
    DrawText(Grid.Canvas.Handle, PChar(Text), Length(Text), CellRect, DT_CENTER or DT_VCENTER or DT_SINGLELINE);
    Grid.Canvas.Font.Style := [];
    Grid.Canvas.Font.Color := OldColor;
end;

procedure TSeatMtrTestFrme.SetCells(ACol, ARow: integer; Text: string; Judge: TResultJudge);
begin
    sgData.Cells[ACol, ARow] := Text;
    sgData.Objects[ACol, ARow] := TObject(Judge);
end;

procedure TSeatMtrTestFrme.SetCells(ACol, ARow: integer; Box: TDataBox; RO: TResultOrd);
begin

    sgData.Cells[ACol, ARow] := Box.GetResultToATxt(Ord(RO), False);

    if Box.IsTested(RO) then
        sgData.Objects[ACol, ARow] := TObject(BoolToJudge(Box.GetResult(RO)))
    else
        sgData.Objects[ACol, ARow] := TObject(rjNone);
end;

function MakeTArray(const OpenArr: array of double): TArray<double>;
var
    i: Integer;
begin
    SetLength(Result, Length(OpenArr));
    for i := 0 to High(OpenArr) do
        Result[i] := OpenArr[i];
end;

procedure TSeatMtrTestFrme.Init(Model: TModel; MtrID: TMotorOrd; HideCurr, HidePulse, HideBackAngle: Boolean; HideLimit: Boolean);
var
    ColRatios: TArray<double>;
begin

    ClearGrid;

    with mGridHeader do
    begin
        Cells[1, 1] := Model.rSpecs.ToMotorStr(MtrID, rospecFwSpeedHiLo);
        Cells[1, 2] := Model.rSpecs.ToMotorStr(MtrID, rospecBwSpeedHiLo);
        Cells[2, 2] := Model.rSpecs.ToMotorStr(MtrID, rospecCurrHiLo);
        Cells[3, 2] := Model.rSpecs.ToMotorStr(MtrID, rospecInitNoiseHi);
        Cells[4, 2] := Model.rSpecs.ToMotorStr(MtrID, rospecRunNoiseHi);

    end;

    UsrGraphInitial(grpData, gtNormal, true);
    ColRatios := MakeTArray([0.4, 1, 1, 0.7, 0.7, 0.6, 1, 0.4]);

    if HideCurr then
        ColRatios[2] := 0;

    if HidePulse then
        ColRatios[5] := 0;

    if HideBackAngle then
        ColRatios[6] := 0;

    if HideLimit then
        ColRatios[7] := 0;

    mGridHeader.SetColumnRatios(ColRatios);

    FrameResize(Self);

//    sgData.Repaint;

end;

procedure TSeatMtrTestFrme.CalcGridSize;
var
    Size, i: Integer;
begin
    mGridHeader.ApplyColumnWidths;

    mGridHeader.RowHeight := Round(sgData.DefaultRowHeight * Ifthen(sgData.RowCount = 2, 0.9, 0.7));
    Size := 0;
    for i := 0 to sgData.RowCount - 1 do
        Size := Size + sgData.RowHeights[i];

    if sgData.RowCount = 2 then    // 전진 한방향인 경우 조금 크게
    begin
        sgData.RowHeights[1] := sgData.DefaultRowHeight + 7;
    end;

    sgData.Height := Size + 4;

    mOverlayPnls[0].BoundsRect := Bounds(0, 0, sgData.Width, sgData.Height);

end;

procedure TSeatMtrTestFrme.ClearGrid;
var
    i: integer;
begin
    for i := 1 to sgData.ColCount - 1 do
    begin
        sgData.Cells[i, 1] := '';
        sgData.Cells[i, 2] := '';

        sgData.Objects[i, 1] := nil;
        sgData.Objects[i, 2] := nil;
    end;
end;

procedure TSeatMtrTestFrme.UpdateGraph(IsClear: Boolean);
begin
    UsrGraphInitial(grpData, gtNormal, IsClear);
    SetLegendColor;
end;

procedure TSeatMtrTestFrme.ActiveUI(Active: boolean);
begin
    if Active then
        lblCaption.Color := $000080FF
    else
        lblCaption.Color := mOldTitleColor;
end;

procedure TSeatMtrTestFrme.SetViewMode(ViewMode: TViewMode);
begin
    mViewMode := ViewMode;

    sgData.Font.Size := mDefGridFontSize;

    case ViewMode of
        vmData:
            begin
                pnlLegend.Visible := False;
                pnlData.Align := alClient;
                pnlData.Visible := True;
                pnlGrp.Visible := False;
                Splitter.Visible := False;
            end;
        vmGrp:
            begin
                pnlLegend.Visible := True;
                pnlGrp.Align := alClient;
                pnlGrp.Visible := True;
                pnlData.Visible := False;
                Splitter.Visible := False;
            end;
        vmGrpData:
            begin
                pnlLegend.Visible := True;
                pnlGrp.Align := alLeft;
                pnlGrp.Width := Round(pnlBase.Width * 0.4);
                pnlGrp.Visible := True;
                Splitter.Left := pnlGrp.Width + 2;
                Splitter.Align := alLeft;
                Splitter.Visible := True;

                sgData.Font.Size := Round(sgData.Font.Size * 0.9);
                pnlData.Align := alClient;
                pnlData.Visible := True;
            end;
    end;

    Invalidate;
end;

procedure TSeatMtrTestFrme.SetLegendColor;
var
    i: integer;
begin
    for i := 0 to self.grpData.Series.Count - 1 do
        mLegend.Items[i].mColor := grpData.Series.Items[i].LineColor;

    mLegend.Repaint;
end;

end.

