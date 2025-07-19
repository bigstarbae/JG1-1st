{
	230219.00: 범용 메시지 및 에러 표시용 Form
	. 기존 공용 모듈을 수정 중
}
unit MsgForm;

interface

uses
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, Buttons, StdCtrls, jpeg, ExtCtrls, Label3D, pngimage, Grids, Generics.Collections;

type

    TfrmMsg = class;

    TMsgFormPool = class(TDictionary<integer, TfrmMsg>)
    private
        mCurPID: integer;

        function GetItems(PID: integer): TfrmMsg;

    public
        destructor Destroy; override;
        function Find(PID: integer): TfrmMsg;   // 폐기 준

    end;

    TfrmMsg = class(TForm)
        imgIcon: TImage;
        lblMainTitle: TLabel;
        lblSubTitle: TLabel;
        pnlMain: TPanel;
        shpMainBorder: TShape;
        pnlCaption: TPanel;
        sbtnClose: TSpeedButton;
        pnlDebug: TPanel;
        shpDebugBorder: TShape;
        Label1: TLabel;
        lblDebug: TLabel;
        tmrScroll: TTimer;
        imgQRCode: TImage;
        sgToDo: TStringGrid;
    tmrBlink: TTimer;
        procedure sbtnCloseClick(Sender: TObject);
        procedure FormShow(Sender: TObject);
        procedure tmrScrollTimer(Sender: TObject);
        procedure pnlCaptionMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
        procedure FormClose(Sender: TObject; var Action: TCloseAction);
        procedure FormActivate(Sender: TObject);
        procedure sgToDoDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
        procedure tmrBlinkTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    private
        { Private declarations }

        mShowFocus: boolean;
        mCurToDoIdx: integer;
        mBlinkColor: TColor;

        mPID: integer;      // Parent ID, 0은 Parent없음

        procedure SetColor(Color: TColor);
        procedure SetAutoScrollFocus(const Value: boolean);
        function GetSetAutoScrollFocus: boolean;

        procedure Init;

        procedure DrawInfoIcon(BndRect: TRect);
        procedure DrawStopIcon(BndRect: TRect);
        procedure Show(Titles, ToDos: array of string; DebugStr, IconPath: string);

        procedure SetBkColor(BkColor: TColor);
    public
        { Public declarations }

        class var
            mIsShow: boolean;

        function ShowIcon(Path: string): TfrmMsg;
        function ShowQRCode(URL: string): TfrmMsg;
        function ShowFocusBk(Show: boolean): TfrmMsg;

        function GotoXY(X, Y: integer): TfrmMsg;
        function GotoCenter(Parent: TWinControl): TfrmMsg;
        function Blink(BlinkColor: TColor = $00D2D2FF; Interval: integer = 800): TfrmMsg;

        property AutoScrollFocus: boolean read GetSetAutoScrollFocus write SetAutoScrollFocus;
    end;


procedure CloseMsg(Parent: TWinControl);

function ShowMsg(Parent: TWinControl; Title: string; ToDo: string = ''): TfrmMsg; overload;

function ShowMsg(Parent: TWinControl; Title: string; SubTitle: string; ToDo: string): TfrmMsg; overload;

function ShowMsg(Parent: TWinControl; Titles, ToDos: array of string; AutoScrollFocus: boolean = false; DebugStr: string = ''; IconPath: string = ''): TfrmMsg; overload;

function ShowErrMsg(Parent: TWinControl; Title: string; ToDo: string = ''): TfrmMsg; overload;

function ShowErrMsg(Parent: TWinControl; Titles, ToDos: array of string; AutoScrollFocus: boolean = true; DebugStr: string = ''; IconPath: string = ''): TfrmMsg; overload;


// 단일 메인창의 Thread에서 호출시 사용!
function SyncShowMsg(Parent: TWinControl; Title: string; ToDo: string = ''): TfrmMsg; overload;

