object RefactoryForm: TRefactoryForm
  Left = 318
  Top = 153
  Width = 377
  Height = 478
  BorderStyle = bsSizeToolWin
  Caption = #1056#1077#1092#1072#1082#1090#1086#1088#1080#1085#1075
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 35
    Height = 13
    Caption = #1057#1093#1077#1084#1072':'
  end
  object Label6: TLabel
    Left = 8
    Top = 216
    Width = 85
    Height = 13
    Caption = #1055#1091#1090#1100' '#1082' '#1084#1086#1076#1077#1083#1103#1084':'
  end
  object cbScheme: TComboBox
    Left = 64
    Top = 8
    Width = 257
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 0
    OnChange = cbSchemeChange
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 40
    Width = 313
    Height = 81
    Caption = #1048#1089#1093#1086#1076#1085#1099#1081' '#1086#1073#1098#1077#1082#1090
    TabOrder = 1
    object Label2: TLabel
      Left = 16
      Top = 24
      Width = 38
      Height = 13
      Caption = #1043#1088#1091#1087#1087#1072':'
    end
    object Label3: TLabel
      Left = 16
      Top = 48
      Width = 32
      Height = 13
      Caption = #1060#1072#1081#1083':'
    end
    object cbSrcGroup: TComboBox
      Left = 64
      Top = 24
      Width = 233
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 0
      OnChange = cbSrcGroupChange
    end
    object cbSrcFile: TComboBox
      Left = 64
      Top = 48
      Width = 233
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 1
    end
  end
  object GroupBox2: TGroupBox
    Left = 8
    Top = 128
    Width = 313
    Height = 81
    Caption = #1053#1086#1074#1099#1081' '#1086#1073#1098#1077#1082#1090
    TabOrder = 2
    object Label4: TLabel
      Left = 16
      Top = 24
      Width = 38
      Height = 13
      Caption = #1043#1088#1091#1087#1087#1072':'
    end
    object Label5: TLabel
      Left = 16
      Top = 48
      Width = 32
      Height = 13
      Caption = #1060#1072#1081#1083':'
    end
    object cbDestGroup: TComboBox
      Left = 64
      Top = 24
      Width = 233
      Height = 21
      ItemHeight = 13
      TabOrder = 0
      OnChange = cbDestGroupChange
    end
    object cbDestFile: TComboBox
      Left = 64
      Top = 48
      Width = 233
      Height = 21
      ItemHeight = 13
      TabOrder = 1
    end
  end
  object editPath: TEdit
    Left = 104
    Top = 216
    Width = 217
    Height = 21
    TabOrder = 3
  end
  object btnPath: TButton
    Left = 328
    Top = 216
    Width = 33
    Height = 25
    Caption = '...'
    TabOrder = 4
    OnClick = btnPathClick
  end
  object btnDo: TButton
    Left = 16
    Top = 248
    Width = 75
    Height = 25
    Caption = #1042#1099#1087#1086#1083#1085#1080#1090#1100
    TabOrder = 5
    OnClick = btnDoClick
  end
  object Memo1: TMemo
    Left = 0
    Top = 273
    Width = 361
    Height = 171
    Align = alBottom
    ScrollBars = ssVertical
    TabOrder = 6
  end
  object OpenDialog1: TOpenDialog
    Filter = #1060#1072#1081#1083#1099' '#1084#1086#1076#1077#1083#1077#1081' (*.gen)|*.gen'
    Options = [ofHideReadOnly, ofPathMustExist, ofEnableSizing]
    Left = 328
    Top = 248
  end
end
