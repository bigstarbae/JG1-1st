{
  Ver.1.9100600

  Ver 220223.00
      : 프로젝트 종속,   한영 전환 지원

  Ver 250623.00
      : 컬럼 숨김 기능 및 비율 설정 기능 추가
}
unit GridHead;

interface

uses
    Windows, Graphics, Grids, Extctrls;

type
    TGridTitle = class;

    PGridHead = ^TGridHead;

    TGridHead = record
    private
        mOwner: PGridHead;
        function GetOwner: PGridHead;
    public
        StartCell: integer; // grid상 시작위치
        StartRow: integer; // grid상 시작위치
        ColCount: integer;
        RowCount: integer;
        Line: boolean;
        Caption: string;
        Color: TColor;
        Visible: boolean;
        WidthRatio: double;

        procedure IncCol;
        procedure IncRow;
        procedure Assign(const GridHead: TGridHead);
        procedure ChangeChildsData(Parent: TGridTitle);

        property Owner: PGridHead read GetOwner write mOwner;

    end;

    TGridHeads = array of array of TGridHead;

    TGridTitle = class
    private
        mIdx, mHeadRow: integer;
        mHeadCol: integer;
        mHead: TGridHeads;
        mMaxRow: integer;
        mFixedLineHLColor, mFixedBColor,              // 그라데이션 Begin Color
        mFixedLineColor: TColor;

        mTextColor: TColor;
        mTextBold: Boolean;

        mGradStep: integer;         // 0이면 단색 처리
        mRowHeight: integer;

        mGrid: TStringGrid;

        mVisibleCols: array of boolean;
        mColRatios: array of double;

        function GetHeads(Col, Row: integer): TGridHead;

        function GetColors(Col, Row: integer): TColor;
        procedure SetColors(Col, Row: integer; Color: TColor);

        function GetCells(Col, Row: integer): string;
        procedure SetCells(Col, Row: integer; Str: string);

        procedure SetGradStep(Step: integer);
        procedure SetRowHeight(ARowHeight: integer);
        function GetColOffset: integer;

        function GetVisibleColCount: integer;
        function GetNextVisibleCol(ACol: integer): integer;
        function GetPrevVisibleCol(ACol: integer): integer;

    public
        constructor Create(Grid: TStringGrid; Col, Row: integer);
        destructor Destroy; override;

        procedure SetHeads(StartCell, StartRow, ColCount, RowCount: integer; Line: boolean; Caption: string);
        procedure AddHeader(CaptionsByRows: array of string);       // 3x2 예제 : ['순번,   작업 정보,   #L', '#T, 일자, 시간']

        function DrawGridHead(Grid: TStringGrid; ACol, ARow: integer; CellRect: TRect; State: TGridDrawState): boolean;

        procedure Print(Canvas: TCanvas; HeaderRect: TRect; ColPos: array of integer);

        function GetHeadLine(ACol, ARow: integer): boolean;
        function GetStartCell(ACol, ARow: integer): integer;
        function GetStartRow(ACol, ARow: integer): integer;
        function GetRowCount(ACol, ARow: integer): integer;
        function GetColCount(ACol, ARow: integer): integer;
        function GetCaption(ACol, ARow: integer): string;
        function GetMergedRect(ACol, ARow: integer; var BndRect: TRect): boolean;
        function GetMergedCells(ACol, ARow: integer; var Cells: TRect): boolean;
        // Cell.Left, Top : 시작Cell Col Row; Right,Bottom : 끝Cell Col, Row

        procedure Rebuild(Grid: TStringGrid; Col, Row: integer);

        procedure SetColumnVisible(ACol: integer; Visible: boolean);
        function GetColumnVisible(ACol: integer): boolean;
        procedure SetColumnRatio(ACol: integer; Ratio: double);
        function GetColumnRatio(ACol: integer): double;
        procedure SetColumnRatios(ColRatios: array of double);
        procedure ApplyColumnWidths;

        property HeadRow: integer read mHeadRow;
        property HeadCol: integer read mHeadCol;
        property ColCount: integer read mHeadCol;
        property RowCount: integer read mHeadRow;
        property FixedLineHLColor: TColor read mFixedLineHLColor write mFixedLineHLColor;
        property FixedLineColor: TColor read mFixedLineColor write mFixedLineColor;
        property TextColor: TColor read mTextColor write mTextColor;
        property TextBold: Boolean read mTextBold write mTextBold;
        property GradStep: integer read mGradStep write SetGradStep;
        property RowHeight: integer read mRowHeight write SetRowHeight;

        property Heads[Col, Row: integer]: TGridHead read GetHeads;
        property Colors[Col, Row: integer]: TColor read GetColors write SetColors;
        property Cells[Col, Row: integer]: string read GetCells write SetCells;
        property VisibleColCount: integer read GetVisibleColCount;
    end;

