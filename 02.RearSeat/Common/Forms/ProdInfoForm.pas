unit ProdInfoForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, KiiMessages, Grids, ComCtrls, StdCtrls, Buttons, ExtCtrls,
  FaGraphEx, _GClass, AbCBitBt, Retrieveunit, RetrieveEx  ;

type
  TfrmProdInfo = class(TForm)
    pnl10: TPanel;
    Label1: TLabel;
    Panel2: TPanel;
    rdbtnTime: TRadioButton;
    rdbtnDay: TRadioButton;
    rdbtnMonth: TRadioButton;
    Label3: TLabel;
    pnlProcWork: TPanel;
    Panel6: TPanel;
    pnlDate: TPanel;
    cbxYear: TComboBox;
    cbxMonth: TComboBox;
    pnlTime: TPanel;
    dtpBeginTime: TDateTimePicker;
    pnl04: TPanel;
    Panel7: TPanel;
    sgrdRight: TStringGrid;
    Panel8: TPanel;
    sgrdLeft: TStringGrid;
    Label4: TLabel;
    labTotalCount: TLabel;
    fgProdInfo: TFaGraphEx;
    Splitter1: TSplitter;
    Dlgsave: TSaveDialog;
    Label2: TLabel;
    dtpEndTime: TDateTimePicker;
    pnlTitle: TPanel;
    Panel4: TPanel;
    sbtnToExcel: TSpeedButton;
    sbtnSearch: TSpeedButton;
    Panel5: TPanel;
    sbtnExit: TSpeedButton;
    labGoalCount: TLabel;
    sbtnSetTimes: TSpeedButton;
    labPeriod: TLabel;
    Label5: TLabel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure fgProdInfoAfterPaint(Sender: TObject);
    procedure fgProdInfoBeforePaint(Sender: TObject);
    procedure fgProdInfoDblClick(Sender: TObject);
    procedure rdbtnMonthClick(Sender: TObject);
    procedure sgrdLeftDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure cbxYearChange(Sender: TObject);
    procedure sbtnToExcelClick(Sender: TObject);
    procedure sbtnSearchClick(Sender: TObject);
    procedure sbtnExitClick(Sender: TObject);
    procedure sbtnSetTimesClick(Sender: TObject);
  private
    { Private declarations }
    mRetrieve : TRetrieve ;
    mFindTime : array[0..1]of TDateTime ;
    mGrpDatas : array[1..32, false..True]of integer ;
    mMinTime,
    mMaxTime  : array[0..24]of double ;

    mDayCount : array[1..12]of integer ;
    mDaystdTime : array[1..12]of integer ;

    procedure RetrieveExUpdates(Init: boolean) ;
    procedure OnUsrFileName(Sender: Tobject; const aTime:TDateTime; var aName: string) ;
    procedure OnUsrSearchDatas(Sender: Tobject; var Buf; var aPass:boolean;
        var aResult: boolean)  ;
    //procedure OnUsrSearchDatas(Sender: Tobject; const Buf; var aPass, aResult: boolean) ;
    procedure OnUsrListToExcelBefore(Sender: TObject; var AbPos: integer) ;
    procedure OnUsrListToExcelAfter(Sender: TObject; var AePos: integer) ;

    procedure DataToExcels ;
    procedure SearchDatas ;
    function  ListToExcel(AFile: string) : boolean ;

    procedure LoadGridWidths ;
    procedure SaveGridWidths ;
    procedure ReadMessage(var myMsg: TMessage); Message WM_SYS_CODE ;
    function  GetTypeAName(ATime: TDateTime): string;
    procedure ChangeAxis(AAxixItem: TFaAxisRuler; ALabelFormat: string;
      AMin, AMax, AStep: Double);
    procedure Initial ;
    function GetSumOfTime: string;
  public
    { Public declarations }
    procedure SetFrm(StartTime, EndTime: TDateTime) ;
  end;

var
  frmProdInfo: TfrmProdInfo;

implementation
uses
    Math, DataUnit, myUtils, Log, ToExcelUnit, BIFFRecsII4, CellFormats4, DataBox,
    IniFiles, GraphConfigForm , DateUtils, ProdTimesForm, SysEnv , LangTran;

const
    _NO     = 0 ;
    _TIME   = 1 ;
    _COUNT  = 2 ;
    _OK     = 3 ;
    _NG     = 4 ;
    _START  = 5 ;
    _END    = 6 ;
    _ATIME  = 7 ;

{$R *.dfm}
//------------------------------------------------------------------------------
procedure SaveGridColWidths(AGrid:TStringGrid; AName:string) ;
var
    i   : integer ;
    sTm : string ;
begin
    sTm := Format('%s\GridWidths.env', [GetUsrDir(udENV, Now, false)]) ;
    with TIniFile.Create(sTm) do
    begin
        try
            for i := 0 to AGrid.ColCount-1 do
            begin
                WriteInteger(AName,'COL_'+IntToStr(i), AGrid.ColWidths[i]) ;
            end ;
        finally
            Free ;
        end ;
    end ;
end ;

procedure LoadGridColwidths(AGrid:TStringGrid; AName:string) ;
var
    i   : integer ;
    sTm : string ;
begin
    sTm := Format('%s\GridWidths.env', [GetUsrDir(udENV, Now, false)]) ;
    if not FileExists(sTm) then Exit ;
    with TIniFile.Create(sTm) do
    begin
        try
            for i := 0 to AGrid.ColCount-1 do
            begin
                AGrid.ColWidths[i] := ReadInteger(AName,'COL_'+IntToStr(i), 100) ;
            end ;
        finally
            Free ;
        end ;
    end ;
end ;

function  GetTimeToMin(aTime: TDateTime): double ;
var
    hh,
    nn,
    ss,
    zz : WORD ;
begin
    Result := aTime ;

    DecodeTime(Result, hh, nn, ss, zz) ;
    Result := hh * 60 ;
    Result := Result + nn ;
    if ss > 0 then
    begin
        nn := Length(IntToStr(ss)) ;
        Result := Result + ss / Power(10, nn)  ;
    end
    else Result := Result ;
