object frmDIOEx: TfrmDIOEx
  Left = 0
  Top = 0
  ClientHeight = 531
  ClientWidth = 882
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDefault
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object sgDIO: TStringGrid
    Left = 0
    Top = 0
    Width = 882
    Height = 531
    Align = alClient
    BorderStyle = bsNone
    Color = clWhite
    ColCount = 6
    Ctl3D = False
    DefaultColWidth = 125
    DefaultRowHeight = 21
    DefaultDrawing = False
    DoubleBuffered = True
    DrawingStyle = gdsClassic
    FixedColor = 2236962
    FixedCols = 0
    RowCount = 21
    Font.Charset = HANGEUL_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #47569#51008' '#44256#46357
    Font.Style = []
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing, goTabs, goRowSelect]
    ParentCtl3D = False
    ParentDoubleBuffered = False
    ParentFont = False
    TabOrder = 0
    OnDrawCell = sgDIODrawCell
    OnMouseUp = sgDIOMouseUp
  end
  object tmrPoll: TTimer
    Interval = 100
    OnTimer = tmrPollTimer
    Left = 24
    Top = 472
  end
end
