{
    Ver. 220329.00
}

{
  주요 History

  Ver. 1.5042200 : 빌더 용  변환 한 스크래치 소스에서 변환
  Ver. 1.9050300 : #L 좌측 Merge 조건 검사 함수 추가 CanLMerge()
  Ver. 1.9050500 : Bold 추가
  Ver. 1.9071800 : TBeforeDrawText 추가
  Ver. 200304.00: TOwnerDrawCell, TTMCell.TextOut 추가
  Ver. 220329.00  프로젝트 종속,   한영 전환 지원(TLangTran)
}
unit TableMaker;

interface

//
uses
    Windows, Graphics { TCoLor } , Messages, Classes, Controls, SysUtils,
    Generics.defaults, Generics.collections, Dialogs;

type

    TTableMakerEx = class;
    TTMCell = class;

    TInitCellEvent = procedure(Sender: TTMCell) of Object;
    TOwnerDrawCell = procedure(Canvas: TCanvas; Cell: TTMCell; var CanDefDraw: boolean) of Object;
    TBeforeDrawText = procedure(var Text: string) of Object;

    TTMCell = class
        mParent: TTableMakerEx;
    private

        function GetXPos: Integer;
        function GetYPos: Integer;
        function GetHeight: integer;
        function GetWidth: integer;

    public
        mCol, mRow: Integer;
        mCX, mCY: Integer;

        mBold: boolean;

        mFontHeight: Integer;
        mBKColor: TColor;
        mTextColor: TColor;
        mText: string;
        mBndRect: TRect;
        mObject: TObject;


        constructor Create(Col: Integer; Row: Integer; Text: string);
        destructor Destroy; override;

        procedure Draw(Canvas: TCanvas);
        procedure TextOut(Canvas: TCanvas; X, Y: integer; Str: string; FontHeight: integer = 0);
        procedure TextOutTAC(Canvas: TCanvas; XPer, YPer: double; Str: string; FontHeight: integer = 0); // Cell에 X, Y 퍼센트 위치  중앙 정렬

        function PtIn(Pos: TPoint): Boolean;
        function CanLMerge(Col, Row: integer): Boolean;
        function IsMerged: boolean;

        property XPos: Integer read mBndRect.Left; //GetXPos;
        property YPos: Integer read mBndRect.Top; //GetYPos;
        property Width: integer read GetWidth;
        property Height: integer read GetHeight;

        property BoundsRect: TRect read mBndRect write mBndRect;

    end;

    TTMCellList = class(TObjectList<TTMCell>)
    public

        constructor Create;
        destructor Destroy; override;

        procedure SetText(Text: string);
        procedure SetBkColor(BkColor: TColor);

    end;

    TTblCellInfo = record
    public
        mSize: Integer;
        mRatio: Double;
        constructor Create(Size: Integer; Ratio: Double);

        procedure CalcSize(UnitSize: Integer);

    end;

    TTblCellInfos = array of TTblCellInfo;

    TTableMakerEx = class
    class var
        mDummyCell: TTMCell;

    private

        function GetCell(Col, Row: Integer): TTMCell;
        procedure SetBoundsRect(const &BndRect: TRect);

        procedure CalcColWidths;
        procedure CalcRowHeights;

        function GetRowHeight(Row: Integer): Integer;
        procedure SetRowHeight(Row: Integer; Height: Integer);

        function GetColWidth(Col: Integer): Integer;
        procedure SetColWidth(Col: Integer; Width: Integer);

    protected
        mTag: Integer;
        mCount: Integer;

        mCellViewFlags: array of Boolean;
        mCells: array of TTMCell;
        mColWidths: TTblCellInfos;
        mRowHeights: TTblCellInfos;
        mBndRect: TRect;
        mSelRect: TRect;

        mInitCell: TInitCellEvent;
        mBeforeDrawText: TBeforeDrawText;
        mOwnerDrawCell : TOwnerDrawCell;

        function GetCellWidth(Cell: TTMCell): Integer;
        function GetCellHeight(Cell: TTMCell): Integer;

        procedure CalcCellRect(Cell: TTMCell);
        procedure CalcCellRects();
        procedure Clear();
        procedure Free();

    public
        mDefColWidth: Integer;
        mDefRowHeight: Integer;
        mColCount: Integer;
        mRowCount: Integer;
        mFontResize: Boolean;
        mFontHeight: Integer;
        mBold: Boolean;
        mLineWidth: Integer;
        mSelCellList: TTMCellList;

        constructor Create; overload;
        constructor Create(AColCount, ARowCount: Integer; CellStr: string; InitCell: TInitCellEvent = nil); overload;
        destructor Destroy; override;

        function IsEmpty: Boolean;
        function IsLeftCellExists(Cell: TTMCell): Boolean;
        function IsTopCellExists(Cell: TTMCell): Boolean;

        function GetXPos(Col: Integer): Integer;
        function GetYPos(Row: Integer): Integer;

        procedure SetColWidths(ColWidths: array of Integer);
        procedure SetRowHeights(RowHeights: array of Integer);

        procedure SetRowHeightsRatio(RowHeightsRatio: array of Double; ALen: integer = 0);
        procedure SetColWidthsRatio(ColWidthsRatio: array of Double; ALen: integer = 0);

        procedure Init(AColCount, ARowCount: Integer; CellStr: string; InitCell: TInitCellEvent = nil); overload;
        procedure Init(AColCount, ARowCount: Integer; CellStr: array of string;  InitCell: TInitCellEvent = nil); overload;
        procedure Init(const BndRect: TRect; AColCount, ARowCount: Integer; CellStr: string; InitCell: TInitCellEvent = nil); overload;
        procedure Init(const BndRect: TRect; AColCount, ARowCount: Integer; CellStr: array of string; InitCell: TInitCellEvent = nil); overload;

        procedure Draw(Canvas: TCanvas); overload; virtual;
        procedure Draw(Canvas: TCanvas; const BoundsRect: TRect; IsRestore: Boolean = False); overload;

        function SetCellStr(Col, Row: Integer; CellStr: String; AObject: TObject = nil): TTMCell; overload;
        function SetCellStr(Col, Row: Integer; Val: Single; const Fmt: string; AObject: TObject = nil): TTMCell; overload;

        function PtIn(const Pos: TPoint): TTMCell;
        procedure ShowCell(Col, Row: Integer; IsShow: Bool);
        function SelectCell(SCol, SRow, ECol, ERow: Integer): TTMCellList;

        property Tag: Integer read mTag write mTag;

        property Cells[Col, Row: Integer]: TTMCell read GetCell;

        property ColWidths[Col: Integer]: Integer read GetColWidth write SetColWidth;
        property RowHeights[Row: Integer]: Integer read GetRowHeight write SetRowHeight;

        property BoundsRect: TRect read mBndRect write SetBoundsRect;

        property ColCount: integer read mColCount;
        property RowCount: integer read mRowCount;

        property OnInitCell: TInitCellEvent read mInitCell write mInitCell;
        property OnBeforeDrawText: TBeforeDrawText read mBeforeDrawText write mBeforeDrawText;
        property OnOwnerDrawCell: TOwnerDrawCell read mOwnerDrawCell write mOwnerDrawCell;

    end;

