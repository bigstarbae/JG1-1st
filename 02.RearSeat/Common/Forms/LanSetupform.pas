unit LanSetupform;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, Buttons, KiiMessages ;

type
  TfrmLanSetup = class(TForm)
    GroupBox1: TGroupBox;
    Panel1: TPanel;
    Label13: TLabel;
    labWaitTime: TLabel;
    labSendTerm: TLabel;
    labConnectTime: TLabel;
    labErWaitTime: TLabel;
    Label1: TLabel;
    lblPort: TLabel;
    Label4: TLabel;
    Label3: TLabel;
    edtPort1: TEdit;
    edtPort2: TEdit;
    edtPort3: TEdit;
    edtPort4: TEdit;
    edtPort5: TEdit;
    edtPort6: TEdit;
    edtPort7: TEdit;
    edtPort8: TEdit;
    edtPort9: TEdit;
    edtPort10: TEdit;
    bbtnSave: TBitBtn;
    ckbIsReConnect: TCheckBox;
    edtWaitTime: TEdit;
    edtSendTerm: TEdit;
    edtErWaitTime: TEdit;
    edtConnectTime: TEdit;
    cbxPort1: TComboBox;
    cbxPort2: TComboBox;
    cbxPort3: TComboBox;
    cbxPort4: TComboBox;
    cbxPort5: TComboBox;
    cbxPort6: TComboBox;
    cbxPort7: TComboBox;
    cbxPort8: TComboBox;
    cbxPort9: TComboBox;
    cbxPort10: TComboBox;
    ckbPort1: TCheckBox;
    ckbPort2: TCheckBox;
    ckbPort3: TCheckBox;
    ckbPort4: TCheckBox;
    ckbPort5: TCheckBox;
    ckbPort6: TCheckBox;
    ckbPort7: TCheckBox;
    ckbPort8: TCheckBox;
    ckbPort9: TCheckBox;
    ckbPort10: TCheckBox;
    edtIP1: TEdit;
    edtIP2: TEdit;
    edtIP3: TEdit;
    edtIP4: TEdit;
    edtIP5: TEdit;
    edtIP6: TEdit;
    edtIP7: TEdit;
    edtIP8: TEdit;
    edtIP9: TEdit;
    edtIP10: TEdit;
    Label8: TLabel;
    Shape10: TShape;
    Shape11: TShape;
    Shape1: TShape;
    Shape2: TShape;
    Shape3: TShape;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure edtHostIpChange(Sender: TObject);
    procedure bbtnSaveClick(Sender: TObject);
    procedure ckbPort1Click(Sender: TObject);
    procedure ckbIsReConnectClick(Sender: TObject);
    procedure lblPortDblClick(Sender: TObject);
  private
    { Private declarations }
    mEdit,
    mIsChanged : boolean ;
    mChangeEvent : TNotifyStatus ;

    procedure LoadPortList ;
    function  SavePortList : boolean ;
    procedure ReadMessage(var myMsg: TMessage); Message WM_SYS_CODE ;
  public
    { Public declarations }
    function  Save : boolean ;
    property  OnUserChange : TNotifyStatus read mChangeEvent write mChangeEvent ;
  end;

var
  frmLanSetup: TfrmLanSetup;

implementation
uses
    UserSocketUnit, myUtils, Log, LanIoUnit , LangTran;

{$R *.DFM}

type
TPortBuffer = packed record
    rIndex,
    rPort : integer ;
    rDevType: TDioMonitorDevORD;
end ;
procedure TfrmLanSetup.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
    Action := caFree ;
end;

procedure TfrmLanSetup.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
//
end;

procedure TfrmLanSetup.FormCreate(Sender: TObject);
begin
    mEdit := true ;
    mIsChanged := false ;
end;

procedure TfrmLanSetup.FormDestroy(Sender: TObject);
begin
//
end;

procedure TfrmLanSetup.FormShow(Sender: TObject);
begin
    LoadPortList ;
    bbtnSave.Enabled  := false ;

    mEdit := false ;
    mIsChanged := false ;
    TLangTran.ChangeCaption(self);
end;

