unit ReferenceForm;
{$I myDefine.inc}

interface

uses
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, ReferBaseForm, StdCtrls, Buttons, ComCtrls, ExtCtrls, DataUnit,
    Grids, KiiMessages, CheckLst;

type
    TfrmReferItem = (riOP, riComm, riMotor, riSoundProof, riBackAngle, riElec, riBuckle, riIMSLimit, riIMSMem, riAntipinch, riMnlSlide, riMnlHeight);

    TControlBoxType = (btCombo, btListBox);

    TfrmReference = class(TfrmReferBase)
        pgcReference: TPageControl;
        tsOp: TTabSheet;
        Shape3: TShape;
        Shape5: TShape;
        Label16: TLabel;
        Shape24: TShape;
        Label28: TLabel;
        Shape1: TShape;
        Label1: TLabel;
        Shape2: TShape;
        Shape6: TShape;
        Label3: TLabel;
        Shape7: TShape;
        Label6: TLabel;
        Shape4: TShape;
        Label74: TLabel;
        Label76: TLabel;
        Label77: TLabel;
        Label2: TLabel;
        Label26: TLabel;
        Label5: TLabel;
        Shape16: TShape;
        Shape17: TShape;
        Label9: TLabel;
        Label10: TLabel;
        Label11: TLabel;
        Label17: TLabel;
        edtOP_StNo: TEdit;
        dtpOP_WorkTime: TDateTimePicker;
        ckbOP_UsePw: TCheckBox;
        ckbOP_UseScreenSaver: TCheckBox;
        bbtnOP_PasswdChange: TBitBtn;
        bbtnOP_ResetCnt: TBitBtn;
        edtOP_AlarmDisk: TEdit;
        edtOP_EmerDisk: TEdit;
        ckbOP_DiskAutoDel: TCheckBox;
        edtOP_KeepGraphMonth: TEdit;
        dtpOP_GraphCheckTimeStart: TDateTimePicker;
        dtpOP_GraphCheckTimeEnd: TDateTimePicker;
        btnOP_ResultDir: TButton;
        edtOP_ResultDir: TEdit;
        btnOP_GraphDir: TButton;
        edtOP_GraphDir: TEdit;
        tsComm: TTabSheet;
        Label38: TLabel;
        Label39: TLabel;
        Label40: TLabel;
        Label41: TLabel;
        Shape11: TShape;
        Shape18: TShape;
        Label23: TLabel;
        Shape8: TShape;
        Label7: TLabel;
        Shape9: TShape;
        Label31: TLabel;
        Label36: TLabel;
        edtPop_HostIp: TEdit;
        edtPop_Port: TEdit;
        edtPop_ConnectTime: TEdit;
        edtPop_SendTerm: TEdit;
        ckbPop_ReConnect: TCheckBox;
        ckbPop_Use: TCheckBox;
        ckbPop_sndData: TCheckBox;
        edtComm_WaitResPwrsply: TEdit;
        edtComm_CANConChkMinTime: TEdit;
        btnComm_ChangePort: TButton;
        tsMtr: TTabSheet;
        rdgOP_Language: TRadioGroup;
        lblNoiseOffset: TLabel;
        edtTest_RefVolt: TEdit;
        btnApplyRefVolt: TBitBtn;
        tsDp: TTabSheet;
        tsSP: TTabSheet;
        Shape13: TShape;
        tsElec: TTabSheet;
        pnlHV: TPanel;
        Label42: TLabel;
        Label44: TLabel;
        edtHV_TestB4Delay: TEdit;
        edtHV_SwOnDelay: TEdit;
        Label45: TLabel;
        Label60: TLabel;
        edtHV_MaxCollectTime: TEdit;
        edtHV_BlowReadTime: TEdit;
        Label61: TLabel;
        edtHV_NGRetry: TEdit;
        Label66: TLabel;
        cbHV_UseSwZeroCurr: TCheckBox;
        pnlECU: TPanel;
        Shape20: TShape;
        Label37: TLabel;
        Label35: TLabel;
        edtECU_EEPROMSaveTime: TEdit;
        ckbECU_UseVerMaster: TCheckBox;
        pnlSP: TPanel;
        Label50: TLabel;
        edtECU_DTCRetry: TEdit;
        edtECU_VerRetry: TEdit;
        Label53: TLabel;
        Label14: TLabel;
        edtTest_Volt: TEdit;
        edtTest_Curr: TEdit;
        Label13: TLabel;
        Label24: TLabel;
        edtTest_SpecCurr: TEdit;
        pnlMtr_Client: TPanel;
        Label4: TLabel;
        tsIMS: TTabSheet;
        shape19: TShape;
        Label21: TLabel;
        Shape15: TShape;
        Label56: TLabel;
        Shape12: TShape;
        Label68: TLabel;
        Shape22: TShape;
        Label55: TLabel;
        Label54: TLabel;
        Shape10: TShape;
        Shape23: TShape;
        Label12: TLabel;
        edtMtr_MinAmp: TEdit;
        edtMtr_LimitAmp: TEdit;
        Label18: TLabel;
        Label29: TLabel;
        edtMtr_LimitAmpOffset: TEdit;
        edtMtr_MoveGapTime: TEdit;
        Label19: TLabel;
        Label20: TLabel;
        edtMtr_MoveCheckTime: TEdit;
        edtMtr_ReadDelayTime: TEdit;
        Label33: TLabel;
        Shape30: TShape;
        Label121: TLabel;
        Panel29: TPanel;
        Shape31: TShape;
        Label122: TLabel;
        ckbDp_UsePwrSplyDebug: TCheckBox;
        pnlDP_LoadCell: TPanel;
        Shape32: TShape;
        Label123: TLabel;
        Panel32: TPanel;
        sbtnDp_FullscaleSave: TSpeedButton;
        Panel34: TPanel;
        Shape34: TShape;
        Label135: TLabel;
        Panel35: TPanel;
        Label137: TLabel;
        Label138: TLabel;
        Label139: TLabel;
        edtDp_TqOffset: TEdit;
        edtDp_TqLvrLength: TEdit;
        edtDp_TqPower: TEdit;
        sbtnDp_CalcTq: TSpeedButton;
        lblDp_CalcTq: TLabel;
        Panel36: TPanel;
        Shape35: TShape;
        Label142: TLabel;
        ckbDp_UseWorkStandard: TCheckBox;
        btnDp_WorkStandardImg: TButton;
        pnlDp_FullScale1: TPanel;
        lblDp_FullScale1: TLabel;
        edtDp_FullScale1: TEdit;
        pnlDp_FullScale2: TPanel;
        lblDp_FullScale2: TLabel;
        edtDp_FullScale2: TEdit;
        pnlDp_FullScale3: TPanel;
        lblDp_FullScale3: TLabel;
        edtDp_FullScale3: TEdit;
        pnlBuckle: TPanel;
        Shape37: TShape;
        Label63: TLabel;
        Label81: TLabel;
        edtbkl_ChkTime: TEdit;
        Label30: TLabel;
        edtSP_SliencerWait: TEdit;
        edtSP_WaitA4WeightLoading: TEdit;
        Label8: TLabel;
        Label34: TLabel;
        edtSP_WaitB4WeightUnLoading: TEdit;
        edtSP_RepeatCount: TEdit;
        Label52: TLabel;
        GroupBox11: TGroupBox;
        Label99: TLabel;
        Label100: TLabel;
        edtSP_CurrFilter: TEdit;
        edtSP_NoiseFilter: TEdit;
        ckbSP_UseSwZeroCurr: TCheckBox;
        pnlMtr_Align: TPanel;
        Shape25: TShape;
        Label70: TLabel;
        edtDp_WorkStandardImg: TEdit;
        pnlIMSClient: TPanel;
        pnlLimit: TPanel;
        Shape14: TShape;
        Label43: TLabel;
        pnlLmtClient: TPanel;
        pnlLmt_Settings: TPanel;
        Label80: TLabel;
        Label51: TLabel;
        ckbLmt_IsSkipSet: TCheckBox;
        edtLmt_CmdFailRetry: TEdit;
        edtLmt_ReqDelay: TEdit;
        pnlMem: TPanel;
        Shape26: TShape;
        Label88: TLabel;
        Label47: TLabel;
        Label48: TLabel;
        Label46: TLabel;
        Label32: TLabel;
        Label25: TLabel;
        pnlMem_ByCarType: TPanel;
        Label92: TLabel;
        Label93: TLabel;
        cbxMem_SelectedCar: TComboBox;
        GroupBox2: TGroupBox;
        ckbMem_UseMem: TCheckBox;
        ckbMem_UseEasyAcc: TCheckBox;
        GroupBox6: TGroupBox;
        ckbMem_UseMem1: TCheckBox;
        ckbMem_UseMem2: TCheckBox;
        ckbMem_UseMem3: TCheckBox;
        edtMem_MemMoveTime: TEdit;
        edtMem_MemSaveWait: TEdit;
        edtMem_MemOffset: TEdit;
        edtMem_EasyAccOffset: TEdit;
        edtMem_MemRepeat: TEdit;
        pnlMtr_ByMtrType: TPanel;
        Label67: TLabel;
        Label69: TLabel;
        Label73: TLabel;
        Label84: TLabel;
        cbxMtr_SelectedMtr: TComboBox;
        edtBrn_BurnishingCount: TEdit;
        GroupBox3: TGroupBox;
        ckbSP_UseSpeed: TCheckBox;
        ckbSP_UseNoise: TCheckBox;
        ckbSP_UseStrokeAmount: TCheckBox;
        ckbSP_UseCurr: TCheckBox;
        GroupBox1: TGroupBox;
        ckbSP_UseRetrySpeed: TCheckBox;
        ckbSP_UseRetryNoise: TCheckBox;
        ckbSP_UseRetryStrokeAmount: TCheckBox;
        ckbSP_UseRetryCurr: TCheckBox;
        rdgSP_NoiseResultType: TRadioGroup;
        edtSP_NoiseCollectEnd: TEdit;
        edtSP_NoiseCollectStart: TEdit;
        Label15: TLabel;
        Label27: TLabel;
        GroupBox4: TGroupBox;
        ckbHV_UseHeat: TCheckBox;
        ckbHV_UseVent: TCheckBox;
        ckbHV_UseSenseVent: TCheckBox;
        GroupBox5: TGroupBox;
        cbECU_UseVer: TCheckBox;
        cbECU_UseDTC: TCheckBox;
        GroupBox19: TGroupBox;
        ckbBkl_UseCurr: TCheckBox;
        ckbBkl_UseIO: TCheckBox;
        ckbBkl_UseILL: TCheckBox;
    Shape38: TShape;
    ckbSP_StopOnNG: TCheckBox;
    grpCanDebug: TGroupBox;
    ckbDp_CanWriteLog: TCheckBox;
    ckbDp_CanReadLog: TCheckBox;
    rdgDp_EtherCAT: TRadioGroup;
        procedure FormClose(Sender: TObject; var Action: TCloseAction);
        procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
        procedure FormCreate(Sender: TObject);
        procedure FormDestroy(Sender: TObject);
        procedure FormShow(Sender: TObject);
        procedure btnOP_ResultDirClick(Sender: TObject);
        procedure bbtnOP_PasswdChangeClick(Sender: TObject);
        procedure bbtnOP_ResetCntClick(Sender: TObject);
        procedure btnComm_ChangePortClick(Sender: TObject);
        procedure btnOP_GraphDirClick(Sender: TObject);
        procedure btnApplyRefVoltClick(Sender: TObject);
        procedure pnlActiveSystemTabDblClick(Sender: TObject);
        procedure Label28DblClick(Sender: TObject);
        procedure ckbSli_UseOverSendPLCClick(Sender: TObject);
        procedure ckbPump_UseOverSendPLCClick(Sender: TObject);
        procedure pgcReferenceChange(Sender: TObject);
        procedure sbtnDp_CalcTqClick(Sender: TObject);

    private
        { Private declarations }
        mActiveItems: array of TfrmReferItem;

        procedure ActiveSaveEvent(Sender: TObject);
        procedure InitMtrTabSheets(PageControl: TPageControl);
        procedure InitLimitCmdTabSheets(PageControl: TPageControl);

        procedure FindChildControls(Parent: TWinControl; Target: TControlBoxType; List: TList);

        function FindTargetCtrlItems(PageControl: TPageControl; Target: TControlBoxType): TList;
        procedure ReadMessage(var myMsg: TMessage); message WM_SYS_CODE;

        procedure InitCarInComboBoxs(ComboBoxs: TList);
        procedure InitCarInComboBox(ComboBox: TComboBox);
        procedure CarInComboBoxEvent(Sender: TObject);

        procedure InitMotorInListBoxs(CheckListBoxs: TList);
        procedure InitMotorInListBox(CheckListBox: TCheckListBox);

        procedure InitMotorInComboBoxs(ComboBoxs: TList);
        procedure InitMotorInComboBox(ComboBox: TComboBox);
        procedure MotorInComboBoxEvent(Sender: TObject);

        procedure SetTabVisible(Tabsheet: TTabSheet; IsVisible: Boolean); overload;
        procedure SetItemVisible(Item: TfrmReferItem); overload;
        procedure SetAllTabVisible(IsVisible: Boolean);

        function GetTabSheetAtItem(Item: TfrmReferItem): TTabSheet;

        procedure OnMotionTypeClick(Sender: TObject);
    public
        { Public declarations }

        constructor Create(AOwner: TComponent); overload; override;
        constructor Create(AOwner: TComponent; Items: array of TfrmReferItem); overload;

        function Save: Boolean; override;

        procedure Initial;

        procedure ActiveItemInitial(Item: TfrmReferItem);
    end;

