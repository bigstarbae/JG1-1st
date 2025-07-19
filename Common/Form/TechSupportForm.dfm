inherited frmTechSupport: TfrmTechSupport
  Caption = #44592#49696' '#51648#50896' '
  ClientHeight = 722
  ClientWidth = 1038
  Color = clWhite
  Font.Name = #47569#51008' '#44256#46357
  ExplicitWidth = 1046
  ExplicitHeight = 753
  PixelsPerInch = 96
  TextHeight = 17
  object imgQRCode: TImage
    Left = 287
    Top = 91
    Width = 298
    Height = 278
  end
  object lblURL: TLabel3D
    Left = 23
    Top = 432
    Width = 914
    Height = 33
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
    Border = False
    BorderType = btBorderLine
    BorderLineT = True
    BorderLineR = True
    BorderLineB = True
    BorderLineL = True
    Escapement = 0
    TextStyle = tsNone
    LabelStyle = lsWWWAddress
    EllipsesStyle = esNone
    Shift = 1
    AutoSize = False
    Caption = 'https://'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -12
    Font.Name = 'Arial'
    Font.Style = []
    Layout = tlCenter
    ParentFont = False
    OnClick = lblURLClick
  end
  object sgTSList: TStringGrid
    Left = 0
    Top = 500
    Width = 1038
    Height = 222
    Align = alBottom
    ColCount = 2
    DrawingStyle = gdsGradient
    GradientEndColor = 15790320
    TabOrder = 0
    OnSelectCell = sgTSListSelectCell
    ColWidths = (
      64
      760)
  end
end
