unit KiiFaGraphDB;
{
    rValidity [0] 삭제여부
    rTime : 파일명과 데이터구분 키
    rsize : 저장된 그래프데이타 크기
    rREM  : DWORD ;

    저장경로.
    %savedir% yyyymm / yyyymmdd.gmf

    2009.10.19 대경에서 밤을 세우며...
    - 파일을 열때 공유모드 추가함, 조회를 별도 프로그램으로 처리하다 보니 아주
      가끔 검사프로그램에서 그래프 파일을 저장하지 못해 에러를 발생한다.
}
interface
uses
  Windows, Messages, SysUtils, Classes, FaGraphEx ;

type
TStoreType = (stDay, stHour) ;
TKiiGraphHead = packed record // size of 24
    rValidity : array[0..7]of BYTE ;  //1~: User Flag
    rTime : double ;
    rsize : Int64 ;
end ;
TUsrGraphFileName = function (Sender:TObject; AHead:TKiiGraphHead):string of Object ;
TKiiGraphDB=class
private
    mDir : string ;
    msType : TStoreType ;

    function  Add(AFlag:BYTE; ATime: double; Buff: TStream): integer ;
    function  Read(AFlag:BYTE; ATime:double; var Stream:TFileStream): Int64 ;
    procedure SetSaveDir(const Value: string);

    function  GetTempFile : string ;
public
    constructor Create(AStoreType:TStoreType; AsaveDir: string) ;
    destructor  Destroy ; override ;

    function  Find(AFlag:integer;ATime:double): Int64 ;
    procedure Load(ATime: double; AGraph:TFaGraphEx; SeriesCount:integer) ; overload ;
    procedure Save(ATime: double; AGraph:TFaGraphEx; SeriesCount:integer;
        IsDupCheck: boolean=true) ; overload ;
    procedure Load(ATime: double; ATag: BYTE; AGraph:TFaGraphEx;
        SeriesCount:integer) ; overload ;
    procedure Save(ATime: double; ATag: BYTE; AGraph:TFaGraphEx;
        SeriesCount:integer;IsDupCheck: boolean=true) ; overload ;
    //구형데이타를 처리할때
    function  Append(AFlag:BYTE; ATime: double; AFile : string):integer ;
    procedure Delete(AFlag:BYTE; ATime: double) ;
    //Repack
    function Repack(AFile:string; UsrGraphFileName:TUsrGraphFileName):integer;
    //
    function GetCount(AFile:string) : integer ;
    //4Test
    function Load(AFile:string; AIndex: integer; AGraph: TFaGraphEx): boolean ; overload ;
    function Load(AFile:string; AIndex, GraphTag: integer;   AGraph: TFaGraphEx): boolean ; overload ;
    //2008.05.09 private -> public으로 이동
    function  GetGraphFileName(ATime: double; IsCreate: boolean): string;
    //2009.01.03 기존그래프 파일이 필요할때.
    function SaveToOldFile(SaveFileName:string; GraphTime:double;
        GraphTag:integer):boolean ;
    //2009.11.16
    function GetGraphHead(AFile: string; Index: integer) : TKiiGraphHead ;

    property SaveDir : string read mDir write SetSaveDir ;
end ;

TKiiGraphDB2 = class(TKiiGraphDB)
private
    mList: TList ;
public
    constructor Create(AStoreType:TStoreType; AsaveDir: string) ;
    destructor  Destroy; override ;

    procedure Add(ATime: double; AGraph:TFaGraphEx; SeriesCount:integer) ; overload ;
    procedure SaveToFiles(IsLog:boolean=false) ;
    function  FileCount(): integer ;
end ;

var gKiiDB: TKiiGraphDB2 ;

implementation
uses
    Log, myUtils ;

const _FILE_EX = '.gmf' ;

{ TKiiGraphDB }

function TKiiGraphDB.Add(AFlag:BYTE; ATime: double; Buff: TStream): integer;
var
    sTm : string ;
    fs : TFileStream ;
    kiiDB : TKiiGraphHead ;
begin
    Result := -1 ;
    sTm := GetGraphFileName(ATime, true);
    if not FileExists(sTm) then
        fs := TFileStream.Create(sTm, fmCreate)
    else
        fs := TFileStream.Create(sTm, fmOpenWrite or fmShareDenyNone) ;

    if not Assigned(fs) then Exit ;
    try
        FillChar(kiiDB, sizeof(TKiiGraphHead), 0) ;
        kiiDB.rValidity[0] := 1 ;
        KiiDB.rValidity[1] := AFlag ;
        kiiDB.rTime := ATime ;
        kiiDB.rsize := Buff.Size ;

        fs.Seek(0, soFromEnd) ;
        Result := fs.Write(kiiDB, sizeof(TKiiGraphHead)) ;
        Buff.Seek(0, soFromBeginning);
        Result := fs.CopyFrom(Buff, Buff.Size) ;
    finally
        fs.Free ;
    end ;
