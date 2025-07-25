unit EditForm;
{$INCLUDE myDefine.inc}

interface

uses
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, ExtCtrls, StdCtrls, Buttons, ImgList, DataUnit, KiiMessages,
    ComCtrls, ModelType, SeatType, SeatMotorType, Grids, pngimage, Label3D,
    MotorSpecFrame;

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
        Label3: TLabel;
        edtPartName: TEdit;
        edtPartNo: TEdit;
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
        rdgCarType: TRadioGroup;
        rdgPosType: TRadioGroup;
        pcMdl: TPageControl;
        ts1: TTabSheet;
        shp6: TShape;
        lbl62: TLabel;
        fmHeightSpec: TMtrSpecFrame;
        TabSheet1: TTabSheet;
        TabSheet2: TTabSheet;
        Label128: TLabel;
        Shape13: TShape;
        Label136: TLabel;
        Label139: TLabel;
        Label140: TLabel;
        Label141: TLabel;
        Label142: TLabel;
        Label143: TLabel;
        Label144: TLabel;
        Label145: TLabel;
        Shape16: TShape;
        Label147: TLabel;
        Label148: TLabel;
        Label149: TLabel;
        Label150: TLabel;
        Label151: TLabel;
        Label152: TLabel;
        Shape17: TShape;
        Label155: TLabel;
        Label156: TLabel;
        Label157: TLabel;
        Label158: TLabel;
        Label159: TLabel;
        Label4: TLabel;
        edtOnLo_Heater: TEdit;
        edtOnHi_Heater: TEdit;
        edtOffHi_Heater: TEdit;
        edtOffsetHeat: TEdit;
        edtOnLo_Vent: TEdit;
        edtOnHi_Vent: TEdit;
        edtOffHi_Vent: TEdit;
        edtOffsetVent: TEdit;
        edtOnLo_Buckle: TEdit;
        edtOnHi_Buckle: TEdit;
        edtOffsetBuckle: TEdit;
        fmTiltSpec: TMtrSpecFrame;
        fmSlideSpec: TMtrSpecFrame;
        fmSwivelSpec: TMtrSpecFrame;
        fmLegSuptSpec: TMtrSpecFrame;
        TabSheet3: TTabSheet;
        Label110: TLabel;
        rgSlidelOutPos: TRadioGroup;
        edtSlideOutPosT: TEdit;
        rgSlideDir4Time: TRadioGroup;
        Label1: TLabel;
        RadioGroup1: TRadioGroup;
        Edit1: TEdit;
        RadioGroup2: TRadioGroup;
        Label5: TLabel;
        RadioGroup3: TRadioGroup;
        Edit2: TEdit;
        RadioGroup4: TRadioGroup;
        Label7: TLabel;
        RadioGroup5: TRadioGroup;
        Edit3: TEdit;
        RadioGroup6: TRadioGroup;
        Label8: TLabel;
        RadioGroup7: TRadioGroup;
        Edit4: TEdit;
        RadioGroup8: TRadioGroup;
        Shape1: TShape;
        Label11: TLabel;
        Label12: TLabel;
        Label13: TLabel;
        Label14: TLabel;
        Label15: TLabel;
        edtAncPTMin: TEdit;
        edtAncPTMax: TEdit;
        edtOffsetAncPT: TEdit;
    rdgDrvPos: TRadioGroup;
    Label10: TLabel;
    Label16: TLabel;
    edtHgtDPos: TEdit;
    Label17: TLabel;
        procedure FormClose(Sender: TObject; var Action: TCloseAction);
        procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
        procedure FormCreate(Sender: TObject);
        procedure FormDestroy(Sender: TObject);
        procedure FormShow(Sender: TObject);
        procedure edtPartNameChange(Sender: TObject);
        procedure cbxSwIoFw_SlideChange(Sender: TObject);
        procedure rgPos4OutPClick(Sender: TObject);
        procedure rgSlidelOutPosClick(Sender: TObject);
    private
    { Private declarations }
        mInit: boolean;
        mChangeEvent: TNotifyStatus;
        mModels: TModels;
        mIsMdlExSave: boolean;

        mMtrSpecFrames: array[TMotorOrd] of TMtrSpecFrame;
        mOutPosCtrls: array[TMotorOrd] of TArray<TControl>;

        procedure Init;

        procedure SpecCheckBoxMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);

        procedure ReadMessage(var myMsg: TMessage); message WM_SYS_CODE;
        function TransModels(aIsEdit: boolean): boolean;

    public
    { Public declarations }
        procedure SetFrm(aIndex: integer);
        procedure Save(AItems: array of boolean; IsMotor, IsDelivery, IsSwIo, IsUsrType, IsMdlSync: boolean);

        property OnUserChange: TNotifyStatus read mChangeEvent write mChangeEvent;
    end;

