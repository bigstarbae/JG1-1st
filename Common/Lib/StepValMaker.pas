{
    Ver.221212.00

    패턴형 : Data 패턴  발생기

    Example>  2초사이 0.3초에 굴곡  X 20, Y 50 생성
        mSVMaker := TStepValMaker.Create('(2, 20)', '(0.3, 10), (0.5, 10), (1, 50)');

    ....

    if mSVMaker.FSMMake(X, Y) > 0 then
    begin
        Y := Y + random(20) * 0.1;
        chtTest.Series[0].AddXY(X, Y);
        gLog.Panel('%f', [Y]);
    end;
}
unit StepValMaker;

interface

uses
    Windows, Messages, SysUtils, Variants, Classes, TimeChecker;

type
    PStepVal = ^TStepVal;

    TStepVal = packed record
    private
        mX, mY, mPreY, mRatio: double;

        procedure CalcRatio(PreY: double);
        function GetYByX(X: double): double;

    public
        constructor Create(X, Y: double); overload;
        constructor Create(StepStr: string); overload;
    end;

    TStepVals = packed record
    private
        mIdx, mState: integer;
        mPreY: double;
        mTC: TTimeChecker;

        mItems: array of TStepVal;
        mCurItem: PStepVal;

    public
        constructor Create(StepStr: string);
        function FSMMake(var Y: double): integer;
    end;

    TStepValMaker = packed record
    private
        mXSteps, mYSteps: TStepVals;
    public

        constructor Create(XStepStr, YStepStr: string);

        procedure Start;
        procedure Stop;
        function  IsStart: boolean;

        function FSMMake(var X, Y: double): integer;
    end;

implementation

function ParseByDelimiter(var RetStr: array of string; RetStrCount: integer; SrcStr: string; Delimiter: string): integer;
var
    Count, i, j, Len, DeLen: integer;
    Token: string;
    IsFind: boolean;
begin
    Count := 0;
    Len := Length(SrcStr);
    DeLen := Length(Delimiter);

    for i := 1 to Len do
    begin
        IsFind := false;
        for j := 1 to DeLen do
        begin
            if (SrcStr[i] = Delimiter[j]) then
            begin
                if Token <> '' then
                begin
                    RetStr[Count] := Trim(Token);
                    Inc(Count);
                    Token := '';
                end;
                IsFind := true;
                Break;
            end;
        end;
        if (not IsFind) then
        begin
            Token := Token + string(SrcStr[i]);
        end;

        if (Count >= RetStrCount) then
        begin
            Break;
        end;

    end;

    if ((Token <> '') or IsFind) and (Count < RetStrCount) then
    begin
        RetStr[Count] := Trim(Token);
        Inc(Count);
    end;

    Result := Count;
end;

{ TStepVal }

procedure TStepVal.CalcRatio(PreY: double);
begin
    mPreY := PreY;
    mRatio := (mY - mPreY) / mX;
end;

constructor TStepVal.Create(X, Y: double);
begin
    mX := X;
    mY := Y;
end;


constructor TStepVal.Create(StepStr: string);
var
    Tokens: array[0..1] of string;
begin
    if ParseByDelimiter(Tokens, 2, StepStr, ',') = 2 then
    begin
        mX := StrToFloat(Tokens[0]);
        mY := StrToFloat(Tokens[1]);
    end;
    mPreY := 0;
    mRatio := 1.0;
end;

function TStepVal.GetYByX(X: double): double;
begin
    Result := mPreY + X * mRatio;
end;

{ TStepVals }

const
    MAX_STEP_VAL_COUNT = 20;

constructor TStepVals.Create(StepStr: string);
var
    Tokens: array[0..MAX_STEP_VAL_COUNT - 1] of string;
    ItemCount, TokCount: integer;
    i: Integer;
begin
    TokCount := ParseByDelimiter(Tokens, MAX_STEP_VAL_COUNT, StepStr, '()[]');

    ItemCount := 0;
    for i := 0 to TokCount - 1 do
    begin
        if Length(Tokens[i]) > 1 then
            Inc(ItemCount);
    end;

    SetLength(mItems, ItemCount);
    ItemCount := 0;
    for i := 0 to TokCount - 1 do
    begin
        if Length(Tokens[i]) > 1 then
        begin
            mItems[ItemCount] := TStepVal.Create(Tokens[i]);
            Inc(ItemCount);
        end;
    end;

end;

function TStepVals.FSMMake(var Y: double): integer;
begin
    Result := 0;
    case mState of
        0:
            begin

            end;
        1:
            begin

                mPreY := 0;
                mIdx := 0;
                Inc(mState);

            end;
        2:
            begin
                mCurItem := @mItems[mIdx];
                mCurItem.CalcRatio(mPreY);
                mPreY := mCurItem.mY;
                mTC.Start(mCurItem.mX * 1000);
                Inc(mState);
            end;
        3:
            begin
                if mTC.IsTimeOut then
                begin
                    Inc(mIdx);
                    if mIdx >= Length(mItems) then
                    begin
                        mState := 0;
                        Exit(0);
                    end;

                    Dec(mState);
                end;
                Y := mCurItem.GetYByX(mTC.GetPassTimeAsSec);
                Exit(1);
            end;

    end;
end;

{ TStepValMaker }

constructor TStepValMaker.Create(XStepStr, YStepStr: string);
begin
    mXSteps := TStepVals.Create(XStepStr);
    mYSteps := TStepVals.Create(YStepStr);
end;

function TStepValMaker.FSMMake(var X, Y: double): integer;
begin

    mXSteps.FSMMake(X);
    Result :=  mYSteps.FSMMake(Y);

end;

function TStepValMaker.IsStart: boolean;
begin
    Result := mXSteps.mState = 3;
end;

procedure TStepValMaker.Start;
begin
    mXSteps.mState := 1;
    mYSteps.mState := 1;
end;

procedure TStepValMaker.Stop;
begin
    mXSteps.mState := 0;
    mYSteps.mState := 0;
end;

end.

