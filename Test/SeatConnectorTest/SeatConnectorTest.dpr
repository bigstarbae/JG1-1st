program SeatConnectorTest;

uses
  Forms,
  TestForm in 'TestForm.pas' {frmTest},
  SeatConnector in '..\..\Common\Lib\SeatConnector.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmTest, frmTest);
  Application.Run;
end.
