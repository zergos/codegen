unit Colorer;

interface

uses Classes, Graphics, ComCtrls, SysUtils, pcre, perlregex;

var gob1:char;

type
  TColorColor = record
    id:char;
    color:TColor;
  end;

  TColorBlock = record
    Name:string;
    Regex:string;
    Regexp:TPerlRegEx;
    Color:TColor;
    Options:TPerlRegExOptions;
  end;
  PColorBlock = ^TColorBlock;

  TColorSection = record
    Name:string;
    Regex:string;
    Regexp:TPerlRegEx;
    Blocks:array of PColorBlock;
    Options:TPerlRegExOptions;
  end;

  TColorConv = class
  private
    Exts:TStringList;
    //Keywords:string;
    //KeywordsColor:TColor;
    Colors:array of TColorColor;
    Blocks:array of PColorBlock;
    Sections:array of TColorSection;
    Options:TPerlRegExOptions;
    //Regexp:TPerlRegEx;

    CurColor:TColor;
    CurData:string;
    KeywordsMode:boolean;
    CurOffset:integer;

    procedure Study;
    procedure Match(Sender:TObject);
    procedure Match2(Sender:TObject);

  public
    Editor:TRichEdit;

    constructor Create(name:string);
    destructor Destroy; override;

    procedure Colorise;
  end;

  TColorFiles = class
    ColorConv:array of TColorConv;
    constructor Create;
    destructor Destroy; override;

    function ColorBlock(name:string):TColorConv;
  end;

implementation

uses StrUtils, StdCtrls;

{ TColorConv }

