{
  1. ���� ����
  --------------------------------------------------------------------------------
   ����       ���� ���                         ��ġ ����             �Ÿ� ��ȭ �ؼ�
  --------------------------------------------------------------------------------
   Sensor 1   �����(Seat Back) ���� ��ġ       ������ �Ʒ��� ����    �������� �Ÿ� ����
   Sensor 2   �����(Seat Back) ��Ŭ���̴�      �ڿ��� ������ ����   �ڷ� ������ �Ÿ� ����

  2. ���� ����
  --------------------------------------------------------------------------------
   ���� ����                 ���� ���� (����)       ���� ��� ����
  --------------------------------------------------------------------------------
   Folding Position          �� 98�� �� ���ġ       Sensor 1 �Ÿ��� ���� �� ���� ����
   Initial Position          �� 0�� �� ���ġ        Sensor 2 �Ÿ��� ���� �� ����� ����
   Middle Position           6~16��                 Sensor 2 �Ÿ��� �߰� �� ����� �߰� ��ġ
   Rearmost Position         �� 22�� �� ���ġ       Sensor 2 �Ÿ��� ���� �� ����� ���� ������ ����
}


unit SensorToAngleConverter;

interface

uses
    Classes, SysUtils, BaseAD, Math;

type
    // �Ÿ�-���� ���� ���ڵ�
    TDistanceAngleMap = record
        Distance: Double; // �Ÿ� (mm)
        Angle: Double;    // ���� (��)
        constructor Create(ADistance, AAngle: Double);
    end;

    TDistanceAngleMapArray = array of TDistanceAngleMap;

    // ��ȯ ��� ������
    TAngleConvertMode = (cmMap, cmTrigonometric);

    TSensorToAngleConverter = class
    private
        mAD: TBaseAD;
        mSensorCount: Integer;            // ���� ����
        mIsDistanceSensor: Boolean;       // True: �Ÿ� ����, False: ���� ����
        mConvertMode: TAngleConvertMode;  // ��ȯ ��� (���� �Ǵ� �ﰢ��)
        mMaps: array of TDistanceAngleMapArray; // ������ �Ÿ�-���� ����
        mBaseLength: Double;              // �ﰢ���� ���� ���� (mm)
        mSensorOffset: Double;            // �ﰢ���� ���� ������ (mm)
        mAngles: array of Double;         // ���� ���� �迭
        mChannels: array of Integer;      // �� ������ �����ϴ� ä�� ��ȣ


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

        // ���� ���� �� �ʱ�ȭ
        procedure SetDistanceAngleMap(SensorIdx: Integer; Maps: TDistanceAngleMapArray);
        procedure SetTrigonometricParams(BaseLength, SensorOffset: Double);


        // ������ �б� �� ���
        function ReadAngles: Boolean;
        function GetMinAngle: Double;
        function GetMaxAngle: Double;
        function GetAvgAngle: Double;
        function GetAngle(SensorIdx: Integer): Double;

        // �Ӽ�
        property SensorCount: Integer read mSensorCount;
        property IsDistanceSensor: Boolean read mIsDistanceSensor;
        property ConvertMode: TAngleConvertMode read mConvertMode;
    end;

implementation

const
    MIN_SENSOR_COUNT = 1;
    MAX_SENSOR_COUNT = 16;     // �ִ� ���� ���� ����
    DEFAULT_ANGLE = 0.0;       // ���� ���� �� �⺻ ����
    DEFAULT_BASE_LENGTH = 100; // �⺻ ���� ���� (mm)
    DEFAULT_SENSOR_OFFSET = 0; // �⺻ ���� ������ (mm)

{ TSensorToAngleConverter }

constructor TSensorToAngleConverter.Create(AD: TBaseAD; Channels: array of Integer; IsDistanceSensor: Boolean; ConvertMode: TAngleConvertMode);
var
    i: Integer;
    SensorCount: Integer;
begin
    inherited Create;

    SensorCount := Length(Channels);

    // �Է� ����
    if not Assigned(AD) then
        raise Exception.Create('TBaseAD ��ü�� �ʿ��մϴ�.');
    if (SensorCount < MIN_SENSOR_COUNT) or (SensorCount > MAX_SENSOR_COUNT) then
        raise Exception.Create(Format('���� ������ %d���� %d ���̿��� �մϴ�.', [MIN_SENSOR_COUNT, MAX_SENSOR_COUNT]));

    mAD := AD;
    mSensorCount := SensorCount;
    mIsDistanceSensor := IsDistanceSensor;
    mConvertMode := ConvertMode;
    mBaseLength := DEFAULT_BASE_LENGTH;
    mSensorOffset := DEFAULT_SENSOR_OFFSET;

    // �迭 �ʱ�ȭ
    SetLength(mMaps, SensorCount);
    SetLength(mAngles, SensorCount);
    SetLength(mChannels, SensorCount);

    SetChannels(Channels);

    // �⺻ ���� ���� (0mm -> 0��)
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
        raise Exception.Create('ä�� �迭 ũ�Ⱑ ���� ������ ��ġ�ؾ� �մϴ�.');

    for i := 0 to mSensorCount - 1 do
        mChannels[i] := Channels[i];
