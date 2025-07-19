unit SingleTypeRange;

interface

uses SysUtils, StdCtrls;

const
    RANGE_MIN = -99999;
    RANGE_MAX = 99999;
    TEST_VAL_NONE = -99999;
    EMPTY_VAL = TEST_VAL_NONE;

type
    PSingleTypeRange = ^TSingleTypeRange;

    TSingleTypeRange = packed record
        constructor Create(Min:Single; Max: Single = RANGE_MAX); overload;
        constructor Create(MinStr, MaxStr: string); overload;

        procedure Clear;

        function MidVal: Single;

        function  GetRange: Single;
        procedure SetRange(Min: Single = RANGE_MIN; Max: Single = RANGE_MAX; ForceValid: boolean = false);
        procedure SetRangeByMidVal(MidVal: Single; AlphaVal: Single);
        procedure CalcMinMax(Val: Single);      // Min, Max계산용

        function IsEmpty(): boolean;
        function IsIn(Val: Single; Offset: Single = 0; CutOffDigit: integer = 0): boolean;
        function IsAboveMin(Val: Single): boolean;
        function IsUnderMax(Val: Single): boolean;

        function IsValid: boolean;
        procedure ReadFromStr(MinStr, MaxStr: string);

        function MakeRndVal:Single; // Min ~ Max 사이값 랜덤 발생

        function ToStr(Format: string = '0.0'; IsBracket: boolean = false): string;
        function ToStrWithUnit(Format: string = '0.0'; UnitStr: string = ''): string;
        function ToMidValStr(Format: string = '0.0'; AlphaFormat: string = '0.0'; IsBracket: boolean = false): string;

        procedure WriteToEdit(MinEdit, MaxEdit: TCustomEdit; Format: string = '0.0');
        function  ReadFromEdit(MinEdit, MaxEdit: TCustomEdit): boolean;

        case integer of
            0:
                (
                    mMin,
                    mMax: Single
                );
            1:
                (
                    mBegin,
                    mEnd: Single
                );
            2:
                (
                    mStart,
                    mStop: Single;
                )

    end;

    // 1. 단순 최소, 최대, 평균을 저장하는 변수 용도
    // 1-1. 위 최소, 최대를 SPEC으로 범위안에 IsIn() 체크 용도
    // 2. Add(Val)을 이용해 누적할 시 최소 최대, 평균을 계산 용도

    TMMAType = (matMin, matMax, matAvg);

    PSingleTypeMinMaxAvg = ^TSingleTypeMinMaxAvg;
    TSingleTypeMinMaxAvg = packed record
        mSubValAsMax,
        mMin, mMax, mAvg: Single;
        mSum: Single;
        mCount: integer;

        constructor Create(Min, Max, Avg: Single);

        procedure Add(Val: Single);
        procedure AddWithSubVal(Val: Single; SubValAsMax: Single);
        procedure Clear;
        procedure ClearWithZero;

        function GetVal(Idx: TMMAType): Single; overload;
        function GetVal(Idx: integer): Single; overload;

        function IsEmpty: boolean;
        function IsIn(Val: Single; Offset: Single = 0; CutOffDigit: integer = 0): boolean;
        function GetRunOut: Single; // 편차용

        function ToStr: string;
    end;


implementation
uses
    Math;

function CutOffVal(Val: Single; Digits: integer): Single;
begin
    Result := Trunc(Val * exp(ln(10) * Digits)) / exp(ln(10) * Digits);
end;

{ TSingleTypeRange }



constructor TSingleTypeRange.Create(Min: Single; Max: Single);
begin
    SetRange(Min, Max);
end;

procedure TSingleTypeRange.Clear;
begin
    mMin := RANGE_MAX;
    mMax := RANGE_MIN;
end;

constructor TSingleTypeRange.Create(MinStr, MaxStr: string);
begin
    ReadFromStr(MinStr, MaxStr);
end;

