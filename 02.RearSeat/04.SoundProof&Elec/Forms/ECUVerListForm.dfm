object frmECUVerList: TfrmECUVerList
  Left = 0
  Top = 0
  ClientHeight = 668
  ClientWidth = 984
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
  object sgECUVerList: TStringGrid
    Left = 0
    Top = 0
    Width = 984
    Height = 668
    Align = alClient
    ColCount = 8
    DefaultColWidth = 85
    RowCount = 15
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #47569#51008' '#44256#46357
    Font.Style = []
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing]
    ParentFont = False
    TabOrder = 0
    OnKeyDown = sgECUVerListKeyDown
    ExplicitWidth = 775
    ColWidths = (
      69
      137
      151
      118
      130
      85
      85
      85)
  end
end
