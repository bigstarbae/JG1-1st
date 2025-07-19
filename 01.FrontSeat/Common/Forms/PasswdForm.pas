unit PasswdForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ComCtrls, ExtCtrls;
Const Allchar: string = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz0123456789';

type
  TfrmPasswd = class(TForm)
    Shape2: TShape;
    labPasswd: TLabel;
    Shape1: TShape;
    edtPasswd: TEdit;
    edtNew: TEdit;
    pblPasswd: TPanel;
    pgbTime: TProgressBar;
    bbtnChange: TBitBtn;
    bbtnCancel: TBitBtn;
    Timer: TTimer;
    labNew: TLabel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure bbtnChangeClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edtPasswdKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edtNewKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure bbtnCancelClick(Sender: TObject);
  private
    { Private declarations }
    mIDx       : integer ;
    m_Passwd   : String;
//    m_PassBak  : string;
    m_RetryCnt : Integer;
    m_Result   : Boolean;
    m_UsrPass  : boolean ;
    m_modify   : Boolean;

    procedure Encrypt( var ss: string );
    function  GetMasterKey : string ;
  public
    { Public declarations }
    procedure SetFrm(IDx: integer) ;
    function  LoadPass : string ;
    procedure SavePass( sData : string ) ;
    procedure SetUsrPass(Passwd: string) ;
    procedure AddCount ;
    property  ModifyMode : boolean read m_modify write m_modify ;
  end;

var
  frmPasswd: TfrmPasswd;

implementation
uses
    Inifiles, myUtils ;
const
    RETRY_CNT = 3 ;
    ORGIN_HT  = 107;
    EXT_HT    = 145;
    INIT_KEY  = '1111' ;

{$R *.DFM}

procedure TfrmPasswd.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    Timer.Enabled := false;

    if not m_Result then ModalResult := mrNo
    else                 ModalResult := mrOK ;

    Action := CaFree ;
end;

procedure TfrmPasswd.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
//
end;

procedure TfrmPasswd.FormCreate(Sender: TObject);
begin
    Timer.Enabled := false;
    m_Modify      := false;
    m_UsrPass     := false ;
    mIDx          := 0 ;
end;

procedure TfrmPasswd.FormDestroy(Sender: TObject);
begin
//
end;

procedure TfrmPasswd.FormShow(Sender: TObject);
begin
    m_Result := false ;
    edtPasswd.Text   := '' ;
    pgbTime.Position := 0;

    if m_Modify then
    begin
        edtNew.Text     := '' ;
        Self.Height     := EXT_HT ;
        pgbTime.Visible := false;
        Timer.Enabled   := false;

        labNew.Visible := true;
        edtNew.Visible := true;

        m_RetryCnt     := 0;
        m_Passwd       := LoadPass;
    end
    else
    begin
        Self.Height   := ORGIN_HT ;
        pgbTime.Visible := true;
        pgbTime.Position := 0 ;
        Timer.Enabled := true;
        labNew.Visible := false;
        edtNew.Visible := false;

        if m_RetryCnt = 0 then
        begin
            Self.Caption      := '비밀번호 입력';
            labPasswd.Caption := '비밀번호';
            m_RetryCnt := 0;
            m_Passwd   := LoadPass ;
        end;
    end;
end;

function TfrmPasswd.GetMasterKey: string;
begin
    Result := FormatDateTime('yyyymmddhh', Now) ;
end;

procedure TfrmPasswd.TimerTimer(Sender: TObject);
begin
    AddCount ;
end;

procedure TfrmPasswd.AddCount;
begin
    if pgbTime.Position >= pgbTime.Max then
    begin
        Timer.Enabled := false;
        ShowMessage('비밀번호를 확인하세요!');
        Close();
    end
    else pgbTime.Position := pgbTime.Position + 10 ;

end;

procedure TfrmPasswd.Encrypt( var ss: string );
var l, lac,                // string length
   sp,                    // ss char pointer
   cp: integer;           // allchar pointer
