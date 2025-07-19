object frmECUVerList: TfrmECUVerList
  Left = 0
  Top = 0
  ClientHeight = 668
  ClientWidth = 775
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #47569#51008' '#44256#46357
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 17
  object sgECUInfoList: TStringGrid
    Left = 0
    Top = 32
    Width = 775
    Height = 636
    Align = alClient
    DefaultColWidth = 85
    DrawingStyle = gdsGradient
    FixedColor = clGray
    RowCount = 15
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #47569#51008' '#44256#46357
    Font.Style = []
    GradientEndColor = 15263976
    GradientStartColor = 15987699
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing]
    ParentFont = False
    TabOrder = 0
    OnKeyDown = sgECUInfoListKeyDown
    OnMouseUp = sgECUInfoListMouseUp
    ColWidths = (
      69
      137
      151
      118
      130)
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
      24)
  end
  object pnlSearch: TPanel
    Left = 0
    Top = 0
    Width = 775
    Height = 32
    Align = alTop
    BevelOuter = bvNone
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #47569#51008' '#44256#46357
    Font.Style = []
    Padding.Left = 2
    Padding.Top = 2
    Padding.Right = 2
    Padding.Bottom = 2
    ParentFont = False
    TabOrder = 1
    object edtSrch: TEdit
      Left = 2
      Top = 2
      Width = 597
      Height = 28
      Align = alClient
      Alignment = taRightJustify
      Color = 14942207
      Ctl3D = False
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlue
      Font.Height = -15
      Font.Name = #47569#51008' '#44256#46357
      Font.Style = []
      ParentCtl3D = False
      ParentFont = False
      TabOrder = 0
      OnKeyDown = edtSrchKeyDown
      ExplicitHeight = 26
    end
    object btnSrch: TButton
      Left = 599
      Top = 2
      Width = 174
      Height = 28
      Align = alRight
      Caption = 'SEAT P/NO '#44160#49353
      TabOrder = 1
      OnClick = btnSrchClick
    end
  end
end
