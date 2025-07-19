unit UserReferForm;

interface

uses
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, KiiMessages, ExtCtrls, Buttons, StdCtrls, BaseCan, BaseCounter,
    ReferenceForm;

type

    /// FormCreate의 Refer 순서에 따라 정의해야함.
    TfrmUserReferItem = (uriTest, uriPLC, uriPwrSpl, uriCANMonitor, uriCANFilter, uriAD, uriDIO, uriLAN, uriMotor, uriECU, uriTech);

    TfrmUserRefer = class(TForm)
        Panel1: TPanel;
        lbList: TListBox;
        pnlDock: TPanel;
        Panel4: TPanel;
        sbtnsave: TSpeedButton;
        Panel18: TPanel;
        sbtnClose: TSpeedButton;
        procedure FormClose(Sender: TObject; var Action: TCloseAction);
        procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
        procedure FormCreate(Sender: TObject);
        procedure FormDestroy(Sender: TObject);
        procedure FormShow(Sender: TObject);
        procedure sbtnsaveClick(Sender: TObject);
        procedure sbtnCloseClick(Sender: TObject);
        procedure lbListClick(Sender: TObject);
        procedure lbListDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
        procedure pnlTitleMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
        procedure lbListMeasureItem(Control: TWinControl; Index: Integer; var Height: Integer);
    private
        mHideItemList: TList;
        mReferItems: array of TfrmReferItem;

        function IsHideItem(Item: TfrmUserReferItem): Boolean;
        procedure InitializeList;
        procedure SeatMtrCtrlChange(Sender: TObject);
        procedure HVCtrlChange(Sender: TObject);
        { Private declarations }
    public
        { Public declarations }
        mLastIDx: Integer;
        mUsePwrSupply: Boolean;
        mFrmHandle: HWND;

        constructor Create(AOwner: TComponent); overload;
        constructor Create(AOwner: TComponent; const Items: array of TfrmUserReferItem); overload;
        constructor Create(AOwner: TComponent; const Items: array of TfrmUserReferItem; const frmReferItems: array of TfrmReferItem); overload;

        procedure Initial;
        procedure ReadMessage(var myMsg: TMessage); message WM_SYS_CODE;
        procedure OnUserEditChanged(Sender: TObject; AStatus: Integer);
    end;

var
    frmUserRefer: TfrmUserRefer;

implementation

uses
    DataUnit, myUtils, Log, ComsForm, LanSetupForm, Global, CanCtrlForm,
    SeatType, ModelType, IODef, CanOperForm, PowerSupplyForm, ADCheckForm,
    DioForm, LanIoUnit, ReferBaseForm, SeatMotorType, SeatMtrCtrlForm,
    TsWorkUnit, HVTester, TechSupportForm, BaseAD, ECUVerListForm, LangTran;
{$R *.dfm}

constructor TfrmUserRefer.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);
end;

constructor TfrmUserRefer.Create(AOwner: TComponent; const Items: array of TfrmUserReferItem);
var
    i: Integer;
begin
    inherited Create(AOwner);

    mHideItemList := TList.Create;

    for i := Low(Items) to High(Items) do
        mHideItemList.Add(Pointer(Items[i]));
end;

constructor TfrmUserRefer.Create(AOwner: TComponent; const Items: array of TfrmUserReferItem; const frmReferItems: array of TfrmReferItem);
var
    i: Integer;
begin
    inherited Create(AOwner);

    mHideItemList := TList.Create;

    for i := Low(Items) to High(Items) do
        mHideItemList.Add(Pointer(Items[i]));

    SetLength(mReferItems, Length(frmReferItems));
    for i := Low(frmReferItems) to High(frmReferItems) do
        mReferItems[i] := frmReferItems[i];
end;

procedure TfrmUserRefer.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    Action := CaFree;
    frmUserRefer := nil;
end;

procedure TfrmUserRefer.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
    SendMessage(mFrmHandle, WM_CLOSE, 0, 0);
end;

procedure TfrmUserRefer.FormCreate(Sender: TObject);
begin
    InitializeList();
    mLastIDx := 0;
    mFrmHandle := 0;
