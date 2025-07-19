object frmPasswd: TfrmPasswd
  Left = 876
  Top = 118
  BorderStyle = bsDialog
  Caption = 'PASSWORD'
  ClientHeight = 118
  ClientWidth = 360
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #44404#47548
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Shape1: TShape
    Left = 19
    Top = 46
    Width = 167
    Height = 23
    Brush.Style = bsClear
  end
  object Shape2: TShape
    Left = 18
    Top = 11
    Width = 167
    Height = 23
    Brush.Style = bsClear
  end
  object labPasswd: TLabel
    Left = 19
    Top = 12
    Width = 165
    Height = 21
    Alignment = taCenter
    AutoSize = False
    Caption = #48708#48128' '#48264#54840
    Color = 5329233
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -13
    Font.Name = #44404#47548
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
    Transparent = False
    Layout = tlCenter
  end
  object labNew: TLabel
    Left = 20
    Top = 47
    Width = 165
    Height = 21
    Alignment = taCenter
    AutoSize = False
    Caption = #49352' '#48708#48128' '#48264#54840
    Color = 5329233
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -13
    Font.Name = #44404#47548
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
    Transparent = False
    Layout = tlCenter
  end
  object edtPasswd: TEdit
    Left = 196
    Top = 11
    Width = 153
    Height = 21
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #44404#47548
    Font.Style = []
    ImeName = 'Microsoft Office IME 2007'
    MaxLength = 12
    ParentFont = False
    PasswordChar = '*'
    TabOrder = 0
    Text = 'edtPasswd'
    OnKeyDown = edtPasswdKeyDown
  end
  object edtNew: TEdit
    Left = 196
    Top = 45
    Width = 153
    Height = 21
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #44404#47548
    Font.Style = []
    ImeName = 'Microsoft Office IME 2007'
    MaxLength = 12
    ParentFont = False
    PasswordChar = '*'
    TabOrder = 1
    Text = 'edtPasswd'
    OnKeyDown = edtNewKeyDown
  end
  object pblPasswd: TPanel
    Left = 0
    Top = 77
    Width = 360
    Height = 41
    Align = alBottom
    ParentBackground = False
    TabOrder = 2
    object pgbTime: TProgressBar
      Left = 18
      Top = 16
      Width = 166
      Height = 11
      Max = 150
      Smooth = True
      TabOrder = 0
    end
    object bbtnChange: TBitBtn
      Left = 198
      Top = 9
      Width = 75
      Height = 25
      Caption = #54869#51064
      Default = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = #44404#47548
      Font.Style = [fsBold]
      Glyph.Data = {
        DE010000424DDE01000000000000760000002800000024000000120000000100
        0400000000006801000000000000000000001000000000000000000000000000
        80000080000000808000800000008000800080800000C0C0C000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
        3333333333333333333333330000333333333333333333333333F33333333333
        00003333344333333333333333388F3333333333000033334224333333333333
        338338F3333333330000333422224333333333333833338F3333333300003342
        222224333333333383333338F3333333000034222A22224333333338F338F333
        8F33333300003222A3A2224333333338F3838F338F33333300003A2A333A2224
        33333338F83338F338F33333000033A33333A222433333338333338F338F3333
        0000333333333A222433333333333338F338F33300003333333333A222433333
        333333338F338F33000033333333333A222433333333333338F338F300003333
        33333333A222433333333333338F338F00003333333333333A22433333333333
        3338F38F000033333333333333A223333333333333338F830000333333333333
        333A333333333333333338330000333333333333333333333333333333333333
        0000}
      NumGlyphs = 2
      ParentFont = False
      TabOrder = 1
      OnClick = bbtnChangeClick
    end
    object bbtnCancel: TBitBtn
      Left = 275
      Top = 9
      Width = 75
      Height = 25
      Caption = #52712#49548
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = #44404#47548
      Font.Style = [fsBold]
      Kind = bkCancel
      ParentFont = False
      TabOrder = 2
      OnClick = bbtnCancelClick
    end
  end
  object Timer: TTimer
    OnTimer = TimerTimer
  end
end