procedure TfrmLanSetup.lblPortDblClick(Sender: TObject);
begin
    if lblPort.Tag = 0 then
    begin
        lblPort.Caption := 'PORT(Hex)';
        lblPort.Tag := 1;
    end
    else
    begin
        lblPort.Caption := 'PORT(Dec)';
        lblPort.Tag := 0;
    end;
end;

procedure TfrmLanSetup.LoadPortList ;
var
    Port, i : integer ;
    myCom : TComponent ;
    IsHexVal, bTm : boolean ;
    j : TDioMonitorDevORD ;
begin
    for i := 1 to 10 do
    begin
        bTm := GetLoadPortUse(i) ;
        myCom := FindComponent(Format('ckbPort%d', [i])) ;
        if Assigned(myCom) then
        begin
            with TCheckBox(myCom) do
            begin
                Checked := bTm ;
                OnClick(myCom) ;
            end ;
        end ;
        myCom := FindComponent(Format('edtIP%d', [i])) ;
        if Assigned(myCom) then
        begin
            with TEdit(myCom) do Text := GetLoadIP(i) ;
        end ;
        myCom := FindComponent(Format('edtPort%d', [i])) ;
        if Assigned(myCom) then
        begin
            with TEdit(myCom) do
            begin
                Port := GetLoadPort(i, IsHexVal);

                if i = 1 then
                begin
                    if IsHexVal then
                    begin
                        lblPort.Caption := 'PORT(Hex)';
                    end
                    else
                    begin
                        lblPort.Caption := 'PORT(Dec)';
                    end;
                end;


                if IsHexVal then
                begin
                    Text := IntToHex(Port, 4);
                end
                else
                begin
                    Text := IntToStr(Port);
                end;
            end;
        end ;
        myCom := FindComponent(Format('cbxPort%d', [i])) ;
        if Assigned(myCom) then
        begin
            with TComboBox(myCom) do
            begin
                Items.Clear ;
                for j := Low(TDioMonitorDevORD) to High(TDioMonitorDevORD) do
                begin
                    Items.Add(GetDevName(j)) ;
                end ;

                ItemIndex := GetLoadPortType(i) ;
            end ;
        end ;
    end ;

    edtWaitTime.Text := FloatToStr(gLanEnv.rWaitTime) ;
    edtSendTerm.Text := FloatToStr(gLanEnv.rSendTerm) ;
    edtErWaitTime.Text := FloatToStr(gLanEnv.rErWaitTime) ;
    edtConnectTime.Text := FloatToStr(gLanEnv.rConnectTime) ;
    ckbIsReConnect.Checked := gLanEnv.rReConOfSndFault ;
end ;

procedure TfrmLanSetup.ReadMessage(var myMsg: TMessage);
begin
    case myMsg.WParam of
        SYS_SAVE_DATA : Save ;
    end ;
end;

procedure QuickSort(var aAry: array of TPortBuffer;First, Last:integer) ;
var
    i,
    j   : integer ;
    Tmp : TPortBuffer ;
    std : TPortBuffer ;
begin
    std := aAry[(First+Last) div 2] ;

    i := First;
    j := Last;
    while true do
    begin
        while (aAry[i].rPort < std.rPort) do Inc(i) ;
        while (aAry[j].rPort > std.rPort) do dec(j) ;
        if (i >= j) then Break ;
        Tmp := aAry[i] ;
        aAry[i]   := aAry[j] ;
        aAry[j]   := Tmp ;
        Inc(i) ;
        Dec(j) ;
    end ;

    if (First < i - 1) then QuickSort(aAry, First, i - 1) ;
    if (j + 1 < Last)  then QuickSort(aAry, j + 1, Last) ;
end ;

function  EditTxtValue(Sender: TObject; IsEdit: boolean; ACom: TEdit;
                       var AVal: double; AUnit: string): boolean ;
begin
    Result := true ;
    with ACom do
    begin
        if not IsEdit then
        begin
            Text := FloatToStr( AVal ) + AUnit ;
            Exit ;
        end ;

        try
            GetStrToFloat(Text) ;
        except
            Result := false ;
        end ;
        
        if not Result and Assigned(gLog) then
        begin
            gLog.ToFiles('Component Name: %s Value: %s Error: EditTxtValue',
                        [Name, Text]) ;
            Exit ;
        end ;
        AVal := GetStrToFloat(Text) ;
    end ;
end ;