end;

procedure TfrmUserRefer.FormDestroy(Sender: TObject);
begin
    if Assigned(mHideItemList) then
        mHideItemList.Free;
end;

procedure TfrmUserRefer.FormShow(Sender: TObject);
begin
    Initial;
    TLangTran.ChangeCaption(self);
end;

procedure TfrmUserRefer.Initial;
begin
    SendMessage(mFrmHandle, WM_CLOSE, 0, 0);

    mLastIDx := 99;
    lbList.ItemIndex := 0;
    lbList.OnClick(Self);
end;

procedure TfrmUserRefer.InitializeList;
begin
    with lbList do
    begin
        Style := lbOwnerDrawVariable;
        ItemHeight := 70;
        Items.Add(_TR('시험 설정'));        // clTest
        Items.Add(_TR('PLC 연결설정'));     // clPLC
        Items.Add(_TR('파워 서플라이'));    // clPwrSpl
        Items.Add(_TR('CAN MONITORING'));   // clCANMonitor
        Items.Add(_TR('CAN MSG FILTER'));   // clCANFilter
        Items.Add(_TR('A/D 입력확인'));     // clAD
        Items.Add(_TR('DI/O 확인(DIO)'));   // clDIO
        Items.Add(_TR('DI/O 확인(LAN)'));   // clLAN
        Items.Add(_TR('모터 제어'));        // clMotor
        Items.Add('ECU INFO');              // clECU
        Items.Add(_TR('기술 지원'));        // clTech
    end;
end;

function TfrmUserRefer.IsHideItem(Item: TfrmUserReferItem): Boolean;
begin

    if not Assigned(mHideItemList) then
        Exit(False);

    Result := mHideItemList.IndexOf(Pointer(Item)) >= 0;
end;

type
    TMetaForm = class of TForm;

procedure TfrmUserRefer.lbListClick(Sender: TObject);
var
    nF: TForm;
    i: Integer;
    TsWork: TTsWork;