var
    frmEdit: TfrmEdit;

implementation

uses
    Global, ModelUnit, SeatTypeUI, Log, myUtils, Math, DioForm, PasswdForm,
    FormUtils, DioReferForm, IniFiles, LanIOUnit, SysEnv, IODef, TsWorkUnit,
    HVTester, LangTran;

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

{
    if mIsMdlExSave then
    begin
        gModels.SaveMdlExDatas(GetEnvPath('MdlExDatas.dat'));
    end;
}
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

    pcMdl.TabIndex := 0;
    pcMdl.ActivePageIndex := 0;
    pcMdl.ActivePage := ts1;

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
end;

const
    RG_OUT_POS_TYPE_TAG = 40;

function TfrmEdit.TransModels(aIsEdit: boolean): boolean;
label
    EDIT_ERROR;
var
    iTm: integer;
    sTm: string;
    Buf: TMotorDeliveryPos;
    MdlExData: TMdlExData;
    MtrIt: TMotorOrd;
begin
    Result := false;


    with mModels do
    begin
        if aIsEdit then
        begin
            rPartName := ShortString(edtPartName.Text);
            //rPartNo   := ShortString(edtPartNo.Text) ;

            rTypes.Clear;
            rTypes.SetCarType(TCAR_TYPE(rdgCarType.ItemIndex));

            if rdgPosType.ItemIndex  = 0 then  //LH
            begin
                rTypes.SetDrvType(rdgDrvPos.ItemIndex = 0);
            end
            else
            begin
                rTypes.SetDrvType(rdgDrvPos.ItemIndex = 1);
            end;

            rTypes.SetPosType(TPOS_TYPE(rdgPosType.ItemIndex));


            for MtrIt := Low(TMotorOrd) to MtrOrdHi do
            begin
                mMtrSpecFrames[MtrIt].ReadFromUI(@mModels.rSpecs.rMotors[MtrIt], @mModels.rConstraints[MtrIt]);
                TRadioGroup(mOutPosCtrls[MtrIt][0]).Tag := RG_OUT_POS_TYPE_TAG + Ord(MtrIt);
                mModels.rOutPos[MtrIt].rType := TRadioGroup(mOutPosCtrls[MtrIt][0]).ItemIndex;
                mModels.rOutPos[MtrIt].rTime := StrToFloatDef(TEdit(mOutPosCtrls[MtrIt][1]).Text, 0);
                mModels.rOutPos[MtrIt].rDir4Time := TMotorDir(TRadioGroup(mOutPosCtrls[MtrIt][2]).ItemIndex);
            end;


            if not mModels.rSpecs.rOnCurr[hvtHeat].ReadFromEdit(edtOnLo_Heater, edtOnHi_Heater) then
            begin
                sTm := _TR('히터검사기준 (ON)');
                goto EDIT_ERROR;
            end;
            mModels.rSpecs.rOffCurr[hvtHeat].ReadFromEdit(nil,  edtOffHi_Heater, 0, 0.2);

            if not mModels.rSpecs.rOnCurr[hvtVent].ReadFromEdit(edtOnLo_Vent, edtOnHi_Vent) then
            begin
                sTm := _TR('통풍검사기준(ON)');
                goto EDIT_ERROR;
            end;
            mModels.rSpecs.rOffCurr[hvtVent].ReadFromEdit(nil,  edtOffHi_Vent, 0, 0.2);


            if not mModels.rSpecs.rBuckleCurr.ReadFromEdit(edtOnLo_Buckle, edtOnHi_Buckle) then
            begin
                sTm := '버클검사기준(ON)';
                goto EDIT_ERROR;
            end;

            if not mModels.rSpecs.rAncPTReg.ReadFromEdit(edtAncPTMin, edtAncPTMax) then
            begin
                sTm := '앵커PT 검사 기준';
                goto EDIT_ERROR;
            end;

            mModels.rOffset[0].rVals[ucHeat] := StrToFloatDef(edtOffsetHeat.Text, 0);
            mModels.rOffset[0].rVals[ucVent] := StrToFloatDef(edtOffsetVent.Text, 0);
            mModels.rOffset[0].rVals[ucBuckle] := StrToFloatDef(edtOffsetBuckle.Text, 0);
            mModels.rOffset[0].rVals[ucAncPT] := StrToFloatDef(edtOffsetAncPT.Text, 0);

            mModels.rDistance := StrToFloatDef(edtHgtDPos.Text, 0);

        end
        else
        begin
            edtPartName.Text := string(rPartName);

            rdgCarType.ItemIndex := integer(rTypes.GetCarType);


            if rTypes.IsLHPos then
            begin
                if rTypes.IsDrvPos then
                begin
                    rdgDrvPos.ItemIndex := 0;
                    rdgPosType.ItemIndex := 0;
                end
                else
                begin
                    rdgDrvPos.ItemIndex := 1;
                    rdgPosType.ItemIndex := 0;

                end
            end
            else
            begin
                if rTypes.IsDrvPos then
                begin
                    rdgDrvPos.ItemIndex := 1;
                    rdgPosType.ItemIndex := 1;
                end
                else
                begin
                    rdgDrvPos.ItemIndex := 0;
                    rdgPosType.ItemIndex := 1;
                end
            end;

            for MtrIt := Low(TMotorOrd) to MtrOrdHi do
            begin
                mMtrSpecFrames[MtrIt].WriteToUI(@mModels.rSpecs.rMotors[MtrIt], @mModels.rConstraints[MtrIt]);

                TRadioGroup(mOutPosCtrls[MtrIt][0]).ItemIndex := mModels.rOutPos[MtrIt].rType;
                TEdit(mOutPosCtrls[MtrIt][1]).Text := GetUsrFloatToStr(mModels.rOutPos[MtrIt].rTime);
                TRadioGroup(mOutPosCtrls[MtrIt][2]).ItemIndex := Ord(mModels.rOutPos[MtrIt].rDir4Time);
            end;

            mModels.rSpecs.rOnCurr[hvtHeat].WriteToEdit(edtOnLo_Heater, edtOnHi_Heater);
            mModels.rSpecs.rOffCurr[hvtHeat].WriteToEdit(nil,  edtOffHi_Heater);
            mModels.rSpecs.rOnCurr[hvtVent].WriteToEdit(edtOnLo_Vent, edtOnHi_Vent);
            mModels.rSpecs.rOffCurr[hvtVent].WriteToEdit(nil,  edtOffHi_Vent);

            mModels.rSpecs.rBuckleCurr.WriteToEdit(edtOnLo_Buckle, edtOnHi_Buckle);
            mModels.rSpecs.rAncPTReg.WriteToEdit(edtAncPTMin, edtAncPTMax);

            edtOffsetHeat.Text := GetUsrFloatToStr(mModels.rOffset[0].rVals[ucHeat]);
            edtOffsetVent.Text := GetUsrFloatToStr(mModels.rOffset[0].rVals[ucVent]);
            edtOffsetBuckle.Text := GetUsrFloatToStr(mModels.rOffset[0].rVals[ucBuckle]);
            edtOffsetAncPT.Text := GetUsrFloatToStr(mModels.rOffset[0].rVals[ucAncPT]);

            edtHgtDPos.Text := GetUsrFloatToStr(mModels.rDistance);

        end;
    end;

    Result := true;
    Exit;

