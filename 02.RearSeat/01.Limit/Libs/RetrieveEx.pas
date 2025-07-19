unit RetrieveEx;
{$INCLUDE myDefine.inc}
interface
uses
    Windows, SysUtils, Classes ;

type
    {
        내가 만든 규칙에 적용한것임..
        참조 소스 : 찾은 자료 파일 -> Temp file
        원본 소스 : 규칙에 의한 파일명.
    }
    TDelFileName = function (const Buf):string of Object ;
    TDelGrpName  = function (const Buf):string of Object ;
    TDelOnWorkData = procedure (Sender:TObject; const Buf; AIndex:integer;
        var APass:boolean) of Object ;
    TDelDatas = class
        protected
            mLen,
            mPassCnt : integer; // buffer size
            mfName : string ;
            mfList : TStringList ;

            mDelFileName : TDelFileName ;
            mDelGrpName  : TDelGrpName ;
            mDelOnWorkData: TDelOnWorkData ;

            function SetDelete(const aBuf): string ; // filename
            function SetPack(afName: string): integer ; // delete Counter
        public

            constructor Create;
            destructor  Destroy; override;

            function  Del(dPos: array of integer; Count: integer;
                          TempName: string): integer ; // deleted counter

            property OnDelFileName: TDelFileName read mDelFileName write mDelFileName ;
            property OnDelGrpName : TDelGrpName  read mDelGrpName  write mDelGrpName ;
            property OnWorkData: TDelOnWorkData read mDelOnWorkData write mDelOnWorkData ;
            property PassCount : integer read mPassCnt ;
    end;
    TRetieveEx = class(TDelDatas)
    private
        mNames : TStringList ;
        // Datas / Items / OK,NG 항상 Datas = 0 은 전체결과이다
        mCount : array of array of array [false..true] of integer ;
    public
        constructor Create(AUserCount, Bufsize: integer) ;
        destructor  Destroy(); override ;

        procedure Initial() ;
        procedure SetUserData(ACount:integer) ;
        function  AddData(AName: string; AResult: boolean; APos:integer=0):integer ;

        function  Count() : integer ;
        function  ItemCount() : integer ;
        function  GetName(Index: integer): string ;
        function  GetCount(AName: string; AResult:boolean; APos:integer=0): integer ; overload ;
        function  GetCount(Index: integer; AResult:boolean; APos:integer=0): integer ; overload ;

        function  GetIndex(AName: string) : integer ;
    end ;

    TRetrieveItem = class(TRetieveEx)
    public
        constructor Create(AUserCount, Bufsize: integer) ;
        destructor  Destroy ; override;

        function  GetOkSum(APos:integer=0) : integer ;
        function  GetNgSum(APos:integer=0) : integer ;
    end ;


implementation
uses
    Forms, myUtils, Log ;

constructor TRetieveEx.Create(AUserCount,Bufsize:integer) ;
begin
    inherited Create  ;
    mLen := Bufsize ;
    mNames := TStringList.Create() ;
    if not mNames.Sorted then mNames.Sort() ;
    SetLength(mCount, AUserCount) ;
end ;

destructor  TRetieveEx.Destroy();
begin
    inherited Destroy ;
    Initial() ;
    FreeAndNil(mNames) ;
    if Length(mCount) > 0 then SetLength(mCount, 0) ;
end ;

procedure TRetieveEx.Initial() ;
var
    i : integer ;
begin
    if mNames.Count > 0 then mNames.Clear ;
    for i := 0 to Length(mCount)-1 do
    begin
        if Length(mCount[i]) > 0 then SetLength(mCount[i], 0) ;
    end ;
end ;

procedure TRetieveEx.SetUserData(ACount:integer) ;
begin
    SetLength(mCount, ACount) ;
end ;

function TRetieveEx.AddData(AName: string; AResult: boolean; APos:integer):integer ;
var
    i : integer ;
