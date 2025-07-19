unit TestForm;

interface

uses
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, SeatConnector, StdCtrls, ExtCtrls, ComCtrls, BaseAD;

type
    TfrmTest = class(TForm)
        btnAssignSelected: TButton;
        mmResult: TMemo;
        cmbConnectorIDs: TComboBox;
        lblConnectorID: TLabel;
        StatusBar1: TStatusBar;
        rgConnectorType: TRadioGroup;
        procedure FormCreate(Sender: TObject);
        procedure FormClose(Sender: TObject; var Action: TCloseAction);
        procedure rgConnectorTypeClick(Sender: TObject);
        procedure btnAssignSelectedClick(Sender: TObject);
    private
    { Private declarations }
        mSCM: TSeatConManager;
        mSeatConnector: TSeatConnector;
        mAD: TSimulAD;
    public
    { Public declarations }
        procedure InitializeConnectorIDs;
        procedure TestAssignByID(ID: string; Connector: TBaseSeatConnector);
        procedure DisplayConnectorInfo(Connector: TBaseSeatConnector);
    end;

var
    frmTest: TfrmTest;

implementation

uses
    DateUtils;

{$R *.dfm}

procedure TfrmTest.btnAssignSelectedClick(Sender: TObject);
begin
    mmResult.Clear;
    mmResult.Lines.Add('===== AssignByID �׽�Ʈ ���� =====');

  // SW1 Ŀ���� �׽�Ʈ
    mmResult.Lines.Add('');
    mmResult.Lines.Add('--- SW1 Ŀ���� �׽�Ʈ ---');
    TestAssignByID('SW1:7CELL', mSeatConnector);
    TestAssignByID('SW1:2CELL', mSeatConnector);

  // JG Ŀ���� �׽�Ʈ
    mmResult.Lines.Add('');
    mmResult.Lines.Add('--- JG Ŀ���� �׽�Ʈ ---');
    TestAssignByID('JG:8CELL', mSeatConnector);
    TestAssignByID('JG:2CELL', mSeatConnector);
    TestAssignByID('JG:6CELL', mSeatConnector);

  // �������� �ʴ� ID �׽�Ʈ
    mmResult.Lines.Add('');
    mmResult.Lines.Add('--- �������� �ʴ� ID �׽�Ʈ ---');
    TestAssignByID('UNKNOWN:ID', mSeatConnector);

    mmResult.Lines.Add('');
    mmResult.Lines.Add('===== AssignByID �׽�Ʈ �Ϸ� =====');

    StatusBar1.SimpleText := 'AssignByID �׽�Ʈ �Ϸ�: ' + FormatDateTime('yyyy-mm-dd hh:nn:ss', Now);
end;

procedure TfrmTest.DisplayConnectorInfo(Connector: TBaseSeatConnector);
var
    i: Integer;
    PinNames: TStringList;
begin
    if Connector.IsEmpty then
    begin
        mmResult.Lines.Add('- Ŀ���� ���� ����');
        Exit;
    end;

    mmResult.Lines.Add(Format('- Ŀ���� �̸�: %s', [Connector.Name]));
    mmResult.Lines.Add(Format('- Ŀ���� ID: %s', [Connector.ID]));
    mmResult.Lines.Add(Format('- Ŀ���� TypeID: %d', [Connector.TypeID]));
    mmResult.Lines.Add(Format('- �� ����: %d', [Connector.PinCount]));

  // Ư�� �� ���� ǥ��
    if Connector.IsSwType then
    begin
        mmResult.Lines.Add('- ����ġ Ÿ�� Ŀ����');

        try
            mmResult.Lines.Add(Format('- RECL_FWD_PIN: %d', [Connector.GetSpecificPinNos('RECL_FWD_PIN')[0]]));
            mmResult.Lines.Add(Format('- RECL_BWD_PIN: %d', [Connector.GetSpecificPinNos('RECL_BWD_PIN')[0]]));
        except
            on E: Exception do
                mmResult.Lines.Add('- Ư�� �� ���� ����: ' + E.Message);
        end;
    end
    else
    begin
        mmResult.Lines.Add('- ���� Ÿ�� Ŀ����');
    end;

  // �� �̸� ��� ǥ��
    PinNames := TStringList.Create;
    try
        PinNames.Add('- �� �̸� ���:');
        for i := 0 to Connector.PinCount - 1 do
        begin
            PinNames.Add(Format('  Pin %d: %s', [i + 1, Connector.Pins[i + 1].mName]));
        end;
        mmResult.Lines.AddStrings(PinNames);

    finally
        PinNames.Free;
    end;

