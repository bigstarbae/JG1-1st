unit SelModelForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, CheckLst;

type
  TfrmSelModels = class(TForm)
    Label1: TLabel;
    cklModel: TCheckListBox;
    Panel1: TPanel;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    CheckBox1: TCheckBox;
    ckbApplyMotor: TCheckBox;
    ckbAppyDelivery: TCheckBox;
    ckbAppySwIo: TCheckBox;
    ckbUsrType: TCheckBox;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
  private
    { Private declarations }
    mInit : integer ;
    procedure InitForm ;
  public
    { Public declarations }
    procedure SetInit(Index:integer) ;
    function  IsChecked(Index:integer): boolean ;
    function  Execute(x, y : Integer) : Boolean ; overload ;
  end;

var
  frmSelModels: TfrmSelModels;

implementation
uses
    ModelUnit, LangTran;

{$R *.dfm}

function TfrmSelModels.Execute(x, y: Integer): Boolean;
begin

    InitForm ;
    if (x + Self.Width) > Screen.Width then Self.Left := Screen.Width - Self.Width
    else                                    Self.Left := x ;
    if (y + Self.Height) > Screen.Height then Self.Top := Screen.Height - Self.Height
    else                                      Self.Top := y ;

    Result := ShowModal() = mrOK ;
end;

procedure TfrmSelModels.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    Action := caFree;
end;

procedure TfrmSelModels.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
    mInit := -1 ;
end;

procedure TfrmSelModels.FormCreate(Sender: TObject);
begin
    cklModel.Clear ;
end;

procedure TfrmSelModels.FormDestroy(Sender: TObject);
begin
//
end;

procedure TfrmSelModels.FormShow(Sender: TObject);
begin
    CheckBox1.Checked := false ;
    ckbApplyMotor.Checked := false ;
    ckbAppySwIo.Checked := false ;
    ckbAppyDelivery.Checked := false ;
    ckbUsrType.Checked := false ;
    TLangTran.ChangeCaption(self);
end;

function TfrmSelModels.IsChecked(Index: integer): boolean;
begin
    Result := cklModel.Checked[Index] ;
end;

procedure TfrmSelModels.InitForm;
var
    i : integer ;
begin
    cklModel.Clear ;
    for i := 1 to _MAX_MODEL_COUNT do
    begin
        if not Assigned(gModels) then Continue ;

        cklModel.Items.Add(IntToStr(i)+ '. '+ gModels.GetModel(i).rPartName) ;
        cklModel.Checked[i-1] := (mInit+1) = i ;
    end ;
end;

procedure TfrmSelModels.SetInit(Index: integer);
begin
    mInit := Index ;
end;

procedure TfrmSelModels.CheckBox1Click(Sender: TObject);
var
    i : integer ;
begin
    for i := 0 to cklModel.Count-1 do
    begin
        cklModel.Checked[i] := CheckBox1.Checked ;
    end ;
end;

end.
