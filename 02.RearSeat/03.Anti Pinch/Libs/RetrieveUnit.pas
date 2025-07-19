unit RetrieveUnit;
{$INCLUDE myDefine.inc}
interface
uses
  Windows, Messages, SysUtils, Classes, Forms, Dialogs, Grids, Controls,
  Graphics, DataUnit, BaseDataBox, GridHead, RetrieveEx, XbarRLib, SelGrid ;

type

TGetFileName = procedure (Sender: Tobject; const aTime:TDateTime; var aName: string) of Object ;
TSearchDatas = procedure (Sender: Tobject; var Buf; var aPass, aResult: boolean) of Object ;
TThreadSearchDatas = function (Sender: Tobject; var Buf; Count:integer): boolean of Object ;
TListToExcel = procedure (Sender: TObject; var EndPosition: integer) of Object ;
TRetrieve = class(TRetrieveItem)
private
    mTag : integer ;   // 같은 프로그램에서 다른용도의클래스로 구분용
    mName: string ;
    mGrid: TStringGrid ;
    mOk,
    mNG  : integer ;
    mfName : string ;
    mLstIDx: integer ;

    mBegin,
    mEnd   : TDateTime ;
    mBreak : boolean ;

    mBox   : TBaseDataBox;
    mGridHead: TGridTitle ;

    mTmpBuf  : array of BYTE ;
    mTmpsize : integer ;
    mSpc     : TXbarEx ;

    mGetFileName : TGetFileName ;
    mSearchDatas : TSearchDatas ;
    mListToExcelBefore : TListToExcel ;
    mListToExcelAfter  : TListToExcel ;
    mSpecUpdates : TNotifyEvent ;
    mSortEvent : TNotifyEvent ;
    //2009.09.03
    mUsrDrawCell : TDrawCellEvent ;

    mGridORD : array of TResultORD ;
    mTmpAry  : array of WORD ;
    mTmpCreate : boolean ;
    mSelGrid : TSelGridItem ;

    procedure SetDates(aIndex: integer; aDate: TDate) ;
    procedure SetTimes(aIndex: integer; aTime: TTime) ;
    function  FindShow: integer ;
    // StringGrid
    procedure DrawCell(Sender: TObject; ACol,
              ARow: Integer; Rect: TRect; State: TGridDrawState);

    procedure OnXMlRead(Sender:TObject; ACol,ARow:integer; var AData:string);
    function  SetReadData(Sender: Tobject): boolean ;
    function  GetUsrFileName(ATime: double): string;
protected
    mTmpHandle : integer ;
public
    constructor Create(AGrid: TStringGrid; AGridHead:TGridTitle;
        ADataBox:TBaseDataBox; ASPC:TXbarEx; AName: string; ItemCount,
        BufSize, ATag: integer) ;
    destructor  Destroy; override ;

    procedure Initial ;
    function  FindDatas : integer ;
    function  DeleteDatas: integer ;
    procedure SetBreak ;

    procedure GetADataFromTemp(aDatas: TStrings; aReadPos :integer) ;
    function  GetATemp(var aBuf; aPos: integer): boolean ;
    function  GetASpec(ASpec: TResultORD; IsUnit:boolean=false): string ;
    function  GetAData(aPos:integer; aData: TResultORD; IsUnit:boolean=false): string ;
    function  ListToExcel(aExcel: string): boolean ; overload ;
    function  ListToExcel(aExcel: string; List:array of WORD; ACount:integer): boolean ; overload ;
    function  GetResult(var Buf; aPos: integer): boolean ;
    procedure SetGridORD(AORD: array of TResultORD) ;

    procedure LoadColInfo ;
    procedure SaveColInfo ;

    property BeginDate: TDate index 0 write SetDates ;
    property EndDate  : TDate index 1 Write SetDates ;
    property BeginTime: TTime index 0 write SetTimes ;
    property EndTime  : TTime index 1 write SetTimes ;

    property OK : integer read mOK ;
    property NG : integer read mNG ;
    property TmpFile  : string     read mfName ;
    property GridHead : TGridTitle read mGridHead ;
    property SPC : TXbarEx read mSpc ;
    property Tag : integer read mTag write mTag;
    property Name: string  read mName ;
    property TmpFileCreate : boolean read mTmpCreate write mTmpCreate ;

    property OnGetFileName : TGetFileName read mGetFileName write mGetFileName ;
    property OnSearchDatas : TSearchDatas read mSearchDatas write mSearchDatas ;
    property OnListToExcelBefore : TListToExcel read mListToExcelBefore write mListToExcelBefore ;
    property OnListToExcelAfter  : TlistToExcel read mListToExcelAfter  write mListToExcelAfter ;
    property OnSpecUpdates : TNotifyEvent read mSpecUpdates write mSpecUpdates ;
    property OnSort : TNotifyEvent read mSortEvent write mSortEvent ;
    //2005.08.30
    function GetSelGrid : TObject ;
    property Box : TBaseDataBox read mBox ;
    //2009.09.03
    property OnUserDrawCell : TDrawCellEvent read mUsrDrawCell write mUsrDrawCell ;
    function IsSelected(Index: integer): boolean ;