implementation

uses
    Classes, Math, MyUtils, LangTran;

function TGridTitle.GetColOffset: integer;
var
    i: integer;
begin
    for i := 0 to mHeadCol - 1 do
    begin
        if (mHead[0][i].Caption = '') and (mHead[0][i].mOwner = nil) then
            Exit(i);
    end;

    Result := 0;
end;

procedure TGridTitle.AddHeader(CaptionsByRows: array of string);
var
    Offset, i, Col, Row, ColCount: Integer;
    Tokens: array of string;
    Captions: array of string;
    Header: PGridHead;
begin

    SetLength(Tokens, mHeadCol);

    Offset := GetColOffset;
    for Row := 0 to mHeadRow - 1 do
    begin
        ColCount := ParseByDelimiter(Tokens, Length(Tokens), CaptionsByRows[Row], ',');
        ColCount := Min(ColCount, mHeadCol);
        for i := 0 to ColCount - 1 do
        begin
            Col := Offset + i;
            with mHead[Row][Col] do
            begin
                if IsHan(Tokens[i]) then
                    Caption := _TR(Tokens[i])
                else
                    Caption := Tokens[i];

                StartCell := Col;
                StartRow := Row;
                ColCount := 1;
                RowCount := 1;
                Owner := nil;
            end;
        end;
    end;

    for Row := 0 to mHeadRow - 1 do
    begin
        for i := 0 to ColCount - 1 do
        begin
            Col := Offset + i;
            with mHead[Row][Col] do
            begin
                if Caption = '#T' then
                begin
                    Owner := mHead[Row - 1][Col].Owner;
                    Owner.IncRow;
                    Owner.ChangeChildsData(Self);
                end
                else if Caption = '#L' then
                begin
                    Owner := mHead[Row][Col - 1].Owner;
                    Owner.IncCol;
                    Owner.ChangeChildsData(Self);
                end;
            end;
        end;
    end;

    Tokens := nil;

end;

constructor TGridTitle.Create(Grid: TStringGrid; Col, Row: integer);
begin
    Rebuild(Grid, Col, Row);
end;

procedure TGridTitle.SetCells(Col, Row: integer; Str: string);
begin
    if (Col < mHeadCol) and (Row < mHeadRow) then
        mHead[Row][Col].Caption := Str;
end;

procedure TGridTitle.SetColors(Col, Row: integer; Color: TColor);
begin
    if (Col < mHeadCol) and (Row < mHeadRow) then
        mHead[Row][Col].Color := Color;
end;

procedure TGridTitle.SetGradStep(Step: integer);
begin
    mGradStep := Step;
    mFixedBColor := IncRGB(mGrid.FixedColor, mGradStep);

end;

procedure TGridTitle.SetHeads(StartCell, StartRow, ColCount, RowCount: integer; Line: boolean; Caption: string);
var
    Col, Row: integer;
begin
    Col := mIdx div mMaxRow;
    ///
    Row := mIdx mod mMaxRow;
    ///

    if (High(mHead) < Row) or (High(mHead[0]) < Col) then
        exit;
    mHead[Row][Col].StartCell := StartCell;
    mHead[Row][Col].StartRow := StartRow;
    mHead[Row][Col].ColCount := ColCount;
    mHead[Row][Col].RowCount := RowCount;
    mHead[Row][Col].Line := Line;
    mHead[Row][Col].Caption := (Caption);

    Inc(mIdx);
