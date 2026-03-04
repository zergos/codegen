unit Refactory;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Scripts, Globals;

type
  TRefactoryForm = class(TForm)
    Label1: TLabel;
    cbScheme: TComboBox;
    GroupBox1: TGroupBox;
    Label2: TLabel;
    cbSrcGroup: TComboBox;
    Label3: TLabel;
    cbSrcFile: TComboBox;
    GroupBox2: TGroupBox;
    Label4: TLabel;
    cbDestGroup: TComboBox;
    Label5: TLabel;
    cbDestFile: TComboBox;
    Label6: TLabel;
    editPath: TEdit;
    btnPath: TButton;
    btnDo: TButton;
    OpenDialog1: TOpenDialog;
    Memo1: TMemo;
    procedure FormShow(Sender: TObject);
    procedure cbSchemeChange(Sender: TObject);
    procedure cbSrcGroupChange(Sender: TObject);
    procedure cbDestGroupChange(Sender: TObject);
    procedure btnPathClick(Sender: TObject);
    procedure btnDoClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  RefactoryForm: TRefactoryForm;

implementation

uses StrUtils, Main;

{$R *.dfm}

resourcestring
  RSParametersMissed = 'Не все параметры заданы';

procedure TRefactoryForm.FormShow(Sender: TObject);
var i:integer;
begin
  cbScheme.Clear;
  for i:=0 to Length(sSchemes.Scheme)-1 do
    cbScheme.Items.Add(sSchemes.Scheme[i].Name);

  cbSrcGroup.Clear;
  cbSrcFile.Clear;
  cbDestGroup.Clear;
  cbDestFile.Clear;

  editPath.Text:=ExtractFilePath(ParamStr(0))+'CodeGrams\';
end;

procedure TRefactoryForm.cbSchemeChange(Sender: TObject);
var
  i,k:integer;
  s,t:string;