end ;

TUsrRetrieve = class(TRetrieve)
public
    constructor Create(AGrid: TStringGrid; AGridHead:TGridTitle;
        ADataBox:TBaseDataBox; ASPC:TXbarEx; AName: string; ItemCount,
        BufSize, ATag: integer) ;
    destructor  Destroy; override ;

    procedure SetFile(aName: string) ;
end ;
    procedure CheckColorAndDisplay(aCanvas:TCanvas;aRect: TRect;Txt: string;
        IsSelectRow, IsResult:boolean) ;

implementation
uses
    myUtils, NotifyForm, Log , Math, IniFiles, UserTool, KiiMessages, DataUnitHelper,
    ToExcelUnit, CellFormats4, SysEnv , LangTran;

type
TUsrThread = class(TThread)
private
    mItem : TRetrieve ;
    mFileName : string ;
protected
    procedure Execute() ; override ;
    procedure UpdateScreen() ;
public
    constructor Create(AItem : TRetrieve) ;
    destructor  Destroy ; override ;
end ;

TUsrToExcel = class(TThread)
private
    mThXls : TToExcel ;
    mThIDx, mThRow : integer ;

    mThItem : TRetrieve ;
    mThFileName : string ;

protected
    procedure Execute() ; override ;
    procedure UpdateScreen() ;
public
    constructor Create(AItem : TRetrieve; AFile: string) ;
    destructor  Destroy ; override ;
end ;
//------------------------------------------------------------------------------
//
//------------------------------------------------------------------------------
procedure DrawVsDatas(ACanvas:TCanvas; ARect:TRect; Txt: string) ;
var
    i, nH, nL, nT, nW : integer ;
    nR : TRect ;
    Tmp : string ;
begin
    //
    nT := ARect.Top + 2 ;
    nL := ARect.Left + 2 ;
    nH := (ARect.Bottom - ARect.Top) -4 ;
    ACanvas.Font.Height := Trunc(nH * 0.7) ;
    nW := ACanvas.TextWidth('12') ;

    SetTextAlign(ACanvas.Handle, TA_CENTER or TA_TOP);
    nR.Left := nL ;
    nR.Top  := nT ;
    nR.Bottom := nT + nH ;
    nR.Right  := nL + nW ;

    ACanvas.Brush.Color := JUDGE_COLOR[false] ;
    ACanvas.Pen.Color := clBlack ;
    ACanvas.Pen.Width := 1 ;
    ACanvas.MoveTo(nL, nT) ;
    ACanvas.LineTo(nL, nT + nH) ;

    Tmp := '' ;
    for i := 1 to Length(Txt) do
    begin
        if (Tmp <> '') and (Txt[i] = ',') then
        begin
            nR.Left  := nL + 1 ;
            nR.Right := nR.Left + nW ;
            ACanvas.FillRect(nR);

            ACanvas.Font.Color := clWhite ;
            ACanvas.TextOut(nR.Left + nW div 2,
                            nT + (nH div 2) - (ACanvas.TextHeight('H') div 2),
                            Tmp) ;

            nL := nL + nW + 1 ;
            ACanvas.MoveTo(nL, nT) ;
            ACanvas.LineTo(nL, nT+nH) ;
            Tmp := ''
        end
        else
        if (Txt[i] <> ',') then Tmp := Tmp + Txt[i] ;
    end ;
    ACanvas.MoveTo(ARect.Left + 2, nT) ;
    ACanvas.LineTo(nL,             nT) ;
    ACanvas.MoveTo(ARect.Left + 2, nT + nH) ;
    ACanvas.LineTo(nL+1,           nT + nH) ;
end ;

procedure CheckColorAndDisplay(aCanvas:TCanvas;
                               aRect: TRect;
                               Txt: string;
                               IsSelectRow, IsResult:boolean) ;