end;

function TGridTitle.DrawGridHead(Grid: TStringGrid; ACol, ARow: integer; CellRect: TRect; State: TGridDrawState): boolean;
var
    x, y, i, r, RowH: integer;
    s: string;
    ARect: TRect;
    NextVisibleCol, LastCol: integer;
    ShouldDrawRightBorder: boolean;
begin
    Result := false;
  // 헤더의 첫 번째 행(ARow=0)만 그리며, 숨김 컬럼은 skip
    if (ARow <> 0) or (ACol >= mHeadCol) or (not mVisibleCols[ACol]) then
        Exit;

    Grid.Canvas.Font.Size := Grid.Font.Size;
    Grid.Canvas.Font.Name := Grid.Font.Name;
    Grid.Canvas.Font.Color := mTextColor;

    if mTextBold then
        Grid.Canvas.Font.Style := [fsBold]
    else
        Grid.Canvas.Font.Style := [];

    Grid.Canvas.Brush.Color := Grid.FixedColor;

    if mRowHeight > 0 then
        RowH := mRowHeight
    else
        RowH := Grid.DefaultRowHeight;

    for r := mHeadRow - 1 downto 0 do
    begin
        if not mHead[r][ACol].Visible then
            Continue;

        x := mHead[r][ACol].StartCell;
        y := mHead[r][ACol].StartRow;
        s := mHead[y][x].Caption;

    // 셀의 화면 위치 계산 (병합 및 스크롤 고려)
        ARect := Grid.CellRect(x, 0);

        if Grid.LeftCol > x then
        begin
            for i := 1 to Grid.LeftCol - x do
                ARect.Left := ARect.Left - Grid.ColWidths[Grid.LeftCol - i] - 1;
        end;

        ARect.Top := ARect.Top + RowH * y;
        ARect.Bottom := ARect.Top + RowH * mHead[r][ACol].RowCount;

    // 병합된 셀의 전체 우측 경계
        ARect.Right := ARect.Left;
        for i := 1 to mHead[r][ACol].ColCount do
            ARect.Right := ARect.Right + Grid.ColWidths[x + i - 1] + 1;
        ARect.Right := ARect.Right - 1;

    // 배경
        if (mHead[r][ACol].Color = 0) then
      // 기본 FixedColor와 mFixedBColor를 사용하여 그라디언트 채우기
            GradientFillRect(Grid.Canvas.Handle, ARect, mFixedBColor, Grid.FixedColor, true)
        else
        begin
      // mGradStep이 0이 아니면 셀의 Color 사용, 아니면 FixedColor 사용
            if (mGradStep = 0) then
                Grid.Canvas.Brush.Color := Grid.FixedColor
            else
                Grid.Canvas.Brush.Color := mHead[r][ACol].Color;
            Grid.Canvas.FillRect(ARect);
        end;

    // 상단/좌측 하이라이트
        Grid.Canvas.Pen.Color := mFixedLineHLColor;
        Grid.Canvas.MoveTo(ARect.Left, ARect.Top + 1);
        Grid.Canvas.LineTo(ARect.Right, ARect.Top + 1);
        Grid.Canvas.MoveTo(ARect.Left, ARect.Top);
        Grid.Canvas.LineTo(ARect.Left, ARect.Bottom);

    // 텍스트
        SetBkMode(Grid.Canvas.Handle, TRANSPARENT);

        DrawText(Grid.Canvas.Handle, PChar(s), Length(s), ARect, DT_CENTER or DT_VCENTER or DT_SINGLELINE);

    // 라인 색상
        Grid.Canvas.Pen.Color := mFixedLineColor;
        Grid.Canvas.Pen.Width := 1;

    // 하단 경계(가로)
        Grid.Canvas.MoveTo(ARect.Left, ARect.Bottom);
        Grid.Canvas.LineTo(ARect.Right, ARect.Bottom);

    // === 우측(세로) 라인 처리 ===
        ShouldDrawRightBorder := False;
    // 병합된 셀의 마지막 컬럼 인덱스
        LastCol := ACol + mHead[r][ACol].ColCount - 1;
    // 다음 가시 컬럼 인덱스 (숨김 건너뜀)
        NextVisibleCol := GetNextVisibleCol(LastCol);

    // (1) 다음 가시 컬럼이 없을 때(즉, 이 셀이 마지막 보이는 셀) → 항상 그린다
        if NextVisibleCol = -1 then
            ShouldDrawRightBorder := True
    // (2) 다음 가시 컬럼이 바로 인접하지 않을 때(즉, 이 셀 이후 숨김 컬럼이 있음)
        else if NextVisibleCol > LastCol + 1 then
            ShouldDrawRightBorder := True;

    // 실제 라인 그리기
        if ShouldDrawRightBorder then
        begin
            Grid.Canvas.MoveTo(ARect.Right, ARect.Top);
            Grid.Canvas.LineTo(ARect.Right, ARect.Bottom);
        end;
    end;

    Result := True;
