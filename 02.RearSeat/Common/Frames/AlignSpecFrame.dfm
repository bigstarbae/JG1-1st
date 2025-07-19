object AlignSpecFrme: TAlignSpecFrme
  Left = 0
  Top = 0
  Width = 668
  Height = 100
  TabOrder = 0
  object pnlClient: TPanel
    Left = 0
    Top = 0
    Width = 668
    Height = 100
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object Shape1: TShape
      Left = 11
      Top = 24
      Width = 649
      Height = 2
      Brush.Color = 2894892
      Pen.Color = clMaroon
    end
    object lblTitle: TLabel
      Left = 15
      Top = 6
      Width = 39
      Height = 13
      Caption = 'TITLE'
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clMaroon
      Font.Height = -13
      Font.Name = #44404#47548
      Font.Style = [fsBold]
      ParentFont = False
    end
    object ckbUse: TCheckBox
      Left = 537
      Top = 5
      Width = 120
      Height = 17
      BiDiMode = bdRightToLeft
      Caption = #51333#47308#51204' '#51221#47148#54596#50836
      Font.Charset = HANGEUL_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = #47569#51008' '#44256#46357
      Font.Style = []
      ParentBiDiMode = False
      ParentFont = False
      TabOrder = 0
    end
    object pnlDatas: TPanel
      Left = 11
      Top = 27
      Width = 648
      Height = 69
      BevelOuter = bvNone
      TabOrder = 1
      object pnlMotorDatas: TPanel
        Left = 0
        Top = 0
        Width = 206
        Height = 69
        Align = alLeft
        BevelOuter = bvNone
        TabOrder = 0
        object Label52: TLabel
          Left = 20
          Top = 13
          Width = 87
          Height = 13
          Alignment = taRightJustify
          Caption = #52572#45824' '#51089#46041#49884#44036'('#52488')'
          Font.Charset = HANGEUL_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = #47569#51008' '#44256#46357
          Font.Style = []
          ParentFont = False
        end
        object Label53: TLabel
          Left = 48
          Top = 39
          Width = 57
          Height = 13
          Alignment = taRightJustify
          Caption = #44396#49549#51204#47448'(A)'
          Font.Charset = HANGEUL_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = #47569#51008' '#44256#46357
          Font.Style = []
          ParentFont = False
        end
        object edtCurrLimit: TEdit
          Left = 114
          Top = 37
          Width = 62
          Height = 19
          Color = 15791615
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
        object edtTimeLimit: TEdit
          Left = 114
          Top = 11
          Width = 62
          Height = 19
          Color = 15791615
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
        end
      end
      object pnlAlignDatas: TPanel
        Left = 206
        Top = 0
        Width = 441
        Height = 69
        Align = alLeft
        BevelOuter = bvNone
        TabOrder = 1
        object Label16: TLabel
          Left = 170
          Top = 32
          Width = 65
          Height = 13
          Caption = #49884#44036' '#51201#50857'('#52488')'
          Font.Charset = HANGEUL_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = #47569#51008' '#44256#46357
          Font.Style = []
          ParentFont = False
        end
        object Label17: TLabel
          Left = 312
          Top = 31
          Width = 109
          Height = 13
          Caption = '( 0 '#49444#51221#49884' '#45149#45800' '#51221#51648' )'
          Font.Charset = HANGEUL_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = #47569#51008' '#44256#46357
          Font.Style = []
          ParentFont = False
        end
        object edtMoveTime: TEdit
          Left = 247
          Top = 28
          Width = 55
          Height = 21
          Font.Charset = HANGEUL_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = #47569#51008' '#44256#46357
          Font.Style = []
          ParentFont = False
          TabOrder = 0
        end
        object rdgDirection: TRadioGroup
          Left = 14
          Top = 16
          Width = 134
          Height = 37
          Caption = #51221#47148#48169#54693
          Columns = 2
          Font.Charset = HANGEUL_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = #47569#51008' '#44256#46357
          Font.Style = []
          Items.Strings = (
            #51204#48169
            #54980#48169)
          ParentFont = False
          TabOrder = 1
        end
      end
    end
  end
end
