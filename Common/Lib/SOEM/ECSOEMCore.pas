unit ECSOEMCore;

interface

uses
    EtherCatUnit, SOEMLIB, SOEMFunctions, SOEMParams, Windows, TimeChecker,
    SysUtils, TSQueue, SyncObjs;

type
    TECSOEMCore = class(TBaseECCore)
    private
        mSlave: Integer;
        mLostSlave: Integer;
        mHandle: Pointer;
        mIsSlaveLost: Boolean;
        mIsLostFound: Boolean;
        mIsSuccessTransfer: Boolean;
        mIsWrite: Boolean;
        mCheckCnt: Integer;
        mShutDownTC: TTimeChecker;
        mECATCheckTC: TTimeChecker;
        mReadBackTC: TTimeChecker;
        mSlaveInfo: pec_slave;
        mIsLogingWriteError: Boolean;

        mCriticalSection: TCriticalSection;

        mTC: TTimeChecker;

    protected
        function IsValid(Status: Cardinal = 0): boolean; override;

        function GetErrStr: string; override;

        function Open: boolean; override;
        function Close: boolean; override;
        function IsOpen: boolean; override;
        function Reopen(CloseAndOpen: boolean = false): boolean; override;

        function Reads(ThreadState: PByte): integer; override;
        function ReadBack(Index: integer; const WBuffer: Pointer; Len: integer): boolean; override;
        function Write(Index: integer; WData: byte): boolean; override;
        function Writes(Index: integer; const WBuffer: Pointer; Len: integer): boolean; override;
        function Recovery(var ECStatus: TECStatus): boolean; override;
        function IsLostSlave: boolean;
        function IsOutput0Byte(Offset: Integer): boolean;

        procedure SetIntervalCaller;

    public
        procedure Transfer;
        constructor Create;
        destructor Destroy; override;
    end;

implementation

uses
    Log, IntervalCaller, AsyncCalls;

const
    ORIGIN_SLAVE = 1;

{ TECSOEMCore }

function TECSOEMCore.Close: boolean;
begin
    if not IsOpen then
        Exit(False);

    gICMan.Enabled := False;

    SOEM_close(mHandle);

    Sleep(100);

    if mHandle = nil then
    begin
        if Assigned(gLog) then
            gLog.Panel('Ethercat: Close Driver!');
    end;

end;

constructor TECSOEMCore.Create;
begin
    inherited Create;
    mCriticalSection := TCriticalSection.Create;
    mTag := TAG_SOEM;
    mSlave := 1;

    mIsLostFound := False;
    mIsSlaveLost := False;
end;

destructor TECSOEMCore.Destroy;
begin
    if Assigned(mCriticalSection) then
        mCriticalSection.Free;

    inherited Destroy;
end;

function TECSOEMCore.Recovery(var ECStatus: TECStatus): boolean;
var
    Status: Integer;
    SlaveCount: Integer;
begin
    Result := False;

    if not mECATCheckTC.IsTimeOut() then
    begin
        Result := True;
        Exit;
    end;

    mECATCheckTC.Start(50);

    Status := SOEM_Recovery(mLostSlave);

    case Status of
        ord(ECS_NONE):
            begin
                if mShutDownTC.IsTimeOut and mIsLostFound then
                begin
                    Inc(mCheckCnt);
                    mShutDownTC.Start(400);

                    if mCheckCnt = TRY_SHUT_DOWN_RECOVER then
                    begin
                        ECStatus := ecsStart;
                        gLog.Panel('Ethercat: Slave %d ���� �������� ��ȯ', [mLostSlave]);
                        if Reopen(True) then
                        begin
                            ECStatus := ecsRun;
                            mCheckCnt := 0;
                            mLostSlave := 0;
                            Exit(True);
                        end;
                    end;
                end;
            end;
        ord(ECS_SAFEOP_ERROR_ATTEMPT_ACK):
            begin
                gLog.Panel('Ethercat: Slave %d SAFE OP + Error ����, Error Clear �õ���..', [mLostSlave]);
                ECStatus := ecsErrRetry;
            end;
        ord(ECS_SAFEOP_CHANGE_OPERATIONAL):
            begin
                gLog.Panel('Ethercat: Slave %d SAFE OP ����.. OPERATIONAL ���·� ����', [mLostSlave]);
                SlaveCount := SOEM_getSlaveCount;
                if mLostSlave < SlaveCount then
                    Inc(mLostSlave)
                else if mLostSlave = SlaveCount then
                    mLostSlave := ORIGIN_SLAVE;
            end;
        ord(ECS_SLAVE_RECONFIGED):
            gLog.Panel('Ethercat: Slave %d RECONFIG �õ�', [mLostSlave]);
        ord(ECS_SLAVE_RECOVERED):
            gLog.Panel('Ethercat: Slave %d RECOVER �õ�', [mLostSlave]);
        ord(ECS_SLAVE_FOUND):
            begin
                gLog.Panel('Ethercat: Slave %d Found. Start Recovery', [mLostSlave]);

                mIsLostFound := True;

                if mLostSlave <> ORIGIN_SLAVE then
                begin
                    ECStatus := ecsRun;
                    gLog.Panel('Ethercat: Slave %d OK', [mLostSlave]);
                    mLostSlave := 0;
                    Exit(True);
                end;
            end;
        ord(ECS_SLAVE_OK):
            begin
                mIsLostFound := False;
                mIsSlaveLost := False;
                ECStatus := ecsRun;
                mLostSlave := 0;
                Exit(True);
            end;
    end;

