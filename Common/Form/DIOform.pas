unit DioForm;
{$INCLUDE myDefine.inc}

interface

uses
    Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
    StdCtrls, Buttons, Grids, ComCtrls, ExtCtrls, BaseDIO, ReferBaseForm;

type

    TFormType = (ftDIO, ftLIO);

    TWordDataReadFunc = function(WdIdx: integer): WORD of Object;

    TDIODesc = packed record
        mDIO: TBaseDIO;
        mType: integer;
        mBeginRCh, mBeginWCh, mChCount: integer;
    end;

    TDIOType = (dtDI, dtDO);
    TDIOFormBkArea = packed record
        mType: TDIOType;
        mBeginCh, mChCount: integer;
        mColor: TColor;

        function IsIn(Ch: integer): boolean;
        function GetColorByCh(Ch: integer; DefColor: TColor): TColor;
    end;

    TDIODescArray = array of TDIODesc;

    TfrmDio = class(TfrmReferBase)
        ioTimer: TTimer;
        openDlg: TOpenDialog;
        Panel2: TPanel;
        Label8: TLabel;
        Shape10: TShape;
        Shape11: TShape;
        sbtnPaste: TSpeedButton;
        sbtnSave: TSpeedButton;
        Panel1: TPanel;
        sgrdIO: TStringGrid;
        labTime: TLabel;
        cbxStation: TComboBox;
        procedure FormClose(Sender: TObject; var Action: TCloseAction);
        procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
        procedure FormCreate(Sender: TObject);
        procedure FormDestroy(Sender: TObject);
        procedure FormShow(Sender: TObject);
        procedure sgrdIOSelectCell(Sender: TObject; ACol, ARow: integer; var CanSelect: boolean);
        procedure ioTimerTimer(Sender: TObject);
        procedure sgrdIODrawCell(Sender: TObject; ACol, ARow: integer; Rect: TRect; State: TGridDrawState);
        procedure sgrdIOSetEditText(Sender: TObject; ACol, ARow: integer; const Value: String);
        procedure sbtnSaveClick(Sender: TObject);
        procedure Label8DblClick(Sender: TObject);
        procedure FormResize(Sender: TObject);
        procedure Panel2Resize(Sender: TObject);
        procedure sbtnPasteClick(Sender: TObject);
        procedure cbxStationChange(Sender: TObject);
        procedure sgrdIOKeyDown(Sender: TObject; var Key: WORD; Shift: TShiftState);
    private
        { Private declarations }
        mFormType: TFormType;
        mBeginRCh, mBeginWCh, mHalfChCount: integer;

        mIobuf: array of BYTE;
        mrIoWORD: array [0 .. 9] of WORD;
        mDIO: TBaseDIO;

        mDIODescs: TDIODescArray;
        mBkAreas: array [TDIOType] of TDIOFormBkArea;

        mWDataReadFunc: TWordDataReadFunc;

        procedure ReadIO(aInit: boolean = false);
        procedure LoadGridWidths;
        procedure SaveGridWidths;
        procedure LoadFormFile;
        procedure LoadIoTxt(AGrid: TStringGrid; SectionSuffix: string);
        procedure SetGridNums;
    public
        { Public declarations }
        constructor Create(AOwner: TComponent; FormType: TFormType = ftDIO);

        procedure AddDIO(DIO: TBaseDIO; BeginRCh, BeginWCh, ChCount: integer; StationName: string = '');

        procedure SetFrm(DIO: TBaseDIO; Index, FirstCh, ChCount: integer) ;     // 기존 호환 함수
        procedure SetBkArea(DIOType: TDIOType; BeginCh, ChCount: integer; Color: TColor);

        property WDataReadFunc: TWordDataReadFunc read mWDataReadFunc write mWDataReadFunc;
    end;

procedure SaveIoTxt(AGrid: TStringGrid; SectionSuffix: string);

