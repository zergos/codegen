unit MAIN;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, Menus,
  StdCtrls, Dialogs, Buttons, Messages, ExtCtrls, ComCtrls, StdActns,
  ActnList, ToolWin, ImgList, PerlRegEx, Colorer, Math;

type
  TMainForm = class(TForm)
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    FileNewItem: TMenuItem;
    FileOpenItem: TMenuItem;
    FileCloseItem: TMenuItem;
    Window1: TMenuItem;
    Help1: TMenuItem;
    N1: TMenuItem;
    FileExitItem: TMenuItem;
    WindowCascadeItem: TMenuItem;
    WindowTileItem: TMenuItem;
    WindowArrangeItem: TMenuItem;
    HelpAboutItem: TMenuItem;
    OpenDialog: TOpenDialog;
    FileSaveItem: TMenuItem;
    FileSaveAsItem: TMenuItem;
    Edit1: TMenuItem;
    CutItem: TMenuItem;
    CopyItem: TMenuItem;
    PasteItem: TMenuItem;
    WindowMinimizeItem: TMenuItem;
    StatusBar: TStatusBar;
    ActionList1: TActionList;
    EditCut1: TEditCut;
    EditCopy1: TEditCopy;
    EditPaste1: TEditPaste;
    FileNew1: TAction;
    FileSave1: TAction;
    FileExit1: TAction;
    FileOpen1: TAction;
    FileSaveAs1: TAction;
    WindowCascade1: TWindowCascade;
    WindowTileHorizontal1: TWindowTileHorizontal;
    WindowArrangeAll1: TWindowArrange;
    WindowMinimizeAll1: TWindowMinimizeAll;
    HelpAbout1: TAction;
    FileClose1: TWindowClose;
    WindowTileVertical1: TWindowTileVertical;
    WindowTileItem2: TMenuItem;
    ToolBar2: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton9: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
    ImageList1: TImageList;
    Timer: TTimer;
    TimerPipe: TTimer;
    N2: TMenuItem;
    mnEditFind: TMenuItem;
    mnEditFindNext: TMenuItem;
    SearchFind1: TSearchFind;
    SearchReplace1: TSearchReplace;
    FileRefresh: TAction;
    TabWindows: TTabControl;
    procedure FileNew1Execute(Sender: TObject);
    procedure FileOpen1Execute(Sender: TObject);
    procedure HelpAbout1Execute(Sender: TObject);
    procedure FileExit1Execute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FileSave1Update(Sender: TObject);
    procedure FileSave1Execute(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure TimerPipeTimer(Sender: TObject);
    procedure SearchReplace1ReplaceDialogShow(Sender: TObject);
    procedure SearchReplace1ReplaceDialogClose(Sender: TObject);
    procedure FileSaveAs1Update(Sender: TObject);
    procedure FileRefreshExecute(Sender: TObject);
    procedure TabWindowsChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    ColorFiles:TColorFiles;
    SaveProc:TWndMethod;

    procedure CreateMDIChild(const Name: string);
    procedure DummyProc(var Message:TMessage);
  end;

const mypipename = '\\.\pipe\CodeColorer';

var
  MainForm: TMainForm;
  mypipe:THandle;
  buffer:array [0..1000] of char;

implementation

{$R *.dfm}

uses CHILDWIN, about, StrUtils;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  ColorFiles:=TColorFiles.Create;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  ColorFiles.Free;
end;

procedure TMainForm.CreateMDIChild(const Name: string);
var
  Child: TMDIChild;
begin
  { create a new MDI child window }
  Child := TMDIChild.Create(Application);
  Child.Caption := Name;
  if FileExists(Name) then Child.Editor.Lines.LoadFromFile(Name);

  Child.FileName:=Name;
  Child.Modified:=false;
  Child.ColorConv:=ColorFiles.ColorBlock(Name);
  //Child.WindowState:=wsMaximized;
  with Child do
  begin
    if ColorConv<>nil then
    begin
      ColorConv.Editor:=Editor;
      //ColorConv.Colorise;
      //Editor.OnChange:=EditorChange;
      //Editor.OnSelectionChange:=EditorSelectionChange;
      Timer.Enabled:=true;
    end;
  end;

  Child.TabIndex:=TabWindows.Tabs.Add(ExtractFileName(Name));
  TabWindows.TabIndex:=Child.TabIndex;
end;

procedure TMainForm.FileNew1Execute(Sender: TObject);
begin
  CreateMDIChild('NONAME' + IntToStr(MDIChildCount + 1));
end;

procedure TMainForm.FileOpen1Execute(Sender: TObject);
begin
  if OpenDialog.Execute then
    CreateMDIChild(OpenDialog.FileName);
end;

procedure TMainForm.HelpAbout1Execute(Sender: TObject);
begin
  AboutBox.ShowModal;
end;

procedure TMainForm.FileExit1Execute(Sender: TObject);
//var n:integer;
begin
  {for n:=0 to MDIChildCount-1 do
    if not MDIChildren[n].CloseQuery then exit;}
  Close;
end;

procedure TMainForm.FileSave1Update(Sender: TObject);
var Child:TMDIChild;
begin
  Child:=TMDIChild(ActiveMDIChild);
  if Child=nil then exit;
  FileSave1.Enabled:=Child.Modified;
end;

procedure TMainForm.FileSave1Execute(Sender: TObject);
var Child:TMDIChild;
begin
  Child:=TMDIChild(ActiveMDIChild);
  if Child.FileName<>'NONAME' then
    Child.Editor.Lines.SaveToFile(Child.FileName);
  Child.Caption:=Child.FileName;
  Child.Modified:=false;
  TabWindows.Tabs[Child.TabIndex]:=ExtractFileName(Child.FileName);
end;

procedure TMainForm.DummyProc(var Message:TMessage);
begin // really cheeky shit
  if (Message.Msg = WM_PAINT) or (Message.Msg = WM_ERASEBKGND) then
  else SaveProc(Message);
end;

procedure TMainForm.TimerTimer(Sender: TObject);
var
  Child:TMDIChild;
begin
  Child:=TMDIChild(ActiveMDIChild);
  if (Child<>nil) and (Child.ColorConv<>nil) then
  with Child do
  begin
    Editor.HideSelection:=true;

    SaveProc:=Editor.WindowProc;
    Editor.WindowProc:=DummyProc;

    Editor.OnChange:=nil;
    Editor.OnSelectionChange:=nil;

    ColorConv.Colorise;

    Editor.OnChange:=EditorChange;
    Editor.OnSelectionChange:=EditorSelectionChange;
    Timer.Enabled:=false;

    Editor.WindowProc:=SaveProc;
    Editor.HideSelection:=false;
    Editor.SetFocus;
  end;

  Timer.Interval:=Max(500, (ActiveMDIChild as TMDIChild).Editor.GetTextLen div 10);
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  CloseHandle(mypipe);
end;

procedure TMainForm.TimerPipeTimer(Sender: TObject);
var
  filename:string;
  res:cardinal;
  child:TMDIChild;
  n:integer;
begin
  if ReadFile(mypipe, buffer, 1000, res, nil) then
  begin
    if res>0 then
    begin
      buffer[res]:=#0;
      filename:=String(PChar(@buffer));

      child:=nil;
      for n:=0 to MDIChildCount-1 do
      begin
        if TMDIChild(MDIChildren[n]).FileName=filename then
        begin
          child:=TMDIChild(MDIChildren[n]);
          break;
        end;
      end;
      if child=nil then
        CreateMDIChild(filename)
      else
        child.BringToFront;
      Application.BringToFront;
    end;
    DisconnectNamedPipe(mypipe);
    CloseHandle(mypipe);
    mypipe:=CreateNamedPipe(mypipename, PIPE_ACCESS_DUPLEX, PIPE_TYPE_BYTE, 1, 1000, 1000, 0, nil);
  end;
end;

procedure TMainForm.SearchReplace1ReplaceDialogShow(Sender: TObject);
var
  Child:TMDIChild;
begin
  Child:=TMDIChild(ActiveMDIChild);
  Child.NoUndates:=true;
end;

procedure TMainForm.SearchReplace1ReplaceDialogClose(Sender: TObject);
var
  Child:TMDIChild;
begin
  Child:=TMDIChild(ActiveMDIChild);
  Child.NoUndates:=false;
  Child.EditorChange(Sender);
end;

procedure TMainForm.FileSaveAs1Update(Sender: TObject);
begin
  FileSaveAs1.Enabled:=ActiveMDIChild<>nil;
end;

procedure TMainForm.FileRefreshExecute(Sender: TObject);
var
  Child:TMDIChild;
  pos:integer;
begin
  if ActiveMDIChild<>nil then
  begin
    Child:=ActiveMDIChild as TMDIChild;
    if FileExists(Child.FileName) then
    begin
      pos:=Child.Editor.SelStart;
      Child.Editor.Lines.LoadFromFile(Child.FileName);
      Child.Modified:=false;
      Child.Editor.SelStart:=pos;
    end;
  end;
end;

procedure TMainForm.TabWindowsChange(Sender: TObject);
var i:integer;
begin
  for i:=0 to MDIChildCount-1 do
    if (MDIChildren[i] as TMDIChild).TabIndex=TabWindows.TabIndex then
    begin
      MDIChildren[i].BringToFront;
      exit;
    end;
end;

end.
