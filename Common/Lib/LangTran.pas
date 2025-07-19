{
    Ver.220222.00 : MemIni -> FastIni 사용
}
unit LangTran;

interface
uses
    Sysutils, Classes, IniFiles, Forms, FastIniFile;

//{$DEFINE _NO_TRAN}   // 번역 기능 미사용시  활성화

type
    TLangType = (ltKor, ltEng, ltChn);

    TLangChkFunc = function(Str: string): boolean;

    TLangTran = class
    private
        class var mSrcLangType: TLangType;
        class var mTarLangType: TLangType;

        class var mFilePath: string;

        class var mSrcLangChkFunc: TLangChkFunc;

    public
        class var mMemIni : TFastIniFile;

        class procedure ChangeCaption(Form : TForm);
        class procedure Init(SrcLangType, TarLangType: TLangType; FilePath: string = '');
        class function Trans(Str: string; IsSave: boolean = true): string;
        class function TransEx(Str: string): string;
    end;

    function IsHan(Str : string) : boolean;
    function IsEng(Str : string) : boolean;
    function IsChn(Str : string) : boolean; //간체


    function _TR(Str : string) : string;
    function _TRE(Str : string) : string;       // 현재 Src언어 확인하고 번역
    function _TRNS(Str : string) : string;      // 번역된 Tar언어 없는 경우 SRC를 저장 안 함  Not Save..

    function MsgBox(const Text, Caption: string; Flags: Longint): Integer;

implementation
uses
    TypInfo, StdCtrls, ComCtrls, ExtCtrls, MyUtils, Log;


function _TR(Str : string) : string;
begin
{$IFDEF _NO_TRAN}
    Result := Str;
{$ELSE}
    Result := TLangTran.Trans(Str);
{$ENDIF}
end;

function _TRNS(Str : string) : string;
begin
{$IFDEF _NO_TRAN}
    Result := Str;
{$ELSE}
    Result := TLangTran.Trans(Str, false);
{$ENDIF}
end;

function _TRE(Str : string) : string;
begin
{$IFDEF _NO_TRAN}
    Result := Str;
{$ELSE}
    Result := TLangTran.TransEx(Str);
{$ENDIF}
end;

function MsgBox(const Text, Caption: string; Flags: Longint): Integer;
begin
    Result := Application.MessageBox(PChar(_TR(Text)), PChar(_TR(Text)), Flags) ;
end;


function GetLangChkFunc(LangType: TLangType): TLangChkFunc;
begin
    case LangType of
        ltEng: Result := IsEng;
        ltChn: Result := IsChn;
    else
        Result := IsHan;
    end;
end;




{ TLangTran }


function GetEnvPath(FileName: string): string;
begin
    Result := GetHomeDirectory + '\env';

    if DirectoryExists(Result) then
        ForceDirectories(Result);

    if FileName <> '' then
        Result := Result + '\' + FileName;
end;



class procedure TLangTran.Init(SrcLangType, TarLangType: TLangType; FilePath: string);
begin
    mSrcLangType := SrcLangType;
    mTarLangType := TarLangType;

    if (FilePath = '') and (mFilePath = '') then
        mFilePath := GetEnvPath('Caption.ini')
    else if FilePath <> '' then
        mFilePath := FilePath;

    case SrcLangType of
        ltKor: mSrcLangChkFunc := IsHan;
        ltEng: mSrcLangChkFunc := IsEng;
        ltChn: mSrcLangChkFunc := IsChn;
    end;
end;


class function TLangTran.Trans(Str: string; IsSave: boolean): string;
begin
    Str := Trim(Str);

    if (mSrcLangType = mTarLangType) or (Str = '') or (mFilePath = '') then
        Exit(Str);

    if not Assigned(mMemIni) then
    begin
        mMemIni := TFastIniFile.Create(mFilePath);
        if Assigned(gLog) then
            gLog.Panel('한영 전환 단어: %d 개', [mMemIni.Count]);
    end;

    Result := mMemIni.ReadString('CAP.LIST', Str, '');

    if Result = '' then
    begin
        if IsSave then
        begin
            mMemIni.WriteString('CAP.LIST', Str, '') ;
            mMemIni.UpdateFile ;
        end;
        Result := Str;
    end;
end;

class function TLangTran.TransEx(Str: string): string;
begin
    if mSrcLangChkFunc(Str) then
        Exit(Trans(Str));

    Result := Str;

end;

procedure TransStrings(Strings: TStrings);
var
    i: integer;
begin
    if Strings = nil then Exit;

    for i := 0 to Strings.Count - 1 do
    begin
        Strings[i] := _TRE(Strings[i]);
    end;
end;


class procedure TLangTran.ChangeCaption(Form : TForm);
var
    PI: PPropInfo;
    CapStr: string;
    i: integer;
begin

	if mTarLangType = mSrcLangType then Exit;

    for i  := 0 to Form.ComponentCount - 1 do
    begin

		PI := GetPropInfo(Form.Components[i].ClassInfo(), 'Caption');

		if PI <> nil then
        begin
			CapStr := GetStrProp(Form.Components[i], PI);

			if mSrcLangChkFunc(CapStr) then
			begin
				SetStrProp(Form.Components[i], 'Caption', Trans(CapStr));
			end;
        end;


        if Form.Components[i] is TRadioGroup then
        begin
            TransStrings(TRadioGroup(Form.Components[i]).Items);
        end
        else if Form.Components[i] is TListBox then
        begin
            TransStrings(TRadioGroup(Form.Components[i]).Items);
        end;


    end;

end;



function IsHan(Str : string) : boolean;
var
    i, Len : integer;
    Code: Word;
begin
    Result := false;
    if Str = '' then Exit;


    Len := Length(Str);

    for i := 1 to Len do
    begin
        Code := Word(Str[i]);
        if ($AC00 <= Code) and (Code <= $D7A3) then
        begin
            Exit(true);
        end;
    end;

end;

function IsEng(Str : string) : boolean;
var
    i, Len : integer;
    Code: Word;
begin
    Result := false;
    if Str = '' then Exit;


    Len := Length(Str);

    for i := 1 to Len do
    begin
        Code := Word(Str[i]);
        if ($41 <= Code) and (Code <= $7A) then
        begin
            Exit;
        end;
    end;

end;

function IsChn(Str : string) : boolean;
var
    i, Len : integer;
    Code: Word;
begin
    Result := false;
    if Str = '' then Exit;


    Len := Length(Str);

    for i := 1 to Len do
    begin
        Code := Word(Str[i]);
        if ($4E00 <= Code) and (Code <= $9FEA) then
        begin
            Exit;
        end;
    end;

end;


Initialization
//    TLangTran.Init(ltKor, ltEng);
finalization
    if Assigned(TLangTran.mMemIni) then
        TLangTran.mMemIni.Free;


end.