var
    frmDio: TfrmDio;

implementation

uses
    IniFiles, myUtils, ToExcelUnit, DataUnit, Clipbrd;

var
    lpioTimerLock: boolean = false;

const
    _DRAW_IN = 1;
    _DRAW_OUT = 5;
    _DRAW_WORD = 9;

    _DEST_COL: array [0 .. 1] of integer = (_DRAW_IN, _DRAW_OUT);
{$R *.dfm}

function MakeSectionSuffix(Idx, SubIdx: integer): string;
begin
    if SubIdx < 0 then
        Result := IntToStr(Idx)
    else
        Result := Format('%d-%d', [Idx, SubIdx]);
end;

constructor TfrmDio.Create(AOwner: TComponent; FormType: TFormType);
begin
    inherited Create(AOwner);
    mFormType := FormType;

    mBkAreas[dtDI].mChCount := 0;
    mBkAreas[dtDO].mChCount := 0;
end;

procedure TfrmDio.LoadIoTxt(AGrid: TStringGrid; SectionSuffix: string);
var
    i: integer;
    sTm: string;
    Ini: TIniFile;
begin
    sTm := Format('%s\IoList.Ini', [GetUsrDir(udENV, Now())]);
    Ini := TIniFile.Create(sTm);
    try
        for i := 1 to AGrid.RowCount - 1 do
        begin
            AGrid.Cells[3, i] := Ini.ReadString('PCIN_IO' + SectionSuffix, 'INDEX ' + IntToStr(i), ''); // + ' ' + mDIO.GetChTypeStr(i - 1);
            AGrid.Cells[2, i] := Ini.ReadString('PCIN_IO' + SectionSuffix, 'ADDRESS ' + IntToStr(i), '');
            AGrid.Cells[7, i] := Ini.ReadString('PCOUT_IO' + SectionSuffix, 'INDEX ' + IntToStr(i), '');
            AGrid.Cells[6, i] := Ini.ReadString('PCOUT_IO' + SectionSuffix, 'ADDRESS ' + IntToStr(i), '');
            AGrid.Cells[11, i] := Ini.ReadString('WORD_IO' + SectionSuffix, 'INDEX ' + IntToStr(i), '');
            AGrid.Cells[10, i] := Ini.ReadString('WORD_IO' + SectionSuffix, 'ADDRESS ' + IntToStr(i), '');
        end;
    finally
        Ini.Free;
    end;
end;

procedure SaveIoTxt(AGrid: TStringGrid; SectionSuffix: string);
var
    i: integer;
    sTm: string;
    Ini: TIniFile;
begin
    sTm := Format('%s\IoList.Ini', [GetUsrDir(udENV, Now())]);
    Ini := TIniFile.Create(sTm);

    try
        for i := 1 to AGrid.RowCount - 1 do
        begin
            Ini.WriteString('PCIN_IO' + SectionSuffix, 'INDEX ' + IntToStr(i), AGrid.Cells[3, i]);
            Ini.WriteString('PCIN_IO' + SectionSuffix, 'ADDRESS ' + IntToStr(i), AGrid.Cells[2, i]);
            Ini.WriteString('PCOUT_IO' + SectionSuffix, 'INDEX ' + IntToStr(i), AGrid.Cells[7, i]);
            Ini.WriteString('PCOUT_IO' + SectionSuffix, 'ADDRESS ' + IntToStr(i), AGrid.Cells[6, i]);
            Ini.WriteString('WORD_IO' + SectionSuffix, 'INDEX ' + IntToStr(i), AGrid.Cells[11, i]);
            Ini.WriteString('WORD_IO' + SectionSuffix, 'ADDRESS ' + IntToStr(i), AGrid.Cells[10, i]);
        end;
    finally
        Ini.Free;
    end;
end;

procedure TfrmDio.cbxStationChange(Sender: TObject);
var
    i, ChCount: integer;