function TfrmLanSetup.Save : boolean ;
begin
    Result := true ;
    if not mIsChanged then Exit ;

    Result := SavePortList ;
    mIsChanged := not Result ;
    if Assigned(mChangeEvent) then
        OnUserChange(Self, integer(mIsChanged)) ;

    if Result then
    begin
        SendToForm(gSocketMan.GetMessageHandle, SYS_LAN_PORT_CHANGED, 0) ;
    end;
end;

function TfrmLanSetup.SavePortList : boolean ;
Label _LABEL_ERROR_INPUT ;
var
    i : integer ;
    sTm : string ;
    myCom : TComponent ;
    Prv : TPortBuffer ;
    nP  : array of TPortBuffer ;
    Ips : array[1..10]of string ;
    IsHexVal, bTm : boolean ;
begin
    Result := true ;
    // 중복 확인
    for i := 1 to 10 do
    begin
        myCom := FindComponent(Format('ckbPort%d', [i])) ;
        bTm := false ;
        if Assigned(myCom) then
        begin
            with TCheckBox(myCom) do
                bTm := Checked ;
        end;
        if not bTm then
        begin
            SetSavePortUse(i, false);
            Continue ;
        end ;

        SetLength(nP, Length(nP)+1) ;
        nP[Length(nP)-1].rIndex := i ;

        IsHexVal := Pos('Hex', lblPort.Caption) > 0;
        myCom := FindComponent(Format('edtPort%d', [i])) ;
        if Assigned(myCom) then
        begin
            with TEdit(myCom) do
                if IsHexVal then
                    nP[Length(nP)-1].rPort := StrToIntDef('$'+Text, -1)
                else
                    nP[Length(nP)-1].rPort := StrToIntDef(Text, -1)
        end
        else
        begin
            nP[Length(nP)-1].rPort := -999 ;
        end ;

        myCom := FindComponent(Format('edtIP%d', [i])) ;
        if Assigned(myCom) then
        begin
            with TEdit(myCom) do IPs[i] := Text ;
        end
        else IPs[i] := '' ;

        myCom := FindComponent(Format('cbxPort%d', [i])) ;
        if Assigned(myCom) then
        begin
            with TComboBox(myCom) do
                nP[Length(nP)-1].rDevType := TDioMonitorDevORD(ItemIndex);
        end
        else
            nP[Length(nP)-1].rDevType := devNone;


    end ;
    // 중복 확인
    if Length(nP) = 2 then
    begin
