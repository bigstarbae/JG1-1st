object Form17: TForm17
  Left = 0
  Top = 0
  ClientHeight = 343
  ClientWidth = 535
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #47569#51008' '#44256#46357
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 17
  object lblResult: TLabel
    Left = 288
    Top = 184
    Width = 100
    Height = 17
    Caption = '-'
  end
  object lblCalculatedAngle: TLabel
    Left = 288
    Top = 224
    Width = 100
    Height = 17
    Caption = '-'
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 535
    Height = 41
    Align = alTop
    TabOrder = 0
    ExplicitLeft = 176
    ExplicitTop = 168
    ExplicitWidth = 185
  end
  object rgConvertMode: TRadioGroup
    Left = 24
    Top = 64
    Width = 185
    Height = 105
    TabOrder = 1
    OnClick = rgConvertModeClick
  end
  object btnCalculate: TButton
    Left = 24
    Top = 175
    Width = 185
    Height = 73
    Caption = #44228#49328
    TabOrder = 3
    OnClick = btnCalculateClick
  end
  object edtSensorDistance: TEdit
    Left = 288
    Top = 144
    Width = 121
    Height = 25
    TabOrder = 2
    Text = '50'
  end
end