begin
    inherited;

    mDIO := mDIODescs[cbxStation.ItemIndex].mDIO;

    if not Assigned(mWDataReadFunc) then
        mWDataReadFunc := mDIO.GetWordData;

    mBeginRCh := mDIODescs[cbxStation.ItemIndex].mBeginRCh;
    mBeginWCh := mDIODescs[cbxStation.ItemIndex].mBeginWCh;
    ChCount := mDIODescs[cbxStation.ItemIndex].mChCount;
    mHalfChCount := ChCount div 2;

    if ChCount <> (Length(mIobuf) * 8) then
    begin
        mIobuf := nil;
        SetLength(mIobuf, ChCount div 8);
    end;

    sgrdIO.RowCount := mHalfChCount + 1;

    for i := 1 to sgrdIO.RowCount - 1 do
    begin
        sgrdIO.Cells[_DRAW_IN, i] := '0';
        sgrdIO.Cells[_DRAW_OUT, i] := '0';
    end;

    LoadIoTxt(sgrdIO, MakeSectionSuffix(Ord(mFormType), cbxStation.ItemIndex));

    SetGridNums;

    ZeroMemory(mIobuf, Length(mIobuf));

    // DI A/B Type 구분
    if mFormType = ftDIO then
    begin
        for i := 1 to sgrdIO.RowCount - 1 do
            sgrdIO.Cells[2, i] := mDIO.GetChTypeStr(i - 1, false);
    end;

    sgrdIO.Invalidate;
end;

procedure TfrmDio.SetBkArea(DIOType: TDIOType; BeginCh, ChCount: integer; Color: TColor);
begin
    mBkAreas[DIOType].mType := DIOType;
    mBkAreas[DIOType].mBeginCh := BeginCh;
    mBkAreas[DIOType].mChCount := ChCount;
    mBkAreas[DIOType].mColor := Color;
end;

procedure TfrmDio.SetFrm(DIO: TBaseDIO; Index, FirstCh, ChCount: integer);
var
    Count: integer;
begin

    Count := Length(mDIODescs);

    if Count <= Index then
        SetLength(mDIODescs, Index + 1);

    mDIODescs[Index].mDIO := DIO;
    mDIODescs[Index].mBeginRCh := FirstCh;
    mDIODescs[Index].mBeginWCh := ChCount div 2;
    mDIODescs[Index].mChCount := ChCount;

    cbxStation.Visible := false;
end;

procedure TfrmDio.SetGridNums;
var
    i: integer;

begin
    for i := 1 to sgrdIO.RowCount - 1 do
    begin
        sgrdIO.Cells[0, i] := IntToStr(mBeginRCh + i - 1);
        sgrdIO.Cells[4, i] := IntToStr(mBeginRCh + i - 1);
        sgrdIO.Cells[8, i] := IntToStr(i - 1);
    end;

end;

procedure TfrmDio.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    Action := caFree;

    inherited;
end;

procedure TfrmDio.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
    ioTimer.Enabled := false;
end;

procedure TfrmDio.FormCreate(Sender: TObject);
begin
    inherited;

    mHalfChCount := 16;
    mBeginRCh := 0;
    mBeginWCh := 32;
end;

procedure TfrmDio.FormDestroy(Sender: TObject);
begin
    if Length(mIobuf) > 0 then
        SetLength(mIobuf, 0);

    mDIODescs := nil;

end;

procedure TfrmDio.FormShow(Sender: TObject);
const
    ChTypeStr: array [false .. true] of string = ('A', 'B');
LABEL _GOTO_EXIT;
var
    i, j, rowL, rowR: integer;
    s: string;
