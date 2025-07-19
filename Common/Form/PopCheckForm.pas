unit PopCheckForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TfrmPopChecker = class(TForm)
    Panel1: TPanel;
    lbLog: TListBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure SetFrm(ALog: string) ;
  end;

var
  frmPopChecker: TfrmPopChecker;

implementation

{$R *.dfm}

{ TfrmPopChecker }

procedure TfrmPopChecker.SetFrm(ALog: string);
var
    sTm : string ;
begin
    sTm := FormatDateTime('hh:nn:ss', Now) ;
    sTm := Format('[%s]%s', [sTm, ALog]) ;
    lbLog.Items.Add(sTm) ;
    while lbLog.Count > 100 do lbLog.Items.Delete(0);
    lbLog.ItemIndex := lbLog.Count-1 ;
end;

procedure TfrmPopChecker.FormCreate(Sender: TObject);
begin
    lbLog.Clear ;
end;

procedure TfrmPopChecker.FormDestroy(Sender: TObject);
begin
    frmPopChecker := nil ;
end;

end.