//        if (nP[0].rPort = nP[1].rPort)
//            and  (IPs[nP[0].rIndex] = IPs[nP[0].rIndex])
//            and ((nP[0].rDevType = devRead) or (nP[1].rDevType = devRead)) then     // Read제외한 Data, W 중복 Port사용토록 허용
//        begin
//            sTm := _TR('중복된 포트 입력 확인하세요.')+#13+ _TR('확인후 다시 시도하세요') ;
//            Goto _LABEL_ERROR_INPUT ;
//        end ;
    end
    else
    if Length(nP) > 2 then QuickSort(nP, 0, Length(nP)-1) ;



    // 입력확인
    FillChar(Prv, sizeof(TPortBuffer), 0) ;
    for i := 0 to Length(nP)-1 do
    begin
        if nP[i].rPort = -999 then
        begin
            sTm := _TR('컴포넌트를 찾을 수 없습니다.')+#13+ _TR('프로그램을 다시 작동하세요') ;
            Goto _LABEL_ERROR_INPUT ;
        end
        //{
        else
        if (nP[i].rPort < 1000) then
        begin
            sTm := Format(_TR('%d. 포트번호 입력오류( 3E8(Hex) 이상)')+#13+ _TR('확인후 다시 시도하세요'), [i+1]) ;
            Goto _LABEL_ERROR_INPUT ;
            Break ;
        end
        //}
        else
        if (i > 0) and (Prv.rPort = nP[i].rPort) and (IPs[nP[i].rIndex] = IPs[Prv.rIndex]) then   // Data제외한 R, W 중복 Port사용토록 허용
        begin
//            sTm := _TR('중복된 포트 입력 확인하세요.')+#13+ _TR('확인후 다시 시도하세요') ;
//            Goto _LABEL_ERROR_INPUT ;
        end
        else Prv := nP[i] ;

        if (IPs[nP[i].rIndex] = '')or(GetIpToDec(IPs[nP[i].rIndex]) < 0) then
        begin
            sTm := Format(_TR('PLC IP 입력오류')+#13+ _TR('확인후 다시 시도하세요'), [i+1]) ;
            Goto _LABEL_ERROR_INPUT ;
        end ;
    end ;

    sTm := labWaitTime.Caption+' '+_TR('응답 대기 시간(ms) 확인 후 다시 시도하세요.') ;
    if not EditTxtValue(Self, true, edtWaitTime, gLanEnv.rWaitTime, '') then Goto _LABEL_ERROR_INPUT ;

    sTm := labSendTerm.Caption+' '+_TR('전송 간격(ms) 확인 후 다시 시도하세요.') ;
    if not EditTxtValue(Self, true, edtSendTerm, gLanEnv.rSendTerm, '') then Goto _LABEL_ERROR_INPUT ;

    sTm := labErWaitTime.Caption+' '+_TR('오류시 재연결 시간(ms) 확인 후 다시 시도하세요.') ;
    if not EditTxtValue(Self, true, edtErWaitTime, gLanEnv.rErWaitTime, '') then Goto _LABEL_ERROR_INPUT ;

    sTm := labConnectTime.Caption+' '+_TR('연결 시도 간격(ms) 확인 후 다시 시도하세요.') ;
    if not EditTxtValue(Self, true, edtConnectTime, gLanEnv.rConnectTime, '') then Goto _LABEL_ERROR_INPUT ;

    gLanEnv.rReConOfSndFault := ckbIsReConnect.Checked ;


    for i := 0 to Length(nP)-1 do
    begin
        SetSaveIP(nP[i].rIndex, IPs[nP[i].rIndex]);
        SetSavePortUse(nP[i].rIndex, true);
        SetSavePort(nP[i].rIndex, nP[i].rPort, IsHexVal);
        myCom := FindComponent(Format('cbxPort%d', [nP[i].rIndex])) ;
        if Assigned(myCom) then
        begin
            with TComboBox(myCom) do SetSavePortType(nP[i].rIndex, ItemIndex);
        end ;
    end ;
    //SendToForm(gSocketMan.GetMessageHandle, SYS_LAN_PORT_CHANGED, 0) ;
    SaveLanEnv ;
    Exit ;

_LABEL_ERROR_INPUT :
    if Length(nP) > 0 then SetLength(nP, 0) ;

    Application.MessageBox(PChar(sTm),
                           PChar(Self.Caption),
                           MB_ICONERROR+MB_OK) ;

    Result := false ;
end ;

procedure TfrmLanSetup.edtHostIpChange(Sender: TObject);
begin
    if mEdit then Exit ;
    bbtnSave.Enabled  := true ;

    mIsChanged := true ;
    if Assigned(mChangeEvent) then
        OnUserChange(Self, integer(mIsChanged)) ;
end;

procedure TfrmLanSetup.bbtnSaveClick(Sender: TObject);
begin
    if not SavePortList then Exit ;
    bbtnSave.Enabled  := false ;
end;

procedure TfrmLanSetup.ckbPort1Click(Sender: TObject);
var
    myCom : TComponent ;
begin
    myCom := FindComponent(Format('edtPort%d', [TCheckBox(Sender).Tag])) ;
    if Assigned(myCom) then
    begin
        TEdit(myCom).Enabled := TCheckBox(Sender).Checked ;
    end ;
    myCom := FindComponent(Format('cbxPort%d', [TCheckBox(Sender).Tag])) ;
    if Assigned(myCom) then
    begin
        TComboBox(myCom).Enabled := TCheckBox(Sender).Checked ;
    end ;
    bbtnSave.Enabled  := true ;

    mIsChanged := true ;
    if Assigned(mChangeEvent) then
        OnUserChange(Self, integer(mIsChanged)) ;
end;

procedure TfrmLanSetup.ckbIsReConnectClick(Sender: TObject);
begin
    bbtnSave.Enabled  := true ;

    mIsChanged := true ;
    if Assigned(mChangeEvent) then
        OnUserChange(Self, integer(mIsChanged)) ;
end;

end.
