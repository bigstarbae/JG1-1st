unit DAQValFrame;

interface

uses
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, StdCtrls;

type
    TDAQValFrme = class(TFrame)
        lblTitle: TLabel;
        lblVal: TLabel;
        lblUnit: TLabel;
    private
    { Private declarations }
        mFormat: string;
    public
    { Public declarations }
        constructor Create(AOwner: TComponent); override;
        procedure Init(ATitle, AUnit: string; AFormat: string = '0.0');
        procedure SetValColor(Color: TColor);

        procedure Update(Val: Double);

        property Format: string read mFormat write mFormat;

    end;

implementation

{$R *.dfm}

{ TDAQValFrme }

constructor TDAQValFrme.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);

    lblUnit.Align := alNone;
    lblUnit.Top := 5;

    mFormat := '0.0';
end;

procedure TDAQValFrme.Init(ATitle, AUnit, AFormat: string);
begin
    lblTitle.Caption := ATitle;
    lblUnit.Caption := AUnit;
    mFormat := AFormat;
end;

procedure TDAQValFrme.SetValColor(Color: TColor);
begin
    lblVal.Font.Color := Color;
end;

procedure TDAQValFrme.Update(Val: Double);
begin
    lblVal.Caption := FormatFloat(mFormat, Val);
end;

end.

