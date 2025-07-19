unit EditForm;
{$INCLUDE myDefine.inc}

interface

uses
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, ExtCtrls, StdCtrls, Buttons, ImgList, DataUnit, KiiMessages,
    ComCtrls, ModelType, SeatType, SeatMotorType, Grids, pngimage, Label3D,
    AlignSpecFrame, MotorSpecFrame;

type
    TCustomBorderRadioGroup = class(TRadioGroup)
    private
        FBorderColor: TColor;
    protected
        procedure Paint; override;
    public
        constructor Create(AOwner: TComponent); override;
        property BorderColor: TColor read FBorderColor write FBorderColor;
    end;

    TfrmEdit = class(TForm)
        Panel1: TPanel;
        Shape3: TShape;
        Label2: TLabel;
        edtPartName: TEdit;
        Shape6: TShape;
        labPartName: TLabel;
        Shape7: TShape;
        labIndex: TLabel;
        GroupBox1: TGroupBox;
        Label6: TLabel;

        Label9: TLabel;
        edtNoiseRunning: TEdit;
        Label49: TLabel;
        edtOffsetNoiseRunning0: TEdit;
        edtOffsetNoiseRunning1: TEdit;
        Label50: TLabel;
        Label51: TLabel;
        Label58: TLabel;
        Label59: TLabel;
        edtNoiseInitTime: TEdit;
        Label61: TLabel;
        Label62: TLabel;
        Label63: TLabel;
        edtNoiseInitMax: TEdit;
        edtOffsetNoiseInit0: TEdit;
        edtOffsetNoiseInit1: TEdit;
        pcMdl: TPageControl;
        tsMotor1: TTabSheet;
        rdgCar: TRadioGroup;
        rdgPos: TRadioGroup;
        rdgCarTrim: TRadioGroup;
        rdgSeats: TRadioGroup;
        tsElec: TTabSheet;
        tsBackAngle: TTabSheet;
        tsDeliver: TTabSheet;
        tsMotor2: TTabSheet;
        GroupBox2: TGroupBox;
        GroupBox3: TGroupBox;
        GroupBox4: TGroupBox;
        Panel5: TPanel;
        Label107: TLabel;
        Label114: TLabel;
        Label116: TLabel;
        Label117: TLabel;
        Label118: TLabel;
        Shape5: TShape;
        Label121: TLabel;
        Label122: TLabel;
        Label123: TLabel;
        edtHeatOn_CurrHi: TEdit;
        edtHeatOn_CurrLo: TEdit;
        edtHeatOff_CurrLo: TEdit;
        edtHeatOff_CurrHi: TEdit;
        Panel8: TPanel;
        Label105: TLabel;
        Label106: TLabel;
        Label108: TLabel;
        Label109: TLabel;
        Label110: TLabel;
        Shape10: TShape;
        Label111: TLabel;
        Label112: TLabel;
        Label113: TLabel;
        edtVentOn_CurrHi: TEdit;
        edtVentOn_CurrLo: TEdit;
        edtVentOff_CurrLo: TEdit;
        edtVentOff_CurrHi: TEdit;
        Panel9: TPanel;
        Label115: TLabel;
        Label119: TLabel;
        Label120: TLabel;
        Label124: TLabel;
        Label125: TLabel;
        Shape11: TShape;
        edtBuckleOn_VoltHi: TEdit;
        edtBuckleOn_VoltLo: TEdit;
        GroupBox5: TGroupBox;
        Panel11: TPanel;
        Label131: TLabel;
        Label132: TLabel;
        Label133: TLabel;
        Label135: TLabel;
        Label201: TLabel;
        Shape14: TShape;
        Label202: TLabel;
        Label203: TLabel;
        Label207: TLabel;
        edtFolding_AngleHi: TEdit;
        edtFolding_AngleLo: TEdit;
        edtRearMost_AngleLo: TEdit;
        edtRearMost_AngleHi: TEdit;
        grpInsepction01: TGroupBox;
        fmAlign_Shoulder: TAlignSpecFrme;
        fmAlign_Relax: TAlignSpecFrme;
        fmAlign_Recl: TAlignSpecFrme;
        fmAlign_WalkinTilt: TAlignSpecFrme;
        fmAlign_CushTilt: TAlignSpecFrme;
        fmAlign_Slide: TAlignSpecFrme;
        fmMtr_WalkinTilt: TMtrSpecFrame;
        fmMtr_CushTilt: TMtrSpecFrame;
        fmMtr_Slide: TMtrSpecFrame;
        fmMtr_Shoulder: TMtrSpecFrame;
        fmMtr_Relax: TMtrSpecFrame;
        fmMtr_Recl: TMtrSpecFrame;
        procedure FormClose(Sender: TObject; var Action: TCloseAction);
        procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
        procedure FormCreate(Sender: TObject);
        procedure FormDestroy(Sender: TObject);
        procedure FormShow(Sender: TObject);
        procedure OnSaveBtnActive(Sender: TObject);
    private
    { Private declarations }
        mInit: boolean;
        mChangeEvent: TNotifyStatus;
        mModels: TModels;
        mIsMdlExSave: boolean;

        procedure Init;

        function TransModels(aIsEdit: boolean): boolean;
        procedure ReadMessage(var myMsg: TMessage);
        procedure SetExistMtrVisible;

    public
    { Public declarations }
        procedure SetFrm(aIndex: integer);
        procedure Save(AItems: array of boolean);

        property OnUserChange: TNotifyStatus read mChangeEvent write mChangeEvent;
    end;

