object AntipinchTestFrme: TAntipinchTestFrme
  Left = 0
  Top = 0
  Width = 1580
  Height = 250
  TabOrder = 0
  OnResize = FrameResize
  object pnlBase: TPanel
    Left = 0
    Top = 0
    Width = 1580
    Height = 250
    Align = alClient
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 0
    object Splitter: TSplitter
      Left = 520
      Top = 20
      Width = 10
      Height = 230
      Color = clWhite
      ParentColor = False
      Visible = False
    end
    object pnlTop: TPanel
      Left = 0
      Top = 0
      Width = 1580
      Height = 20
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 0
      object lblCaption: TLabel
        Left = 0
        Top = 0
        Width = 220
        Height = 18
        Align = alLeft
        Alignment = taCenter
        AutoSize = False
        Caption = 'ANTIPINCH'
        Color = 7824996
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -15
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentColor = False
        ParentFont = False
        Transparent = False
        Layout = tlCenter
        ExplicitLeft = 1
        ExplicitTop = 1
        ExplicitHeight = 39
      end
      object shpTopLine: TShape
        Left = 0
        Top = 18
        Width = 1580
        Height = 2
        Align = alBottom
        Brush.Color = 5789784
        Pen.Color = 6974058
        ExplicitTop = 28
        ExplicitWidth = 788
      end
      object sbtnViewMode: TSpeedButton
        Left = 1544
        Top = 0
        Width = 36
        Height = 18
        Align = alRight
        Caption = #8596
        Flat = True
        Font.Charset = ANSI_CHARSET
        Font.Color = clBlack
        Font.Height = -19
        Font.Name = #47569#51008' '#44256#46357
        Font.Style = [fsBold]
        ParentFont = False
        OnClick = sbtnViewModeClick
        ExplicitLeft = 752
        ExplicitHeight = 23
      end
    end
    object pnlGrp: TPanel
      Left = 0
      Top = 20
      Width = 520
      Height = 230
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 1
      object grpAPCurr: TFaGraphEx
        Left = 0
        Top = 25
        Width = 520
        Height = 105
        Margins.Bottom = 0
        Axis = <
          item
            DrawMin = -32768.000000000000000000
            DrawMax = 32768.000000000000000000
            Climping = False
            Max = 10.000000000000000000
            Step = 1.000000000000000000
            SubTickCount = 10
            Decimal = 0
            Caption = '(sec)'
            Showing = True
            ShowTick = True
            ShowSubTick = False
            ShowLabel = True
            ShowCaption = False
            ShowLabelCenter = False
            ShowFrame = True
            ShowSign = False
            ShowSignMinus = True
            Scale = asNormal
            Align = aaBottom
            TickColor = clBlack
            CaptionColor = clBlack
          end
          item
            DrawMin = -32768.000000000000000000
            DrawMax = 32768.000000000000000000
            Climping = False
            Max = 10.000000000000000000
            Step = 1.000000000000000000
            SubTickCount = 10
            Decimal = 0
            Caption = '(Kg)'
            Showing = True
            ShowTick = True
            ShowSubTick = False
            ShowLabel = True
            ShowCaption = True
            ShowLabelCenter = False
            ShowFrame = True
            ShowSign = False
            ShowSignMinus = True
            Scale = asNormal
            Align = aaLeft
            TickColor = clBlack
            CaptionColor = clBlack
          end
          item
            DrawMax = 10.000000000000000000
            Climping = False
            Max = 10.000000000000000000
            Step = 1.000000000000000000
            SubTickCount = 10
            Decimal = 0
            Caption = '(A)'
            Showing = True
            ShowTick = True
            ShowSubTick = False
            ShowLabel = True
            ShowCaption = True
            ShowLabelCenter = False
            ShowFrame = True
            ShowSign = False
            ShowSignMinus = True
            Scale = asNormal
            Align = aaRight
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
            LineColor = clNavy
            PointColor = clRed
          end
          item
            AxisX = 0
            AxisY = 2
            PointWidth = 4
            ShareX = 2
            ShareY = 3
            Styles = gsLine
            Points = gpNone
            LineColor = clRed
            PointColor = clRed
          end
          item
            AxisX = 0
            AxisY = 1
            PointWidth = 4
            ShareX = 4
            ShareY = 5
            Styles = gsLine
            Points = gpNone
            LineColor = clLime
            PointColor = clRed
          end
          item
            AxisX = 0
            AxisY = 2
            PointWidth = 4
            ShareX = 6
            ShareY = 7
            Styles = gsLine
            Points = gpNone
            LineColor = 33023
            PointColor = clRed
          end>
        MaxDatas = 1000000
        GridDraw = [ggHori]
        GridDrawSide = [gsSide_1, gsSide_2, gsSide_3, gsSide_4]
        GridDrawSub = False
        GridColor = clSilver
        GridStyle = psDot
        BoardColor = clWhite
        GraphType = gtNormal
        OutnerFrame = False
        OutnerFrameColor = clBlack
        Space.Left = -8
        Space.Right = 0
        Space.Top = 8
        Space.Bottom = -8
        Zoom = False
        ZoomSerie = -1
        ViewCrossBar = False
        ViewCrossBarDraw = [ggVert, ggHori]
        UpdateDelayTime = 0.020000000000000000
        UpdateDelayEnabled = False
        Align = alTop
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = #47569#51008' '#44256#46357
        Font.Style = []
        ParentFont = False
        Visible = False
        ExplicitTop = 20
        ExplicitWidth = 526
      end
      object grpAPLoad: TFaGraphEx
        Left = 0
        Top = 130
        Width = 520
        Height = 100
        Margins.Bottom = 0
        Axis = <
          item
            DrawMin = -32768.000000000000000000
            DrawMax = 32768.000000000000000000
            Climping = False
            Max = 10.000000000000000000
            Step = 1.000000000000000000
            SubTickCount = 10
            Decimal = 0
            Caption = '(sec)'
            Showing = True
            ShowTick = True
            ShowSubTick = False
            ShowLabel = True
            ShowCaption = False
            ShowLabelCenter = False
            ShowFrame = True
            ShowSign = False
            ShowSignMinus = True
            Scale = asNormal
            Align = aaBottom
            TickColor = clBlack
            CaptionColor = clBlack
          end
          item
            DrawMin = -32768.000000000000000000
            DrawMax = 32768.000000000000000000
            Climping = False
            Max = 10.000000000000000000
            Step = 1.000000000000000000
            SubTickCount = 10
            Decimal = 0
            Caption = '(Kg)'
            Showing = True
            ShowTick = True
            ShowSubTick = False
            ShowLabel = True
            ShowCaption = True
            ShowLabelCenter = False
            ShowFrame = True
            ShowSign = False
            ShowSignMinus = True
            Scale = asNormal
            Align = aaLeft
            TickColor = clBlack
            CaptionColor = clBlack
          end
          item
            DrawMax = 10.000000000000000000
            Climping = False
            Max = 10.000000000000000000
            Step = 1.000000000000000000
            SubTickCount = 10
            Decimal = 0
            Caption = '(A)'
            Showing = True
            ShowTick = True
            ShowSubTick = False
            ShowLabel = True
            ShowCaption = True
            ShowLabelCenter = False
            ShowFrame = True
            ShowSign = False
            ShowSignMinus = True
            Scale = asNormal
            Align = aaRight
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
            LineColor = clNavy
            PointColor = clRed
          end
          item
            AxisX = 0
            AxisY = 2
            PointWidth = 4
            ShareX = 2
            ShareY = 3
            Styles = gsLine
            Points = gpNone
            LineColor = clRed
            PointColor = clRed
          end
          item
            AxisX = 0
            AxisY = 1
            PointWidth = 4
            ShareX = 4
            ShareY = 5
            Styles = gsLine
            Points = gpNone
            LineColor = clLime
            PointColor = clRed
          end
          item
            AxisX = 0
            AxisY = 2
            PointWidth = 4
            ShareX = 6
            ShareY = 7
            Styles = gsLine
            Points = gpNone
            LineColor = 33023
            PointColor = clRed
          end>
        MaxDatas = 1000000
        GridDraw = [ggHori]
        GridDrawSide = [gsSide_1, gsSide_2, gsSide_3, gsSide_4]
        GridDrawSub = False
        GridColor = clSilver
        GridStyle = psDot
        BoardColor = clWhite
        GraphType = gtNormal
        OutnerFrame = False
        OutnerFrameColor = clBlack
        Space.Left = -8
        Space.Right = 0
        Space.Top = 8
        Space.Bottom = -8
        Zoom = False
        ZoomSerie = -1
        ViewCrossBar = False
        ViewCrossBarDraw = [ggVert, ggHori]
        UpdateDelayTime = 0.020000000000000000
        UpdateDelayEnabled = False
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = #47569#51008' '#44256#46357
        Font.Style = []
        ParentFont = False
        Visible = False
        ExplicitTop = 149
        ExplicitWidth = 526
        ExplicitHeight = 101
      end
      object pnlLegend: TPanel
        Left = 0
        Top = 0
        Width = 520
        Height = 25
        Align = alTop
        BevelOuter = bvNone
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #48148#47480#44277#44400#52404' Medium'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 0
      end
    end
    object pnlData: TPanel
      Left = 530
      Top = 20
      Width = 1050
      Height = 230
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 2
      object sgData: TStringGrid
        Left = 0
        Top = 0
        Width = 1050
        Height = 230
        Align = alClient
        BevelInner = bvNone
        BevelOuter = bvNone
        Color = 16053492
        ColCount = 11
        Ctl3D = False
        DefaultRowHeight = 47
        DefaultDrawing = False
        DrawingStyle = gdsClassic
        Enabled = False
        FixedColor = 16053492
        FixedCols = 0
        RowCount = 3
        FixedRows = 0
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = #47569#51008' '#44256#46357
        Font.Style = []
        ParentCtl3D = False
        ParentFont = False
        ScrollBars = ssNone
        TabOrder = 0
        OnDrawCell = sgDataDrawCell
      end
    end
  end
end