end;

function TKiiGraphDB.Append(AFlag:BYTE; ATime: double; AFile: string): integer;
var
    fs : TMemoryStream ;
begin
    Result := -1 ;
    if not FileExists(AFile) then Exit ;

    fs := TMemoryStream.Create ;
    try
        fs.LoadFromFile(AFile);
        Result := Add(AFlag, ATime, fs) ;
    finally
        fs.Free ;
    end ;
end;

constructor TKiiGraphDB.Create(AStoreType:TStoreType; ASaveDir: string);
begin
    msType := AStoreType ;
    mDir := AsaveDir ;
    if mDir = '' then mDir := MakeRunPath('Result');
end;

destructor TKiiGraphDB.Destroy;
begin

end;

function  TKiiGraphDB.Find(AFlag:integer; ATime:double): Int64 ;
var
    sTm : string ;
    fs  : TFileStream ;
    Buff : TKiiGraphHead ;
begin
    Result := -1 ;
    sTm := GetGraphFileName(ATime, false);
    if not FileExists(sTm) then Exit ;

    fs := TFileStream.Create(sTm, fmOpenRead);
    if not Assigned(fs) then Exit ;
    try
        fs.Seek(0, soFromBeginning) ;
        while fs.Read(Buff, sizeof(TKiiGraphHead))=sizeof(TKiiGraphHead) do
        begin
            if (Buff.rValidity[0] > 0)
                and (Buff.rTime = ATime)
                and(AFlag = Buff.rValidity[1]) then
            begin
                Result := fs.Seek(-sizeof(TKiiGraphHead), soFromCurrent) ;
                Break ;
            end ;
            fs.Seek(Buff.rsize, soFromCurrent) ;
        end ;
    finally
        fs.Free ;
    end ;
end ;

function TKiiGraphDB.Read(AFlag:BYTE; ATime: double; var Stream: TFileStream): Int64;
var
    sTm : string ;
    fs  : TFileStream ;
    Buff : TKiiGraphHead ;
begin
    Result := Find(AFlag, ATime) ;
    if Result < 0 then Exit ;

    sTm := GetGraphFileName(ATime, false);
    if not FileExists(sTm) then Exit ;

    fs := TFileStream.Create(sTm, fmOpenRead);
    if not Assigned(fs) then Exit ;
    try
        fs.Seek(Result, soFromBeginning) ;
        fs.Read(Buff, sizeof(TKiiGraphHead));
        Result := Stream.CopyFrom(fs, Buff.rsize);
    finally
        fs.Free ;
    end ;
end;

procedure TKiiGraphDB.Load(ATime: double; AGraph: TFaGraphEx; SeriesCount:integer);
begin
    Load(ATime, AGraph.Tag, AGraph, SeriesCount) ;
end;

procedure TKiiGraphDB.Save(ATime: double; AGraph: TFaGraphEx;  SeriesCount:integer;IsDupCheck: boolean) ;
begin
    Save(ATime, AGraph.Tag, AGraph, SeriesCount, IsDupCheck);
end;

procedure TKiiGraphDB.SetSaveDir(const Value: string);
begin
    mDir := Value ;
    gLog.ToFiles('KiiGraphDB saveDir 변경 : %s', [mDir]) ;
end;

function TKiiGraphDB.GetGraphFileName(ATime: double; IsCreate:boolean): string ;
begin
    case msType of
        stDay : Result := FormatDateTime('yyyymm\yyyymmdd', ATime) ;
    else //stHour
        Result := FormatDateTime('yyyymm\yyyymmdd\yyyymmddhh', ATime) ;
    end ;
    Result := Format('%s\%s%s', [mDir, Result, _FILE_EX]) ;
    if IsCreate and not DirectoryExists(ExtractFileDir(Result)) then
        ForceDirectories(ExtractFileDir(Result));
end ;

function TKiiGraphDB.GetTempFile: string;
begin
    Result := MakeRunPath('Temp')
              +'\'
              +FormatDateTime('yyyymmddhhnnss', Now)
              +'.tmp';

    if not DirectoryExists(ExtractFileDir(Result)) then
        ForceDirectories(ExtractFileDir(Result));
end;

procedure TKiiGraphDB.Delete(AFlag: BYTE; ATime: double);
var
    sTm : string ;
    fs  : TFileStream ;
    Buff : TKiiGraphHead ;
    fPos : Int64 ;
