{ ===============================================================================
  # for Delphi2010 : Ver 20240415.00
  : History

  - 2014.09.16 : By EmptySpear
  . FindControlByTag 추가
  . ParseByDelimiter 추가
  . TUserData Range 멤버 함수군 추가


  - 2015.01 : By EmptySpear
  . Bit연산 도우미 함수 추가


  - 2016.01
  . TRTTIHelper : RTTI 관련 도움 클래스 추가

  - 2019.03.11:
  . TMyThreadList<> : Thread safe 제네릭 List 클래스 추가

  - 2019.05 :
  . ReadStr, WriteStr : AnsiString Binary 파일에 읽고 쓰기

  - 2019.07:
    . GradientFill 관련 함수

  - 2024.09.24
    . Bit 처리 함수들 집결
    . GetBitStatus 추가 by JSJ

  =============================================================================== }
unit myUtils;

interface

uses
    Windows, SysUtils, Grids, classes, forms, stdctrls, Graphics, ExtCtrls,
    comctrls, Messages {$IFNDEF VER150}, FileCtrl {$ENDIF}, Printers, KiiMessages,
    ShellAPI, shlobj, Controls, Generics.Collections, Generics.Defaults, LangTran;

type
    TArrayHelper = class
    public
        class function MakeArray<T>(const Items: array of T): TArray<T>; static;
    end;

    TMyThreadList<T> = class
    private
        FList: TList<T>;
        FLock: TRTLCriticalSection;
    public
        constructor Create;
        destructor Destroy; override;

        procedure Add(const Item: T);
        procedure Clear;

        function Count: integer;

        function LockList: TList<T>;
        procedure Remove(const Item: T); inline;
        procedure UnlockList; inline;

    end;

    TBit = 0 .. 31;
    TTYPE_TIME = (ty_HOURE, ty_MIN, ty_SEC, ty_MM);
    TGOLD_IDX = (ID_FILES, ID_DIR, ID_SUBDIR);
    TGOLD_IDXs = set of TGOLD_IDX;
    TSIZE_TYPE = (stBYTES, stKB, stMB, stGB);
    TDataCompare = function(Item1, Item2: integer): integer;
    TDataChange = procedure(Item1, Item2: integer);

    TpDataCompare = function(ary: Pointer; Item1, Item2: integer): integer;
    TpDataChange = procedure(ary: Pointer; Item1, Item2: integer);

    TUserArea = packed record
        X, Y, Height, Width: integer;
    end;

    TmyArea = TUserArea;
    pmyArea = ^TmyArea;

    TUserData = packed record

        constructor Create(Lo, Hi: double);
        procedure Init(Lo, Hi: double);
        function ReadFromStr(Lo, Hi: string): boolean;

        function GetRangeStr(Digit: integer = 0; UnitStr: string = ''; Delimiter: string = ' ~ '): string;
        function GetMinStr(Digit: integer = 0; UnitStr: string = ''): string;
        function GetMaxStr(Digit: integer = 0; UnitStr: string = ''): string;

        function InRange(Value: double; Digit: integer = 3): boolean;
        function IsEmpty: boolean;
        function IsValid(): boolean;

        procedure WriteToEdit(MinEdit, MaxEdit: TCustomEdit; Format: string = '0.0');
        function  ReadFromEdit(MinEdit, MaxEdit: TCustomEdit): boolean;


    case Integer of
        0: (
                rLo: double;
                rHi: double;
            );
        1:  (
                rMin: double;
                rMax: double;
            );

    end;

    pUsrDateTime = ^TUsrDateTime;

    TUsrDateTime = record
        yy, mm, dd, hh, nn, ss, zz: WORD;
    end;

    TUsrPowerMode = (ups_AC_ON_LINE, ups_AC_OFF_LINE, ups_AC_BACKUP, ups_AC_UNKNOWN,
        ups_BT_HIGH, ups_BT_LOW, ups_BT_CRITICAL, ups_BT_CHARGING, ups_BT_NO_BATTERY, ups_BT_UNKNOWN, ups_BT_LIFE_UNKNOWN);

    TDynStrArray =  array of string;
    TRttiHelper = class
    public
        class function GetMembersStr<T> : string;
        class function GetMembersName<T>(var MemNames :TDynStrArray): integer;
    end;


    // Time
function SetDisp(Sec: integer): string; // 초 -> hh:nn:ss
function GetUserTime(Times: TDateTime; types: TTYPE_TIME): integer;
function SetUserTime(Times: integer; types: TTYPE_TIME): TDateTime;
function GetExistTime(Times: TDateTime; types: TTYPE_TIME): integer;
function GetUserSepTime(Times: TDateTime; types: TTYPE_TIME): integer;
function GetMinToTime(Min: LongInt): TDateTime;
function TimeToString(Hour, Min, Sec: String): TDateTime;
function IsValidTime(var Times: TDateTime; Hour, Min, Sec, Ms: WORD): boolean;
function IsValidDate(var Dates: TDateTime; Year, Mon, Day: WORD): boolean;
function GetJulianDate(Times: TDateTime): Extended;
function GetTodayOnYear(Times: TDateTime): integer;
function GetTodayOnWeek(Times: TDateTime): integer;
function GetDateTimes(Mons: integer): TDateTime;
function NextMonths(Day: integer; Times: TDateTime): TDateTime;
function NextWeeks(Week: integer; Times: TDateTime): TDateTime;
function NextDays(Times: TDateTime): TDateTime;

function GetAccurateTime: double;
procedure PMSleep(Msec: double);


// Format yyyy-mm-dd hh:nn:ss:zzz => TDateTime
function GetStrToDateTime(const AText: string): TDateTime;

function DrawTitle(var Grid: TStringGrid; Datas: TStrings): boolean;
function IsFileExisted(sDir, sFileName: string): boolean;
function IsDeleteFiled(sFileName: string): boolean;
function DelSeparator(sData: string; Separator: Char): string;
function FileCopy(orgFileName, tagFileName: string): boolean;
function GetIndex(InputTime: TDateTime): integer;
function GetVInfo(app: TApplication; ID: String): String;
function GetStrToInt(sValue: String): integer;
function GetStrToFloat(sValue: string): double;
// Beep sound...
procedure SetPort(address, Value: WORD);
procedure NoSound;
procedure Sound(Freq: WORD);
function GetPort(address: WORD): WORD;
// 콤보박스에 텍스트 중복없이 계속 추가...
function SetTextComboBox(var mycbx: TComboBox): integer;
// 001 등의 스트링 만들기..
function IntToZeroStr(n: integer; m: byte): string;
function SplitBack(Name: string; Sep: Char): string;
function GetSepTxt(aSeparator, aStr: string; aIndex: integer): string; // aSeparator로 구분된 aIndex(1부터)의  문자열 취함
function GetUsrFloatToStr(Val: double; Digit: integer = 0): string;
function BufferToHexStr(Buffer: PByte; Len: integer; IsShowAscii: boolean = false): string;
function wsprintf(Output: PChar; Format: PChar): Integer; cdecl; varargs; external user32 name {$IFDEF UNICODE}'wsprintfW'{$ELSE}'wsprintfA'{$ENDIF};

function MyTrim(Str: string): string;

// 폴더, 파일 모두 땡겨 땡겨...
procedure Zap(const dirPath: string);

function FindAllFileExs(Dirs, Target: string; List: TStrings; ALimit: integer; PerForm: TGOLD_IDXs): integer;
function FindAllFileFxs(Dirs, Target: string; List: TStrings; PerForm: TGOLD_IDXs): integer;
function FindAllFiles(Dirs: string; List: TStrings; PerForm: TGOLD_IDXs = [ID_FILES]): integer;
function FindAllFilesEx(Dirs: string; List: TStrings; ALimit: integer; PerForm: TGOLD_IDXs = [ID_FILES]): integer;
function GetUserFolder(awsnHandle: HWND; aTitle: string = ''): string;
function GetUserFolderEx(awsnHandle: HWND; ACallBack: TFNBFFCallBack = nil; aTitle: string = ''): string;
function GetCreateTime(const aFileName: string; var Times: TDateTime): boolean;
function GetLastAccessTime(const aFileName: string; var Times: TDateTime): boolean;
function GetLastWriteTime(const aFileName: string; var Times: TDateTime): boolean;
function GetFileTimeToDateTime(const afTime: TFileTime; var Times: TDateTime): boolean;
function DeleteFileWithUndo(const FileName: string): Boolean;           // 휴지통으로 파일 삭제


function IsNT(): boolean;
function GetFileSize(const FileName: string): integer;
function FolderSize(Dir: string): Int64; // return BYTE size

// 현디렉토리 참조 및 생성
function GetIniFiles: string;
function GetHomeDirectory: string;
function GetDeskTopDirectory: String;
function MakeRunPath(const szName: String): string;
function GetFileSizeTxt(aSize: Int64; aType: integer = ord(stBYTES)): string;
procedure CheckDirAndMade(aDir: string);

// 항상 실수로 만들어 준다.
function ExtToStr(Val: double): string;
function HexToInt(const AHex: Ansistring): integer;
function CHTB(const HexChar: AnsiChar): byte;
function StrToHex(const Str: string): string;

// Grid
procedure ClearGrid(var Grid: TStringGrid; StartRow, RowCount: integer);
procedure AlignGrid(var Grid: TStringGrid; ACol, ARow: integer; Rect: TRect; State: TGridDrawState; Aligns: array of integer);
function IsSelectedRows(aGrid: TStringGrid; ARow: integer): boolean;

// sorting
// procedure QuickSort(var aAry: array of double;First, Last:integer) ; overload ;
procedure QuickSort(var aAry: array of Variant; First, Last: integer); overload;
procedure BubbleSort(var aAry: array of Variant; First, Last: integer); overload;

procedure QuickSort(Sort: TDataCompare; Change: TDataChange; First, Last: integer); overload;
procedure BubbleSort(Sort: TDataCompare; Change: TDataChange; First, Last: integer); overload;

procedure QuickpSort(aAry: Pointer; Sort: TpDataCompare; Change: TpDataChange; First, Last: integer);
procedure BubblepSort(aAry: Pointer; Sort: TpDataCompare; Change: TpDataChange; First, Last: integer);

{ File attribute constants }
{
  faReadOnly  = $00000001;
  faHidden    = $00000002;
  faSysFile   = $00000004;
  faVolumeID  = $00000008;
  faDirectory = $00000010;
  faArchive   = $00000020;
  faAnyFile   = $0000003F;
}
procedure GetAllWindowsProc(WinHandle: HWND; Slist: TStrings);
procedure GetAllWindows(Slist: TStrings);
procedure SetCloseWindow(aName: string);
procedure SetTimePickerFormat(aPicker: TDateTimePicker; aFormat: string);
procedure SetMyTimeFormat(aForm: TForm);

function IsDefaultPrinterSetup: boolean;
function Process32List(aHandle: THandle): boolean;
// 외부프로그램 실행시켜놓고 대기혀 보자.갸가 죽을때 꺼정 -.-;;;
function WinExecAndWait(const Path: pCHAR; const Dir: pCHAR; const Visibility: WORD; const Wait: boolean): boolean;
procedure Process32ListKill(aFileName: String);
// MessageBox(Application)
procedure MsgError(Caption, Text: pCHAR);
function MsgCheck(Caption, Text: pCHAR): boolean;

function GetsysSaverRunning(): boolean;
function GetsysSaveTimeOut: integer;
function SetsysSaverTimeOut(ATime: integer): boolean;
function SetsysSaverEnable(AEnable: integer): boolean;
function GetsysSaverEnable: boolean;
procedure SaverTurnOn;
procedure SaverTurnOff();

function RectToArea(Rect: TRect): TmyArea;
function AreaToRect(Area: TmyArea): TRect;
procedure DrawImage(desCanvas, srcCanvas: TCanvas; desArea, srcArea: TmyArea);

function GetFloatToTerms(Lo, Hi: double; PointPos: integer = 2): string;
function GetTermToFloat(aTerm: string): TUserData;
// Print
function InitUsrPrint(Print: TPrinter; StartPage: boolean; Title: string; Orientation: TPrinterOrientation): TRect;
function GetDefaultPrint(): string;
function SetDefaultPrint(aName: string): boolean;
//
function GetComPorts(Ports: TStringList): integer;
function GetFloatToStrEx(aDigit: integer; aValue: double; UseBankersRound: boolean = false): string;
function IsExistsWindows(aClassName: string): boolean;
// 다음을 파일헤더 없이 사용시 검증필요
procedure LogFileRemove(aSaveMonth: integer; UserFileHead: string);
// SendMessage
procedure SendToForm(aForm: string; awCode, alCode: integer; IsExpress: boolean = true); overload;
procedure SendToForm(Awnd: HWND; awCode, alCode: integer; IsExpress: boolean = true); overload;
procedure ToPanel(hMsg: HWND; const szFmt: string; const Args: array of const ); overload;
procedure ToPanel(AObj: TObject; const szFmt: string; const Args: array of const ); overload;
function GetUserValue(aValue: double; aDigit: integer): double;
function MyTrunc(const Value: Double; const Digit: Integer): Double;        // Digit자리 밑으로 절삭

