unit BaseTsWork;

interface

uses  
    Windows, Generics.Collections, KIIMessages, BaseFSM, ComCtrls;

type
    THandleList = TList<HWND>;

    TBaseTsWork = class(TBaseFSM)
    protected
        mStationID: integer;


        mIsModelChange: boolean;

        mLstError: string;
        mLstToDo: string;

        mLogHandle: HWND;
        mHList: THandleList;

        mOnRunEvent: TNotifyRun;
        mOnStatus: TNotifyStatus;


        function GetName: string; override;
        function GetTypeBits: DWORD; virtual;

        procedure SetMainCurrZero; virtual; abstract;

    public
        constructor Create;
        destructor Destroy; override;

        procedure Initial(IsLoad: boolean); virtual; abstract;

        procedure SetLogHandle(const aHandle: HWND);

        procedure CheckModelChange(ATypeBits, Mask: DWORD); overload; virtual;
        procedure CheckModelChange(ID: integer; ATypeBits, Mask: DWORD); overload; virtual;
        procedure CheckModelChange(ModelNo: integer);  overload; virtual;

        procedure ReloadModelBits; virtual;

        function IsSpecChkOK: Boolean; virtual;


        function IsStartChOn: boolean; virtual; abstract;
        function IsRun: boolean; virtual; abstract;

        procedure Start; virtual; abstract;
        procedure Stop(IsForce: boolean = false); virtual; abstract;

        procedure WorkProcess(); virtual; abstract;
        procedure ShowProcState; virtual;

        procedure Write(TV: TTreeView); virtual;

        procedure SetError(ErrorMsg, ErrorToDo: string); virtual;
        procedure LinkNext(TsWork: TBaseTsWork); virtual;



        // 메시지 처리
        procedure AddHandle(Handle: HWND);
        procedure RemoveHandle(Handle: HWND);
        procedure UpdateForms(Status: integer = 0; IsPost: boolean = true);
        procedure SendMessageEx(Msg, Param1, Param2: integer; IsPost: boolean = true);

        property Name: string read GetName;

        property TypeBits: DWORD read GetTypeBits;
        property IsModelChange: boolean read mIsModelChange write mIsModelChange;

        property ErrorMsg: string read mLstError;
        property ErrorToDo: string read mLstToDo;

        property OnRun: TNotifyRun read mOnRunEvent write mOnRunEvent;
        property OnStatus: TNotifyStatus read mOnStatus write mOnStatus;

        property LogHandle: HWND read mLogHandle write SetLogHandle;
    end;

    TTsWorkList = TList<TBaseTsWork>;

    TTsWorks = class
    private
        mReady: boolean;
        mItems: TTsWorkList;

        function GetItem(Index: integer): TBaseTsWork;

    public
        constructor Create;
        destructor Destroy; override;

        procedure Start;
        procedure Stop;
        function  IsRun: boolean;
        procedure AddItem(Item: TBaseTsWork);

        function Count: integer;

        procedure WorkProcess(Sender: TObject);

        property Items[Index: integer]: TBaseTsWork read GetItem; default;
    end;

var
    gTsWorks: TTsWorks;

implementation

uses
    Log, Work, SysUtils, LangTran;

{ TBaseTsWork }

procedure TBaseTsWork.CheckModelChange(ModelNo: integer);
begin
    raise Exception.Create(_TR('CheckModelChange(ModelNo: integer) 구현이 안 됨'));
end;

procedure TBaseTsWork.CheckModelChange(ATypeBits, Mask: DWORD);
begin
    raise Exception.Create(_TR('CheckModelChange(ATypeBits, Mask: DWORD) 구현이 안 됨'));
end;

procedure TBaseTsWork.ReloadModelBits;
begin

end;

procedure TBaseTsWork.AddHandle(Handle: HWND);
begin
    if mHList.IndexOf(Handle) < 0 then
        mHList.Add(Handle);
end;

procedure TBaseTsWork.RemoveHandle(Handle: HWND);
begin
    if mHList.IndexOf(Handle) < 0 then
        mHList.Add(Handle);
end;

procedure TBaseTsWork.CheckModelChange(ID: integer; ATypeBits, Mask: DWORD);
begin
    raise Exception.Create(_TR('CheckModelChange(ID: integer; ATypeBits, Mask: DWORD) 구현이 안 됨'));
