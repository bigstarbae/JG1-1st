object frmgrpConfig: TfrmgrpConfig
  Left = 193
  Top = 108
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #44536#47000#54532#49444#51221
  ClientHeight = 587
  ClientWidth = 681
  Color = clBtnFace
  Font.Charset = HANGEUL_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #44404#47548
  Font.Style = []
  OldCreateOrder = False
  Position = poDefault
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
    Width = 681
    Height = 587
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 2
    TabOrder = 0
    object Bevel1: TBevel
      Left = 3
      Top = 535
      Width = 678
      Height = 7
      Shape = bsTopLine
    end
    object bbtnApply: TBitBtn
      Left = 367
      Top = 544
      Width = 101
      Height = 30
      Caption = 'Apply(&A)'
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = #44404#47548
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      OnClick = bbtnApplyClick
    end
    object bbtnOK: TBitBtn
      Left = 475
      Top = 544
      Width = 101
      Height = 30
      Caption = 'OK(&O)'
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = #44404#47548
      Font.Style = [fsBold]
      Kind = bkOK
      ParentFont = False
      TabOrder = 1
      OnClick = bbtnOKClick
    end
    object BitBtn4: TBitBtn
      Left = 575
      Top = 544
      Width = 101
      Height = 30
      Caption = 'Cancel(&C)'
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = #44404#47548
      Font.Style = [fsBold]
      Kind = bkCancel
      ParentFont = False
      TabOrder = 2
    end
    object Panel1: TPanel
      Left = 7
      Top = 8
      Width = 415
      Height = 511
      BevelOuter = bvNone
      BorderStyle = bsSingle
      Color = 15593457
      Ctl3D = False
      ParentBackground = False
      ParentCtl3D = False
      TabOrder = 3
      object faGrpRefer: TFaGraphEx
        Left = 0
        Top = 0
        Width = 413
        Height = 509
        Axis = <
          item
            DrawMin = -8192.000000000000000000
            DrawMax = 8192.000000000000000000
            Climping = False
            Max = 10.000000000000000000
            Step = 1.000000000000000000
            SubTickCount = 2
            Decimal = 0
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
            DrawMin = -8192.000000000000000000
            DrawMax = 1999999999.000000000000000000
            Climping = False
            Max = 10.000000000000000000
            Step = 1.000000000000000000
            SubTickCount = 2
            Decimal = 0
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
          end>
        MaxDatas = 0
        GridDraw = [ggVert, ggHori]
        GridDrawSide = [gsSide_1, gsSide_2, gsSide_3, gsSide_4]
        GridDrawSub = False
        GridColor = clSilver
        GridStyle = psDot
        BoardColor = clWhite
        GraphType = gtNormal
        OutnerFrame = True
        OutnerFrameColor = clBlack
        Space.Left = -8
        Space.Right = 8
        Space.Top = 8
        Space.Bottom = -8
        Zoom = False
        ZoomSerie = -1
        ViewCrossBar = False
        ViewCrossBarDraw = [ggVert, ggHori]
        UpdateDelayTime = 0.100000000000000000
        UpdateDelayEnabled = False
        Align = alClient
        OnBeforePaint = faGrpReferBeforePaint
        OnAfterPaint = faGrpReferAfterPaint
      end
    end
    object Panel4: TPanel
      Left = 428
      Top = 8
      Width = 246
      Height = 511
      BevelOuter = bvNone
      BorderStyle = bsSingle
      Color = 15593457
      Ctl3D = False
      ParentBackground = False
      ParentCtl3D = False
      TabOrder = 4
      object Shape4: TShape
        Left = 7
        Top = 489
        Width = 230
        Height = 5
        Brush.Color = clBlack
      end
      object Shape5: TShape
        Left = 7
        Top = 10
        Width = 230
        Height = 5
        Brush.Color = clBlack
      end
      object Shape6: TShape
        Left = 7
        Top = 54
        Width = 230
        Height = 5
        Brush.Color = clBlack
      end
      object Shape1: TShape
        Left = 7
        Top = 92
        Width = 230
        Height = 1
        Brush.Color = clBlack
      end
      object Label12: TLabel
        Left = 17
        Top = 69
        Width = 44
        Height = 13
        Caption = 'X axis'
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Label1: TLabel
        Tag = 222
        Left = 23
        Top = 110
        Width = 34
        Height = 13
        Alignment = taRightJustify
        Caption = 'Max :'
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = []
        ParentFont = False
      end
      object Label2: TLabel
        Tag = 222
        Left = 27
        Top = 139
        Width = 30
        Height = 13
        Alignment = taRightJustify
        Caption = 'Min :'
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = []
        ParentFont = False
      end
      object Label3: TLabel
        Tag = 222
        Left = 21
        Top = 167
        Width = 36
        Height = 13
        Alignment = taRightJustify
        Caption = 'Step :'
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = []
        ParentFont = False
      end
      object Shape3: TShape
        Left = 7
        Top = 196
        Width = 230
        Height = 5
        Brush.Color = clBlack
      end
      object Shape7: TShape
        Left = 7
        Top = 234
        Width = 230
        Height = 1
        Brush.Color = clBlack
      end
      object Label13: TLabel
        Left = 17
        Top = 213
        Width = 44
        Height = 13
        Caption = 'Y axis'
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Label4: TLabel
        Tag = 222
        Left = 17
        Top = 249
        Width = 34
        Height = 13
        Caption = 'Max :'
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = []
        ParentFont = False
      end
      object Label5: TLabel
        Tag = 222
        Left = 21
        Top = 278
        Width = 30
        Height = 13
        Caption = 'Min :'
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = []
        ParentFont = False
      end
      object Label6: TLabel
        Tag = 222
        Left = 14
        Top = 306
        Width = 36
        Height = 13
        Caption = 'Step :'
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = []
        ParentFont = False
      end
      object Shape8: TShape
        Left = 6
        Top = 337
        Width = 230
        Height = 5
        Brush.Color = clBlack
      end
      object Shape9: TShape
        Left = 6
        Top = 376
        Width = 230
        Height = 1
        Brush.Color = clBlack
      end
      object Label14: TLabel
        Left = 17
        Top = 352
        Width = 38
        Height = 13
        Caption = 'Color'
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Label7: TLabel
        Tag = 222
        Left = 49
        Top = 392
        Width = 36
        Height = 13
        Alignment = taRightJustify
        Caption = 'Data :'
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = []
        ParentFont = False
      end
      object Label8: TLabel
        Tag = 222
        Left = 44
        Top = 421
        Width = 41
        Height = 13
        Alignment = taRightJustify
        Caption = 'Spec :'
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = []
        ParentFont = False
      end
      object Label9: TLabel
        Tag = 222
        Left = 44
        Top = 451
        Width = 41
        Height = 13
        Alignment = taRightJustify
        Caption = 'Spec :'
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = []
        ParentFont = False
      end
      object cbxgrpList: TComboBox
        Left = 21
        Top = 24
        Width = 205
        Height = 21
        Style = csDropDownList
        Ctl3D = True
        ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
        ParentCtl3D = False
        TabOrder = 0
        OnChange = cbxgrpListChange
      end
      object abXMax: TAbNumEdit
        Left = 60
        Top = 107
        Width = 137
        Height = 19
        ColorDefault = clWindow
        DigitsBool = 0
        DigitsHex = 0
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = []
        FormatStr = '#0.###'
        Increment = 1.000000000000000000
        MaxLength = 6
        MaxValue = 8192.000000000000000000
        MinValue = -8192.000000000000000000
        Options = [eoLimitMax, eoLimitMin]
        ParentFont = False
        TabOrder = 1
        Text = '0'
      end
      object abXmin: TAbNumEdit
        Left = 61
        Top = 135
        Width = 137
        Height = 19
        ColorDefault = clWindow
        DigitsBool = 0
        DigitsHex = 0
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = []
        FormatStr = '#0.###'
        Increment = 1.000000000000000000
        MaxLength = 6
        MaxValue = 8192.000000000000000000
        MinValue = -8192.000000000000000000
        Options = [eoLimitMax, eoLimitMin]
        ParentFont = False
        TabOrder = 2
        Text = '0'
      end
      object abXstep: TAbNumEdit
        Left = 61
        Top = 163
        Width = 137
        Height = 19
        ColorDefault = clWindow
        DigitsBool = 0
        DigitsHex = 0
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = []
        FormatStr = '#0.###'
        Increment = 1.000000000000000000
        MaxLength = 6
        MaxValue = 8192.000000000000000000
        MinValue = -8192.000000000000000000
        Options = [eoLimitMax, eoLimitMin]
        ParentFont = False
        TabOrder = 3
        Text = '0'
      end
      object abYMax: TAbNumEdit
        Left = 59
        Top = 246
        Width = 137
        Height = 19
        ColorDefault = clWindow
        DigitsBool = 0
        DigitsHex = 0
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = []
        FormatStr = '#0.###'
        Increment = 1.000000000000000000
        MaxLength = 8
        MaxValue = 1999999999.000000000000000000
        MinValue = -8192.000000000000000000
        Options = [eoLimitMax, eoLimitMin]
        ParentFont = False
        TabOrder = 4
        Text = '0'
      end
      object abYMin: TAbNumEdit
        Left = 60
        Top = 274
        Width = 137
        Height = 19
        ColorDefault = clWindow
        DigitsBool = 0
        DigitsHex = 0
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = []
        FormatStr = '#0.###'
        Increment = 1.000000000000000000
        MaxLength = 8
        MaxValue = 8192.000000000000000000
        MinValue = -8192.000000000000000000
        Options = []
        ParentFont = False
        TabOrder = 5
        Text = '0'
      end
      object abYstep: TAbNumEdit
        Left = 60
        Top = 302
        Width = 137
        Height = 19
        ColorDefault = clWindow
        DigitsBool = 0
        DigitsHex = 0
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = []
        FormatStr = '#0.###'
        Increment = 1.000000000000000000
        MaxLength = 8
        MaxValue = 1999999999.000000000000000000
        MinValue = -8192.000000000000000000
        Options = [eoLimitMax, eoLimitMin]
        ParentFont = False
        TabOrder = 6
        Text = '0'
      end
      object stxColor0: TStaticText
        Left = 88
        Top = 389
        Width = 37
        Height = 22
        AutoSize = False
        BorderStyle = sbsSingle
        Color = clBlack
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = []
        ParentColor = False
        ParentFont = False
        TabOrder = 7
        Transparent = False
      end
      object stxColor1: TStaticText
        Left = 88
        Top = 418
        Width = 37
        Height = 22
        AutoSize = False
        BorderStyle = sbsSingle
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = []
        ParentFont = False
        TabOrder = 8
        Transparent = False
      end
      object stxColor2: TStaticText
        Left = 88
        Top = 448
        Width = 37
        Height = 22
        AutoSize = False
        BorderStyle = sbsSingle
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = []
        ParentFont = False
        TabOrder = 9
        Transparent = False
      end
      object btnData: TButton
        Left = 128
        Top = 387
        Width = 65
        Height = 25
        Caption = 'setup'
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = []
        ParentFont = False
        TabOrder = 10
        OnClick = btnDataClick
      end
      object btnspec: TButton
        Tag = 1
        Left = 129
        Top = 417
        Width = 65
        Height = 25
        Caption = 'setup'
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = []
        ParentFont = False
        TabOrder = 11
        OnClick = btnDataClick
      end
      object btnTerm: TButton
        Tag = 2
        Left = 129
        Top = 446
        Width = 65
        Height = 25
        Caption = 'setup'
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = []
        ParentFont = False
        TabOrder = 12
        OnClick = btnDataClick
      end
    end
  end
  object DlgColor: TColorDialog
    Left = 360
    Top = 8
  end
end
