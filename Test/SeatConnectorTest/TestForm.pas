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
    mmResult.Lines.Add('===== AssignByID 테스트 시작 =====');

  // SW1 커넥터 테스트
    mmResult.Lines.Add('');
    mmResult.Lines.Add('--- SW1 커넥터 테스트 ---');
    TestAssignByID('SW1:7CELL', mSeatConnector);
    TestAssignByID('SW1:2CELL', mSeatConnector);

  // JG 커넥터 테스트
    mmResult.Lines.Add('');
    mmResult.Lines.Add('--- JG 커넥터 테스트 ---');
    TestAssignByID('JG:8CELL', mSeatConnector);
    TestAssignByID('JG:2CELL', mSeatConnector);
    TestAssignByID('JG:6CELL', mSeatConnector);

  // 존재하지 않는 ID 테스트
    mmResult.Lines.Add('');
    mmResult.Lines.Add('--- 존재하지 않는 ID 테스트 ---');
    TestAssignByID('UNKNOWN:ID', mSeatConnector);

    mmResult.Lines.Add('');
    mmResult.Lines.Add('===== AssignByID 테스트 완료 =====');

    StatusBar1.SimpleText := 'AssignByID 테스트 완료: ' + FormatDateTime('yyyy-mm-dd hh:nn:ss', Now);
end;

procedure TfrmTest.DisplayConnectorInfo(Connector: TBaseSeatConnector);
var
    i: Integer;
    PinNames: TStringList;
begin
    if Connector.IsEmpty then
    begin
        mmResult.Lines.Add('- 커넥터 정보 없음');
        Exit;
    end;

    mmResult.Lines.Add(Format('- 커넥터 이름: %s', [Connector.Name]));
    mmResult.Lines.Add(Format('- 커넥터 ID: %s', [Connector.ID]));
    mmResult.Lines.Add(Format('- 커넥터 TypeID: %d', [Connector.TypeID]));
    mmResult.Lines.Add(Format('- 핀 개수: %d', [Connector.PinCount]));

  // 특정 핀 정보 표시
    if Connector.IsSwType then
    begin
        mmResult.Lines.Add('- 스위치 타입 커넥터');

        try
            mmResult.Lines.Add(Format('- RECL_FWD_PIN: %d', [Connector.GetSpecificPinNos('RECL_FWD_PIN')[0]]));
            mmResult.Lines.Add(Format('- RECL_BWD_PIN: %d', [Connector.GetSpecificPinNos('RECL_BWD_PIN')[0]]));
        except
            on E: Exception do
                mmResult.Lines.Add('- 특정 핀 정보 없음: ' + E.Message);
        end;
    end
    else
    begin
        mmResult.Lines.Add('- 메인 타입 커넥터');
    end;

  // 핀 이름 목록 표시
    PinNames := TStringList.Create;
    try
        PinNames.Add('- 핀 이름 목록:');
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

  // 상태바 초기화
    StatusBar1.SimpleText := '준비 완료';

    rgConnectorTypeClick(nil);

end;

procedure TfrmTest.InitializeConnectorIDs;
begin
  // SW1 커넥터 ID 추가
    cmbConnectorIDs.Items.Add('SW1:7CELL');
    cmbConnectorIDs.Items.Add('SW1:2CELL');

  // JG 커넥터 ID 추가
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
        0: // 모든 커넥터
            begin
                cmbConnectorIDs.Items.Add('SW1:7CELL');
                cmbConnectorIDs.Items.Add('SW1:2CELL');
                cmbConnectorIDs.Items.Add('JG:8CELL');
                cmbConnectorIDs.Items.Add('JG:2CELL');
                cmbConnectorIDs.Items.Add('JG:6CELL');
            end;
        1: // SW1 커넥터만
            begin
                cmbConnectorIDs.Items.Add('SW1:7CELL');
                cmbConnectorIDs.Items.Add('SW1:2CELL');
            end;
        2: // JG 커넥터만
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
    mmResult.Lines.Add(Format('커넥터 ID: %s 테스트 중...', [ID]));

  // 기존 커넥터 정보 초기화
    Connector.Clear;

  // 실행 시간 측정 시작
    StartTime := Now;

  // AssignByID 실행
    Success := mSCM.AssignByID(ID, Connector);

  // 실행 시간 측정 종료
    EndTime := Now;

  // 결과 출력
    if Success then
    begin
        mmResult.Lines.Add(Format('- 성공: ID "%s" 할당 완료', [ID]));
        mmResult.Lines.Add(Format('- 실행 시간: %d ms', [MilliSecondsBetween(EndTime, StartTime)]));

        DisplayConnectorInfo(Connector);
    end
    else
    begin
        mmResult.Lines.Add(Format('- 실패: ID "%s" 할당 실패', [ID]));
        mmResult.Lines.Add(Format('- 실행 시간: %d ms', [MilliSecondsBetween(EndTime, StartTime)]));
    end;

    mmResult.Lines.Add('-------------------');
end;

end.

