unit UserIDUnit;
{$I myDefine.inc}
interface
uses
    Windows, sysutils, {$IFNDEF VER150}FileCtrl,{$ENDIF} Grids, Classes,
    DataUnit ;

const
    _MAX_USER_COUNT = 10 ;
    _LOG_OUT = 999 ;
    _MASTER_IDX = 0 ;
    _MASTER_NAME = '°ü¸®ÀÚ';

type

    TUserID = packed record   // sizeof = 128
        rIndex     : BYTE ;
        rName      : string[32] ;
        rPassWord  : string[32] ;
        rREM         : array[0..62]of BYTE ;
    end ;

    TaryUserIDs = array[0.._MAX_USER_COUNT] of TUserID ;
    
TUser = class
private
    function  LoadIndex(Section, Identity: string): integer ;
    procedure SaveIndex(Section, Identity: string; Values: integer) ;
public
    constructor Create() ;
    destructor  Destroy ; override ;
end ;
TBaseUsers = class(TUser)
private
    mIndex : integer ;
    mUserList : TaryUserIDs ;
    mMsg : HWND ;
    mHomePath : string ;

    procedure InitUserList ;
    function GetMasterKey: string;
public
    constructor Create(AHWnd: HWND) ;
    destructor  Destroy; override ;

    function GetUserName(Index: integer): string;
    function GetUserPassWord(Index: integer): string; overload ;
    function GetUserPassWord(AName: string): string; overload ;
    procedure SetUserName(Index: integer; AName: string) ;
    procedure SetUserPassWord(Index: integer; APassWord: string) ; overload ;
    procedure SetUserPassWord(AName, APassWord: string) ; overload ;
    function Authentication(Index: integer; APassWord: string): boolean ; overload ;
    function Authentication(AName, APassWord: string): boolean ; overload ;
    procedure DeleteUser(Index: integer);
    procedure LogOut ;
    function GetLogInUserName(): string ;
    property UserIndex : integer read mIndex ;

    function  LoadUserIDList(): boolean;
    procedure SaveUserIDList() ;

    procedure ToFiles(const s : string);

//    procedure CheckNsaveOwner(aFormat : string ;  var Args: array of const) ;
    procedure CheckNsave(aCaption : string; var aEnv : string; Value : string) ; overload ;
    procedure CheckNsave(aCaption : string; var aEnv : boolean; Value : boolean) ; overload ;
    procedure CheckNsave(aCaption : string; var aEnv : double; Value : double) ; overload ;
    procedure CheckNsave(aCaption : string; var aEnv : integer; Value : integer) ; overload ;
    procedure CheckNsave(aCaption : string; var aEnv : WORD; Value : integer) ; overload ;
    procedure CheckNsave(aCaption : string; var aEnv : Single; Value : Single) ; overload ;

end ;

var
    gUserManager : TBaseUsers ;

implementation
uses
    myutils, IniFiles, Log, KiiMessages, Forms , DateUtils, LangTran;


//------------------------------------------------------------------------------
// TUser
//------------------------------------------------------------------------------
constructor TUser.Create() ;
begin
end ;
destructor  TUser.Destroy ;
begin
end ;
function TUser.LoadIndex(Section, Identity: string): integer ;
var
    Ini : TIniFile ;
begin
    Ini := TIniFile.Create(GetIniFiles()) ;
    try
        Result := Ini.ReadInteger(Section, IDentity, 1) ;
    finally
        Ini.Free ;
    end ;
end ;
procedure TUser.SaveIndex(Section, Identity: string; Values: integer) ;
var
    Ini : TIniFile ;
begin
    Ini := TIniFile.Create(GetIniFiles()) ;
    try
        Ini.WriteInteger(Section, IDentity, Values) ;
    finally
        Ini.Free ;
    end ;
end ;
//------------------------------------------------------------------------------
{ TBaseUsers }
//------------------------------------------------------------------------------
constructor TBaseUsers.Create(AHWnd: HWND) ;
begin
    inherited Create ;

    mHomePath := ExtractFileDir(ParamStr(0)) + '\UserLog';
    if not DirectoryExists(mHomePath) then CreateDir(mHomePath);

