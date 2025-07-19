
unit SeatTypeUI;

interface
uses
    SeatType, ModelType, ExtCtrls, CheckLst;

    procedure WriteToRG(ATypes: array of string; RG: TRadioGroup; IsHori: boolean; Caption: string = '');

    procedure WriteAsCarType(RG: TRadioGroup; IsHori: boolean; Caption: string = '');


    procedure ReadAsOpt(var ModelType: TModelType; ChkListBox: TCheckListBox);
    procedure WriteAsOpt(ModelType: TModelType; ChkListBox: TCheckListBox);

implementation
uses
    Rtti, TypInfo;


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
begin
    WriteToRG(TCAR_TYPE_STR, RG, IsHori, Caption);
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

