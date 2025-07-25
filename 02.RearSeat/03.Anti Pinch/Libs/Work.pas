unit Work;
{$INCLUDE myDefine.inc}

interface

uses
    Windows, sysutils, {$IFNDEF VER150} FileCtrl, {$ENDIF} Classes, Messages,
    EtherCatUnit, DataUnit, KiiBaseUnit, KiiWorkThread, KiiMessages, ModelType,
    SeatType, MelsecPackEx, PLCAddInfo;

type
    TCANMakerType = (cmtSimul, cmtVector, cmtAdv, cmtBnR, cmtPeak);

    TLINMakerType = (lmtSimul, lmtVecotr, lmtPeak, lmtBnR);

    TWork = class(TKiiBase)
    private
        mThread: TWorkEx;

        mComRefresh: boolean;

        mReady: boolean;
        mProc: integer;
        mIntTime, mLoopTime: double;
        mSafeTime: double;

        mIsClose: boolean;

        mioAuto: array[0..1] of boolean;
        mUsrState: integer;

        mPLCAddInfos: TPLCAddInfos;

        procedure WorkProcess(Sender: TObject);
{$IFNDEF VIRTUALIO}
        procedure OnUsrRecievedIos(Sender: TObject; AType: integer);
{$ENDIF}
        procedure ResetIdleTime;
        procedure ReadMessage(var myMsg: TMessage); message WM_SYS_CODE;
        procedure IoCloseCheck(AIndex, APort: integer);
        procedure CheckModelChange;
        procedure TsWorkRun(Sender: TObject; AIsRun: boolean);
        procedure OnDaqError(Sender: TObject; Value: string);
        procedure CreateTsWorks(MaxStCount: integer);


        // 2Port 사용시 모델 읽기
        procedure ReadIOReqPack(Pack: TPackQnA3E_Ascii);
        procedure ReadIORespPack(Pack: TPackQnA3E_Ascii);

    public
        constructor Create(AOwner: TComponent); override;
        destructor Destroy; override;

        procedure Start;
        procedure Stop;
        procedure Reset;

        function GetIo(ACH: integer): boolean;
        function IsSystemIDLE: boolean;
        function IsTesting: boolean;
{$IFDEF VIRTUALIO}
        procedure OnUsrRecievedIos(Sender: TObject; AType: integer);
{$ENDIF}
        function GetUsrBuffCounts: string;
        procedure SetUsrFileUpdates;

        property ComRefresh: boolean write mComRefresh;
        property LoopTime: double read mLoopTime;
        property IntTime: double read mIntTime;
        property IsRun: boolean read mReady;
        property Thread: TWorkEx read mThread write mThread;

        property PLCAddInfos: TPLCAddInfos read mPLCAddInfos;

    protected
        mLoopTmpTime: double;
        mIntTmpTime: double;
    end;

var
    gWork: TWork;

implementation

uses
    myUtils, Forms, Log, Dialogs, ComUnit, LanIoUnit, PowerSupplyUnit, PopWork,
    KiiFaGraphDB, UserSocketUnit, ModelUnit, BoxLibEC, BaseTsWork, IniFiles,
    BaseDAQ, BaseAD, BaseDIO, BaseCAN, EtherCatCan, PEAKCanUnit, EtherCatDIO,
    Global, SysEnv, UDSDef, SeatConnector, TsWorkUnit, IODef, LangTran,
    ECSOEMCore;

const
    ST_EC_IN_BYTE_COUNT = 134;
    ST_EC_OUT_BYTE_COUNT = 14;
    ARY_HI_DAQ_VALS: array[0..7] of double = (100, 100, 10, 10, 200, 200, 200, 200);
    ARY_LO_DAQ_VALS: array[0..7] of double = (-100, -100, -10, -10, -200, -200, -200, -200);
    ARY_DAQ_GAINS: array[0..7] of double = (1.0, 1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0);

    {
      CH2	    DC PWR 메인전류     (50A/5V)
      }

    // ------------------------------------------------------------------------------
    // TWork
    // ------------------------------------------------------------------------------

function CreateCAN(MakerType: TCANMakerType; Ch: integer): TBaseCAN;
var
    SimCAN: TSimulCAN;

    function CreateSimCAN: TBaseCAN;
    begin
        SimCAN := TSimulCAN.Create(true);
        SimCAN.Name := 'Sim.CAN' + IntToStr(Ch);
        SimCAN.AddSimFrame($388, [$FF, $01, $41, $30, $31, $00, $12, $34]); // RS4 Drv의 Height, Slide Pos ($12, $34) 시뮬
        Result := SimCAN;
    end;

