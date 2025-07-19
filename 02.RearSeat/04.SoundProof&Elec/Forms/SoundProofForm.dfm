inherited frmSoundProof: TfrmSoundProof
  Top = 60
  BorderStyle = bsNone
  Caption = 'SoundProof Tester'
  ClientHeight = 1080
  ClientWidth = 1920
  HelpFile = '1080'
  Position = poDesigned
  WindowState = wsNormal
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  ExplicitLeft = -793
  ExplicitWidth = 1920
  ExplicitHeight = 1080
  PixelsPerInch = 96
  TextHeight = 17
  object shpConseparator: TShape [0]
    Left = 1693
    Top = 194
    Width = 1
    Height = 735
    Align = alRight
    Brush.Color = clSilver
    Brush.Style = bsDiagCross
    Pen.Color = 12695993
    ExplicitLeft = 226
    ExplicitTop = 163
    ExplicitHeight = 727
  end
  inherited pnlTitle: TPanel
    Width = 1920
    ExplicitWidth = 1920
    inherited lblSimLanInMode: TLabel3D
      Left = 0
      OnClick = lblSimLanInModeClick
      ExplicitLeft = 0
    end
  end
  inherited pnlStatus: TPanel
    Top = 1056
    Width = 1920
    TabOrder = 8
    ExplicitTop = 1056
    ExplicitWidth = 1920
    inherited pnlCommStatus: TPanel
      inherited abCAN: TAbLED
        Visible = False
      end
    end
    inherited pnlExtra: TPanel
      Left = 1601
      Width = 319
      ExplicitLeft = 1601
      ExplicitWidth = 319
      object lblWorkMonitor: TLabel
        Left = 212
        Top = 0
        Width = 107
        Height = 15
        Align = alRight
        Alignment = taCenter
        Caption = 'P/C 33.3 / 66.6 High '
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWhite
        Font.Height = -12
        Font.Name = #47569#51008' '#44256#46357' Semilight'
        Font.Style = []
        ParentFont = False
        Layout = tlCenter
      end
      object lblMemory: TLabel
        Left = 0
        Top = 0
        Width = 58
        Height = 15
        Align = alRight
        Caption = 'lblMemory'
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clGray
        Font.Height = -12
        Font.Name = #47569#51008' '#44256#46357
        Font.Style = []
        ParentFont = False
        Layout = tlCenter
      end
      object lblCycleTime: TLabel
        Left = 58
        Top = 0
        Width = 154
        Height = 24
        Align = alRight
        Alignment = taCenter
        AutoSize = False
        Caption = '#23 123.4'
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clGray
        Font.Height = -12
        Font.Name = #47569#51008' '#44256#46357
        Font.Style = []
        ParentFont = False
        Layout = tlCenter
        ExplicitLeft = -48
        ExplicitTop = -8
      end
    end
  end
  inherited pnlTop: TPanel
    Width = 1920
    ExplicitWidth = 1920
    inherited lblResult: TLabel3D
      Left = 1693
      Width = 227
      ExplicitLeft = 1693
      ExplicitWidth = 227
    end
    inherited lblMode: TLabel3D
      Left = 1550
      Width = 143
      ExplicitLeft = 1550
      ExplicitWidth = 143
    end
    inline fmModelInfo: TMdllInfoFrame
      Left = 0
      Top = 0
      Width = 1550
      Height = 114
      Align = alClient
      TabOrder = 0
      ExplicitWidth = 1550
      ExplicitHeight = 114
      inherited pnlMdlInfo: TPanel
        Width = 1550
        Height = 114
        ExplicitWidth = 1550
        ExplicitHeight = 114
        inherited pnlPartInfo: TPanel
          Height = 114
          ExplicitHeight = 114
          inherited lblLotNo: TLabel3D
            Height = 37
            ExplicitHeight = 37
          end
        end
        inherited pnlPos: TPanel
          Height = 114
          ExplicitHeight = 114
          inherited pnl2: TPanel
            Height = 98
            ExplicitHeight = 98
            inherited lblRH: TLabel3D
              Height = 48
              ExplicitHeight = 48
            end
          end
        end
        inherited pnlClass: TPanel
          Height = 114
          ExplicitHeight = 114
          inherited pnlClassClient: TPanel
            Height = 98
            ExplicitHeight = 98
          end
        end
        inherited pnlCarSubType: TPanel
          Height = 114
          ExplicitHeight = 114
          inherited pnlCarSubTypeClient: TPanel
            Height = 98
            ExplicitHeight = 98
            inherited lblSE: TLabel3D
              Height = 48
              ExplicitHeight = 48
            end
          end
        end
        inherited pnlECU: TPanel
          Height = 114
          ExplicitHeight = 114
          inherited pnlECUClient: TPanel
            Height = 98
            ExplicitHeight = 98
            inherited lblSAU: TLabel3D
              Height = 48
              ExplicitHeight = 48
            end
          end
        end
        inherited pnlBuckle: TPanel
          Height = 114
          ExplicitHeight = 114
          inherited pnlBuckleClient: TPanel
            Height = 98
            ExplicitHeight = 98
            inherited lblCenterBuckle: TLabel3D
              Top = 65
              ExplicitTop = 65
            end
            inherited lblILLBuckle: TLabel3D
              Height = 32
              ExplicitHeight = 32
            end
          end
        end
        inherited pnlHV: TPanel
          Height = 114
          ExplicitHeight = 114
          inherited pnlHVClient: TPanel
            Height = 98
            ExplicitHeight = 98
            inherited lblHV: TLabel3D
              Height = 48
              ExplicitHeight = 48
            end
          end
        end
        inherited pnlMotors: TPanel
          Width = 294
          Height = 114
          ExplicitWidth = 294
          ExplicitHeight = 114
          inherited pnlMotorsTitle: TPanel
            Width = 294
            ExplicitWidth = 294
          end
          inherited pnlMotorsTop: TPanel
            Width = 294
            ExplicitWidth = 294
          end
          inherited pnlMotorsBottom: TPanel
            Width = 294
            Height = 50
            ExplicitWidth = 294
            ExplicitHeight = 50
            inherited lblShoulder: TLabel3D
              Height = 50
              ExplicitHeight = 50
            end
            inherited lblHeadRest: TLabel3D
              Height = 50
              ExplicitHeight = 50
            end
            inherited lblRelax: TLabel3D
              Height = 50
              ExplicitHeight = 50
            end
          end
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 948
    Width = 1920
    TabOrder = 7
    ExplicitTop = 948
    ExplicitWidth = 1920
    inherited pnlRTVals: TPanel
      Width = 365
      ExplicitWidth = 365
      object Label19: TLabel
        Left = 40
        Top = 65
        Width = 55
        Height = 20
        Alignment = taRightJustify
        Caption = 'MOTOR'
        Font.Charset = HANGEUL_CHARSET
        Font.Color = 14145495
        Font.Height = -15
        Font.Name = #47569#51008' '#44256#46357
        Font.Style = []
        ParentFont = False
        Visible = False
      end
      object lblMotorCurr: TLabel
        Left = 115
        Top = 57
        Width = 47
        Height = 31
        Alignment = taRightJustify
        AutoSize = False
        Caption = '000'
        Color = 4013373
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 9357311
        Font.Height = -27
        Font.Name = #47569#51008' '#44256#46357
        Font.Style = []
        ParentColor = False
        ParentFont = False
        Transparent = True
        Layout = tlCenter
        Visible = False
      end
      object Label99: TLabel
        Left = 173
        Top = 70
        Width = 25
        Height = 13
        AutoSize = False
        Caption = 'A'
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clSilver
        Font.Height = -12
        Font.Name = #47569#51008' '#44256#46357
        Font.Style = []
        ParentFont = False
        Transparent = True
        Layout = tlCenter
        Visible = False
      end
      object Label96: TLabel
        Left = 204
        Top = 21
        Width = 65
        Height = 20
        Alignment = taRightJustify
        Caption = #49444#51221' '#51204#47448
        Font.Charset = HANGEUL_CHARSET
        Font.Color = 14145495
        Font.Height = -15
        Font.Name = #47569#51008' '#44256#46357
        Font.Style = []
        ParentFont = False
      end
      object lblOutCurr: TLabel
        Left = 288
        Top = 13
        Width = 53
        Height = 31
        Alignment = taRightJustify
        AutoSize = False
        Caption = '000'
        Color = 4013373
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clYellow
        Font.Height = -27
        Font.Name = #47569#51008' '#44256#46357
        Font.Style = []
        ParentColor = False
        ParentFont = False
        Transparent = True
        Layout = tlCenter
      end
      object Label102: TLabel
        Left = 351
        Top = 26
        Width = 25
        Height = 13
        AutoSize = False
        Caption = 'A'
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clSilver
        Font.Height = -12
        Font.Name = #47569#51008' '#44256#46357
        Font.Style = []
        ParentFont = False
        Transparent = True
        Layout = tlCenter
      end
      object Label7: TLabel
        Left = 30
        Top = 22
        Width = 65
        Height = 20
        Alignment = taRightJustify
        Caption = #49444#51221' '#51204#50517
        Font.Charset = HANGEUL_CHARSET
        Font.Color = 14145495
        Font.Height = -15
        Font.Name = #47569#51008' '#44256#46357
        Font.Style = []
        ParentFont = False
      end
      object lblOutVolt: TLabel
        Left = 109
        Top = 14
        Width = 53
        Height = 31
        Alignment = taRightJustify
        AutoSize = False
        Caption = '000'
        Color = 4013373
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clYellow
        Font.Height = -27
        Font.Name = #47569#51008' '#44256#46357
        Font.Style = []
        ParentColor = False
        ParentFont = False
        Transparent = True
        Layout = tlCenter
      end
      object Label10: TLabel
        Left = 173
        Top = 26
        Width = 25
        Height = 13
        AutoSize = False
        Caption = 'V'
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clSilver
        Font.Height = -12
        Font.Name = #47569#51008' '#44256#46357
        Font.Style = []
        ParentFont = False
        Transparent = True
        Layout = tlCenter
      end
    end
    inherited pnlLog: TPanel
      Left = 1066
      ExplicitLeft = 1066
    end
    inherited pnlWorkStatus: TPanel
      Left = 365
      Width = 701
      ExplicitLeft = 365
      ExplicitWidth = 701
      inherited lblStatus: TLabel3D
        Width = 701
        ExplicitLeft = 6
        ExplicitTop = 15
        ExplicitWidth = 381
      end
      inherited pnlWorkStatusTitle: TPanel
        Width = 701
        ExplicitWidth = 701
      end
    end
    inherited pnlPdtCnt: TPanel
      Left = 1697
      Width = 223
      Visible = False
      ExplicitLeft = 1697
      ExplicitWidth = 223
      inherited Panel3: TPanel
        Width = 223
        ExplicitWidth = 223
        inherited lblOK: TLabel
          Left = 98
          ExplicitLeft = 98
        end
      end
      inherited Panel6: TPanel
        Width = 223
        ExplicitWidth = 223
        inherited lblNG: TLabel
          Left = 102
          ExplicitLeft = 102
        end
      end
      inherited Panel4: TPanel
        Width = 223
        ExplicitWidth = 223
        inherited lblTot: TLabel
          Left = 102
          ExplicitLeft = 102
        end
      end
    end
  end
  inherited pnlSysStatus: TPanel
    Top = 929
    Width = 1920
    ExplicitTop = 929
    ExplicitWidth = 1920
    inherited abCable: TAbLED
      Left = 85
      Top = -2
      Height = 25
      Visible = True
      ExplicitLeft = 85
      ExplicitTop = -2
      ExplicitHeight = 25
    end
    inherited abPop: TAbLED
      Top = -2
      Height = 25
      ExplicitTop = -2
      ExplicitHeight = 25
    end
    object abDiskD: TAbLED
      Left = 1787
      Top = 2
      Width = 122
      Height = 16
      Caption = 'Disk(D:) 100 %'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      LED.Shape = sRectangle
      LED.Width = 15
      LED.Height = 10
      LED_Position = lpLeft
      Spacing = 5
      Checked = False
      Flashing = False
      Frequency = ff1Hz
      StatusInt = 0
      StatusBit = 0
      GroupIndex = 0
      Mode = mIndicator
    end
    object abDiskC: TAbLED
      Left = 1650
      Top = 2
      Width = 122
      Height = 16
      Caption = 'Disk(C:) 100 %'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      LED.Shape = sRectangle
      LED.Width = 15
      LED.Height = 10
      LED_Position = lpLeft
      Spacing = 5
      Checked = False
      Flashing = False
      Frequency = ff1Hz
      StatusInt = 0
      StatusBit = 0
      GroupIndex = 0
      Mode = mIndicator
    end
  end
  inherited pnlMsg: TPanel
    TabOrder = 6
  end
  object pnlClient: TPanel [7]
    Left = 0
    Top = 194
    Width = 1693
    Height = 735
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 3
    object shpTop: TShape
      Left = 0
      Top = 0
      Width = 1693
      Height = 25
      Align = alTop
      Brush.Style = bsDiagCross
      Pen.Color = clWhite
      ExplicitTop = -1
    end
    object shpLeft: TShape
      Left = 0
      Top = 25
      Width = 10
      Height = 700
      Align = alLeft
      Brush.Style = bsDiagCross
      Pen.Color = clWhite
      ExplicitTop = 10
      ExplicitHeight = 672
    end
    object shpRight: TShape
      Left = 1663
      Top = 25
      Width = 30
      Height = 700
      Align = alRight
      Brush.Style = bsDiagCross
      Pen.Color = clWhite
    end
    object shpBottom: TShape
      Left = 0
      Top = 725
      Width = 1693
      Height = 10
      Align = alBottom
      Brush.Style = bsDiagCross
      Pen.Color = clWhite
      ExplicitLeft = -4
      ExplicitTop = 726
    end
    object pnlMtr: TPanel
      Left = 10
      Top = 25
      Width = 1011
      Height = 700
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 0
      inline fmMtr1: TSeatMtrTestFrme
        Left = 0
        Top = 525
        Width = 1011
        Height = 175
        Align = alTop
        Color = clWhite
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #47569#51008' '#44256#46357
        Font.Style = []
        ParentBackground = False
        ParentColor = False
        ParentFont = False
        TabOrder = 0
        ExplicitTop = 525
        ExplicitWidth = 1011
        ExplicitHeight = 175
        inherited pnlBase: TPanel
          Width = 1011
          Height = 175
          ExplicitWidth = 1011
          ExplicitHeight = 175
          inherited Splitter: TSplitter
            Height = 143
            ExplicitHeight = 141
          end
          inherited pnlTop: TPanel
            Width = 1003
            ExplicitWidth = 1003
            inherited shpTopLine: TShape
              Width = 1003
              ExplicitWidth = 762
            end
            inherited sbtnViewMode: TSpeedButton
              Left = 967
              ExplicitLeft = 726
            end
            inherited pnlLegend: TPanel
              Width = 702
              ExplicitWidth = 702
            end
          end
          inherited pnlData: TPanel
            Height = 143
            ExplicitHeight = 143
            inherited sgData: TStringGrid
              Height = 125
              DefaultRowHeight = 30
              Font.Height = -13
              ExplicitHeight = 125
            end
          end
          inherited pnlGrp: TPanel
            Height = 143
            ExplicitHeight = 143
            inherited grpData: TFaGraphEx
              Height = 133
              ExplicitHeight = 131
            end
          end
        end
      end
      inline SeatMtrTestFrme1: TSeatMtrTestFrme
        Left = 0
        Top = 350
        Width = 1011
        Height = 175
        Align = alTop
        Color = clWhite
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #47569#51008' '#44256#46357
        Font.Style = []
        ParentBackground = False
        ParentColor = False
        ParentFont = False
        TabOrder = 1
        ExplicitTop = 350
        ExplicitWidth = 1011
        ExplicitHeight = 175
        inherited pnlBase: TPanel
          Width = 1011
          Height = 175
          ExplicitWidth = 1011
          ExplicitHeight = 175
          inherited Splitter: TSplitter
            Height = 143
            ExplicitHeight = 141
          end
          inherited pnlTop: TPanel
            Width = 1003
            ExplicitWidth = 1003
            inherited shpTopLine: TShape
              Width = 1003
              ExplicitWidth = 756
            end
            inherited sbtnViewMode: TSpeedButton
              Left = 967
              ExplicitLeft = 720
            end
            inherited pnlLegend: TPanel
              Width = 702
              ExplicitWidth = 702
            end
          end
          inherited pnlData: TPanel
            Height = 143
            ExplicitHeight = 143
            inherited sgData: TStringGrid
              Height = 125
              DefaultRowHeight = 30
              Font.Height = -13
              ExplicitHeight = 125
            end
          end
          inherited pnlGrp: TPanel
            Height = 143
            ExplicitHeight = 143
            inherited grpData: TFaGraphEx
              Height = 133
              ExplicitHeight = 131
            end
          end
        end
      end
      inline SeatMtrTestFrme2: TSeatMtrTestFrme
        Left = 0
        Top = 175
        Width = 1011
        Height = 175
        Align = alTop
        Color = clWhite
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #47569#51008' '#44256#46357
        Font.Style = []
        ParentBackground = False
        ParentColor = False
        ParentFont = False
        TabOrder = 2
        ExplicitTop = 175
        ExplicitWidth = 1011
        ExplicitHeight = 175
        inherited pnlBase: TPanel
          Width = 1011
          Height = 175
          ExplicitWidth = 1011
          ExplicitHeight = 175
          inherited Splitter: TSplitter
            Height = 143
            ExplicitHeight = 141
          end
          inherited pnlTop: TPanel
            Width = 1003
            ExplicitWidth = 1003
            inherited shpTopLine: TShape
              Width = 1003
              ExplicitWidth = 756
            end
            inherited sbtnViewMode: TSpeedButton
              Left = 967
              ExplicitLeft = 720
            end
            inherited pnlLegend: TPanel
              Width = 702
              ExplicitWidth = 702
            end
          end
          inherited pnlData: TPanel
            Height = 143
            ExplicitHeight = 143
            inherited sgData: TStringGrid
              Height = 125
              DefaultRowHeight = 30
              Font.Height = -13
              ExplicitHeight = 125
            end
          end
          inherited pnlGrp: TPanel
            Height = 143
            ExplicitHeight = 143
            inherited grpData: TFaGraphEx
              Height = 133
              ExplicitHeight = 131
            end
          end
        end
      end
      inline SeatMtrTestFrme3: TSeatMtrTestFrme
        Left = 0
        Top = 0
        Width = 1011
        Height = 175
        Align = alTop
        Color = clWhite
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #47569#51008' '#44256#46357
        Font.Style = []
        ParentBackground = False
        ParentColor = False
        ParentFont = False
        TabOrder = 3
        ExplicitWidth = 1011
        ExplicitHeight = 175
        inherited pnlBase: TPanel
          Width = 1011
          Height = 175
          ExplicitWidth = 1011
          ExplicitHeight = 175
          inherited Splitter: TSplitter
            Height = 143
            ExplicitHeight = 141
          end
          inherited pnlTop: TPanel
            Width = 1003
            ExplicitWidth = 1003
            inherited shpTopLine: TShape
              Width = 1003
              ExplicitWidth = 756
            end
            inherited sbtnViewMode: TSpeedButton
              Left = 967
              ExplicitLeft = 720
            end
            inherited pnlLegend: TPanel
              Width = 702
              ExplicitWidth = 702
            end
          end
          inherited pnlData: TPanel
            Height = 143
            ExplicitHeight = 143
            inherited sgData: TStringGrid
              Height = 125
              DefaultRowHeight = 30
              Font.Height = -13
              ExplicitHeight = 125
            end
          end
          inherited pnlGrp: TPanel
            Height = 143
            ExplicitHeight = 143
            inherited grpData: TFaGraphEx
              Height = 133
              ExplicitHeight = 131
            end
          end
        end
      end
    end
    object pnlElec: TPanel
      AlignWithMargins = True
      Left = 1041
      Top = 25
      Width = 622
      Height = 700
      Margins.Left = 20
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 1
      object pnlHV: TPanel
        Left = 0
        Top = 490
        Width = 622
        Height = 210
        Align = alBottom
        BevelOuter = bvNone
        TabOrder = 0
        object pnlHeat: TPanel
          Left = 0
          Top = 0
          Width = 300
          Height = 210
          Align = alLeft
          BevelOuter = bvNone
          TabOrder = 0
          inline HVDatFrame1: THVDatFrame
            Left = 0
            Top = 0
            Width = 300
            Height = 193
            Align = alTop
            Color = clWhite
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clBlack
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentBackground = False
            ParentColor = False
            ParentFont = False
            TabOrder = 0
            inherited pnlHeader: TPanel
              inherited lblPosName: TLabel
                Width = 150
                ExplicitWidth = 150
              end
            end
            inherited chtAD: TChart
              PrintMargins = (
                15
                36
                15
                36)
            end
          end
        end
        object pnlVent: TPanel
          AlignWithMargins = True
          Left = 310
          Top = 0
          Width = 312
          Height = 210
          Margins.Left = 10
          Margins.Top = 0
          Margins.Right = 0
          Margins.Bottom = 0
          Align = alClient
          BevelOuter = bvNone
          TabOrder = 1
          inline HVDatFrame3: THVDatFrame
            Left = 0
            Top = 0
            Width = 312
            Height = 193
            Align = alTop
            Color = clWhite
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clBlack
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentBackground = False
            ParentColor = False
            ParentFont = False
            TabOrder = 0
            ExplicitWidth = 312
            inherited pnlCurr: TPanel
              Width = 312
              ExplicitWidth = 312
            end
            inherited pnlLed: TPanel
              Width = 312
              ExplicitWidth = 312
            end
            inherited pnlHeader: TPanel
              Width = 312
              ExplicitWidth = 312
              inherited lblPosName: TLabel
                Width = 150
                ExplicitWidth = 150
              end
            end
            inherited chtAD: TChart
              PrintMargins = (
                15
                36
                15
                36)
            end
          end
        end
      end
      object pnlECUVer: TPanel
        Left = 0
        Top = 10
        Width = 607
        Height = 111
        BevelOuter = bvNone
        TabOrder = 1
        object Panel1: TPanel
          Left = 0
          Top = 0
          Width = 607
          Height = 20
          Align = alTop
          BevelOuter = bvNone
          Color = clWhite
          ParentBackground = False
          TabOrder = 0
          object lblEcuInfoTitle: TLabel
            Left = 0
            Top = 0
            Width = 150
            Height = 20
            Align = alLeft
            Alignment = taCenter
            AutoSize = False
            Caption = ' ECU '#51221#48372
            Color = 4800317
            Font.Charset = HANGEUL_CHARSET
            Font.Color = clWhite
            Font.Height = -15
            Font.Name = #47569#51008' '#44256#46357
            Font.Style = [fsBold]
            ParentColor = False
            ParentFont = False
            Transparent = False
            Layout = tlCenter
          end
        end
        object Panel5: TPanel
          Left = 0
          Top = 20
          Width = 607
          Height = 91
          Align = alClient
          BevelOuter = bvNone
          TabOrder = 1
          object Panel8: TPanel
            Left = 0
            Top = 0
            Width = 607
            Height = 30
            Align = alTop
            BevelOuter = bvNone
            TabOrder = 0
            object Label3D13: TLabel3D
              Left = 307
              Top = 0
              Width = 150
              Height = 30
              ShowTitle = False
              TitleColor = clGray
              TitleFont.Charset = ANSI_CHARSET
              TitleFont.Color = clWindowText
              TitleFont.Height = -15
              TitleFont.Name = #47569#51008' '#44256#46357
              TitleFont.Style = []
              TitleHeightRatio = 0.200000000000000000
              BorderColor = clBlack
              BorderPenStyle = psSolid
              Border = True
              BorderType = btBorderLine
              BorderLineT = True
              BorderLineR = True
              BorderLineB = True
              BorderLineL = False
              Escapement = 0
              TextStyle = tsNone
              LabelStyle = lsDefault
              EllipsesStyle = esNone
              Shift = 1
              Align = alLeft
              Alignment = taCenter
              AutoSize = False
              Caption = 'S/W VER'
              Color = 16251129
              Font.Charset = ANSI_CHARSET
              Font.Color = clBlack
              Font.Height = -13
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = [fsBold]
              Layout = tlCenter
              ParentColor = False
              ParentFont = False
              Transparent = False
              ExplicitLeft = 301
            end
            object Label3D7: TLabel3D
              Left = 87
              Top = 0
              Width = 220
              Height = 30
              ShowTitle = False
              TitleColor = clGray
              TitleFont.Charset = ANSI_CHARSET
              TitleFont.Color = clWindowText
              TitleFont.Height = -15
              TitleFont.Name = #47569#51008' '#44256#46357
              TitleFont.Style = []
              TitleHeightRatio = 0.200000000000000000
              BorderColor = clBlack
              BorderPenStyle = psSolid
              Border = True
              BorderType = btBorderLine
              BorderLineT = True
              BorderLineR = True
              BorderLineB = True
              BorderLineL = True
              Escapement = 0
              TextStyle = tsNone
              LabelStyle = lsDefault
              EllipsesStyle = esNone
              Shift = 1
              Align = alLeft
              Alignment = taCenter
              AutoSize = False
              Caption = 'PART NO'
              Color = 16251129
              Font.Charset = ANSI_CHARSET
              Font.Color = clBlack
              Font.Height = -13
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = [fsBold]
              Layout = tlCenter
              ParentColor = False
              ParentFont = False
              Transparent = False
              ExplicitLeft = 81
            end
            object Label3D3: TLabel3D
              Left = 0
              Top = 0
              Width = 87
              Height = 30
              ShowTitle = False
              TitleColor = clGray
              TitleFont.Charset = ANSI_CHARSET
              TitleFont.Color = clWindowText
              TitleFont.Height = -15
              TitleFont.Name = #47569#51008' '#44256#46357
              TitleFont.Style = []
              TitleHeightRatio = 0.200000000000000000
              BorderColor = clBlack
              BorderPenStyle = psSolid
              Border = True
              BorderType = btBorderLine
              BorderLineT = True
              BorderLineR = False
              BorderLineB = True
              BorderLineL = True
              Escapement = 0
              TextStyle = tsNone
              LabelStyle = lsDefault
              EllipsesStyle = esNone
              Shift = 1
              Align = alLeft
              Alignment = taCenter
              AutoSize = False
              Color = 16251129
              Font.Charset = ANSI_CHARSET
              Font.Color = clBlack
              Font.Height = -17
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = [fsBold]
              Layout = tlCenter
              ParentColor = False
              ParentFont = False
              Transparent = False
            end
            object Label3D16: TLabel3D
              Left = 457
              Top = 0
              Width = 150
              Height = 30
              ShowTitle = False
              TitleColor = clGray
              TitleFont.Charset = ANSI_CHARSET
              TitleFont.Color = clWindowText
              TitleFont.Height = -15
              TitleFont.Name = #47569#51008' '#44256#46357
              TitleFont.Style = []
              TitleHeightRatio = 0.200000000000000000
              BorderColor = clBlack
              BorderPenStyle = psSolid
              Border = True
              BorderType = btBorderLine
              BorderLineT = True
              BorderLineR = True
              BorderLineB = True
              BorderLineL = False
              Escapement = 0
              TextStyle = tsNone
              LabelStyle = lsDefault
              EllipsesStyle = esNone
              Shift = 1
              Align = alClient
              Alignment = taCenter
              AutoSize = False
              Caption = 'H/W VER'
              Color = 16251129
              Font.Charset = ANSI_CHARSET
              Font.Color = clBlack
              Font.Height = -13
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = [fsBold]
              Layout = tlCenter
              ParentColor = False
              ParentFont = False
              Transparent = False
              ExplicitLeft = 319
              ExplicitWidth = 100
            end
          end
          object Panel10: TPanel
            Left = 0
            Top = 61
            Width = 607
            Height = 30
            Align = alBottom
            BevelOuter = bvNone
            TabOrder = 1
            object lblPSUVerHw: TLabel3D
              Tag = 222
              Left = 532
              Top = 0
              Width = 75
              Height = 30
              ShowTitle = False
              TitleColor = clGray
              TitleFont.Charset = DEFAULT_CHARSET
              TitleFont.Color = clWindowText
              TitleFont.Height = -11
              TitleFont.Name = 'Tahoma'
              TitleFont.Style = []
              TitleHeightRatio = 0.200000000000000000
              BorderColor = clBlack
              BorderPenStyle = psSolid
              Border = True
              BorderType = btBorderLine
              BorderLineT = False
              BorderLineR = True
              BorderLineB = True
              BorderLineL = False
              Escapement = 0
              TextStyle = tsNone
              LabelStyle = lsDefault
              EllipsesStyle = esNone
              Shift = 1
              Align = alClient
              Alignment = taCenter
              AutoSize = False
              Caption = 'D.00'
              Color = 13387839
              Font.Charset = ANSI_CHARSET
              Font.Color = clWhite
              Font.Height = -15
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = [fsBold]
              Layout = tlCenter
              ParentColor = False
              ParentFont = False
              Transparent = False
              ExplicitLeft = 319
              ExplicitWidth = 100
              ExplicitHeight = 31
            end
            object lblPSUVerSw: TLabel3D
              Tag = 222
              Left = 382
              Top = 0
              Width = 75
              Height = 30
              ShowTitle = False
              TitleColor = clGray
              TitleFont.Charset = DEFAULT_CHARSET
              TitleFont.Color = clWindowText
              TitleFont.Height = -11
              TitleFont.Name = 'Tahoma'
              TitleFont.Style = []
              TitleHeightRatio = 0.200000000000000000
              BorderColor = clBlack
              BorderPenStyle = psSolid
              Border = True
              BorderType = btBorderLine
              BorderLineT = False
              BorderLineR = True
              BorderLineB = True
              BorderLineL = False
              Escapement = 0
              TextStyle = tsNone
              LabelStyle = lsDefault
              EllipsesStyle = esNone
              Shift = 1
              Align = alLeft
              Alignment = taCenter
              AutoSize = False
              Caption = '25610'
              Color = 13387839
              Font.Charset = ANSI_CHARSET
              Font.Color = clWhite
              Font.Height = -15
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = [fsBold]
              Layout = tlCenter
              ParentColor = False
              ParentFont = False
              Transparent = False
              ExplicitLeft = 301
            end
            object lblPSUPartNo: TLabel3D
              Tag = 222
              Left = 87
              Top = 0
              Width = 110
              Height = 30
              ShowTitle = False
              TitleColor = clGray
              TitleFont.Charset = DEFAULT_CHARSET
              TitleFont.Color = clWindowText
              TitleFont.Height = -11
              TitleFont.Name = 'Tahoma'
              TitleFont.Style = []
              TitleHeightRatio = 0.200000000000000000
              BorderColor = clBlack
              BorderPenStyle = psSolid
              Border = True
              BorderType = btBorderLine
              BorderLineT = False
              BorderLineR = False
              BorderLineB = True
              BorderLineL = True
              Escapement = 0
              TextStyle = tsNone
              LabelStyle = lsDefault
              EllipsesStyle = esNone
              Shift = 1
              Align = alLeft
              Alignment = taCenter
              AutoSize = False
              Caption = '89B90P8000'
              Color = 14942207
              Font.Charset = ANSI_CHARSET
              Font.Color = clGray
              Font.Height = -15
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = [fsBold]
              Layout = tlCenter
              ParentColor = False
              ParentFont = False
              Transparent = False
              ExplicitLeft = 81
            end
            object Label3D4: TLabel3D
              Left = 0
              Top = 0
              Width = 87
              Height = 30
              ShowTitle = False
              TitleColor = clGray
              TitleFont.Charset = ANSI_CHARSET
              TitleFont.Color = clWindowText
              TitleFont.Height = -15
              TitleFont.Name = #47569#51008' '#44256#46357
              TitleFont.Style = []
              TitleHeightRatio = 0.200000000000000000
              BorderColor = clBlack
              BorderPenStyle = psSolid
              Border = True
              BorderType = btBorderLine
              BorderLineT = False
              BorderLineR = False
              BorderLineB = True
              BorderLineL = True
              Escapement = 0
              TextStyle = tsNone
              LabelStyle = lsDefault
              EllipsesStyle = esNone
              Shift = 1
              Align = alLeft
              Alignment = taCenter
              AutoSize = False
              Caption = 'SAU'
              Color = 16251129
              Font.Charset = ANSI_CHARSET
              Font.Color = clBlack
              Font.Height = -16
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = [fsBold]
              Layout = tlCenter
              ParentColor = False
              ParentFont = False
              Transparent = False
            end
            object Label3D24: TLabel3D
              Tag = 222
              Left = 197
              Top = 0
              Width = 110
              Height = 30
              ShowTitle = False
              TitleColor = clGray
              TitleFont.Charset = DEFAULT_CHARSET
              TitleFont.Color = clWindowText
              TitleFont.Height = -11
              TitleFont.Name = 'Tahoma'
              TitleFont.Style = []
              TitleHeightRatio = 0.200000000000000000
              BorderColor = clBlack
              BorderPenStyle = psSolid
              Border = True
              BorderType = btBorderLine
              BorderLineT = False
              BorderLineR = True
              BorderLineB = True
              BorderLineL = True
              Escapement = 0
              TextStyle = tsNone
              LabelStyle = lsDefault
              EllipsesStyle = esNone
              Shift = 1
              Align = alLeft
              Alignment = taCenter
              AutoSize = False
              Caption = '87B90P8000'
              Color = 5592575
              Font.Charset = ANSI_CHARSET
              Font.Color = clWhite
              Font.Height = -15
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = [fsBold]
              Layout = tlCenter
              ParentColor = False
              ParentFont = False
              Transparent = False
              ExplicitLeft = 207
              ExplicitTop = 2
            end
            object Label3D26: TLabel3D
              Tag = 222
              Left = 307
              Top = 0
              Width = 75
              Height = 30
              ShowTitle = False
              TitleColor = clGray
              TitleFont.Charset = DEFAULT_CHARSET
              TitleFont.Color = clWindowText
              TitleFont.Height = -11
              TitleFont.Name = 'Tahoma'
              TitleFont.Style = []
              TitleHeightRatio = 0.200000000000000000
              BorderColor = clBlack
              BorderPenStyle = psSolid
              Border = True
              BorderType = btBorderLine
              BorderLineT = False
              BorderLineR = True
              BorderLineB = True
              BorderLineL = False
              Escapement = 0
              TextStyle = tsNone
              LabelStyle = lsDefault
              EllipsesStyle = esNone
              Shift = 1
              Align = alLeft
              Alignment = taCenter
              AutoSize = False
              Caption = '25610'
              Color = 14942207
              Font.Charset = ANSI_CHARSET
              Font.Color = clGray
              Font.Height = -15
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = [fsBold]
              Layout = tlCenter
              ParentColor = False
              ParentFont = False
              Transparent = False
              ExplicitLeft = 301
            end
            object Label3D28: TLabel3D
              Tag = 222
              Left = 457
              Top = 0
              Width = 75
              Height = 30
              ShowTitle = False
              TitleColor = clGray
              TitleFont.Charset = DEFAULT_CHARSET
              TitleFont.Color = clWindowText
              TitleFont.Height = -11
              TitleFont.Name = 'Tahoma'
              TitleFont.Style = []
              TitleHeightRatio = 0.200000000000000000
              BorderColor = clBlack
              BorderPenStyle = psSolid
              Border = True
              BorderType = btBorderLine
              BorderLineT = False
              BorderLineR = True
              BorderLineB = True
              BorderLineL = False
              Escapement = 0
              TextStyle = tsNone
              LabelStyle = lsDefault
              EllipsesStyle = esNone
              Shift = 1
              Align = alLeft
              Alignment = taCenter
              AutoSize = False
              Caption = 'D.00'
              Color = 14942207
              Font.Charset = ANSI_CHARSET
              Font.Color = clGray
              Font.Height = -15
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = [fsBold]
              Layout = tlCenter
              ParentColor = False
              ParentFont = False
              Transparent = False
              ExplicitLeft = 509
              ExplicitTop = -6
              ExplicitHeight = 31
            end
          end
          object Panel13: TPanel
            Left = 0
            Top = 30
            Width = 607
            Height = 31
            Align = alClient
            BevelOuter = bvNone
            TabOrder = 2
            object lblSHVUVerSw: TLabel3D
              Tag = 222
              Left = 382
              Top = 0
              Width = 75
              Height = 31
              ShowTitle = False
              TitleColor = clGray
              TitleFont.Charset = DEFAULT_CHARSET
              TitleFont.Color = clWindowText
              TitleFont.Height = -11
              TitleFont.Name = 'Tahoma'
              TitleFont.Style = []
              TitleHeightRatio = 0.200000000000000000
              BorderColor = clBlack
              BorderPenStyle = psSolid
              Border = True
              BorderType = btBorderLine
              BorderLineT = False
              BorderLineR = True
              BorderLineB = True
              BorderLineL = False
              Escapement = 0
              TextStyle = tsNone
              LabelStyle = lsDefault
              EllipsesStyle = esNone
              Shift = 1
              Align = alLeft
              Alignment = taCenter
              AutoSize = False
              Caption = '25610'
              Color = 13387839
              Font.Charset = ANSI_CHARSET
              Font.Color = clWhite
              Font.Height = -15
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = [fsBold]
              Layout = tlCenter
              ParentColor = False
              ParentFont = False
              Transparent = False
              ExplicitLeft = 301
            end
            object lblSHVUPartNo: TLabel3D
              Tag = 222
              Left = 197
              Top = 0
              Width = 110
              Height = 31
              ShowTitle = False
              TitleColor = clGray
              TitleFont.Charset = DEFAULT_CHARSET
              TitleFont.Color = clWindowText
              TitleFont.Height = -11
              TitleFont.Name = 'Tahoma'
              TitleFont.Style = []
              TitleHeightRatio = 0.200000000000000000
              BorderColor = clBlack
              BorderPenStyle = psSolid
              Border = True
              BorderType = btBorderLine
              BorderLineT = False
              BorderLineR = True
              BorderLineB = True
              BorderLineL = True
              Escapement = 0
              TextStyle = tsNone
              LabelStyle = lsDefault
              EllipsesStyle = esNone
              Shift = 1
              Align = alLeft
              Alignment = taCenter
              AutoSize = False
              Caption = '89B90P8010'
              Color = 5592575
              Font.Charset = ANSI_CHARSET
              Font.Color = clWhite
              Font.Height = -15
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = [fsBold]
              Layout = tlCenter
              ParentColor = False
              ParentFont = False
              Transparent = False
              ExplicitLeft = 165
              ExplicitTop = 10
            end
            object Label3D5: TLabel3D
              Left = 0
              Top = 0
              Width = 87
              Height = 31
              ShowTitle = False
              TitleColor = clGray
              TitleFont.Charset = ANSI_CHARSET
              TitleFont.Color = clWindowText
              TitleFont.Height = -15
              TitleFont.Name = #47569#51008' '#44256#46357
              TitleFont.Style = []
              TitleHeightRatio = 0.200000000000000000
              BorderColor = clBlack
              BorderPenStyle = psSolid
              Border = True
              BorderType = btBorderLine
              BorderLineT = False
              BorderLineR = False
              BorderLineB = True
              BorderLineL = True
              Escapement = 0
              TextStyle = tsNone
              LabelStyle = lsDefault
              EllipsesStyle = esNone
              Shift = 1
              Align = alLeft
              Alignment = taCenter
              AutoSize = False
              Caption = 'HVPSU'
              Color = 16251129
              Font.Charset = ANSI_CHARSET
              Font.Color = clBlack
              Font.Height = -16
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = [fsBold]
              Layout = tlCenter
              ParentColor = False
              ParentFont = False
              Transparent = False
            end
            object lblSHVUVerHw: TLabel3D
              Tag = 222
              Left = 532
              Top = 0
              Width = 75
              Height = 31
              ShowTitle = False
              TitleColor = clGray
              TitleFont.Charset = DEFAULT_CHARSET
              TitleFont.Color = clWindowText
              TitleFont.Height = -11
              TitleFont.Name = 'Tahoma'
              TitleFont.Style = []
              TitleHeightRatio = 0.200000000000000000
              BorderColor = clBlack
              BorderPenStyle = psSolid
              Border = True
              BorderType = btBorderLine
              BorderLineT = False
              BorderLineR = True
              BorderLineB = True
              BorderLineL = False
              Escapement = 0
              TextStyle = tsNone
              LabelStyle = lsDefault
              EllipsesStyle = esNone
              Shift = 1
              Align = alClient
              Alignment = taCenter
              AutoSize = False
              Caption = 'D.00'
              Color = 13387839
              Font.Charset = ANSI_CHARSET
              Font.Color = clWhite
              Font.Height = -15
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = [fsBold]
              Layout = tlCenter
              ParentColor = False
              ParentFont = False
              Transparent = False
              ExplicitLeft = 319
              ExplicitWidth = 100
            end
            object Label3D22: TLabel3D
              Tag = 222
              Left = 87
              Top = 0
              Width = 110
              Height = 31
              ShowTitle = False
              TitleColor = clGray
              TitleFont.Charset = DEFAULT_CHARSET
              TitleFont.Color = clWindowText
              TitleFont.Height = -11
              TitleFont.Name = 'Tahoma'
              TitleFont.Style = []
              TitleHeightRatio = 0.200000000000000000
              BorderColor = clBlack
              BorderPenStyle = psSolid
              Border = True
              BorderType = btBorderLine
              BorderLineT = False
              BorderLineR = False
              BorderLineB = True
              BorderLineL = True
              Escapement = 0
              TextStyle = tsNone
              LabelStyle = lsDefault
              EllipsesStyle = esNone
              Shift = 1
              Align = alLeft
              Alignment = taCenter
              AutoSize = False
              Caption = '89B90P8000'
              Color = 14942207
              Font.Charset = ANSI_CHARSET
              Font.Color = clGray
              Font.Height = -15
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = [fsBold]
              Layout = tlCenter
              ParentColor = False
              ParentFont = False
              Transparent = False
              ExplicitLeft = 81
            end
            object Label3D25: TLabel3D
              Tag = 222
              Left = 307
              Top = 0
              Width = 75
              Height = 31
              ShowTitle = False
              TitleColor = clGray
              TitleFont.Charset = DEFAULT_CHARSET
              TitleFont.Color = clWindowText
              TitleFont.Height = -11
              TitleFont.Name = 'Tahoma'
              TitleFont.Style = []
              TitleHeightRatio = 0.200000000000000000
              BorderColor = clBlack
              BorderPenStyle = psSolid
              Border = True
              BorderType = btBorderLine
              BorderLineT = False
              BorderLineR = True
              BorderLineB = True
              BorderLineL = False
              Escapement = 0
              TextStyle = tsNone
              LabelStyle = lsDefault
              EllipsesStyle = esNone
              Shift = 1
              Align = alLeft
              Alignment = taCenter
              AutoSize = False
              Caption = '25610'
              Color = 14942207
              Font.Charset = ANSI_CHARSET
              Font.Color = clGray
              Font.Height = -15
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = [fsBold]
              Layout = tlCenter
              ParentColor = False
              ParentFont = False
              Transparent = False
              ExplicitLeft = 301
            end
            object Label3D27: TLabel3D
              Tag = 222
              Left = 457
              Top = 0
              Width = 75
              Height = 31
              ShowTitle = False
              TitleColor = clGray
              TitleFont.Charset = DEFAULT_CHARSET
              TitleFont.Color = clWindowText
              TitleFont.Height = -11
              TitleFont.Name = 'Tahoma'
              TitleFont.Style = []
              TitleHeightRatio = 0.200000000000000000
              BorderColor = clBlack
              BorderPenStyle = psSolid
              Border = True
              BorderType = btBorderLine
              BorderLineT = False
              BorderLineR = True
              BorderLineB = True
              BorderLineL = False
              Escapement = 0
              TextStyle = tsNone
              LabelStyle = lsDefault
              EllipsesStyle = esNone
              Shift = 1
              Align = alLeft
              Alignment = taCenter
              AutoSize = False
              Caption = 'D.00'
              Color = 14942207
              Font.Charset = ANSI_CHARSET
              Font.Color = clGray
              Font.Height = -15
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = [fsBold]
              Layout = tlCenter
              ParentColor = False
              ParentFont = False
              Transparent = False
              ExplicitLeft = 509
              ExplicitTop = -6
            end
          end
        end
      end
      object Panel20: TPanel
        Left = 0
        Top = 320
        Width = 609
        Height = 123
        BevelOuter = bvNone
        TabOrder = 2
        object Panel23: TPanel
          Left = 0
          Top = 0
          Width = 609
          Height = 20
          Align = alTop
          BevelOuter = bvNone
          Color = clWhite
          ParentBackground = False
          TabOrder = 0
          ExplicitTop = 2
          ExplicitWidth = 462
          object Label9: TLabel
            Left = 0
            Top = 0
            Width = 150
            Height = 20
            Align = alLeft
            Alignment = taCenter
            AutoSize = False
            Caption = #44396#49457#50836#49548
            Color = 4800317
            Font.Charset = HANGEUL_CHARSET
            Font.Color = clWhite
            Font.Height = -15
            Font.Name = #47569#51008' '#44256#46357
            Font.Style = [fsBold]
            ParentColor = False
            ParentFont = False
            Transparent = False
            Layout = tlCenter
          end
        end
        object Panel24: TPanel
          Left = 0
          Top = 20
          Width = 609
          Height = 103
          Align = alClient
          BevelOuter = bvNone
          TabOrder = 1
          ExplicitWidth = 462
          object Panel25: TPanel
            Left = 0
            Top = 30
            Width = 609
            Height = 30
            Align = alTop
            BevelOuter = bvNone
            TabOrder = 0
            ExplicitWidth = 462
            object Label3D1: TLabel3D
              Left = 0
              Top = 0
              Width = 301
              Height = 30
              ShowTitle = False
              TitleColor = clGray
              TitleFont.Charset = ANSI_CHARSET
              TitleFont.Color = clWindowText
              TitleFont.Height = -15
              TitleFont.Name = #47569#51008' '#44256#46357
              TitleFont.Style = []
              TitleHeightRatio = 0.200000000000000000
              BorderColor = clBlack
              BorderPenStyle = psSolid
              Border = True
              BorderType = btBorderLine
              BorderLineT = False
              BorderLineR = True
              BorderLineB = True
              BorderLineL = True
              Escapement = 0
              TextStyle = tsNone
              LabelStyle = lsDefault
              EllipsesStyle = esNone
              Shift = 1
              Align = alRight
              Alignment = taCenter
              AutoSize = False
              Caption = '2.4 ~ 2.5 mA'
              Color = 14942207
              Font.Charset = ANSI_CHARSET
              Font.Color = clBlack
              Font.Height = -13
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = [fsBold]
              Layout = tlCenter
              ParentColor = False
              ParentFont = False
              Transparent = False
              ExplicitWidth = 308
            end
            object Label3D18: TLabel3D
              Left = 301
              Top = 0
              Width = 154
              Height = 30
              ShowTitle = False
              TitleColor = clGray
              TitleFont.Charset = ANSI_CHARSET
              TitleFont.Color = clWindowText
              TitleFont.Height = -15
              TitleFont.Name = #47569#51008' '#44256#46357
              TitleFont.Style = []
              TitleHeightRatio = 0.200000000000000000
              BorderColor = clBlack
              BorderPenStyle = psSolid
              Border = True
              BorderType = btBorderLine
              BorderLineT = False
              BorderLineR = True
              BorderLineB = True
              BorderLineL = False
              Escapement = 0
              TextStyle = tsNone
              LabelStyle = lsDefault
              EllipsesStyle = esNone
              Shift = 1
              Align = alRight
              Alignment = taCenter
              AutoSize = False
              Caption = #54032#51221
              Color = 16251129
              Font.Charset = ANSI_CHARSET
              Font.Color = clBlack
              Font.Height = -13
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = [fsBold]
              Layout = tlCenter
              ParentColor = False
              ParentFont = False
              Transparent = False
              ExplicitLeft = 397
            end
            object Label3D29: TLabel3D
              Left = 455
              Top = 0
              Width = 154
              Height = 30
              ShowTitle = False
              TitleColor = clGray
              TitleFont.Charset = ANSI_CHARSET
              TitleFont.Color = clWindowText
              TitleFont.Height = -15
              TitleFont.Name = #47569#51008' '#44256#46357
              TitleFont.Style = []
              TitleHeightRatio = 0.200000000000000000
              BorderColor = clBlack
              BorderPenStyle = psSolid
              Border = True
              BorderType = btBorderLine
              BorderLineT = False
              BorderLineR = True
              BorderLineB = True
              BorderLineL = False
              Escapement = 0
              TextStyle = tsNone
              LabelStyle = lsDefault
              EllipsesStyle = esNone
              Shift = 1
              Align = alRight
              Alignment = taCenter
              AutoSize = False
              Caption = #54032#51221
              Color = 16251129
              Font.Charset = ANSI_CHARSET
              Font.Color = clBlack
              Font.Height = -13
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = [fsBold]
              Layout = tlCenter
              ParentColor = False
              ParentFont = False
              Transparent = False
              ExplicitLeft = 522
              ExplicitTop = -10
            end
          end
          object Panel27: TPanel
            Left = 0
            Top = 60
            Width = 609
            Height = 43
            Align = alClient
            BevelOuter = bvNone
            TabOrder = 1
            ExplicitWidth = 462
            object Label3D34: TLabel3D
              Tag = 222
              Left = 0
              Top = 0
              Width = 147
              Height = 43
              ShowTitle = False
              TitleColor = clGray
              TitleFont.Charset = DEFAULT_CHARSET
              TitleFont.Color = clWindowText
              TitleFont.Height = -11
              TitleFont.Name = 'Tahoma'
              TitleFont.Style = []
              TitleHeightRatio = 0.200000000000000000
              BorderColor = clBlack
              BorderPenStyle = psSolid
              Border = True
              BorderType = btBorderLine
              BorderLineT = False
              BorderLineR = False
              BorderLineB = True
              BorderLineL = True
              Escapement = 0
              TextStyle = tsNone
              LabelStyle = lsDefault
              EllipsesStyle = esNone
              Shift = 1
              Align = alRight
              Alignment = taCenter
              AutoSize = False
              Caption = 'OK'
              Color = 13387839
              Font.Charset = ANSI_CHARSET
              Font.Color = clWhite
              Font.Height = -19
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = [fsBold]
              Layout = tlCenter
              ParentColor = False
              ParentFont = False
              Transparent = False
              ExplicitLeft = 81
              ExplicitWidth = 138
              ExplicitHeight = 31
            end
            object Label3D2: TLabel3D
              Tag = 222
              Left = 147
              Top = 0
              Width = 154
              Height = 43
              ShowTitle = False
              TitleColor = clGray
              TitleFont.Charset = DEFAULT_CHARSET
              TitleFont.Color = clWindowText
              TitleFont.Height = -11
              TitleFont.Name = 'Tahoma'
              TitleFont.Style = []
              TitleHeightRatio = 0.200000000000000000
              BorderColor = clBlack
              BorderPenStyle = psSolid
              Border = True
              BorderType = btBorderLine
              BorderLineT = False
              BorderLineR = True
              BorderLineB = True
              BorderLineL = True
              Escapement = 0
              TextStyle = tsNone
              LabelStyle = lsDefault
              EllipsesStyle = esNone
              Shift = 1
              Align = alRight
              Alignment = taCenter
              AutoSize = False
              Caption = 'OK'
              Color = 13387839
              Font.Charset = ANSI_CHARSET
              Font.Color = clWhite
              Font.Height = -19
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = [fsBold]
              Layout = tlCenter
              ParentColor = False
              ParentFont = False
              Transparent = False
              ExplicitLeft = 243
            end
            object Label3D19: TLabel3D
              Tag = 222
              Left = 301
              Top = 0
              Width = 154
              Height = 43
              ShowTitle = False
              TitleColor = clGray
              TitleFont.Charset = DEFAULT_CHARSET
              TitleFont.Color = clWindowText
              TitleFont.Height = -11
              TitleFont.Name = 'Tahoma'
              TitleFont.Style = []
              TitleHeightRatio = 0.200000000000000000
              BorderColor = clBlack
              BorderPenStyle = psSolid
              Border = True
              BorderType = btBorderLine
              BorderLineT = False
              BorderLineR = True
              BorderLineB = True
              BorderLineL = False
              Escapement = 0
              TextStyle = tsNone
              LabelStyle = lsDefault
              EllipsesStyle = esNone
              Shift = 1
              Align = alRight
              Alignment = taCenter
              AutoSize = False
              Caption = 'OK'
              Color = 13387839
              Font.Charset = ANSI_CHARSET
              Font.Color = clWhite
              Font.Height = -19
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = [fsBold]
              Layout = tlCenter
              ParentColor = False
              ParentFont = False
              Transparent = False
              ExplicitLeft = 332
            end
            object Label3D30: TLabel3D
              Tag = 222
              Left = 455
              Top = 0
              Width = 154
              Height = 43
              ShowTitle = False
              TitleColor = clGray
              TitleFont.Charset = DEFAULT_CHARSET
              TitleFont.Color = clWindowText
              TitleFont.Height = -11
              TitleFont.Name = 'Tahoma'
              TitleFont.Style = []
              TitleHeightRatio = 0.200000000000000000
              BorderColor = clBlack
              BorderPenStyle = psSolid
              Border = True
              BorderType = btBorderLine
              BorderLineT = False
              BorderLineR = True
              BorderLineB = True
              BorderLineL = False
              Escapement = 0
              TextStyle = tsNone
              LabelStyle = lsDefault
              EllipsesStyle = esNone
              Shift = 1
              Align = alRight
              Alignment = taCenter
              AutoSize = False
              Caption = 'OK'
              Color = 13387839
              Font.Charset = ANSI_CHARSET
              Font.Color = clWhite
              Font.Height = -19
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = [fsBold]
              Layout = tlCenter
              ParentColor = False
              ParentFont = False
              Transparent = False
              ExplicitLeft = 535
              ExplicitTop = -7
            end
          end
          object Panel14: TPanel
            Left = 0
            Top = 0
            Width = 609
            Height = 30
            Align = alTop
            BevelOuter = bvNone
            TabOrder = 2
            ExplicitWidth = 462
            object Label3D8: TLabel3D
              Left = 147
              Top = 0
              Width = 154
              Height = 30
              ShowTitle = False
              TitleColor = clGray
              TitleFont.Charset = ANSI_CHARSET
              TitleFont.Color = clWindowText
              TitleFont.Height = -15
              TitleFont.Name = #47569#51008' '#44256#46357
              TitleFont.Style = []
              TitleHeightRatio = 0.200000000000000000
              BorderColor = clBlack
              BorderPenStyle = psSolid
              Border = True
              BorderType = btBorderLine
              BorderLineT = True
              BorderLineR = True
              BorderLineB = True
              BorderLineL = True
              Escapement = 0
              TextStyle = tsNone
              LabelStyle = lsDefault
              EllipsesStyle = esNone
              Shift = 1
              Align = alRight
              Alignment = taCenter
              AutoSize = False
              Caption = 'CTR BUCKLE'
              Color = 16251129
              Font.Charset = ANSI_CHARSET
              Font.Color = clBlack
              Font.Height = -13
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = [fsBold]
              Layout = tlCenter
              ParentColor = False
              ParentFont = False
              Transparent = False
              ExplicitLeft = 300
            end
            object Label3D10: TLabel3D
              Left = 0
              Top = 0
              Width = 147
              Height = 30
              ShowTitle = False
              TitleColor = clGray
              TitleFont.Charset = ANSI_CHARSET
              TitleFont.Color = clWindowText
              TitleFont.Height = -15
              TitleFont.Name = #47569#51008' '#44256#46357
              TitleFont.Style = []
              TitleHeightRatio = 0.200000000000000000
              BorderColor = clBlack
              BorderPenStyle = psSolid
              Border = True
              BorderType = btBorderLine
              BorderLineT = True
              BorderLineR = False
              BorderLineB = True
              BorderLineL = True
              Escapement = 0
              TextStyle = tsNone
              LabelStyle = lsDefault
              EllipsesStyle = esNone
              Shift = 1
              Align = alClient
              Alignment = taCenter
              AutoSize = False
              Caption = 'BUCKLE'
              Color = 16251129
              Font.Charset = ANSI_CHARSET
              Font.Color = clBlack
              Font.Height = -13
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = [fsBold]
              Layout = tlCenter
              ParentColor = False
              ParentFont = False
              Transparent = False
              ExplicitLeft = 3
              ExplicitTop = -1
            end
            object Label3D15: TLabel3D
              Left = 301
              Top = 0
              Width = 154
              Height = 30
              ShowTitle = False
              TitleColor = clGray
              TitleFont.Charset = ANSI_CHARSET
              TitleFont.Color = clWindowText
              TitleFont.Height = -15
              TitleFont.Name = #47569#51008' '#44256#46357
              TitleFont.Style = []
              TitleHeightRatio = 0.200000000000000000
              BorderColor = clBlack
              BorderPenStyle = psSolid
              Border = True
              BorderType = btBorderLine
              BorderLineT = True
              BorderLineR = True
              BorderLineB = True
              BorderLineL = False
              Escapement = 0
              TextStyle = tsNone
              LabelStyle = lsDefault
              EllipsesStyle = esNone
              Shift = 1
              Align = alRight
              Alignment = taCenter
              AutoSize = False
              Caption = 'DTC CLEAR'
              Color = 16251129
              Font.Charset = ANSI_CHARSET
              Font.Color = clBlack
              Font.Height = -13
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = [fsBold]
              Layout = tlCenter
              ParentColor = False
              ParentFont = False
              Transparent = False
              ExplicitLeft = 361
              ExplicitTop = 13
            end
            object Label3D23: TLabel3D
              Left = 455
              Top = 0
              Width = 154
              Height = 30
              ShowTitle = False
              TitleColor = clGray
              TitleFont.Charset = ANSI_CHARSET
              TitleFont.Color = clWindowText
              TitleFont.Height = -15
              TitleFont.Name = #47569#51008' '#44256#46357
              TitleFont.Style = []
              TitleHeightRatio = 0.200000000000000000
              BorderColor = clBlack
              BorderPenStyle = psSolid
              Border = True
              BorderType = btBorderLine
              BorderLineT = True
              BorderLineR = True
              BorderLineB = True
              BorderLineL = False
              Escapement = 0
              TextStyle = tsNone
              LabelStyle = lsDefault
              EllipsesStyle = esNone
              Shift = 1
              Align = alRight
              Alignment = taCenter
              AutoSize = False
              Caption = 'HEADREST '#53685#51204
              Color = 16251129
              Font.Charset = ANSI_CHARSET
              Font.Color = clBlack
              Font.Height = -13
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = [fsBold]
              Layout = tlCenter
              ParentColor = False
              ParentFont = False
              Transparent = False
              ExplicitLeft = 541
              ExplicitTop = 3
            end
          end
        end
      end
      object Panel2: TPanel
        Left = 1
        Top = 170
        Width = 608
        Height = 100
        BevelOuter = bvNone
        TabOrder = 3
        object Panel7: TPanel
          Left = 0
          Top = 0
          Width = 608
          Height = 20
          Align = alTop
          BevelOuter = bvNone
          Color = clWhite
          ParentBackground = False
          TabOrder = 0
          object Label1: TLabel
            Left = 0
            Top = 0
            Width = 150
            Height = 20
            Align = alLeft
            Alignment = taCenter
            AutoSize = False
            Caption = 'IMS'
            Color = 4800317
            Font.Charset = HANGEUL_CHARSET
            Font.Color = clWhite
            Font.Height = -15
            Font.Name = #47569#51008' '#44256#46357
            Font.Style = [fsBold]
            ParentColor = False
            ParentFont = False
            Transparent = False
            Layout = tlCenter
          end
        end
        object Panel9: TPanel
          Left = 0
          Top = 20
          Width = 608
          Height = 80
          Align = alClient
          BevelOuter = bvNone
          TabOrder = 1
          object Panel11: TPanel
            Left = 0
            Top = 0
            Width = 608
            Height = 40
            Align = alTop
            BevelOuter = bvNone
            TabOrder = 0
            object Label3D6: TLabel3D
              Left = 456
              Top = 0
              Width = 152
              Height = 40
              ShowTitle = False
              TitleColor = clGray
              TitleFont.Charset = ANSI_CHARSET
              TitleFont.Color = clWindowText
              TitleFont.Height = -15
              TitleFont.Name = #47569#51008' '#44256#46357
              TitleFont.Style = []
              TitleHeightRatio = 0.200000000000000000
              BorderColor = clBlack
              BorderPenStyle = psSolid
              Border = True
              BorderType = btBorderLine
              BorderLineT = True
              BorderLineR = True
              BorderLineB = True
              BorderLineL = True
              Escapement = 0
              TextStyle = tsNone
              LabelStyle = lsDefault
              EllipsesStyle = esNone
              Shift = 1
              Align = alRight
              Alignment = taCenter
              AutoSize = False
              Caption = 'EASY ACCESS'
              Color = 16251129
              Font.Charset = ANSI_CHARSET
              Font.Color = clBlack
              Font.Height = -13
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = [fsBold]
              Layout = tlCenter
              ParentColor = False
              ParentFont = False
              Transparent = False
              ExplicitLeft = 531
            end
            object Label3D9: TLabel3D
              Left = 0
              Top = 0
              Width = 152
              Height = 40
              ShowTitle = False
              TitleColor = clGray
              TitleFont.Charset = ANSI_CHARSET
              TitleFont.Color = clWindowText
              TitleFont.Height = -15
              TitleFont.Name = #47569#51008' '#44256#46357
              TitleFont.Style = []
              TitleHeightRatio = 0.200000000000000000
              BorderColor = clBlack
              BorderPenStyle = psSolid
              Border = True
              BorderType = btBorderLine
              BorderLineT = True
              BorderLineR = False
              BorderLineB = True
              BorderLineL = True
              Escapement = 0
              TextStyle = tsNone
              LabelStyle = lsDefault
              EllipsesStyle = esNone
              Shift = 1
              Align = alClient
              Alignment = taCenter
              AutoSize = False
              Caption = 'MEM1'
              Color = 16251129
              Font.Charset = ANSI_CHARSET
              Font.Color = clBlack
              Font.Height = -13
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = [fsBold]
              Layout = tlCenter
              ParentColor = False
              ParentFont = False
              Transparent = False
              ExplicitLeft = 60
              ExplicitWidth = 55
            end
            object Label3D14: TLabel3D
              Left = 152
              Top = 0
              Width = 152
              Height = 40
              ShowTitle = False
              TitleColor = clGray
              TitleFont.Charset = ANSI_CHARSET
              TitleFont.Color = clWindowText
              TitleFont.Height = -15
              TitleFont.Name = #47569#51008' '#44256#46357
              TitleFont.Style = []
              TitleHeightRatio = 0.200000000000000000
              BorderColor = clBlack
              BorderPenStyle = psSolid
              Border = True
              BorderType = btBorderLine
              BorderLineT = True
              BorderLineR = True
              BorderLineB = True
              BorderLineL = True
              Escapement = 0
              TextStyle = tsNone
              LabelStyle = lsDefault
              EllipsesStyle = esNone
              Shift = 1
              Align = alRight
              Alignment = taCenter
              AutoSize = False
              Caption = 'MEM2'
              Color = 16251129
              Font.Charset = ANSI_CHARSET
              Font.Color = clBlack
              Font.Height = -13
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = [fsBold]
              Layout = tlCenter
              ParentColor = False
              ParentFont = False
              Transparent = False
              ExplicitLeft = 377
            end
            object Label3D17: TLabel3D
              Left = 304
              Top = 0
              Width = 152
              Height = 40
              ShowTitle = False
              TitleColor = clGray
              TitleFont.Charset = ANSI_CHARSET
              TitleFont.Color = clWindowText
              TitleFont.Height = -15
              TitleFont.Name = #47569#51008' '#44256#46357
              TitleFont.Style = []
              TitleHeightRatio = 0.200000000000000000
              BorderColor = clBlack
              BorderPenStyle = psSolid
              Border = True
              BorderType = btBorderLine
              BorderLineT = True
              BorderLineR = False
              BorderLineB = True
              BorderLineL = False
              Escapement = 0
              TextStyle = tsNone
              LabelStyle = lsDefault
              EllipsesStyle = esNone
              Shift = 1
              Align = alRight
              Alignment = taCenter
              AutoSize = False
              Caption = 'MEM3'
              Color = 16251129
              Font.Charset = ANSI_CHARSET
              Font.Color = clBlack
              Font.Height = -13
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = [fsBold]
              Layout = tlCenter
              ParentColor = False
              ParentFont = False
              Transparent = False
              ExplicitLeft = 454
            end
          end
          object Panel12: TPanel
            Left = 0
            Top = 40
            Width = 608
            Height = 40
            Align = alClient
            BevelOuter = bvNone
            TabOrder = 1
            object Label3D11: TLabel3D
              Tag = 222
              Left = 0
              Top = 0
              Width = 152
              Height = 40
              ShowTitle = False
              TitleColor = clGray
              TitleFont.Charset = DEFAULT_CHARSET
              TitleFont.Color = clWindowText
              TitleFont.Height = -11
              TitleFont.Name = 'Tahoma'
              TitleFont.Style = []
              TitleHeightRatio = 0.200000000000000000
              BorderColor = clBlack
              BorderPenStyle = psSolid
              Border = True
              BorderType = btBorderLine
              BorderLineT = False
              BorderLineR = False
              BorderLineB = True
              BorderLineL = True
              Escapement = 0
              TextStyle = tsNone
              LabelStyle = lsDefault
              EllipsesStyle = esNone
              Shift = 1
              Align = alClient
              Alignment = taCenter
              AutoSize = False
              Caption = 'OK'
              Color = 13387839
              Font.Charset = ANSI_CHARSET
              Font.Color = clWhite
              Font.Height = -19
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = [fsBold]
              Layout = tlCenter
              ParentColor = False
              ParentFont = False
              Transparent = False
              ExplicitLeft = 81
              ExplicitWidth = 138
              ExplicitHeight = 31
            end
            object Label3D12: TLabel3D
              Tag = 222
              Left = 456
              Top = 0
              Width = 152
              Height = 40
              ShowTitle = False
              TitleColor = clGray
              TitleFont.Charset = DEFAULT_CHARSET
              TitleFont.Color = clWindowText
              TitleFont.Height = -11
              TitleFont.Name = 'Tahoma'
              TitleFont.Style = []
              TitleHeightRatio = 0.200000000000000000
              BorderColor = clBlack
              BorderPenStyle = psSolid
              Border = True
              BorderType = btBorderLine
              BorderLineT = False
              BorderLineR = True
              BorderLineB = True
              BorderLineL = True
              Escapement = 0
              TextStyle = tsNone
              LabelStyle = lsDefault
              EllipsesStyle = esNone
              Shift = 1
              Align = alRight
              Alignment = taCenter
              AutoSize = False
              Caption = 'NG'
              Color = 5592575
              Font.Charset = ANSI_CHARSET
              Font.Color = clWhite
              Font.Height = -19
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = [fsBold]
              Layout = tlCenter
              ParentColor = False
              ParentFont = False
              Transparent = False
              ExplicitLeft = 531
            end
            object Label3D20: TLabel3D
              Tag = 222
              Left = 152
              Top = 0
              Width = 152
              Height = 40
              ShowTitle = False
              TitleColor = clGray
              TitleFont.Charset = DEFAULT_CHARSET
              TitleFont.Color = clWindowText
              TitleFont.Height = -11
              TitleFont.Name = 'Tahoma'
              TitleFont.Style = []
              TitleHeightRatio = 0.200000000000000000
              BorderColor = clBlack
              BorderPenStyle = psSolid
              Border = True
              BorderType = btBorderLine
              BorderLineT = False
              BorderLineR = True
              BorderLineB = True
              BorderLineL = False
              Escapement = 0
              TextStyle = tsNone
              LabelStyle = lsDefault
              EllipsesStyle = esNone
              Shift = 1
              Align = alRight
              Alignment = taCenter
              AutoSize = False
              Caption = 'OK'
              Color = 13387839
              Font.Charset = ANSI_CHARSET
              Font.Color = clWhite
              Font.Height = -19
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = [fsBold]
              Layout = tlCenter
              ParentColor = False
              ParentFont = False
              Transparent = False
              ExplicitLeft = 377
            end
            object Label3D21: TLabel3D
              Tag = 222
              Left = 304
              Top = 0
              Width = 152
              Height = 40
              ShowTitle = False
              TitleColor = clGray
              TitleFont.Charset = DEFAULT_CHARSET
              TitleFont.Color = clWindowText
              TitleFont.Height = -11
              TitleFont.Name = 'Tahoma'
              TitleFont.Style = []
              TitleHeightRatio = 0.200000000000000000
              BorderColor = clBlack
              BorderPenStyle = psSolid
              Border = True
              BorderType = btBorderLine
              BorderLineT = False
              BorderLineR = False
              BorderLineB = True
              BorderLineL = False
              Escapement = 0
              TextStyle = tsNone
              LabelStyle = lsDefault
              EllipsesStyle = esNone
              Shift = 1
              Align = alRight
              Alignment = taCenter
              AutoSize = False
              Caption = 'OK'
              Color = 13387839
              Font.Charset = ANSI_CHARSET
              Font.Color = clWhite
              Font.Height = -19
              Font.Name = #47569#51008' '#44256#46357
              Font.Style = [fsBold]
              Layout = tlCenter
              ParentColor = False
              ParentFont = False
              Transparent = False
              ExplicitLeft = 454
            end
          end
        end
      end
    end
  end
  object pnlCon: TPanel [8]
    Left = 1694
    Top = 194
    Width = 226
    Height = 735
    Align = alRight
    BevelOuter = bvNone
    Color = 15789806
    ParentBackground = False
    TabOrder = 5
    object lblConName: TLabel3D
      Left = 0
      Top = 26
      Width = 226
      Height = 24
      ShowTitle = False
      TitleColor = clGray
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'Tahoma'
      TitleFont.Style = []
      TitleHeightRatio = 0.200000000000000000
      BorderColor = clGray
      BorderPenStyle = psSolid
      Border = True
      BorderType = btBorderLine
      BorderLineT = True
      BorderLineR = False
      BorderLineB = True
      BorderLineL = False
      Escapement = 0
      TextStyle = tsNone
      LabelStyle = lsDefault
      EllipsesStyle = esNone
      Shift = 1
      Align = alTop
      Alignment = taCenter
      AutoSize = False
      Caption = 'JG1'
      Color = clWhite
      Font.Charset = ANSI_CHARSET
      Font.Color = clNavy
      Font.Height = -13
      Font.Name = #47569#51008' '#44256#46357
      Font.Style = []
      Layout = tlCenter
      ParentColor = False
      ParentFont = False
      Transparent = False
      ExplicitLeft = 16
      ExplicitTop = 9
    end
    object sbtnCon: TSpeedButton
      Left = 175
      Top = 692
      Width = 46
      Height = 38
      Flat = True
      Glyph.Data = {
        06070000424D0607000000000000360400002800000022000000140000000100
        080000000000D0020000120B0000120B00000001000000000000000000000101
        0100020202000303030004040400050505000606060007070700080808000909
        09000A0A0A000B0B0B000C0C0C000D0D0D000E0E0E000F0F0F00101010001111
        1100121212001313130014141400151515001616160017171700181818001919
        19001A1A1A001B1B1B001C1C1C001D1D1D001E1E1E001F1F1F00202020002121
        2100222222002323230024242400252525002626260027272700282828002929
        29002A2A2A002B2B2B002C2C2C002D2D2D002E2E2E002F2F2F00303030003131
        3100323232003333330034343400353535003636360037373700383838003939
        39003A3A3A003B3B3B003C3C3C003D3D3D003E3E3E003F3F3F00404040004141
        4100424242004343430044444400454545004646460047474700484848004949
        49004A4A4A004B4B4B004C4C4C004D4D4D004E4E4E004F4F4F00505050005151
        5100525252005353530054545400555555005656560057575700585858005959
        59005A5A5A005B5B5B005C5C5C005D5D5D005E5E5E005F5F5F00606060006161
        6100626262006363630064646400656565006666660067676700686868006969
        69006A6A6A006B6B6B006C6C6C006D6D6D006E6E6E006F6F6F00707070007171
        7100727272007373730074747400757575007676760077777700787878007979
        79007A7A7A007B7B7B007C7C7C007D7D7D007E7E7E007F7F7F00808080008181
        8100828282008383830084848400858585008686860087878700888888008989
        89008A8A8A008B8B8B008C8C8C008D8D8D008E8E8E008F8F8F00909090009191
        9100929292009393930094949400959595009696960097979700989898009999
        99009A9A9A009B9B9B009C9C9C009D9D9D009E9E9E009F9F9F00A0A0A000A1A1
        A100A2A2A200A3A3A300A4A4A400A5A5A500A6A6A600A7A7A700A8A8A800A9A9
        A900AAAAAA00ABABAB00ACACAC00ADADAD00AEAEAE00AFAFAF00B0B0B000B1B1
        B100B2B2B200B3B3B300B4B4B400B5B5B500B6B6B600B7B7B700B8B8B800B9B9
        B900BABABA00BBBBBB00BCBCBC00BDBDBD00BEBEBE00BFBFBF00C0C0C000C1C1
        C100C2C2C200C3C3C300C4C4C400C5C5C500C6C6C600C7C7C700C8C8C800C9C9
        C900CACACA00CBCBCB00CCCCCC00CDCDCD00CECECE00CFCFCF00D0D0D000D1D1
        D100D2D2D200D3D3D300D4D4D400D5D5D500D6D6D600D7D7D700D8D8D800D9D9
        D900DADADA00DBDBDB00DCDCDC00DDDDDD00DEDEDE00DFDFDF00E0E0E000E1E1
        E100E2E2E200E3E3E300E4E4E400E5E5E500E6E6E600E7E7E700E8E8E800E9E9
        E900EAEAEA00EBEBEB00ECECEC00EDEDED00EEEEEE00EFEFEF00F0F0F000F1F1
        F100F2F2F200F3F3F300F4F4F400F5F5F500F6F6F600F7F7F700F8F8F800F9F9
        F900FAFAFA00FBFBFB00FCFCFC00FDFDFD00FEFEFE00FFFFFF00FFE7370E1414
        1414141414141414141414141414141414141414141414140F42E6FE0000F156
        0024310302263A3433373433373334363335363236363239220109361E0058FA
        00009B0026CBDB0D0FB6FFF2F0F6F2F1F7F1F2F6EFF3F6EFF5F5EFFF9C0526F3
        B71700E3000075003FEDF0100FB2EEE7ECE3EAEAE3EBEAE3ECE7E4ECE5E6ECF6
        950426FFE23400DB00007B003BEAE81400111817181617171617171618171618
        161618190D0024F9DF3000DE00007D003FEEE0220D0E0B0C0C0B0C0C0B0C0C0B
        0C0B0B0D0B0B0D0A0E0E30FADF3000DE00007B003AE7FFC5BFC6BFC2C5BEC3C4
        BEC4C3BEC6C2BEC5C1C0C6BFC2C5C8FFDE3000DD00007B0041ECFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE13500DD00007D0017595C5C
        5C575D5B595E5A595F5A5A5D585B5D585C5D585D5A585D60521100DE00007B01
        00000000000000000000000000000000000000000000000000000000000000DC
        00007C00228076070761943100458F53001B807C0E03628E2D00389655021586
        761A00DE00007C004AF6FB1213CAFF63008BFFAF0040F5EC1F09BEFF620075FF
        A9082BFFE73B00DD00007B002594990A0A7DAC36004DB06F00269C93110175AF
        3A0049B7660317A2901F00DD00007D0000000000000000000000000000000000
        000000000000000000000000000000DD00007C000B292A0303232F0F0015311E
        000B2B2905012130100014331D01062D280900DD000075003DEAF51012C7FF5A
        007EFFAE003DF5EB1C04B9FF5D0073FFA30526FFE03300DC0000AC001FB2C70D
        0DA1ED50006EE78D002FCDC718059EE64D005EF1880423DCA21100E50000F574
        00111C020117240C0010221200061F1F030118230B000C241400061F0E0072FB
        0000FFEC6F180E1413101012141010111411101012131110111411101012130D
        1C78EFFF0000FFFFEFA48D919290919090929090929090929090928F91929091
        9090918DABF0FFFF0000}
      OnClick = sbtnConClick
    end
    object sgCon: TStringGrid
      Left = 0
      Top = 50
      Width = 226
      Height = 591
      Align = alTop
      BevelInner = bvNone
      BevelOuter = bvNone
      BorderStyle = bsNone
      Color = 15789806
      ColCount = 4
      Ctl3D = False
      DefaultColWidth = 50
      DefaultRowHeight = 17
      DefaultDrawing = False
      DoubleBuffered = True
      DrawingStyle = gdsClassic
      Enabled = False
      FixedColor = clGray
      FixedCols = 0
      RowCount = 35
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing]
      ParentCtl3D = False
      ParentDoubleBuffered = False
      ScrollBars = ssNone
      TabOrder = 0
      OnDrawCell = sgConDrawCell
      ColWidths = (
        38
        87
        50
        50)
    end
    object tcCon: TTabControl
      Left = 0
      Top = 0
      Width = 226
      Height = 26
      Align = alTop
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = #47569#51008' '#44256#46357
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      Tabs.Strings = (
        'MAIN')
      TabIndex = 0
      TabWidth = 60
      OnChange = tcConChange
    end
  end
  inherited pnlMenu: TPanel
    Width = 1920
    ExplicitWidth = 1920
    inherited sbtnModel: TSpeedButton
      Left = 1376
      OnClick = sbtnModelClick
      ExplicitLeft = 1280
      ExplicitTop = 6
    end
    inherited sbtnReference: TSpeedButton
      Left = 1496
      OnClick = sbtnReferenceClick
      ExplicitLeft = 1496
    end
    inherited sbtnRetrieve: TSpeedButton
      Left = 1616
      OnClick = sbtnRetrieveClick
      ExplicitLeft = 1616
    end
    inherited sbtnExit: TSpeedButton
      Left = 1736
      OnClick = sbtnExitClick
      ExplicitLeft = 1736
    end
  end
  inherited tmrHideMsg: TTimer
    Left = 544
    Top = 184
  end
  object tmrPoll: TTimer
    Enabled = False
    Interval = 10
    OnTimer = tmrPollTimer
    Left = 661
    Top = 183
  end
  object tmrShow: TTimer
    Enabled = False
    Interval = 3000
    OnTimer = tmrShowTimer
    Left = 599
    Top = 187
  end
  object tmrMain: TTimer
    Enabled = False
    Interval = 200
    OnTimer = tmrMainTimer
    Left = 482
    Top = 195
  end
  object tmrDiskChk: TTimer
    Interval = 3600000
    OnTimer = tmrDiskChkTimer
    Left = 739
    Top = 217
  end
end
