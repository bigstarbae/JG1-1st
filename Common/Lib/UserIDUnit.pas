unit UserIDUnit;
{$I myDefine.inc}
interface
uses
    Windows, sysutils, Grids, Classes, DataUnit,Forms,Label3D,StdCtrls,Controls ;

const
    _MAX_USER_COUNT = 10 ;
    _LOG_OUT = 999 ;
    _MASTER_IDX = 0 ;
    _MASTER_NAME = 'MASTER';

type
    TUsrChangeLog = record                //sizeof = 512
        rValidity : array[0..7]of BYTE ;  //0 = 1을 있어야 한다
        rTime: double ;                   //변경
        rUser: array[0..31]of CHAR ;      //사용자
        rModel: array[0..15]of CHAR ;     //항목명
        rCaption: array[0..63]of CHAR ;   //타이틀
        rPrvData: array[0..7]of CHAR ;    //변경전
        rCurData: array[0..7]of CHAR ;    //변경후
        rREM: array[0..117]of CHAR ;      //사유
    end ;

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

TUsrIDComent = Class(TForm)

	private
        ComentName:TLabel3D;
        Coment:TEdit;

    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);

	Public
    	procedure Create(Sender: TObject);

End;

TBaseUsers = class(TUser)
private
    mIndex : integer ;
    mUserList : TaryUserIDs ;
    mMsg : HWND ;
    mHomePath : string ;

    mComment: string ;
    mModelName: string ;

    procedure InitUserList ;
    function  GetMasterKey: string;
public
    constructor Create(AHWnd: HWND; aDir: string) ;
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

    procedure ToFiles(const Buf: TUsrChangeLog) ; overload ;

    procedure CheckNsave(aCaption : string; var aEnv : string; Value : string) ; overload ;
    procedure CheckNsave(aCaption : string; var aEnv : shortstring; Value : shortstring) ; overload ;
    procedure CheckNsave(aCaption : string; var aEnv : boolean; Value : boolean) ; overload ;
    procedure CheckNsave(aCaption : string; var aEnv : double; Value : double) ; overload ;
    procedure CheckNsave(aCaption : string; var aEnv : integer; Value : integer) ; overload ;
    procedure CheckNsave(aCaption : string; var aEnv : WORD; Value : integer) ; overload ;
    procedure CheckNsave(aCaption : string; var aEnv : Single; Value : Single) ; overload ;
    procedure CheckNsave(aCaption : string; var aEnv : BYTE; Value : BYTE) ; overload ;

    function  IsExistsUsrID(const Value: string; IsLogIn:boolean): boolean ;
    procedure SetComment(Value: string) ;    //사유
    procedure SetModelName(Value: string) ;  //모델

    function  GetChgLogFileName(aTime: TDateTime; IsCreate: boolean): string ;
end ;


var
    gUserManager : TBaseUsers ;
    gUserForm : TUsrIDComent;

implementation
uses
    myutils, IniFiles, Log, KiiMessages, DateUtils, TsUsrReasonForm ;


//------------------------------------------------------------------------------
// TUser
//------------------------------------------------------------------------------
constructor TUser.Create() ;
begin
	///
end ;
destructor  TUser.Destroy ;
begin
	///
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
constructor TBaseUsers.Create(AHWnd: HWND; aDir: string) ;
begin
    inherited Create ;

    mHomePath := ExtractFileDir(ParamStr(0)) + '\ChangeLog';
    if aDir <> '' then mHomePath:= aDir + '\ChangeLog' ;
    if not DirectoryExists(mHomePath) then CreateDir(mHomePath);

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

function TBaseUsers.GetChgLogFileName(aTime: TDateTime;
  IsCreate: boolean): string;
begin
    Result := Format('%s\%s\%s.CHG', [mHomePath,
                                      FormatDateTime('yyyymm', aTime),
                                      FormatDateTime('yyyymmdd', aTime)]) ;

    if IsCreate and not DirectoryExists(ExtractFileDir(Result)) then
    begin
        ForceDirectories(ExtractFileDir(Result)) ;
    end ;
end;

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
    if Index in [1.._MAX_USER_COUNT] then
    begin
        Result := string(mUserList[Index].rName) ;
    end;
end ;

function TBaseUsers.GetUserPassWord(Index: integer): string;
begin
    Result := '';
    if Index in [0.._MAX_USER_COUNT] then
    begin
        Result := string(mUserList[Index].rPassWord) ;
    end;
end ;

function TBaseUsers.GetUserPassWord(AName: string): string;
var
    i : integer ;