end;

constructor TBaseTsWork.Create;
begin
    mHList := THandleList.Create;
end;

destructor TBaseTsWork.Destroy;
begin
    mHList.Free;
end;

function TBaseTsWork.GetName: string;
begin
    Result := 'No.Name TsWork';
end;


function TBaseTsWork.GetTypeBits: DWORD;
begin
    Result := 0;
end;

function TBaseTsWork.IsSpecChkOK: Boolean;
begin
    Result := False;
end;

procedure TBaseTsWork.LinkNext(TsWork: TBaseTsWork);
begin

end;

procedure TBaseTsWork.SetError(ErrorMsg, ErrorToDo: string);
begin

end;

procedure TBaseTsWork.SetLogHandle(const aHandle: HWND);
begin
    mLogHandle := aHandle;
end;

procedure TBaseTsWork.ShowProcState;
begin
    gLog.Panel('TBaseTsWork.ShowProcState:구현 안됨');
end;

procedure TBaseTsWork.UpdateForms(Status: integer; IsPost: boolean);
begin
    SendMessageEx(WM_SYS_CODE, SYS_TS_PROCESS, mStationID shl 16 or BYTE(Status), IsPost);
end;

procedure TBaseTsWork.SendMessageEx(Msg, Param1, Param2: integer; IsPost: boolean);
var
    i: integer;
begin
    for i := 0 to mHList.Count - 1 do
    begin
        if IsPost then
            PostMessage(mHList[i], Msg, Param1, Param2)
        else
            SendMessage(mHList[i], Msg, Param1, Param2);
    end;
end;

procedure TBaseTsWork.Write(TV: TTreeView);
var
    RootNode: TTreeNode;
begin
    TV.Items.Clear;

    RootNode := TV.Items.AddObject(nil, Name, Self);

    RootNode.Expand(true);

end;

{ TTsWorks }

constructor TTsWorks.Create;
begin
    gLog.ToFiles('TSWORKS CREATE', []);
    mReady := false;

    mItems := TTsWorkList.Create;
end;

destructor TTsWorks.Destroy;
var
    i: integer;
begin

    for i := 0 to mItems.Count - 1 do
    begin
        mItems[i].Free;
    end;

    mItems.Free;

    inherited;
    gLog.ToFiles('TSWORKS DESTROY', []);
end;

function TTsWorks.Count: integer;
begin
    Result := mItems.Count;
end;

procedure TTsWorks.AddItem(Item: TBaseTsWork);
begin
    mItems.Add(Item);
end;

function TTsWorks.GetItem(Index: integer): TBaseTsWork;
begin
    if Index < Count then
        Result := mItems[Index]
    else
        Result := nil;
end;

function TTsWorks.IsRun: boolean;
var
    i: integer;
begin
    for i := 0 to mItems.Count - 1 do
        if mItems[i].IsRun then
            Exit(true);

    Result := false;
end;

procedure TTsWorks.Start;
var
    i: integer;

begin
    if mReady then
        Exit;
    mReady := true;

    for i := 0 to mItems.Count - 1 do
    begin
        mItems[i].Initial(false);
        mItems[i].SetMainCurrZero;
    end;

    gLog.ToFiles('TSWORK START', []);
end;

procedure TTsWorks.Stop;
var
    i: integer;
begin
    if not mReady then
        Exit;
    mReady := false;

    for i := 0 to mItems.Count - 1 do
    begin
        mItems[i].Stop(true);
    end;

    gLog.ToFiles('TSWORK STOP', []);
end;

procedure TTsWorks.WorkProcess(Sender: TObject);
var
    i: integer;
begin
    if not mReady then
        Exit;

    for i := 0 to mItems.Count - 1 do
    begin
        with mItems[i] do
        begin
            if IsStartChOn <> IsRun then
            begin
                if IsStartChOn then
                begin
                    TWork(Sender).Thread.Delay := false;
                    Start
                end
                else
                begin
                    Stop;

                    if not IsRun then
                        TWork(Sender).Thread.Delay := true;
                end;

            end;
        end; // with
        mItems[i].WorkProcess();
    end;
end;

end.
