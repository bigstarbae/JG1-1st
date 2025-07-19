program SensorToAngleConverterTest;

uses
  Forms,
  TestForm in 'TestForm.pas' {Form17},
  SensorToAngleConverter in '..\..\02.RearSeat\Common\SensorToAngleConverter.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm17, Form17);
  Application.Run;
end.