function IsBatteryMode(var AC: TUsrPowerMode; var Battery: TUsrPowerMode; var BatteryLife: byte): boolean;



function GetCpuCount: integer;
function GetDiskInfo(const Dest: string; var VolumnValue: string): boolean ;

// VCL 찾기
function FindControlByTag(ParentControl: TWinControl; aTag: integer): TWinControl;

// Parse
function ParseByDelimiter(var RetStr: array of string; RetStrCount: integer; SrcStr: string; Delimiter: string): integer;

// Bit


function GetBitValue(Value: Byte; StartBit, BitSize: Integer): Byte;
function bitOn(const Value: integer; const TheBit: TBit): integer;
function bitOff(const Value: integer; const TheBit: TBit): integer;
function IsBitOn(const Value: integer; const TheBit: TBit): boolean;
function BitOnOff(const Value: integer; const TheBit: TBit; OnOff: boolean): integer;


procedure BitOnByIdx(var Value: DWORD; StartIdx, OnIdx: integer); overload;
procedure BitOnByIdx(var Value: DWORD; StartIdx, OnIdx, BitLen: integer); overload;

procedure BitOffByIdx(var Value: DWORD; StartIdx, OffIdx: integer);

function GetOnBitIdx(const Value: DWORD; StartIdx, BitLen: integer): integer;
procedure SetBitWord(var Value: WORD; const TheBit: TBit; IsOn: boolean);
procedure SetBit(var Value: DWORD; const TheBit: TBit; IsOn: boolean);
procedure SetBits(var Value: DWORD; const StartBit: TBit; IsOn: boolean; BitLen: integer);

function GetBit8(const X: byte; const nPos: integer): byte;
procedure SetBit8(var X: byte; const nPos: integer);
procedure ClearBit8(var X: byte; const nPos: integer);

function GetBit16(const X: WORD; const nPos: integer): byte;
procedure SetBit16(var X: WORD; const nPos: integer);
procedure ClearBit16(var X: WORD; const nPos: integer);


function GetBitStatus(const Data: array of Byte; StartByte, StartBit, BitCount: Integer): Integer;

// 문자열 처리

function ReadStr(FH: integer; var Str: AnsiString): boolean;
function WriteStr(FH: integer; Str: AnsiString): boolean;



// ETC
procedure TurnOnOffMonitor(IsOn : boolean);

function CalcSizes(TotSize: Integer; Ratios: array of Double): TArray<Integer>;

// Color
function IncRGB(Color: TColor; Val: integer): TColor;
function GradientFillRect(DC: HDC; const ARect: TRect; StartColor, EndColor: TColor; Vertical: Boolean): Boolean;



var GetTickCount64: Function(): uint64; stdcall;


implementation

uses
    TlHelp32, Math, UserTool, Rtti;


type
  PTriVertex = ^TTriVertex;
  TTriVertex = record
    X, Y: integer;
    Red, Green, Blue, Alpha: WORD;
  end;


function IncRGB(Color: TColor; Val: integer): TColor;
var
    ColorVal: TColor;
    R, G, B: BYTE;
begin

    ColorVal :=  ColorToRGB(Color);

    R := min(255, GetRValue(ColorVal) + Val);
    G := min(255, GetGValue(ColorVal) + Val);
    B := min(255, GetBValue(ColorVal) + Val);

    Result := RGB(R, G, B);
 end;

function GradientFill(DC: HDC; Vertex: PTriVertex; NumVertex: ULONG;  Mesh: Pointer; NumMesh, Mode: ULONG): BOOL; stdcall;
  external msimg32 name 'GradientFill';

function GradientFillRect(DC: HDC; const ARect: TRect; StartColor, EndColor: TColor; Vertical: Boolean): Boolean;
const
    Modes: array[Boolean] of ULONG = (GRADIENT_FILL_RECT_H, GRADIENT_FILL_RECT_V);
var
    Vertices: array[0..1] of TTriVertex;
    GRect: TGradientRect;
begin
    Vertices[0].X := ARect.Left;
    Vertices[0].Y := ARect.Top;
    Vertices[0].Red := GetRValue(ColorToRGB(StartColor)) shl 8;
    Vertices[0].Green := GetGValue(ColorToRGB(StartColor)) shl 8;
    Vertices[0].Blue := GetBValue(ColorToRGB(StartColor)) shl 8;
    Vertices[0].Alpha := 0;
    Vertices[1].X := ARect.Right;
    Vertices[1].Y := ARect.Bottom;
    Vertices[1].Red := GetRValue(ColorToRGB(EndColor)) shl 8;
    Vertices[1].Green := GetGValue(ColorToRGB(EndColor)) shl 8;
    Vertices[1].Blue := GetBValue(ColorToRGB(EndColor)) shl 8;
    Vertices[1].Alpha := 0;

    GRect.UpperLeft := 0;
    GRect.LowerRight := 1;

    Result := GradientFill(DC, @Vertices, 2, @GRect, 1, Modes[Vertical]);
end;


// -----------------------------------------------------------------------
// -----------------------------------------------------------------------
// -----------------------------------------------------------------------
function GetBit8(const X: byte; const nPos: integer): byte;
begin

    ASSERT((0 <= nPos) and (nPos < 8));

    Result := (X shr nPos) and $01;

end;

// -----------------------------------------------------------------------
procedure SetBit8(var X: byte; const nPos: integer);
begin

    ASSERT((0 <= nPos) and (nPos < 8));

    X := X or ($01 shl nPos);

end;

// -----------------------------------------------------------------------
procedure ClearBit8(var X: byte; const nPos: integer);
begin

    ASSERT((0 <= nPos) and (nPos < 8));

    X := X and (not($01 shl nPos));

end;

// -----------------------------------------------------------------------
// -----------------------------------------------------------------------
function GetBit16(const X: WORD; const nPos: integer): byte;
begin

    ASSERT((0 <= nPos) and (nPos < 16));

    Result := (X shr nPos) and $01;

end;

// -----------------------------------------------------------------------
procedure SetBit16(var X: WORD; const nPos: integer);
begin

    ASSERT((0 <= nPos) and (nPos < 16));

    X := X or ($01 shl nPos);

end;

// -----------------------------------------------------------------------
procedure ClearBit16(var X: WORD; const nPos: integer);
begin

    ASSERT((0 <= nPos) and (nPos < 16));

    X := X and (not($01 shl nPos));

end;

// -----------------------------------------------------------------------
// -----------------------------------------------------------------------
function TimeToString(Hour, Min, Sec: String): TDateTime;
begin
    Result := EncodeTime(StrToInt(Hour), StrToInt(Min), StrToInt(Sec), 00);
end;

// -----------------------------------------------------------------------
function DrawTitle(var Grid: TStringGrid; Datas: TStrings): boolean;
var
    i: integer;
begin
    Result := true;
    if Datas.Count <= 0 then
        Result := false;
    Grid.RowCount := Datas.Count;
    for i := 0 to Datas.Count - 1 do
    begin
        Grid.Cells[i, 0] := Datas.Strings[i];
    end;
end;

// ---------------------------------------------------------------------------
{ function GetIniFiles : string;
  var
  i  : integer;
  szHomeDirectory : string;
  begin
  szHomeDirectory := ExtractFileName(ParamStr(0)) ;

  for i := 1 to Length(szHomeDirectory) do  if (szHomeDirectory[i] = '.') then break ;
  szHomeDirectory := Copy(szHomeDirectory,1,i);

  result := ExtractFileDir(ParamStr(0)) + '\' + szHomeDirectory + 'ini';
  end; }
// ---------------------------------------------------------------------------
function IsFileExisted(sDir, sFileName: string): boolean;
begin
    sFileName := MakeRunPath(sDir) + '\' + sFileName;
    Result := FileExists(sFileName);
end;

// -------------------------------------------------------------------------
function IsDeleteFiled(sFileName: string): boolean;
begin
    Result := DeleteFile(sFileName);
end;

// -------------------------------------------------------------------------
// 구분자의 앞의 단어만 솎아 준다....
function DelSeparator(sData: string; Separator: Char): string;
var
    tmp: string;
    i, Len: integer;
begin
    tmp := '';
    Len := Length(sData);
    for i := 1 to Len - 1 do
    begin
        if (sData[i] <> Separator) then
            tmp := tmp + sData[i]
        else
            Break;
    end;
    Result := tmp;
end;

// -------------------------------------------------------------------------
// File Stream을 이용한 복사
function FileCopy(orgFileName, tagFileName: string): boolean;
var
    source, Target: TFileStream;
begin
    Result := false;

    if not FileExists(orgFileName) then
        System.Exit;

    Result := true;
    source := TFileStream.Create(orgFileName, fmOpenRead);
    try
        Target := TFileStream.Create(tagFileName, fmOpenWrite or fmCreate);
        try
            Target.CopyFrom(source, source.Size);
        finally
            Target.Free;
        end;
    finally
        source.Free;
    end;
end;

// -------------------------------------------------------------------------
function GetIndex(InputTime: TDateTime): integer;
var
    yy, mm, dd: WORD;
begin
    DecodeDate(InputTime, yy, mm, dd);
    Result := integer(dd) * 100 + 1;
end;
// -------------------------------------------------------------------------

// -------------------------------------------------------------------------

function GetVInfo(app: TApplication; ID: String): String;
var
    nHandle, nSize: DWORD;
    nBuffer, tmpStr: String;