end;

procedure TGridTitle.Print(Canvas: TCanvas; HeaderRect: TRect; ColPos: array of integer);
var
    prvLine: boolean;
    l, c, i, y, ColHeight, CurrentColPos: integer;
    CellLeft, CellRight: integer;
    TextRect: TRect;
    VisibleColWidths: array of integer; // 가시적인 컬럼들의 너비를 저장
    VisibleColLefts: array of integer; // 가시적인 컬럼의 인쇄 시작 X 좌표
    VisibleColRights: array of integer; // 가시적인 컬럼의 인쇄 끝 X 좌표
    VisibleColIdx: integer; // 가시적인 컬럼 인덱스를 위한 변수
begin
  // 1. 가시적인 컬럼들의 인쇄 너비 및 위치 미리 계산
    SetLength(VisibleColWidths, GetVisibleColCount); // 실제로 사용될 가시 컬럼의 너비만 저장
    SetLength(VisibleColLefts, mHeadCol); // 모든 컬럼에 대해 Left/Right 저장 (숨김 컬럼은 -1 등 유효하지 않은 값)
    SetLength(VisibleColRights, mHeadCol);

    VisibleColIdx := 0;
    CurrentColPos := HeaderRect.Left;

    for c := 0 to mHeadCol - 1 do
    begin
        if mVisibleCols[c] then
        begin
            VisibleColLefts[c] := CurrentColPos;
      // ColPos 배열은 가시적인 컬럼의 오른쪽 경계 위치를 누적하여 제공한다고 가정
            if VisibleColIdx < Length(ColPos) then
            begin
                VisibleColRights[c] := ColPos[VisibleColIdx];
                VisibleColWidths[VisibleColIdx] := ColPos[VisibleColIdx] - CurrentColPos; // 현재 가시 컬럼의 너비
                CurrentColPos := VisibleColRights[c]; // 다음 가시 컬럼의 시작 위치 업데이트
            end
            else
            begin
        // ColPos 배열의 크기가 부족한 경우의 처리 (예: 마지막 가시 컬럼에 남은 공간 할당)
                VisibleColRights[c] := HeaderRect.Right;
                VisibleColWidths[VisibleColIdx] := HeaderRect.Right - CurrentColPos;
                CurrentColPos := HeaderRect.Right;
            end;
            Inc(VisibleColIdx);
        end
        else
        begin
            VisibleColLefts[c] := -1; // 숨김 컬럼
            VisibleColRights[c] := -1; // 숨김 컬럼
        end;
    end;

    ColHeight := (HeaderRect.Bottom - HeaderRect.Top) div mHeadRow;
    Canvas.Font.Height := Trunc(ColHeight * 0.7);
    SetTextAlign(Canvas.Handle, TA_CENTER or TA_TOP);

    Canvas.Pen.Width := 3;
    Canvas.Rectangle(HeaderRect);
    Canvas.Pen.Width := 1;
    Canvas.Pen.Color := mFixedLineColor; // 라인 색상 설정

  // 2. 가로선 그리기 (가시적인 컬럼만 고려)
    y := HeaderRect.Top + ColHeight;
    for l := 0 to mHeadRow - 1 do
    begin
    // 각 행의 시작점은 HeaderRect.Left
        CurrentColPos := HeaderRect.Left;
        Canvas.MoveTo(CurrentColPos, y); // 항상 헤더의 왼쪽에서 시작

        for c := 0 to mHeadCol - 1 do
        begin
            if not mVisibleCols[c] then
                continue;

      // 현재 가시 컬럼의 실제 오른쪽 X 좌표
            CurrentColPos := VisibleColRights[c];

      // 이전 셀의 Line 속성과 현재 셀의 Line 속성을 비교하여 선을 그릴지 결정
            if (not prvLine) and mHead[l][c].Line then
                Canvas.MoveTo(CurrentColPos, y)
            else if (prvLine) and (not mHead[l][c].Line) then
                Canvas.LineTo(CurrentColPos, y);

            prvLine := mHead[l][c].Line;
        end;
    // 마지막 가시적인 컬럼까지 선을 그림
        Canvas.LineTo(HeaderRect.Right, y); // HeaderRect의 끝까지 선을 그림
        y := y + ColHeight;
    end;

  // 3. 세로선 그리기 (가시적인 컬럼만 고려)
    for c := 0 to mHeadCol - 1 do
    begin
        if not mVisibleCols[c] then
            continue;

    // 현재 가시 컬럼의 실제 오른쪽 X 좌표
        CellRight := VisibleColRights[c];

    // 다음 가시적인 컬럼이 없거나 (즉, 현재 컬럼이 마지막 가시적 컬럼),
    // 또는 다음 가시적 컬럼이 바로 옆에 붙어있지 않은 경우에만 선을 그린다.
        if (GetNextVisibleCol(c) = -1) or (GetNextVisibleCol(c) > c + 1) then
        begin
            Canvas.MoveTo(CellRight, HeaderRect.Top);
            Canvas.LineTo(CellRight, HeaderRect.Bottom);
        end;
    end;

  // 4. 제목 출력 (가시적인 컬럼만)
    Canvas.Font.Color := mTextColor; // 텍스트 색상 설정
    if mTextBold then
        Canvas.Font.Style := [fsBold]
    else
        Canvas.Font.Style := []; // 텍스트 볼드 설정

    y := HeaderRect.Top + (ColHeight div 2) - (Canvas.Font.Height div 2);
    for l := 0 to mHeadRow - 1 do
    begin
        VisibleColIdx := 0; // 이 변수를 사용하여 가시적인 컬럼을 추적

        for c := 0 to mHeadCol - 1 do
        begin
            if not mVisibleCols[c] then
                continue;

      // 현재 셀이 병합된 셀의 시작 셀인지 확인
      // ColCount = 1이 아니라, ColCount가 VisibleColIdx와 동일한 경우 즉, 병합된 셀의 마지막 가시적인 컬럼인 경우
      // 또는 병합되지 않은 단일 셀인 경우 (ColCount = 1)
            if (mHead[l][c].ColCount > 0) and (mHead[l][c].StartCell = c) and (mHead[l][c].StartRow = l) then
            begin
        // 병합된 셀의 텍스트를 그릴 영역을 계산합니다.
        // 병합된 셀의 시작 컬럼과 끝 컬럼의 실제 인쇄 위치를 사용합니다.
                CellLeft := VisibleColLefts[mHead[l][c].StartCell];
                CellRight := VisibleColRights[mHead[l][c].StartCell + mHead[l][c].ColCount - 1]; // 병합된 마지막 컬럼의 오른쪽 끝

        // 텍스트 Rect 설정
                TextRect.Left := CellLeft;
                TextRect.Right := CellRight;
        // 병합된 행의 중앙에 오도록 Top/Bottom 계산
                TextRect.Top := HeaderRect.Top + (mHead[l][c].StartRow * ColHeight) + ((mHead[l][c].RowCount - 1) * ColHeight) div 2;
                TextRect.Bottom := TextRect.Top + Canvas.Font.Height;

                DrawText(Canvas.Handle, PChar(mHead[l][c].Caption), Length(mHead[l][c].Caption), TextRect, DT_CENTER or DT_VCENTER or DT_SINGLELINE);
            end;
            Inc(VisibleColIdx); // 다음 가시 컬럼으로 이동
        end;
        y := y + ColHeight; // 다음 행의 Y 위치
    end;
