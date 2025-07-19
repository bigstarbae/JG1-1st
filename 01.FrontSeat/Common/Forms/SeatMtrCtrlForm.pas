{
  Ver.210223.00
}
unit SeatMtrCtrlForm;

interface

uses
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, pngextra, StdCtrls, DSGroupBox, _GClass, AbLED, pngimage, ExtCtrls, AbSwitch, TeEngine, Series, TeeProcs, Chart,
    TimeChecker, TeeChartUtil, SeatMotor, SeatMotorType, DataUnit, SeatType, BaseCAN, ModelType;

type

    TMtrJogUI = record
        mCurrLbl: TLabel;

        procedure Find(Parent: TComponent; Suffix: string);
        procedure SetVisible(Value: boolean);
        procedure DisablePosLbl;

        procedure Update(Mtr: TSeatMotor);

    case Integer of
        0:
        (
            mFwLed, mBwLed: TAbLed;
        );
        1:
        (
            mUpLed, mDnLed: TAbLed;
        )

    end;

    TSMCNotifyEvent = procedure(StationID: TStationID; CarType: TCAR_TYPE) of object;

    TfrmSeatMtrCtrl = class(TForm)
        Panel2: TPanel;
        Panel3: TPanel;
        cbxStation: TComboBox;
        cbxCarType: TComboBox;
        Splitter1: TSplitter;
        pnlCANFrame: TPanel;
        tmrPoll: TTimer;
        cbxPosType: TComboBox;
        Panel1: TPanel;
        pnlMtrJog: TPanel;
        ledBwRecl: TAbLED;
        ledFwRecl: TAbLED;
        lblCurrRecl: TLabel;
        ledBwLSupt: TAbLED;
        lblCurrLSupt: TLabel;
        ledFwLSupt: TAbLED;
        ledBwBolster: TAbLED;
        lblCurrBolster: TLabel;
        ledFwBolster: TAbLED;
        lblCaption: TLabel;
        Label3: TLabel;
        Label4: TLabel;
        procedure FormCreate(Sender: TObject);
        procedure pnlCANFrameUnDock(Sender: TObject; Client: TControl; NewTarget: TWinControl; var Allow: boolean);
        procedure pnlCANFrameDockDrop(Sender: TObject; Source: TDragDockObject; X, Y: Integer);
        procedure FormClose(Sender: TObject; var Action: TCloseAction);
        procedure FormShow(Sender: TObject);
        procedure tmrPollTimer(Sender: TObject);
        procedure cbxStationChange(Sender: TObject);
        procedure ledFwReclMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
        procedure ledFwReclMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
        procedure ledBwReclMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    private
        { Private declarations }
        mMotors: array [0 .. 5] of TSeatMotor;
        mMtrJogUI: array [TMotorOrd] of TMtrJogUI;

        mTotMtrCount: Integer;

        mCAN: TBaseCAN;

        mIsIMS: boolean;

        mEnableChangeEvent, mLock: boolean;

        mMdlType: TModelType;

        mTC: TTimeChecker;
        mCANWState: Integer;

        mOnChange: TNotifyEvent;
        procedure CanRead(Sender: TObject);
        procedure SetMdlType(const Value: TModelType);
        procedure EnableETCGroupBox(Gbx: TDSGroupBox; Enabled: boolean);

    public
        { Public declarations }
        procedure Init(StationNames: array of string; CarNames: array of string);
        procedure InitMotors(Mtrs: array of TSeatMotor; CAN: TBaseCAN);

        property OnChange: TNotifyEvent read mOnChange write mOnChange;

        property MdlType: TModelType read mMdlType write SetMdlType;
    end;

var
    frmSeatMtrCtrl: TfrmSeatMtrCtrl;

implementation

uses
    CanCtrlForm, Log, AsyncCalls, LangTran;
{$R *.dfm}

procedure TfrmSeatMtrCtrl.FormCreate(Sender: TObject);
begin

    // mSC.FixYRange := true;    // bug TO DO

    if not TfrmCanCtrl.mIsVisible then
        frmCanCtrl := TfrmCanCtrl.Create(nil, mCAN);

    frmCanCtrl.ManualDock(pnlCANFrame);
    frmCanCtrl.Show;

    mEnableChangeEvent := true;

end;

procedure TfrmSeatMtrCtrl.FormShow(Sender: TObject);
begin

    mMtrJogUI[tmSlide].Find(Self, 'Recl');
    mMtrJogUI[tmTilt].Find(Self, 'LSupt');
    mMtrJogUI[tmHeight].Find(Self, 'Bolster');

    cbxStation.ItemIndex := 0;
    cbxCarType.ItemIndex := 0;
    cbxPosType.ItemIndex := 0;


    TLangTran.ChangeCaption(Self);
end;

procedure TfrmSeatMtrCtrl.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    mLock := true;

    if TfrmCanCtrl.mIsVisible then
        frmCanCtrl.Close;

    tmrPoll.Enabled := false;

    if Assigned(mCAN) then
        mCAN.OnRead.Remove(CanRead);

end;

procedure EnableDSGroupBox(Gbx: TDSGroupBox; Enabled: boolean);
begin
    Gbx.Enabled := Enabled;

    if Enabled then
    begin
        Gbx.BorderColor := $0053362C;
    end
    else
    begin
        Gbx.BorderColor := clSilver;
    end;
end;

procedure TfrmSeatMtrCtrl.EnableETCGroupBox(Gbx: TDSGroupBox; Enabled: boolean);
begin


end;