var
    frmReference: TfrmReference;

implementation

uses
    ShlObj, Math, Global, Log, myUtils, ComReferForm, PopWork, IniFiles, IODef,
    SysEnv, LangTran, PasswdForm, SeatMotorType, SeatType, StrUtils, FormUtils;
{$R *.dfm}

function GetDecimalPos(aVal: string): Integer;
begin
    Result := 0;
    if Pos('.', aVal) < 1 then
        Exit;
    Result := Length(aVal) - Pos('.', aVal);
    if Result < 0 then
        Result := 0;
end;

procedure TfrmReference.FindChildControls(Parent: TWinControl; Target: TControlBoxType; List: TList);
var
    i: Integer;
    ctrl: TControl;
begin
    for i := 0 to Parent.ControlCount - 1 do
    begin
        ctrl := Parent.Controls[i];

        case Target of
            btCombo:
                if ctrl is TComboBox then
                    List.Add(ctrl);
            btListBox:
                if ctrl is TCheckListBox then
                    List.Add(ctrl);
        end;

        if ctrl is TWinControl then
            FindChildControls(TWinControl(ctrl), Target, List);
    end;
end;

function TfrmReference.FindTargetCtrlItems(PageControl: TPageControl; Target: TControlBoxType): TList;
var
    i: Integer;
    Tabsheet: TTabSheet;
    List: TList;
