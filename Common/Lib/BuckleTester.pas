unit BuckleTester;

interface

uses
    Classes, BaseFSM, TimeChecker, BaseDIO, BaseAD, Range, SeatType;

type

    TBuckleTester = class(TBaseFSM)
    private
        mType: TBuckleTestType;
        mDIO: TBaseDIO;
        mAD: TBaseAD;
        mIOCh,
        mCurrCh: integer;

        mSpec: TRange;
        mChkSec: double;

        mTC: TTimeChecker;

        mVal: double;

        mIsOK: boolean;
        mIOReadFromVolt: boolean;

        function GetVal: double;
        function GetCurr: double;
        function IsVoltHigh(Channel: Integer): boolean;

    public
        constructor Create(DIO: TBaseDIO; AD: TBaseAD; IOCh, CurrCh: integer);
        destructor Destory; virtual;

        procedure Init(BuckType: TBuckleTestType; Spec: TRange; ChkSec: double; CurrCh: integer; IOReadFromVolt: boolean);
        function FSMIRun: integer; override;

        function IsCurrType: boolean;


        property IsOK: boolean read mIsOK;
        property Val: double read mVal;
        property TestType: TBuckleTestType read mType write mType;
        property Curr: Double read GetCurr;

    end;

implementation
uses
    Log;


{ TBuckleTester }

constructor TBuckleTester.Create(DIO: TBaseDIO; AD: TBaseAD; IOCh, CurrCh: integer);
begin
    mName := 'BuckleTetser';

    mAD := AD;
    mDIO := DIO;

    mIOCh := IOCh;
    mCurrCh := CurrCh;
end;

destructor TBuckleTester.Destory;
begin

  inherited;
end;

procedure TBuckleTester.Init(BuckType: TBuckleTestType; Spec: TRange; ChkSec: double; CurrCh: integer; IOReadFromVolt: boolean);
begin
    mVal := 0.0;
    mType := BuckType;
    mSpec := Spec;
    mChkSec := ChkSec;
    mCurrCh := CurrCh;
    mIOReadFromVolt := IOReadFromVolt;
end;

function TBuckleTester.IsCurrType: boolean;
begin
    Result :=  (mType = btIOCurr);
end;

function TBuckleTester.FSMIRun: integer;
var
    IsIOOK: boolean;
begin
    case mState of
        0:
        begin

        end;
        1:
        begin
            mIsOK := false;
            case mType of
                btIO:
                begin
                    gLog.Panel('접점 타입 버클');
                    mState := 2;
                end;
                btCurr:
                begin
                    gLog.Panel('전류 타입 버클');
                    mState := 3;
                end;
                btIOCurr:
                begin
                    gLog.Panel('접점/전류 타입 버클');
                    mState := 2;
                end;
            end;
            mTC.Start(mChkSec * 1000);
        end;

        2:
        begin
            if mIOReadFromVolt = true then
            begin
                IsIOOK := IsVoltHigh(mIOCh);
            end
            else
            begin
                IsIOOK := mDIO.IsIO(mIOCh);
            end;

            if IsIOOK then
            begin
                if mType = btIOCurr then
                begin
                    mState := 3;
                end
                else
                begin
                    mIsOK := true;
                    FSMStop;
                    Exit(1);
                end;
            end;

            if mTC.IsTimeOut then
            begin
                FSMStop;
                Exit(1);
            end;
        end;

        3:
        begin
            mVal := GetVal;
            //gLog.Debug('버클 CH%d: %f', [mADCh,  mVal]);

            if mSpec.IsIn(mVal) then
            begin
                gLog.Panel('버클 %s:  %f(V)', [mName, mVal]);
                mIsOK := true;
                FSMStop;
                Exit(1);
            end;

            if mTC.IsTimeOut then
            begin
                gLog.Error('버클 %s: %f(V) Timeout', [mName, mVal]);
                mIsOK := false;
                FSMStop;
                Exit(1);
            end;
        end;

    end;

    Result := 0;
end;

function TBuckleTester.IsVoltHigh(Channel:Integer): boolean;
begin
    Result := mAD.GetVolt(Channel) >= 10.0;
end;



function TBuckleTester.GetCurr: double;
begin
    Result := mAD.GetVolt(mCurrCh) / 250;
end;

function TBuckleTester.GetVal: double;
begin
    Result := mAD.GetValue(mCurrCh);
end;

end.
