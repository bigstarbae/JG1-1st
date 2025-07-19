unit BaseMainForm;
{$I myDefine.inc}

interface

uses
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, ExtCtrls,
    _GClass, AbLED, Buttons, pngimage, ErrorForm,
    KiiMessages, EtherCatUnit,
    ModelInfoFrame, Label3D, Generics.Collections;

type
    TMsgType = (mtNotify, mtWarn, mtErr, mtQRCode);

    TComPortCount = 0..3;

    PDevComInfo = ^TDevComInfo;

    TDevComInfo = record
    private
        mID: Integer;
        mName: string;

        mPortNo: Integer;
        mOpenState: Boolean;
        mLed: TAbLED;

    public

        constructor Create(ID: Integer; Name: string);
        procedure Update;
    end;

    TfrmBaseMain = class;

    TBaseMainFormList = TList<TfrmBaseMain>;

    TfrmBaseMain = class(TForm)
        pnlTitle: TPanel;
        Shape1: TShape;
        pnlStatus: TPanel;
        labDate: TLabel;
        lblLanTitle: TLabel;
        pnlCommStatus: TPanel;
        Label2: TLabel;
        abCOM2: TAbLED;
        abPLC: TAbLED;
        abCOM1: TAbLED;
        pnlPLCStatus: TPanel;
        abLan1: TAbLED;
        abLan2: TAbLED;
        abLan3: TAbLED;
        pnlExtra: TPanel;
        pnlTop: TPanel;
        lblResult: TLabel3D;
        pnlBottom: TPanel;
        Label35: TLabel;
        pnlRTVals: TPanel;
        pnlLog: TPanel;
        Label3: TLabel;
        lbLog: TListBox;
        pnlWorkStatus: TPanel;
        lblStatus: TLabel3D;
        pnlWorkStatusTitle: TPanel;
        btnCanRDebug: TSpeedButton;
        btnCanWDebug: TSpeedButton;
        pnlPdtCnt: TPanel;
        Panel3: TPanel;
        lblOK: TLabel;
        Label4: TLabel;
        Panel6: TPanel;
        lblNG: TLabel;
        Label8: TLabel;
        Panel4: TPanel;
        lblTot: TLabel;
        Label5: TLabel;
        abCOM3: TAbLED;
        pnlSysStatus: TPanel;
        abCable: TAbLED;
        abPop: TAbLED;
        pnlMsg: TPanel;
        imgMsg: TImage;
        imgIcon: TImage;
        pnlMsgTitle: TPanel;
        sbtnErrorClose: TSpeedButton;
        Image1: TImage;
        lblMode: TLabel3D;
        abECat: TAbLED;
        pnlMenu: TPanel;
        sbtnModel: TSpeedButton;
        sbtnReference: TSpeedButton;
        sbtnRetrieve: TSpeedButton;
        sbtnExit: TSpeedButton;
        lblVer: TLabel;
        abCAN: TAbLED;
        lblSimLanInMode: TLabel3D;
    tmrHideMsg: TTimer;
        procedure FormClose(Sender: TObject; var Action: TCloseAction);
        procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
        procedure FormCreate(Sender: TObject);
        procedure FormShow(Sender: TObject);
        procedure labDateDblClick(Sender: TObject);
        procedure pnlTitleDblClick(Sender: TObject);
        procedure pnlTitleClick(Sender: TObject);

        procedure Image1Click(Sender: TObject);
        procedure pnlTitleMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
        procedure pnlTitleMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
        procedure pnlTitleMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
        procedure lbLogDblClick(Sender: TObject);
        procedure sbtnErrorCloseClick(Sender: TObject);
        procedure pnlMsgTitleMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);


    private
        class function GetForms(FormIdx: integer): TfrmBaseMain; static;

    protected
        { Private declarations }

        mIsClose: Boolean;
        mMsgType: TMsgType;
        mFormIdx: Integer;

        mDoubleClicked, mFormDragging: Boolean;
        mDragStartPos: TPoint;

        // Comport 관리
        mDevComInfos: array[TComPortCount] of TDevComInfo;

        mErrorForm: TfrmError;

        class var
            mForms: TBaseMainFormList;

        function IsMainForm: Boolean;

        function GetDevComInfoByID(ID: Integer): PDevComInfo;      // ID로 찾기
        function GetDevComInfoByPortNo(PortNo: Integer): PDevComInfo;    // PortNo로 찾기

        // 통신 UI
        procedure UpdateDevComInfos;
        procedure UpdateLanPortStatus;
        procedure UpdateECatStatus(AStatus: TECStatus);

        // 윈도우 메시지 처리
        procedure ReadMessage(var myMsg: TMessage); message WM_SYS_CODE;

        procedure HandleReadMessage(var myMsg: TMessage); virtual; abstract;        // ▒▒ 자손 필수 구현 ▒▒
        procedure OnWorkStatus(AStatus: Integer); virtual; abstract;                // UI갱신 위주의 tw_XXX 처리용

        // 예외 처리
        procedure GlobalExceptionHandler(Sender: TObject; E: Exception);

        // 알림 메시지
        procedure DisplayMsg(aMsg, aToDo: string; MsgType: TMsgType = mtNotify; URL: string = '');
        procedure HideMsg;

    public
        { Public declarations }
        procedure AddDevComInfo(ID: Integer; Name: string);
        procedure ShowPLCInfo(Show: Boolean);

        // 서브폼 관리

        class function AddSubForm(SubForm: TfrmBaseMain): TfrmBaseMain;
        class procedure SendToSubForms(var Msg: TMessage);
        class procedure ShowAllForms;

        class property Forms[FormIdx: integer]: TfrmBaseMain read GetForms;
    end;