begin
    Result := nil;

    if PageControl = nil then
        Exit;

    List := TList.Create;

    for i := 0 to PageControl.PageCount - 1 do
    begin
        Tabsheet := PageControl.Pages[i];
        FindChildControls(Tabsheet, Target, List);
    end;

    Result := List;
end;

procedure TfrmReference.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    inherited;

    Action := caFree;
end;

procedure TfrmReference.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
    inherited;
    //
end;

procedure TfrmReference.FormCreate(Sender: TObject);
begin
    inherited;
    gLog.ToFiles('%s CREATE', [Self.Name]);

    mEdit := true;
    mIsChanged := false;

end;

procedure TfrmReference.FormDestroy(Sender: TObject);
begin
    inherited;
    gLog.ToFiles('%s DESTROY', [Self.Name]);
end;

procedure TfrmReference.FormShow(Sender: TObject);
var
    i: Integer;
begin
    inherited;
    gLog.ToFiles('%s SHOW', [Self.Name]);

    for i := 0 to ComponentCount - 1 do
    begin
        if Components[i] is TEdit then
        begin
            with Components[i] as TEdit do
                Text := '';
        end;
    end;

    Initial();

    gSysEnv.DispatchPush(pgcReference.ActivePage);
    gSysEnv.DispatchPush(tsDp);

    mEdit := false;
    mIsChanged := false;

    TLangTran.ChangeCaption(Self);

