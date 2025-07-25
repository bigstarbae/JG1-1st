object CanFrameMatrix: TCanFrameMatrix
  Left = 0
  Top = 0
  Width = 293
  Height = 228
  Color = clBtnFace
  Ctl3D = False
  ParentBackground = False
  ParentColor = False
  ParentCtl3D = False
  TabOrder = 0
  object lblBitOrdH: TLabel
    Left = 0
    Top = 0
    Width = 293
    Height = 16
    Align = alTop
    AutoSize = False
    Caption = '  7     6      5     4      3      2     1     0'
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = #44404#47548
    Font.Style = []
    ParentFont = False
    Layout = tlCenter
    ExplicitTop = -3
  end
  object Panel1: TPanel
    Left = 0
    Top = 16
    Width = 293
    Height = 24
    Align = alTop
    Padding.Left = 2
    Padding.Top = 2
    Padding.Right = 2
    Padding.Bottom = 2
    TabOrder = 0
    object ledBits1: TLedArray
      Left = 3
      Top = 3
      Width = 220
      Height = 18
      NoOfLEDs = 8
      LedWidth = 16
      LedHeight = 16
      Space = 12
      OnOff = 0
      Value = 0
      Orientation = lrHorizontal
      Align = alLeft
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = #44404#47548
      Font.Style = []
      ShowCaption = False
      OnColor = clLime
      OffColor = clGray
      Inverse = False
      Toggle = False
      OnLedClick = ledBits1LedClick
      Shape = stRoundRect
      Copyright = '1999 Mats Asplund/MAs Prod./2013 KII'
    end
    object lblBitOrdV1: TLabel
      Left = 223
      Top = 3
      Width = 22
      Height = 18
      Align = alLeft
      Alignment = taCenter
      AutoSize = False
      Caption = '0'
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlue
      Font.Height = -11
      Font.Name = #44404#47548
      Font.Style = []
      ParentFont = False
      Layout = tlCenter
      ExplicitLeft = 243
    end
    object edtData1: TEdit
      Left = 245
      Top = 3
      Width = 45
      Height = 18
      Align = alRight
      TabOrder = 0
      OnChange = edtData1Change
      OnKeyPress = edtData1KeyPress
      ExplicitHeight = 19
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 136
    Width = 293
    Height = 24
    Align = alTop
    Padding.Left = 2
    Padding.Top = 2
    Padding.Right = 2
    Padding.Bottom = 2
    TabOrder = 5
    object ledBits6: TLedArray
      Left = 3
      Top = 3
      Width = 220
      Height = 18
      NoOfLEDs = 8
      LedWidth = 16
      LedHeight = 16
      Space = 12
      OnOff = 0
      Value = 0
      Orientation = lrHorizontal
      Align = alLeft
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = #44404#47548
      Font.Style = []
      ShowCaption = False
      OnColor = clLime
      OffColor = clGray
      Inverse = False
      Toggle = False
      OnLedClick = ledBits1LedClick
      Shape = stRoundRect
      Copyright = '1999 Mats Asplund/MAs Prod./2013 KII'
    end
    object lblBitOrdV6: TLabel
      Left = 223
      Top = 3
      Width = 22
      Height = 18
      Align = alLeft
      Alignment = taCenter
      AutoSize = False
      Caption = '40'
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlue
      Font.Height = -11
      Font.Name = #44404#47548
      Font.Style = []
      ParentFont = False
      Layout = tlCenter
      ExplicitLeft = 243
    end
    object edtData6: TEdit
      Left = 245
      Top = 3
      Width = 45
      Height = 18
      Align = alRight
      TabOrder = 0
      OnChange = edtData1Change
      OnKeyPress = edtData1KeyPress
      ExplicitHeight = 19
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 112
    Width = 293
    Height = 24
    Align = alTop
    Padding.Left = 2
    Padding.Top = 2
    Padding.Right = 2
    Padding.Bottom = 2
    TabOrder = 4
    object ledBits5: TLedArray
      Left = 3
      Top = 3
      Width = 220
      Height = 18
      NoOfLEDs = 8
      LedWidth = 16
      LedHeight = 16
      Space = 12
      OnOff = 0
      Value = 0
      Orientation = lrHorizontal
      Align = alLeft
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = #44404#47548
      Font.Style = []
      ShowCaption = False
      OnColor = clLime
      OffColor = clGray
      Inverse = False
      Toggle = False
      OnLedClick = ledBits1LedClick
      Shape = stRoundRect
      Copyright = '1999 Mats Asplund/MAs Prod./2013 KII'
    end
    object lblBitOrdV5: TLabel
      Left = 223
      Top = 3
      Width = 22
      Height = 18
      Align = alLeft
      Alignment = taCenter
      AutoSize = False
      Caption = '32'
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlue
      Font.Height = -11
      Font.Name = #44404#47548
      Font.Style = []
      ParentFont = False
      Layout = tlCenter
      ExplicitLeft = 243
    end
    object edtData5: TEdit
      Left = 245
      Top = 3
      Width = 45
      Height = 18
      Align = alRight
      TabOrder = 0
      OnChange = edtData1Change
      OnKeyPress = edtData1KeyPress
      ExplicitHeight = 19
    end
  end
  object Panel4: TPanel
    Left = 0
    Top = 88
    Width = 293
    Height = 24
    Align = alTop
    Padding.Left = 2
    Padding.Top = 2
    Padding.Right = 2
    Padding.Bottom = 2
    TabOrder = 3
    object ledBits4: TLedArray
      Left = 3
      Top = 3
      Width = 220
      Height = 18
      NoOfLEDs = 8
      LedWidth = 16
      LedHeight = 16
      Space = 12
      OnOff = 0
      Value = 0
      Orientation = lrHorizontal
      Align = alLeft
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = #44404#47548
      Font.Style = []
      ShowCaption = False
      OnColor = clLime
      OffColor = clGray
      Inverse = False
      Toggle = False
      OnLedClick = ledBits1LedClick
      Shape = stRoundRect
      Copyright = '1999 Mats Asplund/MAs Prod./2013 KII'
    end
    object lblBitOrdV4: TLabel
      Left = 223
      Top = 3
      Width = 22
      Height = 18
      Align = alLeft
      Alignment = taCenter
      AutoSize = False
      Caption = '24'
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlue
      Font.Height = -11
      Font.Name = #44404#47548
      Font.Style = []
      ParentFont = False
      Layout = tlCenter
      ExplicitLeft = 243
    end
    object edtData4: TEdit
      Left = 245
      Top = 3
      Width = 45
      Height = 18
      Align = alRight
      TabOrder = 0
      OnChange = edtData1Change
      OnKeyPress = edtData1KeyPress
      ExplicitHeight = 19
    end
  end
  object Panel5: TPanel
    Left = 0
    Top = 64
    Width = 293
    Height = 24
    Align = alTop
    Padding.Left = 2
    Padding.Top = 2
    Padding.Right = 2
    Padding.Bottom = 2
    TabOrder = 2
    object ledBits3: TLedArray
      Left = 3
      Top = 3
      Width = 220
      Height = 18
      NoOfLEDs = 8
      LedWidth = 16
      LedHeight = 16
      Space = 12
      OnOff = 0
      Value = 0
      Orientation = lrHorizontal
      Align = alLeft
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = #44404#47548
      Font.Style = []
      ShowCaption = False
      OnColor = clLime
      OffColor = clGray
      Inverse = False
      Toggle = False
      OnLedClick = ledBits1LedClick
      Shape = stRoundRect
      Copyright = '1999 Mats Asplund/MAs Prod./2013 KII'
    end
    object lblBitOrdV3: TLabel
      Left = 223
      Top = 3
      Width = 22
      Height = 18
      Align = alLeft
      Alignment = taCenter
      AutoSize = False
      Caption = '16'
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlue
      Font.Height = -11
      Font.Name = #44404#47548
      Font.Style = []
      ParentFont = False
      Layout = tlCenter
      ExplicitLeft = 243
    end
    object edtData3: TEdit
      Left = 245
      Top = 3
      Width = 45
      Height = 18
      Align = alRight
      TabOrder = 0
      OnChange = edtData1Change
      OnKeyPress = edtData1KeyPress
      ExplicitHeight = 19
    end
  end
  object Panel6: TPanel
    Left = 0
    Top = 40
    Width = 293
    Height = 24
    Align = alTop
    Padding.Left = 2
    Padding.Top = 2
    Padding.Right = 2
    Padding.Bottom = 2
    TabOrder = 1
    object ledBits2: TLedArray
      Left = 3
      Top = 3
      Width = 220
      Height = 18
      NoOfLEDs = 8
      LedWidth = 16
      LedHeight = 16
      Space = 12
      OnOff = 0
      Value = 0
      Orientation = lrHorizontal
      Align = alLeft
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = #44404#47548
      Font.Style = []
      ShowCaption = False
      OnColor = clLime
      OffColor = clGray
      Inverse = False
      Toggle = False
      OnLedClick = ledBits1LedClick
      Shape = stRoundRect
      Copyright = '1999 Mats Asplund/MAs Prod./2013 KII'
    end
    object lblBitOrdV2: TLabel
      Left = 223
      Top = 3
      Width = 22
      Height = 18
      Align = alLeft
      Alignment = taCenter
      AutoSize = False
      Caption = '8'
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlue
      Font.Height = -11
      Font.Name = #44404#47548
      Font.Style = []
      ParentFont = False
      Layout = tlCenter
      ExplicitLeft = 243
    end
    object edtData2: TEdit
      Left = 245
      Top = 3
      Width = 45
      Height = 18
      Align = alRight
      TabOrder = 0
      OnChange = edtData1Change
      OnKeyPress = edtData1KeyPress
      ExplicitHeight = 19
    end
  end
  object Panel7: TPanel
    Left = 0
    Top = 184
    Width = 293
    Height = 24
    Align = alTop
    Padding.Left = 2
    Padding.Top = 2
    Padding.Right = 2
    Padding.Bottom = 2
    TabOrder = 7
    object ledBits8: TLedArray
      Left = 3
      Top = 3
      Width = 220
      Height = 18
      NoOfLEDs = 8
      LedWidth = 16
      LedHeight = 16
      Space = 12
      OnOff = 0
      Value = 0
      Orientation = lrHorizontal
      Align = alLeft
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = #44404#47548
      Font.Style = []
      ShowCaption = False
      OnColor = clLime
      OffColor = clGray
      Inverse = False
      Toggle = False
      OnLedClick = ledBits1LedClick
      Shape = stRoundRect
      Copyright = '1999 Mats Asplund/MAs Prod./2013 KII'
    end
    object lblBitOrdV8: TLabel
      Left = 223
      Top = 3
      Width = 22
      Height = 18
      Align = alLeft
      Alignment = taCenter
      AutoSize = False
      Caption = '56'
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlue
      Font.Height = -11
      Font.Name = #44404#47548
      Font.Style = []
      ParentFont = False
      Layout = tlCenter
      ExplicitLeft = 243
    end
    object edtData8: TEdit
      Left = 245
      Top = 3
      Width = 45
      Height = 18
      Align = alRight
      TabOrder = 0
      OnChange = edtData1Change
      OnKeyPress = edtData1KeyPress
      ExplicitHeight = 19
    end
  end
  object Panel8: TPanel
    Left = 0
    Top = 160
    Width = 293
    Height = 24
    Align = alTop
    Padding.Left = 2
    Padding.Top = 2
    Padding.Right = 2
    Padding.Bottom = 2
    TabOrder = 6
    object ledBits7: TLedArray
      Left = 3
      Top = 3
      Width = 220
      Height = 18
      NoOfLEDs = 8
      LedWidth = 16
      LedHeight = 16
      Space = 12
      OnOff = 0
      Value = 0
      Orientation = lrHorizontal
      Align = alLeft
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = #44404#47548
      Font.Style = []
      ShowCaption = False
      OnColor = clLime
      OffColor = clGray
      Inverse = False
      Toggle = False
      OnLedClick = ledBits1LedClick
      Shape = stRoundRect
      Copyright = '1999 Mats Asplund/MAs Prod./2013 KII'
    end
    object lblBitOrdV7: TLabel
      Left = 223
      Top = 3
      Width = 22
      Height = 18
      Align = alLeft
      Alignment = taCenter
      AutoSize = False
      Caption = '48'
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlue
      Font.Height = -11
      Font.Name = #44404#47548
      Font.Style = []
      ParentFont = False
      Layout = tlCenter
      ExplicitLeft = 243
    end
    object edtData7: TEdit
      Left = 245
      Top = 3
      Width = 45
      Height = 18
      Align = alRight
      TabOrder = 0
      OnChange = edtData1Change
      OnKeyPress = edtData1KeyPress
      ExplicitHeight = 19
    end
  end
  object tcOffset: TTabControl
    Left = 0
    Top = 208
    Width = 293
    Height = 17
    Align = alTop
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    OwnerDraw = True
    ParentFont = False
    TabOrder = 8
    TabPosition = tpBottom
    Tabs.Strings = (
      '0'
      '8'
      '16'
      '24'
      '32'
      '40'
      '48'
      '56')
    TabIndex = 0
    TabWidth = 34
    OnChange = tcOffsetChange
    OnChanging = tcOffsetChanging
    OnDrawTab = tcOffsetDrawTab
  end
end
