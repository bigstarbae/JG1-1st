unit EditForm;
{$INCLUDE myDefine.inc}

interface

uses
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, ExtCtrls, StdCtrls, Buttons, ImgList, DataUnit, KiiMessages,
    ComCtrls, ModelType, SeatType, SeatMotorType, Grids, pngimage, Label3D;

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
        pnlAP_Slide: TPanel;
        Label18: TLabel;
        Shape8: TShape;
        Label15: TLabel;
        edtAPLoadLo_Slide: TEdit;
        Label16: TLabel;
        edtAPLoadHi_Slide: TEdit;
        Label17: TLabel;
        Label79: TLabel;
        edtAPStopCurrHi_Slide: TEdit;
        Label78: TLabel;
        Label81: TLabel;
        Label82: TLabel;
        edtAPRevCurrLo_Slide: TEdit;
        Label80: TLabel;
        Label77: TLabel;
        pnlAP_Recl: TPanel;
        Label1: TLabel;
        Shape1: TShape;
        Label3: TLabel;
        Label4: TLabel;
        Label5: TLabel;
        Label7: TLabel;
        Label8: TLabel;
        Label10: TLabel;
        Label11: TLabel;
        Label12: TLabel;
        Label13: TLabel;
        edtAPLoadLo_Recl: TEdit;
        edtAPStopCurrHi_Recl: TEdit;
        edtAPLoadHi_Recl: TEdit;
        edtAPRevCurrLo_Recl: TEdit;
    sgAPOffset_Slide: TStringGrid;
    sgAPOffset_Recl: TStringGrid;
        procedure FormClose(Sender: TObject; var Action: TCloseAction);
        procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
        procedure FormCreate(Sender: TObject);
        procedure FormDestroy(Sender: TObject);
        procedure FormShow(Sender: TObject);
        procedure OnSaveBtnActive(Sender: TObject);
    procedure Label18DblClick(Sender: TObject);
    procedure Label1DblClick(Sender: TObject);
    private
    { Private declarations }
        mInit: boolean;
        mChangeEvent: TNotifyStatus;
        mModels: TModels;

        procedure Init;

        function TransModels(aIsEdit: boolean): boolean;
        procedure ReadMessage(var myMsg: TMessage);

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
    DioReferForm, IniFiles, LanIOUnit, SysEnv, IODef, TsWorkUnit, LangTran, FormUtils;

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
            rTypes.SetPosType(rdgPos.ItemIndex);

            rSpecs.rAntiPinch[atSlide].rLoad.ReadFromEdit(edtAPLoadLo_Slide, edtAPLoadHi_Slide);
            rSpecs.rAntiPinch[atSlide].rStopCurr := StrToFloatDef(edtAPStopCurrHi_Slide.Text, 0.3);
            rSpecs.rAntiPinch[atSlide].rRisingcurr := StrToFloatDef(edtAPRevCurrLo_Slide.Text, 0.3);

            rSpecs.rAntiPinch[atRecline].rLoad.ReadFromEdit(edtAPLoadLo_Recl, edtAPLoadHi_Recl);
            rSpecs.rAntiPinch[atRecline].rStopCurr := StrToFloatDef(edtAPStopCurrHi_Recl.Text, 0.3);
            rSpecs.rAntiPinch[atRecline].rRisingcurr := StrToFloatDef(edtAPRevCurrLo_Recl.Text, 0.3);

        end
        else
        begin
            edtPartName.Text := string(rPartName);

            rdgCar.ItemIndex := rTypes.GetCarTypeToInt;
            rdgPos.ItemIndex := rTypes.GetPosTypeToInt;

            rSpecs.rAntiPinch[atSlide].rLoad.WriteToEdit(edtAPLoadLo_Slide, edtAPLoadHi_Slide);
            edtAPStopCurrHi_Slide.Text := GetUsrFloatToStr(rSpecs.rAntiPinch[atSlide].rStopCurr);
            edtAPRevCurrLo_Slide.Text := GetUsrFloatToStr(rSpecs.rAntiPinch[atSlide].rRisingcurr);

            rSpecs.rAntiPinch[atRecline].rLoad.WriteToEdit(edtAPLoadLo_Recl, edtAPLoadHi_Recl);
            edtAPStopCurrHi_Recl.Text := GetUsrFloatToStr(rSpecs.rAntiPinch[atRecline].rStopCurr);
            edtAPRevCurrLo_Recl.Text := GetUsrFloatToStr(rSpecs.rAntiPinch[atRecline].rRisingcurr);
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
    WriteToRG(TPOS_TYPE_STR, rdgPos, false, 'POS');
end;

procedure TfrmEdit.Label18DblClick(Sender: TObject);
begin
    sgAPOffset_Slide.Visible := not sgAPOffset_Slide.Visible;
end;

procedure TfrmEdit.Label1DblClick(Sender: TObject);
begin
    sgAPOffset_Recl.Visible := not sgAPOffset_Recl.Visible;
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

