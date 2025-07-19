{
   ■ CAN IMS(NEW UDS:3세대)위주 클래스만 선언

   ■ 1열 특화!!

}
unit SeatIMSCtrler;
{$I mydefine.inc}

interface

uses
    Windows, SeatMotorType, BaseCAN, BaseDIO, SeatMotor;


type
    PRCID = ^TRCID;

    TRCID = packed record
        constructor Create(Hi, Lo: byte); overload;
        constructor Create(AVal: DWORD); overload;

        class operator Implicit(AVal: DWORD): TRCID;
        case Integer of
            0:
                (mLo: byte;
                mHi: byte;);
            1:
                (Val: DWORD;);
    end;

    TCANIMSCtrler = class;

    IIMSCtrlerBuilder = interface
        ['{E50C281A-A525-45AD-BFE9-B4C8A37CFE3B}']
        function Build: TCANIMSCtrler;
    end;
    {
      ex: 빌더 패턴으로 생성시 :
      Ctrler := TCANIMSCtrlerBuilder.Create(mCAN, _UDS_MSG_TAGET_PSM_ID_DRV, _UDS_MSG_RESP_PSM_ID_DRV).
          WithDIO(DIO).
          WithRDBIID(_UDS_RDBI_DID).
          WithRCID(_UDS_RC_DID).
          Build();
    }

    TIMSCtrlerBuilder = class(TInterfacedObject, IIMSCtrlerBuilder)   // 인터페이스 상속으로 Free 필요성 제거 but 유레카로그에서 메모리 누수!!
    private
        class var
            mBuilder: IIMSCtrlerBuilder;         // 생성자에서 자신을(self)대입하여 자동 삭제하게끔 편법 .. static으로 해도 괜찮긴 함.
    protected
        mCAN: TBaseCAN;
        mDIO: TBaseDIO;
        mDOIgnCh: integer;
        mReqID, mPSMRespID: cardinal;  // UDS Can ID
        mRCID: TRCID;                  // Routine Ctrl ID: Limit
        mRDBIID: byte;                   // Body Ctrl(RDBI): Pos, EasyAccess

        mRCType, mRCOpt: byte; // Routine Ctrl용 ex) Limit관련시:  RCType(1, 2, 3)또는 RCType(1) + RCOpt조합으로 사용됨
    public
        constructor Create; overload;
        constructor Create(CAN: TBaseCAN; PSMID, PSMRespID: cardinal); overload;

        function WithDIO(DIO: TBaseDIO; DOIgnCh: integer = -1): TIMSCtrlerBuilder;
        function WithCAN(CAN: TBaseCAN): TIMSCtrlerBuilder;
        function WithPsmID(PSMID, PSMRespID: cardinal): TIMSCtrlerBuilder;
        function WithRCID(RCID: TRCID): TIMSCtrlerBuilder;
        function WithRDBIID(RDBIID: byte): TIMSCtrlerBuilder;

        function Build: TCANIMSCtrler; //virtual;
    end;

    TRCOpt = (
        rcoAllLimit, rcoAllLimitClear,
        rcoReclLimit, rcoReclLimitClear,
        rcoSlideLimit, rcoSlideLimitClear,
        rcoTiltLimit, rcoTiltLimitClear,
        rcoHeightLimit, rcoHeightLimitClear,
        rcoRelaxLimit, rcoRelaxLimitClear,
        rcoCushExtLimit, rcoCushExtLimitClear,
        rcoLegrestLimit, rcoLegrestLimitClear,
        rcoLegExtLimit, rcoLegExtLimitClear,
        rcoFootRestLimit, rcoFootRestLimitClear,
        rcoHeadRestLimit, rcoHeadRestLimitClear,
        rcoHeadExtLimit, rcoHeadExtLimitClear,
        rcoMonitorLimit, rcoMonitorLimitClear,
        rcoShoulderLimit, rcoShoulderLimitClear,
        rcoWalkinUpTiltLimit, rcoWalkinUpTiltLimitClear,
        rcoEEPROMClear
           );

    TCANIMSCtrler = class(TBaseIMSCtrler)
    private
        function GetRCID: PRCID;

        function GetDebug: boolean; override;
        procedure SetDebug(Enabled: boolean); override;

        function GetRCOpt(RCOpt: TRCOPt): byte;
        procedure SetEnabled(const Value: boolean); override;
        procedure SetReqID(const Value: cardinal);
        procedure SetRespID(const Value: cardinal);

    protected
        mReqID, mRespID: cardinal;  // UDS Can ID
        mRCID: TRCID;                  // Routine Ctrl ID: Limit
        mRDBIID: byte;                   // RDBI:Body Ctrl: Pos, EasyAccess

        mRCType, mRCOpt: byte; // Routine Ctrl용 ex) Limit관련시:  RCType(1, 2, 3)또는 RCType(1) + RCOpt조합으로 사용됨

        mFCBlockSize, mFCSepTime: byte; // Flow Ctrl용

        mCAN: TBaseCan;
        mMFrame: TMultiCANFrame; // CAN 멀티 프레임 처리 ex> Pos, Limit


        mIsLHPos: boolean;

        mPSUType: boolean;           // PSM/PSU에 따라 Limit관련 RC Opt 변경됨 (모듈과 유닛 단순 용어차이인지 개념이 다른지 검토 필요)

        procedure ClearRespData;
        procedure CanRead(Sender: TObject); virtual;// Callback event
        function IsRCGetRespDone: boolean; virtual;

        function WriteFlowCtrl: boolean; virtual; // Consecutive.Frame용
        function WriteRountineCtrl(RCType, RCOpt, DataLen: byte): boolean; // Routine Ctrl용 명령(Limit 관련)
    public
        constructor Create(Can: TBaseCan; PSMID, PSMRespID: cardinal); overload;
        constructor Create(Can: TBaseCan; PSMID, PSMRespID: cardinal; RCID: TRCID); overload;
        constructor Create(Can: TBaseCAN; PSMID, PSMRespID: cardinal; RCID: TRCID; RDBIID: Byte); overload;
        destructor Destroy; override;

        procedure Reset; override;
        function IsPending: boolean; override;

        // --- UDS ------------------------------------------------
        // 통신 요청
        function ReqPos(): boolean; override;
        function ReqEasyAccess(): boolean; override;

        function EnableRCReq(): boolean; override; // Limit상태 읽기전 R.Ctrl Enable후 Delay가 필요(차종 마다 다름)
        function ReqLimit(): boolean; override; // LIMIT 상태 읽기 : CAN UDS 차종별 프레임 변경 됨
        function DeleteLimit(): boolean; override; // 차종별 프레임 변경 됨, (리클라이너 모터 유무 해석으로 인한 길이 변경등..)
        function SetLimit(MotorID: TMotorOrd): boolean; override;
        function SetLimitAll(): boolean; override;

        function GetLimitStatus(MtrID: TMotorOrd): TSMLimitStatus; override;

        // 통신 응답
        function IsLimitRespDone: boolean; override;
        procedure ProcessLimitDone; // 리미트 처리 함수

        function IsPosRespDone: boolean; override;
        procedure ProcessPosDone;

        // --- 차종마다 달리 구현 ------------------------------

        // Flow Control
        procedure SetFlowCtrl(BlockSize, SepTime: byte);

        // 승하차 조건 명령들..
        function SetAuthState: boolean; override;
        function SetVehicleSpeed(Speed: byte = 0): boolean; override;

        function SetIgnSw(Value: boolean): boolean; override;                   //IBUmsg16.C_Ign1, C_Ign2, C_IgnSw
        function SetDrvDoorOpenSw(Value: boolean): boolean; override;           //SJBmsg05.C_DrvDrSw
        function SetPPosSw(Value: boolean): boolean; override; // P Position    최근 사용안하는 추세

        procedure SetRCID(const Value: TRCID);

        // 위치 설정
        function StartMemSet(Value: boolean): boolean; override; // 메모리 위치 설정 시작시
        function SetMemP1(Value: boolean): boolean; override; // 설정 및 동작(Go)
        function SetMemP2(Value: boolean): boolean; override;

        // UDS용 CAN MsgID
        property ReqID: cardinal read mReqID write SetReqID;
        property RespID: cardinal read mRespID write SetRespID;
        property RCID: PRCID read GetRCID;      // Routine Ctrl: Limit
        property RDBIID: byte read mRDBIID write mRDBIID;        // RDBI: Body Ctrl: Pos, EasyAccess

        property PSUType: boolean read mPSUType write mPSUType;

        function GetStateStr(IsSimple: boolean = false): string; override;

        property CAN: TBaseCan read mCAN;
        property IsLHPos: Boolean read mIsLHPos write mIsLHPos;
    end;

    TSimulIMSCtrler = class(TCANIMSCtrler)
    private
        mIMSPos: array[TMotorOrd, 0..10] of integer;
        mPosIdx: integer;
        mIsMemSet: boolean;

        procedure MakeRandomPos;
        procedure ReadRandomPos;
    public
        constructor Create;

        // --- UDS ------------------------------------------------
        // 통신 요청
        function ReqPos(): boolean; override;
        function ReqEasyAccess(): boolean; override;

        function EnableRCReq(): boolean; override; // Limit상태 읽기전 R.Ctrl Enable후 Delay가 필요(차종 마다 다름)
        function ReqLimit(): boolean; override; // LIMIT 상태 읽기 : CAN UDS 차종별 프레임 변경 됨
        function DeleteLimit(): boolean; override; // 차종별 프레임 변경 됨, (리클라이너 모터 유무 해석으로 인한 길이 변경등..)
        function SetLimit(MotorID: TMotorOrd): boolean; override;

        // 통신 응답
        function IsLimitRespDone: boolean; override;
        function IsPosRespDone: boolean; override;

        function SetIgnSw(Value: boolean): boolean; override;

        function SetPPosSw(Valuse: boolean): boolean; override; // P Position
        function SetDrvDoorOpenSw(Value: boolean): boolean; override;
        function SetAuthState: boolean; override;

        function SetVehicleSpeed(Speed: byte = 0): boolean; override;

        // 위치 설정
        function StartMemSet(Value: boolean): boolean; override; // 메모리 위치 설정 시작시
        function SetMemP1(Value: boolean): boolean; override; // 설정 및 동작(Go)
        function SetMemP2(Value: boolean): boolean; override;
    end;