end ;

function  GetDateToMin(aTime: TDateTime): double ;
begin
    Result := aTime ;
    Result := Trunc(Result) * MinsPerDay ;
end ;

function  GetMinutes(aTime: TDateTime): double ;
begin
    Result := aTime ;
    if Result <= 0 then
    begin
        Result := 0 ;
        Exit ;
    end
    else
    if (Result > 0)
        and (Result < 1) then
    begin
        Result := GetTimeToMin(aTime) ;
    end
    else
    begin
        Result := GetTimeToMin(aTime)
                  + GetDateToMin(aTime) ;
    end ;
end ;

function GetTimeToHour(ATime: TDateTime): double ;
var
    hh,
    nn,
    ss,
    zz : WORD ;
begin
    Result := aTime ;

    DecodeTime(Result, hh, nn, ss, zz) ;
    Result := hh ;
    if nn > 0 then
    begin
        ss := Length(IntToStr(nn)) ;
        Result := Result + nn / Power(10, ss)  ;
    end
    else Result := Result ;
end ;

function GetDateToHour(ATime: TDateTime): double ;
begin
    Result := aTime ;
    Result := Trunc(Result) * HoursPerDay ;
end ;

function GetHours(ATime: TDateTime): double ;
begin
    Result := ATime ;
    if Result <= 0 then
    begin
        Result := 0 ;
        Exit ;
    end
    else
    if (Result > 0)
        and (Result < 1) then
    begin
        Result := GetTimeToHour(ATime) ;
    end
    else
    begin
        Result := GetTimeToHour(ATime)
                  + GetDateToHour(ATime) ;
    end ;
end ;

function GetUsrTimeToTxt(ATime: double): string ;
var
    Hour, Min, sec, mms : WORD ;
begin
    Result := '' ;
    // 일 시 분 초로 표시해야 함
    DecodeTime(ATime, Hour, Min, Sec, mms) ;
    if Trunc(ATime) > 0 then Result := IntToStr(Trunc(ATime))+_TR('(일)') ;
    if Hour > 0 then Result := Result + IntToStr(Hour)+_TR('(시)') ;
    Result := Format(_TR('%s%d.%d(분)'), [Result, Min, sec]) ;
end ;

function GetTakeTime(ATime: double; IsHour:boolean): string ;
begin
    Result := GetUsrTimeToTxt(ATime) ;
    Exit ;
    if Trunc(ATime) > 0 then Result := IntToStr(Trunc(ATime))+_TR('(일) ') ;
    if IsHour then Result := Result + FloatToStr(GetHours(Frac(ATIme)))+_TR('(시)')
    else Result := Result + FloatToStr(GetMinutes(Frac(ATime)))+_TR('(분)') ;

end ;
//------------------------------------------------------------------------------
 { TfrmProdInfo }
//------------------------------------------------------------------------------
procedure TfrmProdInfo.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
    Action := caFree ;
end;

procedure TfrmProdInfo.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
    SaveGridColWidths(sgrdLeft, '_PROC_INFO_LEFT') ;
    SaveGridColWidths(sgrdRight, '_PROC_INFO_RIGHT') ;
    SaveGridWidths ;
end;

procedure TfrmProdInfo.FormCreate(Sender: TObject);
var
    i : integer ;
begin
    with sgrdLeft do
    begin
        ColCount := 8 ;
        RowCount := 13 ;

        Cells[0,0] := 'NO' ;
        Cells[1,0] := _TR('생산시간') ;
        Cells[2,0] := _TR('생산량') ;
        Cells[3,0] := 'OK' ;
        Cells[4,0] := 'NG' ;
        Cells[5,0] := _TR('시작') ;
        Cells[6,0] := '끝' ;
        Cells[7,0] := _TR('소요시간');
        for i := 1 to RowCount-1 do Rows[i].Clear ;
    end ;
    with sgrdRight do
    begin
        ColCount := 8 ;
        RowCount := 13 ;

        Cells[0,0] := 'NO' ;
        Cells[1,0] := _TR('생산시간') ;
        Cells[2,0] := _TR('생산량') ;
        Cells[3,0] := 'OK' ;
        Cells[4,0] := 'NG' ;
        Cells[5,0] := _TR('시작') ;
        Cells[6,0] := '끝' ;
        Cells[7,0] := _TR('소요시간');
        for i := 1 to RowCount-1 do Rows[i].Clear ;
    end ;

    gProdEx   := TProdTimesEx.Create ;
    mRetrieve := TRetrieve.Create(nil,
                                  nil,
                                  TDataBox.Create(),
                                  nil,
                                  _PROJECT_NAME,
                                  9,
                                  sizeof(TResult),
                                  0) ;
    with mRetrieve do
    begin
        SetGridORD(DataGridORD);
        OnGetFileName := OnUsrFileName ;
        OnSearchDatas := OnUsrSearchDatas ;
    end ;

    fgProdInfo.Tag := ord(faProcInfo_Time) ;

    LoadGridColWidths(sgrdLeft, '_PROC_INFO_LEFT') ;
    LoadGridColWidths(sgrdRight, '_PROC_INFO_RIGHT') ;
    LoadGridWidths ;

    dtpBeginTime.DateTime := Trunc(GetOneDayTime(Now()))+Frac(gProdEx.ProdTime.WorkTime) ;
    dtpEndTime.DateTime := Trunc(GetOneDayTime(Now())+1)+Frac(gProdEx.ProdTime.WorkTime) ;
end;

procedure TfrmProdInfo.FormDestroy(Sender: TObject);
begin
    FreeAndNil(mRetrieve) ;
    FreeAndNil(gProdEx) ;
    frmProdInfo := nil ;
end;

procedure TfrmProdInfo.FormShow(Sender: TObject);
begin
    pnlTitle.Caption := _PROJECT_NAME + _TR(' 생산정보') ;
    Initial ;

    sbtnSearch.Click ;
	ChangeCaption(self);
end;

procedure TfrmProdInfo.ReadMessage(var myMsg: TMessage);
begin
//
end;

