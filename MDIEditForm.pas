unit MDIEditForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, ExtCtrls, ToolWin, ComCtrls, StdCtrls,
  UseFull, ConfirmFrm, Scripts, Editors, Globals, StdActns,
  ActnList, MSHTML, ActiveX, LogFrm, PerlRegEx, OleCtrls, SHDocVw, Grids,
  Buttons, ValEdit, StrUtils;

type
  TEditForm = class(TForm)
    MainMenu1: TMainMenu;
    mnFile: TMenuItem;
    mnEdit: TMenuItem;
    mnEditCopy: TMenuItem;
    mnEditCut: TMenuItem;
    mnEditPaste: TMenuItem;
    mnEditDelete: TMenuItem;
    SaveDialog: TSaveDialog;
    mnFileCloseall: TMenuItem;
    PopupMenu: TPopupMenu;
    mnPopupCut: TMenuItem;
    mnPopupCopy: TMenuItem;
    mnPopupPaste: TMenuItem;
    mnPopupDelete: TMenuItem;
    ActionList: TActionList;
    actCut: TEditCut;
    actCopy: TEditCopy;
    actPaste: TEditPaste;
    actSelectAll: TEditSelectAll;
    actDelete: TEditDelete;
    N1: TMenuItem;
    mnFlatLine2: TMenuItem;
    mnFileNew: TMenuItem;
    mnFileRefresh: TMenuItem;
    mnFileExport: TMenuItem;
    mnFileCompile: TMenuItem;
    actRedo: TAction;
    mnFlatLine3: TMenuItem;
    mnEditUndo: TMenuItem;
    mnEditRedo: TMenuItem;
    actUndo: TEditUndo;
    mnFileRun: TMenuItem;
    N2: TMenuItem;
    mnHConnect: TMenuItem;
    mnFlatLine4: TMenuItem;
    mnFileHist: TMenuItem;
    mnColorLinks: TMenuItem;
    mnFileRefactory: TMenuItem;
    mnFileNewObject: TMenuItem;
    Splitter3: TSplitter;
    PanelRight: TPanel;
    Splitter5: TSplitter;
    GroupPars: TGroupBox;
    Shape2: TShape;
    ValueListEditor: TValueListEditor;
    GroupLayers: TGroupBox;
    PanelMain: TPanel;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    PanelTools: TPanel;
    SpeedButtonUp: TSpeedButton;
    SpeedButtonDown: TSpeedButton;
    ToolsList: TStringGrid;
    GroupMain: TGroupBox;
    Shape1: TShape;
    Panel: TPanel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label1: TLabel;
    EditObject: TEdit;
    PanelWeb: TPanel;
    WebBrowser: TWebBrowser;
    cbDefaultIn: TComboBox;
    MemoComment: TMemo;
    chDebug: TCheckBox;
    cbDefaultObj: TComboBox;
    SpeedButtonLUp: TSpeedButton;
    SpeedButtonLDown: TSpeedButton;
    SpeedButtonAdd: TSpeedButton;
    SpeedButtonDel: TSpeedButton;
    ListLayers: TStringGrid;
    ScrollBox: TScrollBox;
    PaintBox: TPaintBox;
    cbProtected: TCheckBox;
    mnEditProtect: TMenuItem;
    actGo: TAction;
    N3: TMenuItem;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure mnFileCloseClick(Sender: TObject);
    procedure mnFileExitClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure PaintBoxMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxPaint(Sender: TObject);
    procedure mnFileSaveAsClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure mnEditCutClick(Sender: TObject);
    procedure mnEditCopyClick(Sender: TObject);
    procedure mnEditDeleteClick(Sender: TObject);
    procedure mnEditPasteClick(Sender: TObject);
    procedure mnFileCloseallClick(Sender: TObject);
    procedure mnFileSaveClick(Sender: TObject);
    procedure mnFileOpenClick(Sender: TObject);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure actPasteUpdate(Sender: TObject);
    procedure mnFileExportClick(Sender: TObject);
    procedure mnFileRefreshClick(Sender: TObject);
    procedure mnFileCompileClick(Sender: TObject);
    procedure mnFileNewClick(Sender: TObject);
    procedure actUndoUpdate(Sender: TObject);
    procedure actRedoUpdate(Sender: TObject);
    procedure actUndoExecute(Sender: TObject);
    procedure actRedoExecute(Sender: TObject);
    procedure actSelectAllExecute(Sender: TObject);
    procedure actDeleteUpdate(Sender: TObject);
    procedure mnFileRunClick(Sender: TObject);
    procedure PaintBoxDblClick(Sender: TObject);
    procedure mnHConnectClick(Sender: TObject);
    procedure mnFileHistClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure mnColorLinksClick(Sender: TObject);
    procedure mnFileRefactoryClick(Sender: TObject);
    procedure mnFileNewObjectClick(Sender: TObject);
    procedure ToolsListClick(Sender: TObject);
    procedure SpeedButtonUpClick(Sender: TObject);
    procedure SpeedButtonDownClick(Sender: TObject);
    procedure ValueListEditorGetPickList(Sender: TObject; const KeyName: String; Values: TStrings);
    procedure ValueListEditorStringsChange(Sender: TObject);
    procedure ValueListEditorEnter(Sender: TObject);
    procedure ValueListEditorExit(Sender: TObject);
    procedure EditObjectChange(Sender: TObject);
    procedure ValueListEditorSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
    procedure ValueListEditorGetEditMask(Sender: TObject; ACol, ARow: Integer; var Value: String);
    procedure MemoCommentChange(Sender: TObject);
    procedure chDebugClick(Sender: TObject);
    procedure Splitter3Moved(Sender: TObject);
    procedure cbDefaultInChange(Sender: TObject);
    procedure cbDefaultObjChange(Sender: TObject);
    procedure ListLayersDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure SpeedButtonAddClick(Sender: TObject);
    procedure ListLayersClick(Sender: TObject);
    procedure SpeedButtonDelClick(Sender: TObject);
    procedure SpeedButtonLUpClick(Sender: TObject);
    procedure ListLayersSetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: String);
    procedure SpeedButtonLDownClick(Sender: TObject);
    procedure ListLayersDblClick(Sender: TObject);
    procedure cbProtectedClick(Sender: TObject);
    procedure mnEditProtectClick(Sender: TObject);
    procedure actGoUpdate(Sender: TObject);
    procedure actGoExecute(Sender: TObject);
  private
    SavePoint:TPoint; //сохранение точки при вызове меню
    PerlRegEx: TPerlRegEx;

  public
    FilePath:string; //путь файла на диске
    TabIndex:integer; // номер таба
    NewFile:boolean; //статус нового файла
    Modified:boolean;

    Hold:boolean; //флаг отмены обновления объекта при заполнении
                  //полей редактора свойств

    Board:tsBoard; //список объектов
    MultiBoard:tsMultiBoard;
    Selected, LastSelected:tsEntity; //выделенный объект

    ToolEditor:teObject;

    History:array [1..HistoryDepth] of TMemoryStream;
    HistPos:integer;

    ScrollMode:boolean;
    ScrollPos:TPoint;

    constructor Create(owner: TComponent); override;
    procedure ReDraw(ts:tsBoard);

    //обновить размер области редактирования в соответствии с
    //изменёнными свойствами объектов
    function UpdateSize:boolean;

    //установка режима рисования
    procedure SetPenTool;

    // опрос статуса рисования
    procedure ProcessStatus(status:string);

    // обработка выбора объекта
    procedure ProcessSelect(ts:tsUnit);

    procedure ProcessChange;

    //Создать меню объектов
    procedure CreateMenu;
    procedure UpdateLastList;

    //Обновить список объектов из текущего окна
    procedure UpdateToolsList;

    procedure UpdateLayersList;
  end;

