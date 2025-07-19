unit PowerSupplyForm;
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, AbLED, KiiMessages, Buttons, _GClass ;

type
  TfrmPowerSuppy = class(TForm)
    Panel1: TPanel;
    Timer1: TTimer;
    Panel6: TPanel;
    GroupBox1: TGroupBox;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    labPortName: TLabel;
    Label2: TLabel;
    labBaudrate: TLabel;
    labDatabit: TLabel;
    labParity: TLabel;
    labstopbit: TLabel;
    btnOpen: TButton;
    btnClose: TButton;
    bntsetting: TButton;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    labRunMode: TLabel;
    btnAuto: TButton;
    btnMaunal: TButton;
    Label11: TLabel;
    lbLog: TListBox;
    Label7: TLabel;
    Label8: TLabel;
    edtOutVolt: TEdit;
    edtOutCurr: TEdit;
    labVolt: TLabel;
    labCurr: TLabel;
    sbtnPowerOn: TSpeedButton;
    sbtnVoltWrite: TSpeedButton;
    sbtnCurrWrite: TSpeedButton;
    sbtnPowerOff: TSpeedButton;
    abPower: TAbLED;
    Label9: TLabel;
    Shape1: TShape;
    ckbDebugMode: TCheckBox;
    labSetVolt: TLabel;
    labSetCurr: TLabel;
    Label13: TLabel;
    Shape2: TShape;
    cbxStation: TComboBox;
    sbtnClearErr: TSpeedButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnAutoClick(Sender: TObject);
    procedure btnMaunalClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure btnOpenClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure bntsettingClick(Sender: TObject);
    procedure sbtnVoltWriteClick(Sender: TObject);
    procedure sbtnCurrWriteClick(Sender: TObject);
    procedure sbtnPowerOnClick(Sender: TObject);
    procedure sbtnPowerOffClick(Sender: TObject);
    procedure ckbDebugModeClick(Sender: TObject);
    procedure cbxStationChange(Sender: TObject);
    procedure sbtnClearErrClick(Sender: TObject);
  private
    mProc : integer ;
    mLock : boolean ;
    mIdx  : integer ;

    { Private declarations }
    procedure UpdatePorts ;
    procedure ReadMessage(var myMsg: TMessage); Message WM_SYS_CODE ;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent; StationNames: array of string);
  end;

var
  frmPowerSuppy: TfrmPowerSuppy;

implementation
uses
    PowerSupplyUnit, ComUnit, Log, UserComLibEx, ComReferForm, myUtils, DataUnit , LangTran;

{$R *.dfm}

var lpDcPower: TDcPower ;

constructor TfrmPowerSuppy.Create(AOwner: TComponent; StationNames: array of string);
var
    i: integer;
begin
    inherited Create(AOwner);

    for i := 0 to Length(StationNames) - 1 do
    begin
        if StationNames[i] <> '' then
            cbxStation.Items.Add(StationNames[i]);
    end;

end;

procedure TfrmPowerSuppy.bntsettingClick(Sender: TObject);
begin
    with TfrmComsRefer.Create(Application) do
    begin
        ShowModal ;
    end ;
end;

procedure TfrmPowerSuppy.btnAutoClick(Sender: TObject);
begin
    with lpDcPower do if not IsRun then Start ;
end;

procedure TfrmPowerSuppy.btnCloseClick(Sender: TObject);
begin
    with lpDcPower do
    begin
        if not DevCom.IsOpen then Exit ;
        DevCom.Close ;
    end ;
end;

procedure TfrmPowerSuppy.btnMaunalClick(Sender: TObject);
begin
    with lpDcPower do if IsRun then Stop ;
end;

procedure TfrmPowerSuppy.btnOpenClick(Sender: TObject);
begin
    with lpDcPower do
    begin
        if DevCom.IsOpen then Exit ;
        DevCom.Open ;
    end;
end;

procedure TfrmPowerSuppy.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    Action := caFree ;
end;

procedure TfrmPowerSuppy.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
    i: integer ;
begin
    mLock := true ;
    Timer1.Enabled := false ;

    if (ckbDebugMode.Tag > 0) and gPwrDebugMode then
    begin
        gPwrDebugMode:= false ;
    end;

        if Assigned(lpDcPower) then
        begin
            lpDcPower.LogHandle:= 0 ;
        end;
        if not lpDcPower.IsRun then lpDcPower.Start ;

    gLog.ToFiles('powersupply edit form close',[]) ;
end;

procedure TfrmPowerSuppy.FormCreate(Sender: TObject);
begin
//
end;

procedure TfrmPowerSuppy.FormDestroy(Sender: TObject);
begin
//
end;