procedure InitCellInfos(var Arr: TTblCellInfos; Count: Integer);

implementation

uses
    MyUtils, Math, LangTran;

procedure InitCellInfos(var Arr: TTblCellInfos; Count: Integer);
var
    i: Integer;
begin
    if Length(Arr) <> Count then
    begin
        Arr := nil;
        SetLength(Arr, Count);
    end;

    for i := 0 to High(Arr) do
    begin
        Arr[i].Create(0, 1.0);
    end;
end;

{ TTblCellInfo }

constructor TTblCellInfo.Create(Size: Integer; Ratio: Double);
begin

    mSize := Size;
    mRatio := Ratio;
end;

procedure TTblCellInfo.CalcSize(UnitSize: Integer);
begin
    if mRatio = 1 then
    begin
        if mSize = 0 then
            mSize := UnitSize;
    end
    else
        mSize := Round(UnitSize * mRatio);
end;

{ TTMCell }

constructor TTMCell.Create(Col, Row: Integer; Text: string);
begin
    inherited Create;
    mCol := Col;
    mRow := Row;
    mCX := 1;
    mCY := 1;
    mText := Text;

    mBold := false;

    mBndRect := Bounds(0, 0, 0, 0);

    mTextColor := 0;
    mBKColor := 0;

    mFontHeight := 0;
