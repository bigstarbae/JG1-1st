unit ProdTimesForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, Grids, ExtCtrls;

type
  TProdTimes = class ;
  TfrmProdTimes = class(TForm)
    pnlTitle: TPanel;
    sgrdTimes: TStringGrid;
    Panel1: TPanel;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Label1: TLabel;
    rdbtnOrdinary: TRadioButton;
    rdbtnWeekEnd: TRadioButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure sgrdTimesDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure sgrdTimesDblClick(Sender: TObject);
    procedure sgrdTimesKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure rdbtnOrdinaryClick(Sender: TObject);
  private
    { Private declarations }
    mIsEdit : boolean ;
    mResult : TModalResult ;
    procedure SetEditTimes;
    procedure LoadProdTimes;
  public
    { Public declarations }
  end;
  //시간대별 생산량 추적일때 그 시간대를 유저가 지정한 값 로드.
  TProdTime = packed record
    rStart, rEnd : TDateTime ;
  end ;
  TProdTimes = class
  private
    mTag : integer ;
    mWorkTime : TDateTime ;
    mTimes : array[1..24]of TProdTime ;

    procedure Load ;
    procedure Save ;
  public
    constructor Create(Index: integer) ;
    destructor  Destroy; override ;

    function  GetStartTime(Index:integer): TDateTime ;
    procedure SetStartTime(Index:integer; ATime: TDateTime) ;

    function  GetEndTime(Index:integer): TDateTime ;
    procedure SetEndTime(Index:integer; ATime: TDateTime) ;

    property WorkTime : TDateTime read mWorkTime ;
    property Tag : integer read mTag ;
  end ;
  // 요일별로 시간대를 구별한다
{
    DayOfTheWeek = 1: Monday ~ 7: Sunday.
    DayOfWeek    = 1: Sunday ~ 7: Sat ==> 사용.
}
  TProdTimesEx = class
  private
    mIndex : integer ;
    mItems : array[1..7]of TProdTimes ;

    function GetItems(Index: integer): TProdTimes ;
  public
    constructor Create ;
    destructor  Destroy ; override ;

    function  GetOrdinaryDays : TProdTimes ;
    procedure SetOrdinalyDays(AProdTime: TProdTimes) ;

    function  GetWeekEnd : TProdTimes ;
    procedure SetWeekEnd(AProdTime: TProdTimes) ;

    function  ProdTime : TProdTimes ;
    function  ProdIndex : integer ;
    procedure SetProdIndex(Index: integer) ;

    property Items[Index: integer] : TProdTimes read GetItems ;
  end ;

var
  frmProdTimes: TfrmProdTimes;
  //gProdTimes : TProdTimes ;
  gProdEx : TProdTimesEx ;

implementation
uses
    DataUnit, myUtils , DateUtils, SetTimesForm, SysEnv, LangTran;

{$R *.dfm}

//------------------------------------------------------------------------------
{ TProdTimes }
//------------------------------------------------------------------------------
constructor TProdTimes.Create(Index: integer);
begin
    mTag := Index ;
    mWorkTime := gsysEnv.rWorkTime ;
    FillChar(mTimes, sizeof(mTimes), 0) ;
    Load ;
end;

destructor TProdTimes.Destroy;
begin

  inherited;
end;

function TProdTimes.GetEndTime(Index: integer): TDateTime;
begin
    Result := mTimes[Index].rEnd ;
end;

function TProdTimes.GetStartTime(Index: integer): TDateTime;
begin
    Result := mTimes[Index].rStart ;
end;

procedure TProdTimes.Load;
var
    sTm : string;
    i, fh : integer ;
    bT : double ;
    bTm : boolean ;
begin
    sTm := Format('%s\ProdTimes%d.env', [GetUsrDir(udENV, Now, true),mTag]) ;
    bTm := FileExists(sTm) ;
    if bTm then
    begin
        fh := FileOpen(sTm, fmOpenRead) ;
        try
            FileSeek(fh, 0, 0) ;
            bTm := FileRead(fh, mTimes, sizeof(mTimes))=sizeof(mTimes) ;
        finally
            FileClose(fh) ;
        end ;
    end ;

    if bTm then Exit ;

    bT := mWorkTime ;
    for i := 1 to 24 do
    begin
        mTimes[i].rStart := bT ;
        bT := IncHour(bT, 1) ;
        mTimes[i].rEnd   := bT ;
    end ;
end;

procedure TProdTimes.Save;
var
    sTm : string;
    fh  : integer ;
begin
    sTm := Format('%s\ProdTimes%d.env', [GetUsrDir(udENV, Now, true),mTag]) ;
    fh := FileCreate(sTm) ;
    try
        FileWrite(fh, mTimes, sizeof(mTimes)) ;
    finally
        FileClose(fh) ;
    end ;
end;

procedure TProdTimes.SetEndTime(Index: integer; ATime: TDateTime);
begin
    mTimes[Index].rEnd := ATime ;
    Save ;
end;

procedure TProdTimes.SetStartTime(Index: integer; ATime: TDateTime);
begin
    mTimes[Index].rStart := ATime ;
    Save ;
end;
//------------------------------------------------------------------------------
{ TProdTimesEx }
//------------------------------------------------------------------------------
constructor TProdTimesEx.Create;
var
    i : integer ;
begin
    mIndex := DayOfWeek(Now) ;
    for i := 1 to Length(mItems) do
    begin
        mItems[i] := TProdTimes.Create(i) ;
    end ;
end;

function TProdTimesEx.ProdIndex: integer;
begin
    Result := mIndex ;
end;

function TProdTimesEx.ProdTime: TProdTimes;
begin
    Result := mItems[mIndex] ;
end;

destructor TProdTimesEx.Destroy;
var
    i : integer ;
