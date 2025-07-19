object frmComsForm: TfrmComsForm
  Left = 696
  Top = 136
  BorderStyle = bsSingle
  Caption = #46356#48148#51060#49828' '#53685#49888#54252#53944' '#44288#47532
  ClientHeight = 608
  ClientWidth = 630
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #44404#47548
  Font.Style = []
  OldCreateOrder = False
  WindowState = wsMaximized
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnlPortManager: TPanel
    Left = 8
    Top = 8
    Width = 585
    Height = 283
    BevelOuter = bvNone
    BorderStyle = bsSingle
    Color = 15593457
    Ctl3D = False
    ParentBackground = False
    ParentCtl3D = False
    TabOrder = 0
    object Label1: TLabel
      Left = 18
      Top = 31
      Width = 150
      Height = 13
      Caption = #46356#48148#51060#49828' '#53685#49888#54252#53944' '#44288#47532
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = #44404#47548
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Shape10: TShape
      Left = 18
      Top = 16
      Width = 538
      Height = 5
      Brush.Color = clBlack
    end
    object Shape11: TShape
      Left = 18
      Top = 53
      Width = 538
      Height = 1
      Brush.Color = clBlack
    end
    object Label3: TLabel
      Tag = 10
      Left = 165
      Top = 81
      Width = 36
      Height = 13
      Alignment = taRightJustify
      Caption = 'XXXX'
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = #44404#47548
      Font.Style = [fsBold]
      ParentFont = False
      Visible = False
    end
    object Label4: TLabel
      Tag = 20
      Left = 165
      Top = 113
      Width = 36
      Height = 13
      Alignment = taRightJustify
      Caption = 'XXXX'
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = #44404#47548
      Font.Style = [fsBold]
      ParentFont = False
      Visible = False
    end
    object Shape1: TShape
      Left = 18
      Top = 248
      Width = 538
      Height = 5
      Brush.Color = clBlack
    end
    object Label2: TLabel
      Tag = 30
      Left = 165
      Top = 145
      Width = 36
      Height = 13
      Alignment = taRightJustify
      Caption = 'XXXX'
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = #44404#47548
      Font.Style = [fsBold]
      ParentFont = False
      Visible = False
    end
    object Label5: TLabel
      Tag = 40
      Left = 165
      Top = 175
      Width = 36
      Height = 13
      Alignment = taRightJustify
      Caption = 'XXXX'
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = #44404#47548
      Font.Style = [fsBold]
      ParentFont = False
      Visible = False
    end
    object ComboBox3: TComboBox
      Left = 210
      Top = 78
      Width = 191
      Height = 21
      Style = csDropDownList
      ImeName = 'Microsoft IME 2003'
      TabOrder = 0
      Visible = False
      OnChange = ComboBox0Change
    end
    object ComboBox4: TComboBox
      Tag = 1
      Left = 210
      Top = 107
      Width = 191
      Height = 21
      Style = csDropDownList
      ImeName = 'Microsoft IME 2003'
      TabOrder = 1
      Visible = False
      OnChange = ComboBox0Change
    end
    object ComboBox1: TComboBox
      Tag = 2
      Left = 210
      Top = 137
      Width = 191
      Height = 21
      Style = csDropDownList
      ImeName = 'Microsoft IME 2003'
      TabOrder = 2
      Visible = False
      OnChange = ComboBox0Change
    end
    object ComboBox2: TComboBox
      Tag = 3
      Left = 210
      Top = 169
      Width = 191
      Height = 21
      Style = csDropDownList
      ImeName = 'Microsoft IME 2003'
      TabOrder = 3
      Visible = False
      OnChange = ComboBox0Change
    end
  end
end
