{
    Ver.20200407.00
}

unit SpecChecker;

interface
uses
    Windows, SysUtils, Classes, ModelType, BaseDIO;

type

    TSpecIO = class
    private
        mModelType: TModelType;
        mStartCh: integer;
        mDIChs: array of boolean;
        mCmpDIMsg: string;

        function  GetDIChs(Ch: integer): boolean;
        procedure SetDIChs(Ch: integer; Value: boolean);

    public

        constructor Create(StartCh, ChCount: integer);
        destructor  Destroy; override;

        procedure Init(ModelType: TModelType);

        procedure Clear(DIO: TBaseDIO);
        procedure OutputSpecDO(DIO: TBaseDIO);
        function  CompareDI(DIO: TBaseDIO): boolean;

        property DIChs[Ch: integer]: boolean read GetDIChs write SetDIChs;
        property Msg: string read mCmpDIMsg;
    end;


implementation
uses
    SeatType, IODef, LangTran;


{ TSpecIO }

const
    SPEC_CAR_TYPE_COUNT = 1;
    SPEC_BKL_TYPE_COUNT = 0;

procedure TSpecIO.Clear(DIO: TBaseDIO);
var
    i: integer;
begin
    if Length(mDIChs) = 0 then
        Exit;

    ZeroMemory(@mDIChs[0], Length(mDIChs));

    {   // 수동 커넥터라 OFF 안함..
    for i := 0 to SPEC_CAR_TYPE_COUNT - 1 do
        DIO.SetIO(DO_SPEC_JKA + i, false);
    }
    {
    for i := 0 to SPEC_BKL_TYPE_COUNT - 1 do
        DIO.SetIO(DI_SPEC_OS_BKL_CURR + i, false);
    }

end;



constructor TSpecIO.Create(StartCh, ChCount: integer);
begin
    mStartCh := StartCh;
    SetLength(mDIChs, ChCount);

end;


destructor TSpecIO.Destroy;
begin
    mDIChs := nil;
    inherited;
end;

function TSpecIO.GetDIChs(Ch: integer): boolean;
begin
    Ch := Ch - mStartCh;

    if Ch < Length(mDIChs) then
        Result := mDIChs[Ch]
    else
        Result := false;

end;

procedure TSpecIO.Init(ModelType: TModelType);
begin
    mModelType := ModelType;
end;

procedure TSpecIO.OutputSpecDO(DIO: TBaseDIO);
begin

    if mModelType.IsDrvPos then
    begin
        case mModelType.GetCarType of
            rtMX5a: DIO.SetIO(DO_SPEC_MX5A, true);

        end;
    end
    else
    begin
        case mModelType.GetCarType of
            rtMX5a: DIO.SetIO(DO_SPEC_MX5A, true);
        end;
    end;
end;

procedure TSpecIO.SetDIChs(Ch: integer; Value: boolean);
begin
    Ch := Ch - mStartCh;

    if Ch < Length(mDIChs) then
        mDIChs[Ch] := Value;
end;


function TSpecIO.CompareDI(DIO: TBaseDIO): boolean;
begin
    Result := false;
end;

end.
