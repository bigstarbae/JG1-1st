unit Modelunit;
{$INCLUDE myDefine.inc}

interface

uses
    Windows, sysutils, {$IFNDEF VER150}FileCtrl, {$ENDIF} Grids, Classes,
    DataUnit, ModelType, SeatType, SeatMotorType, Generics.Collections;

const
    _MAX_MODEL_COUNT = 50;

type

    TAryModels = array[1.._MAX_MODEL_COUNT] of TModels;

    TBase = class
    public
        constructor Create();
        destructor Destroy; override;
    end;

    TMdlExDatas = TDictionary<string, TMdlExData>;

    TBaseModels = class(TBase)
    private
        mMdlNoBySt: array[TStationID] of integer;       // 공정별 모델번호
        mModels: TAryModels;

        mMdlExDatas: TMdlExDatas;

        mIsModelLoaded: boolean;
        mIsModelFinded: boolean;

        procedure InitModels;
        procedure LoadModelList(AfName: string; var AModelList: TAryModels);
        procedure SaveModelList(AfName: string; const AModelList: TAryModels; ABegin, AEnd: integer);

        procedure LoadLastIndex();
        procedure SaveLastIndex();

    public
        constructor Create;
        destructor Destroy; override;

        procedure SelectModel(Station: TStationID; ModelNo: integer);
        procedure SetTypeBits(ModelNo: integer; TypeBits: DWORD);

        function CopyTo(SrcIdx, TarIdx: integer): boolean;
        function DeleteModel(Index: integer): boolean;

        function FindModel(ModelType: TModelType; Mask: DWORD): integer;
        function EditModel(const Buf: TModels; IsAll: boolean = false): boolean; overload;
        function EditModel(Index: integer; const Buf: TModels; IsSave: boolean = true): boolean; overload;

        function GetModel(Index: integer): TModel;
        function GetModels(Index: integer): TModels;
        function GetPModels(Index: Integer): PModels;
        function GetOffset(Station: TStationID; Index: integer): TOffset;

        function GetMotorTimeLimit(aMotor: TMotorORD; Index: integer): double;
        function GetMotorCurrLimit(aMotor: TMotorORD; Index: integer): double;

        function GetModelToStr(AIndex: integer; AItem: integer; IsUnit: boolean = false): string;

        function GetModelNo(Station: TStationID): integer;
        function GetUsrIndex(Station: TStationID): integer; overload;
        function GetUsrIndex(Station: integer): integer; overload;



        //
        function GetMdlExData(var MdlExData: TMdlExData; ModelType: TModelType; Mask: DWORD): boolean;
        procedure SetMdlExData(MdlExData: TMdlExData);

        property IsModelLoaded: boolean read mIsModelLoaded;
        property IsModelFinded: boolean read mIsModelFinded;

        function LoadFromEnv(FileName: string; IsOverWrite: boolean = false; CondBits: BYTE = $FF): boolean;
        function LoadFromIni(FileName: string; IsOverWrite: boolean = false; CondBits: BYTE = $FF): boolean;
        function SaveToIni(FileName: string): boolean;

        function LoadMdlExDatas(FileName: string): boolean;
        function SaveMdlExDatas(FileName: string): boolean;

    end;

    TUserModels = class(TBaseModels)
        constructor Create;
        destructor Destroy; override;

        function CurrentModel(Station: TStationID): TModel;
        function CurrentModels(Station: TStationID): TModels;
        function CurrentPModels(Station: TStationID): PModels;
        procedure CurrentOffset(Station: TStationID; var Offset: TOffset; var MtrOffset: TMotorOffset);
    end;

function GetModelToTxt(ModelBuf: TModel; AItem: integer; IsUnit: boolean = false): Widestring;


var
    gModels: TUserModels;

implementation

uses
    myUtils, IniFiles, Log, KiiMessages, IODef, Global, LangTran, DataUnitOrd,
    HVTester;

