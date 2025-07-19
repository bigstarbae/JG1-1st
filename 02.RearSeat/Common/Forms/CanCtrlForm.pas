unit CanCtrlForm;

interface

uses
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, StdCtrls, CANMatrixFrame, ExtCtrls, CheckLst, BaseCan, ComCtrls;

type
    TfrmCanCtrl = class(TForm)
        Panel1: TPanel;
        cfmWFrame: TCanFrameMatrix;
        Label25: TLabel;
        btnSend: TButton;
        edtWID: TEdit;
        edtWInterval: TEdit;
        Panel2: TPanel;
        Label1: TLabel;
        cfmRFrame: TCanFrameMatrix;
        btnAddRAllID: TButton;
        btnRemoveAllRID: TButton;
        edtRID: TEdit;
        lbRFrame: TListBox;
        lblBitOrdV1: TLabel;
        btnRemoveRID: TButton;
        Label2: TLabel;
        Label3: TLabel;
        lbLog: TListBox;
        tmrPoll: TTimer;
        PageControl1: TPageControl;
        TabSheet1: TTabSheet;
        TabSheet2: TTabSheet;
        lbCyWFrame: TListBox;
        btnAddCyWID: TButton;
        btnRemoveCyWID: TButton;
        btnRemoveAllCyWID: TButton;
        lbWFrame: TListBox;
        btnAddWID: TButton;
        btnRemoveWID: TButton;
        btnRemoveAllWID: TButton;
        lblBitOrdH: TLabel;
        cbxWDebugMode: TCheckBox;
        cbxRDebugMode: TCheckBox;
        Panel3: TPanel;
        cbxCanPort: TComboBox;
        Label17: TLabel;
        cbLogSave: TCheckBox;
        procedure FormShow(Sender: TObject);
        procedure FormClose(Sender: TObject; var Action: TCloseAction);
        procedure btnSendClick(Sender: TObject);
        procedure btnAddCyWIDClick(Sender: TObject);
        procedure btnRemoveCyWIDClick(Sender: TObject);
        procedure btnRemoveAllCyWIDClick(Sender: TObject);
        procedure btnAddRAllIDClick(Sender: TObject);
        procedure btnRemoveRIDClick(Sender: TObject);
        procedure lbCyWFrameClick(Sender: TObject);
        procedure lbRFrameClick(Sender: TObject);
        procedure tmrPollTimer(Sender: TObject);
        procedure btnAddWIDClick(Sender: TObject);
        procedure btnRemoveWIDClick(Sender: TObject);
        procedure btnRemoveAllWIDClick(Sender: TObject);
        procedure lbWFrameClick(Sender: TObject);
        procedure lbWFrameDblClick(Sender: TObject);
        procedure cbxWDebugModeClick(Sender: TObject);
        procedure cbxRDebugModeClick(Sender: TObject);
        procedure cbxCanPortChange(Sender: TObject);
        procedure btnRemoveAllRIDClick(Sender: TObject);
        procedure cbLogSaveClick(Sender: TObject);
        procedure FormCreate(Sender: TObject);
    private
    { Private declarations }
        mIsAllRead: boolean;
        mOldLogHandle: HWND;
        mRFrameList: TPCanFrameList;
        mCurRFrmIdx: integer;
        mUpdatingUI: boolean;
        mCan: TBaseCan;
        mTempCAN: TBaseCAN;
        mRemoveFlag: boolean;
        mRemoveAllFlag: boolean;
        mCurWFrame: PCanFrame;

        procedure CanRead(Sender: TObject);
        function IsRIDExists(ID: Cardinal): boolean;
        function FindFrameInStrings(ID: cardinal; Strings: TStrings): PCanFrame; overload;
        function FindFrameInStrings(ID: cardinal; Strings: TStrings; Frame: PCanFrame): integer; overload;
        function FindFrameIdx(ID: cardinal): integer;
        procedure FreeObjects(Strings: TStrings);
        procedure ClearCyWFrame;
        procedure ReadCyWFrameFrom(Can: TBaseCan);

        function LoadWFrames(FilePath: string): boolean;
        function SaveWFrames(FilePath: string): boolean;

    public
    { Public declarations }
        constructor Create(AOwner: TComponent; CAN: TBaseCAN = nil);

        class var
            mIsVisible: boolean;

        procedure SetCan(Can: TBaseCAN);
    end;

