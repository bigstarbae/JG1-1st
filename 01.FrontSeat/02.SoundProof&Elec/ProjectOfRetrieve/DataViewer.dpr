program DataViewer;

uses
  Forms,
  DataBox in '..\Libs\DataBox.pas',
  Modelunit in '..\Libs\Modelunit.pas',
  RetrieveEx in '..\Libs\RetrieveEx.pas',
  LangTran in '..\..\Common\Lib\LangTran.pas',
  GridHead in '..\..\Common\Lib\GridHead.pas',
  SeatMtrGrpExtender in '..\Libs\SeatMtrGrpExtender.pas',
  SubDataBox4Mtr in '..\Libs\SubDataBox4Mtr.pas',
  UDSDef in '..\..\Common\Libs\UDSDef.pas',
  SeatMotorType in '..\..\Common\Libs\SeatMotorType.pas',
  RetrieveForm in '..\Forms\RetrieveForm.pas' {frmRetrieve},
  DetailForm in '..\Forms\DetailForm.pas' {frmDetail},
  SysEnv in '..\Libs\SysEnv.pas',
  DataUnitOrd in '..\Libs\DataUnitOrd.pas',
  SeatType in '..\..\Common\Libs\SeatType.pas',
  ModelType in '..\..\Common\Libs\ModelType.pas',
  DataUnit in '..\Libs\DataUnit.pas',
  DataUnitHelper in '..\..\Common\Libs\DataUnitHelper.pas',
  RetrieveUnit in '..\Libs\RetrieveUnit.pas',
  TableMaker in '..\..\..\Common\Lib\TableMaker.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := '검사 결과조회';
  Application.CreateForm(TfrmRetrieve, frmRetrieve);
  Application.Run;
end.