begin
    fPos := Find(AFlag, ATime) ;
    if fPos < 0 then Exit ;

    sTm := GetGraphFileName(ATime, false);
    if not FileExists(sTm) then Exit ;

    fs := TFileStream.Create(sTm, fmOpenReadWrite);
    if not Assigned(fs) then Exit ;
    try
        fs.Seek(fPos, soFromBeginning) ;
        fs.Read(Buff, sizeof(TKiiGraphHead));
        Buff.rValidity[0] := 0 ;
        fs.Seek(-sizeof(TKiiGraphHead), soFromCurrent) ;
        fs.Write(Buff, sizeof(TKiiGraphHead));
    finally
        fs.Free ;
    end ;
end;


procedure TKiiGraphDB.Load(ATime: double; ATag: BYTE;
  AGraph: TFaGraphEx; SeriesCount: integer);
var
    sTm : string ;
    fs : TFileStream ;
begin
    sTm := GetTempFile ;
    fs := TFileStream.Create(sTm, fmCreate) ;
    if not Assigned(fs) then Exit ;
    try
        if Read(ATag, ATime, fs) > sizeof(TKiiGraphHead) then
        begin
            AGraph.BeginUpdate() ;
            fs.Seek(0, soFromBeginning);
            AGraph.Load(fs, SeriesCount);
            AGraph.EndUpdate() ;
        end ;
    finally
        fs.Free ;
        DeleteFile(sTm) ;
    end;
end;

procedure TKiiGraphDB.Save(ATime: double; ATag: BYTE;
  AGraph: TFaGraphEx; SeriesCount: integer;IsDupCheck: boolean);
var
    sTm : string ;
    fs : TFileStream ;
begin
    if IsDupCheck then Delete(ATag, ATime);

    sTm := GetTempFile ;
    fs := TFileStream.Create(sTm, fmCreate) ;
    if not Assigned(fs) then Exit ;
    try
        AGraph.Save(fs, SeriesCount) ;
        Add(ATag, ATime, fs) ;
    finally
        fs.Free ;
        DeleteFile(sTm) ;
    end;
end;

function TKiiGraphDB.Repack(AFile: string;
  UsrGraphFileName: TUsrGraphFileName): integer;
var
    sTm : string ;
    fs, Tmp  : TFileStream ;
    Buff : TKiiGraphHead ;
begin
    Result := 0 ;
    if not FileExists(AFile)or not Assigned(UsrGraphFileName) then Exit ;

    fs := TFileStream.Create(AFile, fmOpenRead or fmShareDenyNone);
    if not Assigned(fs) then Exit ;
    try
        fs.Seek(0, soFromBeginning) ;
        while fs.Read(Buff, sizeof(TKiiGraphHead))=sizeof(TKiiGraphHead) do
        begin
            sTm := UsrGraphFileName(Self, Buff);
            if sTm <> '' then
            begin
                Tmp := TFileStream.Create(sTm, fmCreate);
                try
                    Tmp.CopyFrom(fs, Buff.rsize) ;
                finally
                    Tmp.Free ;
                end ;
                Inc(Result) ;
            end
            else fs.Seek(Buff.rsize, soFromCurrent) ;
        end ;
    finally
        fs.Free ;
    end ;
end;

function TKiiGraphDB.GetCount(AFile: string): integer;
var
    fs  : TFileStream ;
    Buff : TKiiGraphHead ;
begin
    Result := 0 ;
    if not FileExists(AFile) then Exit ;

    fs := TFileStream.Create(AFile, fmOpenRead or fmShareDenyNone);
    if not Assigned(fs) then Exit ;
    try
        fs.Seek(0, soFromBeginning) ;
        while fs.Read(Buff, sizeof(TKiiGraphHead))=sizeof(TKiiGraphHead) do
        begin
            fs.Seek(Buff.rsize, soFromCurrent) ;
            Inc(Result) ;
        end ;
    finally
        fs.Free ;
    end ;
end;

function TKiiGraphDB.Load(AFile:string; AIndex: integer; AGraph: TFaGraphEx): boolean ;
begin
    Result := Load(AFile, AIndex, AGraph.Tag, AGraph) ;
end;

function TKiiGraphDB.SaveToOldFile(SaveFileName: string; GraphTime: double;
  GraphTag : integer): boolean;
var
    fs : TFileStream ;
begin
    Result := false ;

    fs := TFileStream.Create(SaveFileName, fmCreate) ;
    if not Assigned(fs) then Exit ;
    try
        Result := Read(GraphTag, GraphTime, fs) > 0 ;
    finally
        fs.Free ;
    end;

    if not Result then DeleteFile(SaveFileName) ;
end;

function TKiiGraphDB.Load(AFile: string; AIndex, GraphTag: integer;
  AGraph: TFaGraphEx): boolean;
var
    iDx : integer ;
    fs, fsg : TFileStream ;
    Buff : TKiiGraphHead ;
    nP : Int64 ;
    sTm : string ;
