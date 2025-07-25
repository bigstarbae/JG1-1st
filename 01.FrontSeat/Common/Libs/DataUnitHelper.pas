{
    . TResultOrd(TTsOrd) <-> 문자열 변환
    . Device(모터..) 키워드 조합에서 TResultOrd 생성
}
unit DataUnitHelper;


interface
uses
    DataUnit, DataUnitOrd, SysUtils, Generics.Collections, HVTester, SeatMotorType;


    function IsCtrlRO(RO: TResultOrd): boolean;

    function GetTsOrdName(TsOrd : TTsOrd) : string;
    function GetResultOrdName(ResultOrd : TResultOrd) : string;
    function GetTsOrdByName(TOName: string): TTsOrd;
    function GetResultOrdByName(RsOrdName : string) : TResultOrd;

    function GetSpecRO(MtrID: TMotorOrd; ItemName: string; Dir: TMotorDir = twForw): TResultOrd;

    function GetDataRO(ItemName: string; Dir: TMotorDir): TResultOrd;
    function GetDataROEx(ItemName: string; Dir: TMotorDir; Postfix: string): TResultOrd;
    function GetDevRO(ItemName: string; Dir: TMotorDir): TResultOrd; // 소음편차(Deviation) 전용

    function GetRsRO(ItemName: string; Dir: TMotorDir): TResultOrd; overload;
    function GetRsRO(ItemName: string): TResultOrd; overload;

    function GetMemoryOrdName(MemoryORD : TMemoryORD) : string;

    function GetLedDataRO(HVDevType: THVDevType; Step: integer) : TResultOrd;
    function GetLedRsRO(HVDevType: THVDevType; Step: integer) : TResultOrd;

    function GetCurrDataRO(HVDevType: THVDevType; IsON: boolean): TResultOrd;
    function GetCurrRsRO(HVDevType: THVDevType; IsON: boolean): TResultOrd;

    function GetMotorLimitRO(MtrID: TMotorORD): TResultOrd;



    function ExtractROStr(SrcStr: string; var ObjIdx: integer; var ObjStr, MemStr: string): integer;




implementation
uses
    Log, TypInfo, LangTran;

const
    THVDevNameStr: array[THVDevType] of string = ('HEAT', 'HEAT', 'VENT', 'VENT');
    THVDevPosStr: array[THVDevType] of string = ('DRV', 'ASS', 'DRV', 'ASS');
    TLedStepStr: array[0..3] of string = ('OFF', 'LO', 'MID', 'HI');


function IsCtrlRO(RO: TResultOrd): boolean;
begin
    Result := Pos('_CTRL', GetResultOrdName(RO)) > 0;
end;

//   roDataMtr[0].Noise  => 0, 'roDataMtr', 'Noise' 반환
function ExtractROStr(SrcStr: string; var ObjIdx: integer; var ObjStr, MemStr: string): integer;
var
    P1, P2, DotP: integer;
begin
    Result := 0;
    P1 := Pos('[', SrcStr);
    if P1 <= 0 then
        Exit;

    P2 := Pos(']', SrcStr);
    if P2 <= 0 then
        Exit;

    ObjIdx := StrToInt(Copy(SrcStr, P1 + 1, P2  - (P1 + 1)));

    ObjStr := Copy(SrcStr, 1, P1 - 1);

    DotP := Pos('.', SrcStr);

    if DotP <= 0 then
        Exit(1);

    MemStr := Copy(SrcStr, DotP + 1, Length(SrcStr) - DotP);

    Result := 2;
end;



function GetTsOrdName(TsORD : TTsORD) : string;
begin
    Result := GetEnumName(TypeInfo(TTsORD), Ord(TsORD));
end;



function GetResultOrdName(ResultORD : TResultORD) : string;
begin
    Result := GetEnumName(TypeInfo(TResultOrd), Ord(ResultOrd));
end;


