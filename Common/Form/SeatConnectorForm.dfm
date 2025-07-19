object frmSeatConnector: TfrmSeatConnector
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  ClientHeight = 678
  ClientWidth = 968
  Color = clWhite
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #47569#51008' '#44256#46357
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 15
  object splCon: TSplitter
    Left = 597
    Top = 0
    Width = 7
    Height = 678
    Visible = False
    ExplicitLeft = 558
    ExplicitHeight = 645
  end
  object pnlGrp: TPanel
    Left = 281
    Top = 0
    Width = 316
    Height = 678
    Align = alLeft
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 1
    Visible = False
    object chtPinV: TChart
      Left = 0
      Top = 0
      Width = 316
      Height = 265
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
      Legend.Visible = False
      Title.Font.Color = 8404992
      Title.Font.Height = -13
      Title.Font.Name = #47569#51008' '#44256#46357
      Title.Font.Style = [fsBold]
      Title.Text.Strings = (
        'PIN NO: ')
      BottomAxis.Automatic = False
      BottomAxis.AutomaticMaximum = False
      BottomAxis.AutomaticMinimum = False
      BottomAxis.ExactDateTime = False
      BottomAxis.Grid.Color = 14935011
      BottomAxis.Increment = 1.000000000000000000
      BottomAxis.Maximum = 10.000000000000000000
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
      LeftAxis.Title.Caption = '(V)'
      RightAxis.Title.Angle = 0
      RightAxis.Title.Caption = '(V)'
      RightAxis.Visible = False
      View3D = False
      Zoom.Pen.Color = clSilver
      Align = alTop
      BevelOuter = bvNone
      Color = clWhite
      TabOrder = 0
      PrintMargins = (
        15
        36
        15
        36)
      object Series1: TFastLineSeries
        Marks.Arrow.Visible = True
        Marks.Callout.Brush.Color = clBlack
        Marks.Callout.Arrow.Visible = True
        Marks.Visible = False
        SeriesColor = clBlue
        Title = #51204#50517'(V)'
        LinePen.Color = clBlue
        XValues.Name = 'X'
        XValues.Order = loNone
        YValues.Name = 'Y'
        YValues.Order = loAscending
      end
    end
    object Panel2: TPanel
      Left = 0
      Top = 652
      Width = 316
      Height = 26
      Align = alBottom
      BevelOuter = bvNone
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = #47569#51008' '#44256#46357
      Font.Style = []
      ParentFont = False
      TabOrder = 1
    end
  end
  object pnlSWCon: TPanel
    Left = 604
    Top = 0
    Width = 364
    Height = 678
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 5
    TabOrder = 2
    object lblSW: TLabel
      Left = 5
      Top = 5
      Width = 354
      Height = 25
      Align = alTop
      AutoSize = False
      Caption = 'PWR SW'
      Transparent = True
      Layout = tlCenter
      ExplicitLeft = -32
      ExplicitTop = 0
      ExplicitWidth = 360
    end
    object lblWInBack: TLabel
      Left = 5
      Top = 452
      Width = 354
      Height = 25
      Align = alTop
      AutoSize = False
      Caption = 'WALK IN BACK'
      Transparent = True
      Layout = tlCenter
      ExplicitLeft = -6
      ExplicitTop = 494
      ExplicitWidth = 360
    end
    object Label2: TLabel
      Left = 5
      Top = 250
      Width = 354
      Height = 25
      Align = alTop
      AutoSize = False
      Caption = 'WALK IN CUSH'
      Transparent = True
      Layout = tlCenter
      ExplicitLeft = 6
      ExplicitTop = 244
      ExplicitWidth = 347
    end
    object sgSwCon: TStringGrid
      Left = 5
      Top = 30
      Width = 354
      Height = 220
      Align = alTop
      Color = clWhite
      Ctl3D = False
      DefaultColWidth = 70
      DefaultRowHeight = 21
      DefaultDrawing = False
      DoubleBuffered = True
      DrawingStyle = gdsClassic
      FixedColor = 2236962
      FixedCols = 0
      RowCount = 9
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = #47569#51008' '#44256#46357
      Font.Style = []
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing, goTabs, goRowSelect]
      ParentCtl3D = False
      ParentDoubleBuffered = False
      ParentFont = False
      TabOrder = 0
      OnDrawCell = sgSwConDrawCell
      OnMouseUp = sgSwConMouseUp
      ColWidths = (
        50
        121
        70
        70
        70)
    end
    object sgWInCushCon: TStringGrid
      Left = 5
      Top = 275
      Width = 354
      Height = 177
      Align = alTop
      Color = clWhite
      ColCount = 4
      Ctl3D = False
      DefaultColWidth = 70
      DefaultRowHeight = 21
      DefaultDrawing = False
      DoubleBuffered = True
      DrawingStyle = gdsClassic
      FixedColor = 2236962
      FixedCols = 0
      RowCount = 7
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = #47569#51008' '#44256#46357
      Font.Style = []
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing, goTabs, goRowSelect]
      ParentCtl3D = False
      ParentDoubleBuffered = False
      ParentFont = False
      TabOrder = 1
      ColWidths = (
        50
        122
        70
        72)
    end
    object sgWInBackCon: TStringGrid
      Tag = 1
      Left = 5
      Top = 477
      Width = 354
      Height = 193
      Align = alTop
      Color = clWhite
      ColCount = 4
      Ctl3D = False
      DefaultColWidth = 70
      DefaultRowHeight = 21
      DefaultDrawing = False
      DoubleBuffered = True
      DrawingStyle = gdsClassic
      FixedColor = 2236962
      FixedCols = 0
      RowCount = 7
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = #47569#51008' '#44256#46357
      Font.Style = []
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing, goTabs, goRowSelect]
      ParentCtl3D = False
      ParentDoubleBuffered = False
      ParentFont = False
      TabOrder = 2
      ColWidths = (
        50
        123
        70
        73)
    end
  end
  object pnlMainCon: TPanel
    Left = 0
    Top = 0
    Width = 281
    Height = 678
    Align = alLeft
    BevelOuter = bvNone
    BorderWidth = 5
    Caption = 'pnlMainCon'
    TabOrder = 0
    object sgMainCon: TStringGrid
      Left = 5
      Top = 31
      Width = 271
      Height = 642
      Align = alClient
      Color = clWhite
      ColCount = 3
      Ctl3D = False
      DefaultColWidth = 70
      DefaultRowHeight = 21
      DefaultDrawing = False
      DoubleBuffered = True
      DrawingStyle = gdsClassic
      FixedColor = 2236962
      FixedCols = 0
      RowCount = 29
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = #47569#51008' '#44256#46357
      Font.Style = []
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing, goTabs, goRowSelect]
      ParentCtl3D = False
      ParentDoubleBuffered = False
      ParentFont = False
      TabOrder = 1
      OnClick = sgMainConClick
      OnDrawCell = sgMainConDrawCell
      ColWidths = (
        50
        145
        70)
    end
    object pnlMainConTitle: TPanel
      Left = 5
      Top = 5
      Width = 271
      Height = 26
      Align = alTop
      Alignment = taLeftJustify
      BevelOuter = bvNone
      Caption = '2ND EXTN'
      TabOrder = 0
      object btnGrp: TSpeedButton
        Left = 209
        Top = 0
        Width = 62
        Height = 26
        Align = alRight
        Caption = 'GRAPH '#9654
        Flat = True
        Font.Charset = ANSI_CHARSET
        Font.Color = 4227327
        Font.Height = -11
        Font.Name = #47569#51008' '#44256#46357
        Font.Style = []
        ParentFont = False
        OnClick = btnGrpClick
        ExplicitLeft = 192
      end
    end
  end
  object tmrPoll: TTimer
    Interval = 100
    OnTimer = tmrPollTimer
    Left = 352
    Top = 313
  end
end
