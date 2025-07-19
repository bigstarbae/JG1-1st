unit ErCodeListForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, KiiMessages, LanIoUnit, ExtCtrls, StdCtrls, Buttons,
  ErSaveUnit ;

type
  TfrmErCodeList = class(TForm)
    sgrdList: TStringGrid;
    OpenDlg: TOpenDialog;
    ioTimer: TTimer;
    Panel2: TPanel;
    Label8: TLabel;
    Shape10: TShape;
    Shape11: TShape;
    SpeedButton1: TSpeedButton;
    SpeedButton3: TSpeedButton;
    Label2: TLabel;
    cbbTestList: TComboBox;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure sgrdListDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure ioTimerTimer(Sender: TObject);
    procedure sgrdListSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure sgrdListSetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: String);
    procedure cbbTestListChange(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
  private
    { Private declarations }
    mrIoBuf,
    mIobuf : array[0..31]of BYTE ;
    mLock : boolean ;

    mBeginCH, mIoCount, mErIndex : integer ;

    procedure LoadList(aStation : TErStationORD) ;
    procedure SaveList ;
    procedure LoadFromFile ;
    procedure ReadIO(aInit: boolean=false);
  public
    { Public declarations }
  end;

var
  frmErCodeList: TfrmErCodeList;

implementation
uses
    DataUnit, myUtils , LangTran;

{$R *.dfm}

procedure TfrmErCodeList.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
    Action := caFree ;
end;

procedure TfrmErCodeList.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
    ioTimer.Enabled := false ;
    SaveGridColwidths(sgrdList, 'ER_CODE_LIST');
end;

procedure TfrmErCodeList.FormCreate(Sender: TObject);
var
    i : integer ;
begin
    cbbTestList.Clear ;
    for i := 0 to ord(High(TErStationORD)) do
    begin
        cbbTestList.Items.Add(GetErStationName(GetIndexToStation(i))+_TR(' 공정')) ;
    end ;

    cbbTestList.ItemIndex := 0 ;
end;

procedure TfrmErCodeList.FormDestroy(Sender: TObject);
begin
//
end;

procedure TfrmErCodeList.FormShow(Sender: TObject);
begin
    FillChar(mioBuf, sizeof(mioBuf), 0) ;
    FillChar(mrioBuf, sizeof(mrioBuf), 0) ;
    //ReadIO(true) ;

    with sgrdList do
    begin
        Row := 1 ;
        Col := 3 ;
    end ;

    LoadGridColwidths(sgrdList, 'ER_CODE_LIST');

    sgrdList.Align := alClient ;
    LoadList(Low(TErStationORD)) ;
    ReadIO(true) ;
    
    ioTimer.Enabled := true ;
	ChangeCaption(self);
end;

procedure TfrmErCodeList.LoadFromFile;
var
    fh : integer ;
begin
    Screen.Cursor := crHourGlass ;
    with openDlg do
    begin
        if InitialDir = '' then InitialDir := GetHomeDirectory ;
        Filter := 'xls File(*.xls)|*.xls' ;

        if not Execute then
        begin
            SetCurrentDir(GetHomeDirectory);
            Screen.Cursor := crDefault ;
            Exit ;
        end ;

        fh := FileOpen(FileName, fmOpenRead) ;
        if fh <= 32 then
        begin
            with Application do
                MessageBox(PChar(FileName+_TR(' 파일을 열 수 없습니다.')),
                           'Error Code',
                           MB_ICONSTOP+MB_OK);

            SetCurrentDir(GetHomeDirectory);
            Screen.Cursor := crDefault ;
            Exit ;
        end ;

        try
        finally
            FileClose(fh) ;
        end ;

        LoadXLSFile(FileName) ;
        with Application do
            MessageBox(PChar(_TR('프로그램을 종료후 다시 실행시켜주십시요.')),
                       'Error Code',
                       MB_ICONINFORMATION+MB_OK);
    end ;
    SetCurrentDir(GetHomeDirectory);
    Screen.Cursor := crDefault ;
end;

procedure TfrmErCodeList.LoadList(aStation : TErStationORD);
var
    i : integer ;
    Buf : TMcErCodes ;
begin
    with gDio.GetItem(ord(devERROR)) as TUserMonitor do
    begin
        mBeginCH := BeginCH ;
    end;
    mErIndex := GetStataionToPlcErIndexBegin(aStation) ;
    mBeginCh := mBeginCh+mErIndex ;
    mIoCount := GetStataionToPlcErIndexCount(aStation) ;

    if mErIndex = 0 then mErIndex := 1 ;
    with sgrdList do
    begin
        RowCount := mIoCount + 1 ;
        Cells[0, 0] := 'NO' ;
        Cells[1, 0] := 'STATUS' ;
        Cells[2, 0] := 'CODE' ;
        Cells[3, 0] := 'ERROR' ;
        Cells[4, 0] := _TR('분류코드') ;

        for i := 1 to RowCount-1 do Rows[i].Clear ;

        for i := 1 to RowCount-1 do
        begin
            Cells[0, i] := IntToStr(i) ;
            Cells[1, i] := '0';
            LoadPlcError(mErIndex + i-1, Buf) ;
            Cells[2, i] := Buf.rErCode ;
            Cells[3, i] := Buf.rErTxt ;
            Cells[4, i] := Buf.rProperty ;
        end ;
    end ;
end;

procedure TfrmErCodeList.SaveList ;
var
    i : integer ;
begin
    with sgrdList do
    begin
        for i := 1 to RowCount-1 do
        begin
            SavePlcError(mErIndex + i-1,
                           Cells[2, i],
                           Cells[3, i],
                           Cells[4, i]);
        end ;
    end ;
end;

procedure TfrmErCodeList.sgrdListDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
var
    x, y : integer;
    s : string;
begin
    sgrdList.Canvas.Font.Size  := Font.Size;
    sgrdList.Canvas.Font.Name  := Font.Name;
    sgrdList.Canvas.Font.Color := clBlack;

    y := Rect.Top  + (Rect.Bottom - Rect.Top) div 4;
    x := Rect.Left + (Rect.Right - Rect.Left) div 2 ;

    with sgrdList do
    begin
        s := Cells[ACol, ARow];

        Canvas.Brush.Color := Color;
        Canvas.Pen.Color := Color;

        if (s <> '') and (BYTE(s[1]) In[ord('0'),ord('1')]) and (ACol = 1) then
        begin
            Delete(s, 1, 1) ;
        end;

        if (ACol <> 1) or (ARow = 0) then
        begin
            SetBkMode(Canvas.Handle, TRANSPARENT) ;
            if (ARow = Row)and (ACol In[3])and (ACol=Col) then
            begin
                Canvas.Brush.Color := clHighlight ;
                Canvas.Font.Color  := clWhite ;
            end
            else
            if (ARow = 0) then
            begin
                Canvas.Brush.Color := clBtnFace ;
            end ;

            SetTextAlign(Canvas.Handle, TA_CENTER);
            Canvas.TextRect(Rect,
                            Rect.Left + ((Rect.Right-Rect.Left)div 2),
                            y, s);
            Exit ;
        end ;
        SetTextAlign(Canvas.Handle, TA_LEFT);
        Canvas.TextRect(Rect, Rect.Left + 30, y, s);
        if Cells[ACol, ARow] = '' then Exit ;

        Canvas.Pen.Color := clBlack;
        if Cells[ACol, ARow] = '1' then
        begin
            Canvas.Brush.Color := clRed ;
        end
        else
        begin
            Canvas.Brush.Color := clGray;
        end;

        Rect.Left   := x - 6;
        Rect.Top    := y - 3;
        Rect.Right  := x + 6;
        Rect.Bottom := y + 12;
        Frame3D(Canvas, Rect, clWhite, clGray, 1);
        Canvas.RectAngle(x - 5, y - 2, x + 5, y + 11);

        Canvas.Brush.Color := Color;
        Canvas.Pen.Color := Color;
    end;
end;

procedure TfrmErCodeList.ioTimerTimer(Sender: TObject);
begin
    if mLock then Exit ;
    mLock := true ;

    if Assigned(gDio) then ReadIO ;

    mLock := false ;
end;

procedure TfrmErCodeList.ReadIO(aInit: boolean);
var
    i, j, rowIDx : integer ;
    beginBufIdx : integer ;

    ch : integer ;
begin
    beginBufIdx := (mBeginCh div 8) ;
    for i := 0 to Length(mrIoBuf)-1 do
    begin
        mrIoBuf[i] := gDio.GetBuffer(beginBufIdx+i) ;
    end ;

    rowIDx := 1 ;
    ch := beginBufIdx * 8 ;
    for i := 0 to Length(mrIoBuf)-1 do
    begin
        for j := 0 to 7 do
        begin
            if (ch >= mBeginCH) and (ch < mBeginCH+mIoCount) then
            begin
                if ((mrIobuf[i] shr j) and $01) <>  ((mIoBuf[i] shr j) and $01)  then
                begin
                    if Longbool((mrIobuf[i] shr j) and $01) then sgrdList.Cells[1, rowIDx] := '1'
                    else                                         sgrdList.Cells[1, rowIDx] := '0' ;
                end;
                Inc(rowIDx) ;
            end
            else
                if (ch >= mBeginCH+mIoCount) then break ;
            Inc(ch) ;
        end;
        mIoBuf[i] := mrIoBuf[i] ;
    end;
end;

procedure TfrmErCodeList.sgrdListSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
    CanSelect := (ARow > 0) and (ACol <> 1) ;
    {
    case ACol of
        1 : gDio.SetIO(mBeginCH + ARow-1, not gDio.IsIO(mBeginCH + ARow-1)) ;
    end ;
    }
    with Sender as TStringGrid do Repaint ;
end;

procedure TfrmErCodeList.sgrdListSetEditText(Sender: TObject; ACol,
  ARow: Integer; const Value: String);
begin
    //if (ARow < 1) or (ACol < 2) then Exit ;
end;

procedure TfrmErCodeList.SpeedButton1Click(Sender: TObject);
begin
    LoadFromFile ;
    LoadList(GetIndexToStation(cbbTestList.ItemIndex));
end;

procedure TfrmErCodeList.SpeedButton3Click(Sender: TObject);
begin
    SaveList ;
end;

procedure TfrmErCodeList.cbbTestListChange(Sender: TObject);
begin
    LoadList(GetIndexToStation(cbbTestList.ItemIndex));
end;

procedure TfrmErCodeList.Label1Click(Sender: TObject);
begin
    //ShowMessage(Format('%d', [sizeof(TMcErCodes)])) ;
end;

end.