begin
    if Txt = '' then Exit ;
    with aCanvas do
    begin
        if Txt[1] = NG_TAG then
        begin
            if not IsSelectRow then
            begin
                if IsResult then
                begin
                    Font.Color := clWhite ;
                    Brush.Color:= JUDGE_COLOR[false] ;
                end
                else
                begin
                    Font.Color := JUDGE_COLOR[false] ;
                    //Font.Style := [fsbold];
                    if Brush.Color <> USR_COLOR then
                    begin
                        Brush.Color:= clWhite ;
                    end;
                end ;
            end ;
            Delete(Txt, 1, 1) ;
        end
        else
//      if Txt = 'OK'{_TAG} then    //--SJD
        if Txt[1] = OK_TAG then    //--SJD
        begin
            if not IsSelectRow then
            begin
                if IsResult then
                begin
        ///         Font.Color := JUDGE_COLOR[true] ;

                    Font.Color := clWhite ;
                    Brush.Color := JUDGE_COLOR[true] ;
                end
                else
                begin
                    Font.Color := JUDGE_COLOR[true] ;
                    if Brush.Color <> USR_COLOR then
                    begin
                        Brush.Color:= clWhite ;
                    end;
                end ;
            end ;
            Delete(Txt, 1, 1) ;
        end
        else
        if not IsSelectRow then
        begin
            Font.Color := clBlack ;
            if Brush.Color <> USR_COLOR then
            begin
                Brush.Color:= clWhite ;
            end ;
        end ;
        FillRect(aRect);
    end ;
    if Pos(',', Txt) > 0 then
    begin
        DrawVsDatas(ACanvas, ARect, Txt) ;
        Exit ;
    end ;
    TextOutCenter(aCanvas,
                  (aRect.Left + aRect.Right) div 2,
                  (aRect.Top  + aRect.Bottom) div 2,
                  Txt);

end ;

//------------------------------------------------------------------------------
// TRetrieve
//------------------------------------------------------------------------------
constructor TRetrieve.Create(AGrid: TStringGrid; AGridHead:TGridTitle;
    ADataBox:TBaseDataBox; ASPC:TXbarEx; AName: string; ItemCount,
    BufSize, ATag: integer) ;
begin

    inherited Create(ItemCount, BufSize) ;


    mTmpsize := Bufsize ;
    SetLength(mTmpBuf, mTmpsize) ;
    mName  := AName ;
    mTmpCreate := true ;
    mTag   := ATag ;
    mBox   := ADataBox;// as TBaseDataBox ;
    mGrid  := AGrid ;
    if Assigned(mGrid) then
    begin
        mGrid.Tag := 0 ;
        mSelGrid := TSelGridItem.Create(mGrid) ;
        with mGrid do
        begin
            OnDrawCell := DrawCell ;
            Rowcount := 2 ;
        end ;
    end ;


    LoadColInfo ;
    mGridHead := AGridHead ;
    mBreak := false ;
    mSPC   := ASPC ;

    Initial ;

end ;

destructor  TRetrieve.Destroy;
begin
    SaveColInfo ;
    if FileExists(mfName)
        and (ExtractFileExt(mfName)= '.$$$') then DeleteFile(mfName) ;
    try
        if Assigned(mGridHead) then FreeAndNil(mGridHead) ;
        if Assigned(mfList) then FreeAndNil(mfList) ;
        if Assigned(mBox) then FreeAndNil(mBox) ;
        if Assigned(mSelGrid) then FreeAndNil(mSelGrid) ;
    finally
        mGridHead := nil ;
        mfList := nil ;
        mBox := nil ;
        mSelGrid := nil ;
    end ;
    inherited Destroy ;
    if Assigned(mSPC) then FreeAndNil(mSPC) ;
    if Length(mGridORD)> 0 then SetLength(mGridORD, 0) ;
    if Length(mTmpBuf) > 0 then SetLength(mTmpBuf, 0) ;
end ;

procedure TRetrieve.Initial ;
var
    i : integer ;
begin

    inherited Initial ;
    if (mfName <> '')
        and (ExtractFileExt(mfName)= '.$$$') then DeleteFile(mfName);

    mOK := 0 ;
    mNG := 0 ;


    mBox.InitData ;

    mBegin  := Trunc(Now) + Frac(gsysEnv.rWorkTime) ;
    mEnd    := mBegin - EncodeTime(1, 0, 0, 0) ;

    if Assigned(mSPC) then mSPC.Initial ;

    if Assigned(mGrid) then
    begin
        if Assigned(mSelGrid) then
        begin
            mSelGrid.Unselect ;
            mSelGrid.Enabled := false ;
        end ;

        with mGrid do
        begin
            for i := 1 to RowCount-1 do Rows[i].Clear ;
            RowCount := 2 ;

            Repaint ;
            Update ;
        end ;
    end ;
    mBreak := false ;
