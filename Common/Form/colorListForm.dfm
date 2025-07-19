object frmColorList: TfrmColorList
  Left = 780
  Top = 363
  BorderStyle = bsDialog
  Caption = 'Graph Color Reference'
  ClientHeight = 320
  ClientWidth = 340
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
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object gbColorList: TGroupBox
    Tag = 222
    Left = 8
    Top = 8
    Width = 321
    Height = 266
    Caption = #49353#49345' '#49444#51221
    Font.Charset = HANGEUL_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #47569#51008' '#44256#46357
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    object Bevel1: TBevel
      Left = 8
      Top = 37
      Width = 304
      Height = 6
      Shape = bsTopLine
    end
    object Label1: TLabel
      Tag = 222
      Left = 3
      Top = 20
      Width = 31
      Height = 17
      Caption = #51333' '#47448
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = #47569#51008' '#44256#46357
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label2: TLabel
      Tag = 222
      Left = 134
      Top = 20
      Width = 31
      Height = 17
      Caption = #49353' '#49345
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = #47569#51008' '#44256#46357
      Font.Style = [fsBold]
      ParentFont = False
    end
    object ColorBox1: TColorBox
      Left = 133
      Top = 46
      Width = 145
      Height = 22
      Selected = clScrollBar
      TabOrder = 0
      OnChange = ColorBox1Change
    end
    object Edit1: TEdit
      Left = 10
      Top = 46
      Width = 117
      Height = 23
      Ctl3D = False
      ImeName = 'Microsoft IME 2003'
      ParentCtl3D = False
      TabOrder = 1
      Text = 'Edit1'
      OnChange = ColorBox1Change
    end
    object Button1: TButton
      Left = 282
      Top = 46
      Width = 29
      Height = 22
      Caption = '...'
      TabOrder = 2
      OnClick = Button1Click
    end
  end
  object bbtnOK: TBitBtn
    Tag = 222
    Left = 163
    Top = 280
    Width = 83
    Height = 26
    Caption = #54869#51064'(&O)'
    Font.Charset = HANGEUL_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = #47569#51008' '#44256#46357
    Font.Style = [fsBold]
    Kind = bkOK
    ParentFont = False
    TabOrder = 1
    OnClick = bbtnOKClick
  end
  object BitBtn4: TBitBtn
    Tag = 222
    Left = 246
    Top = 280
    Width = 83
    Height = 26
    Caption = #52712#49548'(&C)'
    Font.Charset = HANGEUL_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = #47569#51008' '#44256#46357
    Font.Style = [fsBold]
    Kind = bkCancel
    ParentFont = False
    TabOrder = 2
  end
  object bbtnApply: TBitBtn
    Tag = 222
    Left = 78
    Top = 280
    Width = 83
    Height = 26
    Caption = #51201#50857'(&A)'
    Font.Charset = HANGEUL_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = #47569#51008' '#44256#46357
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 3
    OnClick = bbtnApplyClick
  end
  object DlgColor: TColorDialog
    Left = 296
    Top = 8
  end
end