begin
  l := Length(ss);
  lac := Length( Allchar );
  sp := 1;
  while sp <= l do
  begin
     cp := 1;
     while (allchar[cp] <> ss[sp]) and ( cp <= lac ) do inc( cp );
                { match char and find the encrypted counterpart in the reverse
                  order in position }
     if cp > lac then
     begin
         ss[sp]:= '*'
     end        { Mark illegal char - use only char not in allchar }
     else
     begin
                { Un-remark next line will further enhance security...
                  such that same character will appear as
                  different after encrypt }

//         cp := (( cp + sp*2 ) mod lac) + 1;

        ss[sp] := allchar[ lac - cp + 1 ];     //first char result in the last
     end;
     inc(sp);
  end;
end;

function TfrmPasswd.LoadPass : string;
var
   IniFile : TIniFile;
   sData   : string;
begin
    IniFile := TIniFile.Create(GetIniFiles);
    with IniFile do
    begin
        case mIDx of
            0 : sData := ReadString('MAIN', 'SIZE', '') ;
            1 : sData := ReadString('MAIN', 'LENGTH', '') ;
        else
                sData := ReadString('MAIN', 'USER_'+IntToStr(mIDx), '') ;
        end ;
        Free ;
    end;
    if sData = '' then sData := INIT_KEY
    else
    if sData <> '' then Encrypt(sData);
    Result := sData;
end;

procedure TfrmPasswd.SavePass( sData : string);
var
    IniFile : TIniFile;
begin
    Encrypt(sData);
    IniFile := TIniFile.Create(GetIniFiles);
    with IniFile do
    begin
        case mIDx of
            0 : WriteString('MAIN', 'SIZE', sData);
            1 : WriteString('MAIN', 'LENGTH', sData);
        else
                WriteString('MAIN', 'USER_'+IntToStr(mIDx), sData);
        end ;
        Free ;
    end;
end;

procedure TfrmPasswd.bbtnChangeClick(Sender: TObject);
begin
     if (((m_Passwd <> '')and(edtPasswd.Text=''))or(m_Passwd <> edtPasswd.Text))
        and (GetMasterKey <> Uppercase(edtPasswd.Text)) then
     begin
         Inc(m_RetryCnt) ;
         if m_RetryCnt >= RETRY_CNT then
         begin
            with Application do
                MessageBox(PChar('입력 내용을 확인하세요!'),
                           PChar(Caption),
                           MB_ICONWARNING+MB_OK + MB_DEFBUTTON1);
             m_Result := false;
             Close ;
         end
         else
         begin
            with Application do
                MessageBox(PChar('비밀번호가 맞지 않습니다.'),
                           PChar(Caption),
                           MB_ICONWARNING+MB_OK + MB_DEFBUTTON1);
             edtPasswd.Text := '';
             edtpasswd.SetFocus ;
         end ;
     end
     else
     if m_Modify then
     begin
        if edtNew.Text <> '' then
        begin
            m_Passwd := edtNew.Text ;
            with Application do
                MessageBox(PChar('변경되었습니다!'),
                           PChar(Caption),
                           MB_ICONINFORMATION+MB_OK + MB_DEFBUTTON1);

            SavePass(m_Passwd);
            Close ;
        end
        else
        begin
            Inc(m_RetryCnt);
            edtNew.Text := '';
            edtNew.SetFocus ;
        end;
     end
     else
     begin
         m_Result := true;
         Close ;
     end;
end;

procedure TfrmPasswd.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
     if Key = VK_RETURN then
     begin
        if m_Modify then
        begin
            edtNew.SetFocus ;
        end
        else
        begin
            bbtnChange.Click ;
        end;
     end;
end;

procedure TfrmPasswd.edtPasswdKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
     if Key = VK_RETURN then
     begin
        if m_Modify then
        begin
            edtNew.SetFocus ;
        end
        else
        begin
            bbtnChange.Click ;
        end;
     end;
end;

procedure TfrmPasswd.edtNewKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
     if Key = VK_RETURN then
     begin
         bbtnChange.Click ;
     end;
end;

procedure TfrmPasswd.bbtnCancelClick(Sender: TObject);
begin
    m_Result := false ;
end;

procedure TfrmPasswd.SetUsrPass(Passwd: string) ;
begin
    m_UsrPass := true ;
    m_Passwd  := Passwd ;
end ;

procedure TfrmPasswd.SetFrm(IDx: integer) ;
begin
    mIDx := iDx ;
end ;

end.