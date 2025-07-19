object frmAD: TfrmAD
  Left = 0
  Top = 0
  Caption = 'AD'
  ClientHeight = 518
  ClientWidth = 909
  Color = clWindow
  Ctl3D = False
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 513
    Top = 0
    Height = 518
    ExplicitLeft = 640
    ExplicitTop = 192
    ExplicitHeight = 100
  end
  object sgAD: TStringGrid
    Left = 0
    Top = 0
    Width = 513
    Height = 518
    Align = alLeft
    DefaultColWidth = 80
    DefaultDrawing = False
    DoubleBuffered = True
    FixedColor = 4800317
    FixedCols = 0
    ParentDoubleBuffered = False
    TabOrder = 0
    OnClick = sgADClick
    OnDrawCell = sgADDrawCell
    OnKeyDown = sgADKeyDown
    OnSelectCell = sgADSelectCell
    OnSetEditText = sgADSetEditText
    ColWidths = (
      63
      187
      80
      80
      80)
  end
  object pnlChart: TPanel
    Left = 516
    Top = 0
    Width = 393
    Height = 518
    Align = alClient
    TabOrder = 1
    DesignSize = (
      393
      518)
    object lblADName: TLabel
      Left = 1
      Top = 33
      Width = 391
      Height = 36
      Align = alTop
      Alignment = taCenter
      AutoSize = False
      Caption = 'CH0:'
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
      ExplicitTop = 1
    end
    object chtAD: TChart
      Left = 1
      Top = 69
      Width = 391
      Height = 244
      BackWall.Color = 5395026
      BackWall.Transparent = False
      Border.EndStyle = esSquare
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
      MarginTop = 3
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
      DepthAxis.Maximum = 0.500000000000000400
      DepthAxis.Minimum = -0.500000000000000400
      DepthTopAxis.Automatic = False
      DepthTopAxis.AutomaticMaximum = False
      DepthTopAxis.AutomaticMinimum = False
      DepthTopAxis.Maximum = 0.500000000000000400
      DepthTopAxis.Minimum = -0.500000000000000400
      LeftAxis.Automatic = False
      LeftAxis.AutomaticMaximum = False
      LeftAxis.AutomaticMinimum = False
      LeftAxis.Grid.Color = 8224125
      LeftAxis.Maximum = 10.000000000000000000
      LeftAxis.Minimum = -10.000000000000000000
      LeftAxis.Title.Angle = 0
      LeftAxis.Title.Caption = '(A)'
      LeftAxis.Title.Visible = False
      RightAxis.Automatic = False
      RightAxis.AutomaticMaximum = False
      RightAxis.AutomaticMinimum = False
      RightAxis.Grid.Visible = False
      RightAxis.Maximum = 315.750000000000000000
      RightAxis.Minimum = -421.750000000000000000
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
        36
        15
        36)
      object chkAutoScale: TCheckBox
        Left = 29
        Top = 0
        Width = 97
        Height = 17
        Caption = 'AutoScale'
        Checked = True
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        State = cbChecked
        TabOrder = 0
        OnClick = chkAutoScaleClick
      end
      object FastLineSeries6: TFastLineSeries
        Marks.Arrow.Visible = True
        Marks.Callout.Brush.Color = clBlack
        Marks.Callout.Arrow.Visible = True
        Marks.Visible = False
        SeriesColor = clYellow
        Title = #51204#47448
        LinePen.Color = clYellow
        XValues.Name = 'X'
        XValues.Order = loNone
        YValues.Name = 'Y'
        YValues.Order = loAscending
      end
    end
    object tbcStations: TTabControl
      Left = 1
      Top = 1
      Width = 391
      Height = 32
      Align = alTop
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      Style = tsFlatButtons
      TabOrder = 0
      OnChange = tbcStationsChange
    end
    object udMin: TUpDown
      Left = 3
      Top = 313
      Width = 23
      Height = 25
      TabOrder = 3
      OnChangingEx = udMinChangingEx
    end
    object udMax: TUpDown
      Left = 3
      Top = 70
      Width = 23
      Height = 25
      TabOrder = 2
      OnChangingEx = udMaxChangingEx
    end
    object Panel2: TPanel
      Left = 1
      Top = 458
      Width = 391
      Height = 59
      Align = alBottom
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 5
      DesignSize = (
        391
        59)
      object lblValue: TLabel3D
        Left = 286
        Top = 0
        Width = 105
        Height = 59
        ShowTitle = True
        TitleColor = 4473924
        TitleFont.Charset = ANSI_CHARSET
        TitleFont.Color = clWhite
        TitleFont.Height = -13
        TitleFont.Name = #47569#51008' '#44256#46357
        TitleFont.Style = []
        Title = 'VALUE'
        TitleHeightRatio = 0.350000000000000000
        BorderColor = clBlack
        BorderPenStyle = psSolid
        Border = True
        BorderType = btBorderLine
        BorderLineT = True
        BorderLineR = True
        BorderLineB = True
        BorderLineL = False
        Escapement = 0
        TextStyle = tsNone
        LabelStyle = lsDefault
        EllipsesStyle = esNone
        Shift = 1
        Align = alRight
        Alignment = taCenter
        AutoSize = False
        Caption = '12.34'
        Color = 2105376
        Font.Charset = ANSI_CHARSET
        Font.Color = clAqua
        Font.Height = -21
        Font.Name = #47569#51008' '#44256#46357
        Font.Style = []
        Layout = tlCenter
        ParentColor = False
        ParentFont = False
        Transparent = False
        ExplicitLeft = 2
        ExplicitTop = -6
      end
      object lblVolt: TLabel3D
        Left = 181
        Top = 0
        Width = 105
        Height = 59
        ShowTitle = True
        TitleColor = 4473924
        TitleFont.Charset = ANSI_CHARSET
        TitleFont.Color = clWhite
        TitleFont.Height = -13
        TitleFont.Name = #47569#51008' '#44256#46357
        TitleFont.Style = []
        Title = 'VOLT'
        TitleHeightRatio = 0.350000000000000000
        BorderColor = clBlack
        BorderPenStyle = psSolid
        Border = True
        BorderType = btBorderLine
        BorderLineT = True
        BorderLineR = True
        BorderLineB = True
        BorderLineL = True
        Escapement = 0
        TextStyle = tsNone
        LabelStyle = lsDefault
        EllipsesStyle = esNone
        Shift = 1
        Align = alRight
        Alignment = taCenter
        AutoSize = False
        Caption = '12.34'
        Color = 2105376
        Font.Charset = ANSI_CHARSET
        Font.Color = clYellow
        Font.Height = -21
        Font.Name = #47569#51008' '#44256#46357
        Font.Style = []
        Layout = tlCenter
        ParentColor = False
        ParentFont = False
        Transparent = False
        ExplicitLeft = 116
        ExplicitTop = -8
      end
      object sbtnZero: TSpeedButton
        Left = 144
        Top = 0
        Width = 31
        Height = 30
        Anchors = [akRight, akBottom]
        Caption = #216
        Flat = True
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clRed
        Font.Height = -19
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        OnClick = sbtnZeroClick
      end
      object sbtnResetZero: TSpeedButton
        Left = 144
        Top = 31
        Width = 31
        Height = 30
        Anchors = [akRight, akBottom]
        Caption = #8634
        Flat = True
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGreen
        Font.Height = -27
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        OnClick = sbtnResetZeroClick
      end
      object btnSave: TButton
        Left = 5
        Top = 21
        Width = 105
        Height = 34
        Caption = 'SAVE'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #47569#51008' '#44256#46357
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        Visible = False
        OnClick = btnSaveClick
      end
    end
    object rgReadType: TRadioGroup
      Left = 184
      Top = 400
      Width = 201
      Height = 40
      Anchors = [akRight, akBottom]
      Caption = 'Read Type'
      Columns = 2
      ItemIndex = 1
      Items.Strings = (
        'VOLT'
        'VALUE')
      TabOrder = 4
    end
  end
  object tmrPoll: TTimer
    Enabled = False
    Interval = 10
    Left = 440
    Top = 384
  end
end
