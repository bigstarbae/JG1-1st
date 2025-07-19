object frmAComRefer: TfrmAComRefer
  Left = 614
  Top = 356
  ActiveControl = bbtnOK
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Set up for com port'
  ClientHeight = 319
  ClientWidth = 398
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
  object Bevel1: TBevel
    Left = 4
    Top = 258
    Width = 387
    Height = 9
    Shape = bsTopLine
  end
  object labsubCaption: TLabel
    Left = 0
    Top = 0
    Width = 398
    Height = 40
    Align = alTop
    Alignment = taCenter
    AutoSize = False
    Caption = 'Com port'
    Color = 15570510
    Font.Charset = HANGEUL_CHARSET
    Font.Color = clWhite
    Font.Height = -13
    Font.Name = #47569#51008' '#44256#46357
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
    Transparent = False
    Layout = tlCenter
  end
  object GroupBox1: TGroupBox
    Left = 21
    Top = 52
    Width = 342
    Height = 193
    Font.Charset = HANGEUL_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #47569#51008' '#44256#46357
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    object Label3: TLabel
      Left = 42
      Top = 30
      Width = 49
      Height = 17
      Alignment = taRightJustify
      Caption = 'bit / sec'
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = #47569#51008' '#44256#46357
      Font.Style = []
      ParentFont = False
    end
    object Label4: TLabel
      Left = 45
      Top = 64
      Width = 46
      Height = 17
      Alignment = taRightJustify
      Caption = 'data bit'
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = #47569#51008' '#44256#46357
      Font.Style = []
      ParentFont = False
    end
    object Label5: TLabel
      Left = 58
      Top = 97
      Width = 33
      Height = 17
      Alignment = taRightJustify
      Caption = 'parity'
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = #47569#51008' '#44256#46357
      Font.Style = []
      ParentFont = False
    end
    object Label6: TLabel
      Left = 45
      Top = 130
      Width = 46
      Height = 17
      Alignment = taRightJustify
      Caption = 'stop bit'
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = #47569#51008' '#44256#46357
      Font.Style = []
      ParentFont = False
    end
    object Label1: TLabel
      Left = 19
      Top = 159
      Width = 72
      Height = 17
      Alignment = taRightJustify
      Caption = 'flow control'
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = #47569#51008' '#44256#46357
      Font.Style = []
      ParentFont = False
    end
    object cbxBaud: TComboBox
      Left = 109
      Top = 26
      Width = 193
      Height = 25
      Style = csDropDownList
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = #47569#51008' '#44256#46357
      Font.Style = []
      ImeName = #54620#44397#50612'('#54620#44544')'
      ParentFont = False
      TabOrder = 0
      OnChange = cbxBaudChange
      Items.Strings = (
        '300'
        '600'
        '1200'
        '2400'
        '4800'
        '9600'
        '19200')
    end
    object cbxDataBit: TComboBox
      Left = 109
      Top = 59
      Width = 193
      Height = 25
      Style = csDropDownList
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = #47569#51008' '#44256#46357
      Font.Style = []
      ImeName = #54620#44397#50612'('#54620#44544')'
      ParentFont = False
      TabOrder = 1
      OnChange = cbxBaudChange
      Items.Strings = (
        '4'
        '5'
        '6'
        '7'
        '8')
    end
    object cbxParity: TComboBox
      Left = 109
      Top = 91
      Width = 193
      Height = 25
      Style = csDropDownList
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = #47569#51008' '#44256#46357
      Font.Style = []
      ImeName = #54620#44397#50612'('#54620#44544')'
      ParentFont = False
      TabOrder = 2
      OnChange = cbxBaudChange
      Items.Strings = (
        'even'
        'odd'
        'none')
    end
    object cbxStop: TComboBox
      Left = 109
      Top = 124
      Width = 193
      Height = 25
      Style = csDropDownList
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = #47569#51008' '#44256#46357
      Font.Style = []
      ImeName = #54620#44397#50612'('#54620#44544')'
      ParentFont = False
      TabOrder = 3
      OnChange = cbxBaudChange
      Items.Strings = (
        '1'
        '1.5'
        '2')
    end
    object cbxFlow: TComboBox
      Left = 109
      Top = 155
      Width = 193
      Height = 25
      Style = csDropDownList
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = #47569#51008' '#44256#46357
      Font.Style = []
      ImeName = #54620#44397#50612'('#54620#44544')'
      ParentFont = False
      TabOrder = 4
      OnChange = cbxBaudChange
      Items.Strings = (
        '1'
        '1.5'
        '2')
    end
  end
  object bbtnCancel: TBitBtn
    Left = 279
    Top = 270
    Width = 92
    Height = 27
    Caption = 'Cancel(&C)'
    Font.Charset = HANGEUL_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = #47569#51008' '#44256#46357
    Font.Style = []
    Kind = bkCancel
    ParentFont = False
    TabOrder = 1
  end
  object bbtnOK: TBitBtn
    Left = 185
    Top = 270
    Width = 92
    Height = 27
    Caption = 'OK(&O)'
    Font.Charset = HANGEUL_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = #47569#51008' '#44256#46357
    Font.Style = []
    Kind = bkOK
    ParentFont = False
    TabOrder = 2
    OnClick = bbtnOKClick
  end
  object bbtnApply: TBitBtn
    Left = 93
    Top = 270
    Width = 92
    Height = 27
    Caption = 'Apply(&A)'
    Font.Charset = HANGEUL_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = #47569#51008' '#44256#46357
    Font.Style = []
    ParentFont = False
    TabOrder = 3
    OnClick = bbtnApplyClick
  end
end
