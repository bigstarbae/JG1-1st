unit Spec;

interface

uses
    SysUtils, StdCtrls;

const
    SPEC_MIN = -99999;
    SPEC_MAX = 99999;
    TEST_VAL_NONE = -99999;
    EMPTY_VAL = TEST_VAL_NONE;

type
    PSpec = ^TSpec;

    TSpec = packed record
    private
        function GetUnitStrVisibility(UnitStr: string = ''): string;

    public
        mUnitStr: string[6];
        mShowUnit: Boolean;

        constructor Create(Min: Single; Max: Single = SPEC_MAX); overload;
        constructor Create(MinStr, MaxStr: string); overload;

        procedure Clear; overload;
        procedure Clear(DefVal: Single); overload;

        function MidVal: Single;

        function GetRange: Single;
        procedure SetRange(Min: Single = SPEC_MIN; Max: Single = SPEC_MAX; ForceValid: boolean = false);
        procedure SetRangeByMidVal(MidVal: Single; AlphaVal: Single);
        procedure CalcMinMax(Val: Single);      // Min, Max계산용

        function IsEmpty(): boolean;
        function IsIn(Val: Single; Offset: Single = 0; CutOffDigit: integer = 0): boolean;
        function IsAboveMin(Val: Single): boolean;
        function IsUnderMax(Val: Single): boolean;

        function IsValid: boolean;
        procedure ReadFromStr(MinStr, MaxStr: string);

        function MakeRndVal: Single; // Min ~ Max 사이값 랜덤 발생

        function ToStr(Format: string = '0.0'; IsBracket: boolean = False): string;
        function ToStrWithUnit(Format: string = '0.0'; UnitStr: string = ''): string;
        function ToStrWithUnit2(Format: string = '0.0'; IsUnit: Boolean = False): string;
        function ToMinStr(Format: string = '0.0'; UnitStr: string = ' '): string;
        function ToMaxStr(Format: string = '0.0'; UnitStr: string = ' '): string;

        function ToMidValStr(Format: string = '0.0'; AlphaFormat: string = '0.0'; IsBracket: boolean = false): string;

        procedure WriteToEdit(MinEdit, MaxEdit: TCustomEdit; Format: string = '0.0');
        function ReadFromEdit(MinEdit, MaxEdit: TCustomEdit; DefaultMin: Single = 0; DefaultMax: Single = 0): boolean;

        case integer of
            0:
                (mMin, mMax: Single);
            1:
                (mBegin, mEnd: Single);
            2:
                (mStart, mStop: Single);
            3:
                (rLo, rHi: Single);
            4:
                (mFirst, mSecond: Single);

    end;

implementation

uses
    Math;

function CutOffVal(Val: Single; Digits: integer): Single;
begin
    Result := Trunc(Val * exp(ln(10) * Digits)) / exp(ln(10) * Digits);
end;

{ TSpec }

constructor TSpec.Create(Min: Single; Max: Single);
begin
    SetRange(Min, Max);
end;

procedure TSpec.Clear(DefVal: Single);
begin
    mMin := DefVal;
    mMax := DefVal;
end;

procedure TSpec.Clear;
begin
    mMin := SPEC_MAX;
    mMax := SPEC_MIN;

end;

constructor TSpec.Create(MinStr, MaxStr: string);
begin
    ReadFromStr(MinStr, MaxStr);
end;

procedure TSpec.CalcMinMax(Val: Single);
begin
    if mMin > Val then
        mMin := Val;
    if mMax < Val then
        mMax := Val;
end;

function TSpec.IsEmpty: boolean;
begin
    Result := ((mMin = 0) and (mMax = 0)) or ((mMin = SPEC_MAX) and (mMax = SPEC_MIN));
end;

function TSpec.IsIn(Val, Offset: Single; CutOffDigit: integer): boolean;
begin
    if CutOffDigit > 0 then
    begin
        Val := CutOffVal(Val, CutOffDigit);
    end;

    Result := (((mMin - Offset) <= Val) and ((mMax + Offset) >= Val));

end;

function TSpec.IsUnderMax(Val: Single): boolean;
begin
    Result := mMax >= Val;
end;

function TSpec.IsAboveMin(Val: Single): boolean;
begin
    Result := mMin <= Val;
end;

procedure TSpec.SetRange(Min: Single; Max: Single; ForceValid: boolean);
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

function TSpec.ToMaxStr(Format, UnitStr: string): string;
var
    Str: string;
begin
    if mMax = SPEC_MIN then
        Str := ''
    else
        Str := FormatFloat(Format, mMax);

    Result := Str + ' ' + GetUnitStrVisibility(UnitStr);
end;

function TSpec.ToMidValStr(Format: string; AlphaFormat: string; IsBracket: boolean): string;
var
    ValStr: string;
    Alpha: Single;
begin
    if ((mMin = SPEC_MIN) and (mMax = SPEC_MAX)) then
    begin
        Result := '-';
    end;

    Alpha := GetRange / 2;

    ValStr := FormatFloat(Format, mMin + Alpha) + ' ±' + FormatFloat(AlphaFormat, Alpha);
    if (IsBracket) then
    begin
        Result := '(' + ValStr + ')';
    end;

    Result := ValStr + ' ' + GetUnitStrVisibility;

