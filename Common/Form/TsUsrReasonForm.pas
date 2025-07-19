unit TsUsrReasonForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, AsyncCalls,
  Dialogs, StdCtrls, ExtCtrls, Label3D, Buttons;

type
  TfrmReason = class(TForm)
    labTransReason: TLabel3D;
    Panel1: TPanel;
    edtTransReason: TEdit;
    bbtnOK: TBitBtn;
    bbtnCancel: TBitBtn;
    Label1: TLabel;
    labReasonlist: TLabel;
    Timer1: TTimer;
    procedure FormShow(Sender: TObject);
    procedure bbtnOKClick(Sender: TObject);
    procedure bbtnCancelClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
    mComent : String;
  public
    { Public declarations }
    mPass: boolean;
    procedure SetReasonList(aCaption:String);
    property  Coment:String Read mComent;
  end;

var
  frmReason: TfrmReason;

implementation

{$R *.dfm}

procedure TfrmReason.bbtnCancelClick(Sender: TObject);
begin
	ModalResult := mrCancel;
    Close;
end;

procedure TfrmReason.bbtnOKClick(Sender: TObject);
begin
	if edtTransReason.Text = '' then
    begin
    	Application.MessageBox(PWideChar('사유가 없습니다. 사유를 입력하여주십시요.'),
                               PWideChar(Caption),
                           	   MB_ICONERROR+MB_OK) ;
    	exit;
    end;
    mComent := edtTransReason.Text;
    ModalResult := mrOk;
end;

procedure TfrmReason.FormClose(Sender: TObject; var Action: TCloseAction);
begin
//
end;

procedure TfrmReason.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
//
end;

procedure TfrmReason.FormCreate(Sender: TObject);
begin
//
    mPass := False;
end;

procedure TfrmReason.FormShow(Sender: TObject);
begin
    Left := Screen.Monitors[0].Left
            + (Screen.Monitors[0].Width div 2)
            - (Width div 2) ;

    Top := Screen.Monitors[0].Top
            + (Screen.Monitors[0].Height div 2)
            - (Height div 2) ;
    edtTransReason.Text := '';
    if mPass then
    begin
        Timer1.Enabled := True;
    end;
end;

procedure TfrmReason.SetReasonList(aCaption: String);
begin
	labReasonlist.Caption := aCaption;
end;

procedure TfrmReason.Timer1Timer(Sender: TObject);
begin
    edtTransReason.Text := '관리자 패스 모드';
    bbtnOKClick(Nil);
    Timer1.Enabled := False;
end;

end.