function SyncShowMsg(Parent: TWinControl; Title: string; SubTitle: string; ToDo: string): TfrmMsg; overload;

function SyncShowMsg(Parent: TWinControl; Titles, ToDos: array of string; AutoScrollFocus: boolean = false; DebugStr: string = ''; IconPath: string = ''): TfrmMsg; overload;

function SyncShowErrMsg(Parent: TWinControl; Title: string; ToDo: string = ''): TfrmMsg; overload;

function SyncShowErrMsg(Parent: TWinControl; Titles, ToDos: array of string; AutoScrollFocus: boolean = true; DebugStr: string = ''; IconPath: string = ''): TfrmMsg; overload;

var
    frmMsg: TfrmMsg;

implementation

uses
    DelphiZXingQRCode, Math, MyUtils, URect;



{$R *.dfm}

const
    COLOR_INFO = $00804000;
    COLOR_ERR = $004D50C0;

{            !
// 수평스크롤 참고
procedure TForm1.Timer1Timer(Sender: TObject);
begin
    mScrollText := Copy(ScrollText, 2, Length(ScrollText) - 1);
    mScrollText := mScrollText + mScrollText[1];
    lblMarquee.Caption := mScrollText;
    ListBox1.Items[0] := mScrollText;

end;
}

var
    gMsgFormPool: TMsgFormPool;

procedure CalcFontSize(Lbl: TLabel; sText: string);
const
    MAX_FONT_SIZE = 25;
    MIN_FONT_SIZE = 3;
var
    ARect: TRect;
    i: integer;
begin

    ARect := Default(TRect);
    ARect.Right := Lbl.Width;
    ARect.Bottom := Lbl.Height;

    for i := MAX_FONT_SIZE downto MIN_FONT_SIZE do
    begin
        Lbl.Canvas.Font.Size := i;
        Lbl.Canvas.TextRect(ARect, sText, [tfCalcRect]);

        if ((ARect.Right - ARect.Left) < Lbl.Width) then
        begin
            Lbl.Font.Size := i;
            break;
        end;
    end;

end;


procedure CloseMsg(Parent: TWinControl);
begin
    if gMsgFormPool.ContainsKey(integer(Parent)) then
        gMsgFormPool[integer(Parent)].Close;
end;

function ShowMsg(Parent: TWinControl; Title: string; ToDo: string): TfrmMsg;
begin
    Result := ShowMsg(Parent, [Title, ''], [ToDo], false);
end;

function ShowMsg(Parent: TWinControl; Title: string; SubTitle: string; ToDo: string): TfrmMsg;
begin
    Result := ShowMsg(Parent, [Title, SubTitle], [ToDo], false);
end;

function ShowMsg(Parent: TWinControl; Titles, ToDos: array of string; AutoScrollFocus: boolean; DebugStr, IconPath: string): TfrmMsg;
var
    PID: integer;
begin
    PID := integer(Parent);

    if gMsgFormPool.ContainsKey(PID) then
        Exit(gMsgFormPool[PID]);

    Result := TfrmMsg.Create(nil);

    Result.SetColor(COLOR_INFO);
    Result.sbtnClose.Font.Color := $00FFECD9;
    Result.AutoScrollFocus := AutoScrollFocus;
    Result.mPID := PID;

    Result.Show(Titles, ToDos, DebugStr, IconPath);

    Result.GotoCenter(Parent);

    gMsgFormPool.mCurPID := PID;

    if not gMsgFormPool.ContainsKey(PID) then
        gMsgFormPool.Add(PID, Result);
end;

function ShowErrMsg(Parent: TWinControl; Title: string; ToDo: string = ''): TfrmMsg;
begin
    Result := ShowErrMsg(Parent, [Title], [ToDo], false);
end;

function ShowErrMsg(Parent: TWinControl; Titles, ToDos: array of string; AutoScrollFocus: boolean; DebugStr, IconPath: string): TfrmMsg;
var
    PID: integer;
