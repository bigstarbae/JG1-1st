unit siAPD;
{$I mydefine.inc}
interface
uses
	Windows, Sysutils, Classes ;

type
TUsrBuf = packed record
    rX, rY : double ;
end ;
TAPD = class
private
    mstdDist,
    mLstDist : double ;
    mBuf : array[0..31]of TUsrBuf ;
    mIDx : integer ;

    mX, mY : double ;

    function GetCalY  : double ;
public
    constructor Create ;
    destructor  Destroy ; override ;

    procedure Initial ;
    procedure SetstdDist(Value: double) ;

    function  Add(X, Y: double): boolean ;
    function  GetX : double ;
    function  GetY : double ;
    //계산상 마지막이 남을 수 있다 말끔하게 정리.
    function  SetLastCalc : boolean ;
end ;
TAPD2 = class
private
    mIndex : integer ;
    mBuf : array of double ;
public
    constructor Create(aCount: WORD) ;
    destructor  Destroy ; override ;

    procedure Initial ;
    procedure SetCount(Value: WORD);
    function  Add(Value: double; IsUse:boolean=true): double ;
    function  Count : integer ;
end ;
TAPD3 = class
private
    mIndex, mMaxCount : integer ;
    mBuf : array of double ;
public
    constructor Create ;
    destructor  Destroy ; override ;

    procedure Initial ;
    procedure SetCount(Value: WORD);
    function  Add(Value: double; IsUse:boolean=true): double ;
    function  Count : integer ;
end ;

TAPD4 = class
private
    mIndex, mFilterLevel,mMaxCount : integer ;
    mOldValue: double;
public
    constructor Create ;
    destructor  Destroy ; override ;

    procedure Initial ;
    procedure SetCount(Value: WORD);
    function  Add(Value: double; IsUse:boolean=true): double ;
    function  Count : integer ;
end ;



implementation
uses
    Log , Math;

//------------------------------------------------------------------------------
function GetPointToTorque(A1, A2, A3, T1, T3: double): double ;
begin
    Result := T3 ;
    if ((A2-A1)*(T3-T1)*(A3-A1)) = 0 then Exit ;
    try
        Result := T1 + (((A2-A1)*(T3-T1))/(A3-A1));
    except
        Result := T3 ;
    end ;
end ;
//------------------------------------------------------------------------------

{ TAPD }

function TAPD.Add(X, Y: double): boolean;
begin
    Result := true ;
    mX := X ;
    mY := Y ;
    if {(Length(mBuf) <= 1) or }(mstdDist <= 0) then Exit ;

    Result := false ;
    Inc(mIDx) ;

    if X < mLstDist then
    begin
        if mIDx > Length(mBuf) then
        begin
            Move(mBuf[1], mBuf[0], sizeof(TUsrBuf)*(Length(mBuf)-1)) ;
            mIDx := Length(mBuf) ;
        end ;

        mBuf[mIDx-1].rX := X ;
        mBuf[mIDx-1].rY := Y ;
    end
    else
    if (X = mLstDist) or (mIDx <= 1) then
    begin
        mIDx := 0 ;
        FillChar(mBuf, Length(mBuf) * sizeof(TUsrBuf), 0) ;
        Result := true ;
    end
    else
    begin
        Dec(mIDx) ;

        mY := GetCalY / mIDx ;
        mX := mBuf[mIDx-1].rX ;

        mY := GetPointToTorque(mX, mLstDist, X, mY, Y) ;
        mX := mLstDist ;

        mIDx := 1 ;
        mBuf[0].rX := X ;
        mBuf[1].rY := Y ;
        Result := true ;
    end ;

    if Result then mLstDist := mLstDist + mstdDist ;
end;

constructor TAPD.Create ;
begin
    mstdDist := 0.1 ;
    Initial ;
end;

destructor TAPD.Destroy;
begin
  inherited;
end;

function TAPD.GetCalY: double;
var
    i : integer ;
begin
    Result := 0 ;
    for i := 0 to mIDx -1 do
    begin
        Result := Result + mBuf[i].rY ;
    end ;
    Result := Result / mIDx ;
end;

function TAPD.GetX: double;
begin
    Result := mX ;
end;

function TAPD.GetY: double;
begin
    Result := mY ;
end;