begin
    nSize := GetFileVersionInfoSize(pCHAR(app.ExeName), nHandle);
    if nSize <= 0 then
        Result := 'Cant Read';

    // initialize buffer
    SetLength(nBuffer, nSize);
    // get the version info
    GetFileVersionInfo(pCHAR(app.ExeName), nHandle, nSize, pCHAR(nBuffer));

    // 040904E4 value is the Locale Id as set on the projects
    // Version Info tab
    if VerQueryValue(pCHAR(nBuffer), pCHAR('\StringFileInfo\' + ID + '\' + 'FileVersion'), Pointer(tmpStr), nSize) then
        Result := StrPas(pCHAR(tmpStr))
    else
        Result := ' ' + 'FileVersion' + ' not available';
end;

// -------------------------------------------------------------------------
function GetUsrFloatToStr(Val: double; Digit: integer): string;
var
    FmtStr: String;
    i: integer;
begin

    if Digit < 0 then
        FmtStr := '0'
    else
        FmtStr := '0.';

    for i := 0 to Digit do
    begin
        FmtStr := FmtStr + '0';
    end;

    Result := FormatFloat(FmtStr, Val);

end;
// -------------------------------------------------------------------------

// -------------------------------------------------------------------------
function BufferToHexStr(Buffer: PByte; Len: integer; IsShowAscii: boolean): string;
var
    i: integer;
begin
    for i := 0 to Len - 1 do
    begin
        Result := Result + Format('%.2X ', [Buffer[i]]);
    end;

    if IsShowAscii then
    begin
        Result := Result + ': ';
        for i := 0 to Len - 1 do
        begin
            if Buffer[i] = 0 then
                Result := Result + ' '
            else
                Result := Result + Char(Buffer[i]);
        end;

    end;

end;
// -------------------------------------------------------------------------
function MyTrim(Str: string): string;
begin
    Result := StringReplace(Str, ' ', '', [rfReplaceAll]);
end;
// -------------------------------------------------------------------------
function GetStrToInt(sValue: String): integer;
var
    rValue, eValue: integer;
begin
    Result := 0;
    Val(sValue, rValue, eValue);
    if eValue = 0 then
        Result := rValue;
end;

// -------------------------------------------------------------------------
function GetStrToFloat(sValue: string): double;
var
    i: integer;
    sTm: string;
begin
    try
        sTm := '';
        for i := 1 to Length(sValue) do
        begin
            if not(sValue[i] In ['0' .. '9', '.', '+', '-']) then
                Break
            else
                sTm := sTm + sValue[i];
        end;
        // 2005.09.30
        i := Pos('.', sTm);
        if (i > 0) and (i = Length(sTm)) then
            sTm := sTm + '0';
        // ----------
        Result := StrToFloat(sTm);
    except
        Result := 0.0;
    end;
end;
// -------------------------------------------------------------------------

procedure SetPort(address, Value: WORD);
var
    bValue: byte;
begin
    bValue := trunc(Value and 255);
  asm
    mov dx, address
    mov al, bValue
    out dx, al
  end;
end;

function GetPort(address: WORD): WORD;
var
    bValue: byte;
begin
  asm
    mov dx, address
    in al, dx
    mov bValue, al
  end;
    GetPort := bValue;
end;

procedure Sound(Freq: WORD);
var
    B: byte;
begin
    if Freq > 18 then
    begin
        Freq := WORD(1193181 div LongInt(Freq));
        B := byte(GetPort($61));

        if (B and 3) = 0 then
        begin
            SetPort($61, WORD(B or 3));
            SetPort($43, $B6);
        end;

        SetPort($42, Freq);
        SetPort($42, Freq shr 8);
    end;
end;

procedure NoSound;
var
    Value: WORD;
begin
    Value := GetPort($61) and $FC;
    SetPort($61, Value);
end;

function SetTextComboBox(var mycbx: TComboBox): integer;
var
    checked: boolean;
    sName: String;
    i: integer;
begin
    checked := true;
    if (mycbx.Text <> '') then
    begin
        sName := mycbx.Text;
        For i := 0 to mycbx.items.Count - 1 do
        begin
            if mycbx.Text = mycbx.items.Strings[i] then
            begin
                if i > 0 then
                begin
                    checked := true;
                    mycbx.items.Delete(i);
                end
                else
                    checked := false;
            end
            else
            begin
                if (mycbx.items.Strings[i] = '') then
                    mycbx.items.Delete(i);
            end;
        end;
        if checked then
        begin
            mycbx.items.Insert(0, sName);
            mycbx.ItemIndex := 0;
        end;
    end
    else
        mycbx.ItemIndex := 0;

    Result := mycbx.items.Count;
end;

function IntToZeroStr(n: integer; m: byte): string;
var
    i, w: integer;
    s: string;
begin
    s := IntToStr(n);
    w := m - Length(s);
    for i := 1 to w do
        s := '0' + s;
    Result := s;
end;

function SplitBack(Name: string; Sep: Char): string;
var
    i: integer;
begin
    for i := Length(Name) downto 1 do
    begin
        if Name[i] = Sep then
        begin
            Delete(Name, 1, i);
            Trim(Name);
            Break;
        end;
    end;
    Result := Name;
end;

function GetUserTime(Times: TDateTime; types: TTYPE_TIME): integer;
var
    hh, nn, ss, mm: WORD;
begin
    DecodeTime(Times, hh, nn, ss, mm);
    case types of
        ty_HOURE:
            Result := Round(hh + (nn / 60) + (ss / 3600));
        ty_MIN:
            Result := Round((hh * 60) + nn + (ss / 60));
        ty_SEC:
            Result := Round((hh * 3600) + (nn * 60) + ss);
    else
        Result := 0;
    end;
end;

function GetUserSepTime(Times: TDateTime; types: TTYPE_TIME): integer;
var
    hh, nn, ss, mm: WORD;
begin
    DecodeTime(Times, hh, nn, ss, mm);
    case types of
        ty_HOURE:
            Result := hh;
        ty_MIN:
            Result := nn;
        ty_SEC:
            Result := ss;
    else
        Result := 0;
    end;
end;

function GetMinToTime(Min: LongInt): TDateTime;
begin
    Result := (1.0 / (24 * 60)) * Min;
end;

function SetUserTime(Times: integer; types: TTYPE_TIME): TDateTime;
begin
    Result := 0;
    case types of
        ty_HOURE:
            Result := EncodeTime(Times mod 24, 0, 0, 0);
        ty_MIN:
            Result := EncodeTime(0, Times mod 60, 0, 0);
        ty_SEC:
            Result := EncodeTime(0, 0, Times mod 60, 0);
        ty_MM:
            Result := EncodeTime(0, 0, 0, Times mod 1000);
    end;
end;

function GetExistTime(Times: TDateTime; types: TTYPE_TIME): integer;
var
    hh, nn, ss, Ms: WORD;
begin
    Result := 0;
    DecodeTime(Times, hh, nn, ss, Ms);
    case types of
        ty_HOURE:
            Result := hh;
        ty_MIN:
            Result := nn;
        ty_SEC:
            Result := ss;
    end;
end;

function IsValidTime(var Times: TDateTime; Hour, Min, Sec, Ms: WORD): boolean;
begin
    Result := false;
    if (not(Hour In [0 .. 23])) or (not(Min In [0 .. 59])) or (not(Sec In [0 .. 59])) or (Ms > 999) then
        Exit;

    Times := EncodeTime(Hour, Min, Sec, Ms);

end;

function IsValidDate(var Dates: TDateTime; Year, Mon, Day: WORD): boolean;
begin
    Result := false;
    if (Year < 1) or (Year > 9999) or (not(Mon In [1 .. 12])) or (not(Day In [1 .. 31])) then
        Exit;
    if (Mon = 2) and (not(Day In [1 .. 29])) then
        Exit;

    try
        Dates := EncodeDate(Year, Mon, Day);
    except
        Result := false;
        Exit;
    end;
    Result := true;
end;

function GetJulianDate(Times: TDateTime): Extended;
var
    A, B: integer;
    yy, mm, dd: WORD;
begin
    DecodeDate(Times, yy, mm, dd);

    if mm > 2 then
    begin
        A := yy div 100;
        B := 2 - A + (A div 4);
    end
    else
    begin
        yy := yy - 1;
        mm := mm + 12;
        B := 0;
    end;
    Result := trunc(365.25 * (yy + 4716)) + trunc(30.6001 * (mm + 1)) + dd + B - 1524.5;
end;

// 오늘이 무슨요일이가요?
function GetTodayOnWeek(Times: TDateTime): integer;
// Array of Weeks = ('일', '월', '화', '수', '목', '금', '토') ;
begin
    Result := trunc(GetJulianDate(Times) + 1.5) mod 7;
    if Result > 5 then
        Result := Result - 6
    else
        Result := Result + 1;
end;

// 오늘이 이해의 몇번째 날인가요?
function GetTodayOnYear(Times: TDateTime): integer;
var
    yy, mm, dd: WORD;
    K: integer;
begin
    DecodeDate(Times, yy, mm, dd);
    if IsLeapYear(yy) then
        K := 1
    else
        K := 2;

    Result := trunc((275 * mm) / 9) - (K * trunc((mm + 9) / 12)) + dd - 30;
end;

function GetDateTimes(Mons: integer): TDateTime;
begin
    Result := Mons * 30;
end;

function NextMonths(Day: integer; Times: TDateTime): TDateTime;
var
    yy, mm, dd: WORD;
begin
    if not(Day In [1 .. 31]) then
        Day := 1;
    DecodeDate(Now(), yy, mm, dd);
    mm := mm + 1;
    if mm > 12 then
    begin
        yy := yy + 1;
        mm := 1;
    end;
    dd := Day;
    if (mm = 2) and (dd > 28) then
        dd := 28;
    Result := trunc(EncodeDate(yy, mm, dd)) + (Times - trunc(Times));
end;

function NextWeeks(Week: integer; Times: TDateTime): TDateTime;
begin
    if not(Week In [1 .. 7]) then
        Week := 1;
    Result := trunc(Now()) + (Times - trunc(Times)) + 1;
    while DayOfWeek(Result) <> Week do
        Result := Result + 1;
end;

function NextDays(Times: TDateTime): TDateTime;
begin
    Result := trunc(Now()) + (Times - trunc(Times));
    Result := Result + 1;
end;

function IsNT(): boolean;
var
    os: TOSVERSIONINFO;
begin
    os.dwPlatformId := 0;
    os.dwOSVersionInfoSize := sizeof(OSVERSIONINFO);
    GetVersionEx(os);

    // 이 부분을 조정하면 XP 까지 사용할 것으로 생각됨
    Result := (os.dwPlatformId = VER_PLATFORM_WIN32_NT);
end;

procedure Zap(const dirPath: String);
// 저작권 : 노땅...
var
    done: integer;
    srFiles: TSearchRec;
begin
    done := FindFirst(dirPath + '\*.*', faAnyFile, srFiles);
    try
        while done = 0 do
        begin
            // 메세지 펌프질.
            Application.ProcessMessages();
            if srFiles.Name[1] <> '.' then
            begin
                if (srFiles.Attr and faDirectory) = faDirectory then
                begin
                    // SUB DIRECTORY이면 자기자신을 호출
                    Zap(dirPath + '\' + srFiles.Name);

                    // 그리곤 호출한 폴더 삭제...
                    RemoveDir(dirPath + '\' + srFiles.Name);
                end
                else
                begin
                    // 파일이면 파일 삭제...
                    DeleteFile(dirPath + '\' + srFiles.Name);
                end;
            end;
            done := FindNext(srFiles);
        end;
    finally
        FindClose(srFiles);
    end;
end;

function FindAllFileExs(Dirs, Target: string; List: TStrings; ALimit: integer; PerForm: TGOLD_IDXs): integer;
var
    i: integer;
    sTm, nHead, nTail: string;
begin
    Result := FindAllFilesEx(Dirs, List, ALimit, PerForm);
    if Target <> '' then
    begin
        if Pos('*', Target) > 0 then
        begin
            try
                nHead := Copy(Target, 1, Pos('*', Target) - 1);
                nTail := Copy(Target, Pos('*', Target) + 1, Length(Target) - Pos('*', Target));
            except
                nHead := '';
                nTail := '';
            end;
        end
        else
        begin
            nHead := Target;
            nTail := '';
        end;

        for i := List.Count - 1 downto 0 do
        begin
            sTm := ExtractFileName(List.Strings[i]);
            if (sTm = '') or ((nHead <> '') and (Pos(UpperCase(nHead), UpperCase(sTm)) <= 0)) or ((nTail <> '') and (Pos(UpperCase(nTail), UpperCase(sTm)) <= 0)) then
                List.Delete(i);
        end;
    end;
end;

function FindAllFileFxs(Dirs, Target: string; List: TStrings; PerForm: TGOLD_IDXs): integer;
var
    done: integer;
    srFile: TSearchRec;
    asFile: string;
begin
    Result := 0;
    if List = nil then
        Exit;
    try
        if Dirs = '' then
            Exit;
        if not(Dirs[Length(Dirs)] In ['\']) then
            Dirs := Dirs + '\';
    except
        Exit;
    end;

    asFile := '';
    done := SysUtils.FindFirst(Dirs + Target, faAnyFile, srFile);
    try
        while done = 0 do
        begin
            if srFile.Name[1] <> '.' then
            begin
                if (ID_FILES In PerForm) and ((srFile.Attr and faDirectory) = 0) then
                begin
                    List.AddObject(Dirs + srFile.Name, TObject(ID_FILES));
                end;
                if ((ID_DIR In PerForm) or (ID_SUBDIR In PerForm)) and ((srFile.Attr and faDirectory) <> 0) then
                begin
                    if ID_DIR In PerForm then
                        List.AddObject(Dirs + srFile.Name, TObject(ID_DIR));

                    if ID_SUBDIR In PerForm then
                        FindAllFileFxs(Dirs, Target, List, PerForm);
                end;
            end;
            done := SysUtils.FindNext(srFile);
        end;
    finally
        SysUtils.FindClose(srFile);
    end;
    Result := List.Count;
end;

function FindAllFilesEx(Dirs: string; List: TStrings; ALimit: integer; PerForm: TGOLD_IDXs): integer;
var
    done: integer;
    srFile: TSearchRec;
    asFile: string;
begin
    Result := 0;
    if List = nil then
        Exit;
    try
        if Dirs = '' then
            Exit;
        if not(Dirs[Length(Dirs)] In ['\']) then
            Dirs := Dirs + '\';
    except
        Exit;
    end;

    asFile := '';
    done := SysUtils.FindFirst(Dirs + '*.*', faAnyFile, srFile);
    try
        while done = 0 do
        begin
            if srFile.Name[1] <> '.' then
            begin
                if (ID_FILES In PerForm) and ((srFile.Attr and faDirectory) = 0) then
                begin
                    List.AddObject(Dirs + srFile.Name, TObject(ID_FILES));
                    if (ALimit > 0) and (List.Count > ALimit) then
                        Break;
                end
                else if ((ID_DIR In PerForm) or (ID_SUBDIR In PerForm)) and ((srFile.Attr and faDirectory) <> 0) then
                begin
                    if ID_DIR In PerForm then
                    begin
                        List.AddObject(Dirs + srFile.Name, TObject(ID_DIR));
                        if (ALimit > 0) and (List.Count > ALimit) then
                            Break;
                    end;

                    if ID_SUBDIR In PerForm then
                        FindAllFiles(Dirs + srFile.Name, List, PerForm);
                end;
            end;
            done := SysUtils.FindNext(srFile);
        end;
    finally
        SysUtils.FindClose(srFile);
    end;
    Result := List.Count;
end;

function FindAllFiles(Dirs: string; List: TStrings; PerForm: TGOLD_IDXs): integer;
begin
    Result := FindAllFilesEx(Dirs, List, 0, PerForm);
end;

function GetFileSize(const FileName: string): integer;
var
    done: integer;
    srFile: TSearchRec;
begin
    Result := -1;
    done := FindFirst(FileName, faAnyFile, srFile);
    try
        if (done = 0) and ((srFile.Attr and faDirectory) = 0) then
        begin
            Result := srFile.Size;
        end;
    finally
        FindClose(srFile);
    end;
end;

function FolderSize(Dir: string): Int64;
var
    SearchRec: TSearchRec;
    Separator: string;
begin
    Result := 0;
    if Copy(Dir, Length(Dir), 1) = '\' then
        Separator := ''
    else
        Separator := '\';

    if FindFirst(Dir + Separator + '*.*', faAnyFile, SearchRec) = 0 then
    begin
        if FileExists(Dir + Separator + SearchRec.Name) then
        begin
            Result := Result + SearchRec.Size;
        end
        else if DirectoryExists(Dir + Separator + SearchRec.Name) then
        begin
            if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
            begin
                Result := Result + FolderSize(Dir + Separator + SearchRec.Name);
            end;
        end;
        while FindNext(SearchRec) = 0 do
        begin
            if FileExists(Dir + Separator + SearchRec.Name) then
            begin
                Result := Result + SearchRec.Size;
            end
            else if DirectoryExists(Dir + Separator + SearchRec.Name) then
            begin
                if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
                begin
                    Result := Result + FolderSize(Dir + Separator + SearchRec.Name);
                end;
            end;
        end;
    end;
    FindClose(SearchRec);
end;

function GetFileTimeToDateTime(const afTime: TFileTime; var Times: TDateTime): boolean;
var
    nTime: SYSTEMTIME;
    nFileTime: TFileTime;
begin
    Result := false;
    if not FileTimeToLocalFileTime(afTime, nFileTime) then
        Exit;
    if FileTimeToSystemTime(nFileTime, nTime) then
    begin
        with nTime do
        begin
            Times := EncodeDate(wYear, wMonth, wDay) + EncodeTime(wHour, wMinute, wSecond, wMilliseconds);
        end;
        Result := true;
    end;
end;

function GetCreateTime(const aFileName: string; var Times: TDateTime): boolean;
var
    done: integer;
    srFile: TSearchRec;
begin
    Result := false;
    done := FindFirst(aFileName, faAnyFile, srFile);
    try
        if (done = 0) and ((srFile.Attr and faDirectory) = 0) then
        begin
            with srFile.FindData do
                Result := GetFileTimeToDateTime(ftCreationTime, Times);
        end;
    finally
        FindClose(srFile);
    end;
end;

function GetLastAccessTime(const aFileName: string; var Times: TDateTime): boolean;
var
    done: integer;
    srFile: TSearchRec;
begin
    Result := false;
    done := FindFirst(aFileName, faAnyFile, srFile);
    try
        if (done = 0) and ((srFile.Attr and faDirectory) = 0) then
        begin
            with srFile.FindData do
                Result := GetFileTimeToDateTime(ftLastAccessTime, Times);
        end;
    finally
        FindClose(srFile);
    end;
end;

function GetLastWriteTime(const aFileName: string; var Times: TDateTime): boolean;
var
    done: integer;
    srFile: TSearchRec;
begin
    Result := false;
    done := FindFirst(aFileName, faAnyFile, srFile);
    try
        if (done = 0) and ((srFile.Attr and faDirectory) = 0) then
        begin
            with srFile.FindData do
                Result := GetFileTimeToDateTime(ftLastWriteTime, Times);
        end;
    finally
        FindClose(srFile);
    end;
end;

// ---------------------------------------------------------------------------
function GetIniFiles: string;
var
    i: integer;
    szHomeDirectory: string;
begin
    szHomeDirectory := ExtractFileName(ParamStr(0));

    for i := 1 to Length(szHomeDirectory) do
        if (szHomeDirectory[i] = '.') then
            Break;
    szHomeDirectory := Copy(szHomeDirectory, 1, i);

    Result := ExtractFileDir(ParamStr(0)) + '\' + szHomeDirectory + 'ini';
end;

// ---------------------------------------------------------------------------
function GetHomeDirectory: string;
begin
    Result := ExtractFileDir(ParamStr(0));
end;

// ---------------------------------------------------------------------------
function MakeRunPath(const szName: String): string;
begin
    Result := GetHomeDirectory() + '\' + szName;
end;

// ---------------------------------------------------------------------------
function GetFileSizeTxt(aSize: Int64; aType: integer): string;
begin
    Result := '';
    case aType of
        ord(stBYTES):
            begin
                if (aSize / 1024) > 1.0 then
                    Result := GetFileSizeTxt(aSize, ord(stKB))
                else
                    Result := Format('%0.1f Bytes', [aSize]);
            end;
        ord(stKB):
            begin
                if (aSize / 1024 / 1024) > 1.0 then
                    Result := GetFileSizeTxt(aSize, ord(stMB))
                else
                    Result := Format('%0.1f KB', [aSize / 1024]);
            end;
        ord(stMB):
            begin
                if (aSize / 1024 / 1024 / 1024) > 1.0 then
                    Result := GetFileSizeTxt(aSize, ord(stGB))
                else
                    Result := Format('%0.1f KB', [aSize / 1024]);
            end;
        ord(stGB):
            Result := Format('%0.1f GB', [aSize / 1024 / 1024 / 1024]);
    end;
end;

// ---------------------------------------------------------------------------
function GetAccurateTime: double;
var
    liEndCounter, liFrequency: TLARGEINTEGER;
begin
    try
        QueryPerformanceCounter(liEndCounter);
        QueryPerformanceFrequency(liFrequency);
        Result := (liEndCounter / liFrequency) * 1000;
    except
        Result := -1;
    end;
end;

// ---------------------------------------------------------------------------
procedure AlignGrid(var Grid: TStringGrid; ACol, ARow: integer; Rect: TRect; State: TGridDrawState; Aligns: array of integer);
var
    X, Y: integer;
begin
    X := 0;
    if ACol > High(Aligns) then
        Exit;
    Y := Rect.Top + (Rect.Bottom - Rect.Top) div 4;
    with Grid do
    begin
        Canvas.Font.Size := Font.Size;
        Canvas.Font.Name := Font.Name;
        Canvas.Font.Color := clBlack;
        if (ARow < FixedRows) or (ACol < FixedCols) then
        begin
            GradientFillRect(Canvas.Handle, Rect, IncRGB(Grid.FixedColor, 20), Grid.FixedColor, true);
            SetBkMode(Canvas.Handle, TRANSPARENT);
            DrawText(Canvas.Handle, PChar(Cells[ACol, ARow]), Length(Cells[ACol, ARow]), Rect, DT_CENTER or DT_VCENTER or DT_SINGLELINE);
            Frame3D(Canvas, Rect, clWhite, clGray, 1);
        end
        else
        begin
            SetTextAlign(Canvas.Handle, Aligns[ACol]);
            // if State = [gdSelected, gdFocused] then
            if (State = [gdSelected]) or (State = [gdSelected, gdFocused]) then
            begin
                Canvas.Brush.Color := clHighLight;
                Canvas.Font.Color := clWhite;
            end
            else
                Canvas.Brush.Color := Color;

            case Aligns[ACol] of
                TA_CENTER:
                    X := (Rect.Left + Rect.Right) div 2;
                TA_LEFT:
                    X := Rect.Left + 5;
                TA_RIGHT:
                    X := Rect.Right - 5;
            end;
            Canvas.TextRect(Rect, X, Y, Cells[ACol, ARow]);
        end;
    end;
end;

// 항상 실수로 만들어 준다.
function ExtToStr(Val: double): string;
begin
    Result := FloatToStr(Val);

    if Pos('.', Result) <= 0 then
    begin
        Result := Result + '.0';
    end;
end;

function SetDisp(Sec: integer): string;
var
    hh, nn, ss: string;
begin
    hh := IntToZeroStr(Sec div 3600, 2);
    nn := IntToZeroStr(Sec div 60 mod 60, 2);
    ss := IntToZeroStr(Sec mod 60, 2);
    Result := Format('%s:%s:%s', [hh, nn, ss]);
end;

procedure ClearGrid(var Grid: TStringGrid; StartRow, RowCount: integer);
var
    i: integer;
begin
    // Grid.RowCount := RowCount;

    for i := StartRow to RowCount - 1 do
    begin
        Grid.Rows[i].Clear();
    end;
    Grid.Row := StartRow;
    Grid.Tag := StartRow;
    Grid.RowCount := 2;
end;

{ include ShellAPI, shlobj }
function GetUserFolder(awsnHandle: HWND; aTitle: string): string;
var
    BrowseInfo: TBrowseInfo;
    PIDL: PItemIDList;
    DisplayName: array [0 .. MAX_PATH] of Char;
begin
    Result := '';

    FillChar(BrowseInfo, sizeof(BrowseInfo), #0);
    BrowseInfo.hwndOwner := awsnHandle; // parent handle
    BrowseInfo.pszDisplayName := @DisplayName[0];
    if aTitle = '' then
        BrowseInfo.lpszTitle := 'Select Directory'
    else
        BrowseInfo.lpszTitle := pCHAR(aTitle);
{$IFDEF VER150}
    BrowseInfo.ulFlags := BIF_RETURNONLYFSDIRS or BIF_NEWDIALOGSTYLE;
{$ELSE}
    BrowseInfo.ulFlags := BIF_RETURNONLYFSDIRS;
{$ENDIF}
    PIDL := SHBrowseForFolder(BrowseInfo);
    if Assigned(PIDL) then
        if SHGetPathFromIDList(PIDL, DisplayName) then
            Result := DisplayName;
end;

{
  //  BFFCALLBACK = function(Wnd: HWND; uMsg: UINT; lParam, lpData: LPARAM): Integer stdcall;
  //  TFNBFFCallBack = type BFFCALLBACK;
  function BrowserCallBackProc(Wnd: HWND; uMsg: UINT; lParam, lpData: LPARAM): Integer stdcall ;
  begin
  case uMsg of
  BFFM_INITIALIZED :
  begin
  SendMessage(Wnd,
  BFFM_SETSELECTION,
  integer(true),
  integer(PChar(지정할 디렉토리))) ;
  // wParam 이 true 이면 lParam 경로
  // wParam 이 false이면 lParam PIDL
  end ;
  end ;
  end ;
}
function GetUserFolderEx(awsnHandle: HWND; ACallBack: TFNBFFCallBack; aTitle: string): string;
var
    BrowseInfo: TBrowseInfo;
    PIDL: PItemIDList;
    DisplayName: array [0 .. MAX_PATH] of Char;
begin
    Result := '';

    FillChar(BrowseInfo, sizeof(BrowseInfo), #0);
    BrowseInfo.hwndOwner := awsnHandle; // parent handle
    BrowseInfo.pszDisplayName := @DisplayName[0];
    if aTitle = '' then
        BrowseInfo.lpszTitle := 'Select Directory'
    else
        BrowseInfo.lpszTitle := pCHAR(aTitle);
{$IFDEF VER150}
    BrowseInfo.ulFlags := BIF_RETURNONLYFSDIRS or BIF_NEWDIALOGSTYLE;
{$ELSE}
    BrowseInfo.ulFlags := BIF_RETURNONLYFSDIRS;
{$ENDIF}
    BrowseInfo.lpfn := ACallBack;

    PIDL := SHBrowseForFolder(BrowseInfo);
    if Assigned(PIDL) then
        if SHGetPathFromIDList(PIDL, DisplayName) then
            Result := DisplayName;
end;

procedure BubbleSort(Sort: TDataCompare; Change: TDataChange; First, Last: integer);
var
    i, j, K: integer;
begin
    K := Last;

    while { (k >= 0) or } (K >= First) do
    begin
        j := -1;
        for i := First + 1 to K do
        begin
            if Sort(i - 1, i) > 0 then
            begin
                j := i - 1;
                Change(i, j);
            end;
        end;
        K := j;
    end;
end;

procedure BubbleSort(var aAry: array of Variant; First, Last: integer);
var
    i, j, K: integer;
    tmp: Variant;
begin
    K := Last;

    while { (k >= 0) or } (K >= First) do
    begin
        j := -1;
        for i := First + 1 to K do
        begin
            if aAry[i - 1] > aAry[i] then
            begin
                j := i - 1;
                tmp := aAry[j];
                aAry[j] := aAry[i];
                aAry[i] := tmp;
            end;
        end;
        K := j;
    end;
end;

procedure QuickSort(var aAry: array of Variant; First, Last: integer);
var
    i, j: integer;
    tmp: Variant;
    std: Variant;
begin
    std := aAry[(First + Last) div 2];

    i := First;
    j := Last;
    while true do
    begin
        while (aAry[i] < std) do
            Inc(i);
        while (aAry[j] > std) do
            dec(j);
        if (i >= j) then
            Break;
        tmp := aAry[i];
        aAry[i] := aAry[j];
        aAry[j] := tmp;
        Inc(i);
        dec(j);
    end;

    if (First < i - 1) then
        QuickSort(aAry, First, i - 1);
    if (j + 1 < Last) then
        QuickSort(aAry, j + 1, Last);
end;

procedure QuickSort(Sort: TDataCompare; Change: TDataChange; First, Last: integer);
var
    i, j: integer;
    std: integer;
begin
    std := (First + Last) div 2;

    i := First;
    j := Last;
    while true do
    begin
        while Sort(i, std) < 0 do
            Inc(i);
        while Sort(j, std) > 0 do
            dec(j);
        if (i >= j) then
            Break;

        Change(i, j);
        Inc(i);
        dec(j);
    end;

    if (First < i - 1) then
        QuickSort(Sort, Change, First, i - 1);
    if (j + 1 < Last) then
        QuickSort(Sort, Change, j + 1, Last);
end;

{
  procedure QuickSort(var aAry: array of double;First, Last:integer) ;
  var
  i,
  j   : integer ;
  Tmp : double ;
  std : double ;
  begin
  std := aAry[(First+Last) div 2] ;

  i := First;
  j := Last;
  while true do
  begin
  while (aAry[i] < std) do Inc(i) ;
  while (aAry[j] > std) do dec(j) ;
  if (i >= j) then Break ;
  Tmp := aAry[i] ;
  aAry[i]   := aAry[j] ;
  aAry[j]   := Tmp ;
  Inc(i) ;
  Dec(j) ;
  end ;

  if (First < i - 1) then QuickSort(aAry, First, i - 1) ;
  if (j + 1 < Last)  then QuickSort(aAry, j + 1, Last) ;
  end ;
}
procedure GetAllWindowsProc(WinHandle: HWND; Slist: TStrings);
var
    P: array [0 .. 256] of Char; { title bar를 저장 할 buffer }
begin
    P[0] := #0;
    GetWindowText(WinHandle, P, 255); { window's title bar를 알아낸다 }
    if (P[0] <> #0) then
        if IsWindowVisible(WinHandle) then { invisible한 window는 제외 }
            Slist.AddObject(P, TObject(WinHandle)); { window의 handle 저장 }
end;

procedure GetAllWindows(Slist: TStrings);
var
    WinHandle: HWND;
Begin
    WinHandle := FindWindow(nil, nil);
    GetAllWindowsProc(WinHandle, Slist);
    while (WinHandle <> 0) do { Top level의 window부터 순차적으로 handle을 구한다 }
    begin
        WinHandle := GetWindow(WinHandle, GW_HWNDNEXT);
        GetAllWindowsProc(WinHandle, Slist);
    end;
end;

procedure SetCloseWindow(aName: string);
var
    h: HWND;
begin
    h := FindWindow(nil, pCHAR(aName)); // vPhoen kill
    if h <> 0 then
        PostMessage(h, WM_CLOSE, 0, 0);
end;

procedure SetTimePickerFormat(aPicker: TDateTimePicker; aFormat: string);
begin
    SendMessage(aPicker.Handle, $1005, 0, LongInt(pCHAR(aFormat)));
end;

procedure SetMyTimeFormat(aForm: TForm);
var
    i: integer;
begin
    with aForm do
    begin
        for i := 0 to ComponentCount - 1 do
        begin
            if (Components[i].ClassName = 'TDateTimePicker') and (TDateTimePicker(Components[i]).Kind = dtkTime) then
            begin
                SetTimePickerFormat(TDateTimePicker(Components[i]), 'HH:mm:ss');
            end
            else if (Components[i].ClassName = 'TDateTimePicker') and (TDateTimePicker(Components[i]).Kind = dtkDate) then
            begin
                SetTimePickerFormat(TDateTimePicker(Components[i]), 'yyyy-MM-dd');
            end;
        end;
    end;
end;

procedure CheckDirAndMade(aDir: string);
var
    i: integer;
    sTm, nDir: string;
begin
    if (aDir = '') or (Length(aDir) < 2) then
        Exit;

    if ExtractFileDrive(aDir) = '' then
        aDir := GetHomeDirectory() + '\' + aDir;

    nDir := '';
    sTm := ExtractFileDir(aDir);
    if sTm = '' then
        sTm := aDir;
    for i := 1 to Length(sTm) do
    begin
        if (i > 2) and (sTm[i] = '\') then
        begin
            if not DirectoryExists(nDir) then
                ForceDirectories(nDir);
        end;
        nDir := nDir + sTm[i];
    end;
    if not DirectoryExists(sTm) then
        ForceDirectories(sTm);
end;

function GetBitValue(Value: Byte; StartBit, BitSize: Integer): Byte;
var
    Mask: Byte;
begin

    Mask := (1 shl BitSize) - 1;
    Mask := Mask shl StartBit;


    Result := (Value and Mask) shr StartBit;
end;

function bitOn(const Value: integer; const TheBit: TBit): integer;
begin
    Result := Value or (1 shl TheBit);
end;

function bitOff(const Value: integer; const TheBit: TBit): integer;
begin
    Result := Value and ((1 shl TheBit) xor $FFFFFFFF);
end;

function IsBitOn(const Value: integer; const TheBit: TBit): boolean;
begin
    Result := (Value and (1 shl TheBit)) = (1 shl TheBit);
end;

function BitOnOff(const Value: integer; const TheBit: TBit; OnOff: boolean): integer;
begin
    if OnOff then
        Result := bitOn(Value, TheBit)
    else
        Result := bitOff(Value, TheBit)
end;

procedure BitOnByIdx(var Value: DWORD; StartIdx, OnIdx: integer);
begin
    Value := bitOn(Value, StartIdx + OnIdx);
end;

procedure BitOnByIdx(var Value: DWORD; StartIdx, OnIdx, BitLen: integer);
var
    i: integer;
begin
    for i := 0 to BitLen - 1 do
    begin
        Value := bitOff(VAlue, StartIdx + i);
    end;

    Value := bitOn(Value, StartIdx + OnIdx);
end;

procedure BitOffByIdx(var Value: DWORD; StartIdx, OffIdx: integer);
begin
    Value := bitOff(Value, StartIdx + OffIdx);
end;

function GetOnBitIdx(const Value: DWORD; StartIdx, BitLen: integer): integer;
var
    i: integer;
begin

    if StartIdx + BitLen > 32 then Exit(-1);

    for i := 0 to BitLen - 1 do
    begin
        if IsBitOn(Value, StartIdx + i) = true then
        begin
            Result := i;
            Exit;
        end;
    end;

    Result := -1;
end;

function GetBitStatus(const Data: array of Byte; StartByte, StartBit, BitCount: Integer): Integer;
var
    i, BitPos, ByteIndex: Integer;
    BitValue: Byte;
begin
    Result := 0;

    if (StartByte < 0) or (StartByte >= Length(Data)) then
        raise Exception.Create('myUtils > GetBitStatus Funtion : 시작 바이트가 Data길이를 초과했습니다');
    if (StartBit < 0) or (StartBit > 7) then
        raise Exception.Create('myUtils > GetBitStatus Funtion : 시작 비트가 Bit최대길이(8)을 초과했습니다');
    if (BitCount <= 0) or (BitCount > 16) then // 최대 16비트까지 처리 가능하도록 설정
        raise Exception.Create('myUtils > GetBitStatus Funtion : BitCount는 최대 16비트까지 처리 가능합니다.');

    for i := 0 to BitCount - 1 do
    begin
        BitPos := StartBit + i;
        ByteIndex := StartByte + (BitPos div 8);

        if ByteIndex >= Length(Data) then
            raise Exception.Create('myUtils > GetBitStatus Funtion : StartByte에서 BitCount만큼 찾을 때 Data길이를 초과합니다.');

        BitValue := (Data[ByteIndex] shr (BitPos mod 8)) and 1;
        Result := Result or (BitValue shl i);
    end;
end;


procedure SetBit(var Value: DWORD; const TheBit: TBit; IsOn: boolean);
begin
    if IsOn = true then
        Value := bitOn(Value, TheBit)
    else
        Value := bitOff(Value, TheBit);
end;

procedure SetBitWord(var Value: WORD; const TheBit: TBit; IsOn: boolean);
begin
    if IsOn = true then
        Value := bitOn(Value, TheBit)
    else
        Value := bitOff(Value, TheBit);
end;

procedure SetBits(var Value: DWORD; const StartBit: TBit; IsOn: boolean; BitLen: integer);
var
    i: integer;
begin
    for i := 0 to BitLen - 1 do
    begin
        SetBit(Value, StartBit + i, IsOn);
    end;

end;


function IsDefaultPrinterSetup: boolean;
var
    FDevice: pCHAR;
    FDriver: pCHAR;
    FPort: pCHAR;
    FHandle: THandle;
    CurrentPrinterName: string;
begin
    GetMem(FDevice, 255);
    GetMem(FDriver, 255);
    GetMem(FPort, 255);
    try
        try
            Printer.GetPrinter(FDevice, FDriver, FPort, FHandle);
            CurrentPrinterName := FDevice;
            if (CurrentPrinterName <> '') then
            begin
                Result := true;
            end
            else
            begin
                Result := false; // 기본프린터 없음
            end;
        except
            on Exception do
            begin
                Result := false;
            end;
        end;
    finally
        if FDevice <> nil then
            FreeMem(FDevice, 255);
        if FDriver <> nil then
            FreeMem(FDriver, 255);
        if FPort <> nil then
            FreeMem(FPort, 255);
    end;
end;

function GetSepTxt(aSeparator, aStr: string; aIndex: integer): string;
var
    i, IDx: integer;
begin
    if aIndex <= 0 then
    begin
        Result := aStr;
        Exit;
    end;

    IDx := 0;
    Result := '';
    for i := 1 to Length(aStr) do
    begin
        if (Trim(aStr[i]) = Trim(aSeparator)) then
        begin
            Inc(IDx);
            if IDx = aIndex then
                Exit
            else
                Result := '';
        end
        else
            Result := Result + aStr[i];
    end;
    if aIndex > (IDx + 1) then
        Result := '';
end;

function Process32List(aHandle: THandle): boolean;
var
    Process32: TProcessEntry32;
    SHandle: THandle; // the handle of the Windows object
    Next: BOOL;
begin
    Result := false;
    Process32.dwSize := sizeof(TProcessEntry32);
    SHandle := CreateToolHelp32Snapshot(TH32CS_SNAPPROCESS, 0);

    if Process32First(SHandle, Process32) then
    begin
        if OpenProcess(PROCESS_ALL_ACCESS, true, Process32.th32ProcessID) = aHandle then
            Result := true
        else
        begin
            repeat
                Next := Process32Next(SHandle, Process32);
                if Next then
                begin
                    if OpenProcess(PROCESS_ALL_ACCESS, true, Process32.th32ProcessID) = aHandle then
                    begin
                        Result := true;
                        Break;
                    end;
                end;
            until not Next;
        end;
    end;
    CloseHandle(SHandle); // closes an open object handle
end;

procedure MsgError(Caption, Text: pCHAR);
begin
    MessageBox(GetActiveWindow(), Text, Caption, MB_OK or MB_ICONSTOP);
end;

function MsgCheck(Caption, Text: pCHAR): boolean;
begin
    Result := MessageBox(GetActiveWindow(), Text, Caption, MB_YESNO or MB_DEFBUTTON1 or MB_ICONINFORMATION) = IDYES;
end;

function IsRunningSaverOfNT: boolean;
var
    aParam: LongInt;
begin
    if not SystemParametersInfo(SPI_GETSCREENSAVERRUNNING, 0, @aParam, 0) then
    begin
        Result := false;
        Exit;
    end;

    Result := aParam = 1;
end;

function IsRunningSaverOf98: boolean;
var
    Active: boolean;
    aParam: LongInt;
begin
    Active := false;
    // win98, winMe
    if not SystemParametersInfo(SPI_SCREENSAVERRUNNING, WORD(Active), @aParam, 0) then
    begin
        Result := false;
        Exit;
    end;

    Result := Active;
end;

function GetsysSaverRunning(): boolean;
begin
    if IsNT then
        Result := IsRunningSaverOf98
    else
        Result := IsRunningSaverOfNT;
end;

function SendUserKeyBoard(AKey: byte): integer;
var
    nInput: TInput;
begin
    // ZeroMemory(@nInput, sizeof(TInput)) ;
    FillChar(nInput, sizeof(TInput), 0);
    nInput.Itype := INPUT_KEYBOARD;
    nInput.ki.wVk := AKey;

    Result := SendInput(1, nInput, sizeof(nInput));
end;

function SendUserMouse(AX, AY: LongInt): integer;
var
    nInput: TInput;
begin
    // 사용하지 말고 참조만 할것.
    // ZeroMemory(@nInput, sizeof(TInput)) ;
    FillChar(nInput, sizeof(TInput), 0);
    nInput.Itype := INPUT_MOUSE;
    nInput.mi.dx := AX;
    nInput.mi.dy := AY;
    nInput.mi.dwFlags := MOUSEEVENTF_MOVE;

    Result := SendInput(1, nInput, sizeof(nInput));
end;

procedure SaverTurnOff();
begin
    SendUserKeyBoard(VK_TAB)
end;

procedure SaverTurnOn;
begin
    PostMessage(GetDesktopWindow, WM_SYSCOMMAND, SC_SCREENSAVE, 0);
end;

function GetsysSaverEnable: boolean;
var
    aParam: LongInt;
begin
    if not SystemParametersInfo(SPI_GETSCREENSAVEACTIVE, 0, @aParam, 0) then
    begin
        Result := false;
        Exit;
    end;

    Result := aParam = 1;
end;

function SetsysSaverEnable(AEnable: integer): boolean;
begin
    Result := SystemParametersInfo(SPI_SETSCREENSAVEACTIVE, AEnable, nil, 0);
end;

function SetsysSaverTimeOut(ATime: integer): boolean;
begin

    Result := SystemParametersInfo(SPI_SETSCREENSAVETIMEOUT, ATime, nil, 0);
end;

function GetsysSaveTimeOut: integer;
var
    aParam: LongInt;
begin
    if not SystemParametersInfo(SPI_GETSCREENSAVETIMEOUT, 0, @aParam, 0) then
    begin
        Result := -1;
        Exit;
    end;

    Result := aParam;
end;

procedure DrawImage(desCanvas, srcCanvas: TCanvas; desArea, srcArea: TmyArea);
begin
    StretchBlt(desCanvas.Handle, desArea.X, desArea.Y, desArea.Width, desArea.Height, srcCanvas.Handle, srcArea.X, srcArea.Y, srcArea.Width, srcArea.Height, SRCCOPY);
end;

function AreaToRect(Area: TmyArea): TRect;
begin
    with Result do
    begin
        Left := Area.X;
        Right := Left + Area.Width;

        Top := Area.Y;
        Bottom := Top + Area.Height;
    end;
end;

function RectToArea(Rect: TRect): TmyArea;
begin
    with Result do
    begin
        X := Rect.Left;
        Width := Rect.Right - X;

        Y := Rect.Top;
        Height := Rect.Bottom - Y;
    end;
end;

procedure Process32ListKill(aFileName: String);
var
    Process32: TProcessEntry32;
    SHandle: THandle; // the handle of the Windows object
    Next: BOOL;
    ProcId: DWORD;
begin
    Process32.dwSize := sizeof(TProcessEntry32);
    SHandle := CreateToolHelp32Snapshot(TH32CS_SNAPPROCESS, 0);

    if Process32First(SHandle, Process32) then
    begin
        // 실행화일명과 process object 저장
        repeat
            Next := Process32Next(SHandle, Process32);
            if Next then
            begin
                GetWindowThreadProcessID(SHandle, @ProcId);
                if UpperCase(Process32.szExeFile) = UpperCase(aFileName) then
                begin
                    ProcId := DWORD(Process32.th32ProcessID);
                    SHandle := OpenProcess(PROCESS_ALL_ACCESS, true, ProcId);
                    // 명시한 process를 강제 종료시킨다
                    TerminateProcess(SHandle, 0);
                end;
            end;
        until not Next;
    end;
    CloseHandle(SHandle); // closes an open object handle
end;

function WinExecAndWait(const Path: pCHAR; const Dir: pCHAR; const Visibility: WORD; const Wait: boolean): boolean;
var
    ProcessInformation: TProcessInformation;
    StartupInfo: TStartupInfo;
begin
    FillChar(StartupInfo, sizeof(TStartupInfo), 0);
    with StartupInfo do
    begin
        cb := sizeof(TStartupInfo);
        lpReserved := nil;
        lpDesktop := nil;
        lpTitle := nil;
        dwFlags := STARTF_USESHOWWINDOW;
        wShowWindow := Visibility;
        cbReserved2 := 0;
        lpReserved2 := nil
    end;

    Result := CreateProcess(nil, { address of module name }
        Path, { address of command line }
        nil, { address of process security attributes }
        nil, { address of thread security attributes }
        false, { new process inherits handle }
        NORMAL_PRIORITY_CLASS, { creation flags }
        nil, { address of new environment block }
        Dir, { address of current directory name }
        StartupInfo, ProcessInformation);
    if Result then
    begin
        with ProcessInformation do
        begin
            if Wait then // WaitForSingleObject(hProcess, INFINITE);
            begin
                while MsgWaitForMultipleObjects(1, hProcess, false, INFINITE, QS_ALLINPUT) = WAIT_OBJECT_0 + 1 do
                begin
                    Application.ProcessMessages;
                end;
            end;
            CloseHandle(hThread);
            CloseHandle(hProcess)
        end;
    end;
END { WinExecAndWait } ;


procedure PMSleep(Msec: double);        // ProcessMessagesSleep
var
    STime: double;
begin
    STime := GetAccurateTime;

    while (GetAccurateTime - STime) <= MSec do
    begin
        Application.ProcessMessages;
    end;
end;

function GetFloatToTerms(Lo, Hi: double; PointPos: integer): string;
begin
    Result := Format('%0.*f ~ %0.*f', [PointPos, Lo, PointPos, Hi]);
end;

function GetTermToFloat(aTerm: string): TUserData;
begin
    Result.rLo := GetStrToFloat(Trim(Copy(aTerm, 1, Pos('~', aTerm) - 1)));
    Result.rHi := GetStrToFloat(Trim(Copy(aTerm, Pos('~', aTerm) + 1, Length(aTerm) - Pos('~', aTerm))));
end;

function IsSelectedRows(aGrid: TStringGrid; ARow: integer): boolean;
begin
    Result := false;
    with aGrid do
    begin
        if (Selection.Top <= ARow) and (Selection.Bottom >= ARow) then
            Result := true;
    end;
end;

function InitUsrPrint(Print: TPrinter; StartPage: boolean; Title: string; Orientation: TPrinterOrientation): TRect;
var
    pCanvas: TCanvas;
    DevWidth, DevHeight: integer;
    ViewExt: Size;
    Paper: TRect;
begin
    pCanvas := Print.Canvas;

    if (StartPage) then
    begin
        Print.Orientation := Orientation;
        Print.Title := Title;
        Print.BeginDoc();
    end
    else
    begin
        Print.NewPage();
    end;

    DevWidth := GetDeviceCaps(Print.Handle, HORZSIZE);
    DevHeight := GetDeviceCaps(Print.Handle, VERTSIZE);

    Paper := Rect(0, 0, DevWidth * 10, DevHeight * 10); // 아래 LoMETRIC모드(0.1mm)로 변환하므로,  10배 해준다.
    // InflateRect(Paper, -10, -10);

    SetMapMode(Print.Handle, MM_LOMETRIC); // 10 ---- 1mm
    GetViewportExtEx(Print.Handle, ViewExt);
    SetMapMode(Print.Handle, MM_ISOTROPIC);
    SetViewportExtEx(Print.Handle, ViewExt.cx, -ViewExt.cy, @ViewExt);

    pCanvas.Brush.Color := clWhite;
    pCanvas.Pen.Color := clBlack;

    Result := Paper;
end;

function GetDefaultPrint(): string;
var
    FDevice: pCHAR;
    FDriver: pCHAR;
    FPort: pCHAR;
    FHandle: THandle;
begin
    Result := '';
    GetMem(FDevice, 255);
    GetMem(FDriver, 255);
    GetMem(FPort, 255);
    try
        try
            Printer.GetPrinter(FDevice, FDriver, FPort, FHandle);
            Result := FDevice;
        except
            on Exception do
                Result := '';
        end;
    finally
        if FDevice <> nil then
            FreeMem(FDevice, 255);
        if FDriver <> nil then
            FreeMem(FDriver, 255);
        if FPort <> nil then
            FreeMem(FPort, 255);
    end;
end;

function SetDefaultPrint(aName: string): boolean;
var
    i: integer;
    Device, Name, Port: array [0 .. 255] of Char;
    DevMode: THandle;
Begin
    Result := false;
    if (aName = '') or (Printer.Printers.Count <= 0) then
        Exit;

    try
        with Printer do
        begin
            if Printers[PrinterIndex] = aName then
            begin
                Result := true;
                Exit;
            end
            else
            begin
                for i := 0 to Printers.Count - 1 do
                begin
                    if Printers.Strings[i] = aName then
                    begin
                        PrinterIndex := i;
                        Result := true;
                        Break;
                    end;
                end;
            end;
            if Result then
            begin
                GetPrinter(Device, Name, Port, DevMode);
                SetPrinter(Device, Name, Port, 0);
            end;
        end;
    finally
    end;
end;

function GetComPorts(Ports: TStringList): integer;
var
    KeyHandle: HKEY;
    ErrCode, Index: integer;
    ValueName, Data: string;
    ValueLen, DataLen, ValueType: DWORD;
    TmpPorts: TStringList;
begin
    ErrCode := RegOpenKeyEx(HKEY_LOCAL_MACHINE, 'HARDWARE\DEVICEMAP\SERIALCOMM', 0, KEY_READ, KeyHandle);

    if ErrCode <> ERROR_SUCCESS then // 설치된 포트 없음
        Exception.Create('No Insatalled Comport at This System');

    TmpPorts := TStringList.Create;
    try
        Index := 0;
        repeat
            ValueLen := 256;
            DataLen := 256;
            SetLength(ValueName, ValueLen);
            SetLength(Data, DataLen);
            ErrCode := RegEnumValue(KeyHandle, Index, pCHAR(ValueName),
{$IFDEF DELPHI_4_OR_HIGHER}
                Cardinal(ValueLen),
{$ELSE}
                ValueLen,
{$ENDIF}
                nil, @ValueType, PByte(pCHAR(Data)), @DataLen);

            if ErrCode = ERROR_SUCCESS then
            begin
                SetLength(Data, DataLen);
                TmpPorts.Add(Data);
                Inc(Index);
            end;
        until (ErrCode <> ERROR_SUCCESS);

        TmpPorts.Sort; // 리스트 소트
        Ports.Assign(TmpPorts);
        Result := TmpPorts.Count;
    finally
        RegCloseKey(KeyHandle);
        TmpPorts.Free;
    end;
end;

procedure QuickpSort(aAry: Pointer; Sort: TpDataCompare; Change: TpDataChange; First, Last: integer);
var
    i, j: integer;
    std: integer;
begin
    std := (First + Last) div 2;

    i := First;
    j := Last;
    while true do
    begin
        while Sort(aAry, i, std) < 0 do
            Inc(i);
        while Sort(aAry, j, std) > 0 do
            dec(j);
        if (i >= j) then
            Break;

        Change(aAry, i, j);
        Inc(i);
        dec(j);
    end;

    if (First < i - 1) then
        QuickpSort(aAry, Sort, Change, First, i - 1);
    if (j + 1 < Last) then
        QuickpSort(aAry, Sort, Change, j + 1, Last);
end;

procedure BubblepSort(aAry: Pointer; Sort: TpDataCompare; Change: TpDataChange; First, Last: integer);
var
    i, j, K: integer;
begin
    K := Last;

    while { (k >= 0) or } (K >= First) do
    begin
        j := -1;
        for i := First + 1 to K do
        begin
            if Sort(aAry, i - 1, i) > 0 then
            begin
                j := i - 1;
                Change(aAry, i, j);
            end;
        end;
        K := j;
    end;
end;

function GetFloatToStrEx(aDigit: integer; aValue: double; UseBankersRound: boolean = false): string;
begin
{$IFDEF VER150}
    if UseBankersRound then
    begin
        Result := Format('%0.*f', [aDigit, RoundTo(aValue, -aDigit)]);
        Exit;
    end;
{$ENDIF}
    Result := Format('%0.*f', [aDigit, aValue]);

    // Delphi func
    // type TRoundToRange = -37..37;
    // function RoundTo(const AValue: Double; const ADigit: TRoundToRange): Double;
    // ADigit 는 10의 몇승인지를 넣어주면 됨.
    // Banker's Rounding 방식 사용한다.
    // 참고 Banker's Rounding 방식 사용하는 함수
    // -> 소수점앞에 숫자가 홀수면 5를 포함, 짝수면 5를 버리는 방식.
    // Round, FloatToStr, FormatFloat
    // Format 에서만 5를 반올림함.
end;

function IsExistsWindows(aClassName: string): boolean;
var
    wndName: array [0 .. 255] of Char;
    wndHandle: HWND;
begin
    StrCopy(@wndName[0], pCHAR(aClassName));
    // wndHandle := FindWindow(nil, @wndName[0]);
    wndHandle := FindWindow(@wndName[0], nil);
    Result := wndHandle <> 0;
end;

procedure LogFileRemove(aSaveMonth: integer; UserFileHead: string);
var
    i: integer;
    done: integer;
    yy, mm, dd: WORD;
    SearchFile: TSearchRec;
    szMask, name: string;
begin
    DecodeDate(Now(), yy, mm, dd);

    // nSaveMonth 개월분 보관
    for i := 0 to aSaveMonth - 1 do
    begin
        dec(mm);
        if (mm = 0) then
        begin
            dec(yy);
            mm := 12;
        end
    end;

    name := Format('%s%.4d%.2d%.2d.LOG', [UserFileHead, yy, mm, dd]);
    szMask := Format('%s\Log\%s*.log', [GetHomeDirectory, UserFileHead]);

    done := FindFirst(szMask, faArchive, SearchFile);
    while (done = 0) do
    begin
        if (strComp(pCHAR(SearchFile.Name), pCHAR(name)) < 0) then
        begin
            DeleteFile(GetHomeDirectory + '\' + SearchFile.Name);
        end;
        done := FindNext(SearchFile);
    end;
end;

procedure SendToForm(aForm: string; awCode, alCode: integer; IsExpress: boolean);
var
    wnd: HWND;
begin
    wnd := FindWindow(pCHAR(aForm), nil);
    if wnd <> 0 then
    begin
        SendToForm(wnd, awCode, alCode, IsExpress);
    end;
end;

procedure SendToForm(Awnd: HWND; awCode, alCode: integer; IsExpress: boolean);
begin
    if IsExpress then
        SendMessage(Awnd, WM_SYS_CODE, awCode, alCode)
    else
        PostMessage(Awnd, WM_SYS_CODE, awCode, alCode);
end;

procedure ToPanel(AObj: TObject; const szFmt: string; const Args: array of const );
var
    szMessage, s2: string;
    hh, mm, ss, Ms: WORD;
begin
    if not Assigned(AObj) or not(AObj is TListBox) then
        Exit;
    s2 := Format(szFmt, Args);

    DecodeTime(Now(), hh, mm, ss, Ms);
    szMessage := Format('[%.2d:%.2d:%.2d] %s', [hh, mm, ss, s2]);

    with AObj as TListBox do
    begin
        items.Add(szMessage);
        ItemIndex := items.Count - 1;

        while items.Count > 200 do
            items.Delete(0);
    end;
end;

procedure ToPanel(hMsg: HWND; const szFmt: string; const Args: array of const );
var
    msg: TMSG;
    nCount: integer;
    szMessage, s2: string;
    hh, mm, ss, Ms: WORD;
begin
    if hMsg <= 32 then
        Exit;
    s2 := Format(szFmt, Args);

    DecodeTime(Now(), hh, mm, ss, Ms);
    szMessage := Format('[%.2d:%.2d:%.2d] %s', [hh, mm, ss, s2]);

    SendMessage(hMsg, LB_ADDSTRING, 0, DWORD(pCHAR(szMessage)));
    nCount := integer(SendMessage(hMsg, LB_GETCOUNT, 0, 0));
    SendMessage(hMsg, LB_SETCURSEL, nCount - 1, 0);
    //while (PeekMessage(msg, hMsg, 0, 0, PM_REMOVE)) do
    //begin
    //    TranslateMessage(msg);
    //    DispatchMessage(msg);
    //end;
end;

function CHTB(const HexChar: AnsiChar): byte;
begin
    if HexChar in ['0' .. '9'] then
        Exit(byte(HexChar) - byte('0'));

    if HexChar in ['A' .. 'F'] then
        Exit(byte(HexChar) - byte('A') + 10);

    if HexChar in ['a' .. 'f'] then
        Exit(byte(HexChar) - byte('a') + 10);

end;

function HexToInt(const AHex: Ansistring): integer;
var
    i, tmp: integer;
    sTm: string;
begin
    Result := 0;

    sTm := UpperCase(AHex);
    for i := 1 to Length(sTm) do
    begin
        Result := Result shl 4;

        if sTm[i] In ['0' .. '9'] then
        begin
            tmp := byte(sTm[i]) - byte('0');
        end
        else if sTm[i] In ['A' .. 'F'] then
        begin
            tmp := byte(sTm[i]) - byte('A') + 10;
        end
        else
            tmp := 0;

        Result := Result or tmp;
    end;
end;

function StrToHex(const Str: string): string;
var
    i: integer;
    Temp: AnsiString;
begin
    Result := '';
    Temp := AnsiString(Str);

    for i := 1 to Length(Temp) do
        Result := Result + ' 0x' + IntToHex(Ord(temp[i]), 2);
end;

function GetStrToDateTime(const AText: string): TDateTime;
    procedure ConvertDateTime(const AText: string; Index: integer; UsrTime: pUsrDateTime);
    begin
        if AText = '' then
            Exit;
        with UsrTime^ do
        begin
            case Index of
                1:
                    if Length(AText) <= 4 then
                        yy := StrToInt(AText);
                2:
                    if Length(AText) <= 2 then
                        mm := StrToInt(AText);
                3:
                    if Length(AText) <= 2 then
                        dd := StrToInt(AText);
                4:
                    if Length(AText) <= 2 then
                        hh := StrToInt(AText);
                5:
                    if Length(AText) <= 2 then
                        nn := StrToInt(AText);
                6:
                    if Length(AText) <= 2 then
                        ss := StrToInt(AText);
                7:
                    if Length(AText) <= 3 then
                        zz := StrToInt(AText);
            end;
        end;
    end;

var
    i, IDx: integer;
    UsrTime: TUsrDateTime;
    sTm: string;
begin
    IDx := 0;
    sTm := '';
    // ZeroMemory(@UsrTime, sizeof(TUsrDateTime)) ;
    FillChar(UsrTime, sizeof(TUsrDateTime), 0);

    for i := 1 to Length(AText) do
    begin
        if AText[i] = ' ' then
        begin
            if IDx > 0 then
                Inc(IDx)
            else
                Continue;
            ConvertDateTime(sTm, IDx, @UsrTime);
            sTm := '';
        end
        else if AText[i] In ['-'] then
        begin
            Inc(IDx);
            ConvertDateTime(sTm, IDx, @UsrTime);
            sTm := '';
        end
        else if AText[i] In [':'] then
        begin
            if IDx <= 3 then
                IDx := 4
            else
                Inc(IDx);
            ConvertDateTime(sTm, IDx, @UsrTime);
            sTm := '';
        end
        else
            sTm := sTm + AText[i];
    end;
    if (sTm <> '') and (IDx > 0) then
    begin
        Inc(IDx);
        ConvertDateTime(sTm, IDx, @UsrTime);
    end;

    try
        with UsrTime do
        begin
            Result := EncodeDate(yy, mm, dd);
            Result := Result + EncodeTime(hh, nn, ss, zz);
        end;
    except
        Result := 0;
    end;
end;

function GetUserValue(aValue: double; aDigit: integer): double;
begin
    try
        Result:= StrToFloatDef(Format('%0.*f', [aDigit, aValue]), 0);
        //Result := Round(aValue * Power(10.0, aDigit)) / Power(10.0, aDigit);
    except
        Result := 0;
    end;
end;

function MyTrunc(const Value: Double; const Digit: Integer): Double;
var
    Multiplier: Double;
begin
  // 10^aDigits 계산
    Multiplier := Power(10, Digit);

  // 소수점 이하 절삭
    Result := Trunc(Value * Multiplier) / Multiplier;
end;

{
function MyTrunc(const Value: Double; const Digit: Integer): Double;
begin
    Result := Trunc(Value * Exp(Digit * Ln(10))) / Exp(Digit * Ln(10));
end;
}
function IsBatteryMode(var AC: TUsrPowerMode; var Battery: TUsrPowerMode; var BatteryLife: byte): boolean;
var
    nB: TSystemPowerStatus;
begin
    {
      PSystemPowerStatus = ^TSystemPowerStatus;
      _SYSTEM_POWER_STATUS = packed record
      ACLineStatus : Byte;
      BatteryFlag : Byte;
      BatteryLifePercent : Byte;
      Reserved1 : Byte;
      BatteryLifeTime : DWORD;
      BatteryFullLifeTime : DWORD;
      end;
      }
    { Power Management APIs }

    // AC_LINE_OFFLINE = 0;
    // AC_LINE_ONLINE = 1;
    // AC_LINE_BACKUP_POWER = 2;
    // AC_LINE_UNKNOWN = 255;

    // BATTERY_FLAG_HIGH = 1;
    // BATTERY_FLAG_LOW = 2;
    // BATTERY_FLAG_CRITICAL = 4;
    // BATTERY_FLAG_CHARGING = 8;
    // BATTERY_FLAG_NO_BATTERY = $80;
    // BATTERY_FLAG_UNKNOWN = 255;
    // BATTERY_PERCENTAGE_UNKNOWN = 255;
    // BATTERY_LIFE_UNKNOWN = DWORD($FFFFFFFF);
    Result := false;
    if not GetSystemPowerStatus(nB) then
        Exit;

    case nB.ACLineStatus of
        AC_LINE_OFFLINE:
            AC := ups_AC_ON_LINE;
        AC_LINE_ONLINE:
            AC := ups_AC_OFF_LINE;
        AC_LINE_BACKUP_POWER:
            AC := ups_AC_BACKUP;
    else
        AC := ups_AC_UNKNOWN;
    end;

    if nB.BatteryFlag = BATTERY_LIFE_UNKNOWN then
    begin
        Battery := ups_BT_LIFE_UNKNOWN;
    end
    else if nB.BatteryFlag = BATTERY_FLAG_UNKNOWN then
    begin
        Battery := ups_BT_UNKNOWN;
    end
    else if (nB.BatteryFlag and BATTERY_FLAG_NO_BATTERY) = BATTERY_FLAG_NO_BATTERY then
    begin
        Battery := ups_BT_NO_BATTERY;
    end
    else
    begin
        if (nB.BatteryFlag and BATTERY_FLAG_HIGH) = BATTERY_FLAG_HIGH then
        begin
            Battery := ups_BT_HIGH;
        end;
        if (nB.BatteryFlag and BATTERY_FLAG_LOW) = BATTERY_FLAG_LOW then
        begin
            Battery := ups_BT_LOW;
        end;
        if (nB.BatteryFlag and BATTERY_FLAG_CRITICAL) = BATTERY_FLAG_CRITICAL then
        begin
            Battery := ups_BT_CRITICAL;
        end;
        if (nB.BatteryFlag and BATTERY_FLAG_CHARGING) = BATTERY_FLAG_CHARGING then
        begin
            Battery := ups_BT_CHARGING;
        end;
    end;

    BatteryLife := nB.BatteryLifePercent;

    if (nB.ACLineStatus = AC_LINE_UNKNOWN) or (nB.ACLineStatus = AC_LINE_ONLINE) then
        Exit;

    Result := true;
end;

function GetCpuCount: integer;
var
    Info: SYSTEM_INFO;
begin
    GetSystemInfo(Info);
    Result := Info.dwNumberOfProcessors;
end;

function GetDiskInfo(const Dest: string; var VolumnValue: string): boolean ;
var
    FVolumeName : String;
    FVolumeSerialNumber : integer ;
    FMaximumComponentLength,
    FFileSystemFlags : DWORD ;
    FFileSystemName : String;
begin
    // 문자열에 길이를 할당.
    SetLength(FVolumeName, MAX_PATH);
    SetLength(FFileSystemName, MAX_PATH);

    // 변수들의 초기화
    FVolumeSerialNumber := 0;
    FMaximumComponentLength := 0;
    FFileSystemFlags := 0;

    // Getvolumeinformation() API 호출
    Result := GetVolumeInformation(
                                    PChar(Dest),
                                    PChar(FVolumeName),
                                    MAX_PATH,
                                    @FVolumeSerialNumber,
                                    FMaximumComponentLength,
                                    FFileSystemFlags,
                                    PChar(FFileSystemName),
                                    MAX_PATH
                                   );

    // MAX_PATH값으로 설정된 문자열을 정리한다.
    SetLength(FVolumeName, StrLen(PChar(FVolumeName)));
    SetLength(FFileSystemName, StrLen(PChar(FFileSystemName)));

    VolumnValue:= FVolumeName + ', ' + FFileSystemName;
    VolumnValue := Format('%x', [FVolumeSerialNumber]) ;

    FVolumeName:= '' ;
    FFileSystemName:= '' ;
end ;

function GetDeskTopDirectory: String;
var
    Path: array [0 .. MAX_PATH - 1] of Char;
begin
    if SHGetSpecialFolderPath(Application.Handle, Path, CSIDL_DESKTOP, false) then
    begin
        Result := Path;
        Exit;
    end;
    Result := GetHomeDirectory;
end;

// ---------------------------------------------------------------------------
//
// ---------------------------------------------------------------------------
function FindControlByTag(ParentControl: TWinControl; aTag: integer): TWinControl;
var
    i, Count: integer;
    Temp, Name: string;
    FindControl: TWinControl;
begin

    Count := ParentControl.ControlCount;

    Result := nil;

    for i := 0 to Count - 1 do
    begin
        Name := ParentControl.Controls[i].ClassName;
        Temp := ParentControl.Controls[i].Name;
        if (Pos('GroupBox', Name) > 0) or (Pos('Panel', Name) > 0) then
        begin
            if aTag = ParentControl.Controls[i].Tag then
            begin
                Exit(TWinControl(ParentControl.Controls[i]);
            end
            else if TWinControl(ParentControl.Controls[i]).ControlCount > 0 then
            begin
                FindControl := FindControlByTag(TWinControl(ParentControl.Controls[i]), aTag);
                if Assigned(FindControl) then
                begin
                    Result := FindControl;
                    Exit;
                end;
            end;
        end
        else if aTag = ParentControl.Controls[i].Tag then
        begin
            Result := TWinControl(ParentControl.Controls[i]);
        end;
    end;
end;

// ---------------------------------------------------------------------------

function ParseByDelimiter(var RetStr: array of string; RetStrCount: integer; SrcStr: string; Delimiter: string): integer;
var
    Count, i, j, Len, DeLen: integer;
    Token: string;
    IsFind: boolean;
begin
    Count := 0;
    Len := Length(SrcStr);

    if Len = 0 then
        Exit(0);

    DeLen := Length(Delimiter);

    for i := 1 to Len do
    begin
        IsFind := false;
        for j := 1 to DeLen do
        begin
            if (SrcStr[i] = Delimiter[j])  then
            begin
                RetStr[Count] := Trim(Token);
                Inc(Count);
                Token := '';
                IsFind := true;
                Break;
            end;
        end;
        if (not IsFind) then
        begin
            Token := Token + string(SrcStr[i]);
        end;

        if (Count >= RetStrCount) then
        begin
            Break;
        end;

    end;

    if ((Token <> '') or IsFind) and (Count < RetStrCount) then
    begin
        RetStr[Count] := _TR(Trim(Token));
        Inc(Count);
    end;

    Result := Count;
end;


function DeleteFileWithUndo(const FileName: string): boolean;
var
    FOS: ShellAPI.TSHFileOpStruct; // contains info about required file operation
begin
    // Set up structure that determines file operation
    FillChar(FOS, sizeof(FOS), 0);
    with FOS do
    begin
        wFunc := ShellAPI.FO_DELETE; // we're deleting
        pFrom := pCHAR(FileName + #0); // this file (#0#0 terminated)
        fFlags := ShellAPI.FOF_ALLOWUNDO // with facility to undo op
          or ShellAPI.FOF_NOCONFIRMATION // and we don't want any dialogs
          or ShellAPI.FOF_SILENT;
    end;
    // Perform the operation
    Result := ShellAPI.SHFileOperation(FOS) = 0;
end;


procedure TurnOnOffMonitor(IsOn : boolean);
begin
    if IsOn then
        SendMessage(Application.Handle, WM_SYSCOMMAND, SC_MONITORPOWER, 0)
    else
        SendMessage(Application.Handle, WM_SYSCOMMAND, SC_MONITORPOWER, 2);

end;

function ReadStr(FH: integer; var Str: AnsiString): boolean;
var
    Len: integer;
begin
    Result := false;

    try
        FileRead(FH, Len, sizeof(integer));

        SetLength(Str, Len);

        FileRead(FH, PAnsiChar(Str)^, Len);

        Result := true;
    except

    end;

end;

function WriteStr(FH: integer; Str: AnsiString): boolean;
var
    Len: integer;
begin
    Result := false;

    Len := Length(Str);

    try
        FileWrite(FH, Len, sizeof(integer));
        FileWrite(FH, PAnsiChar(Str)^, Len);
        Result := true;
    except

    end;


end;

{
function CalcSizes(TotSize: Integer; Ratios: array of Double): TArray<Integer>;
var
    TotalRatio, Ratio: Double;
    i: Integer;
    Sizes: TArray<Integer>;
begin

    TotalRatio := 0;
    for i := Low(Ratios) to High(Ratios) do
        TotalRatio := TotalRatio + Ratios[i];


    SetLength(Sizes, Length(Ratios));

    for i := Low(Ratios) to High(Ratios) do
    begin
        Ratio := Ratios[i];
        Sizes[i] := Round((Ratio / TotalRatio) * TotSize);
    end;

    Result := Sizes;
end;
}

function CalcSizes(TotSize: Integer; Ratios: array of Double): TArray<Integer>;
var
    ExactSize, TotalRatio: Double;
    i, j, Remainder, AllocatedSize: Integer;
    Sizes: TArray<Integer>;
    Remainders: TArray<Double>; // 소수점 부분만 저장
    MaxRemainder: Double;
    MaxIndex: Integer;
begin

    TotalRatio := 0;
    for i := Low(Ratios) to High(Ratios) do
        TotalRatio := TotalRatio + Ratios[i];


    SetLength(Sizes, Length(Ratios));
    SetLength(Remainders, Length(Ratios));

    // 기본 할당 (소수점 버림)
    AllocatedSize := 0;
    for i := Low(Ratios) to High(Ratios) do
    begin
        ExactSize := (Ratios[i] / TotalRatio) * TotSize;
        Sizes[i] := Trunc(ExactSize);
        Remainders[i] := ExactSize - Sizes[i]; // 소수점 부분 저장
        AllocatedSize := AllocatedSize + Sizes[i];
    end;

    // 나머지를 소수점이 큰 순서대로 분배
    Remainder := TotSize - AllocatedSize;

    for i := 1 to Remainder do // 'Remainder' 횟수만큼 반복
    begin
        MaxRemainder := 0;
        MaxIndex := 0;

        // 가장 큰 소수점 부분 찾기
        for j := Low(Remainders) to High(Remainders) do
        begin
            if Remainders[j] > MaxRemainder then
            begin
                MaxRemainder := Remainders[j];
                MaxIndex := j;
            end;
        end;

        Inc(Sizes[MaxIndex]);
        Remainders[MaxIndex] := 0; // 해당 인덱스의 소수점 부분 "소모"
    end;

    Result := Sizes;
end;

{ TUserData }

constructor TUserData.Create(Lo, Hi: double);
begin
    Init(Lo, Hi);
end;

procedure TUserData.Init(Lo, Hi: double);
begin
    rLo := Lo;
    rHi := Hi;
end;


function TUserData.GetMaxStr(Digit: integer; UnitStr: string): string;
begin
    Result := GetUsrFloatToStr(rMax, Digit);

    if (UnitStr <> '') then
        Result := Result + UnitStr;
end;

function TUserData.GetMinStr(Digit: integer; UnitStr: string): string;
begin
    Result := GetUsrFloatToStr(rMin, Digit);

    if (UnitStr <> '') then
        Result := Result + UnitStr;
end;

function TUserData.GetRangeStr(Digit: integer; UnitStr: string; Delimiter: string): string;
begin
    Result := GetUsrFloatToStr(rLo, Digit) + Delimiter + GetUsrFloatToStr(rHi, Digit);

    if (UnitStr <> '') then
        Result := Result + UnitStr;

end;

function TUserData.InRange(Value: double; Digit: integer): boolean;
begin
    if rHi = 0 then
        Exit(GetUserValue(Value, Digit) >= rLo);


    Result := (GetUserValue(Value, Digit) >= rLo) and (GetUserValue(Value, Digit) <= rHi)
end;

function TUserData.IsEmpty: boolean;
begin
    Result := (rLo = 0) and (rHi = 0);
end;

function TUserData.IsValid: boolean;
begin
    Result := rLo < rHi;
end;

function TUserData.ReadFromEdit(MinEdit, MaxEdit: TCustomEdit): boolean;
var
    MinStr, MaxStr: string;
begin

    try
        if MinEdit.Text <> '' then
            rMin := StrToFloatDef(MinEdit.Text, MinDouble)
        else
            rMin := MinDouble ;

        if MaxEdit.Text <> '' then
            rMax := StrToFloatDef(MaxEdit.Text, MaxDouble)
        else
            rMax := MaxDouble ;

    except
        Exit(false);
    end;

    Result := true;

end;

function TUserData.ReadFromStr(Lo, Hi: string): boolean;
begin
    rLo := StrToFloatDef(Lo, 0);
    rHi := StrToFloatDef(Hi, 0);

    Result := rLo < rHi;
end;



procedure TUserData.WriteToEdit(MinEdit, MaxEdit: TCustomEdit; Format: string);
begin
    if rMin = MinDouble then
        MinEdit.Text := ''
    else
        MinEdit.Text := FormatFloat(Format, rMin);
    if rMax = MaxDouble then
        MaxEdit.Text := ''
    else
        MaxEdit.Text := FormatFloat(Format, rMax);
end;

{ TRttiHelper }

class function TRttiHelper.GetMembersStr<T>: string;
var
    RttiContext: TRttiContext;
    RttiType: TRttiType;
    Fields: TArray<TRttiField>;
    Caption : string;
    i : integer;
begin
    RttiType := RttiContext.GetType(TypeInfo(T));
    Caption := RttiType.Name + ' {';
    Fields := RttiType.GetFields;
    for i := low(Fields) to high(Fields) do
    begin
        Caption := Caption +'{'+ Fields[i].Name+':';
        Caption := Caption + IntToStr(Fields[i].Offset)+'}';
    end;
    Caption := Caption + '}';

    Result := Caption;
end;



class function TRttiHelper.GetMembersName<T>(var MemNames: TDynStrArray): integer;
var
    RttiContext: TRttiContext;
    RttiType: TRttiType;
    Fields: TArray<TRttiField>;
    i, n : integer;
begin
    RttiType := RttiContext.GetType(TypeInfo(T));
    Fields := RttiType.GetFields;

    SetLength(MemNames, Length(Fields));
    n := 0;
    for i := low(Fields) to high(Fields) do
    begin
        MemNames[n] := Fields[i].Name;
        Inc(n);
    end;

    Result := Length(MemNames);
end;


{ TMyThreadList<T> }

constructor TMyThreadList<T>.Create;
begin
    inherited Create;
    InitializeCriticalSection(FLock);
    FList := TList<T>.Create;

end;

destructor TMyThreadList<T>.Destroy;
begin
    LockList; // Make sure nobody else is inside the list.
    try
        FList.Free;
        inherited Destroy;
    finally
        UnlockList;
        DeleteCriticalSection(FLock);
    end;
end;



procedure TMyThreadList<T>.Clear;
begin
    LockList;
    try
        FList.Clear;
    finally
        UnlockList;
    end;
end;

function TMyThreadList<T>.Count: integer;
begin
    LockList;
    try
        Result := FList.Count;
    finally
        UnlockList;
    end;
end;

function TMyThreadList<T>.LockList: TList<T>;
begin
    EnterCriticalSection(FLock);
    Result := FList;
end;


procedure TMyThreadList<T>.Add(const Item: T);
begin
    LockList;
    try
        FList.Add(Item);
    finally
        UnlockList;
    end;
end;

procedure TMyThreadList<T>.Remove(const Item: T);
begin
    LockList;
    try
        FList.Remove(Item);
    finally
        UnlockList;
    end;

end;


procedure TMyThreadList<T>.UnlockList;
begin
    LeaveCriticalSection(FLock);
end;





{ TArrayHelper }

class function TArrayHelper.MakeArray<T>(const Items: array of T): TArray<T>;
var
  I: Integer;
begin
    SetLength(Result, Length(Items));
    for I := 0 to High(Items) do
        Result[I] := Items[I];
end;

Initialization
  GetTickCount64 := GetProcAddress(GetModuleHandle('Kernel32.dll'), 'GetTickCount64');

end.

