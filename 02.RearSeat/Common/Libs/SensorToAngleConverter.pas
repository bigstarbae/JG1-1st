{
  1. 센서 정보
  --------------------------------------------------------------------------------
   센서       측정 대상                         설치 방향             거리 변화 해석
  --------------------------------------------------------------------------------
   Sensor 1   등받이(Seat Back) 폴딩 위치       위에서 아래로 수직    접힐수록 거리 증가
   Sensor 2   등받이(Seat Back) 리클라이닝      뒤에서 앞으로 수평   뒤로 갈수록 거리 감소

  2. 동작 상태
  --------------------------------------------------------------------------------
   동작 상태                 각도 기준 (예시)       센서 기반 설명
  --------------------------------------------------------------------------------
   Folding Position          약 98도 ± 허용치       Sensor 1 거리값 증가 → 접힘 상태
   Initial Position          약 0도 ± 허용치        Sensor 2 거리값 증가 → 등받이 직각
   Middle Position           6~16도                 Sensor 2 거리값 중간 → 등받이 중간 위치
   Rearmost Position         약 22도 ± 허용치       Sensor 2 거리값 감소 → 등받이 가장 눕혀진 상태
}


unit SensorToAngleConverter;

interface

uses
    Classes, SysUtils, BaseAD, Math;

type
    // 거리-각도 매핑 레코드
    TDistanceAngleMap = record
        Distance: Double; // 거리 (mm)
        Angle: Double;    // 각도 (도)
        constructor Create(ADistance, AAngle: Double);
    end;

    TDistanceAngleMapArray = array of TDistanceAngleMap;

    // 변환 모드 열거형
    TAngleConvertMode = (cmMap, cmTrigonometric);

    TSensorToAngleConverter = class
    private
        mAD: TBaseAD;
        mSensorCount: Integer;            // 센서 개수
        mIsDistanceSensor: Boolean;       // True: 거리 센서, False: 각도 센서
        mConvertMode: TAngleConvertMode;  // 변환 모드 (매핑 또는 삼각법)
        mMaps: array of TDistanceAngleMapArray; // 센서별 거리-각도 매핑
        mBaseLength: Double;              // 삼각법용 기준 길이 (mm)
        mSensorOffset: Double;            // 삼각법용 센서 오프셋 (mm)
        mAngles: array of Double;         // 계산된 각도 배열
        mChannels: array of Integer;      // 각 센서에 대응하는 채널 번호


        procedure ValidateSensorIndex(SensorIdx: Integer);


        procedure CalculateAnglesFromDistance;
        procedure CalculateAnglesFromAngleSensor;

        function DistanceToAngle(Distance: Double; SensorIdx: Integer): Double;
        function MapDistanceToAngle(Distance: Double; SensorIdx: Integer): Double;
        function TrigonometricDistanceToAngle(Distance: Double): Double;


    public
        constructor Create(AD: TBaseAD; Channels: array of Integer; IsDistanceSensor: Boolean = True; ConvertMode: TAngleConvertMode = cmMap);
        destructor Destroy; override;

        procedure SetChannels(Channels: array of Integer);

        // 센서 설정 및 초기화
        procedure SetDistanceAngleMap(SensorIdx: Integer; Maps: TDistanceAngleMapArray);
        procedure SetTrigonometricParams(BaseLength, SensorOffset: Double);


        // 데이터 읽기 및 계산
        function ReadAngles: Boolean;
        function GetMinAngle: Double;
        function GetMaxAngle: Double;
        function GetAvgAngle: Double;
        function GetAngle(SensorIdx: Integer): Double;

        // 속성
        property SensorCount: Integer read mSensorCount;
        property IsDistanceSensor: Boolean read mIsDistanceSensor;
        property ConvertMode: TAngleConvertMode read mConvertMode;
    end;

implementation

const
    MIN_SENSOR_COUNT = 1;
    MAX_SENSOR_COUNT = 16;     // 최대 센서 개수 제한
    DEFAULT_ANGLE = 0.0;       // 매핑 실패 시 기본 각도
    DEFAULT_BASE_LENGTH = 100; // 기본 기준 길이 (mm)
    DEFAULT_SENSOR_OFFSET = 0; // 기본 센서 오프셋 (mm)

{ TSensorToAngleConverter }