var
    frmEdit: TfrmEdit;

implementation

uses
    Global, ModelUnit, SeatTypeUI, Log, myUtils, Math, DioForm, PasswdForm,
    DioReferForm, IniFiles, LanIOUnit, SysEnv, IODef, TsWorkUnit, LangTran,
    FormUtils, HVTester;

{$R *.dfm}

constructor TCustomBorderRadioGroup.Create(AOwner: TComponent);
begin
    inherited;

    FBorderColor := $00EDEFF1;
end;

procedure TCustomBorderRadioGroup.Paint;
var
    R: TRect;
begin
    inherited;
    R := ClientRect;
    Canvas.Pen.Color := FBorderColor;
    Canvas.Pen.Width := 1;
    Canvas.Brush.Style := bsClear;
    Canvas.Rectangle(R);
end;

procedure TfrmEdit.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    Action := caFree;
end;

procedure TfrmEdit.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
    gLog.ToFiles('%s CLOSE', [Caption]);
end;

procedure TfrmEdit.FormCreate(Sender: TObject);
var
    i: integer;
    cFind: TWinControl;
begin
    mInit := true;
    mIsMdlExSave := false;

    Init;
end;

procedure TfrmEdit.FormDestroy(Sender: TObject);
begin
//
end;

procedure TfrmEdit.FormShow(Sender: TObject);
begin

    mInit := false;
    gLog.ToFiles('%s SHOW', [Caption]);

    TLangTran.ChangeCaption(self);
end;

procedure TfrmEdit.SetExistMtrVisible;
begin
    fmAlign_Slide.Visible := mModels.rTypes.IsSlideMtrExists;
    fmAlign_CushTilt.Visible := mModels.rTypes.IsCushTiltMtrExists;
    fmAlign_WalkinTilt.Visible := mModels.rTypes.IsWalkinTiltMtrExists;
    fmAlign_Recl.Visible := mModels.rTypes.IsReclineMtrExists;
    fmAlign_Relax.Visible := mModels.rTypes.IsRelaxMtrExists;
    fmAlign_Shoulder.Visible := mModels.rTypes.IsShoulderMtrExists;

    fmMtr_Slide.Visible := fmAlign_Slide.Visible;
    fmMtr_CushTilt.Visible := fmAlign_CushTilt.Visible;
    fmMtr_WalkinTilt.Visible := fmAlign_WalkinTilt.Visible;
    fmMtr_Recl.Visible := fmAlign_Recl.Visible;
    fmMtr_Relax.Visible := fmAlign_Relax.Visible;
    fmMtr_Shoulder.Visible := fmAlign_Shoulder.Visible;

    RefreshAlignedControls([fmAlign_Slide, fmAlign_CushTilt, fmAlign_WalkinTilt, fmAlign_Recl, fmAlign_Relax, fmAlign_Shoulder], alTop);
    RefreshAlignedControls([fmMtr_Slide, fmMtr_CushTilt, fmMtr_WalkinTilt, fmMtr_Recl, fmMtr_Relax, fmMtr_Shoulder], alTop);
end;

procedure TfrmEdit.SetFrm(aIndex: integer);
var
    iDx: integer;
