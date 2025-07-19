unit BaseDataBox;

interface

uses
    Classes, Generics.Collections, DataUnit, DataUnitOrd;

type

    TBaseDataBox = class
    protected
        mTag: integer; // 검사공정에선 공정구분
        mIsProcessDone: boolean;

        function  GetTag: integer; virtual;
        procedure SetTag(Tag: integer); virtual;

        procedure SetValidity; virtual;
        procedure SetExists(AORD: TResultORD; const IsExist: boolean); virtual;
        function GetUnitStr(AORD: TResultORD): string; virtual;
    public
        constructor Create(); overload;
        constructor Create(ATag: integer); overload;

        procedure InitData(AReadEnv: boolean = false); virtual;
        procedure SetDataInit(ATsMode: TTsORD); virtual;

        function GetPResultBuffer(): PResult; virtual; abstract;
        procedure SetResult(const AResult; Afpos: integer = -1); virtual; abstract;
//        function  GetModel: TModel; virtual; abstract;

        function IsExists(AORD: TResultORD): boolean; overload; virtual;
        function IsTested(AORD: TResultORD): boolean; overload; virtual;

        function GetData(AORD: variant; ADigit: integer = 0): double; overload; virtual;
        function GetData(AORD: TResultORD; ADigit: integer = 0): double; overload; virtual;
        function GetResult(AORD: variant): boolean; overload; virtual;
        function GetResult(AORD: TResultORD): boolean; overload; virtual;
        function GetResult(ATsMode: TTsORD): boolean; overload; virtual;
        function GetResultToATxt(APos: integer; IsUnit: boolean; IsResult: boolean = false): string; virtual;


        procedure SetData(AORD: variant; const Value: double); overload; virtual;
        procedure SetData(AORD: TResultORD; const Value: double); overload; virtual;
        procedure SetData(AORD: TResultORD; const Value: string); overload; virtual;
        procedure SetData(AORD: TResultORD; const Value: boolean); overload; virtual;
        procedure SetData(AORD: TResultORD; const Value: integer); overload; virtual;



        property Tag : integer read GetTag write SetTag;
        property IsProcessDone: boolean read misProcessDone write misProcessDone; // Get/GetData,

        property RsBuf: PResult read GetPResultBuffer;
    end;

    TDataBoxList = TList<TBaseDataBox>;

    // Composite Pattern
    TCompoDataBox = class(TBaseDataBox)
    protected
        mDBXList:       TDataBoxList;

        procedure SetValidity; override;
    public
        constructor Create;
        destructor Destroy; override;


        procedure InitData(AReadEnv: boolean); override;
        procedure SetDataInit(ATsMode: TTsORD); override;

        function  IsExists(AORD: TResultORD): boolean; override;
        function  IsTested(AORD: TResultORD): boolean; override;

        function  GetData(AORD: TResultORD; ADigit: integer = 0): double; override;
        function  GetResult(AORD: TResultORD): boolean ; overload ; override;
        function  GetResult(ATsMode: TTsORD): boolean; overload; override;
        function  GetResultToATxt(APos: integer; IsUnit, IsResult: boolean): string; override;

        procedure SetData(AORD: TResultORD; const Value: double) ; overload; override;
        procedure SetData(AORD: TResultORD; const Value: string) ; overload; override;
        procedure SetData(AORD: TResultORD; const Value: boolean); overload; override;
        procedure SetData(AORD: TResultOrd; const Value: integer); overload; override;

    end;


    function GetUnitStr(AORD: TResultOrd): string;

implementation
uses
    TypInfo, SysUtils;

function GetUnitStr(AORD: TResultOrd): string;
var
    Str: string;
begin
    Str := LowerCase(GetEnumName(TypeInfo(TResultOrd), Ord(AOrd)));

    Result := '';

    if Pos('curr', Str) > 0 then
        Result := ' A'
    else if Pos('load', Str) > 0 then
        Result := ' Kg'
    else if Pos('angle', Str) > 0  then
        Result := ' °  '
    else if Pos('pos', Str) > 0  then
        Result := ' mm';


