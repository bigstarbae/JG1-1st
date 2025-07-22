object frmPowerSuppy: TfrmPowerSuppy
  Left = 150
  Top = 113
  Caption = 'Power Supply '#53685#49888' '#54869#51064
  ClientHeight = 482
  ClientWidth = 668
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #44404#47548
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label11: TLabel
    Left = 0
    Top = 402
    Width = 668
    Height = 19
    Align = alTop
    Alignment = taCenter
    AutoSize = False
    Caption = 'Status Log'
    Color = 5329233
    Font.Charset = HANGEUL_CHARSET
    Font.Color = clWhite
    Font.Height = -13
    Font.Name = #44404#47548
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
    Transparent = False
    Layout = tlCenter
    ExplicitLeft = -16
    ExplicitTop = 439
    ExplicitWidth = 659
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 668
    Height = 39
    Align = alTop
    Caption = 'DC Power Supply'
    Color = 5329233
    Ctl3D = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -16
    Font.Name = #44404#47548
    Font.Style = [fsBold]
    ParentBackground = False
    ParentCtl3D = False
    ParentFont = False
    TabOrder = 0
    ExplicitLeft = -1
  end
  object Panel6: TPanel
    Left = 0
    Top = 39
    Width = 668
    Height = 363
    Align = alTop
    BevelOuter = bvNone
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #44404#47548
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    object GroupBox1: TGroupBox
      Left = 8
      Top = 63
      Width = 297
      Height = 280
      Caption = '[ Set up for com port ]'
      TabOrder = 2
      object Label3: TLabel
        Left = 10
        Top = 58
        Width = 71
        Height = 13
        Alignment = taRightJustify
        Caption = 'bit / sec :'
        Enabled = False
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Label4: TLabel
        Left = 18
        Top = 84
        Width = 63
        Height = 13
        Alignment = taRightJustify
        Caption = 'data bit :'
        Enabled = False
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Label5: TLabel
        Left = 31
        Top = 110
        Width = 50
        Height = 13
        Alignment = taRightJustify
        Caption = 'parity :'
        Enabled = False
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Label6: TLabel
        Left = 18
        Top = 136
        Width = 63
        Height = 13
        Alignment = taRightJustify
        Caption = 'stop bit :'
        Enabled = False
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = [fsBold]
        ParentFont = False
      end
      object labPortName: TLabel
        Left = 88
        Top = 32
        Width = 5
        Height = 13
        Enabled = False
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Label2: TLabel
        Left = 43
        Top = 32
        Width = 38
        Height = 13
        Alignment = taRightJustify
        Caption = 'port :'
        Enabled = False
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = [fsBold]
        ParentFont = False
      end
      object labBaudrate: TLabel
        Left = 88
        Top = 58
        Width = 5
        Height = 13
        Enabled = False
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = [fsBold]
        ParentFont = False
      end
      object labDatabit: TLabel
        Left = 88
        Top = 84
        Width = 5
        Height = 13
        Enabled = False
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = [fsBold]
        ParentFont = False
      end
      object labParity: TLabel
        Left = 88
        Top = 110
        Width = 5
        Height = 13
        Enabled = False
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = [fsBold]
        ParentFont = False
      end
      object labstopbit: TLabel
        Left = 88
        Top = 136
        Width = 5
        Height = 13
        Enabled = False
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = [fsBold]
        ParentFont = False
      end
      object btnOpen: TButton
        Left = 12
        Top = 166
        Width = 91
        Height = 25
        Caption = 'Open(&O)'
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 0
        OnClick = btnOpenClick
      end
      object btnClose: TButton
        Left = 102
        Top = 166
        Width = 91
        Height = 25
        Caption = 'Close(&E)'
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 1
        OnClick = btnCloseClick
      end
      object bntsetting: TButton
        Left = 192
        Top = 166
        Width = 91
        Height = 25
        Caption = 'Setup(&R)'
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 2
        OnClick = bntsettingClick
      end
      object cbxStation: TComboBox
        Left = 12
        Top = 224
        Width = 178
        Height = 21
        Style = csDropDownList
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 3
        OnChange = cbxStationChange
      end
    end
    object GroupBox2: TGroupBox
      Left = 321
      Top = 8
      Width = 336
      Height = 335
      Ctl3D = True
      ParentCtl3D = False
      TabOrder = 1
      object Label7: TLabel
        Left = 24
        Top = 78
        Width = 82
        Height = 13
        Alignment = taRightJustify
        Caption = #51204#50517' '#49444#51221'(V)'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Label8: TLabel
        Left = 25
        Top = 103
        Width = 82
        Height = 13
        Alignment = taRightJustify
        Caption = #51204#47448' '#49444#51221'(A)'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = [fsBold]
        ParentFont = False
      end
      object labVolt: TLabel
        Left = 8
        Top = 283
        Width = 151
        Height = 42
        Alignment = taCenter
        AutoSize = False
        Caption = '30.0 V'
        Color = 4013373
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -27
        Font.Name = #44404#47548
        Font.Style = [fsBold]
        ParentColor = False
        ParentFont = False
        Transparent = False
        Layout = tlCenter
      end
      object labCurr: TLabel
        Left = 163
        Top = 283
        Width = 151
        Height = 42
        Alignment = taCenter
        AutoSize = False
        Caption = '30.0 V'
        Color = 4013373
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -27
        Font.Name = #44404#47548
        Font.Style = [fsBold]
        ParentColor = False
        ParentFont = False
        Transparent = False
        Layout = tlCenter
      end
      object sbtnPowerOn: TSpeedButton
        Left = 112
        Top = 128
        Width = 97
        Height = 24
        Caption = 'POWER ON'
        OnClick = sbtnPowerOnClick
      end
      object sbtnVoltWrite: TSpeedButton
        Left = 274
        Top = 73
        Width = 34
        Height = 22
        Caption = 'set'
        OnClick = sbtnVoltWriteClick
      end
      object sbtnCurrWrite: TSpeedButton
        Left = 274
        Top = 99
        Width = 34
        Height = 22
        Caption = 'set'
        OnClick = sbtnCurrWriteClick
      end
      object sbtnPowerOff: TSpeedButton
        Left = 208
        Top = 128
        Width = 97
        Height = 24
        Caption = 'POWER OFF'
        OnClick = sbtnPowerOffClick
      end
      object abPower: TAbLED
        Left = 71
        Top = 124
        Width = 33
        Height = 33
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = [fsBold]
        ParentFont = False
        LED.Width = 30
        LED.Height = 30
        LED_Position = lpLeft
        Spacing = 5
        Checked = False
        Flashing = False
        Frequency = ff1Hz
        StatusInt = 0
        StatusBit = 0
        GroupIndex = 0
        Mode = mIndicator
      end
      object Label9: TLabel
        Left = 11
        Top = 260
        Width = 61
        Height = 13
        Alignment = taRightJustify
        Caption = #52636#47141' '#54869#51064
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Shape1: TShape
        Left = 78
        Top = 265
        Width = 235
        Height = 1
      end
      object labSetVolt: TLabel
        Left = 8
        Top = 211
        Width = 151
        Height = 42
        Alignment = taCenter
        AutoSize = False
        Caption = '30.0 V'
        Color = 4013373
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -27
        Font.Name = #44404#47548
        Font.Style = [fsBold]
        ParentColor = False
        ParentFont = False
        Transparent = False
        Layout = tlCenter
      end
      object labSetCurr: TLabel
        Left = 163
        Top = 211
        Width = 151
        Height = 42
        Alignment = taCenter
        AutoSize = False
        Caption = '30.0 V'
        Color = 4013373
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -27
        Font.Name = #44404#47548
        Font.Style = [fsBold]
        ParentColor = False
        ParentFont = False
        Transparent = False
        Layout = tlCenter
      end
      object Label13: TLabel
        Left = 11
        Top = 189
        Width = 61
        Height = 13
        Alignment = taRightJustify
        Caption = #49444#51221' '#54869#51064
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Shape2: TShape
        Left = 78
        Top = 194
        Width = 235
        Height = 1
      end
      object sbtnClearErr: TSpeedButton
        Left = 208
        Top = 20
        Width = 97
        Height = 24
        Caption = 'CLEAR'
        OnClick = sbtnClearErrClick
      end
      object edtOutVolt: TEdit
        Left = 112
        Top = 75
        Width = 160
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 0
        Text = 'edtOutVolt'
      end
      object edtOutCurr: TEdit
        Left = 112
        Top = 100
        Width = 160
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 1
        Text = 'Edit1'
      end
      object ckbDebugMode: TCheckBox
        Left = 198
        Top = 164
        Width = 106
        Height = 17
        Caption = 'Debug mode'
        TabOrder = 2
        OnClick = ckbDebugModeClick
      end
    end
    object GroupBox3: TGroupBox
      Left = 8
      Top = 3
      Width = 297
      Height = 54
      Caption = 'Run Mode'
      TabOrder = 0
      object labRunMode: TLabel
        Left = 11
        Top = 18
        Width = 93
        Height = 27
        Alignment = taCenter
        AutoSize = False
        Caption = 'AUTO'
        Color = clGreen
        Font.Charset = ANSI_CHARSET
        Font.Color = clWhite
        Font.Height = -16
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentColor = False
        ParentFont = False
        Transparent = False
        Layout = tlCenter
      end
      object btnAuto: TButton
        Left = 114
        Top = 19
        Width = 75
        Height = 25
        Caption = 'Auto(&A)'
        TabOrder = 0
        OnClick = btnAutoClick
      end
      object btnMaunal: TButton
        Left = 193
        Top = 19
        Width = 75
        Height = 25
        Caption = 'Manual(&M)'
        TabOrder = 1
        OnClick = btnMaunalClick
      end
    end
  end
  object lbLog: TListBox
    Tag = 999
    Left = 0
    Top = 421
    Width = 668
    Height = 61
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #44404#47548
    Font.Style = []
    ImeName = 'Microsoft IME 2003'
    ItemHeight = 13
    ParentFont = False
    TabOrder = 2
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 200
    OnTimer = Timer1Timer
    Left = 16
    Top = 360
  end
end