//    mID:= LoadIndex('USER', '_LAST_SEL') ;
    mMsg := AHWnd ;
    if not LoadUserIDList() then
    begin
        InitUserList ;
    end;
    LogOut;
end ;

destructor  TBaseUsers.Destroy;
begin
    inherited Destroy ;
end ;

procedure TBaseUsers.LogOut ;
begin
    mIndex := _LOG_OUT ;
end ;

function TBaseUsers.GetLogInUserName(): string ;
begin
    Result := GetUserName(mIndex);
end;

procedure TBaseUsers.DeleteUser(Index: integer) ;
begin
    SetUserName(Index, '');
    SetUserPassWord(Index, '');
end ;

procedure TBaseUsers.InitUserList ;
var
    i : integer ;
begin
    FillChar(mUserList, sizeof(TaryUserIDs), 0) ;
    for i := 0 to _MAX_USER_COUNT do    mUserList[i].rIndex := i ;
end ;

function TBaseUsers.GetUserName(Index: integer): string;
begin
    Result := '';
    if Index = _MASTER_IDX then Result := _MASTER_NAME;
    if Index in [0.._MAX_USER_COUNT] then Result := mUserList[Index].rName ;
end ;

function TBaseUsers.GetUserPassWord(Index: integer): string;
begin
    Result := '';
//    if Index = _MASTER_IDX then Result := GetMasterKey;
    if Index in [0.._MAX_USER_COUNT] then Result := mUserList[Index].rPassWord ;
end ;

function TBaseUsers.GetUserPassWord(AName: string): string;
var
    i : integer ;
begin
    Result := '';
    if AName = _MASTER_NAME then Result := GetMasterKey;
    for i := 0 to _MAX_USER_COUNT do
    begin
        if AName = mUserList[i].rName then Result := mUserList[i].rName ;
    end ;
end ;

procedure TBaseUsers.SetUserName(Index: integer; AName: string) ;
begin
    if Index in [0.._MAX_USER_COUNT] then mUserList[Index].rName := AName ;
end ;

procedure TBaseUsers.SetUserPassWord(Index: integer; APassWord: string) ;
begin
    if Index in [0.._MAX_USER_COUNT] then
    begin
        mUserList[Index].rIndex := Index;
        mUserList[Index].rPassWord := APassWord ;
    end ;
end ;

procedure TBaseUsers.SetUserPassWord(AName, APassWord: string) ;
var
    i : integer ;
begin
    for i := 0 to _MAX_USER_COUNT do
    begin
        if AName = mUserList[i].rName then
        begin
            mUserList[i].rIndex := i;
            mUserList[i].rPassWord := APassWord ;
        end ;
    end ;
end ;

function TBaseUsers.Authentication(Index: integer; APassWord: string): boolean ;
begin
    Result := false;
//    if APassWord = '' then Exit ;
//    if (Index = _MASTER_IDX) and (APassWord = GetMasterKey) then Result := true;
    if Index in [0.._MAX_USER_COUNT] then Result := mUserList[Index].rPassWord = APassWord ;
    if Result then mIndex := Index ;
end ;

function TBaseUsers.Authentication(AName, APassWord: string): boolean ;
var
    i : integer ;
begin
    Result := false;
//    if (AName = '') or (APassWord = '') then Exit ;

    if AName = _MASTER_NAME then
    begin
        Result := GetMasterKey = APassWord;
        Exit;
    end ;

    for i := 0 to _MAX_USER_COUNT do
    begin
        if AName = mUserList[i].rName then
        begin
            Result := mUserList[i].rPassWord = APassWord ;
            if Result then mIndex := i ;
            break ;
        end ;
    end ;
end ;

function TBaseUsers.LoadUserIDList(): boolean ;
var
    i, fh: integer ;
    fName : string ;
begin
    Result := false;
    fName := Format('%s\UserList.dat', [GetUsrDir(udENV, Now())]);
    if FileExists(fName) then fh := FileOpen(fName, fmOpenRead)
    else                       Exit ;
    if fh <= 0 then Exit ;

    FileSeek(fh, 0, 0);
    try
        for i := 0 to _MAX_USER_COUNT do
        begin
            FileRead(fh, mUserList[i], sizeof(TUserID)) ;
        end;
    finally
        FileClose(fh) ;
    end;
    Result := true;
