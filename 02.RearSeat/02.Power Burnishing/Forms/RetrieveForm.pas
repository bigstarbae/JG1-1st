unit RetrieveForm;
{$INCLUDE myDefine.inc}
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, ExtCtrls, ComCtrls, StdCtrls, Buttons, CheckLst, RetrieveUnit,ModelType, SeatType,
  Menus, KiiMessages;

type

  TPosMaxMin = record
    rMin,
    rMax : integer ;
  end ;
  TfrmRetrieve = class(TForm)
    Panel3: TPanel;
    sbtnToExcel: TSpeedButton;
    sbtnDetailView: TSpeedButton;
    sbtnSearch: TSpeedButton;
    scbCon: TScrollBox;
    GroupBox2: TGroupBox;
    edtModel: TEdit;
    GroupBox4: TGroupBox;
    Label4: TLabel;
    Label5: TLabel;
    ckbok: TCheckBox;
    ckbng: TCheckBox;
    stubcount: TStatusBar;
    Panel2: TPanel;
    Splitter1: TSplitter;
    Panel6: TPanel;
    sgrdResult: TStringGrid;
    pnlRetrieveEx: TPanel;
    sgrdResultEx: TStringGrid;
    DlgSave: TSaveDialog;
    Button1: TButton;
    GroupBox5: TGroupBox;
    Label3: TLabel;
    sbtnUnSelect: TSpeedButton;
    stxSelCount: TStaticText;
    sbtnSelAll: TSpeedButton;
    Panel1: TPanel;
    sbtnExit: TSpeedButton;
    lbLog: TListBox;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    dtpStart: TDateTimePicker;
    dtpEnd: TDateTimePicker;
    dtpStartTime: TDateTimePicker;
    dtpEndTime: TDateTimePicker;
    Label6: TLabel;
    pnlTitle: TPanel;
    GroupBox3: TGroupBox;
    sbtnSelectFolder: TSpeedButton;
    ckbSort: TCheckBox;
    ckbNonIMS: TCheckBox;
    ckbIMS: TCheckBox;
    ckbJK: TCheckBox;
    ckbIK: TCheckBox;
    ckbCK: TCheckBox;
    ckbCV: TCheckBox;
    ckbJW: TCheckBox;
    ckbCE: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure sgrdResultExDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure FormDestroy(Sender: TObject);
    procedure sbtnExitClick(Sender: TObject);
    procedure sbtnSearchClick(Sender: TObject);
    procedure sbtnToExcelClick(Sender: TObject);
    procedure sgrdResultDblClick(Sender: TObject);
    procedure dtpStartKeyPress(Sender: TObject; var Key: Char);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Button1Click(Sender: TObject);
    procedure sbtnUnSelectClick(Sender: TObject);
    procedure sbtnSelAllClick(Sender: TObject);

    procedure sbtnDetailViewClick(Sender: TObject);
    procedure sbtnDetailView2Click(Sender: TObject);
    procedure sbtnSelectFolderClick(Sender: TObject);


  private
    { Private declarations }
    mRetrieve: TRetrieve ;

    procedure RetrieveExUpdates() ;
    function  DelFileName(const Buf):string ;
    function  DelGrpName(const Buf):string ;
    //--------------

    procedure OnUsrFileName(Sender: Tobject; const aTime:TDateTime; var aName: string) ;
    procedure OnUsrSearchDatas(Sender: Tobject; var Buf; var aPass, aResult: boolean)  ;
    procedure OnUsrListToExcelBefore(Sender: TObject; var AbPos: integer);
    procedure OnUsrListToExcelAfter(Sender: TObject; var AePos: integer) ;
    procedure OnSelGridChange(Sender:TObject) ;
    procedure UpdateItems(const AList: array of WORD; ACount: integer) ;
    procedure OnUsrSort(Sender: TObject);
  public
    { Public declarations }
    function  GetSelectCount: integer ;
    function  GetSelectList: TPosMaxMin ;
  end;

var
  frmRetrieve: TfrmRetrieve;

implementation
uses
    myUtils, DataUnit, ModelUnit, Math, NotifyForm, Log, DataBox,
    SelGrid, RetrieveEx, IniFiles, ShellApi, DateUtils,
    KiiFaGraphDB, ToExcelUnit, BIFFRecsII4, CellFormats4, PasswdForm,
    shlObj, VerUnit, DetailForm, SysEnv, GridHead, WaitForm, LangTran;

var
    // 중복실행방지
    Mutex   : THandle;
    lpList : TStrings ;
    lpItems: TRetrieveItem ;
    lpBox: TDataBox ;

