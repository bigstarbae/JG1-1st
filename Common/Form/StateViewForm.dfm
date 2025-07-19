object frmStateView: TfrmStateView
  Left = 0
  Top = 0
  ClientHeight = 407
  ClientWidth = 739
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object tvState: TTreeView
    Left = 0
    Top = 27
    Width = 739
    Height = 380
    Align = alClient
    Color = 16252927
    DoubleBuffered = True
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = #47569#51008' '#44256#46357
    Font.Style = []
    Indent = 19
    ParentDoubleBuffered = False
    ParentFont = False
    TabOrder = 0
    OnAdvancedCustomDrawItem = tvStateAdvancedCustomDrawItem
    ExplicitLeft = 112
    ExplicitTop = -21
    ExplicitWidth = 369
  end
  object Panel3: TPanel
    Left = 0
    Top = 0
    Width = 739
    Height = 27
    Align = alTop
    TabOrder = 1
    ExplicitLeft = 1
    ExplicitTop = 1
    ExplicitWidth = 613
    object cbxStation: TComboBox
      Left = 1
      Top = 1
      Width = 224
      Height = 25
      Align = alLeft
      Style = csDropDownList
      Ctl3D = False
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = #47569#51008' '#44256#46357
      Font.Style = []
      ImeName = 'Microsoft IME 2003'
      ParentCtl3D = False
      ParentFont = False
      TabOrder = 0
      OnChange = cbxStationChange
    end
  end
  object tmrPoll: TTimer
    Interval = 500
    OnTimer = tmrPollTimer
    Left = 24
    Top = 32
  end
end
