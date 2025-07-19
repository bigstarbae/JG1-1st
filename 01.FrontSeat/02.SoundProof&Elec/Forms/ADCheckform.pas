{
    : Semi 범용처리
}
unit ADCheckform;

interface

uses
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, Buttons, StdCtrls, FaGraphEx, ExtCtrls,
    AbNumEdit, Grids, BaseAD, BaseCounter;

type
    TReqDAQObjFunc = reference to procedure (SatationIdx: Integer; var AD: TBaseAD; var CT: TBaseCounter) ;

    TfrmADChecker = class(TForm)
        tmrPoll: TTimer;
        Panel2: TPanel;
        fagrpChecker: TFaGraphEx;
        Panel3: TPanel;
        sgrdCount: TStringGrid;
        sgrdDaq: TStringGrid;
        Panel1: TPanel;
        Panel4: TPanel;
        Shape10: TShape;
        Shape1: TShape;
        Shape2: TShape;
        Label9: TLabel;
        Label1: TLabel;
        Label3: TLabel;
        Label4: TLabel;
        Label31: TLabel;
        Label32: TLabel;
        Label33: TLabel;
        Label34: TLabel;
        sbtnStart: TSpeedButton;
        sbtnStop: TSpeedButton;
        cbxChs: TComboBox;
        edtadxmax: TEdit;
        edtADxmin: TEdit;
        edtADxstep: TEdit;
        edtadymax: TEdit;
        edtadymin: TEdit;
        edtadystep: TEdit;
        Label8: TLabel;
        Shape5: TShape;
        Splitter1: TSplitter;
        cbxStation: TComboBox;
        sbtnSetZero: TSpeedButton;
        sbtnResetZero: TSpeedButton;
        Shape3: TShape;
        Label5: TLabel;
        cbxCTChs: TComboBox;
        Label6: TLabel;
        Shape6: TShape;
        sbtnSetZeroCT: TSpeedButton;
        sbtnResetZeroCT: TSpeedButton;
        pnlCTMask: TPanel;
        procedure FormClose(Sender: TObject; var Action: TCloseAction);
        procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
        procedure FormCreate(Sender: TObject);
        procedure FormDestroy(Sender: TObject);
        procedure FormShow(Sender: TObject);
        procedure tmrPollTimer(Sender: TObject);
        procedure sgrdCountDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
        procedure sbtnStartClick(Sender: TObject);
        procedure sbtnStopClick(Sender: TObject);
        procedure cbxChsChange(Sender: TObject);
        procedure cbxStationChange(Sender: TObject);
        procedure sbtnSetZeroClick(Sender: TObject);
        procedure sbtnResetZeroClick(Sender: TObject);
        procedure sbtnSetZeroCTClick(Sender: TObject);
        procedure sbtnResetZeroCTClick(Sender: TObject);
    procedure sgrdDaqClick(Sender: TObject);
    private
    { Private declarations }
        mLock: boolean;
        mTsTime: double;
        mstdIDx: integer;

        mAD: TBaseAD;
        mADNames: array of TStringList;

        mCT: TBaseCounter;

        mReqDAQObjFunc: TReqDAQObjFunc;

        procedure LoadGrpScales(Index: integer);
        procedure SaveGrpScales(Index: integer);
        procedure LoadADNamesFromIniFile(FilePath: string);
        procedure UpdateADNames(ADNames: TStringList);
    public
    { Public declarations }
        constructor Create(AOwner: TComponent; ReqDAQObjFunc: TReqDAQObjFunc);

    end;

var
    frmADChecker: TfrmADChecker;

implementation

uses
    DataUnit, SysEnv, myUtils, ClipBrd, IniFiles, LangTran;

{$R *.dfm}

function GetDecimalPos(aVal: string): integer;
begin
    Result := Pos('.', aVal);
    if Result < 0 then
        Result := 0;
end;

procedure TfrmADChecker.FormShow(Sender: TObject);
var
    i: Integer;
begin

    GetStNamesNCarNames(cbxStation.Items, nil);

    cbxStation.ItemIndex := 0;
    cbxStationChange(nil);

    tmrPoll.Enabled := True;
    mLock := false;

    mstdIDx := ord(High(TFaGRAPH_ORD)) + 1;
    fagrpChecker.Tag := mstdIDx;

    cbxChs.Tag := 0;
    LoadGrpScales(fagrpChecker.Tag);
    UsrGraphInitial(fagrpChecker, gtStepScroll, True);
    sbtnStop.Enabled := false;

    LoadADNamesFromIniFile(GetEnvPath('ADList.ini'));

end;

procedure TfrmADChecker.cbxStationChange(Sender: TObject);
var
    i: integer;
begin

    mReqDAQObjFunc(cbxStation.ItemIndex, mAD, mCT);

    for i := 0 to MAX_AD_CH_COUNT - 1 do
        mAD.ResetZero(i);

    if Assigned(mCT) then
    begin
        for i := 0 to mCT.ChCount - 1 do
            mCT.ResetZero(i);
    end;

