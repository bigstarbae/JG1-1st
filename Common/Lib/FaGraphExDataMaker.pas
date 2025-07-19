{
    Ver.241107.00
}

unit FaGraphExDataMaker;

interface

uses
    FaGraphEx, TimeChecker, Generics.Collections;

type
    TFaGraphExDataMaker = class;

    TGrpDataInfo = class
    private
        mFilePath: string;
        mSeriesIdx: Integer;
        mSeriesCount: Integer;

        mOwner: TFaGraphExDataMaker;

        constructor Create(FilePath: string; SeriesIdx, SeriesCount: Integer);
    public
        function Load: Boolean;
    end;

    TGrpDataInfoList = TList<TGrpDataInfo>;

    TFaGraphExDataMaker = class
    private
        function GetDataInfos(Idx: Integer): TGrpDataInfo;
        function GetCurDataInfo: TGrpDataInfo;
    protected
        mDataInfoIdx: Integer;
        mCurDataInfo: TGrpDataInfo;
        mDataInfos: TGrpDataInfoList;

        mGrp: TFaGraphEx;

        mXInterval: Double;
        mValIdx: Integer;
        mTC: TAccTimeChecker;

        mSeriesIdx: Integer;

        mXAsSec: Boolean;

        function GetInterval: Double;

    public
        constructor Create(SeriesIdx: Integer);
        destructor Destroy; override;

        // ========================
        procedure Start;
        function MakeXY(var X, Y: double): Boolean;
        // ========================

        function First: Boolean;
        function Next: Boolean;
        function Add(FilePath: string; SeriesIdx, SeriesCount: Integer; IsLoad: Boolean): TGrpDataInfo;

        function Load(FilePath: string; ShareCount: Integer): Boolean;

        property XInterval: Double read mXInterval write mXInterval;
        property XAsSec: Boolean read mXAsSec write mXAsSec;

        property SeriesIdx: Integer read mSeriesIdx write mSeriesIdx;

        property DataInfos[Idx: Integer]: TGrpDataInfo read GetDataInfos;
        property CurDataInfo: TGrpDataInfo read GetCurDataInfo;
    end;

implementation

uses
    FAGraphExHelper, SysUtils, Classes, Dialogs, Log;

{ TFaGraphExDataMaker }

var
    gGrpDataInfo: TGrpDataInfo;

function TFaGraphExDataMaker.Add(FilePath: string; SeriesIdx, SeriesCount: Integer; IsLoad: Boolean): TGrpDataInfo;
begin
    Result := TGrpDataInfo.Create(FilePath, SeriesIdx, SeriesCount);
    Result.mOwner := Self;

    mDataInfos.Add(Result);

    if IsLoad then
        Result.Load;

end;

constructor TFaGraphExDataMaker.Create(SeriesIdx: Integer);
begin
    mGrp := TFaGraphEx.Create(nil);
    mSeriesIdx := SeriesIdx;

    mDataInfos := TGrpDataInfoList.Create;

    mXInterval := 0.2;
end;

destructor TFaGraphExDataMaker.Destroy;
var
    It: TGrpDataInfo;
begin

    for It in mDataInfos do
        It.Free;

    mDataInfos.Free;

    mGrp.Free;

    inherited;
end;

function TFaGraphExDataMaker.First: Boolean;
begin
    mDataInfoIdx := 0;
    mCurDataInfo := mDataInfos[mDataInfoIdx];
    Result := mCurDataInfo.Load;
end;

function TFaGraphExDataMaker.GetCurDataInfo: TGrpDataInfo;
begin
    if mDataInfos.Count = 0 then
        Exit(gGrpDataInfo);

    Result := mCurDataInfo;
end;

function TFaGraphExDataMaker.GetDataInfos(Idx: Integer): TGrpDataInfo;
begin
    try
        Result := mDataInfos[Idx]
    except
        on E: ERangeError do
            ShowMessage('GetDataInfos함수의 Idx인자가 범위를 벗어났습니다');
    end;
end;

function TFaGraphExDataMaker.GetInterval: Double;
begin
    if mXAsSec then
    begin
        if mValIdx < mGrp.Series.Items[mSeriesIdx].Count - 1 then
            Result := (mGrp.Series.Items[mSeriesIdx].XValue[mValIdx + 1] - mGrp.Series.Items[mSeriesIdx].XValue[mValIdx]) * 1000
        else
            Result := 1;
    end
    else
    begin
        Result := mXInterval;
    end;

end;

function TFaGraphExDataMaker.Load(FilePath: string; ShareCount: Integer): Boolean;
var
    FS: TFileStream;
    i: Integer;
begin
    Result := False;

    if not FileExists(FilePath) then
        Exit;

    FS := TFileStream.Create(FilePath, fmOpenRead);

    try
        mGrp.BeginUpdate();

        for i := 0 to ShareCount - 1 do
        begin
            with mGrp.Series.Add do
            begin
                ShareX := i * 2;
                ShareY := ShareX + 1;
            end;
        end;

        mGrp.Load(FS, ShareCount);
        mGrp.EndUpdate();
    finally
        FS.Free;
        Result := mGrp.Series.Items[0].Count > 0;
    end;

end;

function TFaGraphExDataMaker.MakeXY(var X, Y: double): Boolean;
begin
    Result := True;

    X := mGrp.Series.Items[mSeriesIdx].XValue[mValIdx];
    Y := mGrp.Series.Items[mSeriesIdx].YValue[mValIdx];

    if mTC.IsTimeOut then
    begin
        mTC.Start(GetInterval);
        Inc(mValIdx);
    end;

    if mValIdx >= mGrp.Series.Items[mSeriesIdx].Count  then
        Exit(False);


//    gLog.Debug('%f, %f', [X, Y]);
end;


function TFaGraphExDataMaker.Next: Boolean;
begin
    Result := False;

    Inc(mDataInfoIdx);

    if mDataInfoIdx < mDataInfos.Count then
    begin
        mCurDataInfo := mDataInfos[mDataInfoIdx];

        Result := mCurDataInfo.Load;
    end;

end;


procedure TFaGraphExDataMaker.Start;
begin
    mValIdx := 0;
    mTC.Start(GetInterval);
end;

{ TGrpDataInfo }

constructor TGrpDataInfo.Create(FilePath: string; SeriesIdx, SeriesCount: Integer);
begin
    mFilePath := FilePath;
    mSeriesIdx := SeriesIdx;
    mSeriesCount := SeriesCount;
end;

function TGrpDataInfo.Load: Boolean;
begin
    Result := mOwner.Load(mFilePath, mSeriesCount);
    mOwner.SeriesIdx := mSeriesIdx;
end;

initialization
    gGrpDataInfo := TGrpDataInfo.Create('', 0, 0);

finalization
    gGrpDataInfo.Free;

end.