end;

procedure TGridHead.Assign(const GridHead: TGridHead);
begin
    StartCell := GridHead.StartCell;
    StartRow := GridHead.StartRow;
    ColCount := GridHead.ColCount;
    RowCount := GridHead.RowCount;
    Caption := GridHead.Caption;
    Color := GridHead.Color;
    Line := GridHead.Line;
    Visible := GridHead.Visible;
    WidthRatio := GridHead.WidthRatio;
    mOwner := GridHead.mOwner;
end;

procedure TGridHead.ChangeChildsData(Parent: TGridTitle);
var
    i: integer;
begin

    for i := 0 to ColCount - 1 do
        Parent.mHead[StartRow][StartCell + i].Assign(Self);

    for i := 0 to RowCount - 1 do
        Parent.mHead[StartRow + i][StartCell].Assign(Self);

end;

function TGridHead.GetOwner: PGridHead;
begin
    if mOwner = nil then
        Exit(@Self);

    Result := mOwner;
end;

procedure TGridHead.IncCol;
begin
    Inc(ColCount);
end;

procedure TGridHead.IncRow;
begin
    Inc(RowCount);
end;

function TGridTitle.GetColumnVisible(ACol: integer): boolean;
begin
    if (ACol >= 0) and (ACol < mHeadCol) then
        Result := mVisibleCols[ACol]
    else
        Result := false;
