unit ADForm;

interface

uses
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, ReferBaseForm, Dialogs, Grids, TeeChartUtil, ExtCtrls, TeEngine, Series, TeeProcs,
    Chart, BaseAD, StdCtrls, ComCtrls, Label3D, Buttons, MMTimer;

type
    TfrmAD = class(TfrmReferBase)
        sgAD: TStringGrid;
        Splitter1: TSplitter;
        pnlChart: TPanel;
        chtAD: TChart;
        FastLineSeries6: TFastLineSeries;
        tmrPoll: TTimer;
        lblADName: TLabel;
        tbcStations: TTabControl;
        udMin: TUpDown;
        udMax: TUpDown;
        Panel2: TPanel;
        lblValue: TLabel3D;
        lblVolt: TLabel3D;
        btnSave: TButton;
        sbtnZero: TSpeedButton;
        sbtnResetZero: TSpeedButton;
        rgReadType: TRadioGroup;
        chkAutoScale: TCheckBox;
        procedure sgADDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
        procedure FormClose(Sender: TObject; var Action: TCloseAction);
        procedure FormCreate(Sender: TObject);
        procedure FormShow(Sender: TObject);
        procedure sgADClick(Sender: TObject);
        procedure tmrPollTimer(Sender: TObject);
        procedure tbcStationsChange(Sender: TObject);
        procedure udMaxChangingEx(Sender: TObject; var AllowChange: Boolean; NewValue: SmallInt; Direction: TUpDownDirection);
        procedure udMinChangingEx(Sender: TObject; var AllowChange: Boolean; NewValue: SmallInt; Direction: TUpDownDirection);
        procedure sgADSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
        procedure btnSaveClick(Sender: TObject);
        procedure sgADSetEditText(Sender: TObject; ACol, ARow: Integer; const Value: string);
        procedure sgADKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
        procedure FormDestroy(Sender: TObject);
        procedure sbtnZeroClick(Sender: TObject);
        procedure sbtnResetZeroClick(Sender: TObject);
        procedure chkAutoScaleClick(Sender: TObject);
    private
    { Private declarations }
        mAD: TBaseAD;
        mADs: array of TBaseAD;
        mADNames: array of TStringList;

        mSC: TScrollChartHelper;

        mCurCh: Integer;

        mTimer: TMMTimer;

        procedure SaveADNameToIniFile(FilePath, StationName: string);
        procedure LoadADNamesFromIniFile(FilePath: string);
        procedure UpdateADNames(ADNames: TStringList);

        procedure PollingMMTimer(Sender: TObject);
    public
    { Public declarations }
        procedure AddAD(AD: TBaseAD; StationName: string);
    end;

var
    frmAD: TfrmAD;

implementation

uses
    MyUtils, IniFiles, SysEnv, Clipbrd;

{$R *.dfm}

function GetInvertColor(Color: TColor): TColor;
begin
    if ((GetRValue(Color) + GetGValue(Color) + GetBValue(Color)) > 384) then
        Result := clBlack
    else
        Result := clWhite;
end;

function IsZeroVal(Val: double): boolean;
begin
    Result := (-0.1 < Val) and (Val < 0.1);
end;

function IsPlusVal(Val: double): boolean;
begin
    Result := Val >= 0.1;
end;

procedure TfrmAD.btnSaveClick(Sender: TObject);
begin
    SaveADNameToIniFile(GetEnvPath('ADList.ini'), tbcStations.Tabs[tbcStations.TabIndex]);
end;

procedure TfrmAD.chkAutoScaleClick(Sender: TObject);
begin
    chtAD.LeftAxis.Automatic := chkAutoScale.Checked;
end;

procedure TfrmAD.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    mTimer.Free;

    Action := caFree;

    inherited;
end;

procedure TfrmAD.FormCreate(Sender: TObject);
begin
    inherited;
    mSC := TScrollChartHelper.Create(chtAD);

    mTimer := TMMTimer.Create(Self);
    mTimer.Interval := 10;
    mTimer.OnTimer := PollingMMTimer;
end;

procedure TfrmAD.FormDestroy(Sender: TObject);
var
    i: Integer;
begin

    mTimer.Enabled := False;

    for i := 0 to Length(mADNames) - 1 do
        mADNames[i].Free;

    mSC.Free;
end;

procedure TfrmAD.FormShow(Sender: TObject);
var
    i: Integer;
