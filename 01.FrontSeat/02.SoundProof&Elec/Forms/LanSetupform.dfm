object frmLanSetup: TfrmLanSetup
  Left = 192
  Top = 110
  Caption = 'LAN Reference'
  ClientHeight = 593
  ClientWidth = 874
  Color = clBtnFace
  Font.Charset = HANGEUL_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #44404#47548
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 0
    Top = 0
    Width = 874
    Height = 593
    Align = alClient
    TabOrder = 0
    object Panel1: TPanel
      Left = 10
      Top = 11
      Width = 828
      Height = 548
      BevelOuter = bvNone
      BorderStyle = bsSingle
      Color = 15593457
      Ctl3D = False
      ParentBackground = False
      ParentCtl3D = False
      TabOrder = 0
      object Label13: TLabel
        Tag = 222
        Left = 10
        Top = 480
        Width = 402
        Height = 13
        Caption = #51452#51032') '#47676#51200' PLC'#51032' '#54252#53944' '#48143' IP '#49444#51221#51012' '#54869#51064' '#48143' '#49688#51221#54616#49888' '#54980' '#49444#51221#54616#49464#50836'.'
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clRed
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = []
        ParentFont = False
        Visible = False
      end
      object labWaitTime: TLabel
        Tag = 222
        Left = 34
        Top = 67
        Width = 137
        Height = 13
        Alignment = taRightJustify
        Caption = #51025#45813' '#45824#44592' '#49884#44036'(ms) :'
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = [fsBold]
        ParentFont = False
      end
      object labSendTerm: TLabel
        Tag = 222
        Left = 67
        Top = 95
        Width = 104
        Height = 13
        Alignment = taRightJustify
        Caption = #51204#49569' '#44036#44201'(ms) :'
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = [fsBold]
        ParentFont = False
      end
      object labConnectTime: TLabel
        Tag = 222
        Left = 369
        Top = 95
        Width = 137
        Height = 13
        Alignment = taRightJustify
        Caption = #50672#44208' '#49884#46020' '#44036#44201'(ms) :'
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = [fsBold]
        ParentFont = False
      end
      object labErWaitTime: TLabel
        Tag = 222
        Left = 336
        Top = 67
        Width = 170
        Height = 13
        Alignment = taRightJustify
        Caption = #50724#47448' '#49884' '#51116#50672#44208' '#49884#44036'(ms) :'
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Label1: TLabel
        Left = 127
        Top = 168
        Width = 14
        Height = 13
        Alignment = taCenter
        Caption = 'IP'
        Color = 15593457
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clBlack
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = [fsBold]
        ParentColor = False
        ParentFont = False
        Transparent = True
        Layout = tlCenter
      end
      object lblPort: TLabel
        Left = 243
        Top = 168
        Width = 79
        Height = 13
        Alignment = taCenter
        Caption = 'PORT(Hex)'
        Color = 15593457
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clBlack
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = [fsBold]
        ParentColor = False
        ParentFont = False
        Transparent = True
        Layout = tlCenter
        OnDblClick = lblPortDblClick
      end
      object Label4: TLabel
        Tag = 222
        Left = 363
        Top = 168
        Width = 28
        Height = 13
        Alignment = taCenter
        Caption = #51333#47448
        Color = 15593457
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clBlack
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = [fsBold]
        ParentColor = False
        ParentFont = False
        Transparent = True
        Layout = tlCenter
      end
      object Label3: TLabel
        Left = 27
        Top = 168
        Width = 56
        Height = 13
        Alignment = taCenter
        Caption = #49324#50857#50668#48512
        Color = 15593457
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clBlack
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = [fsBold]
        ParentColor = False
        ParentFont = False
        Transparent = True
        Layout = tlCenter
      end
      object Label8: TLabel
        Left = 18
        Top = 26
        Width = 126
        Height = 13
        Caption = 'LAN '#53685#49888' '#50672#44208' '#49444#51221
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Shape10: TShape
        Left = 10
        Top = 11
        Width = 800
        Height = 5
        Brush.Color = clBlack
      end
      object Shape11: TShape
        Left = 10
        Top = 48
        Width = 800
        Height = 1
        Brush.Color = clBlack
      end
      object Shape1: TShape
        Left = 10
        Top = 155
        Width = 800
        Height = 1
        Brush.Color = clBlack
      end
      object Shape2: TShape
        Left = 10
        Top = 194
        Width = 800
        Height = 1
        Brush.Color = clBlack
      end
      object Shape3: TShape
        Left = 10
        Top = 519
        Width = 800
        Height = 5
        Brush.Color = clBlack
      end
      object edtPort1: TEdit
        Tag = 1
        Left = 243
        Top = 211
        Width = 117
        Height = 19
        ImeName = 'Microsoft IME 2003'
        TabOrder = 0
        Text = 'edtPort1'
        OnChange = edtHostIpChange
      end
      object edtPort2: TEdit
        Tag = 2
        Left = 243
        Top = 236
        Width = 117
        Height = 19
        ImeName = 'Microsoft IME 2003'
        TabOrder = 1
        Text = 'Edit2'
        OnChange = edtHostIpChange
      end
      object edtPort3: TEdit
        Tag = 3
        Left = 243
        Top = 261
        Width = 117
        Height = 19
        ImeName = 'Microsoft IME 2003'
        TabOrder = 2
        Text = 'Edit2'
        OnChange = edtHostIpChange
      end
      object edtPort4: TEdit
        Tag = 4
        Left = 243
        Top = 285
        Width = 117
        Height = 19
        ImeName = 'Microsoft IME 2003'
        TabOrder = 3
        Text = 'Edit2'
        OnChange = edtHostIpChange
      end
      object edtPort5: TEdit
        Tag = 5
        Left = 243
        Top = 310
        Width = 117
        Height = 19
        ImeName = 'Microsoft IME 2003'
        TabOrder = 4
        Text = 'Edit2'
        OnChange = edtHostIpChange
      end
      object edtPort6: TEdit
        Tag = 6
        Left = 243
        Top = 335
        Width = 117
        Height = 19
        ImeName = 'Microsoft IME 2003'
        TabOrder = 5
        Text = 'Edit2'
        OnChange = edtHostIpChange
      end
      object edtPort7: TEdit
        Tag = 7
        Left = 243
        Top = 360
        Width = 117
        Height = 19
        ImeName = 'Microsoft IME 2003'
        TabOrder = 6
        Text = 'Edit2'
        OnChange = edtHostIpChange
      end
      object edtPort8: TEdit
        Tag = 8
        Left = 243
        Top = 384
        Width = 117
        Height = 19
        ImeName = 'Microsoft IME 2003'
        TabOrder = 7
        Text = 'Edit2'
        OnChange = edtHostIpChange
      end
      object edtPort9: TEdit
        Tag = 9
        Left = 243
        Top = 409
        Width = 117
        Height = 19
        ImeName = 'Microsoft IME 2003'
        TabOrder = 8
        Text = 'Edit2'
        OnChange = edtHostIpChange
      end
      object edtPort10: TEdit
        Tag = 10
        Left = 243
        Top = 434
        Width = 117
        Height = 19
        ImeName = 'Microsoft IME 2003'
        TabOrder = 9
        Text = 'Edit2'
        OnChange = edtHostIpChange
      end
      object bbtnSave: TBitBtn
        Left = 517
        Top = 429
        Width = 136
        Height = 25
        Caption = #51200#51109'(&A)'
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = [fsBold]
        Glyph.Data = {
          EE000000424DEE0000000000000076000000280000000F0000000F0000000100
          0400000000007800000000000000000000001000000010000000000000000084
          8400C6C6C600FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFFFFFFFF
          FFF0F0000000000000F001100000022010F001100000022010F0011000000220
          10F001100000000010F001111111111110F001100000000110F0010222222220
          10F001022222222010F001022222222010F001022222222010F0010222222220
          00F001022222222020F000000000000000F0}
        ParentFont = False
        TabOrder = 10
        Visible = False
        OnClick = bbtnSaveClick
      end
      object ckbIsReConnect: TCheckBox
        Tag = 222
        Left = 431
        Top = 121
        Width = 161
        Height = 17
        Caption = #47924#51025#45813#49884' '#51116#50672#44208' '#49884#46020'.'
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 11
        OnClick = ckbIsReConnectClick
      end
      object edtWaitTime: TEdit
        Left = 176
        Top = 64
        Width = 83
        Height = 19
        ImeName = 'Microsoft IME 2003'
        TabOrder = 12
        Text = 'edtHostIp'
        OnChange = edtHostIpChange
      end
      object edtSendTerm: TEdit
        Left = 176
        Top = 91
        Width = 83
        Height = 19
        ImeName = 'Microsoft IME 2003'
        TabOrder = 13
        Text = 'edtHostIp'
        OnChange = edtHostIpChange
      end
      object edtErWaitTime: TEdit
        Left = 509
        Top = 64
        Width = 83
        Height = 19
        ImeName = 'Microsoft IME 2003'
        TabOrder = 14
        Text = 'edtHostIp'
        OnChange = edtHostIpChange
      end
      object edtConnectTime: TEdit
        Left = 509
        Top = 91
        Width = 83
        Height = 19
        ImeName = 'Microsoft IME 2003'
        TabOrder = 15
        Text = 'edtHostIp'
        OnChange = edtHostIpChange
      end
      object cbxPort1: TComboBox
        Tag = 1
        Left = 363
        Top = 211
        Width = 140
        Height = 21
        Style = csDropDownList
        ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
        TabOrder = 16
        OnChange = edtHostIpChange
        Items.Strings = (
          #44396#48516#50630#49844
          'A'#46041'IO'
          'B'#46041'IO'
          'DATA')
      end
      object cbxPort2: TComboBox
        Tag = 2
        Left = 363
        Top = 236
        Width = 140
        Height = 21
        Style = csDropDownList
        ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
        TabOrder = 17
        OnChange = edtHostIpChange
        Items.Strings = (
          #44396#48516#50630#49844
          'A'#46041'IO'
          'B'#46041'IO'
          'DATA')
      end
      object cbxPort3: TComboBox
        Tag = 3
        Left = 363
        Top = 261
        Width = 140
        Height = 21
        Style = csDropDownList
        ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
        TabOrder = 18
        OnChange = edtHostIpChange
        Items.Strings = (
          #44396#48516#50630#49844
          'A'#46041'IO'
          'B'#46041'IO'
          'DATA')
      end
      object cbxPort4: TComboBox
        Tag = 4
        Left = 363
        Top = 285
        Width = 140
        Height = 21
        Style = csDropDownList
        ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
        TabOrder = 19
        OnChange = edtHostIpChange
        Items.Strings = (
          #44396#48516#50630#49844
          'A'#46041'IO'
          'B'#46041'IO'
          'DATA')
      end
      object cbxPort5: TComboBox
        Tag = 5
        Left = 363
        Top = 310
        Width = 140
        Height = 21
        Style = csDropDownList
        ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
        TabOrder = 20
        OnChange = edtHostIpChange
        Items.Strings = (
          #44396#48516#50630#49844
          'A'#46041'IO'
          'B'#46041'IO'
          'DATA')
      end
      object cbxPort6: TComboBox
        Tag = 6
        Left = 363
        Top = 335
        Width = 140
        Height = 21
        Style = csDropDownList
        ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
        TabOrder = 21
        OnChange = edtHostIpChange
        Items.Strings = (
          #44396#48516#50630#49844
          'A'#46041'IO'
          'B'#46041'IO'
          'DATA')
      end
      object cbxPort7: TComboBox
        Tag = 7
        Left = 363
        Top = 360
        Width = 140
        Height = 21
        Style = csDropDownList
        ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
        TabOrder = 22
        OnChange = edtHostIpChange
        Items.Strings = (
          #44396#48516#50630#49844
          'A'#46041'IO'
          'B'#46041'IO'
          'DATA')
      end
      object cbxPort8: TComboBox
        Tag = 8
        Left = 363
        Top = 384
        Width = 140
        Height = 21
        Style = csDropDownList
        ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
        TabOrder = 23
        OnChange = edtHostIpChange
        Items.Strings = (
          #44396#48516#50630#49844
          'A'#46041'IO'
          'B'#46041'IO'
          'DATA')
      end
      object cbxPort9: TComboBox
        Tag = 9
        Left = 363
        Top = 409
        Width = 140
        Height = 21
        Style = csDropDownList
        ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
        TabOrder = 24
        OnChange = edtHostIpChange
        Items.Strings = (
          #44396#48516#50630#49844
          'A'#46041'IO'
          'B'#46041'IO'
          'DATA')
      end
      object cbxPort10: TComboBox
        Tag = 10
        Left = 363
        Top = 434
        Width = 140
        Height = 21
        Style = csDropDownList
        ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
        TabOrder = 25
        OnChange = edtHostIpChange
        Items.Strings = (
          #44396#48516#50630#49844
          'A'#46041'IO'
          'B'#46041'IO'
          'DATA')
      end
      object ckbPort1: TCheckBox
        Tag = 1
        Left = 27
        Top = 212
        Width = 97
        Height = 17
        Caption = '1.  '#54252#53944#48264#54840
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = []
        ParentFont = False
        TabOrder = 26
        OnClick = ckbPort1Click
      end
      object ckbPort2: TCheckBox
        Tag = 2
        Left = 27
        Top = 238
        Width = 97
        Height = 17
        Caption = '2.  '#54252#53944#48264#54840
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = []
        ParentFont = False
        TabOrder = 27
        OnClick = ckbPort1Click
      end
      object ckbPort3: TCheckBox
        Tag = 3
        Left = 27
        Top = 263
        Width = 97
        Height = 17
        Caption = '3.  '#54252#53944#48264#54840
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = []
        ParentFont = False
        TabOrder = 28
        OnClick = ckbPort1Click
      end
      object ckbPort4: TCheckBox
        Tag = 4
        Left = 27
        Top = 287
        Width = 97
        Height = 17
        Caption = '4.  '#54252#53944#48264#54840
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = []
        ParentFont = False
        TabOrder = 29
        OnClick = ckbPort1Click
      end
      object ckbPort5: TCheckBox
        Tag = 5
        Left = 27
        Top = 312
        Width = 97
        Height = 17
        Caption = '5.  '#54252#53944#48264#54840
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = []
        ParentFont = False
        TabOrder = 30
        OnClick = ckbPort1Click
      end
      object ckbPort6: TCheckBox
        Tag = 6
        Left = 27
        Top = 338
        Width = 97
        Height = 17
        Caption = '6.  '#54252#53944#48264#54840
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = []
        ParentFont = False
        TabOrder = 31
        OnClick = ckbPort1Click
      end
      object ckbPort7: TCheckBox
        Tag = 7
        Left = 27
        Top = 363
        Width = 97
        Height = 17
        Caption = '7.  '#54252#53944#48264#54840
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = []
        ParentFont = False
        TabOrder = 32
        OnClick = ckbPort1Click
      end
      object ckbPort8: TCheckBox
        Tag = 8
        Left = 27
        Top = 386
        Width = 97
        Height = 17
        Caption = '8.  '#54252#53944#48264#54840
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = []
        ParentFont = False
        TabOrder = 33
        OnClick = ckbPort1Click
      end
      object ckbPort9: TCheckBox
        Tag = 9
        Left = 27
        Top = 411
        Width = 97
        Height = 17
        Caption = '9.  '#54252#53944#48264#54840
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = []
        ParentFont = False
        TabOrder = 34
        OnClick = ckbPort1Click
      end
      object ckbPort10: TCheckBox
        Tag = 10
        Left = 27
        Top = 435
        Width = 97
        Height = 17
        Caption = '10.  '#54252#53944#48264#54840
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = []
        ParentFont = False
        TabOrder = 35
        OnClick = ckbPort1Click
      end
      object edtIP1: TEdit
        Tag = 1
        Left = 127
        Top = 210
        Width = 113
        Height = 19
        ImeName = 'Microsoft IME 2003'
        TabOrder = 36
        Text = 'edtPort1'
        OnChange = edtHostIpChange
      end
      object edtIP2: TEdit
        Tag = 2
        Left = 127
        Top = 235
        Width = 113
        Height = 19
        ImeName = 'Microsoft IME 2003'
        TabOrder = 37
        Text = 'edtIP2'
        OnChange = edtHostIpChange
      end
      object edtIP3: TEdit
        Tag = 3
        Left = 127
        Top = 260
        Width = 113
        Height = 19
        ImeName = 'Microsoft IME 2003'
        TabOrder = 38
        Text = 'Edit2'
        OnChange = edtHostIpChange
      end
      object edtIP4: TEdit
        Tag = 4
        Left = 127
        Top = 284
        Width = 113
        Height = 19
        ImeName = 'Microsoft IME 2003'
        TabOrder = 39
        Text = 'Edit2'
        OnChange = edtHostIpChange
      end
      object edtIP5: TEdit
        Tag = 5
        Left = 127
        Top = 309
        Width = 113
        Height = 19
        ImeName = 'Microsoft IME 2003'
        TabOrder = 40
        Text = 'Edit2'
        OnChange = edtHostIpChange
      end
      object edtIP6: TEdit
        Tag = 6
        Left = 127
        Top = 334
        Width = 113
        Height = 19
        ImeName = 'Microsoft IME 2003'
        TabOrder = 41
        Text = 'Edit2'
        OnChange = edtHostIpChange
      end
      object edtIP7: TEdit
        Tag = 7
        Left = 127
        Top = 359
        Width = 113
        Height = 19
        ImeName = 'Microsoft IME 2003'
        TabOrder = 42
        Text = 'Edit2'
        OnChange = edtHostIpChange
      end
      object edtIP8: TEdit
        Tag = 8
        Left = 127
        Top = 383
        Width = 113
        Height = 19
        ImeName = 'Microsoft IME 2003'
        TabOrder = 43
        Text = 'Edit2'
        OnChange = edtHostIpChange
      end
      object edtIP9: TEdit
        Tag = 9
        Left = 127
        Top = 408
        Width = 113
        Height = 19
        ImeName = 'Microsoft IME 2003'
        TabOrder = 44
        Text = 'Edit2'
        OnChange = edtHostIpChange
      end
      object edtIP10: TEdit
        Tag = 10
        Left = 127
        Top = 433
        Width = 113
        Height = 19
        ImeName = 'Microsoft IME 2003'
        TabOrder = 45
        Text = 'Edit2'
        OnChange = edtHostIpChange
      end
    end
  end
end
