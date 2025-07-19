object frmCanOper: TfrmCanOper
  Left = 0
  Top = 0
  Caption = 'frmCanOper'
  ClientHeight = 588
  ClientWidth = 1091
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 1091
    Height = 588
    Align = alClient
    BevelOuter = bvLowered
    Color = 15593457
    Font.Charset = HANGEUL_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #47569#51008' '#44256#46357
    Font.Style = []
    ParentBackground = False
    ParentFont = False
    TabOrder = 0
    object btnCanWrite: TSpeedButton
      Tag = 1
      Left = 40
      Top = 168
      Width = 121
      Height = 32
      Caption = #51204#49569'('#54788' '#46972#51064')'
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = #47569#51008' '#44256#46357
      Font.Style = []
      ParentFont = False
      OnClick = btnCanWriteClick
    end
    object btnLoadFrames: TSpeedButton
      Tag = 1
      Left = 215
      Top = 168
      Width = 101
      Height = 32
      Caption = 'LOAD'
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = #47569#51008' '#44256#46357
      Font.Style = []
      ParentFont = False
      OnClick = btnLoadFramesClick
    end
    object btnSaveFrames: TSpeedButton
      Tag = 1
      Left = 322
      Top = 168
      Width = 101
      Height = 32
      Caption = 'SAVE'
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = #47569#51008' '#44256#46357
      Font.Style = []
      ParentFont = False
      OnClick = btnSaveFramesClick
    end
    object Shape3: TShape
      Left = 40
      Top = 217
      Width = 379
      Height = 1
      Brush.Color = clBlack
    end
    object btnUnRWIDApply: TSpeedButton
      Tag = 1
      Left = 40
      Top = 498
      Width = 379
      Height = 32
      Caption = #48120#54364#49884' R/W ID '#51201#50857
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clRed
      Font.Height = -13
      Font.Name = #47569#51008' '#44256#46357
      Font.Style = []
      ParentFont = False
      OnClick = btnUnRWIDApplyClick
    end
    object lblUnusedRIDs: TLabel
      Left = 41
      Top = 383
      Width = 101
      Height = 17
      Caption = #48120#54364#49884' READ IDs'
    end
    object lblUnusedWIDs: TLabel
      Left = 241
      Top = 383
      Width = 106
      Height = 17
      Caption = #48120#54364#49884' WRITE IDs'
    end
    object lblRead: TLabel
      Tag = 222
      Left = 40
      Top = 227
      Width = 79
      Height = 15
      Alignment = taRightJustify
      Caption = #54364#49884' READ IDs'
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = #47569#51008' '#44256#46357
      Font.Style = []
      ParentFont = False
    end
    object lblWrite: TLabel
      Tag = 222
      Left = 240
      Top = 227
      Width = 82
      Height = 15
      Alignment = taRightJustify
      Caption = #54364#49884' WRITE IDs'
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = #47569#51008' '#44256#46357
      Font.Style = []
      ParentFont = False
    end
    object btnUsedRWIDApply: TSpeedButton
      Tag = 1
      Left = 40
      Top = 338
      Width = 379
      Height = 32
      Caption = #54364#49884' R/W ID '#51201#50857
      Font.Charset = HANGEUL_CHARSET
      Font.Color = 10485760
      Font.Height = -13
      Font.Name = #47569#51008' '#44256#46357
      Font.Style = []
      ParentFont = False
      OnClick = btnUsedRWIDApplyClick
    end
    object btnSaveEnv: TSpeedButton
      Tag = 1
      Left = 452
      Top = 498
      Width = 150
      Height = 32
      Caption = #47700#49884#51648' ID '#47784#46160' '#51200#51109
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clGreen
      Font.Height = -13
      Font.Name = #47569#51008' '#44256#46357
      Font.Style = []
      ParentFont = False
      OnClick = btnSaveEnvClick
    end
    object lblRef: TLabel
      Left = 452
      Top = 249
      Width = 114
      Height = 108
      Caption = 'R: $752'#13#10#13#10'W: $75A, $3FB, $3FC'#13#10#13#10#13#10#13#10#13#10#10
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clGray
      Font.Height = -12
      Font.Name = #44404#47548#52404
      Font.Style = []
      ParentFont = False
    end
    object mmoCanFrames: TMemo
      Left = 40
      Top = 22
      Width = 379
      Height = 108
      BevelInner = bvNone
      BevelOuter = bvRaised
      Color = 15925247
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = #44404#47548#52404
      Font.Style = []
      ParentFont = False
      TabOrder = 0
    end
    object chkAllFrames: TCheckBox
      Left = 40
      Top = 145
      Width = 105
      Height = 17
      Caption = #47784#46304' FRAME'
      TabOrder = 1
    end
    object mmoUnusedRIDs: TMemo
      Left = 40
      Top = 404
      Width = 179
      Height = 88
      BevelInner = bvNone
      BevelOuter = bvRaised
      Color = 16777200
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = #44404#47548#52404
      Font.Style = []
      ParentFont = False
      TabOrder = 2
    end
    object mmoUnusedWIDs: TMemo
      Left = 240
      Top = 404
      Width = 179
      Height = 88
      BevelInner = bvNone
      BevelOuter = bvRaised
      Color = 15397375
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = #44404#47548#52404
      Font.Style = []
      ParentFont = False
      TabOrder = 3
    end
    object mmoUsedWIDs: TMemo
      Left = 240
      Top = 245
      Width = 179
      Height = 88
      BevelInner = bvNone
      BevelOuter = bvRaised
      Color = 15397375
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = #44404#47548#52404
      Font.Style = []
      ParentFont = False
      TabOrder = 4
    end
    object mmoUsedRIDs: TMemo
      Left = 40
      Top = 245
      Width = 179
      Height = 88
      BevelInner = bvNone
      BevelOuter = bvRaised
      Color = 16777200
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = #44404#47548#52404
      Font.Style = []
      ParentFont = False
      TabOrder = 5
    end
    object GroupBox12: TGroupBox
      Left = 636
      Top = 38
      Width = 192
      Height = 264
      Caption = 'LIMIT(New UDS)'
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = #47569#51008' '#44256#46357
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 6
      Visible = False
      object btnLimitSet: TSpeedButton
        Tag = 1
        Left = 12
        Top = 33
        Width = 82
        Height = 32
        Caption = 'SLIDE '#49444#51221
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #47569#51008' '#44256#46357
        Font.Style = []
        ParentFont = False
      end
      object btnLimitClear: TSpeedButton
        Tag = 1
        Left = 100
        Top = 33
        Width = 82
        Height = 32
        Caption = 'SLIDE '#49325#51228
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #47569#51008' '#44256#46357
        Font.Style = []
        ParentFont = False
      end
      object SpeedButton13: TSpeedButton
        Tag = 3
        Left = 12
        Top = 76
        Width = 82
        Height = 32
        Caption = 'TILT '#49444#51221
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #47569#51008' '#44256#46357
        Font.Style = []
        ParentFont = False
      end
      object SpeedButton14: TSpeedButton
        Tag = 3
        Left = 100
        Top = 76
        Width = 82
        Height = 32
        Caption = 'TILT '#49325#51228
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #47569#51008' '#44256#46357
        Font.Style = []
        ParentFont = False
      end
      object SpeedButton15: TSpeedButton
        Tag = 4
        Left = 12
        Top = 118
        Width = 82
        Height = 32
        Caption = 'HGT '#49444#51221
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #47569#51008' '#44256#46357
        Font.Style = []
        ParentFont = False
      end
      object SpeedButton16: TSpeedButton
        Tag = 4
        Left = 100
        Top = 118
        Width = 82
        Height = 32
        Caption = 'HGT '#49325#51228
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #47569#51008' '#44256#46357
        Font.Style = []
        ParentFont = False
      end
      object SpeedButton17: TSpeedButton
        Tag = 6
        Left = 12
        Top = 161
        Width = 82
        Height = 32
        Caption = 'EXT '#49444#51221
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #47569#51008' '#44256#46357
        Font.Style = []
        ParentFont = False
      end
      object SpeedButton18: TSpeedButton
        Tag = 6
        Left = 100
        Top = 161
        Width = 82
        Height = 32
        Caption = 'EXT '#49325#51228
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #47569#51008' '#44256#46357
        Font.Style = []
        ParentFont = False
      end
      object SpeedButton12: TSpeedButton
        Left = 12
        Top = 214
        Width = 82
        Height = 32
        Caption = #51204#52404' '#49444#51221
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #47569#51008' '#44256#46357
        Font.Style = []
        ParentFont = False
      end
      object SpeedButton19: TSpeedButton
        Left = 100
        Top = 214
        Width = 82
        Height = 32
        Caption = #51204#52404' '#49325#51228
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #47569#51008' '#44256#46357
        Font.Style = []
        ParentFont = False
      end
    end
  end
  object dlgOpen: TOpenDialog
    DefaultExt = 'txt'
    Filter = 'Can Text|*.txt'
    Left = 960
    Top = 480
  end
  object dlgSave: TSaveDialog
    DefaultExt = 'txt'
    Filter = 'Can Text|*.txt'
    Left = 1000
    Top = 480
  end
end