end;

function TGridTitle.GetVisibleColCount: integer;
var
    i: integer;
begin
    Result := 0;
    for i := 0 to mHeadCol - 1 do
        if mVisibleCols[i] then
            Inc(Result);
end;

function TGridTitle.GetNextVisibleCol(ACol: integer): integer;
var
    i: integer;
begin
    Result := -1; // 다음 가시적인 컬럼이 없음을 나타냄
    for i := ACol + 1 to mHeadCol - 1 do
        if mVisibleCols[i] then
        begin
            Result := i;
            Break; // 찾으면 루프 종료
        end;
end;

function TGridTitle.GetPrevVisibleCol(ACol: integer): integer;
var
    i: integer;
begin
    Result := -1; // 이전 가시적인 컬럼이 없음을 나타냄
    for i := ACol - 1 downto 0 do
        if mVisibleCols[i] then
        begin
            Result := i;
            Break; // 찾으면 루프 종료
        end;
end;

procedure TGridTitle.SetColumnRatio(ACol: integer; Ratio: double);
var
    i: integer;
begin
    if (ACol >= 0) and (ACol < mHeadCol) then
    begin
        mColRatios[ACol] := Ratio;

        // 해당 컬럼의 모든 헤더 셀에 비율 적용
        for i := 0 to mHeadRow - 1 do
            mHead[i][ACol].WidthRatio := Ratio;

        // 비율이 0 이하면 숨김, 아니면 보임
        if Ratio <= 0 then
            SetColumnVisible(ACol, false)
        else
            SetColumnVisible(ACol, true);

        // 컬럼 너비 재계산 및 적용
        ApplyColumnWidths;
    end;
end;

function TGridTitle.GetColumnRatio(ACol: integer): double;
begin
    if (ACol >= 0) and (ACol < mHeadCol) then
        Result := mColRatios[ACol]
    else
        Result := 0.0;
end;

procedure TGridTitle.SetColumnRatios(ColRatios: array of double);
var
    i, j, Count: integer;
begin
    Count := Min(Length(ColRatios), mHeadCol);

    for i := 0 to Count - 1 do
    begin
        mColRatios[i] := ColRatios[i];

        // 해당 컬럼의 모든 헤더 셀에 비율 적용
        for j := 0 to mHeadRow - 1 do
            mHead[j][i].WidthRatio := ColRatios[i];

        // 비율이 0 이하면 숨김
        if ColRatios[i] <= 0 then
            mVisibleCols[i] := false
        else
            mVisibleCols[i] := true;
    end;

    // 컬럼 너비 재계산 및 적용
    ApplyColumnWidths;
end;

