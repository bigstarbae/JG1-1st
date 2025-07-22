{
  Ver.1.9100600

  Ver 220223.00
      : ������Ʈ ����,   �ѿ� ��ȯ ����

  Ver 250623.00
      : �÷� ���� ��� �� ���� ���� ��� �߰�
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
        StartCell: integer; // grid�� ������ġ
        StartRow: integer; // grid�� ������ġ
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
        mFixedLineHLColor, mFixedBColor,              // �׶��̼� Begin Color
        mFixedLineColor: TColor;

        mTextColor: TColor;
        mTextBold: Boolean;

        mGradStep: integer;         // 0�̸� �ܻ� ó��
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
        procedure AddHeader(CaptionsByRows: array of string);       // 3x2 ���� : ['����,   �۾� ����,   #L', '#T, ����, �ð�']

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
        // Cell.Left, Top : ����Cell Col Row; Right,Bottom : ��Cell Col, Row

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
  // ����� ù ��° ��(ARow=0)�� �׸���, ���� �÷��� skip
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

    // ���� ȭ�� ��ġ ��� (���� �� ��ũ�� ���)
        ARect := Grid.CellRect(x, 0);

        if Grid.LeftCol > x then
        begin
            for i := 1 to Grid.LeftCol - x do
                ARect.Left := ARect.Left - Grid.ColWidths[Grid.LeftCol - i] - 1;
        end;

        ARect.Top := ARect.Top + RowH * y;
        ARect.Bottom := ARect.Top + RowH * mHead[r][ACol].RowCount;

    // ���յ� ���� ��ü ���� ���
        ARect.Right := ARect.Left;
        for i := 1 to mHead[r][ACol].ColCount do
            ARect.Right := ARect.Right + Grid.ColWidths[x + i - 1] + 1;
        ARect.Right := ARect.Right - 1;

    // ���
        if (mHead[r][ACol].Color = 0) then
      // �⺻ FixedColor�� mFixedBColor�� ����Ͽ� �׶���Ʈ ä���
            GradientFillRect(Grid.Canvas.Handle, ARect, mFixedBColor, Grid.FixedColor, true)
        else
        begin
      // mGradStep�� 0�� �ƴϸ� ���� Color ���, �ƴϸ� FixedColor ���
            if (mGradStep = 0) then
                Grid.Canvas.Brush.Color := Grid.FixedColor
            else
                Grid.Canvas.Brush.Color := mHead[r][ACol].Color;
            Grid.Canvas.FillRect(ARect);
        end;

    // ���/���� ���̶���Ʈ
        Grid.Canvas.Pen.Color := mFixedLineHLColor;
        Grid.Canvas.MoveTo(ARect.Left, ARect.Top + 1);
        Grid.Canvas.LineTo(ARect.Right, ARect.Top + 1);
        Grid.Canvas.MoveTo(ARect.Left, ARect.Top);
        Grid.Canvas.LineTo(ARect.Left, ARect.Bottom);

    // �ؽ�Ʈ
        SetBkMode(Grid.Canvas.Handle, TRANSPARENT);

        DrawText(Grid.Canvas.Handle, PChar(s), Length(s), ARect, DT_CENTER or DT_VCENTER or DT_SINGLELINE);

    // ���� ����
        Grid.Canvas.Pen.Color := mFixedLineColor;
        Grid.Canvas.Pen.Width := 1;

    // �ϴ� ���(����)
        Grid.Canvas.MoveTo(ARect.Left, ARect.Bottom);
        Grid.Canvas.LineTo(ARect.Right, ARect.Bottom);

    // === ����(����) ���� ó�� ===
        ShouldDrawRightBorder := False;
    // ���յ� ���� ������ �÷� �ε���
        LastCol := ACol + mHead[r][ACol].ColCount - 1;
    // ���� ���� �÷� �ε��� (���� �ǳʶ�)
        NextVisibleCol := GetNextVisibleCol(LastCol);

    // (1) ���� ���� �÷��� ���� ��(��, �� ���� ������ ���̴� ��) �� �׻� �׸���
        if NextVisibleCol = -1 then
            ShouldDrawRightBorder := True
    // (2) ���� ���� �÷��� �ٷ� �������� ���� ��(��, �� �� ���� ���� �÷��� ����)
        else if NextVisibleCol > LastCol + 1 then
            ShouldDrawRightBorder := True;

    // ���� ���� �׸���
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
    VisibleColWidths: array of integer; // �������� �÷����� �ʺ� ����
    VisibleColLefts: array of integer; // �������� �÷��� �μ� ���� X ��ǥ
    VisibleColRights: array of integer; // �������� �÷��� �μ� �� X ��ǥ
    VisibleColIdx: integer; // �������� �÷� �ε����� ���� ����
begin
  // 1. �������� �÷����� �μ� �ʺ� �� ��ġ �̸� ���
    SetLength(VisibleColWidths, GetVisibleColCount); // ������ ���� ���� �÷��� �ʺ� ����
    SetLength(VisibleColLefts, mHeadCol); // ��� �÷��� ���� Left/Right ���� (���� �÷��� -1 �� ��ȿ���� ���� ��)
    SetLength(VisibleColRights, mHeadCol);

    VisibleColIdx := 0;
    CurrentColPos := HeaderRect.Left;

    for c := 0 to mHeadCol - 1 do
    begin
        if mVisibleCols[c] then
        begin
            VisibleColLefts[c] := CurrentColPos;
      // ColPos �迭�� �������� �÷��� ������ ��� ��ġ�� �����Ͽ� �����Ѵٰ� ����
            if VisibleColIdx < Length(ColPos) then
            begin
                VisibleColRights[c] := ColPos[VisibleColIdx];
                VisibleColWidths[VisibleColIdx] := ColPos[VisibleColIdx] - CurrentColPos; // ���� ���� �÷��� �ʺ�
                CurrentColPos := VisibleColRights[c]; // ���� ���� �÷��� ���� ��ġ ������Ʈ
            end
            else
            begin
        // ColPos �迭�� ũ�Ⱑ ������ ����� ó�� (��: ������ ���� �÷��� ���� ���� �Ҵ�)
                VisibleColRights[c] := HeaderRect.Right;
                VisibleColWidths[VisibleColIdx] := HeaderRect.Right - CurrentColPos;
                CurrentColPos := HeaderRect.Right;
            end;
            Inc(VisibleColIdx);
        end
        else
        begin
            VisibleColLefts[c] := -1; // ���� �÷�
            VisibleColRights[c] := -1; // ���� �÷�
        end;
    end;

    ColHeight := (HeaderRect.Bottom - HeaderRect.Top) div mHeadRow;
    Canvas.Font.Height := Trunc(ColHeight * 0.7);
    SetTextAlign(Canvas.Handle, TA_CENTER or TA_TOP);

    Canvas.Pen.Width := 3;
    Canvas.Rectangle(HeaderRect);
    Canvas.Pen.Width := 1;
    Canvas.Pen.Color := mFixedLineColor; // ���� ���� ����

  // 2. ���μ� �׸��� (�������� �÷��� ���)
    y := HeaderRect.Top + ColHeight;
    for l := 0 to mHeadRow - 1 do
    begin
    // �� ���� �������� HeaderRect.Left
        CurrentColPos := HeaderRect.Left;
        Canvas.MoveTo(CurrentColPos, y); // �׻� ����� ���ʿ��� ����

        for c := 0 to mHeadCol - 1 do
        begin
            if not mVisibleCols[c] then
                continue;

      // ���� ���� �÷��� ���� ������ X ��ǥ
            CurrentColPos := VisibleColRights[c];

      // ���� ���� Line �Ӽ��� ���� ���� Line �Ӽ��� ���Ͽ� ���� �׸��� ����
            if (not prvLine) and mHead[l][c].Line then
                Canvas.MoveTo(CurrentColPos, y)
            else if (prvLine) and (not mHead[l][c].Line) then
                Canvas.LineTo(CurrentColPos, y);

            prvLine := mHead[l][c].Line;
        end;
    // ������ �������� �÷����� ���� �׸�
        Canvas.LineTo(HeaderRect.Right, y); // HeaderRect�� ������ ���� �׸�
        y := y + ColHeight;
    end;

  // 3. ���μ� �׸��� (�������� �÷��� ���)
    for c := 0 to mHeadCol - 1 do
    begin
        if not mVisibleCols[c] then
            continue;

    // ���� ���� �÷��� ���� ������ X ��ǥ
        CellRight := VisibleColRights[c];

    // ���� �������� �÷��� ���ų� (��, ���� �÷��� ������ ������ �÷�),
    // �Ǵ� ���� ������ �÷��� �ٷ� ���� �پ����� ���� ��쿡�� ���� �׸���.
        if (GetNextVisibleCol(c) = -1) or (GetNextVisibleCol(c) > c + 1) then
        begin
            Canvas.MoveTo(CellRight, HeaderRect.Top);
            Canvas.LineTo(CellRight, HeaderRect.Bottom);
        end;
    end;

  // 4. ���� ��� (�������� �÷���)
    Canvas.Font.Color := mTextColor; // �ؽ�Ʈ ���� ����
    if mTextBold then
        Canvas.Font.Style := [fsBold]
    else
        Canvas.Font.Style := []; // �ؽ�Ʈ ���� ����

    y := HeaderRect.Top + (ColHeight div 2) - (Canvas.Font.Height div 2);
    for l := 0 to mHeadRow - 1 do
    begin
        VisibleColIdx := 0; // �� ������ ����Ͽ� �������� �÷��� ����

        for c := 0 to mHeadCol - 1 do
        begin
            if not mVisibleCols[c] then
                continue;

      // ���� ���� ���յ� ���� ���� ������ Ȯ��
      // ColCount = 1�� �ƴ϶�, ColCount�� VisibleColIdx�� ������ ��� ��, ���յ� ���� ������ �������� �÷��� ���
      // �Ǵ� ���յ��� ���� ���� ���� ��� (ColCount = 1)
            if (mHead[l][c].ColCount > 0) and (mHead[l][c].StartCell = c) and (mHead[l][c].StartRow = l) then
            begin
        // ���յ� ���� �ؽ�Ʈ�� �׸� ������ ����մϴ�.
        // ���յ� ���� ���� �÷��� �� �÷��� ���� �μ� ��ġ�� ����մϴ�.
                CellLeft := VisibleColLefts[mHead[l][c].StartCell];
                CellRight := VisibleColRights[mHead[l][c].StartCell + mHead[l][c].ColCount - 1]; // ���յ� ������ �÷��� ������ ��

        // �ؽ�Ʈ Rect ����
                TextRect.Left := CellLeft;
                TextRect.Right := CellRight;
        // ���յ� ���� �߾ӿ� ������ Top/Bottom ���
                TextRect.Top := HeaderRect.Top + (mHead[l][c].StartRow * ColHeight) + ((mHead[l][c].RowCount - 1) * ColHeight) div 2;
                TextRect.Bottom := TextRect.Top + Canvas.Font.Height;

                DrawText(Canvas.Handle, PChar(mHead[l][c].Caption), Length(mHead[l][c].Caption), TextRect, DT_CENTER or DT_VCENTER or DT_SINGLELINE);
            end;
            Inc(VisibleColIdx); // ���� ���� �÷����� �̵�
        end;
        y := y + ColHeight; // ���� ���� Y ��ġ
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
    Result := -1; // ���� �������� �÷��� ������ ��Ÿ��
    for i := ACol + 1 to mHeadCol - 1 do
        if mVisibleCols[i] then
        begin
            Result := i;
            Break; // ã���� ���� ����
        end;
end;

function TGridTitle.GetPrevVisibleCol(ACol: integer): integer;
var
    i: integer;
begin
    Result := -1; // ���� �������� �÷��� ������ ��Ÿ��
    for i := ACol - 1 downto 0 do
        if mVisibleCols[i] then
        begin
            Result := i;
            Break; // ã���� ���� ����
        end;
end;

procedure TGridTitle.SetColumnRatio(ACol: integer; Ratio: double);
var
    i: integer;
begin
    if (ACol >= 0) and (ACol < mHeadCol) then
    begin
        mColRatios[ACol] := Ratio;

        // �ش� �÷��� ��� ��� ���� ���� ����
        for i := 0 to mHeadRow - 1 do
            mHead[i][ACol].WidthRatio := Ratio;

        // ������ 0 ���ϸ� ����, �ƴϸ� ����
        if Ratio <= 0 then
            SetColumnVisible(ACol, false)
        else
            SetColumnVisible(ACol, true);

        // �÷� �ʺ� ���� �� ����
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

        // �ش� �÷��� ��� ��� ���� ���� ����
        for j := 0 to mHeadRow - 1 do
            mHead[j][i].WidthRatio := ColRatios[i];

        // ������ 0 ���ϸ� ����
        if ColRatios[i] <= 0 then
            mVisibleCols[i] := false
        else
            mVisibleCols[i] := true;
    end;

    // �÷� �ʺ� ���� �� ����
    ApplyColumnWidths;
end;

procedure TGridTitle.ApplyColumnWidths;
var
    i, TotalWidth, UsedWidth: Integer;
    RatioSum: double;
    ColWidths: array of Integer;
    VisibleCount: integer;
begin
    // �������� �÷��� ���� �հ� ���
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

    // ��� ������ ��ü �ʺ� (�׸��� ���� ����)
    TotalWidth := mGrid.ClientWidth;
    if TotalWidth <= 0 then
        TotalWidth := mGrid.Width;

    // �׸��� ���� �ʺ� �� �ʺ񿡼� ���� (�������� �÷� ���̿��� ������ �׷����Ƿ� VisibleCount-1)
    if VisibleCount > 0 then
        TotalWidth := TotalWidth - (VisibleCount - 1) * mGrid.GridLineWidth;

    SetLength(ColWidths, mHeadCol);
    UsedWidth := 0;
    VisibleCount := 0; // �ٽ� ī��Ʈ (��Ȯ���� ����)

    // �� �÷� �ʺ� ���
    for i := 0 to mHeadCol - 1 do
    begin
        if mVisibleCols[i] and (mColRatios[i] > 0) then
        begin
            if VisibleCount < GetVisibleColCount - 1 then
            begin
                // ������ �������� �÷��� �ƴϸ� �ݿø��Ͽ� �ʺ� �Ҵ�
                ColWidths[i] := Round(TotalWidth * mColRatios[i] / RatioSum);
                UsedWidth := UsedWidth + ColWidths[i];
            end
            else
            begin
                // ������ �������� �÷��� ���� �ʺ� �Ҵ��Ͽ� ���� ����
                ColWidths[i] := TotalWidth - UsedWidth;
            end;
            Inc(VisibleCount);
        end
        else
            ColWidths[i] := -1;   // ������ �÷��� 0
    end;

    // ���� �׸��忡 ����
    for i := 0 to mHeadCol - 1 do
    begin
        if i < mGrid.ColCount then
            mGrid.ColWidths[i] := ColWidths[i];
    end;
    mGrid.Invalidate; // �׸��� �ٽ� �׸���
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

    // ���ü� �迭 �ʱ�ȭ
    SetLength(mVisibleCols, Col);
    SetLength(mColRatios, Col);
    for i := 0 to Col - 1 do
    begin
        mVisibleCols[i] := true;
        mColRatios[i] := 1.0;   // �⺻ ���� 1.0
    end;

    SetLength(mHead, Row);
    for i := 0 to Row - 1 do
    begin
        SetLength(mHead[i], Col);
        for j := 0 to Col - 1 do
        begin
            mHead[i][j].Visible := true;
            mHead[i][j].WidthRatio := 1.0;   // �⺻ ���� 1.0
        end;
    end;

    if mRowHeight > 0 then
        RowH := mRowHeight
    else
        RowH := Grid.DefaultRowHeight;

    mGrid.RowHeights[0] := mGrid.DefaultRowHeight * mHeadRow;

    Grid.ColCount := Col;
    //Grid.RowCount := Row;
    ApplyColumnWidths; // Rebuild �� �ʱ� �÷� �ʺ� ����
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

        // �ش� �÷��� ��� ��� ���� ���ü� ����
        for i := 0 to mHeadRow - 1 do
            mHead[i][ACol].Visible := Visible;

        // ���� ó�� �� ������ 0���� ����, ���� ó�� �� �⺻ ���� 1.0���� ���� (����� ������ ���� ���)
        if not Visible then
        begin
            mColRatios[ACol] := 0;
            for i := 0 to mHeadRow - 1 do
                mHead[i][ACol].WidthRatio := 0;
        end
        else
        begin
            // �̹� ������ ������ 0�� �ƴϸ� ����, 0�̸� 1.0���� �ʱ�ȭ
            if mColRatios[ACol] <= 0 then
            begin
                mColRatios[ACol] := 1.0;
                for i := 0 to mHeadRow - 1 do
                    mHead[i][ACol].WidthRatio := 1.0;
            end;
        end;

        // �÷� �ʺ� ���� �� ����
        ApplyColumnWidths;
        mGrid.Invalidate; // �׸��� �ٽ� �׸���
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