begin
    inherited;

    sgAD.Cells[0, 0] := 'CH';
    sgAD.Cells[1, 0] := 'NAME';
    sgAD.Cells[2, 0] := 'DIGIT';
    sgAD.Cells[3, 0] := 'VOLT';
    sgAD.Cells[4, 0] := 'VALUE';
    //

    chtAD.LeftAxis.Automatic := True;
    mSC.Start(10);

    LoadADNamesFromIniFile(GetEnvPath('ADList.ini'));

    for i := 0 to mAD.ChCount - 1 do
        mAD.ResetZero(i);

    mCurCh := -1;
    sgADClick(nil);
end;

procedure TfrmAD.SaveADNameToIniFile(FilePath, StationName: string);
var
    i: Integer;
    IniFile: TIniFile;
begin
    IniFile := TIniFile.Create(FilePath);

    try
        for i := 1 to sgAD.RowCount - 1 do
        begin
            IniFile.WriteString(StationName, IntToStr(i), sgAD.Cells[1, i]);
        end;
    finally
        IniFile.Free;
    end;

end;

procedure TfrmAD.UpdateADNames(ADNames: TStringList);
var
    i: Integer;
begin
    for i := 0 to ADNames.Count - 1 do
    begin
        sgAD.Cells[1, i + 1] := ADNames.Values[ADNames.Names[i]];
    end;
end;

procedure TfrmAD.LoadADNamesFromIniFile(FilePath: string);
var
    i, j: Integer;
    IniFile: TIniFile;
begin

    if not FileExists(FilePath) then
        Exit;

    IniFile := TIniFile.Create(FilePath);

    try
        for i := 0 to tbcStations.Tabs.Count - 1 do
        begin
            IniFile.ReadSectionValues(tbcStations.Tabs[i], mADNames[i]);
        end;

        UpdateADNames(mADNames[0]);
    finally
        IniFile.Free;
    end;

end;



procedure TfrmAD.AddAD(AD: TBaseAD; StationName: string);
var
    i: Integer;
    Idx: Integer;
begin
    Idx := Length(mADs);
    SetLength(mADs, Idx + 1);

    mADs[Idx] := AD;
    mAD := mADs[0];

    SetLength(mADNames, Idx + 1);
    mADNames[Idx] := TStringList.Create;

    tbcStations.Tabs.Add(StationName);

    sgAD.RowCount := mADs[0].ChCount + 1;

    for i := 0 to sgAD.RowCount - 1 do
    begin
        sgAD.Cells[0, i + 1] := 'CH' + IntToStr(i);
    end;

//    tmrPoll.Enabled := True;
    mTimer.Enabled := True;
end;

procedure TfrmAD.sbtnResetZeroClick(Sender: TObject);
begin

    mAD.ResetZero(mCurCh);
end;

procedure TfrmAD.sbtnZeroClick(Sender: TObject);
begin
    mAD.SetZero(mCurCh);
end;

procedure TfrmAD.sgADClick(Sender: TObject);
begin
    if mCurCh = sgAD.Row - 1 then
        Exit;

    sgAD.Cells[0, mCurCh + 1] := Format('CH%d', [mCurCh]);

    mCurCh := sgAD.Row - 1;

    sgAD.Cells[0, mCurCh + 1] := Format('¢ºCH%d¢¸', [mCurCh]);

    lblADName.Caption := Format('CH%d: %s', [mCurCh, sgAD.Cells[1, mCurCh + 1]]);

    mSC.Start(10);
end;

procedure TfrmAD.sgADDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
var
    FontColor, BkColor: TColor;
    CellStr: string;
    Ch: Integer;
    Grid: TStringGrid;
    Val: Double;

    function GetFontColorBySign(Val: Double): TColor;
    begin
        if IsPlusVal(Val) then
        begin
            Result := clBlue
        end
        else if IsZeroVal(Val) then
        begin
            Result := clBlack;
        end
        else
        begin
            Result := clRed;
        end;
    end;

