unit ExcelTableDrawer;

interface

uses
    Classes, Windows, Types, SysUtils, Graphics, CellFormats4, SheetData4, Cell4,
    XLSReadWriteII4;

type
    TBorderDirection = (bdTop, bdBottom, bdLeft, bdRight);

    TTableDrawer = class;


    PCellInfo = ^TCellInfo;

    TBeforeDrawCellEvent = function (CellInfo: PCellInfo): Boolean of Object;

    TCellInfo = packed record
        Col: Integer;
        Row: Integer;
        Text: string;
        CellColor: TColor;
        FontName: string;
        FontSize: Integer;
        FontStyle: TFontStyles;
        FontColor: TColor;
        BorderTop: TCellBorder;
        BorderLeft: TCellBorder;
        BorderRight: TCellBorder;
        BorderBottom: TCellBorder;
        HorizAlignment: TCellHorizAlignment;
        VertAlignment: TCellVertAlignment;
        DefaultRowHeight: Integer;
        Parent: TTableDrawer;
        Merged: Boolean;

        CellRect: TRect;

        procedure Draw(Canvas: TCanvas; ACellRect: TRect);
    end;

    TCellAreaInfo = packed record
        Cell1, Cell2: PCellInfo;
        procedure Draw(Canvas: TCanvas);
    end;

    TTableDrawer = class
    private
        FMaxCol: Integer;
        FMaxRow: Integer;

        FCellWidthRatios: array of Double;
        FCellHeightRatios: array of Double;
        FCellInfos: array of TCellInfo;
        FCellAreaInfos: array of TCellAreaInfo;
        FOnBeforeDrawCell: TBeforeDrawCellEvent;

        procedure LoadTableFromExcel(const ExcelFileName: string);
        procedure AddCellInfo(Col, Row: Integer; Parent: TTableDrawer; Sheet: TSheet);
        function HasNeighborBorder(Col, Row: Integer; Direction: TBorderDirection): Boolean;
        function GetCellIndex(Col, Row: Integer): Integer;

    public
        constructor Create(const ExcelFileName: string);
        destructor Destroy; override;

        procedure Draw(Canvas: TCanvas; const DrawRect: TRect);

        property OnBeforeDrawCell: TBeforeDrawCellEvent read FOnBeforeDrawCell write FOnBeforeDrawCell;
    end;

implementation

uses
    XLSFonts4, BIFFRecsII4, Math, StrUtils, URect;

{ TCellInfo }
function ExcelColorToDelphiColor(ExcelColor: TExcelColor): TColor;
begin
    case ExcelColor of
        xc0:
            Result := $000000;          // Black
        xc1:
            Result := $FFFFFF;          // White
        xc2:
            Result := $FF0000;          // Red
        xc3:
            Result := $00FF00;          // Bright Green
        xc4:
            Result := $0000FF;          // Blue
        xc5:
            Result := $FFFF00;          // Yellow
        xc6:
            Result := $FF00FF;          // Pink
        xc7:
            Result := $00FFFF;          // Turquoise
        xcBlack:
            Result := $000000;      // Black
        xcWhite:
            Result := $FFFFFF;      // White
        xcRed:
            Result := $FF0000;        // Red
        xcBrightGreen:
            Result := $00FF00; // Bright Green
        xcBlue:
            Result := $0000FF;       // Blue
        xcYellow:
            Result := $FFFF00;     // Yellow
        xcPink:
            Result := $FF00FF;       // Pink
        xcTurquoise:
            Result := $00FFFF;  // Turquoise
        xcDarkRed:
            Result := $800000;    // Dark Red
        xcGreen:
            Result := $008000;      // Green
        xcDarkBlue:
            Result := $000080;   // Dark Blue
        xcBrownGreen:
            Result := $808000; // Brown Green
        xcViolet:
            Result := $800080;     // Violet
        xcBlueGreen:
            Result := $008080;  // Blue Green
        xcGray25:
            Result := $C0C0C0;     // Gray 25%
        xcGray50:
            Result := $808080;     // Gray 50%
        // Add more cases for other colors as needed...
    else
        Result := clNone; // Default color if no match found
    end;
