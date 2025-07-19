unit MotorCurrentGuard;

interface

uses
    SysUtils, Classes, Windows, Math;

type
    // ���� ����: � ���ǿ� ���� �����ϰ� �����Ǿ����� ��Ÿ���ϴ�.
    TDetectionType = (dtNone, dtCurrentRate, dtRelativeRise, dtAbsoluteOverload, dtMaxRise);

    // �̺�Ʈ �ڵ鷯 Ÿ��: �����ϰ� ���� �����Ǿ��� �� ȣ��˴ϴ�.
    TCurrentGuardEvent = procedure(Sender: TObject; Detection: TDetectionType) of object;

    {
      TMotorCurrentGuard Ŭ����
      ������ ������ ���������� �����Ͽ� ����(Stall) �Ǵ� ������ ���¸� �����մϴ�.
      - �ǽð� dI/dt (���� ��ȭ��) ���
      - �̵� ��� ����� �����, ������ ������ ����
      - �ʱ� �⵿ ���� �н��� ���� ���� �Ӱ谪 ����
      - ��Ž���� �����ϱ� ���� Ȧ��(Hold) �� �����׸��ý�(Hysteresis) ���� ����
    }
    TMotorCurrentGuard = class
    private
        FBuffer: array of Double;       // ���� �� ������ ���� ��ȯ ����
        FBufferSum: Double;             // ���� �� ���� ���� ���� (��� ��� ����ȭ��)
        FBufferSize: Integer;           // ������ ũ��
        FBufferIdx: Integer;            // ���� ���� �ε���
        FBufferCount: Integer;          // ���ۿ� ����� ���� ������ ��

        FEarlyMax: Double;              // �ʱ� �⵿ ������ �ִ� ����
        FEarlySum: Double;              // �ʱ� �⵿ ������ ���� �հ�
        FEarlySampleCount: Integer;     // �ʱ� �⵿ ������ ���� ��

        FStartTick: Cardinal;           // ���� ���� �ð�
        FHoldStartTick: Cardinal;       // ������ ���� ���� ���� �ð�
        FHoldDetected: Boolean;         // ������ ������ �Ͻ������� �����Ǿ����� ����
        FDetected: Boolean;             // �����ϰ� ���������� Ȯ���Ǿ����� ����

        FLastCurrent: Double;           // ���������� �Էµ� ���� ��
        FLastTick: Cardinal;            // ������ FeedCurrent ȣ�� �ð�
        FDetectionType: TDetectionType; // ���� ������ ����

        // ���� �Ķ����
        FAvgWinMs: Integer;
        FRelRisePerc: Double;
        FAbsOverload: Double;
        FMaxRisePerc: Double;
        FHoldTimeMs: Integer;
        FEarlyWindowMs: Integer;
        FDIdtThreshold: Double;
        FReleaseThreshold: Double;
        FInitialDIdtThreshold: Double;  // ���� ������ ���� �ʱ� DIdtThreshold �� ����

        // �̺�Ʈ
        FOnDetected: TCurrentGuardEvent;

        procedure ResetEarly;
        function GetAvgCurrent: Double;
        function GetEarlyMax: Double;
        function GetEarlyAvg: Double;
    public
        {
          ������
          aAvgWinMs: �̵� ����� ����� �ð� ������(ms)
          aExpectedSampleIntervalMs: FeedCurrent�� ȣ��� ������ ����Ǵ� ��� �ֱ�(ms).
                                     ���� ũ�� ��꿡�� ���˴ϴ�.
        }
        constructor Create(aAvgWinMs: Integer = 100; aExpectedSampleIntervalMs: Integer = 10);
        destructor Destroy; override;

        procedure Reset;
        procedure FeedCurrent(Current: Double);

        property IsDetected: Boolean read FDetected;
        property DetectionType: TDetectionType read FDetectionType;
        property OnDetected: TCurrentGuardEvent read FOnDetected write FOnDetected;

        // --- Ʃ�� ���̵� ---
        // �Ʒ� �Ķ���͵��� ������ ����, ������ Ư��, ���� �ֱ� � ���� ����ȭ�� �ʿ��մϴ�.
        // 1. ���� ������ ������/������� ���¿��� ������ �����Ͽ� AbsOverload�� ������ ����ϴ�.
        // 2. EarlyWindowMs�� ���� �⵿�� ����ȭ�Ǵ� �ð����� �ణ ��� �����մϴ�.
        // 3. ���ϰ� �ɸ��� ��Ȳ�� �����ϸ� RelRisePerc, MaxRisePerc, DIdtThreshold�� �����Ͽ� �ΰ����� �����մϴ�.
        // 4. �������� ��ũ�� �ʹ� �ΰ��ϰ� �����Ѵٸ� HoldTimeMs�� �ø��ϴ�.

        // ����� ��·� (%): ���� ������ �̵� ��պ��� �� ���� �̻� ���� �� �����մϴ�.
        // (�⺻��: 0.3, 30%) ���Ͽ� ���� ���� ����� �ϸ��� ��� ���� ���߰�, �ް��� ��� ���Դϴ�.
        property RelRisePerc: Double read FRelRisePerc write FRelRisePerc;

        // ���� ������ ���� (A): ������ ������ �Ѱ� �Ǵ� �ý����� ����ϴ� �ִ� �������Դϴ�.
        // �� ���� �ʰ��ϸ� ��� ���� ������ ���۵˴ϴ�. ���� ��缭�� �����Ͽ� �����ϴ� ���� ���� �����ϴ�.
        property AbsOverload: Double read FAbsOverload write FAbsOverload;

        // �ʱ� �ִ밪 ��� ��·� (%): ���� ������ �ʱ� �⵿ ���� �ִ� �������� �� ���� �̻� ���� �� �����մϴ�.
        // (�⺻��: 0.6, 60%) �⵿ �ÿ� ���� ���� ���� ���̰� ū ���Ϳ� �����մϴ�.
        property MaxRisePerc: Double read FMaxRisePerc write FMaxRisePerc;

        // ���� ���� �ð� (ms): ������ ������ �� �ð� �̻� ���ӵ� ���� ���� ����(FDetected)�� Ȯ���մϴ�.
        // (�⺻��: 60) �������� ����� ������ũ�� ���� ��Ž���� �����մϴ�.
        property HoldTimeMs: Integer read FHoldTimeMs write FHoldTimeMs;

        // �ʱ� �н� �ð� (ms): ���� ���� �� �� �ð� ������ �������� �⵿ ���� ������ �н��մϴ�.
        // (�⺻��: 800) ���Ͱ� �õ��Ǿ� ���� ���¿� �����ϱ⿡ ����� �ð����� �����ؾ� �մϴ�.
        property EarlyWindowMs: Integer read FEarlyWindowMs write FEarlyWindowMs;

        // dI/dt �Ӱ谪 ���: ���� ��ȭ��(dI/dt) ������ ���� �Ӱ谪 ����Դϴ�.
        // ���� �Ӱ谪 = (�ʱ� �ִ� ���� * �� ��) �Դϴ�. (�⺻��: 0.7)
        // ���� �������� ���� ��ȭ�� �ΰ��ϰ� �����մϴ�.
        property DIdtThreshold: Double read FDIdtThreshold write FDIdtThreshold;

        // ���� ���� �Ӱ谪 ���� (%): �����׸��ý�(Hysteresis) ����.
        // Hold ���¸� �����ϴ� �����Դϴ�. (���� ���� < �̵���� * (1 + �� ��))
        // (�⺻��: 0.1, 10%) ���� �Ӱ谪 ��ó���� ���°� �Ҿ����ϰ� �ݺ��Ǵ� ���� �����մϴ�.
        property ReleaseThreshold: Double read FReleaseThreshold write FReleaseThreshold;

        // --- ���� ��ȸ ������Ƽ ---
        property EarlyAvg: Double read GetEarlyAvg;
        property EarlyMax: Double read GetEarlyMax;
        property AvgCurrent: Double read GetAvgCurrent;
    end;

