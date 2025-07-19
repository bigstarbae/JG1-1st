object frmProdInfo: TfrmProdInfo
  Left = 442
  Top = 176
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #49373#49328#51221#48372
  ClientHeight = 803
  ClientWidth = 1101
  Color = clBtnFace
  Constraints.MaxHeight = 1025
  Constraints.MaxWidth = 1281
  Font.Charset = HANGEUL_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #44404#47548
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poDefault
  WindowState = wsMaximized
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object fgProdInfo: TFaGraphEx
    Left = 0
    Top = 682
    Width = 1101
    Height = 121
    Axis = <
      item
        DrawMin = 1.000000000000000000
        DrawMax = 31.000000000000000000
        Climping = True
        Max = 32.000000000000000000
        Step = 1.000000000000000000
        SubTickCount = 2
        Decimal = 0
        LabelFormat = 'dd'
        Showing = True
        ShowTick = False
        ShowSubTick = False
        ShowLabel = True
        ShowCaption = True
        ShowLabelCenter = False
        ShowFrame = False
        ShowSign = True
        ShowSignMinus = True
        Scale = asDate
        Align = aaBottom
        TickColor = clBlack
        CaptionColor = clBlack
      end
      item
        DrawMax = 1999999999.000000000000000000
        Climping = False
        Max = 20.000000000000000000
        Step = 2.000000000000000000
        SubTickCount = 10
        Decimal = 0
        Caption = '('#49373#49328#47049')'
        Showing = True
        ShowTick = True
        ShowSubTick = False
        ShowLabel = True
        ShowCaption = True
        ShowLabelCenter = False
        ShowFrame = False
        ShowSign = False
        ShowSignMinus = True
        Scale = asNormal
        Align = aaLeft
        TickColor = clBlack
        CaptionColor = clBlack
      end>
    Series = <
      item
        AxisX = 0
        AxisY = 1
        PointWidth = 4
        ShareX = 0
        ShareY = 1
        Styles = gsLine
        Points = gpNone
        LineColor = clRed
        PointColor = clRed
      end>
    MaxDatas = 0
    GridDraw = [ggVert, ggHori]
    GridDrawSide = [gsSide_1, gsSide_2, gsSide_3, gsSide_4]
    GridDrawSub = True
    GridColor = clSilver
    GridStyle = psDot
    BoardColor = clWhite
    GraphType = gtNormal
    OutnerFrame = True
    OutnerFrameColor = clBlack
    Space.Left = -5
    Space.Right = 5
    Space.Top = 15
    Space.Bottom = 20
    Zoom = False
    ZoomSerie = -1
    ViewCrossBar = False
    ViewCrossBarDraw = [ggVert, ggHori]
    UpdateDelayTime = 0.100000000000000000
    UpdateDelayEnabled = False
    Align = alClient
    Font.Charset = HANGEUL_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = #44404#47548
    Font.Style = []
    ParentFont = False
    OnBeforePaint = fgProdInfoBeforePaint
    OnAfterPaint = fgProdInfoAfterPaint
    OnDblClick = fgProdInfoDblClick
  end
  object pnl10: TPanel
    Left = 0
    Top = 80
    Width = 1101
    Height = 67
    Align = alTop
    BevelInner = bvLowered
    BorderWidth = 4
    TabOrder = 0
    object Label1: TLabel
      Left = 561
      Top = 6
      Width = 136
      Height = 55
      Align = alLeft
      Alignment = taCenter
      AutoSize = False
      Caption = #51312#54924#44592#44036
      Color = clTeal
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clWhite
      Font.Height = -27
      Font.Name = #44404#47548
      Font.Style = [fsBold]
      ParentColor = False
      ParentFont = False
      Transparent = False
      Layout = tlCenter
    end
    object Label3: TLabel
      Left = 6
      Top = 6
      Width = 131
      Height = 55
      Align = alLeft
      Alignment = taCenter
      AutoSize = False
      Caption = #47785#54364#49688#47049
      Color = clTeal
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clWhite
      Font.Height = -27
      Font.Name = #44404#47548
      Font.Style = [fsBold]
      ParentColor = False
      ParentFont = False
      Transparent = False
      Layout = tlCenter
    end
    object labGoalCount: TLabel
      Left = 137
      Top = 6
      Width = 168
      Height = 55
      Align = alLeft
      Alignment = taCenter
      AutoSize = False
      Caption = '123456789'
      Color = clMoneyGreen
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clBlack
      Font.Height = -27
      Font.Name = #44404#47548
      Font.Style = [fsBold]
      ParentColor = False
      ParentFont = False
      Layout = tlCenter
    end
    object Panel2: TPanel
      Left = 305
      Top = 6
      Width = 256
      Height = 55
      Align = alLeft
      Ctl3D = True
      ParentCtl3D = False
      TabOrder = 0
      object rdbtnTime: TRadioButton
        Tag = 1
        Left = 7
        Top = 16
        Width = 105
        Height = 21
        Caption = #49884#44036#45824#48324
        Checked = True
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clBlack
        Font.Height = -19
        Font.Name = #44404#47548
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 0
        TabStop = True
        OnClick = rdbtnMonthClick
      end
      object rdbtnDay: TRadioButton
        Tag = 2
        Left = 115
        Top = 16
        Width = 67
        Height = 21
        Caption = #51068#48324
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clBlack
        Font.Height = -19
        Font.Name = #44404#47548
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 1
        OnClick = rdbtnMonthClick
      end
      object rdbtnMonth: TRadioButton
        Tag = 3
        Left = 183
        Top = 16
        Width = 65
        Height = 21
        Caption = #50900#48324
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clBlack
        Font.Height = -19
        Font.Name = #44404#47548
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 2
        OnClick = rdbtnMonthClick
      end
    end
    object Panel6: TPanel
      Left = 697
      Top = 6
      Width = 398
      Height = 55
      Align = alClient
      BorderWidth = 9
      TabOrder = 1
      object pnlDate: TPanel
        Left = 10
        Top = 10
        Width = 178
        Height = 35
        Align = alLeft
        AutoSize = True
        BevelOuter = bvNone
        TabOrder = 0
        Visible = False
        object cbxYear: TComboBox
          Left = 0
          Top = 1
          Width = 95
          Height = 27
          Style = csDropDownList
          Color = clMoneyGreen
          Font.Charset = HANGEUL_CHARSET
          Font.Color = clWindowText
          Font.Height = -19
          Font.Name = #44404#47548
          Font.Style = [fsBold]
          ImeName = 'Microsoft Office IME 2007'
          ItemIndex = 0
          ParentFont = False
          TabOrder = 0
          Text = '2008'#45380
          OnChange = cbxYearChange
          Items.Strings = (
            '2008'#45380
            '2009'#45380)
        end
        object cbxMonth: TComboBox
          Left = 103
          Top = 1
          Width = 75
          Height = 27
          Style = csDropDownList
          Color = clMoneyGreen
          Font.Charset = HANGEUL_CHARSET
          Font.Color = clWindowText
          Font.Height = -19
          Font.Name = #44404#47548
          Font.Style = [fsBold]
          ImeName = 'Microsoft Office IME 2007'
          ItemIndex = 0
          ParentFont = False
          TabOrder = 1
          Text = '1'#50900
          OnChange = cbxYearChange
          Items.Strings = (
            '1'#50900
            '2'#50900
            '3'#50900
            '4'#50900
            '5'#50900
            '6'#50900
            '7'#50900
            '8'#50900
            '9'#50900
            '10'#50900
            '11'#50900
            '12'#50900)
        end
      end
      object pnlTime: TPanel
        Left = 188
        Top = 10
        Width = 299
        Height = 35
        Align = alLeft
        AutoSize = True
        BevelOuter = bvNone
        TabOrder = 1
        object Label2: TLabel
          Left = 138
          Top = 1
          Width = 22
          Height = 27
          Caption = '~'
          Font.Charset = HANGEUL_CHARSET
          Font.Color = clWindowText
          Font.Height = -27
          Font.Name = #44404#47548
          Font.Style = [fsBold]
          ParentFont = False
        end
        object dtpBeginTime: TDateTimePicker
          Left = 0
          Top = 1
          Width = 137
          Height = 27
          Date = 39767.504868043980000000
          Time = 39767.504868043980000000
          Color = clMoneyGreen
          Font.Charset = HANGEUL_CHARSET
          Font.Color = clWindowText
          Font.Height = -19
          Font.Name = #44404#47548
          Font.Style = [fsBold]
          ImeName = 'Microsoft Office IME 2007'
          ParentFont = False
          TabOrder = 0
          OnChange = cbxYearChange
        end
        object dtpEndTime: TDateTimePicker
          Left = 162
          Top = 1
          Width = 137
          Height = 27
          Date = 39767.504868043980000000
          Time = 39767.504868043980000000
          Color = clMoneyGreen
          Font.Charset = HANGEUL_CHARSET
          Font.Color = clWindowText
          Font.Height = -19
          Font.Name = #44404#47548
          Font.Style = [fsBold]
          ImeName = 'Microsoft Office IME 2007'
          ParentFont = False
          TabOrder = 1
          OnChange = cbxYearChange
        end
      end
    end
  end
  object pnlProcWork: TPanel
    Tag = 222
    Left = 0
    Top = 147
    Width = 1101
    Height = 29
    Align = alTop
    BorderStyle = bsSingle
    Caption = '[ '#49884#44036#45824#48324' '#49373#49328' '#47532#49828#53944' ]'
    Color = 10975851
    Ctl3D = False
    Font.Charset = HANGEUL_CHARSET
    Font.Color = clWhite
    Font.Height = -19
    Font.Name = #44404#47548
    Font.Style = [fsBold]
    ParentBackground = False
    ParentCtl3D = False
    ParentFont = False
    TabOrder = 3
  end
  object pnl04: TPanel
    Left = 0
    Top = 176
    Width = 1101
    Height = 477
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object Splitter1: TSplitter
      Left = 638
      Top = 0
      Width = 6
      Height = 436
    end
    object sgrdRight: TStringGrid
      Left = 644
      Top = 0
      Width = 457
      Height = 436
      Align = alClient
      ColCount = 6
      DefaultColWidth = 100
      FixedCols = 0
      RowCount = 13
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing]
      TabOrder = 0
      OnDrawCell = sgrdLeftDrawCell
      ColWidths = (
        50
        260
        77
        79
        72
        70)
    end
    object Panel8: TPanel
      Left = 0
      Top = 436
      Width = 1101
      Height = 41
      Align = alBottom
      TabOrder = 1
      object Label4: TLabel
        Left = 638
        Top = 5
        Width = 200
        Height = 30
        Alignment = taCenter
        AutoSize = False
        Caption = #54633' '#44228
        Color = clTeal
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWhite
        Font.Height = -16
        Font.Name = #44404#47548
        Font.Style = [fsBold]
        ParentColor = False
        ParentFont = False
        Transparent = False
        Layout = tlCenter
      end
      object labTotalCount: TLabel
        Left = 842
        Top = 5
        Width = 428
        Height = 30
        Alignment = taCenter
        AutoSize = False
        Caption = '1234567890'
        Color = clMoneyGreen
        Font.Charset = ANSI_CHARSET
        Font.Color = clBlack
        Font.Height = -21
        Font.Name = #44404#47548
        Font.Style = [fsBold]
        ParentColor = False
        ParentFont = False
        Layout = tlCenter
      end
      object labPeriod: TLabel
        Left = 74
        Top = 11
        Width = 60
        Height = 13
        Caption = 'labPeriod'
      end
      object Label5: TLabel
        Left = 8
        Top = 11
        Width = 60
        Height = 13
        Caption = #51312#54924#44592#44036' :'
      end
    end
    object sgrdLeft: TStringGrid
      Left = 0
      Top = 0
      Width = 638
      Height = 436
      Align = alLeft
      ColCount = 6
      DefaultColWidth = 100
      FixedCols = 0
      RowCount = 17
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing]
      TabOrder = 2
      OnDrawCell = sgrdLeftDrawCell
      ColWidths = (
        57
        208
        90
        97
        89
        80)
    end
  end
  object Panel7: TPanel
    Tag = 222
    Left = 0
    Top = 653
    Width = 1101
    Height = 29
    Align = alTop
    BorderStyle = bsSingle
    Caption = '[ '#49884#44036#45824#48324' '#49373#49328' '#44536#47000#54532' ]'
    Color = 10975851
    Ctl3D = False
    Font.Charset = HANGEUL_CHARSET
    Font.Color = clWhite
    Font.Height = -19
    Font.Name = #44404#47548
    Font.Style = [fsBold]
    ParentBackground = False
    ParentCtl3D = False
    ParentFont = False
    TabOrder = 2
  end
  object pnlTitle: TPanel
    Left = 0
    Top = 0
    Width = 1101
    Height = 46
    Align = alTop
    BevelOuter = bvNone
    Caption = 'Ass'#39'y '#51312#47549#46972#51064
    Color = clWhite
    FullRepaint = False
    Font.Charset = HANGEUL_CHARSET
    Font.Color = clBlack
    Font.Height = -27
    Font.Name = #44404#47548
    Font.Style = [fsBold]
    ParentBackground = False
    ParentFont = False
    TabOrder = 4
    ExplicitTop = -2
  end
  object Panel4: TPanel
    Left = 0
    Top = 46
    Width = 1101
    Height = 34
    Align = alTop
    BevelOuter = bvLowered
    Color = 8598305
    ParentBackground = False
    TabOrder = 5
    object sbtnToExcel: TSpeedButton
      Tag = 8
      Left = 139
      Top = 4
      Width = 123
      Height = 26
      Caption = #50641#49472'(&E)'
      Flat = True
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clWhite
      Font.Height = -16
      Font.Name = #44404#47548
      Font.Style = [fsBold]
      ParentFont = False
      Spacing = 8
      Transparent = False
      OnClick = sbtnToExcelClick
    end
    object sbtnSearch: TSpeedButton
      Tag = 7
      Left = 12
      Top = 4
      Width = 123
      Height = 26
      Caption = #52286#44592'(&S)'
      Flat = True
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clWhite
      Font.Height = -16
      Font.Name = #44404#47548
      Font.Style = [fsBold]
      NumGlyphs = 2
      ParentFont = False
      Spacing = 8
      Transparent = False
      OnClick = sbtnSearchClick
    end
    object sbtnSetTimes: TSpeedButton
      Tag = 8
      Left = 267
      Top = 4
      Width = 123
      Height = 26
      Caption = #49884#44036' '#49444#51221'(&T)'
      Flat = True
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clWhite
      Font.Height = -16
      Font.Name = #44404#47548
      Font.Style = [fsBold]
      ParentFont = False
      Spacing = 8
      Transparent = False
      OnClick = sbtnSetTimesClick
    end
    object Panel5: TPanel
      Left = 969
      Top = 1
      Width = 131
      Height = 32
      Align = alRight
      AutoSize = True
      BevelOuter = bvNone
      BorderWidth = 4
      Color = 10975851
      TabOrder = 0
      object sbtnExit: TSpeedButton
        Tag = 10
        Left = 4
        Top = 3
        Width = 123
        Height = 26
        Caption = #45803#44592'(&C)'
        Flat = True
        Font.Charset = ANSI_CHARSET
        Font.Color = clWhite
        Font.Height = -16
        Font.Name = #44404#47548
        Font.Style = [fsBold]
        NumGlyphs = 2
        ParentFont = False
        Spacing = 8
        Transparent = False
        OnClick = sbtnExitClick
      end
    end
  end
  object Dlgsave: TSaveDialog
    Left = 472
    Top = 184
  end
end