end;

{ TBaseDataBox }

constructor TBaseDataBox.Create;
begin

end;


constructor TBaseDataBox.Create(ATag: integer);
begin
    Tag := ATag;
end;


function TBaseDataBox.GetData(AORD: TResultORD; ADigit: integer): double;
begin
    Result := 0.0;
end;

function TBaseDataBox.GetData(AORD: variant; ADigit: integer): double;
begin
    Result := 0.0;
end;

function TBaseDataBox.GetResult(ATsMode: TTsORD): boolean;
begin
    Result := false;
end;

function TBaseDataBox.GetResult(AORD: TResultORD): boolean;
begin
    Result := false;
end;

function TBaseDataBox.GetResult(AORD: variant): boolean;
begin
    Result := false;
end;

function TBaseDataBox.GetResultToATxt(APos: integer; IsUnit, IsResult: boolean): string;
begin
    Result := '';
end;

function TBaseDataBox.GetTag: integer;
begin
    Result := mTag;
end;

function TBaseDataBox.GetUnitStr(AORD: TResultORD): string;
begin
    Result := '';
end;

procedure TBaseDataBox.InitData(AReadEnv: boolean);
begin

end;


function TBaseDataBox.IsExists(AORD: TResultORD): boolean;
begin
    Result := false;
end;

function TBaseDataBox.IsTested(AORD: TResultORD): boolean;
begin
    Result := false;
end;

procedure TBaseDataBox.SetData(AORD: TResultORD; const Value: boolean);
begin

end;

procedure TBaseDataBox.SetData(AORD: TResultORD; const Value: integer);
begin

end;

procedure TBaseDataBox.SetData(AORD: variant; const Value: double);
begin

end;

procedure TBaseDataBox.SetData(AORD: TResultORD; const Value: double);
begin

end;

procedure TBaseDataBox.SetData(AORD: TResultORD; const Value: string);
begin

end;

procedure TBaseDataBox.SetDataInit(ATsMode: TTsORD);
begin

end;


procedure TBaseDataBox.SetExists(AORD: TResultORD; const IsExist: boolean);
begin

end;

procedure TBaseDataBox.SetTag(Tag: integer);
begin
    mTag := Tag;
end;

procedure TBaseDataBox.SetValidity;
begin

end;

//--------------------------------------------------------------------------------------
constructor TCompoDataBox.Create;
begin
    mDBXList := TDataBoxList.Create;
end;

destructor TCompoDataBox.Destroy;
var
    i: Integer;
begin

    for i := 0 to mDBXList.Count - 1 do
    begin
        if Assigned(mDBXList[i]) then
            mDBXList[i].Free;
    end;

    mDBXList.Free;

    inherited;
end;

function TCompoDataBox.GetData(AORD: TResultORD; ADigit: integer): double;
var
    i: integer;
begin
    Result := 0;
    mIsProcessDone := false;

    for i := 0 to mDBXList.Count - 1 do
    begin
        Result := mDBXList[i].GetData(AORD, ADigit);
        if mDBXList[i].IsProcessDone then
        begin
            mIsProcessDone := true;
            Exit;
        end;
    end;
end;


function TCompoDataBox.GetResult(ATsMode: TTsORD): boolean;
var
    i: integer;

begin
    Result := false;

    for i := 0 to mDBXList.Count - 1 do
    begin
        Result := mDBXList[i].GetResult(ATsMode);
        if mDBXList[i].IsProcessDone then
        begin
            mIsProcessDone := true;
            Exit;
        end;
    end;
end;

function TCompoDataBox.GetResultToATxt(APos: integer; IsUnit, IsResult: boolean): string;
var
    i: integer;