end;

var
    gDummyCell: TCellInfo;

procedure TCellInfo.Draw(Canvas: TCanvas; ACellRect: TRect);
var
    Format: UINT;
    X, Y, Width, Height: Integer;
    Str: string;
begin

    X := ACellRect.Left;
    Y := ACellRect.Top;
    Width := ACellRect.Width;
    Height := ACellRect.Height;

    CellRect := Types.Rect(X + 1, Y + 1, X + Width + 1, Y + Height + 1);

    if Assigned(Parent.OnBeforeDrawCell) then
    begin
        gDummyCell := Self;
        if Parent.OnBeforeDrawCell(@gDummyCell) then
            Self := gDummyCell;
    end;


    Canvas.Brush.Color := CellColor;
    if CellColor <> $F000000 then
    begin
        Canvas.FillRect(CellRect);
    end;

    Canvas.Font.Name := FontName;
    Canvas.Font.Size := FontSize;
    Canvas.Font.Style := FontStyle;
    Canvas.Font.Color := FontColor;
    Str := Text;

    case HorizAlignment of
        chaLeft:
            begin
                Format := DT_LEFT;
                Str := ' ' + Text;
            end;
        chaCenter:
            Format := DT_CENTER;
        chaRight:
            begin
                Format := DT_RIGHT;
                Str := Text + ' ';
            end;
        chaFill:
            Format := DT_LEFT;
        chaJustify:
            Format := DT_LEFT;
        chaCenterContinuous:
            Format := DT_CENTER;
        chaDistributed:
            Format := DT_LEFT;
    else
        Format := DT_LEFT;
        Str := ' ' + Text;
    end;

    case VertAlignment of
        cvaTop:
            Format := Format or DT_TOP;
        cvaCenter:
            Format := Format or DT_VCENTER;
        cvaBottom:
            Format := Format or DT_BOTTOM;
        cvaJustify:
            Format := Format or DT_TOP;
        cvaDistributed:
            Format := Format or DT_TOP;
    else
        Format := Format or DT_VCENTER;
    end;

    if not Merged then
    begin
        SetBkMode(Canvas.Handle, TRANSPARENT);
        DrawText(Canvas.Handle, PChar(Str), -1, CellRect, Format or DT_SINGLELINE);
    end;

    Canvas.Pen.Width := 1;


    // Top
    if (BorderTop.Style <> cbsNone) then
    begin
        Canvas.Pen.Color := ExcelColorToDelphiColor(BorderTop.Color);
        Canvas.MoveTo(X, Y);
        Canvas.LineTo(X + Width, Y);
    end;

    // Left
    if (BorderLeft.Style <> cbsNone) then
    begin
        Canvas.Pen.Color := ExcelColorToDelphiColor(BorderLeft.Color);
        Canvas.MoveTo(X, Y);
        Canvas.LineTo(X, Y + Height);
    end;

    // Right
    if (BorderRight.Style <> cbsNone) then
    begin
        Canvas.Pen.Color := ExcelColorToDelphiColor(BorderRight.Color);
        Canvas.MoveTo(X + Width, Y);
        Canvas.LineTo(X + Width, Y + Height);
    end;

    // Bottom
    if (BorderBottom.Style <> cbsNone) then
    begin
        Canvas.Pen.Color := ExcelColorToDelphiColor(BorderBottom.Color);
        Canvas.MoveTo(X, Y + Height);
        Canvas.LineTo(X + Width, Y + Height);
    end;
end;

{ TTableDrawer }

constructor TTableDrawer.Create(const ExcelFileName: string);
begin
    LoadTableFromExcel(ExcelFileName);
end;

destructor TTableDrawer.Destroy;
begin
    inherited;
end;

function TTableDrawer.GetCellIndex(Col, Row: Integer): Integer;
begin
    Result := (Row * (FMaxCol + 1)) + Col;
end;

