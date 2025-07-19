object frmSeatMtrCtrl: TfrmSeatMtrCtrl
  Left = 0
  Top = 0
  ClientHeight = 811
  ClientWidth = 924
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #47569#51008' '#44256#46357
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 17
  object Splitter1: TSplitter
    Left = 615
    Top = 0
    Height = 811
    Align = alRight
    ExplicitLeft = 694
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 615
    Height = 811
    Align = alClient
    TabOrder = 0
    object Panel3: TPanel
      Left = 1
      Top = 1
      Width = 613
      Height = 27
      Align = alTop
      TabOrder = 0
      object cbxStation: TComboBox
        Left = 1
        Top = 1
        Width = 115
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
        ItemIndex = 0
        ParentCtl3D = False
        ParentFont = False
        TabOrder = 0
        Text = 'PWR#1'
        OnChange = cbxStationChange
        Items.Strings = (
          'PWR#1'
          'PWR#2')
      end
      object cbxCarType: TComboBox
        Left = 454
        Top = 1
        Width = 79
        Height = 25
        Align = alRight
        Style = csDropDownList
        Ctl3D = False
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #47569#51008' '#44256#46357
        Font.Style = []
        ImeName = 'Microsoft IME 2003'
        ItemIndex = 0
        ParentCtl3D = False
        ParentFont = False
        TabOrder = 1
        Text = 'CAR1'
        OnChange = cbxStationChange
        Items.Strings = (
          'CAR1'
          'CAR2')
      end
      object cbxPosType: TComboBox
        Left = 533
        Top = 1
        Width = 79
        Height = 25
        Align = alRight
        Style = csDropDownList
        Ctl3D = False
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #47569#51008' '#44256#46357
        Font.Style = []
        ImeName = 'Microsoft IME 2003'
        ItemIndex = 0
        ParentCtl3D = False
        ParentFont = False
        TabOrder = 2
        Text = 'LH'
        OnChange = cbxStationChange
        Items.Strings = (
          'LH'
          'RH')
      end
    end
    object Panel1: TPanel
      Left = 1
      Top = 28
      Width = 613
      Height = 318
      Align = alTop
      Color = clWhite
      ParentBackground = False
      TabOrder = 1
      object pnlMtrJog: TPanel
        Left = 1
        Top = 1
        Width = 576
        Height = 316
        Align = alLeft
        BevelOuter = bvNone
        TabOrder = 0
        object ledBwRecl: TAbLED
          Left = 324
          Top = 48
          Width = 49
          Height = 64
          LED.Shape = sArrowLeft
          LED.ColorOn = 8454016
          LED.ColorOff = 14540253
          LED.Width = 40
          LED.Height = 40
          LED_Position = lpLeft
          Spacing = 5
          Checked = False
          Flashing = False
          Frequency = ff1Hz
          StatusInt = 0
          StatusBit = 0
          GroupIndex = 0
          Mode = mIndicator
          OnMouseDown = ledBwReclMouseDown
          OnMouseUp = ledFwReclMouseUp
        end
        object ledFwRecl: TAbLED
          Left = 485
          Top = 48
          Width = 49
          Height = 64
          LED.Shape = sArrowRight
          LED.ColorOn = 8454016
          LED.ColorOff = 14540253
          LED.Width = 40
          LED.Height = 40
          LED_Position = lpLeft
          Spacing = 5
          Checked = False
          Flashing = False
          Frequency = ff1Hz
          StatusInt = 0
          StatusBit = 0
          GroupIndex = 0
          Mode = mIndicator
          OnMouseDown = ledFwReclMouseDown
          OnMouseUp = ledFwReclMouseUp
        end
        object lblCurrRecl: TLabel
          Left = 373
          Top = 61
          Width = 103
          Height = 38
          Alignment = taCenter
          AutoSize = False
          Caption = '000 A'
          Color = clBlack
          Font.Charset = HANGEUL_CHARSET
          Font.Color = 11908607
          Font.Height = -16
          Font.Name = #47569#51008' '#44256#46357
          Font.Style = []
          ParentColor = False
          ParentFont = False
          Transparent = False
          Layout = tlCenter
        end
        object ledBwLSupt: TAbLED
          Tag = 1
          Left = 324
          Top = 146
          Width = 49
          Height = 64
          LED.Shape = sArrowLeft
          LED.ColorOn = 8454016
          LED.ColorOff = 14540253
          LED.Width = 40
          LED.Height = 40
          LED_Position = lpLeft
          Spacing = 5
          Checked = False
          Flashing = False
          Frequency = ff1Hz
          StatusInt = 0
          StatusBit = 0
          GroupIndex = 0
          Mode = mIndicator
          OnMouseDown = ledBwReclMouseDown
          OnMouseUp = ledFwReclMouseUp
        end
        object lblCurrLSupt: TLabel
          Left = 373
          Top = 160
          Width = 103
          Height = 38
          Alignment = taCenter
          AutoSize = False
          Caption = '000 A'
          Color = clBlack
          Font.Charset = HANGEUL_CHARSET
          Font.Color = 11908607
          Font.Height = -16
          Font.Name = #47569#51008' '#44256#46357
          Font.Style = []
          ParentColor = False
          ParentFont = False
          Transparent = False
          Layout = tlCenter
        end
        object ledFwLSupt: TAbLED
          Tag = 1
          Left = 485
          Top = 146
          Width = 49
          Height = 64
          LED.Shape = sArrowRight
          LED.ColorOn = 8454016
          LED.ColorOff = 14540253
          LED.Width = 40
          LED.Height = 40
          LED_Position = lpLeft
          Spacing = 5
          Checked = False
          Flashing = False
          Frequency = ff1Hz
          StatusInt = 0
          StatusBit = 0
          GroupIndex = 0
          Mode = mIndicator
          OnMouseDown = ledFwReclMouseDown
          OnMouseUp = ledFwReclMouseUp
        end
        object ledBwBolster: TAbLED
          Tag = 2
          Left = 324
          Top = 216
          Width = 49
          Height = 64
          LED.Shape = sArrowLeft
          LED.ColorOn = 8454016
          LED.ColorOff = 14540253
          LED.Width = 40
          LED.Height = 40
          LED_Position = lpLeft
          Spacing = 5
          Checked = False
          Flashing = False
          Frequency = ff1Hz
          StatusInt = 0
          StatusBit = 0
          GroupIndex = 0
          Mode = mIndicator
          OnMouseDown = ledBwReclMouseDown
          OnMouseUp = ledFwReclMouseUp
        end
        object lblCurrBolster: TLabel
          Left = 373
          Top = 230
          Width = 103
          Height = 38
          Alignment = taCenter
          AutoSize = False
          Caption = '000 A'
          Color = clBlack
          Font.Charset = HANGEUL_CHARSET
          Font.Color = 11908607
          Font.Height = -16
          Font.Name = #47569#51008' '#44256#46357
          Font.Style = []
          ParentColor = False
          ParentFont = False
          Transparent = False
          Layout = tlCenter
        end
        object ledFwBolster: TAbLED
          Tag = 2
          Left = 485
          Top = 216
          Width = 49
          Height = 64
          LED.Shape = sArrowRight
          LED.ColorOn = 8454016
          LED.ColorOff = 14540253
          LED.Width = 40
          LED.Height = 40
          LED_Position = lpLeft
          Spacing = 5
          Checked = False
          Flashing = False
          Frequency = ff1Hz
          StatusInt = 0
          StatusBit = 0
          GroupIndex = 0
          Mode = mIndicator
          OnMouseDown = ledFwReclMouseDown
          OnMouseUp = ledFwReclMouseUp
        end
        object lblCaption: TLabel
          Left = 56
          Top = 57
          Width = 177
          Height = 46
          Alignment = taCenter
          AutoSize = False
          Caption = 'RECL. MOTOR'
          Color = 9601404
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -15
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentColor = False
          ParentFont = False
          Transparent = False
          Layout = tlCenter
        end
        object Label3: TLabel
          Left = 56
          Top = 153
          Width = 177
          Height = 46
          Alignment = taCenter
          AutoSize = False
          Caption = 'LUMBAR SUPPORT'
          Color = 6707799
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -15
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentColor = False
          ParentFont = False
          Transparent = False
          Layout = tlCenter
        end
        object Label4: TLabel
          Left = 56
          Top = 225
          Width = 177
          Height = 46
          Alignment = taCenter
          AutoSize = False
          Caption = 'BOLSTER'
          Color = 6707799
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -15
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentColor = False
          ParentFont = False
          Transparent = False
          Layout = tlCenter
        end
      end
    end
  end
  object pnlCANFrame: TPanel
    Left = 618
    Top = 0
    Width = 306
    Height = 811
    Align = alRight
    DockSite = True
    TabOrder = 1
    OnDockDrop = pnlCANFrameDockDrop
    OnUnDock = pnlCANFrameUnDock
  end
  object tmrPoll: TTimer
    Enabled = False
    Interval = 100
    OnTimer = tmrPollTimer
    Left = 32
    Top = 688
  end
end
