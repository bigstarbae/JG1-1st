unit MotorCurrentGuard;

interface

uses
    SysUtils, Classes, Windows, Math;

type
    // 감지 유형: 어떤 조건에 의해 과부하가 감지되었는지 나타냅니다.
    TDetectionType = (dtNone, dtCurrentRate, dtRelativeRise, dtAbsoluteOverload, dtMaxRise);

    // 이벤트 핸들러 타입: 과부하가 최종 감지되었을 때 호출됩니다.
    TCurrentGuardEvent = procedure(Sender: TObject; Detection: TDetectionType) of object;

    {
      TMotorCurrentGuard 클래스
      모터의 전류를 지속적으로 감시하여 구속(Stall) 또는 과부하 상태를 감지합니다.
      - 실시간 dI/dt (전류 변화율) 계산
      - 이동 평균 기반의 상대적, 절대적 과부하 감지
      - 초기 기동 구간 학습을 통한 동적 임계값 설정
      - 오탐지를 방지하기 위한 홀드(Hold) 및 히스테리시스(Hysteresis) 로직 포함
    }
    TMotorCurrentGuard = class
    private
        FBuffer: array of Double;       // 전류 값 저장을 위한 순환 버퍼
        FBufferSum: Double;             // 버퍼 내 전류 값의 총합 (평균 계산 최적화용)
        FBufferSize: Integer;           // 버퍼의 크기
        FBufferIdx: Integer;            // 현재 버퍼 인덱스
        FBufferCount: Integer;          // 버퍼에 저장된 실제 데이터 수

        FEarlyMax: Double;              // 초기 기동 구간의 최대 전류
        FEarlySum: Double;              // 초기 기동 구간의 전류 합계
        FEarlySampleCount: Integer;     // 초기 기동 구간의 샘플 수

        FStartTick: Cardinal;           // 감시 시작 시각
        FHoldStartTick: Cardinal;       // 과부하 조건 유지 시작 시각
        FHoldDetected: Boolean;         // 과부하 조건이 일시적으로 감지되었는지 여부
        FDetected: Boolean;             // 과부하가 최종적으로 확정되었는지 여부

        FLastCurrent: Double;           // 마지막으로 입력된 전류 값
        FLastTick: Cardinal;            // 마지막 FeedCurrent 호출 시각
        FDetectionType: TDetectionType; // 최종 감지된 원인

        // 설정 파라미터
        FAvgWinMs: Integer;
        FRelRisePerc: Double;
        FAbsOverload: Double;
        FMaxRisePerc: Double;
        FHoldTimeMs: Integer;
        FEarlyWindowMs: Integer;
        FDIdtThreshold: Double;
        FReleaseThreshold: Double;
        FInitialDIdtThreshold: Double;  // 동적 조정을 위한 초기 DIdtThreshold 값 저장

        // 이벤트
        FOnDetected: TCurrentGuardEvent;

        procedure ResetEarly;
        function GetAvgCurrent: Double;
        function GetEarlyMax: Double;
        function GetEarlyAvg: Double;
    public
        {
          생성자
          aAvgWinMs: 이동 평균을 계산할 시간 윈도우(ms)
          aExpectedSampleIntervalMs: FeedCurrent가 호출될 것으로 예상되는 평균 주기(ms).
                                     버퍼 크기 계산에만 사용됩니다.
        }
        constructor Create(aAvgWinMs: Integer = 100; aExpectedSampleIntervalMs: Integer = 10);
        destructor Destroy; override;

        procedure Reset;
        procedure FeedCurrent(Current: Double);

        property IsDetected: Boolean read FDetected;
        property DetectionType: TDetectionType read FDetectionType;
        property OnDetected: TCurrentGuardEvent read FOnDetected write FOnDetected;

        // --- 튜닝 가이드 ---
        // 아래 파라미터들은 모터의 종류, 부하의 특성, 제어 주기 등에 따라 최적화가 필요합니다.
        // 1. 먼저 모터의 무부하/정상부하 상태에서 전류를 측정하여 AbsOverload의 기준을 잡습니다.
        // 2. EarlyWindowMs를 모터 기동이 안정화되는 시간보다 약간 길게 설정합니다.
        // 3. 부하가 걸리는 상황을 재현하며 RelRisePerc, MaxRisePerc, DIdtThreshold를 조정하여 민감도를 조절합니다.
        // 4. 순간적인 피크에 너무 민감하게 반응한다면 HoldTimeMs를 늘립니다.

        // 상대적 상승률 (%): 현재 전류가 이동 평균보다 이 비율 이상 높을 때 감지합니다.
        // (기본값: 0.3, 30%) 부하에 따른 전류 상승이 완만한 경우 값을 낮추고, 급격한 경우 높입니다.
        property RelRisePerc: Double read FRelRisePerc write FRelRisePerc;

        // 절대 과부하 전류 (A): 모터의 물리적 한계 또는 시스템이 허용하는 최대 전류값입니다.
        // 이 값을 초과하면 즉시 감지 로직이 시작됩니다. 모터 사양서를 참조하여 설정하는 것이 가장 좋습니다.
        property AbsOverload: Double read FAbsOverload write FAbsOverload;

        // 초기 최대값 대비 상승률 (%): 현재 전류가 초기 기동 시의 최대 전류보다 이 비율 이상 높을 때 감지합니다.
        // (기본값: 0.6, 60%) 기동 시와 운전 시의 전류 차이가 큰 모터에 유용합니다.
        property MaxRisePerc: Double read FMaxRisePerc write FMaxRisePerc;

        // 감지 유지 시간 (ms): 과부하 조건이 이 시간 이상 지속될 때만 최종 감지(FDetected)로 확정합니다.
        // (기본값: 60) 순간적인 노이즈나 스파이크로 인한 오탐지를 방지합니다.
        property HoldTimeMs: Integer read FHoldTimeMs write FHoldTimeMs;

        // 초기 학습 시간 (ms): 동작 시작 후 이 시간 동안은 정상적인 기동 전류 패턴을 학습합니다.
        // (기본값: 800) 모터가 시동되어 안정 상태에 도달하기에 충분한 시간으로 설정해야 합니다.
        property EarlyWindowMs: Integer read FEarlyWindowMs write FEarlyWindowMs;

        // dI/dt 임계값 계수: 전류 변화율(dI/dt) 감지를 위한 임계값 계수입니다.
        // 실제 임계값 = (초기 최대 전류 * 이 값) 입니다. (기본값: 0.7)
        // 값이 낮을수록 전류 변화에 민감하게 반응합니다.
        property DIdtThreshold: Double read FDIdtThreshold write FDIdtThreshold;

        // 감지 해제 임계값 비율 (%): 히스테리시스(Hysteresis) 적용.
        // Hold 상태를 해제하는 조건입니다. (현재 전류 < 이동평균 * (1 + 이 값))
        // (기본값: 0.1, 10%) 감지 임계값 근처에서 상태가 불안정하게 반복되는 것을 방지합니다.
        property ReleaseThreshold: Double read FReleaseThreshold write FReleaseThreshold;

        // --- 상태 조회 프로퍼티 ---
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
    // 예상 샘플링 주기에 따라 버퍼 크기 계산 (최소 1)
    FBufferSize := Max(1, aAvgWinMs div aExpectedSampleIntervalMs);
    SetLength(FBuffer, FBufferSize);

    // 기본 파라미터 설정
    FRelRisePerc := 0.3;
    FAbsOverload := 7.0;
    FMaxRisePerc := 0.6;
    FHoldTimeMs := 60;
    FEarlyWindowMs := 800;
    FDIdtThreshold := 0.7;
    FReleaseThreshold := 0.1;

    FInitialDIdtThreshold := FDIdtThreshold; // 초기 DIdtThreshold 값 저장

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
    FBufferSum := 0; // 총합 초기화

    ResetEarly;

    FHoldDetected := False;
    FDetected := False;
    FDetectionType := dtNone;
    FLastCurrent := 0;
    FLastTick := 0;
    FHoldStartTick := 0;
    FStartTick := GetTickCount; // 시작 시간 재설정
    FDIdtThreshold := FInitialDIdtThreshold; // DIdtThreshold를 초기 값으로 재설정