begin

    inherited;

    cbxStation.ItemIndex := 0;

    cbxStation.Visible := cbxStation.Items.Count > 1;

    cbxStationChange(nil);

    FillChar(mIobuf[0], sizeof(mIobuf), 0);
    // ReadIO(true) ;

    with sgrdIO do
    begin
        ColCount := 12;

        Cells[0, 0] := 'NO';
        Cells[1, 0] := 'On/Off';
        if mFormType = ftDIO then
            Cells[2, 0] := 'I/O'
        else
            Cells[2, 0] := 'PLC';
        Cells[3, 0] := 'PC INPUT';

        Cells[4, 0] := 'NO';
        Cells[5, 0] := 'On/Off';
        if mFormType = ftDIO then
            Cells[6, 0] := 'I/O'
        else
            Cells[6, 0] := 'PLC';
        Cells[7, 0] := 'PC OUTPUT';

        Cells[8, 0] := 'NO';
        Cells[9, 0] := 'Value';
        Cells[10, 0] := 'PLC';
        Cells[11, 0] := 'WORD';

        SetGridNums;

        // 초기위치가 선택되어서는 안되는 위치라 강제로 지정한다.
        Row := 1;
        Col := 2;
    end;

    LoadGridWidths;

    for i := 0 to Length(mIobuf) - 1 do
    begin
        mIobuf[i] := mDIO.GetBuffer(i);
    end;

    rowL := _DRAW_IN;
    rowR := 1;
    for i := 0 to Length(mIobuf) - 1 do
    begin
        for j := 0 to 7 do
        begin
            if LongBool((mIobuf[i] shr j) and $01) then
            begin
                s := sgrdIO.Cells[rowL, rowR];
                s[1] := '1';
                sgrdIO.Cells[rowL, rowR] := s;
            end;
            Inc(rowR);
            if rowR >= sgrdIO.RowCount then
            begin
                if rowL = _DRAW_OUT then
                begin
                    ioTimer.Enabled := true;
                    Goto _GOTO_EXIT;
                end;
                rowL := _DRAW_OUT;
                rowR := 1;
            end;
        end;
    end;
_GOTO_EXIT :
    for i := 0 to Length(mrIoWORD) - 1 do
    begin
        mrIoWORD[i] := 999;
    end;
    ioTimer.Enabled := true;
end;

procedure TfrmDio.sgrdIOSelectCell(Sender: TObject; ACol, ARow: integer; var CanSelect: boolean);
var
    Grid: TStringGrid;
begin
    Grid := TStringGrid(Sender);

    case ACol of
        0, 4, 8:
            begin
                CanSelect := false;
            end;
        1: // DI
            begin
                CanSelect := false;
                mDIO.SetIO(mBeginRCh + ARow - 1, not mDIO.IsIO(mBeginRCh + ARow - 1));
            end;
        2:
            CanSelect := mFormType <> ftDIO;
        5: // DO
            begin
                CanSelect := false;
                mDIO.SetIO(mBeginWCh + ARow - 1, not mDIO.IsIO(mBeginWCh + ARow - 1));
            end;

    end;

    with Sender as TStringGrid do
        Repaint;
end;

procedure TfrmDio.ioTimerTimer(Sender: TObject);

begin
    if lpioTimerLock then
        Exit;
    lpioTimerLock := true;

    if Assigned(mDIO) then
        ReadIO;


    //
    lpioTimerLock := false;
end;

procedure TfrmDio.ReadIO(aInit: boolean);
LABEL _READ_WORD;
var
    i, j, rowL, rowR, Ch: integer;
    s: string;
    IoStatus: boolean;
