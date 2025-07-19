unit AntiPinchTestFrame;

interface

uses
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, Grids, StdCtrls, ExtCtrls, GridHead, FaGraphEx, Label3D,
    FaGraphExLegend, Range, Global, DataBox, DataUnit, SeatMotorType,
    TransparentPanel, Buttons;

type
    TViewMode = (vmData, vmCurrGrp, vmLoadGrp, vmCurrGrpData, vmLoadGrpData);

    TAntipinchTestFrme = class(TFrame)
        pnlBase: TPanel;
        pnlTop: TPanel;
        lblCaption: TLabel;
        shpTopLine: TShape;
        pnlGrp: TPanel;
        pnlData: TPanel;
        grpAPCurr: TFaGraphEx;
        sbtnViewMode: TSpeedButton;
        grpAPLoad: TFaGraphEx;
        pnlLegend: TPanel;
        sgData: TStringGrid;
        Splitter: TSplitter;
        procedure FrameResize(Sender: TObject);
        procedure sbtnViewModeClick(Sender: TObject);
        procedure sgDataDrawCell(Sender: TObject; ACol, ARow: Integer; CellRect: TRect; State: TGridDrawState);
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
        function GetActiveModeGrp: TFaGraphEx;
    public
    { Public declarations }
        constructor Create(AOwner: TComponent); override;
        destructor Destroy; override;

        procedure Init(Model: TModel);

        procedure SetCaptions(IsSlide: boolean);

        procedure ClearGrid;
        procedure UpdateGraph(IsClear: boolean);
        procedure SetLegendColor;

        procedure ActiveUI(Active: boolean);
        procedure SetUIState(State: TTestState);

        procedure EnableOpaque(IsEnabled: Boolean);

        procedure SetViewMode(ViewMode: TViewMode);

    end;

implementation

uses
    TypInfo, MyUtils, GridUtils, uRect, DataUnitHelper, Math, SysEnv, LangTran;
{$R *.dfm}

procedure TAntipinchTestFrme.ActiveUI(Active: boolean);
begin
    if Active then
        lblCaption.Color := $000080FF
    else
        lblCaption.Color := mOldTitleColor;
end;

function MakeTArray(const OpenArr: array of double): TArray<double>;
var
    i: Integer;
begin
    SetLength(Result, Length(OpenArr));
    for i := 0 to High(OpenArr) do
        Result[i] := OpenArr[i];
end;

procedure TAntipinchTestFrme.CalcGridSize;
var
    Gap, Size, TotalWidth, AvailableWidth, i: Integer;
    Ratio: Double;
    ColRatios, RowRatios: TArray<double>;
    RoundingError: Integer;
begin
    AvailableWidth := sgData.ClientWidth;

    ColRatios := MakeTArray([0.6, 1, 1, 1, 1, 0.7]);

    SetGridColWidths(sgData, ColRatios);

    TotalWidth := 0;
    for i := 0 to sgData.ColCount - 1 do
        TotalWidth := TotalWidth + sgData.ColWidths[i];

    // 너비 조정
    if TotalWidth <> AvailableWidth then
    begin
        if TotalWidth > AvailableWidth then
        begin
            // 축소 필요
            Ratio := AvailableWidth / TotalWidth;
            RoundingError := 0;

            for i := 0 to sgData.ColCount - 1 do
            begin
                if sgData.ColWidths[i] > 0 then // 숨겨진 컬럼 제외
                begin
                    sgData.ColWidths[i] := Max(Round(sgData.ColWidths[i] * Ratio), 30);
                    RoundingError := RoundingError + sgData.ColWidths[i];
                end;
            end;

            // 반올림 오차 보정 (마지막 보이는 컬럼에 적용)
            RoundingError := AvailableWidth - RoundingError;
            if RoundingError <> 0 then
            begin
                for i := sgData.ColCount - 1 downto 0 do
                begin
                    if sgData.ColWidths[i] > 0 then // 마지막 보이는 컬럼 찾기
                    begin
                        sgData.ColWidths[i] := sgData.ColWidths[i] + RoundingError;
                        Break;
                    end;
                end;
            end;
        end
        else
        begin
            // 확대 필요 - 마지막 보이는 컬럼에 여유 공간 추가
            for i := sgData.ColCount - 1 downto 0 do
            begin
                if sgData.ColWidths[i] > 0 then // 마지막 보이는 컬럼 찾기
                begin
                    sgData.ColWidths[i] := sgData.ColWidths[i] + (AvailableWidth - TotalWidth);
                    Break;
                end;
            end;
        end;
    end;

    mGridHeader.RowHeight := Round(sgData.DefaultRowHeight * Ifthen(sgData.RowCount = 2, 0.9, 0.7));
    Size := 0;
    for i := 0 to sgData.RowCount - 1 do
        Size := Size + sgData.RowHeights[i];

    if sgData.RowCount = 2 then
    begin
        sgData.RowHeights[1] := sgData.DefaultRowHeight + 7;
    end;

    sgData.Height := Size + 4;