end ;

procedure TRetrieve.SetDates(aIndex: integer; aDate: TDate) ;
begin
    if aIndex = 0 then mBegin := Trunc(aDate)+Frac(mBegin)
    else               mEnd   := Trunc(aDate)+Frac(mEnd) ;
end ;

procedure TRetrieve.SetTimes(aIndex: integer; aTime: TTime) ;
begin
    if aIndex = 0 then mBegin := Trunc(mBegin) + Frac(aTime)
    else               mEnd   := Trunc(mEnd) + Frac(aTime) ;
end ;

function  TRetrieve.DeleteDatas: integer ;
var
    i, Cnt : integer ;
    dPos: array of integer ;
begin
    Result := 0 ;
    if not Assigned(mGrid) then Exit ;
    with mGrid do
    begin
        Cnt := (Selection.Bottom - Selection.Top)+1 ;
        if Cnt <= 0 then Exit ;
        SetLength(dPos, Cnt) ;
        for i := Selection.Top to Selection.Bottom do dPos[i] := i ;
    end ;
    Result := Del(dPos, Cnt, mfName) ;
end ;

procedure TRetrieve.SetBreak ;
begin
    mBreak := true ;
end ;

procedure TRetrieve.DrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
var
    asData : string ;
	bTm, bIsSelect : Boolean ;
begin

    if mGridHead.DrawGridHead(mGrid,
                              ACol,
                              ARow,
                              Rect,
                              State) then Exit ;

	with Sender as TStringGrid do
	begin
		Canvas.Font := Font ;
		bIsSelect := false ;
        if (Row = ARow)and(Col = ACol) then
        begin
            bIsSelect := true ;
            Canvas.Font.Color  := clWhite ;
            Canvas.Brush.Color := clNavy ;
        end
        else
        if IsSelected(ARow) then
        begin
            bIsSelect := true ;
            Canvas.Font.Color  := clWhite ;
            Canvas.Brush.Color := clGreen ;
        end
        else
        if (ARow mod 2) = 0 then
        begin
            Canvas.Font.Color  := clBlack ;
            Canvas.Brush.Color := USR_COLOR ;
        end
        else
        begin
            Canvas.Font.Color  := clBlack ;
            Canvas.Brush.Color := Color ;
        end ;

		Canvas.FillRect(Rect) ;
		SetBkMode(Canvas.Handle, TRANSPARENT) ;

        if Length(mGridORD) > 0 then asData := GetAData(ARow, mGridORD[ACol],true)
        else                         asData := Cells[ACol, ARow] ;

        //-- DATA들


        //====
        if Assigned(mUsrDrawCell) then OnUserDrawCell(Sender,ACol, ARow,Rect,State) ;
        //====
        bTm := (Length(mGridORD) > 0) and (mGridORD[ACol] = roNO) ;
        //====
        CheckColorAndDisplay(Canvas, Rect, asData, bIsSelect, bTm);
		SetBkMode(Canvas.Handle, OPAQUE) ;

        if (ARow = Row) and (Tag <> Row) and Assigned(mSpecUpdates) then
        begin
            OnSpecUpdates(Self) ;
            Tag := Row ;
        end ;
    end;
end ;

function  TRetrieve.GetATemp(var aBuf; aPos: integer): boolean ;
var
    fh : integer ;
begin
    Result := false ;

    fh := FileOpen(mfName, fmOpenRead) ;
    if fh < 0 then Exit ;

    try
        FileSeek(fh, (aPos-1)*mTmpsize, 0) ;
        Result := FileRead(fh, aBuf, mTmpsize) = mTmpsize ;
    finally
        FileClose(fh) ;
    end ;
end ;

procedure TRetrieve.GetADataFromTemp(aDatas: TStrings; aReadPos :integer) ;
var
    i : integer ;
begin
    aDatas.Clear ;
    if not Assigned(mGrid) then Exit ;
    for i := 0 to mGrid.ColCount-1 do
    begin
        aDatas.Add(GetAData(aReadPos, mGridORD[i]));//DataGridORD[i])) ;
    end ;
end ;