end;

function TECSOEMCore.GetErrStr: string;

    function AnsiArrayCharToString(const a: array of AnsiChar): Ansistring;
    var
        i: Integer;
    begin
        for i := Low(a) to High(a) do
            if (a[i] >= ' ') and (a[i] <= 'z') then
                Result := Result + a[i];
    end;

var
    ErrStr: array[0..255] of AnsiChar;
begin
    SOEM_getALStatusDesc(mSlave, @ErrStr);

    Result := AnsiArrayCharToString(ErrStr);
end;

function TECSOEMCore.IsLostSlave: boolean;
var
    i: Integer;
begin
    Result := False;
    if mLostSlave > 0 then
        Exit(True);

    mLostSlave := SOEM_lostCheck();

    if mLostSlave > 0 then
        Result := True;

    if Result then
    begin
        gLog.Error('Ethercat: Slave %d Lost', [mLostSlave]);
        mIsLostFound := False;
    end;

end;

function TECSOEMCore.IsOpen: boolean;
begin
    Result := False;
    if mHandle <> nil then
        Result := True;
end;

function TECSOEMCore.IsValid(Status: Cardinal): boolean;
var
    ALStatus: Word;
begin
    ALStatus := Word(SOEM_getALStatusCode(mSlave));

    if not (ALStatus in [AL_NO_ERROR, AL_WATCHDOG_ERROR]) then
    begin
        if Assigned(gLog) then
            gLog.Error('Ethercat: AL Error : Code: %d, Desc: %s', [ALStatus, GetErrStr]);

        Exit(False);
    end;

    Result := True;
end;

function BCErrorToStr(ErrorState: Word): string;
begin
    case ErrorState of
        $0002:
            Result := '���� ��Ʈ�ѷ��� �÷��� �޸� �б�/���� ����.';
        $0004:
            Result := '�۵� �߿� ������ �ְų� ������ I/O ����� �����Ǿ����ϴ�';
        $0008:
            Result := '���� �ܰ迡�� ������ I/O ����� �����Ǿ����ϴ�.';
        $0010:
            Result := '���� �ܰ迡�� �߸��� I/O ����� �����Ǿ����ϴ�.';
        $0020:
            Result := '���� ��Ʈ�ѷ��� ���� �����Ͱ� �߸��Ǿ����ϴ�. �ٽ� �ٿ�ε� �ϼ���.';
        $0040:
            Result := 'ESI ������ ������ ������ ������ϴ�.';
        $0080:
            Result := '�� �̻� ���� ��Ʈ�ѷ� ���� ���ҽ��� ��� �� �� �����ϴ�. �޸𸮸� Ȯ���ϰų� ���� ������ �缳���ϼ���.';
        $0100:
            Result := '�߿�� ������ �߻��߽��ϴ�.';
        $0200:
            Result := '�̴�Ĺ EEPROM �б�/���� ����';
        $0400:
            Result := '�������� �ʴ� I/O ����� ����Ǿ����ϴ�.';
    else
        Result := '�˼� ���� �����Դϴ�';
    end;
end;

function TECSOEMCore.Open: boolean;
var
    BCState: DWord;
    BCError: Word;
begin
    Result := False;
    if SOEM_open(mHandle) > 0 then
    begin
        if Assigned(gLog) then
            gLog.Panel('Ethercat: Open OK!');

        gLog.Panel('Ethercat: Check BusController Error State... OK!');

        SDORead(mSlave, $F100, 0, BCState);
        BCError := Word(BCState shr 16);

        if BCError <> BC_NO_ERROR then
        begin
            if Assigned(gLog) then
                gLog.Error('Ethercat: BC Error : %s', [BCErrorToStr(BCError)]);

            Close();

            Exit(False);
        end;

        SetIntervalCaller();
        gICMan.Enabled := True;

        mSlaveInfo := SOEM_getSlave(mSlave);
        mIsLogingWriteError := False;
        Exit(True);
    end
    else
        gLog.Panel('Ethercat: Open Failed');