procedure TfrmProdInfo.fgProdInfoAfterPaint(Sender: TObject);
var
    ACanvas : TCanvas ;
    xPos1, yPos1, xPos2, yPos2, i, target: Integer;
    bColor, pColor : TColor ;
    grpEnv : TFaGraphEnv ;
begin
    with  TFaGraphEx(Sender) do
    begin
        grpEnv := GetGrpEnv(Tag) ;

        target := StrToIntDef(labGoalCount.Caption, 0) ;
        GetCanvas(ACanvas) ;

        bColor := ACanvas.Brush.Color ;
        pColor := ACanvas.Pen.Color ;

        ACanvas.Pen.Width := 2 ;
        ACanvas.Pen.Color := clRed;
        ACanvas.Brush.Color := clRed;

        GetX(0, Axis.Items[0].Min , xPos1);
        GetY(0, target, yPos1);
        GetX(0, Axis.Items[0].Max , xPos2);
        GetY(0, target, yPos2);

        ACanvas.MoveTo(xPos1, yPos1);
        ACanvas.LineTo(xPos2, yPos2);

        target := sgrdLeft.RowCount + sgrdRight.RowCount -2 ;
        if mRetrieve = nil then exit ;
        for i := 0 to target - 1 do
        begin
            if (mGrpDatas[i+1, false]+mGrpDatas[i+1, true]) <= 0 then Continue ;
            
            GetX(0, Axis.Items[0].Min + (Axis.Items[0].Step * (i + 1)) - (Axis.Items[0].Step * 0.25)  , xPos1);
            GetY(0, Axis.Items[1].Min, yPos1);
            GetX(0, Axis.Items[0].Min + (Axis.Items[0].Step * (i + 1)) + (Axis.Items[0].Step * 0.25) , xPos2);
            GetY(0, mGrpDatas[i+1, true], yPos2);
            ACanvas.Pen.Width := 2 ;
            ACanvas.Pen.Color := grpEnv.rDataLine[0] ;
            ACanvas.Brush.Color := grpEnv.rDataLine[0] ;
            ACanvas.Rectangle(xPos1, yPos1, xPos2, yPos2);       //x나 y}

            ACanvas.Pen.Color := grpEnv.rDataLine[1] ;
            ACanvas.Brush.Color := grpEnv.rDataLine[1] ;
            GetY(0, Axis.Items[1].Min + mGrpDatas[i+1, true], yPos1);
            GetY(0, Axis.Items[1].Min + mGrpDatas[i+1, true]+mGrpDatas[i+1, false], yPos2);
            ACanvas.Rectangle(xPos1, yPos1, xPos2, yPos2);       //x나 y}
        end ;
        ACanvas.Brush.Color := bColor ;
        ACanvas.Pen.Color   := pColor ;
    end;
end;

procedure TfrmProdInfo.fgProdInfoBeforePaint(Sender: TObject);
begin
//
end;

procedure TfrmProdInfo.fgProdInfoDblClick(Sender: TObject);
var
    nE : TFaGraphEnv ;
begin
    with Sender as TFaGraphEx do frmgrpConfig.SetFrm(Tag);
    frmgrpConfig.ShowModal ;

    nE := GetGrpEnv(fgProdInfo.Tag) ;
    with fgProdInfo do
    begin
        BeginUpdate ;
        with Axis.Items[1] do
        begin
            Min  := nE.rYMin ;
            Max  := nE.rYMax ;
            Step := nE.rYStep ;
        end ;
        EndUpdate ;
    end ;
end;

procedure TfrmProdInfo.DataToExcels;
var
    sTm,shFile : string ;
begin
    //선택된것만 할건지 물어보자.
    Screen.Cursor := crHourGlass ;
	shFile := '' ;
    sbtnSearch.Enabled  := false ;
    sbtnToExcel.Enabled := false ;

    with DlgSave do
    begin
        InitialDir := GetHomeDirectory ;
        Options := Options + [ofOverWritePrompt] ;
        Filter     := 'xls File(*.xls)|*.xls' ;

        if rdbtnTime.Checked then
            FileName := _TR('생산정보(시간대별)')+FormatDateTime('ddhhnn',Now)+'.xls'
        else
        if rdbtnDay.Checked then
            FileName := _TR('생산정보(일별)')+FormatDateTime('ddhhnn',Now)+'.xls'
        else
            FileName := _TR('생산정보(월별)')+FormatDateTime('ddhhnn',Now)+'.xls' ;

        if Execute then
        begin
            if Uppercase(ExtractFileExt(FileName)) <> '.XLS' then
            begin
                FileName := ChangeFileExt(FileName, '.xls') ;
            end ;
            //----------
            if FileExists(FileName)
                and not DeleteFile(FileName) then
            begin
                with Application do
                    MessageBox(_TR('지정된 파일이 사용중입니다, 파일을 닫은 후 다시 작업하세요!'),
                               _TR('엑셀 포맷 변환.'),
                               MB_ICONERROR+MB_OK) ;

                sbtnSearch.Enabled  := true ;
                sbtnToExcel.Enabled := true ;
                Screen.Cursor := crDefault ;
                Exit ;
            end ;
            //----------
            if ListToExcel(FileName) then
            begin
                shFile := FileName ;
                sTm := Format(_TR('%s xls 포맷으로 저장되었습니다.'), [FileName]) ;
                with Application do
                    MessageBox(PChar(sTm), _TR('엑셀 포맷 변환.'), MB_ICONINFORMATION+MB_OK) ;
            end
            else
            begin
                sTm := Format(_TR('%s 엑셀 포맷 변환. 확인 후 다시 시도하세요.'), [FileName]) ;
                with Application do
                    MessageBox(PChar(sTm), _TR('엑셀 포맷 변환.'), MB_ICONERROR+MB_OK) ;
            end ;
        end ;
    end ;
    sbtnSearch.Enabled  := true ;
    sbtnToExcel.Enabled := true ;
    Screen.Cursor := crDefault ;
end;

procedure TfrmProdInfo.LoadGridWidths;
var
    sTm : string ;
    Ini : TIniFile ;
