object ConfirmForm: TConfirmForm
  Left = 545
  Top = 286
  BorderStyle = bsToolWindow
  Caption = #1055#1086#1076#1090#1074#1077#1088#1078#1076#1077#1085#1080#1077
  ClientHeight = 99
  ClientWidth = 312
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  DesignSize = (
    312
    99)
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 0
    Top = 0
    Width = 312
    Height = 50
    Anchors = [akLeft, akTop, akRight, akBottom]
  end
  object Label1: TLabel
    Left = 16
    Top = 16
    Width = 281
    Height = 18
    Anchors = [akLeft, akTop, akBottom]
    AutoSize = False
  end
  object Button1: TButton
    Left = 16
    Top = 65
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = '&'#1044#1072
    Default = True
    ModalResult = 6
    TabOrder = 0
  end
  object Button2: TButton
    Left = 104
    Top = 65
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = '&'#1053#1077#1090
    ModalResult = 7
    TabOrder = 1
  end
  object Button3: TButton
    Left = 224
    Top = 65
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Cancel = True
    Caption = '&'#1054#1090#1084#1077#1085#1072
    ModalResult = 2
    TabOrder = 2
  end
end