implementation

uses
    UDSDef, Log, SysUtils;

{ TCANIMSCtrler }

constructor TCANIMSCtrler.Create(Can: TBaseCan; PSMID, PSMRespID: cardinal);
begin
    mName := 'CAN IMS Ctrler';
    mCAN := Can;
    mCAN.OnRead.SyncAdd(CanRead);

    mReqID := PSMID;
    mRespID := PSMRespID;

    mRCID := (_UDS_RC_DID_HI shl 8) or _UDS_RC_DID_LO;
    mRDBIID := $B4;

    mFCBlockSize := $08;
    mFCSepTime := $08;

    mMFrame := TMultiCANFrame.Create(PSMID, PSMRespID, 2, 8);

    mEnabled := true;
end;

constructor TCANIMSCtrler.Create(Can: TBaseCan; PSMID, PSMRespID: cardinal; RCID: TRCID);
begin
    Create(Can, PSMID, PSMRespID);
    mRCID := RCID;
end;

constructor TCANIMSCtrler.Create(Can: TBaseCAN; PSMID, PSMRespID: cardinal; RCID: TRCID; RDBIID: Byte);
begin
    Create(Can, PSMID, PSMRespID, RCID);
    mRDBIID := RDBIID;
end;

function TCANIMSCtrler.IsRCGetRespDone: boolean;
begin
    Result := false;

