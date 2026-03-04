unit Main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, MDIEditForm, ToolWin, ComCtrls, ImgList, ExtCtrls, StdCtrls,
  Grids, Buttons, Spin, AboutForm, UseFull, Clipbrd, Scripts,
  Globals, Editors, ValEdit, OleCtrls, SHDocVw, Registry, AppEvnts,
  ColorGrd, Math, Refactory, NewObjectFrm;

type
  TMainForm = class(TForm)
    MainMenu1: TMainMenu;
    ImageList1: TImageList;
    mnFile: TMenuItem;
    mnFileNew: TMenuItem;
    ControlBar1: TControlBar;
    StatusBar: TStatusBar;
    ToolBar2: TToolBar;
    ToolNew: TToolButton;
    ToolOpen: TToolButton;
    ToolSave: TToolButton;
    ImageList2: TImageList;
    ToolBar1: TToolBar;
    mnWindow: TMenuItem;
    mnWindowTile: TMenuItem;
    mnWindowCascade: TMenuItem;
    mnWindowArrangeicons: TMenuItem;
    mnHelp: TMenuItem;
    mnHelpAbout: TMenuItem;
    SaveDialog: TSaveDialog;
    OpenDialog: TOpenDialog;
    mnView: TMenuItem;
    mnViewTools: TMenuItem;
    ToolBar3: TToolBar;
    ImageList3: TImageList;
    N1: TMenuItem;
    mnViewShowall: TMenuItem;
    mnViewPropertyeditor: TMenuItem;
    ToolArrow: TToolButton;
    ToolLink: TToolButton;
    ToolCompile: TToolButton;
    ToolObject: TToolButton;
    mnObject: TPopupMenu;
    mnFlatLine2: TMenuItem;
    mnFileRefresh: TMenuItem;
    mnViewParamEditor: TMenuItem;
    mnPopupNew: TPopupMenu;
    mnOptions: TMenuItem;
    mnOptionsSnap: TMenuItem;
    mnOptionsHardChains: TMenuItem;
    mnOptionsSub: TMenuItem;
    ApplicationEvents1: TApplicationEvents;
    mnOptionsTags: TMenuItem;
    mnOptionsPrints: TMenuItem;
    mnOptionsDebug: TMenuItem;
    mnFlatLine3: TMenuItem;
    mnFileHistory: TMenuItem;
    mnViewResetScale: TMenuItem;
    mnFileRefactory: TMenuItem;
    mnFileNewObject: TMenuItem;
    mnViewShowNames: TMenuItem;
    mnOptionsCollect: TMenuItem;
    TabWindows: TTabControl;
    mnLanguage: TMenuItem;
    mnRussian: TMenuItem;
    mnEnglish: TMenuItem;
    procedure mnFileExitClick(Sender: TObject);
    procedure mnWindowTileClick(Sender: TObject);
    procedure mnWindowCascadeClick(Sender: TObject);
    procedure mnWindowArrangeiconsClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure mnHelpAboutClick(Sender: TObject);
    procedure ToolSaveClick(Sender: TObject);
    procedure ToolOpenClick(Sender: TObject);
    procedure ToolCompileClick(Sender: TObject);
    procedure mnViewShowallClick(Sender: TObject);
    procedure OnEnterEdit(Sender: TObject);
    procedure ToolArrowClick(Sender: TObject);
    procedure ToolLinkClick(Sender: TObject);
    procedure ToolObjectClick(Sender: TObject);
    procedure mnFileRefreshClick(Sender: TObject);
    procedure mnFileNewClick(Sender: TObject);
    procedure mnOptionsSnapClick(Sender: TObject);
    procedure mnOptionsHardChainsClick(Sender: TObject);
    procedure ApplicationEvents1ShortCut(var Msg: TWMKey;
      var Handled: Boolean);
    procedure mnOptionsTagsClick(Sender: TObject);
    procedure mnOptionsPrintsClick(Sender: TObject);
    procedure mnOptionsDebugClick(Sender: TObject);
    procedure mnFileHistoryClick(Sender: TObject);
    procedure mnViewResetScaleClick(Sender: TObject);
    procedure mnFileRefactoryClick(Sender: TObject);
    procedure mnFileNewObjectClick(Sender: TObject);
    procedure mnViewShowNamesClick(Sender: TObject);
    procedure SwitchPanelClick(Sender: TObject);
    procedure TabWindowsChange(Sender: TObject);
    procedure mnRussianClick(Sender: TObject);
    procedure mnEnglishClick(Sender: TObject);
  public
    sCollection:tsCollection;
    CurPenTool:tsDrawTool;
    CurToolTag:integer;

    MDIWindowState: TWindowState;

    //файлы...
    procedure FileCreate(Sender: TObject);
    procedure SaveFile(prompt:boolean);
    procedure OpenDatFile(name:string);
    procedure CloseAll;
    //Обновить список последних
    procedure UpdateLastList(new: string='');
    //Деактивация кнопок
    procedure ButtonsUp(Sender: TObject);
    //опции
    procedure UpdateOptions(save:boolean=false);
  end;


