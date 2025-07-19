unit AlignSpecFrame;

interface

uses
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, StdCtrls, ExtCtrls, DataUnit, SeatMotorType;

type
    TAlignSpecFrme = class(TFrame)
        pnlClient: TPanel;
        Shape1: TShape;
        lblTitle: TLabel;
        ckbUse: TCheckBox;
        pnlDatas: TPanel;
        pnlMotorDatas: TPanel;
        edtCurrLimit: TEdit;
        edtTimeLimit: TEdit;
        Label52: TLabel;
        Label53: TLabel;
        pnlAlignDatas: TPanel;
        edtMoveTime: TEdit;
        Label16: TLabel;
        Label17: TLabel;
        rdgDirection: TRadioGroup;
    private
    { Private declarations }
        mIsUseMotorDatas: Boolean;
    public
    { Public declarations }
        procedure Init(MotorORD: TMotorOrd; IsUpDn: Boolean = false; IsUseMotorData: Boolean = true);
        procedure WriteToUI(MtrCnst: PMotorConstraints);
        procedure ReadFromUI(MtrCnst: PMotorConstraints);
    end;

implementation

uses
    myUtils;

{$R *.dfm}

{ TfmAlignSpec }

procedure TAlignSpecFrme.Init(MotorORD: TMotorOrd; IsUpDn, IsUseMotorData: Boolean);
begin
    lblTitle.Caption := _MOTOR_ID_STR[MotorORD];

    mIsUseMotorDatas := IsUseMotorData;

    pnlMotorDatas.Visible := IsUseMotorData;

    if IsUpDn then
    begin
        rdgDirection.Items.Clear;
        rdgDirection.Items.Add('»ó½Â');
        rdgDirection.Items.Add('ÇÏ°­');
    end;
end;

procedure TAlignSpecFrme.ReadFromUI(MtrCnst: PMotorConstraints);
begin
    if mIsUseMotorDatas then
    begin
        MtrCnst.rMaxTime := StrToFloatDef(edtTimeLimit.Text, 10);
        MtrCnst.rLockedCurr := StrToFloatDef(edtCurrLimit.Text, 7);
    end;
    MtrCnst.rAlign.rUse := ckbUse.Checked;

    MtrCnst.rAlign.rDirection := TMotorDir(rdgDirection.ItemIndex);
    MtrCnst.rAlign.rOperTime := StrToFloatDef(edtMoveTime.Text, 10);
end;

procedure TAlignSpecFrme.WriteToUI(MtrCnst: PMotorConstraints);
begin
    if mIsUseMotorDatas then
    begin
        edtTimeLimit.Text := GetUsrFloatToStr(MtrCnst.rMaxTime);
        edtCurrLimit.Text := GetUsrFloatToStr(MtrCnst.rLockedCurr);
    end;
    ckbUse.Checked := MtrCnst.rAlign.rUse;
    rdgDirection.ItemIndex := Integer(MtrCnst.rAlign.rDirection);
    edtMoveTime.Text := GetUsrFloatToStr(MtrCnst.rAlign.rOperTime);
end;

end.