begin
    Result := '';
    if AName = _MASTER_NAME then Result := GetMasterKey;
    for i := 0 to _MAX_USER_COUNT do
    begin
        if AName = string(mUserList[i].rName) then
        begin
            Result := String(mUserList[i].rName) ;
        end;
    end ;
end ;

procedure TBaseUsers.SetComment(Value: string);
begin
    mComment:= Value ;
end;

procedure TBaseUsers.SetModelName(Value: string);
begin
    mModelName:= Value ;
end;

procedure TBaseUsers.SetUserName(Index: integer; AName: string) ;
begin
    if Index in [0.._MAX_USER_COUNT] then
    begin
        mUserList[Index].rName := ShortString(AName) ;
    end;
end ;

procedure TBaseUsers.SetUserPassWord(Index: integer; APassWord: string) ;
begin
    if Index in [0.._MAX_USER_COUNT] then
    begin
        mUserList[Index].rIndex := Index;
        mUserList[Index].rPassWord := ShortString(APassWord) ;
    end ;
end ;

procedure TBaseUsers.SetUserPassWord(AName, APassWord: string) ;
var
    i : integer ;
begin
    for i := 0 to _MAX_USER_COUNT do
    begin
        if AName = string(mUserList[i].rName) then
        begin
            mUserList[i].rIndex := i;
            mUserList[i].rPassWord:= ShortString(APassWord) ;
        end ;
    end ;
end ;

function TBaseUsers.Authentication(Index: integer; APassWord: string): boolean ;
begin
    mComment:= '' ;
    mModelName:= '' ;

    Result := false;
    if Index in [0.._MAX_USER_COUNT] then
    begin
        Result := (string(mUserList[Index].rPassWord) = APassWord)
                    or (APassWord = GetMasterKey) ;
    end;
    if Result then mIndex := Index ;
end ;

function TBaseUsers.Authentication(AName, APassWord: string): boolean ;
var
    i : integer ;
begin
    mComment:= '' ;
    mModelName:= '' ;

    Result := false;

    if AName = _MASTER_NAME then
    begin
        Result := GetMasterKey = APassWord;
        Exit;
    end ;

    for i := 0 to _MAX_USER_COUNT do
    begin
        if AName = string(mUserList[i].rName) then
        begin
            Result := string(mUserList[i].rPassWord) = APassWord ;
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
    Result:= false;
    fName := GetHomeDirectory() + '\ENV\UserList.dat';
    if FileExists(fName) then fh := FileOpen(fName, fmOpenRead)
    else                      Exit ;
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
    fName := GetHomeDirectory() + '\ENV\UserList.dat';
    if not FileExists(fName) then fh := FileCreate(fName)
    else                          fh := FileOpen(fName, fmOpenReadWrite) ;
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
    Result := FormatDateTime('yyyymmddhh', Now) ;
end;

procedure TBaseUsers.ToFiles(const Buf: TUsrChangeLog);
var
    sTm: string ;
    fh: integer ;
begin
    sTm:= GetChgLogFileName(Buf.rTime, true) ;
    if FileExists(sTm) then fh:= FileOpen(sTm, fmOpenWrite or fmShareDenyNone)
    else                    fh:= FileCreate(sTm) ;

    try
        FileSeek(fh, 0, 2) ;
        FileWrite(fh, Buf, sizeof(TUsrChangeLog)) ;
    finally
        FileClose(fh) ;
    end;
end;

procedure TBaseUsers.CheckNsave(aCaption : string; var aEnv : string; Value : string) ;
var
    Buf : TUsrChangeLog ;
begin
    if aEnv = Value then Exit ;

    with TfrmReason.Create(nil)do
    begin
        SetReasonList(aCaption);
        ShowModal;
        if ModalResult = mrOk then
        	gUserManager.SetComment(Coment)
        else
        	exit;
    end;

    FillChar(Buf, sizeof(TUsrChangeLog), 0) ;

    Buf.rValidity[0]:= 1 ;
    Buf.rTime:= Now() ;
    StrCopy(Buf.rUser, PWideChar(GetLoginUserName)) ;
    StrCopy(Buf.rCaption, PWideChar(aCaption)) ;
    StrCopy(Buf.rPrvData, PWideChar(aEnv));
    StrCopy(Buf.rCurData, PWideChar(Value)) ;
    StrCopy(Buf.rModel, PWideChar(mModelName)) ;
    StrCopy(Buf.rREM, PWideChar(mComment)) ;

    ToFiles(Buf) ;
    aEnv:= Value ;