begin
    iDx := 0 ;
    Result := false ;
    if not FileExists(AFile) then Exit ;
    nP := 0 ;
    fs := TFileStream.Create(AFile, fmOpenRead);
    if not Assigned(fs) then Exit ;
    try
        fs.Seek(0, soFromBeginning) ;
        while fs.Read(Buff, sizeof(TKiiGraphHead))=sizeof(TKiiGraphHead) do
        begin
            nP := fs.Seek(-sizeof(TKiiGraphHead), soFromCurrent) ;
            fs.Seek(sizeof(TKiiGraphHead), soFromCurrent) ;
            fs.Seek(Buff.rsize, soFromCurrent) ;
            if Buff.rValidity[1]=GraphTag then Inc(iDx) ;

            if (iDx > 0) and (AIndex = iDx) then
            begin
                Result := true ;
                Break ;
            end ;
        end ;
    finally
        fs.Free ;
    end ;

    if Result then
    begin
        fs := TFileStream.Create(AFile, fmOpenRead);
        if not Assigned(fs) then Exit ;
        try
            fs.Seek(nP, soFromBeginning) ;
            fs.Read(Buff, sizeof(TKiiGraphHead));

            sTm := GetTempFile ;
            fsg := TFileStream.Create(sTm, fmCreate) ;
            if Assigned(fsg) then
            begin
                try
                    if fsg.CopyFrom(fs, Buff.rsize) > sizeof(TKiiGraphHead) then
                    begin
                        AGraph.BeginUpdate() ;
                        fsg.Seek(0, soFromBeginning);
                        AGraph.Load(fsg, AGraph.Series.Count*2);
                        AGraph.EndUpdate() ;
                    end ;
                finally
                    fsg.Free ;
                    DeleteFile(sTm) ;
                end;
            end ;
        finally
            fs.Free ;
        end ;
    end ;
end;

function TKiiGraphDB.GetGraphHead(AFile: string; Index: integer): TKiiGraphHead;
var
    iDx : integer ;
    fs : TFileStream ;
    Buff : TKiiGraphHead ;
begin
    FillChar(Result, sizeof(TKiiGraphHead), 0) ;
    if not FileExists(AFile) then Exit ;
    fs := TFileStream.Create(AFile, fmOpenRead);
    if not Assigned(fs) then Exit ;
    
    try
        fs.Seek(0, soFromBeginning) ;
        while fs.Read(Buff, sizeof(TKiiGraphHead))=sizeof(TKiiGraphHead) do
        begin
            Inc(iDx) ;
            if Index = iDx then
            begin
                Move(Buff, Result, sizeof(TKiiGraphHead)) ;
                Break ;
            end ;
            
            fs.Seek(Buff.rsize, soFromCurrent) ;
        end ;
    finally
        fs.Free ;
    end ;
end;

{ TKiiGraphDB2 }
type
pUsrGraphDB = ^TUsrGraphDB ;
TUsrGraphDB = packed record
    rTag: integer ;
    rTime: double ;
    rBuff: TMemoryStream ;
end ;

procedure TKiiGraphDB2.Add(ATime: double; AGraph: TFaGraphEx;
  SeriesCount: integer);
var
    nP: pUsrGraphDB ;
    //fs: TFileStream ;
begin
    New(nP) ;
    nP^.rTag:= AGraph.Tag ;
    nP^.rTime:= ATime ;
    nP^.rBuff:= TMemoryStream.Create ;
    AGraph.Save(TFileStream(nP^.rBuff), SeriesCount);
    //gLog.Debug('%d',[nP^.rBuff.Size]);
    mList.Add(nP)  ;
end;

constructor TKiiGraphDB2.Create(AStoreType:TStoreType; AsaveDir: string) ;
begin
    inherited Create(AStoreType, AsaveDir) ;
    mList:= TList.Create ;
end;

destructor TKiiGraphDB2.Destroy;
begin
    SaveToFiles() ;
    FreeAndNil(mList) ;
  inherited;
end;

function TKiiGraphDB2.FileCount: integer;
begin
    Result:= mList.Count ;
end;

procedure TKiiGraphDB2.SaveToFiles(IsLog:boolean);
var
    i: integer ;
    nP: pUsrGraphDB ;
begin
    if mList.Count <= 0 then Exit ;

    for i:= 0 to mList.Count-1 do
    begin
        nP:= mList.Items[0] ;
        if not Assigned(nP) then
        begin
            mList.Delete(0) ;
            Continue ;
        end ;

        inherited Add(nP^.rTag, nP^.rTime, TFileStream(nP^.rBuff)) ;
        if IsLog then
        begin
            gLog.Debug('grp saved Tag:%d Time:%s',[nP^.rTag,
                               FormatDateTime('yyyy-mm-dd hh:nn:ss',nP^.rTime)]);
        end ;
        try
            FreeAndNil(nP^.rBuff) ;
            Dispose(nP) ;
        finally
            mList.Delete(0);
        end ;
    end ;
end;

end.
