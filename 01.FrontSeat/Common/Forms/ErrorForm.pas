unit ErrorForm;
{$INCLUDE myDefine.inc}
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, Buttons, ImgList;

type    
  TfrmError = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    lbErrorList: TListBox;
    BitBtn1: TBitBtn;
    Label1: TLabel;
    Timer1: TTimer;
    ImgDlg: TImageList;
    ShowTimer: TTimer;
    Image1: TImage;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure lbErrorListDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure BitBtn1Click(Sender: TObject);
    procedure ShowTimerTimer(Sender: TObject);
  private
    { Private declarations }
    mTimeOut,
    mstdTime,
    mRowCount  : integer ;
    mstdHeight : integer ;
    mScreen : integer ;

    procedure LoadEnv ;
  public
    { Public declarations }
    procedure SetScreen(AIndex:integer) ;
    procedure SetFrm(devName, aMsg: string; ATime:integer; IsShow: boolean;
        DlgType:TMsgDlgType=mtError) ;
    procedure SetShow ;
  end;

var
  frmError: TfrmError;

implementation
uses
    UserTool, Log ;

const _MAX_COUNT = 50 ;
{$R *.DFM}
procedure CheckColorAndDisplay(aCanvas:TCanvas;
                               aRect: TRect;
                               Txt: string;
                               IsSelectRow, IsResult:boolean) ;
begin
    if Txt = '' then Exit ;
    with aCanvas do
    begin
        FillRect(aRect);
        TextOut(aRect.Left,
                ((aRect.Top + aRect.Bottom)div 2) - (TextHeight('H')div 2),
                Txt);
    end ;
end ;

procedure TfrmError.FormClose(Sender: TObject; var Action: TCloseAction);
begin
//
end;

procedure TfrmError.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
    Timer1.Enabled := false ;
    //lbErrorList.Clear ;
end;

procedure TfrmError.FormCreate(Sender: TObject);
begin
    mTimeOut   := 0 ;
    mstdTime   := 30 ;
    mRowCount  := 1 ;
    mstdHeight := ImgDlg.Height ;
    mScreen    := 0 ;
end;

procedure TfrmError.FormShow(Sender: TObject);
begin
    label1.Caption := '';//'자동으로 화면을 닫지 않습니다.' ;
    LoadEnv ;
    if mstdTime > 0 then Timer1.Enabled := true ;

    ShowTimer.Enabled := true ;
end;

procedure TfrmError.Timer1Timer(Sender: TObject);
begin
    Inc(mTimeOut) ;

    if mTimeOut > mstdTime then Close ;
    label1.Caption := Format('Close remaining time %d seconds'{'화면 닫기 전 %d 초 남았습니다.'}, [mstdTime - mTimeOut]) ;
end;
{
TMsgDlgType = (mtWarning, mtError, mtInformation, mtConfirmation, mtCustom);
}
procedure TfrmError.SetFrm(devName, aMsg: string; ATime:integer; IsShow: boolean;
    DlgType:TMsgDlgType) ;
var
    sTm : string;
    R, i : integer ;
begin
    mTimeOut := 0 ;
    mstdTime := ATime ;
    //EDIT if mtError = DlgType then mstdTime := 0 ;
    sTm := FormatDateTime('hh:nn:ss', Now());
    sTm := Format('[%s]%s: %s', [sTm, devName, aMsg]) ;
    lbErrorList.Items.AddObject(sTm, TObject(DlgType)) ;

    R := 0 ;
    for i := 1 to Length(sTm) do
    begin
        if sTm[i] = #13 then Inc(R) ;
    end ;

    if mRowCount <= (R+1) then mRowCount := (R+1) ;
    if lbErrorList.ItemHeight <= (mstdHeight * mRowCount) then
    begin
        lbErrorList.ItemHeight := mstdHeight * mRowCount ;
    end ;

    while lbErrorList.Count > 30 do lbErrorList.Items.Delete(0);
    lbErrorList.ItemIndex := lbErrorList.Items.Count-1 ;
    {$IFNDEF NO_ERROR_FORM}
    if not Showing and IsShow then
    begin
        FormStyle := fsStayOnTop ;
        Show ;
    end ;
    {$ENDIF}

    sTm := '' ;
    for i := 1 to Length(aMsg) do
    begin
        if aMsg[i] = #13 then sTm := sTm + ','
        else                  sTm := sTm + aMsg[i] ;
    end ;
    gLog.Panel('%s: %s', [devName, sTm]) ;