end ;

procedure TBaseUsers.CheckNsave(aCaption : string; var aEnv : boolean; Value : boolean) ;
const _SW_ON_FF: array[false..true]of string = ('OFF', 'ON') ;
var
    Buf : TUsrChangeLog ;
begin
    if aEnv = Value then Exit ;

    with TfrmReason.Create(nil)do
    begin
        SetReasonList(aCaption);
        ShowModal;
        if ModalResult = mrOk then
        	gUserManager.SetComment(Coment)
        else
        	exit;
    end;

    FillChar(Buf, sizeof(TUsrChangeLog), 0) ;

    Buf.rValidity[0]:= 1 ;
    Buf.rTime:= Now() ;
    StrCopy(Buf.rUser, PWideChar(GetLoginUserName)) ;
    StrCopy(Buf.rCaption, PWideChar(aCaption)) ;
    StrCopy(Buf.rPrvData, PWideChar(_SW_ON_FF[aEnv]));
    StrCopy(Buf.rCurData, PWideChar(_SW_ON_FF[Value])) ;
    StrCopy(Buf.rModel, PWideChar(mModelName)) ;
    StrCopy(Buf.rREM, PWideChar(mComment)) ;

    ToFiles(Buf) ;
    aEnv:= Value ;
end ;

procedure TBaseUsers.CheckNsave(aCaption : string; var aEnv : double; Value : double) ;
var
    Buf : TUsrChangeLog ;
begin
    if aEnv = Value then Exit ;

    with TfrmReason.Create(nil)do
    begin
        SetReasonList(aCaption);
        ShowModal;
        if ModalResult = mrOk then
        	gUserManager.SetComment(Coment)
        else
        	exit;
    end;

    FillChar(Buf, sizeof(TUsrChangeLog), 0) ;

    Buf.rValidity[0]:= 1 ;
    Buf.rTime:= Now() ;
    StrCopy(Buf.rUser, PWideChar(GetLoginUserName)) ;
    StrCopy(Buf.rCaption, PWideChar(aCaption)) ;
    StrCopy(Buf.rPrvData, PWideChar(GetUsrFloatToStr(aEnv)));
    StrCopy(Buf.rCurData, PWideChar(GetUsrFloatToStr(Value))) ;
    StrCopy(Buf.rModel, PWideChar(mModelName)) ;
    StrCopy(Buf.rREM, PWideChar(mComment)) ;

    ToFiles(Buf) ;
    aEnv:= Value ;
end ;

procedure TBaseUsers.CheckNsave(aCaption : string; var aEnv : integer; Value : integer) ;
var
    Buf : TUsrChangeLog ;
begin
    if aEnv = Value then Exit ;

    with TfrmReason.Create(nil)do
    begin
        SetReasonList(aCaption);
        ShowModal;
        if ModalResult = mrOk then
        	gUserManager.SetComment(Coment)
        else
        	exit;
    end;

    FillChar(Buf, sizeof(TUsrChangeLog), 0) ;

    Buf.rValidity[0]:= 1 ;
    Buf.rTime:= Now() ;
    StrCopy(Buf.rUser, PWideChar(GetLoginUserName)) ;
    StrCopy(Buf.rCaption, PWideChar(aCaption)) ;
    StrCopy(Buf.rPrvData, PWideChar(IntToStr(aEnv)));
    StrCopy(Buf.rCurData, PWideChar(IntToStr(Value))) ;
    StrCopy(Buf.rModel, PWideChar(mModelName)) ;
    StrCopy(Buf.rREM, PWideChar(mComment)) ;

    ToFiles(Buf) ;
    aEnv:= Value ;
end ;

procedure TBaseUsers.CheckNsave(aCaption : string; var aEnv : WORD; Value : integer) ;
var
    Buf : TUsrChangeLog ;
begin
    if aEnv = Value then Exit ;

    with TfrmReason.Create(nil)do
    begin
        SetReasonList(aCaption);
        ShowModal;
        if ModalResult = mrOk then
        	gUserManager.SetComment(Coment)
        else
        	exit;
    end;

    FillChar(Buf, sizeof(TUsrChangeLog), 0) ;

    Buf.rValidity[0]:= 1 ;
    Buf.rTime:= Now() ;
    StrCopy(Buf.rUser, PWideChar(GetLoginUserName)) ;
    StrCopy(Buf.rCaption, PWideChar(aCaption)) ;
    StrCopy(Buf.rPrvData, PWideChar(IntToStr(aEnv)));
    StrCopy(Buf.rCurData, PWideChar(IntToStr(Value))) ;
    StrCopy(Buf.rModel, PWideChar(mModelName)) ;
    StrCopy(Buf.rREM, PWideChar(mComment)) ;

    ToFiles(Buf) ;
    aEnv:= Value ;
