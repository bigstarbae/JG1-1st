unit MotorSpecFrame;

interface

uses
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, StdCtrls, ExtCtrls, Grids, DataUnit;

type
    TMtrSpecFrame = class(TFrame)
    lblTitle: TLabel;
        Shape1: TShape;
        Label17: TLabel;
        Label18: TLabel;
        Label21: TLabel;
        Label7: TLabel;
        Label57: TLabel;
        Label60: TLabel;
        Label64: TLabel;
        Label65: TLabel;
        Label66: TLabel;
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
        Label1: TLabel;
        Label2: TLabel;
        Label3: TLabel;
        Label4: TLabel;
        Label5: TLabel;
        Label6: TLabel;
        Label8: TLabel;
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
    private
    { Private declarations }
        mOnStatusChange: TNotifyEvent;
    public
    { Public declarations }

        procedure WriteToUI(MtrSpec: PMotorSpec; MtrCnst: PMotorConstraints);
        procedure ReadFromUI(MtrSpec: PMotorSpec; MtrCnst: PMotorConstraints);

        property OnStatusChange: TNotifyEvent read mOnStatusChange write mOnStatusChange;
    end;

implementation

uses
    SeatMotorType, myUtils;

{$R *.dfm}

{ TMtrSpecFrame }

procedure TMtrSpecFrame.ReadFromUI(MtrSpec: PMotorSpec; MtrCnst: PMotorConstraints);
begin
    MtrSpec.rTime.ReadFromEdit(edtCurrTimeMin, edtCurrTimeMax);
    MtrSpec.rCurr.ReadFromEdit(edtCurrMin, edtlCurrMax);
    MtrSpec.rSpeed[twForw].ReadFromEdit(edtFwSpeedMin, edtFwSpeedMax);
    MtrSpec.rSpeed[twBack].ReadFromEdit(edtBwSpeedMin, edtBwSpeedMax);
    MtrSpec.rPos[twForw].ReadFromEdit(edtFwPosMin, edtFwPosMax);
    MtrSpec.rPos[twBack].ReadFromEdit(edtBwPosMin, edtBwPosMax);

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
    MtrSpec.rPos[twForw].WriteToEdit(edtFwPosMin, edtFwPosMax);
    MtrSpec.rPos[twBack].WriteToEdit(edtBwPosMin, edtBwPosMax);

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