const _ITEM_COUNT = 8 ;
{$R *.DFM}
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

procedure SetGridCells(GHeader: TGridTitle) ;
begin
    with GHeader do
    begin
        AddHeader([
            '순번, 		작업 정보, 	#L,        #L,   	  #L,      #L,     #L,     공정, 전체 결과',
             '#T,   	작업 일자, 	작업 시간, PART NO, PART NAME, 차종,   LOT NO, #T,   #T',
             '#T,		#T,			#T,		   #T,		  #T,      #T,     #T,     #T,   #T'
         ]);

         AddHeader([
            '이음 체크',
            '#T',
            '#T'
         ]);

        AddHeader([
            'L.SLIDE LH,   #L,     #L,          #L,       #L,          #L,      #L,          #L,     #L,     #L,         #L,     #L,    #L',
            '전류,   #L,     속도 검사,   #L,       #L,          #L,      초기 소음,   #L,     #L,     작동 소음,   #L,     #L,         HALL 센서',
            '전진,   후진,   검사 기준,   전진,     #검사 기준,  후진,    검사 기준,   전진,   후진,   검사 기준,   전진,   후진,       #T'
         ]);

        AddHeader([
            'L.SLIDE RH,  #L,     #L,          #L,       #L,          #L,      #L,          #L,     #L,     #L,         #L,     #L,     #L',
            '전류,  #L,     속도 검사,   #L,       #L,          #L,      초기 소음,   #L,     #L,     작동 소음,   #L,     #L,          HALL 센서',
            '전진,   후진,   검사 기준,   전진,     #검사 기준,  후진,    검사 기준,   전진,   후진,   검사 기준,   전진,   후진,       #T'
         ]);

    end ;
end ;

function CreateHeader(aGrid: TStringGrid): TGridTitle ;
var
    i : integer ;
begin
    with aGrid do
    begin
        for i := 1 to RowCount-1 do Rows[i].Clear() ;
        RowCount := 2 ;
    end ;

    Result := TGridTitle.Create(aGrid, Length(DataGridORD), 3);

    SetGridCells(Result) ;
end ;

procedure TfrmRetrieve.FormCreate(Sender: TObject);
begin
    //ShowMessage(Format('%d',[sizeof(TResult)])) ;
    {$IFDEF _VIEWER}
    gLog := TLog.Create(lbLog.Handle, 1) ;
    gBase := TUserModels.Create ;
    frmNotify := TfrmNotify.Create(Application);
    //sbtnExit.Caption := _TR('종료(&X)') ;
    {$ENDIF}
    //2013-12-30 SetMyTimeFormat(Self) ;
    WindowState := wsMaximized ;
    lpList := TStringList.Create;
   try
        with TVerInfoEx.Create(GetIniFiles) do
        begin
            Caption := Caption+' Ver: 240610.00'; //+FileVersionInfo.fFileVersion ;
            Free ;
        end ;
    finally
    end;
    lpBox:= TDataBox.Create(0) ;
end;

procedure TfrmRetrieve.FormShow(Sender: TObject);
begin
    pnlTitle.Caption := PROJECT_NAME + ' ' + _TR(' 결과조회') ;
    {$IFDEF TEST_DEBUG}
    Button1.Visible := true;
    {$ELSE}
    Button1.Visible := false;
    {$ENDIF}
    with sgrdResult do
    begin
        ColCount := Length(DataGridORD) ;
        RowCount := 2 ;
    end ;
    LoadGridColWidths(sgrdResultEx, '_RETRIEVE_RESULT_EX') ;
    mRetrieve := TRetrieve.Create(sgrdResult,
                                  CreateHeader(sgrdResult),
                                  TDataBox.Create(0),
                                  nil,
                                  PROJECT_NAME,
                                  _ITEM_COUNT,
                                  sizeof(TResult),
                                  0);
    with mRetrieve do
    begin
        SetGridORD(DataGridORD) ;
        OnDelFileName := DelFileName ;
        OnDelGrpName  := DelGrpName ;
        OnGetFileName := OnUsrFileName ;
        OnSearchDatas := OnUsrSearchDatas ;
        OnListToExcelBefore := OnUsrListToExcelBefore ;
        OnListToExcelAfter  := OnUsrListToExcelAfter ;
        OnSort := OnUsrSort ;

        if GetSelGrid <> nil then
            with GetSelGrid as TSelGridItem do
                OnChange := OnSelGridChange ;
    end ;

    lpItems := TRetrieveItem.Create(_ITEM_COUNT, sizeof(TResult)) ;

    dtpStart.Date := GetOneDayTime(Now());
    dtpStartTime.Time := gsysEnv.rWorkTime ;
    dtpEnd.Date   := GetOneDayTime(Now())+1 ;
    dtpEndTime.Time := IncSecond(gsysEnv.rWorkTime, -1) ;

    ckbOk.Checked := true ;
    ckbNG.Checked := true ;
    ckbSort.Checked  := true ;
  
    ckbIMS.Checked:= true ;
    ckbNonIMS.Checked:= true ;
    ckbJK.Checked := true;
    ckbIK.Checked := true;
    ckbCK.Checked := true;
    ckbCV.Checked := True;
    ckbJW.Checked := True;
    ckbCE.Checked := True;

    sbtnSelAll.Enabled     := false ;
    sbtnToExcel.Enabled    := false ;
    sbtnDetailView.Enabled := false ;

    //sbtnSearch.Click ;
    dtpStart.SetFocus ;
    RetrieveExUpdates ;

    sgrdResultEx.RowHeights[0] := sgrdResultEx.DefaultRowHeight + 5;

	TLangTran.ChangeCaption(self);