end ;
{
type TOwnerDrawState
      = set of (odSelected,  odGrayed,    odDisabled, odChecked, odFocused,
                odDefault,   odHotLight,  odInactive, odNoAccel, odNoFocusRect,
                odReserved1, odReserved2, odComboBoxEdit);}
procedure TfrmError.lbErrorListDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
//    bkColor,
//    fColor  : TColor ;
    asDisp, asData : string ;
    i, h, R, Cnt{, Idx} : integer;
    aRect : TRect ;
    dT : TMsgDlgType ;
begin
    asData := lbErrorList.Items.Strings[Index] ;
    dT := TMsgDlgType(lbErrorList.Items.Objects[Index]) ;
{
    if odSelected In State then
    begin
        bkColor := clNavy ;//$00C08080 ;
        fColor  := clWhite ;
    end
    else
    begin
        bkColor := clInfoBK ;
        fColor  := clBlack ;
    end ;
}
    //-----------
    // 조건 첫번째 문장은 : 까지
    // 두번째 문장은 아이콘과 함께 # 이전까지
    // 세번째 부터는 #으로 LF 기능이 된다.
    //-----------

    with Control as TListBox do
    begin
        R := mRowCount-1 ;
        h := (Rect.Bottom - Rect.Top) ;
        if R > 0 then
        begin
//            Idx := 0 ;
            Cnt := 0 ;
            asDisp := '' ;
            for i := 1 to Length(asData) do
            begin
                if asData[i] = #13 then
                begin
//                    Inc(iDx) ;
                    aRect := Rect ;
                    with aRect do
                    begin
                        Top    :=  Top + ((h div Succ(R)) * Cnt);// + (Cnt * 2) ;
                        Bottom :=  (Top + (h div Succ(R)));// - 2 ;
                    end ;
                    Canvas.FillRect(aRect);
                    Canvas.TextOut(aRect.Left + ImgDlg.Width + 5,
                                   aRect.Top  + mstdHeight div 2 - Canvas.TextHeight('H') div 2,
                                   asDisp);

                    Inc(Cnt) ;
                    asDisp := '' ;
                end
                else asDisp := asDisp + asData[i] ;
            end ;
            if asDisp <> '' then
            begin
                aRect := Rect ;
                with aRect do Top := (Top + (h div Succ(R)) * Cnt);
                Canvas.FillRect(aRect);
                Canvas.TextOut(aRect.Left + ImgDlg.Width + 5,
                               aRect.Top  + mstdHeight div 2 - Canvas.TextHeight('H') div 2,
                               asDisp);
            end ;
            case dT of
                mtWarning     :
                begin
                    ImgDlg.Draw(Canvas, Rect.Left, Rect.Top, 1);
                end ;
                mtError       :
                begin
                    ImgDlg.Draw(Canvas, Rect.Left, Rect.Top, 2);
                end ;
            else
                ImgDlg.Draw(Canvas, aRect.Left, Rect.Top, 0);
            end ;
        end ;
        if R = 0 then
        begin
            Canvas.FillRect(Rect);
            Canvas.TextOut(Rect.Left + ImgDlg.Width + 5,
                           Rect.Top    + mstdHeight div 2 - Canvas.TextHeight('H') div 2,
                           asDisp);
        end ;
		SetBkMode(Canvas.Handle, OPAQUE) ;
    end;
end;

procedure TfrmError.LoadEnv ;
begin
    //mstdTime := 30;//GetErShowTime ;
end ;

procedure TfrmError.BitBtn1Click(Sender: TObject);
begin
    Close ;
end;

procedure TfrmError.SetScreen(AIndex: integer);
begin
    mScreen := AIndex ;
end;

procedure TfrmError.SetShow;
begin
    mstdTime := 0 ;
    Show ;
end;

procedure TfrmError.ShowTimerTimer(Sender: TObject);
begin
    ShowTimer.Enabled := false ;
    if (mScreen > 0) and (Screen.MonitorCount > 1) then
    begin
        Left := Screen.Monitors[mScreen].Left
                + (Screen.Monitors[mScreen].Width div 2)
                - (Width div 2) ;
    end
    else
    begin
        Left := Screen.Monitors[0].Left
                + (Screen.Monitors[0].Width div 2)
                - (Width div 2) ;
    end ;

    Top := Screen.Monitors[mScreen].Top
            + (Screen.Monitors[mScreen].Height div 2)
            - (Height div 2) ;
end;

end.