implementation

uses Main;

{$R *.DFM}

resourcestring
  RSLayerLocation = '<объект слоя>';
  RSSchemaLocation = '<объект схемы>';
  RSNoDescription = 'Описание отсутствует';
  RSMainLayer = 'главный';
  RSAnyFile = 'Любой файл';
  RSSaveNewFile = 'Сохранить новый файл?';
  RSFileWasChanged = 'Файл "%s" был изменён. Сохранить изменения?';
  RSLayers = 'Слои';
  RSGenerate = 'Генерация';
  RSCompiled = 'Скомпилирован';
  RSSourcesNotFound = 'Исходник не найден. Нельзя снять защиту.';
  RSProtectionError = 'Ошибка снятия защиты';
  RSEmpty = '<пусто>';
  RSNew = 'новый';
  RSRemoveLayer = 'Удалить слой %s?';

constructor TEditForm.Create(owner: TComponent);
begin
  PerlRegEx:=TPerlRegEx.Create;
  PerlRegEx.Options:=[preMultiLine];

  inherited;
end;

procedure TEditForm.ProcessStatus(status:string);
begin
  MainForm.StatusBar.SimpleText:=status;
end;

procedure TEditForm.ProcessSelect(ts:tsUnit);
var
  wb:IHTMLDocument2;
  main:OleVariant;
  n:integer;

  function MiniWiki(txt:string):string;
  const
    smileys:array[1..10] of string = (':-)','=)',':-D',':-(',':-/',':-\','8-)',':-|',':-o',';-)');
    smilepics:array[1..10] of string = ('smile','smile2','biggrin','cry','doubt','doubt2','eek','neutral','surprised','wink');
  var n:integer;
  begin
    PerlRegEx.Subject:=txt;

    with PerlRegEx do
    begin
      Options:=Options + [preUnGreedy];

      RegEx:='\Q**\E(.+)\Q**\E';
      Replacement:='<b>\1</b>';
      ReplaceAll;

      RegEx:='//(.*)//';
      Replacement:='<i>\1</i>';
      ReplaceAll;

      RegEx:='\[\[(\w+@\w+[.]\w+)\]\]';
      Replacement:='<a href="mailto:\1" target="browse">\1</a>';
      ReplaceAll;

      RegEx:='\[\[(.+)\]\]';
      Replacement:='<a href="http://\1" target="browse">\1</a>';
      ReplaceAll;

      Options:=Options + [preSingleLine];
      RegEx:='<code>(.*)</code>';
      Replacement:='<div><pre>\1</pre></div>';
      ReplaceAll;

      Options:=Options - [preUnGreedy,preSingleLine];

      RegEx:='^\s{2}-(.+)$';
      Replacement:='<ol>'#13#10'<li>\1</li>'#13#10'</ol>';
      ReplaceAll;

      RegEx:='^\s{2}\*(.+)$';
      Replacement:='<ul>'#13#10'<li>\1</li>'#13#10'</ul>';
      ReplaceAll;

      RegEx:='</ol>'#13#10'<ol>'#13#10;
      Replacement:='';
      ReplaceAll;

      RegEx:='</ul>'#13#10'<ul>'#13#10;
      Replacement:='';
      ReplaceAll;

      RegEx:='\\\\$';
      Replacement:='<br/>';
      ReplaceAll;

      RegEx:='^----$';
      Replacement:='<hr/>';
      ReplaceAll;

      //smiles
      for n:=1 to High(smileys) do
      begin
        RegEx:='\Q'+smileys[n]+'\E';
        Replacement:='<img src="smileys\icon_'+smilepics[n]+'.gif" />';
        ReplaceAll;
      end;
    end;

    Result:=PerlRegEx.Subject+'<br/>';
  end;

  function genUses(lines:TStringList; first:boolean=false):string;
  var
    n,p:integer;
  begin
    if (lines=nil) or (lines.Count=0) then Result:=''
    else
    begin
      Result:=IfThen(first,'<hr/','')+'<ul class="uses">';
      for n:=0 to lines.Count-1 do
      begin
        p:=Board.sCollection.IndexOfScript(lines[n]);
        if p>=0 then
          Result:=Result+Format('<li>%s <a href="%s">[%s.o]</a>%s</li>', [Board.sCollection[p], Board.sCollection.Objects[p].ScriptFileName, lines[n], genUses(Board.sCollection.Objects[p].sUses)])
        else
          Result:=Result+Format('<li><a href="../Schema/%s/%s.o">[%s.o]</a>%s</li>', [Board.sCollection.SchemePath, lines[n], lines[n], genUses(Board.sCollection.Objects[p].sUses)]);
      end;
      Result:=Result+'</ul>';
    end;
  end;

begin
  if ts is tsEntity then
  begin
    Selected:=ts as tsEntity;
    LastSelected:=nil;
    with MainForm do
    begin
      EditObject.Text:=Selected.Name;

      cbDefaultIn.Clear;
      for n:=0 to Length(Selected.Source.Input)-1 do
        cbDefaultIn.Items.Add(Selected.Source.Input[n].Name);
      cbDefaultIn.Items.Add(RSLayerLocation);
      cbDefaultIn.Items.Add(RSSchemaLocation);
      cbDefaultIn.ItemIndex:=Selected.ParsInput;
      cbDefaultInChange(Self);

      wb:=WebBrowser.Document as IHTMLDocument2;
      main:=wb.all.item('caption',0);
      main.innerHTML:=Selected.Source.ObjectName;
      main:=wb.all.item('main',0);

      if Selected.Source.sHelp<>nil then
        main.innerHTML:=MiniWiki(string(Selected.Source.sHelp.GetText))+genUses(Selected.Source.sUses, true)
      else
        main.innerHTML:='<p><font color=gray>'+RSNoDescription+'</font></p>'+genUses(Selected.Source.sUses, true);

      main:=wb.all.item('filename',0);
      if Selected.Source.LayerIndex=0 then
        main.innerHTML:=Format('<a href="%s">[%s.o]</a>', [Selected.Source.ScriptFileName, Selected.Source.ScriptName])
      else
        main.innerHTML:='';
      //main.innerHTML:=Format('<a href="shellrun(''../Schema/%s/%s.o'')">[%s.o]</a>', [Board.sCollection.Name, Selected.Source.ScriptName, Selected.Source.ScriptName]);

      ValueListEditor.Strings.Clear;
      for n:=0 to Length(Selected.Source.Propertyes)-1 do
        ValueListEditor.InsertRow(Selected.Source.Propertyes[n].Name, Selected.PropValues[n], true);

      MemoComment.Enabled:=false;
      MemoComment.Clear;
      MemoComment.Lines.AddStrings(Selected.Comments);
      MemoComment.Enabled:=true;

      chDebug.Checked:=Selected.Debug;
      //chEnabled.Enabled:=not Selected.Source.ModelFlag;
      cbProtected.Checked:=Selected.IsProtected;

      Panel.Show;
      ValueListEditor.Show;

      if PanelTools.Visible then
        ToolsList.Row:=Selected.Index+1;
    end;
    LastSelected:=Selected;
  end
  else
  begin
    Panel.Hide;
    ValueListEditor.Hide;
    Selected:=nil;
    LastSelected:=nil;
  end;
