unit TsUsrReason;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
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
    procedure FormShow(Sender: TObject);
    procedure bbtnOKClick(Sender: TObject);
    procedure bbtnCancelClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    mComent : String;
  public
    { Public declarations }
    procedure SetReasonList(aCaption:String);
    property  Coment:String Read mComent;
  end;

var
  frmReason: TfrmReason;

implementation

uses LangTran;
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
    	Application.MessageBox(PWideChar(_TR('사유가 없습니다. 사유를 입력하여주십시요.')),
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

    TLangTran.ChangeCaption(Self);
end;

procedure TfrmReason.SetReasonList(aCaption: String);
begin
	labReasonlist.Caption := aCaption;
end;

end.
