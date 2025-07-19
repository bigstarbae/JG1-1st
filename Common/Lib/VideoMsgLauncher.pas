unit VideoMsgLauncher;

interface


 // Ex>   ShowVideoMsgEX('<Font Size="15" Color="Red"><b>Hi Msgaaaaaaa한글테스트입니다.</b></Font>', 'D:\Project\MyWork\VideoMsgProject\Media\1.mp4');

procedure ShowVideoMsg(Text, FilePath: string; FontSize: integer = 18);
procedure CloseVideoMsg;
procedure SetCaption(Caption: string);



implementation
uses
    Windows, ShellAPI, SysUtils, Messages, AsyncCalls, Dialogs;


const
    MAX_TRIES = 10;
    DELAY = 100;
    VIDEO_MSG_WINDOW_CLASS = 'TfrmVideoMsg';
    EXE_FILE = 'VideoMsgForm.exe';


procedure FindWindowUntilVisible(var TargetHandle: HWND; ClassName: PWideChar);
var
    Tries: integer;
begin
    Tries := 0;
    TargetHandle := 0;
    while (Tries < MAX_TRIES) and (TargetHandle = 0) do
    begin
        TargetHandle := FindWindow(ClassName, nil);
        if TargetHandle = 0 then
        begin
            Inc(Tries);
            Sleep(DELAY);
        end;
    end;
end;


procedure MoveWindowToCenter(TargetHandle, ParentHandle: HWND);
var
    TargetRect, ActiveWindowRect: TRect;
    CenterX, CenterY: integer;
    TargetWidth, TargetMsgHeight: integer;
begin
    if (TargetHandle <> 0) and (ParentHandle <> 0) then
    begin
        GetWindowRect(TargetHandle, TargetRect);
        GetWindowRect(ParentHandle, ActiveWindowRect);

        TargetWidth := TargetRect.Right - TargetRect.Left;
        TargetMsgHeight := TargetRect.Bottom - TargetRect.Top;

        CenterX := (ActiveWindowRect.Left + ActiveWindowRect.Right) div 2 - TargetWidth div 2;
        CenterY := (ActiveWindowRect.Top + ActiveWindowRect.Bottom) div 2 - TargetMsgHeight div 2;

        SetWindowPos(TargetHandle, 0, CenterX, CenterY, 0, 0, SWP_NOZORDER or SWP_NOSIZE);
    end;
end;

function IsWindowVisible(const ClassName: string): boolean;
begin
    Result := FindWindow(PChar(ClassName), nil) <> 0;
end;



procedure AsyncMoveWindowToCenter;
var
    VMsgHandle, ParentHandle: HWND;
begin
    ParentHandle := GetActiveWindow;  // 동일 스레드 내에서만 정상 작동함.

    TAsyncCalls.Invoke(
        procedure
        begin
            FindWindowUntilVisible(VMsgHandle, VIDEO_MSG_WINDOW_CLASS);

            if VMsgHandle <> 0 then
                MoveWindowToCenter(VMsgHandle, ParentHandle);
        end
    ).Forget;

end;

procedure ShowVideoMsg(Text, FilePath: string; FontSize: integer);
    function GetPosFilePath: string;
    begin
        Result := ExtractFilePath(ParamStr(0)) + 'VWndPos.ini';
    end;
begin
    if IsWindowVisible(VIDEO_MSG_WINDOW_CLASS) then
    begin
        CloseVideoMsg;
    end;

    ShellExecute(0, 'open', PChar(ExtractFilePath(ParamStr(0)) + EXE_FILE), PChar(Format('"%s" "%s" "%s"', [Text, FilePath, IntToStr(FontSize)])), nil, SW_SHOW);

    if not FileExists(GetPosFilePath) then
        AsyncMoveWindowToCenter
end;


procedure CloseVideoMsg;
var
    VideoMsgHandle: HWND;
begin
    VideoMsgHandle := FindWindow(VIDEO_MSG_WINDOW_CLASS, nil);

    if VideoMsgHandle <> 0 then
    begin
        PostMessage(VideoMsgHandle, WM_CLOSE, 0, 0);

    end;
end;

const
    WM_VM_CAPTION = WM_USER + 1;


procedure SetCaption(Caption: string);
var
    VideoMsgHandle: HWND;
    LParam: DWORD;
begin
    VideoMsgHandle := FindWindow(VIDEO_MSG_WINDOW_CLASS, nil);

    if VideoMsgHandle <> 0 then
    begin
        LParam := GlobalAddAtom(PChar(Caption));
        SendMessage(VideoMsgHandle, WM_VM_CAPTION, 0, LParam);
    end;
end;

end.

