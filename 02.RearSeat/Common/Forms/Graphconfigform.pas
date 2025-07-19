unit Graphconfigform;
{$I mydefine.inc}
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  FaGraphEx, StdCtrls, AbNumEdit, Buttons, ExtCtrls;

type
  TfrmgrpConfig = class(TForm)
    Panel2: TPanel;
    Bevel1: TBevel;
    bbtnApply: TBitBtn;
    bbtnOK: TBitBtn;
    BitBtn4: TBitBtn;
    DlgColor: TColorDialog;
    Panel1: TPanel;
    faGrpRefer: TFaGraphEx;
    Panel4: TPanel;
    Shape4: TShape;
    Shape5: TShape;
    Shape6: TShape;
    Shape1: TShape;
    Label12: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Shape3: TShape;
    Shape7: TShape;
    Label13: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Shape8: TShape;
    Shape9: TShape;
    Label14: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    cbxgrpList: TComboBox;
    abXMax: TAbNumEdit;
    abXmin: TAbNumEdit;
    abXstep: TAbNumEdit;
    abYMax: TAbNumEdit;
    abYMin: TAbNumEdit;
    abYstep: TAbNumEdit;
    stxColor0: TStaticText;
    stxColor1: TStaticText;
    stxColor2: TStaticText;
    btnData: TButton;
    btnspec: TButton;
    btnTerm: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cbxgrpListChange(Sender: TObject);
    procedure faGrpReferAfterPaint(Sender: TObject);
    procedure btnDataClick(Sender: TObject);
    procedure bbtnApplyClick(Sender: TObject);
    procedure bbtnOKClick(Sender: TObject);
    procedure faGrpReferBeforePaint(Sender: TObject);
    procedure pnlTitleMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
    mCurIDx : integer ;

    procedure XYAxisInitial(aGraphEx: TFaGraphEx; IsClear:boolean) ;
    procedure GraphInitial(aGraphEx: TFaGraphEx; gtValue : TGraphType; IsClear:boolean);

    procedure SetUpdates ;

    procedure UsrExit(Sender: TObject) ;
    procedure UsrEnter(Sender: TObject) ;
    procedure UsrKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure UsrValueChanged(Sender: TObject);
  public
    { Public declarations }
    procedure SetFrm(AGrpIndex: integer) ;
  end;

var
  frmgrpConfig: TfrmgrpConfig;

implementation
uses
    myUtils, DataUnit, ModelUnit, colorListForm, Log, KiiMessages, LangTran ;

var
    lpgrpEnv : array[0..ord(High(TFaGRAPH_ORD))]of TFaGraphEnv ;
    lporgEnv : array[0..ord(High(TFaGRAPH_ORD))]of TFaGraphEnv ;

{$R *.DFM}

procedure TfrmgrpConfig.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    //Action := CaFree ;
end;

procedure TfrmgrpConfig.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
    i : integer ;
begin
    {$IFDEF DEBUG}
    gLog.Debug('%s CLOSE', [Caption]);
    {$ENDIF}
    if (BorderStyle <> bsDialog) and (bbtnApply.Tag > 0) then SetUpdates ;

    for i := 0 to ord(HIGH(TFaGraph_ORD)) do
    begin
        if not CompareMem(@lporgEnv[i], @lpgrpEnv[i], sizeof(TFaGraphEnv)) then
        begin
            lpgrpEnv[i] := lporgEnv[i] ;
        end ;
    end ;
end;

procedure TfrmgrpConfig.FormCreate(Sender: TObject);
var
    i : integer;
begin
    mCurIDx   := 0 ;
    cbxgrpList.Items.Clear ;
    for i := 0 to ord(HIGH(TFaGraph_ORD)) do
    begin
        cbxgrpList.Items.Add(GRP_EXT[(i)]) ;
    end ;
    for i := 0 to ord(HIGH(TFaGraph_ORD)) do
    begin
        lpgrpEnv[i] := GetGrpEnv(i) ;
        lporgEnv[i] := lpgrpEnv[i] ;
    end ;
