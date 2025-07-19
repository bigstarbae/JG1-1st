{
    V.230904.00         by E.S

    - 주의: 최상위 Form의 DoubleBuffered OFF때만 적용 됨
}
unit TransparentPanel;

interface

uses
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, ExtCtrls, GDIPlus;

type
    TTransparentPanel = class(TCustomPanel)
    private
        FAlpha: Byte;

        procedure SetAlpha(const Value: Byte);
    protected
        procedure Paint; override;
        procedure Resize; override;

    public
        constructor Create(AOwner: TComponent); override;
        destructor Destroy; override;
    published
        property Color;
        property Alpha: Byte read FAlpha write SetAlpha default 128;
    end;

implementation


{ TTransparentPanel }

constructor TTransparentPanel.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);
    FAlpha := 180;//200;      //0-255 범위
    DoubleBuffered := True; // 화면 깜박임 방지를 위해 더블 버퍼링 사용

    Color := clWhite;
end;


destructor TTransparentPanel.Destroy;
begin

    inherited Destroy;
end;

procedure TTransparentPanel.Resize;
begin
    inherited Resize;
end;

procedure TTransparentPanel.SetAlpha(const Value: Byte);
begin
    if FAlpha <> Value then
    begin
        FAlpha := Value;
        Repaint;
    end;
end;


procedure TTransparentPanel.Paint;
var
    Grap: IGPGraphics;
    SemiTransBrush: IGPSolidBrush;
begin
    Grap := TGPGraphics.Create(Canvas.Handle);
    SemiTransBrush := TGPSolidBrush.Create(TGPColor.Create((FAlpha shl 24) or ColorToRGB(Color)));
    Grap.FillRectangle(SemiTransBrush, 0, 0, Width, Height);
end;

end.