// Дополнительный класс для использования буфера обмена
  TClipboard2 = class(TClipboard)
  private
    BoardFormat:cardinal;
  public
    constructor Create;
    procedure SetBoard(ts:tsBoard);     // В буфер
    function GetBoard:tsBoard; // Из буфера
    function IsBoard:boolean;               // Проверить наличие в буфере
  end;

Const LastListMAX = 30;

var
  MainForm: TMainForm;
  Clipboard2: TClipboard2;

implementation

uses ComObj, StrUtils;

{$R *.DFM}

resourcestring
  RSFleNotFound = 'Извините, файл не существует';
  RSToolsUpdated = 'Инструменты обновлены';

//Расширение буфера

constructor TClipboard2.Create;
begin
  inherited;
  BoardFormat:=RegisterClipboardFormat('Codegen board');
end;

procedure TClipboard2.SetBoard;
var
  M:TMemoryStream;
begin
  M:=TMemoryStream.Create;
  ts.writeRAW(M, true);
  SetBuffer(BoardFormat, M.Memory^, M.Size);
end;

function TClipboard2.GetBoard:tsBoard;
// взято из Clipbrd.pas
var
  Data: THandle;
  M:TStringStream;
begin
  Result:=nil;
  Open;
  Data := GetClipboardData(BoardFormat);
  try
    if Data <> 0 then
    begin
      M:=TStringStream.Create(String(PAnsiChar(GlobalLock(Data))));
      Result:=readRAW(M);
      M.Free;
    end;
  finally
    if Data <> 0 then
      GlobalUnlock(Data);
    Close;
  end;
end;

function TClipboard2.IsBoard:boolean;
begin
  Result:=HasFormat(BoardFormat);
end;

// Системные подпрограммы

//Меню Окно

procedure TMainForm.mnWindowTileClick(Sender: TObject);
begin
  Tile;
end;

procedure TMainForm.mnWindowCascadeClick(Sender: TObject);
begin
  Cascade;
end;

procedure TMainForm.mnWindowArrangeiconsClick(Sender: TObject);
begin
  ArrangeIcons;
end;

// Основные события
procedure TMainForm.FormCreate(Sender: TObject);
var
  SchMenu:array of TMenuItem;
  n:integer;
begin
  Randomize;

  ForceCurrentDirectory:=TRUE;

  //Иниц буффера обмена
  Clipboard2:=TClipboard2.Create;
  SetClipboard(Clipboard2);

  //Иниц глоб переменных
  ScriptPath:=ExtractFilePath(ParamStr(0))+'Schema\';

  // меню схем
  sSchemes:=tsSchemes.Create;
  SetLength(SchMenu, sSchemes.Count);
  for n:=0 to sSchemes.Count-1 do
  begin
    SchMenu[n]:=TMenuItem.Create(Self);
    SchMenu[n].Caption:=sSchemes[n];
    SchMenu[n].OnClick:=FileCreate;
    SchMenu[n].Tag:=n;
  end;
  mnPopupNew.Items.Add(SchMenu);

  // путь к файлам по умолчанию
  OpenDialog.FileName:=ExtractFilePath(ParamStr(0))+'CodeGrams\*.gen';

  // список последних файлов
  UpdateLastList;

  UpdateOptions;