end;

constructor TfrmADChecker.Create(AOwner: TComponent; ReqDAQObjFunc: TReqDAQObjFunc);
begin
    inherited Create(AOwner);

    mReqDAQObjFunc := ReqDAQObjFunc;

    mReqDAQObjFunc(0, mAD, mCT);

    if Assigned(mCT) then
    begin
        pnlCTMask.Visible := False;
        sgrdCount.Visible := True;
    end;
end;

procedure TfrmADChecker.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    Action := CaFree;
end;

procedure TfrmADChecker.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
    tmrPoll.Enabled := false;
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

procedure TfrmADChecker.UpdateADNames(ADNames: TStringList);
var
    i: Integer;
    ChName: string;
begin
    cbxChs.Clear;

    for i := 0 to ADNames.Count - 1 do
    begin
        ChName := Format('CH%.2d: %s', [i, ADNames.Values[ADNames.Names[i]]]);
        sgrdDAQ.Cells[0, i + 1] := ChName;
        if ADNames.Values[ADNames.Names[i]] <> '' then
            cbxChs.Items.Add(ChName);
    end;

    cbxChs.ItemIndex := 0;

end;

procedure TfrmADChecker.LoadADNamesFromIniFile(FilePath: string);
var
    i, j: Integer;
    IniFile: TIniFile;
begin

    IniFile := TIniFile.Create(FilePath);

    SetLength(mADNames, cbxStation.Items.Count);

    try
        for i := 0 to cbxStation.Items.Count - 1 do
        begin
            mADNames[i] := TStringList.Create;

            if FileExists(FilePath) then
            begin
                IniFile.ReadSectionValues(cbxStation.Items[i], mADNames[i])
            end
            else
            begin
                for j := 0 to MAX_AD_CH_COUNT - 1 do
                begin
                    mADNames[i].Add(IntToStr(j) + '= AI' + IntToStr(j))
                end;
            end;
        end;

        UpdateADNames(mADNames[0]);
    finally
        IniFile.Free;
    end;

end;

procedure TfrmADChecker.FormCreate(Sender: TObject);
var
    i: integer;
begin
    with sgrdDaq do
    begin
        for i := 0 to RowCount - 1 do
            Rows[i].Clear;

        Cells[1, 0] := 'Digit';
        Cells[2, 0] := 'Value';
        Cells[3, 0] := 'Volt';
        for i := 1 to RowCount - 1 do
        begin
            Cells[0, i] := Format('CH%2.2d', [i - 1]);
        end;
        //반드시 "CH+숫자+' '" 형식으로 입력해 줄 것.

    end;

    if not Assigned(mCT) then
        Exit;

    cbxCTChs.Items.Clear;

    for i := 0 to mCT.ChCount - 1 do
        cbxCTChs.Items.Add(Format('CH%2.2d', [i]));

    cbxCTChs.ItemIndex := 0;

    with sgrdCount do
    begin
        RowCount := mCT.ChCount + 1;

        for i := 0 to RowCount - 1 do
            Rows[i].Clear;

        Cells[1, 0] := 'Value';
        Cells[2, 0] := 'Count';

        for i := 1 to RowCount - 1 do
        begin
            Cells[0, i] := Format('CH%2.2d', [i]);
        end;
    end;

end;

procedure TfrmADChecker.FormDestroy(Sender: TObject);
var
    i: Integer;
begin
    for i := 0 to Length(mADNames) - 1 do
        mADNames[i].Free;

//
end;

procedure TfrmADChecker.tmrPollTimer(Sender: TObject);
var
    i, iDx: integer;
    sTm: string;
    X, Y, dTm: double;
begin
    if mLock then
        Exit;
    mLock := True;

    for i := 1 to MAX_AD_CH_COUNT do
    begin
        with mAD do
        begin
            sTm := Format('%d', [GetDigital(i - 1)]);
            if sTm <> sgrdDaq.Cells[1, i] then
                sgrdDaq.Cells[1, i] := sTm;

            dTm := GetValue(i - 1);

            sTm := Format('%0.3f', [dTm]); //GetValue(i-1)]) ;
            if sTm <> sgrdDaq.Cells[2, i] then
                sgrdDaq.Cells[2, i] := sTm;
            sTm := Format('%0.5f', [GetVolt(i - 1)]);
            if sTm <> sgrdDaq.Cells[3, i] then
                sgrdDaq.Cells[3, i] := sTm;

            if not sbtnStart.Enabled then //and (cbxChs.ItemIndex = (i-1)) then
            begin
                iDx := StrToIntDef(Trim(Copy(cbxChs.Text, 3, 2)), 1);
                if iDx = i - 1 then
                begin
                    Y := GetValue(iDx);
                    X := (GetAccurateTime - mTsTime) / 1000.0;

                    fagrpChecker.AddData([0], [X], [Y]);
                end;
            end;
        end;

        if Assigned(mCT) then
        begin
            with mCT do
            begin
                sTm := Format('%0.3f', [GetValue((i - 1) mod ChCount)]);
                if sTm <> sgrdCount.Cells[1, i] then
                    sgrdCount.Cells[1, i] := sTm;

                sTm := Format('%d', [GetPulse((i - 1) mod ChCount)]);
                if sTm <> sgrdCount.Cells[2, i] then
                    sgrdCount.Cells[2, i] := sTm;
            end;
        end;
    end;

    cbxChs.Enabled := sbtnStart.Enabled;
    mLock := false;