procedure TRetrieve.SetGridORD(AORD: array of TResultORD) ;
var
    i : integer ;
begin
    SetLength(mGridORD, Length(AORD)) ;
    for i := 0 to Length(AORD)-1 do mGridORD[i] := AORD[i] ;    
end ;

function  TRetrieve.GetResult(var Buf; aPos: integer): boolean ;
begin
    Result := GetATemp(Buf, aPos) ;
end ;

function TRetrieve.GetSelGrid : TObject ;
begin
    Result := mSelGrid ;
end ;

function  TRetrieve.GetASpec(ASpec: TResultORD; IsUnit:boolean): string ;
begin
    Result := mBox.GetResultToATxt(ord(ASpec),false,IsUnit) ;
end ;

function  TRetrieve.GetAData(APos:integer; AData: TResultORD; IsUnit:boolean): string ;
begin
    Result := '' ;
    if (mNG+mOK) <= 0 then Exit;
    if mLstIDx <> APos then
    begin
        if not GetATemp(mTmpBuf[0], APos) then
        begin
            mLstIDx := -1 ;
            Exit ;
        end ;
        mBox.InitData();
        mBox.SetResult(mTmpBuf[0]) ;
        mLstIDx := APos ;
    end ;
    if aData = roIndex then Result := IntToStr(APos)
    else                    Result := mBox.GetResultToATxt(ord(AData),IsUnit,true) ;
end ;

function TRetrieve.FindShow: integer ;
var
    fh, fDate: integer ;
    sTm  : string ;
begin
    Result := 0 ;
    if not Assigned(mGetFileName) then Exit ;
    fDate  := Trunc(mBegin) ;
    try
        while fDate <= Trunc(mEnd) do
        begin
            OnGetFileName(Self, fDate, sTm) ;

            fh := FileOpen(sTm, fmOpenRead or fmShareDenyNone) ;
            if fh < 0 then
            begin
                Inc(fDate, 1) ;
                Continue ;
            end ;
            try
                Inc(Result) ;
            finally
                FileClose(fh) ;
            end ;
            Inc(fDate, 1) ;
        end ;
    finally
    end ;

    if Result > 0 then
    begin
        with frmNotify do
        begin
            Caption := 'In Searching...';//_TR('시험 결과 검색중...') ;
            SetTotalCount(Result) ;
            FormStyle := fsStayOnTop ;
            Show ;
        end ;
    end ;
end ;

function  TRetrieve.FindDatas : integer ;
begin
    Result := 0 ;
    if mTmpCreate and (FindShow <= 0) then Exit ;

    mOk    := 0 ;
    mNG    := 0 ;
    mLstIDx:= -1 ;
    if FileExists(mfName)
        and (ExtractFileExt(mfName)= '.$$$') then DeleteFile(mfName) ;
    if not Assigned(mGetFileName) then Exit ;

    mfName := Format('%s\%s.$$$', [GetUsrDir(udTemp, Now(), true),
                                   FormatDateTime('yyyymmddhhnnss', Now())]) ;

    mTmpHandle := FileCreate(mfName) ;
    if mTmpHandle < 0 then Exit ;
    try
        with TUsrThread.Create(Self) do
        begin
            WaitFor ;
            Free ;
        end ;
    finally
        Result := FileSeek(mTmpHandle, 0, 1) div mTmpSize ;
        FileClose(mTmpHandle) ;
    end ;

    if (Result <= 0) or not mTmpCreate then
    begin
        if (ExtractFileExt(mfName)= '.$$$') then DeleteFile(mfName) ;
    end
    else
    begin
        if Assigned(mGrid) then
            mGrid.RowCount := Result + 1 ;
        if Assigned(mSPC) then mSPC.SetDataFile(mfName)  ;
        if Assigned(mSelGrid) then mSelGrid.Enabled := true ;
        //Sorting....
        if Assigned(mSortEvent) then OnSort(Self) ;
    end ;
    SendMessage(frmNotify.Handle, WM_CLOSE, 0, 0) ;
end ;

function  GetIndexFileName(aName:string; aIndex:integer): string ;
var
    i : integer ;
begin
    Result := aName ;
    for i := Length(aName) downto 1 do
    begin
        if aName[i] = '.' then
        begin
            Result := Copy(aName, 1, i-1) ;
            Result := Format('%s%2.2d%s', [Result, aIndex, ExtractFileExt(aName)]) ;
        end ;
    end ;
end ;

function  TRetrieve.ListToExcel(AExcel: string; List:array of WORD;
                ACount:integer): boolean ;