end;

procedure TfrmTest.FormClose(Sender: TObject; var Action: TCloseAction);
begin

    mAD.Free;
    mSeatConnector.Free;
    mSCM.Free;
end;

procedure TfrmTest.FormCreate(Sender: TObject);
begin
    mSCM := TSeatConManager.Create;
    mSCM.AddCarTypePaths(['SW1', 'JG'], ['SW.json', 'JG.json'], False);

    mAD := TSimulAD.Create();

    mSeatConnector := TSeatConnector.Create(mAD, 0);
    InitializeConnectorIDs;

  // ���¹� �ʱ�ȭ
    StatusBar1.SimpleText := '�غ� �Ϸ�';

    rgConnectorTypeClick(nil);

end;

procedure TfrmTest.InitializeConnectorIDs;
begin
  // SW1 Ŀ���� ID �߰�
    cmbConnectorIDs.Items.Add('SW1:7CELL');
    cmbConnectorIDs.Items.Add('SW1:2CELL');

  // JG Ŀ���� ID �߰�
    cmbConnectorIDs.Items.Add('JG:8CELL');
    cmbConnectorIDs.Items.Add('JG:2CELL');
    cmbConnectorIDs.Items.Add('JG:6CELL');

    if cmbConnectorIDs.Items.Count > 0 then
        cmbConnectorIDs.ItemIndex := 0;
end;

procedure TfrmTest.rgConnectorTypeClick(Sender: TObject);
begin
    cmbConnectorIDs.Items.Clear;

    case rgConnectorType.ItemIndex of
        0: // ��� Ŀ����
            begin
                cmbConnectorIDs.Items.Add('SW1:7CELL');
                cmbConnectorIDs.Items.Add('SW1:2CELL');
                cmbConnectorIDs.Items.Add('JG:8CELL');
                cmbConnectorIDs.Items.Add('JG:2CELL');
                cmbConnectorIDs.Items.Add('JG:6CELL');
            end;
        1: // SW1 Ŀ���͸�
            begin
                cmbConnectorIDs.Items.Add('SW1:7CELL');
                cmbConnectorIDs.Items.Add('SW1:2CELL');
            end;
        2: // JG Ŀ���͸�
            begin
                cmbConnectorIDs.Items.Add('JG:8CELL');
                cmbConnectorIDs.Items.Add('JG:2CELL');
                cmbConnectorIDs.Items.Add('JG:6CELL');
            end;
    end;
end;

procedure TfrmTest.TestAssignByID(ID: string; Connector: TBaseSeatConnector);
var
    StartTime, EndTime: TDateTime;
    Success: Boolean;
begin
    mmResult.Lines.Add(Format('Ŀ���� ID: %s �׽�Ʈ ��...', [ID]));

  // ���� Ŀ���� ���� �ʱ�ȭ
    Connector.Clear;

  // ���� �ð� ���� ����
    StartTime := Now;

  // AssignByID ����
    Success := mSCM.AssignByID(ID, Connector);

  // ���� �ð� ���� ����
    EndTime := Now;

  // ��� ���
    if Success then
    begin
        mmResult.Lines.Add(Format('- ����: ID "%s" �Ҵ� �Ϸ�', [ID]));
        mmResult.Lines.Add(Format('- ���� �ð�: %d ms', [MilliSecondsBetween(EndTime, StartTime)]));

        DisplayConnectorInfo(Connector);
    end
    else
    begin
        mmResult.Lines.Add(Format('- ����: ID "%s" �Ҵ� ����', [ID]));
        mmResult.Lines.Add(Format('- ���� �ð�: %d ms', [MilliSecondsBetween(EndTime, StartTime)]));
    end;

    mmResult.Lines.Add('-------------------');
end;

end.