var
    frmCanCtrl: TfrmCanCtrl;

implementation

uses
    Log, BaseDAQ, IniFiles, SysEnv, LangTran;


{$R *.dfm}

procedure HorScrollBar(ListBox: TListBox; MaxWidth: Integer);
var
    i, w: Integer;
    dc: HDC;
    size: TSize;
begin
    if MaxWidth = 0 then
        SendMessage(ListBox.Handle, LB_SETHORIZONTALEXTENT, MaxWidth, 0)
    else
    begin
        MaxWidth := 0;
        dc := GetDC(ListBox.Handle);
        try
            // 모든 항목을 순회하며 가장 긴 문자열의 실제 픽셀 너비 계산
            for i := 0 to ListBox.Items.Count - 1 do
            begin
                GetTextExtentPoint32(dc, PChar(ListBox.Items[i]), Length(ListBox.Items[i]), size);
                if size.cx > MaxWidth then
                    MaxWidth := size.cx;
            end;

            // 여유 공간 추가 (스크롤바 버튼 크기 + 여백)
            MaxWidth := MaxWidth + GetSystemMetrics(SM_CXVSCROLL) + 10;

            // 가로 스크롤 범위 설정
            SendMessage(ListBox.Handle, LB_SETHORIZONTALEXTENT, MaxWidth, 0);
        finally
            ReleaseDC(ListBox.Handle, dc);
        end;
    end;
end;

procedure TfrmCanCtrl.FormShow(Sender: TObject);
var
    i: integer;
    FilePath: string;
begin

    if mRFrameList <> nil then
        Exit;        // 언도킹시 FormShow 재호출 중복 생성 방지

    if Assigned(mTempCAN) then
        SetCAN(mTempCAN);

    {   // TO DO : SetCAN내  중복 처리 개선 할 것
    if Assigned(mCan) then
    begin
        FilePath := GetEnvPath('WCanFrames.ini');

        if FileExists(FilePath) then
        begin
            LoadWFrames(FilePath);
        end;
    end;
    }
    mOldLogHandle := gLog.LogHandle;
    gLog.LogHandle := lbLog.Handle;
    gLog.IsWrite := false;

    mIsAllRead := true;

    if gSysEnv.rDevelop.rCanWriteLog then
        cbxWDebugMode.Checked := true
    else
        cbxWDebugMode.Checked := TBaseCAN.mWDebug;

    if gSysEnv.rDevelop.rCanReadLog then
        cbxRDebugMode.Checked := true
    else
        cbxRDebugMode.Checked := TBaseCAN.mRDebug;


    for i := 0 to TBaseCAN.ItemCount - 1 do
    begin
        cbxCanPort.Items.Add('CAN' + IntToStr(i + 1));
    end;

    cbxCanPort.ItemIndex := 0;

    mIsVisible := true;
    tmrPoll.Enabled := true;

    TLangTran.ChangeCaption(self);
end;

procedure TfrmCanCtrl.FormClose(Sender: TObject; var Action: TCloseAction);
var
    i: integer;
    Frame: PCanFrame;
begin

    TBaseCAN.mRDebug := false;//cbxRDebugMode.Checked;
    TBaseCAN.mWDebug := false;//cbxWDebugMode.Checked;

    tmrPoll.Enabled := false;
    mUpdatingUI := true;

    if Assigned(mCan) then
    begin
        mCAN.EnableWFrameList := false;

        mCAN.OnRead.SyncRemove(CanRead);

    end;

    SaveWFrames(GetEnvPath('WCanFrames.ini'));

    gLog.LogHandle := mOldLogHandle;
    gLog.IsWrite := true;

    for i := 0 to mRFrameList.Count - 1 do
    begin
        Dispose(mRFrameList[i]);
    end;

    mRFrameList.Clear;
    mRFrameList.Free;

    for i := 0 to lbWFrame.Count - 1 do
    begin
        Frame := PCanFrame(lbWFrame.Items.Objects[i]);
        Dispose(Frame);
    end;

    lbWFrame.Clear;

    ClearCyWFrame;

    mIsVisible := false;

    Action := caFree;