begin
  if cbScheme.ItemIndex<0 then exit;

  cbSrcGroup.Clear;
  cbSrcFile.Clear;
  cbDestGroup.Clear;
  cbDestFile.Clear;

  i:=cbScheme.ItemIndex;
  t:='';
  cbSrcGroup.Items.Add('<root>');
  for k:=0 to sSchemes.Scheme[i].Count-1 do
  begin
    s:=sSchemes.Scheme[i].Objects[k].ScriptName;
    s:=LeftStr(s, Pos('\',s)-1);
    if (s<>t)and(s<>'') then
    begin
      t:=s;
      cbSrcGroup.Items.Add(s);
      cbDestGroup.Items.Add(s);
    end;
  end;
end;

procedure TRefactoryForm.cbSrcGroupChange(Sender: TObject);
var
  i,k:integer;
  s,t:string;
begin
  if cbSrcGroup.ItemIndex<0 then exit;
  cbSrcFile.Clear;
  i:=cbScheme.ItemIndex;
  s:=cbSrcGroup.Items[cbSrcGroup.ItemIndex];
  if s='<root>' then s:='';
  for k:=0 to sSchemes.Scheme[i].Count-1 do
  begin
    t:=sSchemes.Scheme[i].Objects[k].ScriptName;
    if s=LeftStr(t, Pos('\', t)-1) then
      cbSrcFile.Items.Add(MidStr(t, Pos('\', t)+1,Length(t)));
  end;
end;

procedure TRefactoryForm.cbDestGroupChange(Sender: TObject);
var
  i,k:integer;
  s,t:string;
begin
  if cbDestGroup.ItemIndex<0 then exit;
  cbDestFile.Clear;
  i:=cbScheme.ItemIndex;
  s:=cbDestGroup.Items[cbDestGroup.ItemIndex];
  for k:=0 to sSchemes.Scheme[i].Count-1 do
  begin
    t:=sSchemes.Scheme[i].Objects[k].ScriptName;
    if s=LeftStr(t, Pos('\', t)-1) then
      cbDestFile.Items.Add(MidStr(t, Pos('\', t)+1,Length(t)));
  end;
end;

procedure TRefactoryForm.btnPathClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
    EditPath.Text:=ExtractFilePath(OpenDialog1.FileName);
end;

procedure TRefactoryForm.btnDoClick(Sender: TObject);
var
  i,k:integer;
  src,dest:TStringList;
  ind,code:integer;
  s,sub:string;
  check,found,fixed:boolean;

  function Next(sym:string='='):string;
  var p:integer;
  begin
    p:=Pos(sym, s);
    if p=0 then p:=length(s)+1;
    result:=MidStr(s,1,p-1);
    s:=MidStr(s,p+1,Length(s));
  end;

  procedure Search(path:string);
  var
    rec:TSearchRec;
    n:integer;
  begin
    if FindFirst(Path+'*.*', faAnyFile, rec)=0 then
    repeat
      if rec.Name[1]='.' then Continue;
      if rec.Attr and faDirectory>0 then
      begin
        Search(Path+rec.Name+'\');
        continue;
      end
      else if ExtractFileExt(rec.Name)<>'.gen' then continue;

      src.LoadFromFile(path+rec.Name);

      if src[0]<>sSchemes.Scheme[i].Name then continue;

      dest.Clear;

      code:=-1;
      ind:=1;
      fixed:=false;
      dest.Add(src[0]); // scheme name
      while (ind<src.Count)and(code<100) do
      begin
        s:=src[ind];
        inc(ind);
        if length(s)=0 then continue;
        if s[1]='<' then code:=0;
        case code of
        0:begin
          dest.Add(s);
          if s='<BLOX>' then code:=1
          else
          if s='<BLOX2>' then code:=1
          else if s='<LINX>' then code:=2
          else if s='<TOUCH>' then code:=2
          else if s='<COMMON>' then code:=2;
          end;
        1:begin
            sub:=next;
            found:=false;
            check:=false;
            for n:=0 to sSchemes.Scheme[i].Count-1 do
              if sSchemes.Scheme[i].Objects[n].ScriptName=sub then begin found:=true; break; end;
            if found then check:=(sub=IfThen(cbSrcGroup.Text='<root>','',cbSrcGroup.Text+'\')+cbSrcFile.Text)
            else // add custom directory patch
            begin
              for n:=0 to sSchemes.Scheme[i].Count-1 do
              begin
                k:=pos('\', sSchemes.Scheme[i].Objects[n].ScriptName);
                if k>0 then
                  if Copy(sSchemes.Scheme[i].Objects[n].ScriptName,k+1,10000)=sub then begin found:=true; break; end;
              end;
              if found then check:=(sub = cbSrcFile.Text);
            end;
            if not found then begin code:=100; continue; end;
            if check then
            begin
              dest.Add(cbDestGroup.Text+'\'+cbDestFile.Text+'='+s);
              fixed:=true;
            end
            else
              dest.Add(sub+'='+s);
            code:=14;
          end;
        14:begin
             dest.Add(s);
             if s='-' then code:=1;
           end;
        2: dest.Add(s);
        end;
      end;

      if (code<100) and fixed then
      begin
        Memo1.Lines.Add(ExtractFileName(rec.Name));
        dest.SaveToFile(path+rec.Name);
      end;
    until FindNext(rec)<>0;
  end;

begin
  if (cbScheme.ItemIndex<0)or(cbSrcGroup.ItemIndex<0)or(cbSrcFile.ItemIndex<0)or(cbDestGroup.Text='')or(cbDestFile.Text='')or(editPath.Text='') then
  begin
    Application.MessageBox(PChar(RSParametersMissed), '');
    exit;
  end;

  i:=cbScheme.ItemIndex;
  CreateDir(ScriptPath+sSchemes.Scheme[i].Name+'\'+cbDestGroup.Text);
  // copy file
  MoveFile(PChar(ScriptPath+sSchemes.Scheme[i].Name+'\'+IFThen(cbSrcGroup.Text='<root>','',cbSrcGroup.Text+'\')+cbSrcFile.Text+'.o'), PChar(ScriptPath+sSchemes.Scheme[i].Name+'\'+cbDestGroup.Text+'\'+cbDestFile.Text+'.o'));
  // refactory sources
  src:=TStringList.Create;
  dest:=TStringList.Create;
  Memo1.Lines.Clear;
  Search(editPath.Text);
  src.Free;
  dest.Free;

  (Application.MainForm as TMainForm).mnFileRefreshClick(Sender);
end;

end.