implementation

{ TMotorCurrentGuard }

constructor TMotorCurrentGuard.Create(aAvgWinMs, aExpectedSampleIntervalMs: Integer);
begin
    inherited Create;
    FAvgWinMs := aAvgWinMs;
    // ���� ���ø� �ֱ⿡ ���� ���� ũ�� ��� (�ּ� 1)
    FBufferSize := Max(1, aAvgWinMs div aExpectedSampleIntervalMs);
    SetLength(FBuffer, FBufferSize);

    // �⺻ �Ķ���� ����
    FRelRisePerc := 0.3;
    FAbsOverload := 7.0;
    FMaxRisePerc := 0.6;
    FHoldTimeMs := 60;
    FEarlyWindowMs := 800;
    FDIdtThreshold := 0.7;
    FReleaseThreshold := 0.1;

    FInitialDIdtThreshold := FDIdtThreshold; // �ʱ� DIdtThreshold �� ����

    Reset;
end;

destructor TMotorCurrentGuard.Destroy;
begin
    SetLength(FBuffer, 0);
    inherited Destroy;
end;

procedure TMotorCurrentGuard.Reset;
begin
    if FBufferSize > 0 then
        FillChar(FBuffer[0], FBufferSize * SizeOf(Double), 0);
    FBufferIdx := 0;
    FBufferCount := 0;
    FBufferSum := 0; // ���� �ʱ�ȭ

    ResetEarly;

    FHoldDetected := False;
    FDetected := False;
    FDetectionType := dtNone;
    FLastCurrent := 0;
    FLastTick := 0;
    FHoldStartTick := 0;
    FStartTick := GetTickCount; // ���� �ð� �缳��
    FDIdtThreshold := FInitialDIdtThreshold; // DIdtThreshold�� �ʱ� ������ �缳��
