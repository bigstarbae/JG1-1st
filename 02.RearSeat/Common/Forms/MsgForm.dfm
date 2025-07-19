object frmMsg: TfrmMsg
  Left = 0
  Top = 0
  BorderStyle = bsNone
  ClientHeight = 507
  ClientWidth = 906
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poScreenCenter
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnlMain: TPanel
    Left = 0
    Top = 30
    Width = 906
    Height = 400
    Align = alTop
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 0
    object shpMainBorder: TShape
      Left = 0
      Top = 0
      Width = 906
      Height = 400
      Align = alClient
      Brush.Style = bsClear
      Pen.Color = 5066944
      Pen.Width = 4
      ExplicitLeft = 15
    end
    object imgIcon: TImage
      Left = 15
      Top = 35
      Width = 140
      Height = 140
    end
    object lblMainTitle: TLabel
      Left = 184
      Top = 35
      Width = 710
      Height = 37
      AutoSize = False
      Caption = #49324#50577#52404#53356#50640' '#49892#54056#54616#50688#49845#45768#45796
      Font.Charset = ANSI_CHARSET
      Font.Color = 3487637
      Font.Height = -33
      Font.Name = #45796#51020'_Regular'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblSubTitle: TLabel
      Left = 184
      Top = 82
      Width = 307
      Height = 30
      Caption = #50500#47000' '#54637#47785#51012' '#51216#44160' '#54616#49464#50836
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -27
      Font.Name = #45796#51020'_Regular'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object imgQRCode: TImage
      Left = 869
      Top = 35
      Width = 248
      Height = 241
    end
    object sgToDo: TStringGrid
      Left = 184
      Top = 114
      Width = 679
      Height = 243
      BevelInner = bvNone
      BevelOuter = bvNone
      BorderStyle = bsNone
      Color = clWhite
      ColCount = 1
      Ctl3D = False
      DefaultColWidth = 680
      DefaultRowHeight = 30
      DefaultDrawing = False
      FixedCols = 0
      RowCount = 1
      FixedRows = 0
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -21
      Font.Name = 'Tahoma'
      Font.Style = []
      GridLineWidth = 0
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goRangeSelect]
      ParentCtl3D = False
      ParentFont = False
      ScrollBars = ssNone
      TabOrder = 0
      OnDrawCell = sgToDoDrawCell
    end
  end
  object pnlCaption: TPanel
    Left = 0
    Top = 0
    Width = 906
    Height = 30
    Align = alTop
    BevelOuter = bvNone
    Color = 5066944
    ParentBackground = False
    TabOrder = 1
    OnMouseDown = pnlCaptionMouseDown
    object sbtnClose: TSpeedButton
      Left = 868
      Top = 0
      Width = 38
      Height = 30
      Align = alRight
      Caption = 'X'
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 13158892
      Font.Height = -21
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      OnClick = sbtnCloseClick
      ExplicitTop = -6
      ExplicitHeight = 40
    end
  end
  object pnlDebug: TPanel
    Left = 0
    Top = 448
    Width = 906
    Height = 59
    Align = alBottom
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 2
    object shpDebugBorder: TShape
      Left = 0
      Top = 0
      Width = 906
      Height = 59
      Align = alClient
      Brush.Style = bsClear
      Pen.Color = 5066944
      Pen.Width = 4
      ExplicitTop = -8
      ExplicitWidth = 1011
    end
    object Label1: TLabel
      Left = 15
      Top = 21
      Width = 82
      Height = 25
      AutoSize = False
      Caption = 'Debug : '
      Font.Charset = ANSI_CHARSET
      Font.Color = 5066944
      Font.Height = -16
      Font.Name = #45796#51020'_Regular'
      Font.Style = [fsBold]
      ParentFont = False
      Layout = tlCenter
    end
    object lblDebug: TLabel
      Left = 103
      Top = 18
      Width = 791
      Height = 25
      AutoSize = False
      Caption = #51060#44275#51008' Debug '#44277#44036' '#51077#45768#45796',  '#44032#47196' '#48176#50676#47196' '#54364#49884' '#46121#45768#45796
      Font.Charset = ANSI_CHARSET
      Font.Color = 5197647
      Font.Height = -16
      Font.Name = #47569#51008' '#44256#46357
      Font.Style = [fsBold]
      ParentFont = False
      Layout = tlCenter
    end
  end
  object tmrScroll: TTimer
    Enabled = False
    Interval = 2000
    OnTimer = tmrScrollTimer
    Left = 32
    Top = 240
  end
  object tmrBlink: TTimer
    Enabled = False
    Interval = 800
    OnTimer = tmrBlinkTimer
    Left = 112
    Top = 240
  end
end