//------------------------------------------------------------------------------
// Utility
//------------------------------------------------------------------------------
function GetModelToTxt(ModelBuf: TModel; AItem: integer; IsUnit: boolean): Widestring;
begin
    with ModelBuf do
    begin

        case AItem of

            ord(roPosType):
                Result := TPOS_TYPE_STR[BYTE(rTypes.GetPosType)];
            ord(roPosExType):
                Result := rTypes.GetPosStr;

            ord(roCarType):
                Result := TCAR_TYPE_STR[BYTE(rTypes.GetCarType)];
            ord(roPartName):
                Result := rPartName;
            ord(roPartNo):
                Result := rPartNo;
            ord(roLclPartNo):
                Result := string(rLclPartNo);

            ord(roIndex):
                Result := Format('%0.2d', [rIndex]);
        {    ord(roUsrType):
            begin
                Result:= TUSR_TYPE_STR[rTypes[toUsrType]] ;
            end ;
            ord(roDrvType):
            begin
                Result:= TDRV_TYPE_STR[rTypes[toDrvType]] ;
            end ;
            ord(roSeatType):
            begin
                Result:= TSEAT_TYPE_STR[rTypes[toSeatType]] ;
            end ;
            ord(roImsType):
            begin
                Result:= TIMS_TYPE_STR[rTypes[toImsType]] ;
            end ;



         //   ord(roIndex)     : Result := Format('%0.2d', [rIndex]);          }
            //spec
            ord(roSpecAncPT):
                begin
                    Result := ModelBuf.rSpecs.rAncPTReg.ToStrWithUnit2('0.0', IsUnit);
                end;

            ord(roSpecBuckleHiLo):
                begin
                    Result := ModelBuf.rspecs.rBuckleCurr.ToStrWithUnit2('0.0', IsUnit);
                end;

            ord(roSpecHeatOnLo):
                begin
                    Result := GetFloatToStr(rspecs.rOnCurr[hvtHeat].rLo);
                    if IsUnit then
                        Result := Result + ' A';
                end;
            ord(roSpecHeatOnHi):
                begin
                    Result := GetFloatToStr(rspecs.rOnCurr[hvtHeat].rHi);
                    if IsUnit then
                        Result := Result + ' A';
                end;
            ord(roSpecHeatOnHiLo):
                begin
                    Result := GetModelToTxt(ModelBuf, ord(rospecHeatOnLo), false) + ' ~ ' + GetModelToTxt(ModelBuf, ord(rospecHeatOnHi), false);

                    if IsUnit then
                        Result := Result + ' A';
                end;

            ord(roSpecHeatOffLo):
                begin
                    Result := GetFloatToStr(rspecs.rOffCurr[hvtHeat].rLo);
                    if IsUnit then
                        Result := Result + ' A';
                end;
            ord(roSpecHeatOffHi):
                begin
                    Result := GetFloatToStr(rspecs.rOffCurr[hvtHeat].rHi);
                    if IsUnit then
                        Result := Result + ' A';
                end;
            ord(roSpecHeatOffHiLo):
                begin
                    Result := GetModelToTxt(ModelBuf, ord(rospecHeatOffLo), false) + ' ~ ' + GetModelToTxt(ModelBuf, ord(rospecHeatOffHi), false);

                    if IsUnit then
                        Result := Result + ' A';
                end;

            ord(roSpecVentOnLo):
                begin
                    Result := GetFloatToStr(rspecs.rOnCurr[hvtVent].rLo);
                    if IsUnit then
                        Result := Result + ' A';
                end;
            ord(roSpecVentOnHi):
                begin
                    Result := GetFloatToStr(rspecs.rOnCurr[hvtVent].rHi);
                    if IsUnit then
                        Result := Result + ' A';
                end;
            ord(roSpecVentOnHiLo):
                begin
                    Result := GetModelToTxt(ModelBuf, ord(roSpecVentOnLo), false) + ' ~ ' + GetModelToTxt(ModelBuf, ord(roSpecVentOnHi), false);
                    if IsUnit then
                        Result := Result + ' A';
                end;

            ord(roSpecVentOffLo):
                begin
                    Result := GetFloatToStr(rspecs.rOffCurr[hvtVent].rLo);
                    if IsUnit then
                        Result := Result + ' A';
                end;
            ord(roSpecVentOffHi):
                begin
                    Result := GetFloatToStr(rspecs.rOffCurr[hvtVent].rHi);
                    if IsUnit then
                        Result := Result + ' A';
                end;
            ord(roSpecVentOffHiLo):
                begin
                    Result := GetModelToTxt(ModelBuf, ord(roSpecVentOffLo), false) + ' ~ ' + GetModelToTxt(ModelBuf, ord(roSpecVentOffHi), false);
                    if IsUnit then
                        Result := Result + ' A';
                end;

        else
            Result := '';
        end;
    end;
end;
//------------------------------------------------------------------------------
// TBase
//------------------------------------------------------------------------------

constructor TBase.Create();
begin
end;

destructor TBase.Destroy;
begin
end;
{
function TBase.LoadIndex(Section, Identity: string): integer ;
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

procedure TBase.SaveIndex(Section, Identity: string; Values: integer) ;
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
}
//------------------------------------------------------------------------------
// TModel
//------------------------------------------------------------------------------

constructor TBaseModels.Create;
var
    i: TStationID;
begin
    inherited Create;
    for i := Low(TStationID) to High(TStationID) do
        mMdlNoBySt[i] := 1;

    FillChar(mModels, sizeof(TaryModels), 0);

    LoadModelList(Format('%s\models.dat', [GetUsrDir(udENV, Now())]), mModels);
    InitModels;

    mMdlExDatas := TMdlExDatas.Create;
end;

destructor TBaseModels.Destroy;
begin
{$IFDEF _VIEWER}
    SaveModelList(Format('%s\models.dat', [GetUsrDir(udENV, Now())]), mModels, 1, _MAX_MODEL_COUNT);
{$ENDIF}

    mMdlExDatas.Free;

    inherited Destroy;
end;

function TBaseModels.CopyTo(SrcIdx, TarIdx: integer): boolean;
var
    MdlIdx: integer;
begin
    if SrcIdx in [1.._MAX_MODEL_COUNT] then
    begin
        if TarIdx in [1.._MAX_MODEL_COUNT] then
        begin
            MdlIdx := mModels[TarIdx].rIndex;
            Move(mModels[SrcIdx], mModels[TarIdx], sizeof(TModels));
            mModels[TarIdx].rIndex := MdlIdx;

            SaveModelList(Format('%s\models.dat', [GetUsrDir(udENV, Now())]), mModels, TarIdx, TarIdx);

            Exit(true);
        end;
    end;
    Result := false;
end;

function TBaseModels.DeleteModel(Index: integer): boolean;
begin
    if not (Index in [1.._MAX_MODEL_COUNT]) then
        Exit(false);

    FillChar(mModels[Index], sizeof(TModels), 0);
    SaveModelList(Format('%s\models.dat', [GetUsrDir(udENV, Now())]), mModels, Index, Index);

    Result := true;
end;

procedure TBaseModels.SelectModel(Station: TStationID; ModelNo: integer);
var
    bTm: boolean;
begin
    if ((ModelNo >= 1) and (_MAX_MODEL_COUNT >= ModelNo)) then
    begin
        mIsModelLoaded := true;
        if (mMdlNoBySt[Station] <> ModelNo) then
        begin
            mMdlNoBySt[Station] := ModelNo;
            SaveLastIndex();
        end;
    end
    else
    begin
        mIsModelLoaded := false;
    end;
end;

procedure TBaseModels.SetMdlExData(MdlExData: TMdlExData);
begin
    if not mMdlExDatas.ContainsKey(MdlExData.ToKeyStr) then
    begin
        mMdlExDatas.Add(MdlExData.ToKeyStr, MdlExData);
        Exit;
    end;

    mMdlExDatas[MdlExData.ToKeyStr] := MdlExData;
end;

procedure TBaseModels.SetTypeBits(ModelNo: integer; TypeBits: DWORD);
begin
    if (ModelNo in [1.._MAX_MODEL_COUNT]) then
    begin
        mModels[ModelNo].rTypes.mDataBits := TypeBits;
    end;
end;

function TBaseModels.EditModel(const Buf: TModels; IsAll: boolean = false): boolean;
var
    i: integer;
begin
    Result := false;
    if not (Buf.rIndex >= 1) or (_MAX_MODEL_COUNT < Buf.rIndex) then
        exit;

    Move(Buf, mModels[Buf.rIndex], sizeof(TModels));
    if IsAll then
    begin
        for i := 1 to _MAX_MODEL_COUNT do
        begin
            if Buf.rIndex = i then
                Continue;
            Move(Buf.rspecs, mModels[i].rspecs, sizeof(TSpecs));
        end;
        SaveModelList(Format('%s\models.dat', [GetUsrDir(udENV, Now())]), mModels, 1, _MAX_MODEL_COUNT);
    end
    else
    begin
        SaveModelList(Format('%s\models.dat', [GetUsrDir(udENV, Now())]), mModels, Buf.rIndex, Buf.rIndex);
    end;

    Result := true;
end;

function TBaseModels.EditModel(Index: integer; const Buf: TModels; IsSave: boolean): boolean;
begin
    Result := false;
    if not (Index >= 1) or (_MAX_MODEL_COUNT < Index) then
        exit;

    Move(Buf, mModels[Index], sizeof(TModels));
    if IsSave then
        SaveModelList(Format('%s\models.dat', [GetUsrDir(udENV, Now())]), mModels, Index, Index);
    Result := true;
end;

function TBaseModels.FindModel(ModelType: TModelType; Mask: DWORD): integer;
var
    i: integer;
    SrchDataBits: DWORD;
begin
    Result := 0;
    mIsModelFinded := false;

    for i := 1 to _MAX_MODEL_COUNT do
    begin

        if mModels[i].rTypes.IsEqual(ModelType, Mask) then
        begin
            mIsModelFinded := true;
            Result := i;
            Exit;
        end;
    end;
end;

function TBaseModels.GetModels(Index: integer): TModels;
begin
   // if not(Index In[1.._MAX_MODEL_COUNT]) then Exit ;
    if not (Index >= 1) or (_MAX_MODEL_COUNT < Index) then
        exit;

    FillChar(Result, sizeof(TModels), 0);
    Result := mModels[Index];
end;

function TBaseModels.GetModelToStr(AIndex: integer; AItem: integer; IsUnit: boolean): string;
begin
{ USER EDIT }
    Result := GetModelToTxt(GetModel(AIndex), AItem, IsUnit);
end;

function TBaseModels.GetOffset(Station: TStationID; Index: integer): TOffset;
begin
    with mModels[Index] do
        Result := rOffset[ord(Station)];
end;

function TBaseModels.GetPModels(Index: Integer): PModels;
begin
    if not (Index >= 1) or (_MAX_MODEL_COUNT < Index) then
        exit;

    Result := @mModels[Index];
end;

function TBaseModels.GetMdlExData(var MdlExData: TMdlExData; ModelType: TModelType; Mask: DWORD): boolean;
var
    Temp: TMdlExData;
begin
    Temp := TMdlExData.Create(ModelType.mID, ModelType.mDataBits and Mask);

    if mMdlExDatas.ContainsKey(Temp.ToKeyStr) then
    begin
        MdlExData := mMdlExDatas[Temp.ToKeyStr];
        Exit(true);
    end;

    Result := false;
end;

function TBaseModels.GetModel(Index: integer): TModel;
begin
    FillChar(Result, sizeof(TModel), 0);
    with Result do
    begin
        rIndex := mModels[Index].rIndex;
        Move(mModels[Index].rTypes, rTypes, sizeof(rTypes));
        rPartName := mModels[Index].rPartName;
        rPartNo := mModels[Index].rPartNo;

        Move(mModels[Index].rspecs, rspecs, sizeof(rspecs));
    end;
end;

function TBaseModels.GetModelNo(Station: TStationID): integer;
begin
    Result := GetUsrIndex(Station);
end;

procedure TBaseModels.InitModels;
var
    i: integer;
    Mtr: TMotorOrd;
begin
    try
        for i := 1 to _MAX_MODEL_COUNT do
        begin
            with mModels[i] do
            begin

                if rIndex <> 0 then
                begin
                    Continue;
                end;

                rIndex := i;

                for Mtr := Low(TMotorOrd) to MtrOrdHi do
                begin
                    with rSpecs.rMotors[Mtr] do
                    begin
                        rCurr.Create(0.5, 7.0);
                        rSpeed[twForw].Create(6.0, 8.0);
                        rSpeed[twBack].Create(6.0, 9.0);
                        rTime.Create(2.0, 7.0);
                        rInitNoiseTime := 1.0;
                        rInitNoise := 45.0;
                        rRunNoise := 50.0;
                    end;

                    mModels[i].rConstraints[Mtr].rMaxTime := 20;
                    mModels[i].rConstraints[Mtr].rStroke := 200;
                    mModels[i].rConstraints[Mtr].rLockedCurr := 7;
                    mModels[i].rConstraints[Mtr].rOperTIme := 5;
                end;

            end;
        end;
    finally
    end;
end;

function Load(FileHandle, Index: integer; var Buf: TModels): boolean;
begin
    Result := false;
    FileSeek(FileHandle, 0, 0);
    while FileRead(FileHandle, Buf, sizeof(TModels)) = sizeof(TModels) do
    begin
        if Buf.rIndex = Index then
        begin
            Result := true;
            Break;
        end;
    end;
end;

function TBaseModels.LoadMdlExDatas(FileName: string): boolean;
var
    FileHandle: integer;
    MdlExData: TMdlExData;
begin

    if FileExists(FileName) then
        FileHandle := FileOpen(FileName, fmOpenRead)
    else
        Exit(false);

    if FileHandle < 0 then
        Exit(false);

    mMdlExDatas.Clear;

    while FileRead(FileHandle, MdlExData, sizeof(TMdlExData)) = sizeof(TMdlExData) do
    begin
        SetMdlExData(MdlExData);
    end;

    FileClose(FileHandle);

    Result := true;
end;

function TBaseModels.SaveMdlExDatas(FileName: string): boolean;
var
    FileHandle: integer;
    Key: string;
begin
    if not FileExists(FileName) then
        FileHandle := FileCreate(FileName)
    else
        FileHandle := FileOpen(FileName, fmOpenReadWrite);

    if FileHandle <= 0 then
        Exit(false);

    for Key in mMdlExDatas.Keys do
    begin
        mMdlExDatas[Key].Write(FileHandle);
    end;

    FileClose(FileHandle);

    Result := true;

end;

procedure TBaseModels.LoadModelList(AfName: string; var AModelList: TAryModels);
var
    i, fh: integer;
    Buf: TModels;
begin
    if FileExists(AfName) then
        fh := FileOpen(AfName, fmOpenRead)
    else
        Exit;

    i := FileSeek(fh, 0, 2);
    if (i > 0) and ((i mod sizeof(TModels)) <> 0) then
    begin
        FileClose(fh);
        RenameFile(AfName, ChangeFileExt(AfName, '.' + FormatDateTime('yymmdd', Now)));
        gLog.ToFiles('Model File 크기이상 이름변경함.', []);
        Exit;
    end;

    try
        for i := 1 to _MAX_MODEL_COUNT do
        begin
            if Load(fh, i, Buf) then
            begin
                Move(Buf, AModelList[i], sizeof(TModels));
            end;
        end;
    finally
        FileClose(fh);
    end;
end;

procedure TBaseModels.SaveLastIndex;
var
    Ini: TIniFile;
    sTm: string;
    i: TStationID;
begin
    sTm := Format('%s\LstModelIndex.ini', [GetUsrDir(udENV, Now())]);
    Ini := TIniFile.Create(sTm);
    try
        for i := Low(TStationID) to High(TStationID) do
            Ini.WriteInteger('MODEL', 'LST INDEX ' + IntToStr(Ord(i) + 1), mMdlNoBySt[i]);

    finally
        Ini.Free;
    end;
end;

procedure TBaseModels.SaveModelList(AfName: string; const AModelList: TAryModels; ABegin, AEnd: integer);
var
    i, fh: integer;
    Buf: TModels;
begin
    if not FileExists(AfName) then
        fh := FileCreate(AfName)
    else
        fh := FileOpen(AfName, fmOpenReadWrite);
    if fh <= 0 then
        Exit;

    i := FileSeek(fh, 0, 2);
    if (i > 0) and ((i mod sizeof(TModels)) <> 0) then
    begin
        FileClose(fh);
        RenameFile(AfName, ChangeFileExt(AfName, '.' + FormatDateTime('yymmdd', Now)));
        gLog.ToFiles('Model File 크기이상 이름 변경함.', []);

        fh := FileCreate(AfName);
        if fh <= 0 then
            Exit;
    end;

    try
        for i := ABegin to AEnd do
        begin
            if Load(fh, i, Buf) then
                FileSeek(fh, -sizeof(TModels), 1)
            else
                FileSeek(fh, 0, 2);
            FileWrite(fh, AModelList[i], sizeof(TModels));
        end;
    finally
        FileClose(fh);
    end;
end;

procedure TBaseModels.LoadLastIndex;
var
    Ini: TIniFile;
    sTm: string;
    i: TStationID;
begin
    sTm := Format('%s\LstModelIndex.ini', [GetUsrDir(udENV, Now())]);
    Ini := TIniFile.Create(sTm);
    try
        for i := Low(TStationID) to High(TStationID) do
            mMdlNoBySt[i] := Ini.ReadInteger('MODEL', 'LST INDEX ' + IntToStr(Integer(i) + 1), 11);
    finally
        Ini.Free;
    end;
end;

function TBaseModels.SaveToIni(FileName: string): boolean;
var
    Ini: TIniFile;
    i: Integer;
begin
   { Ini := TIniFile.Create(FileName);
    try
        for i := 1 to _MAX_MODEL_COUNT - 1 do
        begin
            if mModels[i].rPartName <> '' then
            begin
                mModels[i].Write(Ini);
            end;
        end;
    finally
        Ini.Free;
    end;

    Result := true;   }
end;

function TBaseModels.LoadFromEnv(FileName: string; IsOverWrite: boolean; CondBits: BYTE): boolean;
var
    Ini: TIniFile;
    i: Integer;
    MdlNo: integer;
begin
   { Ini := TIniFile.Create(FileName);
    try
        for i := 1 to _MAX_MODEL_COUNT - 1 do
        begin
            MdlNo := Ini.ReadInteger(IntToStr(i - 1), 'CODE', 0);
            if (MdlNo > 0) then
            begin
                mModels[MdlNo].rIndex := MdlNo;
                mModels[MdlNo].ReadFromEnv(Ini, i - 1, IsOverWrite, CondBits);
            end;
        end;
        SaveModelList(Format('%s\models.dat', [GetUsrDir(udENV, Now())]), mModels,  1, _MAX_MODEL_COUNT);
    finally
        Ini.Free;
    end;

    Result := true; }
end;

function TBaseModels.LoadFromIni(FileName: string; IsOverWrite: boolean; CondBits: BYTE): boolean;
var
    Ini: TIniFile;
    i: Integer;
begin
  {  Ini := TIniFile.Create(FileName);
    try
        for i := 1 to _MAX_MODEL_COUNT - 1 do
        begin
            mModels[i].Read(Ini, i, IsOverWrite, CondBits);
        end;
        SaveModelList(Format('%s\models.dat', [GetUsrDir(udENV, Now())]), mModels,  1, _MAX_MODEL_COUNT);
    finally
        Ini.Free;
    end;

    Result := true;  }
end;

function TBaseModels.GetMotorCurrLimit(aMotor: TMotorORD; Index: integer): double;
begin
    Result := mModels[Index].rConstraints[aMotor].rLockedCurr;
end;

function TBaseModels.GetMotorTimeLimit(aMotor: TMotorORD; Index: integer): double;
begin
    Result := mModels[Index].rConstraints[aMotor].rMaxTime;
end;

function TBaseModels.GetUsrIndex(Station: TStationID): integer;
begin
    Result := mMdlNoBySt[Station];
end;

function TBaseModels.GetUsrIndex(Station: integer): integer;
begin
    Result := GetUsrIndex(TStationID(Station));
end;

//------------------------------------------------------------------------------
// TBaseData
//------------------------------------------------------------------------------
constructor TUserModels.Create;
begin
    inherited Create;
end;

destructor TUserModels.Destroy;
begin
    inherited Destroy;
end;

function TUserModels.CurrentModel(Station: TStationID): TModel;
begin
    Result := GetModel(GetUsrIndex(Station));
end;

function TUserModels.CurrentModels(Station: TStationID): TModels;
begin
    Result := GetModels(GetUsrIndex(Station));
end;

procedure TUserModels.CurrentOffset(Station: TStationID; var Offset: TOffset; var MtrOffset: TMotorOffset);
var
    Models: TModels;
begin
    Models := CurrentModels(Station);

    Offset := Models.rOffset[Ord(Station)];
    MtrOffset := Models.rMtrOffset[Ord(Station)];
end;

function TUserModels.CurrentPModels(Station: TStationID): PModels;
begin
    Result := GetPModels(GetUsrIndex(Station));
end;

end.

