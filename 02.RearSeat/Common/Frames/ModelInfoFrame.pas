unit ModelInfoFrame;

interface

uses
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, StdCtrls, Label3D, ExtCtrls, ModelType, SeatType;

type
    TMdllInfoFrame = class(TFrame)
        pnlMdlInfo: TPanel;
        pnlPartInfo: TPanel;
        lblLotNo: TLabel3D;
        lblPartNo: TLabel3D;
        lblCarType: TLabel3D;
        pnlPos: TPanel;
        lblRH: TLabel3D;
        lblLH: TLabel3D;
        pnlPosTitle: TPanel;
        pnl1: TPanel;
        lblZigNo: TLabel3D;
        pnl2: TPanel;
        pnlClass: TPanel;
        pnlClassTitle: TPanel;
        pnlClassClient: TPanel;
        pnlClassVal: TPanel;
        pnlSeats: TPanel;
        lbl7P: TLabel3D;
        lbl6P: TLabel3D;
        lbl4P: TLabel3D;
        lbl5P: TLabel3D;
        pnlCarSubType: TPanel;
        pnlCarSubTypeTitle: TPanel;
        pnlCarSubTypeClient: TPanel;
        lblSE: TLabel3D;
        lblSTD: TLabel3D;
        pnlECU: TPanel;
        pnlECUTitle: TPanel;
        pnlECUClient: TPanel;
        lblHVPSU: TLabel3D;
        lblSAU: TLabel3D;
        pnlBuckle: TPanel;
        pnlBuckleTitle: TPanel;
        pnlBuckleClient: TPanel;
        lblWarnBuckle: TLabel3D;
        lblCenterBuckle: TLabel3D;
        lblILLBuckle: TLabel3D;
        pnlHV: TPanel;
        pnlHVTitle: TPanel;
        pnlHVClient: TPanel;
        lblHeat: TLabel3D;
        lblHV: TLabel3D;
        pnlMotors: TPanel;
        pnlMotorsTitle: TPanel;
        pnlMotorsTop: TPanel;
        pnlMotorsBottom: TPanel;
        lblSlide: TLabel3D;
        lblTilt: TLabel3D;
        lblRecline: TLabel3D;
        lblShoulder: TLabel3D;
        lblHeadRest: TLabel3D;
    lblRelax: TLabel3D;
    private
        { Private declarations }
        procedure SelectLabel(aLabel3D: TLabel3D; aVal: Boolean);
        procedure SetPopLinkMode(const Value: Boolean);

    public
        { Public declarations }
        procedure Clear;
        procedure SetModel(ModelType: TModelType);
        procedure SetSeatsCount(SeatsCount: Integer);
        procedure SetUseMotors(Motors: TMTR_TYPE_array);

        procedure SetColRatios(Ratios: array of Double); overload;
        procedure SetColRatios(ChildPnls: array of TControl; Ratios: array of Double); overload;

        property PopLinkMode: Boolean write SetPopLinkMode;
    end;

implementation

uses
    myUtils, FormUtils, Generics.Collections, LangTran;

const
    _SELECT_COLOR = $00258B25;
    _NON_SELECT_COLOR = $00C6C3C6;
    _SELECT_FONT_COLOR = clWHITE;
    _NON_SELECT_FONT_COLOR = $00ABA8AC;
{$R *.dfm}
    { TFrame1 }

procedure TMdllInfoFrame.Clear;
var
    ComponentSub: TComponent;
    itm: Integer;
begin
    for itm := 0 to self.ComponentCount - 1 do
    begin
        ComponentSub := self.Components[itm];
        if (ComponentSub is TLabel3D) then
        begin
            if TLabel3D(ComponentSub).Tag >= 100 then
                continue;

            if TLabel3D(ComponentSub).Tag = 1 then
            begin
                TLabel3D(ComponentSub).Caption := '-';
            end
            else
            begin
                SelectLabel(TLabel3D(ComponentSub), False);
            end;
        end;
    end;
end;

procedure TMdllInfoFrame.SelectLabel(aLabel3D: TLabel3D; aVal: Boolean);
begin
    if aVal then
    begin
        aLabel3D.Color := _SELECT_COLOR;
        aLabel3D.Font.Color := _SELECT_FONT_COLOR;
    end
    else
    begin
        aLabel3D.Color := _NON_SELECT_COLOR;
        aLabel3D.Font.Color := _NON_SELECT_FONT_COLOR;
    end;
end;

procedure TMdllInfoFrame.SetColRatios(Ratios: array of Double);
begin
    SetCtrlColRatios(pnlMdlInfo, Ratios);

    SetCtrlColRatios(pnlClassVal, [1, 1]);
