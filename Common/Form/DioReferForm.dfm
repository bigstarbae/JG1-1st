object frmDioReferForm: TfrmDioReferForm
  Left = 225
  Top = 150
  Caption = 'I/O CHECKER FORM'
  ClientHeight = 446
  ClientWidth = 667
  Color = clBtnFace
  Font.Charset = HANGEUL_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #44404#47548
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel2: TPanel
    Left = 0
    Top = 397
    Width = 667
    Height = 49
    Align = alBottom
    ParentBackground = False
    TabOrder = 1
    object Panel1: TPanel
      Left = 574
      Top = 1
      Width = 92
      Height = 47
      Align = alRight
      AutoSize = True
      BevelOuter = bvNone
      BorderWidth = 4
      TabOrder = 0
      object bbtnOK: TBitBtn
        Left = 4
        Top = 8
        Width = 84
        Height = 30
        Caption = #54869#51064'(&O)'
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = [fsBold]
        Kind = bkOK
        ParentFont = False
        TabOrder = 0
        OnClick = bbtnOKClick
      end
    end
    object btnUndock: TButton
      Left = 8
      Top = 9
      Width = 84
      Height = 30
      Caption = 'UNDOCK'
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = #47569#51008' '#44256#46357
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      OnClick = btnUndockClick
    end
  end
  object pcSubForms: TPageControl
    Left = 0
    Top = 0
    Width = 667
    Height = 397
    Align = alClient
    Font.Charset = HANGEUL_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #47569#51008' '#44256#46357
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    OnChange = pcSubFormsChange
  end
end