begin

    if (MakerType = cmtSimul) or (Ch < 0) then
    begin
        Result := CreateSimCAN;
    end
    else
    begin

        case MakerType of
            cmtBnR:
                begin
                    if Ch = 0 then
                        Result := TECCan.Create(148, 152, 12, 16)
                    else
                        Result := TECCan.Create(ST_EC_IN_BYTE_COUNT + 148, ST_EC_IN_BYTE_COUNT + 152, ST_EC_OUT_BYTE_COUNT + 12, ST_EC_OUT_BYTE_COUNT + 16);

                    Result.Name := 'EC(BnR).CAN' + IntToStr(Ch);
                   // Result.WQueueing := True;
                   // Result.WDelay := 5;
                end;
            cmtPeak:
                begin
                    Result := TPeakCAN.Create();
                    Result.UseFD := True;
                    Result.Name := 'PEAK.CAN' + IntToStr(Ch);

                end;
        else
            Result := CreateSimCAN;
        end;

    end;

    Result.OwnerFree := true;
end;

procedure ECStatus(ECManager: TECManager; Status: TECStatus);
var
    i: Integer;
    Msg: string;
begin
    case Status of
        ecsStart:
            begin

            end;
        ecsStop:
            begin

            end;
        ecsRetry:
            ;
        ecsError:
            begin

                for i := 0 to gTsWorks.Count - 1 do
                begin
                    Msg := Format('%s' + _TR('공정 이더캣 통신 에러'), [gTsWorks[i].Name]);
                    if gTsWorks[i].IsRun then
                        gTsWorks[i].SetError(Msg, '프로그램을 재시작하거나, PC를 재시작 하세요')
                    else
                        SetErrorTxt('DAQ ERROR', Msg, '이더캣 모듈의 전원 투여 여부,  이더캣 LAN선의 상태를 점검하세요');

                end;
            end;

    end;

    SendToForm(gUsrMsg, SYS_ECAT_STATUS, ord(Status));
end;

const
    PLC_DATA_ID_MODEL = 1;
    PLC_DATA_ID_FPROOF = 2;
    USE_SOEM = 1;

constructor TWork.Create(AOwner: TComponent);
type
    TPlcIOAdd = record
        mRead, mWrite, mData: Integer;
    end;

    function GetPLCIOAdd: TPlcIOAdd;
    begin
        case gSysEnv.rOP.rStNo of
            1, 9:
                begin
                    Result.mRead := $440;
                    Result.mWrite := $440;
                    Result.mData := $450;
                end;

        else
            Result.mRead := $400;
            Result.mWrite := $500;
            Result.mData := $410;
            ShowMessage(Format('공정번호: %d에 해당하는 PLC 주소 없음', [gSysEnv.rOP.rStNo]));
        end;
    end;

var
    PlcIOAdd: TPlcIOAdd;
    MaxStCount: integer;
    ConStr: string;
begin
    Randomize();

    inherited Create(AOwner);

    gLog.Debug('WORK CREATED', []);

    mPLCAddInfos := TPLCAddInfos.Create();

    mThread := TWorkEx.Create(tpLower);
    with mThread do
    begin
        OnUsrExec := WorkProcess;
        Delay := true;
        Interval := 10;
    end;

    gUsrMsg := TForm(AOwner).Handle;

    if gSysEnv.rDevelop.rEtherCAT = USE_SOEM then
    begin
        TECManager.GetInstance.Core := TECSOEMCore.Create;
        gLog.Panel('EtherCAT: SOEM 사용');
    end;

    TECManager.GetInstance.BufferLen := ST_EC_IN_BYTE_COUNT * 2;

    if not TECManager.GetInstance.Open then
    begin
        gLog.Panel('EtherCAT 장치 열기 실패!');
        SetErrorTxt('DAQ ERROR', '이더캣 드라이버 OPEN 오류', '이더캣 마스터 보드의 올바른 장착 및 드라이버 설치를 확인하시고, 전용 LAN선의 상태도 점검하세요', umtError);
    end;

    PlcIOAdd := GetPLCIOAdd;

    gLanDIO := TDioMonitor.Create(Handle,
            [TPlcAddInfo.Create(dtWORD, 'W', PlcIOAdd.mRead, _WORD_PER_ST * MAX_ST_COUNT, 0), TPlcAddInfo.Create(dtWORD, 'W', PlcIOAdd.mData, MAX_MODEL_WD_COUNT, 1, True)],
            [TPlcAddInfo.Create(dtWORD, 'W', PlcIOAdd.mWrite, _WORD_PER_ST * MAX_ST_COUNT, 0)]);

    with gLanDIO.GetItem(ord(devREAD)) as TReadIO do
    begin
        OnRecievedDatas := OnUsrRecievedIos;