end;

procedure TfrmgrpConfig.FormDestroy(Sender: TObject);
begin
//
end;

procedure TfrmgrpConfig.FormShow(Sender: TObject);
var
    i : integer ;
begin
    {$IFDEF DEBUG}
    gLog.Debug('%s SHOW', [Caption]);
    {$ENDIF}
    cbxgrpList.ItemIndex := cbxgrpList.Tag ;
    with lpgrpEnv[cbxgrpList.ItemIndex] do
    begin
        abXmax.Value  := rXMax ;
        abXmin.Value  := rXMin ;
        abXstep.Value := rXstep ;
        abYmax.Value  := rYMax ;
        abYmin.Value  := rYMin ;
        abYstep.Value := rYStep ;
        stxColor0.Color := rDataLine[0] ;
        stxColor1.Color := rspecLine[0] ;
        stxColor2.Color := rspecLine[1] ;
    end ;

    for i := 0 to ComponentCount-1 do
    begin
        if not (Components[i] is TAbNumEdit) then Continue ;
        with Components[i] as TAbNumEdit do
        begin
            OnExit := UsrExit ;
            OnEnter := UsrEnter ;
            OnKeyup := UsrKeyup ;
            OnValueChanged := UsrValueChanged ;
        end ;
    end ;

    GraphInitial(faGrpRefer, gtNormal, true) ;
    cbxgrpList.OnChange(cbxgrpList) ;
    bbtnApply.Enabled := false ;
    //cbxgrpList.Enabled := (BorderStyle <> bsDialog) ;

    bbtnOK.SetFocus ;
    TLangTran.ChangeCaption(self);
end;

procedure TfrmgrpConfig.cbxgrpListChange(Sender: TObject);
begin
    bbtnApply.Tag := integer(bbtnApply.Enabled) ;
    with Sender as TComboBox do
    begin
        if (mCurIDx <> ItemIndex)and (mCurIDx >= 0) then
        begin
            with lpgrpEnv[mCurIDx] do
            begin
                rXmax := abXMax.Value ;
                rXMin := abXMin.Value ;
                rXstep:= abXstep.Value ;
                rYMax := abYMax.Value ;
                rYMin := abYMin.Value ;
                rYStep:= abYStep.Value ;
                rDataLine[0] := stxColor0.Color ;
                rSpecLine[0] := stxColor1.Color ;
                rSpecLine[1] := stxColor2.Color ;
            end ;

            with lpgrpEnv[ItemIndex] do
            begin
                abXmax.Value  := rXMax ;
                abXmin.Value  := rXMin ;
                abXstep.Value := rXstep ;

                abYmax.Value  := rYMax ;
                abYmin.Value  := rYMin ;
                abYstep.Value := rYStep ;
                stxColor0.Color := rDataLine[0] ;
                stxColor1.Color := rspecLine[0] ;
                stxColor2.Color := rspecLine[1] ;
            end ;
            mCurIDx := ItemIndex ;
        end ;
    end ;
    GraphInitial(faGrpRefer, gtNormal, true) ;
    bbtnApply.Enabled := LongBool(bbtnApply.Tag) ;

    bbtnApply.Tag     := 0 ;
end;

procedure TfrmgrpConfig.XYAxisInitial(aGraphEx: TFaGraphEx; IsClear:boolean) ;
var
    i: integer ;
begin
    if IsClear then aGraphEx.Empty();
    with aGraphEx.Axis do
    begin
        Items[0].Min     := abXMin.Value ;
        Items[0].Max     := abXMax.Value ;
        Items[0].Step    := abXStep.Value ;

        if Frac(abXStep.Value) > 0 then Items[0].Decimal := 1
        else                            Items[0].Decimal := 0 ;

        Items[1].Min     := abYMin.Value ;
        Items[1].Max     := abYMax.Value ;
        Items[1].Step    := abYStep.Value ;

        if Frac(abYStep.Value) > 0 then Items[1].Decimal := 1
        else                            Items[1].Decimal := 0 ;
    end;

    for i := 0 to aGraphEx.Series.Count-1 do
    begin
        aGraphEx.Series.Items[i].LineColor := lpgrpEnv[cbxgrpList.ItemIndex].rDataLine[i] ;
    end ;
