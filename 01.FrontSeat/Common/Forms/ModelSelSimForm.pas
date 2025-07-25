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
        rdgCarType: TRadioGroup;
        rdgPosType: TRadioGroup;
    rdgHostHVType: TRadioGroup;
        rdgBuckType: TRadioGroup;
    rdgSeatType: TRadioGroup;
        cbxStation: TComboBox;
        clbOpt: TCheckListBox;
        Label3: TLabel;
        lblTypeBits: TLabel;
        ledTypeBits: TLedArray;
        procedure FormClose(Sender: TObject; var Action: TCloseAction);
        procedure bbtnApplyClick(Sender: TObject);
        procedure rdgCarTypeClick(Sender: TObject);
        procedure cbxStationChange(Sender: TObject);
        procedure cbxIMSClick(Sender: TObject);
        procedure rdgHostHVTypeClick(Sender: TObject);
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
var
    OptType: TMdlOptType;
begin
//
    mIsShow := True;

    WriteAsCarType(rdgCarType, false);
    WriteToRG(TCAR_TRIM_TYPE_STR, rdgSeatType, false, 'TRIM');
    WriteToRG(THV_TYPE_STR, rdgHostHVType, false, 'H/V(HOST)');

    //clbOpt에 TMdlOptType 항목 자동 추가
    clbOpt.Clear;
    for OptType := Low(TMdlOptType) to High(TMdlOptType) do
    begin
        clbOpt.Items.AddObject(mModelType.GetOptStr(OptType), TObject(Ord(OptType)));
    end;



    UpdateForm(TModelType.Create(mDataIO.GetDataAsDWord(1), mDataIO.GetDataAsWord(0)));

    rdgCarTypeClick(nil);

    TLangTran.ChangeCaption(self);

end;

procedure TfrmModelSelSim.cbxIMSClick(Sender: TObject);
begin
    rdgCarTypeClick(nil);
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
    rdgCarTypeClick(nil);
end;

procedure TfrmModelSelSim.clbOptClickCheck(Sender: TObject);
begin
    clbOpt.Checked[clbOpt.ItemIndex] := not clbOpt.Checked[clbOpt.ItemIndex];
    rdgCarTypeClick(nil);
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

procedure TfrmModelSelSim.rdgCarTypeClick(Sender: TObject);
var
    Ch: integer;
    OldBigEndianState: Boolean;
begin
    if mIsSet then
        Exit;

    mModelType.Clear;

    mModelType.SetCarType(TCAR_TYPE(rdgCarType.ItemIndex));
    mModelType.SetPosTypeEx(TPOS_TYPE_EX(rdgPosType.ItemIndex));
    mModelType.SetTrimType(TCAR_TRIM_TYPE(rdgSeatType.ItemIndex));
    mModelType.SetHostHVType(THV_TYPE(rdgHostHVType.ItemIndex));


    mModelType.SetBuckleType(TBuckleTestType(rdgBuckType.ItemIndex));

    SeatTypeUI.ReadAsOpt(mModelType, clbOpt);

    Ch := cbxStation.ItemIndex * 3;

    mDataIO.SetDataAsWord(Ch + 1, $FFFF and mModelType.mDataBits);
    mDataIO.SetDataAsWord(Ch + 2, $FFFF and (mModelType.mDataBits shr 16));

    lblTypeBits.Caption := Format('0x%.X', [mModelType.mDataBits]);
    ledTypeBits.OnOff := mModelType.mDataBits;

    if Assigned(mOnChange) then
        mOnChange(Self);


end;

procedure TfrmModelSelSim.rdgHostHVTypeClick(Sender: TObject);
begin
    rdgHostHVType.ItemIndex := rdgHostHVType.ItemIndex;

    rdgCarTypeClick(nil);
end;

procedure TfrmModelSelSim.UpdateForm(ModelType: TModelType);
begin
    mIsSet := true;

    mModelType := ModelType;

    rdgCarType.ItemIndex := Ord(mModelType.GetCarType);
    rdgPosType.ItemIndex := Ord(mModelType.GetPosTypeEx);


    {
    if mModelType.IsMnl then
        rdgWayType.ItemIndex := Ord(mModelType.GetMnlWayType)
    else
        rdgWayType.ItemIndex := Ord(mModelType.GetWayType);
    }

    rdgHostHVType.ItemIndex := Ord(mModelType.GetHVType);
    rdgBuckType.ItemIndex := Ord(mModelType.GetBuckleType);

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
    rdgCarType.Items.Clear;

    for i := 0 to integer(High(TCAR_TYPE)) do
    begin
        rdgCarType.Items.Add(TCAR_TYPE_STR[i]);
    end;

end;

procedure TfrmModelSelSim.bbtnApplyClick(Sender: TObject);
begin
    rdgCarTypeClick(nil);

    {
    if Assigned(mOnChange) then
        if mOnChange(Self) then
            Close;
    }
    Close;

end;

end.