var
    i : integer ;
begin
    Result := false ;
    if ACount <= 0 then Exit ;

    if Length(mTmpAry) > 0 then SetLength(mTmpAry, 0) ;
    for i := 0 to ACount-1 do
    begin
        SetLength(mTmpAry, Length(mTmpAry)+1) ;
        mTmpAry[i] := List[i] ;
    end ;
    try
        with TUsrToExcel.Create(Self, AExcel) do
        begin
            WaitFor ;
            Free ;
        end ;
    finally
        if Length(mTmpAry) > 0 then SetLength(mTmpAry, 0) ;
    end ;
    SendMessage(frmNotify.Handle, WM_CLOSE, 0, 0) ;
    Result := true ;
end ;
{
function  TRetrieve.ListToExcel(AExcel: string; List:array of WORD;
                ACount:integer): boolean ;
var
    i, j, x, Cnt, iDx, ARow : integer ;
    nTmp : string ;
    nX : TToExcel ;
begin
    Result := true ;
    Cnt  := 0 ;
    iDx  := 0 ;
    ARow := 0 ;
    if Length(mTmpAry) > 0 then SetLength(mTmpAry, 0) ;
    nX := TToExcel.Create(AExcel);
    try
        for i := 0 to ACount -1 do
        begin
            //----------------------
            Application.ProcessMessages ;
            //----------------------
            SetLength(mTmpAry, Length(mTmpAry)+1) ;
            mTmpAry[Length(mTmpAry)-1] := List[i] ;
            Inc(Cnt) ;
            if (Cnt > 65000) or (ACount = (i+1)) then
            begin
                if iDx > 0 then ARow := 0 ;
                try
                    try
                        if iDx > 0 then nX.AddSheet('Data'+IntToStr(iDx+1))
                        else            nX.SetSheet(iDx,'Data'+IntToStr(iDx+1));

                        if Assigned(mListToExcelBefore) then
                        begin
                            OnListToExcelBefore(nX, ARow) ;
                        end ;

                        for j := 0 to Length(mTmpAry)-1 do
                        begin
                            //----------------------
                            Application.ProcessMessages ;
                            //----------------------
                            for x := 0 to mGrid.ColCount-1 do
                            begin
                                OnXMlRead(Self, x, j+1, nTmp);
                                nX.Font.Color := clBlack ;
                                nX.CellStyle.rAlignment := chaCenter ;
                                if (nTmp <> '')
                                    and ((nTmp[1] = OK_TAG)
                                         or(nTmp[1] = NG_TAG)) then
                                begin
                                    if nTmp[1]=NG_TAG then
                                        nX.Font.Color := clRed ;

                                    Delete(nTmp, 1, 1) ;
                                end ;

                                if (nTmp = '--')or(nTmp = '') then
                                begin
                                    nX.SetData(x, ARow, '') ;
                                end
                                else
                                begin
                                    nX.SetData(x, ARow, nTmp);
                                end ;
                                nX.Box(x, ARow, x, ARow);
                            end ;
                            Inc(ARow) ;
                        end ;
                    except
                        Result := false ;
                        Break ;
                    end ;
                    if Result and (ACount = (i+1))then
                    begin
                        if Assigned(mListToExcelAfter) then
                            OnListToExcelAfter(nX, ARow) ;
                        nX.EndOfDatas ;
                    end ;
                finally
                    if Length(mTmpAry) > 0 then SetLength(mTmpAry, 0) ;
                end ;
                Cnt := 0 ;
                Inc(iDx) ;
            end ;
        end ;
    finally
        if Assigned(nX) then FreeAndNil(nX) ;
        if Length(mTmpAry) > 0 then SetLength(mTmpAry, 0) ;
    end ;
end ;
}
function  TRetrieve.ListToExcel(AExcel: string): boolean ;
var
    i   : integer ;
    List: array of WORD;
begin
    SetLength(List, mOK+mNG) ;
    for i := 1 to mOK+mNG do List[i-1] := i ;
    Result := ListToExcel(AExcel, List, mOK+mNG) ;
    if Length(List) > 0 then SetLength(List, 0) ;
end;

procedure TRetrieve.LoadColInfo ;
var
    Ini : TIniFile ;
    i : integer ;
begin
    if not Assigned(mGrid) then Exit ;
    Ini := TIniFile.Create(GetIniFiles) ;
    try
        for i := 0 to mGrid.ColCount-1 do
            mGrid.ColWidths[i] := Ini.ReadInteger(Format('%s_%d', [mName, mTag]),
                                                  Format('%d_COL_WIDTH_%d', [mTag, i]),
                                                  mGrid.DefaultColWidth) ;
    finally
        Ini.Free ;
    end ;