//    glog.Panel('IsRCGetRespDone' + mMFrame.ToStr);
    case mMFrame.mType of
        ftSF:
            begin
//                glog.Panel('sf돌입' + mMFrame.ToStr);
                Result := (mMFrame.mDatas[1] = $71) and (mMFrame.mDatas[2] = $03);   // 응답 & GET인 경우

            end;
        ftCF1:    // CF가 $22인 이상인 경우는 고려 안 함
            begin
                Result := (mMFrame.mDatas[2] = $71) and (mMFrame.mDatas[3] = $03);   // 응답 & GET인 경우
            end;
    end;

end;

type
    TMotorORDArray = array of TMotorORD;

procedure TCANIMSCtrler.ProcessLimitDone;

    function UpdateLimitStatus: TMotorORDArray;
    var
        It: TMotorORD;
        idx: Integer;
        tmpResult: TMotorORDArray;
        count: Integer;
    begin
        SetLength(tmpResult, 0);
        count := 0;

        for It := Low(TMotorORD) to High(TMotorORD) do
        begin
            idx := UDS_USE_RC_RESP_IDXS[It];
            if mLimitStatus[It] <> mMFrame.mDatas[idx] then
            begin
                mLimitStatus[It] := mMFrame.mDatas[idx];

                SetLength(tmpResult, count + 1);
                tmpResult[count] := It;
                Inc(count);
            end;
        end;

        Result := tmpResult;
    end;

    procedure LogLimitStatus(const StatChangeMotors: TMotorORDArray);
    var
        It: TMotorORD;
        i: Integer;
        msg: string;
    begin
        if Length(StatChangeMotors) = 0 then
            Exit;

        msg := 'Changed Limit Status:';
        for i := 0 to High(StatChangeMotors) do
        begin
            It := StatChangeMotors[i];
            msg := msg + Format(' [%s = %x]', [_MOTOR_ID_STR[It], mLimitStatus[It]]);
        end;

        gLog.Panel('%s', [msg]);
    end;