end;

procedure TMotorCurrentGuard.ResetEarly;
begin
    FEarlySum := 0;
    FEarlySampleCount := 0;
    FEarlyMax := 0;
end;

function TMotorCurrentGuard.GetAvgCurrent: Double;
begin
    // 최적화된 평균 계산: O(1)
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
    elapsedTime: Cardinal; // 동적 임계값 조정을 위한 경과 시간
begin
    nowTick := GetTickCount;
    earlyPhase := (nowTick - FStartTick) < FEarlyWindowMs;

    // --- 1. 버퍼 갱신 및 이동 평균 계산을 위한 총합 관리 ---
    if FBufferCount = FBufferSize then
    begin
        // 버퍼가 꽉 찼으면, 가장 오래된 값을 총합에서 뺀다.
        oldestValue := FBuffer[FBufferIdx];
        FBufferSum := FBufferSum - oldestValue;
    end;

    FBuffer[FBufferIdx] := Current;
    FBufferSum := FBufferSum + Current; // 새로 들어온 값은 더한다.

    if FBufferCount < FBufferSize then
        Inc(FBufferCount);
    FBufferIdx := (FBufferIdx + 1) mod FBufferSize;

    // --- 2. 초기 기동 구간 학습 ---
    if earlyPhase then
    begin
        Inc(FEarlySampleCount);
        FEarlySum := FEarlySum + Current;
        if Current > FEarlyMax then
            FEarlyMax := Current;
    end;

    avgCur := GetAvgCurrent;
    detectedType := dtNone;

    // --- 3. 과부하 조건 검사 ---
    // dI/dt 계산 (실제 시간 기반)
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

    // 이동평균 대비 상대적 상승 (earlyPhase 동안에는 비활성화)
    // 초기 기동 전류가 높은 경우 오탐지를 방지하기 위함
    if (not earlyPhase) and (detectedType = dtNone) and (not FHoldDetected) and (avgCur > 0) and (Current > avgCur * (1 + FRelRisePerc)) then
    begin
        FHoldDetected := True;
        FHoldStartTick := nowTick;
        detectedType := dtRelativeRise;
    end;

    // 절대 포화전류 (항상 활성화 - 안전을 위한 하드 리밋)
    if (detectedType = dtNone) and (not FHoldDetected) and (Current > FAbsOverload) then
    begin
        FHoldDetected := True;
        FHoldStartTick := nowTick;
        detectedType := dtAbsoluteOverload;
    end;

    // 초기최대값 대비 상승 (earlyPhase 동안에는 비활성화)
    // 초기 기동 전류가 높은 경우 오탐지를 방지하기 위함
    if (not earlyPhase) and (detectedType = dtNone) and (not FHoldDetected) and (FEarlyMax > 0) and (Current > FEarlyMax * (1 + FMaxRisePerc)) then
    begin
        FHoldDetected := True;
        FHoldStartTick := nowTick;
        detectedType := dtMaxRise;
    end;

    // --- 4. 동적 임계값 조정 (새로운 로직) ---
    // 장시간 운전 시 dI/dt 임계값 조정
    if not FDetected then // 이미 감지된 상태가 아닐 때만 조정
    begin
        elapsedTime := nowTick - FStartTick;
        // 운전 시간이 초기 학습 시간의 두 배를 초과하고, dI/dt 임계값이 초기 값의 10%보다 클 경우 점진적으로 감소
        if (elapsedTime > FEarlyWindowMs * 2) and (FDIdtThreshold > FInitialDIdtThreshold * 0.1) then
        begin
            FDIdtThreshold := FDIdtThreshold * 0.999; // 점진적 감소 (조정률은 필요에 따라 튜닝 가능)
        end;
    end;

    // --- 5. 감지 상태 및 이벤트 처리 ---
    // 감지유형 기록 (최초 감지된 유형만 기록)
    if (detectedType <> dtNone) and (FDetectionType = dtNone) then
        FDetectionType := detectedType;

    // 구속 조건 지속시간 체크 -> 최종 감지 확정
    if FHoldDetected and ((nowTick - FHoldStartTick) > FHoldTimeMs) and (not FDetected) then
    begin
        FDetected := True;
        if Assigned(FOnDetected) then
            FOnDetected(Self, FDetectionType);
    end;

    // 히스테리시스(Hold 상태만 해제, Detected 상태는 유지)
    if FHoldDetected and (Current < avgCur * (1 + FReleaseThreshold)) then
    begin
        FHoldDetected := False;
        FHoldStartTick := 0;
        // 최종 감지(FDetected)가 된 후에는 원인(FDetectionType)을 초기화하지 않는다.
        if not FDetected then
            FDetectionType := dtNone;
    end;

    // --- 6. 다음 루프를 위한 값 갱신 ---
    FLastCurrent := Current;
    FLastTick := nowTick;
end;

end.

