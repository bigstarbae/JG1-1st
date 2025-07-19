{
    221208:   TBaseComm interface ����
}
unit ComUnit;

interface
uses
  Windows, SysUtils, Classes, Dialogs, UserComLibEx, KiiMessages, DataUnit, BaseComm ;

const
    _NORMAL = 0 ;
    _PORT_ERROR = 1 ;
    _FORMAT_ERROR = 2 ;
    _NOT_RESPONSE = 3 ;
    _INT_ERROR    = 4 ; //Code Error
    _EXT_ERROR    = 5 ; //����� ���°� READY�� �ƴҶ�

type
{
    COM Port ����Ʈ�� ����(����)
    TCOMs �ʱ⿡�� �ý����� ��� ��Ʈ ����Ʈ�� ������ �ְ� �� �� ���ϴ���
    ����Ʈ�� ������ ����. ȣ����?f�� nil ������ �װ� ȣ���ڰ� �˾Ƽ� å������.
    Open / Close�� ���⼭�� �ȵǰ� ������ ȣ���ڰ� �Ѵ�.
    ��, ��Ʈ���� ����ÿ��� ���⼱ �Ѵ�.
}
TNotifyDevCom = procedure (Sender:TObject; ADatas: string)of Object ;
TDevCom = class(TBaseComm)
private
    mpCom : TCom ;
    mPort : integer ;
    mDevID: TDevComORD ;
    mLock : boolean ;
public
    constructor Create(ADevComID:TDevComORD; ACom: TComInfo) ;
    destructor  Destroy ; override ;

    function  Open : boolean ; override;
    procedure Close ; override;

    function  IsOpen : boolean ; override;
    procedure SetCom(ACom: TComInfo) ;

    function  IsInQueue: integer; override;
    function  GetInQue : integer ;
    function  GetOutQue: integer ;
    procedure ClearQue(InQue, OutQue: boolean) ;
    procedure ClearToSend(bFlag : Boolean);
    procedure SetDTR(Enable:boolean) ;


    function  Read(var AData; Count:integer): integer ;
    function  Write(const AData; Count:integer):boolean ;


    procedure Clear; override;

    function Writes(Buffer: Pointer; Len: integer): integer; override;
    function Reads(Buffer: Pointer; Len: integer): integer; override;

    function WriteStr(Str: AnsiString): integer; override;
    function ReadStr(ReadLen: integer): AnsiString; override;

    property Lock : boolean read mLock write mLock ;
    property DevID: TDevComORD read mDevID ;
    property Port : integer read mPort ;
end ;

TDevComs = class(TComs)
private
    mHandle : HWND ;
    mProc   : integer ;
    mDevCom : array[TDevComORD] of TDevCom ;

    function Load : boolean ;
public
    constructor Create(const AHWnd:HWND) ;
    destructor  Destroy ; override ;

    procedure Updates ;
    function  GetDevCom(ADevComID: TDevComORD): TDevCom ;
    function  GetMsgHandle : HWND ;

    procedure WorkProcess(Sender:TObject) ;
end ;
TDevComInfo = packed record
    rDevComID : TDevComORD ;
    rAPort    : integer ;
end ;

    function  GetDevComInfo(ADevComID: TDevComORD): TDevComInfo ;
    procedure SetDevComInfo(AComInfo:TDevComInfo) ;

var
    gDevComs : TDevComs ;

implementation
uses
    IniFiles, Log, myUtils, NotifyForm, Messages , RS232, LangTran;

//------------------------------------------------------------------------------
{ Utilify }
//------------------------------------------------------------------------------
function  GetDevComInfo(ADevComID: TDevComORD): TDevComInfo ;
var
    Ini : TIniFile ;
    sTm : string ;
begin
    sTm := Format('%s\DevComs.env', [GetUsrDir(udENV, Now, true)]) ;
    Ini := TIniFile.Create(sTm);
    try
        Result.rDevComID := ADevComID ;
        sTm := GetDevComName(ADevComID) ;
        Result.rAPort := Ini.ReadInteger(sTm, _TR('_�����Ʈ'), ord(ADevComID)+1) ;
        if not Ini.SectionExists(sTm) then
            Ini.WriteInteger(sTm, _TR('_�����Ʈ'), Result.rAPort) ;
    finally
        Ini.Free ;
    end ;
end ;

procedure SetDevComInfo(AComInfo:TDevComInfo) ;
var
    Ini : TIniFile ;
    sTm : string ;