end;

function TfrmReference.GetTabSheetAtItem(Item: TfrmReferItem): TTabSheet;
begin
    Result := nil;

end;

function TfrmReference.Save: Boolean;
begin
    Result := true;
    if not mIsChanged then
        Exit;

    gSysEnv.DispatchPull(pgcReference.ActivePage);
    gSysEnv.Save(TSysEnvItem(pgcReference.ActivePageIndex));

    mIsChanged := not Result;
    if Assigned(mChangeEvent) then
        OnUserChange(Self, Integer(mIsChanged));

    if Result then
        SendToForm(gUsrMsg, SYS_BASE, 0);
end;

procedure TfrmReference.sbtnDp_CalcTqClick(Sender: TObject);
var
    kgfCm, kgfMeter, LeverMM, LeverCm, LeverMeter, ResultKgfMeter, ResultKgfMeter1, offset: double;
begin
    inherited;
    kgfCm := StrToFloatDef(edtDp_TqPower.Text, 0);
    LeverMM := StrToIntDef(edtDp_TqLvrLength.Text, 178);
    LeverCm := LeverMM / 10;
    offset := StrToIntDef(edtDp_TqOffset.Text, 100);
    kgfMeter := kgfCm / 100;
    LeverMeter := LeverCm / 100;

    // ResultKgfMeter := kgfMeter / LeverMeter;
    ResultKgfMeter1 := kgfCm / LeverCm * (offset / 100);
    lblDp_CalcTq.Caption := Format('%.2f / %.2f * %.2f%%  = %.2f(kgf)', [kgfCm, LeverMM / 10, offset, ResultKgfMeter1]);