begin
    PID := integer(Parent);

    if gMsgFormPool.ContainsKey(PID) then
        Exit(gMsgFormPool[PID]);

    Result := TfrmMsg.Create(nil);

    Result.SetColor(COLOR_ERR);
    Result.sbtnClose.Font.Color := $00C8C9EC;
    Result.AutoScrollFocus := AutoScrollFocus;
    Result.mPID := PID;

    Result.Show(Titles, ToDos, DebugStr, IconPath);

    Result.GotoCenter(Parent);

    gMsgFormPool.mCurPID := PID;

    if not gMsgFormPool.ContainsKey(PID) then
        gMsgFormPool.Add(PID, Result);

end;

function SyncShowMsg(Parent: TWinControl; Title: string; ToDo: string): TfrmMsg;
begin
    TThread.Synchronize(nil,
        procedure
        begin
            ShowMsg(Parent, Title, ToDo);
        end);

    Result := gMsgFormPool[integer(Parent)];
end;

function SyncShowMsg(Parent: TWinControl; Title: string; SubTitle: string; ToDo: string): TfrmMsg;
begin
    Result := SyncShowMsg(Parent, [Title, SubTitle], [ToDo]);
end;

function SyncShowMsg(Parent: TWinControl; Titles, ToDos: array of string; AutoScrollFocus: boolean; DebugStr, IconPath: string): TfrmMsg;
var
    i: integer;
    TmpTitles, TmpToDos: array of string;
begin
    // 인자배열을 그대로  Synchronize 호출시 에러 발생하여 임시 배열에 넣어 전달
    SetLength(TmpTitles, Length(Titles));
    SetLength(TmpToDos, Length(ToDos));

    for i := 0 to Length(Titles) - 1 do
        TmpTitles[i] := Titles[i];

    for i := 0 to Length(ToDos) - 1 do
        TmpToDos[i] := ToDos[i];

    TThread.Synchronize(nil,
        procedure
        begin
            ShowMsg(Parent, TmpTitles, TmpToDos, AutoScrollFocus, DebugStr, IconPath);
        end);

    TmpTitles := nil;
    TmpToDos := nil;

    Result := gMsgFormPool[integer(Parent)];
end;

function SyncShowErrMsg(Parent: TWinControl; Title: string; ToDo: string): TfrmMsg;
begin
    Result := SyncShowErrMsg(Parent, [Title], [ToDo]);
end;

function SyncShowErrMsg(Parent: TWinControl; Titles, ToDos: array of string; AutoScrollFocus: boolean; DebugStr, IconPath: string): TfrmMsg;
var
    i: integer;
    TmpTitles, TmpToDos: array of string;
begin
    // 인자배열을 그대로  Synchronize 호출시 에러 발생하여 임시 배열에 넣어 전달
    SetLength(TmpTitles, Length(Titles));
    SetLength(TmpToDos, Length(ToDos));

    for i := 0 to Length(Titles) - 1 do
        TmpTitles[i] := Titles[i];

    for i := 0 to Length(ToDos) - 1 do
        TmpToDos[i] := ToDos[i];

    TThread.Synchronize(nil,
        procedure
        begin
            ShowErrMsg(Parent, TmpTitles, TmpToDos, AutoScrollFocus, DebugStr, IconPath);
        end);

    TmpTitles := nil;
    TmpToDos := nil;

    Result := gMsgFormPool[integer(Parent)];
end;

procedure DrawTextEx(Canvas: TCanvas; Text: string; BoundsRect: TRect; AlignCenter: boolean);
var
    TextSize: TSize;
    i, TextHeight: Integer;
    Lines: array[0..10] of string;
    LineCount: integer;
