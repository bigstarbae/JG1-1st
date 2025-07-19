unit HVSimulCtrler;

interface

uses
    HVTester, TimeChecker;

const
    gUpXVals: array [0 .. 65] of double = (0.00, 6.66, 13.33, 20.00, 26.68, 33.37, 40.06, 46.77, 53.50, 60.24, 67.00, 67.00, 73.15, 78.21, 82.41, 85.95, 89.07, 91.98, 94.91, 98.07, 101.70, 106.00,
        106.00, 110.50, 114.64, 118.50, 122.17, 125.73, 129.27, 132.88, 136.65, 140.66, 145.00, 145.00, 149.29, 153.18, 156.78, 160.21, 163.59, 167.05, 170.70, 174.66, 179.06, 184.00, 184.00, 189.15,
        194.11, 198.94, 203.67, 208.37, 213.08, 217.85, 222.72, 227.76, 233.00, 233.00, 238.00, 242.38, 246.35, 250.08, 253.77, 257.59, 261.74, 266.40, 271.76, 278.00);
    gUpYVals: array [0 .. 65] of double = (0.00, 5.32, 10.68, 16.12, 21.68, 27.42, 33.35, 39.54, 46.02, 52.82, 60.00, 60.00, 67.08, 73.68, 79.96, 86.09, 92.24, 98.56, 105.24, 112.42, 120.29, 129.00,
        129.00, 137.97, 146.57, 154.89, 163.02, 171.05, 179.08, 187.20, 195.50, 204.07, 213.00, 213.00, 221.48, 228.74, 234.92, 240.18, 244.67, 248.55, 251.97, 255.08, 258.04, 261.00, 261.00, 263.21,
        263.98, 263.56, 262.17, 260.06, 257.46, 254.62, 251.77, 249.15, 247.00, 247.00, 245.21, 243.47, 241.75, 239.99, 238.14, 236.16, 234.01, 231.63, 228.97, 226.00);

    gDnXVals: array [0 .. 54] of double = (0.00, 6.73, 13.47, 20.23, 27.02, 33.85, 40.74, 47.68, 54.70, 61.80, 69.00, 69.00, 75.66, 81.26, 86.00, 90.07, 93.66, 96.95, 100.14, 103.42, 106.98, 111.00,
        111.00, 114.95, 118.24, 121.03, 123.44, 125.62, 127.72, 129.86, 132.19, 134.86, 138.00, 138.00, 141.31, 144.45, 147.50, 150.53, 153.64, 156.89, 160.37, 164.17, 168.35, 173.00, 173.00, 177.86,
        182.70, 187.63, 192.76, 198.20, 204.07, 210.47, 217.52, 225.32, 234.00);
    gDnYVals: array [0 .. 54] of double = (274.00, 271.58, 269.13, 266.63, 264.03, 261.32, 258.47, 255.44, 252.20, 248.73, 245.00, 245.00, 241.21, 237.53, 233.87, 230.15, 226.29, 222.21, 217.83,
        213.05, 207.80, 202.00, 202.00, 195.94, 189.91, 183.79, 177.46, 170.83, 163.76, 156.16, 147.91, 138.89, 129.00, 129.00, 118.75, 108.72, 98.91, 89.32, 79.95, 70.77, 61.79, 53.01, 44.41, 36.00,
        36.00, 28.73, 23.33, 19.39, 16.52, 14.34, 12.46, 10.47, 7.99, 4.63, 0.00);

type
    THVSimulCtrler = class(TBaseHVCtrler)
    private
        mPreStep: integer;


        mUpXSecs, mUpYSecs, mDnXSecs, mDnYSecs: array of double;
        mUpSec, mDnSec: double;
        mMaxCurr,
        mLastCurr,
        mCurCurr: double;

        mUpStartSec,
        mDnStartSec: double;

        mState: integer;

        procedure Scale4Dn(MaxCurr: double);
        procedure Scale4Up;

        function GetCurrBySec(Sec: double): double;

    public
        mTC: TTimeChecker;
        mIsSwOn: boolean;


        constructor Create(MaxCurr: double = 5; UpSec: double = 3; DnSec: double = 1);
        destructor Destroy; override;

        procedure Init(MaxCurr, UpSec, DnSec: double);


        // Base
        function SwOn(CurStep: integer): boolean; override;
        function SwOff(CurStep: integer): boolean; override;
        function GetLedData: BYTE; override;
        function GetCurr: double; override;
        function GetDOSwVal: boolean; override;


    end;

implementation

uses
    Log;

{ THVSimulCtrler }

constructor THVSimulCtrler.Create(MaxCurr: double; UpSec: double; DnSec: double);
begin
    mPreStep := -1;
    Init(MaxCurr, UpSec, DnSec);
end;

destructor THVSimulCtrler.Destroy;
begin
    mUpXSecs  := nil;
    mUpYSecs  := nil;
    mDnXSecs  := nil;
    mDnYSecs  := nil;

    inherited;
end;


procedure THVSimulCtrler.Init(MaxCurr, UpSec, DnSec: double);
begin
    mMaxCurr := MaxCurr;
    mUpSec := UpSec;
    mDnSec := DnSec;

    Scale4Up();

end;

function GetMaxVal(Datas: array of double): double;
var
    i: integer;
    Max: double;
begin
    Max := -9999;
    for i := 0 to High(Datas) do
    begin
        if Max < Datas[i] then
            Max := Datas[i];
    end;

    Result := Max;
end;


function THVSimulCtrler.GetCurrBySec(Sec: double): double;
var
    i: integer;
    Ratio: double;