begin
    Result := '';
    mIsProcessDone := false;

    for i := 0 to mDBXList.Count - 1 do
    begin
        Result := mDBXList[i].GetResultToATxt(APos, IsUnit, IsResult);
        if mDBXList[i].IsProcessDone then
        begin
            mIsProcessDone := true;
            Exit;
        end;
    end;
end;

function TCompoDataBox.GetResult(AORD: TResultORD): boolean;
var
    i: integer;
begin
    Result := false;
    misProcessDone := false;

    for i := 0 to mDBXList.Count - 1 do
    begin
        Result := mDBXList[i].GetResult(AORD);
        if mDBXList[i].IsProcessDone then
        begin
            mIsProcessDone := true;
            Exit;
        end;
    end;
end;



procedure TCompoDataBox.InitData(AReadEnv: boolean);
var
    i: integer;
begin
    for i := 0 to mDBXList.Count - 1 do
    begin
        mDBXList[i].InitData(AReadEnv);
    end;
end;


function TCompoDataBox.IsExists(AORD: TResultORD): boolean;
var
    i: integer;
begin
    Result := false;

    mIsProcessDone := false;

    for i := 0 to mDBXList.Count - 1 do
    begin
        Result := mDBXList[i].IsExists(AORD);

        if mDBXList[i].IsProcessDone then
        begin
            mIsProcessDone := true;
            Exit;
        end;
    end;
end;


function TCompoDataBox.IsTested(AORD: TResultORD): boolean;
var
    i: integer;

begin
    Result := false;
    misProcessDone := false;

    for i := 0 to mDBXList.Count - 1 do
    begin
        Result := mDBXList[i].IsTested(AORD);

        if mDBXList[i].IsProcessDone then
        begin
            mIsProcessDone := true;
            Exit;
        end;
    end;
end;

procedure TCompoDataBox.SetData(AORD: TResultORD; const Value: integer);
var
    i: integer;
begin
    misProcessDone := false;

    for i := 0 to mDBXList.Count - 1 do
    begin
        mDBXList[i].SetData(AORD, Value);
        if mDBXList[i].IsProcessDone then
        begin
            mIsProcessDone := true;
            Exit;
        end;
    end;

end;

procedure TCompoDataBox.SetDataInit(ATsMode: TTsORD);
var
    i: integer;
begin
    for i := 0 to mDBXList.Count - 1 do
    begin
        mDBXList[i].SetDataInit(ATsMode);
        if mDBXList[i].IsProcessDone then
        begin
            mIsProcessDone := true;
            Exit;
        end;
    end;

end;


procedure TCompoDataBox.SetValidity;
var
    i: integer;
begin
    for i := 0 to mDBXList.Count - 1 do
    begin
        mDBXList[i].SetValidity;
    end;
end;

procedure TCompoDataBox.SetData(AORD: TResultORD; const Value: boolean);
var
    i: integer;
begin
    mIsProcessDone := false;

    for i := 0 to mDBXList.Count - 1 do
    begin
        mDBXList[i].SetData(AORD, Value);
        if mDBXList[i].IsProcessDone then
        begin
            misProcessDone := true;
            Exit;
        end;
    end;

end;

procedure TCompoDataBox.SetData(AORD: TResultORD; const Value: double);
var
    i: integer;
begin
    mIsProcessDone := false;

    for i := 0 to mDBXList.Count - 1 do
    begin
        mDBXList[i].SetData(AORD, Value);
        if mDBXList[i].IsProcessDone then
        begin
            mIsProcessDone := true;
            Exit;
        end;
    end;

end;

procedure TCompoDataBox.SetData(AORD: TResultORD; const Value: string);
var
    i: integer;
begin
    mIsProcessDone := false;

    for i := 0 to mDBXList.Count - 1 do
    begin
        mDBXList[i].SetData(AORD, Value);
        if mDBXList[i].IsProcessDone then
        begin
            mIsProcessDone := true;
            Exit;
        end;
    end;

end;

end.