end;

procedure TfrmRetrieve.sgrdResultExDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
begin
    AlignGrid(TStringGrid(Sender), ACol, ARow, Rect, State,
              [
               TA_CENTER, TA_CENTER, TA_RIGHT, TA_RIGHT, TA_RIGHT,
               TA_RIGHT,  TA_RIGHT,  TA_RIGHT, TA_RIGHT, TA_RIGHT,
               TA_RIGHT,  TA_RIGHT,  TA_RIGHT, TA_RIGHT, TA_RIGHT
               ]);
end;

procedure TfrmRetrieve.FormDestroy(Sender: TObject);
begin
    try
        FreeAndNil(lpBox) ;
        FreeAndNil(mRetrieve) ;
        FreeAndNil(lpList);
        FreeAndNil(lpItems) ;
    Finally
        mRetrieve := nil ;
        lpList := nil ;
        lpItems:= nil ;
    end ;
    {$IFDEF _VIEWER}
    FreeAndNil(gBase) ;
    FreeAndNil(gLog) ;
    {$ENDIF}
end;



procedure TfrmRetrieve.sbtnDetailView2Click(Sender: TObject);
begin
    gLog.Panel('11');
end;

procedure TfrmRetrieve.sbtnDetailViewClick(Sender: TObject);
var
    nL: TPosMaxMin ;
    UsrFrm : TfrmDetail ;
begin
    if ((mRetrieve.OK + mRetrieve.NG) <= 0)
        and not Button1.Visible then Exit ;

    with TfrmWait.Create(Application) do
    begin
        Execute('PwrSeatTester.exe', 30.0) ;
    end ;

    UsrFrm := TfrmDetail.Create(Application) ;
    with UsrFrm do
    begin
        nL := GetSelectList ;
        SetFrm(mRetrieve.TmpFile, nL.rMin) ;
        ShowModal ;
    end ;
end;

procedure TfrmRetrieve.sbtnExitClick(Sender: TObject);
begin
    SaveGridColwidths(sgrdResultEx, '_RETRIEVE_RESULT_EX') ;
    Close ;
end;

const
    RESULT_TXT : array[0.. 9] of string
                   = ('No','Part Name','작업수량','양품', '불량',
                      'L.SLIDE LH','L.SLIDE RH','초기소음','작동소음',
                      '이음') ;
procedure TfrmRetrieve.RetrieveExUpdates() ;
var
    i, j, nC : integer ;
begin
    with sgrdResultEx do
    begin
        ColCount := Length(RESULT_TXT) ;
        for i := 0 to ColCount -1 do
            if IsHan(RESULT_TXT[i]) then
                Cells[i, 0] := _TR(RESULT_TXT[i])
            else
                Cells[i, 0] := RESULT_TXT[i];
        for i := 1 to RowCount -1 do Rows[i].Clear() ;
        RowCount := 4 ;

        with mRetrieve do
        begin
            if Count > 0 then
            begin
                RowCount := Count + 2 ;
                for i := 0 to Count-1 do
                begin
                    Cells[0, i+1] := IntToStr(i+1) ;
                    Cells[1, i+1] := GetName(i) ;
                    Cells[2, i+1] := Format('%d', [GetCount(i,true)+GetCount(i,false)]) ;
                    Cells[3, i+1] := Format('%d', [GetCount(i,true)]) ;
                    Cells[4, i+1] := Format('%d', [GetCount(i,false)]) ;
                    nC := 5 ;
                    for j := 1 to ItemCount-1 do
                    begin
                        Cells[nC, i+1] := Format('%d', [GetCount(i, false, j)]) ;
                        Inc(nC) ;
                    end;
                end ;
                Cells[2, RowCount-1] := Format('%d', [OK+NG]) ;
                Cells[3, RowCount-1] := Format('%d', [OK]) ;
                Cells[4, RowCount-1] := Format('%d', [NG]) ;
                nC := 5 ;
                for j := 1 to ItemCount-1 do
                begin
                    Cells[nC, RowCount-1] := Format('%d', [GetNgSum(j)]) ;
                    Inc(nC) ;
                end;
            end ;
        end ;

        Cells[0, RowCount-1] := 'Total' ;
        pnlRetrieveEx.Height := RowCount * DefaultRowHeight + 10 ;
    end ;
