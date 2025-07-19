unit ComReferForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls;

type
  TfrmComsRefer = class(TForm)
    pnlDock: TPanel;
    Panel2: TPanel;
    bbtnApply: TBitBtn;
    bbtnOK: TBitBtn;
    bbtnCancel: TBitBtn;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure bbtnApplyClick(Sender: TObject);
    procedure bbtnOKClick(Sender: TObject);
    procedure bbtnCancelClick(Sender: TObject);

    procedure OnPortChanged(Sender: TObject; AStatus: integer) ;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmComsRefer: TfrmComsRefer;

implementation
uses
    ComsForm, DataUnit , LangTran;
{$R *.dfm}

var
    lpfrmComsForm : TfrmComsForm;

procedure TfrmComsRefer.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
    Action := caFree ;
end;

procedure TfrmComsRefer.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
    lpfrmComsForm.Close ;
end;

procedure TfrmComsRefer.FormCreate(Sender: TObject);
begin
    lpfrmComsForm := TfrmComsForm.Create(Application) ;
    lpfrmComsForm.OnUserChange := OnPortChanged ;
    lpfrmComsForm.ManualDock(pnlDock, nil, alClient) ;
    lpfrmComsForm.Show ;
end;

procedure TfrmComsRefer.FormDestroy(Sender: TObject);
begin
//
end;

procedure TfrmComsRefer.FormShow(Sender: TObject);
begin
    bbtnApply.Enabled := false ;

	TLangTran.ChangeCaption(self);
end;

procedure TfrmComsRefer.OnPortChanged(Sender: TObject; AStatus:integer);
begin
    bbtnApply.Enabled := true ;
end;

procedure TfrmComsRefer.bbtnApplyClick(Sender: TObject);
begin
    bbtnApply.Enabled := not lpfrmComsForm.Save ;
end;

const
    _MS_Contents_Changed_do_u_save = '내용이 변경되었습니다. 저장하겠습니까?' ;

procedure TfrmComsRefer.bbtnOKClick(Sender: TObject);
begin
    if bbtnApply.Enabled
        and (Application.MessageBox(PWideChar(_TR('내용이 변경되었습니다, 저장하시겠습니까?')),
                                    PChar(Caption),
                                    MB_ICONQUESTION+MB_YESNO)=ID_YES) then
    begin
        bbtnApply.Click ;
        if not bbtnApply.Enabled then Close ;
    end
    else Close ;
end;

procedure TfrmComsRefer.bbtnCancelClick(Sender: TObject);
begin
    Close ;
end;

end.
