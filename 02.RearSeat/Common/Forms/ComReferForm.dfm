object frmComsRefer: TfrmComsRefer
  Left = 293
  Top = 83
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Set up for Com port'
  ClientHeight = 529
  ClientWidth = 639
  Color = clBtnFace
  Font.Charset = HANGEUL_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #47569#51008' '#44256#46357
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 17
  object pnlDock: TPanel
    Left = 0
    Top = 0
    Width = 639
    Height = 480
    Align = alClient
    TabOrder = 0
  end
  object Panel2: TPanel
    Left = 0
    Top = 480
    Width = 639
    Height = 49
    Align = alBottom
    TabOrder = 1
    object bbtnApply: TBitBtn
      Left = 371
      Top = 10
      Width = 84
      Height = 30
      Caption = #51201#50857'(&A)'
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = #47569#51008' '#44256#46357
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      OnClick = bbtnApplyClick
    end
    object bbtnOK: TBitBtn
      Left = 458
      Top = 10
      Width = 84
      Height = 30
      Caption = #54869#51064'(&O)'
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = #47569#51008' '#44256#46357
      Font.Style = [fsBold]
      Kind = bkOK
      ParentFont = False
      TabOrder = 1
      OnClick = bbtnOKClick
    end
    object bbtnCancel: TBitBtn
      Left = 546
      Top = 10
      Width = 84
      Height = 30
      Caption = #52712#49548'(&C)'
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = #47569#51008' '#44256#46357
      Font.Style = [fsBold]
      Kind = bkCancel
      ParentFont = False
      TabOrder = 2
      OnClick = bbtnCancelClick
    end
  end
end