begin
    sTm := Format('%s\DevComs.env', [GetUsrDir(udENV, Now, true)]) ;
    Ini := TIniFile.Create(sTm);
    try
        sTm := GetDevComName(AComInfo.rDevComID) ;
        Ini.WriteInteger(sTm, _TR('_�����Ʈ'), AComInfo.rAPort) ;
    finally
        Ini.Free ;
    end ;
end ;

{ TDevComs }

constructor TDevComs.Create(const AHWnd:HWND);
begin
    mHandle := AHWnd ;
    inherited Create(mHandle) ;
    Load ;
    mProc := 0 ;
end;

destructor TDevComs.Destroy;
var
    i : TDevComORD ;
begin
    for i := Low(TDevComORD) to High(TDevComORD) do
    begin
        if Assigned(mDevCom[i]) then FreeAndNil(mDevCom[i]) ;
    end ;
    inherited Destroy ;
end;

function TDevComs.GetDevCom(ADevComID: TDevComORD): TDevCom;
var
    i : TDevComORD ;
begin
    Result := nil ;
    for i := Low(TDevComORD) to High(TDevComORD) do
    begin
        if Assigned(mDevCom[i]) then
            with mDevCom[i] do
            begin
                if DevID = ADevComID then
                begin
                    Result := mDevCom[i] ;
                    Break ;
                end ;
            end ;
    end ;
end;

function TDevComs.GetMsgHandle: HWND;
begin
    Result := mHandle ;
end;

function TDevComs.Load : boolean ;
var
    sTm : string ;
    i : TDevComORD ;
    Buff : TDevComInfo ;
begin
    Result := false ;
    for i := Low(TDevComORD) to High(TDevComORD) do
    begin
        if Assigned(mDevCom[i])
            and mDevCom[i].Lock then Exit ;
    end ;
    Result := true ;
    for i := Low(TDevComORD) to High(TDevComORD) do
    begin
        Buff := GetDevComInfo(i) ;
        if not Assigned(mDevCom[i]) then
        begin
            mDevCom[i] := TDevCom.Create(i, GetComInfo(Buff.rAPort)) ;
            gLog.ToFiles('%s ����̽� ��Ʈ�Ҵ� -> COM%d',
                        [GetDevComName(i), mDevCom[i].Port]) ;
        end
        else if (mDevCom[i].Port = Buff.rAPort) then
        begin
            Continue
        end
        else if mDevCom[i].Lock then
        begin
            Result := false ;
            Continue ;
        end
        else
        begin
            mDevCom[i].Lock := true ;
            sTm := Format(_TR('%s ����̽� ��Ʈ���� COM%d -> '),
                          [GetDevComName(i), mDevCom[i].Port]) ;

            //mDevCom[i].Close ;
            mDevCom[i].SetCom(GetComInfo(Buff.rAPort));

            gLog.Panel('%s -> COM%d',
                        [sTm, mDevCom[i].Port]) ;
            mDevCom[i].Lock := false ;
        end ;
    end ;
end;

procedure TDevComs.Updates ;
begin
    if mProc = 0 then Inc(mProc) ;
end ;

procedure TDevComs.WorkProcess(Sender: TObject);
var
    i   : TDevComORD ;
    Cnt : integer ;
begin
    case mProc of
        0 : ; //IDLE
        1 :
        begin
            {
            frmNotify.Caption := _TR('����̽� ��Ʈ���� �۾���...') ;
            frmNotify.SetFrm(_TR('����̽� ��Ʈ���� �۾� ��...'));
            frmNotify.Show ;
            }
            gMsgData.Init(_TR('����̽� ��Ʈ ���� �۾���..'),  _TR('����̽� ��Ʈ���� �۾� ��...'));
            SendToForm(gUsrMsg, SYS_MSG_NOTIFY, 0);

            gLog.Panel('����̽� ��Ʈ���� �۾� ����') ;
            Inc(mProc) ;
        end ;
        2 :
        begin
            if Load then Inc(mProc) ;
        end ;
        3 :
        begin
            Cnt := 0 ;
            for i := Low(TDevComORD) to High(TDevComORD) do
            begin
                if mDevCom[i].Lock then Continue
                else
                begin
                    SetUpdates(mDevCom[i].Port) ;
                    Inc(Cnt) ;
                end ;
            end ;
            if Cnt = (ord(High(TDevComORD))+1) then Inc(mProc) ;
        end ;
        4 :
        begin
            for i := Low(TDevComORD) to High(TDevComORD) do
            begin
                SendToForm(mHandle,
                           SYS_USERCOM,
                           (ord(mDevCom[i].DevID )shl (sizeof(WORD) * 8)) or BYTE(mDevCom[i].Port)) ;
            end ;
            SendToForm(mHandle, SYS_PORT_END, 0) ;
            SendMessage(frmNotify.Handle, WM_CLOSE, 0, 0) ;
            gLog.Panel('����̽� ��Ʈ���� �۾� �Ϸ�') ;
            mProc := 0 ;
        end ;
    else
        mProc := 2 ;
    end ;