end ;


procedure TfrmRetrieve.sbtnSearchClick(Sender: TObject);
var
    i : integer ;
begin
    dtpStart.DateTime := Trunc(dtpStart.Date)+Frac(dtpStartTime.Time) ;
    dtpEnd.DateTime   := Trunc(dtpEnd.Date)+Frac(dtpEndTime.Time) ;
    
    if dtpStart.Date > dtpEnd.Date then
    begin
        with Application do
            MessageBox(PChar(_TR('검색일자를 조정하십시요!')),
                       PChar(Caption),
                       MB_ICONWARNING+MB_OK) ;
        Exit ;
    end ;

    sgrdResult.Tag := -1 ;
    lpList.Clear ;
    lpList.CommaText := edtModel.Text ;
    with mRetrieve do
    begin
        Initial ;
        //Option := rpPartName ;

        BeginDate := dtpStart.DateTime-1 ;
        BeginTime := dtpStart.DateTime ;
        EndDate   := dtpEnd.DateTime + 1 ;
        EndTime   := dtpEnd.DateTime ;

        i := FindDatas ;

        sbtnDetailView.Enabled := i > 0 ;
        sbtnSelAll.Enabled     := i > 0 ;
        stubCount.Panels.Items[0].Text := IntToStr(i) ;

        sgrdResult.Repaint() ;
    end ;
    RetrieveExUpdates() ;

    with sgrdResult do
    begin
        Row    := 1;//2009.11.03 RowCount-1 ;
        SetFocus ;
    end ;

    sbtnUnSelect.Enabled := false ;
end;

procedure TfrmRetrieve.sbtnToExcelClick(Sender: TObject);
var
    sTm,shFile : string ;
    i, iDx, Count : integer ;
    exlData: array of WORD ;