begin
    if IsHideItem(TfrmUserReferItem(lbList.ItemIndex)) then
        Exit;

    if mLastIDx <> lbList.ItemIndex then
    begin
        sbtnsave.Visible := false;
        SendMessage(mFrmHandle, WM_CLOSE, 0, 0);
        mFrmHandle := 0;
        case lbList.ItemIndex of
            0:
                begin
                    nF := TfrmReference.Create(self, mReferItems);
                    with nF as TfrmReference do
                    begin
                        Parent := pnlDock;
                        BorderStyle := bsNone;
                        Align := alClient;
                        mFrmHandle := Handle;

                        OnUserChange := OnUserEditChanged;
                        sbtnsave.Visible := true;
                        sbtnsave.Enabled := false;

                        Show;
                    end;
                end;
            1:
                begin
                    nF := TfrmLanSetup.Create(self);
                    with nF as TfrmLanSetup do
                    begin
                        Parent := pnlDock;
                        BorderStyle := bsNone;
                        Align := alClient;
                        mFrmHandle := Handle;

                        OnUserChange := OnUserEditChanged;
                        sbtnsave.Visible := true;
                        sbtnsave.Enabled := false;

                        Show;
                    end;
                end;
            2:
                begin
                    nF := TfrmPowerSuppy.Create(self, [gTsWork[0].Name]);
                    with nF as TfrmPowerSuppy do
                    begin
                        Parent := pnlDock;
                        BorderStyle := bsNone;
                        Align := alClient;
                        mFrmHandle := Handle;
                        // OnUserChange := OnUserEditChanged ;
                        // sbtnsave.Visible := true ;
                        // sbtnsave.Enabled := false ;
                        Show;
                    end;
                end;
            3:
                begin
                    if TfrmCanCtrl.mIsVisible then
                        nF := frmCanCtrl
                    else
                        nF := TfrmCanCtrl.Create(self);
                    with nF as TfrmCanCtrl do
                    begin
                        SetCAN(TBaseCAN.Items[0]);
                        Parent := pnlDock;
                        BorderStyle := bsNone;
                        Align := alClient;
                        mFrmHandle := Handle;

                        // OnUserChange := OnUserEditChanged ;
                        // sbtnsave.Visible := true ;
                        // sbtnsave.Enabled := false ;

                        Show;
                    end;
                end;
            4:
                begin
                    nF := TfrmCanOper.Create(self);
                    with nF as TfrmCanOper do
                    begin
                        SetCAN(TBaseCAN.Items[0]);
                        Parent := pnlDock;
                        BorderStyle := bsNone;
                        Align := alClient;
                        mFrmHandle := Handle;

                        Show;
                    end;
                end;
            5:
                begin
                    nF := TfrmADChecker.Create(self,
                        procedure(SatationIdx: Integer; var AD: TBaseAD; var CT: TBaseCounter)
                        begin
                            AD := gTsWork[SatationIdx].AD;
                        // CT := gTsWork[SatationIdx].CT
                        end);
                    with nF as TfrmADChecker do
                    begin
                        Parent := pnlDock;
                        BorderStyle := bsNone;
                        Align := alClient;
                        mFrmHandle := Handle;

                        Show;
                    end;
                end;
            6:
                begin
                    nF := TfrmDio.Create(self, ftDIO);
                    with nF as TfrmDio do
                    begin
                        for i := 0 to MAX_ST_COUNT - 1 do
                            AddDIO(gTsWork[i].DIO, 0, _DIO_CH_COUNT div 2, _DIO_CH_COUNT, gTsWork[i].Name);

                        Parent := pnlDock;
                        BorderStyle := bsNone;
                        Align := alClient;
                        mFrmHandle := Handle;

                        Show;
                    end;
                end;
            7:
                begin
                    nF := TfrmDio.Create(self, ftLIO);
                    with nF as TfrmDio do
                    begin
                        for i := 0 to MAX_ST_COUNT - 1 do
                        begin
                            AddDIO(gLanDIO, i * (_LAN_IO_CH_COUNT div 2 div 2), _LAN_IO_CH_COUNT div 2, _LAN_IO_CH_COUNT div 2, gTsWork[i].Name);
                        end;
                        WDataReadFunc := gLanDIO.GetDataIoAsWord;
                        Parent := pnlDock;
                        BorderStyle := bsNone;
                        Align := alClient;
                        mFrmHandle := Handle;

                        Show;
                    end;
                end;
            8:
                begin
                    with TfrmSeatMtrCtrl.Create(self) do
                    begin
                        GetStNamesNCarNames(cbxStation.Items, cbxCarType.Items);

                        Parent := pnlDock;
                        BorderStyle := bsNone;
                        Align := alClient;
                        mFrmHandle := Handle;
                        OnChange := SeatMtrCtrlChange;
                        // 폼 자체의 모델(MdlType) 선택에 따라 모터 설정도 변경하기 위해
                        Show;

                        // FormShow다음에 있어야 함. 코드 위치 변경 주의
                        TsWork := TTsWork(GetConnectedSt);
                        // 전극 접속된 공정의 모델 사양에 맞춰 Form을 설정
                        if TsWork = nil then
                            TsWork := TTsWork(gTsWork[0]);

                        MdlType := TsWork.CurModelType;
                        // Frm.InitMotors전에 디폴트값으로 사양 비트 설정 할 것
                        cbxStation.ItemIndex := Integer(TsWork.StationID);
                        // InitMotors([TsWork.Motors[tmRecl], TsWork.Motors[tmLSupt], TsWork.Motors[tmBolster]], TsWork.CAN);

                    end;
                end;
            9:
                begin
                    nF := TfrmECUVerList.Create(self);
                    with nF as TfrmECUVerList do
                    begin
                        // SetForm(gTsWork[0].ECUVerList);
                        Parent := self.pnlDock;
                        BorderStyle := bsNone;
                        Align := alClient;
                        mFrmHandle := Handle;

                        OnUserChange := OnUserEditChanged;
                        sbtnsave.Visible := true;
                        sbtnsave.Enabled := false;

                        Show;
                    end;
                end;
            10:
                begin
                    nF := TfrmTechSupport.Create(self);
                    with nF as TfrmTechSupport do
                    begin
                        Parent := pnlDock;
                        BorderStyle := bsNone;
                        Align := alClient;
                        mFrmHandle := Handle;

                        Show;
                    end;
                end;

        end;
        mLastIDx := lbList.ItemIndex;

    end;