begin
    sTm := Format('%s\GridWidths.env',[GetUsrDir(udENV,Now,true)]) ;
    Ini := TIniFile.Create(sTm);
    try
        sgrdLeft.Width := Ini.ReadInteger('GRID WIDTH','PROD INFO LEFT',638) ;
    finally
        Ini.Free ;
    end ;
end;

procedure TfrmProdInfo.OnUsrFileName(Sender: Tobject;
  const aTime: TDateTime; var aName: string);
begin
    AName := GetResultFileName(ATime, false) ;
end;

function TfrmProdInfo.GetSumOfTime : string ;
var
    i : integer ;
    sum : double ;
begin
    if not rdbtnMonth.Checked then
    begin
        sum := 0 ;
        for i := 0 to 24 do
        begin
            sum := sum + (mMaxTime[i]-mMinTime[i]) ;
        end ;
        Result := GetTakeTime(sum, rdbtnDay.Checked) ;
    end
    else
    begin
        sum := 0 ;
        for i := 1 to 12 do sum := sum + mDayCount[i] ;
        Result := IntToStr(Trunc(sum))+'일';
    end ;
end ;

procedure TfrmProdInfo.OnUsrListToExcelAfter(Sender: TObject;
  var AePos: integer);
begin
    with Sender as TToExcel do
    begin
        Font.Name := Self.Font.Name ;

        Font.Size  := 10 ;
        Font.Style := [] ;

        BoardStyle.rColor := xcBlack ;
        BoardStyle.rStyle := cbsThin ;

        CellStyle.rColor  := xcWhite ;
        CellStyle.rAlignment := chaCenter ;
        CellStyle.rLayOut    := cvaCenter ;

        SetMergeData(0, AePos, 1, AePos, _TR('합계')) ;
        Box(0, AePos, 1, AePos) ;

        CellStyle.rAlignment := chaRight ;
        SetData(2, AePos, StrToIntDef(labTotalCount.Caption,0)) ;
        Box(2, AePos, 2, AePos) ;

        CellStyle.rAlignment := chaRight ;
        SetMergeData(3, AePos, 5, AePos, GetSumOfTime) ;
        Box(3, AePos, 5, AePos) ;

        CellStyle.rAlignment := chaLeft ;
        SetData(0, AePos+1, _TR('조건: ')+labPeriod.Caption) ;
    end ;
end;

procedure TfrmProdInfo.OnUsrListToExcelBefore(Sender: TObject;
  var AbPos: integer);
var
    i : integer ;
begin
    AbPos := 3 ;
    with Sender as TToExcel do
    begin
        Font.Name := Self.Font.Name ;

        Font.Size  := 14 ;
        Font.Color := clBlack ;
        Font.Style := [fsBold] ;

        BoardStyle.rColor := xcBlack ;
        BoardStyle.rStyle := cbsThin ;
        CellStyle.rColor  := xcWhite ;
        CellStyle.rAlignment := chaCenter ;
        CellStyle.rLayOut    := cvaCenter ;
        //Title
        SetMergeData(0, 0, sgrdLeft.ColCount-1, 1, pnlProcWork.Caption);
        Box(0, 0, sgrdLeft.ColCount-1, 1) ;

        Font.Size  := 10 ;
        Font.Style := [] ;

        for i := 0 to sgrdLeft.ColCount-1 do
        begin
            SetData(i, 2, sgrdLeft.Cells[i, 0]);
            Box(i, 2, i, 2) ;
        end ;
    end ;
end;

function TfrmProdInfo.GetTypeAName(ATime: TDateTime): string ;
var
    i, iDx : integer ;
    nB, nE : double ;
begin
    Result := '' ;
    if rdbtnTime.Checked then
    begin
        for i := 1 to 24 do
        begin
            nB := Trunc(ATime) + Frac(gProdEx.ProdTime.GetStartTime(i)) ;
            nE := Trunc(ATime) + Frac(gProdEx.ProdTime.GetEndTime(i)) ;
            if nB > nE then nE := nE + 1 ;
            if (nB <= ATime) and (nE >= ATime) then
            begin
                Result := IntToStr(i)+'TIME' ;
                Break ;
            end ;
        end ;
    end
    else
    if rdbtnDay.Checked then
    begin
        nB := mFindTime[0] ;
        nE := nB + 1 ;

        iDx := DaysInAMonth(YearOf(nB), MonthOf(nB)) ;
        for i := 1 to iDx do
        begin
            if (nB <= ATime) and (nE >= ATime) then
            begin
                Result := IntToStr(i)+'DAY' ;
                Break ;
            end ;
            nB := nE ;
            nE := nB + 1 ;
        end ;
    end
    else
    if rdbtnMonth.Checked then
    begin
        for i := 1 to 12 do
        begin
            nB := EncodeDate(YearOf(mFindTime[0]), i, 1) ;
            nB := Trunc(nB) + Frac(gProdEx.ProdTime.WorkTime) ;

            nE := EncodeDate(YearOf(mFindTime[0]), i, DaysInAMonth(YearOf(nB), i)) ;
            nE := Trunc(nE) + Frac(gProdEx.ProdTime.WorkTime) ;
            nE := nE + 1 ; //작업시간 기준으로 하면 다음날 아침까지

            if (nB <= ATime) and (nE >= ATime) then
            begin
                Result := IntToStr(i)+'MONTH' ;
                Break ;
            end ;
        end ;
    end ;
end ;

procedure TfrmProdInfo.OnUsrSearchDatas(Sender: Tobject; var Buf;
    var aPass:boolean; var aResult: boolean) ;
var
    nRs : TResult ;
    iDx : integer ;