{$IFNDEF VIRTUALLANIO}
{$ENDIF}
    end;

    gSocketMan := TSocketMan.Create(Handle, true);
    gDevComs := TDevComs.Create(Handle);
    gModels := TUserModels.Create();
//    gDcPower := TDcPowers.Create([]);
    gPopsys := TPopSystems.Create(Handle, MAX_ST_COUNT);

    if not gConMan.Load(GetEnvPath('JG1_Connector.json')) then
    begin
        gLog.Error('커넥터 정보 파일:JG1_Connector.json 열기 실패', []);
        SetErrorTxt('OPEN ERROR', '커넥터 정보 파일 OPEN 오류', 'Env폴더내 JG1_Connector.json 파일 유무를 확인 하세요', umtError);
    end;

    CreateTsWorks(MAX_ST_COUNT);

    { 그래프 파일 저장 }
    gKiiDB := TKiiGraphDB2.Create(stHour, GetUsrDir(udRS, Now(), false));

    mProc := 0;
    mReady := false;
    mComRefresh := true;
    mIntTime := 0.0;
    mLoopTime := 0.0;
    mSafeTime := 0.0;
    mioAuto[0] := false;
    mioAuto[1] := false;

end;

procedure TWork.CreateTsWorks(MaxStCount: integer);
var
    i: integer;
    StID: TStationID;
    Msg: string;
    OffsetIn, OffsetOut: integer;
    CANs: array[0..MAX_ST_COUNT - 1] of TBaseCAN;
    DIOs: array[0..MAX_ST_COUNT - 1] of TBaseDIO;
    ADs: array[0..MAX_ST_COUNT - 1] of TUserECAD;
    AOs: array[0..MAX_ST_COUNT - 1] of TECAO;
begin
    gTsWorks := TTsWorks.Create;

    StID := st_Limit;

    for i := 0 to MaxStCount - 1 do
    begin
        OffsetIn := i * ST_EC_IN_BYTE_COUNT;
        OffsetOut := i * ST_EC_OUT_BYTE_COUNT;

        ADs[i] := TUserECAD.Create(
            [TECModule.Create(OffsetIn + 16, 8), TECModule.Create(OffsetIn + 36, 8), TECModule.Create(OffsetIn + 56, 8),
             TECModule.Create(OffsetIn + 76, 8), TECModule.Create(OffsetIn + 96, 8), TECModule.Create(OffsetIn + 116, 8)]);

        ADs[i].Init(ARY_DAQ_GAINS, ARY_HI_DAQ_VALS, ARY_LO_DAQ_VALS, 0, 7);
        ADs[i].Init(1, 10 * 2, -10 * 2, Abs(SYS_REF_VOLT), AI_MAIN_CON_VOLT_START, AI_MAIN_CON_VOLT_END);    ///

        ADs[i].OnError := OnDaqError;
        ADs[i].Name := Format('AD%d', [i]);
        ADs[i].Load(GetEnvPath('ADINfo.ini'));

        AOs[i] := TECAO.Create([TECModule.Create(OffsetOut + 0, 2)], 0, 2);
        gSysEnv.rRefVoltSetter.SetAO(i, AOs[i]);

        DIOs[i] := TEtherCatDIO.Create(
            [TECModuleDIO.Create(OffsetIn + 4, 12)],
            [TECModuleDIO.Create(OffsetOut + 8, 12), TECModuleDIO.Create(OffsetOut + 10, 12),
             TECModuleDIO.Create(OffsetOut + 12, 12)], _DIO_OUT_START);

        DIOs[i].SetChTypes(gSysEnv.rOP.rDIChType);
        DIOs[i].ReadBack;
        DIOs[i].Name := Format('DIO%d', [i]);

