object frmErCodeList: TfrmErCodeList
  Left = 210
  Top = 122
  Caption = 'Error Code List'
  ClientHeight = 639
  ClientWidth = 884
  Color = clBtnFace
  Font.Charset = HANGEUL_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #44404#47548
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object sgrdList: TStringGrid
    Left = 56
    Top = 176
    Width = 419
    Height = 401
    ColCount = 4
    Ctl3D = False
    DefaultRowHeight = 20
    DefaultDrawing = False
    FixedCols = 0
    RowCount = 257
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = #44404#47548
    Font.Style = []
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing, goEditing]
    ParentCtl3D = False
    ParentFont = False
    TabOrder = 0
    OnDrawCell = sgrdListDrawCell
    OnSelectCell = sgrdListSelectCell
    OnSetEditText = sgrdListSetEditText
    ColWidths = (
      62
      68
      68
      64)
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 884
    Height = 97
    Align = alTop
    BevelOuter = bvNone
    BorderStyle = bsSingle
    Color = 15593457
    Ctl3D = False
    ParentBackground = False
    ParentCtl3D = False
    TabOrder = 1
    object Label8: TLabel
      Left = 21
      Top = 29
      Width = 128
      Height = 13
      Caption = 'ERROR CODE '#44288#47532
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = #44404#47548
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Shape10: TShape
      Left = 13
      Top = 12
      Width = 800
      Height = 5
      Brush.Color = clBlack
    end
    object Shape11: TShape
      Left = 13
      Top = 53
      Width = 800
      Height = 1
      Brush.Color = clBlack
    end
    object SpeedButton1: TSpeedButton
      Left = 575
      Top = 21
      Width = 116
      Height = 27
      Caption = 'Load From File'
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clBlack
      Font.Height = -12
      Font.Name = #44404#47548
      Font.Style = [fsBold]
      ParentFont = False
      OnClick = SpeedButton1Click
    end
    object SpeedButton3: TSpeedButton
      Left = 696
      Top = 21
      Width = 116
      Height = 27
      Caption = 'SAVE'
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clBlack
      Font.Height = -12
      Font.Name = #44404#47548
      Font.Style = [fsBold]
      ParentFont = False
      OnClick = SpeedButton3Click
    end
    object Label2: TLabel
      Left = 31
      Top = 66
      Width = 56
      Height = 13
      Alignment = taRightJustify
      Caption = #44277#51221#49440#53469
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = #44404#47548
      Font.Style = [fsBold]
      ParentFont = False
    end
    object cbbTestList: TComboBox
      Left = 93
      Top = 64
      Width = 270
      Height = 19
      Style = csOwnerDrawFixed
      ImeName = 'Microsoft Office IME 2007'
      ItemHeight = 13
      TabOrder = 0
      OnChange = cbbTestListChange
    end
  end
  object OpenDlg: TOpenDialog
    Left = 472
    Top = 24
  end
  object ioTimer: TTimer
    Enabled = False
    OnTimer = ioTimerTimer
    Left = 424
    Top = 24
  end
end
