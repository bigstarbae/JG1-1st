object frmPinIO: TfrmPinIO
  Left = 0
  Top = 0
  ClientHeight = 470
  ClientWidth = 1039
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object sgPinIO: TStringGrid
    Left = 0
    Top = 0
    Width = 442
    Height = 470
    Align = alLeft
    BorderStyle = bsNone
    Color = clWhite
    ColCount = 6
    Ctl3D = False
    DefaultColWidth = 70
    DefaultRowHeight = 21
    DefaultDrawing = False
    DoubleBuffered = True
    DrawingStyle = gdsClassic
    FixedColor = 2236962
    FixedCols = 0
    RowCount = 21
    Font.Charset = HANGEUL_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #47569#51008' '#44256#46357
    Font.Style = []
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing, goTabs, goRowSelect]
    ParentCtl3D = False
    ParentDoubleBuffered = False
    ParentFont = False
    TabOrder = 0
    OnClick = sgPinIOClick
    OnDrawCell = sgPinIODrawCell
    OnMouseUp = sgPinIOMouseUp
    ColWidths = (
      50
      70
      70
      70
      70
      101)
  end
  object sgAIEx: TStringGrid
    Left = 442
    Top = 0
    Width = 193
    Height = 470
    Align = alLeft
    BorderStyle = bsNone
    Color = clWhite
    ColCount = 2
    Ctl3D = False
    DefaultColWidth = 70
    DefaultRowHeight = 21
    DefaultDrawing = False
    DoubleBuffered = True
    DrawingStyle = gdsClassic
    FixedColor = 2236962
    FixedCols = 0
    RowCount = 21
    Font.Charset = HANGEUL_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #47569#51008' '#44256#46357
    Font.Style = []
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing, goTabs, goRowSelect]
    ParentCtl3D = False
    ParentDoubleBuffered = False
    ParentFont = False
    TabOrder = 1
    Visible = False
    OnClick = sgAIExClick
    OnDrawCell = sgAIExDrawCell
    ColWidths = (
      117
      70)
  end
  object Panel1: TPanel
    Left = 635
    Top = 0
    Width = 404
    Height = 470
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 2
    object chtPinCV: TChart
      Left = 0
      Top = 0
      Width = 404
      Height = 444
      BackWall.Color = clWhite
      BackWall.Transparent = False
      Legend.Alignment = laBottom
      Legend.CheckBoxes = True
      Legend.DividingLines.Style = psDash
      Legend.Font.Name = #47569#51008' '#44256#46357
      Legend.FontSeriesColor = True
      Legend.LegendStyle = lsSeries
      Legend.Shadow.HorizSize = 2
      Legend.Shadow.VertSize = 2
      Legend.TopPos = 0
      Legend.VertMargin = 1
      Title.Font.Color = 8404992
      Title.Font.Height = -13
      Title.Font.Name = #47569#51008' '#44256#46357
      Title.Font.Style = [fsBold]
      Title.Text.Strings = (
        'PIN NO: ')
      BottomAxis.Grid.Color = 14935011
      DepthAxis.Automatic = False
      DepthAxis.AutomaticMaximum = False
      DepthAxis.AutomaticMinimum = False
      DepthAxis.Maximum = 1.160000000000001000
      DepthAxis.Minimum = 0.160000000000000100
      DepthTopAxis.Automatic = False
      DepthTopAxis.AutomaticMaximum = False
      DepthTopAxis.AutomaticMinimum = False
      DepthTopAxis.Maximum = 1.160000000000001000
      DepthTopAxis.Minimum = 0.160000000000000100
      LeftAxis.Grid.Color = 14540253
      LeftAxis.Title.Angle = 0
      LeftAxis.Title.Caption = '(A)'
      RightAxis.Title.Angle = 0
      RightAxis.Title.Caption = '(V)'
      View3D = False
      Zoom.Pen.Color = clSilver
      Align = alClient
      BevelOuter = bvLowered
      Color = clWhite
      TabOrder = 0
      PrintMargins = (
        15
        36
        15
        36)
      object FastLineSeries6: TFastLineSeries
        Marks.Arrow.Visible = True
        Marks.Callout.Brush.Color = clBlack
        Marks.Callout.Arrow.Visible = True
        Marks.Visible = False
        Title = #51204#47448'(A)'
        LinePen.Color = clRed
        XValues.Name = 'X'
        XValues.Order = loNone
        YValues.Name = 'Y'
        YValues.Order = loAscending
      end
      object Series1: TFastLineSeries
        Marks.Arrow.Visible = True
        Marks.Callout.Brush.Color = clBlack
        Marks.Callout.Arrow.Visible = True
        Marks.Visible = False
        SeriesColor = clBlue
        Title = #51204#50517'(V)'
        VertAxis = aRightAxis
        LinePen.Color = clBlue
        XValues.Name = 'X'
        XValues.Order = loNone
        YValues.Name = 'Y'
        YValues.Order = loAscending
      end
    end
    object Panel2: TPanel
      Left = 0
      Top = 444
      Width = 404
      Height = 26
      Align = alBottom
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = #47569#51008' '#44256#46357
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      object cbxSubFormClose: TCheckBox
        Left = 280
        Top = 1
        Width = 123
        Height = 24
        Align = alRight
        Caption = 'SUB'#52285' '#44057#51060' '#45803#44592
        Checked = True
        State = cbChecked
        TabOrder = 0
      end
      object cbxAutoYScale: TCheckBox
        Left = 184
        Top = 1
        Width = 96
        Height = 24
        Align = alRight
        Caption = #51088#46041' '#49828#52992#51068
        TabOrder = 1
        OnClick = cbxAutoYScaleClick
      end
    end
  end
  object tmrPoll: TTimer
    Enabled = False
    Interval = 100
    OnTimer = tmrPollTimer
    Left = 544
    Top = 408
  end
end