end;

destructor TTMCell.Destroy;
begin
    inherited;
end;

procedure FrameRect(ACanvas: TCanvas; Rect: TRect; LeftDraw, TopDraw: Boolean; LineWidth: integer);
var
    OldLineWidth: integer;
begin
    OldLineWidth := ACanvas.Pen.Width;
    ACanvas.Pen.Width := LineWidth;

    if LineWidth >= 3 then
    begin
        Rect.Left := Rect.Left + 1;     // 수정 필요
        Rect.Top := Rect.Top + 1;
    end
    else
        Rect.Top := Rect.Top + 1;

    if LeftDraw then
    begin
        ACanvas.MoveTo(Rect.Left, Rect.Bottom);
        ACanvas.LineTo(Rect.Left, Rect.Top);
    end;

    if TopDraw then
    begin
        ACanvas.MoveTo(Rect.Left, Rect.Top);
        ACanvas.LineTo(Rect.Right, Rect.Top);
    end;

    ACanvas.MoveTo(Rect.Right, Rect.Top);
    ACanvas.LineTo(Rect.Right, Rect.Bottom);
    ACanvas.LineTo(Rect.Left, Rect.Bottom);

    ACanvas.Pen.Width := OldLineWidth;
end;

procedure TTMCell.Draw(Canvas: TCanvas);
var
    TextRect: TRect;
    Tokens: array [0 .. 10] of string;
    MaxLenText, TempStr: string;
    Temp: array [0 .. 200] of Char;
    i, Count, Height, FontHeight: Integer;
    CanDefDraw: boolean;