EDIT_ERROR:
    Application.MessageBox(PChar(sTm + _TR(' 입력오류 확인하세요!')), PChar(Caption), MB_ICONERROR + MB_OK);
    gLog.ToFiles('%s', [sTm]);
end;

procedure TfrmEdit.edtPartNameChange(Sender: TObject);
begin
    if mInit then
        Exit;

//    TWinControl(Sender).Tag := 1;

    if Assigned(mChangeEvent) then
        OnUserChange(Self, 1);
end;

procedure TfrmEdit.Save(AItems: array of boolean; IsMotor, IsDelivery, IsSwIo, IsUsrType, IsMdlSync: boolean);
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

function GetUsrIoTxt(CH: integer): string;
var
    ID: integer;
    sTm: string;
    Ini: TIniFile;
begin
    sTm := Format('%s\IoList.Ini', [GetUsrDir(udENV, Now())]);
    Ini := TIniFile.Create(sTm);
    try
        if CH >= _DIO_CH_COUNT div 2 then
        begin
            ID := CH - 32 + 1;
            Result := Ini.ReadString('PCOUT_IO' + IntToStr(0), 'INDEX ' + IntToStr(ID), '');
        end
        else
        begin
            ID := CH + 1;
            Result := Ini.ReadString('PCIN_IO' + IntToStr(0), 'INDEX ' + IntToStr(ID), '');
        end;

    finally
        Ini.Free;
    end;