var
    frmBaseMain: TfrmBaseMain;

implementation

uses
    Shellapi, Math, Global, VerUnit, Log, UserSocketUnit,  LanIoUnit,
    FormUtils, myUtils, Work, BaseTsWork, SysEnv,
    DioReferForm, PasswdForm, GIFImg, MsgData, IniFiles,
    ModelSelSimForm, StateViewForm, IODef, LangTran;

{$R *.dfm}

const
    MAX_LAN_LED_COUNT = 3;

var
    // 중복실행방지
    Mutex: THandle;

    // Lan : 기존 전역 관리, 레거시 수정 필요
    lpPortList: array[0..MAX_LAN_LED_COUNT - 1] of integer;
    lpPortType: array[0..MAX_LAN_LED_COUNT - 1] of integer;
    lpPortLed: array[0..MAX_LAN_LED_COUNT - 1] of TAbLED;


procedure SavePanelPos(APanel: TPanel; const AIniFileName: string);
var
    Ini: TIniFile;
begin
    Ini := TIniFile.Create(AIniFileName);
    try
        Ini.WriteInteger(APanel.Name, 'Left', APanel.Left);
        Ini.WriteInteger(APanel.Name, 'Top', APanel.Top);
    finally
        Ini.Free;
    end;
end;

procedure LoadPanelPos(APanel: TPanel; const AIniFileName: string);
var
    Ini: TIniFile;
    L, T: Integer;
begin
    Ini := TIniFile.Create(AIniFileName);
    try
        L := Ini.ReadInteger(APanel.Name, 'Left', APanel.Left);
        T := Ini.ReadInteger(APanel.Name, 'Top', APanel.Top);
        APanel.Left := L;
        APanel.Top := T;
    finally
        Ini.Free;
    end;
end;

procedure LoadPortLists;
var
    i: integer;
    IsHexVal: Boolean;
begin
    FillChar(lpPortList, sizeof(lpPortList), 0);
    FillChar(lpPortType, sizeof(lpPortType), 0);

    for i := 0 to MAX_LAN_LED_COUNT - 1 do
    begin
        lpPortLed[i].Checked := false;
        if not GetLoadPortUse(i + 1) then
            Continue;

        lpPortList[i] := GetLoadPort(i + 1, IsHexVal);
        lpPortType[i] := GetLoadPortType(i + 1);
    end;
end;

procedure DisplayStatus(AIndex, APort, AStatus: Word);
const
    _LAN_STATUS: array[1..5] of TColor = (clRed, clYellow, clMoneyGreen, clBlue, clLime);