end;

function TSpec.ToMinStr(Format, UnitStr: string): string;
var
    Str: string;
begin
    if mMin = SPEC_MIN then
        Str := ''
    else
        Str := FormatFloat(Format, mMin);

    Result := Str + ' ' + ' ' + GetUnitStrVisibility(UnitStr);
end;

function TSpec.ToStr(Format: string; IsBracket: Boolean): string;
var
    MinStr, MaxStr: string;
begin

    if mMin = SPEC_MIN then
        MinStr := ''
    else
        MinStr := FormatFloat(Format, mMin);

    if mMax = SPEC_MAX then
        MaxStr := ''
    else
        MaxStr := FormatFloat(Format, mMax);

    if (IsBracket) then
        Result := '(' + MinStr + ' ~ ' + MaxStr + ')'
    else
        Result := MinStr + ' ~ ' + MaxStr;

    Result := Result + ' ' + GetUnitStrVisibility;
end;

function TSpec.ToStrWithUnit2(Format: string; IsUnit: Boolean): string;
var
    MinStr, MaxStr: string;
begin
    if mMin = SPEC_MIN then
        MinStr := ''
    else
        MinStr := FormatFloat(Format, mMin);
    if mMax = SPEC_MAX then
        MaxStr := ''
    else
        MaxStr := FormatFloat(Format, mMax);

    Result := MinStr + ' ~ ' + MaxStr;

    if IsUnit then
        Result := Result + ' ' + mUnitStr;
end;

function TSpec.ToStrWithUnit(Format, UnitStr: string): string;
var
    MinStr, MaxStr: string;
begin

    if mMin = SPEC_MIN then
        MinStr := ''
    else
        MinStr := FormatFloat(Format, mMin);
    if mMax = SPEC_MAX then
        MaxStr := ''
    else
        MaxStr := FormatFloat(Format, mMax);

    Result := MinStr + ' ~ ' + MaxStr + ' ' + GetUnitStrVisibility(UnitStr);

end;

function TSpec.IsValid: boolean;
begin
    Result := mMin < mMax;
end;

function RandomRangeF(min, max: Single): Single;
begin
    Result := min + Random * (max - min);
end;

function TSpec.MakeRndVal: Single;
begin
    Result := RandomRangeF(mMin, mMax);
end;

function TSpec.MidVal: Single;
begin
    Result := mMin + (mMax - mMin) / 2.0;
end;

procedure TSpec.ReadFromStr(MinStr, MaxStr: string);
var
    MinVal, MaxVal: Single;
begin
    if MinStr = '' then
        MinVal := SPEC_MIN
    else
        MinVal := StrToFloatDef(MinStr, SPEC_MIN);

    if MaxStr = '' then
        MaxVal := SPEC_MAX
    else
        MaxVal := StrToFloatDef(MaxStr, SPEC_MAX);

    SetRange(MinVal, MaxVal);
end;

procedure TSpec.SetRangeByMidVal(MidVal, AlphaVal: Single);
begin
    SetRange(MidVal - AlphaVal, MidVal + AlphaVal);
end;

function TSpec.ReadFromEdit(MinEdit, MaxEdit: TCustomEdit; DefaultMin: Single; DefaultMax: Single): Boolean;
begin
    try

        if (MinEdit = nil) or (MinEdit.Text = '') then
        begin
            if DefaultMin <> 0 then
                mMin := DefaultMin
            else
                mMin := SPEC_MIN;
        end
        else
        begin
            mMin := StrToFloatDef(MinEdit.Text, SPEC_MIN);
        end;

        if (MaxEdit = nil) or (MaxEdit.Text = '') then
        begin
            if DefaultMax <> 0 then
                mMax := DefaultMax
            else
                mMax := SPEC_MAX;
        end
        else
        begin
            mMax := StrToFloatDef(MaxEdit.Text, SPEC_MAX);
        end;

    except
        Exit(False);
    end;

    Result := IsValid;
end;

procedure TSpec.WriteToEdit(MinEdit, MaxEdit: TCustomEdit; Format: string);
begin
    if MinEdit <> nil then
    begin
        if mMin = SPEC_MIN then
            MinEdit.Text := ''
        else
            MinEdit.Text := FormatFloat(Format, mMin);
    end;


    if MaxEdit <> nil then
    begin
        if mMax = SPEC_MAX then
            MaxEdit.Text := ''
        else
            MaxEdit.Text := FormatFloat(Format, mMax);
    end;
end;

function TSpec.GetRange: Single;
begin
    if (mMin = SPEC_MIN) or (mMax = SPEC_MAX) then
        Exit(0);

    Result := abs(mMax - mMin);
end;

function TSpec.GetUnitStrVisibility(UnitStr: string): string;
begin
    Result := '';

    if UnitStr <> '' then
        Exit(UnitStr);

    if mShowUnit and (mUnitStr <> '') then
        Exit(mUnitStr);
end;

end.

