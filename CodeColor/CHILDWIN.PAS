unit CHILDWIN;

interface

uses Windows, Classes, Graphics, Forms, Controls, StdCtrls, ComCtrls, SysUtils,
  Colorer, Main, Dialogs, Menus;

type
  TMDIChild = class(TForm)
    Editor: TRichEdit;
    LocalMenu: TMainMenu;
    mnView: TMenuItem;
    mnViewFont: TMenuItem;
    FontDialog: TFontDialog;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EditorChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure EditorKeyPress(Sender: TObject; var Key: Char);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure EditorSelectionChange(Sender: TObject);
    procedure EditorKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormActivate(Sender: TObject);
    procedure mnViewFontClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    FileName:string;
    Modified:boolean;
    ColorConv:TColorConv;
    CurPos:TPoint;

    NoUndates:boolean;

    TabIndex:integer;
  end;

implementation

uses StrUtils;

{$R *.dfm}

resourcestring
  RSSaveChanges = 'Сохранить изменения?';
  RSClosing = 'Закрытие';

procedure TMDIChild.FormClose(Sender: TObject; var Action: TCloseAction);
var i:integer;
begin
  //ColorConv:=nil;
  //MainForm.Timer.Enabled:=false;
  Action:=caFree;
  MainForm.TabWindows.Tabs.Delete(TabIndex);
  for i:=0 to MainForm.MDIChildCount-1 do
    if (MainForm.MDIChildren[i] as TMDIChild).TabIndex>TabIndex then
      dec((MainForm.MDIChildren[i] as TMDIChild).TabIndex);
end;

procedure TMDIChild.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose:=true;
  if Modified then
  begin
    case Application.MessageBox(PAnsiChar(RSSaveChanges), PAnsiChar(RSClosing+': '+FileName), MB_YESNOCANCEL) of
    ID_YES:MainForm.FileSave1Execute(Sender);
    ID_CANCEL:CanClose:=false;
    end;
  end;
end;

procedure TMDIChild.EditorChange(Sender: TObject);
begin
  if NoUndates then exit;
  if not Modified then Caption:=FileName+'*';
  Modified:=true;
  Editor.SelAttributes.Color:=0;
  if ColorConv<>nil then
  begin
    MainForm.Timer.Enabled:=false;
    MainForm.Timer.Enabled:=true;
  end;
end;

procedure TMDIChild.FormCreate(Sender: TObject);
begin
  Modified:=false;
  ColorConv:=nil;
  NoUndates:=false;
  FontDialog.Font:=Editor.Font;
end;

procedure TMDIChild.EditorKeyPress(Sender: TObject; var Key: Char);
var
  row,n:integer;
  ident,s:string;
begin
  if Key=#13 then
  begin
    Editor.OnSelectionChange:=nil;

    // gen ident
    ident:='';
    row:=CurPos.Y;
    while (row>0) and (Length(Trim(Editor.Lines[row]))=0) do dec(row);
    if (row>=0) and (Length(Trim(Editor.Lines[row]))>0) then
    begin
      n:=1;
      s:=Editor.Lines[row];
      while (n<=Length(s)) and (s[n] in [' ',#9]) do begin ident:=ident+s[n]; inc(n); end;
    end;

    // split line
    row:=CurPos.Y;
    s:=Editor.Lines[row];
    if CurPos.X=Length(s) then
    begin
      Editor.Lines.Insert(row+1, ident);
      Editor.SelStart:=Editor.SelStart-2;
    end
    else
    begin
      Editor.Lines.Insert(row+1, ident+Copy(s,CurPos.X+1,Length(s)));
      Editor.Lines[row]:=LeftStr(s, CurPos.X);
      Editor.SelStart:=Editor.SelStart+2+Length(ident);
    end;

    Editor.OnSelectionChange:=EditorSelectionChange;
    EditorSelectionChange(Sender);
  end;
end;

procedure TMDIChild.EditorSelectionChange(Sender: TObject);
var
  p,col,row:integer;
begin
  //calc cur pos
  p:=0;
  row:=0;
  while p<Editor.SelStart do
  begin
    if Length(Editor.Lines[row])+p<Editor.SelStart then
    begin
      inc(p, Length(Editor.Lines[row])+2);
      inc(row);
      col:=0;
    end
    else
    begin
      col:=Editor.SelStart-p;
      p:=Editor.SelStart;
    end;
  end;
  //MainForm.StatusBar.SimpleText:=IntToStr(Editor.SelStart);
  CurPos.X:=col;
  CurPos.Y:=row;
  MainForm.StatusBar.Panels[0].Text:=IntToStr(row+1);
  MainForm.StatusBar.Panels[1].Text:=IntToStr(col+1);
end;

procedure TMDIChild.EditorKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (ssCtrl in Shift) and (lo(Key)=ord('Y')) then Editor.Lines.Delete(CurPos.Y);
end;

procedure TMDIChild.FormActivate(Sender: TObject);
begin
  if ColorConv<>nil then ColorConv.Editor:=Editor;
  MainForm.TabWindows.OnChange:=nil;
  MainForm.TabWindows.TabIndex:=TabIndex;
  MainForm.TabWindows.OnChange:=MainForm.TabWindowsChange;
end;

procedure TMDIChild.mnViewFontClick(Sender: TObject);
var p:integer;
begin
  If FontDialog.Execute then
  with FontDialog.Font do
  begin
    p:=Editor.SelStart;
    Editor.SelectAll;
    Editor.SelAttributes.Name:=Name;
    Editor.SelAttributes.Charset:=Charset;
    Editor.SelAttributes.Size:=Size;
    Editor.SelAttributes.Pitch:=Pitch;
    Editor.SelAttributes.Style:=Style;
    //Editor.SelAttributes.Height:=Height;
    Editor.SelStart:=p;
  end;
end;

end.
