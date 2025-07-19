
# **TMotorCurrentGuard 클래스 설명 및 사용법**

TMotorCurrentGuard는 모터의 전류 패턴을 분석하여 과부하 또는 구속(Stall) 상태를 효율적으로 감지하기 위한 델파이 클래스입니다. 다양한 파라미터들을 조합하여 모터의 특성과 운전 환경에 맞는 정교한 감지 로직을 구현합니다.

## **TMotorCurrentGuard 간략 사용법**

TMotorCurrentGuard는 모터 전류를 모니터링하여 과부하 또는 구속 상태를 감지하는 데 사용됩니다.

### **1. 객체 생성 및 초기화**

AvgWinMs와 ExpectedSampleIntervalMs를 지정하여 객체를 생성합니다.
OnDetected 이벤트를 할당하여 감지 시 호출될 함수를 지정합니다.

```pascal
var  
  MyMotorGuard: TMotorCurrentGuard;

procedure TMyForm.FormCreate(Sender: TObject);  
begin  
    // 이동 평균 윈도우 100ms, 예상 샘플링 주기 20ms  
    MyMotorGuard := TMotorCurrentGuard.Create(100, 20);  
    MyMotorGuard.OnDetected := MyMotorOverloadDetected;  
    // 필요에 따라 파라미터 설정 (예: MyMotorGuard.AbsOverload := 7.5;)  
end;

procedure TMyForm.FormDestroy(Sender: TObject);  
begin  
    MyMotorGuard.Free;  
end;
```


### **2. 전류 데이터 공급**

모터의 실시간 전류 값을 주기적으로 FeedCurrent 메서드에 전달합니다. 일반적으로 타이머를 사용합니다.

```pascal
procedure TMyForm.Timer1Timer(Sender: TObject);  
var  
    currentSensorValue: Double;  
begin  
    // 실제 센서에서 전류 값 읽기  
    currentSensorValue := GetCurrentFromSensor(); // 사용자 정의 함수  
    MyMotorGuard.FeedCurrent(currentSensorValue);

    // 감지 상태를 UI에 표시 (MyMotorGuard.IsDetected, MyMotorGuard.DetectionType 등 활용)  
end;
```


### **3. 감지 이벤트 처리**

OnDetected 이벤트 핸들러에서 과부하 감지 시 수행할 동작을 정의합니다.

```pascal
procedure TMyForm.MyMotorOverloadDetected(Sender: TObject; Detection: TDetectionType);  
begin  
    case Detection of  
        dtCurrentRate: ShowMessage('경고: 급격한 전류 상승 감지!');  
        dtRelativeRise: ShowMessage('경고: 상대적 전류 증가 감지!');  
        dtAbsoluteOverload: ShowMessage('경고: 절대 과부하 전류 초과!');  
        dtMaxRise: ShowMessage('경고: 초기 최대값 대비 상승 감지!');  
    end;  
    // 예: 모터 정지 명령 호출  
    // StopMotor();  
end;
```


### **4. 리셋**

새로운 감시 주기가 필요할 때 Reset 메서드를 호출하여 내부 상태를 초기화합니다.

```pascal
procedure TMyForm.ResetButtonClick(Sender: TObject);  
begin  
    MyMotorGuard.Reset;  
    ShowMessage('MotorCurrentGuard가 리셋되었습니다.');  
end;
```


## **TMotorCurrentGuard 파라미터 일반 설명**

| 파라미터 | 의미/역할 | 핵심 조건/사용처 | 실무 팁/튜닝 가이드 |
| :-- | :-- | :-- | :-- |
| **AvgWinMs** | 이동 평균 계산 구간(ms) | 최근 AvgWinMs 구간의 전류값 평균 사용 | 잡음 많은 환경은 넉넉히, 응답성 중시 땐 짧게 |
| **EarlyWindowMs** | 초기 학습 구간(ms) | 모터 기동 직후 학습 기간. 오탐 방지, FEarlyMax/Avg 기록 | 기동특성 길면 넉넉히, 짧으면 응답성↑ |
| **AbsOverload** | 절대 과부하 전류값 | 현재전류 > AbsOverload 즉시 과부하 | 모터스펙 최대치보다 약간 낮게 설정 |
| **RelRisePerc** | 이동평균 대비 상승률(%) | 현재전류 > AvgCurrent×(1+RelRisePerc) | 평상시 대비 급증 인식, 0.2~0.5(20~50%) 추천 |
| **MaxRisePerc** | 초기피크 대비 상승률(%) | 현재전류 > FEarlyMax×(1+MaxRisePerc) | 초기피크 재현시 오탐 방지, 0.2~0.4 적당 |
| **DIdtThreshold** | dI/dt 변화율 임계 계수 | (전류증가속도) > FEarlyMax×DIdtThreshold | 순간 구속/급격한 부하 감지, 보통 0.5~1.0 |
| **HoldTimeMs** | 감지 유지 시간(ms) | 조건 충족 시 몇 ms 이상 지속돼야 최종 감지 | 짧으면 오탐↑, 길면 감지 지연. 100~500 적당 |
| **ReleaseThreshold** | 감지 해제(히스테리시스, %) | 감지상태→해제: 전류 < AvgCurrent×(1+Release) | 0.1~0.2 (10~20%) 설정, 출렁임 방지용 |