end;

procedure TEditForm.ProcessChange;
var n:integer;
begin
  UpdateToolsList;
  Modified:=true;

  // сохранить историю
  if HistPos=HistoryDepth then
  begin
    FreeAndNil(History[1]);
    for n:=1 to HistoryDepth-1 do
      History[n]:=History[n+1];
  end
  else
    inc(HistPos);

  if History[HistPos]<>nil then
    for n:=HistPos to HistoryDepth do
      if History[n]=nil then break
      else FreeAndNil(History[n]);

  History[HistPos]:=TMemoryStream.Create;
  MultiBoard.writeRAW(History[HistPos], false);
end;

// установка режима рисования
procedure TEditForm.SetPenTool;
var
 ToolMode: tsDrawTool;
 ObjIndex:integer;
begin
  ToolMode:=MainForm.CurPenTool;
  ObjIndex:=MainForm.CurToolTag;

  if ToolEditor<>nil then FreeAndNil(ToolEditor);
  case ToolMode of
    dtArrow: ToolEditor:=teArrow.Create(Board, PaintBox);
    dtLink: ToolEditor:=teChain.Create(Board, PaintBox);
    dtEntity:
    begin
      ToolEditor:=teEntity.Create(Board, PaintBox);
      if ObjIndex>=0 then
        (ToolEditor as teEntity).Source:=Board.sCollection.Objects[ObjIndex]
      else
        (ToolEditor as teEntity).Source:=MultiBoard.lObjects[-1-ObjIndex];
    end;
  end;
  ToolEditor.OnStatus:=ProcessStatus;
  ToolEditor.OnSelect:=ProcessSelect;
  ToolEditor.OnChange:=ProcessChange;
  ToolEditor.DoRepaint:=ReDraw;
end;

// Основные события

procedure TEditForm.FormCreate(Sender: TObject);
var n:integer;
begin
  //Иниц списка объектов
  with ToolsList do
    begin
    Cells[0, 0]:='#';
    Cells[1, 0]:='Type';
    ColWidths[0]:=40;
    ColWidths[1]:=Width-40;
    end;

  // окно помощи
  WebBrowser.Navigate('file:///'+ExtractFilePath(ParamStr(0))+'help\template.htm');

  //установка статусов кнопок
  MainForm.ToolSave.Enabled:=True;
  with MainForm do
  begin
    ToolArrow.Enabled:=true;
    ToolLink.Enabled:=true;
    ToolObject.Enabled:=true;
    ToolCompile.Enabled:=True;
  end;

  if WindowState<>MainForm.MDIWindowState then
    WindowState:=MainForm.MDIWindowState;

  //задание начальных значений переменных
  NewFile:=TRUE;
  Modified:=FALSE;
  Hold:=FALSE;

  Board:=tsBoard.Create;
  Board.sCollection:=MainForm.sCollection;
  MultiBoard:=tsMultiBoard.Create;
  MultiBoard.Add(RSMainLayer);
  SetLength(MultiBoard.Layers, 1);
  MultiBoard.Layers[0]:=Board;
  UpdateLayersList;

  SaveDialog.Filter:=Board.sCollection.Env.Values['DestMask']+'|'+RSAnyFile+'|*.*';

  ToolEditor:=nil;
  Selected:=nil;

  HistPos:=0;
  for n:=1 to HistoryDepth do History[n]:=nil;

  ScrollMode:=false;

  ListLayers.ColWidths[0]:=20;
end;

procedure TEditForm.FormClose(Sender: TObject; var Action: TCloseAction);
var n:integer;
begin
  Action:=caFree;

  // сброс панели редактирования объектов
  //SelectTool(-1);
  Panel.Hide;
  ValueListEditor.Hide;

  // если закрывается последняя форма, то деактивируем некоторые кнопки
  with MainForm do
    if MDIChildCount=1 then
      begin
      ToolSave.Enabled:=False;
      ToolArrow.Enabled:=false;
      ToolObject.Enabled:=false;
      ToolLink.Enabled:=false;
      ToolCompile.Enabled:=False;
      end;

  // удаление мусора
  for n:=1 to HistoryDepth do
    if Assigned(History[n]) then History[n].Free;

  FreeAndNil(ToolEditor);
  FreeAndNil(MultiBoard);

  // сброс списка объектов
  UpdateToolsList;

  // удаление табы
  for n:=0 to MainForm.MDIChildCount-1 do
    if (MainForm.MDIChildren[n] as TEditForm).TabIndex>TabIndex then
      dec((MainForm.MDIChildren[n] as TEditForm).TabIndex);
  MainForm.TabWindows.Tabs.Delete(TabIndex);
end;

procedure TEditForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose:=True;
  if Modified then
    begin
    if NewFile then
      ConfirmForm.Label1.Caption:=RSSaveNewFile
    else
      ConfirmForm.Label1.Caption:=Format(RSFileWasChanged, [ExtractFileName(FilePath)]);
    case ConfirmForm.ShowModal of
      mrYes: MainForm.ToolSaveClick(Sender);
      mrCancel: CanClose:=False;
      end;
    end;
end;

procedure TEditForm.CreateMenu;
type
  TAr = array of TMenuItem;
  PAr = ^TAr;