begin
    Move(Buf, nRs, sizeof(TResult)) ;
    with Sender as TRetrieve do
    begin
        APass := true ;
        if (mFindTime[0] > nRs.rLastTime)
            or (mFindTime[1] < nRs.rLastTime) then Exit ;

        if nRs.rValidity[tsResult] then AResult := true
        else                            AResult := false ;
        APass   := false ;

        iDx := AddData(GetTypeAName( nRs.rLastTime ), AResult) ;

        if (mMinTime[iDx] = 0) and (mMaxTime[iDx] = 0) then
        begin
            mMinTime[iDx] := nRs.rLastTime ;
            mMaxTime[iDx] := nRs.rLastTime ;
        end
        else
        if mMinTime[iDx] > nRs.rLastTime then
        begin
            mMinTime[iDx] := nRs.rLastTime ;
        end
        else
        if mMaxTime[iDx] < nRs.rLastTime then
        begin
            mMaxTime[iDx] := nRs.rLastTime ;
        end ;

        if not rdbtnMonth.Checked then Exit ;

        iDx := MonthOf(nRs.rLastTime) ;
        if mDaystdTime[iDx] <> Trunc(nRs.rLastTime) then
        begin
            mDaystdTime[iDx] := Trunc(nRs.rLastTime) ;
            Inc(mDayCount[iDx]) ;
        end ;
    end ;
end;

procedure TfrmProdInfo.RetrieveExUpdates(Init: boolean);
var
    i, nT, iTm, iDx : integer ;
    nB, nE : TDateTime;
    nGrpEnv : TFaGraphEnv ;
