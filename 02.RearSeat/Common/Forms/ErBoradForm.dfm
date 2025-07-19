object frmErBorad: TfrmErBorad
  Left = 953
  Top = 123
  Caption = 'M/C Error status Board #1'
  ClientHeight = 730
  ClientWidth = 1344
  Color = clBtnFace
  Font.Charset = HANGEUL_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #44404#47548
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDblClick = FormDblClick
  OnDestroy = FormDestroy
  OnPaint = FormPaint
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnlError: TPanel
    Left = 25
    Top = 283
    Width = 1088
    Height = 281
    Caption = #50616#47196#46377#52769' C/V '#50640#47084#48156#49373
    Color = clYellow
    Font.Charset = HANGEUL_CHARSET
    Font.Color = clRed
    Font.Height = -133
    Font.Name = #44404#47548
    Font.Style = [fsBold]
    ParentBackground = False
    ParentFont = False
    TabOrder = 0
    Visible = False
  end
  object Timer1: TTimer
    Enabled = False
    OnTimer = Timer1Timer
    Left = 352
    Top = 144
  end
end