constructor TColorConv.Create;
const SynSections = 'MAIN,COLORS,SECTIONS,REGEX';
var
  s,Sec:TStringList;
  n,mode,l,k,i:integer;
  line,ex,ex2,curname:string;

  function get(ident:string=','):string;
  var p:integer;
  begin
    p:=Pos(ident,line);
    if p=0 then
    begin
      Result:=line;
      line:='';
    end
    else
    begin
      Result:=Trim(LeftStr(line, p-1));
      line:=Trim(Copy(line, p+1, length(line)));
    end;
  end;

  function gets:string;
  var p:integer;
  begin
    p:=2;
    Result:='';
    while true do
    begin
      if (line[p]='"') and (line[p-1]<>'\') then break;
      Result:=Result+line[p];
      inc(p);
    end;
    //Result:=StringReplace(Result, '\n','\x0D\x0A',[rfReplaceAll]);
    line:=Copy(line, p+2, length(line));
    //line:=Copy(line, p+2, length(line));
  end;

  function getoptions(s:string):TPerlRegExOptions;
  var n:integer;
  begin
    Result:=[];
    for n:=1 to Length(s) do
    case s[n] of
    'c':Result:=Result+[preCaseLess];
    'm':Result:=Result+[preMultiLine];
    's':Result:=Result+[preSingleLine];
    'u':Result:=Result+[preUnGreedy];
    'a':Result:=Result+[preAnchored];
    end;
  end;

  function gethex(s:string):integer;
  begin
    if s[1]<>'$' then Result:=StrToInt(s)
    else
      Result:=StringToColor(s);
  end;

  function getcolor(c:char):TColor;
  var n:integer;
  begin
    Result:=0;
    for n:=0 to Length(Colors)-1 do
    if Colors[n].id=c then
    begin
      Result:=Colors[n].color;
      break;
    end;
  end;

begin
  Sec:=TStringList.Create;
  Sec.CommaText:=SynSections;

  Exts:=TStringList.Create;

  s:=TStringList.Create;
  s.LoadFromFile(name);
  n:=0;
  mode:=-1;
  while n<s.Count do
  begin
    line:=Trim(s[n]);
    inc(n);
    if line='' then Continue;

    if line[1]='[' then
    begin
      line:=UpperCase(Copy(line,2,Length(line)-2));
      mode:=Sec.IndexOf(get('.'));
      if mode=3 then curname:=UpperCase(line);
      continue;
    end;

    if line[1]='#' then Continue;

    case mode of
    0:begin
        ex:=UpperCase(get('='));
        if ex='EXTENSION' then
        begin
          while line<>'' do Exts.Add(UpperCase(get));
        end
        else if ex='OPTIONS' then Options:=getoptions(line)
        ;//else if ex='KEYWORDS' then Keywords:=line;
      end;
    1:begin
        l:=Length(Colors);
        SetLength(Colors, l+1);
        ex2:=Trim(get('='));
        ex:=get;
        Colors[l].id:=ex[1];
        Colors[l].color:=gethex(line);
        //if UpperCase(ex2)='KEYWORDS' then KeywordsColor:=Colors[l].color;
      end;
    2:begin
        l:=Length(Sections);
        SetLength(Sections,l+1);
        Sections[l].Name:=UpperCase(get('='));
        Sections[l].Regex:=gets;
        Sections[l].Options:=getoptions(line);
      end;
    3:begin
        ex:=UpperCase(get('='));
        l:=-1;
        if line='' then
        for i:=0 to Length(Blocks)-1 do
          if Blocks[i].Name=ex then
          begin
            l:=i;
            break;
          end;

        if l=-1 then
        begin
          l:=Length(Blocks);
          SetLength(Blocks, l+1);
          New(Blocks[l]);
          Blocks[l].Name:=ex;
          Blocks[l].Regex:=gets;
          Blocks[l].Color:=getcolor(get[1]);
          Blocks[l].Options:=getoptions(line);
        end;

        for k:=0 to Length(Sections)-1 do
          if Sections[k].Name=curname then
          begin
            i:=Length(Sections[k].Blocks);
            SetLength(Sections[k].Blocks, i+1);
            Sections[k].Blocks[i]:=Blocks[l];
          end;
      end;
    end;
  end;

  Sec.Free;
  s.Free;

  Study;
end;

destructor TColorConv.Destroy;
begin
  //Regexp.Free;
  SetLength(Colors,0);
  SetLength(Sections,0);
  inherited;
end;

procedure TColorConv.Colorise;
var
  save,n,k:integer;
  reg:TPerlRegEx;
begin
  save:=Editor.SelStart;
  //Editor.Enabled:=false;

  Editor.SelectAll;
  Editor.SelAttributes.Color:=Colors[0].color;

  KeywordsMode:=false;
  for k:=0 to Length(Sections)-1 do
  begin
    reg:=Sections[k].Regexp;
    reg.Subject:=Editor.Lines.Text;//GetText);

    if reg.Match then
    repeat
      for n:=0 to Length(Sections[k].Blocks)-1 do
      begin
        with Sections[k], Sections[k].Blocks[n].Regexp do
        begin
          Subject:=CurData;
          CurColor:=Blocks[n].Color;
          if Match then while MatchAgain do;
        end;
      end;

      {if Sections[k].Name='CODE' then
      begin
        CurColor:=KeywordsColor;
        KeywordsMode:=true;
        with Regexp do
        begin
          Subject:=CurData;
          if Match then while MatchAgain do;
        end;
        KeywordsMode:=false;
      end;}
    until not reg.MatchAgain;
  end;

  //Editor.Enabled:=true;
  Editor.SelStart:=save;
  Editor.SelAttributes.Color:=Colors[0].color;
  //Editor.SelLength:=0;
end;

procedure TColorConv.Match(Sender: TObject);
var reg:TPerlRegEx;
begin
  reg:=Sender as TPerlRegEx;

  Editor.SelStart:=reg.GroupOffsets[1]-1+CurOffset;
  Editor.SelLength:=reg.GroupLengths[1];
  Editor.SelAttributes.Color:=CurColor;//ColorBlocks[CurBlock].Color;
  if KeywordsMode then
    Editor.SelAttributes.Style:=[fsBold];
  FillChar(CurData[reg.GroupOffsets[1]], Editor.SelLength, ' ');
end;

procedure TColorConv.Match2(Sender: TObject);
var reg:TPerlRegEx;
begin
  reg:=Sender as TPerlRegEx;
  CurData:=reg.Groups[1];
  CurOffset:=reg.GroupOffsets[1]-1;
end;

procedure TColorConv.Study;
var n,k:integer;
begin
  for k:=0 to Length(Sections)-1 do
  begin
    Sections[k].Regexp:=TPerlRegEx.Create();
    Sections[k].Regexp.RegEx:=Sections[k].Regex;
    Sections[k].Regexp.Options:=Options+Sections[k].Options;
    Sections[k].Regexp.Study;
    Sections[k].Regexp.OnMatch:=Match2;
  end;

  for n:=0 to Length(Blocks)-1 do
  with Blocks[n]^ do
  begin
    Regexp:=TPerlRegEx.Create();
    Regexp.RegEx:=Regex;
    Regexp.Options:=Self.Options+Options;
    Regexp.Study;
    Regexp.OnMatch:=Match;
  end;

  {Regexp:=TPerlRegEx.Create(nil);
  Regexp.Options:=Options+[preMultiLine, preSingleLine];
  Regexp.RegEx:='\b('+Keywords+')\b';
  Regexp.Study;
  Regexp.OnMatch:=Match;}
end;

{ TColorFiles }

constructor TColorFiles.Create;
var
  rec:TSearchRec;
  n:integer;
begin
  if FindFirst(ExtractFilePath(ParamStr(0))+'syntax\*.syn', faAnyFile, rec)=0 then
  repeat
    n:=Length(ColorConv);
    SetLength(ColorConv, n+1);
    ColorConv[n]:=TColorConv.Create(ExtractFilePath(ParamStr(0))+'syntax\'+rec.Name);
  until FindNext(rec)<>0;
  FindClose(rec);
end;

destructor TColorFiles.Destroy;
begin
  Finalize(ColorConv);
  inherited;
end;

function TColorFiles.ColorBlock(name: string): TColorConv;
var
  n:integer;
  ext:string;
begin
  ext:=UpperCase(RightStr(name, Pos('.', ReverseString(name))-1));
  Result:=nil;
  for n:=0 to Length(ColorConv)-1 do
    if ColorConv[n].Exts.IndexOf(ext)>=0 then
    begin
      Result:=ColorConv[n];
      break;
    end;
end;

end.