end;

function TECSOEMCore.ReadBack(Index: integer; const WBuffer: Pointer; Len: integer): boolean;
begin
    Result := False;

    if not IsOpen then
        Exit;

    if not mReadBackTC.IsTimeOut() then
        Exit;

    if IsValid then
    begin
        Transfer();

        if not mIsSuccessTransfer then
            Exit;

        SOEM_getInputBufferPDO(mSlave, Index, @WBuffer, Len);
        mReadBackTC.Start(500);
        Result := True;
    end
    else
    begin
        if Assigned(gLog) then
            gLog.Panel('Ethercat: ReadBack Fail');
    end;

end;

function TECSOEMCore.Reads(ThreadState: PByte): integer;
var
    i, j, TarIdx: Integer;
begin
    if not IsOpen then
        Exit;

    if Assigned(gICMan) then
        gICMan.Run();

    if mIsSlaveLost then
        Exit(-1);

    Result := 0;
    TarIdx := 0;

    for j := 0 to mECRRangeCount - 1 do
    begin
        if IsValid then
        begin
            if not mIsWrite then
            begin
                Transfer();

                if not mIsSuccessTransfer then
                    Exit;

                SOEM_getInputBufferPDO(mSlave, mECRRanges[j].Offset, @mRInrBuffer[0], mECRRanges[j].Len);

                CopyMemory(@mRBuffer[TarIdx], @mRInrBuffer[0], mECRRanges[j].Len);

                TarIdx := TarIdx + mECRRanges[j].Len;
            end;

            for i := 0 to mItems.Count - 1 do
            begin
                if ThreadState^ = 0 then
                    break;

                mItems[i].Reads;
            end;

            for i := 0 to Length(mMOKOffsets) - 1 do
            begin
                if mRBuffer[mMOKOffsets[i]] = 0 then
                begin
                    gLog.Error('Ethercat: ModuleOK(%d) Error', [mMOKOffsets[i]]);
                    mErrModuleOffset := mMOKOffsets[i];
                    Exit(-1);
                end;
            end;
            mECATCheckTC.Start(50);
        end
        else
            Exit(-1);
    end;

    Result := 1;
end;

function TECSOEMCore.Reopen(CloseAndOpen: boolean): boolean;
begin
    Result := False;

    if CloseAndOpen and (mHandle <> nil) then
        Close;

    if mHandle = nil then
        if Open then
            Result := True;
end;

procedure TECSOEMCore.SetIntervalCaller;
begin
    gICMan.Add('SOEMTranfer',
        procedure
        begin
            if mIsWrite then
                Transfer();
        end, 1).Name := 'SOEMTranfer';

    gICMan.Add('SOEMLostChk',
        procedure
        begin
            if IsLostSlave() then
                mIsSlaveLost := True;
        end, 100).Name := 'SOEMLostChk';
end;

procedure TECSOEMCore.Transfer;
begin
    mCriticalSection.Enter;
    try
        mIsSuccessTransfer := Boolean(SOEM_transferPDO());
    finally
        mCriticalSection.Leave;
    end;
end;

function TECSOEMCore.IsOutput0Byte(Offset: Integer): boolean;
begin
    Result := False;

    if mSlaveInfo.outputs = nil then
    begin
        if not mIsLogingWriteError then
        begin
            gLog.Panel('EtherCAT: Output�� �Ҵ�� Byte�� ���̰� 0 �Դϴ�.');
            gLog.Panel('EtherCAT: XML ������ ����� �Ǿ��ִ��� Ȯ���� �ּ���.');
            mIsLogingWriteError := True;
        end;
        Exit(True);
    end;
end;

function TECSOEMCore.Write(Index: integer; WData: byte): boolean;
begin
    Result := False;

    if not IsOpen then
        Exit;

    if IsOutput0Byte(Index) then
        Exit;

    if IsValid then
    begin
        mIsWrite := True;

        SOEM_setOutPutAsBufferPDO(mSlave, Index, @WData, SizeOf(WData));

        mIsWrite := False;
        Exit(True);
    end;

end;

function TECSOEMCore.Writes(Index: integer; const WBuffer: Pointer; Len: integer): boolean;
begin
    Result := False;

    if not IsOpen then
        Exit;

    if IsOutput0Byte(Index) then
        Exit;

    if IsValid then
    begin
        mIsWrite := True;
        SOEM_setOutPutAsBufferPDO(mSlave, Index, WBuffer, Len);
        mIsWrite := False;
        Exit(True);
    end;

end;

end.

