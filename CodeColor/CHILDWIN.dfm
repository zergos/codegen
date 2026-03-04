object MDIChild: TMDIChild
  Left = 332
  Top = 246
  Width = 590
  Height = 462
  Caption = 'MDI Child'
  Color = clBtnFace
  ParentFont = True
  FormStyle = fsMDIChild
  Menu = LocalMenu
  OldCreateOrder = False
  Position = poDefault
  Visible = True
  OnActivate = FormActivate
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Editor: TRichEdit
    Left = 0
    Top = 0
    Width = 574
    Height = 403
    Align = alClient
    Color = clWhite
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Courier New'
    Font.Style = []
    HideSelection = False
    ParentFont = False
    PlainText = True
    ScrollBars = ssBoth
    TabOrder = 0
    WantTabs = True
    WantReturns = False
    WordWrap = False
    OnKeyDown = EditorKeyDown
    OnKeyPress = EditorKeyPress
  end
  object LocalMenu: TMainMenu
    Left = 32
    Top = 32
    object mnView: TMenuItem
      Caption = #1042#1080#1076
      GroupIndex = 3
      object mnViewFont: TMenuItem
        Caption = #1064#1088#1080#1092#1090'...'
        OnClick = mnViewFontClick
      end
    end
  end
  object FontDialog: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    Left = 80
    Top = 32
  end
end
