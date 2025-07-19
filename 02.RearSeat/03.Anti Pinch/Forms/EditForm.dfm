object frmEdit: TfrmEdit
  Left = 266
  Top = 119
  BorderIcons = [biSystemMenu]
  Caption = 'Model'
  ClientHeight = 902
  ClientWidth = 737
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
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 737
    Height = 902
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
    object Shape3: TShape
      Left = 8
      Top = 12
      Width = 700
      Height = 5
      Brush.Color = clBlack
    end
    object Label2: TLabel
      Left = 63
      Top = 65
      Width = 33
      Height = 16
      Alignment = taRightJustify
      Caption = #47784#45944#47749
      FocusControl = edtPartName
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object Shape6: TShape
      Left = 8
      Top = 50
      Width = 700
      Height = 1
      Brush.Color = clBlack
    end
    object labPartName: TLabel
      Left = 16
      Top = 25
      Width = 74
      Height = 16
      Caption = #47784#45944' '#51221#48372
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = #44404#47548
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Shape7: TShape
      Left = 12
      Top = 98
      Width = 700
      Height = 2
      Brush.Color = clBlack
    end
    object labIndex: TLabel
      Left = 657
      Top = 20
      Width = 49
      Height = 27
      Alignment = taCenter
      AutoSize = False
      Caption = '01'
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clWindowText
      Font.Height = -27
      Font.Name = #44404#47548
      Font.Style = [fsBold]
      ParentFont = False
      Layout = tlCenter
    end
    object edtPartName: TEdit
      Left = 106
      Top = 64
      Width = 550
      Height = 19
      Ctl3D = False
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = #44404#47548
      Font.Style = []
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      MaxLength = 62
      ParentCtl3D = False
      ParentFont = False
      TabOrder = 0
      OnChange = OnSaveBtnActive
    end
    object GroupBox1: TGroupBox
      Left = 957
      Top = 432
      Width = 653
      Height = 117
      Caption = #49548#51020' '#44160#49324'(&E)'
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = #44404#47548
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 4
      Visible = False
      object Label6: TLabel
        Left = 59
        Top = 34
        Width = 127
        Height = 13
        Alignment = taRightJustify
        Caption = #51089#46041' '#49548#51020' '#44160#49324' '#44592#51456
      end
      object Label9: TLabel
        Left = 335
        Top = 34
        Width = 74
        Height = 13
        Caption = '( dB '#51060#54616' )'
      end
      object Label49: TLabel
        Left = 436
        Top = 34
        Width = 39
        Height = 13
        Alignment = taRightJustify
        Caption = 'offset'
        Visible = False
      end
      object Label50: TLabel
        Left = 482
        Top = 15
        Width = 25
        Height = 13
        Caption = '#12'
        Visible = False
      end
      object Label51: TLabel
        Left = 547
        Top = 15
        Width = 25
        Height = 13
        Caption = '#13'
        Visible = False
      end
      object Label58: TLabel
        Left = 36
        Top = 63
        Width = 150
        Height = 13
        Alignment = taRightJustify
        Caption = #52488#44592#51089#46041' '#49548#51020' '#52769#51221#44396#44036
      end
      object Label59: TLabel
        Left = 335
        Top = 63
        Width = 69
        Height = 13
        Caption = '( '#52488' '#44620#51648' )'
      end
      object Label61: TLabel
        Left = 36
        Top = 86
        Width = 150
        Height = 13
        Alignment = taRightJustify
        Caption = #52488#44592#51089#46041' '#49548#51020' '#44160#49324#44592#51456
      end
      object Label62: TLabel
        Left = 335
        Top = 86
        Width = 74
        Height = 13
        Caption = '( dB '#51060#54616' )'
      end
      object Label63: TLabel
        Left = 436
        Top = 86
        Width = 39
        Height = 13
        Alignment = taRightJustify
        Caption = 'offset'
        Visible = False
      end
      object edtNoiseRunning: TEdit
        Left = 190
        Top = 31
        Width = 141
        Height = 19
        Ctl3D = False
        ImeName = 'Microsoft IME 2003'
        ParentCtl3D = False
        TabOrder = 0
      end
      object edtOffsetNoiseRunning0: TEdit
        Left = 480
        Top = 31
        Width = 62
        Height = 19
        Ctl3D = False
        ImeName = 'Microsoft IME 2003'
        ParentCtl3D = False
        TabOrder = 1
        Text = 'edtLeverOffsetAngleRH'
        Visible = False
      end
      object edtOffsetNoiseRunning1: TEdit
        Left = 545
        Top = 31
        Width = 62
        Height = 19
        Ctl3D = False
        ImeName = 'Microsoft IME 2003'
        ParentCtl3D = False
        TabOrder = 2
        Text = 'edtLeverOffsetAngleRH'
        Visible = False
      end
      object edtNoiseInitTime: TEdit
        Left = 190
        Top = 60
        Width = 141
        Height = 19
        Ctl3D = False
        ImeName = 'Microsoft IME 2003'
        ParentCtl3D = False
        TabOrder = 3
      end
      object edtNoiseInitMax: TEdit
        Left = 190
        Top = 83
        Width = 141
        Height = 19
        Ctl3D = False
        ImeName = 'Microsoft IME 2003'
        ParentCtl3D = False
        TabOrder = 4
      end
      object edtOffsetNoiseInit0: TEdit
        Left = 480
        Top = 83
        Width = 62
        Height = 19
        Ctl3D = False
        ImeName = 'Microsoft IME 2003'
        ParentCtl3D = False
        TabOrder = 5
        Text = 'edtLeverOffsetAngleRH'
        Visible = False
      end
      object edtOffsetNoiseInit1: TEdit
        Left = 545
        Top = 83
        Width = 62
        Height = 19
        Ctl3D = False
        ImeName = 'Microsoft IME 2003'
        ParentCtl3D = False
        TabOrder = 6
        Text = 'edtLeverOffsetAngleRH'
        Visible = False
      end
    end
    object pcMdl: TPageControl
      Left = 0
      Top = 225
      Width = 735
      Height = 675
      ActivePage = TabSheet1
      Align = alBottom
      Style = tsFlatButtons
      TabOrder = 3
      TabWidth = 135
      object TabSheet1: TTabSheet
        Caption = #44160#49324' '#49444#51221
        object pnlAP_Slide: TPanel
          Left = 0
          Top = 0
          Width = 727
          Height = 153
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 0
          object Label18: TLabel
            Left = 27
            Top = 9
            Width = 121
            Height = 17
            Caption = 'SLIDE ANTI PINCH '
            Font.Charset = HANGEUL_CHARSET
            Font.Color = clMaroon
            Font.Height = -13
            Font.Name = #47569#51008' '#44256#46357
            Font.Style = [fsBold]
            ParentFont = False
            Transparent = False
            OnDblClick = Label18DblClick
          end
          object Shape8: TShape
            Left = 28
            Top = 30
            Width = 615
            Height = 2
            Brush.Color = clMaroon
            Pen.Color = clMaroon
          end
          object Label15: TLabel
            Left = 85
            Top = 49
            Width = 29
            Height = 17
            Alignment = taRightJustify
            Caption = 'Load'
            Font.Charset = HANGEUL_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = #47569#51008' '#44256#46357
            Font.Style = []
            ParentFont = False
          end
          object Label16: TLabel
            Left = 204
            Top = 49
            Width = 9
            Height = 17
            Caption = '~'
          end
          object Label17: TLabel
            Left = 306
            Top = 49
            Width = 27
            Height = 17
            Caption = '(kgf)'
            Font.Charset = HANGEUL_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = #47569#51008' '#44256#46357
            Font.Style = []
            ParentFont = False
          end
          object Label79: TLabel
            Left = 306
            Top = 123
            Width = 17
            Height = 17
            Caption = '(A)'
            Font.Charset = HANGEUL_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = #47569#51008' '#44256#46357
            Font.Style = []
            ParentFont = False
          end
          object Label78: TLabel
            Left = 204
            Top = 88
            Width = 9
            Height = 17
            Caption = '~'
          end
          object Label81: TLabel
            Left = 204
            Top = 123
            Width = 9
            Height = 17
            Caption = '~'
          end
          object Label82: TLabel
            Left = 306
            Top = 88
            Width = 17
            Height = 17
            Caption = '(A)'
            Font.Charset = HANGEUL_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = #47569#51008' '#44256#46357
            Font.Style = []
            ParentFont = False
          end
          object Label80: TLabel
            Left = 40
            Top = 123
            Width = 74
            Height = 17
            Alignment = taRightJustify
            Caption = 'Rev. Current'
            Font.Charset = HANGEUL_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = #47569#51008' '#44256#46357
            Font.Style = []
            ParentFont = False
          end
          object Label77: TLabel
            Left = 37
            Top = 88
            Width = 77
            Height = 17
            Alignment = taRightJustify
            Caption = 'Stop Current'
            Font.Charset = HANGEUL_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = #47569#51008' '#44256#46357
            Font.Style = []
            ParentFont = False
          end
          object edtAPLoadLo_Slide: TEdit
            Left = 131
            Top = 46
            Width = 62
            Height = 23
            Color = 14811135
            Ctl3D = False
            ImeName = 'Microsoft IME 2003'
            ParentCtl3D = False
            TabOrder = 0
          end
          object edtAPLoadHi_Slide: TEdit
            Left = 228
            Top = 46
            Width = 62
            Height = 23
            Color = 14811135
            Ctl3D = False
            ImeName = 'Microsoft IME 2003'
            ParentCtl3D = False
            TabOrder = 1
          end
          object edtAPStopCurrHi_Slide: TEdit
            Left = 228
            Top = 85
            Width = 62
            Height = 23
            Color = 14811135
            Ctl3D = False
            ImeName = 'Microsoft IME 2003'
            ParentCtl3D = False
            TabOrder = 2
          end
          object edtAPRevCurrLo_Slide: TEdit
            Left = 131
            Top = 120
            Width = 62
            Height = 23
            Color = 14811135
            Ctl3D = False
            ImeName = 'Microsoft IME 2003'
            ParentCtl3D = False
            TabOrder = 3
          end
          object sgAPOffset_Slide: TStringGrid
            Left = 352
            Top = 41
            Width = 216
            Height = 111
            Ctl3D = False
            ParentCtl3D = False
            TabOrder = 4
            Visible = False
          end
        end
        object pnlAP_Recl: TPanel
          Left = 0
          Top = 153
          Width = 727
          Height = 153
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 1
          object Label1: TLabel
            Left = 27
            Top = 9
            Width = 137
            Height = 17
            Caption = 'RECLINE ANTI PINCH '
            Font.Charset = HANGEUL_CHARSET
            Font.Color = clMaroon
            Font.Height = -13
            Font.Name = #47569#51008' '#44256#46357
            Font.Style = [fsBold]
            ParentFont = False
            Transparent = False
            OnDblClick = Label1DblClick
          end
          object Shape1: TShape
            Left = 28
            Top = 30
            Width = 615
            Height = 2
            Brush.Color = clMaroon
            Pen.Color = clMaroon
          end
          object Label3: TLabel
            Left = 85
            Top = 50
            Width = 29
            Height = 17
            Alignment = taRightJustify
            Caption = 'Load'
            Font.Charset = HANGEUL_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = #47569#51008' '#44256#46357
            Font.Style = []
            ParentFont = False
          end
          object Label4: TLabel
            Left = 204
            Top = 50
            Width = 9
            Height = 17
            Caption = '~'
          end
          object Label5: TLabel
            Left = 306
            Top = 50
            Width = 27
            Height = 17
            Caption = '(kgf)'
            Font.Charset = HANGEUL_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = #47569#51008' '#44256#46357
            Font.Style = []
            ParentFont = False
          end
          object Label7: TLabel
            Left = 306
            Top = 123
            Width = 17
            Height = 17
            Caption = '(A)'
            Font.Charset = HANGEUL_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = #47569#51008' '#44256#46357
            Font.Style = []
            ParentFont = False
          end
          object Label8: TLabel
            Left = 204
            Top = 84
            Width = 9
            Height = 17
            Caption = '~'
          end
          object Label10: TLabel
            Left = 204
            Top = 123
            Width = 9
            Height = 17
            Caption = '~'
          end
          object Label11: TLabel
            Left = 306
            Top = 84
            Width = 17
            Height = 17
            Caption = '(A)'
            Font.Charset = HANGEUL_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = #47569#51008' '#44256#46357
            Font.Style = []
            ParentFont = False
          end
          object Label12: TLabel
            Left = 40
            Top = 123
            Width = 74
            Height = 17
            Alignment = taRightJustify
            Caption = 'Rev. Current'
            Font.Charset = HANGEUL_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = #47569#51008' '#44256#46357
            Font.Style = []
            ParentFont = False
          end
          object Label13: TLabel
            Left = 37
            Top = 84
            Width = 77
            Height = 17
            Alignment = taRightJustify
            Caption = 'Stop Current'
            Font.Charset = HANGEUL_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = #47569#51008' '#44256#46357
            Font.Style = []
            ParentFont = False
          end
          object edtAPLoadLo_Recl: TEdit
            Left = 131
            Top = 47
            Width = 62
            Height = 23
            Color = 14811135
            Ctl3D = False
            ImeName = 'Microsoft IME 2003'
            ParentCtl3D = False
            TabOrder = 0
          end
          object edtAPStopCurrHi_Recl: TEdit
            Left = 228
            Top = 81
            Width = 62
            Height = 23
            Color = 14811135
            Ctl3D = False
            ImeName = 'Microsoft IME 2003'
            ParentCtl3D = False
            TabOrder = 1
          end
          object edtAPLoadHi_Recl: TEdit
            Left = 228
            Top = 47
            Width = 62
            Height = 23
            Color = 14811135
            Ctl3D = False
            ImeName = 'Microsoft IME 2003'
            ParentCtl3D = False
            TabOrder = 2
          end
          object edtAPRevCurrLo_Recl: TEdit
            Left = 131
            Top = 120
            Width = 62
            Height = 23
            Color = 14811135
            Ctl3D = False
            ImeName = 'Microsoft IME 2003'
            ParentCtl3D = False
            TabOrder = 3
          end
          object sgAPOffset_Recl: TStringGrid
            Left = 355
            Top = 37
            Width = 216
            Height = 111
            Ctl3D = False
            ParentCtl3D = False
            TabOrder = 4
            Visible = False
            RowHeights = (
              24
              24
              24
              24
              24)
          end
        end
      end
    end
    object rdgCar: TRadioGroup
      Left = 16
      Top = 112
      Width = 258
      Height = 54
      Caption = 'CAR'
      Columns = 2
      Ctl3D = False
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = #47569#51008' '#44256#46357
      Font.Style = []
      ItemIndex = 0
      Items.Strings = (
        'JG1'
        'SP1')
      ParentCtl3D = False
      ParentFont = False
      TabOrder = 1
      OnClick = OnSaveBtnActive
    end
    object rdgPos: TRadioGroup
      Left = 291
      Top = 112
      Width = 179
      Height = 54
      Caption = 'POS'
      Columns = 2
      Ctl3D = False
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = #47569#51008' '#44256#46357
      Font.Style = []
      ItemIndex = 0
      Items.Strings = (
        'LH'
        'RH')
      ParentCtl3D = False
      ParentFont = False
      TabOrder = 2
      OnClick = OnSaveBtnActive
    end
  end
end