procedure TSingleTypeRange.CalcMinMax(Val: Single);
begin
    if mMin > Val then
        mMin := Val;
    if mMax < Val then
        mMax := Val;
end;

function TSingleTypeRange.IsEmpty: boolean;
begin
    Result := ((mMin = 0) and (mMax = 0)) or ((mMin = RANGE_MAX) and (mMax = RANGE_MIN));
end;

function TSingleTypeRange.IsIn(Val, Offset: Single; CutOffDigit: integer): boolean;
begin
    if CutOffDigit > 0 then
    begin
        Val := CutOffVal(Val, CutOffDigit);
    end;

    Result := (((mMin - Offset) <= Val) and ((mMax + Offset) >= Val));

end;

function TSingleTypeRange.IsUnderMax(Val: Single): boolean;
begin
    Result := mMax >= Val;
end;

function TSingleTypeRange.IsAboveMin(Val: Single): boolean;
begin
    Result := mMin <= Val;
end;

procedure TSingleTypeRange.SetRange(Min: Single; Max: Single; ForceValid: boolean);
begin
    if not ForceValid then
    begin
        mMin := Min;
        mMax := Max;
        Exit;
    end;

    if (Min <= Max) then
    begin
        mMin := Min;
        mMax := Max;
    end
    else
    begin
        mMin := Max;
        mMax := Min;
    end;
end;

function TSingleTypeRange.ToMidValStr(Format: string; AlphaFormat: string; IsBracket: boolean): string;
var
    ValStr: string;
    Alpha: Single;
begin
    if ((mMin = RANGE_MIN) and (mMax = RANGE_MAX)) then
    begin
        Result := '-';
    end;

    Alpha := GetRange / 2;

    ValStr := FormatFloat(Format, mMin + Alpha) + ' ±' + FormatFloat(AlphaFormat, Alpha);
    if (IsBracket) then
    begin
        Result := '(' + ValStr + ')';
    end;

    Result := ValStr;
end;

function TSingleTypeRange.ToStr(Format: string; IsBracket: boolean): string;
var
    MinStr, MaxStr: string;
begin

    if mMin = RANGE_MIN then
        MinStr := ''
    else
        MinStr := FormatFloat(Format, mMin);
    if mMax = RANGE_MAX then
        MaxStr := ''
    else
        MaxStr := FormatFloat(Format, mMax);

    if (IsBracket) then
    begin
        Result := '(' + MinStr + ' ~ ' + MaxStr + ')';
    end;

    Result := MinStr + ' ~ ' + MaxStr;
end;

function TSingleTypeRange.ToStrWithUnit(Format, UnitStr: string): string;
var
    MinStr, MaxStr: string;
begin

    if mMin = RANGE_MIN then
        MinStr := ''
    else
        MinStr := FormatFloat(Format, mMin);
    if mMax = RANGE_MAX then
        MaxStr := ''
    else
        MaxStr := FormatFloat(Format, mMax);


    Result := MinStr + UnitStr + ' ~ ' + MaxStr + UnitStr;

end;

function TSingleTypeRange.IsValid: boolean;
begin
    Result := mMin < mMax;
end;

function RandomRangeF(min, max: Single): Single;
begin
    Result := Min + Random * (Max - Min);
end;

function TSingleTypeRange.MakeRndVal: Single;
begin
    Result := RandomRangeF(mMin, mMax);
end;

function TSingleTypeRange.MidVal: Single;
begin
    Result := mMin + (mMax - mMin) / 2.0;
end;

procedure TSingleTypeRange.ReadFromStr(MinStr, MaxStr: string);
begin
    SetRange(StrToFloatDef(MinStr, 0), StrToFloatDef(MaxStr, 0));
end;

procedure TSingleTypeRange.SetRangeByMidVal(MidVal, AlphaVal: Single);
begin
    SetRange(MidVal - AlphaVal, MidVal + AlphaVal);
