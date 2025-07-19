object frmEdit: TfrmEdit
  Left = 266
  Top = 119
  BorderIcons = [biSystemMenu]
  Caption = 'Model'
  ClientHeight = 902
  ClientWidth = 737
  Color = clBtnFace
  Font.Charset = HANGEUL_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #44404#47548
  Font.Style = []
  OldCreateOrder = False
  Position = poDefault
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 737
    Height = 902
    Align = alClient
    BevelOuter = bvNone
    BorderStyle = bsSingle
    Color = 15593457
    Ctl3D = False
    Font.Charset = HANGEUL_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #47569#51008' '#44256#46357
    Font.Style = []
    ParentBackground = False
    ParentCtl3D = False
    ParentFont = False
    TabOrder = 0
    object Shape3: TShape
      Left = 8
      Top = 12
      Width = 700
      Height = 5
      Brush.Color = clBlack
    end
    object Label2: TLabel
      Left = 63
      Top = 65
      Width = 33
      Height = 16
      Alignment = taRightJustify
      Caption = #47784#45944#47749
      FocusControl = edtPartName
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object Shape6: TShape
      Left = 8
      Top = 50
      Width = 700
      Height = 1
      Brush.Color = clBlack
    end
    object labPartName: TLabel
      Left = 16
      Top = 25
      Width = 74
      Height = 16
      Caption = #47784#45944' '#51221#48372
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = #44404#47548
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Shape7: TShape
      Left = 12
      Top = 98
      Width = 700
      Height = 2
      Brush.Color = clBlack
    end
    object labIndex: TLabel
      Left = 657
      Top = 20
      Width = 49
      Height = 27
      Alignment = taCenter
      AutoSize = False
      Caption = '01'
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clWindowText
      Font.Height = -27
      Font.Name = #44404#47548
      Font.Style = [fsBold]
      ParentFont = False
      Layout = tlCenter
    end
    object edtPartName: TEdit
      Left = 106
      Top = 64
      Width = 550
      Height = 19
      Ctl3D = False
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = #44404#47548
      Font.Style = []
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      MaxLength = 62
      ParentCtl3D = False
      ParentFont = False
      TabOrder = 0
      OnChange = OnSaveBtnActive
    end
    object GroupBox1: TGroupBox
      Left = 957
      Top = 432
      Width = 653
      Height = 117
      Caption = #49548#51020' '#44160#49324'(&E)'
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = #44404#47548
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 4
      Visible = False
      object Label6: TLabel
        Left = 59
        Top = 34
        Width = 127
        Height = 13
        Alignment = taRightJustify
        Caption = #51089#46041' '#49548#51020' '#44160#49324' '#44592#51456
      end
      object Label9: TLabel
        Left = 335
        Top = 34
        Width = 74
        Height = 13
        Caption = '( dB '#51060#54616' )'
      end
      object Label49: TLabel
        Left = 436
        Top = 34
        Width = 39
        Height = 13
        Alignment = taRightJustify
        Caption = 'offset'
        Visible = False
      end
      object Label50: TLabel
        Left = 482
        Top = 15
        Width = 25
        Height = 13
        Caption = '#12'
        Visible = False
      end
      object Label51: TLabel
        Left = 547
        Top = 15
        Width = 25
        Height = 13
        Caption = '#13'
        Visible = False
      end
      object Label58: TLabel
        Left = 36
        Top = 63
        Width = 150
        Height = 13
        Alignment = taRightJustify
        Caption = #52488#44592#51089#46041' '#49548#51020' '#52769#51221#44396#44036
      end
      object Label59: TLabel
        Left = 335
        Top = 63
        Width = 69
        Height = 13
        Caption = '( '#52488' '#44620#51648' )'
      end
      object Label61: TLabel
        Left = 36
        Top = 86
        Width = 150
        Height = 13
        Alignment = taRightJustify
        Caption = #52488#44592#51089#46041' '#49548#51020' '#44160#49324#44592#51456
      end
      object Label62: TLabel
        Left = 335
        Top = 86
        Width = 74
        Height = 13
        Caption = '( dB '#51060#54616' )'
      end
      object Label63: TLabel
        Left = 436
        Top = 86
        Width = 39
        Height = 13
        Alignment = taRightJustify
        Caption = 'offset'
        Visible = False
      end
      object edtNoiseRunning: TEdit
        Left = 190
        Top = 31
        Width = 141
        Height = 19
        Ctl3D = False
        ImeName = 'Microsoft IME 2003'
        ParentCtl3D = False
        TabOrder = 0
      end
      object edtOffsetNoiseRunning0: TEdit
        Left = 480
        Top = 31
        Width = 62
        Height = 19
        Ctl3D = False
        ImeName = 'Microsoft IME 2003'
        ParentCtl3D = False
        TabOrder = 1
        Text = 'edtLeverOffsetAngleRH'
        Visible = False
      end
      object edtOffsetNoiseRunning1: TEdit
        Left = 545
        Top = 31
        Width = 62
        Height = 19
        Ctl3D = False
        ImeName = 'Microsoft IME 2003'
        ParentCtl3D = False
        TabOrder = 2
        Text = 'edtLeverOffsetAngleRH'
        Visible = False
      end
      object edtNoiseInitTime: TEdit
        Left = 190
        Top = 60
        Width = 141
        Height = 19
        Ctl3D = False
        ImeName = 'Microsoft IME 2003'
        ParentCtl3D = False
        TabOrder = 3
      end
      object edtNoiseInitMax: TEdit
        Left = 190
        Top = 83
        Width = 141
        Height = 19
        Ctl3D = False
        ImeName = 'Microsoft IME 2003'
        ParentCtl3D = False
        TabOrder = 4
      end
      object edtOffsetNoiseInit0: TEdit
        Left = 480
        Top = 83
        Width = 62
        Height = 19
        Ctl3D = False
        ImeName = 'Microsoft IME 2003'
        ParentCtl3D = False
        TabOrder = 5
        Text = 'edtLeverOffsetAngleRH'
        Visible = False
      end
      object edtOffsetNoiseInit1: TEdit
        Left = 545
        Top = 83
        Width = 62
        Height = 19
        Ctl3D = False
        ImeName = 'Microsoft IME 2003'
        ParentCtl3D = False
        TabOrder = 6
        Text = 'edtLeverOffsetAngleRH'
        Visible = False
      end
    end
    object pcMdl: TPageControl
      Left = 0
      Top = 230
      Width = 735
      Height = 670
      ActivePage = TabSheet1
      Align = alBottom
      Style = tsFlatButtons
      TabOrder = 3
      TabWidth = 135
      object TabSheet1: TTabSheet
        Caption = #44160#49324' '#49444#51221
        object gbxAlign: TGroupBox
          Left = 20
          Top = 12
          Width = 684
          Height = 657
          Caption = #47784#53552' '#51221#47148' '#49444#51221
          Ctl3D = False
          Font.Charset = HANGEUL_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = #47569#51008' '#44256#46357
          Font.Style = []
          ParentCtl3D = False
          ParentFont = False
          TabOrder = 0
          inline fmSlide: TAlignSpecFrme
            Left = 1
            Top = 18
            Width = 682
            Height = 100
            Align = alTop
            TabOrder = 0
            ExplicitLeft = 1
            ExplicitTop = 18
            ExplicitWidth = 682
            inherited pnlClient: TPanel
              Width = 682
              ExplicitWidth = 682
              inherited pnlDatas: TPanel
                inherited pnlMotorDatas: TPanel
                  ExplicitLeft = 0
                  ExplicitTop = 0
                end
                inherited pnlAlignDatas: TPanel
                  inherited edtMoveTime: TEdit
                    Height = 19
                    ExplicitHeight = 19
                  end
                end
              end
            end
          end
          inline fmShoulder: TAlignSpecFrme
            Left = 1
            Top = 518
            Width = 682
            Height = 100
            Align = alTop
            TabOrder = 1
            ExplicitLeft = 1
            ExplicitTop = 518
            ExplicitWidth = 682
            inherited pnlClient: TPanel
              Width = 682
              ExplicitWidth = 682
              inherited pnlDatas: TPanel
                inherited pnlMotorDatas: TPanel
                  ExplicitLeft = 0
                  ExplicitTop = 0
                end
                inherited pnlAlignDatas: TPanel
                  inherited edtMoveTime: TEdit
                    Height = 19
                    ExplicitHeight = 19
                  end
                end
              end
            end
          end
          inline fmRecl: TAlignSpecFrme
            Left = 1
            Top = 318
            Width = 682
            Height = 100
            Align = alTop
            TabOrder = 2
            ExplicitLeft = 1
            ExplicitTop = 318
            ExplicitWidth = 682
            inherited pnlClient: TPanel
              Width = 682
              ExplicitWidth = 682
              inherited pnlDatas: TPanel
                inherited pnlMotorDatas: TPanel
                  ExplicitLeft = 0
                  ExplicitTop = 0
                end
                inherited pnlAlignDatas: TPanel
                  inherited edtMoveTime: TEdit
                    Height = 19
                    ExplicitHeight = 19
                  end
                end
              end
            end
          end
          inline fmWalkinTilt: TAlignSpecFrme
            Left = 1
            Top = 218
            Width = 682
            Height = 100
            Align = alTop
            TabOrder = 3
            ExplicitLeft = 1
            ExplicitTop = 218
            ExplicitWidth = 682
            inherited pnlClient: TPanel
              Width = 682
              ExplicitWidth = 682
              inherited pnlDatas: TPanel
                inherited pnlMotorDatas: TPanel
                  ExplicitLeft = 0
                  ExplicitTop = 0
                end
                inherited pnlAlignDatas: TPanel
                  inherited edtMoveTime: TEdit
                    Height = 19
                    ExplicitHeight = 19
                  end
                end
              end
            end
          end
          inline fmCushTilt: TAlignSpecFrme
            Left = 1
            Top = 118
            Width = 682
            Height = 100
            Align = alTop
            TabOrder = 4
            ExplicitLeft = 1
            ExplicitTop = 118
            ExplicitWidth = 682
            inherited pnlClient: TPanel
              Width = 682
              ExplicitWidth = 682
              inherited pnlDatas: TPanel
                inherited pnlMotorDatas: TPanel
                  ExplicitLeft = 0
                  ExplicitTop = 0
                end
                inherited pnlAlignDatas: TPanel
                  inherited edtMoveTime: TEdit
                    Height = 19
                    ExplicitHeight = 19
                  end
                end
              end
            end
          end
          inline fmRelax: TAlignSpecFrme
            Left = 1
            Top = 418
            Width = 682
            Height = 100
            Align = alTop
            TabOrder = 5
            ExplicitLeft = 1
            ExplicitTop = 418
            ExplicitWidth = 682
            inherited pnlClient: TPanel
              Width = 682
              ExplicitWidth = 682
              inherited pnlDatas: TPanel
                inherited pnlMotorDatas: TPanel
                  ExplicitLeft = 0
                  ExplicitTop = 0
                end
                inherited pnlAlignDatas: TPanel
                  inherited edtMoveTime: TEdit
                    Height = 19
                    ExplicitHeight = 19
                  end
                end
              end
            end
          end
        end
      end
    end
    object rdgCar: TRadioGroup
      Left = 16
      Top = 112
      Width = 140
      Height = 54
      Caption = 'CAR'
      Columns = 2
      Ctl3D = False
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = #47569#51008' '#44256#46357
      Font.Style = []
      ItemIndex = 0
      Items.Strings = (
        'JG1'
        'SP1')
      ParentCtl3D = False
      ParentFont = False
      TabOrder = 1
      OnClick = OnSaveBtnActive
    end
    object rdgPos: TRadioGroup
      Left = 577
      Top = 112
      Width = 140
      Height = 54
      Caption = 'POS'
      Columns = 2
      Ctl3D = False
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = #47569#51008' '#44256#46357
      Font.Style = []
      ItemIndex = 0
      Items.Strings = (
        'LH'
        'RH')
      ParentCtl3D = False
      ParentFont = False
      TabOrder = 2
      OnClick = OnSaveBtnActive
    end
    object rdgCarTrim: TRadioGroup
      Left = 178
      Top = 113
      Width = 140
      Height = 54
      Caption = 'TRIM'
      Columns = 2
      Ctl3D = False
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = #47569#51008' '#44256#46357
      Font.Style = []
      ItemIndex = 0
      Items.Strings = (
        'SE'
        'STD')
      ParentCtl3D = False
      ParentFont = False
      TabOrder = 5
      OnClick = OnSaveBtnActive
    end
    object rdgSeats: TRadioGroup
      Left = 339
      Top = 112
      Width = 216
      Height = 54
      Caption = 'SEATS'
      Columns = 4
      Ctl3D = False
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = #47569#51008' '#44256#46357
      Font.Style = []
      ItemIndex = 0
      Items.Strings = (
        '4P'
        '5P'
        '6P'
        '7P')
      ParentCtl3D = False
      ParentFont = False
      TabOrder = 6
      OnClick = OnSaveBtnActive
    end
  end
end
