object EditForm: TEditForm
  Left = 338
  Top = 156
  Width = 704
  Height = 333
  Caption = '<'#1073#1077#1079' '#1080#1084#1077#1085#1080'>'
  Color = clSilver
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsMDIChild
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poDefault
  Visible = True
  OnActivate = FormActivate
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnMouseWheelDown = FormMouseWheelDown
  OnMouseWheelUp = FormMouseWheelUp
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter3: TSplitter
    Left = 395
    Top = 0
    Width = 4
    Height = 274
    Align = alRight
    Color = clSilver
    ParentColor = False
    OnMoved = Splitter3Moved
  end
  object PanelRight: TPanel
    Left = 399
    Top = 0
    Width = 289
    Height = 274
    Align = alRight
    BevelOuter = bvNone
    TabOrder = 0
    object Splitter5: TSplitter
      Left = 0
      Top = 62
      Width = 289
      Height = 4
      Cursor = crVSplit
      Align = alBottom
      Color = clSilver
      ParentColor = False
    end
    object GroupPars: TGroupBox
      Left = 0
      Top = 0
      Width = 289
      Height = 62
      Align = alClient
      Caption = #1055#1072#1088#1072#1084#1077#1090#1088#1099
      TabOrder = 0
      object Shape2: TShape
        Left = 2
        Top = 15
        Width = 285
        Height = 45
        Align = alClient
        Brush.Color = 14211288
        Brush.Style = bsCross
        Pen.Color = clGray
        Pen.Style = psDot
      end
      object ValueListEditor: TValueListEditor
        Left = 2
        Top = 15
        Width = 285
        Height = 45
        Align = alClient
        TabOrder = 0
        TitleCaptions.Strings = (
          #1055#1072#1088#1072#1084#1077#1090#1088
          #1047#1085#1072#1095#1077#1085#1080#1077
          #1054#1087#1080#1089#1072#1085#1080#1077)
        Visible = False
        OnEnter = ValueListEditorEnter
        OnExit = ValueListEditorExit
        OnGetEditMask = ValueListEditorGetEditMask
        OnGetPickList = ValueListEditorGetPickList
        OnSelectCell = ValueListEditorSelectCell
        OnStringsChange = ValueListEditorStringsChange
        ColWidths = (
          135
          300)
      end
    end
    object GroupLayers: TGroupBox
      Left = 0
      Top = 66
      Width = 289
      Height = 208
      Align = alBottom
      Caption = #1057#1083#1086#1080
      TabOrder = 1
      DesignSize = (
        289
        208)
      object SpeedButtonLUp: TSpeedButton
        Left = 258
        Top = 112
        Width = 23
        Height = 22
        Hint = #1055#1077#1088#1077#1084#1077#1089#1090#1080#1090#1100' '#1086#1073#1098#1077#1082#1090' '#1074#1074#1077#1088#1093
        Anchors = [akTop, akRight]
        Glyph.Data = {
          76010000424D7601000000000000760000002800000020000000100000000100
          04000000000000010000C40E0000C40E00001000000000000000000000000000
          800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333000333
          3333333333777F3333333333330C033333333333337F7F3333333333330C0333
          33333333337F7F3333333333330C033333333333337F7F3333333333330C0333
          33333333337F7F3333333333330C033333333333FF7F7FFFF3333330000C0000
          3333333777737777F3333330CCCCCCC0333333373F333337333333330CCCCC03
          333333337F33337F333333330CCCCC033333333373F333733333333330CCC033
          3333333337F337F33333333330CCC03333333333373F373333333333330C0333
          33333333337F7F3333333333330C033333333333337373333333333333303333
          333333333337F333333333333330333333333333333733333333}
        NumGlyphs = 2
        OnClick = SpeedButtonLUpClick
      end
      object SpeedButtonLDown: TSpeedButton
        Left = 258
        Top = 144
        Width = 23
        Height = 22
        Hint = #1055#1077#1088#1077#1084#1077#1089#1090#1080#1090#1100' '#1086#1073#1098#1077#1082#1090' '#1074#1085#1080#1079
        Anchors = [akTop, akRight]
        Glyph.Data = {
          76010000424D7601000000000000760000002800000020000000100000000100
          04000000000000010000C40E0000C40E00001000000000000000000000000000
          800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333303333
          333333333337F33333333333333033333333333333373F3333333333330C0333
          33333333337F7F3333333333330C033333333333337373F33333333330CCC033
          3333333337F337F33333333330CCC033333333333733373F333333330CCCCC03
          333333337F33337F333333330CCCCC033333333373333373F3333330CCCCCCC0
          33333337FFFF3FF7F3333330000C000033333337777F777733333333330C0333
          33333333337F7F3333333333330C033333333333337F7F3333333333330C0333
          33333333337F7F3333333333330C033333333333337F7F3333333333330C0333
          33333333337F7F33333333333300033333333333337773333333}
        NumGlyphs = 2
        OnClick = SpeedButtonLDownClick
      end
      object SpeedButtonAdd: TSpeedButton
        Left = 258
        Top = 24
        Width = 23
        Height = 22
        Hint = #1055#1077#1088#1077#1084#1077#1089#1090#1080#1090#1100' '#1086#1073#1098#1077#1082#1090' '#1074#1074#1077#1088#1093
        Anchors = [akTop, akRight]
        Glyph.Data = {
          E6000000424DE60000000000000076000000280000000E0000000E0000000100
          0400000000007000000000000000000000001000000000000000000000000000
          BF0000BF000000BFBF00BF000000BF00BF00BFBF0000C0C0C000808080000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
          3300333333333333330033333333333333003333300033333300333330F03333
          3300333330F033333300330000F000033300330FFFFFFF033300330000F00003
          3300333330F033333300333330F0333333003333300033333300333333333333
          33003333333333333300}
        OnClick = SpeedButtonAddClick
      end
      object SpeedButtonDel: TSpeedButton
        Left = 258
        Top = 56
        Width = 23
        Height = 22
        Hint = #1055#1077#1088#1077#1084#1077#1089#1090#1080#1090#1100' '#1086#1073#1098#1077#1082#1090' '#1074#1074#1077#1088#1093
        Anchors = [akTop, akRight]
        Glyph.Data = {
          E6000000424DE60000000000000076000000280000000E0000000E0000000100
          0400000000007000000000000000000000001000000000000000000000000000
          BF0000BF000000BFBF00BF000000BF00BF00BFBF0000C0C0C000808080000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
          3300333333333333330033333333333333003333333333333300333333333333
          330033333333333333003300000000003300330FFFFFFFF03300330000000000
          3300333333333333330033333333333333003333333333333300333333333333
          33003333333333333300}
        OnClick = SpeedButtonDelClick
      end
      object ListLayers: TStringGrid
        Left = 2
        Top = 14
        Width = 250
        Height = 190
        Anchors = [akLeft, akTop, akRight, akBottom]
        ColCount = 2
        DefaultColWidth = 240
        DefaultRowHeight = 16
        RowCount = 1
        FixedRows = 0
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing, goEditing]
        TabOrder = 0
        OnClick = ListLayersClick
        OnDblClick = ListLayersDblClick
        OnDrawCell = ListLayersDrawCell
        OnSetEditText = ListLayersSetEditText
      end
    end
  end
  object PanelMain: TPanel
    Left = 0
    Top = 0
    Width = 395
    Height = 274
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object Splitter1: TSplitter
      Left = 130
      Top = 0
      Width = 7
      Height = 116
      Visible = False
    end
    object Splitter2: TSplitter
      Left = 0
      Top = 116
      Width = 395
      Height = 4
      Cursor = crVSplit
      Align = alBottom
      Color = clSilver
      ParentColor = False
    end
    object PanelTools: TPanel
      Left = 0
      Top = 0
      Width = 130
      Height = 116
      Align = alLeft
      BevelOuter = bvLowered
      TabOrder = 0
      Visible = False
      DesignSize = (
        130
        116)
      object SpeedButtonUp: TSpeedButton
        Left = 32
        Top = 88
        Width = 23
        Height = 22
        Hint = #1055#1077#1088#1077#1084#1077#1089#1090#1080#1090#1100' '#1086#1073#1098#1077#1082#1090' '#1074#1074#1077#1088#1093
        Anchors = [akLeft, akBottom]
        Glyph.Data = {
          76010000424D7601000000000000760000002800000020000000100000000100
          04000000000000010000C40E0000C40E00001000000000000000000000000000
          800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333000333
          3333333333777F3333333333330C033333333333337F7F3333333333330C0333
          33333333337F7F3333333333330C033333333333337F7F3333333333330C0333
          33333333337F7F3333333333330C033333333333FF7F7FFFF3333330000C0000
          3333333777737777F3333330CCCCCCC0333333373F333337333333330CCCCC03
          333333337F33337F333333330CCCCC033333333373F333733333333330CCC033
          3333333337F337F33333333330CCC03333333333373F373333333333330C0333
          33333333337F7F3333333333330C033333333333337373333333333333303333
          333333333337F333333333333330333333333333333733333333}
        NumGlyphs = 2
        OnClick = SpeedButtonUpClick
      end
      object SpeedButtonDown: TSpeedButton
        Left = 72
        Top = 88
        Width = 23
        Height = 22
        Hint = #1055#1077#1088#1077#1084#1077#1089#1090#1080#1090#1100' '#1086#1073#1098#1077#1082#1090' '#1074#1085#1080#1079
        Anchors = [akRight, akBottom]
        Glyph.Data = {
          76010000424D7601000000000000760000002800000020000000100000000100
          04000000000000010000C40E0000C40E00001000000000000000000000000000
          800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333303333
          333333333337F33333333333333033333333333333373F3333333333330C0333
          33333333337F7F3333333333330C033333333333337373F33333333330CCC033
          3333333337F337F33333333330CCC033333333333733373F333333330CCCCC03
          333333337F33337F333333330CCCCC033333333373333373F3333330CCCCCCC0
          33333337FFFF3FF7F3333330000C000033333337777F777733333333330C0333
          33333333337F7F3333333333330C033333333333337F7F3333333333330C0333
          33333333337F7F3333333333330C033333333333337F7F3333333333330C0333
          33333333337F7F33333333333300033333333333337773333333}
        NumGlyphs = 2
        OnClick = SpeedButtonDownClick
      end
      object ToolsList: TStringGrid
        Left = 1
        Top = 1
        Width = 128
        Height = 80
        Align = alTop
        Anchors = [akLeft, akTop, akRight, akBottom]
        ColCount = 2
        DefaultRowHeight = 18
        FixedCols = 0
        RowCount = 2
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing, goRowSelect]
        TabOrder = 0
        OnClick = ToolsListClick
      end
    end
    object GroupMain: TGroupBox
      Left = 0
      Top = 120
      Width = 395
      Height = 154
      Align = alBottom
      Caption = #1057#1074#1086#1081#1089#1090#1074#1072
      Ctl3D = True
      ParentCtl3D = False
      TabOrder = 1
      object Shape1: TShape
        Left = 2
        Top = 15
        Width = 391
        Height = 137
        Align = alClient
        Brush.Color = 14211288
        Brush.Style = bsCross
        Pen.Color = clGray
        Pen.Style = psDot
      end
      object Panel: TPanel
        Left = 2
        Top = 15
        Width = 391
        Height = 137
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        Visible = False
        DesignSize = (
          391
          137)
        object Label2: TLabel
          Left = 8
          Top = 4
          Width = 41
          Height = 13
          Caption = #1054#1073#1098#1077#1082#1090':'
        end
        object Label3: TLabel
          Left = 8
          Top = 28
          Width = 52
          Height = 13
          Caption = #1055#1072#1088'. '#1074#1093#1086#1076':'
        end
        object Label4: TLabel
          Left = 8
          Top = 72
          Width = 52
          Height = 13
          Caption = #1050#1086#1084#1084#1077#1085#1090'.:'
        end
        object Label1: TLabel
          Left = 8
          Top = 48
          Width = 65
          Height = 13
          Caption = #1055#1072#1088'. '#1086#1073#1098#1077#1082#1090':'
        end
        object EditObject: TEdit
          Left = 72
          Top = 1
          Width = 233
          Height = 28
          TabOrder = 0
          Text = 'EditObject'
          OnChange = EditObjectChange
        end
        object PanelWeb: TPanel
          Left = 312
          Top = 0
          Width = 87
          Height = 132
          Anchors = [akLeft, akTop, akRight]
          BorderStyle = bsSingle
          TabOrder = 1
          object WebBrowser: TWebBrowser
            Left = 1
            Top = 1
            Width = 81
            Height = 126
            Align = alClient
            TabOrder = 0
            ControlData = {
              4C0000005F080000060D00000000000000000000000000000000000000000000
              000000004C000000000000000000000001000000E0D057007335CF11AE690800
              2B2E126208000000000000004C0000000114020000000000C000000000000046
              8000000000000000000000000000000000000000000000000000000000000000
              00000000000000000100000000000000000000000000000000000000}
          end
        end
        object cbDefaultIn: TComboBox
          Left = 72
          Top = 26
          Width = 233
          Height = 22
          Style = csOwnerDrawFixed
          ItemHeight = 16
          TabOrder = 2
          OnChange = cbDefaultInChange
        end
        object MemoComment: TMemo
          Left = 72
          Top = 72
          Width = 233
          Height = 57
          ScrollBars = ssBoth
          TabOrder = 3
          WordWrap = False
          OnChange = MemoCommentChange
        end
        object chDebug: TCheckBox
          Left = 6
          Top = 90
          Width = 65
          Height = 17
          Caption = #1054#1090#1083#1072#1076#1082#1072
          TabOrder = 4
          OnClick = chDebugClick
        end
        object cbDefaultObj: TComboBox
          Left = 72
          Top = 48
          Width = 233
          Height = 22
          Style = csOwnerDrawFixed
          ItemHeight = 16
          TabOrder = 5
          OnChange = cbDefaultObjChange
        end
        object cbProtected: TCheckBox
          Left = 6
          Top = 110
          Width = 57
          Height = 17
          Caption = #1047#1072#1097#1080#1090#1072
          TabOrder = 6
          OnClick = cbProtectedClick
        end
      end
    end
    object ScrollBox: TScrollBox
      Left = 137
      Top = 0
      Width = 258
      Height = 116
      Align = alClient
      TabOrder = 2
      object PaintBox: TPaintBox
        Left = 0
        Top = 0
        Width = 1000
        Height = 1000
        Color = clSilver
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentColor = False
        ParentFont = False
        PopupMenu = PopupMenu
        OnDblClick = PaintBoxDblClick
        OnMouseDown = PaintBoxMouseDown
        OnMouseMove = PaintBoxMouseMove
        OnMouseUp = PaintBoxMouseUp
        OnPaint = PaintBoxPaint
      end
    end
  end
  object MainMenu1: TMainMenu
    Left = 176
    Top = 8
    object mnFile: TMenuItem
      Caption = '&'#1060#1072#1081#1083
      object mnFileNew: TMenuItem
        Caption = '&'#1057#1086#1079#1076#1072#1090#1100'...'
        Hint = #1057#1086#1079#1076#1072#1090#1100' '#1085#1086#1074#1099#1081' '#1092#1072#1081#1083
        ShortCut = 16462
        OnClick = mnFileNewClick
      end
      object mnFileNewObject: TMenuItem
        Caption = #1057#1086#1079#1076#1072#1090#1100' '#1086#1073#1098#1077#1082#1090
        OnClick = mnFileNewObjectClick
      end
      object mnFileOpen: TMenuItem
        Caption = '&'#1054#1090#1082#1088#1099#1090#1100'...'
        Hint = #1054#1090#1082#1088#1099#1090#1100' '#1089#1091#1097#1077#1089#1090#1074#1091#1102#1097#1080#1081' '#1092#1072#1081#1083
        ShortCut = 114
        OnClick = mnFileOpenClick
      end
      object mnFileSave: TMenuItem
        Caption = #1057'&'#1086#1093#1088#1072#1085#1080#1090#1100
        Hint = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1092#1072#1081#1083
        ShortCut = 113
        OnClick = mnFileSaveClick
      end
      object mnFileSaveAs: TMenuItem
        Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100' &'#1082#1072#1082'...'
        Hint = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1092#1072#1081#1083' '#1087#1086#1076' '#1085#1086#1074#1099#1084' '#1080#1084#1077#1085#1077#1084
        OnClick = mnFileSaveAsClick
      end
      object mnFileClose: TMenuItem
        Caption = '&'#1047#1072#1082#1088#1099#1090#1100
        Hint = #1047#1072#1082#1088#1099#1090#1100' '#1090#1077#1082#1091#1097#1077#1077' '#1086#1082#1085#1086
        OnClick = mnFileCloseClick
      end
      object mnFileCloseall: TMenuItem
        Caption = #1047#1072#1082#1088#1099#1090#1100' &'#1074#1089#1077
        Hint = #1047#1072#1082#1088#1099#1090#1100' '#1074#1089#1077' '#1086#1082#1085#1072
        OnClick = mnFileCloseallClick
      end
      object mnFlatLine2: TMenuItem
        Caption = '-'
      end
      object mnFileRefresh: TMenuItem
        Caption = #1054#1073#1085#1086#1074#1080#1090#1100' '#1080#1085#1089#1090#1088#1091#1084#1077#1085#1090#1099
        ShortCut = 119
        OnClick = mnFileRefreshClick
      end
      object mnFileRefactory: TMenuItem
        Caption = #1056#1077#1092#1072#1082#1090#1086#1088#1080#1085#1075
        OnClick = mnFileRefactoryClick
      end
      object mnFileLine1: TMenuItem
        Caption = '-'
      end
      object mnFileExport: TMenuItem
        Caption = '&'#1043#1077#1085#1077#1088#1072#1094#1080#1103' MQL4'
        ShortCut = 115
        OnClick = mnFileExportClick
      end
      object mnFileCompile: TMenuItem
        Caption = #1050#1086#1084#1087#1080#1083#1080#1088#1086#1074#1072#1090#1100
        ShortCut = 116
        OnClick = mnFileCompileClick
      end
      object mnFileRun: TMenuItem
        Caption = #1047#1072#1087#1091#1089#1090#1080#1090#1100
        ShortCut = 120
        Visible = False
        OnClick = mnFileRunClick
      end
      object mnFileLine2: TMenuItem
        Caption = '-'
      end
      object mnFileExit: TMenuItem
        Caption = '&'#1042#1099#1093#1086#1076
        Hint = #1042#1099#1081#1090#1080' '#1080#1079' '#1087#1088#1086#1075#1088#1072#1084#1084#1099
        OnClick = mnFileExitClick
      end
      object mnFlatLine4: TMenuItem
        Tag = 1
        Caption = '-'
      end
      object mnFileHist: TMenuItem
        Caption = '<'#1080#1089#1090#1086#1088#1080#1103'>'
        OnClick = mnFileHistClick
      end
    end
    object mnEdit: TMenuItem
      Caption = '&'#1055#1088#1072#1074#1082#1072
      GroupIndex = 1
      object mnEditUndo: TMenuItem
        Action = actUndo
      end
      object mnEditRedo: TMenuItem
        Action = actRedo
      end
      object mnFlatLine3: TMenuItem
        Caption = '-'
      end
      object mnEditCut: TMenuItem
        Action = actCut
      end
      object mnEditCopy: TMenuItem
        Action = actCopy
      end
      object mnEditPaste: TMenuItem
        Action = actPaste
      end
      object mnEditDelete: TMenuItem
        Action = actDelete
      end
      object N1: TMenuItem
        Action = actSelectAll
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object mnHConnect: TMenuItem
        Caption = #1057#1086#1077#1076#1080#1085#1080#1090#1100' '#1075#1086#1088#1080#1079#1086#1085#1090#1072#1083#1080
        ShortCut = 16469
        OnClick = mnHConnectClick
      end
      object mnColorLinks: TMenuItem
        Caption = #1056#1072#1089#1082#1088#1072#1089#1080#1090#1100' '#1089#1074#1103#1079#1080
        OnClick = mnColorLinksClick
      end
      object mnEditProtect: TMenuItem
        AutoCheck = True
        Caption = #1059#1089#1090#1072#1085#1086#1074#1080#1090#1100'/'#1089#1085#1103#1090#1100' '#1079#1072#1097#1080#1090#1091
        OnClick = mnEditProtectClick
      end
    end
  end
  object SaveDialog: TSaveDialog
    DefaultExt = 'html'
    Filter = #1060#1072#1081#1083#1099' MQ4|*.mq4|'#1051#1102#1073#1086#1081' '#1092#1072#1081#1083'|*.*'
    Left = 176
    Top = 40
  end
  object PopupMenu: TPopupMenu
    Left = 216
    Top = 8
    object mnPopupCut: TMenuItem
      Action = actCut
    end
    object mnPopupCopy: TMenuItem
      Action = actCopy
    end
    object mnPopupPaste: TMenuItem
      Action = actPaste
    end
    object mnPopupDelete: TMenuItem
      Action = actDelete
    end
    object N3: TMenuItem
      Action = actGo
    end
  end
  object ActionList: TActionList
    Left = 216
    Top = 72
    object actCut: TEditCut
      Category = 'Edit'
      Caption = #1042#1099#1088#1077#1079#1072#1090#1100
      Enabled = False
      Hint = 'Cut|Cuts the selection and puts it on the Clipboard'
      ImageIndex = 0
      OnExecute = mnEditCutClick
    end
    object actCopy: TEditCopy
      Category = 'Edit'
      Caption = #1050#1086#1087#1080#1088#1086#1074#1072#1090#1100
      Enabled = False
      Hint = 'Copy|Copies the selection and puts it on the Clipboard'
      ImageIndex = 1
      OnExecute = mnEditCopyClick
    end
    object actPaste: TEditPaste
      Category = 'Edit'
      Caption = #1042#1089#1090#1072#1074#1080#1090#1100
      Enabled = False
      Hint = 'Paste|Inserts Clipboard contents'
      ImageIndex = 2
      OnExecute = mnEditPasteClick
      OnUpdate = actPasteUpdate
    end
    object actSelectAll: TEditSelectAll
      Category = 'Edit'
      Caption = #1042#1099#1073#1088#1072#1090#1100' '#1074#1089#1077
      Hint = 'Select All|Selects the entire document'
      ShortCut = 16449
      OnExecute = actSelectAllExecute
    end
    object actDelete: TEditDelete
      Category = 'Edit'
      Caption = #1059#1076#1072#1083#1080#1090#1100
      Enabled = False
      Hint = 'Delete|Erases the selection'
      ImageIndex = 5
      OnExecute = mnEditDeleteClick
      OnUpdate = actDeleteUpdate
    end
    object actUndo: TEditUndo
      Category = 'Edit'
      Caption = #1054#1090#1084#1077#1085#1080#1090#1100
      Enabled = False
      Hint = 'Undo|Reverts the last action'
      ImageIndex = 3
      ShortCut = 16474
      OnExecute = actUndoExecute
      OnUpdate = actUndoUpdate
    end
    object actRedo: TAction
      Category = 'Edit'
      Caption = #1042#1077#1088#1085#1091#1090#1100
      Enabled = False
      ShortCut = 16466
      OnExecute = actRedoExecute
      OnUpdate = actRedoUpdate
    end
    object actGo: TAction
      Category = 'Edit'
      Caption = #1055#1077#1088#1077#1081#1090#1080
      Enabled = False
      OnExecute = actGoExecute
      OnUpdate = actGoUpdate
    end
  end
end