end;

procedure TfrmReference.InitCarInComboBox(ComboBox: TComboBox);
var
    i: Integer;
begin
    ComboBox.Clear;

    for i := 0 to Length(TCAR_TYPE_STR) - 1 do
        ComboBox.Items.Add(TCAR_TYPE_STR[i]);

    ComboBox.ItemIndex := 0;

    ComboBox.OnChange := CarInComboBoxEvent;

end;

procedure TfrmReference.InitCarInComboBoxs(ComboBoxs: TList);
var
    i: Integer;
    Item: TComboBox;
begin
    if ComboBoxs = nil then
        Exit;

    try
        for i := 0 to ComboBoxs.Count - 1 do
        begin
            Item := TComboBox(ComboBoxs.Items[i]);
            if Pos('_SelectedCar', Item.Name) > 0 then
                InitCarInComboBox(Item);
        end;
    finally
        ComboBoxs.Free;
    end;
end;

procedure TfrmReference.InitMotorInComboBox(ComboBox: TComboBox);
var
    i: Integer;
begin
    ComboBox.Clear;

    for i := 0 to Length(_MOTOR_ID_STR) - 1 do
        ComboBox.Items.Add(_MOTOR_ID_STR[TMotorOrd(i)]);

    ComboBox.ItemIndex := 0;

    ComboBox.OnChange := MotorInComboBoxEvent;
end;

procedure TfrmReference.InitMotorInComboBoxs(ComboBoxs: TList);
var
    i: Integer;
    Item: TComboBox;
begin
    if ComboBoxs = nil then
        Exit;

    try
        for i := 0 to ComboBoxs.Count - 1 do
        begin
            Item := TComboBox(ComboBoxs.Items[i]);

            if Pos('_SelectedMtr', Item.Name) > 0 then
                InitMotorInComboBox(Item);
        end;
    finally
        ComboBoxs.Free;
    end;
end;

procedure TfrmReference.InitMotorInListBox(CheckListBox: TCheckListBox);
var
    i: Integer;
begin
    CheckListBox.Clear;

    for i := 0 to Length(_MOTOR_ID_STR) - 1 do
        CheckListBox.Items.Add(_MOTOR_ID_STR[TMotorOrd(i)]);
end;

procedure TfrmReference.InitMotorInListBoxs(CheckListBoxs: TList);
var
    i: Integer;
begin
    if CheckListBoxs = nil then
        Exit;

    try
        for i := 0 to CheckListBoxs.Count - 1 do
            InitMotorInListBox(TCheckListBox(CheckListBoxs.Items[i]));
    finally
        CheckListBoxs.Free;
    end;
end;

procedure TfrmReference.SetTabVisible(Tabsheet: TTabSheet; IsVisible: Boolean);
begin
    Tabsheet.TabVisible := IsVisible;
    Tabsheet.Visible := IsVisible;
end;

procedure TfrmReference.Label28DblClick(Sender: TObject);
begin
    inherited;
    tsDp.TabVisible := not tsDp.TabVisible;
end;

procedure TfrmReference.MotorInComboBoxEvent(Sender: TObject);
var
    Ctrl: TWinControl;
begin
    if not (Sender is TComboBox) then
        Exit;

    Ctrl := TComboBox(Sender).Parent;

    if Assigned(Ctrl) then
        gSysEnv.DispatchPush(Ctrl);
end;

var
    lpCallBackDir: string;

function BrowserCallBackProc(Wnd: HWND; uMsg: UINT; lParam, lpData: lParam): Integer stdcall;
begin
    Result := 1;
    case uMsg of
        BFFM_INITIALIZED:
            begin
                SendMessage(Wnd, BFFM_SETSELECTION, Integer(true), Integer(PChar(lpCallBackDir)));
                // wParam 이 true 이면 lParam 경로
                // wParam 이 false이면 lParam PIDL
            end;
    end;
end;

procedure TfrmReference.Initial;
var
    Item: TfrmReferItem;
begin
    // 기본 탭 표시 조정

    SetAllTabVisible(false);
    SetTabVisible(tsOp, true);
    SetTabVisible(tsComm, true);


    AttachSaveEventToControlChild(pgcReference, ActiveSaveEvent);

    for Item in mActiveItems do
    begin
        // 탭 항목 표시
        SetItemVisible(Item);

        // 활성화 탭 초기화
        ActiveItemInitial(Item);
    end;
end;

procedure TfrmReference.SetAllTabVisible(IsVisible: Boolean);
var
    i: Integer;
    Sheet: TTabSheet;
