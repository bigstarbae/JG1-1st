unit DetailForm;
{$INCLUDE myDefine.INC}

interface

uses
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, ExtCtrls, FaGraphEx, ComCtrls, ToolWin, ImgList, Buttons,
    StdCtrls, DataUnit, TableMaker, FAGraphExLegend, SeatMotorType, SeatMtrGrpExtender;

const
    MAX_TM_COUNT = 2;

type
    TfrmDetail = class(TForm)
        OpenDialog1: TOpenDialog;
        sbBoard: TScrollBox;
        iPreview: TImage;
        StatusBar1: TStatusBar;
        Panel3: TPanel;
        sbtnPrint: TSpeedButton;
        sbtnReferPrint: TSpeedButton;
        Panel1: TPanel;
        sbtnExit: TSpeedButton;
        sbtnReferGraph: TSpeedButton;
        PrinterSetupDialog1: TPrinterSetupDialog;
        SpeedButton1: TSpeedButton;
        SaveDialog1: TSaveDialog;
        pnlTitle: TPanel;
    fagrpLSlideLH: TFaGraphEx;
    fagrpLSlideRH: TFaGraphEx;
        Timer1: TTimer;
        procedure FormClose(Sender: TObject; var Action: TCloseAction);
        procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
        procedure FormCreate(Sender: TObject);
        procedure FormDestroy(Sender: TObject);
        procedure FormShow(Sender: TObject);
        procedure sbtnPrintClick(Sender: TObject);
        procedure sbtnReferPrintClick(Sender: TObject);
        procedure sbtnExitClick(Sender: TObject);
        procedure sbtnReferGraphClick(Sender: TObject);
        procedure ckbDataPosClick(Sender: TObject);
        procedure SpeedButton1Click(Sender: TObject);
        procedure fagrpSlideAfterPaint(Sender: TObject);
        procedure fagrpSlideBeforePaint(Sender: TObject);
        procedure Timer1Timer(Sender: TObject);
        procedure pnlTitleClick(Sender: TObject);

    private
        { Private declarations }
        mfName: string;
        mIndex: integer;
        mTM: array [0 .. MAX_TM_COUNT - 1] of TTableMakerEx;

        mLegends: array[TMotorOrd] of TLegend;
        mGH: array [TMotorOrd] of TSeatMtrGrpExtender;

        procedure DrawTitle(ACanvas: TCanvas; Rect: TRect; ACaption: string);
        procedure DrawDatas(ACanvas: TCanvas; Rect: TRect);
        procedure DrawGraphs(ACanvas: TCanvas; Rect: TRect);
        procedure Preview(PageNo: integer; scale: integer);
        procedure DrawReport(ACanvas: TCanvas; Rect: TRect);
        procedure DrawPage(ACanvas: TCanvas; Rect: TRect);
        function LoadData(AIDx: integer): Boolean;
        procedure LoadAndDisplays;
        procedure CreateTbls;
        procedure InitCell(Cell: TTMCell);
        procedure InitLegends;

    public
        { Public declarations }

        procedure SetFrm(const afName: string; Index: integer);
        procedure PrintOut;
    end;

var
    frmDetail: TfrmDetail;

implementation

uses
    SeatMotor,
    Printers, myUtils, DataBox, Graphconfigform, DrawBmp, NotifyForm, SysEnv,
    Log, UserTool, KiiFaGraphDB, DataUnitHelper, URect, Global, Range, LangTran;

var
    lpData: TDataBox;
    lpBmp: TDrawBmp;
    lpFont: integer;
{$R *.dfm}

function GetPrintImage(ADir, AFile: string): string;
    function GetUsrFileName(ADir, AFile, ATag: string): string;
    var
        i: integer;
    begin
        for i := 1 to 999 do
        begin
            Result := Format('%s%s(%s%3.3d)%s', [ADir, Copy(ExtractFileName(AFile), 1, Pos('.', AFile) - 1), ATag, i,
                ExtractFileExt(AFile)]);

            if not FileExists(Result) then
                Exit;
        end;
        Result := '';
    end;

