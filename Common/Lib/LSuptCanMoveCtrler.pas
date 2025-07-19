unit LSuptCanMoveCtrler;

interface

uses
    Windows, Sysutils, Classes, KiiMessages, TimeChecker, SeatMotor,
    SeatMotorType, BaseCAN;

type
    TLSuptCANMoveCtrler = class(TBaseMoveCtrler)
    protected
        mCAN: TBaseCAN;
        mFrame: TCANFrame;
        mDrvInfSig, mDrvDefSig,
        mAstInfSig, mAstDefSig: TCANSignal;

        mIsDrv: Boolean;

        mRepeatTC: TTimeChecker;

        procedure CanRead(Sender: TObject);

    public
        constructor Create(CAN: TBaseCAN; DrvInfSig, DrvDefSig, AstInfSig, AstDefSig: TCANSignal);
        destructor Destroy; override;

        function MoveToForw(MtrID: TMotorOrd): Boolean; override;
        function MoveToBack(MtrID: TMotorOrd): Boolean; override;

        function StopForForw(MtrID: TMotorOrd): Boolean; override;
        function StopForBack(MtrID: TMotorOrd): Boolean; override;

        procedure SetDirSignal(DrvInfSig, DrvDefSig, AstInfSig, AstDefSig: TCANSignal);

        property IsDrv: Boolean read mIsDrv write mIsDrv;

    end;

implementation
uses
    Log;

{ TLSuptCANMoveCtrler }

procedure TLSuptCANMoveCtrler.CanRead(Sender: TObject);
begin
    if mIsMove and mRepeatTC.IsTimeout then
    begin
        mCAN.Write(mFrame);
        mRepeatTC.Start(500);
    end;
end;

constructor TLSuptCANMoveCtrler.Create(CAN: TBaseCAN; DrvInfSig, DrvDefSig, AstInfSig, AstDefSig: TCANSignal);
begin
    mCAN := CAN;
    mCAN.OnRead.Add(CanRead);

    SetDirSignal(DrvInfSig, DrvDefSig, AstInfSig, AstDefSig);

    mFrame := TCANFrame.Create(DrvInfSig.mID, 32);

    mRepeatTC.Start(200);
end;

destructor TLSuptCANMoveCtrler.Destroy;
begin
    mCAN.OnRead.Remove(CanRead);

    inherited;
end;


function TLSuptCANMoveCtrler.MoveToBack(MtrID: TMotorOrd): Boolean;
begin
    mFrame.Clear;

    if mIsDrv then
        mDrvDefSig.Write(mFrame, 2)
    else
        mAstDefSig.Write(mFrame, 2);

    Result := mCAN.Write(mFrame);

    if Result then
        mIsMove := True;
end;

function TLSuptCANMoveCtrler.MoveToForw(MtrID: TMotorOrd): Boolean;
begin
    mFrame.Clear;

    if mIsDrv then
        mDrvInfSig.Write(mFrame, 2)
    else
        mAstInfSig.Write(mFrame, 2);

    Result := mCAN.Write(mFrame);

    if Result then
        mIsMove := True;

end;


procedure TLSuptCANMoveCtrler.SetDirSignal(DrvInfSig, DrvDefSig, AstInfSig, AstDefSig: TCANSignal);
begin
    mDrvInfSig := DrvInfSig;
    mDrvDefSig := DrvDefSig;
    mAstInfSig := AstInfSig;
    mAstDefSig := AstDefSig;
end;

function TLSuptCANMoveCtrler.StopForBack(MtrID: TMotorOrd): Boolean;
begin
    if mIgnoreStop then
        Exit(True);


    mFrame.Clear;

    if mIsDrv then
        mDrvDefSig.Write(mFrame, 1)
    else
        mAstDefSig.Write(mFrame, 1);

    Result := mCAN.Write(mFrame);

    if Result then
        mIsMove := False;

end;

function TLSuptCANMoveCtrler.StopForForw(MtrID: TMotorOrd): Boolean;
begin
    if mIgnoreStop then
        Exit(True);

    mFrame.Clear;

    if mIsDrv then
        mDrvInfSig.Write(mFrame, 1)
    else
        mAstInfSig.Write(mFrame, 1);

    Result := mCAN.Write(mFrame);

    if Result then
        mIsMove := False;

end;


end.