end;

procedure TAntipinchTestFrme.ClearGrid;
begin

end;

constructor TAntipinchTestFrme.Create(AOwner: TComponent);
var
    Gap: integer;
begin
    inherited;

    mViewMode := vmLoadGrpData;

    mLegend := TLegend.Create(self);
    mLegend.Parent := pnlLegend;
    mLegend.Init(GetActiveModeGrp);
    mLegend.ShowBorder := false;
    mLegend.Align := alRight;
//    mLegend.TextColor := clWhite;

    mLegend.Top := 0;
    mLegend.Height := pnlLegend.Height;
    mStdCellSize := 100;
    mLegend.Width := mStdCellSize * 4;
    mLegend.OnClick := LegendClick;

    mGridHeader := TGridTitle.Create(sgData, 6, 4);
    mGridHeader.SetHeads(0, 0, 1, 4, false, _TR('방향'));
    mGridHeader.SetHeads(0, 0, 1, 4, false, _TR('방향'));
    mGridHeader.SetHeads(0, 0, 1, 4, false, _TR('방향'));
    mGridHeader.SetHeads(0, 0, 1, 4, false, _TR('방향'));

    mGridHeader.SetHeads(1, 0, 2, 2, false, _TR('하중(kgf)'));
    mGridHeader.SetHeads(1, 0, 2, 2, false, _TR('하중(kgf)'));
    mGridHeader.SetHeads(1, 2, 2, 1, true, '1');
    mGridHeader.SetHeads(1, 3, 1, 1, true, _TR('작동감지'));

    mGridHeader.SetHeads(1, 0, 2, 2, false, _TR('하중(kgf)'));
    mGridHeader.SetHeads(1, 0, 2, 2, false, _TR('하중(kgf)'));
    mGridHeader.SetHeads(1, 2, 2, 1, true, '1');
    mGridHeader.SetHeads(2, 3, 1, 1, true, _TR('정지감지'));

    mGridHeader.SetHeads(3, 0, 2, 2, false, _TR('전류(A)'));
    mGridHeader.SetHeads(3, 0, 2, 2, false, _TR('전류(A)'));
    mGridHeader.SetHeads(3, 2, 1, 1, true, '2');
    mGridHeader.SetHeads(3, 3, 1, 1, true, _TR('모터 정지'));

    mGridHeader.SetHeads(3, 0, 2, 2, false, _TR('전류(A)'));
    mGridHeader.SetHeads(3, 0, 2, 2, false, _TR('전류(A)'));
    mGridHeader.SetHeads(4, 2, 1, 1, true, '3');
    mGridHeader.SetHeads(4, 3, 1, 1, true, _TR('모터 역동작'));

    mGridHeader.SetHeads(5, 0, 1, 4, false, _TR('동작 판정'));
    mGridHeader.SetHeads(5, 0, 1, 4, false, _TR('동작 판정'));
    mGridHeader.SetHeads(5, 0, 1, 4, false, _TR('동작 판정'));
    mGridHeader.SetHeads(5, 0, 1, 4, false, _TR('동작 판정'));

    mGridHeader.FixedLineColor := clSilver;

    mGridHeader.Colors[1, 2] := COLOR_SPEC;
    mGridHeader.Colors[2, 2] := COLOR_SPEC;
    mGridHeader.Colors[3, 2] := COLOR_SPEC;
    mGridHeader.Colors[4, 2] := COLOR_SPEC;

    mGridHeader.GradStep := 20;

    sgData.FixedColor := $00F4F4F4; //$00E0E0E0;


    mOverlayPnls[0] := TTransparentPanel.Create(Self);
    mOverlayPnls[0].Parent := pnlBase;
    mOverlayPnls[0].BoundsRect := Bounds(0, pnlTop.Height + 5, Width, GetActiveModeGrp.Height - 5);

    mOverlayPnls[1] := TTransparentPanel.Create(Self);
    mOverlayPnls[1].Parent := sgData;
    mOverlayPnls[1].BoundsRect := Bounds(0, 0, sgData.Width, sgData.Height);

    EnableOpaque(False);

    SetCaptions(False);

    UpdateGraph(True);

    if sgData.Font.Size > 0 then
        mDefGridFontSize := sgData.Font.Size
    else
        mDefGridFontSize := 10;  // 기본값 설정

    mOldTitleColor := lblCaption.Color;

    SetViewMode(mViewMode);