begin
    for i := 0 to pgcReference.ControlCount - 1 do
    begin
        if pgcReference.Controls[i] is TTabSheet then
        begin
            Sheet := TTabSheet(pgcReference.Controls[i]);
            Sheet.TabVisible := IsVisible;
        end;
    end;
end;

procedure TfrmReference.SetItemVisible(Item: TfrmReferItem);
begin
    case Item of
        riMotor:
            SetTabVisible(tsMtr, true);
        riSoundProof:
            SetTabVisible(tsSP, true);
        riElec:
            SetTabVisible(tsElec, true);
        riBuckle:
            pnlBuckle.Visible := True;
        riIMSLimit:
            begin
                SetTabVisible(tsIMS, true);
                pnlLimit.Visible := true;
            end;
        riIMSMem:
            begin
                SetTabVisible(tsIMS, true);
                pnlMem.Visible := true;
            end;
    end;
end;

procedure TfrmReference.ActiveItemInitial(Item: TfrmReferItem);
var
    CheckListBoxs: TList;
    i: Integer;
begin

    InitMotorInComboBoxs(FindTargetCtrlItems(pgcReference, btCombo));
    InitCarInComboBoxs(FindTargetCtrlItems(pgcReference, btCombo));

    case Item of
        riMotor:
            begin

            end;
        riSoundProof:
            begin

            end;
        riBackAngle:
            begin

            end;
        riElec:
            begin
            end;
        riIMSLimit:
            begin
            end;
        riIMSMem:
            begin
            end;
        riAntipinch:
            begin

            end;
        riMnlSlide:
            begin
                pnlDp_FullScale3.Visible := true;
            end;
        riMnlHeight:
            begin
                pnlDp_FullScale3.Visible := false;
            end;
    end;

end;

procedure TfrmReference.ActiveSaveEvent(Sender: TObject);
begin
    if mEdit then
        Exit;

    mIsChanged := true;
    if Assigned(mChangeEvent) then
        OnUserChange(Self, Integer(mIsChanged));
end;

procedure TfrmReference.bbtnOP_PasswdChangeClick(Sender: TObject);
begin
    inherited;
    frmPasswd := TfrmPasswd.Create(Application);
    with frmPasswd do
    begin
        ModifyMode := true;
        ShowModal();
    end;
end;

procedure TfrmReference.bbtnOP_ResetCntClick(Sender: TObject);
begin
    inherited;
    if Application.MessageBox(PChar(_TR('현재 생산수량을 초기화 하시겠습니까?')), PChar(Caption), MB_ICONQUESTION + MB_YESNO) <> ID_YES then
        Exit;

    SetResultReset;
end;

procedure TfrmReference.btnApplyRefVoltClick(Sender: TObject);
var
    i: Integer;
begin
    for i := 0 to MAX_ST_COUNT - 1 do
        gSysEnv.rRefVoltSetter.SetRefVolt(i, StrToFloat(edtTest_RefVolt.Text));
end;

procedure TfrmReference.btnOP_ResultDirClick(Sender: TObject);
var
    sTm: string;
begin
    lpCallBackDir := edtOP_ResultDir.Text;

    sTm := GetUserFolderEx(Self.Handle, BrowserCallBackProc, 'Data folder');
    if (sTm = '') or not DirectoryExists(sTm) then
        Exit;

    if edtOP_ResultDir.Text <> sTm then
    begin
        edtOP_ResultDir.Text := sTm;
    end;

    ActiveSaveEvent(Sender);
end;

procedure TfrmReference.CarInComboBoxEvent(Sender: TObject);
var
    Ctrl: TWinControl;
begin
    if not (Sender is TComboBox) then
        Exit;

    Ctrl := TComboBox(Sender).Parent;

    if Assigned(Ctrl) then
        gSysEnv.DispatchPush(Ctrl);
end;

procedure TfrmReference.ckbPump_UseOverSendPLCClick(Sender: TObject);
begin
    inherited;


    ActiveSaveEvent(Sender);
end;

procedure TfrmReference.ckbSli_UseOverSendPLCClick(Sender: TObject);
begin
    inherited;

    ActiveSaveEvent(Sender);
end;

constructor TfrmReference.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);
end;

procedure TfrmReference.OnMotionTypeClick(Sender: TObject);
var
    Prefix: string;
    RadioGroup: TRadioGroup;
    MtrGroupPanel, MtrGapPanel, ByCarTypePanel: TPanel;
    GroupTitleLabel: TLabel;
    Index: Integer;
