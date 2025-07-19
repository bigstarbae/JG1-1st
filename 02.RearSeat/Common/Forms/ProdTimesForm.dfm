object frmProdTimes: TfrmProdTimes
  Left = 392
  Top = 122
  BorderStyle = bsDialog
  Caption = #49884#44036#45824#48324' '#49884#44036' '#44396#44036' '#49444#51221'.'
  ClientHeight = 736
  ClientWidth = 439
  Color = clBtnFace
  Font.Charset = HANGEUL_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #44404#47548
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 0
    Top = 679
    Width = 439
    Height = 16
    Align = alBottom
    Alignment = taCenter
    AutoSize = False
    Caption = #49688#51221#51008' '#54644#45817' '#49472#51012' '#45908#48660#53364#47533#54616#49464#50836'!.'
    Font.Charset = HANGEUL_CHARSET
    Font.Color = clRed
    Font.Height = -13
    Font.Name = #44404#47548
    Font.Style = [fsBold]
    ParentFont = False
    Layout = tlCenter
  end
  object pnlTitle: TPanel
    Left = 0
    Top = 0
    Width = 439
    Height = 46
    Align = alTop
    BevelOuter = bvNone
    Caption = #49884#44036#45824#48324' '#49884#44036' '#44396#44036' '#49444#51221
    Color = 10975851
    FullRepaint = False
    Font.Charset = HANGEUL_CHARSET
    Font.Color = clWhite
    Font.Height = -27
    Font.Name = #44404#47548
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
  end
  object sgrdTimes: TStringGrid
    Left = 0
    Top = 46
    Width = 439
    Height = 633
    Align = alClient
    ColCount = 3
    FixedCols = 0
    RowCount = 25
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine]
    ScrollBars = ssNone
    TabOrder = 1
    OnDblClick = sgrdTimesDblClick
    OnDrawCell = sgrdTimesDrawCell
    OnKeyUp = sgrdTimesKeyUp
    ColWidths = (
      70
      181
      176)
  end
  object Panel1: TPanel
    Left = 0
    Top = 695
    Width = 439
    Height = 41
    Align = alBottom
    TabOrder = 2
    object BitBtn1: TBitBtn
      Left = 267
      Top = 8
      Width = 75
      Height = 25
      Caption = #54869#51064
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = #44404#47548
      Font.Style = [fsBold]
      Kind = bkOK
      ParentFont = False
      TabOrder = 0
    end
    object BitBtn2: TBitBtn
      Left = 347
      Top = 8
      Width = 75
      Height = 25
      Caption = #52712#49548
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = #44404#47548
      Font.Style = [fsBold]
      Kind = bkCancel
      ParentFont = False
      TabOrder = 1
    end
    object rdbtnOrdinary: TRadioButton
      Left = 19
      Top = 11
      Width = 54
      Height = 17
      Caption = #54217#51068
      Checked = True
      TabOrder = 2
      TabStop = True
      OnClick = rdbtnOrdinaryClick
    end
    object rdbtnWeekEnd: TRadioButton
      Left = 76
      Top = 11
      Width = 54
      Height = 17
      Caption = #51452#47568
      TabOrder = 3
      OnClick = rdbtnOrdinaryClick
    end
  end
end