end;

procedure TfrmCanCtrl.FormCreate(Sender: TObject);
begin

    mRFrameList := TPCANFrameList.Create;
end;

procedure TfrmCanCtrl.ReadCyWFrameFrom(Can: TBaseCan);
var
    i, Count: integer;
    WFrame: PCanFrame;
begin
    Count := Can.WFrameCount;
    for i := 0 to Count - 1 do
    begin
        WFrame := Can.WFrames[i];
        lbCyWFrame.AddItem(WFrame^.ToStr, TObject(WFrame));
    end;

end;

procedure TfrmCanCtrl.ClearCyWFrame;
var
    i: integer;
    Frame: PCanFrame;
begin
    for i := 0 to lbCyWFrame.Count - 1 do
    begin
        Frame := PCanFrame(lbCyWFrame.Items.Objects[i]);
        // UI에서 추가한 것만 제거 필요
        if Frame.mTag = 1 then
            mCan.RemoveWFrame(Frame);
    end;

    lbCyWFrame.Clear;

end;

constructor TfrmCanCtrl.Create(AOwner: TComponent; CAN: TBaseCAN);
begin
    inherited Create(AOwner);

    mTempCAN := CAN;
end;

function TfrmCanCtrl.SaveWFrames(FilePath: string): boolean;
var
    i: integer;
    Frame: PCanFrame;
    IniFile: TIniFile;
begin
    Result := true;

    //if (lbWFrame.Items.Count = 0) and (lbCyWFrame.Items.Count = 0) then Exit;     // FormClose에서 저장할 경우 문제되는 코드(이미 자료구조에서 삭제됨)

    mUpdatingUI := true;

    IniFile := TIniFile.Create(FilePath);

    try
        IniFile.WriteInteger('W.FRAMES', 'COUNT', lbWFrame.Items.Count);
        for i := 0 to lbWFrame.Items.Count - 1 do
        begin
            Frame := PCanFrame(lbWFrame.Items.Objects[i]);
            Result := Frame.Write(IniFile, 'W.FRAMES', IntToStr(i + 1));

            if not Result then
                Exit;
        end;

        IniFile.WriteInteger('CYCLIC.W.FRAMES', 'COUNT', lbCyWFrame.Items.Count);
        for i := 0 to lbCyWFrame.Items.Count - 1 do
        begin
            Frame := PCanFrame(lbCyWFrame.Items.Objects[i]);
            Result := Frame.Write(IniFile, 'CYCLIC.W.FRAMES', IntToStr(i + 1));
            if not Result then
                Exit;
        end;

    finally
        mUpdatingUI := false;
        IniFile.Free;
    end;

end;

procedure TfrmCanCtrl.SetCan(Can: TBaseCAN);
var
    FilePath: string;
begin
    if mCan = Can then
        Exit;

    tmrPoll.Enabled := false;
    mUpdatingUI := true;
    // OnRead.Add 내부적으로 중복 막아주니 이 코드는 필요 없는데.. 검토 필요
    if Assigned(mCan) then
    begin
        mCan.OnRead.SyncRemove(CanRead); // 기존 핸들러 제거,
    end;

    mCan := Can;

    if Assigned(mCan) then
    begin
        FilePath := GetEnvPath('WCanFrames.ini');

        if FileExists(FilePath) then
        begin
            LoadWFrames(FilePath);
        end;
    end;

    mCAN.OnRead.SyncAdd(CanRead);

    ClearCyWFrame;

    ReadCyWFrameFrom(mCan);

    tmrPoll.Enabled := true;
    mUpdatingUI := false;

end;

procedure TfrmCanCtrl.btnAddRAllIDClick(Sender: TObject);
begin
    mIsAllRead := true;
end;

procedure TfrmCanCtrl.btnRemoveRIDClick(Sender: TObject);
var
    Frame: PCanFrame;
