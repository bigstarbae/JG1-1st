{
    Ver.230403.00

1. 삭제
    DTC Clear Request   : 04 14 FF FF FF
    DTC Clear Response : 01 54

2. 읽기
    DTC Read Request   : 03 19 02 09
    DTC Read Response : 03 59 02 09, [AA, AA, AA, AA] : 대괄호내 DTC코드

}
unit DTCReader;

interface

uses
    BaseCAN, BaseFSM, TimeChecker;

const
    DTC_CMD_TIMEOUT = 3000;

type
    TDTCCmdStatus = (dcsNone, dcsClear, dcsClearDone, dcsRead, dcsReadDone);

    TDTCReader = class(TBaseFSM)
    private
        mCAN: TBaseCAN;
        mCode: WORD;
        mCmdStatus: TDTCCmdStatus;

        mReqID, mRespID: Cardinal;

        mCurFrame: TCANFrame;

        mTC: TTimeChecker;
        procedure CanRead(Sender: TObject);
        function GetCurFrame: PCANFrame;


    public
        constructor Create(CAN: TBaseCAN; ReqID, RespID: Cardinal);
        destructor Destroy; override;

        procedure InitID(ReqID, RespID: Cardinal);

        function FSMClear: integer;
        function FSMRead: integer;

        property CurFrame: PCANFrame read GetCurFrame;
    end;

implementation

uses
    SysUtils, Log;

{ TDTCReader }

constructor TDTCReader.Create(CAN: TBaseCAN; ReqID, RespID: Cardinal);
begin
    mCAN := CAN;
    mCAN.OnRead.SyncAdd(CanRead);

    mReqID := ReqID;
    mRespID := RespID;
end;

destructor TDTCReader.Destroy;
begin
    mCAN.OnRead.SyncRemove(CanRead);
    inherited;
end;

// ID 초기화 메서드 구현
procedure TDTCReader.InitID(ReqID, RespID: Cardinal);
begin
    mReqID := ReqID;
    mRespID := RespID;

    gLog.Debug('DTC Reader ID 변경 - ReqID: $%X, RespID: $%X', [ReqID, RespID]);
end;

procedure TDTCReader.CanRead(Sender: TObject);
var
    CAN: TBaseCAN;
begin
    CAN := TBaseCAN(Sender);

    if CAN.ID <> mRespID then
        Exit;

    mCurFrame := CAN.RFrame^;

    case mCmdStatus of

        dcsClear:
            begin
                if CAN.Datas[1] = $54 then
                    mCmdStatus := dcsClearDone;
                gLog.Debug('DTC CLEAR: %s', [mCurFrame.ToStr]);
            end;

        dcsRead:
            begin
                if CAN.Compare(1, [$59, $02, $09], 3) then
                begin
                    if CAN.Compare(4, [$AA, $AA, $AA, $AA], 4) then
                        mCmdStatus := dcsReadDone;
                end;
                gLog.Debug('DTC READ: %s', [mCurFrame.ToStr]);
            end;
    end;

end;

function TDTCReader.FSMClear: integer;
begin
    Result := 0;
    case mState of
        0:
            begin
                mCmdStatus := dcsClear;
                mCAN.Write(mReqID, [$04, $14, $FF, $FF, $FF, 00, 00, 00]);
                mTC.Start(DTC_CMD_TIMEOUT);
                IncState;
            end;
        1:
            begin
                if mCmdStatus = dcsClearDone then
                begin
                    mCmdStatus := dcsNone;
                    ClearFSM;
                    Exit(1);
                end;

                if mTC.IsTimeOut() then
                begin
                    mCmdStatus := dcsNone;
                    ClearFSM;
                    Exit(-1);
                end;
            end;
    end;

end;

function TDTCReader.FSMRead: integer;
begin
    Result := 0;
    case mState of
        0:
            begin
                mCmdStatus := dcsRead;
                mCAN.Write(mReqID, [$03, $19, $02, $09, $00, 00, 00, 00]);
                mTC.Start(DTC_CMD_TIMEOUT);
                IncState;
            end;
        1:
            begin
                if mCmdStatus = dcsReadDone then
                begin
                    mCmdStatus := dcsNone;
                    ClearFSM;
                    Exit(1);
                end;

                if mTC.IsTimeOut() then
                begin
                    mCmdStatus := dcsNone;
                    ClearFSM;
                    Exit(-1);
                end;
            end;
    end;
end;

function TDTCReader.GetCurFrame: PCANFrame;
begin
    Result := @mCurFrame;
end;

end.

