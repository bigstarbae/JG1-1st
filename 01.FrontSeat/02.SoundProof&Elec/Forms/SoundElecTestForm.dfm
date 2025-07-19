inherited frmSoundElec: TfrmSoundElec
  Top = 60
  BorderStyle = bsNone
  Caption = 'frmSoundElec'
  ClientHeight = 1080
  ClientWidth = 1920
  HelpFile = '1080'
  Position = poDesigned
  WindowState = wsNormal
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnResize = FormResize
  ExplicitTop = -25
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
      Left = 258
      Top = 4
      OnClick = lblSimLanInModeClick
      ExplicitLeft = 258
      ExplicitTop = 4
    end
  end
  inherited pnlStatus: TPanel
    Top = 1056
    Width = 1920
    TabOrder = 8
    ExplicitTop = 1056
    ExplicitWidth = 1920
    object lblWorkMonitor: TLabel [2]
      Left = 1659
      Top = 0
      Width = 107
      Height = 24
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
      ExplicitHeight = 15
    end
    object lblMemory: TLabel [3]
      Left = 1601
      Top = 0
      Width = 58
      Height = 24
      Align = alRight
      Caption = 'lblMemory'
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clGray
      Font.Height = -12
      Font.Name = #47569#51008' '#44256#46357
      Font.Style = []
      ParentFont = False
      Layout = tlCenter
      ExplicitHeight = 15
    end
    inherited pnlCommStatus: TPanel
      inherited Label2: TLabel
        Height = 24
      end
      inherited abCAN: TAbLED
        Visible = False
      end
    end
    inherited pnlExtra: TPanel
      Left = 1766
      Width = 154
      ExplicitLeft = 1766
      ExplicitWidth = 154
      object lblCycleTime: TLabel
        Left = 0
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
      Left = 1503
      Width = 190
      ExplicitLeft = 1503
      ExplicitWidth = 190
    end
    inline fmModelInfo: TMdllInfoFrame
      Left = 0
      Top = 0
      Width = 1503
      Height = 114
      Align = alClient
      TabOrder = 0
      ExplicitWidth = 1503
      ExplicitHeight = 114
      inherited pnlMdlInfo: TPanel
        Width = 1503
        Height = 114
        ExplicitWidth = 1503
        ExplicitHeight = 114
        inherited pnlPartInfo: TPanel
          Height = 114
          ExplicitHeight = 114
          inherited lblLotNo: TLabel3D
            Height = 37
            ExplicitHeight = 37
          end
        end
        inherited pnlDriver: TPanel
          Height = 114
          ExplicitHeight = 114
          inherited pnl3: TPanel
            Height = 98
            ExplicitHeight = 98
            inherited lblDrv: TLabel3D
              ExplicitLeft = 6
              ExplicitTop = 24
              ExplicitWidth = 140
            end
            inherited lblPsg: TLabel3D
              Height = 50
              ExplicitLeft = 6
              ExplicitTop = 47
              ExplicitHeight = 50
            end
          end
        end
        inherited pnlOpt: TPanel
          Width = 534
          Height = 114
          Align = alLeft
          ExplicitWidth = 534
          ExplicitHeight = 114
          inherited pnlOptTop: TPanel
            Width = 534
            Height = 114
            ExplicitWidth = 534
            ExplicitHeight = 114
            inherited lblECU: TLabel3D
              Height = 114
              ExplicitHeight = 112
            end
            inherited lblIMS: TLabel3D
              Height = 114
              ExplicitHeight = 112
            end
            inherited lblCushLeg: TLabel3D
              Height = 114
              ExplicitWidth = 109
              ExplicitHeight = 112
            end
            inherited lblODS: TLabel3D
              Height = 114
              ExplicitHeight = 112
            end
            inherited lblACPT: TLabel3D
              Height = 114
              ExplicitHeight = 112
            end
            inherited lbl17MY: TLabel3D
              Width = 99
              Height = 114
              ExplicitWidth = 107
              ExplicitHeight = 114
            end
            inherited lblPE: TLabel3D
              Height = 114
              ExplicitHeight = 114
            end
          end
        end
        inherited pnlPos: TPanel
          Height = 114
          ExplicitHeight = 114
          inherited pnl2: TPanel
            Height = 98
            ExplicitHeight = 98
            inherited lblRH: TLabel3D
              Height = 50
              ExplicitHeight = 50
            end
          end
        end
        inherited pnlClass: TPanel
          Height = 114
          ExplicitHeight = 114
          inherited pnlClassTitle: TPanel
            Height = 17
            ExplicitHeight = 17
          end
          inherited pnlClassClient: TPanel
            Top = 17
            Height = 97
            ExplicitTop = 17
            ExplicitHeight = 97
            inherited pnlClassVal: TPanel
              Height = 97
              ExplicitHeight = 97
              inherited pnlSeatSpec: TPanel
                Height = 97
                ExplicitHeight = 97
                inherited lblLONG_S: TLabel3D
                  Top = 32
                  ExplicitLeft = 0
                  ExplicitTop = 31
                end
                inherited lblSTD: TLabel3D
                  Height = 32
                  ExplicitHeight = 32
                end
                inherited lblSwivel: TLabel3D
                  Top = 65
                  ExplicitTop = 65
                end
              end
            end
          end
        end
        inherited pnl4: TPanel
          Height = 114
          ExplicitHeight = 114
          inherited pnlBuckle: TPanel
            Height = 98
            ExplicitHeight = 98
            inherited lblBuckleCurr: TLabel3D
              Height = 32
              ExplicitHeight = 32
            end
          end
        end
        inherited pnl5: TPanel
          Height = 114
          ExplicitHeight = 114
          inherited pnl6: TPanel
            Height = 98
            ExplicitHeight = 98
            inherited lblHV: TLabel3D
              Height = 32
              ExplicitHeight = 32
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
      Width = 670
      Align = alLeft
      ExplicitWidth = 670
      object Label19: TLabel
        Left = 209
        Top = 28
        Width = 39
        Height = 20
        Alignment = taRightJustify
        Caption = 'MAIN'
        Font.Charset = HANGEUL_CHARSET
        Font.Color = 14145495
        Font.Height = -15
        Font.Name = #47569#51008' '#44256#46357
        Font.Style = []
        ParentFont = False
      end
      object lblMainCurr: TLabel
        Left = 262
        Top = 21
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
      end
      object Label99: TLabel
        Left = 319
        Top = 34
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
      object Label96: TLabel
        Left = 18
        Top = 70
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
        Left = 91
        Top = 61
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
        Left = 156
        Top = 74
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
        Left = 17
        Top = 24
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
        Left = 91
        Top = 18
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
        Left = 156
        Top = 32
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
      object Label9: TLabel
        Left = 494
        Top = 33
        Width = 45
        Height = 20
        Alignment = taRightJustify
        Caption = #49548#51020#44592
        Font.Charset = HANGEUL_CHARSET
        Font.Color = 14145495
        Font.Height = -15
        Font.Name = #47569#51008' '#44256#46357
        Font.Style = []
        ParentFont = False
      end
      object lblNoise: TLabel
        Left = 547
        Top = 24
        Width = 53
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
      end
      object Label12: TLabel
        Left = 614
        Top = 37
        Width = 25
        Height = 13
        AutoSize = False
        Caption = 'db'
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clSilver
        Font.Height = -12
        Font.Name = #47569#51008' '#44256#46357
        Font.Style = []
        ParentFont = False
        Transparent = True
        Layout = tlCenter
      end
      object lblLaser1: TLabel
        Left = 494
        Top = 67
        Width = 45
        Height = 20
        Alignment = taRightJustify
        Caption = #47112#51060#51256
        Font.Charset = HANGEUL_CHARSET
        Font.Color = 14145495
        Font.Height = -15
        Font.Name = #47569#51008' '#44256#46357
        Font.Style = []
        ParentFont = False
      end
      object Label6: TLabel
        Left = 193
        Top = 68
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
      end
      object lblMotorCurr: TLabel
        Left = 261
        Top = 59
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
      end
      object Label14: TLabel
        Left = 319
        Top = 71
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
      object Label15: TLabel
        Left = 612
        Top = 72
        Width = 25
        Height = 13
        AutoSize = False
        Caption = 'mm'
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clSilver
        Font.Height = -12
        Font.Name = #47569#51008' '#44256#46357
        Font.Style = []
        ParentFont = False
        Transparent = True
        Layout = tlCenter
      end
      object Label16: TLabel
        Left = 346
        Top = 32
        Width = 48
        Height = 20
        Alignment = taRightJustify
        Caption = 'SHVU1'
        Font.Charset = HANGEUL_CHARSET
        Font.Color = 14145495
        Font.Height = -15
        Font.Name = #47569#51008' '#44256#46357
        Font.Style = []
        ParentFont = False
      end
      object Label18: TLabel
        Left = 466
        Top = 36
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
      object Label20: TLabel
        Left = 466
        Top = 71
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
      object lblSHVU2Curr: TLabel
        Left = 408
        Top = 60
        Width = 47
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
      object Label22: TLabel
        Left = 346
        Top = 67
        Width = 48
        Height = 20
        Alignment = taRightJustify
        Caption = 'SHVU2'
        Font.Charset = HANGEUL_CHARSET
        Font.Color = 14145495
        Font.Height = -15
        Font.Name = #47569#51008' '#44256#46357
        Font.Style = []
        ParentFont = False
      end
      object lblLaserDistance: TLabel
        Left = 549
        Top = 59
        Width = 52
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
      end
      object lblSHVU1Curr: TLabel
        Left = 410
        Top = 24
        Width = 47
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
      object lblAPT: TLabel
        Left = 599
        Top = 6
        Width = 53
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
      end
    end
    inherited pnlLog: TPanel
      Left = 1265
      Width = 432
      Align = alClient
      ExplicitLeft = 1265
      ExplicitWidth = 432
      inherited Label3: TLabel
        Width = 432
        ExplicitWidth = 566
      end
      inherited lbLog: TListBox
        Width = 432
        ExplicitWidth = 432
      end
    end
    inherited pnlWorkStatus: TPanel
      Left = 670
      Width = 595
      Align = alLeft
      ExplicitLeft = 670
      ExplicitWidth = 595
      inherited lblStatus: TLabel3D
        Width = 595
        ExplicitLeft = 6
        ExplicitTop = 15
        ExplicitWidth = 381
      end
      inherited pnlWorkStatusTitle: TPanel
        Width = 595
        ExplicitWidth = 595
        inherited btnCanRDebug: TSpeedButton
          OnClick = btnCanRDebugClick
        end
        inherited btnCanWDebug: TSpeedButton
          OnClick = btnCanWDebugClick
        end
      end
    end
    inherited pnlPdtCnt: TPanel
      Left = 1697
      Width = 223
      ExplicitLeft = 1697
      ExplicitWidth = 223
      inherited Panel3: TPanel
        Width = 223
        ExplicitWidth = 223
        inherited lblOK: TLabel
          Left = 98
          ExplicitLeft = 98
        end
        inherited Label4: TLabel
          ExplicitLeft = 53
          ExplicitTop = 27
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
      Left = 114
      Top = -2
      Height = 25
      Visible = True
      ExplicitLeft = 114
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
    object pnlLeft: TPanel
      Left = 0
      Top = 0
      Width = 1043
      Height = 735
      Margins.Left = 0
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alLeft
      BevelEdges = []
      BevelOuter = bvNone
      Color = clWhite
      Padding.Left = 5
      Padding.Top = 5
      ParentBackground = False
      TabOrder = 0
      inline fmSMTSlide: TSeatMtrTestFrme
        Left = 5
        Top = 5
        Width = 1038
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
        ExplicitLeft = 5
        ExplicitTop = 5
        ExplicitWidth = 1038
        ExplicitHeight = 175
        inherited pnlBase: TPanel
          Width = 1038
          Height = 175
          ExplicitWidth = 1038
          ExplicitHeight = 175
          inherited Splitter: TSplitter
            Height = 143
            ExplicitHeight = 131
          end
          inherited pnlTop: TPanel
            Width = 1030
            ExplicitWidth = 1030
            inherited shpTopLine: TShape
              Width = 1030
              ExplicitWidth = 788
            end
            inherited sbtnViewMode: TSpeedButton
              Left = 994
              OnClick = fmSMTSlidesbtnViewModeClick
              ExplicitLeft = 752
            end
            inherited pnlLegend: TPanel
              Width = 729
              ExplicitWidth = 729
            end
          end
          inherited pnlData: TPanel
            Height = 143
            ExplicitHeight = 143
          end
          inherited pnlGrp: TPanel
            Height = 143
            ExplicitHeight = 143
            inherited grpData: TFaGraphEx
              Height = 133
              ExplicitTop = 1
              ExplicitHeight = 118
            end
          end
        end
      end
      inline fmSMTHeight: TSeatMtrTestFrme
        Left = 5
        Top = 355
        Width = 1038
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
        ExplicitLeft = 5
        ExplicitTop = 355
        ExplicitWidth = 1038
        ExplicitHeight = 175
        inherited pnlBase: TPanel
          Width = 1038
          Height = 175
          ExplicitWidth = 1038
          ExplicitHeight = 175
          inherited Splitter: TSplitter
            Height = 143
            ExplicitHeight = 131
          end
          inherited pnlTop: TPanel
            Width = 1030
            ExplicitWidth = 1030
            inherited shpTopLine: TShape
              Width = 1030
              ExplicitWidth = 788
            end
            inherited sbtnViewMode: TSpeedButton
              Left = 994
              ExplicitLeft = 752
            end
            inherited pnlLegend: TPanel
              Width = 729
              ExplicitWidth = 729
            end
          end
          inherited pnlData: TPanel
            Height = 143
            ExplicitHeight = 143
          end
          inherited pnlGrp: TPanel
            Height = 143
            ExplicitHeight = 143
            inherited grpData: TFaGraphEx
              Height = 133
              ExplicitHeight = 121
            end
          end
        end
      end
      inline fmSMTTilt: TSeatMtrTestFrme
        Left = 5
        Top = 180
        Width = 1038
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
        ExplicitLeft = 5
        ExplicitTop = 180
        ExplicitWidth = 1038
        ExplicitHeight = 175
        inherited pnlBase: TPanel
          Width = 1038
          Height = 175
          ExplicitWidth = 1038
          ExplicitHeight = 175
          inherited Splitter: TSplitter
            Height = 143
            ExplicitHeight = 131
          end
          inherited pnlTop: TPanel
            Width = 1030
            ExplicitWidth = 1030
            inherited shpTopLine: TShape
              Width = 1030
              ExplicitWidth = 788
            end
            inherited sbtnViewMode: TSpeedButton
              Left = 994
              ExplicitLeft = 752
            end
            inherited pnlLegend: TPanel
              Width = 729
              ExplicitWidth = 729
            end
          end
          inherited pnlData: TPanel
            Height = 143
            ExplicitHeight = 143
          end
          inherited pnlGrp: TPanel
            Height = 143
            ExplicitHeight = 143
            inherited grpData: TFaGraphEx
              Height = 133
              ExplicitHeight = 121
            end
          end
        end
      end
      inline fmSMTLeg: TSeatMtrTestFrme
        Left = 5
        Top = 530
        Width = 1038
        Height = 170
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
        ExplicitLeft = 5
        ExplicitTop = 530
        ExplicitWidth = 1038
        ExplicitHeight = 170
        inherited pnlBase: TPanel
          Width = 1038
          Height = 170
          ExplicitWidth = 1038
          ExplicitHeight = 170
          inherited Splitter: TSplitter
            Height = 138
            ExplicitHeight = 151
          end
          inherited pnlTop: TPanel
            Width = 1030
            ExplicitWidth = 1030
            inherited shpTopLine: TShape
              Width = 1030
              ExplicitWidth = 788
            end
            inherited sbtnViewMode: TSpeedButton
              Left = 994
              ExplicitLeft = 752
            end
            inherited pnlLegend: TPanel
              Width = 729
              ExplicitWidth = 729
            end
          end
          inherited pnlData: TPanel
            Height = 138
            ExplicitHeight = 138
          end
          inherited pnlGrp: TPanel
            Height = 138
            ExplicitHeight = 138
            inherited grpData: TFaGraphEx
              Height = 128
              ExplicitHeight = 141
            end
          end
        end
      end
      inline fmSMTSwivel: TSeatMtrTestFrme
        Left = 5
        Top = 700
        Width = 1038
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
        TabOrder = 4
        Visible = False
        ExplicitLeft = 5
        ExplicitTop = 700
        ExplicitWidth = 1038
        ExplicitHeight = 175
        inherited pnlBase: TPanel
          Width = 1038
          Height = 175
          ExplicitWidth = 1038
          ExplicitHeight = 175
          inherited Splitter: TSplitter
            Height = 143
            ExplicitHeight = 151
          end
          inherited pnlTop: TPanel
            Width = 1030
            ExplicitWidth = 1030
            inherited shpTopLine: TShape
              Width = 1030
              ExplicitWidth = 788
            end
            inherited sbtnViewMode: TSpeedButton
              Left = 994
              ExplicitLeft = 752
            end
            inherited pnlLegend: TPanel
              Width = 729
              ExplicitWidth = 729
            end
          end
          inherited pnlData: TPanel
            Height = 143
            ExplicitHeight = 143
          end
          inherited pnlGrp: TPanel
            Height = 143
            ExplicitHeight = 143
            inherited grpData: TFaGraphEx
              Height = 133
              ExplicitHeight = 141
            end
          end
        end
      end
    end
    object pnlRight: TPanel
      Left = 1043
      Top = 0
      Width = 650
      Height = 735
      Margins.Left = 0
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alClient
      BevelOuter = bvNone
      Padding.Left = 10
      Padding.Top = 10
      Padding.Bottom = 5
      TabOrder = 1
      object pnlHV: TPanel
        Left = 10
        Top = 521
        Width = 640
        Height = 209
        Align = alBottom
        BevelOuter = bvNone
        Padding.Right = 10
        TabOrder = 0
        inline fmHtrHost: THVDatFrame
          Left = 0
          Top = 0
          Width = 310
          Height = 209
          Align = alLeft
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
          ExplicitHeight = 209
          inherited pnlHeader: TPanel
            inherited lblPosName: TLabel
              Width = 193
              Caption = 'HEATER'
              ExplicitLeft = -2
              ExplicitTop = -3
              ExplicitWidth = 193
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
        inline fmVntHost: THVDatFrame
          Left = 320
          Top = 0
          Width = 310
          Height = 209
          Align = alRight
          Color = clWhite
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentBackground = False
          ParentColor = False
          ParentFont = False
          TabOrder = 1
          ExplicitLeft = 320
          ExplicitHeight = 209
          inherited pnlHeader: TPanel
            inherited lblPosName: TLabel
              Width = 193
              Caption = 'VENT.'
              ExplicitLeft = -4
              ExplicitTop = -3
              ExplicitWidth = 193
            end
            inherited lblVentSensor: TLabel3D
              ExplicitTop = 2
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
      object pnlMemory: TPanel
        Left = 10
        Top = 192
        Width = 640
        Height = 137
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 1
        object pnl2: TPanel
          Left = 0
          Top = 0
          Width = 640
          Height = 24
          Align = alTop
          BevelOuter = bvNone
          Color = clWhite
          ParentBackground = False
          TabOrder = 0
          object lblName3: TLabel
            Left = 0
            Top = 0
            Width = 193
            Height = 24
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
        object pnlTOP10: TPanel
          Left = 0
          Top = 24
          Width = 640
          Height = 30
          Align = alTop
          BevelOuter = bvNone
          Caption = 'pnlTOP1'
          TabOrder = 1
          object lbl18: TLabel3D
            Left = 0
            Top = 0
            Width = 157
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
            BorderLineB = False
            BorderLineL = True
            Escapement = 0
            TextStyle = tsNone
            LabelStyle = lsDefault
            EllipsesStyle = esNone
            Shift = 1
            Align = alLeft
            Alignment = taCenter
            AutoSize = False
            Caption = 'MEM1'
            Color = 16251129
            FocusControl = fmHtrHost
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
          object lbl23: TLabel3D
            Left = 157
            Top = 0
            Width = 157
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
            BorderLineB = False
            BorderLineL = False
            Escapement = 0
            TextStyle = tsNone
            LabelStyle = lsDefault
            EllipsesStyle = esNone
            Shift = 1
            Align = alLeft
            Alignment = taCenter
            AutoSize = False
            Caption = 'MEM2'
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
          object lbl24: TLabel3D
            Left = 314
            Top = 0
            Width = 157
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
            BorderLineB = False
            BorderLineL = False
            Escapement = 0
            TextStyle = tsNone
            LabelStyle = lsDefault
            EllipsesStyle = esNone
            Shift = 1
            Align = alLeft
            Alignment = taCenter
            AutoSize = False
            Caption = 'MEM3'
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
          object lbl25: TLabel3D
            Left = 471
            Top = 0
            Width = 159
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
            BorderLineB = False
            BorderLineL = False
            Escapement = 0
            TextStyle = tsNone
            LabelStyle = lsDefault
            EllipsesStyle = esNone
            Shift = 1
            Align = alLeft
            Alignment = taCenter
            AutoSize = False
            Caption = 'EASY ACCESS'
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
        end
        object pnlTOP12: TPanel
          Left = 0
          Top = 54
          Width = 640
          Height = 60
          Margins.Left = 0
          Margins.Top = 0
          Margins.Right = 0
          Margins.Bottom = 0
          Align = alTop
          BevelOuter = bvNone
          Caption = 'pnlTOP2'
          TabOrder = 2
          object lblEasyAccess: TLabel3D
            Tag = 222
            Left = 471
            Top = 0
            Width = 159
            Height = 60
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
            Caption = 'OK'
            Color = 16723245
            Font.Charset = ANSI_CHARSET
            Font.Color = clWhite
            Font.Height = -35
            Font.Name = #47569#51008' '#44256#46357
            Font.Style = [fsBold]
            Layout = tlCenter
            ParentColor = False
            ParentFont = False
            Transparent = False
            ExplicitLeft = 470
          end
          object lblMem3: TLabel3D
            Tag = 222
            Left = 314
            Top = 0
            Width = 157
            Height = 60
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
            Caption = 'OK'
            Color = 16723245
            Font.Charset = ANSI_CHARSET
            Font.Color = clWhite
            Font.Height = -35
            Font.Name = #47569#51008' '#44256#46357
            Font.Style = [fsBold]
            Layout = tlCenter
            ParentColor = False
            ParentFont = False
            Transparent = False
            ExplicitLeft = 311
            ExplicitTop = 6
          end
          object lblMem2: TLabel3D
            Tag = 222
            Left = 157
            Top = 0
            Width = 157
            Height = 60
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
            Caption = 'OK'
            Color = 16723245
            Font.Charset = ANSI_CHARSET
            Font.Color = clWhite
            Font.Height = -35
            Font.Name = #47569#51008' '#44256#46357
            Font.Style = [fsBold]
            Layout = tlCenter
            ParentColor = False
            ParentFont = False
            Transparent = False
          end
          object lblMem1: TLabel3D
            Tag = 222
            Left = 0
            Top = 0
            Width = 157
            Height = 60
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
            Caption = 'OK'
            Color = 16723245
            Font.Charset = ANSI_CHARSET
            Font.Color = clWhite
            Font.Height = -35
            Font.Name = #47569#51008' '#44256#46357
            Font.Style = [fsBold]
            Layout = tlCenter
            ParentColor = False
            ParentFont = False
            Transparent = False
          end
        end
      end
      object pnlMemory2: TPanel
        Left = 10
        Top = 10
        Width = 640
        Height = 182
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 2
        object pnl6: TPanel
          Left = 0
          Top = 0
          Width = 640
          Height = 24
          Align = alTop
          BevelOuter = bvNone
          Color = clWhite
          ParentBackground = False
          TabOrder = 0
          object lblName7: TLabel
            Left = 0
            Top = 0
            Width = 194
            Height = 24
            Align = alLeft
            Alignment = taCenter
            AutoSize = False
            Caption = 'ECU '#51221#48372
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
        object pnlTOP19: TPanel
          Left = 0
          Top = 24
          Width = 640
          Height = 30
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 1
          object lbl20: TLabel3D
            Left = 0
            Top = 0
            Width = 314
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
            BorderLineB = False
            BorderLineL = True
            Escapement = 0
            TextStyle = tsNone
            LabelStyle = lsDefault
            EllipsesStyle = esNone
            Shift = 1
            Align = alLeft
            Alignment = taCenter
            AutoSize = False
            Caption = 'Part No.'
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
          object lbl21: TLabel3D
            Left = 314
            Top = 0
            Width = 157
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
            BorderLineB = False
            BorderLineL = False
            Escapement = 0
            TextStyle = tsNone
            LabelStyle = lsDefault
            EllipsesStyle = esNone
            Shift = 1
            Align = alLeft
            Alignment = taCenter
            AutoSize = False
            Caption = 'H/W VER.'
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
            ExplicitLeft = 157
          end
          object lbl22: TLabel3D
            Left = 471
            Top = 0
            Width = 157
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
            BorderLineB = False
            BorderLineL = False
            Escapement = 0
            TextStyle = tsNone
            LabelStyle = lsDefault
            EllipsesStyle = esNone
            Shift = 1
            Align = alLeft
            Alignment = taCenter
            AutoSize = False
            Caption = 'S/W VER.'
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
            ExplicitLeft = 266
          end
        end
        object pnlTOP20: TPanel
          Left = 0
          Top = 54
          Width = 640
          Height = 88
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 2
          object lblEcuPartNo: TLabel3D
            Tag = 222
            Left = 0
            Top = 0
            Width = 314
            Height = 88
            ShowTitle = True
            TitleColor = 14942207
            TitleFont.Charset = ANSI_CHARSET
            TitleFont.Color = clGray
            TitleFont.Height = -16
            TitleFont.Name = #47569#51008' '#44256#46357
            TitleFont.Style = [fsBold]
            Title = '12345'
            TitleHeightRatio = 0.350000000000000000
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
            Caption = '88500-12345'
            Color = 16723245
            Font.Charset = ANSI_CHARSET
            Font.Color = clWhite
            Font.Height = -29
            Font.Name = #47569#51008' '#44256#46357
            Font.Style = [fsBold]
            Layout = tlCenter
            ParentColor = False
            ParentFont = False
            Transparent = False
            ExplicitLeft = 1
          end
          object lblEcuSwVer: TLabel3D
            Tag = 222
            Left = 314
            Top = 0
            Width = 157
            Height = 88
            ShowTitle = True
            TitleColor = 14942207
            TitleFont.Charset = ANSI_CHARSET
            TitleFont.Color = clGray
            TitleFont.Height = -16
            TitleFont.Name = #47569#51008' '#44256#46357
            TitleFont.Style = [fsBold]
            Title = '12345'
            TitleHeightRatio = 0.350000000000000000
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
            Caption = '1.0'
            Color = 16723245
            Font.Charset = ANSI_CHARSET
            Font.Color = clWhite
            Font.Height = -29
            Font.Name = #47569#51008' '#44256#46357
            Font.Style = [fsBold]
            Layout = tlCenter
            ParentColor = False
            ParentFont = False
            Transparent = False
            ExplicitLeft = 298
            ExplicitTop = 6
            ExplicitHeight = 60
          end
          object lblEcuHwVer: TLabel3D
            Tag = 222
            Left = 471
            Top = 0
            Width = 157
            Height = 88
            ShowTitle = True
            TitleColor = 14942207
            TitleFont.Charset = ANSI_CHARSET
            TitleFont.Color = clGray
            TitleFont.Height = -16
            TitleFont.Name = #47569#51008' '#44256#46357
            TitleFont.Style = [fsBold]
            Title = '12345'
            TitleHeightRatio = 0.350000000000000000
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
            Caption = '1.0'
            Color = 16723245
            Font.Charset = ANSI_CHARSET
            Font.Color = clWhite
            Font.Height = -29
            Font.Name = #47569#51008' '#44256#46357
            Font.Style = [fsBold]
            Layout = tlCenter
            ParentColor = False
            ParentFont = False
            Transparent = False
            ExplicitLeft = 472
            ExplicitTop = 6
            ExplicitHeight = 60
          end
        end
      end
      object pnlETC: TPanel
        Left = 10
        Top = 329
        Width = 640
        Height = 168
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 3
        object Panel1: TPanel
          Left = 0
          Top = 0
          Width = 640
          Height = 24
          Align = alTop
          BevelOuter = bvNone
          Color = clWhite
          ParentBackground = False
          TabOrder = 0
          object Label1: TLabel
            Left = 0
            Top = 0
            Width = 193
            Height = 24
            Align = alLeft
            Alignment = taCenter
            AutoSize = False
            Caption = #44396#49457' '#50836#49548
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
        object Panel2: TPanel
          Left = 0
          Top = 24
          Width = 640
          Height = 30
          Align = alTop
          BevelOuter = bvNone
          Caption = 'pnlTOP1'
          TabOrder = 1
          object Label3D1: TLabel3D
            Left = 0
            Top = 0
            Width = 316
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
            BorderLineB = False
            BorderLineL = True
            Escapement = 0
            TextStyle = tsNone
            LabelStyle = lsDefault
            EllipsesStyle = esNone
            Shift = 1
            Align = alLeft
            Alignment = taCenter
            AutoSize = False
            Caption = 'DTC CLEAR'
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
            ExplicitLeft = 314
          end
          object Label3D2: TLabel3D
            Left = 473
            Top = 0
            Width = 157
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
            BorderLineB = False
            BorderLineL = False
            Escapement = 0
            TextStyle = tsNone
            LabelStyle = lsDefault
            EllipsesStyle = esNone
            Shift = 1
            Align = alLeft
            Alignment = taCenter
            AutoSize = False
            Caption = 'ANC.PT('#937')'
            Color = 16251129
            FocusControl = fmHtrHost
            Font.Charset = ANSI_CHARSET
            Font.Color = clBlack
            Font.Height = -16
            Font.Name = #47569#51008' '#44256#46357
            Font.Style = [fsBold]
            Layout = tlCenter
            ParentColor = False
            ParentFont = False
            Transparent = False
            ExplicitLeft = 0
          end
          object Label3D4: TLabel3D
            Left = 316
            Top = 0
            Width = 157
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
            BorderLineB = False
            BorderLineL = False
            Escapement = 0
            TextStyle = tsNone
            LabelStyle = lsDefault
            EllipsesStyle = esNone
            Shift = 1
            Align = alLeft
            Alignment = taCenter
            AutoSize = False
            Caption = 'BUCKLE(mA)'
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
            ExplicitLeft = 130
            ExplicitTop = 6
          end
        end
        object Panel5: TPanel
          Left = 0
          Top = 54
          Width = 640
          Height = 88
          Align = alTop
          BevelOuter = bvNone
          Caption = 'pnlTOP2'
          TabOrder = 2
          object lblDTCClear: TLabel3D
            Tag = 222
            Left = 0
            Top = 0
            Width = 316
            Height = 88
            ShowTitle = True
            TitleColor = 16251129
            TitleFont.Charset = ANSI_CHARSET
            TitleFont.Color = clWindowText
            TitleFont.Height = -16
            TitleFont.Name = #47569#51008' '#44256#46357
            TitleFont.Style = [fsBold]
            Title = #54032#51221
            TitleHeightRatio = 0.350000000000000000
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
            Caption = 'OK'
            Color = 3618815
            Font.Charset = ANSI_CHARSET
            Font.Color = clWhite
            Font.Height = -35
            Font.Name = #47569#51008' '#44256#46357
            Font.Style = [fsBold]
            Layout = tlCenter
            ParentColor = False
            ParentFont = False
            Transparent = False
            ExplicitLeft = 314
          end
          object lblBuckle: TLabel3D
            Tag = 222
            Left = 316
            Top = 0
            Width = 157
            Height = 88
            ShowTitle = True
            TitleColor = 14942207
            TitleFont.Charset = ANSI_CHARSET
            TitleFont.Color = clWindowText
            TitleFont.Height = -16
            TitleFont.Name = #47569#51008' '#44256#46357
            TitleFont.Style = [fsBold]
            Title = '24 ~ 25'
            TitleHeightRatio = 0.350000000000000000
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
            Caption = '1.2'
            Color = 16723245
            Font.Charset = ANSI_CHARSET
            Font.Color = clWhite
            Font.Height = -29
            Font.Name = #47569#51008' '#44256#46357
            Font.Style = [fsBold]
            Layout = tlCenter
            ParentColor = False
            ParentFont = False
            Transparent = False
            ExplicitLeft = 151
            ExplicitTop = 6
          end
          object lblAncPT: TLabel3D
            Tag = 222
            Left = 473
            Top = 0
            Width = 157
            Height = 88
            ShowTitle = True
            TitleColor = 14942207
            TitleFont.Charset = ANSI_CHARSET
            TitleFont.Color = clWindowText
            TitleFont.Height = -16
            TitleFont.Name = #47569#51008' '#44256#46357
            TitleFont.Style = [fsBold]
            Title = '12 ~ 13'
            TitleHeightRatio = 0.350000000000000000
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
            Caption = '12.5'
            Color = 16723245
            Font.Charset = ANSI_CHARSET
            Font.Color = clWhite
            Font.Height = -29
            Font.Name = #47569#51008' '#44256#46357
            Font.Style = [fsBold]
            Layout = tlCenter
            ParentColor = False
            ParentFont = False
            Transparent = False
            ExplicitLeft = 1
            ExplicitTop = 6
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
    DesignSize = (
      226
      735)
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
      Caption = 'SW1 PBV SHVU DRV'
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
      Left = 178
      Top = 704
      Width = 46
      Height = 28
      Anchors = [akRight, akBottom]
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
    object tcCon: TTabControl
      Left = 0
      Top = 0
      Width = 226
      Height = 26
      Align = alTop
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = #47569#51008' '#44256#46357
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      Tabs.Strings = (
        'MAIN'
        'SWITCH')
      TabIndex = 0
      TabWidth = 70
      OnChange = tcConChange
    end
    object sgCon: TStringGrid
      Left = 0
      Top = 50
      Width = 226
      Height = 648
      Align = alTop
      BevelInner = bvNone
      BevelOuter = bvNone
      BorderStyle = bsNone
      Color = 15789806
      ColCount = 4
      Ctl3D = False
      DefaultColWidth = 50
      DefaultRowHeight = 18
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
      TabOrder = 1
      OnDrawCell = sgConDrawCell
      ColWidths = (
        38
        87
        50
        50)
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
    Left = 1707
    Top = 92
  end
  object tmrPoll: TTimer
    Enabled = False
    Interval = 10
    OnTimer = tmrPollTimer
    Left = 1860
    Top = 106
  end
  object tmrMain: TTimer
    OnTimer = tmrMainTimer
    Left = 1777
    Top = 152
  end
  object tmrShow: TTimer
    Enabled = False
    Interval = 3000
    OnTimer = tmrShowTimer
    Left = 1813
    Top = 101
  end
  object tmrDiskChk: TTimer
    Interval = 3600000
    OnTimer = tmrDiskChkTimer
    Left = 1757
    Top = 95
  end
end