end;

destructor TSensorToAngleConverter.Destroy;
var
    i: Integer;
begin
    // ���� �迭 ����
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

    // ���� ������ ���� �� ���� (�Ÿ��� ��������)
    if Length(Maps) < 1 then
        raise Exception.Create('���� �����Ͱ� ��� �ֽ��ϴ�.');

    for i := 1 to High(Maps) do
        if Maps[i].Distance <= Maps[i - 1].Distance then
            raise Exception.Create('�Ÿ� ���� ������������ ���ĵǾ�� �մϴ�.');

    // ���� ������ ����
    mMaps[SensorIdx] := Copy(Maps, 0, Length(Maps));
end;

procedure TSensorToAngleConverter.SetTrigonometricParams(BaseLength, SensorOffset: Double);
begin
    if BaseLength <= 0 then
        raise Exception.Create('���� ���̴� ������� �մϴ�.');
    mBaseLength := BaseLength;
    mSensorOffset := SensorOffset;
end;

function TSensorToAngleConverter.ReadAngles: Boolean;
begin
    Result := True;
    // ���� Ÿ�Կ� ���� ���� ���
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
    // �Ÿ� ����: �� ä���� �Ÿ� ���� ������ ��ȯ
    for i := 0 to mSensorCount - 1 do
    begin
        Distance := mAD.GetValue(mChannels[i]); // �����κ��� �Ÿ� �� (mm)
        mAngles[i] := DistanceToAngle(Distance, i);
    end;
end;

procedure TSensorToAngleConverter.CalculateAnglesFromAngleSensor;
var
    i: Integer;
    RawValue: Double;
begin
    // ���� ����: �Ƴ��α� ���� ������ ��ȯ
    for i := 0 to mSensorCount - 1 do
    begin
        RawValue := mAD.GetValue(mChannels[i]); // �����κ��� �Ƴ��α� ��
        mAngles[i] := RawValue; // ���� �����ϸ��� ���� ���忡 ���� ���� �ʿ�
    end;
end;

function TSensorToAngleConverter.DistanceToAngle(Distance: Double; SensorIdx: Integer): Double;
begin
    // ��ȯ ��忡 ���� ó��
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

    // ���� �����Ͱ� ���ų� �ϳ��� �ִ� ���
    if Length(Maps) = 0 then
        Exit(DEFAULT_ANGLE);
    if Length(Maps) = 1 then
        Exit(Maps[0].Angle);

    // ���� ��: ù ��° ���� ���� ���
    if Distance < Maps[0].Distance then
    begin
        Slope := (Maps[1].Angle - Maps[0].Angle) / (Maps[1].Distance - Maps[0].Distance);
        Result := Maps[0].Angle + Slope * (Distance - Maps[0].Distance);
        Exit;
    end;

    // ���� ��: ������ ���� ���� ���
    if Distance > Maps[High(Maps)].Distance then
    begin
        Slope := (Maps[High(Maps)].Angle - Maps[High(Maps) - 1].Angle) / (Maps[High(Maps)].Distance - Maps[High(Maps) - 1].Distance);
        Result := Maps[High(Maps)].Angle + Slope * (Distance - Maps[High(Maps)].Distance);
        Exit;
    end;

    // ���� ������
    for i := 0 to High(Maps) - 1 do
        if (Distance >= Maps[i].Distance) and (Distance <= Maps[i + 1].Distance) then
        begin
            Slope := (Maps[i + 1].Angle - Maps[i].Angle) / (Maps[i + 1].Distance - Maps[i].Distance);
            Result := Maps[i].Angle + Slope * (Distance - Maps[i].Distance);
            Exit;
        end;

    // ���������� �������� �ʾƾ� ��
    Result := DEFAULT_ANGLE;
end;

function TSensorToAngleConverter.TrigonometricDistanceToAngle(Distance: Double): Double;
begin
    // �ﰢ��: Distance�� ��Ʈ ���������� �̵� �Ÿ���� ����
    // ���� = arctan((Distance - Offset) / BaseLength)
    // Distance: ���� ���� �Ÿ�, Offset: ���� ��ġ ������, BaseLength: ���� ����
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
        raise Exception.Create(Format('�߸��� ���� �ε���: %d', [SensorIdx]));
end;

{ TDistanceAngleMap }

constructor TDistanceAngleMap.Create(ADistance, AAngle: Double);
begin
    Distance := ADistance;
    Angle := AAngle;
end;

end.