end ;

procedure TRetrieve.SaveColInfo ;
var
    Ini : TIniFile ;
    i : integer ;
begin
    if not Assigned(mGrid) then Exit ;
    Ini := TIniFile.Create(GetIniFiles) ;
    try
        for i := 0 to mGrid.ColCount-1 do
            Ini.WriteInteger(Format('%s_%d', [mName, mTag]),
                             Format('%d_COL_WIDTH_%d', [mTag, i]),
                             mGrid.ColWidths[i]) ;
    finally
        Ini.Free ;
    end ;
end ;

procedure TRetrieve.OnXMlRead(Sender: TObject; ACol, ARow: integer;
  var AData: string);
    function IsSpecRO(RO: TResultOrd): Boolean;
    begin
        Result := Pos('spec',  GetResultOrdName(RO)) > 0;
    end;
begin
    //if Length(mGridORD) > 0 then GetAData(mTmpAry[ARow-1], mGridORD[0]);
    if (ACol = 0) and (mGridORD[ACol]=roIndex) then AData := IntToStr(ARow)
    else
    if Length(mGridORD) > 0 then
    begin
        if mLstIDx <> mTmpAry[ARow-1] then
        begin
            GetAData(mTmpAry[ARow-1], mGridORD[0]);
        end ;
        AData := mBox.GetResultToATxt(ord(mGridORD[ACol]), IsSpecRO(mGridORD[ACol]), true) ;
        if (AData <> '')
            and (AData[Length(AData)] = ',') then
        begin
            Delete(AData, Length(AData), 1) ;
        end ;
    end
    else
    begin
        AData := mGrid.Rows[mTmpAry[ARow-1]].Strings[ACol] ;
    end ;
end;

function TRetrieve.SetReadData(Sender: Tobject): boolean ;
var
    nP, nR  : boolean ;
begin
    Result := true ;
    OnSearchDatas(Self, mTmpBuf[0], nP, nR) ;
    if nP then Exit ;
    // OK count, NG count
    if nR then Inc(mOK)
    else       Inc(mNG) ;
    if mTmpCreate and (mTmpHandle > 32) then
    begin
        if FileWrite(mTmpHandle, mTmpBuf[0], mTmpsize) <> mTmpsize then
        begin
            Result := false ;
        end ;
    end ;
end;

function TRetrieve.GetUsrFileName(ATime: double): string;
begin
    Result := '' ;
    if not Assigned(mGetFileName) then Exit ;
    OnGetFileName(Self, ATime, Result) ;
end;

function TRetrieve.IsSelected(Index: integer): boolean;
begin
    Result := Assigned(mSelGrid)
                and (mSelGrid.Count > 0)
                and mSelGrid.IsSelected(Index) ;
end;
//------------------------------------------------------------------------------
// TUsrRetrieve
//------------------------------------------------------------------------------
constructor TUsrRetrieve.Create(AGrid: TStringGrid; AGridHead:TGridTitle;
        ADataBox:TBaseDataBox; ASPC:TXbarEx; AName: string; ItemCount,
        BufSize, ATag: integer) ;
begin
    inherited Create(AGrid,
                     AGridHead,
                     ADataBox,
                     ASPC,
                     AName,
                     ItemCount,
                     BufSize,
                     ATag) ;
end ;

destructor  TUsrRetrieve.Destroy;
begin
    mfName := '' ;
    inherited Destroy ;
end ;

procedure TUsrRetrieve.SetFile(aName: string) ;
var
    nC : integer ;
begin
    if mfName <> aName then
    begin
        mfName := '' ;
        Initial ;
    end ;

    if not Assigned(mGrid) then Exit ;
    if FileExists(aName) then
    begin
        mfName := aName ;
        nC := GetFileSize(aName) div sizeof(TResult) ;

        mOk:= nC ;
        mGrid.RowCount := nC + 1 ;
        mGrid.Repaint ;
    end ;
end ;
//------------------------------------------------------------------------------
{ TUsrThread }
//------------------------------------------------------------------------------
constructor TUsrThread.Create(AItem : TRetrieve) ;
begin
    FreeOnTerminate := false ;
    inherited Create(false) ;
    Priority := tpLowest ;

    mItem := AItem ;
end;

destructor TUsrThread.Destroy;
begin

  inherited Destroy ;
