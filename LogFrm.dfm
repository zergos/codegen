object LogForm: TLogForm
  Left = 300
  Top = 388
  Width = 456
  Height = 321
  Caption = #1057#1086#1086#1073#1097#1077#1085#1080#1103' '#1082#1086#1084#1087#1080#1083#1103#1094#1080#1080
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnActivate = FormActivate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 312
    Top = 264
    Width = 51
    Height = 13
    Caption = #1054#1096#1080#1073#1086#1082':'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clActiveCaption
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Memo: TMemo
    Left = 0
    Top = 0
    Width = 440
    Height = 249
    Align = alTop
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 0
    OnClick = MemoClick
    OnKeyPress = MemoKeyPress
  end
  object btnClose: TButton
    Left = 8
    Top = 256
    Width = 81
    Height = 25
    Cancel = True
    Caption = #1047#1072#1082#1088#1099#1090#1100
    Default = True
    TabOrder = 1
    OnClick = btnCloseClick
  end
  object stErrors: TStaticText
    Left = 368
    Top = 264
    Width = 69
    Height = 17
    Alignment = taRightJustify
    AutoSize = False
    BevelKind = bkFlat
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clActiveCaption
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 2
  end
  object Timer1: TTimer
    Enabled = False
    OnTimer = Timer1Timer
    Left = 152
    Top = 256
  end
end
