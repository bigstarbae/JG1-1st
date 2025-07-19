object frmDio: TfrmDio
  Left = 19
  Top = 163
  BorderStyle = bsSingle
  Caption = 'I/O Checker'
  ClientHeight = 628
  ClientWidth = 1009
  Color = clBtnFace
  Font.Charset = HANGEUL_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #44404#47548
  Font.Style = []
  OldCreateOrder = False
  WindowState = wsMaximized
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 1009
    Height = 66
    Align = alTop
    BevelOuter = bvNone
    BorderStyle = bsSingle
    Color = 15593457
    Ctl3D = False
    ParentBackground = False
    ParentCtl3D = False
    TabOrder = 0
    OnResize = Panel2Resize
    object Label8: TLabel
      Left = 21
      Top = 29
      Width = 32
      Height = 13
      Caption = 'DI/O'
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = #44404#47548
      Font.Style = [fsBold]
      ParentFont = False
      OnDblClick = Label8DblClick
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
    object sbtnPaste: TSpeedButton
      Left = 560
      Top = 21
      Width = 130
      Height = 27
      Caption = 'Paste From Clipbd'
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clBlack
      Font.Height = -12
      Font.Name = #44404#47548
      Font.Style = [fsBold]
      ParentFont = False
      Visible = False
      OnClick = sbtnPasteClick
    end
    object sbtnSave: TSpeedButton
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
      OnClick = sbtnSaveClick
    end
    object labTime: TLabel
      Left = 470
      Top = 34
      Width = 49
      Height = 13
      Caption = 'labTime'
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clSilver
      Font.Height = -13
      Font.Name = #44404#47548
      Font.Style = []
      ParentFont = False
    end
    object cbxStation: TComboBox
      Left = 72
      Top = 24
      Width = 121
      Height = 21
      Style = csDropDownList
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 0
      OnChange = cbxStationChange
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 66
    Width = 1009
    Height = 562
    Align = alClient
    TabOrder = 1
    object sgrdIO: TStringGrid
      Left = 1
      Top = 1
      Width = 1007
      Height = 560
      Align = alClient
      BorderStyle = bsNone
      Color = clWhite
      ColCount = 8
      DefaultColWidth = 60
      DefaultRowHeight = 21
      DefaultDrawing = False
      FixedCols = 0
      RowCount = 225
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = #47569#51008' '#44256#46357
      Font.Style = []
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing, goEditing, goTabs]
      ParentFont = False
      TabOrder = 0
      OnDrawCell = sgrdIODrawCell
      OnKeyDown = sgrdIOKeyDown
      OnSelectCell = sgrdIOSelectCell
      OnSetEditText = sgrdIOSetEditText
      ColWidths = (
        60
        60
        60
        326
        60
        60
        60
        282)
    end
  end
  object ioTimer: TTimer
    Enabled = False
    Interval = 100
    OnTimer = ioTimerTimer
    Left = 504
    Top = 88
  end
  object openDlg: TOpenDialog
    Left = 536
    Top = 94
  end
end
