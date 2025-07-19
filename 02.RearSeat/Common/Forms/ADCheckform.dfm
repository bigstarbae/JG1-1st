object frmADChecker: TfrmADChecker
  Left = 229
  Top = 106
  BorderStyle = bsSingle
  Caption = 'A/D and Counter'
  ClientHeight = 731
  ClientWidth = 981
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
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 693
    Height = 731
    Align = alClient
    BorderWidth = 5
    Color = 15593457
    ParentBackground = False
    TabOrder = 0
    object fagrpChecker: TFaGraphEx
      Left = 6
      Top = 6
      Width = 681
      Height = 281
      Axis = <
        item
          DrawMin = -32768.000000000000000000
          DrawMax = 32768.000000000000000000
          Climping = False
          Max = 250.000000000000000000
          Step = 50.000000000000000000
          SubTickCount = 10
          Decimal = 0
          Caption = '(sec)'
          Showing = True
          ShowTick = True
          ShowSubTick = True
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
          Max = 20.000000000000000000
          Step = 5.000000000000000000
          SubTickCount = 10
          Decimal = 0
          Caption = '(N.m)'
          Showing = True
          ShowTick = True
          ShowSubTick = True
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
        end
        item
          AxisX = 0
          AxisY = 1
          PointWidth = 4
          ShareX = 2
          ShareY = 3
          Styles = gsLine
          Points = gpNone
          LineColor = clBlue
          PointColor = clRed
          Visible = False
        end>
      MaxDatas = 32768
      GridDraw = [ggVert, ggHori]
      GridDrawSide = [gsSide_1, gsSide_2, gsSide_3, gsSide_4]
      GridDrawSub = False
      GridColor = clSilver
      GridStyle = psDot
      BoardColor = clWhite
      GraphType = gtStepScroll
      OutnerFrame = True
      OutnerFrameColor = clBlack
      Space.Left = 8
      Space.Right = 16
      Space.Top = 8
      Space.Bottom = -8
      Zoom = False
      ZoomSerie = -1
      ViewCrossBar = False
      ViewCrossBarDraw = [ggVert, ggHori]
      UpdateDelayTime = 0.100000000000000000
      UpdateDelayEnabled = False
      Align = alTop
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = #44404#47548
      Font.Style = []
      ParentFont = False
      ExplicitTop = 5
    end
    object Panel3: TPanel
      Left = 6
      Top = 287
      Width = 681
      Height = 438
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 0
      object Splitter1: TSplitter
        Left = 0
        Top = 0
        Width = 681
        Height = 5
        Cursor = crVSplit
        Align = alTop
        ExplicitTop = 329
      end
      object sgrdCount: TStringGrid
        Left = 0
        Top = 334
        Width = 681
        Height = 104
        Align = alBottom
        ColCount = 3
        DefaultColWidth = 150
        RowCount = 17
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing]
        TabOrder = 1
        Visible = False
        OnDrawCell = sgrdCountDrawCell
        RowHeights = (
          24
          24
          24
          24
          24
          24
          24
          24
          24
          24
          24
          24
          24
          24
          24
          24
          24)
      end
      object sgrdDaq: TStringGrid
        Left = 0
        Top = 5
        Width = 681
        Height = 329
        Align = alClient
        ColCount = 4
        DefaultColWidth = 120
        DefaultDrawing = False
        DoubleBuffered = True
        RowCount = 17
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing]
        ParentDoubleBuffered = False
        TabOrder = 0
        OnClick = sgrdDaqClick
        OnDrawCell = sgrdCountDrawCell
        ColWidths = (
          193
          120
          120
          120)
      end
    end
  end
  object Panel1: TPanel
    Left = 693
    Top = 0
    Width = 288
    Height = 731
    Align = alRight
    BorderWidth = 8
    Color = clWhite
    ParentBackground = False
    TabOrder = 1
    object Panel4: TPanel
      Left = 9
      Top = 9
      Width = 270
      Height = 713
      Align = alClient
      BevelOuter = bvNone
      BorderStyle = bsSingle
      Color = 15593457
      Ctl3D = False
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = #47569#51008' '#44256#46357
      Font.Style = []
      ParentBackground = False
      ParentCtl3D = False
      ParentFont = False
      TabOrder = 0
      object Shape10: TShape
        Left = 7
        Top = 19
        Width = 245
        Height = 5
        Brush.Color = clBlack
      end
      object Shape1: TShape
        Left = 7
        Top = 533
        Width = 245
        Height = 5
        Brush.Color = clBlack
      end
      object Shape2: TShape
        Left = 7
        Top = 109
        Width = 245
        Height = 1
        Brush.Color = clBlack
      end
      object Label9: TLabel
        Left = 17
        Top = 82
        Width = 55
        Height = 17
        Caption = 'AI Graph'
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #47569#51008' '#44256#46357
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Label1: TLabel
        Left = 52
        Top = 127
        Width = 17
        Height = 17
        Alignment = taRightJustify
        Caption = 'CH'
      end
      object Label3: TLabel
        Left = 31
        Top = 175
        Width = 38
        Height = 17
        Alignment = taRightJustify
        Caption = 'X Max'
      end
      object Label4: TLabel
        Left = 33
        Top = 202
        Width = 36
        Height = 17
        Alignment = taRightJustify
        Caption = 'X Min'
      end
      object Label31: TLabel
        Left = 30
        Top = 226
        Width = 39
        Height = 17
        Alignment = taRightJustify
        Caption = 'X Step'
      end
      object Label32: TLabel
        Left = 32
        Top = 256
        Width = 37
        Height = 17
        Alignment = taRightJustify
        Caption = 'Y Max'
      end
      object Label33: TLabel
        Left = 34
        Top = 281
        Width = 35
        Height = 17
        Alignment = taRightJustify
        Caption = 'Y Min'
      end
      object Label34: TLabel
        Left = 31
        Top = 305
        Width = 38
        Height = 17
        Alignment = taRightJustify
        Caption = 'Y Step'
      end
      object sbtnStart: TSpeedButton
        Left = 30
        Top = 379
        Width = 97
        Height = 30
        Caption = 'START'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #47569#51008#44256#46357
        Font.Style = [fsBold]
        ParentFont = False
        OnClick = sbtnStartClick
      end
      object sbtnStop: TSpeedButton
        Left = 139
        Top = 379
        Width = 97
        Height = 30
        Caption = 'STOP'
        Enabled = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #47569#51008#44256#46357
        Font.Style = [fsBold]
        ParentFont = False
        OnClick = sbtnStopClick
      end
      object Label8: TLabel
        Left = 33
        Top = 38
        Width = 26
        Height = 17
        Caption = #44277#51221
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #47569#51008' '#44256#46357
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Shape5: TShape
        Left = 7
        Top = 66
        Width = 245
        Height = 5
        Brush.Color = clBlack
      end
      object sbtnSetZero: TSpeedButton
        Left = 30
        Top = 465
        Width = 97
        Height = 30
        Caption = 'SET ZERO'
        Font.Charset = HANGEUL_CHARSET
        Font.Color = 33023
        Font.Height = -13
        Font.Name = #47569#51008' '#44256#46357
        Font.Style = [fsBold]
        ParentFont = False
        OnClick = sbtnSetZeroClick
      end
      object sbtnResetZero: TSpeedButton
        Left = 139
        Top = 465
        Width = 97
        Height = 30
        Caption = 'RESET ZERO'
        Enabled = False
        Font.Charset = HANGEUL_CHARSET
        Font.Color = 33023
        Font.Height = -13
        Font.Name = #47569#51008' '#44256#46357
        Font.Style = [fsBold]
        ParentFont = False
        OnClick = sbtnResetZeroClick
      end
      object Shape3: TShape
        Left = 7
        Top = 428
        Width = 245
        Height = 1
        Brush.Color = clBlack
      end
      object Label5: TLabel
        Left = 60
        Top = 595
        Width = 17
        Height = 17
        Alignment = taRightJustify
        Caption = 'CH'
      end
      object Label6: TLabel
        Left = 20
        Top = 548
        Width = 49
        Height = 17
        Caption = 'Counter'
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #47569#51008' '#44256#46357
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Shape6: TShape
        Left = 7
        Top = 580
        Width = 245
        Height = 1
        Brush.Color = clBlack
      end
      object sbtnSetZeroCT: TSpeedButton
        Left = 30
        Top = 641
        Width = 97
        Height = 30
        Caption = 'SET ZERO'
        Font.Charset = HANGEUL_CHARSET
        Font.Color = 33023
        Font.Height = -13
        Font.Name = #47569#51008' '#44256#46357
        Font.Style = [fsBold]
        ParentFont = False
        OnClick = sbtnSetZeroCTClick
      end
      object sbtnResetZeroCT: TSpeedButton
        Left = 139
        Top = 641
        Width = 97
        Height = 30
        Caption = 'RESET ZERO'
        Enabled = False
        Font.Charset = HANGEUL_CHARSET
        Font.Color = 33023
        Font.Height = -13
        Font.Name = #47569#51008' '#44256#46357
        Font.Style = [fsBold]
        ParentFont = False
        OnClick = sbtnResetZeroCTClick
      end
      object cbxChs: TComboBox
        Left = 85
        Top = 125
        Width = 151
        Height = 23
        Style = csDropDownList
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = #47569#51008' '#44256#46357
        Font.Style = []
        ImeName = 'Microsoft Office IME 2007'
        ParentFont = False
        TabOrder = 1
        OnChange = cbxChsChange
      end
      object edtadxmax: TEdit
        Left = 85
        Top = 172
        Width = 151
        Height = 23
        Color = 15269887
        ImeName = 'Microsoft Korean IME 2002'
        TabOrder = 2
      end
      object edtADxmin: TEdit
        Left = 85
        Top = 196
        Width = 151
        Height = 23
        Color = 15269887
        ImeName = 'Microsoft Korean IME 2002'
        TabOrder = 3
      end
      object edtADxstep: TEdit
        Left = 85
        Top = 220
        Width = 151
        Height = 23
        Color = 15269887
        ImeName = 'Microsoft Korean IME 2002'
        TabOrder = 4
      end
      object edtadymax: TEdit
        Left = 85
        Top = 253
        Width = 151
        Height = 23
        Color = 16771304
        ImeName = 'Microsoft Korean IME 2002'
        TabOrder = 5
      end
      object edtadymin: TEdit
        Left = 85
        Top = 277
        Width = 151
        Height = 23
        Color = 16771304
        ImeName = 'Microsoft Korean IME 2002'
        TabOrder = 6
      end
      object edtadystep: TEdit
        Left = 85
        Top = 301
        Width = 151
        Height = 23
        Color = 16771304
        ImeName = 'Microsoft Korean IME 2002'
        TabOrder = 7
      end
      object cbxStation: TComboBox
        Left = 85
        Top = 35
        Width = 151
        Height = 23
        Style = csDropDownList
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = #47569#51008' '#44256#46357
        Font.Style = []
        ImeName = 'Microsoft Office IME 2007'
        ParentFont = False
        TabOrder = 0
        OnChange = cbxStationChange
      end
      object cbxCTChs: TComboBox
        Left = 93
        Top = 592
        Width = 151
        Height = 23
        Style = csDropDownList
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = #47569#51008' '#44256#46357
        Font.Style = []
        ImeName = 'Microsoft Office IME 2007'
        ItemIndex = 0
        ParentFont = False
        TabOrder = 8
        Text = 'CH0'
        Items.Strings = (
          'CH0'
          'CH1'
          'CH2')
      end
      object pnlCTMask: TPanel
        Left = 3
        Top = 544
        Width = 262
        Height = 145
        BevelOuter = bvNone
        Color = 15593457
        ParentBackground = False
        TabOrder = 9
      end
    end
  end
  object tmrPoll: TTimer
    Enabled = False
    Interval = 10
    OnTimer = tmrPollTimer
    Left = 624
    Top = 328
  end
end
