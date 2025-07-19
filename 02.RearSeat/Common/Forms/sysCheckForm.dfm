object frmsysCheck: TfrmsysCheck
  Left = 306
  Top = 232
  BorderStyle = bsDialog
  Caption = #51104#49884' '#44592#45796#47140' '#51452#49901#49884#50836'...'
  ClientHeight = 132
  ClientWidth = 567
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #44404#47548
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object labLog: TLabel
    Left = 49
    Top = 102
    Width = 111
    Height = 17
    Caption = 'device conneting...'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #47569#51008' '#44256#46357
    Font.Style = []
    ParentFont = False
  end
  object pgbTimer: TProgressBar
    Left = 48
    Top = 69
    Width = 473
    Height = 17
    Max = 60
    TabOrder = 0
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 567
    Height = 57
    Align = alTop
    Caption = #51104#49884' '#44592#45796#47140' '#51452#49901#49884#50836'.'
    Color = clWhite
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -27
    Font.Name = #47569#51008' '#44256#46357
    Font.Style = [fsBold]
    ParentBackground = False
    ParentFont = False
    TabOrder = 1
  end
  object BitBtn1: TBitBtn
    Left = 435
    Top = 92
    Width = 86
    Height = 29
    Caption = 'Close'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #47569#51008' '#44256#46357
    Font.Style = [fsBold]
    Kind = bkCancel
    ParentFont = False
    TabOrder = 2
  end
  object cpuUsageTimer: TTimer
    Enabled = False
    Interval = 500
    OnTimer = cpuUsageTimerTimer
    Left = 16
    Top = 24
  end
end