begin
    if AName = '' then AName := ' ';

    Result := mNames.IndexOf(aName) ;
    if Result < 0 then
    begin
        mNames.Add(aName) ;
        Result := mNames.IndexOf(aName) ;
        for i := 0 to Length(mCount)-1 do
        begin
            SetLength(mCount[i], mNames.Count) ;
        end ;
    end ;
    mCount[APos, Result, AResult] := mCount[APos, Result, AResult] + 1 ;
end ;

function  TRetieveEx.GetCount(AName: string; AResult:boolean; APos:integer): integer ;
var
    iDx : integer ;
begin
    Result := 0 ;
    iDx := mNames.IndexOf(aName) ;
    try
        if iDx >= 0 then Result := mCount[APos, iDx, AResult] ;
    except
        Result := 0 ;
    end ;
end ;

function  TRetieveEx.GetCount(Index: integer; AResult:boolean; APos:integer): integer ;
begin
    Result := 0 ;
    if Count <= Index then Exit ;
    try
        Result := mCount[APos, Index, AResult] ;
    except
        Result := 0 ;
    end ;
end ;

function  TRetieveEx.Count() : integer ;
begin
    Result := mNames.Count ;
end ;

function TRetieveEx.ItemCount() : integer;
begin
    Result := Length(mCount) ;
end;

function  TRetieveEx.GetName(Index: integer): string ;
begin
    Result := '' ;
    if Count <= Index then Exit ;
    try
        Result := mNames.Strings[Index] ;
    except
        Result := '' ;
    end ;
end ;

function TRetieveEx.GetIndex(AName: string): integer;
begin
    Result := mNames.IndexOf(aName) ;
end;
//------------------------------------------------------------------------------
//    TDelDatas
//------------------------------------------------------------------------------
constructor TDelDatas.Create;
begin
    mLen   := 0 ;
    mfList := TStringList.Create ;
end ;

destructor TDelDatas.Destroy;
begin
    mfList.Free ;
    mfList := nil ;
end ;

function TDelDatas.SetDelete(const ABuf): string ; // filename
var
    sTm : string ;
    fh  : integer ;
    Buf : array of BYTE ;
    nPass : boolean ;
begin
    Result := '' ;
    if not Assigned(mDelFileName) then Exit ;

    SetLength(Buf, mLen) ;
    sTm := OnDelFileName(ABuf) ;
    if sTm = '' then Exit ;

    fh := FileOpen(sTm, fmOpenReadWrite) ;
    if fh < 0 then Exit ;
    try
        while FileRead(fh, Buf[0], mLen)=mLen do
        begin
            if CompareMem(@ABuf, @Buf[0], mLen) then
            begin
                //DRM 2호기 마지막공정을 통과하지 않은 작업중이던 데이터 삭제방지.
                if Assigned(mDelOnWorkData) then
                begin
                    OnWorkData(Self, ABuf, FileSeek(fh, 0, 1) div mLen, nPass) ;
                    if nPass then
                    begin
                        Inc(mPassCnt) ; 
                        Continue ;
                    end ;
                end ;
                //--------------------------------------------------------------
                Buf[0] := 0 ;
                FileSeek(fh, -mLen, 1) ;
                FileWrite(fh, Buf[0], mLen) ;
                Result := sTm ;
                Break ;
            end ;
            //{$IFNDEF _VIEWER}
            Application.ProcessMessages ;
            //{$ENDIF}
        end ;
    finally
        FileClose(fh) ;
    end ;
    SetLength(Buf, 0) ;
end ;

function TDelDatas.SetPack(afName: string): integer ; // delete Counter
var
    fNew,
    fOld : integer ;
    Buf  : array of BYTE ;
    sTm  : string ;