var
    It: TMotorORD;
    StatChangeMotors: TMotorORDArray;
begin

{$IFDEF _SIMUL_MTR}
    for It := Low(TMotorORD) to High(TMotorORD) do
        mLimitStatus[It] := _UDS_RC_LIMIT_OK;
{$ELSE}
    StatChangeMotors := UpdateLimitStatus;
    LogLimitStatus(StatChangeMotors);
{$ENDIF}
end;
procedure TCANIMSCtrler.ProcessPosDone;
begin
end;

function TCANIMSCtrler.IsLimitRespDone: boolean;
begin
    Result := IsRCGetRespDone;
end;

function TCANIMSCtrler.IsPending: boolean;
begin
    Result := not mMFrame.IsDone;
end;

function TCANIMSCtrler.IsPosRespDone: boolean;
var
    Val: Word;
begin
    Result := mMFrame.IsDone and (mMFrame.mDatas[2] = $62);
end;

function TCANIMSCtrler.ReqEasyAccess: boolean;
begin
    ClearRespData;
    Result := mCAN.Write(mReqID, 0, [$04, _UDS_RDBI_REQ_SID, mRDBIID, _UDS_RDBI_EASY_ACCESS, 0, 0, 0, 0], 8); // TO DO
end;

function TCANIMSCtrler.WriteFlowCtrl: boolean;
begin
    Result := mCAN.Write(mReqID, 0, [$30, mFCBlockSize, mFCSepTime, $AA, $AA, $AA, $AA, $AA], 8);
end;

function TCANIMSCtrler.EnableRCReq: boolean;
begin
    ClearRespData;
    Result := WriteRountineCtrl(_UDS_RC_SET, $F0, 5); // $F0 옵션 Routine Req Enable
end;

function TCANIMSCtrler.GetRCID: PRCID;
begin
    Result := @mRCID;
end;

