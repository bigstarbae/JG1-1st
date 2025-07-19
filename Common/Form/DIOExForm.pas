unit DIOExForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, BaseDIO, ExtCtrls, MagneticForm;

type
  TfrmDIOEx = class(TfrmMagnetic)
    sgDIO: TStringGrid;
    tmrPoll: TTimer;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure sgDIODrawCell(Sender: TObject; ACol, ARow: Integer; ARect: TRect; State: TGridDrawState);
    procedure sgDIOMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure tmrPollTimer(Sender: TObject);
  private
    { Private declarations }
        mDIO: TBaseDIO;

        mDICounts: array of integer;
        mDOCounts: array of integer;

        mDOStartCol: integer;

  public
    { Public declarations }
        class var mIsShow: boolean;

        procedure Init(DIO: TBaseDIO; DICounts, DOCounts: array of integer; HdrTitles: array of string);
        procedure AddExtraDO(Ch: Integer; ChName: string);
        function LoadNames(FileName: string): boolean;
  end;

var
  frmDIOEx: TfrmDIOEx;

implementation
uses
    IniFiles, Math, MyUtils, URect;

{$R *.dfm}

procedure TfrmDIOEx.FormShow(Sender: TObject);
begin
//
    mIsShow := true;

    ClientWidth :=  sgDIO.DefaultColWidth * sgDIO.ColCount + (1 * sgDIO.ColCount);
    ClientHeight := sgDIO.DefaultRowHeight * sgDIO.RowCount + (1 * sgDIO.RowCount);

end;

procedure TfrmDIOEx.AddExtraDO(Ch: Integer; ChName: string);    // TO DO : 검증 필요 24.11.05
var
    LastIdx: Integer;
begin
    if Length(mDOCounts) = 0 then
        raise Exception.Create('Init 함수를 먼저 호출하세요');

    LastIdx := Length(mDOCounts) - 1;
    if mDOCounts[LastIdx] >= (sgDIO.RowCount - 1) then
    begin
        SetLength(mDOCounts, Length(mDOCounts) + 1);
        LastIdx := Length(mDOCounts) - 1;
        mDOCounts[LastIdx] := 0;
        sgDIO.ColCount := sgDIO.ColCount + 1;
        ClientWidth :=  sgDIO.DefaultColWidth * sgDIO.ColCount + (1 * sgDIO.ColCount);
    end;

    LastIdx := Length(mDOCounts) - 1;
    Inc(mDOCounts[LastIdx]);

    sgDIO.Objects[sgDIO.ColCount - 1, mDOCounts[LastIdx]] := TObject(Ch);
    sgDIO.Cells[sgDIO.ColCount - 1, mDOCounts[LastIdx]] := ChName;
end;

procedure TfrmDIOEx.FormClose(Sender: TObject; var Action: TCloseAction);
begin
//
    mDICounts := nil;
    mDOCounts := nil;

    mIsShow := false;

    Action := caFree;
end;

procedure TfrmDIOEx.Init(DIO: TBaseDIO; DICounts, DOCounts: array of integer; HdrTitles: array of string);
var
    MaxRowCount, ColCount,
    Ch, i, j: integer;

begin
    mDIO := DIO;

    SetLength(mDICounts, Length(DICounts));
    SetLength(mDOCounts, Length(DOCounts));

    MaxRowCount := -999;

    for i := 0 to Length(DICounts) - 1 do
    begin
        if DICounts[i] > MaxRowCount then
            MaxRowCount := DICounts[i];

        mDICounts[i] := DICounts[i];
    end;

    for i := 0 to Length(DOCounts) - 1 do
    begin
        if DOCounts[i] > MaxRowCount then
            MaxRowCount := DOCounts[i];
        mDOCounts[i] := DOCounts[i];
    end;


    mDOStartCol := Length(DICounts);

    sgDIO.ColCount := Length(DICounts) + Length(DOCounts);
    sgDIO.RowCount := MaxRowCount + 1;

    ColCount := Max(sgDIO.ColCount, Length(HdrTitles));

    for i := 0 to ColCount - 1 do
    begin
        sgDIO.Cells[i, 0] := HdrTitles[i];
    end;

    Ch := 0;
    for i := 0 to Length(mDICounts) - 1 do
    begin
        for j := 0 to mDICounts[i] - 1 do
        begin
            sgDIO.Objects[i, j + 1] := TObject(Ch);
            Inc(Ch);
        end;
    end;

    Ch := mDIO.DOStartCh;

    for i := 0 to Length(mDOCounts) - 1 do
    begin
        for j := 0 to mDOCounts[i] - 1 do
        begin
            sgDIO.Objects[mDOStartCol + i, j + 1] := TObject(Ch);
            Inc(Ch);
        end;
    end;


end;


function TfrmDIOEx.LoadNames(FileName: string): boolean;
var
    IniFile: TIniFile;
    Ch, i, j: integer;