procedure TfrmSeatMtrCtrl.Init(StationNames, CarNames: array of string);
var
    i: Integer;
begin
    cbxStation.Items.Clear;
    for i := 0 to Length(StationNames) - 1 do
        cbxStation.Items.Add(StationNames[i]);

    cbxCarType.Items.Clear;
    for i := 0 to Length(CarNames) - 1 do
        cbxCarType.Items.Add(CarNames[i]);
end;

procedure TfrmSeatMtrCtrl.InitMotors(Mtrs: array of TSeatMotor; CAN: TBaseCAN);
var
    i: Integer;
    IMSCtrler: TBaseIMSCtrler;
    MtrIt: TMotorOrd;

    function IsMtrExists: boolean;
    begin
        case mMotors[i].ID of
            tmSlide:
                Result := true;
            tmTilt:
                Result := mMdlType.Is2Cell or mMdlType.Is7Cell;
            tmHeight:
                Result := mMdlType.Is7Cell;

        end;
    end;

begin
    tmrPoll.Enabled := false;
    mLock := true;


    for MtrIt := Low(TMotorOrd) to MtrOrdHi do
    begin
        mMtrJogUI[MtrIt].SetVisible(False);
    end;

    mTotMtrCount := Length(Mtrs);

    for i := 0 to mTotMtrCount - 1 do
    begin
        mMotors[i] := Mtrs[i];
        mMotors[i].ClearFSM;
        mMtrJogUI[mMotors[i].ID].SetVisible(IsMtrExists);
    end;


    mLock := false;
    tmrPoll.Enabled := true;
end;

procedure TfrmSeatMtrCtrl.CanRead(Sender: TObject);
var
    Str: string;
begin

    if mLock or not mIsIMS then
        Exit;

    // 동기화를 위해 ..Can Callback event에서

    with Sender as TBaseCAN do
    begin

        case mCANWState of
            0:
                begin
                end;
            1:
                begin
                end;
        end;

    end;

end;

procedure TfrmSeatMtrCtrl.cbxStationChange(Sender: TObject);
begin
    // if  not mEnableChangeEvent then  Exit;

    mMdlType.SetCarType(TCAR_TYPE(cbxCarType.ItemIndex));
    if cbxPosType.Visible then
        mMdlType.SetPosType(TPOS_TYPE(cbxPosType.ItemIndex));


    if Assigned(mOnChange) then
        mOnChange(Self);
end;

procedure TfrmSeatMtrCtrl.SetMdlType(const Value: TModelType);
begin
    mMdlType := Value;
    // mEnableChangeEvent := false;
    cbxCarType.ItemIndex := ord(mMdlType.GetCarType);
    cbxPosType.ItemIndex := ord(mMdlType.GetPosType);
    // mEnableChangeEvent := true;
end;

procedure TfrmSeatMtrCtrl.ledBwReclMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
    Btn: TAbLed;
begin
    Btn := TAbLed(Sender);

    Btn.Checked := true;
    TAsyncCalls.Invoke( procedure begin mMotors[Btn.Tag].MoveBw; end).Forget;

end;

procedure TfrmSeatMtrCtrl.ledFwReclMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
    Btn: TAbLed;
begin
    Btn := TAbLed(Sender);
    Btn.Checked := true;
    TAsyncCalls.Invoke( procedure begin mMotors[Btn.Tag].MoveFw; end).Forget;
end;

procedure TfrmSeatMtrCtrl.ledFwReclMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
    Btn: TAbLed;

begin
    Btn := TAbLed(Sender);
    Btn.Checked := false;
    TAsyncCalls.Invoke( procedure begin mMotors[Btn.Tag].Stop; end).Forget;
end;

procedure TfrmSeatMtrCtrl.pnlCANFrameDockDrop(Sender: TObject; Source: TDragDockObject; X, Y: Integer);
begin
    pnlCANFrame.Width := 306;
end;

procedure TfrmSeatMtrCtrl.pnlCANFrameUnDock(Sender: TObject; Client: TControl; NewTarget: TWinControl; var Allow: boolean);
begin
    pnlCANFrame.Width := 0;
end;

var
    DispState: Integer;

procedure TfrmSeatMtrCtrl.tmrPollTimer(Sender: TObject);
begin
    mMtrJogUI[tmSlide].Update(mMotors[0]);
    mMtrJogUI[tmTilt].Update(mMotors[1]);
    mMtrJogUI[tmHeight].Update(mMotors[2]);



    if mLock or not mIsIMS then
        Exit;

    case DispState of
        0:
            begin
                Inc(DispState);

            end;
        1:
            begin

                DispState := 0;
            end;
    end;

end;

{ TMtrJogUI }

procedure TMtrJogUI.DisablePosLbl;
begin

end;

procedure TMtrJogUI.Find(Parent: TComponent; Suffix: string);
begin

    mFwLed := TAbLed(Parent.FindComponent('ledFw' + Suffix));
    mBwLed := TAbLed(Parent.FindComponent('ledBw' + Suffix));

    mCurrLbl := TLabel(Parent.FindComponent('lblCurr' + Suffix));

end;

procedure TMtrJogUI.SetVisible(Value: boolean);
begin
    mFwLed.Visible := Value;
    mBwLed.Visible := Value;
    mCurrLbl.Visible := Value;
end;

procedure TMtrJogUI.Update(Mtr: TSeatMotor);
begin
    if Mtr = nil then
        Exit;

    mCurrLbl.Caption := Format('%.2f A', [Mtr.GetCurr]);
end;

end.