var
    i: integer;
    sTm: string;
begin
    if ADir[Length(ADir)] <> '\' then
        ADir := ADir + '\';

    sTm := ADir + AFile;

    if not FileExists(sTm) then
    begin
        Result := sTm;
        Exit;
    end;

    Result := GetUsrFileName(ADir, AFile, '');
    if Result <> '' then
        Exit;
    // A..Z
    for i := 65 to 90 do
    begin
        Result := GetUsrFileName(ADir, AFile, Char(i));
        if Result <> '' then
            Exit;
    end;
    // a..z
    for i := 97 to 122 do
    begin
        Result := GetUsrFileName(ADir, AFile, Char(i));
        if Result <> '' then
            Exit;
    end;

    Result := ADir + AFile;
end;

procedure TfrmDetail.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    Action := caFree;
end;

procedure TfrmDetail.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
    {
      with TfrmWait.Create(Application) do
      begin
      Execute('PwrSeatTester.exe', 50.0) ;
      end ;
      }
end;

procedure TfrmDetail.FormCreate(Sender: TObject);
var
  Mtr: TMotorOrd;
begin
    lpData := TDataBox.Create(22);
    lpData.InitData();


    mGH[tmLSlideLH] := TSeatMtrGrpExtender.Create(fagrpLSlideLH);
    mGH[tmLSlideRH] := TSeatMtrGrpExtender.Create(fagrpLSlideRh);

    for Mtr := Low(TMotorOrd) to MtrOrdHi do
    begin
        mLegends[Mtr] := TLegend.Create(Self, mGH[Mtr].Graph);
    end;

end;

procedure TfrmDetail.FormDestroy(Sender: TObject);
var
    i: integer;
    Mtr: TMotorOrd;
begin
    for i := 0 to MAX_TM_COUNT - 1 do
    begin
        if Assigned(mTM[i]) then
            FreeAndNil(mTM[i]);
    end;

    if Assigned(lpData) then
        FreeAndNil(lpData);
    lpData := nil;

    for Mtr := Low(TMotorOrd) to MtrOrdHi do
    begin
        mLegends[Mtr].Free;
        mGH[Mtr].Free;
    end;

end;

procedure TfrmDetail.FormShow(Sender: TObject);
begin
    pnlTitle.Caption := PROJECT_NAME + ' REPORT';

    iPreview.Left := 35;

    if lpData.GetMcNO = 0 then
    begin
        fagrpLSlideLH.Tag := ord(faLSlideLH);
        fagrpLSlideRH.Tag := ord(faLSlideRH);
    end
    else
    begin
        fagrpLSlideLH.Tag := ord(faLSlideLH2);
        fagrpLSlideRH.Tag := ord(faLSlideRH2);
    end;

    sbtnPrint.Enabled := Printer.Printers.Count > 0;
    sbtnReferPrint.Enabled := sbtnPrint.Enabled;

    WindowState := wsMaximized;
    LoadAndDisplays();
    // Timer1.Enabled:= true ;

    TLangTran.ChangeCaption(self);
end;

procedure TfrmDetail.CreateTbls;
var
    CellStr: string;