begin

    rowL := _DRAW_IN;
    rowR := 1;
    for i := 0 to Length(mIobuf) - 1 do
    begin
        for j := 0 to 7 do
        begin

            if rowL = _DRAW_IN then
            begin
                Ch := mBeginRCh + rowR - 1;
                if Ch >= mBeginRCh + mHalfChCount then
                    continue;
            end
            else
            begin
                Ch := mBeginWCh + rowR - 1;
                if Ch >= mBeginWCh + mHalfChCount then
                    continue;
            end;

            IoStatus := mDIO.IsIO(Ch);

            if IoStatus <> boolean((mIobuf[i] shr j) and $01) then
            begin
                s := sgrdIO.Cells[rowL, rowR];
                if s <> '' then
                    Delete(s, 1, 1);
                if LongBool(IoStatus) then
                    s := '1' + s
                else
                    s := '0' + s;
                sgrdIO.Cells[rowL, rowR] := s;
            end;

            if IoStatus then
                mIobuf[i] := BitOn(mIobuf[i], j)
            else
                mIobuf[i] := BitOff(mIobuf[i], j);

            Inc(rowR);
            if rowR >= sgrdIO.RowCount then
            begin
                if rowL = _DRAW_OUT then
                begin
                    Goto _READ_WORD;
                end;
                rowL := _DRAW_OUT;
                rowR := 1;
            end;

        end; // j
    end; // i

_READ_WORD :
    if mFormType = ftDIO then
        Exit;

    for i := 0 to Length(mrIoWORD) - 1 do
    begin
        if mrIoWORD[i] <> mWDataReadFunc(i) then
        begin
            mrIoWORD[i] := mWDataReadFunc(i);
            sgrdIO.Cells[9, i + 1] := IntToHex(mrIoWORD[i], 4);
        end;
    end;
end;

procedure TfrmDio.sgrdIODrawCell(Sender: TObject; ACol, ARow: integer; Rect: TRect; State: TGridDrawState);
var
    x, y: integer;
    s: string;
    Grid: TStringGrid;
begin

    Grid := TStringGrid(Sender);

    Grid.Canvas.Font.Size := Font.Size;
    Grid.Canvas.Font.Name := Font.Name;
    Grid.Canvas.Font.Color := clBlack;

    y := Rect.Top + (Rect.Bottom - Rect.Top) div 4;
    x := Rect.Left + (Rect.Right - Rect.Left) div 2; // 20;

    with Grid do
    begin
        s := Cells[ACol, ARow];

        if (s <> '') and (BYTE(s[1]) In [ord('0'), ord('1')]) and (ACol In [_DRAW_IN, _DRAW_OUT]) then
            Delete(s, 1, 1);

        Canvas.Brush.Color := Color;
        Canvas.Pen.Color := Color;
        if not(ACol In [_DRAW_IN, _DRAW_OUT, _DRAW_WORD]) or (ARow = 0) then
        begin
            SetBkMode(Canvas.Handle, TRANSPARENT);
            if (ARow = Row) and (ACol In [2, 3, 6, 7, 10, 11]) and (ACol = Col) then
            begin
                Canvas.Brush.Color := clHighlight;
                Canvas.Font.Color := clWhite;
            end
            else if (ARow = 0) or (ACol In [0, 4, 8]) then
            begin
                Canvas.Brush.Color := clBtnFace;
            end
            else if (ACol = 2) and (mFormType = ftDIO) then
            begin
                if s = 'A' then
                    Canvas.Font.Color := clBlue
                else
                    Canvas.Font.Color := clRed;
            end
            else if ACol = 3 then
            begin
                Canvas.Brush.Color := mBkAreas[dtDI].GetColorByCh(ARow - 1, Color);
            end
            else if ACol = 7 then
            begin
                Canvas.Brush.Color := mBkAreas[dtDO].GetColorByCh(mDIODescs[cbxStation.ItemIndex].mBeginWCh + ARow - 1, Color);
            end;

            SetTextAlign(Canvas.Handle, TA_CENTER);
            Canvas.TextRect(Rect, Rect.Left + ((Rect.Right - Rect.Left) div 2), y, s);

            Exit;
        end;
        SetTextAlign(Canvas.Handle, TA_CENTER);
        Canvas.TextRect(Rect, Rect.Left + ((Rect.Right - Rect.Left) div 2), y, s);

        if (ACol >= 8) or (Cells[ACol, ARow] = '') then
            Exit;

        Canvas.Pen.Color := clBlack;
        if Cells[ACol, ARow][1] = '1' then
        begin
            Canvas.Brush.Color := clRed;
        end
        else
        begin
            Canvas.Brush.Color := clGray;
        end;

        Rect.Left := x - 6;
        Rect.Top := y - 3;
        Rect.Right := x + 6;
        Rect.Bottom := y + 12;
        Frame3D(Canvas, Rect, clWhite, clGray, 1);
        Canvas.RectAngle(x - 5, y - 2, x + 5, y + 11);

        Canvas.Brush.Color := Color;
        Canvas.Pen.Color := Color;
    end;
