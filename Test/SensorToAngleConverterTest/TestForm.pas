unit TestForm;

interface

uses
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, SensorToAngleConverter, BaseAD, ExtCtrls, StdCtrls;

type
    TMockAD = class(TBaseAD)
    private
        FMockValues: array of Double;
        function GetValueCount: Integer;
    public
        constructor Create(NumChannels: Integer);
        destructor Destroy; override;
        procedure SetMockValue(Channel: Integer; Value: Double);
        function GetValue(Channel: Integer): Double; override; // TBaseAD의 메소드 시그니처에 맞게
        property ValueCount: Integer read GetValueCount;
    end;

    TForm17 = class(TForm)
        Panel1: TPanel;
        rgConvertMode: TRadioGroup;
        btnCalculate: TButton;
        lblResult: TLabel;
        lblCalculatedAngle: TLabel;
        edtSensorDistance: TEdit;
        procedure FormCreate(Sender: TObject);
        procedure FormDestroy(Sender: TObject);
        procedure btnCalculateClick(Sender: TObject);
        procedure rgConvertModeClick(Sender: TObject);
    private
    { Private declarations }
        FConverter: TSensorToAngleConverter;
        FMockADDevice: TMockAD;
        FSensorChannel: Integer;
        procedure InitializeConverter; // 컨버터 초기화/재초기화용
    public
    { Public declarations }
    end;

var
    Form17: TForm17;

implementation

{$R *.dfm}

{ TMockAD }

constructor TMockAD.Create(NumChannels: Integer);
var
    i: Integer;
begin
    inherited Create;
    SetLength(FMockValues, NumChannels);
    for i := 0 to High(FMockValues) do
        FMockValues[i] := 0.0;
end;

destructor TMockAD.Destroy;
begin
    SetLength(FMockValues, 0);
    inherited Destroy;
end;

function TMockAD.GetValue(Channel: Integer): Double;
begin
    if (Channel >= 0) and (Channel < Length(FMockValues)) then
        Result := FMockValues[Channel]
    else
        Result := 0.0; // 범위를 벗어나면 0 또는 예외 발생
end;

procedure TMockAD.SetMockValue(Channel: Integer; Value: Double);
begin
    if (Channel >= 0) and (Channel < Length(FMockValues)) then
        FMockValues[Channel] := Value;
end;

function TMockAD.GetValueCount: Integer;
begin
    Result := Length(FMockValues);
end;

procedure TForm17.btnCalculateClick(Sender: TObject);
var
    DistanceValue: Double;
    CalculatedAngle: Double;
begin
    if not Assigned(FConverter) then
    begin
        ShowMessage('변환기 객체가 초기화되지 않았습니다.');
        Exit;
    end;

  // 1. TEdit에서 거리 값 읽기
    try
        DistanceValue := StrToFloat(edtSensorDistance.Text);
    except
        on EConvertError do
        begin
            ShowMessage('유효한 숫자(거리 값)를 입력하세요.');
            edtSensorDistance.SetFocus;
            Exit;
        end;
    end;

  // 2. 모의 AD 장치에 현재 거리 값 설정
    FMockADDevice.SetMockValue(FSensorChannel, DistanceValue);

  // 3. 각도 읽기 (내부적으로 mAD.GetValue 호출)
    if FConverter.ReadAngles then
    begin
    // 4. 계산된 각도 가져오기 (0번 센서)
        CalculatedAngle := FConverter.GetAngle(FSensorChannel);
        lblCalculatedAngle.Caption := Format('%.2f 도', [CalculatedAngle]);
    end
    else
    begin
    // 이 부분은 현재 코드에서는 도달하기 어려움
        lblCalculatedAngle.Caption := '계산 실패';
    end;

end;

procedure TForm17.FormCreate(Sender: TObject);
begin
// 1. 모의 TBaseAD 객체 생성 (1개 채널)
    FMockADDevice := TMockAD.Create(1); // 1개 채널용 모의 장치

  // 라디오 그룹 아이템 설정
    rgConvertMode.Items.Clear;
    rgConvertMode.Items.Add('맵핑 (Map)');
    rgConvertMode.Items.Add('삼각법 (Trigonometric)');
    rgConvertMode.ItemIndex := 0; // 기본 선택: 맵핑

  // 2. Converter 초기화
    InitializeConverter;

  // UI 초기 값 설정
    edtSensorDistance.Text := '50'; // 기본 입력 거리
    lblCalculatedAngle.Caption := '-';
end;

procedure TForm17.InitializeConverter;
var
    Channels: array of Integer;
    MapData: TDistanceAngleMapArray;
    SelectedMode: TAngleConvertMode;
begin
  // 기존 컨버터가 있으면 해제
    if Assigned(FConverter) then
        FConverter.Free;

    FSensorChannel := 0; // 0번 채널 사용

  // 채널 설정
    SetLength(Channels, 1);
    Channels[0] := FSensorChannel;

  // UI에서 변환 모드 확인
    if rgConvertMode.ItemIndex = 0 then
        SelectedMode := cmMap
    else
        SelectedMode := cmTrigonometric;

  // TSensorToAngleConverter 객체 생성
  // 생성자에서 SensorCount 파라미터가 제거된 버전 사용 (Length(Channels) 기반)
    FConverter := TSensorToAngleConverter.Create(FMockADDevice, Channels, True, SelectedMode);

  // 모드에 따라 설정
    if SelectedMode = cmMap then
    begin
    // Sensor 2 (등받이)와 유사한 매핑 데이터 설정 (거리가 오름차순이어야 함)
    // (작은 거리, 큰 각도) ... (큰 거리, 작은 각도)
        SetLength(MapData, 3);
        MapData[0].Create(20, 22.0);   // 거리 20mm => 22도 (가장 눕혀짐)
        MapData[1].Create(50, 10.0);   // 거리 50mm => 10도 (중간)
        MapData[2].Create(100, 0.0);   // 거리 100mm => 0도 (가장 세워짐)
        FConverter.SetDistanceAngleMap(FSensorChannel, MapData);
    end
    else // cmTrigonometric
    begin
    // 삼각법 파라미터 설정 (예시 값)
        FConverter.SetTrigonometricParams(150.0, 10.0); // BaseLength=150mm, SensorOffset=10mm
    end;
end;

procedure TForm17.rgConvertModeClick(Sender: TObject);
begin
    InitializeConverter;
    lblCalculatedAngle.Caption := '- (모드 변경됨)';
end;

procedure TForm17.FormDestroy(Sender: TObject);
begin
    if Assigned(FConverter) then
        FConverter.Free;
    if Assigned(FMockADDevice) then
        FMockADDevice.Free;
end;

end.

