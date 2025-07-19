object frmTest: TfrmTest
  Left = 0
  Top = 0
  Caption = 'frmTest'
  ClientHeight = 519
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
  object lblStatus: TLabel
    Left = 0
    Top = 279
    Width = 535
    Height = 17
    Align = alBottom
    Caption = 'lblStatus'
    ExplicitTop = 215
    ExplicitWidth = 50
  end
  object btnStartSimul: TButton
    Left = 16
    Top = 8
    Width = 129
    Height = 45
    Caption = 'START'
    TabOrder = 0
    OnClick = btnStartSimulClick
  end
  object btnStopSimul: TButton
    Left = 168
    Top = 8
    Width = 129
    Height = 45
    Caption = 'STOP'
    TabOrder = 1
    OnClick = btnStopSimulClick
  end
  object btnSaveLog: TButton
    Left = 320
    Top = 8
    Width = 129
    Height = 45
    Caption = 'SAVE'
    TabOrder = 2
    OnClick = btnSaveLogClick
  end
  object mmoLog: TMemo
    Left = 0
    Top = 296
    Width = 535
    Height = 223
    Align = alBottom
    TabOrder = 6
  end
  object edtFilterIDs: TEdit
    Left = 136
    Top = 77
    Width = 161
    Height = 25
    TabOrder = 4
  end
  object btnAddFilter: TButton
    Left = 320
    Top = 76
    Width = 129
    Height = 27
    Caption = 'ADD Filter'
    TabOrder = 3
    OnClick = btnAddFilterClick
  end
  object lstFilterIDs: TListBox
    Left = 136
    Top = 108
    Width = 161
    Height = 157
    ItemHeight = 17
    TabOrder = 5
  end
  object tmrUpdate: TTimer
    Interval = 100
    OnTimer = tmrUpdateTimer
    Left = 480
    Top = 128
  end
end