{$IFDEF VIRTUALIO}
        CANs[i] := CreateCAN(cmtSimul, i);
{$ELSE}
        CANs[i] := CreateCAN(cmtPeak, i);
{$ENDIF}

        TECManager.GetInstance.Add(ADs[i], true);
        TECManager.GetInstance.Add(AOs[i], true);
        TECManager.GetInstance.Add(DIOs[i], true);
        TECManager.GetInstance.OnStatus := ECStatus;

         // 아래 추가 !!! ------ Module OK 상태 체크
        //TECManager.GetInstance.SetModuleOKOffsets([34, 194]);   // AI 시작 모듈, CAN 모듈
        //TECManager.GetInstance.SetModuleOKOffsets([OffsetIn + 34, OffsetIn + 194]);   // AI 시작 모듈, CAN 모듈

        gTsWork[i] := TTsWork.Create(StID, CANs[i], ADs[i], DIOs[i], nil);
        gTsWorks.AddItem(gTsWork[i]);

        //- 2공정시 버퍼 순서:  LAN IN IN OUT OUT
        gTsWork[i].SetLanDIChs(i * (_LAN_IO_CH_COUNT div 2));
        gTsWork[i].SetLanDOChs((i + MAX_ST_COUNT) * (_LAN_IO_CH_COUNT div 2));
        gTsWork[i].InitJogChs;
        StID := Succ(StID);

        with gTsWork[i] do
        begin
            OnRun := TsWorkRun;
        end;

        if i > 0 then
            gTsWork[i].LinkNext(gTsWork[i - 1]);
    end;


    gSysEnv.rRefVoltSetter.ApplyToAll;
end;

destructor TWork.Destroy;
var
    i: Integer;
begin
    mReady := false;

    mPLCAddInfos.Free;

    if Assigned(gTsWorks) then
        FreeAndNil(gTsWorks);

    if Assigned(gKiiDB) then
        FreeAndNil(gKiiDB);

    if Assigned(gPopsys) then
        FreeAndNil(gPopsys);


    if Assigned(gModels) then
        FreeAndNil(gModels);

    if Assigned(gDevComs) then
        FreeAndNil(gDevComs);

    if Assigned(gLanDIO) then
        FreeAndNil(gLanDIO);

    if Assigned(gSocketMan) then
        FreeAndNil(gSocketMan);

    gLog.Debug('WORK DESTROIED', []);

    inherited Destroy;
end;

procedure TWork.OnDaqError(Sender: TObject; Value: string);
begin
    SetErrorTxt('PCI-1716',
{$IFDEF LANG}
        'DAQ ' + GetUsrMsg(105),
{$ELSE}
        _TR('DAQ 오류발생 다음 메시지를 확인하여 조치하십시요'),
{$ENDIF}
        Value, umtError);
end;

procedure TWork.Start;
begin
    if mReady then
        Exit;

    mIsClose := false;
    if Assigned(mThread) and mThread.Suspended then
    begin
        TECManager.GetInstance.Delay := True;
        TECManager.GetInstance.Start;

        TDAQManager.GetInstance.Delay := True;
        if TDAQManager.GetInstance.Count > 0 then
            TDAQManager.GetInstance.Start;

        gSocketMan.Start;
        gLanDIO.Start;
//        gDcPower.Start;

        gTsWorks.Start;
        gPopsys.Start;

        ResetIdleTime;

        mThread.Delay := true;
        mThread.Start;

        mReady := true;
    end;
end;

procedure TWork.Stop;
var
    dTm: double;
begin

    mIsClose := true;

    if not mReady then
    begin

        if Assigned(mThread) then
        begin
            mThread.Close;
            Exit;
        end;
    end;

    mReady := false;

    TECManager.GetInstance.Stop;
    TDAQManager.GetInstance.Stop;

    gPopsys.Stop;

    gTsWorks.Stop;
//    gDcPower.Stop;
    // ==============================
    // 그냥 죽기전에 I/O Clear 작업.

    gLanDIO.SetClearAll;

    dTm := GetAccurateTime;
    while (GetAccurateTime - dTm) <= 500.0 do
    begin
        gSocketMan.WorkProcess(Self);
        gLanDIO.WorkProcess(Self);
    end;
    // ==============================

    gLanDIO.Stop;
    gSocketMan.Stop;

    if Assigned(mThread) then
    begin
        mThread.Close;
        Exit;
    end;

end;

procedure TWork.WorkProcess(Sender: TObject);
begin

    if not mReady then
        Exit;
    mIntTmpTime := GetAccurateTime;
    { TCP/IP 프로세스 }
    gSocketMan.WorkProcess(Self);
    { LAN I/O 프로세스 }
    gLanDIO.WorkProcess(Self);
    { CAN Control 프로세스 }

    { TEST 프로세스 }
    gTsWorks.WorkProcess(Self);

    { 기타 프로세스 }
    case mProc of
        0:
            begin
                { 통신 포트 변경 }
                if mComRefresh then
                begin
                    gDevComs.Updates;
                    mComRefresh := false;
                end;
            end;
        1:
            begin
                { ComPort 관리자 }
                gDevComs.WorkProcess(Self);
            end;
        2:
            begin
                //-