end;

procedure TBaseUsers.SaveUserIDList() ;
var
    i, fh : integer ;
    fName : string ;
begin
    fName := Format('%s\UserList.dat', [GetUsrDir(udENV, Now())]);
    if not FileExists(fName) then fh := FileCreate(fName)
    else                           fh := FileOpen(fName, fmOpenReadWrite) ;
    if fh <= 0 then Exit ;

    FileSeek(fh, 0, 0);
    try
        for i := 0 to _MAX_USER_COUNT do
        begin
            FileWrite(fh, mUserList[i], sizeof(TUserID)) ;
        end ;
    finally
        FileClose(fh) ;
    end ;
end ;

function TBaseUsers.GetMasterKey: string;
begin
    Result := '0802';//FormatDateTime('yyyymmddhh', Now) ;
end;

procedure TBaseUsers.ToFiles(const s : string);
var
	fd : integer;
	FileFath, Str : string;
	yy, mm, dd, hh, nn, ss, ns  : word;
begin
	DecodeDateTime(Now(), yy, mm, dd, hh, nn, ss, ns) ;
	FileFath := Format('%s\%.4d%.2d%.2d.LOG', [mHomePath, yy, mm, dd]);
    if FileExists(FileFath) then fd := FileOpen(FileFath, fmOpenWrite)
    else                            fd := FileCreate(FileFath);

	if (fd < 0) then exit;

    Str := Format('[%.2d:%.2d:%.2d] < %s > %s', [hh, nn, ss, GetLoginUserName, s]) + #13 + #10;

    FileSeek(fd, 0, FILE_END);
	FileWrite(fd, Str[1], Length(Str));
	FileClose(fd);
end;

{
procedure TBaseUsers.CheckNsaveOwner(aFormat : string ;  var Args: array of const) ;
var
    sTm : string ;
begin
    if Args[1] <> Args[2] then
    begin
        sTm := Format(aFormat, Args);
        ToFiles(sTm);
        Args[1] := Args[2] ;
    end ;
end ;

}

procedure TBaseUsers.CheckNsave(aCaption : string; var aEnv : string; Value : string) ;
var
    sTm : string ;
begin
    if aEnv <> Value then
    begin
        sTm := Format('%s : [%s] -> [%s]', [aCaption, aEnv, Value]);
        ToFiles(sTm);
        aEnv := Value ;
    end ;
end ;

procedure TBaseUsers.CheckNsave(aCaption : string; var aEnv : boolean; Value : boolean) ;
var
    sTm : string ;
begin
    if aEnv <> Value then
    begin
        sTm := Format('%s : [%s] -> [%s]', [aCaption, OnNOff[aEnv], OnNOff[Value]]);
        ToFiles(sTm);
        aEnv := Value ;
    end ;
end ;

procedure TBaseUsers.CheckNsave(aCaption : string; var aEnv : double; Value : double) ;
var
    sTm : string ;
begin
    if aEnv <> Value then
    begin
        sTm := Format('%s : [%f] -> [%f]', [aCaption, aEnv, Value]);
        ToFiles(sTm);
        aEnv := Value ;
    end ;
end ;

procedure TBaseUsers.CheckNsave(aCaption : string; var aEnv : integer; Value : integer) ;
var
    sTm : string ;
begin
    if aEnv <> Value then
    begin
        sTm := Format('%s : [%d] -> [%d]', [aCaption, aEnv, Value]);
        ToFiles(sTm);
        aEnv := Value ;
    end ;
end ;

procedure TBaseUsers.CheckNsave(aCaption : string; var aEnv : WORD; Value : integer) ;
var
    sTm : string ;
begin
    if aEnv <> Value then
    begin
        sTm := Format('%s : [%d] -> [%d]', [aCaption, aEnv, Value]);
        ToFiles(sTm);
        aEnv := Value ;
    end ;
end ;

procedure TBaseUsers.CheckNsave(aCaption : string; var aEnv : Single; Value : Single) ;
var
    sTm : string ;
begin
    if aEnv <> Value then
    begin
        sTm := Format('%s : [%f] -> [%f]', [aCaption, aEnv, Value]);
        ToFiles(sTm);
        aEnv := Value ;
    end ;
end ;


end.