end;

procedure TMotorCurrentGuard.ResetEarly;
begin
    FEarlySum := 0;
    FEarlySampleCount := 0;
    FEarlyMax := 0;
end;

function TMotorCurrentGuard.GetAvgCurrent: Double;
begin
    // ����ȭ�� ��� ���: O(1)
    if FBufferCount = 0 then
        Result := 0
    else
        Result := FBufferSum / FBufferCount;
end;

function TMotorCurrentGuard.GetEarlyMax: Double;
begin
    if FEarlySampleCount = 0 then
        Result := 0
    else
        Result := FEarlyMax;
end;

function TMotorCurrentGuard.GetEarlyAvg: Double;
begin
    if FEarlySampleCount = 0 then
        Result := 0
    else
        Result := FEarlySum / FEarlySampleCount;
end;

procedure TMotorCurrentGuard.FeedCurrent(Current: Double);
var
    nowTick: Cardinal;
    timeDelta: Cardinal;
    dIdt: Double;
    avgCur: Double;
    earlyPhase: Boolean;
    dIdtThresholdValue: Double;
    detectedType: TDetectionType;
    oldestValue: Double;
    elapsedTime: Cardinal; // ���� �Ӱ谪 ������ ���� ��� �ð�
begin
    nowTick := GetTickCount;
    earlyPhase := (nowTick - FStartTick) < FEarlyWindowMs;

    // --- 1. ���� ���� �� �̵� ��� ����� ���� ���� ���� ---
    if FBufferCount = FBufferSize then
    begin
        // ���۰� �� á����, ���� ������ ���� ���տ��� ����.
        oldestValue := FBuffer[FBufferIdx];
        FBufferSum := FBufferSum - oldestValue;
    end;

    FBuffer[FBufferIdx] := Current;
    FBufferSum := FBufferSum + Current; // ���� ���� ���� ���Ѵ�.

    if FBufferCount < FBufferSize then
        Inc(FBufferCount);
    FBufferIdx := (FBufferIdx + 1) mod FBufferSize;

    // --- 2. �ʱ� �⵿ ���� �н� ---
    if earlyPhase then
    begin
        Inc(FEarlySampleCount);
        FEarlySum := FEarlySum + Current;
        if Current > FEarlyMax then
            FEarlyMax := Current;
    end;

    avgCur := GetAvgCurrent;
    detectedType := dtNone;

    // --- 3. ������ ���� �˻� ---
    // dI/dt ��� (���� �ð� ���)
    if FLastTick <> 0 then
    begin
        timeDelta := nowTick - FLastTick;
        if timeDelta > 0 then
        begin
            dIdt := (Current - FLastCurrent) / (timeDelta / 1000.0);
            dIdtThresholdValue := FEarlyMax * FDIdtThreshold;

            if (not FHoldDetected) and (dIdt > dIdtThresholdValue) then
            begin
                FHoldDetected := True;
                FHoldStartTick := nowTick;
                detectedType := dtCurrentRate;
            end;
        end;
    end;

    // �̵���� ��� ����� ��� (earlyPhase ���ȿ��� ��Ȱ��ȭ)
    // �ʱ� �⵿ ������ ���� ��� ��Ž���� �����ϱ� ����
    if (not earlyPhase) and (detectedType = dtNone) and (not FHoldDetected) and (avgCur > 0) and (Current > avgCur * (1 + FRelRisePerc)) then
    begin
        FHoldDetected := True;
        FHoldStartTick := nowTick;
        detectedType := dtRelativeRise;
    end;

    // ���� ��ȭ���� (�׻� Ȱ��ȭ - ������ ���� �ϵ� ����)
    if (detectedType = dtNone) and (not FHoldDetected) and (Current > FAbsOverload) then
    begin
        FHoldDetected := True;
        FHoldStartTick := nowTick;
        detectedType := dtAbsoluteOverload;
    end;

    // �ʱ��ִ밪 ��� ��� (earlyPhase ���ȿ��� ��Ȱ��ȭ)
    // �ʱ� �⵿ ������ ���� ��� ��Ž���� �����ϱ� ����
    if (not earlyPhase) and (detectedType = dtNone) and (not FHoldDetected) and (FEarlyMax > 0) and (Current > FEarlyMax * (1 + FMaxRisePerc)) then
    begin
        FHoldDetected := True;
        FHoldStartTick := nowTick;
        detectedType := dtMaxRise;
    end;

    // --- 4. ���� �Ӱ谪 ���� (���ο� ����) ---
    // ��ð� ���� �� dI/dt �Ӱ谪 ����
    if not FDetected then // �̹� ������ ���°� �ƴ� ���� ����
    begin
        elapsedTime := nowTick - FStartTick;
        // ���� �ð��� �ʱ� �н� �ð��� �� �踦 �ʰ��ϰ�, dI/dt �Ӱ谪�� �ʱ� ���� 10%���� Ŭ ��� ���������� ����
        if (elapsedTime > FEarlyWindowMs * 2) and (FDIdtThreshold > FInitialDIdtThreshold * 0.1) then
        begin
            FDIdtThreshold := FDIdtThreshold * 0.999; // ������ ���� (�������� �ʿ信 ���� Ʃ�� ����)
        end;
    end;

    // --- 5. ���� ���� �� �̺�Ʈ ó�� ---
    // �������� ��� (���� ������ ������ ���)
    if (detectedType <> dtNone) and (FDetectionType = dtNone) then
        FDetectionType := detectedType;

    // ���� ���� ���ӽð� üũ -> ���� ���� Ȯ��
    if FHoldDetected and ((nowTick - FHoldStartTick) > FHoldTimeMs) and (not FDetected) then
    begin
        FDetected := True;
        if Assigned(FOnDetected) then
            FOnDetected(Self, FDetectionType);
    end;

    // �����׸��ý�(Hold ���¸� ����, Detected ���´� ����)
    if FHoldDetected and (Current < avgCur * (1 + FReleaseThreshold)) then
    begin
        FHoldDetected := False;
        FHoldStartTick := 0;
        // ���� ����(FDetected)�� �� �Ŀ��� ����(FDetectionType)�� �ʱ�ȭ���� �ʴ´�.
        if not FDetected then
            FDetectionType := dtNone;
    end;

    // --- 6. ���� ������ ���� �� ���� ---
    FLastCurrent := Current;
    FLastTick := nowTick;
end;

end.