end;

procedure TMdllInfoFrame.SetColRatios(ChildPnls: array of TControl; Ratios: array of Double);
begin
    AdjustChildControlSizes(pnlMdlInfo, ChildPnls, Ratios);

    SetCtrlColRatios(pnlClassVal, [1, 1]);
end;

procedure TMdllInfoFrame.SetModel(ModelType: TModelType);
begin
    Clear;

    with ModelType do
    begin
        lblCarType.Caption := GetCarTypeStr();

        case GetSeatsType() of
            st4P:
                SelectLabel(lbl4P, True);
            st5P:
                SelectLabel(lbl5P, True);
            st6P:
                SelectLabel(lbl6P, True);
            st7P:
                SelectLabel(lbl7P, True);
        end;

        case GetPosType() of
            ptLH:
                SelectLabel(lblLH, True);
            ptRH:
                SelectLabel(lblRH, True);
        end;

        case GetCarTrimType of
            cstSE:
                SelectLabel(lblSE, True);
            cstSTD:
                SelectLabel(lblSTD, True);
        end;

        case GetHVType() of
            htHeat:
                SelectLabel(lblHeat, True);
            htHV:
                SelectLabel(lblHV, True);
        end;

        SelectLabel(lblHVPSU, IsHVPSU);
        SelectLabel(lblSAU, IsSAU);

        SelectLabel(lblWarnBuckle, IsWarnBuckle);
        SelectLabel(lblILLBuckle, IsIllBuckle);
        SelectLabel(lblCenterBuckle, IsCenterBuckle);

        SetUseMotors(GetUseMotors());
    end;

end;

procedure TMdllInfoFrame.SetPopLinkMode(const Value: Boolean);
begin

    lblPartNo.Visible := Value;

    if Value then
    begin
        lblLotNo.Color := lblPartNo.Color;
        lblLotNo.Font.Color := lblPartNo.Font.Color;
        lblLotNo.Caption := '';
    end
    else
    begin
        lblLotNo.Color := $000EC9FF;
        lblLotNo.Font.Color := clBlack;
        lblLotNo.Caption := _TR('단동 모드');
    end;
end;

procedure TMdllInfoFrame.SetSeatsCount(SeatsCount: Integer);
var
    Heights: TArray<Integer>;
    Lbls: array[0..3] of TLabel3D;
    i: Integer;
begin
    Lbls[0] := lbl4P;
    Lbls[1] := lbl5P;
    Lbls[2] := lbl6P;
    Lbls[3] := lbl7P;

    for i := 0 to Length(Lbls) - 1 do
        Lbls[i].Visible := False;

    case SeatsCount of
        2:
            Heights := myUtils.CalcSizes(pnlSeats.Height, [1, 1]);
        3:
            Heights := myUtils.CalcSizes(pnlSeats.Height, [1, 1, 0.9]);
        4:
            Heights := myUtils.CalcSizes(pnlSeats.Height, [1, 1, 1, 1]);
    end;

    for i := 0 to Length(Heights) - 1 do
    begin
        Lbls[i].Height := Heights[i];
        Lbls[i].Visible := True;

        if i > 0 then // 위치가 틀어져서 명시적으로 설정함
            Lbls[i].Top := Lbls[i - 1].Top + Lbls[i - 1].Height;
    end;

    Lbls[Length(Heights) - 1].Align := alClient;

    pnlSeats.Repaint;
end;

procedure TMdllInfoFrame.SetUseMotors(Motors: TMTR_TYPE_array);
var
    i: Integer;
    Mtr: TMTR_TYPE;
begin
    for i := 0 to High(Motors) do
    begin
        Mtr := Motors[i];

        case Mtr of
            mtSlide:
                begin
                    SelectLabel(lblSlide, True);
                    lblSlide.Caption := 'SLIDE';
                end;
            mtRecline:
                SelectLabel(lblRecline, True);
            mtCushTilt:
                begin
                    SelectLabel(lblTilt, True);
                    lblTilt.Caption := 'C.TILT';
                end;
            mtWalkinTilt:
                begin
                    SelectLabel(lblRelax, True);
                    lblRelax.Caption := 'W.TILT';
                end;
            mtRelax:
                begin
                    SelectLabel(lblRelax, True);
                    lblRelax.Caption := 'RELAX';
                end;
            mtShoulder:
                SelectLabel(lblShoulder, True);
            mtLongSlide:
                begin
                    lblSlide.Caption := 'L.SLIDE';
                end;
        end;
    end;
end;

end.

