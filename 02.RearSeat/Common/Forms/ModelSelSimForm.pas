unit ModelSelSimForm;

interface

uses
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, StdCtrls, ExtCtrls, DataUnit, LanIOUnit, Buttons, ModelType,
    CheckLst, LedArray, BaseDIO;

type
    TMdlSelSimNotifyEvent = function(Sender: TObject): boolean of object;

    TfrmModelSelSim = class(TForm)
        Panel1: TPanel;
        bbtnApply: TBitBtn;
        rdgCar: TRadioGroup;
        rdgPos: TRadioGroup;
        rdgHV: TRadioGroup;
        rdgSeats: TRadioGroup;
        cbxStation: TComboBox;
        clbOpt: TCheckListBox;
        Label3: TLabel;
        lblTypeBits: TLabel;
        ledTypeBits: TLedArray;
    rdgCarTrim: TRadioGroup;
        procedure FormClose(Sender: TObject; var Action: TCloseAction);
        procedure bbtnApplyClick(Sender: TObject);
        procedure rdgCarClick(Sender: TObject);
        procedure cbxStationChange(Sender: TObject);
        procedure rdgHVClick(Sender: TObject);
        procedure rdgPsgHVTypeClick(Sender: TObject);
        procedure clbOptClick(Sender: TObject);
        procedure clbOptClickCheck(Sender: TObject);
        procedure clbOptDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
        procedure lblTypeBitsDblClick(Sender: TObject);
        procedure FormShow(Sender: TObject);
    private
    { Private declarations }
        mDataIO: TBaseDIO;
        mModelType: TModelType;
        mIsSet: boolean;

        mOnChange: TMdlSelSimNotifyEvent;
        procedure UpdateForm(ModelType: TModelType);

    public
    { Public declarations }
        class var
            mIsShow: Boolean;
        procedure SetForm(DataIO: TBaseDIO; StationNames: array of string; AOnChange: TMdlSelSimNotifyEvent = nil);

        property DataIO: TBaseDIO read mDataIO;
        property OnChange: TMdlSelSimNotifyEvent read mOnChange write mOnChange;
    end;

var
    frmModelSelSim: TfrmModelSelSim;

implementation

uses
    Math, SeatType, SeatTypeUI, Clipbrd, LangTran;

{$R *.dfm}

procedure TfrmModelSelSim.lblTypeBitsDblClick(Sender: TObject);
begin
    Clipboard().AsText := lblTypeBits.Caption;
end;

procedure TfrmModelSelSim.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    mIsShow := False;
    Action := caFree;
end;

procedure TfrmModelSelSim.FormShow(Sender: TObject);
begin
//
    mIsShow := True;

    WriteAsCarType(rdgCar, false);
    WriteToRG(TSEATS_TYPE_STR, rdgSeats, false, 'SEATS');
    WriteToRG(TPOS_TYPE_STR, rdgPos, false, 'POS');
    WriteToRG(TCAR_TRIM_TYPE_STR, rdgCarTrim, false, 'TRIM');
    WriteToRG(THV_TYPE_STR, rdgHV, false, 'H/V');

    mModelType.WriteAsOptName(clbOpt.Items, [motHVPSU, motSAU, motWarnBuckle, motILLBuckle, motCTRBuckle, motWalkin, motRelax, motPE]);

    UpdateForm(TModelType.Create(mDataIO.GetDataAsDWord(1), mDataIO.GetDataAsWord(0)));

    rdgCarClick(nil);

    TLangTran.ChangeCaption(self);

end;

procedure TfrmModelSelSim.cbxStationChange(Sender: TObject);
var
    Ch: integer;
begin
    Ch := cbxStation.ItemIndex * 3;

    UpdateForm(TModelType.Create(mDataIO.GetDataAsDWord(Ch + 1), mDataIO.GetDataAsWord(Ch)));
end;

procedure TfrmModelSelSim.clbOptClick(Sender: TObject);
begin
    clbOpt.Checked[clbOpt.ItemIndex] := not clbOpt.Checked[clbOpt.ItemIndex];
    rdgCarClick(nil);
