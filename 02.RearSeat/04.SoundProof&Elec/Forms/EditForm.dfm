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
      TabOrder = 1
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
      Top = 225
      Width = 735
      Height = 675
      ActivePage = tsMotor2
      Align = alBottom
      Style = tsFlatButtons
      TabOrder = 0
      TabWidth = 135
      object tsMotor1: TTabSheet
        Caption = #47784#53552' '#44160#49324' '#49444#51221' 1'
        object GroupBox2: TGroupBox
          AlignWithMargins = True
          Left = 3
          Top = 3
          Width = 721
          Height = 634
          Align = alClient
          Caption = #47784#53552' '#49549#46020' '#48143' '#49548#51020' '#44160#49324
          Ctl3D = False
          Font.Charset = HANGEUL_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = #47569#51008' '#44256#46357
          Font.Style = []
          ParentCtl3D = False
          ParentFont = False
          TabOrder = 0
          ExplicitLeft = 20
          ExplicitTop = 1
          ExplicitWidth = 694
          ExplicitHeight = 631
          inline fmMtr_WalkinTilt: TMtrSpecFrame
            Left = 1
            Top = 402
            Width = 719
            Height = 192
            Align = alTop
            Ctl3D = False
            Font.Charset = ANSI_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = #47569#51008' '#44256#46357
            Font.Style = []
            ParentCtl3D = False
            ParentFont = False
            TabOrder = 0
            ExplicitLeft = 7
            ExplicitTop = 439
            inherited lblTitle: TLabel
              Width = 88
              Caption = 'WALKIN TILT'
              ExplicitWidth = 88
            end
          end
          inline fmMtr_CushTilt: TMtrSpecFrame
            Left = 1
            Top = 210
            Width = 719
            Height = 192
            Align = alTop
            Ctl3D = False
            Font.Charset = ANSI_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = #47569#51008' '#44256#46357
            Font.Style = []
            ParentCtl3D = False
            ParentFont = False
            TabOrder = 1
            ExplicitLeft = 7
            ExplicitTop = 439
            ExplicitWidth = 692
            inherited lblTitle: TLabel
              Width = 75
              Caption = 'CUSH TILT'
              ExplicitWidth = 75
            end
          end
          inline fmMtr_Slide: TMtrSpecFrame
            Left = 1
            Top = 18
            Width = 719
            Height = 192
            Align = alTop
            Ctl3D = False
            Font.Charset = ANSI_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = #47569#51008' '#44256#46357
            Font.Style = []
            ParentCtl3D = False
            ParentFont = False
            TabOrder = 2
            ExplicitLeft = 7
            ExplicitTop = 439
            ExplicitWidth = 692
            inherited lblTitle: TLabel
              Width = 41
              Caption = 'SLIDE'
              ExplicitWidth = 41
            end
          end
        end
      end
      object tsMotor2: TTabSheet
        Caption = #47784#53552' '#44160#49324' '#49444#51221' 2'
        ImageIndex = 5
        object GroupBox3: TGroupBox
          AlignWithMargins = True
          Left = 3
          Top = 3
          Width = 721
          Height = 634
          Align = alClient
          Caption = #47784#53552' '#49549#46020' '#48143' '#49548#51020' '#44160#49324
          Ctl3D = False
          Font.Charset = HANGEUL_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = #47569#51008' '#44256#46357
          Font.Style = []
          ParentCtl3D = False
          ParentFont = False
          TabOrder = 0
          ExplicitLeft = 17
          ExplicitTop = 2
          ExplicitWidth = 694
          ExplicitHeight = 631
          inline fmMtr_Shoulder: TMtrSpecFrame
            Left = 1
            Top = 402
            Width = 719
            Height = 192
            Align = alTop
            Ctl3D = False
            Font.Charset = ANSI_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = #47569#51008' '#44256#46357
            Font.Style = []
            ParentCtl3D = False
            ParentFont = False
            TabOrder = 0
            ExplicitLeft = 7
            ExplicitTop = 439
            ExplicitWidth = 692
            inherited lblTitle: TLabel
              Width = 78
              Caption = 'SHOULDER'
              ExplicitWidth = 78
            end
          end
          inline fmMtr_Relax: TMtrSpecFrame
            Left = 1
            Top = 210
            Width = 719
            Height = 192
            Align = alTop
            Ctl3D = False
            Font.Charset = ANSI_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = #47569#51008' '#44256#46357
            Font.Style = []
            ParentCtl3D = False
            ParentFont = False
            TabOrder = 1
            ExplicitLeft = 7
            ExplicitTop = 439
            ExplicitWidth = 692
            inherited lblTitle: TLabel
              Width = 45
              Caption = 'RELAX'
              ExplicitWidth = 45
            end
          end
          inline fmMtr_Recl: TMtrSpecFrame
            Left = 1
            Top = 18
            Width = 719
            Height = 192
            Align = alTop
            Ctl3D = False
            Font.Charset = ANSI_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = #47569#51008' '#44256#46357
            Font.Style = []
            ParentCtl3D = False
            ParentFont = False
            TabOrder = 2
            ExplicitLeft = 7
            ExplicitTop = 439
            ExplicitWidth = 692
            inherited lblTitle: TLabel
              Width = 60
              Caption = 'RECLINE'
              ExplicitWidth = 60
            end
          end
        end
      end
      object tsElec: TTabSheet
        Caption = #51204#51109' '#44160#49324' '#49444#51221
        ImageIndex = 1
        object GroupBox4: TGroupBox
          Left = 17
          Top = 2
          Width = 694
          Height = 631
          Caption = #55176#53552' '#53685#54413' '#48143' '#48260#53364' '#49444#51221
          Ctl3D = False
          Font.Charset = HANGEUL_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = #47569#51008' '#44256#46357
          Font.Style = []
          ParentCtl3D = False
          ParentFont = False
          TabOrder = 0
          object Panel5: TPanel
            Left = 1
            Top = 18
            Width = 692
            Height = 106
            Align = alTop
            BevelOuter = bvNone
            TabOrder = 0
            ExplicitLeft = 2
            ExplicitTop = 19
            object Label107: TLabel
              Left = 23
              Top = 33
              Width = 50
              Height = 45
              Alignment = taCenter
              AutoSize = False
              Caption = #51204#47448
              Color = 9605778
              Font.Charset = HANGEUL_CHARSET
              Font.Color = clWhite
              Font.Height = -11
              Font.Name = #44404#47548
              Font.Style = [fsBold]
              ParentColor = False
              ParentFont = False
              Transparent = False
              Layout = tlCenter
            end
            object Label114: TLabel
              Left = 14
              Top = 5
              Width = 56
              Height = 13
              Caption = 'HEATER'
              Font.Charset = HANGEUL_CHARSET
              Font.Color = clMaroon
              Font.Height = -13
              Font.Name = #44404#47548
              Font.Style = [fsBold]
              ParentFont = False
            end
            object Label116: TLabel
              Left = 103
              Top = 36
              Width = 43
              Height = 13
              Alignment = taRightJustify
              Caption = 'ON '#44592#51456
              Font.Charset = HANGEUL_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = []
              ParentFont = False
            end
            object Label117: TLabel
              Left = 212
              Top = 36
              Width = 8
              Height = 13
              Caption = '~'
              Font.Charset = HANGEUL_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = []
              ParentFont = False
            end
            object Label118: TLabel
              Left = 276
              Top = 36
              Width = 21
              Height = 13
              Caption = '( A )'
              Font.Charset = HANGEUL_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = []
              ParentFont = False
            end
            object Shape5: TShape
              Left = 9
              Top = 22
              Width = 669
              Height = 2
              Brush.Color = clMaroon
              Pen.Color = clMaroon
            end
            object Label121: TLabel
              Left = 101
              Top = 62
              Width = 45
              Height = 13
              Alignment = taRightJustify
              Caption = 'OFF '#44592#51456
              Font.Charset = HANGEUL_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = []
              ParentFont = False
            end
            object Label122: TLabel
              Left = 212
              Top = 63
              Width = 8
              Height = 13
              Caption = '~'
              Font.Charset = HANGEUL_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = []
              ParentFont = False
            end
            object Label123: TLabel
              Left = 276
              Top = 62
              Width = 21
              Height = 13
              Caption = '( A )'
              Font.Charset = HANGEUL_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = []
              ParentFont = False
            end
            object edtHeatOn_CurrHi: TEdit
              Left = 227
              Top = 33
              Width = 40
              Height = 19
              Color = 14286847
              Ctl3D = False
              Font.Charset = HANGEUL_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = []
              ImeName = 'Microsoft IME 2003'
              ParentCtl3D = False
              ParentFont = False
              TabOrder = 0
            end
            object edtHeatOn_CurrLo: TEdit
              Left = 167
              Top = 33
              Width = 40
              Height = 19
              Color = 14286847
              Ctl3D = False
              Font.Charset = HANGEUL_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = []
              ImeName = 'Microsoft IME 2003'
              ParentCtl3D = False
              ParentFont = False
              TabOrder = 1
              Text = '21.7'
            end
            object edtHeatOff_CurrLo: TEdit
              Left = 167
              Top = 59
              Width = 40
              Height = 19
              Color = 14286847
              Ctl3D = False
              Font.Charset = HANGEUL_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = []
              ImeName = 'Microsoft IME 2003'
              ParentCtl3D = False
              ParentFont = False
              TabOrder = 2
              Text = '21.7'
            end
            object edtHeatOff_CurrHi: TEdit
              Left = 227
              Top = 59
              Width = 40
              Height = 19
              Color = 14286847
              Ctl3D = False
              Font.Charset = HANGEUL_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = []
              ImeName = 'Microsoft IME 2003'
              ParentCtl3D = False
              ParentFont = False
              TabOrder = 3
            end
          end
          object Panel8: TPanel
            Left = 1
            Top = 124
            Width = 692
            Height = 106
            Align = alTop
            BevelOuter = bvNone
            TabOrder = 1
            object Label105: TLabel
              Left = 23
              Top = 33
              Width = 50
              Height = 45
              Alignment = taCenter
              AutoSize = False
              Caption = #51204#47448
              Color = 9605778
              Font.Charset = HANGEUL_CHARSET
              Font.Color = clWhite
              Font.Height = -11
              Font.Name = #44404#47548
              Font.Style = [fsBold]
              ParentColor = False
              ParentFont = False
              Transparent = False
              Layout = tlCenter
            end
            object Label106: TLabel
              Left = 14
              Top = 5
              Width = 37
              Height = 13
              Caption = 'VENT'
              Font.Charset = HANGEUL_CHARSET
              Font.Color = clMaroon
              Font.Height = -13
              Font.Name = #44404#47548
              Font.Style = [fsBold]
              ParentFont = False
            end
            object Label108: TLabel
              Left = 103
              Top = 36
              Width = 43
              Height = 13
              Alignment = taRightJustify
              Caption = 'ON '#44592#51456
              Font.Charset = HANGEUL_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = []
              ParentFont = False
            end
            object Label109: TLabel
              Left = 212
              Top = 36
              Width = 8
              Height = 13
              Caption = '~'
              Font.Charset = HANGEUL_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = []
              ParentFont = False
            end
            object Label110: TLabel
              Left = 276
              Top = 36
              Width = 21
              Height = 13
              Caption = '( A )'
              Font.Charset = HANGEUL_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = []
              ParentFont = False
            end
            object Shape10: TShape
              Left = 9
              Top = 22
              Width = 669
              Height = 2
              Brush.Color = clMaroon
              Pen.Color = clMaroon
            end
            object Label111: TLabel
              Left = 101
              Top = 62
              Width = 45
              Height = 13
              Alignment = taRightJustify
              Caption = 'OFF '#44592#51456
              Font.Charset = HANGEUL_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = []
              ParentFont = False
            end
            object Label112: TLabel
              Left = 212
              Top = 63
              Width = 8
              Height = 13
              Caption = '~'
              Font.Charset = HANGEUL_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = []
              ParentFont = False
            end
            object Label113: TLabel
              Left = 276
              Top = 62
              Width = 21
              Height = 13
              Caption = '( A )'
              Font.Charset = HANGEUL_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = []
              ParentFont = False
            end
            object edtVentOn_CurrHi: TEdit
              Left = 227
              Top = 33
              Width = 40
              Height = 19
              Color = 14286847
              Ctl3D = False
              Font.Charset = HANGEUL_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = []
              ImeName = 'Microsoft IME 2003'
              ParentCtl3D = False
              ParentFont = False
              TabOrder = 0
            end
            object edtVentOn_CurrLo: TEdit
              Left = 167
              Top = 33
              Width = 40
              Height = 19
              Color = 14286847
              Ctl3D = False
              Font.Charset = HANGEUL_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = []
              ImeName = 'Microsoft IME 2003'
              ParentCtl3D = False
              ParentFont = False
              TabOrder = 1
              Text = '21.7'
            end
            object edtVentOff_CurrLo: TEdit
              Left = 167
              Top = 59
              Width = 40
              Height = 19
              Color = 14286847
              Ctl3D = False
              Font.Charset = HANGEUL_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = []
              ImeName = 'Microsoft IME 2003'
              ParentCtl3D = False
              ParentFont = False
              TabOrder = 2
              Text = '21.7'
            end
            object edtVentOff_CurrHi: TEdit
              Left = 227
              Top = 59
              Width = 40
              Height = 19
              Color = 14286847
              Ctl3D = False
              Font.Charset = HANGEUL_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = []
              ImeName = 'Microsoft IME 2003'
              ParentCtl3D = False
              ParentFont = False
              TabOrder = 3
            end
          end
          object Panel9: TPanel
            Left = 1
            Top = 230
            Width = 692
            Height = 86
            Align = alTop
            BevelOuter = bvNone
            TabOrder = 2
            object Label115: TLabel
              Left = 24
              Top = 38
              Width = 50
              Height = 23
              Alignment = taCenter
              AutoSize = False
              Caption = #51204#50517
              Color = 9605778
              Font.Charset = HANGEUL_CHARSET
              Font.Color = clWhite
              Font.Height = -11
              Font.Name = #44404#47548
              Font.Style = [fsBold]
              ParentColor = False
              ParentFont = False
              Transparent = False
              Layout = tlCenter
            end
            object Label119: TLabel
              Left = 14
              Top = 5
              Width = 56
              Height = 13
              Caption = 'BUCKLE'
              Font.Charset = HANGEUL_CHARSET
              Font.Color = clMaroon
              Font.Height = -13
              Font.Name = #44404#47548
              Font.Style = [fsBold]
              ParentFont = False
            end
            object Label120: TLabel
              Left = 104
              Top = 43
              Width = 43
              Height = 13
              Alignment = taRightJustify
              Caption = 'ON '#44592#51456
              Font.Charset = HANGEUL_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = []
              ParentFont = False
            end
            object Label124: TLabel
              Left = 213
              Top = 43
              Width = 8
              Height = 13
              Caption = '~'
              Font.Charset = HANGEUL_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = []
              ParentFont = False
            end
            object Label125: TLabel
              Left = 277
              Top = 43
              Width = 21
              Height = 13
              Caption = '( V )'
              Font.Charset = HANGEUL_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = []
              ParentFont = False
            end
            object Shape11: TShape
              Left = 9
              Top = 22
              Width = 669
              Height = 2
              Brush.Color = clMaroon
              Pen.Color = clMaroon
            end
            object edtBuckleOn_VoltHi: TEdit
              Left = 228
              Top = 40
              Width = 40
              Height = 19
              Color = 14286847
              Ctl3D = False
              Font.Charset = HANGEUL_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = []
              ImeName = 'Microsoft IME 2003'
              ParentCtl3D = False
              ParentFont = False
              TabOrder = 0
            end
            object edtBuckleOn_VoltLo: TEdit
              Left = 168
              Top = 40
              Width = 40
              Height = 19
              Color = 14286847
              Ctl3D = False
              Font.Charset = HANGEUL_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = []
              ImeName = 'Microsoft IME 2003'
              ParentCtl3D = False
              ParentFont = False
              TabOrder = 1
              Text = '21.7'
            end
          end
        end
      end
      object tsBackAngle: TTabSheet
        Caption = #48177#44033#46020' '#44160#49324' '#49444#51221
        ImageIndex = 3
        object GroupBox5: TGroupBox
          Left = 19
          Top = 2
          Width = 694
          Height = 631
          Caption = #48177#44033#46020' '#44160#49324' '#49444#51221
          Ctl3D = False
          Font.Charset = HANGEUL_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = #47569#51008' '#44256#46357
          Font.Style = []
          ParentCtl3D = False
          ParentFont = False
          TabOrder = 0
          object Panel11: TPanel
            Left = 1
            Top = 18
            Width = 692
            Height = 106
            Align = alTop
            BevelOuter = bvNone
            TabOrder = 0
            object Label131: TLabel
              Left = 23
              Top = 33
              Width = 50
              Height = 45
              Alignment = taCenter
              AutoSize = False
              Caption = #44033#46020
              Color = 9605778
              Font.Charset = HANGEUL_CHARSET
              Font.Color = clWhite
              Font.Height = -11
              Font.Name = #44404#47548
              Font.Style = [fsBold]
              ParentColor = False
              ParentFont = False
              Transparent = False
              Layout = tlCenter
            end
            object Label132: TLabel
              Left = 14
              Top = 5
              Width = 73
              Height = 13
              Caption = 'RECL POS'
              Font.Charset = HANGEUL_CHARSET
              Font.Color = clMaroon
              Font.Height = -13
              Font.Name = #44404#47548
              Font.Style = [fsBold]
              ParentFont = False
            end
            object Label133: TLabel
              Left = 124
              Top = 36
              Width = 22
              Height = 13
              Alignment = taRightJustify
              Caption = #54260#46377
              Font.Charset = HANGEUL_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = []
              ParentFont = False
            end
            object Label135: TLabel
              Left = 212
              Top = 36
              Width = 8
              Height = 13
              Caption = '~'
              Font.Charset = HANGEUL_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = []
              ParentFont = False
            end
            object Label201: TLabel
              Left = 276
              Top = 36
              Width = 18
              Height = 13
              Caption = '( '#176' )'
              Font.Charset = HANGEUL_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = []
              ParentFont = False
            end
            object Shape14: TShape
              Left = 9
              Top = 22
              Width = 669
              Height = 2
              Brush.Color = clMaroon
              Pen.Color = clMaroon
            end
            object Label202: TLabel
              Left = 113
              Top = 62
              Width = 33
              Height = 13
              Alignment = taRightJustify
              Caption = #52572#54980#48169
              Font.Charset = HANGEUL_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = []
              ParentFont = False
            end
            object Label203: TLabel
              Left = 212
              Top = 63
              Width = 8
              Height = 13
              Caption = '~'
              Font.Charset = HANGEUL_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = []
              ParentFont = False
            end
            object Label207: TLabel
              Left = 276
              Top = 62
              Width = 18
              Height = 13
              Caption = '( '#176' )'
              Font.Charset = HANGEUL_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = []
              ParentFont = False
            end
            object edtFolding_AngleHi: TEdit
              Left = 227
              Top = 33
              Width = 40
              Height = 19
              Color = 14286847
              Ctl3D = False
              Font.Charset = HANGEUL_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = []
              ImeName = 'Microsoft IME 2003'
              ParentCtl3D = False
              ParentFont = False
              TabOrder = 0
            end
            object edtFolding_AngleLo: TEdit
              Left = 167
              Top = 33
              Width = 40
              Height = 19
              Color = 14286847
              Ctl3D = False
              Font.Charset = HANGEUL_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = []
              ImeName = 'Microsoft IME 2003'
              ParentCtl3D = False
              ParentFont = False
              TabOrder = 1
              Text = '21.7'
            end
            object edtRearMost_AngleLo: TEdit
              Left = 167
              Top = 59
              Width = 40
              Height = 19
              Color = 14286847
              Ctl3D = False
              Font.Charset = HANGEUL_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = []
              ImeName = 'Microsoft IME 2003'
              ParentCtl3D = False
              ParentFont = False
              TabOrder = 2
              Text = '21.7'
            end
            object edtRearMost_AngleHi: TEdit
              Left = 227
              Top = 59
              Width = 40
              Height = 19
              Color = 14286847
              Ctl3D = False
              Font.Charset = HANGEUL_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = []
              ImeName = 'Microsoft IME 2003'
              ParentCtl3D = False
              ParentFont = False
              TabOrder = 3
            end
          end
        end
      end
      object tsDeliver: TTabSheet
        Caption = #45225#54408#50948#52824' '#49444#51221
        ImageIndex = 4
        object grpInsepction01: TGroupBox
          Left = 23
          Top = 0
          Width = 684
          Height = 657
          Caption = #45225#54408#50948#52824' '#49444#51221
          Ctl3D = False
          Font.Charset = HANGEUL_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = #47569#51008' '#44256#46357
          Font.Style = []
          ParentCtl3D = False
          ParentFont = False
          TabOrder = 0
          inline fmAlign_Shoulder: TAlignSpecFrme
            Left = 1
            Top = 518
            Width = 682
            Height = 100
            Align = alTop
            TabOrder = 0
            ExplicitLeft = 1
            ExplicitTop = 518
            ExplicitWidth = 682
            inherited pnlClient: TPanel
              Width = 682
              ExplicitWidth = 682
              inherited lblTitle: TLabel
                Width = 78
                Caption = 'SHOULDER'
                ExplicitWidth = 78
              end
              inherited pnlDatas: TPanel
                inherited pnlAlignDatas: TPanel
                  inherited edtMoveTime: TEdit
                    Height = 19
                    ExplicitHeight = 19
                  end
                end
              end
            end
          end
          inline fmAlign_Relax: TAlignSpecFrme
            Left = 1
            Top = 418
            Width = 682
            Height = 100
            Align = alTop
            TabOrder = 1
            ExplicitLeft = 1
            ExplicitTop = 418
            ExplicitWidth = 682
            inherited pnlClient: TPanel
              Width = 682
              ExplicitWidth = 682
              inherited lblTitle: TLabel
                Width = 45
                Caption = 'RELAX'
                ExplicitWidth = 45
              end
              inherited pnlDatas: TPanel
                inherited pnlAlignDatas: TPanel
                  inherited edtMoveTime: TEdit
                    Height = 19
                    ExplicitHeight = 19
                  end
                end
              end
            end
          end
          inline fmAlign_Recl: TAlignSpecFrme
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
              inherited lblTitle: TLabel
                Width = 60
                Caption = 'RECLINE'
                ExplicitWidth = 60
              end
              inherited pnlDatas: TPanel
                inherited pnlAlignDatas: TPanel
                  inherited edtMoveTime: TEdit
                    Height = 19
                    ExplicitHeight = 19
                  end
                end
              end
            end
          end
          inline fmAlign_WalkinTilt: TAlignSpecFrme
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
              inherited lblTitle: TLabel
                Width = 88
                Caption = 'WALKIN TILT'
                ExplicitWidth = 88
              end
              inherited pnlDatas: TPanel
                inherited pnlAlignDatas: TPanel
                  inherited edtMoveTime: TEdit
                    Height = 19
                    ExplicitHeight = 19
                  end
                end
              end
            end
          end
          inline fmAlign_CushTilt: TAlignSpecFrme
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
              inherited lblTitle: TLabel
                Width = 75
                Caption = 'CUSH TILT'
                ExplicitWidth = 75
              end
              inherited pnlDatas: TPanel
                inherited pnlAlignDatas: TPanel
                  inherited edtMoveTime: TEdit
                    Height = 19
                    ExplicitHeight = 19
                  end
                end
              end
            end
          end
          inline fmAlign_Slide: TAlignSpecFrme
            Left = 1
            Top = 18
            Width = 682
            Height = 100
            Align = alTop
            TabOrder = 5
            ExplicitLeft = 1
            ExplicitTop = 18
            ExplicitWidth = 682
            inherited pnlClient: TPanel
              Width = 682
              ExplicitWidth = 682
              inherited lblTitle: TLabel
                Width = 41
                Caption = 'SLIDE'
                ExplicitWidth = 41
              end
              inherited pnlDatas: TPanel
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
      TabOrder = 2
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
      TabOrder = 3
      OnClick = OnSaveBtnActive
    end
    object rdgCarTrim: TRadioGroup
      Left = 178
      Top = 112
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