end ;

procedure TfrmgrpConfig.GraphInitial(aGraphEx: TFaGraphEx; gtValue : TGraphType; IsClear:boolean);
begin
    aGraphEx.BeginUpdate();
    aGraphEx.GraphType   := gtValue;

    if gtValue in [gtNormal] then
    begin
        aGraphEx.GridDraw := [ggHori, ggVert] ;
    end
    else
    begin
        aGraphEx.GridDraw := [ggHori] ;
    end ;

    XYAxisInitial(aGraphEx, IsClear) ;
    aGraphEx.EndUpdate();
end ;

procedure TfrmgrpConfig.pnlTitleMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
    ReleaseCapture() ;
    PostMessage(Handle, WM_NCLBUTTONDOWN, HTCAPTION, 0) ;
end;

procedure TfrmgrpConfig.SetFrm(AGrpIndex: integer) ;
begin
    cbxgrpList.Tag := AGrpIndex ;
    mCurIDx := cbxgrpList.Tag ;
end ;

procedure TfrmgrpConfig.faGrpReferAfterPaint(Sender: TObject);
var
    dTm: double ;
begin
    Exit ;
    with Sender as TFaGraphEx do
    begin
        if (GraphType <> gtNormal) then Exit ;

        dTm := (Axis.Items[1].Max - Axis.Items[1].Min) * 0.2 ;
        DrawHoriLine(0, 1, GetBoardRect,
                     Axis.Items[0].Min,
                     Axis.Items[0].Max,
                     dTm + Axis.Items[1].Min,
                     stxColor1.Color, psSolid);
        DrawHoriLine(0, 1, GetBoardRect,
                     Axis.Items[0].Min,
                     Axis.Items[0].Max,
                     Axis.Items[1].Max - dTm ,
                     stxColor1.Color, psSolid);
        dTm := (Axis.Items[0].Max - Axis.Items[0].Min) * 0.2 ;
        DrawVertLine(0, 1, GetBoardRect,
                     dTm + Axis.Items[0].Min,
                     Axis.Items[1].Min,
                     Axis.Items[1].Max,
                     stxColor2.Color, psSolid);
        DrawVertLine(0, 1, GetBoardRect,
                     AXis.Items[0].Max - dTm,
                     Axis.Items[1].Min,
                     Axis.Items[1].Max,
                     stxColor2.Color, psSolid);
    end ;
end;

procedure TfrmgrpConfig.SetUpdates ;
begin
    SendToForm(gUsrMsg, SYS_GRAPH, 0);
end ;

procedure TfrmgrpConfig.btnDataClick(Sender: TObject);
var
    IsData, bk : boolean ;
begin
    bk := bbtnApply.Enabled ;
    with Sender as TButton do IsData := Tag = 0 ;
    with TfrmColorList.Create(Application) do
    begin
        if IsData then
        begin
            with lpgrpEnv[cbxgrpList.ItemIndex] do
                SetFrm(@rDataLine,
                       ARY_DATA_LINE_COUNT[TFaGraph_ORD(cbxgrpList.ItemIndex)]);
        end
        else
        begin
            with lpgrpEnv[cbxgrpList.ItemIndex] do
                SetFrm(@rspecLine,
                       ARY_SPEC_LINE_COUNT[TFaGraph_ORD(cbxgrpList.ItemIndex)]);
        end ;

        SetNames(cbxgrpList.Text, IsData);
        Self.bbtnApply.Enabled := (ShowModal = mrOK) or bk ;
    end ;

    if bbtnApply.Enabled then
    begin
        with lpgrpEnv[cbxgrpList.ItemIndex] do
        begin
            stxColor0.Color := rDataLine[0] ;
            stxColor1.Color := rspecLine[0] ;
        end ;
        GraphInitial(faGrpRefer, gtNormal, true) ;
    end ;
