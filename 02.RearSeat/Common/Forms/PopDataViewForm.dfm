object frmPopDataView: TfrmPopDataView
  Left = 0
  Top = 0
  Caption = 'POP '#51204#49569' DATA '
  ClientHeight = 673
  ClientWidth = 265
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 265
    Height = 29
    Align = alTop
    Caption = 'Panel1'
    TabOrder = 0
    object btnParse: TButton
      Left = 158
      Top = 1
      Width = 106
      Height = 27
      Align = alRight
      Caption = #48516#49437
      TabOrder = 0
      OnClick = btnParseClick
    end
    object edtPopData: TEdit
      Left = 1
      Top = 1
      Width = 157
      Height = 27
      Align = alClient
      TabOrder = 1
      ExplicitHeight = 21
    end
  end
  object sgPopData: TStringGrid
    Left = 0
    Top = 29
    Width = 265
    Height = 644
    Align = alClient
    ColCount = 2
    Ctl3D = False
    FixedRows = 0
    ParentCtl3D = False
    TabOrder = 1
    ColWidths = (
      141
      116)
  end
end