begin
    if not (AIndex in [1..10]) then
        Exit; // or gWork.IsTesting then Exit ;
    if (lpPortList[AIndex - 1] = APort) and (APort > 0) then
    begin
        if lpPortLed[AIndex - 1].Checked <> (AStatus in [1..5]) then
        begin
            lpPortLed[AIndex - 1].Checked := AStatus in [1..5];
        end;
        if (AStatus in [1..5]) and (lpPortLed[AIndex - 1].LED.ColorOn <> _LAN_STATUS[AStatus]) then
        begin
            lpPortLed[AIndex - 1].LED.ColorOn := _LAN_STATUS[AStatus];
        end;
    end;
end;


procedure TfrmBaseMain.AddDevComInfo(ID: Integer; Name: string);
var
    i: Integer;
    LedCtrl: TAbLED;
begin

    for i := 0 to High(TComPortCount) do
    begin
        LedCtrl := TAbLED(FindComponent('abCOM' + IntToStr(i + 1)));

        if (LedCtrl <> nil) and (mDevComInfos[i].mLed = nil) then
        begin
            mDevComInfos[i].mID := ID;
            mDevComInfos[i].mName := Name;
            mDevComInfos[i].mLed := LedCtrl;
            mDevComInfos[i].mLed.Visible := True;
            UpdateDevComInfos;
            break;
        end;
    end;

end;

class function TfrmBaseMain.AddSubForm(SubForm: TfrmBaseMain): TfrmBaseMain;
begin

    SubForm.mFormIdx := mForms.Count;        // MainForm이 mFormIdx: 0
    mForms.Add(SubForm);

    if SubForm.mFormIdx >= 1 then
    begin
        SubForm.Left := mForms[SubForm.mFormIdx - 1].Width;
    end;

    SubForm.Show;

    Result := SubForm;
end;


//  TECStatus = (ecsStart, ecsRun, ecsStop, ecsError, ecsRetry, ecsErrRetry, ecsModuleErr, ecsNone);
procedure TfrmBaseMain.UpdateECatStatus(AStatus: TECStatus);
begin
    abECat.Checked := True;

    case AStatus of
        ecsStart,
        ecsRun:
            abECat.LED.ColorOn := clLime;
        ecsStop:
            abECat.LED.ColorOn := clWebPink;
        ecsError,
        ecsModuleErr:
            abECat.LED.ColorOn := clRed;
        ecsRetry,
        ecsErrRetry:
            abECat.LED.ColorOn := $004080FF;
        ecsNone:
            abECat.LED.ColorOn := clBtnFace;
    end;
end;

procedure TfrmBaseMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    //
    SavePanelPos(pnlMsg, GetEnvPath('UIPos.ini'));
end;

procedure TfrmBaseMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin

    mIsClose := true;

end;

procedure TfrmBaseMain.FormCreate(Sender: TObject);
begin
//    WindowState := wsMaximized;

    mErrorForm := TfrmError.Create(Self);

    if mForms.Count = 0 then
    begin
        mFormIdx := 0;
        mForms.Add(Self);
    end;

    LoadPanelPos(pnlMsg, GetEnvPath('UIPos.ini'));

end;

procedure TfrmBaseMain.FormShow(Sender: TObject);
begin

    lpPortLed[0] := abLan1;
    lpPortLed[1] := abLan2;
    lpPortLed[2] := abLan3;
    LoadPortLists;

    if IsMainForm then
        gLog.LogHandle := lbLog.Handle
    else
        gLog.SubHandle := lbLog.Handle;

    lblVer.Caption := 'V.' + gSysEnv.rOP.rVer;

    if IsFontInstalled('바른공군체 Medium') then
    begin
        ChangeFontsInPanel(pnlTitle, '바른공군체 Medium');
        imgMsg.Canvas.Font.Name := '바른공군체 Medium';
    end
    else
    begin
        imgMsg.Canvas.Font.Name := '맑은 고딕';
    end;

    lblSimLanInMode.Align := alClient;

    TLangTran.ChangeCaption(Self);
end;

procedure TfrmBaseMain.Image1Click(Sender: TObject);
begin
    gWork.ComRefresh := true;
end;

function TfrmBaseMain.IsMainForm: Boolean;
begin
    Result := mFormIdx = 0;
end;



var
    gDummyPortInfo: TDevComInfo;

function TfrmBaseMain.GetDevComInfoByID(ID: Integer): PDevComInfo;
var
    i: Integer;