begin
    if lbRFrame.Count = 0 then
        Exit;
    mRemoveFlag := true;
    Exit;

    tmrPoll.Enabled := false;

    mIsAllRead := false;

    Dispose(mRFrameList[LbRFrame.ItemIndex]);

    lbRFrame.Items.Delete(lbRFrame.ItemIndex);

    tmrPoll.Enabled := true;
end;

procedure TfrmCanCtrl.btnAddWIDClick(Sender: TObject);
var
    ID: cardinal;
    Datas: array[0..MAX_CAN_DATA_LEN] of byte;
    WFrame: PCanFrame;
begin
    if edtWID.Text = '' then
        Exit;

    ID := StrToInt('$' + edtWID.Text);
    cfmWFrame.GetDatas(Datas);
    WFrame := new(PCANFrame);
    WFrame^ := TCANFrame.Create(ID, Datas, MAX_CAN_DATA_LEN);
    lbWFrame.AddItem(WFrame^.ToStr, TObject(WFrame));

    HorScrollBar(lbWFrame, 100);
end;

procedure TfrmCanCtrl.btnRemoveWIDClick(Sender: TObject);
var
    Frame: PCanFrame;
begin
    if (lbWFrame.Count = 0) or (lbWFrame.ItemIndex < 0) then
        Exit;

    Frame := PCanFrame(lbWFrame.Items.Objects[lbWFrame.ItemIndex]);

    Dispose(Frame);

    lbWFrame.Items.Delete(lbWFrame.ItemIndex);

end;

procedure TfrmCanCtrl.btnAddCyWIDClick(Sender: TObject);
var
    ID: cardinal;
    Datas: array[0..7] of byte;
    WFrame: PCanFrame;
begin
    if edtWID.Text = '' then
        Exit;

    ID := StrToInt('$' + edtWID.Text);
    cfmWFrame.GetDatas(Datas);
    WFrame := mCan.AddWFrame(ID, Datas, StrToInt(edtWInterval.Text));
    WFrame.mTag := 1;
    lbCyWFrame.AddItem(WFrame^.ToStr, TObject(WFrame));
end;

procedure TfrmCanCtrl.btnRemoveCyWIDClick(Sender: TObject);
var
    Frame: PCanFrame;
begin
    if (lbCyWFrame.Count = 0) or (lbCyWFrame.ItemIndex < 0) then
        Exit;

    Frame := PCanFrame(lbCyWFrame.Items.Objects[lbCyWFrame.ItemIndex]);

    mCan.RemoveWFrame(Frame);

    lbCyWFrame.Items.Delete(lbCyWFrame.ItemIndex);
end;

procedure TfrmCanCtrl.btnRemoveAllCyWIDClick(Sender: TObject);
var
    i: Integer;
    Frame: PCanFrame;
begin
//
    for i := 0 to lbCyWFrame.Count - 1 do
    begin
        Frame := PCanFrame(lbCyWFrame.Items.Objects[i]);
        mCan.RemoveWFrame(Frame);
    end;

    lbCyWFrame.Clear;
end;

procedure TfrmCanCtrl.btnRemoveAllRIDClick(Sender: TObject);
var
    i: integer;
begin
    tmrPoll.Enabled := false;
    mIsAllRead := false;

    for i := 0 to mRFrameList.Count - 1 do
    begin
        Dispose(mRFrameList[i]);
    end;

    mRFrameList.Clear;
    lbRFrame.Clear;

    tmrPoll.Enabled := true;

end;

procedure TfrmCanCtrl.btnRemoveAllWIDClick(Sender: TObject);
var
    i: Integer;
    Frame: PCanFrame;
begin
    for i := 0 to lbWFrame.Count - 1 do
    begin
        Frame := PCanFrame(lbWFrame.Items.Objects[i]);
        Dispose(Frame);
    end;

    lbWFrame.Items.Clear;
end;

procedure TfrmCanCtrl.btnSendClick(Sender: TObject);
begin

    if mCurWFrame = nil then
        Exit;

    mCan.Write(mCurWFrame^);

end;

function TfrmCanCtrl.IsRIDExists(ID: Cardinal): boolean;
var
    i: integer;