begin
    mInit := true;
    Init;

    labIndex.Tag := aIndex;

    gLog.ToFiles('%s Call Setfrm', [Caption]);
    iDx := labIndex.Tag;
    mModels := gModels.GetModels(iDx);

    labIndex.Caption := IntToStr(labIndex.Tag);
    TransModels(false);

    SetExistMtrVisible();

    mInit := false;
    if Assigned(mChangeEvent) then
        OnUserChange(Self, 0);

    AttachSaveEventToControlChild(Self, OnSaveBtnActive);
end;

function TfrmEdit.TransModels(aIsEdit: boolean): boolean;
label
    EDIT_ERROR;
var
    iTm: integer;
    sTm: string;
begin
    Result := false;
    with mModels do
    begin
        if aIsEdit then
        begin
            rPartName := ShortString(edtPartName.Text);

            rTypes.Clear;
            rTypes.SetCarType(rdgCar.ItemIndex);
            rTypes.SetCarTrimType(rdgCarTrim.ItemIndex);
            rTypes.SetSeatsType(rdgSeats.ItemIndex);
            rTypes.SetPosType(rdgPos.ItemIndex);

            fmAlign_Slide.ReadFromUI(@rConstraints[tmSlide]);
            fmAlign_CushTilt.ReadFromUI(@rConstraints[tmCushTilt]);
            fmAlign_WalkinTilt.ReadFromUI(@rConstraints[tmWalkinUpTilt]);
            fmAlign_Recl.ReadFromUI(@rConstraints[tmRecl]);
            fmAlign_Relax.ReadFromUI(@rConstraints[tmRelax]);
            fmAlign_Shoulder.ReadFromUI(@rConstraints[tmShoulder]);

            fmMtr_Slide.ReadFromUI(@rSpecs.rMotors[tmSlide], @rConstraints[tmSlide]);
            fmMtr_CushTilt.ReadFromUI(@rSpecs.rMotors[tmCushTilt], @rConstraints[tmCushTilt]);
            fmMtr_WalkinTilt.ReadFromUI(@rSpecs.rMotors[tmWalkinUpTilt], @rConstraints[tmWalkinUpTilt]);
            fmMtr_Recl.ReadFromUI(@rSpecs.rMotors[tmRecl], @rConstraints[tmRecl]);
            fmMtr_Relax.ReadFromUI(@rSpecs.rMotors[tmRelax], @rConstraints[tmRelax]);
            fmMtr_Shoulder.ReadFromUI(@rSpecs.rMotors[tmShoulder], @rConstraints[tmShoulder]);

            rSpecs.rOnCurr[hvtHeat].ReadFromEdit(edtHeatOn_CurrLo, edtHeatOn_CurrHi);
            rSpecs.rOffCurr[hvtHeat].ReadFromEdit(edtHeatOff_CurrLo, edtHeatOff_CurrHi);

            rSpecs.rOnCurr[hvtVent].ReadFromEdit(edtVentOn_CurrLo, edtVentOn_CurrHi);
            rSpecs.rOffCurr[hvtVent].ReadFromEdit(edtVentOff_CurrLo, edtVentOff_CurrHi);

            rSpecs.rBuckle.ReadFromEdit(edtBuckleOn_VoltLo, edtBuckleOn_VoltHi);

            rSpecs.rMotors[tmRecl].rAngle[twForw].ReadFromEdit(edtFolding_AngleLo, edtFolding_AngleHi);
            rSpecs.rMotors[tmRecl].rAngle[twBack].ReadFromEdit(edtRearMost_AngleLo, edtRearMost_AngleHi);
        end
        else
        begin
            edtPartName.Text := string(rPartName);

            rdgCar.ItemIndex := rTypes.GetCarTypeToInt;
            rdgCarTrim.ItemIndex := rTypes.GetCarTrimTypeToInt;
            rdgSeats.ItemIndex := rTypes.GetSeatsTypeToInt;
            rdgPos.ItemIndex := rTypes.GetPosTypeToInt;

            fmAlign_Slide.WriteToUI(@rConstraints[tmSlide]);
            fmAlign_CushTilt.WriteToUI(@rConstraints[tmCushTilt]);
            fmAlign_WalkinTilt.WriteToUI(@rConstraints[tmWalkinUpTilt]);
            fmAlign_Recl.WriteToUI(@rConstraints[tmRecl]);
            fmAlign_Relax.WriteToUI(@rConstraints[tmRelax]);
            fmAlign_Shoulder.WriteToUI(@rConstraints[tmShoulder]);

            fmMtr_Slide.WriteToUI(@rSpecs.rMotors[tmSlide], @rConstraints[tmSlide]);
            fmMtr_CushTilt.WriteToUI(@rSpecs.rMotors[tmCushTilt], @rConstraints[tmCushTilt]);
            fmMtr_WalkinTilt.WriteToUI(@rSpecs.rMotors[tmWalkinUpTilt], @rConstraints[tmWalkinUpTilt]);
            fmMtr_Recl.WriteToUI(@rSpecs.rMotors[tmRecl], @rConstraints[tmRecl]);
            fmMtr_Relax.WriteToUI(@rSpecs.rMotors[tmRelax], @rConstraints[tmRelax]);
            fmMtr_Shoulder.WriteToUI(@rSpecs.rMotors[tmShoulder], @rConstraints[tmShoulder]);

            rSpecs.rOnCurr[hvtHeat].WriteToEdit(edtHeatOn_CurrLo, edtHeatOn_CurrHi);
            rSpecs.rOffCurr[hvtHeat].WriteToEdit(edtHeatOff_CurrLo, edtHeatOff_CurrHi);

            rSpecs.rOnCurr[hvtVent].WriteToEdit(edtVentOn_CurrLo, edtVentOn_CurrHi);
            rSpecs.rOffCurr[hvtVent].WriteToEdit(edtVentOff_CurrLo, edtVentOff_CurrHi);

            rSpecs.rBuckle.WriteToEdit(edtBuckleOn_VoltLo, edtBuckleOn_VoltHi);

            rSpecs.rMotors[tmRecl].rAngle[twForw].WriteToEdit(edtFolding_AngleLo, edtFolding_AngleHi);
            rSpecs.rMotors[tmRecl].rAngle[twBack].WriteToEdit(edtRearMost_AngleLo, edtRearMost_AngleHi);
        end;
    end;
    Result := true;
    Exit;