begin
    nT := 0 ;
    labTotalCount.Caption := '' ;
    FillChar(mGrpDatas, sizeof(mGrpDatas), 0);

    if Init then
    begin
        mRetrieve.Initial ;
        sbtnToExcel.Enabled := false ;
    end ;

    with sgrdLeft do
    begin
        for i := 1 to RowCount-1 do Rows[i].Clear ;
    end ;
    with sgrdRight do
    begin
        for i := 1 to RowCount-1 do Rows[i].Clear ;
    end ;

    if rdbtnTime.Checked then
    begin
        pnlProcWork.Caption := _TR('[시간대별 생산 리스트]') ;
        Panel7.Caption      := _TR('[시간대별 생산 그래프]') ;

        fgProdInfo.Tag := ord(faProcInfo_Time) ;
        pnl04.Height := 374 ;

        ChangeAxis( fgProdInfo.Axis.Items[0],
                    'd',
                    EncodeDate(YearOf(Now), 1, 1),
                    EncodeDate(YearOf(Now), 1, 24),
                    1) ;
        pnlDate.Visible := false ;
        pnlTime.Visible := true ;

        labGoalCount.Caption := IntToStr(gsysEnv.rProdOfATimeCount) ;
        //nB := gProdEx.WorkTime ;
        with sgrdLeft do
        begin
            Cells[_ATIME,0] := _TR('소요시간');

            RowCount := 13 ;
            for i := 1 to 12 do
            begin
                nB := gProdEx.ProdTime.GetStartTime(i) ;
                nE := gProdEx.ProdTime.GetEndTime(i) ;

                Rows[i].Clear ;
                Cells[_NO, i] := IntToStr(i) ;
                Cells[_TIME, i] := FormatDateTime('hh:nn:ss ~ ', nB)
                               + FormatDateTime('hh:nn:ss',    nE) ;
                if not Init then
                begin
                    mGrpDatas[i,true] := mRetrieve.GetCount(IntToStr(i)+'TIME',true) ;
                    mGrpDatas[i,false]:= mRetrieve.GetCount(IntToStr(i)+'TIME',false) ;
                    Cells[_COUNT, i]  := IntToStr(mGrpDatas[i,false] + mGrpDatas[i,true]) ;
                    Cells[_OK, i]     := IntToStr(mGrpDatas[i,true]) ;
                    Cells[_NG, i]     := IntToStr(mGrpDatas[i,false]) ;
                    nT := nT + mGrpDatas[i,false] + mGrpDatas[i,true] ;

                    iDx := mRetrieve.GetIndex(IntToStr(i)+'TIME') ;
                    if iDx >= 0 then
                    begin
                        Cells[_START, i] := FormatDateTime('hh:nn:ss', mMinTime[iDx]) ;
                        Cells[_END, i]   := FormatDateTime('hh:nn:ss', mMaxTime[iDx]) ;
                        Cells[_ATIME, i] := GetTakeTime(mMaxTime[iDx]-mMinTime[iDx],false) ;
                    end ;
                end ;
            end ;
        end ;
        with sgrdRight do
        begin
            Cells[_ATIME,0] := _TR('소요시간');

            RowCount := 13 ;
            for i := 13 to 24 do
            begin
                nB := gProdEx.ProdTime.GetStartTime(i) ;
                nE := gProdEx.ProdTime.GetEndTime(i) ;

                Rows[i].Clear ;
                Cells[_NO, i-12] := IntToStr(i) ;
                Cells[_TIME, i-12] := FormatDateTime('hh:nn:ss ~ ', nB)
                                  + FormatDateTime('hh:nn:ss',    nE) ;
                if not Init then
                begin
                    mGrpDatas[i,true]   := mRetrieve.GetCount(IntToStr(i)+'TIME',true) ;
                    mGrpDatas[i,false]  := mRetrieve.GetCount(IntToStr(i)+'TIME',false) ;
                    Cells[_COUNT, i-12] := IntToStr(mGrpDatas[i,true]+mGrpDatas[i,false]) ;
                    Cells[_OK, i-12]    := IntToStr(mGrpDatas[i,true]) ;
                    Cells[_NG, i-12]    := IntToStr(mGrpDatas[i,false]) ;
                    nT := nT + mGrpDatas[i,true]+mGrpDatas[i,false] ;

                    iDx := mRetrieve.GetIndex(IntToStr(i)+'TIME') ;
                    if iDx >= 0 then
                    begin
                        Cells[_START, i-12] := FormatDateTime('hh:nn:ss', mMinTime[iDx]) ;
                        Cells[_END, i-12]   := FormatDateTime('hh:nn:ss', mMaxTime[iDx]) ;
                        Cells[_ATIME, i-12] := GetTakeTime(mMaxTime[iDx]-mMinTime[iDx],false) ;
                    end ;
                end ;
                //nB := IncMinute(nB, 60) ;
            end ;
        end ;
    end
    else
    if rdbtnDay.Checked then
    begin
        pnlProcWork.Caption := _TR('[일별 생산 리스트]') ;
        Panel7.Caption      := _TR('[일별 생산 그래프]') ;

        fgProdInfo.Tag := ord(faProcInfo_Day) ;
        pnl04.Height := 477 ;

        pnlTime.Visible := false ;
        pnlDate.Visible := true ;

        cbxYear.Visible  := true ;
        cbxMonth.Visible := true ;

        labGoalCount.Caption := IntToStr(gsysEnv.rProdOfADayCount) ;
        iTm := DaysInAMonth(CurrentYear-cbxYear.ItemIndex,
                            cbxMonth.ItemIndex+1) ;

        ChangeAxis( fgProdInfo.Axis.Items[0],
                    'dd',
                    EncodeDate(CurrentYear-cbxYear.ItemIndex,
                               cbxMonth.ItemIndex+1,
                               1),
                    EncodeDate(CurrentYear-cbxYear.ItemIndex,
                               cbxMonth.ItemIndex+1,
                               iTm),
                    1);

        with sgrdLeft do
        begin
            Cells[_ATIME,0] := _TR('소요시간');

            RowCount := iTm div 2 + 1 ;
            for i := 1 to RowCount-1 do
            begin
                Rows[i].Clear ;
                Cells[_NO, i] := IntToStr(i) ;
                Cells[_TIME, i] := Format(_TR('%d년 %d월 %d일'),
                                    [CurrentYear-cbxYear.ItemIndex,
                                     cbxMonth.ItemIndex+1,
                                     i]) ;
                if not Init then
                begin
                    mGrpDatas[i,true]  := mRetrieve.GetCount(IntToStr(i)+'DAY',true) ;
                    mGrpDatas[i,false] := mRetrieve.GetCount(IntToStr(i)+'DAY',false) ;
                    Cells[_COUNT, i]   := IntToStr(mGrpDatas[i,true]+mGrpDatas[i,false]) ;
                    Cells[_OK, i]      := IntToStr(mGrpDatas[i,true]) ;
                    Cells[_NG, i]      := IntToStr(mGrpDatas[i,false]) ;
                    nT := nT + mGrpDatas[i,true]+mGrpDatas[i,false] ;

                    iDx := mRetrieve.GetIndex(IntToStr(i)+'DAY') ;
                    if iDx >= 0 then
                    begin
                        Cells[_START, i] := FormatDateTime('hh:nn:ss', mMinTime[iDx]) ;
                        Cells[_END, i]   := FormatDateTime('hh:nn:ss', mMaxTime[iDx]) ;
                        Cells[_ATIME, i] := GetTakeTime(mMaxTime[iDx]-mMinTime[iDx],true) ;
                    end ;
                end ;
            end ;
        end ;
        with sgrdRight do
        begin
            Cells[_ATIME,0] := _TR('소요시간');

            RowCount := (iTm - (sgrdLeft.RowCount-1)) + 1 ;
            iTm := sgrdLeft.RowCount ;
            for i := 1 to RowCount-1 do
            begin
                Rows[i].Clear ;
                Cells[_NO, i] := IntToStr(iTm) ;
                Cells[_TIME, i] := Format(_TR('%d년 %d월 %d일'),
                                    [CurrentYear-cbxYear.ItemIndex,
                                     cbxMonth.ItemIndex+1,
                                     iTm]) ;
                if not Init then
                begin
                    mGrpDatas[iTm,true]  := mRetrieve.GetCount(IntToStr(iTm)+'DAY',true) ;
                    mGrpDatas[iTm,false] := mRetrieve.GetCount(IntToStr(iTm)+'DAY',false) ;
                    Cells[_COUNT, i]     := IntToStr(mGrpDatas[iTm,true]+mGrpDatas[iTm,false]) ;
                    Cells[_OK, i]        := IntToStr(mGrpDatas[iTm,true]) ;
                    Cells[_NG, i]        := IntToStr(mGrpDatas[iTm,false]) ;
                    nT := nT + mGrpDatas[iTm,true]+mGrpDatas[iTm,false] ;

                    iDx := mRetrieve.GetIndex(IntToStr(iTm)+'DAY') ;
                    if iDx >= 0 then
                    begin
                        Cells[_START, i] := FormatDateTime('hh:nn:ss', mMinTime[iDx]) ;
                        Cells[_END, i]   := FormatDateTime('hh:nn:ss', mMaxTime[iDx]) ;
                        Cells[_ATIME, i] := GetTakeTime(mMaxTime[iDx]-mMinTime[iDx],true) ;
                    end ;
                end ;
                Inc(iTm) ;
            end ;
        end ;
    end
    else
    if rdbtnMonth.Checked then
    begin
        pnlProcWork.Caption := _TR('[월별 생산 리스트]') ;
        Panel7.Caption      := _TR('[월별 생산 그래프]') ;

        fgProdInfo.Tag := ord(faProcInfo_Month) ;
        pnl04.Height := 227 ;

        ChangeAxis( fgProdInfo.Axis.Items[0],
                    'yyyy-mm',
                    EncodeDate(CurrentYear-cbxYear.ItemIndex,
                               1,
                               1),
                    EncodeDate(CurrentYear-cbxYear.ItemIndex,
                               12,
                               31)-20,
                    31);

        pnlTime.Visible := false ;
        pnlDate.Visible := true ;

        cbxMonth.Visible := false ;
        //dtpTime.Visible  := false ;
        cbxYear.Visible  := true ;

        labGoalCount.Caption := IntToStr(gsysEnv.rProdOfAMonthCount) ;
        iTm := 1 ;
        with sgrdLeft do
        begin
            Cells[_ATIME,0] := _TR('작업일수');

            RowCount := 7 ;
            for i := 1 to RowCount-1 do
            begin
                Rows[i].Clear ;
                Cells[_NO, i] := IntToStr(iTm) ;
                Cells[_TIME, i] := Format(_TR('%d년 %d월'),
                                    [CurrentYear-cbxYear.ItemIndex, iTm]) ;
                if not Init then
                begin
                    mGrpDatas[iTm,true]  := mRetrieve.GetCount(IntToStr(iTm)+'MONTH',true) ;
                    mGrpDatas[iTm,false] := mRetrieve.GetCount(IntToStr(iTm)+'MONTH',false) ;
                    Cells[_COUNT, i] := IntToStr(mGrpDatas[iTm,true]+mGrpDatas[iTm,false]) ;
                    Cells[_OK, i]    := IntToStr(mGrpDatas[iTm,true]) ;
                    Cells[_NG, i]    := IntToStr(mGrpDatas[iTm,false]) ;
                    nT := nT + mGrpDatas[iTm,true]+mGrpDatas[iTm,false] ;

                    iDx := mRetrieve.GetIndex(IntToStr(iTm)+'MONTH') ;
                    if iDx >= 0 then
                    begin
                        Cells[_START, i] := FormatDateTime('yyyy-mm-dd', mMinTime[iDx]) ;
                        Cells[_END, i]   := FormatDateTime('yyyy-mm-dd', mMaxTime[iDx]) ;
                        Cells[_ATIME, i] := IntToStr(mDayCount[iTm])+'일';
                    end ;
                end ;
                Inc(iTm) ;
            end ;
        end ;
        with sgrdRight do
        begin
            Cells[_ATIME,0] := _TR('작업일수');

            RowCount := 7 ;
            for i := 1 to RowCount-1 do
            begin
                Rows[i].Clear ;
                Cells[_NO, i] := IntToStr(iTm) ;
                Cells[_TIME, i] := Format(_TR('%d년 %d월'),
                                    [CurrentYear-cbxYear.ItemIndex, iTm]) ;
                if not Init then
                begin
                    mGrpDatas[iTm,true]  := mRetrieve.GetCount(IntToStr(iTm)+'MONTH',true) ;
                    mGrpDatas[iTm,false] := mRetrieve.GetCount(IntToStr(iTm)+'MONTH',false) ;
                    Cells[_COUNT, i]     := IntToStr(mGrpDatas[iTm,true]+mGrpDatas[iTm,false]) ;
                    Cells[_OK, i]        := IntToStr(mGrpDatas[iTm,true]) ;
                    Cells[_NG, i]        := IntToStr(mGrpDatas[iTm,false]) ;
                    nT := nT + mGrpDatas[iTm,true]+mGrpDatas[iTm,false] ;

                    iDx := mRetrieve.GetIndex(IntToStr(iTm)+'MONTH') ;
                    if iDx >= 0 then
                    begin
                        Cells[_START, i] := FormatDateTime('yyyy-mm-dd', mMinTime[iDx]) ;
                        Cells[_END, i]   := FormatDateTime('yyyy-mm-dd', mMaxTime[iDx]) ;
                        Cells[_ATIME, i] := IntToStr(mDayCount[iTm])+'일';
                    end ;
                end ;
                Inc(iTm) ;
            end ;
        end ;
    end ;
    nGrpEnv := GetGrpEnv(fgProdInfo.Tag) ;
    with fgProdInfo do
    begin
        BeginUpdate ;
        with Axis.Items[1] do
        begin
            Min  := nGrpEnv.rYMin ;
            Max  := nGrpEnv.rYMax ;
            Step := nGrpEnv.rYStep ;
        end ;
        EndUpdate ;
    end ;
    labTotalCount.Caption := IntToStr(nT) ;