begin
    if not (Sender is TRadioGroup) then
        Exit;

    RadioGroup := TRadioGroup(Sender);
    Index := RadioGroup.ItemIndex;

    Prefix := Copy(RadioGroup.Name, 4, Pos('_', RadioGroup.Name) - 4);

    MtrGroupPanel := FindComponent('pnl' + Prefix + '_MtrGroup') as TPanel;
    MtrGapPanel := FindComponent('pnl' + Prefix + '_MtrGapTime') as TPanel;
    ByCarTypePanel := FindComponent('pnl' + Prefix + '_ByCarType') as TPanel;
    GroupTitleLabel := FindComponent('lbl' + Prefix + '_MtrGroupTitle') as TLabel;

    if Assigned(MtrGroupPanel) then
        MtrGroupPanel.Visible := Index > 1;

    if Assigned(MtrGapPanel) then
        MtrGapPanel.Visible := Index = 3;

    if Assigned(GroupTitleLabel) then
    begin
        GroupTitleLabel.Caption := IfThen(Index = 3, '시차별 검사', '그룹별 검사');
    end;

    ActiveSaveEvent(Sender);
end;

procedure TfrmReference.pgcReferenceChange(Sender: TObject);
begin
    inherited;
    gSysEnv.Load(TSysEnvItem(pgcReference.ActivePageIndex));
    gSysEnv.DispatchPush(pgcReference.ActivePage);
end;

procedure TfrmReference.pnlActiveSystemTabDblClick(Sender: TObject);
begin
    inherited;
    tsDp.TabVisible := not tsDp.TabVisible;
end;

constructor TfrmReference.Create(AOwner: TComponent; Items: array of TfrmReferItem);
var
    Item: TfrmReferItem;
    i: Integer;
begin
    inherited Create(AOwner);

    if Length(Items) < 1 then
    begin
        SetLength(mActiveItems, Ord(High(TfrmReferItem)) - Ord(Low(TfrmReferItem)) + 1);
        for Item := Low(TfrmReferItem) to High(TfrmReferItem) do
            mActiveItems[Ord(Item)] := Item;
    end
    else
    begin
        SetLength(mActiveItems, Length(Items));
        for i := Low(Items) to High(Items) do
            mActiveItems[i] := Items[i];
    end;

end;

procedure TfrmReference.InitLimitCmdTabSheets(PageControl: TPageControl);
var
    i, j, MotorCount: Integer;
    Prefix, TemplateTabName: string;
    TemplateTab: TTabSheet;
    NewTab: TTabSheet;
    Comp, NewComp: TComponent;
    CompClass: TComponentClass;
begin

    MotorCount := Ord(High(TMotorOrd));

    if (MotorCount < 1) or (PageControl = nil) then
        Exit;

    // 접두사 추출 (예: pcLmt_LimitGroup → Lmt)
    if Copy(PageControl.Name, 1, 2) = 'pc' then
        Prefix := Copy(PageControl.Name, 3, Pos('_', PageControl.Name) - 3)
    else
        raise Exception.Create('PageControl name must start with "pc" and include "_"');

    // 템플릿 탭 이름은 항상 2번 탭을 기준
    TemplateTabName := Format('ts%s_CmdBGroup1', [Prefix]);
    TemplateTab := Self.FindComponent(TemplateTabName) as TTabSheet;
    if not Assigned(TemplateTab) then
        raise Exception.CreateFmt('Template TabSheet "%s" not found', [TemplateTabName]);

    // 탭 2 ~ MotorCount 생성
    for i := 2 to MotorCount do
    begin
        NewTab := TTabSheet.Create(PageControl);
        NewTab.PageControl := PageControl;
        NewTab.Name := Format('ts%s_CmdBGroup%d', [Prefix, i]);
        NewTab.Caption := Format('%d차', [i + 1]);

        // 템플릿 안의 컴포넌트를 복사
        for j := 0 to TemplateTab.ControlCount - 1 do
        begin
            Comp := TemplateTab.Controls[j];
            CompClass := TComponentClass(Comp.ClassType);
            NewComp := CompClass.Create(NewTab);

            if NewComp is TControl then
            begin
                TControl(NewComp).Parent := NewTab;
                TControl(NewComp).Left := TControl(Comp).Left;
                TControl(NewComp).Top := TControl(Comp).Top;
                TControl(NewComp).Width := TControl(Comp).Width;
                TControl(NewComp).Height := TControl(Comp).Height;
                TControl(NewComp).Align := TControl(Comp).Align;
                TControl(NewComp).Anchors := TControl(Comp).Anchors;
            end;

            // 속성 복사
            if NewComp is TEdit then
            begin
                with TEdit(NewComp) do
                begin
                    Font.Assign(TEdit(Comp).Font);
                    Name := Format('edtLmt_GroupGapTime%d', [i]);
                    Text := '';
                end;
            end
            else if NewComp is TCheckListBox then
            begin
                with TCheckListBox(NewComp) do
                begin
                    Items.Assign(TCheckListBox(Comp).Items);
                    Font.Assign(TCheckListBox(Comp).Font);
                    Name := Format('clbLmt_CmdBGroup%d', [i]);
                end;
            end
            else if NewComp is TLabel then
            begin
                with TLabel(NewComp) do
                begin
                    Caption := TLabel(Comp).Caption;
                    Font.Assign(TLabel(Comp).Font);
                end;
            end
            else
            begin
                // 다른 컴포넌트는 이름 그대로 복사
                NewComp.Name := Comp.Name;
            end;
        end;
    end;