end;

function TSingleTypeRange.ReadFromEdit(MinEdit, MaxEdit: TCustomEdit): boolean;
var
    MinStr, MaxStr: string;
begin

    try
        if MinEdit.Text <> '' then
            mMin := StrToFloatDef(MinEdit.Text, RANGE_MIN)
        else
            mMin := RANGE_MIN;

        if MaxEdit.Text <> '' then
            mMax := StrToFloatDef(MaxEdit.Text, RANGE_MAX)
        else
            mMax := RANGE_MAX;

    except
        Exit(false);
    end;

    Result := true;
end;

procedure TSingleTypeRange.WriteToEdit(MinEdit, MaxEdit: TCustomEdit; Format: string);
begin

    if mMin = RANGE_MIN then
        MinEdit.Text := ''
    else
        MinEdit.Text := FormatFloat(Format, mMin);
    if mMax = RANGE_MAX then
        MaxEdit.Text := ''
    else
        MaxEdit.Text := FormatFloat(Format, mMax);
end;

function TSingleTypeRange.GetRange: Single;
begin
    if (mMin = RANGE_MIN) or (mMax = RANGE_MAX) then
        Exit(0);

    Result := abs(mMax - mMin);
end;

{ TSingleTypeMinMaxAvg }

procedure TSingleTypeMinMaxAvg.Add(Val: Single);
begin
    if mMin > Val then
        mMin := Val;
    if mMax < Val then
        mMax := Val;

    mSum := mSum + Val;

    Inc(mCount);

    mAvg := mSum / mCount;
end;



procedure TSingleTypeMinMaxAvg.AddWithSubVal(Val, SubValAsMax: Single);
begin
    if mMin > Val then
        mMin := Val;
    if mMax < Val then
    begin
        mMax := Val;
        mSubValAsMax := SubValAsMax;
    end;

    mSum := mSum + Val;

    Inc(mCount);

    mAvg := mSum / mCount;
end;

procedure TSingleTypeMinMaxAvg.Clear;
begin
    mMin := RANGE_MAX;
    mMax := RANGE_MIN;
    mSum := 0;
    mCount := 0;
    mAvg := 0;

    mSubValAsMax := 0;
end;

procedure TSingleTypeMinMaxAvg.ClearWithZero;
begin
    mMin := 0;
    mMax := 0;
    mSum := 0;
    mCount := 0;
    mAvg := 0;

    mSubValAsMax := 0;
end;

constructor TSingleTypeMinMaxAvg.Create(Min, Max, Avg: Single);
begin
    Clear;

    mMin := Min;
    mMax := Max;
    mAvg := Avg;

end;

function TSingleTypeMinMaxAvg.GetVal(Idx: integer): Single;
begin
    case Idx of
        0:  Result := mMin;
        1:  Result := mMax;
        2:  Result := mAvg;
    else
        Result := 0;
    end;
end;

function TSingleTypeMinMaxAvg.GetVal(Idx: TMMAType): Single;
begin
    Result := GetVal(Ord(Idx));
end;

function TSingleTypeMinMaxAvg.IsEmpty: boolean;
begin
    Result := (mMin = RANGE_MAX) or (mMax = RANGE_MIN);
end;

function TSingleTypeMinMaxAvg.IsIn(Val, Offset: Single; CutOffDigit: integer): boolean;
begin
    if CutOffDigit > 0 then
    begin
        Val := CutOffVal(Val, CutOffDigit);
    end;

    Result := (((mMin - Offset) <= Val) and ((mMax + Offset) >= Val));
end;

function TSingleTypeMinMaxAvg.ToStr: string;
begin
    Result := Format('Min:%f, Max:%f, Avg:%f', [mMin, mMax, mAvg]);
end;

function TSingleTypeMinMaxAvg.GetRunOut: Single;
begin
    if IsEmpty then
        Exit(0);

    Result := mMax - mMin;

end;



end.