function GetResultOrdByName(RsOrdName : string) : TResultOrd;
begin
    Result := TResultOrd(GetEnumValue(TypeInfo(TResultOrd), RsOrdName));
end;

function GetTsOrdByName(TOName: string): TTsOrd;
begin
    Result := TTsOrd(GetEnumValue(TypeInfo(TTsOrd), TOName));
end;



function GetSpecRO(MtrID: TMotorOrd; ItemName: string; Dir: TMotorDir): TResultOrd;
var
    Str: string;

begin
    // 속도만 전후진
    // 소음은 Max
    Str := 'rospec' + ItemName;

    if Pos('Speed', ItemName) > 0 then
    begin
        Str := Str + _MOTOR_DIR_STR[Dir] + 'HiLo_';
    end
    else {if Pos('Noise', ItemName) > 0 then  } // 로직 검토 필요
    begin
        Str := Str + 'Hi_'
    end;

    Str := Str + _MOTOR_ID_STR[MtrID];

    Result := GetResultOrdByName(Str);

end;

function GetMotorLimitRO(MtrID: TMotorOrd): TResultOrd;
var
    Str: string;
begin
    Str := 'roRs' + _MOTOR_ID_STR[MtrID] + 'Limit';
    Result := GetResultOrdByName(Str);
end;

function GetDataRO(ItemName: string; Dir: TMotorDir): TResultOrd;
var
    Str: string;
begin
    Str := 'roData' + _MOTOR_DIR_STR[Dir] + ItemName;
    Result := GetResultOrdByName(Str);
end;

function GetDataROEx(ItemName: string; Dir: TMotorDir; Postfix: string): TResultOrd;
var
    Str: string;
begin
    Str := 'roData' + _MOTOR_DIR_STR[Dir] + ItemName + Postfix;
    Result := GetResultOrdByName(Str);
end;


// 소음 편차 전용
function GetDevRO(ItemName: string; Dir: TMotorDir): TResultOrd;
var
    Str: string;
begin
    Str := 'roDev' + _MOTOR_DIR_STR[Dir] + ItemName;
    Result := GetResultOrdByName(Str);
end;

function GetRsRO(ItemName: string; Dir: TMotorDir): TResultOrd;
var
    Str: string;
begin
    Str := 'roRs' +  _MOTOR_DIR_STR[Dir] + ItemName;
    Result := GetResultOrdByName(Str);

end;

function GetRsRO(ItemName: string): TResultOrd;
var
    Str: string;
begin
    Str := 'roRs' + ItemName;
    Result := GetResultOrdByName(Str);

end;


function GetMemoryOrdName(MemoryORD : TMemoryORD) : string;
begin

    case MemoryOrd of
        meMEM1: Result := _TR('메모리 1');
        meMEM2: Result := _TR('메모리 2');
        meKEY_ON: Result := _TR('승차');
        meKEY_OFF: Result := _TR('하차');
    end;

end;

function GetLedDataRO(HVDevType: THVDevType; Step: integer) : TResultOrd;
begin
    Result := GetResultOrdByName('roDat' + THVDevNameStr[HVDevType] + 'Led' + TLedStepStr[Step] + 'Bit' + THVDevPosStr[HVDevType]);
end;

function GetLedRsRO(HVDevType: THVDevType; Step: integer) : TResultOrd;
begin
    Result := GetResultOrdByName('roRs' + THVDevNameStr[HVDevType] + 'Led' + TLedStepStr[Step] + THVDevPosStr[HVDevType]);
end;


function GetCurrDataRO(HVDevType: THVDevType; IsON: boolean): TResultOrd;
begin
    if IsOn then
        Result := roDatOnCurr
    else
        Result := roDatOffCurr
end;

function GetCurrRsRO(HVDevType: THVDevType; IsON: boolean): TResultOrd;
begin
    if IsOn then
        Result := roRsOnCurr
    else
        Result := roRsOffCurr;

end;

initialization



Finalization
end.