procedure TTableDrawer.LoadTableFromExcel(const ExcelFileName: string);
var
    XLS: TXLSReadWriteII4;
    Sheet: TSheet;
    i, Col, Row, Idx: Integer;
    TotalColWidths, TotalRowHeights: Integer;

    function GetWidth(Col: Integer): Integer;
    begin
        if Sheet.Columns[Col] = nil then
            Result := Sheet.DefaultColWidth * 256
        else
            Result := Sheet.Columns[Col].Width;
    end;

    function GetHeight(Row: Integer): Integer;
    begin
        if Sheet.Rows[Row] = nil then
            Result := Sheet.DefaultRowHeight * 256
        else
            Result := Sheet.Rows[Row].Height;
    end;

begin
    if not FileExists(ExcelFileName) then
        Exit;

    XLS := TXLSReadWriteII4.Create(nil);
    try
        XLS.Filename := ExcelFileName;
        XLS.Read;
        Sheet := XLS.Sheets[0];
        FMaxCol := Sheet.LastCol;
        FMaxRow := Sheet.LastRow;
        SetLength(FCellWidthRatios, Sheet.LastCol + 1);
        SetLength(FCellHeightRatios, Sheet.LastRow + 1);
        SetLength(FCellInfos, (Sheet.LastCol + 1) * (Sheet.LastRow + 1));

        //--------------------------------------------------------
        // Ratio
        TotalColWidths := 0;
        TotalRowHeights := 0;

        for Col := 0 to Sheet.LastCol do
        begin
            Inc(TotalColWidths, GetWidth(Col));
        end;
        for Col := 0 to Sheet.LastCol do
        begin
            FCellWidthRatios[Col] := GetWidth(Col) / TotalColWidths;
        end;

        for Row := 0 to Sheet.LastRow do
        begin
            Inc(TotalRowHeights, GetHeight(Row));
        end;
        for Row := 0 to Sheet.LastRow do
        begin
            FCellHeightRatios[Row] := GetHeight(Row) / TotalRowHeights;
        end;

        //--------------------------------------------------------

        for Row := 0 to Sheet.LastRow do
        begin
            for Col := 0 to Sheet.LastCol do
            begin
                AddCellInfo(Col, Row, Self, Sheet);
            end;
        end;
        //--------------------------------------------------------
        SetLength(FCellAreaInfos, Sheet.MergedCells.Count);

        for i := 0 to Sheet.MergedCells.Count - 1 do
        begin
            Idx := GetCellIndex(Sheet.MergedCells.Items[i].Col1, Sheet.MergedCells.Items[i].Row1);
            FCellAreaInfos[i].Cell1 := @FCellInfos[Idx];

            Idx := GetCellIndex(Sheet.MergedCells.Items[i].Col2, Sheet.MergedCells.Items[i].Row2);
            FCellAreaInfos[i].Cell2 := @FCellInfos[Idx];
        end;
    finally
        XLS.Free;
    end;
end;

function ConvertToDelphiFontStyle(XFontStyles: TXFontStyles): TFontStyles;
begin
    Result := [];
    if xfsBold in XFontStyles then
        Include(Result, fsBold);
    if xfsItalic in XFontStyles then
        Include(Result, fsItalic);
    if xfsStrikeOut in XFontStyles then
        Include(Result, fsStrikeOut);
end;


procedure TTableDrawer.AddCellInfo(Col, Row: Integer; Parent: TTableDrawer; Sheet: TSheet);
var
    CellInfo: TCellInfo;
    Border: TCellBorder;
    Index: Integer;
    CurCell: TCell;