begin
    Result := 0;
    case mState of
        0:
        begin
            mCurCurr :=  random(1) / 100.0;
            Result := mCurCurr;
        end;
        1:
        begin
            Sec := Sec - mUpStartSec;
            if Sec < mUpSec then // 상승
            begin
                for i := 0 to High(mUpXSecs) do
                begin
                    if Sec < mUpXSecs[i] then
                    begin
                        Ratio := (mUpYSecs[i] - mUpYSecs[i - 1]) / (mUpXSecs[i] - mUpXSecs[i - 1]) ;
                        if Ratio <> 0 then
                        begin
                            mCurCurr := mUpYSecs[i - 1] + (Sec - mUpXSecs[i - 1]) * Ratio;
                        end;
        //                gLog.Panel('sec=%0.2f, ratio=%0.2f -> %0.2f', [Sec, Ratio, mCurCurr]);
                        Exit(mCurCurr);
                    end
                    else if Sec = mUpXSecs[i] then
                    begin
                        mCurCurr := mUpYSecs[i];
                        Exit(mCurCurr);
                    end;
                end;
            end
            else
            begin
                mLastCurr := mCurCurr;
                Result := mCurCurr;
                mState := 2;
            end;
        end;
        2:
        begin
            mCurCurr := mLastCurr + random(4) / 10.0;
            Result := mCurCurr;
        end;
        3:
        begin
            Sec := Sec - mDnStartSec;
            for i := 0 to High(mDnXSecs) do
            begin
                if Sec < mDnXSecs[i] then
                begin
                    Ratio :=  (mDnYSecs[i] - mDnYSecs[i - 1]) / (mDnXSecs[i] - mDnXSecs[i - 1]);
                    mCurCurr := mDnYSecs[i - 1] + (Sec - mDnXSecs[i - 1]) * Ratio;
                    Exit(mCurCurr);
                end
                else if Sec = mDnXSecs[i] then
                begin
                    mCurCurr := mDnYSecs[i];
                    Exit(mCurCurr);
                end;
            end;

        end;

    end;

end;

function THVSimulCtrler.GetCurr: double;
begin

    {
    case mHVTest.CurStep of
        0:
            Result := 0 + random(1) / 100.0;
        1:
            Result := 8 + random(1) / 100.0;
        2:
            Result := 8 + random(1) / 100.0;
        3:
            Result := 8 + random(1) / 100.0;
    else
        Result := 0 + random(1) / 100.0;
    end;
    }

    Result := GetCurrBySec(mTC.GetPassTimeAsSec);
end;

function THVSimulCtrler.GetLedData: BYTE;
begin

    case mHVTest.CurStep of // TO DO : 일단 RevTest만 구현   H.Coding
        0:
            Result := 0;
        1:
            Result := 1;
        2:
            Result := 3;
        3:
            Result := 7;
    else
        Result := 0;
    end;
    {
    if mPreStep <> mHVTest.CurStep then
    begin
        mPreStep := mHVTest.CurStep;
        case mHVTest.CurStep of // TO DO : 일단 RevTest만 구현   H.Coding
            0:
                Result := 0;
            1:
                Result := 1;
            2:
                Result := 3;
            3:
                Result := 7;
        else
            Result := 0;
        end;
    end
    else
        Result := 0;
    }
end;

procedure THVSimulCtrler.Scale4Up();
var
    XRatio, YRatio: double;
    i, Count: integer;
begin
    Count := High(gUpXVals);

    SetLength(mUpXSecs, Count + 1);
    SetLength(mUpYSecs, Count + 1);

    XRatio := mUpSec / gUpXVals[Count]  ;
    YRatio := mMaxCurr / GetMaxVal(gUpYVals);

    for i := 0 to Count do
    begin
        mUpXSecs[i] := gUpXVals[i] * XRatio;
        mUpYSecs[i] := gUpYVals[i] * YRatio;
    end;

end;



procedure THVSimulCtrler.Scale4Dn(MaxCurr: double);
var
    XRatio, YRatio: double;
    i, Count: integer;
begin
    Count := High(gDnXVals);

    SetLength(mDnXSecs, Count + 1);
    SetLength(mDnYSecs, Count + 1);

    XRatio := mDnSec/ gDnXVals[Count];
    YRatio := MaxCurr / GetMaxVal(gDnYVals);

    for i := 0 to Count do
    begin
        mDnXSecs[i] := gDnXVals[i] * XRatio;
        mDnYSecs[i] := gDnYVals[i] * YRatio;
    end;

end;



function THVSimulCtrler.SwOn(CurStep: integer): boolean;
begin

    mIsSwOn := true;
    //gLog.Panel('%s: %d단 SW ON', [mHVTest.Name, mHVTest.CurStep]);

    if mHVTest.IsStart then
    begin
        mState := 0;
        mTC.Start;
    end;


    Result := true;
end;

function THVSimulCtrler.SwOff(CurStep: integer): boolean;
begin
    mIsSwOn := false;

    if mHVTest.CurStep = 3 then
    begin
        mUpStartSec := mTC.GetPassTimeAsSec;
        mState := 1;
    end;

    if mHVTest.IsEnd then
    begin
        mDnStartSec := mTC.GetPassTimeAsSec;
        Scale4Dn(mCurCurr);
        mState := 3;
    end;

    //gLog.Panel('%s: %d단 SW OFF', [mHVTest.Name, mHVTest.CurStep]);
    Result := true;

end;


function THVSimulCtrler.GetDOSwVal: boolean;
begin
    Result := mIsSwOn;
end;


end.