begin


    CellStr := '작업정보, #L,       #L,         #L,        #L,          전체판정,' +
               '작업일자, 작업시간, CAR TYPE,   PART NO,    LOT NO,     @roNO,' +
               '$roDate,  $roTime,  $roCarType, $roPartNo,  $roLotNo,   #T';



    mTM[0] := TTableMakerEx.Create(6, 3, CellStr, InitCell);
    mTM[0].SelectCell(0, 0, 5, 0).SetBkColor(clBtnFace);
    mTM[0].Cells[5, 1].mFontHeight := 40;
    {
      Prefix @(roRs): 판정, $: 값
      }
    CellStr :=
      '모터, 전류, #L,  속도검사, #L,   #L,       #L,      초기 소음검사, #L,  #L,  작동 소음검사, #L,  #L, HALL 센서,' +
      '#T,   전진, 후진,    검사기준, 전진,   검사기준, 후진,  기준,   전진,    후진,   기준,  전진,   후진, #T,' +

      'L.SLIDE LH, @roDataCurrFw_LSlideLH, @roDataCurrBw_LSlideLH,' +
      '$rospecSpeedFwHiLo_LSlideLH, @roDataSpeedFw_LSlideLH, $rospecSpeedBwHiLo_LSlideLH, @roDataSpeedBw_LSlideLH,' +
      '$rospecNoiseInitHi_LSlideLH, @roDataNoiseInitFw_LSlideLH, @roDataNoiseInitBw_LSlideLH,' +
      '$rospecNoiseHi_LSlideLH, @roDataNoiseFw_LSlideLH, @roDataNoiseBw_LSlideLH, @roRsHallSensor_LSlideLH,' +

      'L.SLIDE RH, @roDataCurrFw_LSlideRH, @roDataCurrBw_LSlideRH,' +
      '$rospecSpeedFwHiLo_LSlideRH, @roDataSpeedFw_LSlideRH, $rospecSpeedBwHiLo_LSlideRH, @roDataSpeedBw_LSlideRH, ' +
      '$rospecNoiseInitHi_LSlideRH, @roDataNoiseInitFw_LSlideRH, @roDataNoiseInitBw_LSlideRH,' +
      '$rospecNoiseHi_LSlideRH, @roDataNoiseFw_LSlideRH, @roDataNoiseBw_LSlideRH, @roRsHallSensor_LSlideRH';



    mTM[1] := TTableMakerEx.Create(14, 4, CellStr, InitCell);
    mTM[1].SelectCell(0, 0, 13, 1).SetBkColor(clBtnFace);
    mTM[1].SetColWidthsRatio([0.8, 0.7, 0.7, 1.3, 1, 1.3, 1, 1, 0.8, 0.8, 1, 0.8, 0.8, 0.8]);


end;

procedure TfrmDetail.InitCell(Cell: TTMCell);
var
    RsOrd: TResultOrd;
    Prefix, RsOrdStr: string;
begin

    if Length(Cell.mText) = 0 then
        Exit;

    Prefix := Cell.mText[1];
    if (Prefix = '$') or (Prefix = '@') then
    begin

        RsOrdStr := Copy(Cell.mText, 2, Length(Cell.mText) - 1);

        RsOrd := GetResultOrdByName(RsOrdStr);
        if RsOrd <> roNone then
        begin
            Cell.mText := lpData.GetResultToATxt(ord(RsOrd), true);

            if IsHan(Cell.mText) then
                Cell.mText := _TR(Cell.mText);

            if (Pos('roRs', Cell.mText) > 0) or (Prefix = '@') then
            begin
                if not lpData.GetResult(RsOrd) then
                begin
                    Cell.mBKColor := COLOR_NG_LIGHT; //COLOR_NG;
                end;
            end;
        end;
    end;

end;





procedure TfrmDetail.InitLegends;
var
    i: TMotorOrd;
    j: integer;
    procedure SetCaption(UpDn: boolean);
    begin

        if UpDn then
        begin
            mLegends[i].Items[0].mCaption := _TR('상승소음');
            mLegends[i].Items[1].mCaption := _TR('하강소음');

            mLegends[i].Items[2].mCaption := _TR('상승전류');
            mLegends[i].Items[3].mCaption := _TR('하강전류');

        end
        else
        begin
            mLegends[i].Items[0].mCaption := _TR('전진소음');
            mLegends[i].Items[1].mCaption := _TR('후진소음');

            mLegends[i].Items[2].mCaption := _TR('전진전류');
            mLegends[i].Items[3].mCaption := _TR('후진전류');
        end;

    end;

begin

    for i := Low(TMotorOrd) to MtrOrdHi do
    begin
        for j := 0 to mGH[i].Graph.Series.Count - 1 do
        begin
            SetCaption(i = tmLSlideLH);
            mLegends[i].Items[j].mColor := mGH[i].Graph.Series.Items[j].LineColor;
        end;
    end;

end;

