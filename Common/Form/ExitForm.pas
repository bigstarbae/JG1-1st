unit ExitForm;

interface

uses
    Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, Buttons,
    ExtCtrls, jpeg;

type
    TExitFrm = class(TForm)
        OKBtn: TButton;
        CancelBtn: TButton;
        cbxShutdown: TCheckBox;
        mmMemo: TMemo;
        Bevel2: TBevel;
        pnl1: TPanel;
        img1: TImage;
        labTitle: TLabel;
        labSubTitle: TLabel;
        lblVer: TLabel;
        lbl2: TLabel;
        procedure OKBtnClick(Sender: TObject);
        procedure FormClose(Sender: TObject; var Action: TCloseAction);
        procedure FormShow(Sender: TObject);
        procedure FormCreate(Sender: TObject);
    private
    { Private declarations }
        mScreen: integer;

    public
    { Public declarations }
        constructor Create(AOwner: TComponent; Ver: string); reintroduce;

        function ReadHistory(FilePath: string): boolean;
        procedure SetTitile(AText: string; AScreenIndex: integer = 0);
        procedure SetsubTitle(aText: string);

    end;

function WindowsExit(RebootParam: Longword): Boolean;

var
    ExitFrm: TExitFrm;

implementation

uses
    myUtils, VerUnit;

{$R *.DFM}
//윈도우종료
//WindowsExit(EWX_POWEROFF or EWX_FORCE) ;

//윈도우재부팅
//WindowsExit(EWX_REBOOT or EWX_FORCE) ;

//윈도우로그오프
//WindowsExit(EWX_LOGOFF or EWX_FORCE) ;
//{
function WindowsExit(RebootParam: Longword): Boolean;
var
    TTokenHd: THandle;
    TTokenPvg: TTokenPrivileges;
    cbtpPrevious: DWORD;
    rTTokenPvg: TTokenPrivileges;
    pcbtpPreviousRequired: DWORD;
    tpResult: Boolean;
const
    SE_SHUTDOWN_NAME = 'SeShutdownPrivilege';
begin
    if Win32Platform = VER_PLATFORM_WIN32_NT then
    begin
        tpResult := OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, TTokenHd);
        if tpResult then
        begin
            tpResult := LookupPrivilegeValue(nil, SE_SHUTDOWN_NAME, TTokenPvg.Privileges[0].Luid);
            TTokenPvg.PrivilegeCount := 1;
            TTokenPvg.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
            cbtpPrevious := SizeOf(rTTokenPvg);
            pcbtpPreviousRequired := 0;
            if tpResult then
                Windows.AdjustTokenPrivileges(TTokenHd, False, TTokenPvg, cbtpPrevious, rTTokenPvg, pcbtpPreviousRequired);
        end;
    end;
    Result := ExitWindowsEx(RebootParam, 0);
end;
//}
{
procedure ShutDown(dwTimeOut : DWord = 0; bForceClose : Boolean = true; bReboot : Boolean = false) ;
var
	PreviosPrivileges: ^TTokenPrivileges;

	TokenPrivileges: TTokenPrivileges;

	hToken: THandle;

	tmpReturnLength: DWord;

    WinExitOption : Integer ;
begin
	WinExitOption := EWX_FORCE or EWX_POWEROFF ;
    if Win32Platform = VER_PLATFORM_WIN32_NT then
    begin
        if OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, hToken) then
        begin
            LookupPrivilegeValue(Nil, 'SeShutdownPrivilege', TokenPrivileges.Privileges[0].Luid);

            TokenPrivileges.PrivilegeCount := 1;

            TokenPrivileges.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;

            tmpReturnLength := 0;

            PreviosPrivileges := nil;

            AdjustTokenPrivileges(hToken, False, TokenPrivileges, 0, PreviosPrivileges^, tmpReturnLength);

            //if InitiateSystemShutdown(Nil, Nil, dwTimeOut, bForceClose, bReboot) then
            //begin
            //    TokenPrivileges.Privileges[0].Attributes := 0;

            //    AdjustTokenPrivileges(hToken, False, TokenPrivileges, 0, PreviosPrivileges^, tmpReturnLength);
            //end ;
        end ;
    end
    else	WinExitOption := WinExitOption or EWX_SHUTDOWN ;
    ExitWindowsEx(WinExitOption, 0);
end ;
}

function GetVersion: string;
const
    VER_SEC = 'VERINFO';
begin
    //-----------------
    try
        VerInfoEx := TVerInfoEx.Create(GetIniFiles);
        Result := FileVersionInfo.fFileVersion;
        VerInfoEx.Free;
        VerInfoEx := nil;
    finally
    end;
    //-----------------
    Result := 'Ver:' + Result;
end;

constructor TExitFrm.Create(AOwner: TComponent; Ver: string);
begin
    inherited Create(AOwner);
    lblVer.Caption := 'Ver.' + Ver;
end;

procedure TExitFrm.OKBtnClick(Sender: TObject);
begin
    if cbxShutdown.Checked then
    begin
        WindowsExit(EWX_POWEROFF or EWX_FORCE);
        //ShutDown;
    end;
end;

procedure TExitFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    Action := caFree;
end;

procedure TExitFrm.FormShow(Sender: TObject);
var
    FilePath: string;
begin
    FilePath := GetHomeDirectory + '\History.txt';
    ReadHistory(FilePath);

    OKBtn.SetFocus;

    if (mScreen > 0) and (Screen.MonitorCount > 1) then
    begin
        Left := Screen.Monitors[mScreen].Left + (Screen.Monitors[mScreen].Width div 2) - (Width div 2);
    end;
end;

function TExitFrm.ReadHistory(FilePath: string): boolean;
var
    History: TStringList;
    i: integer;
begin
    if FileExists(FilePath) then
    begin
        History := TStringList.Create;
        History.LoadFromFile(FilePath);
        for i := 0 to History.Count - 1 do
        begin
            mmMemo.Lines.Add(History.Strings[i]);
        end;
        History.Free;
        Result := true;
        Exit;
    end;
    Result := false;
end;

procedure TExitFrm.SetTitile(aText: string; AScreenIndex: integer);
begin
    labTitle.Caption := aText;
    mScreen := AScreenIndex;
end;

procedure TExitFrm.SetSubTitle(AText: string);
begin
    labSubTitle.Caption := AText;
end;

procedure TExitFrm.FormCreate(Sender: TObject);
begin
    mScreen := 0;
end;

end.

