unit ErBoradForm;
{$I myDefine.inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, Buttons, ExtCtrls, StdCtrls, KiiMessages ;

type
  TfrmErBorad = class(TForm)
    Timer1: TTimer;
    pnlError: TPanel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDblClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormPaint(Sender: TObject);
  private
    { Private declarations }
    mClose,
    mIsInit : boolean ;
    mTimeRect : TRect ;

    procedure ReadMessage(var myMsg: TMessage); Message SYS_CODE ;

    procedure Preview  ;
    procedure DrawTimes ;
    procedure DrawErCodes(ACanvas : TCanvas; Rect: TRect) ;
    procedure DrawInfos(ACanvas: TCanvas; Rect: TRect) ;
  public
    { Public declarations }
    procedure SetFrm(Index: integer) ;
  end;
var
  frmErBorad: TfrmErBorad;

implementation
uses
    ExitForm, DataUnit, Log, myUtils, ErBoardUnit, ModelUnit , LangTran;

{$R *.dfm}

function GetUsrFontHeight(ACanvas:TCanvas; ATxt: string; nW: integer): integer ;
begin
    while ACanvas.TextWidth(ATxt) >= nW do
    begin
        ACanvas.Font.Height := ACanvas.Font.Height - 1;
    end ;
    Result := ACanvas.Font.Height ;
end ;

procedure TfrmErBorad.DrawInfos(ACanvas: TCanvas; Rect: TRect);
const
    nC = 9 ;
    nR = 9 ;
var
    i, nH, nW, nL, nT, dH, ddH, Cnt, nP, ui : integer ;
    nTm : TRect ;
    sTm : string ;

    dTm : double ;
    nG, nI, nO : array[0..1]of WORD ;
    nTotal : array[0..5]of WORD ;
begin
    if not Assigned(gBase) then Exit ;

    FillChar(nTotal, sizeof(nTotal), 0) ;
    with ACanvas do
    begin
        Font.Name  := _TR('굴림체') ;
        Font.Style := [fsBold] ;
        Font.Color := gErBoard.FColor ;
        Pen.Color  := gErBoard.LColor ;

        SetBkMode(Handle, TRANSPARENT);

        nH := (Rect.Bottom - Rect.Top) div nR ;
        nW := (Rect.Right - Rect.Left) div nC ;
        Font.Height := Trunc(nH * 0.8) ;
    //Title
        nL := Rect.Left ;
        nT := Rect.Top ;
        nTm := Rect ;
        nTm.Bottom := nTm.Top + nH ;
        //InflateRect(nTm, -10, -10) ;

        Pen.Width   := 2 ;
        Brush.Color := clBlack ;
        Font.Color  := clWhite ;
        Font.Style  := [fsBold] ;

        sTm:= 'GCV CORE ASS'+''''+_TR('Y 조립라인 데이타관리') ;
        Font.Height := Trunc(nH*0.6);// GetUsrFontHeight(ACanvas,sTm,nW*nC-100) ;
        dH := TextHeight('H') div 2 ;
        ddH := (nH div 2) - dH ;

        SetTextAlign(Handle, TA_CENTER or TA_TOP) ;
        TextOut(nL+nW*4+nW div 2, nT+ddH,sTm);
        //Rectangle(nTm);
        MoveTo(nL,       nT + nH) ;
        LineTo(nL+nW*nC, nT + nH) ;
    //Time
        nT := nT + nH ;

        mTimeRect.Top := nT ;
        mTimeRect.Left:= Rect.Left ;
        mTimeRect.Right:= Rect.Right ;
        mTimeRect.Bottom:= nT + nH ;

        MoveTo(nL,       nT + nH) ;
        LineTo(nL+nW*nC, nT + nH) ;
    //생산모델 | INR                | OTR                | 생산율
    //         | 계획 | 투입 | 실적 | 계획 | 투입 | 실적 |
        Font.Height := Trunc(nH * 0.6) ;
        dH := TextHeight('H') div 2 ;
        ddH := (nH div 2) - dH ;
        nT := nT + nH ;
        TextOut(nL+nW,   nT+nH - TextHeight('H') div 2,
            _TR('생산실적'));
        TextOut(nL+nW*3+nW div 2, nT+ddH, _TR('지그(L)')) ;
        TextOut(nL+nW*6+nW div 2, nT+ddH, _TR('지그(R)')) ;
        TextOut(nL+nW*8+nW div 2, nT+nH - TextHeight('H') div 2, _TR('생산율'));

        Font.Height := Trunc(nH * 0.6) ;
        dH := TextHeight('H') div 2 ;
        ddH := (nH div 2) - dH ;

        Pen.Width   := 1 ;
        MoveTo(nL+nW*2,      nT+nH) ;
        LineTo(nL+nW*(nC-1), nT+nH) ;

        nT := nT + nH ;
        TextOut(nL+nW*2+nW div 2, nT+ddH, _TR('계획'));
        TextOut(nL+nW*3+nW div 2, nT+ddH, _TR('투입'));
        TextOut(nL+nW*4+nW div 2, nT+ddH, _TR('실적'));
        TextOut(nL+nW*5+nW div 2, nT+ddH, _TR('계획'));
        TextOut(nL+nW*6+nW div 2, nT+ddH, _TR('투입'));
        TextOut(nL+nW*7+nW div 2, nT+ddH, _TR('실적'));

        Pen.Width   := 2 ;
        MoveTo(nL,       nT + nH) ;
        LineTo(nL+nW*nC, nT + nH) ;
        Pen.Width   := 1 ;
    //DATA
        Cnt := 0 ;
        for i := 1 to _MAX_MODEL_COUNT do
        begin
            if Cnt >= 4 then Break ;
            if not GetProdVislbe(i) then Continue ;

            nT := nT + nH ;
            with gBase.GetModels(i) do
            begin
                //LH    OTR(1) / INR(0)
                //RH    INR    / OTR
                if rTypes[toUsrType] then nP:= 0
                else                      nP:= 1 ;
                sTm := String(rPartName) ;
            end;
            TextOut(nL+nW,   nT+ddH, sTm) ;
            nG[0] := GetProdGoalCount(i,nP) ;
            nTotal[0]:= nTotal[0]+nG[0] ;

            nO[0] := GetProdOutCount(i,nP,true) ;
            nTotal[1]:= nTotal[1]+nO[0] ;

            nI[0] := GetProdInCount(i, 0) ;
            nTotal[2]:= nTotal[2]+nI[0] ;

            nP:= (nP+1) mod 2 ;
            nG[1] := GetProdGoalCount(i,nP) ;
            nTotal[3]:= nTotal[3]+nG[1] ;

            nO[1] := GetProdOutCount(i,nP,true) ;
            nTotal[4]:= nTotal[4]+nO[1] ;

            nI[1] := GetProdInCount(i,1) ;
            nTotal[5]:= nTotal[5]+nI[1] ;

            TextOut(nL+nW*2+nW div 2, nT+ddH, IntToStr(nG[0]));
            TextOut(nL+nW*3+nW div 2, nT+ddH, IntToStr(nI[0]));
            TextOut(nL+nW*4+nW div 2, nT+ddH, IntToStr(nO[0]));
            TextOut(nL+nW*5+nW div 2, nT+ddH, IntToStr(nG[1]));
            TextOut(nL+nW*6+nW div 2, nT+ddH, IntToStr(nI[1]));
            TextOut(nL+nW*7+nW div 2, nT+ddH, IntToStr(nO[1]));

            if (nG[0] + nG[1]) <= 0 then dTm := 0
            else                         dTm := (nO[0] + nO[1])/(nG[0] + nG[1]) * 100.0 ;
            TextOut(nL+nW*8+nW div 2, nT+ddH, Format('%0.1f%%',[dTm]));
            Inc(Cnt) ;
        end;
        nT := Rect.Top + nH * 3 ;
        for i := 0 to 3 do
        begin
            nT := nT + nH ;
            MoveTo(nL,       nT+nH) ;
            LineTo(nL+nW*nC, nT+nH) ;
        end;
    //TOTAL    |      |      |      |      |      |      |
        nT := nT + nH ;
        TextOut(nL+nW,   nT+ddH, 'TOTAL') ;
        TextOut(nL+nW*2+nW div 2, nT+ddH, IntToStr(nTotal[0]));//GetSumOfGoalCount(0)));      //INR GOAL
        TextOut(nL+nW*3+nW div 2, nT+ddH, IntToStr(nTotal[2]));//GetSumOfInCount(0)));      //INR IN
        TextOut(nL+nW*4+nW div 2, nT+ddH, IntToStr(nTotal[1]));//GetSumOfOutCount(0,true)));        //INR OUT
        TextOut(nL+nW*5+nW div 2, nT+ddH, IntToStr(nTotal[3]));//GetSumOfGoalCount(1)));
        TextOut(nL+nW*6+nW div 2, nT+ddH, IntToStr(nTotal[5]));//GetSumOfInCount(1)));
        TextOut(nL+nW*7+nW div 2, nT+ddH, IntToStr(nTotal[4]));//GetSumOfOutCount(1,true)));

        Pen.Width   := 2 ;
        MoveTo(nL+nW*2, Rect.Top+nH*2) ;
        LineTo(nL+nW*2, Rect.Bottom) ;
        MoveTo(nL+nW*5, Rect.Top+nH*2) ;
        LineTo(nL+nW*5, Rect.Bottom) ;
        MoveTo(nL+nW*8, Rect.Top+nH*2) ;
        LineTo(nL+nW*8, Rect.Bottom) ;

        MoveTo(nL+nW*3, Rect.Top+nH*3) ;
        LineTo(nL+nW*3, Rect.Bottom) ;
        MoveTo(nL+nW*4, Rect.Top+nH*3) ;
        LineTo(nL+nW*4, Rect.Bottom) ;
        MoveTo(nL+nW*6, Rect.Top+nH*3) ;
        LineTo(nL+nW*6, Rect.Bottom) ;
        MoveTo(nL+nW*7, Rect.Top+nH*3) ;
        LineTo(nL+nW*7, Rect.Bottom) ;
    end ;
end;

procedure TfrmErBorad.DrawTimes;
var
    nH, dH, ddH : integer ;
    nR : TRect ;
begin
    if mTimeRect.Top = 0 then Exit ;

    with Canvas do
    begin
        SetBkMode(Handle, TRANSPARENT);
        SetTextAlign(Handle, TA_RIGHT or TA_TOP) ;

        nR := mTimeRect ;
        Brush.Color := clBlack ;
        InflateRect(nR, -50, -5) ;
        FillRect(nR);

        nH := nR.Bottom - nR.Top ;
        Font.Height := Trunc(nH * 0.5) ;
        dH := TextHeight('H') div 2 ;
        ddH := (nH div 2) - dH ;

        TextOut(nR.Right, nR.Top+ddH,
            FormatDateTime('ddddd hh:nn:ss',Now())) ;
    end;
end;

procedure TfrmErBorad.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    //Action := CaFree ;
end;

procedure TfrmErBorad.ReadMessage(var myMsg: TMessage);
begin
    if mClose then Exit ;
    case myMsg.WParam of
        SYS_CLOSE   : mClose := true ;
        SYS_UPDATES : Preview ;
    end ;
end;

procedure TfrmErBorad.FormCreate(Sender: TObject);
begin
    gLog.ToFiles('------------>ERROR STATUS BOARD START<------------', []) ;
    mClose := false ;

    Self.Constraints.MaxHeight := 0 ;
    Self.Constraints.MaxWidth  := 0 ;

    mIsInit := true ;
end;

procedure TfrmErBorad.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
    mClose := true ;
end;

procedure TfrmErBorad.FormDestroy(Sender: TObject);
begin
    gLog.Panel('------------>ERROR STATUS BOARD CLOSE<------------', []) ;
end;

procedure TfrmErBorad.FormShow(Sender: TObject);
begin
    mClose  := false ;

    Caption := _PROJECT_NAME + ' M/C Error status Board #1' ;
    gErFrm := Handle ;
    Preview ;
    Timer1.Enabled := true ;

    gLog.Panel('------------>ERROR STATUS BOARD SHOW<------------', []) ;
	ChangeCaption(self);
end;

procedure TfrmErBorad.DrawErCodes(ACanvas : TCanvas; Rect: TRect) ;
var
    nItem : string ;
begin
    if not Assigned(gErBoard) then Exit ;

    with Canvas do
    begin
        nItem := gErBoard.GetTopTxt(erFRT) ;
        pnlError.Visible := nItem <> '' ;

        if pnlError.Visible then
        begin
            pnlError.Caption := nItem ;// + _TR(' 에러발생') ;
            pnlError.Width:= Self.Width - 50 ;
            //Exit ;
        end;

        DrawInfos(ACanvas, Rect);
    end;
end;

procedure TfrmErBorad.FormResize(Sender: TObject);
begin
    if pnlError.Visible then
    begin
        pnlError.Width:= Self.Width - 50 ;
    end;
    Preview ;
end;
{
procedure TfrmErBorad.DrawTitle(ACanvas : TCanvas; Rect: TRect) ;
var
    nL, nT, nH, nW : integer ;
begin
    with ACanvas do
    begin
        nT := Rect.Top ;
        nL := Rect.Left ;
        nH := Rect.Bottom - Rect.Top ;
        nW := Rect.Right - Rect.Left ;

        Font.Name  := _TR('굴림체') ;
        Font.Style := [fsBold] ;
        Font.Color := clWhite ;
        Pen.Color  := clWhite ;
        Pen.Width  := 5 ;

        Rectangle(Rect);

        SetBkMode(Handle, TRANSPARENT) ;
        SetTextAlign(Handle, TA_CENTER or TA_TOP) ;

        Font.Height := Trunc(nH * 0.7) ;
        Font.Height := GetUsrFontHeight(ACanvas, PROJECT_NAME+_TR(' M/C 2호기'), nW) ;
        TextOut(nL + nW div 2,
                nT + nH div 2 - TextHeight('H') div 2,
                PROJECT_NAME+_TR(' M/C 2호기')) ;
    end;
end;
}
procedure TfrmErBorad.Preview ;
var
    nR : TRect ;
begin
    if not Assigned(gErBoard) then Exit ;

    nR := ClientRect ;
    Canvas.Brush.Color := gErBoard.BColor ;      
    Canvas.FillRect(nR);

    //InflateRect(nR, -20, -20) ;
    DrawErCodes(Canvas, nR);
end;

procedure TfrmErBorad.FormDblClick(Sender: TObject);
begin
    if WindowState = wsNormal then mIsInit:= true //WindowState := wsMaximized
    else
    begin
        WindowState := wsNormal ;
        BorderStyle:= bsSizeable ;
        Left:= 0 ;
        TOP := 130 ;
    end;
end;

procedure TfrmErBorad.Timer1Timer(Sender: TObject);
begin
    //Timer1.Enabled := false ;
    if mIsInit then
    begin
        if Screen.MonitorCount < 2 then
        begin
            Close ;
            Exit ;
        end;
        Left := Screen.Monitors[1].Left + 100 ;
        WindowState:= wsMaximized ;
        BorderStyle:= bsNone ;

        mIsInit := false ;
        Exit ;
    end;

    DrawTimes ;
    {
    if (BorderStyle = bsNone)
        //and (Screen.MonitorCount < 2) then
        and (Screen.Monitors[0].Width > Left) then
    begin
        WindowState := wsNormal ;
        BorderStyle:= bsSizeable ;
        Left:= 0 ;
        TOP := 130 ;
    end;
    }
end;

procedure TfrmErBorad.FormPaint(Sender: TObject);
begin
    Preview ;
end;

procedure TfrmErBorad.SetFrm(Index: integer);
begin
    Self.Tag := Index ;
end;

end.