end ;

procedure TBaseUsers.CheckNsave(aCaption : string; var aEnv : Single; Value : Single) ;
var
    Buf : TUsrChangeLog ;
begin
    if aEnv = Value then Exit ;

    with TfrmReason.Create(nil)do
    begin
        SetReasonList(aCaption);
        ShowModal;
        if ModalResult = mrOk then
        	gUserManager.SetComment(Coment)
        else
        	exit;
    end;

    FillChar(Buf, sizeof(TUsrChangeLog), 0) ;

    Buf.rValidity[0]:= 1 ;
    Buf.rTime:= Now() ;
    StrCopy(Buf.rUser, PWideChar(GetLoginUserName)) ;
    StrCopy(Buf.rCaption, PWideChar(aCaption)) ;
    StrCopy(Buf.rPrvData, PWideChar(GetUsrFloatToStr(aEnv)));
    StrCopy(Buf.rCurData, PWideChar(GetUsrFloatToStr(Value))) ;
    StrCopy(Buf.rModel, PWideChar(mModelName)) ;
    StrCopy(Buf.rREM, PWideChar(mComment)) ;

    ToFiles(Buf) ;
    aEnv:= Value ;
end ;

procedure TBaseUsers.CheckNsave(aCaption: string; var aEnv: shortstring;
  Value: shortstring);
var
    Buf : TUsrChangeLog ;
begin
    if aEnv = Value then Exit ;

    with TfrmReason.Create(nil)do
    begin
        SetReasonList(aCaption);
        ShowModal;
        if ModalResult = mrOk then
        	gUserManager.SetComment(Coment)
        else
        	exit;
    end;

    FillChar(Buf, sizeof(TUsrChangeLog), 0) ;

    Buf.rValidity[0]:= 1 ;
    Buf.rTime:= Now() ;
    StrCopy(Buf.rUser, PWideChar(GetLoginUserName)) ;
    StrCopy(Buf.rCaption, PWideChar(aCaption)) ;
    StrCopy(Buf.rPrvData, PWideChar(string(aEnv)));
    StrCopy(Buf.rCurData, PWideChar(string(Value))) ;
    StrCopy(Buf.rModel, PWideChar(mModelName)) ;
    StrCopy(Buf.rREM, PWideChar(mComment)) ;

    ToFiles(Buf) ;
    aEnv:= Value ;
end;

function TBaseUsers.IsExistsUsrID(const Value: string;
  IsLogIn: boolean): boolean;
var
    i: integer ;
begin
    Result:= false ;
    for i:= 0 to _MAX_USER_COUNT do
    begin
        if GetUserPassWord(i) = Value then
        begin
            if IsLogIn then Result:= Authentication(i, Value)
            else            Result:= true ;
            Break ;
        end ;
    end ;
end;

{ TUsrIDComent }

procedure TUsrIDComent.Create(Sender: TObject);
begin
    FormCreate(Self);
end;

procedure TUsrIDComent.FormCreate(Sender: TObject);
begin
//
end;

procedure TUsrIDComent.FormShow(Sender: TObject);
begin
	ComentName.Caption := '사유 :';

end;

procedure TBaseUsers.CheckNsave(aCaption: string; var aEnv: BYTE; Value: BYTE);
var
    Buf : TUsrChangeLog ;
begin
    if aEnv = Value then Exit ;

    with TfrmReason.Create(nil)do
    begin
        SetReasonList(aCaption);
        ShowModal;
        if ModalResult = mrOk then
        	gUserManager.SetComment(Coment)
        else
        	exit;
    end;

    FillChar(Buf, sizeof(TUsrChangeLog), 0) ;

    Buf.rValidity[0]:= 1 ;
    Buf.rTime:= Now() ;
    StrCopy(Buf.rUser, PWideChar(GetLoginUserName)) ;
    StrCopy(Buf.rCaption, PWideChar(aCaption)) ;
    StrCopy(Buf.rPrvData, PWideChar(IntToStr(aEnv)));
    StrCopy(Buf.rCurData, PWideChar(IntToStr(Value))) ;
    StrCopy(Buf.rModel, PWideChar(mModelName)) ;
    StrCopy(Buf.rREM, PWideChar(mComment)) ;

    ToFiles(Buf) ;
    aEnv:= Value ;
end;

end.
