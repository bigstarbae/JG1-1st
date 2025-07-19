unit BkForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs;

type
  TfrmBk = class(TForm)
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmBk: TfrmBk;

implementation

{$R *.dfm}

procedure TfrmBk.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    Action := caFree;
end;

end.
