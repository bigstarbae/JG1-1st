unit PopDataViewForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, ExtCtrls, LangTran;

type
  TfrmPopDataView = class(TForm)
    Panel1: TPanel;
    sgPopData: TStringGrid;
    btnParse: TButton;
    edtPopData: TEdit;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnParseClick(Sender: TObject);
  private
    { Private declarations }
    function Parse(DataStr : string) : integer;
  public
    { Public declarations }
  end;

var
  frmPopDataView: TfrmPopDataView;

implementation

uses
    MyUtils,DataUnit, DataUnitHelper;

{$R *.dfm}
procedure TfrmPopDataView.FormShow(Sender: TObject);
begin
//
    TLangTran.ChangeCaption(self);
end;

function IsDatePat(Str : string) : boolean;
begin
    if Length(Str) > 9 then
        if (Str[5] = '-') and (Str[8] = '-') then Exit(true);

    Result := false;
end;

function TfrmPopDataView.Parse(DataStr: string): integer;
var
    Tokens : array [0 .. 200] of string;
    i, Count: integer;

begin

    for i := 0 to Count - 1 do
    begin
        sgPopData.Cells[0, i] := GetResultOrdName(PopDataORD[i]);
        sgPopData.Cells[1, i] := Tokens[i];
    end;


end;

procedure TfrmPopDataView.btnParseClick(Sender: TObject);
begin
    if edtPopData.Text <> '' then
    begin
        Parse(edtPopData.Text);
    end;

end;

procedure TfrmPopDataView.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    Action := caFree;
end;


end.