function TCANIMSCtrler.GetRCOpt(RCOpt: TRCOPt): byte;
begin
    if mPSUType then  // CE, LX2 ...
    begin
        case RCOpt of
            rcoAllLimit:
                Result := $40;
            rcoAllLimitClear:
                Result := $41;
            rcoSlideLimit:
                Result := $44;
            rcoSlideLimitClear:
                Result := $45;
            rcoTiltLimit:
                Result := $46;
            rcoTiltLimitClear:
                Result := $47;
            rcoHeightLimit:
                Result := $48;
            rcoHeightLimitClear:
                Result := $49;
            rcoCushExtLimit:
                Result := $4C;
            rcoCushExtLimitClear:
                Result := $4D;
            rcoLegrestLimit:
                Result := $50;
            rcoLegrestLimitClear:
                Result := $51;
            rcoReclLimit:
                Result := $42;
            rcoReclLimitClear:
                Result := $43;
        end
    end
    else
    begin                // JK1, JX1, RS4..
        case RCOpt of
            rcoAllLimit:
                Result := $00;
            rcoAllLimitClear:
                Result := $80;
            rcoSlideLimit:
                Result := $01;
            rcoSlideLimitClear:
                Result := $81;
            rcoTiltLimit:
                Result := $03;
            rcoTiltLimitClear:
                Result := $83;
            rcoHeightLimit:
                Result := $04;
            rcoHeightLimitClear:
                Result := $84;
            rcoCushExtLimit:
                Result := $06;
            rcoCushExtLimitClear:
                Result := $86;

            rcoLegrestLimit:
                Result := $50;
            rcoLegrestLimitClear:
                Result := $51;

            rcoReclLimit:
                Result := $02;
            rcoReclLimitClear:
                Result := $82;
        end

    end;
end;

function TCANIMSCtrler.GetStateStr(IsSimple: boolean): string;
begin
    Result := inherited GetstateStr(IsSimple) + ';   ' + mMFrame.GetStateStr;
end;

function TCANIMSCtrler.ReqLimit: boolean;
begin
    ClearRespData;
    Result := WriteRountineCtrl(_UDS_RC_GET, 0, 4);     // New UDS: 위 EnableRCReq() 호출 이후 요청해야 함 , 길이4 검증 필요
end;

function TCANIMSCtrler.DeleteLimit: boolean;        // All Limit Clear
begin
    ClearRespData;
    Result := WriteRountineCtrl(_UDS_RC_SET, GetRCOpt(rcoAllLimitClear), 5);  // 옵션 : $80: All Clear, $81: Slide Clear, $83: Tilt, $84: Hgt, $86: C.Ext
end;

destructor TCANIMSCtrler.Destroy;
begin
    if Assigned(mCAN) then
        mCAN.OnRead.SyncRemove(CanRead);

    mMFrame.Deinit;

    inherited;
end;

function TCANIMSCtrler.SetLimit(MotorID: TMotorOrd): boolean;
var
    MotorType, Len: byte;
begin
    ClearRespData;

    Len := $05;
    case MotorID of
        tmSlide:
            MotorType := GetRCOpt(rcoSlideLimit);
//        tmTilt:
//            MotorType := GetRCOpt(rcoTiltLimit);
//        tmHeight:
//            MotorType := GetRCOpt(rcoHeightLimit);
//        tmCushExt:
//            MotorType := GetRCOpt(rcoCushExtLimit);
    else
        MotorType := GetRCOpt(rcoAllLimit)
    end;

    Result := WriteRountineCtrl(_UDS_RC_SET, MotorType, Len);

end;

function TCANIMSCtrler.SetLimitAll: boolean;
begin
    Result := WriteRountineCtrl(_UDS_RC_SET, GetRCOpt(rcoAllLimit), $05);
end;

function TCANIMSCtrler.GetDebug: boolean;
begin
    Result := mMFrame.mDebug;
end;

function TCANIMSCtrler.GetLimitStatus(MtrID: TMotorOrd): TSMLimitStatus;
begin
    case mLimitStatus[MtrID] of
        $00:
            Result := lsInvalid;
        $11:
            Result := lsIng;
        $02, $12:
            Result := lsDone;
        $03:
            Result := lsUnKnown;
    else
        Result := lsNone;
    end;
end;

function TCANIMSCtrler.WriteRountineCtrl(RCType, RCOpt, DataLen: byte): boolean;
begin
    Result := mCAN.Write(mReqID, 0, [DataLen, _UDS_RC_REQ_SID, RCType, mRCID.mHi, mRCID.mLo, RCOpt, 0, 0], 8);
end;

function TCANIMSCtrler.ReqPos: boolean;
begin
    ClearRespData;

    Result := mCAN.Write(mReqID, 0, [$03, _UDS_RDBI_REQ_SID, mRDBIID, 3, 0, 0, 0, 0], 8);
