{
    Ver 240313.00
    : DO를 출력해서 해당하는 DI를 시간내 검사시 사용 ex> 워크인 라인 검사
}
unit DIOPairChecker;

interface
uses
    Windows, Sysutils, Classes, BaseFSM, TimeChecker, BaseDIO;



type
    PDIOPairItem = ^TDIOPairItem;
    TDIOPairItem = packed record
    private
        mDOCh: Integer;
        mDIChs: array of Integer;

    public

        constructor Create(DOCh, DICh: integer); overload;
        constructor Create(DOCh: integer; DIChs: array of Integer); overload;
        procedure Free;
        procedure SetCh(DOCh,DICh: integer);
        procedure SetChs(DOCh: integer; DIChs: array of Integer);

        procedure Start(DIO: TBaseDIO);
        function  IsDone(DIO: TBaseDIO): Boolean;
        function GetOnChsStr(DIO: TBaseDIO): string;

        function IsOn(DIChIdx: Integer; DIO: TBaseDIO): Boolean;
        function DIChCount: Integer;

    end;

    TDIOPairChecker = class(TBaseFSM)
    private
        mDIO: TBaseDIO;
        mTC: TTimeChecker;
        mTOSec: integer;
        mItems: array of TDIOPairItem;
        mIdx: integer;
        function GetItems(Idx: integer): PDIOPairItem;
    public
        constructor Create(DIO: TBaseDIO; Sec4TimeOut: integer = 8);
        destructor Destroy; override;

        procedure Clear;
        procedure Add(DOCh, DICh: integer); overload;
        procedure Add(DOCh: integer; DIChs: array of Integer); overload;
        function Count: integer;


        procedure FSMStart; override;
        function  FSMIRun: integer; override;

        function IsDone: boolean;

        property Items[Idx: integer] : PDIOPairItem read GetItems;

    end;

implementation
uses
    Log, LangTran;

{ TDIOPairItem }

constructor TDIOPairItem.Create(DOCh, DICh: integer);
begin
    SetCh(DOCh, DICh);
end;

constructor TDIOPairItem.Create(DOCh: integer; DIChs: array of Integer);
begin
    SetChs(DOCh, DIChs);
end;

function TDIOPairItem.DIChCount: Integer;
begin
    Result := Length(mDIChs);
end;

procedure TDIOPairItem.Free;
begin
    mDIChs := nil;
end;


function TDIOPairItem.GetOnChsStr(DIO: TBaseDIO): string;
var
    i: Integer;
begin
    for i := 0 to DIChCount - 1 do
    begin
        if  DIO.IsIO(mDIChs[i]) then
            Result := Result + IntToStr(mDIChs[i]) + ', ';
    end;

    if Length(Result) > 1 then
        Delete(Result, Length(Result) - 1, 2);

end;

function TDIOPairItem.IsDone(DIO: TBaseDIO): Boolean;
var
    i: Integer;
begin
    for i := 0 to DIChCount - 1 do
    begin
        if not DIO.IsIO(mDIChs[i]) then
            Exit(False);
    end;

    Result := True;
end;

function TDIOPairItem.IsOn(DIChIdx: Integer; DIO: TBaseDIO): Boolean;
begin
    Result := False;
    if DIChIdx > DIChCount then
        Exit;

    Result := DIO.IsIO(mDIChs[DIChIdx]);

end;

procedure TDIOPairItem.Start(DIO: TBaseDIO);
begin
    DIO.SetIO(mDOCh, False);
end;

procedure TDIOPairItem.SetCh(DOCh, DICh: integer);
begin
    mDOCh := DOCh;
    if DIChCount = 0 then
    begin
        SetLength(mDIChs, 1);
    end;

    mDIChs[0] := DICh;
end;

procedure TDIOPairItem.SetChs(DOCh: integer; DIChs: array of Integer);
var
    i: Integer;
begin
    mDOCh := DOCh;
    if DIChCount = 0 then
    begin
        SetLength(mDIChs, Length(DIChs));
    end;

    for i := 0 to DIChCount - 1 do
    begin
        mDIChs[i] := DIChs[i];
    end;

end;

{ TDIOPairChecker }


constructor TDIOPairChecker.Create(DIO: TBaseDIO; Sec4TimeOut: integer);
begin
    mDIO := DIO;
    mTOSec := Sec4Timeout;
end;

destructor TDIOPairChecker.Destroy;
var
  i: Integer;
begin
    for i := 0 to Length(mItems) - 1 do
        mItems[i].Free;

    mItems := nil;
    inherited;
end;


procedure TDIOPairChecker.FSMStart;
var
    i: integer;

begin
    inherited FSMStart;

    mIdx := 0;

    for i := 0 to Count - 1 do
    begin
        mItems[i].Start(mDIO);
    end;

end;


function TDIOPairChecker.GetItems(Idx: integer): PDIOPairItem;
begin
    try
        Result := @mItems[Idx];
    except
        raise Exception.Create(_TR('Idx가 범위를 벗어났어요!'));
    end;

end;

procedure TDIOPairChecker.Add(DOCh: integer; DIChs: array of Integer);
begin
    SetLength(mItems, Count + 1);
    mItems[Count - 1] := TDIOPairItem.Create(DOCh, DIChs);
end;

procedure TDIOPairChecker.Clear;
begin
    mItems := nil;
end;

function TDIOPairChecker.Count: integer;
begin
    Result := Length(mItems);
end;


procedure TDIOPairChecker.Add(DOCh, DICh: integer);
begin
    SetLength(mItems, Count + 1);
    mItems[Count - 1] := TDIOPairItem.Create(DOCh, DICh);
end;


function TDIOPairChecker.FSMIRun: integer;
begin
    Result := 0;
    case mState of
        0:
            ;
        1:
            begin
                mDIO.SetIO(mItems[mIdx].mDOCh, true);
                gLog.Panel('PairChecker DO: %d ON 출력', [mItems[mIdx].mDOCh]);
                mTC.Start(mTOSec * 1000);
                IncState;
            end;
        2:
            begin

                if mItems[mIdx].IsDone(mDIO) then
                begin

                    gLog.Panel('PairChecker DI: %s ON 확인', [mItems[mIdx].GetOnChsStr(mDIO)]);
                    mDIO.SetIO(mItems[mIdx].mDOCh, false);
                    Inc(mIdx);
                    if mIdx >= Count then
                    begin
                        mIdx := 0;
                        FSMStop;
                        Exit(1);
                    end;

                    IncState(-1);
                end;

                if mTC.IsTimeOut then
                begin
                    mDIO.SetIO(mItems[mIdx].mDOCh, false);
                    mIdx := 0;
                    FSMStop;
                    Exit(-1);
                end;
            end;
    end;
end;


function TDIOPairChecker.IsDone: boolean;
var
    i: integer;
begin
    for i := 0 to Count - 1 do
    begin
        if not mItems[i].IsDone(mDIO) then
            Exit(false);
    end;

    Result := true;
end;

end.