//                gDcPower.WorkProcess(Self);
            end;
        3:
            begin
                gPopsys.WorkProcess(Self);
            end;
        4:
            begin
                CheckModelChange;
            end;
    end;

    Inc(mProc);
    mProc := mProc mod 5;
    { 쓰레드 사이클 타임 확인 }
    mIntTime := GetAccurateTime - mIntTmpTime;

//    if mThread.InProc <> 1 then   Exit;
    mLoopTime := GetAccurateTime - mLoopTmpTime;
    mLoopTmpTime := GetAccurateTime;
    if mLoopTime > 100.0 then
    begin
        gLog.ToFiles('CycleOver: %f', [mLoopTime]);
    end;
end;

procedure TWork.TsWorkRun(Sender: TObject; AIsRun: boolean);
const
    _THREAD_SPEED: array[false..true] of string = ('HIGH', 'LOW');
var
    i: integer;
    nIsRun: boolean;
begin
    // 시험중이 아니면 쓰레드 속도를 낮줘주자. 다른 작업및 PC효율이 좋아짐
    for i := 0 to gTsWorks.Count - 1 do
    begin
        if gTsWorks.Items[i].IsRun then
        begin
            break;
        end;
    end;

    nIsRun := i < gTsWorks.Count;

    if gSysRunMode <> nIsRun then
    begin
        mThread.Delay := not nIsRun;
        TECManager.GetInstance.Delay := mThread.Delay;
        TDAQManager.GetInstance.Delay := mThread.Delay;
        gLog.ToFiles('Thread Speed :%s', [_THREAD_SPEED[mThread.Delay]]);
        ResetIdleTime;
    end;

    gsysRunMode := not mThread.Delay;
end;

function TWork.GetIo(ACH: integer): boolean;
begin
    Result := gLanDIO.IsIo(ACH);
end;

var
    lpIdleTime: double = 10 * 60 * 1000.0;

function TWork.IsSystemIDLE: boolean;
begin
    Result := Assigned(mThread) and mThread.Delay and ((GetAccurateTime - mSafeTime) > lpIdleTime);
end;

function TWork.IsTesting: boolean;
begin
    Result := (Assigned(gTsWorks) and gTsWorks.IsRun);
end;

procedure TWork.OnUsrRecievedIos(Sender: TObject; AType: integer);
begin
    ResetIdleTime;
end;

procedure TWork.ResetIdleTime;
begin
    mSafeTime := GetAccurateTime;
end;

procedure TWork.ReadIOReqPack(Pack: TPackQnA3E_Ascii);
begin

    with mPLCAddInfos do
    begin
        Pack.DataType := CurItem.mDataType;
        Pack.DeviceName := CurItem.mDevName;
        Pack.BeginAddress := CurItem.mAdd;
        Pack.RwCount := CurItem.mWDLen;
    end;
end;

procedure TWork.ReadIORespPack(Pack: TPackQnA3E_Ascii);
begin
end;

