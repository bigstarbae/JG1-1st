unit PwrBurnishingForm;
{$I myDefine.inc}

interface

uses
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, BaseMainForm, ExtCtrls, StdCtrls, ModelInfoFrame, Label3D, _GClass,
    AbLED, pngimage, Buttons, ComCtrls, Grids, SeatConnector, SeatMotor,
    TeeChartUtil, TsWorkUnit, SeatMotorType, TimeChecker, TeEngine, Series,
    TeeProcs, Chart;

type
    TfrmPwrBurnishing = class(TfrmBaseMain)
        pnlClient: TPanel;
        shpTop: TShape;
        shpLeft: TShape;
        shpRight: TShape;
        shpConseparator: TShape;
        shpBottom: TShape;
        pnlCon: TPanel;
        lblConName: TLabel3D;
        Label19: TLabel;
        lblMotorCurr: TLabel;
        Label99: TLabel;
        tmrPoll: TTimer;
        sgCon: TStringGrid;
        tmrShow: TTimer;
        tmrMain: TTimer;
        abDiskD: TAbLED;
        abDiskC: TAbLED;
        tmrDiskChk: TTimer;
        lblWorkMonitor: TLabel;
        lblMemory: TLabel;
        lblCycleTime: TLabel;
        fmModelInfo: TMdllInfoFrame;
        sbtnCon: TSpeedButton;
        tcCon: TTabControl;
        pnlGrp: TPanel;
        shpGap2: TShape;
        Shape3: TShape;
        pnlLegend: TPanel;
        lblCaption: TLabel;
        Shape2: TShape;
        chtMtr: TChart;
        FastLineSeries6: TFastLineSeries;
        Series1: TFastLineSeries;
        Series2: TFastLineSeries;
        Series3: TFastLineSeries;
        pnlBurnInfo: TPanel;
    pnlBurn_Slide: TPanel;
        lblBrnCnt_Slide: TLabel3D;
        Label3D2: TLabel3D;
    pnlBurn_CushTilt: TPanel;
    lblBrnCnt_CushTilt: TLabel3D;
        lbl1: TLabel3D;
    pnlBurn_Recl: TPanel;
        lblBrnCnt_Recl: TLabel3D;
        lbl2: TLabel3D;
    pnlBurn_Shoulder: TPanel;
        lblBrnCnt_Shoulder: TLabel3D;
        lbl3: TLabel3D;
    pnlBurn_Relax: TPanel;
        lblBrnCnt_Relax: TLabel3D;
        lbl4: TLabel3D;
    pnlBurn_WalkinTilt: TPanel;
    lblBrnCnt_WalkinTilt: TLabel3D;
    Label3D3: TLabel3D;
        procedure FormShow(Sender: TObject);
        procedure sgConDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
        procedure sbtnModelClick(Sender: TObject);
        procedure sbtnReferenceClick(Sender: TObject);
        procedure sbtnRetrieveClick(Sender: TObject);
        procedure sbtnExitClick(Sender: TObject);
        procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
        procedure tmrPollTimer(Sender: TObject);
        procedure sbtnConClick(Sender: TObject);
        procedure SpeedButton1Click(Sender: TObject);
        procedure FormDestroy(Sender: TObject);
        procedure FormCreate(Sender: TObject);
        procedure chtMtrDblClick(Sender: TObject);
        procedure tcConChange(Sender: TObject);
        procedure lblSimLanInModeClick(Sender: TObject);
        procedure tmrShowTimer(Sender: TObject);
        procedure FormClose(Sender: TObject; var Action: TCloseAction);
        procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
        procedure tmrDiskChkTimer(Sender: TObject);
        procedure tmrMainTimer(Sender: TObject);
    private
    { Private declarations }
        mCT: TTimeChecker;
        mDAQTimerCnt: Integer;

        mSC: TScrollChartHelper;
        mXMax: Double;

        mState: Integer;
        mScrIO, mSysIdle, mLock: Boolean;

        procedure UpdateGraph(IsClear: Boolean);
        procedure UpdateConUI(Con: TBaseSeatConnector);

        procedure ReadCount;
        procedure ReadDAQValues;
        procedure ShowConnectorForm(Station: integer);
        procedure SetBurnishingCount(Motor: TSeatMotor);
        procedure DisplayDiskFree;
        procedure ReadWorkCycleTime;
        procedure WorkError(Sender: TObject);
        procedure WorkClose(Sender: TObject);
        procedure GlobalExceptionHandler(Sender: TObject; E: Exception);
    protected
        mTsWork: TTsWork;
        mCurCon: TBaseSeatConnector;        // 현재 보여지는 커넥터

        procedure HandleReadMessage(var myMsg: TMessage); override;
        procedure OnWorkStatus(AStatus: Integer); override;

    public
    { Public declarations }
    end;

var
    frmPwrBurnishing: TfrmPwrBurnishing;

implementation

uses
    ShellAPI, Global, Work, Log, DataUnit, SysEnv, DataUnitHelper, IODef,
    KIIMessages, ModelUnit, UserSocketUnit, LanIoUnit, BaseTsWork, PopWork,
    madKernel, FormUtils, StrUtils, GridUtils, myUtils, LangTran,
    ModelSelSimForm, DioReferForm, StateViewForm, waitForm, ExitForm,
    UserModelForm, PinIOForm, DIOExForm, UserReferForm, NotifyForm,
    GraphconfigForm, BaseDIO, BaseAD, ErrorForm, ReferenceForm;

{$R *.dfm}

const
    MAX_RT_GRP_TIME_RANGE = 20;

procedure TfrmPwrBurnishing.chtMtrDblClick(Sender: TObject);
begin
    if gWork.IsTesting then
        Exit;

    frmgrpConfig.Left := Left + Width div 2 - frmgrpConfig.Width div 2;
    frmgrpConfig.Top := Top + Height div 2 - frmgrpConfig.Height div 2;

    frmgrpConfig.BorderStyle := bsDialog;
    frmgrpConfig.SetFrm(TComponent(Sender).Tag);

    frmgrpConfig.ShowModal;