begin
    if (mBndRect.Right - mBndRect.Left) = 0 then
    begin
        mParent.CalcCellRect(Self);
    end;

    if mBKColor <> 0 then
    begin

        Canvas.Brush.Color := mBKColor;
        Canvas.FillRect(Rect(mBndRect.Left + 2, mBndRect.Top + 2, mBndRect.Right, mBndRect.Bottom));
        FrameRect(Canvas, mBndRect, not mParent.IsLeftCellExists(Self), not mParent.IsTopCellExists(Self), mParent.mLineWidth);
    end
    else
    begin
        Canvas.Brush.Color := clBlack;
        FrameRect(Canvas, mBndRect, not mParent.IsLeftCellExists(Self), not mParent.IsTopCellExists(Self), mParent.mLineWidth);
    end;

    if Assigned(mParent.mBeforeDrawText) then
        mParent.mBeforeDrawText(mText);

    if mFontHeight <> 0 then
    begin
        Canvas.Font.Height := mFontHeight;
    end
    else
    begin
        if (mParent.mFontResize) then
        begin
            TempStr := mText;
            Count := ParseByDelimiter(Tokens, 10, TempStr, '#10');
            for i := 0 to Count - 1 do
            begin
                if Length(Tokens[i]) > Length(MaxLenText) then
                begin
                    MaxLenText := Tokens[i];
                end;
            end;
            Canvas.Font.Height := mParent.mFontHeight;
            FontHeight := Canvas.Font.Height;
            while (mBndRect.Right - mBndRect.Left) < Canvas.TextWidth(MaxLenText) do
            begin
                FontHeight := Canvas.Font.Height;
                Dec(FontHeight);
                Canvas.Font.Height := FontHeight;

                if (FontHeight <= 1) then
                begin
                    break;
                end;
            end;
            //mFontHeight := FontHeight;
        end
        else
        begin
            Canvas.Font.Height := mParent.mFontHeight;
        end;
    end;

    SetBkMode(Canvas.Handle, TRANSPARENT);
    Canvas.Font.Color := mTextColor;

    CanDefDraw := true;
    if Assigned(mParent.mOwnerDrawCell) then
    begin
        mParent.mOwnerDrawCell(Canvas, self, CanDefDraw);

        if not CanDefDraw then
            Exit;
    end;



    if Pos(#10, mText) > 0 then
    begin

        Height := DrawText(Canvas.Handle, mText, -1, TextRect, DT_CALCRECT);

        TextRect := mBndRect;
        TextRect.Top := mBndRect.Top + ((mBndRect.Bottom - mBndRect.Top) - Height) div 2;

        if mBold or mParent.mBold then
            Canvas.Font.Style := [fsBold]
        else
            Canvas.Font.Style := [];
        DrawText(Canvas.Handle, mText, Length(mText), TextRect, DT_CENTER or DT_VCENTER);

    end
    else
    begin
        //mText := Format('[%d, %d]', [mCol, mRow]); // Debug 용도

        if mBold or mParent.mBold then
            Canvas.Font.Style := [fsBold]
        else
            Canvas.Font.Style := [];

      DrawText(Canvas.Handle, mText, Length(mText), mBndRect, DT_CENTER or DT_SINGLELINE or DT_VCENTER);
    end;

end;

function TTMCell.GetHeight: integer;
begin
    Result := mBndRect.Bottom - mBndRect.Top;

end;

function TTMCell.GetWidth: integer;
begin
    Result := mBndRect.Right - mBndRect.Left;
end;

function TTMCell.GetXPos: Integer;
begin
    Result := mParent.GetXPos(mCol);
end;

function TTMCell.GetYPos: Integer;
begin
    Result := mParent.GetYPos(mRow);
end;

function TTMCell.IsMerged: boolean;
begin
    Result := (mCX > 1) or (mCY > 1);
end;

function TTMCell.CanLMerge(Col, Row: integer): Boolean;
begin
    Result := (mCol > Col) or (Col > mCol + mCX) or (mRow = Row);

end;

function TTMCell.PtIn(Pos: TPoint): Boolean;
begin
    Result := PtInRect(mBndRect, Pos);
end;

procedure TTMCell.TextOut(Canvas: TCanvas; X, Y: integer; Str: string; FontHeight: integer);
var
    OldFH: integer;
begin
    if FontHeight > 0  then
    begin
        OldFH := Canvas.Font.Height;
        Canvas.Font.Height := FontHeight;
    end;

//    Canvas.TextOut(XPos + X, YPos + Y, Str);

    if FontHeight > 0  then
        Canvas.Font.Height := OldFH;
end;

procedure TTMCell.TextOutTAC(Canvas: TCanvas; XPer, YPer: double; Str: string; FontHeight: integer);
var
    TA, OldFH: integer;

begin
    if FontHeight > 0  then
    begin
        OldFH := Canvas.Font.Height;
        Canvas.Font.Height := FontHeight;
    end;

    TA := SetTextAlign(Canvas.Handle, TA_CENTER);

    Canvas.TextOut(XPos + Round(Width * (XPer / 100.0)),
        YPos + Round(Height * (YPer / 100.0)) - Canvas.TextHeight('W') div 2,
        Str);

    SetTextAlign(Canvas.Handle, TA);

    if FontHeight > 0  then
        Canvas.Font.Height := OldFH;

end;

{ TTMCellList }

constructor TTMCellList.Create;
begin
    inherited Create(false); // 자동해제 옵션 끔
end;

destructor TTMCellList.Destroy;
begin
    inherited;
end;

procedure TTMCellList.SetBkColor(BkColor: TColor);
var
    i: Integer;
begin

    for i := 0 to Self.Count - 1 do
    begin
        Self[i].mBKColor := BkColor;

    end;
end;

procedure TTMCellList.SetText(Text: string);
var
    i: Integer;
begin

    for i := 0 to Self.Count - 1 do
    begin
        Self[i].mText := Text;
    end;
end;

{ TTableMakerEx }

constructor TTableMakerEx.Create;
begin
    inherited;

    mCount := 0;
    mColCount := 0;
    mRowCount := 0;

    mFontResize := true;
    mFontHeight := 15;
    mSelCellList := TTMCellList.Create;

    mInitCell := nil;

    mLineWidth := 1;
end;

constructor TTableMakerEx.Create(AColCount, ARowCount: Integer; CellStr: string; InitCell: TInitCellEvent);
begin

    Init(AColCount, ARowCount, CellStr, InitCell);

    mFontResize := true;
    mFontHeight := 15;
    mSelCellList := TTMCellList.Create;

    mLineWidth := 1;
end;

destructor TTableMakerEx.Destroy;
begin

    FreeAndNil(mSelCellList);

    Free();

    inherited;
end;

procedure TTableMakerEx.Clear;
var
    i: Integer;
begin
    for i := 0 to mCount - 1 do
    begin
        mCells[i].mText := '';
    end;

end;

procedure TTableMakerEx.Free;
var
    i: Integer;
begin
    if mCells <> nil then
    begin
        for i := 0 to mCount - 1 do
        begin
            if mCellViewFlags[i] = true then
            begin
                if Assigned(mCells[i]) then
                    FreeAndNil(mCells[i]);
            end;
        end;
        mCells := nil;
    end;

    if mColWidths <> nil then
    begin
        mColWidths := nil;
    end;

    if mRowHeights <> nil then
    begin
        mRowHeights := nil;
    end;

    if mCellViewFlags <> nil then
    begin
        mCellViewFlags := nil;
    end;
end;

function TTableMakerEx.GetCellHeight(Cell: TTMCell): Integer;
var
    Sum: Integer;
    i: Integer;
begin
    if Length(mRowHeights) > 0 then
    begin
        Sum := 0;
        for i := 0 to Cell.mCY - 1 do
        begin
            Sum := Sum + mRowHeights[Cell.mRow + i].mSize;
        end;
        Result := Sum;
        Exit;
    end;

    Result := mDefRowHeight * Cell.mCY;
end;

procedure TTableMakerEx.CalcCellRect(Cell: TTMCell);
begin
    Cell.mBndRect := Bounds(GetXPos(Cell.mCol), GetYPos(Cell.mRow), GetCellWidth(Cell) + 1, GetCellHeight(Cell) + 1);
end;

function TTableMakerEx.GetCellWidth(Cell: TTMCell): Integer;
var
    Sum: Integer;
    i: Integer;
begin
    if Length(mColWidths) > 0 then
    begin
        Sum := 0;
        for i := 0 to Cell.mCX - 1 do
        begin
            Sum := Sum + mColWidths[Cell.mCol + i].mSize;
        end;
        Result := Sum;
        Exit;
    end;

    Result := mDefColWidth * Cell.mCX;
end;

function TTableMakerEx.GetColWidth(Col: Integer): Integer;
begin
    if Length(mColWidths) > 0 then
    begin
        if Col < mColCount then
        begin
            Result := mColWidths[Col].mSize;
            Exit;
        end;
    end;

    Result := mDefColWidth;
end;

function TTableMakerEx.GetRowHeight(Row: Integer): Integer;
begin
    if Length(mRowHeights) > 0 then
    begin
        if Row < mRowCount then
        begin
            Result := mRowHeights[Row].mSize;
            Exit;
        end;
    end;

    Result := mDefRowHeight;

end;

function TTableMakerEx.GetXPos(Col: Integer): Integer;
var
    WidthSum: Integer;
    i: Integer;
begin

    if Length(mColWidths) > 0 then
    begin
        WidthSum := 0;
        for i := 0 to Col - 1 do
        begin
            WidthSum := WidthSum + GetColWidth(i);
        end;
        Result := mBndRect.Left + WidthSum;
    end
    else
    begin
        Result := mBndRect.Left + Col * mDefColWidth;
    end;
end;

function TTableMakerEx.GetYPos(Row: Integer): Integer;
var
    HeightSum: Integer;
    i: Integer;
begin
    if Length(mRowHeights) > 0 then
    begin
        HeightSum := 0;
        for i := 0 to Row - 1 do
        begin
            HeightSum := HeightSum + GetRowHeight(i);
        end;
        Result := mBndRect.Top + HeightSum;
    end
    else
    begin
        Result := mBndRect.Top + Row * mDefRowHeight;
    end;
end;

procedure TTableMakerEx.CalcCellRects;
var
    i: Integer;
begin
    for i := 0 to mCount - 1 do
    begin
        CalcCellRect(mCells[i]);
    end;

    // 마진 정렬 옵션 처리 필요!!
    for i := 0 to mRowCount - 1 do
    begin
        GetCell(mColCount - 1, i).mBndRect.Right := mBndRect.Right;
    end;

end;

procedure TTableMakerEx.Draw(Canvas: TCanvas);
var
    i: Integer;
    TA: UINT;
begin
    Canvas.Font.Height := mFontHeight;
    for i := 0 to mCount - 1 do
    begin
        if mCellViewFlags[i] = true then
        begin
            mCells[i].Draw(Canvas);
        end;
    end;

end;

procedure TTableMakerEx.Draw(Canvas: TCanvas; const BoundsRect: TRect; IsRestore: Boolean);
var
    OldRect: TRect;
    OldFontHeight: Integer;
    Ratio: Single;
begin
    if (mBndRect.Bottom - mBndRect.Top) = 0 then
    begin
        SetBoundsRect(BoundsRect);
        //mFontHeight := 33;
    end;

    OldRect := mBndRect;
    OldFontHeight := mFontHeight;
    Ratio := (BoundsRect.Bottom - BoundsRect.Top) / (mBndRect.Bottom - mBndRect.Top);

    mFontHeight := Round(mFontHeight * Ratio);

    SetBoundsRect(BoundsRect);

    Draw(Canvas);

    mFontHeight := OldFontHeight;

    if IsRestore then
    begin
        SetBoundsRect(OldRect);
    end;
end;

function TTableMakerEx.SelectCell(SCol, SRow, ECol, ERow: Integer): TTMCellList;
var
    i, J: Integer;

begin
    mSelCellList.Clear;
    if (ECol < mColCount) and (ERow < mRowCount) then
    begin
        for i := SRow to ERow do
        begin
            for J := SCol to ECol do
            begin
                mSelCellList.Add(GetCell(J, i));
            end;
        end;
    end;

    Result := mSelCellList;

end;

procedure TTableMakerEx.CalcColWidths();
var
    RatioSum: Single;
    i, Sum, UnitSize: Integer;
begin
    if Length(mColWidths) = 0 then
        Exit;

    RatioSum := 0;

    for i := 0 to mColCount - 1 do
    begin
        RatioSum := RatioSum + mColWidths[i].mRatio;
    end;

    UnitSize := Round((mBndRect.Right - mBndRect.Left) / RatioSum);

    Sum := 0;
    for i := 0 to mColCount - 1 do
    begin
        mColWidths[i].CalcSize(UnitSize);
        Sum := Sum + mColWidths[i].mSize;
    end;

    mColWidths[mColCount - 1].mSize := mColWidths[mColCount - 1].mSize + abs((mBndRect.Right - mBndRect.Left) - Sum);

end;

procedure TTableMakerEx.CalcRowHeights();
var
    RatioSum: Single;
    i, UnitSize: Integer;
begin
    if Length(mRowHeights) = 0 then
        Exit;

    RatioSum := 0;
    for i := 0 to mRowCount - 1 do
    begin
        RatioSum := RatioSum + mRowHeights[i].mRatio;
    end;
    UnitSize := Round((mBndRect.Bottom - mBndRect.Top) / RatioSum);

    for i := 0 to mRowCount - 1 do
    begin
        mRowHeights[i].CalcSize(UnitSize);

    end;
end;

procedure TTableMakerEx.SetBoundsRect(const BndRect: TRect);
var
    IsModifyW, IsModifyH: Boolean;
    RatioSum: Single;
    i: Integer;

begin

    IsModifyW := (BndRect.Right - BndRect.Left) <> (mBndRect.Right - mBndRect.Left);
    IsModifyH := (BndRect.Bottom - BndRect.Top) <> (mBndRect.Bottom - mBndRect.Top);

    mBndRect := BndRect;

    if mCount > 0 then
    begin
        mDefColWidth := (BndRect.Right - BndRect.Left) div mColCount;
        mDefRowHeight := (BndRect.Bottom - BndRect.Top) div mRowCount;

        if IsModifyW then
        begin
            CalcColWidths;
        end;

        if IsModifyH then
        begin
            CalcRowHeights;
        end;

        CalcCellRects();

    end;

end;

procedure TTableMakerEx.SetColWidth(Col, Width: Integer);
begin
    if Length(mColWidths) = 0 then
        InitCellInfos(mColWidths, mColCount);

    if Col < mColCount then
    begin
        mColWidths[Col].mSize := Width;
    end;

    CalcColWidths;

    CalcCellRects
end;

function TTableMakerEx.GetCell(Col, Row: Integer): TTMCell;
begin
    if (Col < mColCount) and (Row < mRowCount) then
    begin
        Result := mCells[Row * mColCount + Col];
        Exit;
    end;
    Result := mDummyCell;

end;

function TTableMakerEx.PtIn(const Pos: TPoint): TTMCell;
var
    i: Integer;
begin
    for i := 0 to mCount - 1 do
    begin
        if mCellViewFlags[i] then
        begin
            if mCells[i].PtIn(Pos) = true then
            begin
                Result := mCells[i];
            end;
        end;
    end;

end;

function TTableMakerEx.SetCellStr(Col, Row: Integer; CellStr: String; AObject: TObject): TTMCell;
begin
    if ((Col < mColCount) and (Row < mRowCount)) then
    begin
        mCells[Row * mColCount + Col].mText := CellStr;
        mCells[Row * mColCount + Col].mObject := AObject;

        Exit(mCells[Row * mColCount + Col]);
    end;

    Result := mDummyCell;

end;

function TTableMakerEx.SetCellStr(Col, Row: Integer; Val: Single; const Fmt: string; AObject: TObject): TTMCell;
begin
    Result := SetCellStr(Col, Row, Val, Format(Fmt, [Val]), AObject);
end;

procedure TTableMakerEx.SetRowHeight(Row, Height: Integer);
begin
    if Length(mRowHeights) = 0 then
        InitCellInfos(mRowHeights, mRowCount);

    if Row < mRowCount then
    begin
        mRowHeights[Row].mSize := Height;
    end;

    CalcRowHeights;

    CalcCellRects;

end;

procedure TTableMakerEx.SetRowHeights(RowHeights: array of Integer);
var
    i, Len: Integer;
begin

    Len := Length(RowHeights);

    if mRowCount = 0 then
        InitCellInfos(mRowHeights, Len)
    else
        InitCellInfos(mRowHeights, min(Len, mRowCount));

    for i := 0 to Len - 1 do
    begin
        mRowHeights[i].mSize := RowHeights[i];
    end;

    CalcRowHeights();

    CalcCellRects();

end;

procedure TTableMakerEx.SetColWidths(ColWidths: array of Integer);
var
    i, Len: Integer;
begin
    Len := Length(ColWidths);

    if mColCount = 0 then
        InitCellInfos(mColWidths, Len)
    else
        InitCellInfos(mColWidths, min(Len, mColCount));

    for i := 0 to Length(ColWidths) - 1 do
    begin
        mColWidths[i].mSize := ColWidths[i];
    end;

    CalcColWidths();

    CalcCellRects();

end;

procedure TTableMakerEx.SetRowHeightsRatio(RowHeightsRatio: array of Double; ALen: integer);
var
    i, Len: Integer;
begin

    if ALen = 0 then
        Len := Length(RowHeightsRatio)
    else
        Len := ALen;


    if mRowCount = 0 then
        InitCellInfos(mRowHeights, Len)
    else
    begin
        if Len > mRowCount then
            InitCellInfos(mRowHeights, Len)
        else
            InitCellInfos(mRowHeights, min(Len, mRowCount));
    end;


    for i := 0 to Len - 1 do
    begin
        mRowHeights[i].mRatio := RowHeightsRatio[i];
    end;

    CalcRowHeights();

    CalcCellRects();
end;

procedure TTableMakerEx.SetColWidthsRatio(ColWidthsRatio: array of Double; ALen: integer);
var
    i, Len: Integer;
begin
    if mCount = 0 then
        Exit;

    if ALen = 0 then
        Len := Length(ColWidthsRatio)
    else
        Len := ALen;

    if mColCount = 0 then
        InitCellInfos(mColWidths, Len)
    else
    begin
        if Len > mColCount then
            InitCellInfos(mColWidths, Len)
        else
            InitCellInfos(mColWidths, min(Len, mColCount));
    end;


    for i := 0 to Len - 1 do
    begin
        mColWidths[i].mRatio := ColWidthsRatio[i];
    end;

    CalcColWidths();

    CalcCellRects();
end;

function TTableMakerEx.IsEmpty: Boolean;
begin
    Result := (mCount = 0) or ((mColCount = 0) and (mRowCount = 0)) or ((mBndRect.Right - mBndRect.Left) = 0);
end;

function TTableMakerEx.IsLeftCellExists(Cell: TTMCell): Boolean;
begin
    if (Cell.mCol > 0) then
    begin
        if Cell <> Self.GetCell(Cell.mCol - 1, Cell.mRow) then
            Exit(true);
    end;

    Result := false;
end;

function TTableMakerEx.IsTopCellExists(Cell: TTMCell): Boolean;
begin
    if (Cell.mRow > 0) then
    begin
        if Cell <> Self.GetCell(Cell.mCol, Cell.mRow - 1) then
            Exit(true);
    end;

    Result := false;
end;

procedure TTableMakerEx.Init(AColCount, ARowCount: Integer; CellStr: array of string; InitCell: TInitCellEvent);
var
    Text: string;
    Cell: TTMCell;
    n, i: Integer;
    Row, Col: Integer;
begin

    mInitCell := InitCell;

    n := 0;

    if (mColCount <> AColCount) or (mRowCount <> ARowCount) then
    begin
        Free();

        mColCount := AColCount;
        mRowCount := ARowCount;
        mCount := AColCount * ARowCount;

        SetLength(mCells, mCount);
        SetLength(mCellViewFlags, mCount);
    end;


    for Row := 0 to ARowCount - 1 do
    begin
        for Col := 0 to AColCount - 1 do
        begin
            if IsHan(CellStr[n]) then
                Text := _TR(CellStr[n])
            else
                Text := CellStr[n];
            if Text = '#T' then
            begin
                Cell := mCells[(Row - 1) * AColCount + Col];

                if (Cell.mRow + Cell.mCY) < ARowCount then
                begin
                    Inc(Cell.mCY);
                end;

                mCellViewFlags[n] := false;
            end
            else if Text = '#L' then
            begin
                Cell := mCells[Row * AColCount + (Col - 1)];
                if  Cell.CanLMerge(Col, Row) and ((Cell.mCol + Cell.mCX) < AColCount) then
                begin
                    Inc(Cell.mCX);
                end;

                mCellViewFlags[n] := false;
            end
            else
            begin
                Cell := TTMCell.Create(Col, Row, Text);
                Cell.mParent := Self;
                mCellViewFlags[n] := true;

                if Assigned(mInitCell) then
                    mInitCell(Cell);
            end;
            mCells[n] := Cell;
            Inc(n);
        end;
    end;
end;

procedure TTableMakerEx.Init(const BndRect: TRect; AColCount, ARowCount: Integer; CellStr: string; InitCell: TInitCellEvent);
var
    Tokens: array [0 .. 1000] of string;
    Count: Integer;
    StrTemp: string;
begin
    Count := ParseByDelimiter(Tokens, 1000, CellStr, ',');

    if Count = AColCount * ARowCount then
    begin
        Init(AColCount, ARowCount, Tokens, InitCell);
        SetBoundsRect(BndRect);
    end;

end;

procedure TTableMakerEx.Init(const BndRect: TRect; AColCount, ARowCount: Integer; CellStr: array of string; InitCell: TInitCellEvent);
begin
    Init(AColCount, ARowCount, CellStr);
    SetBoundsRect(BndRect);
end;

procedure TTableMakerEx.Init(AColCount, ARowCount: Integer; CellStr: string; InitCell: TInitCellEvent);
var
    TokCount: integer;
    Tokens: array [0 .. 1000] of string;
    Str: string;
begin
    TokCount := ParseByDelimiter(Tokens, 1000, CellStr, ',');

    if TokCount = (AColCount * ARowCount) then
    begin
        Init(AColCount, ARowCount, Tokens, InitCell);
    end
    else
    begin
        Str := Format('TTableMakerEx.Init: ColCount x RowCount:%d <> TokCount:%d', [AColCount * ARowCount, TokCount]);
        raise Exception.Create(Str);
    end;

end;

procedure TTableMakerEx.ShowCell(Col, Row: Integer; IsShow: Bool);
begin
    if (Col < mColCount) and (Row < mRowCount) then
    begin
        mCellViewFlags[Row * mColCount + Col] := IsShow;
    end;
end;

Initialization

TTableMakerEx.mDummyCell := TTMCell.Create(0, 0, 'None');

finalization

FreeAndNil(TTableMakerEx.mDummyCell);

end.