procedure TfrmDetail.Preview(PageNo: integer; scale: integer);
var
    DevWidth, DevHeight: integer;
    ViewExt, WindowExt: TSize;
    Paper: TRect;
    PaperSize: TPoint;

    tWidth: integer;
    tHeight: integer;
begin
    tWidth := iPreview.Width;
    tHeight := iPreview.Height;

    Screen.Cursor := crHourGlass;
    try
        iPreview.Canvas.Pen.Color := clBlack;
        iPreview.Canvas.Brush.Color := clWhite;
        iPreview.Canvas.Pen.Color := clBlack;
        iPreview.Canvas.FillRect(iPreview.ClientRect);

        SaveDC(iPreview.Canvas.Handle);
        /// /poPortrait, poLandscape  A4 210 * 297

        if (Printer.Printers.Count > 0) and IsDefaultPrinterSetup and Printer.Printing
        { and (GetDefaultPrint <> GetUserPrint) } then
        begin
            Printer.Orientation := poLandscape;
            DevWidth := GetDeviceCaps(Printer.Handle, HORZSIZE);
            DevHeight := GetDeviceCaps(Printer.Handle, VERTSIZE);
        end
        else
        begin
            DevWidth := 287;
            DevHeight := 203;
        end;

        Paper := Rect(0, 0, tWidth, tHeight);
        DrawReport(iPreview.Canvas, Paper);
    finally
        RestoreDC(iPreview.Canvas.Handle, -1);

        Screen.Cursor := crDefault;
    end;
end;