end;

procedure TfrmPwrBurnishing.DisplayDiskFree;
var
    dTm: double;
    iTm, Total: int64;
begin
    if DirectoryExists('C:\') then
    begin
        iTm := GetDiskFreeSize('C:\', Total);
        dTm := ((Total - iTm) / Total) * 100.0;

        abDiskC.Caption := Format('Disk(C:) %0.0f %%', [dTm]);

        abDiskC.Checked := True;
        if dTm < 70.0 then
            abDiskC.LED.ColorOn := clLime
        else if dTm < 90.0 then
            abDiskC.LED.ColorOn := clYellow
        else
            abDiskC.LED.ColorOn := clRed;

        abDiskC.Flashing := abDiskC.LED.ColorOn = clRed;
    end
    else
    begin
        abDiskC.Checked := False;
    end;

    if DirectoryExists('D:\') then
    begin
        iTm := GetDiskFreeSize('D:\', Total);
        dTm := ((Total - iTm) / Total) * 100.0;
        abDiskD.Caption := Format('Disk(D:) %0.0f %%', [dTm]);

        abDiskD.Checked := True;
        if dTm < 70.0 then
            abDiskD.LED.ColorOn := clLime
        else if dTm < 90.0 then
            abDiskD.LED.ColorOn := clYellow
        else
            abDiskD.LED.ColorOn := clRed;

        abDiskD.Flashing := abDiskD.LED.ColorOn = clRed;
    end
    else
    begin
        abDiskD.Checked := False;
    end;
end;

procedure TfrmPwrBurnishing.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    inherited;
    FreeAndNil(abPLC);
    FreeAndNil(gWork);
    gLog.Panel('------------>%s CLOSE<------------', [PROJECT_NAME]);

end;

procedure TfrmPwrBurnishing.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
    inherited;
    if not tmrMain.Enabled then
        Exit;

    mIsClose := True;

    gLog.Debug('------------>%s 종료중...<------------', [PROJECT_NAME]);
    tmrMain.Enabled := False;
    abPLC.Checked := False;
    abPLC.Flashing := False;

    if Assigned(gWork) then
    begin

        gWork.Stop;

        if Assigned(gWork.Thread) then
        begin
            gWork.Stop;
            CanClose := False;
        end;

    end;
end;

procedure TfrmPwrBurnishing.FormCreate(Sender: TObject);
begin
    inherited;

//    mSC := TScrollChartHelper.Create(chtMtr);
//    mSC.XMax4Reset := 999999;
//    mXMax := MAX_RT_GRP_TIME_RANGE;
//    mSC.Start(mXMax);
//    chtMtr.OnAfterDraw := ChartAfterDraw;

    if not gsysEnv.rOP.rUseScreenSaver then
        SetsysSaverEnable(0);

    mIsClose := False;
    mSysIdle := True;
    mScrIO := True;

  //  gLog := TLog.Create(lbLog.Handle, 1, True);
    // gLog.UseQueue := True;
    gLog.ToFiles('------------>%s V%s START<------------', [PROJECT_NAME, gSysEnv.rOP.rVer]);
{$IFNDEF VIRTUALIO}
{
    frmsysCheck := TfrmsysCheck.Create(Application);
    with frmsysCheck do
    begin
        Execute();
    end;
}
{$ENDIF}

    frmNotify := TfrmNotify.Create(Application);
    frmError := TfrmError.Create(Application);

    Application.OnException := GlobalExceptionHandler;
end;

procedure TfrmPwrBurnishing.FormDestroy(Sender: TObject);
begin

    if not GetsysSaverEnable then
        SetsysSaverEnable(1);

    mSC.Free;
    inherited;

end;

procedure TfrmPwrBurnishing.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
    i: Integer;
    DIOs: TArray<TBaseDIO>;
    ADs: TArray<TBaseAD>;
    StNames: TArray<string>;

    procedure ShowModelSelForm;
    var
        i: integer;
        StNames: array of string;
    begin
        SetLength(StNames, gTsWorks.Count);
        for i := 0 to gTsWorks.Count - 1 do
            StNames[i] := gTsWorks.Items[i].Name;

        with TfrmModelSelSim.Create(Application) do
        begin

            FormStyle := fsStayOnTop;
            SetForm(gLanDIO.DataRawIO, StNames);

            Show;
        end;
        StNames := nil;
    end;

begin
    case Key of
        VK_F1:
            begin
                if (ssCtrl in Shift) or (ssShift in Shift) then
                begin

                end
                else
                begin

                    TfrmDioReferForm.CloseForm;

                    SetLength(StNames, MAX_ST_COUNT);
                    SetLength(DIOs, MAX_ST_COUNT);
                    SetLength(ADs, MAX_ST_COUNT);

                    for i := 0 to MAX_ST_COUNT - 1 do
                    begin
                        StNames[i] := gTsWork[i].Name;
                        DIOs[i] := gTsWork[i].DIO;
                        ADs[i] := gTsWork[i].AD;
                    end;

                    with TfrmDioReferForm.Create(Application, StNames) do
                    begin
                        AddLIO('LAN DIO', gLanDIO, _LAN_IO_CH_COUNT, MAX_ST_COUNT, gLanDIO.GetDataIoAsWord);
                        AddDIOs('내부 DIO', DIOs, _DIO_CH_COUNT);
                        AddADs('AI', ADs);
                        Show;
                    end;
                end;
            end;
        VK_F2:
            begin
                if (ssCtrl in Shift) or (ssShift in Shift) then
                begin

                end
                else
                begin

                end;
            end;
        VK_F3:
            begin
{$IFDEF VIRTUALLANIO}
                ShowModelSelForm;
{$ELSE}
                if not gLanDIO.Items[devREAD].Enabeld then
                    ShowModelSelForm;
{$ENDIF}
            end;
        VK_F5:
            begin
                frmStateView := TfrmStateView.Create(Application);
                frmStateView.Show;
            end;

        VK_F7:
            begin
                if Shift = [ssShift] then
                begin

                end
                else if Shift = [ssCtrl] then
                begin
                end
                else if Shift = [ssAlt] then
                begin
                end;
            end;
        VK_F8:
            begin
                if Shift = [ssShift] then
                begin
                end
                else if Shift = [ssCtrl] then
                begin
                    lblSimLanInMode.Visible := not lblSimLanInMode.Visible;
                    gLanDIO.Items[devRead].Enabeld := not lblSimLanInMode.Visible;

                end
                else if Shift = [ssAlt] then
                begin
                end;
            end;
        VK_F9:
            begin
                if Shift = [ssShift] then
                begin
                end
                else if Shift = [ssCtrl] then
                begin
                end
                else if Shift = [ssAlt] then
                begin
                end;
            end;
        VK_F10:
            begin
                if Shift = [ssShift] then
                begin
                end
                else if Shift = [ssCtrl] then
                begin
                end
                else if Shift = [ssAlt] then
                begin
                end;
            end;
    end;

end;

procedure TfrmPwrBurnishing.FormShow(Sender: TObject);
var
    i: Integer;
    DevComOrd: TDevComORD;
begin
    inherited;

{$IFDEF VIRTUALIO}
    Application.MessageBox(PWideChar(_TR('시뮬레이션 모드입니다.') + #13 + Format(_TR('Mtr Spec:%d, Model:%d, MotorData:%d, IMS Data:%d, TResult:%d, TModels:%d 납품위치:%d'), [sizeof(TMotorSpec), sizeof(TModel), sizeof(TMotorData), sizeof(TImsData), sizeof(TResult), sizeof(TModels), sizeof(TMotorDeliveryPos)])), '');
{$ENDIF}

    gWork := TWork.Create(Self);

    if Assigned(gWork) then
    begin
        gWork.Thread.OnTerminate := WorkClose;
{$IFNDEF VIRTUALIO}
        gWork.Thread.OnError := WorkError;
{$ENDIF}
    end;

    for i := 1 to MAX_ST_COUNT - 1 do
    begin
        DevComOrd := Succ(DevComOrd);
        AddSubForm(TfrmPwrBurnishing.Create(Self)).ShowPLCInfo(False);
    end;
//
//    DevComOrd := dcPS_01;
//
//    AddDevComInfo(Ord(DevComOrd), GetDevComName(DevComOrd));

    DisplayDiskFree;

    tmrShow.Enabled := True;
    tmrMain.Enabled := True;

    if mFormIdx >= Length(gTsWork) then
        Exit;

    mTsWork := gTsWork[mFormIdx];
    if mTsWork = nil then
        Exit;

    mTsWork.Handle := Handle;
    gPopSys.Items[mFormIdx].DestHandle := Handle;

    Caption := mTsWork.Name + '  ' + PROJECT_NAME;

{$IFDEF VIRTUALIO}
    pnlTitle.Caption := Caption + ' : SIMUL.MODE';
{$ELSE}
    pnlTitle.Caption := Caption;
{$ENDIF}

    tcCon.Tabs.Clear;

    for i := 0 to mTsWork.ConCount - 1 do
        tcCon.Tabs.Add(mTsWork.Connectors[i].Title);

    sgCon.Cells[0, 0] := 'No';
    sgCon.Cells[1, 0] := 'Name';
    sgCon.Cells[2, 0] := '(A)';
    sgCon.Cells[3, 0] := '(V)';

    ReadCount;

    UpdateGraph(True);

    tmrPoll.Enabled := True;

    Top := 0;
    Width := 1920;
    Height := 1080;

    with fmModelInfo do
    begin
        SetColRatios([pnlPartInfo, pnlClass, pnlPos, pnlCarSubType, pnlECU, pnlHV, pnlBuckle, pnlMotors], [4, 1, 1, 1, 1, 1, 1, 2.4]);
        SetSeatsCount(4);
    end;

    mTsWork.Initial(False);

end;

procedure TfrmPwrBurnishing.GlobalExceptionHandler(Sender: TObject; E: Exception);
begin
    gLog.Error('예외 발생: %s', [E.Message]);
    if E.StackTrace <> '' then         // 유레카 로그 활성화한 경우 StackTrace 가능
        gLog.Error('호출 경로: %s', [E.StackTrace]);

    Application.ShowException(E);
end;

procedure TfrmPwrBurnishing.HandleReadMessage(var myMsg: TMessage);
begin

    case myMsg.WParam of
        SYS_GRAPH:
            begin
                if gWork.IsTesting then
                    Exit;
                UpdateGraph(false);
            end;
        SYS_MODEL:
            begin
                if not Assigned(gModels) or gWork.IsTesting or (not mTsWork.IsModelChange) then
                    Exit;

                OnWorkStatus(ord(tw_None));

            end;
        SYS_RUN_MODE:
            begin
            end;
        SYS_UPDATES, SYS_COUNT_UPDATES:
            begin
                ReadCount();
            end;
        // ----------------------------
        SYS_POP_CONNECTED:
            begin
                if myMsg.LParam <> mFormIdx then
                    Exit;
                HideMsg;
                abPOP.Checked := True;
                abPOP.LED.ColorOn := clLime;
            end;
        SYS_POP_CONNECTING:
            begin
                if myMsg.LParam <> mFormIdx then
                    Exit;
                abPOP.Checked := True;
                abPOP.LED.ColorOn := clYellow;
            end;
        SYS_POP_DISCONNECTED:
            begin
                if myMsg.LParam <> mFormIdx then
                    Exit;
                DisplayMsg(_TR('POP 연결 끊김'), _TR('LAN 연결 상태를 점검 하세요'), mtErr);
                abPOP.Checked := false;
            end;
        SYS_ETHERNET_ERROR:
            begin
                if myMsg.LParam <> mFormIdx then
                    Exit;
                abPOP.Checked := True;
                abPOP.LED.ColorOn := clRed;
            end;
    end;

end;

procedure TfrmPwrBurnishing.lblSimLanInModeClick(Sender: TObject);
begin
    lblSimLanInMode.Visible := False;
    gLanDIO.Items[devRead].Enabeld := not lblSimLanInMode.Visible;

end;

procedure TfrmPwrBurnishing.OnWorkStatus(AStatus: Integer);

    procedure ClearComponents(AModel: TModel);
    var
        MtrIt: TMotorORD;
    begin
//        if TfrmPinIO.mIsShow then
//        begin
//            mTsWork.SwCon.WriteAsPinName(frmPinIO.sgPinIO.Cols[frmPinIO.sgPinIO.ColCount - 1], 1);
//        end;

        fmModelInfo.SetModel(AModel.rTypes);
        fmModelInfo.PopLinkMode := mTsWork.IsPopLinkMode;
        fmModelInfo.lblCarType.Caption := AModel.rTypes.GetCarTypeStr;

        if mTsWork.IsPopLinkMode then
        begin
            fmModelInfo.lblPartNo.Caption := mTsWork.Pop.rcvPartNo; // string(AModel.rPartNo);
            fmModelInfo.lblLotNo.Caption := mTsWork.Pop.rcvLotNo;
        end;

        lblResult.Caption := '';
        lblResult.Color := $00555555;
        lblResult.Font.Color := clLime;

        lblStatus.Caption := '';

        for MtrIt := Low(TMotorORD) to MtrOrdHi do
        begin
            mTsWork.Motors[MtrIt].mCurRepeatCount := 0;
            SetBurnishingCount(mTsWork.Motors[MtrIt]);
        end;

        pnlBurn_Slide.Visible := AModel.rTypes.IsSlideMtrExists;
        pnlBurn_CushTilt.Visible := AModel.rTypes.IsCushTiltMtrExists;
        pnlBurn_WalkinTilt.Visible := AModel.rTypes.IsWalkinTiltMtrExists;
        pnlBurn_Recl.Visible := AModel.rTypes.IsReclineMtrExists;
        pnlBurn_Relax.Visible := AModel.rTypes.IsRelaxMtrExists;
        pnlBurn_Shoulder.Visible := AModel.rTypes.IsShoulderMtrExists;

        RefreshAlignedControls([pnlBurn_Slide, pnlBurn_CushTilt, pnlBurn_WalkinTilt, pnlBurn_Recl, pnlBurn_Relax, pnlBurn_Shoulder], alTop);

    end;

begin

    with mTsWork, mTsWork.DBX do
    begin
        case AStatus of
            ord(tw_None):
                begin
                    ClearComponents(mTsWork.RsBuf.rModel);
                    Exit;
                end;

            ord(tw_INIT):
                begin
                    HideMsg;

                    ClearComponents(RsBuf.rModel);
                    lblStatus.Caption := _TR('대기 중');
                end;

            ord(tw_TEST_MODE):
                begin

                    if mTsWork.IsAuto then
                    begin
                        lblMode.Font.Color := $00FFFFBD;
                        lblMode.Caption := 'AUTO';

                    end
                    else
                    begin
                        lblMode.Font.Color := $000EC9FF;
                        lblMode.Caption := 'MANUAL';

                    end;

                end;
            ord(tw_POP_LINK_MODE):
                begin
                    fmModelInfo.PopLinkMode := mTsWork.IsPopLinkMode;
                    {
                    if mTsWork.IsPopLinkMode then
                        lblCarType.Caption := mTsWork.CurModelType.GetCarTypeStr
                    else
                        lblCarType.Caption := mTsWork.CurModelType.GetCarTypeStr + _TR(' : 단동');
                    }

                end;
            ord(tw_POP_RCVD_MODEL):
                begin
                    fmModelInfo.lblPartNo.Caption := mTsWork.Pop.rcvPartNo;
                    fmModelInfo.lblLotNo.Caption := mTsWork.Pop.rcvLotNo;
                end;
            ord(tw_PDT_LOADED):
                begin
                    lblStatus.Caption := _TR('제품 도착');
                    DisplayMsg('커넥터 체결 후, 시작 버튼을 누르세요', '커넥터를 체결하세요', mtNotify, GetEnvPath('ICON\Start.png'));
                end;
            ord(tw_CON_CHK):
                begin
                    ClearComponents(mTsWork.RsBuf.rModel);

                    if mTsWork.IsAuto then
                        DisplayMsg(_TR('커넥터를 체결하세요'), _TR('측정을 위해 커넥터를 체결해 주세요'));
                end;
            ord(tw_SPEC_CHK_START):
                begin
                    lblStatus.Caption := _TR('제품 사양 검사');
                    DisplayMsg(_TR('모델 사양 검사 중 입니다'), _TR('커넥터 체결 후 잠시만 기다리세요..'), mtNotify, GetEnvPath('ICON\Loading3.gif'));
                end;
            ord(tw_SPEC_CHK_END):
                begin
                    lblStatus.Caption := _TR('제품 사양 검사 완료');
                    HideMsg;
                end;

            ord(tw_CHK_DISCONNECT):
                begin
                    lblStatus.Caption := _TR('커넥터 체결 유무  검사');
                    DisplayMsg(_TR('커넥터 체결 유무 검사 중 입니다'), _TR('해제시 완료버튼을 다시 눌러 진행하세요'), mtNotify, GetEnvPath('ICON\Loading3.gif'));
                end;

            ord(tw_FP_START):
                lblStatus.Caption := _TR('F/P 검사 시작');
            ord(tw_FP_END):
                begin
                end;
            ord(tw_START):
                begin

                    HideMsg;

                    lblStatus.Caption := _TR('검사 시작');
                    lblResult.Caption := '▶';
                    mCT.Start;
                end;
            ord(tw_STOP):
                begin
                    {
                    if imgIcon.Visible then
                        HideMsg; // 사양체크시만 닫고, 나머지는 사용자 인지 위해 계속 표시
                    }

                    lblStatus.Caption := _TR('검사 중지');
                    lblResult.Caption := '';
                    mCT.Stop;
                    if lblResult.Color <> $00555555 then
                    begin
                        lblResult.Color := $00555555;
                    end;

                end;
            ord(tw_END):
                begin
                    mCT.Stop;
                    lblStatus.Caption := _TR('작업 완료');
                    DisplayMsg(_TR('작업 완료!'), _TR('작업을 종료하였습니다. 커넥터를 뽑은 뒤 버튼을 눌러주세요.'), mtNotify, GetEnvPath('ICON\TestEnd.png'));
                end;
            ord(tw_SAVE):
                begin
                    lblResult.Caption := 'OK';
                    lblResult.Color := JUDGE_COLOR[True];
                    lblResult.Font.Color := clWhite;
                end;
            ord(tw_ARRANGE):
                lblStatus.Caption := _TR('데이타 정리');

            ord(tw_BURNISHING_START):
                begin
                    lblStatus.Caption := _TR('버니싱 수행 중');
                end;
            ord(tw_BURNISHING_CYCLE):
                begin
                    SetBurnishingCount(mTsWork.CurMotor);
                end;

            ord(tw_BURNISHING_END):
                begin
                    lblStatus.Caption := _TR('버니싱 완료');
                end;

            ord(tw_MEAS_START):
                begin

                end;

            ord(tw_MEAS_STOP):
                begin
                end;

            ord(tw_INIT_POS_START):
                begin
                    lblStatus.Caption := _TR('모터초기위치 이동');
                end;
            ord(tw_INIT_POS_END):
                lblStatus.Caption := _TR('모터초기위치 완료');

            ord(tw_CHECK_LOAD_RELEASE):
                lblStatus.Caption := _TR('부하 로딩 대기중');

            ord(tw_UNLOADING):
                lblStatus.Caption := _TR('부하 언로딩 중');

            ord(tw_CHECK_ALL_TEST_END):
                lblStatus.Caption := _TR('검사완료 대기중');

            ord(tw_DELIVERY_START):
                lblStatus.Caption := _TR('납품위치 이동');
            ord(tw_DELIVERY_END):
                begin
                    lblStatus.Caption := _TR('납품위치 완료');
                  {  if not pnlError.Visible and not gSysEnv.rAutoConnect then
                    begin
                        DisplayMsg(_TR('커넥터를 제거해 주세요'),  _TR('시험이 완료되었습니다, 커넥터 제거후 완료버튼을 누르세요'), 1);
                    end; }
                end;
            ord(tw_MID_POS_OK):
                begin
                    lblStatus.Caption := _TR('SLIDE M 납품위치 완료');
                end;

            ord(tw_MOTOR_INIT):
                begin
                    lblStatus.Caption := _TR('모터 정렬 시작')
                end;

            ord(tw_ERROR):
                begin

                    lblStatus.Caption := _TR('에러 발생');
                    lblResult.Caption := '';

                    HideMsg;
                    DisplayMsg(ErrorMsg, ErrorToDo, mtWarn, GetEnvPath('ICON\Warn.gif'));

                    {
                    pnlError.Visible := false;
                    if ErrorMsg <> '' then
                        MsgForm.ShowErrMsg(self, ErrorMsg, ErrorToDo);
                    }
                end;

            ord(tw_MSG):
                begin

                    HideMsg;
                    DisplayMsg(ErrorMsg, ErrorToDo, mtNotify);

                end;

            ord(tw_MSG2):
                begin

                end;

            ord(tw_ALARM):
                begin
                    DisplayMsg(_TR('ALARM'), _TR('기구 ALARM이 발생했습니다, 상황을 해제하고 RESET을 누르세요'), mtErr, GetEnvPath('ICON\Warn.png'));
                end;

            ord(tw_EMERGY):
                begin
                    DisplayMsg(_TR('비상정지'), _TR('비상정지 버튼을 누르셨습니다, 상황을 해제하고 RESET을 누르세요'), mtErr, GetEnvPath('ICON\Error.png'));
                end;
            ord(tw_HIDE_MSG):
                begin
                    HideMsg;
                end;
            ord(tw_STATUS):
                ;
            ord(tw_POWER_CHECK):
                lblStatus.Caption := _TR('전원 확인중');

            // ----------------------------------------------------------------------
            // 모터 검사
            // ----------------------------------------------------------------------

            ord(tw_MTR_TEST_START):
                begin
                    with CurMotor do
                    begin
                        with mTsWork.RsBuf.rModel.rTypes do
                        begin
                            lblStatus.Caption := GetMotorName(ID) + ' ' + SeatMotor.GetMotorDirStr(CurMotor) + _TR(' 시작');
                        end;

                        {
                        if TestStep = 0 then
                            mMtrFrames[ID].ClearGrid;
                        }
                    end;
                end;
            ord(tw_MTR_TEST_STOP):
                begin
                    with CurMotor do
                    begin
                        with mTsWork.RsBuf.rModel.rTypes do
                        begin
                            lblStatus.Caption := GetMotorName(ID) + ' ' + SeatMotor.GetMotorDirStr(CurMotor) + _TR(' 완료');
                        end;

                    end;

                end;

            ord(tw_LIMIT_START):
                begin
                    lblStatus.Caption := _TR('LIMIT 설정 중');
                end;

            ord(tw_LIMIT_READED):
                begin

                end;

            ord(tw_HALL_SENSOR):
                begin
                end;

            ord(tw_BLUE_LINK):
                begin

                end;

            // 이음
                ord(tw_ABNML_SOUND):
                begin
                    DisplayMsg(_TR('이음 감지 NG'), _TR('제품을 NG처리 합니다'), mtErr);
                end;

            ord(tw_CON_INFO_LOADED):
                begin
                    tcConChange(tcCon);
                end;

            // ----------------------------------------------------------------------
            // 바코드 스캔
            // ----------------------------------------------------------------------
                ord(tw_BC_READED):
                begin
                    HideMsg;
                end;

        end;
    end;
end;

function GetInvertColor(Color: TColor): TColor;
begin
    if ((GetRValue(Color) + GetGValue(Color) + GetBValue(Color)) > 384) then
        Result := clBlack
    else
        Result := clWhite;
end;

function IsZeroVal(Val: double): boolean;
begin
    Result := (-0.2 <= Val) and (Val <= 0.2);
end;

function IsPlusVal(Val: double): boolean;
begin
    Result := Val >= 0.02;
end;

procedure TfrmPwrBurnishing.ShowConnectorForm(Station: integer);
begin
    if not TfrmPinIO.mIsShow then
    begin
        frmPinIO := TfrmPinIO.Create(Application);
        with frmPinIO do
        begin
            BorderStyle := bsSizeable;
            FormStyle := fsStayOnTop;
            with mTsWork do
            begin
                frmPinIO.Caption := mTsWork.Name;
//                frmPinIO.InitPinDAQ(DIO, AD, DO_SW_PIN_START, AI_MTR_CURR_START, AI_SW_CON_VOLT_START, MAX_SW_PIN_COUNT);
//                mTsWork.SwCon.WriteAsPinName(sgPinIO.Cols[sgPinIO.ColCount - 1], 1);
            end;
            Show;
        end;
    end;

    if not frmDIOEx.mIsShow then
    begin
        frmDIOEx := TfrmDIOEx.Create(Application);
        with frmDIOEx do
        begin
            BorderStyle := bsSizeable;
            FormStyle := fsStayOnTop;
            Init(gTsWork[Station].DIO, [12], [12, 12], ['DI', 'IGN/SPEC', 'SPEC OUTPUT']);
            LoadNames(GetEnvPath('IOList.ini'));

//            AddExtraDO(DO_DMOVE_GND, 'DIRECT DRIVE');
//            AddExtraDO(DO_L_CAN, 'L_CAN');
            Show;
        end;
    end;

    frmPinIO.AddChild(frmDIOEx.Handle);

    frmPinIO.Top := 150; // Screen.Height - ((frmPinIO.Height + frmDIOEx.Height) div 2);
//    frmPinIO.Width := frmDIOEx.Width;
    frmDIOEx.Left := frmPinIO.Left;
    frmDIOEx.Top := frmPinIO.Top + frmPinIO.Height;

    frmPinIO.CheckGlueing;

end;

procedure TfrmPwrBurnishing.SpeedButton1Click(Sender: TObject);
begin
    inherited;
    ShowMessage('TEST');
end;

procedure TfrmPwrBurnishing.sbtnConClick(Sender: TObject);
begin
    ShowConnectorForm(Ord(mTsWork.StationID));
end;

procedure TfrmPwrBurnishing.sbtnExitClick(Sender: TObject);
begin
    with TExitFrm.Create(Application, gSysEnv.rOP.rVer) do
    begin
        Position := poScreenCenter;
        Caption := PROJECT_NAME + _TR(' 종료');
        SetTitile(PROJECT_NAME);
        SetsubTitle('2024.11 kii@kii-fa.co.kr');

        if ShowModal = mrCancel then
            Exit;
    end;
    mIsClose := true;
    // -----------------------------
    frmNotify.Caption := Caption + _TR(' 프로그램 종료중...');
    frmNotify.SetFrm(_TR('잠시 기다려 주십시요'));
    frmNotify.Show;
    // 각모듈에 연결된 포인트 청소.
    PostMessage(gUsrMsg, WM_CLOSE, 0, 0);
    gLog.Debug('MEASURE FORM CLOSE', []);

end;

procedure TfrmPwrBurnishing.sbtnModelClick(Sender: TObject);
begin
    if not ShowPasswordForm then
        Exit;

    if Assigned(frmUserModel) then
        SendMessage(frmUserModel.Handle, WM_CLOSE, 0, 0);
    frmUserModel := TfrmUserModel.Create(Self);
    frmUserModel.FormStyle := fsStayOnTop;
    frmUserModel.Height := 980;
    frmUserModel.Show();

end;

procedure TfrmPwrBurnishing.sbtnReferenceClick(Sender: TObject);
begin
    if not ShowPasswordForm then
        Exit;

    SendMessage(gDioReferwnd, WM_CLOSE, 0, 0);
    if Assigned(frmUserRefer) then
        SendMessage(frmUserRefer.Handle, WM_CLOSE, 0, 0);
    frmUserRefer := TfrmUserRefer.Create(Self, [uriPwrSpl, uriECU], [riMotor, riBurnishing, riIMSLimit]);
    frmUserRefer.FormStyle := fsStayOnTop;
    frmUserRefer.Show();

end;

procedure TfrmPwrBurnishing.sbtnRetrieveClick(Sender: TObject);
var
    sTm: string;
    nP: IProcesses;
    nF: TfrmWait;
    dTm: double;
begin
    sTm := GetHomeDirectory + '\DataViewer.exe';
    if not FileExists(sTm) then
    begin
        MessageDlg(_TR('조회 프로그램을 찾을 수 없습니다. 확인 후 다시 시도하세요.'), mtERROR, [mbYes], 0);
        Exit;
    end;
    nF := TfrmWait.Create(Application);
    with nF do
    begin
        Execute('PwrSeatTester.exe', 30.0);
        // Execute();
    end;

    nP := Processes('DataViewer.exe');
    if nP.IsStillRunning then
    begin
        nP.Minimize();
        nP.Restore();
        Exit;
    end;
    dTm := GetAccurateTime;
    ShellExecute(0, 'OPEN', PChar(sTm), '', PChar(ExtractFileDir(sTm)), SW_SHOW);
    gLog.Panel('ShowTime: %f', [GetAccurateTime - dTm]);
end;

procedure TfrmPwrBurnishing.SetBurnishingCount(Motor: TSeatMotor);
begin
    case Motor.ID of
        tmSlide:
            begin
//                lblSlideBrnCnt.Caption := Format('%d/%d', [Motor.CurRepeatCount, Motor.TotRepeatCount]);
            end;
    end;
end;

procedure TfrmPwrBurnishing.sgConDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
var
    FontColor, BkColor: TColor;
    CellStr: string;
    Grid: TStringGrid;
    Val: double;
    FontSize: Integer;

    procedure SetCurrCell;
    begin
        Val := mCurCon.GetPinCurr(ARow);
        CellStr := Format('%f', [Val]);
        if IsPlusVal(Val) then
            FontColor := clRed
        else
            FontColor := clBlack;
    end;

    procedure SetVoltCell;
    begin
        Val := mCurCon.GetPinVolt(ARow);
        CellStr := Format('%f', [Val]);
        if IsPlusVal(Val) then
            FontColor := clBlue
        else
            FontColor := clBlack;
    end;

begin

    Grid := TStringGrid(Sender);
    Grid.Canvas.Font := Grid.Font;
    FontSize := 10;

    FontColor := Grid.Font.Color;
    if (ARow mod 2) = 0 then
        BkColor := IncRGB(Grid.Color, -10)
    else
        BkColor := Grid.Color;

    CellStr := Grid.Cells[ACol, ARow];

    if ARow = 0 then
    begin
        FontColor := GetInvertColor(Grid.FixedColor);
        BkColor := Grid.FixedColor;
    end
    else if Assigned(mCurCon) then
    begin

        case ACol of
            0, 1:
                begin
                    FontColor := clBlack;

                    if ACol = 1 then
                        FontSize := 8;

                end;
            2, 3:
                begin
                    if Grid.Cells[ACol, 0] = '(A)' then
                        SetCurrCell
                    else
                        SetVoltCell;
                end;
        end;

    end;

    SetBkMode(Grid.Canvas.Handle, TRANSPARENT);
    Grid.Canvas.Font.Size := FontSize;
    Grid.Canvas.Font.Color := FontColor;
    Grid.Canvas.Brush.Color := BkColor;
    Inc(Rect.Bottom);
    Grid.Canvas.FillRect(Rect);
    DrawText(Grid.Canvas.Handle, CellStr, Length(CellStr), Rect, DT_CENTER or DT_VCENTER or DT_SINGLELINE);

end;

procedure TfrmPwrBurnishing.tcConChange(Sender: TObject);
begin
    if tcCon.TabIndex = 0 then
        UpdateConUI(mTsWork.MainCon);
end;

procedure TfrmPwrBurnishing.tmrDiskChkTimer(Sender: TObject);
begin
    inherited;
    DisplayDiskFree;
end;

procedure TfrmPwrBurnishing.tmrMainTimer(Sender: TObject);
var
    dTm: double;
    sTm: string;
begin

    if mIsClose then
        Exit;
    mLock := True;

    if Assigned(gWork) then
    begin
        gWork.SetUsrFileUpdates();
    end;

    case mState of
        0:
            begin
                labDate.Caption := FormatDateTime('ddddd hh:nn:ss', Now());
            end;
        1:
            begin
                ReadWorkCycleTime();
                if Assigned(gWork) then
                    lblMemory.Caption := gWork.GetUsrBuffCounts();
            end;
        2:
            begin
                if gsysEnv.rOP.rUseScreenSaver and Assigned(gWork) and (gWork.IsSystemIDLE <> mscrIO) then
                begin
                    mScrIO := gWork.IsSystemIDLE;
                    SetsysSaverEnable(integer(mScrIO));
                    if not mScrIO then
                    begin
                        SaverTurnOff;
                        gLog.Panel('SCREEN SET OFF');
                    end
                    else
                    begin
                        gLog.Panel('SCREEN SET ON');
                    end;
                end;
            end;
        3:
            begin
                SysEnvUpdates;
            end;
        4:
            begin
                if not mIsClose and Assigned(gWork) and (gWork.IsSystemIDLE <> mSysIdle) then
                begin
                    mSysIdle := gWork.IsSystemIDLE;
                end;
            end;
        5:
            begin

                // 오래된 그래프 파일 제거 2012.08.29
                if not mIsClose and (Now() > gsysEnv.rOP.rGraphCheckTimeStart) then
                begin

                    if gWork.IsSystemIDLE then
                    begin
                        try
                            if gsysEnv.rOP.rKeepGraphMonth > 0 then
                            begin
                                frmNotify.Caption := Caption + _TR(' 그래프 파일 정리 시작');
                                frmNotify.SetFrm(_TR('그래프 파일 정리중...'));
                                frmNotify.Show;

                                gLog.Panel('그래프 파일 정리 중...', []);
                                dTm := IncMonth(Now(), -gsysEnv.rOP.rKeepGraphMonth);
                                SetGraphFileDelete(dTm);
                                gLog.Panel('그래프 파일 정리 끝', []);
                            end;
                        finally
                            gsysEnv.rOP.rGraphCheckTimeStart := Trunc(Now() + 1) + Frac(gsysEnv.rOP.rGraphCheckTimeStart);
                            gsysEnv.rOP.rGraphCheckTimeEnd := Trunc(Now() + 1) + Frac(gsysEnv.rOP.rGraphCheckTimeEnd);
                            frmNotify.Close;
                        end;
                    end
                    else if (Now() > gsysEnv.rOP.rGraphCheckTimeEnd) then
                    begin
                        gsysEnv.rOP.rGraphCheckTimeStart := Trunc(Now() + 1) + Frac(gsysEnv.rOP.rGraphCheckTimeStart);
                        gsysEnv.rOP.rGraphCheckTimeEnd := Trunc(Now() + 1) + Frac(gsysEnv.rOP.rGraphCheckTimeEnd);
                    end;

                end;

            end;
        6:
            begin
                sTm := GetUsrFloatToStr(GetSeconds(gCycleTime[0]), 1);
                if MAX_ST_COUNT > 1 then
                begin
                    sTm := sTm + '  /  ';
                    sTm := sTm + GetUsrFloatToStr(GetSeconds(gCycleTime[1]), 1);
                end;

                if lblCycleTime.Caption <> sTm then
                begin
                    lblCycleTime.Caption := sTm;
                end;
            end;
    end;
    Inc(mState);
    mState := mState mod 7;
    mLock := False;

end;

procedure TfrmPwrBurnishing.tmrPollTimer(Sender: TObject);
begin
//    mSC.Add([mTsWork.GetMotorCurr(tmSlide), 0, 0, 0]);

    Inc(mDAQTimerCnt);
    if (mDAQTimerCnt mod 20) = 0 then   // 약 200 ms 예상
    begin
        ReadDAQValues;
    end
    else if (mDAQTimerCnt mod 50) = 0 then
    begin
        abCable.Checked := mTsWork.IsSpecChkOK;
    end;

end;

procedure TfrmPwrBurnishing.tmrShowTimer(Sender: TObject);
begin
    inherited;

    tmrShow.Enabled := false;

    ShowAllForms;

    if Assigned(gWork) then
        gWork.ComRefresh := True;

    { Thread Run }
    if gsysEnv.rOP.rEnabled and Assigned(gWork) then
        gWork.Start;

end;

procedure TfrmPwrBurnishing.UpdateConUI(Con: TBaseSeatConnector);
var
    i, ColCount, TotWidth: Integer;
const
    WidthRatios: array[0..3] of Double = (0.6, 3, 1, 1);
begin
    mCurCon := Con;

    lblConName.Caption := mCurCon.Name;

    ColCount := 2;

    if mCurCon.IsCurrReadable then
    begin
        sgCon.Cells[ColCount, 0] := '(A)';
        Inc(ColCount);
    end;
    if mCurCon.IsVoltReadable then
    begin
        sgCon.Cells[ColCount, 0] := '(V)';
        Inc(ColCount);
    end;

    sgCon.ColCount := ColCount;
    sgCon.RowCount := mCurCon.PinCount + 1;

    for i := 1 to sgCon.RowCount - 1 do
    begin
        sgCon.Cells[0, i] := IntToStr(i);
    end;

    SetGridColWidths(sgCon, WidthRatios);

    mCurCon.WriteAsPinName(sgCon.Cols[1], 1);

end;

procedure TfrmPwrBurnishing.UpdateGraph(IsClear: Boolean);

    function GetCommaPos(aValue: double; AUnit: integer): WORD;
    var
        i: integer;
        sTm: string;
    begin
        Result := 0;
        if Frac(aValue) = 0 then
            Exit;

        sTm := Format('%0.*f', [AUnit, aValue]);
        sTm := Copy(sTm, Pos('.', sTm) + 1, Length(sTm) - Pos('.', sTm));

        for i := Length(sTm) downto 1 do
        begin
            if sTm[i] <> '0' then
            begin
                Result := i;
                Break;
            end;
        end;
    end;

var
    i: integer;
    grpEnv: TFaGraphEnv;
begin

//    with chtMtr do
//    begin
//        grpEnv := GetGrpEnv(Tag);
//
//        if IsClear then
//        begin
//            mSC.Clear;
//        end;
//
//        LeftAxis.Minimum := grpEnv.rYMin;
//        LeftAxis.Maximum := grpEnv.rYMax;
//        LeftAxis.Increment := grpEnv.rYStep;
//
//        mXMax := grpEnv.rXMax - grpEnv.rXMin;
//        mSC.Start(mXMax);
//
//        for i := 0 to SeriesCount - 1 do
//        begin
//            Series[i].Visible := true;
//            Series[i].Color := grpEnv.rDataLine[i mod 8];
//        end;
//    end;
//
//    shpLegendSlide.Brush.Color := chtMtr.Series[0].Color;

end;

procedure TfrmPwrBurnishing.WorkClose(Sender: TObject);
begin
    gWork.Thread := nil;
    Close;
end;

procedure TfrmPwrBurnishing.WorkError(Sender: TObject);
begin
    gWork.Thread := nil;
    SetErrorTxt(Caption, '메인 프로세스 오류발생', '프로그램을 종료후 다시 실행하십시요!', umtError);

    mTsWork.ShowProcState;

    gWork.Stop;
end;

procedure TfrmPwrBurnishing.ReadCount;
var
    nOK, nNG: Integer;
begin
    nOK := GetResultCount(mFormIdx, True);
    nNG := GetResultCount(mFormIdx, false);
    lblOK.Caption := IntToStr(nOK);
    lblNG.Caption := IntToStr(nNG);
    lblTot.Caption := IntToStr(nOK + nNG);

end;

procedure TfrmPwrBurnishing.ReadDAQValues;
var
    SlideCurr, HgtCurr: Double;
begin
    with mTsWork do
    begin

        sgCon.Repaint;

        lblMotorCurr.Caption := Format('%0.1f', [GetMotorCurr(tmSlide)]);

    end;
end;

procedure TfrmPwrBurnishing.ReadWorkCycleTime;
const
    _HiNLo: array[false..true] of string = ('Lo ', 'Hi');
    _NorNIdle: array[false..true] of string = ('NOR ', 'IDLE');
var
    sTm: string;
begin
    if not Assigned(gWork) then
        Exit;
    sTm := Format('[P/C] %f >>%s | %s<< ', [gWork.LoopTime, _HiNLo[gWork.IsTesting], _NorNIdle[gWork.IsSystemIDLE]]);

    lblWorkMonitor.Caption := sTm;
end;

end.