end;

procedure TfrmADChecker.sgrdCountDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
begin
    AlignGrid(TStringGrid(Sender), ACol, ARow, Rect, State, [TA_CENTER, TA_CENTER, TA_CENTER, TA_CENTER, TA_CENTER, TA_CENTER, TA_CENTER, TA_CENTER, TA_CENTER,
        TA_CENTER]);
end;

procedure TfrmADChecker.sgrdDaqClick(Sender: TObject);
begin
    cbxChs.ItemIndex := sgrdDaq.Row - 1;
end;

procedure TfrmADChecker.sbtnResetZeroClick(Sender: TObject);
begin
    mAD.ResetZero(cbxChs.ItemIndex);
    sbtnSetZero.Enabled := True;
    sbtnResetZero.Enabled := false;
end;

procedure TfrmADChecker.sbtnResetZeroCTClick(Sender: TObject);
begin
    mCT.ResetZero(cbxCTChs.ItemIndex);
    sbtnSetZeroCT.Enabled := True;
    sbtnResetZeroCT.Enabled := False;

end;

procedure TfrmADChecker.sbtnSetZeroClick(Sender: TObject);
begin
    mAD.SetZero(cbxChs.ItemIndex);
    sbtnSetZero.Enabled := false;
    sbtnResetZero.Enabled := True;
end;

procedure TfrmADChecker.sbtnStartClick(Sender: TObject);
begin
    SaveGrpScales(fagrpChecker.Tag);
    UsrGraphInitial(fagrpChecker, gtStepScroll, True);

    fagrpChecker.Axis.Items[1].Caption := '(kgf)';
    fagrpChecker.Axis.Items[1].ShowCaption := false;

    sbtnStart.Enabled := false;
    sbtnStop.Enabled := True;
    mTsTime := GetAccurateTime;
end;

procedure TfrmADChecker.sbtnStopClick(Sender: TObject);
begin
    sbtnStart.Enabled := True;
    sbtnStop.Enabled := False;
end;

procedure TfrmADChecker.sbtnSetZeroCTClick(Sender: TObject);
begin
    mCT.SetZero(cbxCTChs.ItemIndex);
    sbtnSetZeroCT.Enabled := True;
    sbtnResetZeroCT.Enabled := False;

end;

procedure TfrmADChecker.cbxChsChange(Sender: TObject);
begin
    if cbxChs.Tag <> cbxChs.ItemIndex then
    begin
        SaveGrpScales(fagrpChecker.Tag);
        cbxChs.Tag := cbxChs.ItemIndex;

        fagrpChecker.Tag := mstdIDx + cbxChs.ItemIndex;
        LoadGrpScales(fagrpChecker.Tag);
        UsrGraphInitial(fagrpChecker, gtStepScroll, True);
    end;
end;

procedure TfrmADChecker.LoadGrpScales(Index: Integer);
var
    grpEnv: TFaGraphEnv;
begin
    grpEnv := GetGrpEnv(Index);
    with grpEnv do
    begin
        edtADxmin.Text := FloatToStr(rXMin);
        edtADxmax.Text := FloatToStr(rXMax);
        edtADxstep.Text := FloatToStr(rXStep);

        edtADymin.Text := FloatToStr(rYMin);
        edtADymax.Text := FloatToStr(rYMax);
        edtADystep.Text := FloatToStr(rYStep);
    end;
end;

procedure TfrmADChecker.SaveGrpScales(Index: Integer);
var
    grpEnv: TFaGraphEnv;
begin
    grpEnv := GetGrpEnv(Index);
    with grpEnv do
    begin
        rID := fagrpChecker.Tag;

        rXMin := StrToFloatDef(edtADxmin.Text, rXMin);
        rXMax := StrToFloatDef(edtADxmax.Text, rXMax);
        rXstep := StrToFloatDef(edtADxstep.Text, rXStep);

        rYMin := StrToFloatDef(edtADymin.Text, rYMin);
        rYMax := StrtoFloatDef(edtADymax.Text, rYMax);
        rYstep := StrToFloatDef(edtADystep.Text, rYstep);
    end;
    SetGrpEnv(grpEnv);
end;

end.