end;

procedure TfrmProdInfo.SaveGridWidths;
var
    sTm : string ;
    Ini : TIniFile ;
begin
    sTm := Format('%s\GridWidths.env',[GetUsrDir(udENV,Now,true)]) ;
    Ini := TIniFile.Create(sTm);
    try
        Ini.WriteInteger('GRID WIDTH','PROD INFO LEFT',sgrdLeft.Width) ;
    finally
        Ini.Free ;
    end ;
end;

procedure TfrmProdInfo.SearchDatas ;
var
    iTm : integer ;
    yy,mm,dd : WORD ;
begin
    if rdbtnTime.Checked then
    begin
        mFindTime[0] := Trunc(dtpBeginTime.Date)+Frac(gProdEx.ProdTime.WorkTime) ;
        mFindTime[1] := mFindTime[0] + 1 ;//Trunc(dtpEndTime.Date)+Frac(IncSecond(gProdEx.ProdTime.WorkTime, -1)) ;

        if mFindTime[0] >= mFindTime[1] then
        begin
            with Application do
                MessageBox(_TR('조회일자를 조정하십시요!'),
                           PChar(Caption),
                           MB_ICONWARNING+MB_OK) ;
            Exit ;
        end ;

        labPeriod.Caption := FormatDateTime('yyyy-mm-dd hh:nn:ss',mFindTime[0])
                             +' ~ '
                             +FormatDateTime('yyyy-mm-dd hh:nn:ss',mFindTime[1]) ;
    end
    else
    if rdbtnDay.Checked then
    begin
        yy := CurrentYear -  cbxYear.ItemIndex ;
        mm := cbxMonth.ItemIndex + 1 ;
        dd := DaysInAMonth(yy, mm) ;

        mFindTime[0] := Trunc(EncodeDate(yy,mm,1))+Frac(gProdEx.ProdTime.WorkTime) ;
        mFindTime[1] := Trunc(EncodeDate(yy,mm,dd))+1+Frac(IncSecond(gProdEx.ProdTime.WorkTime, -1)) ;

        labPeriod.Caption := IntToStr(yy)+_TR('년 ')+IntToStr(mm)+ _TR('월') ;
    end
    else
    if rdbtnMonth.Checked then
    begin
        yy := CurrentYear -  cbxYear.ItemIndex ;
        mFindTime[0] := Trunc(EncodeDate(yy, 1, 1))+Frac(gProdEx.ProdTime.WorkTime) ;
        mFindTime[1] := Trunc(EncodeDate(yy, 12, 31))+1+Frac(IncSecond(gProdEx.ProdTime.WorkTime, -1)) ;

        labPeriod.Caption := IntToStr(yy)+_TR('년 ') ;
    end ;

    FillChar(mMinTime, sizeof(mMinTime), 0) ;
    FillChar(mMaxTime, sizeof(mMaxTime), 0) ;
    FillChar(mDayCount, sizeof(mDayCount), 0) ;
    with mRetrieve do
    begin
        Initial ;
        BeginDate := mFindTime[0] ;
        BeginTime := mFindTime[0] ;
        EndDate   := mFindTime[1] ;
        EndTime   := mFindTime[1] ;
        iTm := FindDatas ;
    end ;
    sbtnToExcel.Enabled := iTm > 0 ;
    RetrieveExUpdates(false);
    fgProdInfo.Refresh ;
