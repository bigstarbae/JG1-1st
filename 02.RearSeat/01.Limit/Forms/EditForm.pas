unit EditForm;
{$INCLUDE myDefine.inc}

interface

uses
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, ExtCtrls, StdCtrls, Buttons, ImgList, DataUnit, KiiMessages,
    ComCtrls, ModelType, SeatType, SeatMotorType, Grids, pngimage, Label3D,
    AlignSpecFrame;

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
        TabSheet1: TTabSheet;
        rdgCar: TRadioGroup;
        rdgPos: TRadioGroup;
    rdgCarTrim: TRadioGroup;
        rdgSeats: TRadioGroup;
    gbxAlign: TGroupBox;
        fmSlide: TAlignSpecFrme;
        fmShoulder: TAlignSpecFrme;
        fmRecl: TAlignSpecFrme;
        fmWalkinTilt: TAlignSpecFrme;
        fmCushTilt: TAlignSpecFrme;
        fmRelax: TAlignSpecFrme;
        procedure FormClose(Sender: TObject; var Action: TCloseAction);
        procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
        procedure FormCreate(Sender: TObject);
        procedure FormDestroy(Sender: TObject);
        procedure FormShow(Sender: TObject);
        procedure OnSaveBtnActive(Sender: TObject);
    private
        { Private declarations }
        mInit: Boolean;
        mChangeEvent: TNotifyStatus;
        mModels: TModels;
        mIsMdlExSave: Boolean;

        procedure Init;

        function TransModels(aIsEdit: Boolean): Boolean;
        procedure ReadMessage(var myMsg: TMessage);
        procedure SetExistMtrVisible;

    public
        { Public declarations }
        procedure SetFrm(aIndex: Integer);
        procedure Save(AItems: array of Boolean);

        property OnUserChange: TNotifyStatus read mChangeEvent write mChangeEvent;
    end;

var
    frmEdit: TfrmEdit;

implementation

uses
    Global, ModelUnit, SeatTypeUI, Log, myUtils, Math, DioForm, PasswdForm,
    DioReferForm, IniFiles, LanIOUnit, SysEnv, IODef, TsWorkUnit, LangTran,
    FormUtils;
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
    i: Integer;
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

    pcMdl.ActivePageIndex := 0;

    TLangTran.ChangeCaption(self);
end;

procedure TfrmEdit.SetFrm(aIndex: Integer);
var
    iDx: Integer;
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

    AttachSaveEventToControlChild(Self, OnSaveBtnActive);

    if Assigned(mChangeEvent) then
        OnUserChange(self, 0);
end;


procedure TfrmEdit.SetExistMtrVisible;
begin
    fmSlide.Visible := mModels.rTypes.IsSlideMtrExists;
    fmCushTilt.Visible := mModels.rTypes.IsCushTiltMtrExists;
    fmWalkinTilt.Visible := mModels.rTypes.IsWalkinTiltMtrExists;
    fmRecl.Visible := mModels.rTypes.IsReclineMtrExists;
    fmRelax.Visible := mModels.rTypes.IsRelaxMtrExists;
    fmShoulder.Visible := mModels.rTypes.IsShoulderMtrExists;

    RefreshAlignedControls([fmSlide, fmCushTilt, fmWalkinTilt, fmRecl, fmRelax, fmShoulder], alTop);
end;

function TfrmEdit.TransModels(aIsEdit: Boolean): Boolean;
label
    EDIT_ERROR;
var
    iTm: Integer;
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

            fmSlide.ReadFromUI(@rConstraints[tmSlide]);
            fmCushTilt.ReadFromUI(@rConstraints[tmCushTilt]);
            fmWalkinTilt.ReadFromUI(@rConstraints[tmWalkinUpTilt]);
            fmRecl.ReadFromUI(@rConstraints[tmRecl]);
            fmRelax.ReadFromUI(@rConstraints[tmRelax]);
            fmShoulder.ReadFromUI(@rConstraints[tmShoulder]);
        end
        else
        begin
            edtPartName.Text := string(rPartName);

            rdgCar.ItemIndex := rTypes.GetCarTypeToInt;
            rdgCarTrim.ItemIndex := rTypes.GetCarTrimTypeToInt;
            rdgSeats.ItemIndex := rTypes.GetSeatsTypeToInt;
            rdgPos.ItemIndex := rTypes.GetPosTypeToInt;

            fmSlide.WriteToUI(@rConstraints[tmSlide]);
            fmCushTilt.WriteToUI(@rConstraints[tmCushTilt]);
            fmWalkinTilt.WriteToUI(@rConstraints[tmWalkinUpTilt]);
            fmRecl.WriteToUI(@rConstraints[tmRecl]);
            fmRelax.WriteToUI(@rConstraints[tmRelax]);
            fmShoulder.WriteToUI(@rConstraints[tmShoulder]);
        end;
    end;
    Result := true;
    Exit;

EDIT_ERROR:
    Application.MessageBox(PChar(sTm + _TR(' 입력오류 확인하세요!')), PChar(Caption), MB_ICONERROR + MB_OK);
    gLog.ToFiles('%s', [sTm]);
end;

procedure TfrmEdit.Save(AItems: array of Boolean);
var
    i, Cnt: Integer;
    Buf: TModels;
    dPos: TMotorDeliveryPos;
begin
    if TransModels(true) then
    begin
        gModels.EditModel(mModels, false);

        if Assigned(mChangeEvent) then
            mChangeEvent(self, 0);
    end;
end;

procedure TfrmEdit.Init;
var
    i: Integer;
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
    WriteToRG(TCAR_Trim_TYPE_STR, rdgCarTrim, false, 'CAR TRIM');

    fmSlide.Init(tmSlide);
    fmCushTilt.Init(tmCushTilt, True);
    fmWalkinTilt.Init(tmWalkinUpTilt, True);
    fmRecl.Init(tmRecl);
    fmRelax.Init(tmRelax, True);
    fmShoulder.Init(tmShoulder);
end;

procedure TfrmEdit.OnSaveBtnActive(Sender: TObject);
begin
    if mInit then
        Exit;

    TWinControl(Sender).Tag := 1;

    if Assigned(mChangeEvent) then
        OnUserChange(self, 1);
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

