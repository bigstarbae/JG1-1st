unit MotorSpecFrame;

interface

uses
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, StdCtrls, ExtCtrls, Grids, DataUnit, SeatMotorType;

type
    TMtrSpecFrame = class(TFrame)
        lblTitle: TLabel;
        Shape1: TShape;
        lblSpeedTitle1: TLabel;
        Label18: TLabel;
        lblSpeedUnit1: TLabel;
        Label7: TLabel;
        Label57: TLabel;
        lblSpeedTitle2: TLabel;
        Label64: TLabel;
        lblSpeedUnit2: TLabel;
        lblStrokeUnit: TLabel;
        Label11: TLabel;
        Label20: TLabel;
        Label79: TLabel;
        Label80: TLabel;
        Label81: TLabel;
        Label82: TLabel;
        Label83: TLabel;
        Label10: TLabel;
        Label25: TLabel;
        Label28: TLabel;
        Label29: TLabel;
        Label30: TLabel;
        Label31: TLabel;
        Label56: TLabel;
        edtMaxOperTime: TEdit;
        edtStroke: TEdit;
        Panel2: TPanel;
        rgOperMethod: TRadioGroup;
        edtCurrTimeMin: TEdit;
        edtCurrTimeMax: TEdit;
        edtCurrMin: TEdit;
        edtlCurrMax: TEdit;
        lblPositionTitle1: TLabel;
        Label2: TLabel;
        lblPositionUnit1: TLabel;
        Label4: TLabel;
        lblPositionTitle2: TLabel;
        Label6: TLabel;
        lblPositionUnit2: TLabel;
        edtFwPosMin: TEdit;
        edtFwPosMax: TEdit;
        edtBwPosMin: TEdit;
        edtBwPosMax: TEdit;
        sgOffset: TStringGrid;
        edtFwSpeedMin: TEdit;
        edtBwSpeedMin: TEdit;
        edtFwSpeedMax: TEdit;
        edtBwSpeedMax: TEdit;
        edtInitNoiseMax: TEdit;
        edtRunNoiseMax: TEdit;
        edtInitNoiseTime: TEdit;
        edtLockedCurr: TEdit;
        edtOperTime: TEdit;
        procedure edtOperTimeChange(Sender: TObject);
    procedure lblTitleDblClick(Sender: TObject);
    private
    { Private declarations }
        mOnStatusChange: TNotifyEvent;
    public
    { Public declarations }
        procedure Init(MotorORD: TMotorOrd; IsUpDn: Boolean = false);
        procedure WriteToUI(MtrSpec: PMotorSpec; MtrCnst: PMotorConstraints);
        procedure ReadFromUI(MtrSpec: PMotorSpec; MtrCnst: PMotorConstraints);

        property OnStatusChange: TNotifyEvent read mOnStatusChange write mOnStatusChange;
    end;

implementation

uses
    myUtils;

{$R *.dfm}

{ TMtrSpecFrame }

procedure TMtrSpecFrame.Init(MotorORD: TMotorOrd; IsUpDn: Boolean);
begin
    lblTitle.Caption := _MOTOR_ID_STR[MotorORD];

    if IsUpDn then
    begin
        lblSpeedTitle1.Caption := '상승 기준';
        lblSpeedTitle2.Caption := '하강 기준';
        lblPositionTitle1.Caption := '상승 기준';
        lblPositionTitle2.Caption := '하강 기준';
    end;

    sgOffset.Top := 31;
    sgOffset.Left := 380;

end;

procedure TMtrSpecFrame.lblTitleDblClick(Sender: TObject);
begin
    sgOffset.Visible := not sgOffset.Visible;
end;

procedure TMtrSpecFrame.ReadFromUI(MtrSpec: PMotorSpec; MtrCnst: PMotorConstraints);
begin
    MtrSpec.rTime.ReadFromEdit(edtCurrTimeMin, edtCurrTimeMax);
    MtrSpec.rCurr.ReadFromEdit(edtCurrMin, edtlCurrMax);
    MtrSpec.rSpeed[twForw].ReadFromEdit(edtFwSpeedMin, edtFwSpeedMax);
    MtrSpec.rSpeed[twBack].ReadFromEdit(edtBwSpeedMin, edtBwSpeedMax);
    MtrSpec.rSpeed[twForw].ReadFromEdit(edtFwPosMin, edtFwPosMax);
    MtrSpec.rSpeed[twBack].ReadFromEdit(edtBwPosMin, edtBwPosMax);

    MtrSpec.rInitNoiseTime := StrToFloatDef(edtInitNoiseTime.Text, 1);
    MtrSpec.rInitNoise := StrToFloatDef(edtInitNoiseMax.Text, 45);
    MtrSpec.rRunNoise := StrToFloatDef(edtRunNoiseMax.Text, 50);

    MtrCnst.rMaxTime := StrToFloatDef(edtMaxOperTime.Text, 10);
    MtrCnst.rOperTime := StrToFloatDef(edtOperTime.Text, 10);
    MtrCnst.rLockedCurr := StrToFloatDef(edtLockedCurr.Text, 7);
    MtrCnst.rStroke := StrToFloatDef(edtStroke.Text, 240);
    MtrCnst.rMethodIdx := rgOperMethod.ItemIndex;
end;

procedure TMtrSpecFrame.WriteToUI(MtrSpec: PMotorSpec; MtrCnst: PMotorConstraints);
begin

    MtrSpec.rTime.WriteToEdit(edtCurrTimeMin, edtCurrTimeMax);
    MtrSpec.rCurr.WriteToEdit(edtCurrMin, edtlCurrMax);
    MtrSpec.rSpeed[twForw].WriteToEdit(edtFwSpeedMin, edtFwSpeedMax);
    MtrSpec.rSpeed[twBack].WriteToEdit(edtBwSpeedMin, edtBwSpeedMax);
    MtrSpec.rSpeed[twForw].WriteToEdit(edtFwPosMin, edtFwPosMax);
    MtrSpec.rSpeed[twBack].WriteToEdit(edtBwPosMin, edtBwPosMax);

    edtInitNoiseTime.Text := GetUsrFloatToStr(MtrSpec.rInitNoiseTime);
    edtInitNoiseMax.Text := GetUsrFloatToStr(MtrSpec.rInitNoise);
    edtRunNoiseMax.Text := GetUsrFloatToStr(MtrSpec.rRunNoise);

    edtMaxOperTime.Text := GetUsrFloatToStr(MtrCnst.rMaxTime);
    edtOperTime.Text := GetUsrFloatToStr(MtrCnst.rOperTime);
    edtLockedCurr.Text := GetUsrFloatToStr(MtrCnst.rLockedCurr);
    edtStroke.Text := GetUsrFloatToStr(MtrCnst.rStroke);
    rgOperMethod.ItemIndex := MtrCnst.rMethodIdx;

end;

procedure TMtrSpecFrame.edtOperTimeChange(Sender: TObject);
begin
    if Assigned(mOnStatusChange) then
        mOnStatusChange(Self);
end;

end.