end;

function TfrmProdInfo.ListToExcel(AFile: string): boolean;
var
    i, j, ARow : integer ;
    nX : TToExcel ;
    sTm : string ;
begin
    Result := true ;
    nX   := TToExcel.Create(AFile);
    try
        ARow := 0 ;
        nX.SetSheet(0,'Data1');
        OnUsrListToExcelBefore(nX, ARow) ;

        nX.Font.Color := clBlack ;
        nX.CellStyle.rAlignment := chaCenter ;
        with sgrdLeft do
        begin
            for i := 1 to RowCount-1 do
            begin
                for j := 0 to ColCount-1 do
                begin
                    sTm := Cells[j, i] ;
                    if j In[0, 2] then nX.SetData(j, ARow, StrToIntDef(sTm,0))
                    else               nX.SetData(j, ARow, sTm);
                    nX.Box(j, ARow, j, ARow);
                end ;
                Inc(ARow) ;
            end ;
        end ;
        with sgrdRight do
        begin
            for i := 1 to RowCount-1 do
            begin
                for j := 0 to ColCount-1 do
                begin
                    sTm := Cells[j, i] ;
                    if j In[0, 2] then nX.SetData(j, ARow, StrToIntDef(sTm,0))
                    else               nX.SetData(j, ARow, sTm);
                    nX.Box(j, ARow, j, ARow);
                end ;
                Inc(ARow) ;
            end ;
        end ;
        OnUsrListToExcelAfter(nX, ARow) ;
        nX.EndOfDatas ;
    finally
        nX.Free ;
    end ;
end;

procedure TfrmProdInfo.rdbtnMonthClick(Sender: TObject);
begin
    sbtnSetTimes.Enabled := rdbtnTime.Checked ;
    RetrieveExUpdates(true) ;
end;

procedure TfrmProdInfo.sgrdLeftDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
begin
    AlignGrid(TStringGrid(Sender), ACol, ARow, Rect, State,
              [
               TA_CENTER,
               TA_CENTER,
               TA_CENTER,
               TA_CENTER,
               TA_CENTER,

               TA_CENTER,
               TA_CENTER,
               TA_CENTER,
               TA_CENTER,
               TA_CENTER,

               TA_CENTER,
               TA_CENTER,
               TA_CENTER,
               TA_CENTER,
               TA_CENTER
               ]);
end;

procedure TfrmProdInfo.ChangeAxis(AAxixItem: TFaAxisRuler;
    ALabelFormat: string; AMin, AMax, AStep: Double);
begin
    AAxixItem.LabelFormat := ALabelFormat ;
    AAxixItem.Min       := AMin - AStep;
    if AAxixItem.Min < 0 then AAxixItem.Min := 0 ;
    AAxixItem.Max       := AMax + AStep;

    AAxixItem.Step      := AStep ;

    if AAxixItem.Index <> 1 then
    begin
        AAxixItem.DrawMin   := AAxixItem.Min + AStep;
        AAxixItem.DrawMax   := AAxixItem.Max - AStep;
    end ;
end;

procedure TfrmProdInfo.cbxYearChange(Sender: TObject);
begin
    RetrieveExUpdates(true);
end;

procedure TfrmProdInfo.Initial;
var
    i : integer ;
    yy,mm,dd : WORD ;
begin
    DecodeDate(Now, yy,mm,dd);
    cbxYear.Clear ;
    for i := 0 to 9 do
    begin
        cbxYear.Items.Add(IntToStr(yy-i)+'년') ;
    end ;
    cbxYear.ItemIndex  := 0 ;
    cbxMonth.ItemIndex := mm-1 ;

    rdbtnTime.Checked := true ;

    mRetrieve.Initial ;
    RetrieveExUpdates(true);

    sbtnToExcel.Enabled  := false ;
    rdbtnTime.SetFocus ;
end;

procedure TfrmProdInfo.SetFrm(StartTime, EndTime: TDateTime);
begin
    //여기서의 일자는 작업일자를 기준으로 한다.
    //2009-03-01 하루 조회는
    // -> 일자는 2009-03-01로 모두 지정
    // -> 조회할때 2009-03-01 08:00:00 ~ 2009-03-02 07:59:59
    //2009-03-01 ~ 2009-03-02 하루 이상 조회일때
    // -> 일자는 START 2009-03-01, END 2009-03-02로 지정.
    // -> 조회는 2009-03-01 08:00:00 ~ 2009-03-03 07:59:59.
    dtpBeginTime.DateTime := StartTime ;
    dtpEndTime.DateTime   := EndTime ;
    if Trunc(StartTime) = Trunc(EndTime) then
    begin
        dtpEndTime.DateTime := EndTime + 1 ;
    end ;
end;

procedure TfrmProdInfo.sbtnToExcelClick(Sender: TObject);
begin
    DataToExcels ;
end;

procedure TfrmProdInfo.sbtnSearchClick(Sender: TObject);
begin
    SearchDatas ;
end;

procedure TfrmProdInfo.sbtnExitClick(Sender: TObject);
begin
    Close ;
end;

procedure TfrmProdInfo.sbtnSetTimesClick(Sender: TObject);
begin
    with TfrmProdTimes.Create(Self) do
    begin
        if ShowModal <> mrOK then Exit ; 
    end ;
    RetrieveExUpdates(true) ;
end;

end.