end;

procedure TCANIMSCtrler.Reset;
begin
    mCAN.Close;
    Sleep(10);

    if mCAN.Open then
    begin
    end;
end;

procedure TCANIMSCtrler.ClearRespData;
begin
    mMFrame.ClearFSM;
    mMFrame.Clear;

    FillChar(mLimitStatus, sizeof(mLimitStatus), 0);
end;

function TCANIMSCtrler.SetAuthState: boolean;
begin
    Result := mCAN.Write($1AB, 0, [$0, 0, 0, 0, 0, 0, 0, 0], 8);
end;

procedure TCANIMSCtrler.SetDebug(Enabled: boolean);
begin

    mMFrame.mDebug := Enabled;
end;

function TCANIMSCtrler.SetDrvDoorOpenSw(Value: boolean): boolean;
begin
    ClearRespData;

    if Value then
    begin
        Result := mCAN.Write(_KEY_LESS_BCM_ID, 0, [0, 0, 0, 1, 0, 0, 0, 0], 8);

    end
    else
    begin
        Result := mCAN.Write(_KEY_LESS_BCM_ID, 0, [0, 0, 0, 0, 0, 0, 0, 0], 8);
    end
end;

procedure TCANIMSCtrler.SetEnabled(const Value: boolean);
begin
    if mEnabled = Value then
        Exit;

    mEnabled := Value;

    if mEnabled then
        mCAN.OnRead.SyncAdd(CanRead)
    else
        mCAN.OnRead.SyncRemove(CanRead)

end;

procedure TCANIMSCtrler.SetFlowCtrl(BlockSize, SepTime: byte);
begin
    mFCBlockSize := BlockSize;
    mFCSepTime := SepTime;
end;

function TCANIMSCtrler.SetIgnSw(Value: boolean): boolean;
begin
    ClearRespData;

    if Value then
    begin
        Result := mCAN.Write(_C_IGNSW_BCM_ID, 0, [0, 0, 0, 0, $50, $03, 0, 0], 8);

    end
    else
    begin
        Result := mCAN.Write(_C_IGNSW_BCM_ID, 0, [0, 0, 0, 0, 0, 0, 0, 0], 8);
    end;
end;

function TCANIMSCtrler.SetPPosSw(Value: boolean): boolean;
begin
    ClearRespData;
//    Result := mCAN.Write(_C_IGNSW_BCM_ID, 0, [0, 0, 0, 0, 0, _C_P_POS_ON, 0, 0], 8);
    if Value then
        Result := mCAN.Write($422, [0, 0, 0, 0, 0, 0, $04, 0])    // 23.04.04
    else
        Result := mCAN.Write($422, [0, 0, 0, 0, 0, 0, 0, 0]);    // 23.04.04
end;

procedure TCANIMSCtrler.SetReqID(const Value: cardinal);
begin
    mReqID := Value;
    mMFrame.mReqID := Value;
end;

procedure TCANIMSCtrler.SetRespID(const Value: cardinal);
begin
    mRespID := Value;
    mMFrame.mRspID := Value;
end;

procedure TCANIMSCtrler.SetRCID(const Value: TRCID);
begin
    mRCID := Value;
end;

function TCANIMSCtrler.SetVehicleSpeed(Speed: byte): boolean;
begin
    ClearRespData;
    Result := mCAN.Write(_C_DE_VehicSpd_ID, 0, [0, 0, Speed, 0, 0, 0, 0], 8);
end;

function TCANIMSCtrler.StartMemSet(Value: boolean): boolean;
begin
    if Value then
    begin
        Result := mCAN.Write(_DDM_MEM_ID, 0, [0, $80, 0, 0, 0, 0, 0, 0], 8);
    end
    else
    begin
        Result := mCAN.Write(_DDM_MEM_ID, 0, [0, 0, 0, 0, 0, 0, 0, 0], 8);
    end;
end;

function TCANIMSCtrler.SetMemP1(Value: boolean): boolean;
begin

    if Value then
    begin
        Result := mCAN.Write(_DDM_MEM_ID, 0, [0, $10, 0, 0, 0, 0, 0, 0], 8);
    end
    else
    begin
        Result := mCAN.Write(_DDM_MEM_ID, 0, [0, 0, 0, 0, 0, 0, 0, 0], 8);
    end;