procedure TfrmDetail.SetFrm(const afName: string; Index: integer);
begin
    mfName := afName;
    mIndex := Index;

    if not LoadData(mIndex) then
    begin
        MessageDlg(_TR('자료를 찾을 수 없습니다.') + #13 +  _TR('종료 후 다시 작업하세요'), mtWarning, [mbOK], 0);
        Exit;
    end;

    with lpData do
    begin
        mGH[tmLSlideLH].LockedCurr := GetData(roLimitCurr_LSlideLH);
        mGH[tmLSlideLH].Param.Create(TRange.Create(GetData(rospecTimeLo_LSlideLH), GetData(rospecTimeHi_LSlideLH)),
            TRange.Create(GetData(rospecCurrLo_LSlideLH), GetData(rospecCurrHi_LSlideLH)), GetData(rospecNoiseInitTime_LSlideLH), GetData(rospecNoiseInitHi_LSlideLH), GetData(rospecNoiseHi_LSlideLH), 0);

        mGH[tmLSlideRH].LockedCurr := GetData(roLimitCurr_LSlideRH);
        mGH[tmLSlideRH].Param.Create(TRange.Create(GetData(rospecTimeLo_LSlideRH), GetData(rospecTimeHi_LSlideRH)),
            TRange.Create(GetData(rospecCurrLo_LSlideRH), GetData(rospecCurrHi_LSlideRH)), GetData(rospecNoiseInitTime_LSlideRH), GetData(rospecNoiseInitHi_LSlideRH), GetData(rospecNoiseHi_LSlideRH), 0);

    end;
end;

procedure TfrmDetail.DrawTitle(ACanvas: TCanvas; Rect: TRect; ACaption: string);
    procedure TextOutCenter(ACanvas: TCanvas; x, y: integer; const str: string);
    var
        ta: word;
    begin
        ta := SetTextAlign(ACanvas.Handle, TA_CENTER or TA_TOP);
        ACanvas.TextOut(x, y - ACanvas.TextHeight(str) div 2, str);
        SetTextAlign(ACanvas.Handle, ta);
    end;

var
    tmp: integer;
begin
    ACanvas.Font.Name := _TR('굴림');
    ACanvas.Font.Height := Trunc((Rect.Bottom - Rect.Top) * 0.45);

    ACanvas.Brush.Color := clWhite;
    tmp := ACanvas.Pen.Width;
    ACanvas.Pen.Width := 3;
    ACanvas.Rectangle(Rect);
    ACanvas.Pen.Width := tmp;

    TextOutCenter(ACanvas, Rect.Left + (Rect.Right - Rect.Left) div 2, Rect.Top + (Rect.Bottom - Rect.Top) div 2, ACaption);

    ACanvas.Font.Height := Trunc((Rect.Bottom - Rect.Top) * 0.25);
    // SetTextAlign(aCanvas.Handle, TA_CENTER or TA_TOP);
    ACanvas.TextOut(Rect.Left + Trunc((Rect.Right - Rect.Left) * 5 / 6), Rect.Bottom - Trunc(ACanvas.TextHeight('h') * 1.3),
        _TR('출력일자: ') + FormatDateTime('ddddd', Now()));

end;

function GetMyTxtToPrintTxt(AValue, AUnit: string): string;
begin
    if (AValue <> '--') and (AValue <> '') then
    begin
        Result := AValue + ' ' + AUnit;
    end;
end;

function PosToRect(Left, Top, Right, Bottom: integer): TRect;
begin
    Result.Left := Left;
    Result.Top := Top;
    Result.Right := Result.Left + Right;
    Result.Bottom := Result.Top + Bottom;
end;

procedure TfrmDetail.DrawDatas(ACanvas: TCanvas; Rect: TRect);
const
    ROW_COUNT = 16;
var
    i, CellH, Gap: integer;
    CellStr: string;
    PdtInfoRect, PwrRsRect, HeatRsRect, VentRsRect, IMSRsRect: TRect;
begin

    if not Assigned(mTM[0]) then
    begin
        CreateTbls;
    end;

    PdtInfoRect := Rect;
    PwrRsRect := Rect;
    HeatRsRect := Rect;
    VentRsRect := Rect;
    IMSRsRect := Rect;

    CellH := RectHeight(Rect) div ROW_COUNT;
    Gap := CellH div 5;

    with ACanvas do
    begin
        Font.Name := '굴림';
        Font.Style := [];
        Font.Color := clBlack;
        Brush.Color := clWhite;
        Pen.Color := clBlack;
        Font.Size := Trunc(CellH * 0.6);
        // --------------------
        lpFont := Font.Size;
        // --------------------
    end;

    SetRectHeight(PdtInfoRect, CellH * 3);

    SetRectHeight(PwrRsRect, CellH * 6, PdtInfoRect.Bottom + Gap);
    SetRectWidth(PwrRsRect, RectWidth(Rect));

    SetRectHeight(IMSRsRect, CellH * 1, PwrRsRect.Bottom + Gap);

    mTM[0].BoundsRect := PdtInfoRect;
    mTM[1].BoundsRect := PwrRsRect;


    for i := 0 to MAX_TM_COUNT - 1 do
    begin
        mTM[i].mFontHeight := lpFont;
        mTM[i].Draw(ACanvas);
    end;


end;

procedure TfrmDetail.DrawGraphs(ACanvas: TCanvas; Rect: TRect);
var
    GrpR1, GrpR2, GrpR3: TRect;
    H: integer;
    LegendW: integer;
begin
    with ACanvas do
    begin
        Font.Name := '굴림';
        Font.Style := [];
        Font.Color := clBlack;
        Brush.Color := clWhite;
        Pen.Color := clBlack;
        Font.Size := lpFont;
        if Printer.Printing then
            Font.Size := Trunc(lpFont * 0.2)
        else
            Font.Size := Trunc(lpFont * 0.7);

        GrpR1 := Rect;
        H := Rect.Height div 3;
        GrpR1.Bottom := GrpR1.Top + H;

        GrpR2 := GrpR1;
        GrpR2.Offset(0, H);
        GrpR3 := GrpR2;
        GrpR3.Offset(0, H);


        Rectangle(GrpR1);
        Rectangle(GrpR2);
        Rectangle(GrpR3);

        InflateRect(GrpR1, -20, -20);
        InflateRect(GrpR2, -20, -20);
        InflateRect(GrpR3, -20, -20);
    end;

    LegendW := Round(GrpR1.Width * 0.3);

    mLegends[tmLSlideLH].Draw(ACanvas, Bounds(GrpR1.Left + 50, GrpR1.Top - 3, LegendW, 24));
    mLegends[tmLSlideRH].Draw(ACanvas, Bounds(GrpR2.Left + 60, GrpR2.Top - 3, LegendW, 24));

    with ACanvas do
    begin
        SetBkMode(Handle, TRANSPARENT);
        SetTextAlign(Handle, TA_Right or TA_TOP);
        Font.Style := [fsBold];
        Font.Color := clBlack;
        TextOut(GrpR1.Right - 80, GrpR1.Top + 2, 'L.SLIDE LH');
        TextOut(GrpR2.Right - 80, GrpR2.Top + 2, 'L.SLIDE RH');
        Font.Style := [];
    end;


    fagrpLSlideLH.Print(ACanvas, GrpR1, not Printer.Printing, true);
    fagrpLSlideRH.Print(ACanvas, GrpR2, not Printer.Printing, true);

end;

procedure TfrmDetail.DrawReport(ACanvas: TCanvas; Rect: TRect);
var
    Paper: TRect;
begin
    Paper := Rect;
    Paper.Bottom := Paper.Top + Trunc(Rect.Height * 0.05);
    DrawTitle(ACanvas, Paper, pnlTitle.Caption);

    Paper.Top := Paper.Bottom + 2;
    Paper.Bottom := Paper.Top + Trunc(Rect.Height * 0.38);
    DrawDatas(ACanvas, Paper);


    Paper.Top := mTM[MAX_TM_COUNT - 1].BoundsRect.Bottom + 5; // Paper.Bottom + 2  ;
    Paper.Bottom := Rect.Bottom - 20;
    DrawGraphs(ACanvas, Paper);


    Paper.Top := Paper.Bottom + 2;
    Paper.Bottom := Rect.Bottom;
    DrawPage(ACanvas, Rect);
end;

function InitUsrPrint(Print: TPrinter; StartPage: Boolean; Title: string; Orientation: TPrinterOrientation): TRect;
var
    pCanvas: TCanvas;
    DevWidth, DevHeight: integer;
    ViewExt: Size;
    Paper: TRect;
begin
    pCanvas := Print.Canvas;

    if (StartPage) then
    begin
        Print.Orientation := Orientation;
        Print.Title := Title;
        Print.BeginDoc();
    end
    else
    begin
        Print.NewPage();
    end;

    DevWidth := GetDeviceCaps(Print.Handle, HORZSIZE);
    DevHeight := GetDeviceCaps(Print.Handle, VERTSIZE);

    Paper := Rect(0, 0, DevWidth * 10, DevHeight * 10); // 아래 LoMETRIC모드(0.1mm)로 변환하므로,  10배 해준다.
    InflateRect(Paper, -10, -10);

    SetMapMode(Print.Handle, MM_LOMETRIC); // 10 ---- 1mm
    GetViewportExtEx(Print.Handle, ViewExt);
    SetMapMode(Print.Handle, MM_ISOTROPIC);
    SetViewportExtEx(Print.Handle, ViewExt.cx, -ViewExt.cy, @ViewExt);

    pCanvas.Brush.Color := clWhite;
    pCanvas.Pen.Color := clBlack;

    Result := Paper;
end;

procedure TfrmDetail.PrintOut;
var
    Prt: TPrinter;
    Pages: TRect;
begin
    Screen.Cursor := crHourGlass;
    Prt := Printer;
    Pages := InitUsrPrint(Prt, true, Caption, poLandscape);
    try
        DrawReport(Prt.Canvas, Pages);
    finally
        Prt.EndDoc();
    end;
    Screen.Cursor := crDefault;
end;

procedure TfrmDetail.sbtnPrintClick(Sender: TObject);
begin
    if not IsDefaultPrinterSetup then
    begin
        MessageDlg(_TR('기본 프린트가 없습니다.') + #13 +  _TR('[제어판]-[프린트]에서 확인하신 후 다시 시도하세요.'), mtWarning, [mbOK], 0);
        Exit;
    end;
    PrintOut;
end;

procedure TfrmDetail.sbtnReferPrintClick(Sender: TObject);
begin
    with PrinterSetupDialog1 do
        Execute;
end;

procedure TfrmDetail.sbtnExitClick(Sender: TObject);
begin
    Close;
end;

procedure TfrmDetail.sbtnReferGraphClick(Sender: TObject);
begin
    with frmgrpConfig do
    begin
        BorderStyle := bsSingle;
        SetFrm(fagrpLSlideLH.Tag);
        ShowModal;
    end;

    UsrGraphInitial(fagrpLSlideLH, gtNormal, false);
    UsrGraphInitial(fagrpLSlideRH, gtNormal, false);
    Preview(0, 0);
end;

procedure TfrmDetail.DrawPage(ACanvas: TCanvas; Rect: TRect);
begin
    Font.Color := clBlack;
    Font.Size := 8;
    Font.Style := [];

    ACanvas.TextOut(Rect.Left + (Rect.Right - Rect.Left) div 2, Rect.Bottom + 20, '1/1');
    ACanvas.TextOut(Rect.Right - ACanvas.TextWidth('H'), Rect.Bottom + 20, _CO_SYMBOL);
end;



procedure TfrmDetail.ckbDataPosClick(Sender: TObject);
begin
    Preview(0, 0);
end;

procedure TfrmDetail.SpeedButton1Click(Sender: TObject);
begin
    with SaveDialog1 do
    begin
        InitialDir := GetDeskTopDirectory;
        Filter := 'bmp Files(*.bmp)|*.bmp';
        FileName := GetPrintImage(InitialDir, 'Data.bmp');
        if Execute then
            iPreview.Picture.SaveToFile(FileName);
    end;
end;

procedure TfrmDetail.fagrpSlideAfterPaint(Sender: TObject);
begin
    //
end;

procedure TfrmDetail.fagrpSlideBeforePaint(Sender: TObject);
begin
    //
end;

procedure TfrmDetail.LoadAndDisplays;
var
    KiiDB: TKiiGraphDB;
begin
    UsrGraphInitial(fagrpLSlideLH, gtNormal, true);
    UsrGraphInitial(fagrpLSlideRH, gtNormal, true);

    KiiDB := TKiiGraphDB.Create(stHour, GetUsrDir(udRS, Now, false));
    try
        // 작동력

        KiiDB.Load(lpData.GetGraphTime, fagrpLSlideLH.Tag, fagrpLSlideLH, fagrpLSlideLH.Series.Count * 2);
        KiiDB.Load(lpData.GetGraphTime, fagrpLSlideRH.Tag, fagrpLSlideRH, fagrpLSlideRH.Series.Count * 2);

    finally
        KiiDB.Free;
    end;

    InitLegends;


    mGH[tmLSlideLH].ShowCurrSpec := lpData.IsTested(tsCurr) and gSysEnv.rShowCurrSpec;
    mGH[tmLSlideRH].ShowCurrSpec := lpData.IsTested(tsCurr) and gSysEnv.rShowCurrSpec;


    mGH[tmLSlideLH].ShowNoiseSpec := lpData.IsTested(tsNoise);
    mGH[tmLSlideRH].ShowNoiseSpec := lpData.IsTested(tsNoise);

    Preview(0, 1);
end;

procedure TfrmDetail.Timer1Timer(Sender: TObject);
begin
    Timer1.Enabled := false;
    LoadAndDisplays;
end;

function TfrmDetail.LoadData(AIDx: integer): Boolean;
var
    fh: integer;
    Buf: TResult;
begin
    Result := false;

    fh := FileOpen(mfName, fmOpenRead);
    if fh < 0 then
        Exit;

    try
        FileSeek(fh, sizeof(TResult) * (AIDx - 1), 0);
        Result := FileRead(fh, Buf, sizeof(TResult)) = sizeof(TResult);
    finally
        FileClose(fh);
    end;

    if not Result then
        FillChar(Buf, sizeof(TResult), 0);

    lpData.InitData();
    lpData.SetResult(Buf);
end;

procedure TfrmDetail.pnlTitleClick(Sender: TObject);
begin
    LoadAndDisplays();
end;

end.