constructor TSensorToAngleConverter.Create(AD: TBaseAD; Channels: array of Integer; IsDistanceSensor: Boolean; ConvertMode: TAngleConvertMode);
var
    i: Integer;
    SensorCount: Integer;
begin
    inherited Create;

    SensorCount := Length(Channels);

    // 입력 검증
    if not Assigned(AD) then
        raise Exception.Create('TBaseAD 객체가 필요합니다.');
    if (SensorCount < MIN_SENSOR_COUNT) or (SensorCount > MAX_SENSOR_COUNT) then
        raise Exception.Create(Format('센서 개수는 %d에서 %d 사이여야 합니다.', [MIN_SENSOR_COUNT, MAX_SENSOR_COUNT]));

    mAD := AD;
    mSensorCount := SensorCount;
    mIsDistanceSensor := IsDistanceSensor;
    mConvertMode := ConvertMode;
    mBaseLength := DEFAULT_BASE_LENGTH;
    mSensorOffset := DEFAULT_SENSOR_OFFSET;

    // 배열 초기화
    SetLength(mMaps, SensorCount);
    SetLength(mAngles, SensorCount);
    SetLength(mChannels, SensorCount);

    SetChannels(Channels);

    // 기본 매핑 설정 (0mm -> 0도)
    for i := 0 to SensorCount - 1 do
    begin
        SetLength(mMaps[i], 1);
        mMaps[i][0].Distance := 0;
        mMaps[i][0].Angle := 0;
    end;


end;

procedure TSensorToAngleConverter.SetChannels(Channels: array of Integer);
var
    i: Integer;
begin
    if Length(Channels) <> mSensorCount then
        raise Exception.Create('채널 배열 크기가 센서 개수와 일치해야 합니다.');

    for i := 0 to mSensorCount - 1 do
        mChannels[i] := Channels[i];
end;

destructor TSensorToAngleConverter.Destroy;
var
    i: Integer;
begin
    // 매핑 배열 해제
    for i := 0 to mSensorCount - 1 do
        SetLength(mMaps[i], 0);
    SetLength(mMaps, 0);
    SetLength(mAngles, 0);

    inherited Destroy;
end;

procedure TSensorToAngleConverter.SetDistanceAngleMap(SensorIdx: Integer; Maps: TDistanceAngleMapArray);
var
    i: Integer;
begin
    ValidateSensorIndex(SensorIdx);

    // 매핑 데이터 검증 및 정렬 (거리가 오름차순)
    if Length(Maps) < 1 then
        raise Exception.Create('매핑 데이터가 비어 있습니다.');

    for i := 1 to High(Maps) do
        if Maps[i].Distance <= Maps[i - 1].Distance then
            raise Exception.Create('거리 값은 오름차순으로 정렬되어야 합니다.');

    // 매핑 데이터 설정
    mMaps[SensorIdx] := Copy(Maps, 0, Length(Maps));
end;

procedure TSensorToAngleConverter.SetTrigonometricParams(BaseLength, SensorOffset: Double);
begin
    if BaseLength <= 0 then
        raise Exception.Create('기준 길이는 양수여야 합니다.');
    mBaseLength := BaseLength;
    mSensorOffset := SensorOffset;
end;

function TSensorToAngleConverter.ReadAngles: Boolean;
begin
    Result := True;
    // 센서 타입에 따라 각도 계산
    if mIsDistanceSensor then
        CalculateAnglesFromDistance
    else
        CalculateAnglesFromAngleSensor;
end;

procedure TSensorToAngleConverter.CalculateAnglesFromDistance;
var
    i: Integer;
    Distance: Double;
begin
    // 거리 센서: 각 채널의 거리 값을 각도로 변환
    for i := 0 to mSensorCount - 1 do
    begin
        Distance := mAD.GetValue(mChannels[i]); // 센서로부터 거리 값 (mm)
        mAngles[i] := DistanceToAngle(Distance, i);
    end;
end;

procedure TSensorToAngleConverter.CalculateAnglesFromAngleSensor;
var
    i: Integer;
    RawValue: Double;
begin
    // 각도 센서: 아날로그 값을 각도로 변환
    for i := 0 to mSensorCount - 1 do
    begin
        RawValue := mAD.GetValue(mChannels[i]); // 센서로부터 아날로그 값
        mAngles[i] := RawValue; // 실제 스케일링은 센서 스펙에 따라 조정 필요
    end;
end;