end;

procedure PasteClipboardToGrid(Grid: TStringGrid; Col, StartRow: integer);
var
    i, Row: integer;
    Str: string;
    RowStrList: TStringList;
begin
    RowStrList := TStringList.Create;

    RowStrList.Text := Clipboard.AsText;

    for i := 0 to RowStrList.Count - 1 do
    begin
        Row := StartRow + i;
        if Row >= Grid.RowCount then
            break;

        Grid.Cells[Col, Row] := RowStrList[i];
    end;

    RowStrList.Free;

end;

procedure TfrmDio.sgrdIOKeyDown(Sender: TObject; var Key: WORD; Shift: TShiftState);
begin
    if (LowerCase(Char(Key)) = 'v') and (Shift = [ssCtrl]) then
    begin
        PasteClipboardToGrid(sgrdIO, sgrdIO.Col, sgrdIO.Row);
        Key := 0;
    end;
end;

procedure TfrmDio.Label8DblClick(Sender: TObject);
begin
    sbtnPaste.Visible := not sbtnPaste.Visible;
end;

procedure TfrmDio.LoadGridWidths;
var
    i: integer;
    sTm: string;
begin
    sTm := Format('%s\DioGridWidths.env', [GetUsrDir(udENV, Now, false)]);
    if not FileExists(sTm) then
        Exit;

    with TIniFile.Create(sTm) do
    begin
        try
            for i := 0 to sgrdIO.ColCount - 1 do
            begin
                sgrdIO.ColWidths[i] := ReadInteger('DIO_GRID' + IntToStr(Ord(mFormType)), 'COL_' + IntToStr(i), 60);
            end;
        finally
            Free;
        end;
    end;
end;

procedure TfrmDio.SaveGridWidths;
var
    i: integer;
    sTm: string;
begin
    sTm := Format('%s\DioGridWidths.env', [GetUsrDir(udENV, Now, false)]);
    with TIniFile.Create(sTm) do
    begin
        try
            for i := 0 to sgrdIO.ColCount - 1 do
            begin
                WriteInteger('DIO_GRID' + IntToStr(Ord(mFormType)), 'COL_' + IntToStr(i), sgrdIO.ColWidths[i]);
            end;
        finally
            Free;
        end;
    end;
end;

procedure TfrmDio.sgrdIOSetEditText(Sender: TObject; ACol, ARow: integer; const Value: String);
begin
    if (ARow = 0) or (ACol In [_DRAW_IN, _DRAW_OUT]) then
        Exit;
end;

procedure LoadXLSFile(const SheetIndex: integer; const AGrid: TStringGrid; AFile: string);
var
    i, j: integer;
    nxls: TToExcel;
    sTm: string;
begin
    nxls := TToExcel.Create(AFile, '굴림');
    try
        with AGrid do
        begin
            nxls.SheetIndex := SheetIndex;
            for i := 1 to AGrid.RowCount do
            begin
                sTm := IntToStr(i);
                for j := 0 to AGrid.RowCount do
                begin
                    if Trim(nxls.GetAsString(0, j)) = sTm then
                    begin
                        Cells[2, i] := nxls.GetAsString(1, j);
                        Cells[3, i] := nxls.GetAsString(3, j);
                        Cells[6, i] := nxls.GetAsString(4, j);
                        Cells[7, i] := nxls.GetAsString(6, j);
                        Cells[10, i] := nxls.GetAsString(8, j);
                        Cells[11, i] := nxls.GetAsString(9, j);
                        break;
                    end;
                end;
            end;
        end;
    finally
        nxls.Free;
    end;
