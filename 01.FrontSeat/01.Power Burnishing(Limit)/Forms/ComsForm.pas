unit ComsForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, KiiMessages ;

type
  TfrmComsForm = class(TForm)
    pnlPortManager: TPanel;
    Label1: TLabel;
    Shape10: TShape;
    Shape11: TShape;
    Label3: TLabel;
    ComboBox3: TComboBox;
    Label4: TLabel;
    ComboBox4: TComboBox;
    Shape1: TShape;
    Label2: TLabel;
    Label5: TLabel;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ComboBox0Change(Sender: TObject);
  private
    { Private declarations }
    mIsChanged : boolean ;
    mChangeEvent : TNotifyStatus ;

    procedure UsrButtonClick(Sender:TObject) ;
    procedure ReadMessage(var myMsg: TMessage); Message WM_SYS_CODE ;
    function SaveDatas: boolean;
  public
    { Public declarations }
    function Save : boolean ;

    property  OnUserChange : TNotifyStatus read mChangeEvent write mChangeEvent ;
  end;

var
  frmComsForm: TfrmComsForm;

implementation
uses
    ComUnit, DataUnit, UserComLibEx, myUtils, AComReferForm , LangTran;

{$R *.dfm}
var
    lpComEnvs : array of TComParam ;
    lpDevComInfo : array[0..ord(High(TDevComORD))] of TDevComInfo ;

function GetUsrObject(AForm:TForm; AClassName:string; ATag: integer):TObject ;
var
    i : integer ;
begin
    Result := nil ;
    for i := 0 to AForm.ComponentCount-1 do
    begin
        if (UpperCase(AForm.Components[i].ClassName)=Uppercase(AClassName))
            and (AForm.Components[i].Tag = ATag) then
        begin
            Result := AForm.Components[i] ;
            Break ;
        end ;
    end ;
end ;

procedure TfrmComsForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
    Action := caFree ;
end;

procedure TfrmComsForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
    if Length(lpComEnvs) > 0 then SetLength(lpComEnvs, 0) ;
end;

procedure TfrmComsForm.FormCreate(Sender: TObject);
var
    i, j : integer ;
    nBtn   : TButton ;
    nCombo : TComboBox ;
    Lbl:     TLabel;
begin
    for i := 0 to ord(High(TDevComORD)) do
    begin
        lpDevComInfo[i] := GetDevComInfo(TDevComORD(i)) ;
        nBtn := TButton.Create(Self);
        with nBtn do
        begin
            Name    := Format('btnSetCom%d', [i]) ;
            Tag     := i ;
            Caption := 'Setting';//_TR('설정변경') ;
            Width   := 75 ;
            Height  := 25 ;
            Parent := pnlPortManager ;
            nCombo := TComboBox(GetUsrObject(Self, 'TComboBox',i)) ;
            Lbl := TLabel(GetUsrObject(Self, 'TLabel', 10 + i * 10));
            if Assigned(Lbl) then
            begin
                Lbl.Caption := GetDevComName(lpDevComInfo[i].rDevComID);
                Lbl.Visible := true;
            end;

            if Assigned(nCombo) then
            begin
                nCombo.Visible := true;
                Left := nCombo.Left + nCombo.Width + 5 ;
                if nCombo.Height > Height then
                    Top := nCombo.Top  + (nCombo.Height - Height) div 2
                else
                if nCombo.Height = Height then
                    Top := nCombo.Top
                else
                    Top := nCombo.Top - (Height - nCombo.Height) div 2 ;

                nCombo.Clear ;
                nCombo.Items.AddObject('-do not use-', nil) ;
                for j := 0 to gDevComs.Count-1 do
                begin
                    with gDevComs.GetItem(j) do
                        nCombo.Items.AddObject(Format('COM%d', [rComIDx]),
                                               TObject(rComIDx));
                end ;
                with nCombo do
                begin
                    if Items.IndexOf(Format('COM%d', [lpDevComInfo[i].rAPort]))> 0 then
                    begin
                        ItemIndex := Items.IndexOf(Format('COM%d', [lpDevComInfo[i].rAPort])) ;
                    end
                    else
                    begin
                        lpDevComInfo[i].rAPort := 0 ;
                        ItemIndex := 0 ;
                    end ;
                end ;
            end ;
            OnClick := UsrButtonClick ;
            if not Assigned(nCombo) then Continue ;
            
            with gDevComs do
            begin
                Enabled := (nCombo.ItemIndex > 0)
                           and(GetCom(GetDevCom(TDevComORD(i)).Port)<>nil) ;
            end ;
        end ;
    end ;
end;

procedure TfrmComsForm.FormDestroy(Sender: TObject);
begin
//
end;

procedure TfrmComsForm.FormShow(Sender: TObject);
begin
    mIsChanged := false ;
	TLangTran.ChangeCaption(self);
end;