begin

    LineCount := ParseByDelimiter(Lines, 10, Text, #13);

    if LineCount = 0 then
    begin
        Exit;
    end;

    TextSize := Canvas.TextExtent('W!');
    TextHeight := TextSize.cy * LineCount;
    TextHeight := TextHeight;

    for i := 0 to LineCount - 1 do
    begin
        TextSize := Canvas.TextExtent(Lines[i]);
        if AlignCenter then
            Canvas.TextOut(BoundsRect.Left + (BoundsRect.Width div 2) - (TextSize.cx div 2), BoundsRect.Top + (BoundsRect.Height div 2) - (TextHeight div 2) + (TextSize.cy * i), Lines[i])
        else
            Canvas.TextOut(BoundsRect.Left, BoundsRect.Top + (BoundsRect.Height div 2) - (TextHeight div 2) + (TextSize.cy * i), Lines[i]);
    end;

end;

const
    MSG_FORM_MARGIN = 40;

procedure TfrmMsg.FormShow(Sender: TObject);
begin
    mIsShow := true;
    Init;
end;

procedure TfrmMsg.DrawStopIcon(BndRect: TRect);
var
    StdSize, W, X, Y: integer;
begin
    with imgIcon.Canvas do
    begin
        Brush.Color := pnlMain.Color;
        FillRect(Bounds(0, 0, imgIcon.Width, imgIcon.Height));

        Pen.Color := clRed;
        Pen.Width := 14;
        Ellipse(BndRect);
        W := (BndRect.Right - BndRect.Left) div 2;
        X := BndRect.Left + W;
        Y := BndRect.Top + W;
        MoveTo(X + Round(W * sin(DegToRad(45))) , Y - Round(W * cos(DegToRad(45))));
        LineTo(X + Round(W * sin(DegToRad(228))) + 4, Y - Round(W * cos(DegToRad(228))));
    end;
end;

function TfrmMsg.Blink(BlinkColor: TColor; Interval: integer): TfrmMsg;
begin
    mBlinkColor := BlinkColor;
    tmrBlink.Interval := Interval;
    tmrBlink.Enabled := true;
    Result := self;
end;

procedure TfrmMsg.DrawInfoIcon(BndRect: TRect);
var
    StdSize, W, X, Y: integer;
begin

    with imgIcon.Canvas do
    begin
        Brush.Color := pnlMain.Color;
        FillRect(Bounds(0, 0, imgIcon.Width, imgIcon.Height));

        Pen.Color := clNavy;
        Pen.Width := 10;
        Ellipse(BndRect);

        Brush.Color := clNavy;
        W := BndRect.Right - BndRect.Left;
        StdSize := W div 7;
        X := BndRect.Left + (W div 2) - (StdSize div 2);
        Y := BndRect.Top + Round(StdSize * 1.1);
        Ellipse(Bounds(X, Y, StdSize, StdSize));
        RoundRect(X, Y + Round(StdSize * 1.8), X + StdSize, Y + BndRect.Bottom - Round(StdSize * 2.8), 5, 5);
    end;

end;

procedure TfrmMsg.FormActivate(Sender: TObject);
begin
    Init;

    if imgIcon.Picture.Graphic = nil then
    begin
        imgIcon.Picture.Bitmap.Width := imgIcon.Width;
        imgIcon.Picture.Bitmap.Height := imgIcon.Height;

        if pnlCaption.Color = COLOR_INFO then
            DrawInfoIcon(Bounds(10, 10, imgIcon.Width - 25, imgIcon.Height - 25))
        else
            DrawStopIcon(Bounds(10, 10, imgIcon.Width - 25, imgIcon.Height - 30));
    end;

end;

procedure TfrmMsg.Init;
begin

    Width := 906;
    imgQRCode.Visible := false;

    mCurToDoIdx := 0;

    SetBkColor(clWhite);

end;

procedure TfrmMsg.FormClose(Sender: TObject; var Action: TCloseAction);
begin

    mIsShow := false;
    tmrBlink.Enabled := false;

    if gMsgFormPool.ContainsKey(mPID) then
        gMsgFormPool.Remove(mPID);

    Action := caFree;

end;

procedure TfrmMsg.FormCreate(Sender: TObject);
begin
    mPID := 0;
end;

procedure TfrmMsg.SetAutoScrollFocus(const Value: boolean);
begin
    if Value <> tmrScroll.Enabled then
    begin
        mCurToDoIdx := 0;
        tmrScroll.Enabled := Value;
    end;

end;

procedure TfrmMsg.SetBkColor(BkColor: TColor);
begin
    pnlMain.Color := BkColor;
    sgToDo.Color := BkColor;
end;

procedure TfrmMsg.SetColor(Color: TColor);
begin
    pnlCaption.Color := Color;
    shpMainBorder.Pen.Color := Color;
    shpDebugBorder.Pen.Color := Color;
end;

function CountLines(Str: string): integer;
var
    i: integer;
begin
    Result := 1;
    for i := 1 to Length(Str) do
    begin
        if (Str[i] = #13) then
            Inc(Result);
    end;
end;

procedure TfrmMsg.Show(Titles, ToDos: array of string; DebugStr, IconPath: string);
var
    i, SumH: Integer;
begin

    lblMainTitle.Caption := Titles[0];
    CalcFontSize(lblMainTitle, lblMainTitle.Caption);


    if Length(Titles) >= 2 then
        lblSubTitle.Caption := Titles[1]
    else
        lblSubTitle.Caption := '';

    ClearGrid(sgToDo, 0, sgToDo.RowCount);
    sgToDo.RowCount := Length(ToDos);

    SumH := 0;
    for i := 0 to Length(ToDos) - 1 do
    begin
        sgToDo.Cells[0, i] := ToDos[i];
        sgToDo.RowHeights[i] := CountLines(ToDos[i]) * sgToDo.DefaultRowHeight;
        SumH := SumH + sgToDo.RowHeights[i];
    end;

    sgToDo.Height := SumH;// + (sgToDo.RowCount) ;

    if DebugStr = '' then
    begin
        pnlDebug.Visible := false;
        Height := pnlCaption.Height + sgToDo.BoundsRect.Bottom + MSG_FORM_MARGIN;
        pnlMain.Align := alClient;
        shpMainBorder.Align := alClient;
    end
    else
    begin
        pnlDebug.Visible := true;
        lblDebug.Caption := DebugStr;
        pnlMain.Align := alTop;
        pnlMain.Height := pnlCaption.Height + sgToDo.BoundsRect.Bottom + MSG_FORM_MARGIN;

        Height := pnlMain.Height + pnlDebug.Height;
    end;

    // To Do 없는 경우
    if Length(ToDos) = 0 then
        Height := Height + MSG_FORM_MARGIN * 1;

    if IconPath <> '' then
        imgIcon.Picture.LoadFromFile(IconPath)
    else
        imgIcon.Picture.Assign(nil);

    inherited Show;
end;

function TfrmMsg.ShowFocusBk(Show: boolean): TfrmMsg;
begin
    mShowFocus := Show;
    Result := self;
end;

function TfrmMsg.ShowIcon(Path: string): TfrmMsg;
begin
    imgIcon.Picture.LoadFromFile(Path);
    Result := self;
end;

function TfrmMsg.ShowQRCode(URL: string): TfrmMsg;
var
    Size: integer;
begin
    Size := Round(Width * 0.27);
    Width := Width + Size;

    Size := Size - Round(Size * 0.1);

    repeat
        imgQRCode.Width := Size;
        imgQRCode.Height := Size;
        Dec(Size);
    until (imgQRCode.Height < (pnlMain.Height - 20));

    imgQRCode.Left := sgToDo.Left + sgToDo.Width + 10;
    imgQRCode.Top := (pnlMain.Height - imgQRCode.Height) div 2;

    Left := Trunc((Screen.Width - Width) / 2);

    DrawQRCode(imgQRCode, URL);
    imgQRCode.Visible := true;

    Result := self;
end;

procedure TfrmMsg.tmrBlinkTimer(Sender: TObject);
begin
    if pnlMain.Color = clWhite then
        SetBkColor(mBlinkColor)
    else
        SetBkColor(clWhite);

    if pnlCaption.Color = COLOR_INFO then
        DrawInfoIcon(Bounds(10, 10, imgIcon.Width - 25, imgIcon.Height - 25))
    else
        DrawStopIcon(Bounds(10, 10, imgIcon.Width - 25, imgIcon.Height - 30));
end;

procedure TfrmMsg.tmrScrollTimer(Sender: TObject);
begin
    if sgToDo.RowCount = 0 then
        Exit;

    sgToDo.Row := mCurToDoIdx;
    Inc(mCurToDoIdx);
    mCurToDoIdx := mCurToDoIdx mod sgToDo.RowCount
end;

function TfrmMsg.GetSetAutoScrollFocus: boolean;
begin
    Result := tmrScroll.Enabled;
end;

function TfrmMsg.GotoCenter(Parent: TWinControl): TfrmMsg;
begin
    Result := self;

    Left := Parent.Left + (Parent.Width - Width) div 2;
    Top := Parent.Top + (Parent.Height - Height) div 2;

end;

function TfrmMsg.GotoXY(X, Y: integer): TfrmMsg;
begin
    Left := X;
    Top := Y;
    Result := self;
end;

procedure TfrmMsg.sgToDoDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
var
    Grid: TStringGrid;
    Text: string;
    OldColor, TextColor, BkColor: TColor;
    FontSize: integer;
begin
    Grid := TStringGrid(Sender);
    OldColor := Grid.Canvas.Font.Color;
    Text := Grid.Cells[ACol, ARow];

    if ARow = Grid.Row then
    begin

        if mShowFocus then
            BkColor := sbtnClose.Font.Color
        else
            BkColor := sgToDo.Color;
//        Grid.Canvas.Font.Name := lblMainTitle.Font.Name;
        if AutoScrollFocus then
        begin
            Grid.Canvas.Font.Style := [fsBold];
            TextColor := $004D0000;
        end
        else
            TextColor := Grid.Font.Color;

    end
    else
    begin
        Grid.Canvas.Font.Name := Grid.Font.Name;
        BkColor := Grid.Color;
        TextColor := Grid.Font.Color;
    end;

    Grid.Canvas.Brush.Color := BkColor;
    Grid.Canvas.FillRect(Rect);

    Grid.Canvas.Font.Size := Grid.Font.Size;
    Grid.Canvas.Font.Color := TextColor;
    SetBkMode(Grid.Canvas.Handle, TRANSPARENT);

    DrawTextEx(Grid.Canvas, Text, Rect, false);

    Grid.Canvas.Font.Style := [];
    Grid.Canvas.Font.Color := OldColor;

end;

procedure TfrmMsg.pnlCaptionMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
    ReleaseCapture;
    SendMessage(Handle, WM_NCLBUTTONDOWN, HTCAPTION, 0);
end;

procedure TfrmMsg.sbtnCloseClick(Sender: TObject);
begin
    Close;
end;

{ TMsgFormPool }

destructor TMsgFormPool.Destroy;
var
    Key: integer;
begin
    if Count > 0 then   // Count = 0인데 Keys가 남아있는 경우가 생김...??
    begin
        for Key in Keys do
            Items[Key].Free;
    end;

    inherited;
end;

function TMsgFormPool.Find(PID: integer): TfrmMsg;
begin
    if ContainsKey(PID) then
    begin
        Result := Items[PID];
    end
    else
    begin
        Result := TfrmMsg.Create(nil);
        Add(PID, Result);
    end;
end;

function TMsgFormPool.GetItems(PID: integer): TfrmMsg;
begin
    Result := Find(PID);
end;

initialization
    gMsgFormPool := TMsgFormPool.Create;
finalization

    if Assigned(gMsgFormPool) then
    begin
        gMsgFormPool.Free;
    end;

end.