begin
    Result := 0 ;
    if not FileExists(afName) then Exit ;
    SetLength(Buf, mLen) ;

    fOld := FileOpen(afName, fmOpenRead) ;
    if fOld < 0 then Exit ;
    try
        fNew := FileCreate(ChangeFileExt(afName, '.$$$')) ;
        if fNew >= 0 then
        begin
            gLog.ToFiles('------------------------>', []) ;
            gLog.ToFiles(' Delete Data Work ', []) ;
            gLog.ToFiles(' %s', [afName]) ;
            gLog.ToFiles(' Record of File: %d', [FileSeek(fOld, 0, 2) div mLen]) ;
            FileSeek(fOld, 0, 0) ;

            try
                while FileRead(fOld, Buf[0], mLen)=mLen do
                begin
                    if Buf[0] <> 0 then
                    begin
                        FileWrite(fNew, Buf[0], mLen) ;
                        Inc(Result) ;
                    end
                    else
                    begin
                        if Assigned(mDelGrpName) then
                        begin
                            sTm := OnDelGrpName(Buf[0]);
                            if sTm <> '' then
                            begin
                                DeleteFile(sTm) ;
                                gLog.ToFiles(' Graph File Deleted ', []);
                                gLog.ToFiles(' %s', [sTm]) ;
                            end;
                        end ;
                    end ;
                end ;
            finally
                FileClose(fNew) ;
            end ;

            gLog.ToFiles(' Del Count: %d ', [Result]) ;
            gLog.ToFiles('------------------------>', []) ;
        end ;
    finally
        FileClose(fOld) ;
    end ;

    DeleteFile(afName) ;
    if Result > 0 then RenameFile(ChangeFileExt(afName, '.$$$'), afName)
    else               DeleteFile(ChangeFileExt(afName, '.$$$')) ;
    if Length(Buf) > 0 then SetLength(Buf, 0) ;
end ;


function  TDelDatas.Del(dPos: array of integer; Count: integer;
                        TempName: string): integer ; // deleted counter
var
    i,
    fh  : integer ;
    Buf : array of BYTE ;
    sTm : string ;
begin
    mPassCnt := 0 ;
    Result   := 0 ;
    if not FileExists(TempName)
        or (mLen <= 0) then Exit ;

    fh := FileOpen(TempName, fmOpenReadWrite) ;
    if fh < 0 then Exit ;

    mfList.Clear ;
    try
        SetLength(Buf, mLen) ;
        for i := 0 to Count-1 do
        begin
            if FileSeek(fh, (dPos[i]-1) * mLen, 0) < 0 then Break
            else
            begin
                if FileRead(fh, Buf[0], mLen) = mLen then
                begin
                    sTm := SetDelete(Buf[0]) ;
                    if sTm <> '' then
                    begin
                        if mfList.IndexOf(sTm) < 0 then
                        begin
                            mfList.Add(sTm) ;
                            FileSeek(fh, -mLen, 1) ;
                            Buf[0] := 0 ;
                            FileWrite(fh, Buf[0], mLen) ;
                        end ;
                    end ;
                end ;
            end ;
        end ;

        for i := 0 to mfList.Count-1 do
        begin
            Result := Result + SetPack(mfList.Strings[i]) ;
        end ;
    finally
        FileClose(fh) ;
    end ;

    if Result > 0 then SetPack(TempName) ;
    SetLength(Buf, 0) ;
end ;

{ TRetrieveItem }

constructor TRetrieveItem.Create(AUserCount, Bufsize: integer);
begin
    inherited Create(AUserCount, Bufsize) ;
end;

destructor TRetrieveItem.Destroy;
begin
  inherited Destroy ;
end;

function TRetrieveItem.GetNgSum(APos:integer): integer;
var
    i : integer ;
begin
    Result := 0 ;
    for i := 0 to Count-1 do Result := Result + GetCount(i, false, APos) ;
end;

function TRetrieveItem.GetOkSum(APos:integer): integer;
var
    i : integer ;
begin
    Result := 0 ;
    for i := 0 to Count-1 do Result := Result + GetCount(i, true, APos) ;
end;

end.
