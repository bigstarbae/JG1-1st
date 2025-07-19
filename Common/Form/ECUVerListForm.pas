unit ECUVerListForm;

interface

uses
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, Grids, ECUVerList,
     IniFiles, ReferBaseForm, KiiMessages, StdCtrls,
    ExtCtrls;

type
    TfrmECUVerList = class(TfrmReferBase)
        sgECUInfoList: TStringGrid;
        pnlSearch: TPanel;
        edtSrch: TEdit;
        btnSrch: TButton;
        procedure FormShow(Sender: TObject);
        procedure FormCreate(Sender: TObject);
        procedure FormClose(Sender: TObject; var Action: TCloseAction);
        procedure sgECUInfoListKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
        procedure btnSrchClick(Sender: TObject);
        procedure edtSrchKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
        procedure sgECUInfoListMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);

    private
        { Private declarations }
        mEVL: TECUVerList;
        mHint: TBalloonHint;

        function Save: boolean; override;

        procedure ReadMessage(var myMsg: TMessage); message WM_SYS_CODE;
        procedure SortGridByCol(SelCol: Integer);

        function SelSeatPartNo(PartNo: string): boolean;
    public
        { Public declarations }

        procedure SetForm(EVL: TECUVerList);

    end;

var
    frmECUVerList: TfrmECUVerList;

implementation

uses
    GridUtils, SysEnv;

{$R *.dfm}

{ TfrmECUVerList }

var
    gLastPartNo: string;

function TfrmECUVerList.SelSeatPartNo(PartNo: string): boolean;
var
    i: integer;
begin
    Result := false;

    PartNo := Trim(PartNo);

    if PartNo = '' then
        Exit;


    for i := sgECUInfoList.FixedRows to sgECUInfoList.RowCount - 1 do
        if Pos(PartNo, Trim(sgECUInfoList.Cells[1, i])) > 0 then
        begin
            sgECUInfoList.TopRow := i;
            sgECUInfoList.Row := i;
            gLastPartNo := Trim(PartNo);
            Exit(true);
        end;

    sgECUInfoList.Row := sgECUInfoList.FixedRows;
end;

procedure TfrmECUVerList.btnSrchClick(Sender: TObject);
var
    R: TRect;

    procedure MoveToEmptyRow;
    var
        i: Integer;
    begin
        for i := 1 to sgECUInfoList.RowCount - 1 do
        begin
            if (sgECUInfoList.Cells[1, i] = '') and (sgECUInfoList.Cells[2, i] = '') and (sgECUInfoList.Cells[3, i] = '') then
            begin
                sgECUInfoList.Row := i;
                Break;
            end;
        end;

    end;

begin
    if not SelSeatPartNo(edtSrch.Text) then
    begin
        mHint.Description := '해당 P/NO를 발견하지 못했습니다';
        R := edtSrch.BoundsRect;
        R.TopLeft := ClientToScreen(R.TopLeft);
        R.BottomRight := ClientToScreen(R.BottomRight);
        mHint.ShowHint(R);

        MoveToEmptyRow;
    end;

end;

procedure TfrmECUVerList.edtSrchKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
    if Key = VK_RETURN then
        btnSrch.Click;

end;

procedure TfrmECUVerList.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    Action := caFree;
end;

procedure TfrmECUVerList.FormCreate(Sender: TObject);
begin
    mHint := TBalloonHint.Create(Self);
    mHint.HideAfter := 3000;
    mHint.Delay := 0;
end;

procedure TfrmECUVerList.FormShow(Sender: TObject);
var
    i: integer;