procedure TGridTitle.ApplyColumnWidths;
var
    i, TotalWidth, UsedWidth: Integer;
    RatioSum: double;
    ColWidths: array of Integer;
    VisibleCount: integer;
begin
    // 가시적인 컬럼의 비율 합계 계산
    RatioSum := 0;
    VisibleCount := 0;
    for i := 0 to mHeadCol - 1 do
    begin
        if mVisibleCols[i] and (mColRatios[i] > 0) then
        begin
            RatioSum := RatioSum + mColRatios[i];
            Inc(VisibleCount);
        end;
    end;

    if RatioSum <= 0 then
        Exit;

    // 사용 가능한 전체 너비 (그리드 라인 제외)
    TotalWidth := mGrid.ClientWidth;
    if TotalWidth <= 0 then
        TotalWidth := mGrid.Width;

    // 그리드 라인 너비를 총 너비에서 제외 (가시적인 컬럼 사이에만 라인이 그려지므로 VisibleCount-1)
    if VisibleCount > 0 then
        TotalWidth := TotalWidth - (VisibleCount - 1) * mGrid.GridLineWidth;

    SetLength(ColWidths, mHeadCol);
    UsedWidth := 0;
    VisibleCount := 0; // 다시 카운트 (정확성을 위해)

    // 각 컬럼 너비 계산
    for i := 0 to mHeadCol - 1 do
    begin
        if mVisibleCols[i] and (mColRatios[i] > 0) then
        begin
            if VisibleCount < GetVisibleColCount - 1 then
            begin
                // 마지막 가시적인 컬럼이 아니면 반올림하여 너비 할당
                ColWidths[i] := Round(TotalWidth * mColRatios[i] / RatioSum);
                UsedWidth := UsedWidth + ColWidths[i];
            end
            else
            begin
                // 마지막 가시적인 컬럼에 남은 너비 할당하여 오차 보정
                ColWidths[i] := TotalWidth - UsedWidth;
            end;
            Inc(VisibleCount);
        end
        else
            ColWidths[i] := -1;   // 숨겨진 컬럼은 0
    end;

    // 실제 그리드에 적용
    for i := 0 to mHeadCol - 1 do
    begin
        if i < mGrid.ColCount then
            mGrid.ColWidths[i] := ColWidths[i];
    end;
    mGrid.Invalidate; // 그리드 다시 그리기
end;

procedure TGridTitle.Rebuild(Grid: TStringGrid; Col, Row: integer);
var
    RowH, i, j: integer;
begin
    mGrid := Grid;
    mGrid.FixedCols := 0;
    mGrid.DefaultDrawing := false;

    mIdx := 0;
    mHeadRow := Row;
    mHeadCol := Col;
    mMaxRow := Row;

    mGradStep := 20;

    mFixedLineColor := clGray;
    mFixedLineHLColor := clWhite;
    mFixedBColor := IncRGB(Grid.FixedColor, mGradStep);
    mTextColor := clBlack;

    // 가시성 배열 초기화
    SetLength(mVisibleCols, Col);
    SetLength(mColRatios, Col);
    for i := 0 to Col - 1 do
    begin
        mVisibleCols[i] := true;
        mColRatios[i] := 1.0;   // 기본 비율 1.0
    end;

    SetLength(mHead, Row);
    for i := 0 to Row - 1 do
    begin
        SetLength(mHead[i], Col);
        for j := 0 to Col - 1 do
        begin
            mHead[i][j].Visible := true;
            mHead[i][j].WidthRatio := 1.0;   // 기본 비율 1.0
        end;
    end;

    if mRowHeight > 0 then
        RowH := mRowHeight
    else
        RowH := Grid.DefaultRowHeight;

    mGrid.RowHeights[0] := mGrid.DefaultRowHeight * mHeadRow;

    Grid.ColCount := Col;
    //Grid.RowCount := Row;
    ApplyColumnWidths; // Rebuild 시 초기 컬럼 너비 적용
end;

destructor TGridTitle.Destroy;
var
    i: integer;
begin
    for i := 0 to Length(mHead) - 1 do
    begin
        if Length(mHead[i]) > 0 then
            SetLength(mHead[i], 0);
    end;

    if Length(mHead) > 0 then
        SetLength(mHead, 0);

    inherited;