procedure TfrmComsForm.ReadMessage(var myMsg: TMessage);
begin
    case myMsg.WParam of
        SYS_SAVE_DATA : Save ;
    end ;
end;

function IsDuplication(APort: integer) : integer ;
var
    i : integer ;
begin
    Result := -1 ;
    for i := 0 to Length(lpDevComInfo)-1 do
    begin
        if lpDevComInfo[i].rAPort = APort then
        begin
            Result := i ;
            Break ;
        end ;
    end ;
end ;

function TfrmComsForm.Save: boolean;
begin
    Result := true ;
    if not mIsChanged then Exit ;

    Result := SaveDatas ;
    mIsChanged := not Result ;
    if Assigned(mChangeEvent) then
        OnUserChange(Self, integer(mIsChanged)) ;

    if Result then SendToForm(gUsrMsg, SYS_BASE, 0);
end;

function TfrmComsForm.SaveDatas : boolean ;
var
    i, Cnt : integer ;
    nInfo: TDevComInfo ;
begin
    Result := false ;

    //같은넘 찾기
    for i := 0 to ord(High(TDevComORD)) do
    begin
        if (lpDevComInfo[i].rAPort > 0)
            and (IsDuplication(lpDevComInfo[i].rAPort)<>i) then
        begin
            Application.MessageBox(PChar(_TR('중복되는 포트가 있습니다')
                                         +#13
                                         +_TR('확인 후 재설정하세요.')),
                                   PChar(Caption),
                                   MB_ICONERROR+MB_OK) ;
            Exit ;
        end ;
    end ;

    Cnt := 0 ;
    for i := 0 to Length(lpComEnvs)-1 do
    begin
        SaveComEnv(lpComEnvs[i],
                   Format('COM%d', [ord(lpComEnvs[i].rPort)+1]));
        Inc(Cnt) ;
    end ;

    for i := 0 to ord(High(TDevComORD)) do
    begin
        nInfo := GetDevComInfo(lpDevComInfo[i].rDevComID) ;
        if not CompareMem(@nInfo, @lpDevComInfo[i], sizeof(TDevComInfo)) then
        begin
            SetDevComInfo(lpDevComInfo[i]) ;
            Inc(Cnt) ;
        end ;
    end ;

    Result := true ;
    if Cnt > 0 then
    begin
        SendToForm(gDevComs.GetMsgHandle, SYS_PORT, 0);
    end ;
end;

procedure TfrmComsForm.UsrButtonClick(Sender: TObject);
var
    i : integer ;
    CurEnv, PrvEnv : TComParam ;
    nCombo : TComboBox ;
begin
    with Sender as TButton do
    begin
        nCombo := TComboBox(GetUsrObject(Self, 'TComboBox', Tag)) ;
        if not Assigned(nCombo) then Exit ;
        if nCombo.ItemIndex < 1 then Exit ;
        LoadComEnv(CurEnv, Format('COM%d', [integer(nCombo.Items.Objects[nCombo.ItemIndex])])) ;
        PrvEnv := CurEnv ;

        with TfrmAComRefer.Create(Application) do
        begin
            SetFrm(@CurEnv);
            ShowModal ;
        end ;

        if not CompareMem(@PrvEnv, @CurEnv, sizeof(TComParam)) then
        begin
            for i := 0 to Length(lpComEnvs)-1 do
            begin
                if lpComEnvs[i].rPort = CurEnv.rPort then
                begin
                    lpComEnvs[i] := CurEnv ;
                    //==================
                    mIsChanged := true ;
                    if Assigned(mChangeEvent) then
                        OnUserChange(Self, integer(mIsChanged)) ;
                    //if Assigned(mChanged) then OnPortChanged(Self) ;
                    Exit ;
                end ;
            end ;

            SetLength(lpComEnvs, Length(lpComEnvs)+1) ;
            lpComEnvs[Length(lpComEnvs)-1] := CurEnv ;
            //if Assigned(mChanged) then OnPortChanged(Self) ;
            //==================
            mIsChanged := true ;
            if Assigned(mChangeEvent) then
                OnUserChange(Self, integer(mIsChanged)) ;
        end ;
    end ;
end;

procedure TfrmComsForm.ComboBox0Change(Sender: TObject);
var
    nC : TComponent ;
begin
    with Sender as TComboBox do
    begin
        lpDevComInfo[Tag].rAPort := integer(Items.Objects[ItemIndex]) ;
        nC := TButton(GetUsrObject(Self, 'TButton', Tag)) ;
        if Assigned(nC) then
        begin
            TButton(nC).Enabled := (lpDevComInfo[Tag].rAPort > 0)
                                    or (gDevComs.GetCom(lpDevComInfo[Tag].rAPort)<>nil) ;
        end ;
        //if Assigned(mChanged) then OnPortChanged(Self) ;
        mIsChanged := true ;
        if Assigned(mChangeEvent) then
            OnUserChange(Self, integer(mIsChanged)) ;
    end ;
end;

end.