end;

procedure TfrmEdit.Init;
var
    i: integer;
    CbxRect: TRect;
    MtrIt: TMotorORD;
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
    edtHgtDPos.Text := '0';
    FillChar(mModels, sizeof(TModels), 0);

    WriteAsCarType(rdgCarType, true);


    mMtrSpecFrames[tmSlide] := fmSlideSpec;
    mMtrSpecFrames[tmTilt] := fmTiltSpec;
    mMtrSpecFrames[tmHeight] := fmHeightSpec;
    mMtrSpecFrames[tmLegSupt] := fmLegSuptSpec;
    mMtrSpecFrames[tmSwivel] := fmSwivelSpec;

    for MtrIt := Low(TMotorOrd) to MtrOrdHi do
    begin
        mMtrSpecFrames[MtrIt].lblTitle.Caption := UpperCase(GetMotorName(MtrIt));
        mMtrSpecFrames[MtrIt].OnStatusChange := edtPartNameChange;
    end;


    // 배출위치
    mOutPosCtrls[tmSlide] := GetRightComponents(rgSlidelOutPos, 3, 11);
    mOutPosCtrls[tmTilt] := GetRightComponents(RadioGroup1, 3, 11);
    mOutPosCtrls[tmHeight] := GetRightComponents(RadioGroup3, 3, 11);
    mOutPosCtrls[tmLegSupt] := GetRightComponents(RadioGroup5, 3, 11);
    mOutPosCtrls[tmSwivel] := GetRightComponents(RadioGroup7, 3, 11);

end;

procedure TfrmEdit.SpecCheckBoxMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
    TCheckBox(Sender).Checked := not TCheckBox(Sender).Checked;
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
                Save([], false, false, false, false, false);
            end;
    end;
end;

procedure TfrmEdit.rgPos4OutPClick(Sender: TObject);
begin
    {   // 차후 LH/RH 구분시 살릴것
    with mModels do
    begin
        rTypes.Clear;
        rTypes.SetCarType(TCAR_TYPE(rdgCarType.ItemIndex));
        rTypes.SetAreaType(TAREA_TYPE(rgArea.ItemIndex));
        rTypes.SetPosType(TPOS_TYPE(rgPos4OutP.ItemIndex));

        DisplayOutPosSpec(rTypes.rDataBits, MDL_MASK_CAR_N_POS);     // MDL_MASK_CAR_TYPE
    end;
    }
end;

procedure TfrmEdit.rgSlidelOutPosClick(Sender: TObject);
var
    RG: TRadioGroup;
    Idx: Integer;
    IsVisible: Boolean;
begin
    RG := TRadioGroup(Sender);

    Idx := RG.Tag - RG_OUT_POS_TYPE_TAG;
    IsVisible := RG.ItemIndex = 2;
    mOutPosCtrls[TMotorOrd(Idx), 1].Visible := IsVisible;
    mOutPosCtrls[TMotorOrd(Idx), 2].Visible := IsVisible;

    edtPartNameChange(Sender);
end;

procedure TfrmEdit.cbxSwIoFw_SlideChange(Sender: TObject);
begin

    if Assigned(mChangeEvent) then
        OnUserChange(Self, 1);
end;

end.