end;

procedure TfrmUserRefer.HVCtrlChange(Sender: TObject);
begin

end;

procedure TfrmUserRefer.lbListDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
    bC: TColor;
    bkAlign, bkMode: Integer;
    sTm: string;
begin

    if IsHideItem(TfrmUserReferItem(Index)) then
        Exit;

    with Control as TListBox do
    begin
        bC := Canvas.Brush.Color;
        bkMode := GetBkColor(Canvas.Handle);
        bkAlign := GetTextAlign(Canvas.Handle);

        SetBkMode(Canvas.Handle, TRANSPARENT);
        SetTextAlign(Canvas.Handle, TA_CENTER + TA_TOP);

        Canvas.Font.Name := Font.Name;
        Canvas.Font.Height := Font.Height;

        sTm := Items.Strings[Index];

        // if (Index mod 2) = 0 then Canvas.Brush.Color := clGray
        // else                      Canvas.Brush.Color := clSilver ;
        if odSelected in State then
        begin
            Canvas.Pen.Color := clLime;
            Canvas.Brush.Color := clSilver;
        end
        else
        begin
            Canvas.Pen.Color := clSilver;
            Canvas.Brush.Color := clWhite;
        end;
        Canvas.FillRect(Rect);

        // Canvas.Pen.Color := clLime ;
        Canvas.Pen.Width := 2;
        Canvas.Brush.Style := bsClear;
        InflateRect(Rect, -1, -1);
        Canvas.Rectangle(Rect);

        // Canvas.Pen.Color := $00737373 ;

        Canvas.Font.Style := [fsBold];
        Canvas.TextOut(Rect.Left + (Rect.Right - Rect.Left) div 2, Rect.Top + (Rect.Bottom - Rect.Top) div 2 - Canvas.TextHeight('H') div 2, sTm);

        Canvas.Brush.Color := bC;
        SetTextAlign(Canvas.Handle, bkAlign);
        SetBkMode(Canvas.Handle, bkMode);
    end;
end;

procedure TfrmUserRefer.lbListMeasureItem(Control: TWinControl; Index: Integer; var Height: Integer);
begin
    if IsHideItem(TfrmUserReferItem(Index)) then
        Height := 0
    else
        Height := 70;
end;

procedure TfrmUserRefer.OnUserEditChanged(Sender: TObject; AStatus: Integer);
begin
    if not sbtnsave.Visible then
        Exit;
    sbtnsave.Enabled := AStatus = 1;
end;

procedure TfrmUserRefer.pnlTitleMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
    ReleaseCapture();
    PostMessage(Handle, WM_NCLBUTTONDOWN, HTCAPTION, 0);
end;

procedure TfrmUserRefer.ReadMessage(var myMsg: TMessage);
begin
    SendToForm(mFrmHandle, myMsg.WParam, myMsg.LParam);
end;

procedure TfrmUserRefer.sbtnCloseClick(Sender: TObject);
begin
    Close;
end;

procedure TfrmUserRefer.sbtnsaveClick(Sender: TObject);
begin
    SendToForm(mFrmHandle, SYS_SAVE_DATA, 0);
end;

procedure TfrmUserRefer.SeatMtrCtrlChange(Sender: TObject);
var
    Form: TfrmSeatMtrCtrl;
    TsWork: TTsWork;
begin

    Form := TfrmSeatMtrCtrl(Sender);
    TsWork := gTsWork[Form.cbxStation.ItemIndex];
    Form.MdlType := TsWork.CurModelType;
    // Form.InitMotors([TsWork.Motors[tmRecl], TsWork.Motors[tmLSupt]], TsWork.CAN); // Form에 재설정 -> UI 변경
end;

end.