## **TMotorCurrentGuard 파라미터 상세 설명**

### **1. AvgWinMs (이동 평균 윈도우)**

- **정의**: 이동 평균을 계산하는 데 사용되는 시간 윈도우(밀리초)
- **내부 알고리즘**: FeedCurrent 메서드에서 새로운 전류 값이 들어올 때마다, 이 윈도우 내의 전류 값들의 평균(AvgCurrent)을 계산합니다. 이는 전류의 단기적인 노이즈를 평활화하고, 안정적인 기준선을 제공합니다.

**도식:**

```
I_n−k,...,I_n−1,I_n <-- AvgWinMs (k=AvgWinMs/SampleInterval)
     ↓
Moving Average (AvgCurrent)
```

**실전 팁:**

- *예)* 센서 노이즈 심하면 200ms~500ms, 응답 빠를 땐 50~100ms
- **주행환경/모터 RPM이 불규칙하면 넓게 잡으세요**


### **2. EarlyWindowMs (초기 학습 시간)**

- **정의**: 모터 기동 후 정상적인 전류 패턴을 학습하는 기간(밀리초)
- **내부 알고리즘**:
    - 이 시간 동안 (nowTick - FStartTick < EarlyWindowMs) FEarlyMax (최대 기동 전류)와 FEarlyAvg (초기 평균 전류)를 기록합니다.
    - 이 기간 중에는 RelRisePerc 및 MaxRisePerc에 의한 감지 로직이 **비활성화**되어 기동 시의 정상적인 전류 상승으로 인한 오탐지를 방지합니다.

**도식:**

```
시간 0 ------------------- EarlyWindowMs --------------------->
     | 초기 기동 학습 구간  |  정상 감지 활성화 구간
     | (FEarlyMax, FEarlyAvg 기록) |
     | (RelRise, MaxRise 감지 OFF) |
```

**실전 팁:**

- *예)* 기동전류 치솟는 시간만큼(모터 따라 200~1500ms)
- **불필요하게 길면 구속 빠른감지 어려움, 짧으면 피크에 오탐!**


### **3. AbsOverload (절대 과부하 전류)**

- **정의**: 모터가 허용할 수 있는 최대 전류 값(암페어). 이 값을 초과하면 즉시 과부하 조건으로 간주됩니다.
- **내부 알고리즘**: 현재 전류(Current)가 AbsOverload보다 큰지 직접 비교합니다. 안전을 위해 EarlyWindowMs 동안에도 항상 활성화됩니다.

**도식:**

```
Current > AbsOverload ? --> Overload Condition (dtAbsoluteOverload)
```

**실전 팁:**

- *예)* 카다로그 허용치 × 90~95% 정도
- **EarlyWindow와 무관하게 항상 동작!**


### **4. RelRisePerc (상대적 상승률)**

- **정의**: 현재 전류가 이동 평균(AvgCurrent) 대비 얼마나 상승했는지의 비율(%)
- **내부 알고리즘**: EarlyWindowMs 이후에 활성화됩니다. Current > AvgCurrent * (1 + RelRisePerc) 조건을 검사하여, 평균 대비 비정상적인 전류 상승을 감지합니다.

**도식:**

```
AvgCurrent * (1 + RelRisePerc)
---------------------------------- <-- Threshold
Current
```

**실전 팁:**

- *예)* 0.3(30%) 추천, 구동부 마모 등 느린 변화 감지엔 낮게, 급격한 환경엔 높게
- **AvgCurrent 산출 신뢰도가 높을 때만 의미 있음**


### **5. MaxRisePerc (초기 최대값 대비 상승률)**

- **정의**: 현재 전류가 초기 기동 시 학습된 최대 전류(FEarlyMax) 대비 얼마나 상승했는지의 비율(%)
- **내부 알고리즘**: EarlyWindowMs 이후에 활성화됩니다. Current > FEarlyMax * (1 + MaxRisePerc) 조건을 검사하여, 기동 피크 수준을 넘어서는 심각한 과부하를 감지합니다.