begin
    //선택된것만 할건지 물어보자.
    if mRetrieve.GetSelGrid = nil then Exit ;
    with Application do
        if MessageBox(PChar(_TR('검사 작업중일 경우 작업에 영향을 줄 수 있습니다, 계속하시겠습니까?')),
                      PChar(_TR('엑셀 변환!')),
                      MB_ICONWARNING+MB_YESNO) = IDNO then
        begin
            Exit ;
        end ;

	shFile := '' ;
    Count := TSelGridItem(mRetrieve.GetSelGrid).Count ;
    if Count > 60000 then
    begin
        with Application do
            MessageBox(PChar(_TR('변환할 데이터가 너무 많습니다, 변환 범위를 줄여주십시요(<60000)')),
                          PChar(_TR('엑셀 변환!')),
                          MB_ICONWARNING);

        Exit ;
    end ;
    SetLength(exlData, Count) ;

    iDx := 0 ;
    for i := 1 to sgrdResult.RowCount-1 do
    begin
        if TSelGridItem(mRetrieve.GetSelGrid).IsSelected(i) then
        begin
            exlData[iDx] := i ;
            Inc(iDx) ;
            if iDx = Count then Break ;
        end ;
    end ;

    sbtnSearch.Enabled     := false ;
    sbtnDetailView.Enabled := false ;
    sbtnToExcel.Enabled    := false ;
    sbtnExit.Enabled       := false ;

    with DlgSave do
    begin
        InitialDir := GetDeskTopDirectory ;
        Options := Options + [ofOverWritePrompt] ;
        Filter     := _TR('엑셀파일(*.xls)|*.xls') ;
        FileName   := 'Report'+FormatDateTime('mmdd-hhnnss',Now)+'.xls' ;
        if Execute then
        begin
            if Uppercase(ExtractFileExt(FileName)) <> '.XLS' then
            begin
                FileName := ChangeFileExt(FileName, '.xls') ;
            end ;
            UpdateItems(exlData, Count) ;
            //----------
            if FileExists(FileName)
                and not DeleteFile(FileName) then
            begin
                with Application do
                    MessageBox(PChar(_TR('지정된 파일이 사용중입니다, 파일을 닫은 후 다시 작업하세요!')),
                               PChar(_TR('엑셀 변환!')),
                               MB_ICONERROR+MB_OK) ;
                Exit ;
            end ;
            //----------
            Screen.Cursor := crHourGlass ;
            if mRetrieve.ListToExcel(FileName, exlData, Count) then
            begin
            	shFile := FileName ;
                sTm := Format('%s'+#13+_TR(' xls 저장되었습니다!'), [FileName]) ;
                with Application do
                    MessageBox(PChar(sTm), PChar(_TR('엑셀 변환!')), MB_ICONINFORMATION+MB_OK) ;
            end
            else
            begin
                sTm := Format('%s'+#13+' %s', [FileName, _TR('저장할 수 없습니다, 확인 후 다시하세요!')]) ;
                with Application do
                    MessageBox(PChar(sTm), PChar(_TR('엑셀 변환!')), MB_ICONERROR+MB_OK) ;
            end ;
        end ;
    end ;
    if Length(exlData) > 0 then SetLength(exlData, 0) ;
    if sbtnUnSelect.Enabled then sbtnUnSelect.Click ;
    //EDIT if FileExists(shFile) then Shellexecute(Handle,'open', PChar(shFile),'',nil,sw_shownormal);
    sbtnSearch.Enabled     := true ;
    sbtnDetailView.Enabled := true ;
    sbtnExit.Enabled       := true ;

    SetCurrentDir(GetHomeDirectory) ;
    Screen.Cursor := crDefault ;
end;

procedure TfrmRetrieve.sgrdResultDblClick(Sender: TObject);
begin
    if (mRetrieve.OK + mRetrieve.NG) <= 0 then Exit ;
    sbtnDetailView.Click ;
end;

function  TfrmRetrieve.DelFileName(const Buf):string ;
var
    nBuf: TResult ;
begin
    Move(Buf, nBuf, sizeof(TResult)) ;
    Result := GetResultFileName(nBuf.rFileTime, false) ;
end ;

function  TfrmRetrieve.DelGrpName(const Buf):string ;
begin
    Result := '' ;
end ;

procedure TfrmRetrieve.dtpStartKeyPress(Sender: TObject; var Key: Char);
begin
    if Key In[#13] then
    begin
        Key := #0 ;
        sbtnSearch.Click ;
    end ;
end;

function  TfrmRetrieve.GetSelectCount: integer ;
begin
    with sgrdResult do
        Result := (Selection.Bottom - Selection.Top) + 1 ;
end ;

function  TfrmRetrieve.GetSelectList: TPosMaxMin ;
begin
    with sgrdResult do
    begin
        Result.rMin := Selection.Top ;
        Result.rMax := Selection.Bottom ;
    end ;
end ;

procedure TfrmRetrieve.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
    {$IFNDEF _VIEWER}
    Action := caFree ;
    {$ENDIF}
end;

procedure TfrmRetrieve.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
    with TfrmWait.Create(Application) do
    begin
        Execute('PwrSeatTester.exe', 50.0) ;
    end ;
end;

procedure TfrmRetrieve.OnUsrFileName(Sender: Tobject; const aTime:TDateTime; var aName: string) ;
begin
    aName := GetResultFileName(aTime, false) ;
end ;

procedure TfrmRetrieve.OnUsrSearchDatas(Sender: Tobject; var Buf;
    var aPass, aResult: boolean)  ;
var
    nRs : TResult ;
    aVal : integer;
begin
    Move(Buf, nRs, sizeof(TResult)) ;
    with Sender as TRetrieve do
    begin
        aPass := true ;
        // date check
        // a day Time check
        if (dtpStart.DateTime > nRs.rLastTime)
            or (dtpEnd.DateTime < nRs.rLastTime) then Exit ;

        if lpList.Count > 0 then
        begin
            if not IsTxtInList(lpList, nRs.rModel.rPartName)
                and not IsTxtInList(lpList, nRs.rModel.rPartNO)
                //and not IsTxtInList(lpList, nRs.rModel.rTypes.GetOpTypeStr)
                and not IsTxtInList(lpList, nRs.rModel.rTypes.GetPosStr)
                and not IsTxtInList(lpList, nRs.rLotNo) then Exit ;
        end ;

        if ckbOk.Checked <> ckbNG.Checked then
        begin
            if (nRs.rValidity[tsResult]<>ckbOk.Checked)
                and (not nRs.rValidity[tsResult]<>ckbNG.Checked) then Exit ;
        end ;



        if ckbIMS.Checked <> ckbNonIMS.Checked then
        begin
            {
            if nRs.rModel.rTypes.IsIMS then aVal := 1
            else                            aVal := 0;
            }
            if (aVal = BYTE(ckbNonIMS.Checked))
                or (aVal <> BYTE(ckbIMS.Checked)) then Exit ;
        end ;



        aResult := nRs.rValidity[tsResult] ;
        aPass   := false ;
        AddData(nRs.rModel.rPartName, aResult) ;
        if not AResult then
        begin
            lpBox.SetResult(nRs);
            if (lpBox.IsTested(tsLSlideLH) and not lpBox.GetResult(tsLSlideLH)) then
            begin
                AddData(nRs.rModel.rPartName,false, 1) ;
            end;
            if (lpBox.IsTested(tsLSlideRH) and not lpBox.GetResult(tsLSlideRH)) then
            begin
                AddData(nRs.rModel.rPartName,false, 2) ;
            end ;
            if (lpBox.IsTested(roRsInitNoise)
                and not lpBox.GetResult(roRsInitNoise)) then
            begin
                AddData(nRs.rModel.rPartName,false, 3) ;
            end ;
            if (lpBox.IsTested(roRsRunNoise)
                and not lpBox.GetResult(roRsRunNoise)) then
            begin
                AddData(nRs.rModel.rPartName,false, 4) ;
            end ;
            if lpBox.IsTested(roRsAbnormalSound)
                and not lpBox.GetResult(roRsAbnormalSound) then
            begin
                AddData(nRs.rModel.rPartName,false, 5) ;
            end ;


        end;
    end ;
end ;

procedure TfrmRetrieve.Button1Click(Sender: TObject);
begin
    sbtnDetailView.Enabled := true ;
end;

procedure TfrmRetrieve.OnSelGridChange(Sender: TObject);
begin
    with Sender as TSelGridItem do
    begin
        sbtnUnSelect.Enabled := Count > 0 ;
        stxSelCount.Caption  := IntToStr(Count)+' ' ;

        //sbtnDel.Enabled        := sbtnUnSelect.Enabled ;
        sbtnToExcel.Enabled    := sbtnUnSelect.Enabled ;
        //sbtnAutoGraphSave.Enabled := sbtnUnSelect.Enabled ;
    end ;
end;

procedure TfrmRetrieve.sbtnUnSelectClick(Sender: TObject);
begin
    if not Assigned(mRetrieve) then
    begin
        with Sender as TSpeedButton do Enabled := false ;
        Exit ;
    end ;

    with mRetrieve do
    begin
        if GetSelGrid <> nil then
            with GetSelGrid as TSelGridItem do Unselect ;
    end ;
end;

procedure TfrmRetrieve.sbtnSelAllClick(Sender: TObject);
begin
    with mRetrieve do
    begin
        if GetSelGrid <> nil then
            with GetSelGrid as TSelGridItem do AllSelect ;
    end ;
end;

procedure TfrmRetrieve.UpdateItems(const AList: array of WORD;
  ACount: integer);
var
    i, fh : integer ;
    Buf : TResult ;
begin
    if not Assigned(lpItems) then Exit ;
    with lpItems do
    begin
        Initial ;
        fh := FileOpen(mRetrieve.TmpFile, fmOpenRead) ;
        if fh < 0 then Exit ;
        try
            for i := 0 to ACount-1 do
            begin
                FileSeek(fh, (AList[i]-1) * sizeof(TResult), 0);
                FileRead(fh, Buf, sizeof(TResult)) ;
                AddData(Buf.rModel.rPartName, Buf.rValidity[tsResult]) ;
                if not Buf.rValidity[tsResult] then
                begin
                    lpBox.SetResult(Buf);
                    if (lpBox.IsTested(tsLSlideLH) and not lpBox.GetResult(tsLSlideLH)) then
                    begin
                        AddData(Buf.rModel.rPartName,false,1) ;
                    end;
                    if (lpBox.IsTested(tsLSlideRH) and not lpBox.GetResult(tsLSlideRH)) then
                    begin
                        AddData(Buf.rModel.rPartName,false,2) ;
                    end ;

                    if (lpBox.IsTested(roRsInitNoise)
                        and not lpBox.GetResult(roRsInitNoise)) then
                    begin
                        AddData(Buf.rModel.rPartName,false, 4) ;
                    end ;
                    if (lpBox.IsTested(roRsRunNoise)
                        and not lpBox.GetResult(roRsRunNoise)) then
                    begin
                        AddData(Buf.rModel.rPartName,false, 5) ;
                    end ;
                    {
                    if lpBox.IsTested(tsLimit)
                        and not lpBox.GetResult(roRsLimit) then
                    begin
                        AddData(Buf.rModel.rPartName,false,6) ;
                    end ;
                    }
                end ;
            end ;
        finally
            FileClose(fh) ;
        end ;
    end ;
end;

procedure TfrmRetrieve.OnUsrListToExcelAfter(Sender: TObject;
  var AePos: integer);
var
    i, j : integer ;
    sTm : string ;
begin
    Inc(AePos) ;
    with Sender as TToExcel do
    begin
        Font.Color := clBlack ;

        BoardStyle.rColor := xcBlack ;
        BoardStyle.rStyle := cbsThin ;

        CellStyle.rColor  := xcWhite ;
        CellStyle.rAlignment := chaCenter ;
        CellStyle.rLayOut    := cvaCenter ;
        //Caption
        for i := 0 to sgrdResultEx.ColCount-1 do
        begin
            sTm := sgrdResultEx.Cells[i, 0] ;
            Box(i, AePos, i, AePos) ;
            if sTm <> '' then
            begin
                CellStyle.rAlignment := chaCenter ;
                SetData(i, AePos, sTm);
            end ;
        end ;
        Inc(AePos) ;
        //Datas
        for i := 0 to lpItems.Count-1 do
        begin
            CellStyle.rAlignment := chaCenter ;
            SetData(0, AePos, i+1) ;
            Box(0, AePos, 0, AePos) ;

            SetData(1, AePos, lpItems.GetName(i)) ;
            Box(1, AePos, 1, AePos) ;

            CellStyle.rAlignment := chaRight ;
            SetData(2, AePos, lpItems.GetCount(i, true, 0)+lpItems.GetCount(i,false,0)) ;
            Box(2, AePos, 2, AePos) ;
            SetData(3, AePos, lpItems.GetCount(i, true, 0)) ;
            Box(3, AePos, 3, AePos) ;
            SetData(4, AePos, lpItems.GetCount(i,false,0)) ;
            Box(4, AePos, 4, AePos) ;

            CellStyle.rAlignment := chaCenter ;
            for j := 1 to lpItems.ItemCount-1 do
            begin
                SetData(4+j, AePos, lpItems.GetCount(i, false, j)) ;
                Box(4+j, AePos, 4+j, AePos) ;
            end ;
            Inc(AePos) ;
        end;
        //Sum
        CellStyle.rAlignment := chaCenter ;
        SetData(0, AePos, _TR('합계')) ;
        Box(0, AePos, 0, AePos) ;
        Box(1, AePos, 1, AePos) ;

        CellStyle.rAlignment := chaRight ;
        SetData(2, AePos, lpItems.GetOkSum()+lpItems.GetNgSum()) ;
        Box(2, AePos, 2, AePos) ;

        SetData(3, AePos, lpItems.GetOkSum()) ;
        Box(3, AePos, 3, AePos) ;

        SetData(4, AePos, lpItems.GetNgSum()) ;
        Box(4, AePos, 4, AePos) ;

        CellStyle.rAlignment := chaCenter ;
        for j := 1 to lpItems.ItemCount-1 do
        begin
            SetData(j+4, AePos, lpItems.GetNGSum(j)) ;
            Box(j+4, AePos, j+4, AePos) ;
        end ;
    end ;
end;

procedure TfrmRetrieve.OnUsrListToExcelBefore(Sender: TObject;
  var AbPos: integer);
var
    i, j : integer ;
    CellRect : TRect;
begin
    AbPos := 5 ;
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
        SetMergeData(0, 0, sgrdResult.ColCount-1, 1, PROJECT_NAME+' Report');
        Box(0, 0, sgrdResult.ColCount-1, 1) ;

        Font.Size  := 10 ;
        Font.Style := [] ;

        with mRetrieve.GridHead do
        begin
            for i := 0 to ColCount - 1 do
            begin
                for j := 0 to RowCount - 1 do
                begin
                    if GetMergedCells(i, j, CellRect) then
                    begin
                        Inc(CellRect.Top, 2);
                        Inc(CellRect.Bottom, 2);
                        SetMergeData(CellRect.Left, CellRect.Top, CellRect.Right, CellRect.Bottom, Heads[i, j].Caption);
                        Box(CellRect.Left, CellRect.Top, CellRect.Right, CellRect.Bottom);
                    end;
                end;

            end;
        end;
    end ;
end;
{$IFDEF _VIEWER}
var lpCallBackDir : string ;
function BrowserCallBackProc(Wnd: HWND; uMsg: UINT; lParam, lpData: LPARAM): Integer stdcall ;
begin
    Result := 1 ;
    case uMsg of
        BFFM_INITIALIZED :
        begin
            SendMessage(Wnd,
                        BFFM_SETSELECTION,
                        integer(true),
                        integer(PChar(lpCallBackDir))) ;
            // wParam 이 true 이면 lParam 경로
            // wParam 이 false이면 lParam PIDL
        end ;
    end ;
end ;



procedure TfrmRetrieve.sbtnSelectFolderClick(Sender: TObject);
var
    sTm : string ;
begin
    lpCallBackDir := gsysEnv.rResultDir ;
    sTm := GetUserFolderEx(Self.Handle, BrowserCallBackProc, _TR('데이타저장위치')) ;
    if (sTm = '')
        or not DirectoryExists(sTm) then Exit ;

    gsysEnv.rResultDir := sTm ;
    SaveEnvFile ;
end;





function  DataSort(const AfHandle: integer; Item1, Item2: integer): integer ;
var
    Buf1, Buf2 : TResult ;
begin
    FileSeek(AfHandle, (Item1-1)*sizeof(TResult), 0) ;
    FileRead(AfHandle, Buf1, sizeof(TResult)) ;

    FileSeek(AfHandle, (Item2-1)*sizeof(TResult), 0) ;
    FileRead(AfHandle, Buf2, sizeof(TResult)) ;

    if Buf1.rLastTime > Buf2.rLastTime then Result := 1
    else
    if Buf1.rLastTime < Buf2.rLastTime then Result := -1
    else                                    Result := 0 ;
end ;

procedure DataChange(const AfHandle: integer; Item1, Item2: integer) ;
var
    Buf1, Buf2, Tmp : TResult ;
begin
    FileSeek(AfHandle, (Item1-1)*sizeof(TResult), 0) ;
    FileRead(AfHandle, Buf1, sizeof(TResult)) ;

    FileSeek(AfHandle, (Item2-1)*sizeof(TResult), 0) ;
    FileRead(AfHandle, Buf2, sizeof(TResult)) ;

    Tmp  := Buf1 ;
    Buf1 := Buf2 ;
    Buf2 := Tmp ;

    FileSeek(AfHandle, (Item1-1)*sizeof(TResult), 0) ;
    FileWrite(AfHandle, Buf1, sizeof(TResult)) ;

    FileSeek(AfHandle, (Item2-1)*sizeof(TResult), 0) ;
    FileWrite(AfHandle, Buf2, sizeof(TResult)) ;
end ;

procedure DataQuickpSort(const AfHandle: integer; First, Last:integer) ;
var
    i, j, std : integer ;
begin
    std := (First+Last) div 2 ;

    i := First;
    j := Last;
    while true do
    begin
        while DataSort(AfHandle, i, std) < 0 do
        begin
            Inc(i) ;
        end ;
        while DataSort(AfHandle, j, std) > 0 do
        begin
            dec(j) ;
        end ;
        if (i >= j) then Break ;

        DataChange(AfHandle, i, j) ;
        Inc(i) ;
        Dec(j) ;
    end ;

    if (First < i - 1) then DataQuickpSort(AfHandle, First, i - 1) ;
    if (j + 1 < Last)  then DataQuickpSort(AfHandle, j + 1, Last) ;
end;

procedure TfrmRetrieve.OnUsrSort(Sender: TObject);
var
    fh : integer ;
begin
    if not FileExists(mRetrieve.TmpFile) or not ckbSort.Checked then Exit ;

    fh := 0 ;
    try
        fh := FileOpen(mRetrieve.TmpFile, fmOpenReadWrite) ;
        if (fh >= 32) and ((FileSeek(fh, 0, 2) div sizeof(TResult)) > 2) then
        begin
            DataQuickpSort(fh, 1, FileSeek(fh, 0, 2) div sizeof(TResult)) ;
        end ;
    finally
        FileClose(fh) ;
    end;
end;



initialization
    Mutex := CreateMutex(nil, True, PChar(PROJECT_NAME+_TR(' 조회')));
    if GetLastError = ERROR_ALREADY_EXISTS then
    begin
        with Application do
            MessageBox(PChar(PROJECT_NAME+_TR(' 조회 프로그램이 실행중입니다.')),
                       PChar(PROJECT_NAME+_TR(' 조회 프로그램')),
                       MB_ICONSTOP+MB_OK);
        Halt ; // kill the second instance
    end;

finalization                            // alt end free the mHandle
    if Mutex <> 0 then CloseHandle(Mutex) ;
{$ENDIF}


end.