begin
    if not FileExists(FileName) then
        Exit(false);

    Result := true;
    IniFile := TIniFile.Create(FileName);
    try
        Ch := 0;
        for i := 0 to Length(mDICounts) - 1 do
        begin
            for j := 0 to mDICounts[i] - 1 do
            begin
                sgDIO.Cells[i, j + 1] := IniFile.ReadString('PCIN_IO0-0', 'INDEX ' + IntToStr(Ch + 1), '');
                Inc(Ch);
            end;
        end;

        Ch := 0;
        for i := 0 to Length(mDOCounts) - 1 do
        begin
            for j := 0 to mDOCounts[i] - 1 do
            begin
                sgDIO.Cells[mDOStartCol + i, j + 1] := IniFile.ReadString('PCOUT_IO0-0', 'INDEX ' + IntToStr(Ch + 1), '');
                Inc(Ch);
            end;
        end;

    finally
        IniFile.Free;
    end;
end;

procedure TfrmDIOEx.sgDIODrawCell(Sender: TObject; ACol, ARow: Integer; ARect: TRect; State: TGridDrawState);
var
    FontColor, BkColor: TColor;
    CellStr: string;
    Ch, StdWSize, LampTDMargin: Integer;
    LampRect: TRect;
    Grid: TStringGrid;
label
    DEFAULT_DRAW;

    function GetInvertColor(Color: TColor): TColor;
    begin
        if ((GetRValue(Color) + GetGValue(Color) + GetBValue(Color)) > 384) then
            Result := clBlack
        else
            Result := clWhite;
    end;

begin
    Grid := TStringGrid(Sender);
    Grid.Canvas.Font := Grid.Font;

    StdWSize := Round(ARect.Width / 25);
    LampTDMargin := Round(ARect.Height * 0.32);
    LampRect := Rect(Round(ARect.Left + StdWSize * 0.8), ARect.Top + LampTDMargin, Round(ARect.Left + StdWSize * 4.0), ARect.Bottom - LampTDMargin);

    BkColor := Grid.Color;
    CellStr := Grid.Cells[ACol, ARow];


    if ARow = 0 then
    begin
        FontColor := GetInvertColor(Grid.FixedColor);
        BkColor := Grid.FixedColor;
    end
    else
    begin
        Grid.Canvas.Font.Size := Grid.Canvas.Font.Size - 3;
        FontColor := clBlack;
        Ch :=  integer(Grid.Objects[ACol, ARow]);

        if (ACol < mDOStartCol)  then
        begin
            if ((ARow - 1) >= mDICounts[ACol]) then  goto DEFAULT_DRAW;
            Grid.Canvas.Font.Color := clBlack;
            Grid.Canvas.Brush.Color := BkColor;
            Grid.Canvas.FillRect(ARect);
            CellStr := Grid.Cells[ACol, ARow];
            if mDIO.IsIO(Ch) then
            begin
                Grid.Canvas.Brush.Color := clRed;
            end
            else
            begin
                Grid.Canvas.Brush.Color := clGray;
            end;
            Grid.Canvas.Rectangle(LampRect.Left, LampRect.Top, LampRect.Right, LampRect.Bottom);
            SetBkMode(Grid.Canvas.Handle, TRANSPARENT);
            Grid.Canvas.TextOut(LampRect.Right + 7, ARect.Top + 3, CellStr);

            Exit;
        end
        else
        begin
            if ((ARow - 1) >= mDOCounts[ACol - mDOStartCol]) then  goto DEFAULT_DRAW;
            CellStr := Grid.Cells[ACol, ARow];
            if mDIO.IsIO(Ch) then
            begin
                DrawFrameControl(Grid.Canvas.Handle, ARect, DFC_BUTTON, DFCS_BUTTONPUSH or DFCS_PUSHED);
                Grid.Canvas.Brush.Color := clRed;

            end
            else
            begin
                DrawFrameControl(Grid.Canvas.Handle, ARect, DFC_BUTTON, DFCS_BUTTONPUSH);
                Grid.Canvas.Brush.Color := clGray;
            end;

            Grid.Canvas.Rectangle(LampRect.Left, LampRect.Top, LampRect.Right, LampRect.Bottom);
            SetBkMode(Grid.Canvas.Handle, TRANSPARENT);
            Grid.Canvas.TextOut(LampRect.Right + 7, ARect.Top + 3, CellStr);
            Exit;
        end;

    end;

DEFAULT_DRAW:

    SetBkMode(Grid.Canvas.Handle, TRANSPARENT);
    Grid.Canvas.Font.Color := FontColor;
    Grid.Canvas.Brush.Color := BkColor;
    Grid.Canvas.FillRect(ARect);
    DrawText(Grid.Canvas.Handle, CellStr, Length(CellStr), ARect, DT_CENTER or DT_VCENTER or DT_SINGLELINE);
end;

procedure TfrmDIOEx.sgDIOMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
    Ch, Col, Row: integer;
begin
    sgDIO.MouseToCell(X, Y, Col, Row);

    if Row > 0 then
    begin
        if Col >= mDOStartCol then
        begin
            Ch :=  integer(sgDIO.Objects[Col, Row]);
            if (Row - 1) < mDOCounts[Col - mDOStartCol] then
                mDIO.SetIO(Ch, not mDIO.IsIO(Ch));
        end;

    end;

end;

procedure TfrmDIOEx.tmrPollTimer(Sender: TObject);
begin
    sgDIO.Repaint;

end;

end.
