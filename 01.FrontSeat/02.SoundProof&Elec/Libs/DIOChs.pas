{
    Ver.240517.00
}
unit DIOChs;

interface
uses
    Sysutils, Classes, BaseDIO, SeatMotor, Log, SeatMotorType;


type
    TDIEvent = reference to procedure(Ch: Integer; OnOff: Boolean);


    // Lan DI Chs
    TLDIChs = packed record
    private
        mState: array [0 .. 31] of Boolean;
    public

        procedure Init(StartCh: Integer);
        procedure RunAsCh(Ch: Integer; DIO: TBaseDIO; DIEvent: TDIEvent);
        procedure Run(DIO: TBaseDIO; DIEvent: TDIEvent);

        case Integer of
            0:
            (
                mStart,             // 시작
                mWeightLodingOK,    // 웨이트 로딩 완료 , 검사 시작
                mWeightUnLodingOK,  //  버니싱 시작
                mDPosSensorReady,
                mDPosSensorReleased,
                mCh6,
                mVentSensor,
                mLegFwdSensor,
                mCh9,
                mCh10,
                mCh11,
                mCh12,
                mEmerStop,
                mAlarm,
                mAutoMode,
                mPopLinkMode,
                mCh15,
                mSlideFw,
                mSlideBw,
                mHeightUp,
                mHeightDn,
                mTiltUp,
                mTiltDn,
                mExtFw,
                mExtBw,
                mSwivelFw,
                mSwivelBw,
                mCh28,
                mCh29,
                mCh30,
                mCh31,
                mReset
                : Integer;
            );
            1:
            (
                mItems: array[0 .. 31] of Integer;
            );
    end;
    // Lan DO Chs
    TLDOChs = packed record

        procedure Init(StartCh: Integer);
        procedure Clear(DIO: TBaseDIO; ExceptChs: array of Integer);

        case Integer of
            0:
            (
                mTestReady,
                mWeightLodingReq,
                mWeightUnLodingReq,
                mReqDPosSensorReady,
                mReqDPosSensorRelease,
                mCh6,
                mCh7,
                mCh8,
                mCh9,
                mCh10,
                mCh11,
                mCh12,
                mAlarm,
                mOK,
                mNOK,
                mCh16,
                mCh17,
                mCh18,
                mCh19,
                mCh20,
                mCh21,
                mCh22,
                mCh23,
                mCh24,
                mCh25,
                mCh26,
                mCh27,
                mCh28,
                mCh29,
                mCh30,
                mCh31: Integer;

            );
            1:
            (
                mItems: array[0 .. 31] of Integer;
            );
    end;

    TDIOEventItem = packed record
        mCh:        Integer;
        mState:     Boolean;
        mEnabled:   Boolean;
    end;

    TDIChStatus = procedure (Ch: Integer; State: Boolean) of Object;

    TDIEventer = packed record
    private

        mItems:     array of TDIOEventItem;

        mIdx:       Integer;
        mOnStatus:  TDIChStatus;
    public
        constructor Create(Chs: array of Integer; IOChStatus: TDIChStatus);
        procedure   Init(Chs: array of Integer; IOChStatus: TDIChStatus);
        procedure   Run(DIO: TBaseDIO);
    end;



implementation


{ TLDIChs }

procedure TLDIChs.Init(StartCh: Integer);
var
    i: Integer;
begin
    for i := 0 to Length(mItems) - 1 do
        mItems[i] := StartCh + i;
end;

procedure TLDIChs.Run(DIO: TBaseDIO; DIEvent: TDIEvent);
var
    i: Integer;
begin
    for i := 0 to Length(mItems) - 1 do
    begin
        if mItems[i] >= 0 then
            RunAsCh(mItems[i], DIO, DIEvent);
    end;
end;

procedure TLDIChs.RunAsCh(Ch: Integer; DIO: TBaseDIO; DIEvent: TDIEvent);
begin
    if mState[Ch - mItems[0]] <> DIO.IsIO(Ch) then
    begin
        mState[Ch - mItems[0]] := DIO.IsIO(Ch);

        if mState[Ch - mItems[0]] then
            DIEvent(Ch, true)
        else
            DIEvent(Ch, false);
    end;
end;

{ TLDOChs }

procedure TLDOChs.Clear(DIO: TBaseDIO; ExceptChs: array of Integer);
var
    i, j: Integer;
    IsSkip: Boolean;
begin
    for i := 0 to Length(mItems) - 1 do
    begin
        IsSkip := false;
        for j := 0 to Length(ExceptChs) - 1 do
        begin
            if mItems[i] = ExceptChs[j] then
            begin
                IsSkip := true;
                Break;
            end;
        end;

        if not IsSkip then
            DIO.SetIo(mItems[i], false);
    end;
end;

procedure TLDOChs.Init(StartCh: Integer);
var
    i: Integer;
begin
    for i := 0 to Length(mItems) - 1 do
        mItems[i] := StartCh + i;

end;


{ TDIEventer }

constructor TDIEventer.Create(Chs: array of Integer; IOChStatus: TDIChStatus);
begin
    Init(Chs, IOChStatus);
end;

procedure TDIEventer.Init(Chs: array of Integer; IOChStatus: TDIChStatus);
var
    i: Integer;
begin
    if mItems <> nil then
        mItems := nil;

    SetLength(mItems, Length(Chs));

    for i := 0 to Length(mItems) - 1 do
    begin
        mItems[i].mCh := Chs[i];
        mItems[i].mEnabled := true;
    end;


    mOnStatus := IOChStatus;

    mIdx := 0;
end;

procedure TDIEventer.Run(DIO: TBaseDIO);
begin
    if Length(mItems) = 0 then
        Exit;

    with mItems[mIdx] do
    begin
        if mEnabled then
        begin
            if mState <> DIO.IsIO(mCh) then
            begin
                mState := DIO.IsIO(mCh);
                mOnStatus(mCh, mState);
            end;
        end;
    end;

    Inc(mIdx);
    mIdx := mIdx mod Length(mItems);
end;

end.
