object frmTest: TfrmTest
  Left = 0
  Top = 0
  Caption = 'frmTest'
  ClientHeight = 685
  ClientWidth = 688
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #47569#51008' '#44256#46357
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 17
  object lblConnectorID: TLabel
    Left = 48
    Top = 222
    Width = 89
    Height = 17
    Caption = 'lblConnectorID'
  end
  object btnAssignSelected: TButton
    Left = 416
    Top = 168
    Width = 145
    Height = 41
    Caption = 'TEST'
    TabOrder = 1
    OnClick = btnAssignSelectedClick
  end
  object mmResult: TMemo
    Left = 0
    Top = 272
    Width = 688
    Height = 413
    Align = alBottom
    Lines.Strings = (
      'mmResult')
    TabOrder = 4
  end
  object cmbConnectorIDs: TComboBox
    Left = 48
    Top = 176
    Width = 313
    Height = 25
    TabOrder = 2
    Text = 'cmbConnectorIDs'
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 248
    Width = 688
    Height = 24
    Panels = <>
    ExplicitTop = 232
  end
  object rgConnectorType: TRadioGroup
    Left = 48
    Top = 48
    Width = 313
    Height = 105
    ItemIndex = 0
    Items.Strings = (
      #47784#46304' '#52964#45349#53552
      'SW1'
      'JG')
    TabOrder = 0
    OnClick = rgConnectorTypeClick
  end
end