begin
    Grid := TStringGrid(Sender);

    Grid.Canvas.Font := Grid.Font;

    FontColor := Grid.Font.Color;
    BkColor := Grid.Color;
    CellStr := Grid.Cells[ACol, ARow];

    if ARow = 0 then
    begin
        FontColor := GetInvertColor(Grid.FixedColor);
        BkColor := Grid.FixedColor;
    end
    else
    begin

        if Assigned(mAD) then
        begin
            Ch := ARow - 1;
            case ACol of
                0:
                    begin
                        FontColor := clBlack;
                    end;
                2:
                    begin
                        CellStr := IntToStr(mAD.GetDigital(Ch));
                    end;
                3:
                    begin
                        Val := mAD.GetVolt(Ch);
                        CellStr := Format('%f', [Val]);
                        FontColor := GetFontColorBySign(Val);
                    end;
                4:
                    begin
                        Val := mAD.GetValue(ARow - 1);
                        CellStr := Format('%f', [Val]);
                        FontColor := GetFontColorBySign(Val);
                    end;
            end;
        end;

    end;

    SetBkMode(Grid.Canvas.Handle, TRANSPARENT);
    Grid.Canvas.Font.Color := FontColor;
    Grid.Canvas.Brush.Color := BkColor;
    Grid.Canvas.FillRect(Rect);
    DrawText(Grid.Canvas.Handle, CellStr, Length(CellStr), Rect, DT_CENTER or DT_VCENTER or DT_SINGLELINE);

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

procedure TfrmAD.sgADKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
    if (LowerCase(Char(Key)) = 'v') and (Shift = [ssCtrl]) then
    begin
        PasteClipboardToGrid(sgAD, sgAD.Col, sgAD.Row);
        Key := 0;
    end;

end;

procedure TfrmAD.sgADSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
begin
    if ACol = 1 then
    begin
        sgAD.Options := sgAD.Options + [goEditing];
    end
    else
    begin
        sgAD.Options := sgAD.Options - [goEditing];
    end;
end;

procedure TfrmAD.sgADSetEditText(Sender: TObject; ACol, ARow: Integer; const Value: string);
begin
    btnSave.Visible := True;
end;

procedure TfrmAD.tbcStationsChange(Sender: TObject);
begin
    mAD := mADs[tbcStations.TabIndex];
    UpdateADNames(mADNames[tbcStations.TabIndex]);
end;

procedure TfrmAD.PollingMMTimer(Sender: TObject);
begin
    TThread.Synchronize(nil,
        procedure
        begin
            if not Assigned(mAD) or sgAD.EditorMode then
                Exit;

            sgAD.Repaint;

            if rgReadType.ItemIndex = 0 then
                mSC.Add([mAD.GetVolt(mCurCh)])
            else
                mSC.Add([mAD.GetValue(mCurCh)]);

            lblVolt.Caption := Format('%f', [mAD.GetVolt(mCurCh)]);
            lblValue.Caption := Format('%f', [mAD.GetValue(mCurCh)]);
        end
    );
end;

procedure TfrmAD.tmrPollTimer(Sender: TObject);
begin
    if not Assigned(mAD) or sgAD.EditorMode then
        Exit;

    sgAD.Repaint;

    if rgReadType.ItemIndex = 0 then
        mSC.Add([mAD.GetVolt(mCurCh)])
    else
        mSC.Add([mAD.GetValue(mCurCh)]);

    lblVolt.Caption := Format('%f', [mAD.GetVolt(mCurCh)]);
    lblValue.Caption := Format('%f', [mAD.GetValue(mCurCh)]);
end;

procedure TfrmAD.udMaxChangingEx(Sender: TObject; var AllowChange: Boolean; NewValue: SmallInt; Direction: TUpDownDirection);
begin
    if Direction = updUp then
    begin
        chtAD.LeftAxis.Maximum := chtAD.LeftAxis.Maximum + 0.5;
    end
    else
    begin
        if chtAD.LeftAxis.Minimum + 1 < chtAD.LeftAxis.Maximum then
            chtAD.LeftAxis.Maximum := chtAD.LeftAxis.Maximum - 0.5;
    end;
end;

procedure TfrmAD.udMinChangingEx(Sender: TObject; var AllowChange: Boolean; NewValue: SmallInt; Direction: TUpDownDirection);
begin
    if Direction = updUp then
    begin
        if chtAD.LeftAxis.Minimum < chtAD.LeftAxis.Maximum - 1 then
            chtAD.LeftAxis.Minimum := chtAD.LeftAxis.Minimum + 0.5;
    end
    else
    begin
        chtAD.LeftAxis.Minimum := chtAD.LeftAxis.Minimum - 0.5;
    end;

end;

end.

