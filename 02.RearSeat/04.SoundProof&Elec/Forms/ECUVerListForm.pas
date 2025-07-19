unit ECUVerListForm;

interface

uses
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, Grids, ECUVerList, IniFiles, ReferBaseForm, KiiMessages;

type
    TfrmECUVerList = class(TfrmReferBase)
        sgECUVerList: TStringGrid;
        procedure FormShow(Sender: TObject);
        procedure FormCreate(Sender: TObject);
        procedure FormClose(Sender: TObject; var Action: TCloseAction);
        procedure sgECUVerListKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);

    private
        { Private declarations }
        mEVL: TECUVerList;

        function Save: boolean; override;
        procedure ReadMessage(var myMsg: TMessage); message WM_SYS_CODE;
        procedure CalcGridSize;
    public
        { Public declarations }

        procedure SetForm(EVL: TECUVerList);

    end;

var
    frmECUVerList: TfrmECUVerList;

implementation

uses
    SysEnv, GridUtils, Math;

{$R *.dfm}
{ TForm1 }
function MakeTArray(const OpenArr: array of double): TArray<double>;
var
    i: Integer;
begin
    SetLength(Result, Length(OpenArr));
    for i := 0 to High(OpenArr) do
        Result[i] := OpenArr[i];
end;

procedure TfrmECUVerList.CalcGridSize;
var
    Gap, Size, TotalWidth, AvailableWidth, i: Integer;
    Ratio: Double;
    ColRatios, RowRatios: TArray<double>;
    RoundingError: Integer;
begin
    AvailableWidth := sgECUVerList.ClientWidth;

    ColRatios := MakeTArray([0.6, 1, 1, 0.7, 0.7, 1, 0.7, 0.7]);

    SetGridColWidths(sgECUVerList, ColRatios);

    TotalWidth := 0;
    for i := 0 to sgECUVerList.ColCount - 1 do
        TotalWidth := TotalWidth + sgECUVerList.ColWidths[i];

    // 너비 조정
    if TotalWidth <> AvailableWidth then
    begin
        if TotalWidth > AvailableWidth then
        begin
            // 축소 필요
            Ratio := AvailableWidth / TotalWidth;
            RoundingError := 0;

            for i := 0 to sgECUVerList.ColCount - 1 do
            begin
                if sgECUVerList.ColWidths[i] > 0 then // 숨겨진 컬럼 제외
                begin
                    sgECUVerList.ColWidths[i] := Max(Round(sgECUVerList.ColWidths[i] * Ratio), 30);
                    RoundingError := RoundingError + sgECUVerList.ColWidths[i];
                end;
            end;

            // 반올림 오차 보정 (마지막 보이는 컬럼에 적용)
            RoundingError := AvailableWidth - RoundingError;
            if RoundingError <> 0 then
            begin
                for i := sgECUVerList.ColCount - 1 downto 0 do
                begin
                    if sgECUVerList.ColWidths[i] > 0 then // 마지막 보이는 컬럼 찾기
                    begin
                        sgECUVerList.ColWidths[i] := sgECUVerList.ColWidths[i] + RoundingError;
                        Break;
                    end;
                end;
            end;
        end
        else
        begin
            // 확대 필요 - 마지막 보이는 컬럼에 여유 공간 추가
            for i := sgECUVerList.ColCount - 1 downto 0 do
            begin
                if sgECUVerList.ColWidths[i] > 0 then // 마지막 보이는 컬럼 찾기
                begin
                    sgECUVerList.ColWidths[i] := sgECUVerList.ColWidths[i] + (AvailableWidth - TotalWidth);
                    Break;
                end;
            end;
        end;
    end;
end;


procedure TfrmECUVerList.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    Action := caFree;
end;

procedure TfrmECUVerList.FormCreate(Sender: TObject);
begin
    //
end;

procedure TfrmECUVerList.FormShow(Sender: TObject);
var
    i: integer;
begin

    with sgECUVerList do
    begin
        Cells[0, 0] := 'NO';
        Cells[1, 0] := 'PART NO';
        Cells[2, 0] := 'HVPSU PART NO';
        Cells[3, 0] := 'HVPSU SW VER.';
        Cells[4, 0] := 'HVPSU HW VER.';
        Cells[5, 0] := 'SAU PART NO';
        Cells[6, 0] := 'SAU SW VER.';
        Cells[7, 0] := 'SAU HW VER.';

        RowCount := MAX_ECU_VER_ITEM_COUNT + 1;
    end;

    CalcGridSize();

    if not Assigned(mEVL) then
        Exit;

    for i := 0 to MAX_ECU_VER_ITEM_COUNT - 1 do
    begin
        sgECUVerList.Cells[0, i + 1] := IntToStr(i + 1);
        sgECUVerList.Cells[1, i + 1] := mEVL.mItems[i].mPartNo;
        sgECUVerList.Cells[2, i + 1] := mEVL.mItems[i].mECUPartNo;
        sgECUVerList.Cells[3, i + 1] := mEVL.mItems[i].mECUSwVer;
        sgECUVerList.Cells[4, i + 1] := mEVL.mItems[i].mECUHwVer;
//        sgECUVerList.Cells[5, i + 1] := mEVL.mItems[i].mECUPSUPartNo;
//        sgECUVerList.Cells[6, i + 1] := mEVL.mItems[i].mECUPSUSwVer;
//        sgECUVerList.Cells[7, i + 1] := mEVL.mItems[i].mECUPSUHwVer;
    end;
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
        mEVL.mItems[i].mPartNo := Trim(sgECUVerList.Cells[1, i + 1]);
        mEVL.mItems[i].mECUPartNo := Trim(sgECUVerList.Cells[2, i + 1]);
        mEVL.mItems[i].mECUSwVer := Trim(sgECUVerList.Cells[3, i + 1]);
        mEVL.mItems[i].mECUHwVer := Trim(sgECUVerList.Cells[4, i + 1]);
//        mEVL.mItems[i].mECUPSUPartNo := Trim(sgECUVerList.Cells[5, i + 1]);
//        mEVL.mItems[i].mECUPSUSwVer := Trim(sgECUVerList.Cells[6, i + 1]);
//        mEVL.mItems[i].mECUPSUHwVer := Trim(sgECUVerList.Cells[7, i + 1]);
    end;

    FilePath := GetEnvPath('ECUVerList.ini');
    Result := mEVL.Save(FilePath);
    mIsChanged := not Result;
    if Assigned(mChangeEvent) then
        OnUserChange(Self, integer(mIsChanged));
end;

procedure TfrmECUVerList.sgECUVerListKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
    mIsChanged := true;
    if Assigned(mChangeEvent) then
        OnUserChange(Self, integer(mIsChanged));
end;

procedure TfrmECUVerList.SetForm(EVL: TECUVerList);
begin
    mEVL := EVL;
end;

end.

