unit TestForm;

interface

uses
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, BaseCAN, CANLogger, ExtCtrls, StdCtrls;

type
    TfrmTest = class(TForm)
        btnStartSimul: TButton;
        btnStopSimul: TButton;
        btnSaveLog: TButton;
        mmoLog: TMemo;
        lblStatus: TLabel;
        edtFilterIDs: TEdit;
        btnAddFilter: TButton;
        tmrUpdate: TTimer;
    lstFilterIDs: TListBox;
        procedure FormCreate(Sender: TObject);
        procedure FormDestroy(Sender: TObject);
        procedure btnSaveLogClick(Sender: TObject);
        procedure btnStartSimulClick(Sender: TObject);
        procedure btnStopSimulClick(Sender: TObject);
        procedure tmrUpdateTimer(Sender: TObject);
        procedure btnAddFilterClick(Sender: TObject);
    private
    { Private declarations }
        FSimulCAN: TSimulCAN;
        FCANLogger: TCANLogger;
        FTimer: TTimer;
        FErrorSimulated: Boolean;

        procedure OnCANRead(Sender: TObject);
        procedure AddLogMessage(const Msg: string);
        procedure SimulateError;
        procedure UpdateStatus;

    public
    { Public declarations }
    end;

var
    frmTest: TfrmTest;

implementation

uses
    StrUtils;

{$R *.dfm}

procedure TfrmTest.btnAddFilterClick(Sender: TObject);
var
    ID: Integer;
begin
    if TryStrToInt('$' + edtFilterIDs.Text, ID) then
    begin
        FCANLogger.AddFilterID(ID);
        lstFilterIDs.Items.Add('0x' + IntToHex(ID, 3));
        edtFilterIDs.Clear;

        AddLogMessage('���� ID�� �߰��Ǿ����ϴ�: 0x' + IntToHex(ID, 3));
        UpdateStatus;
    end
    else
        ShowMessage('��ȿ�� 16���� ID�� �Է��ϼ��� (��: 123)');

end;

procedure TfrmTest.btnSaveLogClick(Sender: TObject);
var
    FileName: string;
begin
    FileName := FCANLogger.SaveToFile;

    if FileName <> '' then
        AddLogMessage('�αװ� ����Ǿ����ϴ�: ' + FileName)
    else
        AddLogMessage('������ �α� �����Ͱ� �����ϴ�.');

end;

procedure TfrmTest.btnStartSimulClick(Sender: TObject);
begin
// CAN �ùķ��̼� ����
    FSimulCAN.Open(1, 500000); // ä�� 1, 500Kbps

  // �ùķ��̼� ������ �߰�
    FSimulCAN.AddSimFrame($123, [$01, $02, $03, $04, $05, $06, $07, $08], 500);
    FSimulCAN.AddSimFrame($456, [$11, $22, $33, $44, $55, $66, $77, $88], 1000);
    FSimulCAN.AddSimFrame($789, [$AA, $BB, $CC, $DD, $EE, $FF, $00, $11], 1500);

  // ���� �ùķ��̼ǿ� ������
    FSimulCAN.AddSimFrame($321, [$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF], 7000);

    tmrUpdate.Enabled := True;
    FErrorSimulated := False;

    btnStartSimul.Enabled := False;
    btnStopSimul.Enabled := True;

    AddLogMessage('CAN �ùķ��̼��� ���۵Ǿ����ϴ�.');
    UpdateStatus;
end;

procedure TfrmTest.btnStopSimulClick(Sender: TObject);
begin
    tmrUpdate.Enabled := False;
    FSimulCAN.Close;

    btnStartSimul.Enabled := True;
    btnStopSimul.Enabled := False;

    AddLogMessage('CAN �ùķ��̼��� �����Ǿ����ϴ�.');
    UpdateStatus;
end;

procedure TfrmTest.FormCreate(Sender: TObject);
begin
// �ʱ�ȭ
    FSimulCAN := TSimulCAN.Create(True, False);
    FCANLogger := TCANLogger.Create(60, 1000);

  // �⺻ ������ ǥ��
  {
    edtMaxTimeSpan.Text := IntToStr(FCANLogger.MaxTimeSpan);
    edtMaxCount.Text := IntToStr(FCANLogger.MaxCount);
    edtMaxFiles.Text := IntToStr(FCANLogger.MaxFiles);
    edtSavePath.Text := FCANLogger.SavePath;
   }
  // �̺�Ʈ �ڵ鷯 ����
    FSimulCAN.OnRead.Add(OnCANRead);

  // Ÿ�̸� ����
    tmrUpdate.Interval := 500;
    tmrUpdate.Enabled := False;

  // ���� ������Ʈ
    UpdateStatus;

  // �α� �޽���
    AddLogMessage('���ø����̼��� ���۵Ǿ����ϴ�.');
end;

procedure TfrmTest.FormDestroy(Sender: TObject);
begin
    tmrUpdate.Enabled := False;

    if Assigned(FSimulCAN) then
    begin
        FSimulCAN.OnRead.Remove(OnCANRead);
        FSimulCAN.Free;
    end;

    if Assigned(FCANLogger) then
        FCANLogger.Free;
end;

procedure TfrmTest.AddLogMessage(const Msg: string);
begin
    mmoLog.Lines.Add(FormatDateTime('[yyyy-mm-dd hh:nn:ss] ', Now) + Msg);
    mmoLog.SelStart := Length(mmoLog.Text);
    mmoLog.SelLength := 0;
end;

procedure TfrmTest.OnCANRead(Sender: TObject);
var
    Frame: TCANFrame;
begin
  // CAN ������ �б�
    FSimulCAN.Read(Frame);

  // �ΰſ� ������ �߰�
    FCANLogger.AddFrame(Frame);

  // ���� �ùķ��̼� (Ư�� ID ���� �� ���� �߻�)
    if (Frame.mID = $321) and not FErrorSimulated then
        SimulateError;
end;

procedure TfrmTest.UpdateStatus;
begin
    lblStatus.Caption := Format('����: %s | ����� �޽���: %d | ���� ID ��: %d', [IfThen(tmrUpdate.Enabled, '���� ��', '������'), FCANLogger.ItemCount, FCANLogger.FilteredIDCount]);
end;

procedure TfrmTest.SimulateError;
begin
    FErrorSimulated := True;

  // ���� �α� �޽���
    AddLogMessage('!!!! CAN ���� �߻� - ID: 0x321 !!!!');

  // �α� ����
    btnSaveLogClick(nil);
end;

procedure TfrmTest.tmrUpdateTimer(Sender: TObject);
begin
  // CAN �б� ����
    FSimulCAN.Reads;

  // ���� ������Ʈ
    UpdateStatus;
end;

end.

