program SoundProofTester;

uses
  Forms,
  BaseMainForm in '..\..\Common\Forms\BaseMainForm.pas' {frmBaseMain},
  ModelSelSimForm in '..\..\Common\Forms\ModelSelSimForm.pas' {frmModelSelSim},
  EditForm in '..\Forms\EditForm.pas' {frmEdit},
  SoundProofForm in '..\Forms\SoundProofForm.pas' {frmSoundProof},
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
  SeatMotorType in '..\..\Common\Libs\SeatMotorType.pas',
  SeatType in '..\..\Common\Libs\SeatType.pas',
  SeatTypeUI in '..\..\Common\Libs\SeatTypeUI.pas',
  SubDataBox4Elec in '..\..\Common\Libs\SubDataBox4Elec.pas',
  SubDataBox4IMS in '..\..\Common\Libs\SubDataBox4IMS.pas',
  SubDataBox4Mtr in '..\..\Common\Libs\SubDataBox4Mtr.pas',
  SeatIMSCtrler in '..\..\Common\Libs\SeatIMSCtrler.pas',
  SeatMoveCtrler in '..\..\Common\Libs\SeatMoveCtrler.pas',
  SeatMtrCtrlForm in '..\..\Common\Forms\SeatMtrCtrlForm.pas' {frmSeatMtrCtrl},
  CanCtrlForm in '..\..\Common\Forms\CanCtrlForm.pas' {frmCanCtrl},
  CanOperForm in '..\..\Common\Forms\CanOperForm.pas' {frmCanOper},
  ReferenceForm in '..\..\Common\Forms\ReferenceForm.pas' {frmReference},
  SysEnv in '..\..\Common\Libs\SysEnv.pas',
  ECUVerListForm in '..\Forms\ECUVerListForm.pas' {frmECUVerList},
  DataUnitOrd in '..\..\Common\Libs\DataUnitOrd.pas',
  DataBox in '..\Libs\DataBox.pas',
  HVDataFrame in '..\..\Common\Frames\HVDataFrame.pas' {HVDatFrame: TFrame},
  AlignSpecFrame in '..\..\Common\Frames\AlignSpecFrame.pas' {AlignSpecFrme: TFrame},
  ModelInfoFrame in '..\..\Common\Frames\ModelInfoFrame.pas' {MdllInfoFrame: TFrame},
  MotorSpecFrame in '..\..\Common\Frames\MotorSpecFrame.pas' {MtrSpecFrame: TFrame},
  SeatMtrTestFrame in '..\..\..\Common\Form\SeatMtrTestFrame.pas' {SeatMtrTestFrme: TFrame},
  UserReferForm in '..\..\Common\Forms\UserReferForm.pas' {frmUserRefer},
  ReferBaseForm in '..\..\..\Common\Form\ReferBaseForm.pas' {frmReferBase};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'JG1 2nd SoundProofRoom';
  Application.CreateForm(TfrmSoundProof, frmSoundProof);
  Application.Run;
end.
