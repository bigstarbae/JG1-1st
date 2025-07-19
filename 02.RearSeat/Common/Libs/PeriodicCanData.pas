unit PeriodicCanData;

interface

uses
    Classes, BaseCAN, IntervalCaller, Log, ModelType, SysUtils, SeatType;

const
    // Interval Caller
    IC_IGN_AND_P = 'IC_IGN_P';
    IC_IGN3 = 'IC_IGN3';
    IC_SPEED = 'IC_SPEED';

type
    TPeriodicCanData = class
    private
        mICMan: TIntervalCallerManager;
        mCAN: TBaseCAN;
        mCarType: TCAR_TYPE;

        procedure SetEnabled(Value: boolean);

    public
        constructor Create(CAN: TBaseCAN; CarType: TCAR_TYPE);
        destructor Destroy; override;

        procedure Init(CarType: TCAR_TYPE);

        procedure SetIgn(IsStart: Boolean);
        procedure SetSpeedZero(IsStart: Boolean);

        procedure Run;

        property Enabled: boolean write SetEnabled;

    end;

implementation

{ TPeriodicCanData }

constructor TPeriodicCanData.Create(CAN: TBaseCAN; CarType: TCAR_TYPE);
begin
    mCAN := CAN;
    mCarType := CarType;

    mICMan := TIntervalCallerManager.Create();

    mICMan.Add(IC_IGN_AND_P,
        procedure
        var
            CANFrame: TCANData;
        begin
            FillChar(CANFrame, SizeOf(CANFrame), 0);
            CANFrame[0] := $FF;
            CANFrame[1] := $FF;
            CANFrame[3] := $50;
            CANFrame[5] := $01;
            mCAN.Write($3D1, CANFrame, 32);
        end, 200);


    mICMan.Add(IC_SPEED,
        procedure
        var
            CANFrame: TCANData;
        begin
            FillChar(CANFrame, SizeOf(CANFrame), 0);
            CANFrame[0] := $FF;
            CANFrame[1] := $FF;
            mCAN.Write($1AA, CANFrame, 32);
        end, 200);

    mICMan.Add(IC_IGN3,
        procedure
        var
            CANFrame: TCANData;
        begin
            FillChar(CANFrame, SizeOf(CANFrame), 0);
            CANFrame[0] := $FF;
            CANFrame[1] := $FF;
            CANFrame[21] := $02;
            mCAN.Write($3E0, CANFrame, 32);

        end, 200);
end;

destructor TPeriodicCanData.Destroy;
begin
    FreeAndNil(mICMan);
end;

procedure TPeriodicCanData.Init(CarType: TCAR_TYPE);
begin
    mCarType := CarType;
end;

procedure TPeriodicCanData.Run;
begin
    mICMan.Run;
end;

procedure TPeriodicCanData.SetEnabled(Value: boolean);
begin
    mICMan.Enabled := Value;
end;

procedure TPeriodicCanData.SetIgn(IsStart: Boolean);
begin
    mICMan.Items[IC_IGN_AND_P].Enabled := IsStart;
    mICMan.Items[IC_IGN3].Enabled := IsStart;
end;

procedure TPeriodicCanData.SetSpeedZero(IsStart: Boolean);
begin
    mICMan.Items[IC_SPEED].Enabled := IsStart;
end;

end.