procedure TfrmPowerSuppy.FormShow(Sender: TObject);
begin
    mProc := 0 ;
    mLock := false ;

    cbxStation.ItemIndex := 0;
    cbxStationChange(nil);

    with lpDcPower do LogHandle:= lbLog.Handle ;

    Timer1.Enabled := true ;

    with lpDcPower do
    begin
        edtOutVolt.Text:= GetUsrFloatToStr(GetOutVolt) ;
        edtOutCurr.Text:= GetUsrFloattoStr(GetOutCurr) ;
    end ;

    lbLog.Clear ;
    UpdatePorts ;

    ckbDebugMode.Checked:= gPwrDebugMode ;


    gLog.ToFiles('powersupply edit form show',[]) ;

    TLangTran.ChangeCaption(self);
end;

procedure TfrmPowerSuppy.cbxStationChange(Sender: TObject);
begin
    mLock := true;
    lpDcPower:= gDcPower.Items[cbxStation.ItemIndex] ;
    UpdatePorts;
    mLock := false;
end;


procedure TfrmPowerSuppy.ReadMessage(var myMsg: TMessage);
begin
    case myMsg.WParam of
        SYS_USERCOM,
        SYS_PORT_NOTIFY,
        SYS_PORT_END : UpdatePorts ;
    end;
end;

procedure TfrmPowerSuppy.Timer1Timer(Sender: TObject);
const _OPEN_CLOSE : array[false..true] of string=('¿­¸²', '´ÝÈû');
begin
    if mLock then Exit ;
    mLock := true ;

    case mProc of
        0 :
        begin
        end ;
        1 :
        begin
            if Assigned(lpDcPower) and lpDcPower.IsRun then
            begin
                labRunMode.Color := clRed ;
                labRunMode.Caption := 'Auto' ;
            end
            else
            begin
                labRunMode.Color := clGreen ;
                labRunMode.Caption := 'Manual' ;
            end ;
        end ;
        2 :
        begin
            if Assigned(lpDcPower) then
            begin
                with lpDcPower do
                begin
                    btnOpen.Enabled  := not DevCom.IsOpen ;
                    btnClose.Enabled := DevCom.IsOpen ;
                    sbtnPowerOn.Enabled:= btnClose.Enabled ;
                    sbtnPowerOff.Enabled:= btnClose.Enabled ;
                    sbtnVoltWrite.Enabled:= btnClose.Enabled ;
                end;
            end ;
        end ;
        3 :
        begin
            if Assigned(lpDcPower) then
            begin
                with lpDcPower do
                begin
                    abPower.Checked:= Power ;

                    labSetVolt.Caption:= Format('%0.1f V',[GetOutVolt]) ;
                    labSetCurr.Caption:= Format('%0.1f A',[GetOutCurr]) ;
                    labVolt.Caption:= Format('%0.1f V',[Volt]) ;
                    labCurr.Caption:= Format('%0.1f A',[Curr]) ;
                end ;
            end ;
        end ;
        4 :
        begin
        end ;
    else
        mProc := 0 ;
    end ;
    Inc(mProc) ;
    mProc := mProc mod 5 ;

    mLock := false ;
end;

procedure TfrmPowerSuppy.UpdatePorts;
var
    Param : TComParam ;
begin
    if not Assigned(lpDcPower) then Exit ;
    
    with lpDcPower do
    begin
        if DevCom.Port > 0 then
        begin
            LoadComEnv(Param, Format('COM%d',[DevCom.Port])) ;
            labPortName.Caption := Format('COM%d',[DevCom.Port]) ;
            labBaudrate.Caption := IntToStr(Param.rBaudRate);
            labDatabit.Caption := IntToStr(Param.rDataBit) ;
            labParity.Caption := GetParityTxt(Param.rParity) ;
            labstopbit.Caption := GetStopBitTxt(Param.rStopBIt) ;
        end
        else
        begin
            labPortName.Caption := '' ;
            labBaudrate.Caption := '' ;
            labDatabit.Caption := '' ;
            labParity.Caption := '' ;
            labstopbit.Caption := '' ;
        end ;
    end ;
end;

procedure TfrmPowerSuppy.sbtnVoltWriteClick(Sender: TObject);
begin
    with lpDcPower do SetVolt(StrToFloatDef(edtOutVolt.Text,13.5),false);
end;

procedure TfrmPowerSuppy.sbtnClearErrClick(Sender: TObject);
begin
    with lpDCPower do Clear;
end;

procedure TfrmPowerSuppy.sbtnCurrWriteClick(Sender: TObject);
begin
    with lpDcPower do SetCurr(StrToFloatDef(edtOutCurr.Text,20.0),false);
end;

procedure TfrmPowerSuppy.sbtnPowerOnClick(Sender: TObject);
begin
    with lpDcPower do PowerON();

end;

procedure TfrmPowerSuppy.sbtnPowerOffClick(Sender: TObject);
begin
    with lpDcPower do PowerOFF();
end;


procedure TfrmPowerSuppy.ckbDebugModeClick(Sender: TObject);
begin
    ckbDebugMode.Tag:= BYTE((gPwrDebugMode <> ckbDebugMode.Checked) and ckbDebugMode.Checked) ;
    gPwrDebugMode:= ckbDebugMode.Checked ;
end;



end.