**도식:**

```
FEarlyMax * (1 + MaxRisePerc)
---------------------------------- <-- Threshold
Current
```

**실전 팁:**

- *예)* 0.2(20%)~0.5(50%)
- **FEarlyMax 튜닝 중요! 부하 레일 등 경년변화 반영 필요**


### **6. DIdtThreshold (dI/dt 임계값 계수)**

- **정의**: 전류 변화율(dI/dt) 감지를 위한 임계값 계수. 실제 임계값은 FEarlyMax * DIdtThreshold로 계산됩니다.
- **내부 알고리즘**:
    - dI/dt = (Current - FLastCurrent) / TimeDelta로 계산합니다.
    - dI/dt > (FEarlyMax * DIdtThreshold) 조건을 검사하여 급격한 전류 변화를 감지합니다.
    - 장시간 운전 시 (elapsedTime > EarlyWindowMs * 2), DIdtThreshold는 점진적으로 감소하여 안정 운전 중 미세한 변화에도 민감하게 반응하도록 동적으로 조정됩니다.

**도식:**

```
(Current - FLastCurrent) / TimeDelta > (FEarlyMax * DIdtThreshold) ?
--> Overload Condition (dtCurrentRate)
```

**실전 팁:**

- *예)* 평소 0.5, 급정지 빈번시 1.0, 민감히 탐지 땐 낮게
- **장시간 운전시 감도를 자동 올려 미세한 변화도 감지**


### **7. HoldTimeMs (감지 유지 시간)**

- **정의**: 과부하 조건이 최종적으로 감지되기 위해 해당 조건이 지속되어야 하는 최소 시간(밀리초)
- **내부 알고리즘**: 감지 조건(FHoldDetected)이 충족되면 FHoldStartTick을 기록하고, nowTick - FHoldStartTick > HoldTimeMs일 때 FDetected를 True로 설정하고 OnDetected 이벤트를 발생시킵니다. 오탐지 방지에 중요합니다.

**도식:**

```
Overload Condition TRUE
----------------------> [Start Hold Timer]
If (CurrentTime - HoldStartTime) > HoldTimeMs ? --> Final Detection
```

**실전 팁:**

- *예)* 200~500ms. 모터 가변조건/환경 잡음따라 조정
- **짧으면 찰나 노이즈에 감지, 길면 실제 구속 감지 늦어짐**


### **8. ReleaseThreshold (감지 해제 임계값 비율)**

- **정의**: 히스테리시스(Hysteresis)를 적용하여 HoldDetected 상태를 해제하는 기준 비율(%)
- **내부 알고리즘**: FHoldDetected 상태에서 Current < AvgCurrent * (1 + ReleaseThreshold) 조건을 만족하면 FHoldDetected를 False로 변경합니다. 이는 감지 임계값 근처에서 상태가 불안정하게 반복되는 것을 방지합니다. FDetected (최종 감지) 상태는 Reset 호출 전까지 유지됩니다.

**도식:**

```
HoldDetected TRUE
Current < AvgCurrent * (1 + ReleaseThreshold) ? --> Release Hold
```

**실전 팁:**

- *예)* 0.15(15%), 감지-비감지 경계에서 출렁임 많으면 올림
- **실제 사용환경서 테스트 강추!**


### **💡실전 튜닝 팁/FAQ**

- **초기 학습구간 설정?**
    - 무부하 기동 시 전류패턴 로깅 후 *가장 긴 피크 지속시간*을 EarlyWindowMs로
- **레일부하/이물질 등으로 점진적 전류상승?**
    - RelRisePerc/MaxRisePerc를 낮추되, HoldTimeMs를 높여 '일시적 스파이크' 오탐 방지
- **모터 노후화로 점진적 과부하?**
    - AvgWinMs를 길게, RelRisePerc/MaxRisePerc 낮게.
- **초기 오탐?**
    - EarlyWindowMs 길게, RelRisePerc/MaxRisePerc 높임
- **환경별 특이상황**
    - 장마철, 온도 변화, 윤활상태별 각각 한번씩 '전류로그' 꼭 쌓아서 기준치 재설정 필요


### **✅ 요약**

- 모든 파라미터는 **실환경의 전류 로그를 분석**하고, "안정 운전 구간"과 "고장/부하/구속" 패턴을 *눈으로 직접 확인 후* 튜닝해야 가장 효과적!
- **과민하게/둔감하게 튜닝된 경우 오탐, 미감지 발생**
- **튜닝 후에는 반드시 수동 시험, 여러 패턴 반복 검증!**

<div style="text-align: center">⁂</div>

[^1]: MotorCurrentGuard-sayong-seolmyeong.md