end;

procedure TfrmgrpConfig.UsrExit(Sender: TObject) ;
begin
    if bbtnApply.Enabled then GraphInitial(faGrpRefer, gtNormal, true) ;
end ;

procedure TfrmgrpConfig.UsrEnter(Sender: TObject) ;
begin
    if bbtnApply.Enabled then GraphInitial(faGrpRefer, gtNormal, true) ;
end ;

procedure TfrmgrpConfig.UsrKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
    if Key = VK_RETURN then GraphInitial(faGrpRefer, gtNormal, true) ;
end ;

procedure TfrmgrpConfig.UsrValueChanged(Sender: TObject);
begin
    bbtnApply.Enabled := true ;
    GraphInitial(faGrpRefer, gtNormal, true) ;
end;

procedure TfrmgrpConfig.bbtnApplyClick(Sender: TObject);
var
    i, Cnt : integer ;
begin
    Screen.Cursor := crHourGlass ;

    with lpgrpEnv[cbxgrpList.ItemIndex] do
    begin
        rXMax := abXmax.Value ;
        rXMin := abXmin.Value ;
        rXstep := abXstep.Value ;
        rYMax  := abYmax.Value ;
        rYMin  := abYmin.Value ;
        rYStep := abYstep.Value ;
        rDataLine[0] := stxColor0.Color ;
        rspecLine[0] := stxColor1.Color ;
        //rspecLine[1] := stxColor2.Color ;
    end ;

    Cnt := 0 ;

    for i := 0 to ord(HIGH(TFaGraph_ORD)) do
    begin
        if not CompareMem(@lporgEnv[i], @lpgrpEnv[i], sizeof(TFaGraphEnv)) then
        begin
            with lpgrpEnv[i] do
            begin
                rID    := i ;
            end ;
            SetGrpEnv( lpgrpEnv[i] ) ;
            lporgEnv[i] := lpgrpEnv[i] ;
            Inc(Cnt) ;
        end ;
    end ;

    bbtnApply.Tag :=  1 ;
    bbtnApply.Enabled := false ;

    if Cnt > 0 then SetUpdates() ;

    Screen.Cursor := crDefault ;
end;

procedure TfrmgrpConfig.bbtnOKClick(Sender: TObject);
begin
    if bbtnApply.Enabled then bbtnApply.Click ;
    if BorderStyle = bsDialog then
    begin
        if bbtnApply.Tag > 0 then ModalResult := mrOK
        else                      ModalResult := mrCancel ;
    end
    else Close ;
end;

procedure TfrmgrpConfig.faGrpReferBeforePaint(Sender: TObject);
var
    dTm: double ;
    Rect: TRect ;
    PenColor,
    BrushColor: TColor ;
    TmpCanvas: TCanvas ;
begin
    with Sender as TFaGraphEx do
    begin
        if (GraphType <> gtNormal) then Exit ;

        GetCanvas(TmpCanvas);
        with Rect do
        begin
            dTm := (Axis.Items[0].Max - Axis.Items[0].Min) * 0.3 ;
            GetX(0, dTm+Axis.Items[0].Min, Left);
            GetX(0, Axis.Items[0].Max-dTm, Right);
            dTm := (Axis.Items[1].Max - Axis.Items[1].Min) * 0.3 ;
            GetY(0, dTm+Axis.Items[1].Min, Bottom) ;
            GetY(0, Axis.Items[1].Max-dTm, Top);
        end ;
        PenColor  := TmpCanvas.Pen.Color ;
        BrushColor:= TmpCanvas.Brush.Color ;
        TmpCanvas.Brush.Color := stxColor1.Color ;
        TmpCanvas.Pen.Color   := stxColor1.Color ;
        TmpCanvas.FillRect(Rect);

        TmpCanvas.Brush.Color := BrushColor ;
        TmpCanvas.Pen.Color := PenColor ;
    end ;
end;

end.
