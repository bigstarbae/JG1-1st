{
    Ver 240318.00
    : DO를 출력해서 해당하는 AI(PIN 전압)체크, 히터 결선 검증등에 사용
}
unit WiringTester;

{$I myDefine.inc}

interface

uses
    Windows, Sysutils, Classes, BaseFSM, TimeChecker, BaseDIO, BaseAD;

type
    TWiringTester = class;

    PIOPairItem = ^TIOPairItem;

    TIOPairItem = packed record
    private
        mIdx, mDOCh: Integer;
        mAIChs: array of Integer;
        mParent: TWiringTester;


        function AIChToIdx(AICh: Integer): Integer;
    public

        constructor Create(Parent: TWiringTester; DOCh, AICh: integer); overload;
        constructor Create(Parent: TWiringTester; DOCh: integer; AIChs: array of Integer); overload;
        procedure Free;
        procedure SetCh(DOCh, AICh: integer);
        procedure SetChs(DOCh: integer; AIChs: array of Integer);

        procedure Start;

        function IsAllOn: Boolean;
        function IsOK(Idx: Integer): Boolean;
        function IsOKByAICh(AICh: Integer): Boolean;

        function GetTarVolt(Idx: Integer): Double;

        function AIChCount: Integer;

        function GetAIChStatusStr: string;

        property DOCh: Integer read mDOCh;
        property Idx: Integer read mIdx;
    end;

    TWTStatusEvent = procedure(Item: PIOPairItem) of object;

    TWiringTester = class(TBaseFSM)
    private
        mTarVolt: Double;
        mDIO: TBaseDIO;
        mAD: TBaseAD;
        mTC: TTimeChecker;
        mTOSec: integer;
        mItems: array of TIOPairItem;
        mCurItem:  TIOPairItem;
        mIdx: integer;

        mOnStatus: TWTStatusEvent;

        function GetItems(Idx: integer): PIOPairItem;
        function IsOn(AICh: Integer): Boolean;
        function IsAllOn: boolean;

    public
        constructor Create(DIO: TBaseDIO; AD: TBaseAD; TarVolt: Double = 13.5; Sec4TimeOut: integer = 1);
        destructor Destroy; override;

        procedure Stop;

        procedure Clear;
        procedure Add(DOCh, AICh: integer); overload;
        procedure Add(DOCh: integer; AIChs: array of Integer); overload;
        function  Count: integer;

        procedure FSMStart; override;
        function  FSMIRun: integer; override;

        function GetVolt(AICh: Integer): Double;
        function GetOnItemExcept(const ExcludeItem: PIOPairItem): PIOPairItem;

        property Items[Idx: integer]: PIOPairItem read GetItems; default;
        property TarVolt: Double read mTarVolt write mTarVolt;

        property OnStatus: TWTStatusEvent read mOnStatus write mOnStatus;
        property CurItem: TIOPairItem read mCurItem;
    end;

implementation

uses
    Log, myUtils;

{ TIOPairItem }

constructor TIOPairItem.Create(Parent: TWiringTester; DOCh, AICh: integer);
begin
    mParent := Parent;
    SetCh(DOCh, AICh);
end;

constructor TIOPairItem.Create(Parent: TWiringTester; DOCh: integer; AIChs: array of Integer);
begin
    mParent := Parent;
    SetChs(DOCh, AIChs);
end;

function TIOPairItem.AIChCount: Integer;
begin
    Result := Length(mAIChs);
end;

procedure TIOPairItem.Free;
begin
    mAIChs := nil;
end;



function TIOPairItem.GetAIChStatusStr: string;
begin
    if AIChCount = 1 then
        Result := Format('[%d] AI CH%d:%s(%fV) 확인', [mIdx, mAIChs[0], BoolToStr(IsOK(0), True), GetTarVolt(0)])
    else
        Result := Format('[%d] AI CH%d:%s(%fV), CH%d:%s(%fV) 확인', [mIdx, mAIChs[0], BoolToStr(IsOK(0), True), GetTarVolt(0),  mAIChs[1], BoolToStr(IsOK(1), True), GetTarVolt(1)]);

end;

function TIOPairItem.GetTarVolt(Idx: Integer): Double;
begin
    Result := 0;
    if Idx < AIChCount then
        Result := mParent.GetVolt(mAIChs[Idx]);
end;

function TIOPairItem.IsAllOn: Boolean;
var
    i: Integer;
begin
    for i := 0 to AIChCount - 1 do
    begin
        if not mParent.IsOn(mAIChs[i]) then
            Exit(False);
    end;

    Result := True;
end;

function TIOPairItem.AIChToIdx(AICh: Integer): Integer;
var
    i: Integer;
begin
    Result := -1;

    for i := 0 to AIChCount - 1 do
    begin
        if mAIChs[i] = AICh then
            Exit(i);
    end;

end;

function TIOPairItem.IsOKByAICh(AICh: Integer): Boolean;
begin
    Result := mParent.IsOn(AICh);

end;

function TIOPairItem.IsOK(Idx: Integer): Boolean;
begin
    Result := True;
    if Idx < AIChCount then
        Result := mParent.IsOn(mAIChs[Idx]);
end;