end;

procedure TUsrThread.Execute;
var
    fDate: TDateTime ;
begin
    fDate := Trunc(mItem.mBegin) ;
    while fDate <= Trunc(mItem.mEnd) do
    begin
        if mItem.mBreak then Break ;

        mFileName := mItem.GetUsrFileName(fDate) ;
        frmNotify.SetStates(ExtractFileName(mFileName));

        if not FileExists(mFileName) then
        begin
            fDate := fDate + 1 ;
            Continue ;
        end ;
        //=====
        Synchronize(UpdateScreen);
        //=====
        fDate := fDate + 1 ;
        SendToForm(frmNotify.Handle, SYS_UPDATES, 0);
    end ;
end;

procedure TUsrThread.UpdateScreen() ;
var
    fh  : integer ;
begin
    fh := FileOpen(mFileName, fmOpenRead or fmShareDenyNone) ;
    try
        with frmNotify do SetFrm(_TR('데이터 검색 중...'));

        FileSeek(fh, 0, 0) ;
        while FileRead(fh, mItem.mTmpBuf[0], mItem.mTmpsize) = mItem.mTmpsize do
        begin
            if mItem.mTmpBuf[0] = 0 then Continue;
            if not mItem.SetReadData(Self) then
            begin
                gLog.ToFiles('파일 write 오류: %s',[mItem.TmpFile]);
            end ;
        end ;
    finally
        FileClose(fh) ;
    end ;
end;

{ TUsrToExcel }

constructor TUsrToExcel.Create(AItem : TRetrieve; AFile: string) ;
begin
    FreeOnTerminate := false ;
    inherited Create(false) ;
    Priority := tpLowest ;

    mThFileName := AFile ;
    mThItem := AItem ;
end;

destructor TUsrToExcel.Destroy;
begin
  inherited;
end;

procedure TUsrToExcel.Execute;
var
    i : integer ;
begin
  inherited;
    frmNotify.SetTotalCount(Length(mThItem.mTmpAry));
    frmNotify.SetStates(ExtractFileName(mThFileName));

    mThRow := 0 ;
    mThXls := TToExcel.Create(mThFileName) ;
    try
        mThXls.SetSheet(0,'Data');
        with mThItem do
        begin
            if Assigned(mListToExcelBefore) then
            begin
                OnListToExcelBefore(mThXls, mThRow) ;
            end ;

            for i := 0 to Length(mTmpAry)-1 do
            begin
                mThiDx := i ;
                Synchronize(UpdateScreen);
                Inc(mThRow) ;

                SendToForm(frmNotify.Handle, SYS_UPDATES, 0);
            end ;
            if Assigned(mListToExcelAfter) then OnListToExcelAfter(mThXls, mThRow) ;
            mThXls.EndOfDatas ;
        end ;
    finally
        FreeAndNil(mThXls) ;
    end ;
end;

procedure TUsrToExcel.UpdateScreen;
var
    iDx : integer ;
    sTm : string ;

    function IsDataRO(RO: TResultOrd): Boolean;
    begin
        Result := (Pos('roDat',  GetResultOrdName(RO)) > 0) or (Pos('roDev',  GetResultOrdName(RO)) > 0)
    end;

begin
    with mThItem do
    begin
        for iDx := 0 to mGrid.ColCount-1 do
        begin
            OnXMlRead(Self, iDx, mThiDx+1, sTm);
            mThXls.Font.Color := clBlack ;
            mThXls.CellStyle.rAlignment := chaCenter ;
            if (sTm <> '')
                and ((sTm[1] = OK_TAG)
                     or(sTm[1] = NG_TAG)) then
            begin
                if sTm[1]=NG_TAG then
                    mThXls.Font.Color := clRed ;

                Delete(sTm, 1, 1) ;
            end ;

            if (sTm = '--')or(sTm = '') then
            begin
                mThXls.SetData(iDx, mThRow, '') ;
            end
            else
            if mGridORD[iDx] In [roIndex] then
            begin
                mThXls.SetData(iDx, mThRow, StrToIntDef(sTm, 0)) ;
            end
            else
            if IsDataRO(mGridORD[iDx]) then
            begin
                mThXls.SetData(iDx, mThRow, StrToFloatDef(sTm, 0.0)) ;
            end
            else
            begin
                mThXls.SetWideString(iDx, mThRow, sTm);
            end ;
            mThXls.Box(iDx, mThRow, iDx, mThRow);
        end ;
    end ;
end;

end.