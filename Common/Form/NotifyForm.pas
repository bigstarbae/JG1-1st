unit NotifyForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls, KiiMessages ;

type
  TfrmNotify = class(TForm)
    labMsg: TLabel;
    labState: TLabel;
    pgbReadCount: TProgressBar;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
    procedure ReadMessage(var myMsg: TMessage); Message WM_SYS_CODE ;
  public
    { Public declarations }

    procedure SetFrm(aMsg: string) ;
    procedure SetStates(aMsg: string) ;
    procedure SetTotalCount(aCount: integer) ;
    procedure SetIncrease ;
  end;

var
  frmNotify: TfrmNotify;

implementation
uses
    Log ;

{$R *.DFM}

//------------------------------------------------------------------------------
procedure TfrmNotify.SetFrm(aMsg: string) ;
begin
    labMsg.Caption := aMsg ;
end ;
//------------------------------------------------------------------------------
procedure TfrmNotify.SetStates(aMsg: string) ;
begin
    labState.Caption := aMsg ;
end ;
//------------------------------------------------------------------------------
procedure TfrmNotify.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    if gLog <> nil then
    begin
        gLog.ToFiles('%s', [Caption]) ;
        gLog.ToFiles('-------------------------------------------- END', []) ;
    end ;
end;
//------------------------------------------------------------------------------
procedure TfrmNotify.FormCreate(Sender: TObject);
begin
    labMsg.Caption := '' ;
    labState.Caption := '' ;
    with pgbReadCount do Visible := false ;
end;
//------------------------------------------------------------------------------
procedure TfrmNotify.FormDestroy(Sender: TObject);
begin
//
    Tag := 1 ;
end;
//------------------------------------------------------------------------------
procedure TfrmNotify.FormShow(Sender: TObject);
begin
    if gLog <> nil then
    begin
        gLog.ToFiles('%s', [Caption]) ;
        gLog.ToFiles('-------------------------------------------- BEGIN', []) ;
    end ;
end;
//------------------------------------------------------------------------------
procedure TfrmNotify.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
//
end;
//------------------------------------------------------------------------------
procedure TfrmNotify.SetTotalCount(aCount: integer) ;
begin
    with pgbReadCount do
    begin
        Min      := 0 ;
        Max      := aCount ;
        Position := 0 ;
        Visible  := true ;
    end ;
end ;
//------------------------------------------------------------------------------
procedure TfrmNotify.SetIncrease ;
begin
    with pgbReadCount do Position := Position+1 ; 
end ;

procedure TfrmNotify.ReadMessage(var myMsg: TMessage);
begin
    case myMsg.WParam of
        SYS_UPDATES : SetIncrease ;
    end ;
end;

end.