procedure TIOPairItem.Start;
begin
    mParent.mDIO.SetIO(mDOCh, False);
end;

procedure TIOPairItem.SetCh(DOCh, AICh: integer);
begin
    mDOCh := DOCh;
    if AIChCount = 0 then
    begin
        SetLength(mAIChs, 1);
    end;

    mAIChs[0] := AICh;
end;

procedure TIOPairItem.SetChs(DOCh: integer; AIChs: array of Integer);
var
    i: Integer;
begin
    mDOCh := DOCh;
    if AIChCount = 0 then
    begin
        SetLength(mAIChs, Length(AIChs));
    end;

    for i := 0 to AIChCount - 1 do
    begin
        mAIChs[i] := AIChs[i];
    end;

end;

{ TWiringTester }

constructor TWiringTester.Create(DIO: TBaseDIO; AD: TBaseAD; TarVolt: Double; Sec4TimeOut: integer);
begin
    mDIO := DIO;
    mAD := AD;
    mTarVolt := TarVolt;
    mTOSec := Sec4TimeOut;
end;

destructor TWiringTester.Destroy;
var
    i: Integer;
begin
    for i := 0 to Length(mItems) - 1 do
        mItems[i].Free;

    mItems := nil;
    inherited;
end;

procedure TWiringTester.FSMStart;
var
    i: integer;
begin
    inherited FSMStart;

    mIdx := 0;

    for i := 0 to Count - 1 do
    begin
        mItems[i].Start;
    end;

end;

function TWiringTester.GetItems(Idx: integer): PIOPairItem;
begin
    try
        Result := @mItems[Idx];
    except
        raise Exception.Create('Idx가 범위를 벗어났어요!');
    end;

end;

procedure TWiringTester.Add(DOCh: integer; AIChs: array of Integer);
begin
    SetLength(mItems, Count + 1);
    mItems[Count - 1] := TIOPairItem.Create(Self, DOCh, AIChs);
    mItems[Count - 1].mIdx := Count - 1;
end;

procedure TWiringTester.Clear;
begin
    mItems := nil;
end;

function TWiringTester.Count: integer;
begin
    Result := Length(mItems);
end;

procedure TWiringTester.Add(DOCh, AICh: integer);
begin
    SetLength(mItems, Count + 1);
    mItems[Count - 1] := TIOPairItem.Create(Self, DOCh, AICh);
    mItems[Count - 1].mIdx := Count - 1;
end;

function TWiringTester.FSMIRun: integer;
begin
    Result := 0;
    case mState of
        0:
            ;
        1:
            begin
                mCurItem := mItems[mIdx];
                mDIO.SetIO(mItems[mIdx].mDOCh, true);
                gLog.Panel('[%d] DO CH%d:ON 출력', [mIdx, mItems[mIdx].mDOCh]);
                mTC.Start(mTOSec * 1000);
                IncState;
            end;
        2:
            begin

                if mItems[mIdx].IsAllOn then
                begin
                    if Assigned(mOnStatus) then
                        mOnStatus(@mItems[mIdx]);

                    gLog.Panel(mItems[mIdx].GetAIChStatusStr);
                    IncState;
                end;

                if mTC.IsTimeOut then
                begin
                    if Assigned(mOnStatus) then
                        mOnStatus(@mItems[mIdx]);

                    gLog.Panel(mItems[mIdx].GetAIChStatusStr);
                    gLog.Panel('=>' + GetOnItemExcept(@mItems[mIdx]).GetAIChStatusStr);
                    IncState;
                end;
            end;
        3:
            begin
                mDIO.SetIO(mItems[mIdx].mDOCh, false);

                Inc(mIdx);
                if mIdx >= Count then
                begin
                    mIdx := 0;
                    Stop;
                    Exit(1);
                end;

                mState := 1;

            end;
    end;
end;

function TWiringTester.GetOnItemExcept(const ExcludeItem: PIOPairItem): PIOPairItem;
var
    i: integer;
begin
    Result := ExcludeItem;

    for i := 0 to Count - 1 do
    begin
        if (@mItems[i] <> ExcludeItem) and (mItems[i].IsOK(0) or mItems[i].IsOK(1)) then
        begin
            Exit(@mItems[i]);
        end;
    end;
end;

function TWiringTester.GetVolt(AICh: Integer): Double;
begin
    Result := mAD.GetVolt(AICh);
end;

function TWiringTester.IsAllOn: boolean;
var
    i: integer;
begin
    for i := 0 to Count - 1 do
    begin
        if not mItems[i].IsAllOn then
            Exit(false);
    end;

    Result := true;
end;

function TWiringTester.IsOn(AICh: Integer): Boolean;
begin
{$IFDEF VIRTUALIO}

    Result := (AICh mod 2) = 0;

{$ELSE}
    Result := (mTarVolt * 0.4) <= mAD.GetVolt(AICh);
    Sleep(1);
   // gLog.Debug('CH%d:%f', [AICh, mAD.GetVolt(AICh)]);
{$ENDIF}
end;

procedure TWiringTester.Stop;
var
    i: Integer;
begin
    for i := 0 to Count - 1 do
        mDIO.SetIO(mItems[mIdx].mDOCh, false);
end;

end.