end;

procedure TMainForm.mnFileExitClick(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.CloseAll;
var
  n:byte;
begin
  for n:=0 to MDIChildCount-2 do
    if MDIChildren[n].CloseQuery then
      MDIChildren[n].Close
    else Break;
end;

procedure TMainForm.UpdateOptions(save: boolean);
var
  r:TRegistry;

  function defval(s:string; def:boolean):boolean;
  begin
    if r.ValueExists(s) then Result:=r.ReadBool(s)
    else Result:=def;
  end;

  function defint(s:string; def:integer; max_val:integer=0):integer;
  begin
    if r.ValueExists(s) then Result:=Max(r.ReadInteger(s), max_val)
    else Result:=def;
  end;

begin
  r:=TRegistry.Create;
  r.RootKey:=HKEY_CURRENT_USER;
  r.OpenKey('Software\CodeGen', True);
  if save then
  begin
    r.WriteBool('Snap', mnOptionsSnap.Checked);
    r.WriteBool('HardChains', mnOptionsHardChains.Checked);
    r.WriteBool('DebugTags', mnOptionsTags.Checked);
    r.WriteBool('DebugPrints', mnOptionsPrints.Checked);
    r.WriteBool('DebugFull', mnOptionsDebug.Checked);
    r.WriteBool('English', LangEnglish);
    //r.WriteInteger('WidthProps', GroupPars.Width);
    //r.WriteInteger('HeightExtra', GroupMain.Height);
    r.WriteInteger('MainWindowState', Ord(WindowState));
    r.WriteInteger('MDIWindowState', Ord(MDIWindowState));
  end
  else
  begin
    mnOptionsSnap.Checked:=defval('Snap', true);
    GridSnap:=mnOptionsSnap.Checked;
    mnOptionsHardChains.Checked:=defval('HardChains', true);
    HardChains:=mnOptionsHardChains.Checked;
    mnOptionsTags.Checked:=defval('DebugTags', false);
    CompileWriteTags:=mnOptionsTags.Checked;
    mnOptionsPrints.Checked:=defval('DebugPrints', false);
    CompileWritePrints:=mnOptionsPrints.Checked;
    mnOptionsDebug.Checked:=defval('DebugFull', false);
    CompileFullDebug:=mnOptionsDebug.Checked;

    LangEnglish:=defval('English', false);
    mnRussian.Checked:=not LangEnglish;
    mnEnglish.Checked:=LangEnglish;

    //GroupPars.Width:=defint('WidthProps', 250, 50);
    //GroupMain.Height:=defint('HeightExtra', 130, 50);
    WindowState:=TWindowState(defint('MainWindowState',0));
    MDIWindowState:=TWindowState(defint('MDIWindowState',0));
  end;
  r.CloseKey;
  r.Free;
end;

// Меню Вид

procedure TMainForm.mnViewShowallClick(Sender: TObject);
begin
  ToolBar1.Show;
  ToolBar2.Show;
  ToolBar3.Show;
end;

// Редактор свойств объектов

procedure TMainForm.OnEnterEdit(Sender: TObject);
begin
  //освобождение клавиши Del для редактирования текста
  TEditForm(ActiveMDIChild).mnEditDelete.ShortCut:=0;
end;

// Меню Справка

procedure TMainForm.mnHelpAboutClick(Sender: TObject);
begin
  AboutBox.ShowModal;
end;

// Работа с файлами

procedure TMainForm.FileCreate(Sender: TObject);
var Form:TEditForm;
begin
  sCollection:=sSchemes.Scheme[(Sender as TMenuItem).Tag];
  Form:=TEditForm.Create(Owner);
  Form.ProcessChange;
  Form.TabIndex:=TabWindows.Tabs.Add('<new>');
  TabWindows.TabIndex:=Form.TabIndex;
end;

procedure TMainForm.mnFileNewClick(Sender: TObject);
var cur:TPoint;
begin
  cur:=Mouse.CursorPos;
  mnPopupNew.Popup(cur.X,cur.Y);
end;

procedure TMainForm.SaveFile(prompt:boolean);
var
  Flag:boolean;
  Form: TEditForm;

  F:TFileStream;
begin
  Form:=TEditForm(ActiveMDIChild);

  Flag:=not Prompt and not Form.NewFile;
  if not Flag then
    begin
    Flag:=SaveDialog.Execute;
    if Flag then
      begin
      Form.FilePath:=SaveDialog.FileName;
      Form.Caption:=ExtractFileName(SaveDialog.FileName);
      Form.NewFile:=FALSE;

      UpdateLastList(Form.FilePath);
      end;
    end;

  // Сохранять файл, только если Flag = TRUE

  if Flag then
  try
    F:=TFileStream.Create(Form.FilePath, fmCreate);
    if Form.MultiBoard.Count=1 then
    begin
      if Form.Board.Version<Form.MultiBoard.Version then Form.Board.Version:=Form.MultiBoard.Version;
      Form.Board.writeRAW(F,false,true,mnOptionsCollect.Checked)
    end
    else
    begin
      if Form.Board.Version>Form.MultiBoard.Version then Form.MultiBoard.Version:=Form.Board.Version;
      Form.MultiBoard.writeRAW(F,mnOptionsCollect.Checked);
    end;
    Form.Modified:=FALSE;
  finally
    F.Free;
  end;

  TabWindows.Tabs[Form.TabIndex]:=NoExt(ExtractFileName(Form.FilePath));
end;

procedure TMainForm.ToolSaveClick(Sender: TObject);
begin
  SaveFile(FALSE);
end;

procedure TMainForm.OpenDatFile(Name:string);
var
  Form:TEditForm;
  MultiBoard:tsMultiBoard;
  Board:tsBoard;
  F:TFileStream;
  i:integer;
begin
  F:=TFileStream.Create(Name, fmOpenRead+fmShareDenyNone);
  try
    MultiBoard:=readMultiRAW(F);
    if MultiBoard=nil then exit;
    //Board:=readRAW(F);
    Board:=MultiBoard.Layers[0];
    sCollection:=Board.sCollection;
    Form:=TEditForm.Create(Owner);

    Form.MultiBoard:=MultiBoard;
    Form.Board:=Board;
    Form.CreateMenu;

    Form.UpdateLayersList;

    Form.ProcessChange;
    Form.Modified:=false;
    Form.UpdateSize;

    Form.ReDraw(Form.Board);
    Form.UpdateToolsList;

    Form.FilePath:=Name;
    Form.Caption:=ExtractFileName(Name);
    Form.NewFile:=FALSE;
    Form.Modified:=false;

    Form.TabIndex:=TabWindows.Tabs.Add(NoExt(ExtractFileName(Name)));
    TabWindows.TabIndex:=Form.TabIndex;

    ToolArrow.Down:=true;
    ToolArrowClick(ToolArrow);

    UpdateLastList(Name);

  finally
    F.Free;
  end;

end;

procedure TMainForm.ToolOpenClick(Sender: TObject);
begin
  if not OpenDialog.Execute then Exit;
  if not FileExists(OpenDialog.FileName) then
    Warn(RSFleNotFound)
  else
    OpenDatFile(OpenDialog.FileName);
end;

procedure TMainForm.UpdateLastList(new: string);
const ShortCuts:pchar = '123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
var
  r:TRegistry;
  n:integer;
  st:TStringList;
  mn:TMenuItem;
begin
  r:=TRegistry.Create;
  r.RootKey:=HKEY_CURRENT_USER;
  r.OpenKey('Software\CodeGen\History', true);

  st:=TStringList.Create;
  if new='' then // read
  begin
    n:=mnFile.IndexOf(mnFlatLine3)+1;
    while n<mnFile.Count do
      mnFile.Delete(n);
    r.GetValueNames(st);
    for n:=0 to st.Count-1 do
    begin
      mn:=TMenuItem.Create(Self);
      //mn.AutoHotkeys:=maManual;
      mn.Caption:='&'+ShortCuts[n]+' '+r.ReadString(st[n]);
      mn.GroupIndex:=1;
      mn.OnClick:=mnFileHistoryClick;
      mnFile.Add(mn);
    end;
  end
  else // write
  begin
    n:=mnFile.IndexOf(mnFlatLine3)+1;
    while n<mnFile.Count do
    begin
      st.Add(Copy(StringReplace(mnFile.Items[n].Caption,'&','',[rfReplaceAll]), 3, 1024));
      mnFile.Delete(n);
    end;
    if st.IndexOf(new)>=0 then st.Delete(st.IndexOf(new));
    st.Insert(0, new);
    if st.Count>LastListMAX then st.Delete(LastListMax);
    for n:=0 to st.Count-1 do
      r.WriteString(Format('%.2d', [n]), st[n]);
    UpdateLastList();
    if ActiveMDIChild<>nil then
      (ActiveMDIChild as TEditForm).UpdateLastList;
  end;
  st.Free;

  r.CloseKey;
  r.Free;
end;

procedure TMainForm.mnFileHistoryClick(Sender: TObject);
begin
  OpenDatFile(Copy(StringReplace((Sender as TMenuItem).Caption, '&', '', [rfReplaceAll]), 3, 1024));
end;

// Обработка инструментов в тулбаре

procedure TMainForm.ToolCompileClick(Sender: TObject);
begin
  TEditForm(ActiveMDIChild).mnFileCompileClick(Sender);
end;

procedure TMainForm.ButtonsUp(Sender: TObject);
var i:integer;
begin
  for i:=0 to ToolBar1.ButtonCount-1 do
  if ToolBar1.Buttons[i]<>Sender then
    ToolBar1.Buttons[i].Down:=false;
end;

procedure TMainForm.ToolArrowClick(Sender: TObject);
begin
  ButtonsUp(Sender);
  ToolArrow.Down:=true;
  CurPenTool:=dtArrow;
  TEditForm(ActiveMDIChild).SetPenTool;
end;

procedure TMainForm.ToolLinkClick(Sender: TObject);
begin
  ButtonsUp(Sender);
  ToolLink.Down:=true;
  CurPenTool:=dtLink;
  TEditForm(ActiveMDIChild).SetPenTool;
end;

procedure TMainForm.ToolObjectClick(Sender: TObject);
begin
  ButtonsUp(Sender);

  CurPenTool:=dtEntity;
  CurToolTag:=(Sender as TComponent).Tag;
  TEditForm(ActiveMDIChild).SetPenTool;
  
  ToolObject.Down:=true;
  if Sender is TMenuItem then
  begin
    ToolObject.Caption:=(Sender as TMenuItem).Caption;
    ToolObject.Tag:=(Sender as TMenuItem).Tag;
  end;
end;

procedure TMainForm.mnFileRefreshClick(Sender: TObject);
var
  i:integer;
begin
  // сохранение и очистка всех досок
  for i:=0 to MDIChildCount-1 do
  with MDIChildren[i] as TEditForm do
  begin
    History[HistPos].Clear;
    //Board.writeRAW(History[HistPos]);
    MultiBoard.writeRAW(History[HistPos], false);

    FreeAndNil(ToolEditor);
    //Board.Free;
    MultiBoard.Free;
  end;

  // перезагрузка всех инструментов
  sSchemes.Free;
  sSchemes:=tsSchemes.Create;

  // восстановление досок
  for i:=0 to MDIChildCount-1 do
  with MDIChildren[i] as TEditForm do
  begin
    //Board:=readRAW(History[HistPos]);
    MultiBoard:=readMultiRAW(History[HistPos]);
    MultiBoard.UpdateLObjects;
    Board:=MultiBoard.Layers[ListLayers.Row];
    ReDraw(Board);
    SetPenTool;
    ProcessSelect(nil);
  end;

  if ActiveMDIChild<>nil then
    (ActiveMDIChild as TEditForm).CreateMenu;

  {for i:=0 to sSchemes.Count-1 do
  begin
    sCollection:=sSchemes.Scheme[i];
    for n:=0 to sCollection.Count-1 do
    with sCollection.Objects[n] do
    begin
      SetLength(Propertyes,0);
      SetLength(Input,0);
      SetLength(Output,0);
      SetLength(InputPars,0);
      SetLength(OutputPars,0);
      if sCode<>nil then sCode.Clear;
      if sTemplate<>nil then sTemplate.Clear;
      if sHelp<>nil then sHelp.Clear;
      SetLength(Maps, 0);
      LoadScript(ScriptName);
    end;
    for n:=0 to Length(sCollection.Types)-1 do
      sCollection.Types[n].LoadScript(sCollection.Types[n].ScriptName);
    sCollection.ConnectTypes;
  end;}
  StatusBar.SimpleText:=RSToolsUpdated;
end;

// Меню опции

procedure TMainForm.mnOptionsSnapClick(Sender: TObject);
begin
  GridSnap:=mnOptionsSnap.Checked;
  UpdateOptions(true);
end;

procedure TMainForm.mnOptionsHardChainsClick(Sender: TObject);
var
  n:integer;
begin
  HardChains:=mnOptionsHardChains.Checked;
  for n:=0 to MDIChildCount-1 do
  with MDIChildren[n] as TEditForm do
  begin
    Board.ConnectChains;
    ReDraw(Board);
  end;
  UpdateOptions(true);
end;

procedure TMainForm.mnOptionsTagsClick(Sender: TObject);
begin
  CompileWriteTags:=mnOptionsTags.Checked;
  UpdateOptions(true);
end;

procedure TMainForm.mnOptionsPrintsClick(Sender: TObject);
begin
  CompileWritePrints:=mnOptionsPrints.Checked;
  UpdateOptions(true);
end;

procedure TMainForm.mnOptionsDebugClick(Sender: TObject);
begin
  CompileFullDebug:=mnOptionsDebug.Checked;
  UpdateOptions(true);
end;

// Перехват горячих клавиш
procedure TMainForm.ApplicationEvents1ShortCut(var Msg: TWMKey;
  var Handled: Boolean);
begin
  if GetKeyState(VK_CONTROL) and $8000<>0 then
  case Lo(Msg.CharCode) of
  ord('1'):begin ToolArrowClick(ToolArrow); Handled:=true; end;
  ord('2'):begin ToolLinkClick(ToolLink); Handled:=true; end;
  ord('3'):begin ToolObjectClick(ToolObject); Handled:=true; end;
  end;
end;

procedure TMainForm.mnViewResetScaleClick(Sender: TObject);
var Form:TEditForm;
begin
  GridX:=16;
  GridY:=16;
  if ActiveMDIChild = nil then exit;

  Form:=ActiveMDIChild as TEditForm;
  Form.Board.ConnectChains;
  Form.ReDraw(Form.Board);
end;

procedure TMainForm.mnFileRefactoryClick(Sender: TObject);
begin
  RefactoryForm.Show;
end;

procedure TMainForm.mnFileNewObjectClick(Sender: TObject);
begin
  NewObjectForm.Show;
end;

procedure TMainForm.mnViewShowNamesClick(Sender: TObject);
var n:integer;
begin
  ShowObjectsNames:=not ShowObjectsNames;
  for n:=0 to MDIChildCount-1 do
    (MDIChildren[n] as TEditForm).Redraw((MDIChildren[n] as TEditForm).Board);
end;

procedure TMainForm.SwitchPanelClick(Sender: TObject);
var n:integer;
begin
  for n:=0 to MDIChildCount-1 do
    (MDIChildren[n] as TEditForm).FormActivate(nil);
end;

procedure TMainForm.TabWindowsChange(Sender: TObject);
var i:integer;
begin
  for i:=0 to MDIChildCount-1 do
    if (MDIChildren[i] as TEditForm).TabIndex=TabWindows.TabIndex then
    begin
      MDIChildren[i].BringToFront;
      break;
    end;
end;

procedure TMainForm.mnRussianClick(Sender: TObject);
begin
  LangEnglish:=false;
  mnRussian.Checked:=true;
  mnEnglish.Checked:=false;
  UpdateOptions(true);
end;

procedure TMainForm.mnEnglishClick(Sender: TObject);
begin
  LangEnglish:=true;
  mnRussian.Checked:=false;
  mnEnglish.Checked:=true;
  UpdateOptions(true);
end;

end.
