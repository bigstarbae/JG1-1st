object frmPopChecker: TfrmPopChecker
  Left = 432
  Top = 384
  Width = 529
  Height = 484
  Caption = 'POP'#49569#49688#49888#54869#51064
  Color = clBtnFace
  Font.Charset = HANGEUL_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #44404#47548
  Font.Style = [fsBold]
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 513
    Height = 41
    Align = alTop
    Caption = 'POP '#49569#49688#49888#54869#51064
    Font.Charset = HANGEUL_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = #47569#51008' '#44256#46357
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
  end
  object lbLog: TListBox
    Left = 0
    Top = 41
    Width = 513
    Height = 404
    Align = alClient
    BorderStyle = bsNone
    Color = clWhite
    Font.Charset = HANGEUL_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = #47569#51008' '#44256#46357
    Font.Style = [fsBold]
    ImeName = 'Microsoft Office IME 2007'
    ItemHeight = 17
    Items.Strings = (
      '[12:34:56]POP '#49569#49688#49888#54869#51064'.'
      '[12:34:56]POP '#49569#49688#49888#54869#51064'.')
    ParentFont = False
    TabOrder = 1
  end
end
