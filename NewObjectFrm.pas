unit NewObjectFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Scripts, Globals, StdCtrls, StrUtils, ShellApi;

type
  TNewObjectForm = class(TForm)
    Label1: TLabel;
    cbSchemes: TComboBox;
    Label2: TLabel;
    cbDirectory: TComboBox;
    Label3: TLabel;
    cbGroup: TComboBox;
    Label4: TLabel;
    cbFileName: TComboBox;
    Label5: TLabel;
    cbNames: TComboBox;
    btnCreate: TButton;
    Label6: TLabel;
    cbUserNames: TComboBox;
    procedure FormCreate(Sender: TObject);
    procedure cbSchemesChange(Sender: TObject);
    procedure cbDirectoryChange(Sender: TObject);
    procedure cbGroupChange(Sender: TObject);
    procedure btnCreateClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  NewObjectForm: TNewObjectForm;

implementation

{$R *.dfm}

resourcestring
  RSParametersMissed = 'Не все параметры заданы';
  RSFileExists = 'Файл %s.o существует. Перезаписать?';

procedure TNewObjectForm.FormCreate(Sender: TObject);
var n:integer;
begin
  cbSchemes.Clear;
  for n:=0 to Length(sSchemes.Scheme)-1 do
    cbSchemes.Items.Add(sSchemes.Scheme[n].Name);

  cbDirectory.Clear;
  cbFileName.Clear;
  cbGroup.Clear;
  cbNames.Clear;
end;

procedure TNewObjectForm.cbSchemesChange(Sender: TObject);
var
  i,k:integer;
  s,t:string;
  ts:TStringList;
begin
  if cbSchemes.ItemIndex<0 then exit;

  cbDirectory.Clear;
  cbFileName.Clear;
  cbGroup.Clear;
  cbNames.Clear;
  cbUserNames.Clear;

  i:=cbSchemes.ItemIndex;
  t:='';
  ts:=TStringList.Create;
  cbDirectory.Items.Add('<root>');
  for k:=0 to sSchemes.Scheme[i].Count-1 do
  begin
    s:=sSchemes.Scheme[i].Objects[k].ScriptName;
    s:=LeftStr(s, Pos('\',s)-1);
    if (s<>t)and(s<>'') then
    begin
      t:=s;
      cbDirectory.Items.Add(s);
    end;

    s:=sSchemes.Scheme[i].Objects[k].GroupName;
    if ts.IndexOf(s)<0 then
      ts.Add(s);
  end;

  ts.Sort;
  cbGroup.Items.AddStrings(ts);
  ts.Free;
end;

procedure TNewObjectForm.cbDirectoryChange(Sender: TObject);
var
  i,k:integer;
  s,t:string;
begin
  if cbDirectory.ItemIndex<0 then exit;
  cbFileName.Clear;
  i:=cbSchemes.ItemIndex;
  s:=cbDirectory.Items[cbDirectory.ItemIndex];
  if s='<root>' then s:='';
  for k:=0 to sSchemes.Scheme[i].Count-1 do
  begin
    t:=sSchemes.Scheme[i].Objects[k].ScriptName;
    if s=LeftStr(t, Pos('\', t)-1) then
      cbFileName.Items.Add(MidStr(t, Pos('\', t)+1,Length(t)));
  end;
end;

procedure TNewObjectForm.cbGroupChange(Sender: TObject);
var
  i,k:integer;
  s,t:string;
begin
  if cbGroup.ItemIndex<0 then exit;
  cbNames.Clear;
  cbUserNames.Clear;
  i:=cbSchemes.ItemIndex;
  s:=cbGroup.Items[cbGroup.ItemIndex];
  for k:=0 to sSchemes.Scheme[i].Count-1 do
  begin
    t:=sSchemes.Scheme[i].Objects[k].GroupName;
    if s=t then
    begin
      cbNames.Items.Add(sSchemes.Scheme[i].Objects[k].DefaultName);
      cbUserNames.Items.Add(sSchemes.Scheme[i].Objects[k].ObjectName);
    end;
  end;
end;

procedure TNewObjectForm.btnCreateClick(Sender: TObject);
var
  i:integer;
  ts:TStringList;
  f:string;
begin
  if (cbSchemes.ItemIndex=-1)or(cbDirectory.Text='')or(cbFileName.Text='')or(cbGroup.Text='')or(cbNames.Text='') then
  begin
    Application.MessageBox(PChar(RSParametersMissed), '');
    exit;
  end;

  i:=cbSchemes.ItemIndex;
  if cbDirectory.Text<>'<root>' then
    CreateDir(ScriptPath+sSchemes.Scheme[i].Name+'\'+cbDirectory.Text);
  ts:=TStringList.Create;
  ts.Add('[Main]');
  ts.Add(Format('Name=%s', [cbNames.Text]));
  ts.Add(Format('Title=%s', [cbUserNames.Text]));
  ts.Add(Format('Group=%s', [cbGroup.Text]));
  ts.Add('');
  ts.Add('[Code]');
  ts.Add('<lines>');
  ts.Add('');
  ts.Add('[Help]');

  if cbDirectory.Text<>'<root>' then
    f:=ScriptPath+sSchemes.Scheme[i].SchemePath+'\'+cbDirectory.Text+'\'+cbFileName.Text+'.o'
  else
    f:=ScriptPath+sSchemes.Scheme[i].SchemePath+'\'+cbFileName.Text+'.o';

  if FileExists(f) then
    if MessageDlg(Format(RSFileExists, [cbFileName.Text]), mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
      exit;

  ts.SaveToFile(f);
  ts.Free;

  ShellExecute(ParentWindow, 'open', PAnsiChar(f), nil, '', SW_NORMAL);
  Hide;
end;

end.
