object frmNotify: TfrmNotify
  Left = 247
  Top = 321
  BorderIcons = []
  BorderStyle = bsDialog
  ClientHeight = 111
  ClientWidth = 613
  Color = clBtnFace
  Font.Charset = HANGEUL_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #44404#47548
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object labMsg: TLabel
    Left = 16
    Top = 16
    Width = 55
    Height = 21
    Caption = 'labMsg'
    Font.Charset = HANGEUL_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = #47569#51008' '#44256#46357
    Font.Style = [fsBold]
    ParentFont = False
  end
  object labState: TLabel
    Left = 16
    Top = 64
    Width = 47
    Height = 17
    Caption = 'labState'
    Font.Charset = HANGEUL_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #47569#51008' '#44256#46357
    Font.Style = []
    ParentFont = False
  end
  object pgbReadCount: TProgressBar
    Left = 8
    Top = 88
    Width = 598
    Height = 16
    Smooth = True
    TabOrder = 0
  end
end
