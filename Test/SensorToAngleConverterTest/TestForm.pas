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
        function GetValue(Channel: Integer): Double; override; // TBaseAD�� �޼ҵ� �ñ״�ó�� �°�
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
        procedure InitializeConverter; // ������ �ʱ�ȭ/���ʱ�ȭ��
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
        Result := 0.0; // ������ ����� 0 �Ǵ� ���� �߻�
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
        ShowMessage('��ȯ�� ��ü�� �ʱ�ȭ���� �ʾҽ��ϴ�.');
        Exit;
    end;

  // 1. TEdit���� �Ÿ� �� �б�
    try
        DistanceValue := StrToFloat(edtSensorDistance.Text);
    except
        on EConvertError do
        begin
            ShowMessage('��ȿ�� ����(�Ÿ� ��)�� �Է��ϼ���.');
            edtSensorDistance.SetFocus;
            Exit;
        end;
    end;

  // 2. ���� AD ��ġ�� ���� �Ÿ� �� ����
    FMockADDevice.SetMockValue(FSensorChannel, DistanceValue);

  // 3. ���� �б� (���������� mAD.GetValue ȣ��)
    if FConverter.ReadAngles then
    begin
    // 4. ���� ���� �������� (0�� ����)
        CalculatedAngle := FConverter.GetAngle(FSensorChannel);
        lblCalculatedAngle.Caption := Format('%.2f ��', [CalculatedAngle]);
    end
    else
    begin
    // �� �κ��� ���� �ڵ忡���� �����ϱ� �����
        lblCalculatedAngle.Caption := '��� ����';
    end;

end;

procedure TForm17.FormCreate(Sender: TObject);
begin
// 1. ���� TBaseAD ��ü ���� (1�� ä��)
    FMockADDevice := TMockAD.Create(1); // 1�� ä�ο� ���� ��ġ

  // ���� �׷� ������ ����
    rgConvertMode.Items.Clear;
    rgConvertMode.Items.Add('���� (Map)');
    rgConvertMode.Items.Add('�ﰢ�� (Trigonometric)');
    rgConvertMode.ItemIndex := 0; // �⺻ ����: ����

  // 2. Converter �ʱ�ȭ
    InitializeConverter;

  // UI �ʱ� �� ����
    edtSensorDistance.Text := '50'; // �⺻ �Է� �Ÿ�
    lblCalculatedAngle.Caption := '-';
end;

procedure TForm17.InitializeConverter;
var
    Channels: array of Integer;
    MapData: TDistanceAngleMapArray;
    SelectedMode: TAngleConvertMode;
begin
  // ���� �����Ͱ� ������ ����
    if Assigned(FConverter) then
        FConverter.Free;

    FSensorChannel := 0; // 0�� ä�� ���

  // ä�� ����
    SetLength(Channels, 1);
    Channels[0] := FSensorChannel;

  // UI���� ��ȯ ��� Ȯ��
    if rgConvertMode.ItemIndex = 0 then
        SelectedMode := cmMap
    else
        SelectedMode := cmTrigonometric;

  // TSensorToAngleConverter ��ü ����
  // �����ڿ��� SensorCount �Ķ���Ͱ� ���ŵ� ���� ��� (Length(Channels) ���)
    FConverter := TSensorToAngleConverter.Create(FMockADDevice, Channels, True, SelectedMode);

  // ��忡 ���� ����
    if SelectedMode = cmMap then
    begin
    // Sensor 2 (�����)�� ������ ���� ������ ���� (�Ÿ��� ���������̾�� ��)
    // (���� �Ÿ�, ū ����) ... (ū �Ÿ�, ���� ����)
        SetLength(MapData, 3);
        MapData[0].Create(20, 22.0);   // �Ÿ� 20mm => 22�� (���� ������)
        MapData[1].Create(50, 10.0);   // �Ÿ� 50mm => 10�� (�߰�)
        MapData[2].Create(100, 0.0);   // �Ÿ� 100mm => 0�� (���� ������)
        FConverter.SetDistanceAngleMap(FSensorChannel, MapData);
    end
    else // cmTrigonometric
    begin
    // �ﰢ�� �Ķ���� ���� (���� ��)
        FConverter.SetTrigonometricParams(150.0, 10.0); // BaseLength=150mm, SensorOffset=10mm
    end;
end;

procedure TForm17.rgConvertModeClick(Sender: TObject);
begin
    InitializeConverter;
    lblCalculatedAngle.Caption := '- (��� �����)';
end;

procedure TForm17.FormDestroy(Sender: TObject);
begin
    if Assigned(FConverter) then
        FConverter.Free;
    if Assigned(FMockADDevice) then
        FMockADDevice.Free;
end;

end.