end;

function TCANIMSCtrler.SetMemP2(Value: boolean): boolean;
begin

    if Value then
    begin
        Result := mCAN.Write(_DDM_MEM_ID, 0, [0, $08, 0, 0, 0, 0, 0, 0], 8);
    end
    else
    begin
        Result := mCAN.Write(_DDM_MEM_ID, 0, [0, 0, 0, 0, 0, 0, 0, 0], 8);
    end;

end;

const
    TF_TXT: array[false..true] of string = ('false', 'true');

procedure TCANIMSCtrler.CanRead(Sender: TObject);
begin
//   glog.Panel('TCANIMSCtrler.CanRead %s' ,[TF_TXT[mEnabled]]);
    if not mEnabled then
        Exit;

    mMFrame.FSMRun(mCAN);
end;



{ TSimulIMSCtrler }

constructor TSimulIMSCtrler.Create;
begin
    mName := 'SIM. IMS Ctrler';
    mPosIdx := 0;

end;

function TSimulIMSCtrler.DeleteLimit: boolean;
begin
    gLog.Panel('SIMUL:DeleteLimit');
    Result := true;
end;

function TSimulIMSCtrler.EnableRCReq: boolean;
begin
    gLog.Panel('SIMUL:EnableRCReq');
    Result := true;
end;

function TSimulIMSCtrler.IsLimitRespDone: boolean;
begin

    Result := true;
end;

function TSimulIMSCtrler.IsPosRespDone: boolean;
begin

    Result := true;
end;

function TSimulIMSCtrler.ReqEasyAccess: boolean;
begin
    gLog.Panel('SIMUL:ReqEasyAccess');
    mPosIdx := 0;
    Result := true;
end;

function TSimulIMSCtrler.ReqLimit: boolean;
begin
    gLog.Panel('SIMUL:ReqLimit');
    Result := true;
end;

function TSimulIMSCtrler.ReqPos: boolean;
begin
    gLog.Panel('SIMUL:ReqPos');
    Result := true;
end;

function TSimulIMSCtrler.SetAuthState: boolean;
begin
    Result := true;
end;

function TSimulIMSCtrler.SetDrvDoorOpenSw(Value: boolean): boolean;
begin
    gLog.Panel('SIMUL:SetDrvDoorOpenSw: %s', [BoolToStr(Value, true)]);
    Result := true;
end;

function TSimulIMSCtrler.SetIgnSw(Value: boolean): boolean;
begin
    gLog.Panel('SIMUL:SetIgnSw: %s', [BoolToStr(Value, true)]);

    {
      if not Value then
      begin
      MakeRandomPos;
      Inc(mPosIdx);
      mIsMemSet := false;
      end
      else
      begin
      Dec(mPosIdx);
      end;
      }
    Result := true;
end;

function TSimulIMSCtrler.SetLimit(MotorID: TMotorOrd): boolean;
begin
    gLog.Panel('SIMUL:SetLimit');
    Result := true;
end;

procedure TSimulIMSCtrler.MakeRandomPos;
begin
//    mIMSPos[tmSlide, mPosIdx] := random(100) + 1;
//    mIMSPos[tmTilt, mPosIdx] := random(100) + 1;
//    mIMSPos[tmHeight, mPosIdx] := random(100) + 1;
//    mIMSPos[tmCushExt, mPosIdx] := random(100) + 1;
end;

procedure TSimulIMSCtrler.ReadRandomPos;
begin
//    mPos[tmSlide] := mIMSPos[tmSlide, mPosIdx];
//    mPos[tmTilt] := mIMSPos[tmTilt, mPosIdx];
//    mPos[tmHeight] := mIMSPos[tmHeight, mPosIdx];
//    mPos[tmCushExt] := mIMSPos[tmCushExt, mPosIdx];
end;

