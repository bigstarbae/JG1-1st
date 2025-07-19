unit HVBlowerTest;

interface

uses
    HVTester, BaseDIO, BaseAD, Range;

Type

    THVBlowerTest = class(THVBaseBlowerTest)
    protected
        mAD: TBaseAD;
        mDIO: TBaseDIO;

        mDOSWCh, mDOCOMCh,
        mDIRpmCh,
        mTotRpmCnt, mDINtcCheck,
        mCurrCh: integer;

        mCurRPMCnt : integer;
        mOldRPMState: boolean;



        procedure CheckRPM;

    public
        constructor Create(DIO: TBaseDIO; AD: TBaseAD; DOSWCh, CurrCh : integer;  PosType: THVPosType; AutoFree: boolean = true); overload;
        constructor Create(DIO: TBaseDIO; AD: TBaseAD; DOSWCh, DOCOMCh, CurrCh : integer;  PosType: THVPosType; AutoFree: boolean = true); overload;

        function GetCurr: double; override;

        procedure InitRpmCheck(DIRpmCh, DINtcCheck: integer; TotRpmCnt : integer = 3); override;

        procedure Run(IsRun: boolean); override;
        function  FSMIRun: integer; override;
        procedure ClearIO;  override;

    end;


implementation
uses
    Log;

{ TBlowerTest }

constructor THVBlowerTest.Create(DIO: TBaseDIO; AD: TBaseAD; DOSWCh, CurrCh: integer;  PosType: THVPosType; AutoFree: boolean);
begin
    mDIO := DIO;
    mAD := AD;
    mTestType := hvtVent;
    mPosType := PosType;
    mAutoFree := AutoFree;
    mDOSWCh := DOSWCh;
    mDOCOMCh := -1;
    mCurrCh := CurrCh;
end;

constructor THVBlowerTest.Create(DIO: TBaseDIO; AD: TBaseAD; DOSWCh, DOCOMCh, CurrCh: integer;  PosType: THVPosType; AutoFree: boolean);
begin
    mDIO := DIO;
    mAD := AD;
    mTestType := hvtVent;
    mPosType := PosType;
    mAutoFree := AutoFree;
    mDOSWCh := DOSWCh;
    mDOCOMCh := DOCOMCh;
    mCurrCh := CurrCh;
end;

procedure THVBlowerTest.ClearIO;
begin
    mDIO.SetIo(mDOSWCh, false);
    mDIO.SetIo(mDOCOMCh, false);
end;


function THVBlowerTest.FSMIRun: integer;
begin
    case mState of
        0:
            ;
        1:
        begin
            if not mUse then
                Exit(1);

            if Assigned(mOnStatus) then
            begin
                mOnStatus(Self, hvsTestStart);
            end;

            mMaxCurr := -999;
            mCurRPMCnt := 0;

            if mDOCOMCh >= 0 then
                mDIO.SetIO(mDOCOMCh, True);

            mDIO.SetIO(mDOSWCh, True);
            mTC.Start(mOnSec * 1000);
            IncState;
        end;
        2:
        begin
            if mUseRpmCheck then
                CheckRPM;

            if Assigned(mOnReading) then
                mOnReading(self);


            if mMaxCurr < GetCurr then
                mMaxCurr := GetCurr;

            if mTC.IsTimeOut then
            begin
                mRPMDec := mDIO.IsIO(mDINtcCheck) and (mCurRPMCnt > mTotRpmCnt);

                if Assigned(mOnStatus) then
                begin
                    mOnStatus(Self, hvsTestEnd);
                end;
                if mDOCOMCh >= 0 then
                    mDIO.SetIO(mDOCOMCh, False);
                    mDIO.SetIO(mDOSWCh, False);
                FSMStop;
                Exit(1);
            end;

        end;
    end;
    Result := 0;
end;


function THVBlowerTest.GetCurr: double;
begin
    Result := mAD.GetValue(mCurrCh);
end;

procedure THVBlowerTest.InitRpmCheck(DIRpmCh, DINtcCheck: integer; TotRpmCnt: integer);
begin
    mTotRpmCnt := TotRpmCnt;
    mDIRpmCh := DIRpmCh;
    mDINtcCheck := DINtcCheck;
end;


procedure THVBlowerTest.Run(IsRun: boolean);
begin
    mDIO.SetIO(mDOSWCh, IsRun);
end;

procedure THVBlowerTest.CheckRPM();
begin
    if mDIO.IsIO(mDIRpmCh) <> mOldRPMState then
    begin
        Inc(mCurRPMCnt);
        mOldRPMState := mDIO.IsIO(mDIRpmCh);
        gLog.Panel('Ä«¿îÆ® È½¼ö : %d', [mCurRPMCnt]);
    end;
end;



end.