begin
    CurCell := Sheet.Cell[Col, Row];

    Index := (Row * (Sheet.LastCol + 1)) + Col;

    if CurCell = nil then
    begin
        FCellInfos[Index].Parent := Parent;
        FCellInfos[Index].CellColor := clWhite;
        Exit;
    end;

    CellInfo.Parent := Parent;
    CellInfo.Col := Col;
    CellInfo.Row := Row;
    CellInfo.Text := Sheet.AsString[Col, Row];

    CellInfo.CellColor := CurCell.CellColorRGB;
    CellInfo.FontName := CurCell.FontName;
    CellInfo.FontSize := CurCell.FontSize;
    CellInfo.FontStyle := ConvertToDelphiFontStyle(CurCell.FontStyle);
    CellInfo.FontColor := CurCell.FontColor;
    CellInfo.Merged := Sheet.MergedCells.CellInAreas(Col, Row) >= 0;

    // Borders
    Border.Style := CurCell.BorderTopStyle;
    Border.Color := TExcelColor(CurCell.BorderTopColorRGB);
    CellInfo.BorderTop := Border;

    Border.Style := CurCell.BorderLeftStyle;
    Border.Color := TExcelColor(CurCell.BorderLeftColorRGB);
    CellInfo.BorderLeft := Border;

    Border.Style := CurCell.BorderRightStyle;
    Border.Color := TExcelColor(CurCell.BorderRightColorRGB);
    CellInfo.BorderRight := Border;

    Border.Style := CurCell.BorderBottomStyle;
    Border.Color := TExcelColor(CurCell.BorderBottomColorRGB);
    CellInfo.BorderBottom := Border;

    CellInfo.HorizAlignment := CurCell.HorizAlignment;
    CellInfo.VertAlignment := CurCell.VertAlignment;
    CellInfo.DefaultRowHeight := Sheet.DefaultRowHeight;

    if Index < Length(FCellInfos) then
        FCellInfos[Index] := CellInfo;
end;

procedure TTableDrawer.Draw(Canvas: TCanvas; const DrawRect: TRect);
var
    Col, Row, Index: Integer;
    i, X, Y, Width, Height: Integer;
    CellRect: TRect;
begin
    Index := 0;
    X := DrawRect.Left;
    Y := DrawRect.Top;

    for Row := 0 to Length(FCellHeightRatios) - 1 do
    begin
        Height := Round(DrawRect.Height * Self.FCellHeightRatios[Row]);
        for Col := 0 to Length(FCellWidthRatios) - 1 do
        begin
            Width := Round(DrawRect.Width * Self.FCellWidthRatios[Col]);
            CellRect := Rect(X, Y, X + Width, Y + Height);
            FCellInfos[Index].Draw(Canvas, CellRect);
            Inc(X, Width);
            Inc(Index);
        end;
        X := DrawRect.Left;
        Inc(Y, Height);
    end;

    for i := 0 to Length(FCellAreaInfos) - 1 do
    begin
        FCellAreaInfos[i].Draw(Canvas);
    end;
end;

function TTableDrawer.HasNeighborBorder(Col, Row: Integer; Direction: TBorderDirection): Boolean;
begin
    Result := False;

    case Direction of
        bdTop:
            if Row > 0 then
                Result := FCellInfos[GetCellIndex(Col, Row - 1)].BorderBottom.Style <> cbsNone;
        bdBottom:
            if Row < FMaxRow then
                Result := FCellInfos[GetCellIndex(Col, Row + 1)].BorderTop.Style <> cbsNone;
        bdLeft:
            if Col > 0 then
                Result := FCellInfos[GetCellIndex(Col - 1, Row)].BorderRight.Style <> cbsNone;
        bdRight:
            if Col < FMaxCol then
                Result := FCellInfos[GetCellIndex(Col + 1, Row)].BorderLeft.Style <> cbsNone;
    end;
end;

{ TCellAreaInfo }


procedure TCellAreaInfo.Draw(Canvas: TCanvas);
var
    MergedRect: TRect;
begin
    URect.UnionRect(MergedRect, Cell1.CellRect, Cell2.CellRect);

    Canvas.Font.Name := Cell1.FontName;
    Canvas.Font.Size := Cell1.FontSize;
    Canvas.Font.Style := Cell1.FontStyle;
    Canvas.Font.Color := Cell1.FontColor;

    SetBkMode(Canvas.Handle, TRANSPARENT);
    DrawText(Canvas.Handle, PChar(Cell1.Text), -1, MergedRect, DT_CENTER or DT_VCENTER or DT_SINGLELINE);

end;

end.

