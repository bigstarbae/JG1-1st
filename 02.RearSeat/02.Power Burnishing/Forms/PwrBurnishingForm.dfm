inherited frmPwrBurnishing: TfrmPwrBurnishing
  Top = 60
  BorderStyle = bsNone
  Caption = 'Power Burnishing Tester'
  ClientHeight = 1080
  ClientWidth = 1920
  HelpFile = '1080'
  Position = poDesigned
  WindowState = wsNormal
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  ExplicitLeft = -300
  ExplicitTop = -392
  ExplicitWidth = 1920
  ExplicitHeight = 1080
  PixelsPerInch = 96
  TextHeight = 17
  object shpConseparator: TShape [0]
    Left = 1694
    Top = 194
    Width = 1
    Height = 735
    Align = alRight
    Brush.Color = clSilver
    Brush.Style = bsDiagCross
    Pen.Color = 12695993
    ExplicitLeft = 226
    ExplicitTop = 163
    ExplicitHeight = 727
  end
  inherited pnlTitle: TPanel
    Width = 1920
    ExplicitWidth = 1920
    inherited lblSimLanInMode: TLabel3D
      Left = 0
      OnClick = lblSimLanInModeClick
      ExplicitLeft = 0
    end
  end
  inherited pnlStatus: TPanel
    Top = 1056
    Width = 1920
    TabOrder = 8
    ExplicitTop = 1056
    ExplicitWidth = 1920
    inherited pnlCommStatus: TPanel
      inherited Label2: TLabel
        Height = 24
      end
      inherited abCAN: TAbLED
        Visible = False
      end
    end
    inherited pnlExtra: TPanel
      Left = 1601
      Width = 319
      ExplicitLeft = 1601
      ExplicitWidth = 319
      object lblWorkMonitor: TLabel
        Left = 212
        Top = 0
        Width = 107
        Height = 24
        Align = alRight
        Alignment = taCenter
        Caption = 'P/C 33.3 / 66.6 High '
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWhite
        Font.Height = -12
        Font.Name = #47569#51008' '#44256#46357' Semilight'
        Font.Style = []
        ParentFont = False
        Layout = tlCenter
        ExplicitHeight = 15
      end
      object lblMemory: TLabel
        Left = 0
        Top = 0
        Width = 58
        Height = 24
        Align = alRight
        Caption = 'lblMemory'
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clGray
        Font.Height = -12
        Font.Name = #47569#51008' '#44256#46357
        Font.Style = []
        ParentFont = False
        Layout = tlCenter
        ExplicitHeight = 15
      end
      object lblCycleTime: TLabel
        Left = 58
        Top = 0
        Width = 154
        Height = 24
        Align = alRight
        Alignment = taCenter
        AutoSize = False
        Caption = '#23 123.4'
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clGray
        Font.Height = -12
        Font.Name = #47569#51008' '#44256#46357
        Font.Style = []
        ParentFont = False
        Layout = tlCenter
        ExplicitLeft = -48
        ExplicitTop = -8
      end
    end
  end
  inherited pnlTop: TPanel
    Width = 1920
    ExplicitWidth = 1920
    inherited lblResult: TLabel3D
      Left = 1695
      Width = 225
      ExplicitLeft = 1695
      ExplicitWidth = 225
    end
    inherited lblMode: TLabel3D
      Left = 1550
      Width = 145
      ExplicitLeft = 1552
      ExplicitWidth = 145
    end
    inline fmModelInfo: TMdllInfoFrame
      Left = 0
      Top = 0
      Width = 1550
      Height = 114
      Align = alClient
      TabOrder = 0
      ExplicitWidth = 1550
      ExplicitHeight = 114
      inherited pnlMdlInfo: TPanel
        Width = 1550
        Height = 114
        ExplicitWidth = 1550
        ExplicitHeight = 114
        inherited pnlPartInfo: TPanel
          Height = 114
          ExplicitHeight = 114
          inherited lblLotNo: TLabel3D
            Height = 37
            ExplicitHeight = 37
          end
        end
        inherited pnlPos: TPanel
          Height = 114
          ExplicitHeight = 114
          inherited pnl2: TPanel
            Height = 98
            ExplicitHeight = 98
            inherited lblRH: TLabel3D
              Height = 48
              ExplicitHeight = 48
            end
          end
        end
        inherited pnlClass: TPanel
          Height = 114
          ExplicitHeight = 114
          inherited pnlClassClient: TPanel
            Height = 98
            ExplicitHeight = 98
          end
        end
        inherited pnlCarSubType: TPanel
          Height = 114
          ExplicitHeight = 114
          inherited pnlCarSubTypeClient: TPanel
            Height = 98
            ExplicitHeight = 98
            inherited lblSE: TLabel3D
              Height = 48
              ExplicitHeight = 48
            end
          end
        end
        inherited pnlECU: TPanel
          Height = 114
          ExplicitHeight = 114
          inherited pnlECUClient: TPanel
            Height = 98
            ExplicitHeight = 98
            inherited lblSAU: TLabel3D
              Height = 48
              ExplicitHeight = 48
            end
          end
        end
        inherited pnlBuckle: TPanel
          Height = 114
          ExplicitHeight = 114
          inherited pnlBuckleClient: TPanel
            Height = 98
            ExplicitHeight = 98
            inherited lblCenterBuckle: TLabel3D
              Top = 65
              ExplicitTop = 65
            end
            inherited lblILLBuckle: TLabel3D
              Height = 32
              ExplicitHeight = 32
            end
          end
        end
        inherited pnlHV: TPanel
          Height = 114
          ExplicitHeight = 114
          inherited pnlHVClient: TPanel
            Height = 98
            ExplicitHeight = 98
            inherited lblHV: TLabel3D
              Height = 48
              ExplicitHeight = 48
            end
          end
        end
        inherited pnlMotors: TPanel
          Width = 294
          Height = 114
          ExplicitWidth = 294
          ExplicitHeight = 114
          inherited pnlMotorsTitle: TPanel
            Width = 294
            ExplicitWidth = 294
          end
          inherited pnlMotorsTop: TPanel
            Width = 294
            ExplicitWidth = 294
          end
          inherited pnlMotorsBottom: TPanel
            Width = 294
            Height = 50
            ExplicitWidth = 294
            ExplicitHeight = 50
            inherited lblShoulder: TLabel3D
              Height = 50
              ExplicitHeight = 50
            end
            inherited lblHeadRest: TLabel3D
              Height = 50
              ExplicitHeight = 50
            end
            inherited lblRelax: TLabel3D
              Height = 50
              ExplicitHeight = 50
            end
          end
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 948
    Width = 1920
    TabOrder = 7
    ExplicitTop = 948
    ExplicitWidth = 1920
    inherited pnlRTVals: TPanel
      Width = 365
      ExplicitWidth = 365
      object Label19: TLabel
        Left = 32
        Top = 21
        Width = 55
        Height = 20
        Alignment = taRightJustify
        Caption = 'MOTOR'
        Font.Charset = HANGEUL_CHARSET
        Font.Color = 14145495
        Font.Height = -15
        Font.Name = #47569#51008' '#44256#46357
        Font.Style = []
        ParentFont = False
        Visible = False
      end
      object lblMotorCurr: TLabel
        Left = 107
        Top = 12
        Width = 47
        Height = 31
        Alignment = taRightJustify
        AutoSize = False
        Caption = '000'
        Color = 4013373
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 9357311
        Font.Height = -27
        Font.Name = #47569#51008' '#44256#46357
        Font.Style = []
        ParentColor = False
        ParentFont = False
        Transparent = True
        Layout = tlCenter
        Visible = False
      end
      object Label99: TLabel
        Left = 165
        Top = 25
        Width = 25
        Height = 13
        AutoSize = False
        Caption = 'A'
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clSilver
        Font.Height = -12
        Font.Name = #47569#51008' '#44256#46357
        Font.Style = []
        ParentFont = False
        Transparent = True
        Layout = tlCenter
        Visible = False
      end
    end
    inherited pnlLog: TPanel
      Left = 1066
      ExplicitLeft = 1066
    end
    inherited pnlWorkStatus: TPanel
      Left = 365
      Width = 701
      ExplicitLeft = 365
      ExplicitWidth = 701
      inherited lblStatus: TLabel3D
        Width = 701
        ExplicitLeft = 6
        ExplicitTop = 15
        ExplicitWidth = 381
      end
      inherited pnlWorkStatusTitle: TPanel
        Width = 701
        ExplicitWidth = 701
      end
    end
    inherited pnlPdtCnt: TPanel
      Left = 1697
      Width = 223
      Visible = False
      ExplicitLeft = 1697
      ExplicitWidth = 223
      inherited Panel3: TPanel
        Width = 223
        ExplicitWidth = 223
        inherited lblOK: TLabel
          Left = 98
          ExplicitLeft = 98
        end
      end
      inherited Panel6: TPanel
        Width = 223
        ExplicitWidth = 223
        inherited lblNG: TLabel
          Left = 102
          ExplicitLeft = 102
        end
      end
      inherited Panel4: TPanel
        Width = 223
        ExplicitWidth = 223
        inherited lblTot: TLabel
          Left = 102
          ExplicitLeft = 102
        end
      end
    end
  end
  inherited pnlSysStatus: TPanel
    Top = 929
    Width = 1920
    ExplicitTop = 929
    ExplicitWidth = 1920
    inherited abCable: TAbLED
      Left = 114
      Top = -2
      Height = 25
      Visible = True
      ExplicitLeft = 114
      ExplicitTop = -2
      ExplicitHeight = 25
    end
    inherited abPop: TAbLED
      Top = -2
      Height = 25
      ExplicitTop = -2
      ExplicitHeight = 25
    end
    object abDiskD: TAbLED
      Left = 1787
      Top = 2
      Width = 122
      Height = 16
      Caption = 'Disk(D:) 100 %'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      LED.Shape = sRectangle
      LED.Width = 15
      LED.Height = 10
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
    object abDiskC: TAbLED
      Left = 1650
      Top = 2
      Width = 122
      Height = 16
      Caption = 'Disk(C:) 100 %'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      LED.Shape = sRectangle
      LED.Width = 15
      LED.Height = 10
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
  end
  inherited pnlMsg: TPanel
    TabOrder = 6
  end
  object pnlClient: TPanel [7]
    Left = 0
    Top = 194
    Width = 1694
    Height = 735
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 3
    object shpTop: TShape
      Left = 0
      Top = 0
      Width = 1694
      Height = 20
      Align = alTop
      Brush.Style = bsDiagCross
      Pen.Color = clWhite
    end
    object shpLeft: TShape
      Left = 0
      Top = 20
      Width = 20
      Height = 662
      Align = alLeft
      Brush.Style = bsDiagCross
      Pen.Color = clWhite
      ExplicitTop = 81
      ExplicitHeight = 601
    end
    object shpRight: TShape
      Left = 1632
      Top = 20
      Width = 62
      Height = 662
      Align = alRight
      Brush.Style = bsDiagCross
      Pen.Color = clWhite
      ExplicitLeft = 915
      ExplicitTop = 81
      ExplicitHeight = 545
    end
    object shpBottom: TShape
      Left = 0
      Top = 682
      Width = 1694
      Height = 53
      Align = alBottom
      Brush.Style = bsDiagCross
      Pen.Color = clWhite
      ExplicitLeft = 79
      ExplicitTop = 6
      ExplicitWidth = 1678
    end
    object pnlGrp: TPanel
      Left = 20
      Top = 20
      Width = 1619
      Height = 662
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 0
      object shpGap2: TShape
        Left = 0
        Top = 282
        Width = 1619
        Height = 17
        Align = alTop
        Brush.Style = bsDiagCross
        Pen.Color = clWhite
        ExplicitLeft = 32
        ExplicitTop = 360
        ExplicitWidth = 1557
      end
      object Shape3: TShape
        Left = 0
        Top = 660
        Width = 1619
        Height = 2
        Align = alBottom
        Brush.Color = 5789784
        Pen.Color = 5789784
        ExplicitTop = 216
        ExplicitWidth = 724
      end
      object pnlLegend: TPanel
        Left = 0
        Top = 0
        Width = 1619
        Height = 25
        Align = alTop
        BevelOuter = bvNone
        Color = clWhite
        ParentBackground = False
        TabOrder = 0
        object lblCaption: TLabel
          Left = 0
          Top = 0
          Width = 297
          Height = 23
          Align = alLeft
          Alignment = taCenter
          AutoSize = False
          Caption = '  MOTOR '#51204#47448'(A)'
          Color = 4800317
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -15
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentColor = False
          ParentFont = False
          Transparent = False
          Layout = tlCenter
          ExplicitLeft = -7
          ExplicitTop = -8
        end
        object Shape2: TShape
          Left = 0
          Top = 23
          Width = 1619
          Height = 2
          Align = alBottom
          Brush.Color = 5789784
          Pen.Color = 5789784
          ExplicitTop = 216
          ExplicitWidth = 724
        end
      end
      object chtMtr: TChart
        Left = 0
        Top = 25
        Width = 1619
        Height = 257
        BackWall.Color = 5395026
        BackWall.Transparent = False
        Legend.Alignment = laBottom
        Legend.CheckBoxes = True
        Legend.DividingLines.Style = psDash
        Legend.Font.Name = #47569#51008' '#44256#46357
        Legend.FontSeriesColor = True
        Legend.Frame.Visible = False
        Legend.LegendStyle = lsSeries
        Legend.Shadow.HorizSize = 2
        Legend.Shadow.VertSize = 2
        Legend.Shadow.Visible = False
        Legend.TopPos = 36
        Legend.VertMargin = 1
        Legend.Visible = False
        MarginBottom = 0
        MarginLeft = 0
        MarginTop = 0
        PrintProportional = False
        Title.AdjustFrame = False
        Title.BevelWidth = 1
        Title.Font.Color = 8404992
        Title.Font.Height = -13
        Title.Font.Name = #47569#51008' '#44256#46357
        Title.Font.Style = [fsBold]
        Title.Text.Strings = (
          '')
        BottomAxis.Automatic = False
        BottomAxis.AutomaticMaximum = False
        BottomAxis.AutomaticMinimum = False
        BottomAxis.ExactDateTime = False
        BottomAxis.Grid.Color = 14935011
        BottomAxis.Grid.Visible = False
        BottomAxis.Increment = 1.000000000000000000
        BottomAxis.Maximum = 24.000000000000000000
        DepthAxis.Automatic = False
        DepthAxis.AutomaticMaximum = False
        DepthAxis.AutomaticMinimum = False
        DepthAxis.Maximum = 1.100000000000001000
        DepthAxis.Minimum = 0.100000000000000100
        DepthTopAxis.Automatic = False
        DepthTopAxis.AutomaticMaximum = False
        DepthTopAxis.AutomaticMinimum = False
        DepthTopAxis.Maximum = 1.100000000000001000
        DepthTopAxis.Minimum = 0.100000000000000100
        LeftAxis.Automatic = False
        LeftAxis.AutomaticMaximum = False
        LeftAxis.AutomaticMinimum = False
        LeftAxis.Grid.Color = 8224125
        LeftAxis.Maximum = 842.649999999999600000
        LeftAxis.Minimum = 220.150000000000200000
        LeftAxis.Title.Angle = 0
        LeftAxis.Title.Caption = '(A)'
        LeftAxis.Title.Visible = False
        RightAxis.Automatic = False
        RightAxis.AutomaticMaximum = False
        RightAxis.AutomaticMinimum = False
        RightAxis.Grid.Visible = False
        RightAxis.Maximum = 758.250000000000000000
        RightAxis.Minimum = 20.750000000000000000
        RightAxis.Title.Angle = 0
        RightAxis.Title.Caption = '(dB)'
        View3D = False
        Zoom.Pen.Color = clSilver
        Align = alTop
        BevelOuter = bvNone
        Color = clWhite
        TabOrder = 1
        PrintMargins = (
          15
          0
          15
          0)
        object FastLineSeries6: TFastLineSeries
          Marks.Arrow.Visible = True
          Marks.Callout.Brush.Color = clBlack
          Marks.Callout.Arrow.Visible = True
          Marks.Visible = False
          SeriesColor = clYellow
          Title = 'Slide'
          LinePen.Color = clYellow
          XValues.Name = 'X'
          XValues.Order = loNone
          YValues.Name = 'Y'
          YValues.Order = loAscending
        end
        object Series1: TFastLineSeries
          Active = False
          Marks.Arrow.Visible = True
          Marks.Callout.Brush.Color = clBlack
          Marks.Callout.Arrow.Visible = True
          Marks.Visible = False
          SeriesColor = 8454016
          Title = 'Tilt'
          LinePen.Color = 8454016
          XValues.Name = 'X'
          XValues.Order = loAscending
          YValues.Name = 'Y'
          YValues.Order = loNone
        end
        object Series2: TFastLineSeries
          Marks.Arrow.Visible = True
          Marks.Callout.Brush.Color = clBlack
          Marks.Callout.Arrow.Visible = True
          Marks.Visible = False
          SeriesColor = 13553407
          Title = 'Height'
          LinePen.Color = 13553407
          XValues.Name = 'X'
          XValues.Order = loAscending
          YValues.Name = 'Y'
          YValues.Order = loNone
        end
        object Series3: TFastLineSeries
          Active = False
          Marks.Arrow.Visible = True
          Marks.Callout.Brush.Color = clBlack
          Marks.Callout.Arrow.Visible = True
          Marks.Visible = False
          SeriesColor = 16767449
          Title = 'CushExt'
          LinePen.Color = 16767449
          XValues.Name = 'X'
          XValues.Order = loAscending
          YValues.Name = 'Y'
          YValues.Order = loNone
        end
      end
      object pnlBurnInfo: TPanel
        Left = 746
        Top = 295
        Width = 842
        Height = 358
        BevelOuter = bvNone
        TabOrder = 2
        object pnlBurn_Slide: TPanel
          Left = 0
          Top = 0
          Width = 842
          Height = 59
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 0
          object lblBrnCnt_Slide: TLabel3D
            Tag = 1
            Left = 310
            Top = 0
            Width = 532
            Height = 59
            ShowTitle = False
            TitleColor = clGray
            TitleFont.Charset = DEFAULT_CHARSET
            TitleFont.Color = clWindowText
            TitleFont.Height = -11
            TitleFont.Name = 'Tahoma'
            TitleFont.Style = []
            TitleHeightRatio = 0.200000000000000000
            BorderColor = clGray
            BorderPenStyle = psDot
            Border = True
            BorderType = btBorderLine
            BorderLineT = True
            BorderLineR = False
            BorderLineB = True
            BorderLineL = False
            Escapement = 0
            TextStyle = tsNone
            LabelStyle = lsDefault
            EllipsesStyle = esNone
            Shift = 1
            Align = alClient
            Alignment = taCenter
            AutoSize = False
            Caption = '0/3'
            Color = clWhite
            Font.Charset = ANSI_CHARSET
            Font.Color = 12615680
            Font.Height = -48
            Font.Name = #48148#47480#44277#44400#52404' Medium'
            Font.Style = [fsBold]
            Layout = tlCenter
            ParentColor = False
            ParentFont = False
            Transparent = False
            ExplicitWidth = 247
          end
          object Label3D2: TLabel3D
            Tag = 1
            Left = 0
            Top = 0
            Width = 310
            Height = 59
            ShowTitle = False
            TitleColor = clGray
            TitleFont.Charset = DEFAULT_CHARSET
            TitleFont.Color = clWindowText
            TitleFont.Height = -11
            TitleFont.Name = 'Tahoma'
            TitleFont.Style = []
            TitleHeightRatio = 0.200000000000000000
            BorderColor = clGray
            BorderPenStyle = psDot
            Border = True
            BorderType = btBorderLine
            BorderLineT = True
            BorderLineR = False
            BorderLineB = True
            BorderLineL = False
            Escapement = 0
            TextStyle = tsNone
            LabelStyle = lsDefault
            EllipsesStyle = esNone
            Shift = 1
            Align = alLeft
            Alignment = taRightJustify
            AutoSize = False
            Caption = 'SLIDE'
            Color = clWhite
            Font.Charset = ANSI_CHARSET
            Font.Color = clGray
            Font.Height = -27
            Font.Name = #48148#47480#44277#44400#52404' Medium'
            Font.Style = [fsBold]
            Layout = tlCenter
            ParentColor = False
            ParentFont = False
            Transparent = False
          end
        end
        object pnlBurn_CushTilt: TPanel
          Left = 0
          Top = 59
          Width = 842
          Height = 59
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 1
          object lblBrnCnt_CushTilt: TLabel3D
            Tag = 1
            Left = 310
            Top = 0
            Width = 532
            Height = 59
            ShowTitle = False
            TitleColor = clGray
            TitleFont.Charset = DEFAULT_CHARSET
            TitleFont.Color = clWindowText
            TitleFont.Height = -11
            TitleFont.Name = 'Tahoma'
            TitleFont.Style = []
            TitleHeightRatio = 0.200000000000000000
            BorderColor = clGray
            BorderPenStyle = psDot
            Border = True
            BorderType = btBorderLine
            BorderLineT = True
            BorderLineR = False
            BorderLineB = True
            BorderLineL = False
            Escapement = 0
            TextStyle = tsNone
            LabelStyle = lsDefault
            EllipsesStyle = esNone
            Shift = 1
            Align = alClient
            Alignment = taCenter
            AutoSize = False
            Caption = '0/3'
            Color = clWhite
            Font.Charset = ANSI_CHARSET
            Font.Color = 12615680
            Font.Height = -48
            Font.Name = #48148#47480#44277#44400#52404' Medium'
            Font.Style = [fsBold]
            Layout = tlCenter
            ParentColor = False
            ParentFont = False
            Transparent = False
            ExplicitWidth = 247
          end
          object lbl1: TLabel3D
            Tag = 1
            Left = 0
            Top = 0
            Width = 310
            Height = 59
            ShowTitle = False
            TitleColor = clGray
            TitleFont.Charset = DEFAULT_CHARSET
            TitleFont.Color = clWindowText
            TitleFont.Height = -11
            TitleFont.Name = 'Tahoma'
            TitleFont.Style = []
            TitleHeightRatio = 0.200000000000000000
            BorderColor = clGray
            BorderPenStyle = psDot
            Border = True
            BorderType = btBorderLine
            BorderLineT = True
            BorderLineR = False
            BorderLineB = True
            BorderLineL = False
            Escapement = 0
            TextStyle = tsNone
            LabelStyle = lsDefault
            EllipsesStyle = esNone
            Shift = 1
            Align = alLeft
            Alignment = taRightJustify
            AutoSize = False
            Caption = 'CUSH TILT'
            Color = clWhite
            Font.Charset = ANSI_CHARSET
            Font.Color = clGray
            Font.Height = -27
            Font.Name = #48148#47480#44277#44400#52404' Medium'
            Font.Style = [fsBold]
            Layout = tlCenter
            ParentColor = False
            ParentFont = False
            Transparent = False
          end
        end
        object pnlBurn_Recl: TPanel
          Left = 0
          Top = 177
          Width = 842
          Height = 59
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 2
          ExplicitTop = 118
          object lblBrnCnt_Recl: TLabel3D
            Tag = 1
            Left = 310
            Top = 0
            Width = 532
            Height = 59
            ShowTitle = False
            TitleColor = clGray
            TitleFont.Charset = DEFAULT_CHARSET
            TitleFont.Color = clWindowText
            TitleFont.Height = -11
            TitleFont.Name = 'Tahoma'
            TitleFont.Style = []
            TitleHeightRatio = 0.200000000000000000
            BorderColor = clGray
            BorderPenStyle = psDot
            Border = True
            BorderType = btBorderLine
            BorderLineT = True
            BorderLineR = False
            BorderLineB = True
            BorderLineL = False
            Escapement = 0
            TextStyle = tsNone
            LabelStyle = lsDefault
            EllipsesStyle = esNone
            Shift = 1
            Align = alClient
            Alignment = taCenter
            AutoSize = False
            Caption = '0/3'
            Color = clWhite
            Font.Charset = ANSI_CHARSET
            Font.Color = 12615680
            Font.Height = -48
            Font.Name = #48148#47480#44277#44400#52404' Medium'
            Font.Style = [fsBold]
            Layout = tlCenter
            ParentColor = False
            ParentFont = False
            Transparent = False
            ExplicitWidth = 247
          end
          object lbl2: TLabel3D
            Tag = 1
            Left = 0
            Top = 0
            Width = 310
            Height = 59
            ShowTitle = False
            TitleColor = clGray
            TitleFont.Charset = DEFAULT_CHARSET
            TitleFont.Color = clWindowText
            TitleFont.Height = -11
            TitleFont.Name = 'Tahoma'
            TitleFont.Style = []
            TitleHeightRatio = 0.200000000000000000
            BorderColor = clGray
            BorderPenStyle = psDot
            Border = True
            BorderType = btBorderLine
            BorderLineT = True
            BorderLineR = False
            BorderLineB = True
            BorderLineL = False
            Escapement = 0
            TextStyle = tsNone
            LabelStyle = lsDefault
            EllipsesStyle = esNone
            Shift = 1
            Align = alLeft
            Alignment = taRightJustify
            AutoSize = False
            Caption = 'RECLINE'
            Color = clWhite
            Font.Charset = ANSI_CHARSET
            Font.Color = clGray
            Font.Height = -27
            Font.Name = #48148#47480#44277#44400#52404' Medium'
            Font.Style = [fsBold]
            Layout = tlCenter
            ParentColor = False
            ParentFont = False
            Transparent = False
          end
        end
        object pnlBurn_Shoulder: TPanel
          Left = 0
          Top = 295
          Width = 842
          Height = 59
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 3
          ExplicitTop = 177
          object lblBrnCnt_Shoulder: TLabel3D
            Tag = 1
            Left = 310
            Top = 0
            Width = 532
            Height = 59
            ShowTitle = False
            TitleColor = clGray
            TitleFont.Charset = DEFAULT_CHARSET
            TitleFont.Color = clWindowText
            TitleFont.Height = -11
            TitleFont.Name = 'Tahoma'
            TitleFont.Style = []
            TitleHeightRatio = 0.200000000000000000
            BorderColor = clGray
            BorderPenStyle = psDot
            Border = True
            BorderType = btBorderLine
            BorderLineT = True
            BorderLineR = False
            BorderLineB = True
            BorderLineL = False
            Escapement = 0
            TextStyle = tsNone
            LabelStyle = lsDefault
            EllipsesStyle = esNone
            Shift = 1
            Align = alClient
            Alignment = taCenter
            AutoSize = False
            Caption = '0/3'
            Color = clWhite
            Font.Charset = ANSI_CHARSET
            Font.Color = 12615680
            Font.Height = -48
            Font.Name = #48148#47480#44277#44400#52404' Medium'
            Font.Style = [fsBold]
            Layout = tlCenter
            ParentColor = False
            ParentFont = False
            Transparent = False
            ExplicitWidth = 247
          end
          object lbl3: TLabel3D
            Tag = 1
            Left = 0
            Top = 0
            Width = 310
            Height = 59
            ShowTitle = False
            TitleColor = clGray
            TitleFont.Charset = DEFAULT_CHARSET
            TitleFont.Color = clWindowText
            TitleFont.Height = -11
            TitleFont.Name = 'Tahoma'
            TitleFont.Style = []
            TitleHeightRatio = 0.200000000000000000
            BorderColor = clGray
            BorderPenStyle = psDot
            Border = True
            BorderType = btBorderLine
            BorderLineT = True
            BorderLineR = False
            BorderLineB = True
            BorderLineL = False
            Escapement = 0
            TextStyle = tsNone
            LabelStyle = lsDefault
            EllipsesStyle = esNone
            Shift = 1
            Align = alLeft
            Alignment = taRightJustify
            AutoSize = False
            Caption = 'SHOULDER'
            Color = clWhite
            Font.Charset = ANSI_CHARSET
            Font.Color = clGray
            Font.Height = -27
            Font.Name = #48148#47480#44277#44400#52404' Medium'
            Font.Style = [fsBold]
            Layout = tlCenter
            ParentColor = False
            ParentFont = False
            Transparent = False
          end
        end
        object pnlBurn_Relax: TPanel
          Left = 0
          Top = 236
          Width = 842
          Height = 59
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 4
          object lblBrnCnt_Relax: TLabel3D
            Tag = 1
            Left = 310
            Top = 0
            Width = 532
            Height = 59
            ShowTitle = False
            TitleColor = clGray
            TitleFont.Charset = DEFAULT_CHARSET
            TitleFont.Color = clWindowText
            TitleFont.Height = -11
            TitleFont.Name = 'Tahoma'
            TitleFont.Style = []
            TitleHeightRatio = 0.200000000000000000
            BorderColor = clGray
            BorderPenStyle = psDot
            Border = True
            BorderType = btBorderLine
            BorderLineT = True
            BorderLineR = False
            BorderLineB = True
            BorderLineL = False
            Escapement = 0
            TextStyle = tsNone
            LabelStyle = lsDefault
            EllipsesStyle = esNone
            Shift = 1
            Align = alClient
            Alignment = taCenter
            AutoSize = False
            Caption = '0/3'
            Color = clWhite
            Font.Charset = ANSI_CHARSET
            Font.Color = 12615680
            Font.Height = -48
            Font.Name = #48148#47480#44277#44400#52404' Medium'
            Font.Style = [fsBold]
            Layout = tlCenter
            ParentColor = False
            ParentFont = False
            Transparent = False
            ExplicitTop = -1
          end
          object lbl4: TLabel3D
            Tag = 1
            Left = 0
            Top = 0
            Width = 310
            Height = 59
            ShowTitle = False
            TitleColor = clGray
            TitleFont.Charset = DEFAULT_CHARSET
            TitleFont.Color = clWindowText
            TitleFont.Height = -11
            TitleFont.Name = 'Tahoma'
            TitleFont.Style = []
            TitleHeightRatio = 0.200000000000000000
            BorderColor = clGray
            BorderPenStyle = psDot
            Border = True
            BorderType = btBorderLine
            BorderLineT = True
            BorderLineR = False
            BorderLineB = True
            BorderLineL = False
            Escapement = 0
            TextStyle = tsNone
            LabelStyle = lsDefault
            EllipsesStyle = esNone
            Shift = 1
            Align = alLeft
            Alignment = taRightJustify
            AutoSize = False
            Caption = 'RELAX'
            Color = clWhite
            Font.Charset = ANSI_CHARSET
            Font.Color = clGray
            Font.Height = -27
            Font.Name = #48148#47480#44277#44400#52404' Medium'
            Font.Style = [fsBold]
            Layout = tlCenter
            ParentColor = False
            ParentFont = False
            Transparent = False
            ExplicitTop = -1
          end
        end
        object pnlBurn_WalkinTilt: TPanel
          Left = 0
          Top = 118
          Width = 842
          Height = 59
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 5
          ExplicitTop = 236
          object lblBrnCnt_WalkinTilt: TLabel3D
            Tag = 1
            Left = 310
            Top = 0
            Width = 532
            Height = 59
            ShowTitle = False
            TitleColor = clGray
            TitleFont.Charset = DEFAULT_CHARSET
            TitleFont.Color = clWindowText
            TitleFont.Height = -11
            TitleFont.Name = 'Tahoma'
            TitleFont.Style = []
            TitleHeightRatio = 0.200000000000000000
            BorderColor = clGray
            BorderPenStyle = psDot
            Border = True
            BorderType = btBorderLine
            BorderLineT = True
            BorderLineR = False
            BorderLineB = True
            BorderLineL = False
            Escapement = 0
            TextStyle = tsNone
            LabelStyle = lsDefault
            EllipsesStyle = esNone
            Shift = 1
            Align = alClient
            Alignment = taCenter
            AutoSize = False
            Caption = '0/3'
            Color = clWhite
            Font.Charset = ANSI_CHARSET
            Font.Color = 12615680
            Font.Height = -48
            Font.Name = #48148#47480#44277#44400#52404' Medium'
            Font.Style = [fsBold]
            Layout = tlCenter
            ParentColor = False
            ParentFont = False
            Transparent = False
            ExplicitWidth = 247
          end
          object Label3D3: TLabel3D
            Tag = 1
            Left = 0
            Top = 0
            Width = 310
            Height = 59
            ShowTitle = False
            TitleColor = clGray
            TitleFont.Charset = DEFAULT_CHARSET
            TitleFont.Color = clWindowText
            TitleFont.Height = -11
            TitleFont.Name = 'Tahoma'
            TitleFont.Style = []
            TitleHeightRatio = 0.200000000000000000
            BorderColor = clGray
            BorderPenStyle = psDot
            Border = True
            BorderType = btBorderLine
            BorderLineT = True
            BorderLineR = False
            BorderLineB = True
            BorderLineL = False
            Escapement = 0
            TextStyle = tsNone
            LabelStyle = lsDefault
            EllipsesStyle = esNone
            Shift = 1
            Align = alLeft
            Alignment = taRightJustify
            AutoSize = False
            Caption = 'WALKIN TILT'
            Color = clWhite
            Font.Charset = ANSI_CHARSET
            Font.Color = clGray
            Font.Height = -27
            Font.Name = #48148#47480#44277#44400#52404' Medium'
            Font.Style = [fsBold]
            Layout = tlCenter
            ParentColor = False
            ParentFont = False
            Transparent = False
          end
        end
      end
    end
  end
  object pnlCon: TPanel [8]
    Left = 1695
    Top = 194
    Width = 225
    Height = 735
    Align = alRight
    BevelOuter = bvNone
    Color = 15789806
    ParentBackground = False
    TabOrder = 5
    object lblConName: TLabel3D
      Left = 0
      Top = 26
      Width = 225
      Height = 24
      ShowTitle = False
      TitleColor = clGray
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'Tahoma'
      TitleFont.Style = []
      TitleHeightRatio = 0.200000000000000000
      BorderColor = clGray
      BorderPenStyle = psSolid
      Border = True
      BorderType = btBorderLine
      BorderLineT = True
      BorderLineR = False
      BorderLineB = True
      BorderLineL = False
      Escapement = 0
      TextStyle = tsNone
      LabelStyle = lsDefault
      EllipsesStyle = esNone
      Shift = 1
      Align = alTop
      Alignment = taCenter
      AutoSize = False
      Caption = 'JG1'
      Color = clWhite
      Font.Charset = ANSI_CHARSET
      Font.Color = clNavy
      Font.Height = -13
      Font.Name = #47569#51008' '#44256#46357
      Font.Style = []
      Layout = tlCenter
      ParentColor = False
      ParentFont = False
      Transparent = False
      ExplicitLeft = 16
      ExplicitTop = 9
      ExplicitWidth = 226
    end
    object sbtnCon: TSpeedButton
      Left = 175
      Top = 693
      Width = 46
      Height = 38
      Flat = True
      Glyph.Data = {
        06070000424D0607000000000000360400002800000022000000140000000100
        080000000000D0020000120B0000120B00000001000000000000000000000101
        0100020202000303030004040400050505000606060007070700080808000909
        09000A0A0A000B0B0B000C0C0C000D0D0D000E0E0E000F0F0F00101010001111
        1100121212001313130014141400151515001616160017171700181818001919
        19001A1A1A001B1B1B001C1C1C001D1D1D001E1E1E001F1F1F00202020002121
        2100222222002323230024242400252525002626260027272700282828002929
        29002A2A2A002B2B2B002C2C2C002D2D2D002E2E2E002F2F2F00303030003131
        3100323232003333330034343400353535003636360037373700383838003939
        39003A3A3A003B3B3B003C3C3C003D3D3D003E3E3E003F3F3F00404040004141
        4100424242004343430044444400454545004646460047474700484848004949
        49004A4A4A004B4B4B004C4C4C004D4D4D004E4E4E004F4F4F00505050005151
        5100525252005353530054545400555555005656560057575700585858005959
        59005A5A5A005B5B5B005C5C5C005D5D5D005E5E5E005F5F5F00606060006161
        6100626262006363630064646400656565006666660067676700686868006969
        69006A6A6A006B6B6B006C6C6C006D6D6D006E6E6E006F6F6F00707070007171
        7100727272007373730074747400757575007676760077777700787878007979
        79007A7A7A007B7B7B007C7C7C007D7D7D007E7E7E007F7F7F00808080008181
        8100828282008383830084848400858585008686860087878700888888008989
        89008A8A8A008B8B8B008C8C8C008D8D8D008E8E8E008F8F8F00909090009191
        9100929292009393930094949400959595009696960097979700989898009999
        99009A9A9A009B9B9B009C9C9C009D9D9D009E9E9E009F9F9F00A0A0A000A1A1
        A100A2A2A200A3A3A300A4A4A400A5A5A500A6A6A600A7A7A700A8A8A800A9A9
        A900AAAAAA00ABABAB00ACACAC00ADADAD00AEAEAE00AFAFAF00B0B0B000B1B1
        B100B2B2B200B3B3B300B4B4B400B5B5B500B6B6B600B7B7B700B8B8B800B9B9
        B900BABABA00BBBBBB00BCBCBC00BDBDBD00BEBEBE00BFBFBF00C0C0C000C1C1
        C100C2C2C200C3C3C300C4C4C400C5C5C500C6C6C600C7C7C700C8C8C800C9C9
        C900CACACA00CBCBCB00CCCCCC00CDCDCD00CECECE00CFCFCF00D0D0D000D1D1
        D100D2D2D200D3D3D300D4D4D400D5D5D500D6D6D600D7D7D700D8D8D800D9D9
        D900DADADA00DBDBDB00DCDCDC00DDDDDD00DEDEDE00DFDFDF00E0E0E000E1E1
        E100E2E2E200E3E3E300E4E4E400E5E5E500E6E6E600E7E7E700E8E8E800E9E9
        E900EAEAEA00EBEBEB00ECECEC00EDEDED00EEEEEE00EFEFEF00F0F0F000F1F1
        F100F2F2F200F3F3F300F4F4F400F5F5F500F6F6F600F7F7F700F8F8F800F9F9
        F900FAFAFA00FBFBFB00FCFCFC00FDFDFD00FEFEFE00FFFFFF00FFE7370E1414
        1414141414141414141414141414141414141414141414140F42E6FE0000F156
        0024310302263A3433373433373334363335363236363239220109361E0058FA
        00009B0026CBDB0D0FB6FFF2F0F6F2F1F7F1F2F6EFF3F6EFF5F5EFFF9C0526F3
        B71700E3000075003FEDF0100FB2EEE7ECE3EAEAE3EBEAE3ECE7E4ECE5E6ECF6
        950426FFE23400DB00007B003BEAE81400111817181617171617171618171618
        161618190D0024F9DF3000DE00007D003FEEE0220D0E0B0C0C0B0C0C0B0C0C0B
        0C0B0B0D0B0B0D0A0E0E30FADF3000DE00007B003AE7FFC5BFC6BFC2C5BEC3C4
        BEC4C3BEC6C2BEC5C1C0C6BFC2C5C8FFDE3000DD00007B0041ECFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE13500DD00007D0017595C5C
        5C575D5B595E5A595F5A5A5D585B5D585C5D585D5A585D60521100DE00007B01
        00000000000000000000000000000000000000000000000000000000000000DC
        00007C00228076070761943100458F53001B807C0E03628E2D00389655021586
        761A00DE00007C004AF6FB1213CAFF63008BFFAF0040F5EC1F09BEFF620075FF
        A9082BFFE73B00DD00007B002594990A0A7DAC36004DB06F00269C93110175AF
        3A0049B7660317A2901F00DD00007D0000000000000000000000000000000000
        000000000000000000000000000000DD00007C000B292A0303232F0F0015311E
        000B2B2905012130100014331D01062D280900DD000075003DEAF51012C7FF5A
        007EFFAE003DF5EB1C04B9FF5D0073FFA30526FFE03300DC0000AC001FB2C70D
        0DA1ED50006EE78D002FCDC718059EE64D005EF1880423DCA21100E50000F574
        00111C020117240C0010221200061F1F030118230B000C241400061F0E0072FB
        0000FFEC6F180E1413101012141010111411101012131110111411101012130D
        1C78EFFF0000FFFFEFA48D919290919090929090929090929090928F91929091
        9090918DABF0FFFF0000}
      OnClick = sbtnConClick
    end
    object sgCon: TStringGrid
      Left = 0
      Top = 50
      Width = 225
      Height = 591
      Align = alTop
      BevelInner = bvNone
      BevelOuter = bvNone
      BorderStyle = bsNone
      Color = 15789806
      ColCount = 4
      Ctl3D = False
      DefaultColWidth = 50
      DefaultRowHeight = 17
      DefaultDrawing = False
      DoubleBuffered = True
      DrawingStyle = gdsClassic
      Enabled = False
      FixedColor = clGray
      FixedCols = 0
      RowCount = 35
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing]
      ParentCtl3D = False
      ParentDoubleBuffered = False
      ScrollBars = ssNone
      TabOrder = 0
      OnDrawCell = sgConDrawCell
      ColWidths = (
        38
        87
        50
        50)
    end
    object tcCon: TTabControl
      Left = 0
      Top = 0
      Width = 225
      Height = 26
      Align = alTop
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = #47569#51008' '#44256#46357
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      Tabs.Strings = (
        'MAIN')
      TabIndex = 0
      TabWidth = 60
      OnChange = tcConChange
    end
  end
  inherited pnlMenu: TPanel
    Width = 1920
    ExplicitWidth = 1920
    inherited sbtnModel: TSpeedButton
      Left = 1376
      OnClick = sbtnModelClick
      ExplicitLeft = 1280
      ExplicitTop = 6
    end
    inherited sbtnReference: TSpeedButton
      Left = 1496
      OnClick = sbtnReferenceClick
      ExplicitLeft = 1496
    end
    inherited sbtnRetrieve: TSpeedButton
      Left = 1616
      Visible = False
      OnClick = sbtnRetrieveClick
      ExplicitLeft = 1616
    end
    inherited sbtnExit: TSpeedButton
      Left = 1736
      OnClick = sbtnExitClick
      ExplicitLeft = 1736
    end
  end
  inherited tmrHideMsg: TTimer
    Left = 544
    Top = 184
  end
  object tmrPoll: TTimer
    Enabled = False
    Interval = 10
    OnTimer = tmrPollTimer
    Left = 661
    Top = 183
  end
  object tmrShow: TTimer
    Enabled = False
    Interval = 3000
    OnTimer = tmrShowTimer
    Left = 599
    Top = 187
  end
  object tmrMain: TTimer
    Enabled = False
    Interval = 200
    OnTimer = tmrMainTimer
    Left = 482
    Top = 195
  end
  object tmrDiskChk: TTimer
    Interval = 3600000
    OnTimer = tmrDiskChkTimer
    Left = 739
    Top = 217
  end
end