end;

destructor TAntipinchTestFrme.Destroy;
begin

    inherited;
end;

procedure TAntipinchTestFrme.EnableOpaque(IsEnabled: Boolean);
begin
    mOverlayPnls[0].Visible := IsEnabled;
    mOverlayPnls[1].Visible := IsEnabled;
    mLegend.Visible := not IsEnabled;
end;

procedure TAntipinchTestFrme.FrameResize(Sender: TObject);
begin
    mLegend.Left := pnlLegend.Width - (mLegend.Width + 10);
    CalcGridSize;
end;

function TAntipinchTestFrme.GetActiveModeGrp: TFaGraphEx;
begin
    Result := nil;
    case mViewMode of
        vmCurrGrp, vmCurrGrpData:
            Result := grpAPCurr;
        vmLoadGrp, vmLoadGrpData:
            Result := grpAPLoad;
    end;
end;

procedure TAntipinchTestFrme.Init(Model: TModel);
begin
    ClearGrid;

    with mGridHeader do
    begin
       {  // 모델 TO DO
        Cells[1, 1] := Model.rSpecs.ToStr(MtrID, rospecFwSpeedHiLo);
        Cells[1, 2] := Model.rSpecs.ToStr(MtrID, rospecBwSpeedHiLo);
        Cells[2, 2] := Model.rSpecs.ToStr(MtrID, rospecCurrHiLo);
        Cells[3, 2] := Model.rSpecs.ToStr(MtrID, rospecInitNoiseHi);
        Cells[4, 2] := Model.rSpecs.ToStr(MtrID, rospecRunNoiseHi);
       }
    end;

    UsrGraphInitial(GetActiveModeGrp, gtNormal, true);

    GetActiveModeGrp.Repaint;
end;

procedure TAntipinchTestFrme.LegendClick(Graph: TFaGraphEx; Item: TLegendItem; Button: TMouseButton);
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

procedure TAntipinchTestFrme.sbtnViewModeClick(Sender: TObject);
begin
    if mViewMode < High(TViewMode) then
        mViewMode := Succ(mViewMode)
    else
        mViewMode := Low(TViewMode);

    SetViewMode(mViewMode);
end;

procedure TAntipinchTestFrme.SetLegendColor;
var
    i: integer;
begin
    for i := 0 to GetActiveModeGrp.Series.Count - 1 do
        mLegend.Items[i].mColor := GetActiveModeGrp.Series.Items[i].LineColor;

    mLegend.Repaint;
end;