end;

procedure TfrmReference.InitMtrTabSheets(PageControl: TPageControl);
var
    i: Integer;
    MotorCount: Integer;
    Prefix, TemplateTabName: string;
    TemplateTab: TTabSheet;
    TemplateCLB: TCheckListBox;
    NewTab: TTabSheet;
    NewCLB: TCheckListBox;
    SavedItems: TStrings;
begin

    MotorCount := Ord(High(TMotorOrd));

    if PageControl = nil then
        Exit;

    // 접두사 추출 (예: pcAl_MtrGroup → Al)
    if Copy(PageControl.Name, 1, 2) = 'pc' then
        Prefix := Copy(PageControl.Name, 3, Pos('_', PageControl.Name) - 3)
    else
        raise Exception.Create('PageControl name must start with "pc" and include "_"');

    // 첫번째 TabSheet는 고정. 2번째부터 생성

    TemplateTabName := Format('ts%s_MtrBGroup0', [Prefix]);
    TemplateTab := Self.FindComponent(TemplateTabName) as TTabSheet;
    if not Assigned(TemplateTab) then
        raise Exception.CreateFmt('Template TabSheet "%s" not found', [TemplateTabName]);

    // 템플릿 탭 내 CheckListBox 추출
    TemplateCLB := nil;
    for i := 0 to TemplateTab.ControlCount - 1 do
    begin
        if TemplateTab.Controls[i] is TCheckListBox then
        begin
            TemplateCLB := TemplateTab.Controls[i] as TCheckListBox;
            Break;
        end;
    end;

    if not Assigned(TemplateCLB) then
        raise Exception.Create('TCheckListBox not found in template tab');

    // 템플릿 CLB의 Items를 저장해둠
    SavedItems := TStringList.Create;
    try
        SavedItems.Assign(TemplateCLB.Items);

        // PageControl의 첫번째 탭 제외 모두 삭제
        while PageControl.PageCount > 0 do
            PageControl.Pages[0].Free;

        // MotorCount만큼 새로 생성
        for i := 0 to MotorCount do
        begin
            NewTab := TTabSheet.Create(PageControl);
            NewTab.PageControl := PageControl;
            NewTab.Name := Format('ts%s_MtrBGroup%d', [Prefix, i]);
            NewTab.Caption := Format('%d차', [i + 1]);

            NewCLB := TCheckListBox.Create(NewTab);
            NewCLB.Parent := NewTab;
            NewCLB.Align := alClient;
            NewCLB.Name := Format('clb%s_MtrBGroup%d', [Prefix, i]);
            NewCLB.OnClick := ActiveSaveEvent;
            NewCLB.Items.Assign(SavedItems);
        end;

    finally
        SavedItems.Free;
    end;
end;

procedure TfrmReference.ReadMessage(var myMsg: TMessage);
begin
    case myMsg.WParam of
        SYS_SAVE_DATA:
            Save;
    end;
end;

procedure TfrmReference.btnComm_ChangePortClick(Sender: TObject);
begin
    inherited;
    frmComsRefer := TfrmComsRefer.Create(Self);
    frmComsRefer.ShowModal;
end;

procedure TfrmReference.btnOP_GraphDirClick(Sender: TObject);
var
    sTm: string;
begin
    lpCallBackDir := edtOP_GraphDir.Text;

    sTm := GetUserFolderEx(Self.Handle, BrowserCallBackProc, 'Graph folder');
    if (sTm = '') or not DirectoryExists(sTm) then
        Exit;

    if edtOP_GraphDir.Text <> sTm then
    begin
        edtOP_GraphDir.Text := sTm;
    end;

    ActiveSaveEvent(Sender);
end;

end.

