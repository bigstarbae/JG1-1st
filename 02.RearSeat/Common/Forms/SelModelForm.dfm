object frmSelModels: TfrmSelModels
  Left = 362
  Top = 252
  Caption = #47784#45944#49440#53469
  ClientHeight = 601
  ClientWidth = 380
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
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 0
    Top = 0
    Width = 380
    Height = 21
    Align = alTop
    Alignment = taCenter
    AutoSize = False
    Caption = #51201#50857' '#47784#45944#49440#53469
    Color = 7321527
    Font.Charset = HANGEUL_CHARSET
    Font.Color = clWhite
    Font.Height = -13
    Font.Name = #44404#47548
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
    Layout = tlCenter
    ExplicitWidth = 372
  end
  object cklModel: TCheckListBox
    Left = 0
    Top = 21
    Width = 380
    Height = 519
    Align = alClient
    Font.Charset = HANGEUL_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = #44404#47548
    Font.Style = [fsBold]
    ImeName = 'Microsoft Office IME 2007'
    Items.Strings = (
      '1'
      '2'
      '3'
      '4'
      '5')
    ParentFont = False
    TabOrder = 0
  end
  object Panel1: TPanel
    Left = 0
    Top = 540
    Width = 380
    Height = 61
    Align = alBottom
    TabOrder = 1
    object BitBtn1: TBitBtn
      Left = 184
      Top = 14
      Width = 89
      Height = 29
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
      Left = 272
      Top = 14
      Width = 89
      Height = 29
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
    object CheckBox1: TCheckBox
      Left = 3
      Top = 3
      Width = 77
      Height = 17
      Caption = #47784#46160#49440#53469
      TabOrder = 2
      OnClick = CheckBox1Click
    end
    object ckbApplyMotor: TCheckBox
      Left = 80
      Top = 2
      Width = 101
      Height = 17
      Caption = #47784#53552#44160#49324#49444#51221
      TabOrder = 3
    end
    object ckbAppyDelivery: TCheckBox
      Left = 80
      Top = 20
      Width = 101
      Height = 17
      Caption = #45225#54408#50948#52824#49444#51221
      TabOrder = 4
    end
    object ckbAppySwIo: TCheckBox
      Left = 3
      Top = 21
      Width = 77
      Height = 17
      Caption = 'SW I/O'
      TabOrder = 5
    end
    object ckbUsrType: TCheckBox
      Left = 3
      Top = 39
      Width = 77
      Height = 17
      Caption = #49324#50577#51221#48372
      TabOrder = 6
    end
  end
end