EDIT_ERROR:
    Application.MessageBox(PChar(sTm + _TR(' 입력오류 확인하세요!')), PChar(Caption), MB_ICONERROR + MB_OK);
    gLog.ToFiles('%s', [sTm]);
end;

procedure TfrmEdit.Save(AItems: array of boolean);
var
    i, Cnt: integer;
    Buf: TModels;
    dPos: TMotorDeliveryPos;
begin
    if TransModels(true) then
    begin
        gModels.EditModel(mModels, false);

        if Assigned(mChangeEvent) then
            mChangeEvent(Self, 0);
    end;
end;

procedure TfrmEdit.Init;
var
    i: integer;
    CbxRect: TRect;
begin

    labIndex.Caption := IntToStr(1);

    for i := 0 to ComponentCount - 1 do
    begin
        if Components[i] is TEdit then
        begin
            with Components[i] as TEdit do
                Text := '';
        end;
    end;
    FillChar(mModels, sizeof(TModels), 0);

    WriteAsCarType(rdgCar, true);
    WriteToRG(TSEATS_TYPE_STR, rdgSeats, false, 'SEATS');
    WriteToRG(TPOS_TYPE_STR, rdgPos, false, 'POS');
    WriteToRG(TCAR_TRIM_TYPE_STR, rdgCarTrim, false, 'TRIM');

    fmAlign_Slide.Init(tmSlide, False, False);
    fmAlign_CushTilt.Init(tmCushTilt, True, False);
    fmAlign_WalkinTilt.Init(tmWalkinUpTilt, True, False);
    fmAlign_Recl.Init(tmRecl, False, False);
    fmAlign_Relax.Init(tmRelax, True, False);
    fmAlign_Shoulder.Init(tmShoulder, False, False);

    fmMtr_Slide.Init(tmSlide);
    fmMtr_CushTilt.Init(tmCushTilt, True);
    fmMtr_WalkinTilt.Init(tmWalkinUpTilt, True);
    fmMtr_Recl.Init(tmRecl);
    fmMtr_Relax.Init(tmRelax, True);
    fmMtr_Shoulder.Init(tmShoulder);
end;

procedure TfrmEdit.OnSaveBtnActive(Sender: TObject);
begin
    if mInit then
        Exit;

    TWinControl(Sender).Tag := 1;

    if Assigned(mChangeEvent) then
        OnUserChange(Self, 1);
end;

procedure TfrmEdit.ReadMessage(var myMsg: TMessage);
begin
    case myMsg.WParam of
        SYS_MODEL:
            begin
                SetFrm(myMsg.LParam);
            end;
        SYS_SAVE_DATA:
            begin
                Save([]);
            end;
    end;
end;

end.