procedure TAPD.Initial;
begin
    FillChar(mBuf, Length(mBuf) * sizeof(TUsrBuf), 0) ;
    mIDx := 0 ;

    mX := 0;
    mY := 0 ;

    mLstDist := mstdDist ;
end;

function TAPD.SetLastCalc: boolean;
begin
    Result := mIDx > 0 ;
    if not Result then Exit ;
    
    mY := GetCalY ;
    mX := mBuf[mIDx-1].rX ;
end;

procedure TAPD.SetstdDist(Value: double);
begin
    mstdDist := Value ;
    Initial ;
end;

{ TAPD2 }

function TAPD2.Add(Value: double; IsUse:boolean): double;
begin
    Result := Value ;
    if not IsUse or (Length(mBuf) = 0) then Exit ;

    if mIndex < Length(mBuf) then
    begin
        mBuf[mIndex] := Value ;
        Result := Sum(mBuf) / Length(mBuf) ;
    end ;

    Inc(mIndex) ;
    mIndex := mIndex mod Length(mBuf) ;
end;

function TAPD2.Count: integer;
begin
    Result := Length(mBuf) ;
end;

constructor TAPD2.Create(aCount: WORD);
begin
    mIndex := 0 ;
    if aCount > 0 then SetLength(mBuf, aCount) ;
end;

destructor TAPD2.Destroy;
begin
    if Length(mBuf) > 0 then SetLength(mBuf, 0) ;
end;

procedure TAPD2.Initial;
begin
    mIndex := 0 ;
    if Length(mBuf) > 0 then
    begin
        FillChar(mBuf[0], sizeof(double)*Length(mBuf), 0) ;
    end ;
end;

procedure TAPD2.SetCount(Value: WORD);
begin
    if Length(mBuf) = Value then Exit ;

    if Value = 0 then
    begin
        if Length(mBuf) > 0 then SetLength(mBuf, 0) ;
        Exit ;
    end ;

    SetLength(mBuf, Value) ;
end;

{ TAPD3 }

function TAPD3.Add(Value: double; IsUse: boolean): double;
begin
    Result := Value ;
    if not IsUse or (mMaxCount <= 1) then Exit ;

    Inc(mIndex) ;
    if mIndex > mMaxCount then
    begin
        mIndex := mMaxCount;
    end ;
    if Length(mBuf) < mIndex then
    begin
        SetLength(mBuf, mIndex) ;
    end
    else
    begin
        Move(mBuf[1], mBuf[0], (Length(mBuf)-1) * sizeof(double)) ;
    end;
    mBuf[mIndex-1] := Value ;
    Result := Sum(mBuf) / Length(mBuf) ;
end;

function TAPD3.Count: integer;
begin
    Result := mMaxCount ;
end;

constructor TAPD3.Create;
begin
    mMaxCount := 100 ;
    Initial;
end;

destructor TAPD3.Destroy;
begin
    Initial ;
  inherited;
end;

procedure TAPD3.Initial;
begin
    mIndex := 0 ;
    if Length(mBuf) > 0 then SetLength(mBuf, 0) ;
end;

procedure TAPD3.SetCount(Value: WORD);
begin
    mMaxCount := Value ;
    Initial ;
end;

{ TAPD4 }

function TAPD4.Add(Value: double; IsUse: boolean): double;
begin
    Result := Value ;
    if not IsUse or (mMaxCount <= 0) or (mFilterLevel = 0) then Exit ;
    Result := mOldValue - (mOldValue/mFilterLevel) + (Value/mFilterLevel);
    mOldValue := Result;
end;

function TAPD4.Count: integer;
begin
    Result := mMaxCount;
end;

constructor TAPD4.Create;
begin
    mFilterLevel := 2;
    mMaxCount := 0;
    mOldValue := 0;
end;

destructor TAPD4.Destroy;
begin
    Initial ;
  inherited;
end;

procedure TAPD4.Initial;
begin
    mMaxCount := 0;
    mOldValue := 0;
end;

procedure TAPD4.SetCount(Value: WORD);
begin
    mMaxCount :=Value;
    if Value <= 0 then
    begin
        mFilterLevel :=0;
    end
    else if Value <= 2 then
    begin
        mFilterLevel :=2;
    end
    else if Value <= 99 then
    begin
        mFilterLevel :=Value;
    end
    else
    begin
        mFilterLevel :=128;
    end
end;


end.