begin
    for i := 0 to High(TComPortCount) do
    begin
        if mDevComInfos[i].mID = ID then
        begin
            Exit(@mDevComInfos[i]);
        end;
    end;

    Result := @gDummyPortInfo;

end;

function TfrmBaseMain.GetDevComInfoByPortNo(PortNo: Integer): PDevComInfo;
var
    i: Integer;
begin
    Result := @gDummyPortInfo;

    if (PortNo <= 0) or (PortNo > High(TComPortCount)) then
    begin
        raise EListError.CreateFmt('TfrmBaseMain.GetDevComInfoByPortNo: PortNo %d가 범위 벗어남', [PortNo]);
        Exit;
    end;

    for i := 0 to High(TComPortCount) do
    begin
        if mDevComInfos[i].mPortNo = PortNo then
        begin
            Exit(@mDevComInfos[i]);
        end;
    end;

end;

class function TfrmBaseMain.GetForms(FormIdx: integer): TfrmBaseMain;
begin
    if FormIdx < mForms.Count then
        Result := mForms[FormIdx]
    else
        raise EListError.CreateFmt('TfrmBaseMain.GetForms: FormIdx %d가 범위 벗어남 (0..%d)', [FormIdx, mForms.Count - 1]);
end;

procedure TfrmBaseMain.GlobalExceptionHandler(Sender: TObject; E: Exception);
begin
    gLog.Error('예외 발생: %s', [E.Message]);
    if E.StackTrace <> '' then         // 유레카 로그 활성화한 경우 StackTrace 가능
        gLog.Error('호출 경로: %s', [E.StackTrace]);

    Application.ShowException(E);
end;