begin
    for i := 0 to lbRFrame.Count - 1 do
    begin
        if PCanFrame(lbRFrame.Items.Objects[i])^.mID = ID then
        begin

            Exit(true);
        end;
    end;

    Result := false;
end;

procedure TfrmCanCtrl.lbCyWFrameClick(Sender: TObject);
var
    Frame: PCanFrame;
begin
    if (lbCyWFrame.Count = 0) or (lbCyWFrame.ItemIndex < 0) then
        Exit;

    Frame := PCanFrame(lbCyWFrame.Items.Objects[lbCyWFrame.ItemIndex]);

    cfmWFrame.SetDatas(Frame.mData);
    edtWID.Text := IntToHex(Frame.mID, 3);
end;

procedure TfrmCanCtrl.tmrPollTimer(Sender: TObject);
var
    Diff, i: integer;
    Frame: PCanFrame;
begin
    if (mRFrameList.Count = 0) then
        Exit;

    if lbRFrame.Count < mRFrameList.Count then
    begin
        mUpdatingUI := true;
        Diff := mRFrameList.Count - lbRFrame.Count;
        for i := 0 to Diff - 1 do
        begin
            lbRFrame.Items.Add('--');
        end;
        mUpdatingUI := false;

    end;

    mUpdatingUI := true;
    for i := 0 to lbRFrame.Count - 1 do     // 전체 갱신
    begin
        lbRFrame.Items[i] := mRFrameList[i].ToStr;
    end;

    if lbRFrame.ItemIndex >= 0 then
    begin
        Frame := mRFrameList[lbRFrame.ItemIndex];
        cfmRFrame.SetDatas(Frame.mData);
    end;

    mUpdatingUI := false;

    {
    if (mCurRFrmIdx >= 0) and (mCurRFrmIdx < lbRFrame.Count) then
    begin
        mUpdatingUI := true;                                // 부분 갱신
        lbRFrame.Items.Strings[mCurRFrmIdx] := mRFrameList[mCurRFrmIdx].ToStr;
        mUpdatingUI := false;
    end;
    }
end;

procedure TfrmCanCtrl.lbRFrameClick(Sender: TObject);
var
    Frame: PCanFrame;
begin
    if (lbRFrame.Count = 0) or (lbRFrame.ItemIndex < 0) then
        Exit;

    Frame := mRFrameList[lbRFrame.ItemIndex];

    lbRFrame.Items.Strings[lbRFrame.ItemIndex] := Frame.ToStr;

    cfmRFrame.SetDatas(Frame.mData);

    edtRID.Text := IntToHex(Frame.mID, 3);

end;

procedure TfrmCanCtrl.lbWFrameClick(Sender: TObject);
begin
    if (lbWFrame.Count = 0) or (lbWFrame.ItemIndex < 0) then
        Exit;

    mCurWFrame := PCanFrame(lbWFrame.Items.Objects[lbWFrame.ItemIndex]);

    cfmWFrame.SetDatas(mCurWFrame.mData);
    edtWID.Text := IntToHex(mCurWFrame.mID, 3);
end;

procedure TfrmCanCtrl.lbWFrameDblClick(Sender: TObject);
begin

    btnSend.Click;

end;

function TfrmCanCtrl.LoadWFrames(FilePath: string): boolean;
var
    i, Count: integer;
    Frame: PCanFrame;
    IniFile: TIniFile;
    WFrame: PCANFrame;
begin
    Result := true;

    mUpdatingUI := true;

    IniFile := TIniFile.Create(FilePath);

    try
        lbWFrame.Items.Clear;
        Count := IniFile.ReadInteger('W.FRAMES', 'COUNT', 0);
        for i := 0 to Count - 1 do
        begin
            WFrame := new(PCANFrame);
            WFrame^.Read(IniFile, 'W.FRAMES', IntToStr(i + 1));
            lbWFrame.AddItem(WFrame^.ToStr, TObject(WFrame));
        end;

        HorScrollBar(lbWFrame, 100);

        {   // 폼종료후에도 계속 호출될 가능성 있기에 일단 주석 처리, 이후 폼에서 등록된 메시지만 삭제 하도록 수정 할 것
        lbCyWFrame.Items.Clear;
        Count := IniFile.ReadInteger('CYCLIC.W.FRAMES', 'COUNT', 0);
        for i := 0 to Count - 1 do
        begin
            WFrame := new(PCANFrame);
            WFrame^.Read(IniFile, 'CYCLIC.W.FRAMES', IntToStr(i + 1));
            mCan.AddWFrame(WFrame);
            lbCyWFrame.AddItem(WFrame^.ToStr, TObject(WFrame));

        end;
        }

    finally
        mUpdatingUI := false;
        IniFile.Free;
    end;
