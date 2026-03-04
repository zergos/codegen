object NewObjectForm: TNewObjectForm
  Left = 412
  Top = 240
  Width = 265
  Height = 228
  BorderStyle = bsSizeToolWin
  Caption = #1053#1086#1074#1099#1081' '#1086#1073#1098#1077#1082#1090
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 35
    Height = 13
    Caption = #1057#1093#1077#1084#1072':'
  end
  object Label2: TLabel
    Left = 8
    Top = 32
    Width = 44
    Height = 13
    Caption = #1050#1072#1090#1072#1083#1086#1075':'
  end
  object Label3: TLabel
    Left = 8
    Top = 80
    Width = 38
    Height = 13
    Caption = #1043#1088#1091#1087#1087#1072':'
  end
  object Label4: TLabel
    Left = 8
    Top = 56
    Width = 60
    Height = 13
    Caption = #1048#1084#1103' '#1092#1072#1081#1083#1072':'
  end
  object Label5: TLabel
    Left = 8
    Top = 104
    Width = 70
    Height = 13
    Caption = #1048#1084#1103' '#1086#1073#1098#1077#1082#1090#1072':'
  end
  object Label6: TLabel
    Left = 8
    Top = 128
    Width = 61
    Height = 13
    Caption = #1048#1084#1103' '#1087#1086#1083#1100#1079'.:'
  end
  object cbSchemes: TComboBox
    Left = 96
    Top = 8
    Width = 153
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 0
    OnChange = cbSchemesChange
  end
  object cbDirectory: TComboBox
    Left = 96
    Top = 32
    Width = 153
    Height = 21
    ItemHeight = 13
    TabOrder = 1
    OnChange = cbDirectoryChange
  end
  object cbGroup: TComboBox
    Left = 96
    Top = 80
    Width = 153
    Height = 21
    ItemHeight = 13
    TabOrder = 3
    OnChange = cbGroupChange
  end
  object cbFileName: TComboBox
    Left = 96
    Top = 56
    Width = 153
    Height = 21
    ItemHeight = 13
    TabOrder = 2
  end
  object cbNames: TComboBox
    Left = 96
    Top = 104
    Width = 153
    Height = 21
    ItemHeight = 13
    TabOrder = 4
  end
  object btnCreate: TButton
    Left = 72
    Top = 168
    Width = 105
    Height = 25
    Caption = #1057#1086#1079#1076#1072#1090#1100
    TabOrder = 6
    OnClick = btnCreateClick
  end
  object cbUserNames: TComboBox
    Left = 96
    Top = 128
    Width = 153
    Height = 21
    ItemHeight = 13
    TabOrder = 5
  end
end