begin

    with sgECUInfoList do
    begin
        Cells[0, 0] := 'NO';
        Cells[1, 0] := 'SEAT PART NO';
        Cells[2, 0] := 'ECU PART NO';
        Cells[3, 0] := 'ECU SW VER.';
        Cells[4, 0] := 'ECU HW VER.';

        RowCount := MAX_ECU_VER_ITEM_COUNT + 1;
    end;

    if not Assigned(mEVL) then
        Exit;

    for i := 0 to MAX_ECU_VER_ITEM_COUNT - 1 do
    begin
        sgECUInfoList.Cells[0, i + 1] := IntToStr(i + 1);
        sgECUInfoList.Cells[1, i + 1] := mEVL.mItems[i].mPartNo;
        sgECUInfoList.Cells[2, i + 1] := mEVL.mItems[i].mECUPartNo;
        sgECUInfoList.Cells[3, i + 1] := mEVL.mItems[i].mECUSwVer;
        sgECUInfoList.Cells[4, i + 1] := mEVL.mItems[i].mECUHwVer;
    end;

    SortGridByCol(1);

end;

procedure TfrmECUVerList.ReadMessage(var myMsg: TMessage);
begin
    case myMsg.WParam of
        SYS_SAVE_DATA:
            Save;
    end;
end;

function TfrmECUVerList.Save: boolean;
var
    Ini: TIniFile;
    FilePath: string;
    i: integer;
begin

    if not Assigned(mEVL) then
        Exit;

    for i := 0 to MAX_ECU_VER_ITEM_COUNT - 1 do
    begin
        mEVL.mItems[i].mPartNo := Trim(sgECUInfoList.Cells[1, i + 1]);
        mEVL.mItems[i].mECUPartNo := Trim(sgECUInfoList.Cells[2, i + 1]);
        mEVL.mItems[i].mECUSwVer := Trim(sgECUInfoList.Cells[3, i + 1]);
        mEVL.mItems[i].mECUHwVer := Trim(sgECUInfoList.Cells[4, i + 1]);
    end;

    FilePath := GetEnvPath('ECUVerList.ini');
    Result := mEVL.Save(FilePath);

    mIsChanged := not Result;
    if Assigned(mChangeEvent) then
        OnUserChange(Self, integer(mIsChanged));

end;

procedure TfrmECUVerList.sgECUInfoListKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
    mIsChanged := true;
    if Assigned(mChangeEvent) then
        OnUserChange(Self, integer(mIsChanged));
end;

procedure TfrmECUVerList.sgECUInfoListMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
    SelCol, SelRow: Integer;
begin

    SelCol := sgECUInfoList.MouseCoord(X, Y).X;
    SelRow := sgECUInfoList.MouseCoord(X, Y).Y;

    if (SelCol < sgECUInfoList.FixedCols) or (SelCol > 2) or (SelRow >= sgECUInfoList.FixedRows) then
        Exit;

    SortGridByCol(SelCol);
end;

procedure TfrmECUVerList.SortGridByCol(SelCol: Integer);
var
    SortDir: Boolean;

    procedure RenumberGridNo;
    var
        i: integer;
    begin
        for i := 1 to sgECUInfoList.RowCount - 1 do
        begin
            sgECUInfoList.Cells[0, i] := IntToStr(i);
        end;
    end;

    procedure UpdateSortMark(ACol: Integer; Ascending: Boolean);
    var
        i: Integer;
        Mark: string;
    begin
        if Ascending then
            Mark := ' ▲'
        else
            Mark := ' ▼';

        for i := 0 to sgECUInfoList.ColCount - 1 do
        begin
            sgECUInfoList.Cells[i, 0] := StringReplace(sgECUInfoList.Cells[i, 0], ' ▲', '', [rfReplaceAll]);
            sgECUInfoList.Cells[i, 0] := StringReplace(sgECUInfoList.Cells[i, 0], ' ▼', '', [rfReplaceAll]);
        end;

        sgECUInfoList.Cells[ACol, 0] := sgECUInfoList.Cells[ACol, 0] + Mark;
    end;

begin

    SortDir := Boolean(sgECUInfoList.Objects[SelCol, 0]);
    SortDir := not SortDir;
    sgECUInfoList.Objects[SelCol, 0] := TObject(SortDir);

    UpdateSortMark(SelCol, SortDir);

    SortStringGrid(sgECUInfoList, SelCol, SortDir);

    RenumberGridNo;
end;

procedure TfrmECUVerList.SetForm(EVL: TECUVerList);
begin
    mEVL := EVL;
end;

end.