end;

procedure TfrmCanCtrl.FreeObjects(Strings: TStrings);
var
    i: integer;
begin
    for i := 0 to Strings.Count - 1 do
    begin
        if Strings.Objects[i] <> nil then
        begin
            Dispose(PCanFrame(Strings.Objects[i]));
        end;

    end;
end;

function TfrmCanCtrl.FindFrameInStrings(ID: cardinal; Strings: TStrings): PCanFrame;
var
    i: integer;
begin
    for i := 0 to Strings.Count - 1 do
    begin
        if PCanFrame(Strings.Objects[i])^.mID = ID then
        begin
            Exit(PCanFrame(Strings.Objects[i]));
        end;
    end;

    Result := nil;
end;

function TfrmCanCtrl.FindFrameIdx(ID: cardinal): integer;
var
    i: integer;
begin
    Result := -1;

    if mRFrameList = nil then
        Exit;

    for i := 0 to mRFrameList.Count - 1 do
    begin
        if mRFrameList[i].mID = ID then
            Exit(i);
    end;

end;

function TfrmCanCtrl.FindFrameInStrings(ID: cardinal; Strings: TStrings; Frame: PCanFrame): integer;
var
    i: integer;
begin
    for i := 0 to Strings.Count - 1 do
    begin
        if PCanFrame(Strings.Objects[i])^.mID = ID then
        begin
            Frame := PCanFrame(Strings.Objects[i]);
            Exit(i);
        end;
    end;

    Result := -1;
end;

procedure TfrmCanCtrl.CanRead(Sender: TObject);
var
    i, Idx: integer;
    Str: string;
    Frame: PCanFrame;
begin

    if not tmrPoll.Enabled or mUpdatingUI then
        Exit;

    with Sender as TBaseCan do
    begin
        if mRemoveFlag then
        begin
            mRemoveFlag := false;
            tmrPoll.Enabled := false;
            Frame := mRFrameList[LbRFrame.ItemIndex];
            mRFrameList.Remove(Frame);
            Dispose(Frame);
            lbRFrame.Items.Delete(lbRFrame.ItemIndex);
            tmrPoll.Enabled := true;
            Exit;
        end;

        Idx := FindFrameIdx(ID);
        if (Idx < 0) and mIsAllRead then
        begin
            Frame := new(PCANFrame);
            Frame^.Clear;
            Read(Frame^);

            mRFrameList.Add(Frame);
            mCurRFrmIdx := mRFrameList.Count - 1;
        end
        else if Idx >= 0 then
        begin
            Read(mRFrameList[Idx]^);
            mCurRFrmIdx := Idx;
        end;

    end;

end;

procedure TfrmCanCtrl.cbLogSaveClick(Sender: TObject);
begin
    gLog.IsWrite := cbLogSave.Checked;
end;

procedure TfrmCanCtrl.cbxCanPortChange(Sender: TObject);
begin
//
    if TDAQManager.GetInstance.Count > 0 then       // TECManager  사용할 수도 있으니
        TDAQManager.GetInstance.Stop;

    SetCan(TBaseCAN.Items[cbxCanPort.ItemIndex]);

    if TDAQManager.GetInstance.Count > 0 then
        TDAQManager.GetInstance.Start;
end;

procedure TfrmCanCtrl.cbxRDebugModeClick(Sender: TObject);
begin
    TBaseCAN.mRDebug := cbxRDebugMode.Checked;
end;

procedure TfrmCanCtrl.cbxWDebugModeClick(Sender: TObject);
begin
    TBaseCAN.mWDebug := cbxWDebugMode.Checked;
end;

end.