end;

procedure TfrmDio.LoadFormFile;
var
    fh: integer;
begin
    Screen.Cursor := crHourGlass;
    with openDlg do
    begin
        if InitialDir = '' then
            InitialDir := GetHomeDirectory;
        Filter := 'xls File(*.xls)|*.xls';

        if not Execute then
        begin
            SetCurrentDir(GetHomeDirectory);
            Screen.Cursor := crDefault;
            Exit;
        end;

        fh := FileOpen(FileName, fmOpenRead or fmShareDenyNone);
        if fh <= 32 then
        begin
            with Application do
                MessageBox(PChar(FileName + ' 파일을 열 수 없습니다.'), PChar(Label8.Caption), MB_ICONSTOP + MB_OK);

            SetCurrentDir(GetHomeDirectory);
            Screen.Cursor := crDefault;
            Exit;
        end;

        try
        finally
            FileClose(fh);
        end;

        LoadXLSFile(Ord(mFormType), sgrdIO, FileName);
        with Application do
            MessageBox(PChar('프로그램을 종료후 다시 실행시켜주십시요.'), 'Error Code', MB_ICONINFORMATION + MB_OK);
    end;
    SetCurrentDir(GetHomeDirectory);
    Screen.Cursor := crDefault;

end;

procedure TfrmDio.sbtnPasteClick(Sender: TObject);
begin
    PasteClipboardToGrid(sgrdIO, sgrdIO.Col, sgrdIO.Row);
end;

procedure TfrmDio.sbtnSaveClick(Sender: TObject);
begin
    SaveIoTxt(sgrdIO, MakeSectionSuffix(Ord(mFormType), cbxStation.ItemIndex));
    SaveGridWidths;
end;

procedure TfrmDio.AddDIO(DIO: TBaseDIO; BeginRCh, BeginWCh, ChCount: integer; StationName: string);
var
    Idx: integer;
begin
    Idx := Length(mDIODescs);
    SetLength(mDIODescs, Idx + 1);

    mDIODescs[Idx].mDIO := DIO;
    mDIODescs[Idx].mBeginRCh := BeginRCh;
    mDIODescs[Idx].mBeginWCh := BeginWCh;
    mDIODescs[Idx].mChCount := ChCount;

    if StationName = '' then
    begin
        cbxStation.Items.Add('');
        cbxStation.Visible := false;
    end
    else
    begin
        cbxStation.Items.Add(StationName);
    end;

end;

procedure TfrmDio.FormResize(Sender: TObject);
begin
    Shape10.Width := Panel2.Width - 15;
    sbtnSave.Left := Shape10.Width - sbtnSave.Width;
    sbtnPaste.Left := sbtnSave.Left - sbtnPaste.Width - 5;
end;

procedure TfrmDio.Panel2Resize(Sender: TObject);
begin
    Shape10.Width := Panel2.Width - 30;
    Shape11.Width := Shape10.Width;
    sbtnSave.Left := Shape10.Left + Shape10.Width - sbtnSave.Width;
    sbtnPaste.Left := sbtnSave.Left - sbtnPaste.Width - 2;
end;

{ TDIOFormBkArea }

function TDIOFormBkArea.GetColorByCh(Ch: integer; DefColor: TColor): TColor;
begin
    if IsIn(Ch) then
        Exit(mColor);

    Result := DefColor;
end;

function TDIOFormBkArea.IsIn(Ch: integer): boolean;
begin
    Result := (mBeginCh <= Ch) and (Ch < (mBeginCh + mChCount));
end;

end.