end;

{ TGridHead }

procedure TGridTitle.SetColumnVisible(ACol: integer; Visible: boolean);
var
    i: integer;
begin
    if (ACol >= 0) and (ACol < mHeadCol) then
    begin
        mVisibleCols[ACol] := Visible;

        // 해당 컬럼의 모든 헤더 셀에 가시성 적용
        for i := 0 to mHeadRow - 1 do
            mHead[i][ACol].Visible := Visible;

        // 숨김 처리 시 비율도 0으로 설정, 보임 처리 시 기본 비율 1.0으로 설정 (사용자 설정이 없는 경우)
        if not Visible then
        begin
            mColRatios[ACol] := 0;
            for i := 0 to mHeadRow - 1 do
                mHead[i][ACol].WidthRatio := 0;
        end
        else
        begin
            // 이미 설정된 비율이 0이 아니면 유지, 0이면 1.0으로 초기화
            if mColRatios[ACol] <= 0 then
            begin
                mColRatios[ACol] := 1.0;
                for i := 0 to mHeadRow - 1 do
                    mHead[i][ACol].WidthRatio := 1.0;
            end;
        end;

        // 컬럼 너비 재계산 및 적용
        ApplyColumnWidths;
        mGrid.Invalidate; // 그리드 다시 그리기
    end;
end;

function TGridTitle.GetCaption(ACol, ARow: integer): string;
begin
    Result := mHead[ARow][ACol].Caption;
end;

function TGridTitle.GetCells(Col, Row: integer): string;
begin
    if (Col < mHeadCol) and (Row < mHeadRow) then
        exit(mHead[Row][Col].Caption);

    Result := '';

end;

function TGridTitle.GetColCount(ACol, ARow: integer): integer;
begin
    Result := mHead[ARow][ACol].ColCount;
end;

function TGridTitle.GetColors(Col, Row: integer): TColor;
begin
    if (Col < mHeadCol) and (Row < mHeadRow) then
        exit(mHead[Row][Col].Color);

    Result := mFixedLineColor;
end;

function TGridTitle.GetRowCount(ACol, ARow: integer): integer;
begin
    Result := mHead[ARow][ACol].RowCount;
end;

function TGridTitle.GetStartCell(ACol, ARow: integer): integer;
begin
    Result := mHead[ARow][ACol].StartCell;
end;

function TGridTitle.GetStartRow(ACol, ARow: integer): integer;
begin
    Result := mHead[ARow][ACol].StartRow;
end;

procedure TGridTitle.SetRowHeight(ARowHeight: integer);
var
    RowH: integer;
begin
    mRowHeight := ARowHeight;
    if mRowHeight > 0 then
        mGrid.RowHeights[0] := ARowHeight * mHeadRow
    else
        mGrid.RowHeights[0] := mGrid.DefaultRowHeight * mHeadRow;
end;

var
    lDummyGH: TGridHead;

function TGridTitle.GetHeadLine(ACol, ARow: integer): boolean;
begin

end;

function TGridTitle.GetHeads(Col, Row: integer): TGridHead;
begin
    if (Col < mHeadCol) and (Row < mHeadRow) then
    begin
        exit(mHead[Row][Col]);
    end;

    Result := lDummyGH;
end;

function TGridTitle.GetMergedCells(ACol, ARow: integer; var Cells: TRect): boolean;
begin
    with mHead[ARow][ACol] do
    begin
        if (StartCell = ACol) and (StartRow = ARow) then
        begin
            Cells := Rect(ACol, ARow, ACol + ColCount - 1, ARow + RowCount - 1);
            exit(true);
        end;

        exit(false);
    end;
end;

function TGridTitle.GetMergedRect(ACol, ARow: integer; var BndRect: TRect): boolean;
begin
    with mHead[ARow][ACol] do
    begin
        if (StartCell = ACol) and (StartRow = ARow) then
        begin
            BndRect := Bounds(ACol, ARow, ColCount, RowCount);
            exit(true);
        end;

        exit(false);
    end;
end;

end.

