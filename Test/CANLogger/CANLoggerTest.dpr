program CANLoggerTest;

uses
  Forms,
  TestForm in 'TestForm.pas' {frmTest},
  CANLogger in '..\..\Common\Lib\CANLogger.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmTest, frmTest);
  Application.Run;
end.