var
  menu,sub_menu:TAr;
  curmenu:PAr;
  st:TStringList;
  s:string;
  i,len,idx:integer;

  last_group, group:string;

  function Next:string;
  var p:integer;
  begin
    p:=pos('\',s);
    if p=0 then p:=length(s)+1;
    //else
    //begin
      result:=LeftStr(s,p-1);
      s:=MidStr(s,p+1,length(s));
    //end;
  end;

begin
  st:=TStringList.Create;
  st.AddStrings(Board.sCollection);
  st.CaseSensitive:=false;
  st.Sort;

  last_group:='';
  curmenu:=@menu;
  for i:=0 to st.Count-1 do
  begin
    s:=st[i];

    idx:=Board.sCollection.IndexOf(s);
    if Board.sCollection.Objects[idx].oType in [totDeprecated, totUsable] then continue;

    group:=next;

    if group<>last_group then
    begin
      last_group:=group;

      len:=length(menu);
      if length(sub_menu)>0 then
      begin
        menu[len-1].Add(sub_menu);
        SetLength(sub_menu, 0);
      end;

      if group<>'' then
      begin
        SetLength(menu, len+1);
        menu[len]:=TMenuItem.Create(Self);
        menu[len].Caption:=last_group;
        curmenu:=@sub_menu;
      end
      else
        curmenu:=@menu;
    end;

    len:=length(curmenu^);
    SetLength(curmenu^, len+1);
    curmenu^[len]:=TMenuItem.Create(self);
    with curmenu^[len] do
    begin
      idx:=Board.sCollection.IndexOf(st[i]);
      Caption:=Board.sCollection.Objects[idx].ObjectName;
      OnClick:=MainForm.ToolObjectClick;
      Tag:=idx;
    end;
  end;

  if length(sub_menu)>0 then
  begin
    len:=length(menu);
    menu[len-1].Add(sub_menu);
    SetLength(sub_menu, 0);
  end;

  // добавить слои
  if MultiBoard.Count>1 then
  begin
    // поиск меню "слои"
    idx:=-1;
    for i:=0 to Length(menu)-1 do
      if menu[i].Caption=RSLayers then
      begin
        idx:=i;
        break;
      end;

    if idx<0 then
    begin
      idx:=Length(menu);
      SetLength(menu, idx+1);
      menu[idx]:=TMenuItem.Create(Self);
      menu[idx].Caption:=RSLayers;
    end;

    SetLength(sub_menu, MultiBoard.Count);
    sub_menu[0]:=TMenuItem.Create(self);
    sub_menu[0].Caption:='-';
    for i:=1 to MultiBoard.Count-1 do
    begin
      sub_menu[i]:=TMenuItem.Create(self);
      with sub_menu[i] do
      begin
        Caption:=MultiBoard[i];
        OnClick:=MainForm.ToolObjectClick;
        Tag:=-i;
      end;
    end;

    menu[idx].Add(sub_menu);
  end;

  {SetLength(mn, Length(sCollection.Objects));
  for i:=0 to Length(mn)-1 do
  begin
    mn[i]:=TMenuItem.Create(Self);
    with mn[i] do
    begin
      Caption:=sCollection.Objects[i].ObjectName;
      Tag:=i;
      OnClick:=ToolObjectClick;//MenuObjectClick;
    end;
  end;}

  MainForm.mnObject.Items.Clear;
  MainForm.mnObject.Items.Add(menu);
  MainForm.ToolObject.DropdownMenu:=MainForm.mnObject;
end;

procedure TEditForm.FormActivate(Sender: TObject);
begin
  ToolsList.Visible:=MainForm.mnViewTools.Checked;
  ToolsList.Enabled:=MainForm.mnViewTools.Checked;
  PanelTools.Visible:=MainForm.mnViewTools.Checked;
  Splitter1.Visible:=MainForm.mnViewTools.Checked;

  GroupMain.Visible:=MainForm.mnViewPropertyeditor.Checked;

  GroupPars.Visible:=MainForm.mnViewParamEditor.Checked;

  Board.CalcPrioIndices(MainForm.mnViewTools.Checked);
  Board.Repaint(PaintBox.Canvas);

  // обновление списка объектов
  if MainForm.mnViewTools.Checked then
    UpdateToolsList;

  // проверка буфера обмена
  actPaste.Enabled:=Clipboard2.IsBoard;

  // создание меню
  CreateMenu;
  UpdateLastList;

  mnFileRun.Visible:=Board.sCollection.Env.Values['Run']<>'';

  // пометки
  mnFileExport.Caption:=RSGenerate+' '+Board.sCollection.Name;

  SetPenTool;

  MainForm.TabWindows.OnChange:=nil;
  MainForm.TabWindows.TabIndex:=TabIndex;
  MainForm.TabWindows.OnChange:=MainForm.TabWindowsChange;
end;

// Прорисовка

procedure TEditForm.ReDraw;
var
  n:word;
  g:TPicture;
  s:string;
begin
  if UpdateSize then exit;

  g:=TPicture.Create;
  g.Bitmap.Width:=PaintBox.Width;
  g.Bitmap.Height:=PaintBox.Height;

//  with PaintBox.Canvas do
  with g.Bitmap.Canvas do
  begin
    Font:=PaintBox.Font;

    //очистка всей области
    Brush.Color:=clWhite;
    Pen.Color:=clBlack;
    Rectangle(PaintBox.ClientRect);

    //пометка
    Brush.Color:=clWhite;//clBlack;
    //Rectangle(0,0,PaintBox.ClientRect.Right, GridY);
    Font.Color:=$6F5F7F;//clBlack;//$A0A0A0;//clLime;
    //Font.Style:=[fsBold];

    s:=Board.sCollection.Env.Values['Title'];
    //Rectangle(0, 0, GridX+1,GridY*Length(s)+1);
    //Rectangle(0, 0, GridX*Length(s)+1,GridY+1);
    for n:=1 to Length(s) do
    begin
      //TextOut(4+GridX*(n-1), 1, s[n]);
      TextOut(4, 1+GridY*(n-1), s[n]);
    end;

    //TextOut(2,2,Board.sCollection.Env.Values['Title']);
    //сетка
    Pen.Color:=$A0A0A0;
    Pen.Style:=psSolid;
    n:=GridX;
    while n<PaintBox.Width do
    begin
      MoveTo(n, 0);
      LineTo(n, PaintBox.Height);
      inc(n, GridX);
    end;
    n:=GridY;
    while n<PaintBox.Height do
    begin
      MoveTo(0,n);
      LineTo(PaintBox.Width,n);
      inc(n, GridY);
    end;

    Font.Color:=0;
    Font.Style:=[];
  end;

  ts.Repaint(g.Bitmap.Canvas);
  PaintBox.Canvas.Draw(0,0,g.Graphic);
  g.Free;
end;

procedure TEditForm.PaintBoxPaint(Sender: TObject);
begin
  ReDraw(Board);
end;

function TEditForm.UpdateSize:boolean;
var
  n, Max: word;
  LastW, LastH, NewW, NewH:integer;
begin
  LastW:=PaintBox.Width;
  LastH:=PaintBox.Height;
  NewW:=PaintBox.Width;
  NewH:=PaintBox.Height;

  if Length(Board.Entityes)>0 then
  begin
    Max:=0;
    for n:=0 to Length(Board.Entityes)-1 do
      if Board.Entityes[n].Rect.Right*GridX>Max then
        Max:=Board.Entityes[n].Rect.Right*GridX;
    if NewW<Max+300 then
      NewW:=Max+300;

    Max:=0;
    for n:=0 to Length(Board.Entityes)-1 do
      if Board.Entityes[n].Rect.Bottom*GridY>Max then
        Max:=Board.Entityes[n].Rect.Bottom*GridY;
    if NewH<Max+300 then
      NewH:=Max+300;
  end;

  Result:=false;

  if LastW<NewW then
  begin
    PaintBox.Align:=alLeft;
    PaintBox.Width:=NewW;
    Result:=true;
  end;

  if LastH<NewH then
  begin
    if PaintBox.Align=alClient then PaintBox.Align:=alTop
    else PaintBox.Align:=alNone;
    PaintBox.Height:=NewH;
    Result:=true;
  end;
end;

// Обработчик мыши

procedure TEditForm.PaintBoxMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button=mbMiddle then
  begin
    PaintBox.Cursor:=crHandPoint;
    ScrollMode:=true;
    ScrollPos:=PaintBox.ClientToScreen(Point(X,Y));
    exit;
  end;
  //actDelete.ShortCut:=ShortCut(VK_DELETE, []);
  if ToolEditor<>nil then ToolEditor.MouseDown(Sender, Button, Shift, X, Y);
end;

procedure TEditForm.PaintBoxMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
  p:TPoint;
  dx,dy:integer;
begin
  if ScrollMode {and (X>0) and (Y>0)} then
  with ScrollBox do
  begin
    p:=PaintBox.ClientToScreen(Point(X,Y));
    dx:=(p.X-ScrollPos.X) div 8;
    if (dx<0) and (-dx>HorzScrollBar.Position) then dx:=-HorzScrollBar.Position;
    if (dx>0) and (dx>HorzScrollBar.Range-HorzScrollBar.Position) then dx:=HorzScrollBar.Range-HorzScrollBar.Position;
    HorzScrollBar.Position:=HorzScrollBar.Position+dx;
    dy:=(p.Y-ScrollPos.Y) div 8;
    if (dy<0) and (-dy>VertScrollBar.Position) then dy:=-VertScrollBar.Position;
    if (dy>0) and (dy>VertScrollBar.Range-VertScrollBar.Position) then dy:=VertScrollBar.Range-VertScrollBar.Position;
    VertScrollBar.Position:=VertScrollBar.Position+dy;
    //self.ScrollBy(dx, (ScrollPos.Y-p.Y) div 8);
    //ScrollPos:=p;
  end;
  if ToolEditor<>nil then
    ToolEditor.MouseMove(Sender, Shift, X, Y);
end;

procedure TEditForm.PaintBoxMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button=mbMiddle then
  begin
    PaintBox.Cursor:=crDefault;
    ScrollMode:=false;
    exit;
  end;
  if Button=mbRight then SavePoint:=Point(X-X mod GridX,Y-Y mod GridY);
  if ToolEditor<>nil then ToolEditor.MouseUp(Sender, Button, Shift, X, Y);
end;

// Обработчик колеса

procedure TEditForm.FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  if ssCTRL in Shift then
  begin
    if GridX>1 then
    begin
      dec(GridX);
      dec(GridY);
      Board.ConnectChains;
      ReDraw(Board);
    end;
  end
  else
  with VertScrollBar do
    Position:=Position+Increment;
end;

procedure TEditForm.FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  if ssCTRL in Shift then
  begin
    if GridX<32 then
    begin
      inc(GridX);
      inc(GridY);
      Board.ConnectChains;
      ReDraw(Board);
    end;
  end
  else
  with VertScrollBar do
    Position:=Position-Increment;
end;

procedure TEditForm.PaintBoxDblClick(Sender: TObject);
begin
  if ToolEditor<>nil then
    if Selected is tsEntity then
    begin
      Selected.Enabled:=not Selected.Enabled;
      ReDraw(Board);
      ProcessChange;
    end;
end;

// Меню Правка

procedure TEditForm.mnEditCopyClick(Sender: TObject);
begin
  Clipboard2.SetBoard(Board);
end;

procedure TEditForm.mnEditDeleteClick(Sender: TObject);
begin
  Board.DelSelect;
  Board.ConnectChains;
  UpdateToolsList;
  Redraw(Board);
  ProcessSelect(nil);
  ProcessChange;
end;

procedure TEditForm.mnEditCutClick(Sender: TObject);
begin
  mnEditCopyClick(Sender);
  mnEditDeleteClick(Sender);
end;

procedure TEditForm.mnEditPasteClick(Sender: TObject);
var
  ts:tsBoard;
begin
  ts:=Clipboard2.GetBoard;
  if ts=nil then exit;

  //вставка со сдвигом
  ts.ClearSelect(true);
  ts.ReducePos;

  ts.MoveSelected(SavePoint.X, SavePoint.Y);
  Board.ClearSelect;
  Board.Merge(ts);
  ts.Free;

  UpdateToolsList;
  
  Board.ConnectChains;
  Redraw(Board);
  //SelectTool(Tools.Count-1); //сделать новый объект текущим

  ProcessChange;
end;

procedure TEditForm.actPasteUpdate(Sender: TObject);
begin
  actPaste.Enabled:=Clipboard2.IsBoard;
end;

procedure TEditForm.actUndoUpdate(Sender: TObject);
begin
  actUndo.Enabled:=HistPos>1;
end;

procedure TEditForm.actRedoUpdate(Sender: TObject);
begin
  actRedo.Enabled:=(HistPos<HistoryDepth) and (History[HistPos+1]<>nil);
end;

procedure TEditForm.actGoUpdate(Sender: TObject);
begin
  actGo.Enabled:=(Selected<>nil) and (Selected.Source.oType=totLayer);
end;

procedure TEditForm.actUndoExecute(Sender: TObject);
begin
  FreeAndNil(ToolEditor);
  //Board.Free;
  MultiBoard.Free;
  dec(HistPos);
  //Board:=readRAW(History[HistPos]);
  MultiBoard:=readMultiRAW(History[HistPos]);
  Board:=MultiBoard.Layers[ListLayers.Row];
  ReDraw(Board);
  SetPenTool;
end;

procedure TEditForm.actRedoExecute(Sender: TObject);
begin
  FreeAndNil(ToolEditor);
  //Board.Free;
  MultiBoard.Free;
  inc(HistPos);
//  Board:=readRAW(History[HistPos]);
  MultiBoard:=readMultiRAW(History[HistPos]);
  Board:=MultiBoard.Layers[ListLayers.Row];
  ReDraw(Board);
  SetPenTool;
end;

procedure TEditForm.actSelectAllExecute(Sender: TObject);
begin
  Board.ClearSelect(true);
  ReDraw(Board);
end;

procedure TEditForm.actDeleteUpdate(Sender: TObject);
begin
  actDelete.Enabled:=Board.IsChecked;
  actCut.Enabled:=Board.IsChecked;
  actCopy.Enabled:=Board.IsChecked;
end;

procedure TEditForm.actGoExecute(Sender: TObject);
var i:integer;
begin
  for i:=0 to High(MultiBoard.lObjects) do
    if Selected.Name = MultiBoard.lObjects[i].ScriptName then
    begin
      ListLayers.Row:=i+1;
      break;
    end;
end;

procedure TEditForm.mnHConnectClick(Sender: TObject);
var
  n,k,l:integer;
  x,y:integer;
  sel:tsUnit;
  ch:tsChain;

  function CheckFreeRight(ent:tsEntity; k:integer):boolean;
  var
    i:integer;
  begin
    Result:=true;
    for i:=0 to Length(Board.Chains)-1 do
      if (Board.Chains[i].Right.Obj=ent) and (Board.Chains[i].Right.InOutInd=k) then
      begin
        Result:=false;
        break;
      end;
  end;

  function ChainExists(lo:tsEntity; li:integer; ro:tsEntity; ri:integer):boolean;
  var i:integer;
  begin
    Result:=true;
    for i:=0 to Length(Board.Chains)-1 do
      with Board.Chains[i] do
        if (Left.Obj=lo) and (Left.InOutInd=li) and (Right.Obj=ro) and (Right.InOutInd=ri) then
        begin
          Result:=false;
          break;
        end;
  end;

begin
  for n:=0 to Length(Board.Entityes)-1 do
    for k:=0 to Length(Board.Entityes[n].Source.Output)-1 do
    begin
      // find closer bar with same input with line tracing
      with Board.Entityes[n] do
      begin
        SelInOut:=k+Length(Source.Input);
        X:=Rect.Right*GridX;
        Y:=Rect.Top*GridY+GridY+GridY*k+(GridY div 2);
      end;

      while (x<PaintBox.Width) do
      begin
        inc(x, GridX);
        sel:=Board.MousePress(Point(x,y));
        if sel is tsEntity then
        begin
          (sel as tsEntity).Selected:=false;
          l:=(sel as tsEntity).CheckIn(PaintBox.Canvas, Point(x,y));
          if l=-1 then break;
          if Board.Entityes[n].Source.Output[k].LinkType <> (sel as tsEntity).Source.Input[l].LinkType then
          begin
            (sel as tsEntity).SelInOut:=-1;
            break;
          end;
          if not CheckFreeRight(sel as tsEntity, l) then
          begin
            (sel as tsEntity).SelInOut:=-1;
            break;
          end;
          if not ChainExists(Board.Entityes[n], k, sel as tsEntity, l) then
          begin
            (sel as tsEntity).SelInOut:=-1;
            break;
          end;

          ch:=Board.AddChain(Board.Entityes[n], sel as tsEntity);
          ch.Selected:=true;
          (sel as tsEntity).SelInOut:=-1;
          break;
        end;
      end;
    end;
  ReDraw(Board);
  ProcessChange;
end;

// Меню Файл

procedure TEditForm.mnFileNewClick(Sender: TObject);
begin
  MainForm.mnFileNewClick(Sender);
end;

procedure TEditForm.mnFileOpenClick(Sender: TObject);
begin
  MainForm.ToolOpenClick(Sender);
end;

procedure TEditForm.mnFileSaveClick(Sender: TObject);
begin
  MainForm.ToolSaveClick(Sender);
end;

procedure TEditForm.mnFileSaveAsClick(Sender: TObject);
begin
  MainForm.SaveFile(True);
end;

procedure TEditForm.mnFileCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TEditForm.mnFileCloseallClick(Sender: TObject);
begin
  MainForm.CloseAll;
end;

procedure TEditForm.mnFileExitClick(Sender: TObject);
begin
  MainForm.mnFileExitClick(Sender);
end;

procedure TEditForm.mnFileExportClick(Sender: TObject);
begin
  if SaveDialog.Execute then
  begin
    //Board.Compile(SaveDialog.FileName);
    MultiBoard.Compile(SaveDialog.FileName);
  end;
end;

procedure TEditForm.mnFileRefreshClick(Sender: TObject);
begin
  MainForm.mnFileRefresh.Click;
end;

procedure TEditForm.mnFileCompileClick(Sender: TObject);
var
  logname,s,exe:string;
  First:tsObject;
  i,errors:integer;
begin
  if Length(SaveDialog.FileName)=0 then
    if not SaveDialog.Execute then exit;
  if MultiBoard.Count=1 then
    Board.Compile(SaveDialog.FileName)
  else
    MultiBoard.Compile(SaveDialog.FileName);

  s:=ExtractFileName(SaveDialog.FileName);
  s:=MidStr(s, 1, Length(s)-Pos('.',ReverseString(s)));

  SetCurrentDir(ExtractFilePath(SaveDialog.FileName));
  //WinExec(PAnsiChar('cmd /c '+Board.sCollection.DecodeCmd(SaveDialog.FileName, 'Compiler')+' >'+s+'.log'), SW_HIDE);
  exe:=Board.sCollection.DecodeCmd(SaveDialog.FileName, 'Compiler');
  ExecuteAndWait(exe);

  //Sleep(1000); // ждать появления ошибок

  if Board.sCollection.Env.Values['CheckLog']='true' then
  begin
    // Проверка ошибок компиляции
    logname:=SaveDialog.FileName;
    logname:=ExtractFilePath(logname)+s+'.log';
    if FileExists(logname) then
    begin
      LogForm.Memo.Lines.Text:=LoadFile(logname);
      //LogForm.Memo.Lines.LoadFromFile(logname);
      s:=Board.sCollection.Env.Values['ErrorCheck'];
      errors:=0;
      if s<>'' then
        for i:=0 to LogForm.Memo.Lines.Count-1 do
          if Pos(s, LogForm.Memo.Lines[i])>0 then
            inc(errors);

      if errors>0 then
      begin
        i:=0;
        while i<LogForm.Memo.Lines.Count do
          if Pos(s, LogForm.Memo.Lines[i])>0 then inc(i)
          else LogForm.Memo.Lines.Delete(i);
      end;

      LogForm.stErrors.Caption:=IntToStr(errors);
      LogForm.Show;
    end;
  end;

  MainForm.StatusBar.SimpleText:=RSCompiled;

  // Перемещение файла
  {First:=Board.BoardBase;
  if (First<>nil) and (First.DestPath<>'') and (First.DestPath<>ExtractFilePath(SaveDialog.FileName)) then
  begin
    exe:=s+'.'+Board.sCollection.Env.Values['BinExt'];
    if FileExists(ExtractFilePath(SaveDialog.FileName)+exe) then
      CopyFile(PAnsiChar(ExtractFilePath(SaveDialog.FileName)+exe),
               PAnsiChar(First.DestPath+exe), false);
  end;}
end;

procedure TEditForm.mnFileRunClick(Sender: TObject);
begin
  if Length(SaveDialog.FileName)=0 then
    if not SaveDialog.Execute then exit;

  WinExec(PAnsiChar(Board.sCollection.DecodeCmd(SaveDialog.FileName,'Run')), SW_NORMAL);
end;

procedure TEditForm.UpdateLastList;
var
  p,n:integer;
  mn:TMenuItem;
begin
  n:=mnFile.IndexOf(mnFlatLine4)+1;
  while n<mnFile.Count do
    mnFile.Delete(n);
  p:=MainForm.mnFile.IndexOf(MainForm.mnFlatLine3)+1;
  for n:=p to MainForm.mnFile.Count-1 do
  with MainForm.mnFile do
  begin
    mn:=TMenuItem.Create(Self);
    mn.AutoHotkeys:=maManual;
    mn.Caption:=Items[n].Caption;
    mn.OnClick:=mnFileHistClick;
    mnFile.Add(mn);
  end;
end;

procedure TEditForm.mnFileHistClick(Sender: TObject);
begin
  MainForm.OpenDatFile(Copy(StringReplace((Sender as TMenuItem).Caption,'&','',[rfReplaceAll]), 3, 1024));
end;

procedure TEditForm.FormResize(Sender: TObject);
begin
  if (WindowState<>MainForm.MDIWindowState) and (WindowState<>wsMinimized) then
  begin
    MainForm.MDIWindowState:=WindowState;
    MainForm.UpdateOptions(true);
  end;
end;

procedure TEditForm.mnColorLinksClick(Sender: TObject);
var n,k:integer;
begin
  //mnColorLinks.Checked:=not mnColorLinks.Checked;
    for n:=0 to Length(Board.Chains)-1 do
    begin
      Board.Chains[n].Color:=RandomColor;
      if n>0 then
      for k:=0 to n-1 do
        if (Board.Chains[k].Left.Obj=Board.Chains[n].Left.Obj)and(Board.Chains[k].Left.InOutInd=Board.Chains[n].Left.InOutInd)
        or (Board.Chains[k].Right.Obj=Board.Chains[n].Right.Obj)and(Board.Chains[k].Right.InOutInd=Board.Chains[n].Right.InOutInd) then
        begin
          Board.Chains[n].Color:=Board.Chains[k].Color;
          break;
        end;
    end;
  ReDraw(Board);
end;

procedure TEditForm.mnFileRefactoryClick(Sender: TObject);
begin
  MainForm.mnFileRefactory.Click;
end;

procedure TEditForm.mnFileNewObjectClick(Sender: TObject);
begin
  MainForm.mnFileNewObject.Click;
end;

procedure TEditForm.mnEditProtectClick(Sender: TObject);
var
  i,k:integer;
  found:boolean;
begin
  if mnEditProtect.Checked then
  begin
    for i:=0 to High(Board.Entityes) do
    if not Board.Entityes[i].IsProtected and (Board.Entityes[i].Source.oType<>totLayer) then
    begin
      Board.Entityes[i].IsProtected:=true;
      Board.SetProtect(Board.Entityes[i]);
    end;
  end
  else
  begin
    // поиск исходного кода
    for k:=0 to High(Board.Entityes) do
    if Board.Entityes[i].IsProtected then
    begin
      found:=false;
      for i:=0 to Board.sCollection.Count-1 do
        if Board.sCollection.Objects[i].ScriptName = Board.Entityes[k].Source.ScriptName then
        begin
          found:=true;
          break;
        end;
      if found then
        Board.Entityes[k].IsProtected:=false
    end;
  end;
end;

// Список объектов

procedure TEditForm.ToolsListClick(Sender: TObject);
begin
  if ToolsList.Cells[0,1]<>'' then
  begin
    Board.ClearSelect;
    Board.Entityes[ToolsList.Row-1].Selected:=true;
    ReDraw(Board);
  end;
end;

procedure TEditForm.UpdateToolsList;
var
  n:byte;
  Tool:tsEntity;
begin
  with ToolsList do
    begin
    if (Board=nil)or(Length(Board.Entityes)=0) then
      begin
      RowCount:=2;
      Cells[0, 1]:='';
      Cells[1, 1]:='';
      end
    else
      begin
      RowCount:=Length(Board.Entityes)+1;
      for n:=1 to Length(Board.Entityes) do
        begin
        Tool:=Board.Entityes[n-1];
        Cells[0, n]:=IntToStr(n);
        Cells[1, n]:=Tool.Name;
        end;
      end;
    end;
end;

procedure TEditForm.SpeedButtonUpClick(Sender: TObject);
var
  C:tsEntity;
begin
  if ToolsList.Cells[0,1]<>'' then
    if ToolsList.Row>1 then
    begin
      C:=Board.Entityes[ToolsList.Row-1];
      Board.Entityes[ToolsList.Row-1]:=Board.Entityes[ToolsList.Row-2];
      Board.Entityes[ToolsList.Row-2]:=C;
      UpdateToolsList;
      ToolsList.Row:=ToolsList.Row-1;

      Board.CalcPrioIndices;
      Board.Repaint(PaintBox.Canvas);
    end;
end;

procedure TEditForm.SpeedButtonDownClick(Sender: TObject);
var
  C:tsEntity;
begin
  if ToolsList.Cells[0,1]<>'' then
    if ToolsList.Row<ToolsList.RowCount-1 then
    begin
      C:=Board.Entityes[ToolsList.Row-1];
      Board.Entityes[ToolsList.Row-1]:=Board.Entityes[ToolsList.Row];
      Board.Entityes[ToolsList.Row]:=C;
      UpdateToolsList;
      ToolsList.Row:=ToolsList.Row+1;

      Board.CalcPrioIndices;
      Board.Repaint(PaintBox.Canvas);
    end;
end;

// Редактор свойств объектов

procedure TEditForm.ValueListEditorGetPickList(Sender: TObject;
  const KeyName: String; Values: TStrings);
var
  n:integer;
begin
  if Selected<>nil then
  with Selected do
  begin
    for n:=0 to Length(Source.Propertyes)-1 do
      if Source.Propertyes[n].Name=KeyName then
      begin
        if (Source.Propertyes[n].PropType=ptExtern) and (Source.Propertyes[n].ExtValues<>nil) then
          Values.AddStrings(Source.Propertyes[n].ExtValues);
      end;
  end;
end;

procedure TEditForm.ValueListEditorStringsChange(Sender: TObject);
const stop:boolean = false;
var
  n:integer;
  s:string;
begin
  if stop then exit;
  if LastSelected<>nil then
  begin
    with LastSelected do
    begin
      MainForm.StatusBar.SimpleText:=ValueListEditor.Cells[1,1];
      stop:=true;
      for n:=0 to Length(Source.Propertyes)-1 do
      begin
        s:=ValueListEditor.Values[Source.Propertyes[n].Name];

        if s<>'' then
          case Source.Propertyes[n].PropType of
          {ptNumber:s:=IntToStr(StrToInt(s));
          ptFloat:s:=FloatToStr(StrToFloat(s));
          ptSwitch:s:=LeftStr(s,1);}
          ptDate:if s[1]=' ' then s:='';
          ptExtern:
            begin
              if s='\' then
              with Source.Propertyes[n] do
                s:=ExtValues[Random(ExtValues.Count)];
              if Pos(' ',s)>0 then s:=LeftStr(s,Pos(' ',s)-1);
            end;
          end;

        ValueListEditor.Values[Source.Propertyes[n].Name]:=s;
        PropValues[n]:=s;
      end;
    end;

    stop:=false;
  end;
end;

procedure TEditForm.ValueListEditorEnter(Sender: TObject);
begin
  //actDelete.ShortCut:=0;
end;

procedure TEditForm.ValueListEditorExit(Sender: TObject);
begin
  //actDelete.ShortCut:=TextToShortCut('Del');
end;

procedure TEditForm.EditObjectChange(Sender: TObject);
begin
  Selected.Name:=EditObject.Text;
end;

procedure TEditForm.ValueListEditorSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
  if ARow<=Length(Selected.Source.Propertyes) then
    MainForm.StatusBar.SimpleText:=Selected.Source.Propertyes[ARow-1].LabelName;
end;

procedure TEditForm.ValueListEditorGetEditMask(Sender: TObject; ACol,
  ARow: Integer; var Value: String);
begin
  if Selected=nil then exit;
  with Selected do
  begin
    if Length(Source.Propertyes)>0 then
    case Source.Propertyes[ARow-1].PropType of
    {ptNumber:Value:='!99999';
    ptFloat:Value:='!99999\.999';}
    //ptSwitch:Value:='!9';
    ptDate:Value:='!0000/00/00 00:00;1;x';
    else Value:='';
    end;
  end;
end;

// Обработка изменений основных свойств объекта

procedure TEditForm.MemoCommentChange(Sender: TObject);
begin
  if not MemoComment.Enabled then exit;
  Selected.Comments.Clear;
  Selected.Comments.AddStrings(MemoComment.Lines);
end;

procedure TEditForm.chDebugClick(Sender: TObject);
begin
  Selected.Debug:=chDebug.Checked;
end;

procedure TEditForm.cbProtectedClick(Sender: TObject);
var
  i:integer;
  found:boolean;
begin
  if cbProtected.Checked then
  begin
    Selected.IsProtected:=true;
    Board.SetProtect(Selected);
  end
  else
  begin
    // поиск исходного кода
    found:=false;
    for i:=0 to Board.sCollection.Count-1 do
      if Board.sCollection.Objects[i].ScriptName = Selected.Source.ScriptName then
      begin
        found:=true;
        break;
      end;
    if found then
      Selected.IsProtected:=false
    else
    begin
      Application.MessageBox(PChar(RSSourcesNotFound), PChar(RSProtectionError), mb_OK);
      cbProtected.Checked:=true;
    end;
  end;
end;

procedure TEditForm.Splitter3Moved(Sender: TObject);
begin
  MainForm.UpdateOptions(true);
end;

procedure TEditForm.cbDefaultInChange(Sender: TObject);
var
  i,k:integer;
begin
  Selected.ParsInput:=cbDefaultIn.ItemIndex;

  if (cbDefaultIn.ItemIndex<Length(Selected.Source.Input)) and (Selected.ObjInput=nil) then
    for i:=0 to Length(Board.Chains)-1 do
      if (Board.Chains[i].Right.Obj = Selected) and (Board.Chains[i].Right.InOutInd = Selected.ParsInput) then
        begin
          Selected.ObjInput:=Board.Chains[i].Left.Obj;
          cbDefaultObj.ItemIndex:=cbDefaultObj.Items.IndexOf(Selected.ObjInput.Name);
          break;
        end;

  cbDefaultObj.Clear;
  cbDefaultObj.Items.Add(RSEmpty);
  if cbDefaultIn.ItemIndex=Length(Selected.Source.Input) then
  begin
    for i:=0 to Length(Board.Entityes)-1 do
    if (Board.Entityes[i]<>Selected)
      and not (Board.Entityes[i].Source.oType in [totLayer, totBlockIn, totBlockOut]) then
      begin
        cbDefaultObj.Items.Add(Board.Entityes[i].Name);
      end;
  end
  else if cbDefaultIn.ItemIndex=Length(Selected.Source.Input)+1 then
  begin
    for k:=0 to High(MultiBoard.Layers) do
    for i:=0 to High(MultiBoard.Layers[k].Entityes)-1 do
    if (MultiBoard.Layers[k].Entityes[i]<>Selected)
      and not (MultiBoard.Layers[k].Entityes[i].Source.oType in [totLayer, totBlockIn, totBlockOut]) then
      begin
        cbDefaultObj.Items.Add(MultiBoard.Layers[k].Entityes[i].Name);
      end;
  end
  else
  begin
    for i:=0 to Length(Board.Chains)-1 do
      if (Board.Chains[i].Right.Obj=Selected) and (Board.Chains[i].Right.InOutInd=Selected.ParsInput) then
      begin
        cbDefaultObj.Items.Add(Board.Chains[i].Left.Obj.Name);
      end;
  end;

  cbDefaultObj.Sorted:=true;
  if (Selected.ObjInput<>nil) and (cbDefaultObj.Items.IndexOf(Selected.ObjInput.Name)>=0) then
    cbDefaultObj.ItemIndex:=cbDefaultObj.Items.IndexOf(Selected.ObjInput.Name)
  else
    cbDefaultObj.ItemIndex:=0;//cbDefaultObj.Items.Count-1;
  if cbDefaultObj.ItemIndex>0 then cbDefaultObjChange(Sender);
  ReDraw(Board);
end;

procedure TEditForm.cbDefaultObjChange(Sender: TObject);
var
  i,k:integer;
begin
  if cbDefaultObj.ItemIndex=0 then Selected.ObjInput:=nil
  else
  if Selected.ParsInput<=Length(Selected.Source.Input) then
  begin
    for i:=0 to Length(Board.Entityes)-1 do
      if Board.Entityes[i].Name = cbDefaultObj.Text then
      begin
        Selected.ObjInput:=Board.Entityes[i];
        break;
      end
  end
  else
  begin
    for k:=0 to High(MultiBoard.Layers) do
      for i:=0 to High(MultiBoard.Layers[k].Entityes)-1 do
        if MultiBoard.Layers[k].Entityes[i].Name = cbDefaultObj.Text then
        begin
          Selected.ObjInput:=MultiBoard.Layers[k].Entityes[i];
          break;
        end
  end;
end;

// список слоев

procedure TEditForm.UpdateLayersList;
var n:integer;
begin
  if ListLayers.RowCount<MultiBoard.Count then
    ListLayers.RowCount:=MultiBoard.Count;
  for n:=0 to MultiBoard.Count-1 do
  begin
    ListLayers.Cells[0,n]:=IntToStr(n+1);
    ListLayers.Cells[1,n]:=MultiBoard[n];
  end;
  if ListLayers.RowCount>MultiBoard.Count then
    ListLayers.RowCount:=MultiBoard.Count;
end;

procedure TEditForm.ListLayersDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
begin
  if ACol>0 then
  with ListLayers.Canvas do
  begin
    if ARow = ListLayers.Row then
      Brush.Color:=clYellow
    else
      Brush.Color:=$DFDFDF;
    FillRect(Rect);
    if ARow=0 then
    begin
      Font.Style:=[fsBold];
    end
    else
    begin
      if Length(MultiBoard.Layers[ARow].Entityes)=0 then Font.Style:=[fsItalic];
    end;
    Font.Color:=0;
    TextOut(Rect.Left+2, Rect.Top+2, ListLayers.Cells[ACol, ARow]);
  end;
end;

procedure TEditForm.ListLayersSetEditText(Sender: TObject; ACol,
  ARow: Integer; const Value: String);
begin
  MultiBoard[ListLayers.Row]:=Value;
end;

procedure TEditForm.ListLayersClick(Sender: TObject);
var
  new_board:tsBoard;
begin
  new_board:=MultiBoard.Layers[ListLayers.Row];
  if new_board<>Board then
  begin
    Board:=new_board;
    ReDraw(Board);
    SetPenTool;
  end;
end;

procedure TEditForm.SpeedButtonAddClick(Sender: TObject);
var
  l:integer;
begin
  l:=MultiBoard.Count;
  MultiBoard.Add(RSNew);
  SetLength(MultiBoard.Layers, l+1);
  MultiBoard.Layers[l]:=tsBoard.Create;
  MultiBoard.Layers[l].sCollection:=MultiBoard.Layers[0].sCollection;
  MultiBoard.Layers[l].Host:=MultiBoard;
  UpdateLayersList;
  ProcessChange;
end;

procedure TEditForm.SpeedButtonDelClick(Sender: TObject);
var
  n:integer;
begin
  if ListLayers.Row<1 then exit;

  ConfirmForm.Label1.Caption:=Format(RSRemoveLayer, [ListLayers.Cells[0,ListLayers.Row]]);
  if ConfirmForm.ShowModal<>mrYes then exit;

  MultiBoard.Layers[ListLayers.Row].Free;
  for n:=ListLayers.Row to MultiBoard.Count-2 do
    MultiBoard.Layers[n] := MultiBoard.Layers[n+1];
  MultiBoard.Layers[MultiBoard.Count-1]:=nil;

  SetLength(MultiBoard.Layers, MultiBoard.Count);
  MultiBoard.Delete(ListLayers.Row);

  UpdateLayersList;

  if ListLayers.Row<MultiBoard.Count then Board:=MultiBoard.Layers[ListLayers.Row]
  else Board:=MultiBoard.Layers[MultiBoard.Count-1];
  Redraw(Board);
  SetPenTool;
  ProcessChange;
end;

procedure TEditForm.SpeedButtonLUpClick(Sender: TObject);
var
  a,b:tsBoard;
begin
  if (ListLayers.Row<1) or (ListLayers.RowCount=1) then exit;
  a:=MultiBoard.Layers[ListLayers.Row];
  b:=MultiBoard.Layers[ListLayers.Row-1];
  MultiBoard.Layers[ListLayers.Row-1]:=a;
  MultiBoard.Layers[ListLayers.Row]:=b;
  MultiBoard.Exchange(ListLayers.Row, ListLayers.Row-1);
  ListLayers.Row:=ListLayers.Row-1;
  UpdateLayersList;
end;

procedure TEditForm.SpeedButtonLDownClick(Sender: TObject);
var
  a,b:tsBoard;
begin
  if (ListLayers.Row=ListLayers.RowCount-1) or (ListLayers.RowCount=1) then exit;
  a:=MultiBoard.Layers[ListLayers.Row];
  b:=MultiBoard.Layers[ListLayers.Row+1];
  MultiBoard.Layers[ListLayers.Row+1]:=a;
  MultiBoard.Layers[ListLayers.Row]:=b;
  MultiBoard.Exchange(ListLayers.Row, ListLayers.Row+1);
  ListLayers.Row:=ListLayers.Row+1;
  UpdateLayersList;
end;

procedure TEditForm.ListLayersDblClick(Sender: TObject);
begin
  if ListLayers.Row<1 then exit;
  with Application.MainForm as TMainForm do
  begin
    ToolObject.Caption:=ListLayers.Cells[0,ListLayers.Row];
    ToolObject.Tag:=-ListLayers.Row;
  end;
end;

end.
