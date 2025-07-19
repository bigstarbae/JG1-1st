{
    V.241014.02
}
unit PinUpForm;

interface

uses
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, ExtCtrls;

type
    TfrmPinUp = class(TForm)
        tmrClose: TTimer;
        procedure FormCreate(Sender: TObject);
        procedure FormClose(Sender: TObject; var Action: TCloseAction);
        procedure FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
        procedure tmrCloseTimer(Sender: TObject);
    private
    { Private declarations }
        mFilePath: string;
        mIsPngGroup: Boolean;
        mPngIdx: Integer;
        procedure SetShowSec(const Value: Integer);
    public
    { Public declarations }
        constructor Create(AOwner: TComponent; PngGroupFilePath: string; PngIdx: Integer; ShowSec: Integer = 0); overload;
        constructor Create(AOwner: TComponent; PngFilePath: string); overload;

        property ShowSec: Integer write SetShowSec;

        procedure Show(X, Y: Integer); reintroduce; overload;
    end;

var
    frmPinUp: TfrmPinUp;

implementation

uses
    PNGimage, PNGFIleMerger;

{$R *.dfm}

procedure MakeAlphaBlend(Bitmap: TBitmap; PNG: TPNGImage);
type
    TPixels = array[0..0] of TRGBQuad;

    TPixels2 = array[0..0] of TRGBTriple;
var
    Pixels: ^TPixels;
    Pixels2: ^TPixels2;
    Col, Row: Integer;
    Alpha: Byte;
    BlendFactor: Single;
begin
    for Row := 0 to Bitmap.Height - 1 do
    begin
        Pixels := Bitmap.ScanLine[Row];
        Pixels2 := PNG.ScanLine[Row];
        for Col := 0 to Bitmap.Width - 1 do
        begin
            Alpha := PNG.AlphaScanline[Row]^[Col];
            Pixels^[Col].rgbReserved := Alpha;

            if Alpha = 0 then
            begin
                Pixels^[Col].rgbRed := 0;
                Pixels^[Col].rgbGreen := 0;
                Pixels^[Col].rgbBlue := 0;
            end
            else
            begin
                BlendFactor := Alpha / 255.0;
                Pixels^[Col].rgbRed := Round(Pixels2^[Col].rgbtRed * BlendFactor);
                Pixels^[Col].rgbGreen := Round(Pixels2^[Col].rgbtGreen * BlendFactor);
                Pixels^[Col].rgbBlue := Round(Pixels2^[Col].rgbtBlue * BlendFactor);
            end;
        end;
    end;
end;

constructor TfrmPinUp.Create(AOwner: TComponent; PngGroupFilePath: string; PngIdx: Integer; ShowSec: Integer);
begin
    inherited Create(AOwner);
    mFilePath := PngGroupFilePath;
    mPngIdx := PngIdx;
    mIsPngGroup := True;

    Self.ShowSec := ShowSec;
end;

constructor TfrmPinUp.Create(AOwner: TComponent; PngFilePath: string);
begin
    inherited Create(AOwner);
    mFilePath := PngFilePath;
    mIsPngGroup := False;
end;

procedure TfrmPinUp.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    Action := caFree;
end;

procedure TfrmPinUp.FormCreate(Sender: TObject);
var
    Bitmap: TBitmap;
    TmpPNG: TPNGImage;
    DestPoint, SourcePoint: TPoint;
    BlendFunction: TBlendFunction;
    Size: TSize;
    DC: HDC;
begin

    if not FileExists(mFilePath) then
    begin
        Close;
        Exit;
    end;

    SetWindowLong(Handle, GWL_EXSTYLE, GetWindowLong(Handle, GWL_EXSTYLE) or WS_EX_LAYERED);
    ShowWindow(Application.Handle, SW_HIDE);

    Bitmap := TBitmap.Create;

    if mIsPngGroup then
    begin
        TmpPNG := TPngFileMerger.CreatePngFromMergedFile(mFilePath, mPngIdx)
    end
    else
    begin
        TmpPNG := TPNGImage.Create;
        TmpPNG.LoadFromFile(mFilePath);
    end;

    if TmpPNG = nil then
    begin
        Close;
        Exit;
    end;

    try

        Bitmap.PixelFormat := pf32Bit;
        Bitmap.Width := TmpPNG.Width;
        Bitmap.Height := TmpPNG.Height;
        Self.Width := TmpPNG.Width;
        Self.Height := TmpPNG.Height;

        MakeAlphaBlend(Bitmap, TmpPNG);

        Size.cx := Bitmap.Width;
        Size.cy := Bitmap.Height;

        DestPoint := BoundsRect.TopLeft;
        SourcePoint := Point(0, 0);

        DC := GetDC(0);

        BlendFunction.BlendOp := AC_SRC_OVER;
        BlendFunction.BlendFlags := 0;
        BlendFunction.SourceConstantAlpha := 255;
        BlendFunction.AlphaFormat := AC_SRC_ALPHA;

        UpdateLayeredWindow(Handle, DC, @DestPoint, @Size, Bitmap.Canvas.Handle, @SourcePoint, clBlack, @BlendFunction, ULW_ALPHA);

        ReleaseDC(0, DC);
    finally
        Bitmap.Free;
        TmpPNG.free;
    end;

end;

procedure TfrmPinUp.FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
    ReleaseCapture;
    SendMessage(Handle, WM_SYSCOMMAND, $F012, 0);
end;

procedure TfrmPinUp.SetShowSec(const Value: Integer);
begin
    if Value > 0 then
    begin
        tmrClose.Interval := Value * 1000;
        tmrClose.Enabled := True;
    end;
end;

procedure TfrmPinUp.Show(X, Y: Integer);
begin
    Left := X;
    Top := Y;
    inherited Show;
end;

procedure TfrmPinUp.tmrCloseTimer(Sender: TObject);
begin
    Close;
end;

end.