procedure TAntipinchTestFrme.SetCaptions(IsSlide: boolean);
begin

    sgData.Cells[0, 1] := _TR('전진');
    sgData.Cells[0, 2] := _TR('후진');
    if IsSlide then
    begin
        lblCaption.Caption := 'SLIDE ANTIPINCH';
        mLegend.Items[0].mCaption := _TR('워크인 하중');
        mLegend.Items[1].mCaption := _TR('워크인 전류');

        mLegend.Items[2].mCaption := _TR('언워크인 하중');
        mLegend.Items[3].mCaption := _TR('언워크인 전류');

    end
    else
    begin
        lblCaption.Caption := 'RECLINE ANTIPINCH';
        mLegend.Items[0].mCaption := _TR('폴딩 하중');
        mLegend.Items[1].mCaption := _TR('폴딩 전류');

        mLegend.Items[2].mCaption := _TR('언폴딩 하중');
        mLegend.Items[3].mCaption := _TR('언폴딩 전류');
    end;
end;

procedure TAntipinchTestFrme.SetUIState(State: TTestState);
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

procedure TAntipinchTestFrme.SetViewMode(ViewMode: TViewMode);
begin
    pnlGrp.Visible := False;
    pnlData.Visible := False;
    Splitter.Visible := False;

    case ViewMode of
        vmData:
            begin
                pnlData.Visible := True;
                pnlData.Align := alClient;

            end;
        vmCurrGrp:
            begin
                pnlGrp.Visible := True;
                pnlGrp.Align := alClient;
                grpAPLoad.Visible := False;
                grpAPLoad.Align := alTop;
                grpAPCurr.Visible := True;
                grpAPCurr.Align := alClient;
            end;
        vmLoadGrp:
            begin
                pnlGrp.Visible := True;
                pnlGrp.Align := alClient;
                grpAPLoad.Visible := True;
                grpAPLoad.Align := alClient;
                grpAPCurr.Visible := False;
                grpAPCurr.Align := alClient;
            end;
        vmCurrGrpData:
            begin
                pnlGrp.Align := alLeft;
                pnlGrp.Width := Round(pnlBase.Width * 0.4);
                pnlData.Align := alClient;
                pnlGrp.Visible := True;
                pnlData.Visible := True;
                Splitter.Left := pnlGrp.Width + 2;
                Splitter.Align := alLeft;
                Splitter.Visible := True;
                grpAPLoad.Visible := False;
                grpAPLoad.Align := alTop;
                grpAPCurr.Visible := True;
                grpAPCurr.Align := alClient;
            end;
        vmLoadGrpData:
            begin
                pnlGrp.Align := alLeft;
                pnlGrp.Width := Round(pnlBase.Width * 0.4);
                pnlData.Align := alClient;
                pnlGrp.Visible := True;
                pnlData.Visible := True;
                Splitter.Left := pnlGrp.Width + 2;
                Splitter.Align := alLeft;
                Splitter.Visible := True;
                grpAPLoad.Visible := True;
                grpAPLoad.Align := alClient;
                grpAPCurr.Visible := False;
                grpAPCurr.Align := alClient;
            end;
    end;
    CalcGridSize();
    sgData.Repaint();
end;

procedure TAntipinchTestFrme.sgDataDrawCell(Sender: TObject; ACol, ARow: Integer; CellRect: TRect; State: TGridDrawState);

    function GetBkColor: TColor;
    begin
        if ARow = 1 then
            Exit(clWhite);

        Exit($00FAF7EF);
    end;

var
    Grid: TStringGrid;
    Text: string;
    OldColor, TextColor, BkColor: TColor;
    Judge: TResultJudge;
    FontSize: integer;
    IsBold: Boolean;
begin

    Grid := TStringGrid(Sender);

    if mGridHeader.DrawGridHead(Grid, ACol, ARow, CellRect, State) then
        Exit;

    IsBold := False;
    Text := Grid.Cells[ACol, ARow];

    TextColor := clBlack;
    OldColor := Grid.Canvas.Font.Color;

    if (ACol = 0) or (ARow = 0) then
    begin
        GradFillRect(Grid, CellRect, mGridHeader.GradStep);
        FontSize := mDefGridFontSize;
     //   IsBold := True;
    end
    else
    begin
        FontSize := mDefGridFontSize + 1;

        IsBold := True;
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

procedure TAntipinchTestFrme.UpdateGraph(IsClear: boolean);
begin
    UsrGraphInitial(GetActiveModeGrp, gtNormal, IsClear);
    SetLegendColor;
end;

end.