procedure TfrmBaseMain.ReadMessage(var myMsg: TMessage);
begin

    if mIsClose then
        Exit;

    if myMsg.WParam < SYS_CODE then // WParam에 SYS_CODE이하이면 tw_XXX계열 처리
    begin
        OnWorkStatus(myMsg.WParam);
        Exit;
    end;

    case myMsg.WParam of

        SYS_TS_PROCESS:
            begin
                OnWorkStatus(myMsg.LParam);
            end;

        SYS_CLOSE:
            Close;

        SYS_BASE:
            begin
                SetsysSaverEnable(integer(gsysEnv.rOP.rUseScreenSaver));
                ;
                if not Assigned(gWork) then
                    Exit;
                gWork.Reset;
            end;
        SYS_PORT:
            begin
                gWork.ComRefresh := true;
            end;
        SYS_USERCOM:
            begin
                // Device ID : LParamHi Device Port : LParamLo
                GetDevComInfoByID(myMsg.LParamHi).mPortNo := myMsg.LParamLo;
                UpdateDevComInfos;

            end;
        SYS_PORT_NOTIFY: // Open/Close
            begin
                // Com PortNo : LParamHi  OPEN/CLOE : LParamLo
                GetDevComInfoByPortNo(myMsg.LParamHi).mOpenState := myMsg.LParamLo = 1;
                UpdateDevComInfos;

            end;
        SYS_VISIBLE_LOG:
            begin
                Exit;
            end;
        SYS_UPDATES, SYS_COUNT_UPDATES:
            begin
            end;
        // ----------------------------
        SYS_CONNECTED: // TCP/IP
            begin
                // _TR('연결됨')
                DisplayStatus(myMsg.LParamHi, myMsg.LParamLo, 5); // 'OPEN') ;
                UpdateLanPortStatus;
            end;
        SYS_CONNECTING: // TCP/IP
            begin
                // _TR('접속중')
                DisplayStatus(myMsg.LParamHi, myMsg.LParamLo, 2); // 'CON...') ;
            end;
        SYS_DISCONNECTED: // TCP/IP
            begin
                // _TR('끊어짐')
                DisplayStatus(myMsg.LParamHi, myMsg.LParamLo, 0); // 'CLOSE') ;
                UpdateLanPortStatus;
            end;
        SYS_TCP_ERROR: // TCP/IP
            begin
                DisplayStatus(myMsg.LParamHi, myMsg.LParamLo, 1); // 'ER') ;
                UpdateLanPortStatus;
            end;
        SYS_TCP_READ: // TCP/IP
            begin
                // _TR('수신')
                DisplayStatus(myMsg.LParamHi, myMsg.LParamLo, 4); // 'RD') ;
            end;
        SYS_TCP_WRITE: // TCP/IP
            begin
                // _TR('송신')
                DisplayStatus(myMsg.LParamHi, myMsg.LParamLo, 3); // 'WD') ;
            end;
        SYS_POP_READY: // TCP/IP
            begin
                // _TR('대기')
                DisplayStatus(myMsg.LParamHi, myMsg.LParamLo, 5); // 'RDY') ;
            end;
        SYS_RCV_ERROR: // PLC 무응답 처리.
            begin
                DisplayStatus(myMsg.LParamHi, myMsg.LParamLo, 1); // _TR('무응답')) ;
                UpdateLanPortStatus;
            end;
        SYS_PLC_ERROR: // 에러코드 수신 - 상세한 코드와 처리방법 메시지 처리.
            begin
                UpdateLanPortStatus;
            end;
        SYS_LAN_PORT_CHANGED:
            begin
                gLog.Panel('Recieved Lan Port Changed!', []);
                LoadPortLists;
                UpdateLanPortStatus;
            end;
        // ----------------------------
        SYS_PORT_END:
            begin
                gWork.Reset();
            end;

        SYS_ECAT_STATUS:
            begin
                UpdateECatStatus(TECStatus(MyMsg.LParam));
            end;
        // ----------------------------
        SYS_MSG_ERR:
            begin
                mErrorForm.SetFrm(gMsgData.mCaption, gMsgData.mMsg1 + #13 + gMsgData.mMsg2, gMsgData.mTime, True, gMsgData.mDlgType);
            end;
    end;

    HandleReadMessage(myMsg);

    if IsMainForm then
        SendToSubForms(myMsg);
end;

procedure TfrmBaseMain.sbtnErrorCloseClick(Sender: TObject);
begin
    pnlMsg.Visible := False;
end;

procedure TfrmBaseMain.UpdateLanPortStatus;
begin
    with gSocketMan do
    begin
        if (IsOpenPort(ord(devREAD)) > 0) and (IsOpenPort(ord(devWRITE)) > 0) then
        begin
            abPLC.LED.ColorOn := clLime;
            abPLC.Checked := true;
        end
        else
        begin
            abPLC.LED.ColorOn := clRed;
            abPLC.Checked := true;
        end;
    end;
end;

procedure TfrmBaseMain.UpdateDevComInfos;
var
    i: Integer;
begin

    for i := 0 to Length(mDevComInfos) - 1 do
    begin
        mDevComInfos[i].Update;
    end;
end;

procedure TfrmBaseMain.labDateDblClick(Sender: TObject);
begin
    gLog.Updates();
end;

procedure TfrmBaseMain.lbLogDblClick(Sender: TObject);
begin
    gLog.ShowCurLogFile(lbLog.Handle);
end;

procedure TfrmBaseMain.pnlMsgTitleMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
    ReleaseCapture;
    (TPanel(Sender)).Parent.Perform(WM_SYSCOMMAND, $F012, 0);
end;

procedure TfrmBaseMain.pnlTitleClick(Sender: TObject);
begin
    //
end;

procedure TfrmBaseMain.pnlTitleDblClick(Sender: TObject);
begin
    mDoubleClicked := True;

    if IsMainForm then
    begin
        Left := 0;
        gTsWorks.Items[0].ShowProcState;
    end
    else
    begin
        if mForms.Count > 1 then
        begin
            Left := mForms[mFormIdx - 1].Width;
            gTsWorks.Items[1].ShowProcState;
        end;
    end;

    Top := 0;

    gLog.Updates();

end;

procedure TfrmBaseMain.pnlTitleMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
    if mDoubleClicked then
    begin
        mDoubleClicked := False;
        Exit;
    end;

    if Button = mbLeft then
    begin
        mFormDragging := True;
        mDragStartPos := Point(X, Y);
    end;

end;

procedure TfrmBaseMain.pnlTitleMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
    dx, dy: Integer;
begin
    if mFormDragging then
    begin
        dx := X - mDragStartPos.X;
        dy := Y - mDragStartPos.Y;
        Left := Left + dx;
        Top := Top + dy;
    end;

end;

procedure TfrmBaseMain.pnlTitleMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
    mFormDragging := False;
end;

procedure DrawWarningLines(Canvas: TCanvas; const Rect: TRect; const StepSize: Integer);
var
    i, Top: Integer;
    Points: array[0..3] of TPoint;
    CurrentColor: TColor;
begin
    with Canvas do
    begin
        // 상단 경고 사선 그리기
        for i := 0 to (Rect.Right div StepSize) do
        begin
            if i mod 2 = 0 then
                CurrentColor := clYellow
            else
                CurrentColor := clBlack;

            Brush.Color := CurrentColor;
            Brush.Style := bsSolid;
            //Pen.Color := CurrentColor;

            Points[0] := Point(i * StepSize, Rect.Top);
            Points[1] := Point((i + 1) * StepSize, Rect.Top);
            Points[2] := Point(i * StepSize, Rect.Top + StepSize);
            Points[3] := Point((i - 1) * StepSize, Rect.Top + StepSize);

            Polygon(Points);
        end;

        Top := Rect.Bottom - StepSize;
        // 하단 경고 사선 그리기
        for i := 0 to (Rect.Right div StepSize) do
        begin
            if i mod 2 = 0 then
                CurrentColor := clYellow
            else
                CurrentColor := clBlack;

            Brush.Color := CurrentColor;
            Brush.Style := bsSolid;
            //Pen.Color := CurrentColor;

            Points[0] := Point(i * StepSize, Top);
            Points[1] := Point((i + 1) * StepSize, Top);
            Points[2] := Point(i * StepSize, Top + StepSize);
            Points[3] := Point((i - 1) * StepSize, Top + StepSize);

            Polygon(Points);
        end;
    end;
end;

class procedure TfrmBaseMain.SendToSubForms(var Msg: TMessage);
var
    i: Integer;
begin
    for i := 1 to mForms.Count - 1 do
        SendToForm(mForms[i].Handle, Msg.WParam, Msg.LParam);
end;

class procedure TfrmBaseMain.ShowAllForms;
var
    i: Integer;
begin
    mForms[0].Left := 0;
    mForms[0].Top := 0;

    for i := 1 to mForms.Count - 1 do
    begin
        mForms[i].Left := mForms[i - 1].Width;
        mForms[i].Top := 0;
    end;
end;

procedure TfrmBaseMain.ShowPLCInfo(Show: Boolean);
var
    Leds: array[0 .. 2] of TAbLED;
    i: Integer;
begin
    lblLanTitle.Visible := Show;
    pnlPLCStatus.Visible := Show;

    Leds[0] := abPLC;
    Leds[1] := abECAT;
    Leds[2] := abCAN;

    abPLC.Visible := Show;


    if Show then
    begin
        abECAT.Left := 111;
        abCAN.Left := 184;
    end
    else
    begin
        abECAT.Left := 49;
        abCAN.Left := 111;
    end;

end;

procedure TfrmBaseMain.DisplayMsg(aMsg, aToDo: string; MsgType: TMsgType; URL: string);
var
    LPos, nH, nW: Integer;
    BkColor, TextColor: TColor;
    ToDoRect: TRect;
begin

    tmrHideMsg.Enabled := False;

    if (aMsg = '') and (aToDo = '') then
    begin
        aMsg := 'ERROR';
        aToDo := '장비를 점검 하세요';
      //  Exit
    end;

    imgIcon.Visible := false;
    TextColor := clBlack;
    BkColor := clInfoBk;

    aMsg := _TRE(aMsg);
    aToDo := _TRE(aToDo);

    mMsgType := MsgType;

    if URL <> '' then
    begin
        if FileExists(URL) then
        begin
            imgIcon.Picture.LoadFromFile(URL);

            if Assigned(imgIcon.Picture.Graphic) then
            begin
                imgIcon.Visible := True;

                if (imgIcon.Picture.Graphic is TGIFImage) then
                begin
                    with imgIcon.Picture.Graphic as TGIFImage do
                    begin
                        Animate := True;
                        AnimationSpeed := 100;
                    end;
                end;
            end;

        end

    end;

    case MsgType of
        mtNotify:  // 알림
            begin
                pnlMsgTitle.Caption := _TR('알림');
                pnlMsgTitle.Font.Color := clYellow;
                TextColor := clBlue;
            end;
        mtWarn:
            begin
                pnlMsgTitle.Caption := _TR('경고');
                pnlMsgTitle.Font.Color := clYellow;//$000080FF;
                TextColor := $000080FF;//clBlue;
                BkColor := clInfoBk;
            end;

        mtErr:
            begin
                pnlMsgTitle.Caption := _TR('ERROR 발생');
                pnlMsgTitle.Font.Color := $000080FF;
                TextColor := clRed;
            end;

        mtQRCode: // QR Code 표시
            begin
                imgIcon.Visible := True;
                DrawQRCode(imgIcon, URL);
            end;
    end;

    with imgMsg do
    begin
        Canvas.Brush.Color := BkColor;
        Canvas.FillRect(ClientRect);

        if MsgType in [mtWarn, mtErr] then
            DrawWarningLines(Canvas, ClientRect, 8);

        SetBkMode(Canvas.Handle, Windows.TRANSPARENT);

//        Canvas.Font.Name := '굴림';
        Canvas.Font.Size := 32;
        Canvas.Font.Color := TextColor;
        Canvas.Font.Style := [fsBold];

        if imgIcon.Visible then
            LPos := imgIcon.Left + imgIcon.Width + 6
        else
            LPos := ClientRect.Left;

        nW := ClientRect.Right - LPos;
        nH := (ClientRect.Bottom - ClientRect.Top) div 3;

        while Canvas.TextWidth(aMsg) > nW do
        begin
            Canvas.Font.Size := Canvas.Font.Size - 1;
            if Canvas.Font.Size <= 0 then
                break;
        end;

        SetTextAlign(Canvas.Handle, TA_CENTER or TA_TOP);
        Canvas.TextOut(LPos + nW div 2, ClientRect.Top + nH - Canvas.TextHeight('H') div 2, aMsg);

        Canvas.Font.Size := 20;
        Canvas.Font.Color := clGray;

        if Pos(sLineBreak, aToDo) > 0 then
        begin
            ToDoRect := ClientRect;
            ToDoRect.Left := LPos;
            ToDoRect.Top := ClientRect.Top + nH * 2;
            InflateRect(ToDoRect, -20, -20);
            DrawTextInRect(Canvas, ToDoRect, aToDo, Canvas.Font.Size);
        end
        else
        begin

            while Canvas.TextWidth(aToDo) > nW do
            begin
                Canvas.Font.Size := Canvas.Font.Size - 1;
                if Canvas.Font.Size <= 0 then
                    break;
            end;

            Canvas.TextOut(LPos + nW div 2, ClientRect.Top + nH * 2 + nH div 2 - Canvas.TextHeight('H') div 2, aToDo);
        end;
    end;

  //  if not pnlMsg.Visible then
    begin
        pnlMsg.Visible := True;
        pnlMsg.BringToFront;
    end;

    gLog.Debug('DisplayMsg:%s', [AMsg]);
end;

procedure TfrmBaseMain.HideMsg;
begin
    if not pnlMsg.Visible then
        Exit;

    pnlMsg.Visible := false;
end;

{ TDevComInfo }

constructor TDevComInfo.Create(ID: Integer; Name: string);
begin
    mID := ID;
    mName := Name;
end;

procedure TDevComInfo.Update;
begin
    if mLed = nil then
        Exit;

    if mPortNo = 0 then
    begin
        mLed.Caption := Format(_TR('%s 지정안됨'), [mName]);
        Exit;
    end
    else
    begin
        mLed.Caption := Format('%s(COM%d)', [mName, mPortNo]);
    end;

    mLed.Checked := mOpenState;
end;


initialization
    Mutex := CreateMutex(nil, true, PChar(PROJECT_NAME));
    if GetLastError = ERROR_ALREADY_EXISTS then
    begin
        with Application do
            MessageBox(PChar(PROJECT_NAME + _TR(' 프로그램이 실행중입니다.')), PChar(PROJECT_NAME + _TR(' 프로그램')), MB_ICONSTOP + MB_OK);
        Halt; // kill the second instance
    end;

    TfrmBaseMain.mForms := TBaseMainFormList.Create;

    gLog := TLog.Create(0, 2, True);

finalization // alt end free the mHandle

    if Mutex <> 0 then
        CloseHandle(Mutex);

    TfrmBaseMain.mForms.Free;

    if Assigned(gLog) then
        FreeAndNil(gLog);

end.