begin
    for i := 1 to Length(mItems) do FreeAndNil(mItems[i]) ;
  inherited;
end;

function TProdTimesEx.GetItems(Index: integer): TProdTimes;
begin
    Result := mItems[Index] ;
end;

function TProdTimesEx.GetOrdinaryDays: TProdTimes;
begin
    Result := mItems[4] ;
end;

function TProdTimesEx.GetWeekEnd: TProdTimes;
begin
    Result := mItems[7] ;
end;

procedure TProdTimesEx.SetProdIndex(Index: integer);
begin
    mIndex := Index ;
end;

procedure TProdTimesEx.SetOrdinalyDays(AProdTime: TProdTimes);
var
    i : integer ;
begin
    for i := 2 to 6 do
    begin
        with mItems[i] do
        begin
            Move(AProdTime.mTimes,  mTimes, sizeof(AProdTime.mTimes)) ;
        end ;
    end ;
end;

procedure TProdTimesEx.SetWeekEnd(AProdTime: TProdTimes);
begin
    with mItems[1] do
    begin
        Move(AProdTime.mTimes,  mTimes, sizeof(AProdTime.mTimes)) ;
    end ;
    with mItems[7] do
    begin
        Move(AProdTime.mTimes,  mTimes, sizeof(AProdTime.mTimes)) ;
    end ;
end;
//------------------------------------------------------------------------------
{ TfrmProdTimes }
//------------------------------------------------------------------------------
procedure TfrmProdTimes.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
    Action := caFree ;
end;

procedure TfrmProdTimes.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
    ModalResult := mResult ;
end;

procedure TfrmProdTimes.FormCreate(Sender: TObject);
begin
    mResult := mrCancel ;
end;

procedure TfrmProdTimes.FormDestroy(Sender: TObject);
begin
//
end;

procedure TfrmProdTimes.LoadProdTimes ;
var
    i : integer ;
begin
    with sgrdTimes do
    begin
        for i := 1 to 24 do
        begin
            Cells[0, i] := IntToStr(i) ;
            with gProdEx.ProdTime do
            begin
                Cells[1, i] := FormatDateTime('hh:nn:ss', GetStartTime(i));//gProdTimes.GetStartTime(i)) ;
                Cells[2, i] := FormatDateTime('hh:nn:ss', GetEndTime(i));//gProdTimes.GetEndTime(i)) ;
            end ;
        end ;
    end ;
end ;

procedure TfrmProdTimes.FormShow(Sender: TObject);
begin
    mIsEdit := false ;
    with sgrdTimes do
    begin
        Cells[0,0] := 'NO' ;
        Cells[1,0] := 'START' ;
        Cells[2,0] := 'END' ;
    end ;
    rdbtnOrdinary.Checked ;
    with gProdEx do
    begin
        SetProdIndex( GetOrdinaryDays.Tag ) ;
    end ;
    LoadProdTimes ;
    mIsEdit := true ;
    TLangTran.ChangeCaption(self);
end;

procedure TfrmProdTimes.sgrdTimesDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
begin
    AlignGrid(TStringGrid(Sender), ACol, ARow, Rect, State,
              [
               TA_CENTER,
               TA_CENTER,
               TA_CENTER,
               TA_CENTER,
               TA_CENTER,
               TA_CENTER
               ]);
end;

procedure TfrmProdTimes.sgrdTimesDblClick(Sender: TObject);
begin
    SetEditTimes ;
end;

procedure TfrmProdTimes.SetEditTimes ;
var
    nR : TGridRect ;
    nP : TPoint ;
    nT : double ;
begin
    if not mIsEdit then Exit ;
    nR := sgrdTimes.Selection ;
    if (nR.Top < 1) or (nR.Left = 0) then Exit ;

    with gProdEx.ProdTime do
    begin
        if nR.Left = 1 then nT := GetStartTime(nR.Top) //gProdTimes.GetStartTime(nR.Top)
        else                nT := GetEndTime(nR.Top) ; //gProdTimes.GetEndTime(nR.Top) ;
    end ;

    nP.X := sgrdTimes.Left + (sgrdTimes.DefaultColWidth * (nR.Left-1)) ;
    nP.Y := sgrdTimes.Top
            + (sgrdTimes.DefaultRowHeight * nR.Top)
            - pnlTitle.Height ;

    nP := sgrdTimes.ClientToScreen(nP);
    with TftmSetTimes.Create(Self) do
    begin
        if Execute(nP.X, nP.Y, nT) then
        begin
            with gProdEx.ProdTime do
            begin
                if nR.Left = 1 then SetStartTime(nR.Top, nT) //gProdTimes.SetStartTime(nR.Top, nT)
                else                SetEndTime(nR.Top, nT);  //gProdTimes.SetEndTime(nR.Top, nT);
            end ;
            if rdbtnOrdinary.Checked then gProdEx.SetOrdinalyDays(gProdEx.ProdTime)
            else                          gProdEx.SetWeekEnd(gProdEx.ProdTime);
            sgrdTimes.Cells[nR.Left, nR.Top] := FormatDateTime('hh:nn:ss', nT) ;
            mResult := mrOK ;
        end ;
    end ;
end ;

procedure TfrmProdTimes.sgrdTimesKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    case Key of
        VK_F5 :
        begin
            SetEditTimes ;
        end ;
    end ;
end;


procedure TfrmProdTimes.rdbtnOrdinaryClick(Sender: TObject);
begin
    mIsEdit := false ;
    with gProdEx do
    begin
        if rdbtnOrdinary.Checked then SetProdIndex(GetOrdinaryDays.Tag)
        else                          SetProdIndex(GetWeekEnd.Tag);
    end ;
    LoadProdTimes ;
    mIsEdit := true ;
end;

end.