end;

procedure TfrmModelSelSim.clbOptClickCheck(Sender: TObject);
begin
    clbOpt.Checked[clbOpt.ItemIndex] := not clbOpt.Checked[clbOpt.ItemIndex];
    rdgCarClick(nil);
end;

procedure TfrmModelSelSim.clbOptDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
    Text: string;
begin
    with clbOpt.Canvas do
    begin
        Brush.Color := clbOpt.Color;
        Font.Color := clWindowText;
        FillRect(Rect);
        Text := '   ' + clbOpt.Items.Strings[Index];
        DrawText(Handle, PChar(Text), Length(Text), Rect, DT_LEFT or DT_VCENTER or DT_SINGLELINE);
    end;
end;

procedure TfrmModelSelSim.rdgCarClick(Sender: TObject);
var
    Ch: integer;
begin
    if mIsSet then
        Exit;

    mModelType.Clear;

    mModelType.SetCarType(TCAR_TYPE(rdgCar.ItemIndex));
    mModelType.SetSeatsType(TSEATS_TYPE(rdgSeats.ItemIndex));
    mModelType.SetPosType(TPOS_TYPE(rdgPos.ItemIndex));
    mModelType.SetCarTrimType(TCAR_TRIM_TYPE(rdgCarTrim.ItemIndex));
    mModelType.SetHVType(THV_TYPE(rdgHV.ItemIndex));

    SeatTypeUI.ReadAsOpt(mModelType, clbOpt);

    Ch := cbxStation.ItemIndex * 3;

    mDataIO.SetDataAsWord(Ch + 1, $FFFF and mModelType.mDataBits);
    mDataIO.SetDataAsWord(Ch + 2, $FFFF and (mModelType.mDataBits shr 16));

    lblTypeBits.Caption := Format('0x%.X', [mModelType.mDataBits]);
    ledTypeBits.OnOff := mModelType.mDataBits;

    if Assigned(mOnChange) then
        mOnChange(Self);
end;

procedure TfrmModelSelSim.rdgHVClick(Sender: TObject);
begin
    rdgCarClick(nil);
end;

procedure TfrmModelSelSim.rdgPsgHVTypeClick(Sender: TObject);
begin
    rdgCarClick(nil);
end;

procedure TfrmModelSelSim.UpdateForm(ModelType: TModelType);
begin
    mIsSet := true;

    mModelType := ModelType;
    rdgCar.ItemIndex := Ord(mModelType.GetCarType);
    rdgSeats.ItemIndex := Ord(mModelType.GetSeatsType);
    rdgPos.ItemIndex := Ord(mModelType.GetPosType);
    rdgCarTrim.ItemIndex := Ord(mModelType.GetCarTrimType);
    rdgHV.ItemIndex := Ord(mModelType.GetHVType);

    SeatTypeUI.WriteAsOpt(mModelType, clbOpt);
    mIsSet := false;
end;

procedure TfrmModelSelSim.SetForm(DataIO: TBaseDIO; StationNames: array of string; AOnChange: TMdlSelSimNotifyEvent);
var
    i: integer;
begin
    mDataIO := DataIO;
    mOnChange := AOnChange;

    if Length(StationNames) > 0 then
    begin
        cbxStation.Visible := true;
        for i := 0 to Length(StationNames) - 1 do
        begin
            cbxStation.Items.Add(StationNames[i]);
        end;

        cbxStation.ItemIndex := 0;
    end;

    cbxStation.Visible := cbxStation.Items.Count > 1;
    rdgCar.Items.Clear;

    for i := 0 to integer(High(TCAR_TYPE)) do
    begin
        rdgCar.Items.Add(TCAR_TYPE_STR[i]);
    end;

end;

procedure TfrmModelSelSim.bbtnApplyClick(Sender: TObject);
begin
    rdgCarClick(nil);

    Close;
end;

end.

