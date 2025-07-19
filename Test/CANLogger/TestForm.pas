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

        AddLogMessage('필터 ID가 추가되었습니다: 0x' + IntToHex(ID, 3));
        UpdateStatus;
    end
    else
        ShowMessage('유효한 16진수 ID를 입력하세요 (예: 123)');

end;

procedure TfrmTest.btnSaveLogClick(Sender: TObject);
var
    FileName: string;
begin
    FileName := FCANLogger.SaveToFile;

    if FileName <> '' then
        AddLogMessage('로그가 저장되었습니다: ' + FileName)
    else
        AddLogMessage('저장할 로그 데이터가 없습니다.');

end;

procedure TfrmTest.btnStartSimulClick(Sender: TObject);
begin
// CAN 시뮬레이션 시작
    FSimulCAN.Open(1, 500000); // 채널 1, 500Kbps

  // 시뮬레이션 프레임 추가
    FSimulCAN.AddSimFrame($123, [$01, $02, $03, $04, $05, $06, $07, $08], 500);
    FSimulCAN.AddSimFrame($456, [$11, $22, $33, $44, $55, $66, $77, $88], 1000);
    FSimulCAN.AddSimFrame($789, [$AA, $BB, $CC, $DD, $EE, $FF, $00, $11], 1500);

  // 에러 시뮬레이션용 프레임
    FSimulCAN.AddSimFrame($321, [$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF], 7000);

    tmrUpdate.Enabled := True;
    FErrorSimulated := False;

    btnStartSimul.Enabled := False;
    btnStopSimul.Enabled := True;

    AddLogMessage('CAN 시뮬레이션이 시작되었습니다.');
    UpdateStatus;
end;

procedure TfrmTest.btnStopSimulClick(Sender: TObject);
begin
    tmrUpdate.Enabled := False;
    FSimulCAN.Close;

    btnStartSimul.Enabled := True;
    btnStopSimul.Enabled := False;

    AddLogMessage('CAN 시뮬레이션이 중지되었습니다.');
    UpdateStatus;
end;

procedure TfrmTest.FormCreate(Sender: TObject);
begin
// 초기화
    FSimulCAN := TSimulCAN.Create(True, False);
    FCANLogger := TCANLogger.Create(60, 1000);

  // 기본 설정값 표시
  {
    edtMaxTimeSpan.Text := IntToStr(FCANLogger.MaxTimeSpan);
    edtMaxCount.Text := IntToStr(FCANLogger.MaxCount);
    edtMaxFiles.Text := IntToStr(FCANLogger.MaxFiles);
    edtSavePath.Text := FCANLogger.SavePath;
   }
  // 이벤트 핸들러 설정
    FSimulCAN.OnRead.Add(OnCANRead);

  // 타이머 설정
    tmrUpdate.Interval := 500;
    tmrUpdate.Enabled := False;

  // 상태 업데이트
    UpdateStatus;

  // 로그 메시지
    AddLogMessage('애플리케이션이 시작되었습니다.');
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
  // CAN 프레임 읽기
    FSimulCAN.Read(Frame);

  // 로거에 프레임 추가
    FCANLogger.AddFrame(Frame);

  // 에러 시뮬레이션 (특정 ID 수신 시 에러 발생)
    if (Frame.mID = $321) and not FErrorSimulated then
        SimulateError;
end;

procedure TfrmTest.UpdateStatus;
begin
    lblStatus.Caption := Format('상태: %s | 저장된 메시지: %d | 필터 ID 수: %d', [IfThen(tmrUpdate.Enabled, '실행 중', '중지됨'), FCANLogger.ItemCount, FCANLogger.FilteredIDCount]);
end;

procedure TfrmTest.SimulateError;
begin
    FErrorSimulated := True;

  // 에러 로그 메시지
    AddLogMessage('!!!! CAN 에러 발생 - ID: 0x321 !!!!');

  // 로그 저장
    btnSaveLogClick(nil);
end;

procedure TfrmTest.tmrUpdateTimer(Sender: TObject);
begin
  // CAN 읽기 실행
    FSimulCAN.Reads;

  // 상태 업데이트
    UpdateStatus;
end;

end.