procedure TWork.ReadMessage(var myMsg: TMessage);
begin
    if mIsClose then
        Exit;
    case myMsg.WParam of
        SYS_UPDATES:
            begin
            end;
        SYS_TCP_READ, SYS_TCP_WRITE, SYS_POP_READY:
            begin
                if IsTesting then
                    Exit;
            end;
        SYS_TCP_ERROR: // TCP/IP
            begin
                // _TR('오류발생')
                if not Assigned(gSocketMan.GetUserPort(myMsg.LParamHi, myMsg.LParamLo)) then
                    Exit;

                with TUserPort(gSocketMan.GetUserPort(myMsg.LParamHi, myMsg.LParamLo)) do
                begin
                    SetErrorTxt('TCP/IP오류', 'TCP/IP 오류발생 다음 메시지를 확인하여 조치하십시요', LastError, umtWarning);
                end;
            end;
        SYS_RCV_ERROR: // PLC 무응답 처리.
            begin
                SetErrorTxt('PLC 통신오류', 'PLC 통신 응답이 없습니다', '설비전원 OFF->ON, 그래도 응답이 없을경우 프로그램을 껐다 켜주세요.', umtWarning);
            end;
        SYS_PLC_ERROR: // 에러코드 수신 - 상세한 코드와 처리방법 메시지 처리.
            begin
                // _TR('오류발생')
                if not Assigned(gLanDIO.GetItem(myMsg.LParam)) then
                    Exit;
                with TUserMonitor(gLanDIO.GetItem(myMsg.LParam)) do
                begin
                    // 에러가 발생하거나 제거될때 생김.
                    SetErrorTxt('수신오류발생', 'PLC와PC간 통신오류발생. 다음 메시지를 확인하여 조치하십시요', LastError, umtWarning);
                end;
            end;
        SYS_LAN_PORT_CHANGED:
            begin
                gSocketMan.Reset;
            end;
        SYS_CONNECTED:
            begin
            end;
        SYS_DISCONNECTED:
            begin
                // 포트의 타입을 확인, Read I/O이면 같은 타입이 모두 닫혔는지 확인.
                try
                    IoCloseCheck(myMsg.LParamHi, myMsg.LParamLo);
                except
                    on E: Exception do
                    begin
                        gLog.ToFiles('%s (1001)', [E.Message]);
                    end;
                end;
            end;
        SYS_PORT_END:
            begin
                Reset();
                Exit;
            end;
    end;
    SendToForm(gUsrMsg, myMsg.WParam, myMsg.LParam);
end;

procedure TWork.IoCloseCheck(AIndex, APort: integer);
var
    nPortType: integer;
    nUsrPort: TUserPort;
begin
    nUsrPort := gSocketMan.GetUserPort(AIndex, APort);
    if not Assigned(nUsrPort) then
        Exit;

    nPortType := nUsrPort.GetPortType; // -1 ;
    case nPortType of
        Ord(devREAD):
            begin
                if gSocketMan.IsOpenPort(nPortType) <= 0 then
                begin
                    with TReadIO(gLanDIO.GetItem(nPortType)) do
                    begin
                        IoClear;
                        gLog.Debug('IO CLEAR Index:%d Port Type:%d Port:%x', [AIndex, nPortType, APort]);
                    end;
                end;
            end;
        Ord(devWRITE):
            begin
            end;
    end;
end;

var
    gMdlMask: DWORD;

procedure TWork.CheckModelChange;
var
    TypeBits: DWORD;
    i, MdlNo: integer;
begin

    ResetIdleTime;
    if mIsClose then
        Exit;

    for i := 0 to gTsWorks.Count - 1 do
    begin
        if not gTsWorks.Items[i].IsRun then
        begin
            gLanDIO.GetModelIoAsDWord(i * 3 + 1, TypeBits); // 모델 정보는 PLC 맵상 연속으로 있어야 함.
            MdlNo := gLanDio.GetDataIoAsWord(i * 3);
            gTsWorks.Items[i].CheckModelChange(MdlNo, TypeBits, gMdlMask);
        end;
    end;

end;

procedure TWork.Reset;
begin
//    gDcPower.Stop;
//    gDcPower.Start;
end;

procedure TWork.SetUsrFileUpdates;
var
    sTm: string;
begin
    if IsTesting then
        Exit;
    // Log File 분산처리
    if Assigned(gLog) then
        gLog.Updates();

    Inc(mUsrState);
    mUsrState := mUsrState mod 4;

    case mUsrState of
        0:
            begin
                // 설비에러 파일
                // if Assigned(gErCodeFiles) then gErCodeFiles.SaveToFiles(gsysEnv.rUseDebug) ;
            end;
        1:
            begin
                // 그래프 파일 분산처리
                {
                if Assigned(gKiiDB) then
                begin
                    sTm := GetUsrDir(udRS, Now(), false);
                    if gKiiDB.SaveDir <> sTm then
                    begin
                        gLog.Debug('KiiDB savedir change %s -> %s', [gKiiDB.SaveDir, sTm]);

                        gKiiDB.SaveDir := sTm;
                    end;
                    gKiiDB.SaveToFiles();
                end;
                }
            end;
        2:
            begin
                // 실적데이터 분산처리
                // 2014-06-29 if Assigned(gPallets) then gPallets.SaveToFiles() ;
            end;
        3:
            begin
                // Ini Files 분산처리
                // SaveUsrFiles ;
            end;
    end;
end;

function TWork.GetUsrBuffCounts: string;
begin
    Result := Format('Log: %d grp: %d', [gLog.LogCount, gKiiDB.FileCount()]);
end;

initialization
    gMdlMask := MakeModelMaskForAP;

end.

