object frmCanCtrl: TfrmCanCtrl
  Left = 0
  Top = 0
  ClientHeight = 712
  ClientWidth = 927
  Color = clBtnFace
  DragKind = dkDock
  DragMode = dmAutomatic
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 16
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 927
    Height = 337
    Align = alTop
    TabOrder = 0
    object Label25: TLabel
      Left = 1
      Top = 1
      Width = 925
      Height = 30
      Align = alTop
      AutoSize = False
      Caption = ' WRITE  CAN FRAME'
      Color = 5453356
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentColor = False
      ParentFont = False
      Transparent = False
      Layout = tlCenter
      ExplicitWidth = 673
    end
    object lblBitOrdV1: TLabel
      Left = 108
      Top = 309
      Width = 83
      Height = 18
      AutoSize = False
      Caption = #44036#44201' (msec)'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = #44404#47548
      Font.Style = []
      ParentFont = False
      Layout = tlCenter
    end
    object Label2: TLabel
      Left = 108
      Top = 285
      Width = 50
      Height = 18
      AutoSize = False
      Caption = 'ID (Hex)'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = #44404#47548
      Font.Style = []
      ParentFont = False
      Layout = tlCenter
    end
    inline cfmWFrame: TCanFrameMatrix
      Left = 7
      Top = 47
      Width = 293
      Height = 224
      Color = clBtnFace
      Ctl3D = False
      ParentBackground = False
      ParentColor = False
      ParentCtl3D = False
      TabOrder = 0
      ExplicitLeft = 7
      ExplicitTop = 47
      ExplicitHeight = 224
      inherited Panel1: TPanel
        inherited edtData1: TEdit
          ExplicitHeight = 22
        end
      end
      inherited Panel2: TPanel
        inherited edtData6: TEdit
          ExplicitHeight = 22
        end
      end
      inherited Panel3: TPanel
        inherited edtData5: TEdit
          ExplicitHeight = 22
        end
      end
      inherited Panel4: TPanel
        inherited edtData4: TEdit
          ExplicitHeight = 22
        end
      end
      inherited Panel5: TPanel
        inherited edtData3: TEdit
          ExplicitHeight = 22
        end
      end
      inherited Panel6: TPanel
        inherited edtData2: TEdit
          ExplicitHeight = 22
        end
      end
      inherited Panel7: TPanel
        inherited edtData8: TEdit
          ExplicitHeight = 22
        end
      end
      inherited Panel8: TPanel
        inherited edtData7: TEdit
          ExplicitHeight = 22
        end
      end
    end
    object btnSend: TButton
      Left = 197
      Top = 280
      Width = 100
      Height = 41
      Caption = '1'#54924' '#51204#49569
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = #47569#51008' '#44256#46357
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      OnClick = btnSendClick
    end
    object edtWID: TEdit
      Left = 10
      Top = 280
      Width = 92
      Height = 24
      Color = 13828095
      TabOrder = 2
    end
    object edtWInterval: TEdit
      Left = 10
      Top = 305
      Width = 92
      Height = 24
      TabOrder = 3
      Text = '200'
    end
    object PageControl1: TPageControl
      Left = 306
      Top = 38
      Width = 604
      Height = 309
      ActivePage = TabSheet2
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = #47569#51008' '#44256#46357
      Font.Style = []
      ParentFont = False
      Style = tsFlatButtons
      TabOrder = 4
      TabWidth = 140
      object TabSheet2: TTabSheet
        Caption = #49688#46041' '#51204#49569
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #47569#51008' '#44256#46357
        Font.Style = []
        ImageIndex = 1
        ParentFont = False
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        object lblBitOrdH: TLabel
          Left = 0
          Top = 177
          Width = 596
          Height = 16
          Align = alTop
          AutoSize = False
          Caption = #8251'  '#45908#48660#53364#47533#49884' 1'#54924' '#51204#49569
          Font.Charset = ANSI_CHARSET
          Font.Color = clBlue
          Font.Height = -12
          Font.Name = #44404#47548
          Font.Style = []
          ParentFont = False
          Layout = tlCenter
          ExplicitLeft = -4
          ExplicitTop = 199
        end
        object lbWFrame: TListBox
          Left = 0
          Top = 0
          Width = 596
          Height = 177
          Align = alTop
          ItemHeight = 17
          TabOrder = 0
          OnClick = lbWFrameClick
          OnDblClick = lbWFrameDblClick
        end
        object btnAddWID: TButton
          Left = 0
          Top = 213
          Width = 100
          Height = 41
          Caption = #52628#44032
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = #47569#51008' '#44256#46357
          Font.Style = []
          ParentFont = False
          TabOrder = 1
          OnClick = btnAddWIDClick
        end
        object btnRemoveWID: TButton
          Left = 106
          Top = 213
          Width = 100
          Height = 41
          Caption = #51228#44144
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = #47569#51008' '#44256#46357
          Font.Style = []
          ParentFont = False
          TabOrder = 2
          OnClick = btnRemoveWIDClick
        end
        object btnRemoveAllWID: TButton
          Left = 211
          Top = 213
          Width = 100
          Height = 41
          Caption = #47784#46160' '#51228#44144
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = #47569#51008' '#44256#46357
          Font.Style = []
          ParentFont = False
          TabOrder = 3
          OnClick = btnRemoveAllWIDClick
        end
      end
      object TabSheet1: TTabSheet
        Caption = #50672#49549' '#51088#46041' '#51204#49569
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = #47569#51008' '#44256#46357
        Font.Style = []
        ParentFont = False
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        object lbCyWFrame: TListBox
          Left = 0
          Top = 0
          Width = 596
          Height = 192
          Align = alTop
          Color = 15663103
          ItemHeight = 15
          TabOrder = 0
          OnClick = lbCyWFrameClick
        end
        object btnAddCyWID: TButton
          Left = 3
          Top = 201
          Width = 100
          Height = 41
          Caption = #52628#44032
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = #47569#51008' '#44256#46357
          Font.Style = []
          ParentFont = False
          TabOrder = 1
          OnClick = btnAddCyWIDClick
        end
        object btnRemoveCyWID: TButton
          Left = 107
          Top = 201
          Width = 100
          Height = 41
          Caption = #51228#44144
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = #47569#51008' '#44256#46357
          Font.Style = []
          ParentFont = False
          TabOrder = 2
          OnClick = btnRemoveCyWIDClick
        end
        object btnRemoveAllCyWID: TButton
          Left = 211
          Top = 201
          Width = 100
          Height = 41
          Caption = #47784#46160' '#51228#44144
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = #47569#51008' '#44256#46357
          Font.Style = []
          ParentFont = False
          TabOrder = 3
          OnClick = btnRemoveAllCyWIDClick
        end
      end
    end
    object cbxWDebugMode: TCheckBox
      Tag = 222
      Left = 176
      Top = 8
      Width = 131
      Height = 17
      Caption = 'Debug Mode'
      Ctl3D = False
      Font.Charset = ANSI_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentCtl3D = False
      ParentFont = False
      TabOrder = 5
      OnClick = cbxWDebugModeClick
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 337
    Width = 927
    Height = 313
    Align = alTop
    TabOrder = 1
    object Label1: TLabel
      Left = 1
      Top = 1
      Width = 925
      Height = 30
      Align = alTop
      AutoSize = False
      Caption = ' READ  CAN FRAME'
      Color = 5453356
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentColor = False
      ParentFont = False
      Transparent = False
      Layout = tlCenter
      ExplicitWidth = 673
    end
    object Label3: TLabel
      Left = 108
      Top = 277
      Width = 50
      Height = 18
      AutoSize = False
      Caption = 'ID (Hex)'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = #44404#47548
      Font.Style = []
      ParentFont = False
      Layout = tlCenter
    end
    inline cfmRFrame: TCanFrameMatrix
      Left = 4
      Top = 34
      Width = 293
      Height = 232
      Color = clBtnFace
      Ctl3D = False
      ParentBackground = False
      ParentColor = False
      ParentCtl3D = False
      TabOrder = 0
      ExplicitLeft = 4
      ExplicitTop = 34
      ExplicitHeight = 232
      inherited Panel1: TPanel
        inherited edtData1: TEdit
          ExplicitHeight = 22
        end
      end
      inherited Panel2: TPanel
        inherited edtData6: TEdit
          ExplicitHeight = 22
        end
      end
      inherited Panel3: TPanel
        inherited edtData5: TEdit
          ExplicitHeight = 22
        end
      end
      inherited Panel4: TPanel
        inherited edtData4: TEdit
          ExplicitHeight = 22
        end
      end
      inherited Panel5: TPanel
        inherited edtData3: TEdit
          ExplicitHeight = 22
        end
      end
      inherited Panel6: TPanel
        inherited edtData2: TEdit
          ExplicitHeight = 22
        end
      end
      inherited Panel7: TPanel
        inherited edtData8: TEdit
          ExplicitHeight = 22
        end
      end
      inherited Panel8: TPanel
        inherited edtData7: TEdit
          ExplicitHeight = 22
        end
      end
    end
    object btnAddRAllID: TButton
      Left = 310
      Top = 265
      Width = 100
      Height = 41
      Caption = #49688#49888#46108' ID '#52628#44032
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = #47569#51008' '#44256#46357
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      OnClick = btnAddRAllIDClick
    end
    object btnRemoveAllRID: TButton
      Left = 521
      Top = 265
      Width = 100
      Height = 41
      Caption = #47784#46160' '#51228#44144
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = #47569#51008' '#44256#46357
      Font.Style = []
      ParentFont = False
      TabOrder = 2
      Visible = False
      OnClick = btnRemoveAllRIDClick
    end
    object edtRID: TEdit
      Left = 10
      Top = 272
      Width = 92
      Height = 24
      Color = 13828095
      TabOrder = 3
    end
    object lbRFrame: TListBox
      Left = 303
      Top = 53
      Width = 603
      Height = 192
      Color = 16121840
      DoubleBuffered = True
      ParentDoubleBuffered = False
      TabOrder = 4
      OnClick = lbRFrameClick
    end
    object btnRemoveRID: TButton
      Left = 416
      Top = 265
      Width = 100
      Height = 41
      Caption = #51228#44144
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = #47569#51008' '#44256#46357
      Font.Style = []
      ParentFont = False
      TabOrder = 5
      Visible = False
      OnClick = btnRemoveRIDClick
    end
    object cbxRDebugMode: TCheckBox
      Tag = 222
      Left = 176
      Top = 8
      Width = 131
      Height = 17
      Caption = 'Debug Mode'
      Ctl3D = False
      Font.Charset = ANSI_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentCtl3D = False
      ParentFont = False
      TabOrder = 6
      OnClick = cbxRDebugModeClick
    end
  end
  object lbLog: TListBox
    Left = 0
    Top = 687
    Width = 927
    Height = 25
    Align = alClient
    TabOrder = 2
  end
  object Panel3: TPanel
    Left = 0
    Top = 650
    Width = 927
    Height = 37
    Align = alTop
    TabOrder = 3
    DesignSize = (
      927
      37)
    object Label17: TLabel
      Tag = 1
      Left = 10
      Top = 9
      Width = 64
      Height = 17
      Alignment = taRightJustify
      Caption = 'CAN PORT'
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = #47569#51008' '#44256#46357
      Font.Style = []
      ParentFont = False
    end
    object cbxCanPort: TComboBox
      Left = 86
      Top = 5
      Width = 102
      Height = 25
      Style = csDropDownList
      Ctl3D = False
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = #47569#51008' '#44256#46357
      Font.Style = []
      ImeName = 'Microsoft IME 2003'
      ParentCtl3D = False
      ParentFont = False
      TabOrder = 0
      OnChange = cbxCanPortChange
    end
    object cbLogSave: TCheckBox
      Tag = 222
      Left = 849
      Top = 14
      Width = 61
      Height = 17
      Anchors = [akRight]
      Caption = 'Log '#51200#51109
      Ctl3D = False
      Font.Charset = ANSI_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentCtl3D = False
      ParentFont = False
      TabOrder = 1
      OnClick = cbLogSaveClick
    end
  end
  object tmrPoll: TTimer
    Enabled = False
    Interval = 100
    OnTimer = tmrPollTimer
    Left = 552
    Top = 496
  end
end