function TSensorToAngleConverter.DistanceToAngle(Distance: Double; SensorIdx: Integer): Double;
begin
    // 변환 모드에 따라 처리
    if mConvertMode = cmTrigonometric then
        Result := TrigonometricDistanceToAngle(Distance)
    else
        Result := MapDistanceToAngle(Distance, SensorIdx);
end;

function TSensorToAngleConverter.MapDistanceToAngle(Distance: Double; SensorIdx: Integer): Double;
var
    Maps: TDistanceAngleMapArray;
    i: Integer;
    Slope: Double;
begin
    Maps := mMaps[SensorIdx];

    // 매핑 데이터가 없거나 하나만 있는 경우
    if Length(Maps) = 0 then
        Exit(DEFAULT_ANGLE);
    if Length(Maps) = 1 then
        Exit(Maps[0].Angle);

    // 범위 밖: 첫 번째 구간 기울기 사용
    if Distance < Maps[0].Distance then
    begin
        Slope := (Maps[1].Angle - Maps[0].Angle) / (Maps[1].Distance - Maps[0].Distance);
        Result := Maps[0].Angle + Slope * (Distance - Maps[0].Distance);
        Exit;
    end;

    // 범위 밖: 마지막 구간 기울기 사용
    if Distance > Maps[High(Maps)].Distance then
    begin
        Slope := (Maps[High(Maps)].Angle - Maps[High(Maps) - 1].Angle) / (Maps[High(Maps)].Distance - Maps[High(Maps) - 1].Distance);
        Result := Maps[High(Maps)].Angle + Slope * (Distance - Maps[High(Maps)].Distance);
        Exit;
    end;

    // 선형 보간법
    for i := 0 to High(Maps) - 1 do
        if (Distance >= Maps[i].Distance) and (Distance <= Maps[i + 1].Distance) then
        begin
            Slope := (Maps[i + 1].Angle - Maps[i].Angle) / (Maps[i + 1].Distance - Maps[i].Distance);
            Result := Maps[i].Angle + Slope * (Distance - Maps[i].Distance);
            Exit;
        end;

    // 예외적으로 도달하지 않아야 함
    Result := DEFAULT_ANGLE;
end;

function TSensorToAngleConverter.TrigonometricDistanceToAngle(Distance: Double): Double;
begin
    // 삼각법: Distance가 시트 백프레임의 이동 거리라고 가정
    // 각도 = arctan((Distance - Offset) / BaseLength)
    // Distance: 센서 측정 거리, Offset: 센서 위치 오프셋, BaseLength: 기준 길이
    if mBaseLength = 0 then
        Exit(DEFAULT_ANGLE);

    Result := RadToDeg(ArcTan((Distance - mSensorOffset) / mBaseLength));
end;

function TSensorToAngleConverter.GetMinAngle: Double;
var
    i: Integer;
begin
    if mSensorCount = 0 then
    begin
        Result := 0;
        Exit;
    end;

    Result := mAngles[0];
    for i := 1 to mSensorCount - 1 do
        if mAngles[i] < Result then
            Result := mAngles[i];
end;

function TSensorToAngleConverter.GetMaxAngle: Double;
var
    i: Integer;
begin
    if mSensorCount = 0 then
    begin
        Result := 0;
        Exit;
    end;

    Result := mAngles[0];
    for i := 1 to mSensorCount - 1 do
        if mAngles[i] > Result then
            Result := mAngles[i];
end;

function TSensorToAngleConverter.GetAvgAngle: Double;
var
    i: Integer;
    Sum: Double;
begin
    if mSensorCount = 0 then
    begin
        Result := 0;
        Exit;
    end;

    Sum := 0;
    for i := 0 to mSensorCount - 1 do
        Sum := Sum + mAngles[i];

    Result := Sum / mSensorCount;
end;

function TSensorToAngleConverter.GetAngle(SensorIdx: Integer): Double;
begin
    ValidateSensorIndex(SensorIdx);
    Result := mAngles[SensorIdx];
end;

procedure TSensorToAngleConverter.ValidateSensorIndex(SensorIdx: Integer);
begin
    if (SensorIdx < 0) or (SensorIdx >= mSensorCount) then
        raise Exception.Create(Format('잘못된 센서 인덱스: %d', [SensorIdx]));
end;

{ TDistanceAngleMap }

constructor TDistanceAngleMap.Create(ADistance, AAngle: Double);
begin
    Distance := ADistance;
    Angle := AAngle;
end;

end.

