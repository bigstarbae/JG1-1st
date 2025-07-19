
unit SeatTypeUI;

interface
uses
    SeatType, ModelType, ExtCtrls, CheckLst;

    procedure WriteToRG(ATypes: array of string; RG: TRadioGroup; IsHori: boolean; Caption: string = '');

    procedure WriteAsCarType(RG: TRadioGroup; IsHori: boolean; Caption: string = '');

    procedure ReadAsType(var Modeltype: TModelType; PosRG, CarTypeRG, WayTypeRG, DrvHVTypeRG, PsgHVTypeRG, BklRG: TRadioGroup);
    procedure WriteAsType(ModelType: TModelType; PosRG, CarTypeRG, WayTypeRG, DrvHVTypeRG, PsgHVTypeRG, BklRG: TRadioGroup);

    procedure ReadAsOpt(var ModelType: TModelType; ChkListBox: TCheckListBox);
    procedure WriteAsOpt(ModelType: TModelType; ChkListBox: TCheckListBox);

implementation
uses
    Rtti, TypInfo, myUtils;


procedure WriteToRG(ATypes: array of string; RG: TRadioGroup; IsHori: boolean; Caption: string);
var
    i: integer;
begin

    if Caption <> '' then
        RG.Caption := Caption;
    RG.Items.Clear;

    if IsHori then
    begin
        RG.Columns := Length(ATypes);
    end;


    for i := 0 to Length(ATypes) - 1 do
    begin
        RG.Items.Add(ATypes[i]);
    end;

end;

procedure WriteAsCarType(RG: TRadioGroup; IsHori: boolean; Caption: string = '');
var
    i: Integer;
    SeatNames: array of string;
    CarType: TCAR_TYPE;
begin
    SetLength(SeatNames, Ord(ctSPARE1));
    i := 0;
    for CarType := Low(TCAR_TYPE) to Pred(ctSPARE1) do
    begin
        SeatNames[i] := TCAR_TYPE_STR[i];
        Inc(i);
    end;

    WriteToRG(SeatNames, RG, IsHori, Caption);
end;

procedure ReadAsType(var Modeltype: TModelType; PosRG, CarTypeRG, WayTypeRG, DrvHVTypeRG, PsgHVTypeRG, BklRG: TRadioGroup);
begin
    ModelType.SetPosTypeEx(TPOS_TYPE_EX(PosRG.ItemIndex));
    ModelType.SetCarType(TCAR_TYPE(CarTypeRG.ItemIndex));
    ModelType.SetHostHVType(THV_TYPE(DrvHVTypeRG.ItemIndex));
    //ModelType.SetHVType(THV_TYPE(PsgHVTypeRG.ItemIndex));
    ModelType.SetBuckleType(TBuckleTestType(BklRG.ItemIndex));
end;

procedure WriteAsType(ModelType: TModelType; PosRG, CarTypeRG, WayTypeRG, DrvHVTypeRG, PsgHVTypeRG, BklRG: TRadioGroup);
begin
    PosRG.ItemIndex := integer(ModelType.GetPosTypeEx);
    CarTypeRG.ItemIndex := integer(ModelType.GetCarType);

    DrvHVTypeRG.ItemIndex := integer(ModelType.GetHVType);
    PsgHVTypeRG.ItemIndex := integer(ModelType.GetHVType);

    BklRG.ItemIndex := integer(ModelType.GetBuckleType);
end;


procedure ReadAsOpt(var ModelType: TModelType; ChkListBox: TCheckListBox);
var
    i: integer;
begin

    for i := 0 to ChkListBox.Count - 1 do
    begin
        ModelType.SetOpt(TMdlOptType(ChkListBox.Items.Objects[i]), ChkListBox.Checked[i]);
    end;

end;


procedure WriteAsOpt(ModelType: TModelType; ChkListBox: TCheckListBox);
var
    i: integer;
begin
    for i := 0 to ChkListBox.Count - 1 do
    begin
        ChkListBox.Checked[i] := ModelType.GetOpt(TMdlOptType(ChkListBox.Items.Objects[i]));
    end;

end;

end.

