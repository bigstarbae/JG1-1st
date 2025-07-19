object SeatMtrTestFrme: TSeatMtrTestFrme
  Left = 0
  Top = 0
  Width = 780
  Height = 199
  Color = clWhite
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #47569#51008' '#44256#46357
  Font.Style = []
  ParentBackground = False
  ParentColor = False
  ParentFont = False
  TabOrder = 0
  OnResize = FrameResize
  object pnlBase: TPanel
    Left = 0
    Top = 0
    Width = 780
    Height = 199
    Margins.Left = 0
    Margins.Top = 0
    Margins.Right = 0
    Margins.Bottom = 0
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 4
    Color = clWhite
    ParentBackground = False
    TabOrder = 0
    object Splitter: TSplitter
      Left = 292
      Top = 28
      Width = 5
      Height = 167
      Color = clWhite
      ParentColor = False
      Visible = False
      ExplicitTop = 29
      ExplicitHeight = 169
    end
    object pnlTop: TPanel
      Left = 4
      Top = 4
      Width = 772
      Height = 24
      Align = alTop
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 0
      object shpTopLine: TShape
        Left = 0
        Top = 22
        Width = 772
        Height = 2
        Align = alBottom
        Brush.Color = 5789784
        Pen.Color = 6974058
        ExplicitTop = 28
        ExplicitWidth = 982
      end
      object lblCaption: TLabel
        Left = 0
        Top = 0
        Width = 265
        Height = 22
        Align = alLeft
        Alignment = taCenter
        AutoSize = False
        Caption = '  MOTOR'
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
        ExplicitHeight = 27
      end
      object sbtnViewMode: TSpeedButton
        Left = 736
        Top = 0
        Width = 36
        Height = 22
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
        ExplicitHeight = 23
      end
      object pnlLegend: TPanel
        Left = 265
        Top = 0
        Width = 471
        Height = 22
        Align = alClient
        BevelOuter = bvNone
        Color = clWhite
        ParentBackground = False
        TabOrder = 0
      end
    end
    object pnlData: TPanel
      Left = 297
      Top = 28
      Width = 288
      Height = 167
      Align = alLeft
      BevelOuter = bvNone
      Padding.Top = 5
      Padding.Right = 10
      TabOrder = 2
      OnResize = pnlDataResize
      object sgData: TStringGrid
        Left = 0
        Top = 5
        Width = 278
        Height = 159
        Align = alTop
        BevelInner = bvNone
        BevelOuter = bvNone
        Color = 16053492
        ColCount = 9
        Ctl3D = False
        DefaultRowHeight = 34
        DefaultDrawing = False
        DrawingStyle = gdsClassic
        Enabled = False
        FixedColor = 16053492
        FixedCols = 0
        RowCount = 3
        FixedRows = 0
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = #47569#51008' '#44256#46357
        Font.Style = [fsBold]
        ParentCtl3D = False
        ParentFont = False
        ScrollBars = ssNone
        TabOrder = 0
        OnDrawCell = sgDataDrawCell
      end
    end
    object pnlGrp: TPanel
      Left = 4
      Top = 28
      Width = 288
      Height = 167
      Align = alLeft
      BevelOuter = bvNone
      Padding.Right = 5
      Padding.Bottom = 10
      TabOrder = 1
      object grpData: TFaGraphEx
        Left = 0
        Top = 0
        Width = 283
        Height = 157
        Margins.Left = 0
        Margins.Top = 0
        Margins.Right = 0
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
            Align = aaLeft
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
            Caption = '(dB)'
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
            AxisY = 2
            PointWidth = 4
            ShareX = 0
            ShareY = 1
            Styles = gsLine
            Points = gpNone
            LineColor = 16744576
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
            LineColor = clBlue
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
            LineColor = 7961087
            PointColor = clRed
          end
          item
            AxisX = 0
            AxisY = 1
            PointWidth = 4
            ShareX = 6
            ShareY = 7
            Styles = gsLine
            Points = gpNone
            LineColor = clRed
            PointColor = clRed
          end>
        MaxDatas = 1000000
        GridDraw = [ggHori]
        GridDrawSide = [gsSide_1, gsSide_2, gsSide_3, gsSide_4]
        GridDrawSub = False
        GridColor = 14342874
        GridStyle = psDot
        BoardColor = clWhite
        GraphType = gtNormal
        OutnerFrame = False
        OutnerFrameColor = clBlack
        Space.Left = -15
        Space.Right = -15
        Space.Top = 10
        Space.Bottom = -25
        Zoom = False
        ZoomSerie = -1
        ViewCrossBar = False
        ViewCrossBarDraw = [ggVert, ggHori]
        UpdateDelayTime = 0.020000000000000000
        UpdateDelayEnabled = False
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -12
        Font.Name = #47569#51008' '#44256#46357
        Font.Style = []
        ParentFont = False
        ExplicitLeft = 2
        ExplicitTop = 24
        ExplicitHeight = 190
      end
    end
  end
end