function TSimulIMSCtrler.SetMemP1(Value: boolean): boolean;
begin
    gLog.Panel('SIMUL:SetMemP1: %s', [BoolToStr(Value, true)]);

    {
      if Value then Exit(true);

      if mIsMemSet then
      begin
      MakeRandomPos;
      Inc(mPosIdx);
      mIsMemSet := false;
      end
      else
      begin
      Dec(mPosIdx);
      ReadRandomPos;
      end;
      }

    Result := true;
end;

function TSimulIMSCtrler.SetMemP2(Value: boolean): boolean;
begin
    gLog.Panel('SIMUL:SetMemP2: %s', [BoolToStr(Value, true)]);

    {
      if Value then Exit(true);


      if mIsMemSet then
      begin
      MakeRandomPos;
      Inc(mPosIdx);
      mIsMemSet := false;
      end
      else
      begin
      Dec(mPosIdx);
      ReadRandomPos;
      end;
      }

    Result := true;
end;

function TSimulIMSCtrler.SetPPosSw(Valuse: boolean): boolean;
begin
    gLog.Panel('SIMUL:SetPPosSw');
    Result := true;
end;

function TSimulIMSCtrler.SetVehicleSpeed(Speed: byte): boolean;
begin
    gLog.Panel('SIMUL:SetVehicleSpeed');
    Result := true;
end;

function TSimulIMSCtrler.StartMemSet(Value: boolean): boolean;
begin
    gLog.Panel('SIMUL:StartMemSet: %s', [BoolToStr(Value, true)]);
    mIsMemSet := true;
    Result := true;
end;

{ TRCID }

constructor TRCID.Create(Hi, Lo: byte);
begin
    mHi := Hi;
    mLo := Lo;
end;

constructor TRCID.Create(AVal: DWORD);
begin
    Val := AVal;
end;

class operator TRCID.Implicit(AVal: DWORD): TRCID;
begin
    Result.Val := AVal;
end;

{ TIMSCtrlerBuilder }

constructor TIMSCtrlerBuilder.Create;
begin
    TIMSCtrlerBuilder.Create(nil, $7A3, $7AB);
    mDOIgnCh := -1;

    mRCID := (_UDS_RC_DID_HI shl 8) or _UDS_RC_DID_LO;
    mRDBIID := $B4;
end;

constructor TIMSCtrlerBuilder.Create(CAN: TBaseCAN; PSMID, PSMRespID: cardinal);
begin
    mCAN := CAN;
    mDIO := nil;
    mDOIgnCh := -1;
    mReqID := PSMID;
    mPSMRespID := PSMRespID;
    mRCID := (_UDS_RC_DID_HI shl 8) or _UDS_RC_DID_LO;
    mRDBIID := $B4;

    mBuilder := self;   // 인터페이스의 자동 삭제를 이용하기 위한 편법
end;

function TIMSCtrlerBuilder.Build: TCANIMSCtrler;
begin
    Result := TCANIMSCtrler.Create(mCAN, mReqID, mPSMRespID);

    Result.DIO := mDIO;
    Result.DOIgnCh := mDOIgnCh;

    Result.RCID^ := mRCID;
    Result.RDBIID := mRDBIID
end;

function TIMSCtrlerBuilder.WithRDBIID(RDBIID: byte): TIMSCtrlerBuilder;
begin
    mRDBIID := RDBIID;
    Result := Self;
end;

function TIMSCtrlerBuilder.WithCAN(CAN: TBaseCAN): TIMSCtrlerBuilder;
begin
    mCAN := CAN;
    Result := Self;
end;

function TIMSCtrlerBuilder.WithDIO(DIO: TBaseDIO; DOIgnCh: integer): TIMSCtrlerBuilder;
begin
    mDIO := DIO;
    mDOIgnCh := DOIgnCh;
    Result := Self;
end;

function TIMSCtrlerBuilder.WithPsmID(PSMID, PSMRespID: cardinal): TIMSCtrlerBuilder;
begin
    mReqID := PSMID;
    mPSMRespID := PSMRespID;
    Result := Self;
end;

function TIMSCtrlerBuilder.WithRCID(RCID: TRCID): TIMSCtrlerBuilder;
begin
    mRCID := RCID;
    Result := Self;
end;

end.