end;

{ TDevCom }

constructor TDevCom.Create(ADevComID:TDevComORD; ACom: TComInfo);
begin
    mDevID := ADevComID ;
    mLock  := false ;
    SetCom(ACom) ;
end;

destructor TDevCom.Destroy;
begin
    Close ;
end;

procedure TDevCom.Clear;
begin
    ClearQue(true, true);
end;

procedure TDevCom.ClearQue(InQue, OutQue: boolean);
begin
    if not Assigned(mpCom) then Exit ;
    mpCom.ClearBuff(InQue, OutQue);
end;

procedure TDevCom.Close;
begin
    if not Assigned(mpCom) then Exit ;
    mpCom.Close ;
end;

function TDevCom.GetInQue: integer;
begin
    Result := 0 ;
    if not Assigned(mpCom) then Exit ;
    Result := mpCom.GetInQue ;
end;

function  TDevCom.GetOutQue: integer ;
begin
    Result := 0 ;
    if not Assigned(mpCom) then Exit ;
    Result := mpCom.GetOutQue ;
end ;

function TDevCom.IsInQueue: integer;
begin
    Result := GetInQue;
end;

function TDevCom.IsOpen: boolean;
begin
    Result := Assigned(mpCom) and mpCom.IsOpen ;
end;

function TDevCom.Open: boolean;
begin
    Result := false ;
    if not Assigned(mpCom) then Exit ;
    Result := mpCom.Open ;
end;

function TDevCom.Read(var AData; Count:integer): integer;
begin
    Result := 0 ;
    if not Assigned(mpCom) then Exit ;

    Result := mpCom.ComNRead(AData, Count, Result) ;
end;

function TDevCom.Reads(Buffer: Pointer; Len: integer): integer;
var
    RetLen: DWORD;
begin
    RetLen := 0;

    if IsOpen then
        ReadFile(mpCom.MsgHandle, Buffer, Len, RetLen, nil);

    Result := RetLen;

end;

function TDevCom.ReadStr(ReadLen: integer): AnsiString;
var
    RetLen: integer;
begin
    if IsOpen then
    begin
        SetLength(Result, ReadLen);
        mpCom.ComNRead(Result[1], ReadLen, RetLen);
    end;

end;

procedure TDevCom.SetCom(ACom: TComInfo);
begin
    Close ;
    mPort := ACom.rComIDx ;
    mpCom := ACom.rpCom ;
    if Assigned(mpCom) then
        SendToForm(mpCom.MsgHandle, SYS_USERCOM, (ord(mDevID) shl (sizeof(WORD)*8)) or BYTE(mPort)) ;
end;

function TDevCom.Write(const AData; Count: integer): boolean ;
begin
    Result := false ;
    if not Assigned(mpCom) then Exit ;
    Result := mpCom.ComWrites(AData, Count) = Count ;
end;

function TDevCom.Writes(Buffer: Pointer; Len: integer): integer;
var
    RetLen: DWORD;
begin
    RetLen := 0;

    if IsOpen then
        WriteFile(mpCom.MsgHandle, Buffer^, Len, RetLen, nil);

    Result := RetLen;

end;

function TDevCom.WriteStr(Str: AnsiString): integer;
begin
    Result := 0;

    if IsOpen then
        Result := mpCom.ComWrites(Str[1], Length(Str));

end;

procedure TDevCom.ClearToSend(bFlag: Boolean);
begin
    if not Assigned(mpCom) then Exit ;
    mpCom.ClearToSend(bFlag);
end;

procedure TDevCom.SetDTR(Enable: boolean);
begin
    if not Assigned(mpCom) then Exit ;
    mpCom.SetDTREx(not Enable);
end;

end.

