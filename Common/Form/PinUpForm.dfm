object frmPinUp: TfrmPinUp
  Left = 0
  Top = 0
  BorderStyle = bsNone
  ClientHeight = 338
  ClientWidth = 651
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poDefault
  OnClose = FormClose
  OnCreate = FormCreate
  OnMouseDown = FormMouseDown
  PixelsPerInch = 96
  TextHeight = 13
  object tmrClose: TTimer
    Enabled = False
    OnTimer = tmrCloseTimer
    Left = 312
    Top = 152
  end
end
