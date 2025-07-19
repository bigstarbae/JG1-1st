unit RefVoltSetter;

interface

uses
    SysUtils, Classes, IniFiles, BaseAO;

type
    TRefVoltSetter = class
    private
        mAOs: array of TBaseAO;
        mRefVolts: array of Double;
        mChCount: Integer;
    public
        constructor Create(AOCount, ChCount: Integer); overload;
        constructor Create(AOs: array of TBaseAO; ChCount: Integer); overload;

        procedure AddAO(AO: TBaseAO);
        procedure SetAO(AOIdx: Integer; AO: TBaseAO);

        procedure SetRefVolt(AOIdx: Integer; Volt: Double);

        procedure ApplyToAll; overload;
        procedure ApplyToAll(Volt: Double); overload;

        procedure Write(Ini: TIniFile);
        procedure Read(Ini: TIniFile);

        function GetVolt(AOIdx: Integer): Double;
        procedure ResetAll;
    end;

implementation

constructor TRefVoltSetter.Create(AOCount, ChCount: Integer);
begin
    inherited Create;
    mChCount := ChCount;
    SetLength(mAOs, AOCount);  // 빈 배열로 초기화
    SetLength(mRefVolts, AOCount);
end;

constructor TRefVoltSetter.Create(AOs: array of TBaseAO; ChCount: Integer);
var
    i: Integer;
begin
    inherited Create;
    mChCount := ChCount;
    SetLength(mAOs, Length(AOs));
    SetLength(mRefVolts, Length(AOs));

    for i := 0 to High(AOs) do
    begin
        mAOs[i] := AOs[i];
        mRefVolts[i] := 0.0;  // 초기 전압값을 0으로 설정
    end;
end;

procedure TRefVoltSetter.AddAO(AO: TBaseAO);
var
    NewIndex: Integer;
begin
    NewIndex := Length(mAOs);
    SetLength(mAOs, NewIndex + 1);
    SetLength(mRefVolts, NewIndex + 1);
end;

procedure TRefVoltSetter.SetAO(AOIdx: Integer; AO: TBaseAO);
var
    NewIndex: Integer;
begin
    if (AOIdx < 0) or (AOIdx >= Length(mAOs)) then
        raise Exception.Create('Invalid AO index');

    mAOs[AOIdx] := AO;

end;

procedure TRefVoltSetter.SetRefVolt(AOIdx: Integer; Volt: Double);
var
    Ch: Integer;
begin
    if (AOIdx < 0) or (AOIdx >= Length(mAOs)) then
        raise Exception.Create('Invalid AO index');

    mRefVolts[AOIdx] := Volt;

    for Ch := 0 to mChCount - 1 do
        mAOs[AOIdx].SetVolt(Ch, Volt);
end;

procedure TRefVoltSetter.ApplyToAll;
var
    i, Ch: Integer;
begin
    for i := 0 to High(mAOs) do
    begin
        for Ch := 0 to mChCount - 1 do
            mAOs[i].SetVolt(Ch, mRefVolts[i]);
    end;
end;

procedure TRefVoltSetter.ApplyToAll(Volt: Double);
var
    i, Ch: Integer;
begin
    for i := 0 to High(mAOs) do
    begin
        mRefVolts[i] := Volt;

        for Ch := 0 to mChCount - 1 do
            mAOs[i].SetVolt(Ch, Volt);
    end;
end;

procedure TRefVoltSetter.Write(Ini: TIniFile);
var
    i: Integer;
begin
    for i := 0 to High(mRefVolts) do
        Ini.WriteFloat('REF.VOLT SETTER', 'REF.VOLT' + IntToStr(i), mRefVolts[i]);
end;

procedure TRefVoltSetter.Read(Ini: TIniFile);
var
    i: Integer;
begin
    for i := 0 to High(mRefVolts) do
        mRefVolts[i] := Ini.ReadFloat('REF.VOLT SETTER', 'REF.VOLT' + IntToStr(i), -1);
end;

function TRefVoltSetter.GetVolt(AOIdx: Integer): Double;
begin
    if (AOIdx < 0) or (AOIdx >= Length(mAOs)) then
        raise Exception.Create('Invalid AO index');

    Result := mRefVolts[AOIdx];
end;

procedure TRefVoltSetter.ResetAll;
var
    i: Integer;
begin
    for i := 0 to High(mAOs) do
        SetRefVolt(i, -1);
end;

end.

