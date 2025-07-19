program LimitTester;

uses
  Forms,
  EditForm in '..\Forms\EditForm.pas' {frmEdit},
  DataUnit in '..\Libs\DataUnit.pas',
  DIOChs in '..\Libs\DIOChs.pas',
  IODef in '..\Libs\IODef.pas',
  TsWorkUnit in '..\Libs\TsWorkUnit.pas',
  Work in '..\Libs\Work.pas',
  DataUnitHelper in '..\..\Common\Libs\DataUnitHelper.pas',
  Global in '..\..\Common\Libs\Global.pas',
  ModelType in '..\..\Common\Libs\ModelType.pas',
  ModelUnit in '..\..\Common\Libs\ModelUnit.pas',
  SeatConnector in '..\..\Common\Libs\SeatConnector.pas',
  SeatType in '..\..\Common\Libs\SeatType.pas',
  SeatTypeUI in '..\..\Common\Libs\SeatTypeUI.pas',
  SubDataBox4IMS in '..\..\Common\Libs\SubDataBox4IMS.pas',
  SeatMotorType in '..\..\Common\Libs\SeatMotorType.pas',
  LimitForm in '..\Forms\LimitForm.pas' {frmLimit},
  SeatIMSCtrler in '..\..\Common\Libs\SeatIMSCtrler.pas',
  SeatMoveCtrler in '..\..\Common\Libs\SeatMoveCtrler.pas',
  SeatMtrCtrlForm in '..\..\Common\Forms\SeatMtrCtrlForm.pas' {frmSeatMtrCtrl},
  UserModelForm in '..\..\Common\Forms\UserModelForm.pas' {frmUserModel},
  UserReferForm in '..\..\Common\Forms\UserReferForm.pas' {frmUserRefer},
  ReferenceForm in '..\..\Common\Forms\ReferenceForm.pas' {frmReference},
  SysEnv in '..\..\Common\Libs\SysEnv.pas',
  CanCtrlForm in '..\..\Common\Forms\CanCtrlForm.pas' {frmCanCtrl},
  CanOperForm in '..\..\Common\Forms\CanOperForm.pas' {frmCanOper},
  DataUnitOrd in '..\..\Common\Libs\DataUnitOrd.pas',
  PopWork in '..\..\Common\Libs\PopWork.pas',
  DataBox in '..\Libs\DataBox.pas',
  AlignSpecFrame in '..\..\Common\Frames\AlignSpecFrame.pas' {AlignSpecFrme: TFrame},
  ModelInfoFrame in '..\..\Common\Frames\ModelInfoFrame.pas' {MdllInfoFrame: TFrame},
  ModelSelSimForm in '..\..\Common\Forms\ModelSelSimForm.pas' {frmModelSelSim},
  UDSDef in '..\..\Common\Libs\UDSDef.pas',
  JG1SeatIMSCtrler in '..\..\Common\Libs\JG1SeatIMSCtrler.pas',
  PeriodicCanData in '..\..\Common\Libs\PeriodicCanData.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'JG1 2nd Limit';
  Application.CreateForm(TfrmLimit, frmLimit);
  Application.Run;
end.
