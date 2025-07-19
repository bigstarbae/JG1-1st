program AntiPinchTester;

uses
  Forms,
  BaseMainForm in '..\..\Common\Forms\BaseMainForm.pas' {frmBaseMain},
  ModelSelSimForm in '..\..\Common\Forms\ModelSelSimForm.pas' {frmModelSelSim},
  EditForm in '..\Forms\EditForm.pas' {frmEdit},
  AntiPinchForm in '..\Forms\AntiPinchForm.pas' {frmAntiPinch},
  DataUnit in '..\Libs\DataUnit.pas',
  DIOChs in '..\Libs\DIOChs.pas',
  IODef in '..\Libs\IODef.pas',
  TsWorkUnit in '..\Libs\TsWorkUnit.pas',
  Work in '..\Libs\Work.pas',
  DataUnitHelper in '..\..\Common\Libs\DataUnitHelper.pas',
  ModelType in '..\..\Common\Libs\ModelType.pas',
  ModelUnit in '..\..\Common\Libs\ModelUnit.pas',
  SeatConnector in '..\..\Common\Libs\SeatConnector.pas',
  SeatMotorType in '..\..\Common\Libs\SeatMotorType.pas',
  SeatType in '..\..\Common\Libs\SeatType.pas',
  SeatTypeUI in '..\..\Common\Libs\SeatTypeUI.pas',
  SeatIMSCtrler in '..\..\Common\Libs\SeatIMSCtrler.pas',
  SeatMoveCtrler in '..\..\Common\Libs\SeatMoveCtrler.pas',
  SeatMtrCtrlForm in '..\..\Common\Forms\SeatMtrCtrlForm.pas' {frmSeatMtrCtrl},
  CanCtrlForm in '..\..\Common\Forms\CanCtrlForm.pas' {frmCanCtrl},
  CanOperForm in '..\..\Common\Forms\CanOperForm.pas' {frmCanOper},
  ReferenceForm in '..\..\Common\Forms\ReferenceForm.pas' {frmReference},
  UserReferForm in '..\..\Common\Forms\UserReferForm.pas' {frmUserRefer},
  SysEnv in '..\..\Common\Libs\SysEnv.pas',
  DataUnitOrd in '..\..\Common\Libs\DataUnitOrd.pas',
  DataBox in '..\Libs\DataBox.pas',
  AntiPinchTestFrame in '..\..\Common\Frames\AntiPinchTestFrame.pas' {AntipinchTestFrme: TFrame},
  ModelInfoFrame in '..\..\Common\Frames\ModelInfoFrame.pas' {MdllInfoFrame: TFrame},
  SubDataBox4AP in '..\..\Common\Libs\SubDataBox4AP.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'JG1 2nd AntiPinch';
  Application.CreateForm(TfrmAntiPinch, frmAntiPinch);
  Application.Run;
end.
