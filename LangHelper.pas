unit LangHelper;

interface

uses Classes, Globals, StrUtils;

type
  TLangConverter = class
    private
      S, Values:TStringList;
      name:string;
      stype:integer;
      paramchar:char;
    public
      constructor Create(fname, stringtype:string; _paramchar:char);
      destructor Destroy; override;

      function Translate(src:string):string;
  end;

implementation

uses SysUtils;

{ TLangConverter }

constructor TLangConverter.Create(fname, stringtype: string; _paramchar:char);
var
  src:TStringList;
  i:integer;
begin
  name:=fname;
  paramchar:=_paramchar;
  stype:=0;
  if stringtype='C' then stype:=1;

  src:=TStringList.Create;
  if LangEnglish and FileExists(fname) then
    src.LoadFromFile(fname);

  S:=TStringList.Create;
  Values:=TStringList.Create;

  for i:=0 to src.Count div 2-1 do
  begin
    //if LeftStr(src[i*2], 1)='[' then
      S.Add(Copy(src[i*2], 2, Length(src[i*2])-2));
    //else
    //  S.Add(src[i*2]);
    Values.Add(src[i*2+1]);
  end;

end;

destructor TLangConverter.Destroy;
var
  res:TStringList;
  i:integer;
begin
  if LangEnglish then
  begin
    res:=TStringList.Create;
    for i:=0 to S.Count-1 do
    begin
      res.Add('['+S[i]+']');
      res.Add(Values[i]);
    end;
    res.SaveToFile(name);
    res.Free;
  end;
  S.Free;
  Values.Free;
end;

function TLangConverter.Translate(src: string): string;
var
  pos, start:integer;
  mode:integer;
  res:string;
  skip:boolean;

  function get(value:string):string;
  var
    i:integer;
    check:boolean;
  begin
    if value='' then
    begin
      Result:='';
      exit;
    end;
    if skip then
    begin
      result:=value;
      skip:=false;
      exit;
    end;
    i:=S.IndexOf(value);
    if i>=0 then
    begin
      if Values[i]='' then Result:=value
      else
        Result:=Values[i];
    end
    else
    begin
      Result:=value;
      check:=false;
      for i:=1 to Length(value) do
        if ord(value[i])>127 then
        begin
          check:=true;
          break
        end;
      if check then
      begin
        S.Add(value);
        Values.Add('');
      end;
    end;
  end;

begin
  if not LangEnglish or (stype=0) then
  begin
    Result:=src;
    exit;
  end;

  res:='';

  if stype=1 then
  begin
    pos:=0;
    skip:=false;
    mode:=1;
    while pos<Length(src) do
    begin
      case mode of
        1:
        begin
          if src[pos]='"' then
          begin
            res:=res+'"';
            start:=pos+1;
            mode:=2;
          end
          else
            res:=res+src[pos];
        end;
        2:
        begin
          if src[pos]='"' then
          begin
            if (pos<Length(src)-1) and (src[pos+1]='"') then
              inc(pos)
            else
            begin
              res:=res+get(Copy(src, start, pos-start))+'"';
              mode:=1;
            end;
          end
          else if src[pos]='\' then
          begin
            inc(pos);
          end
          {else if src[pos]=paramchar then
          begin
            skip:=true;
          end;}
        end;
      end;
      inc(pos);
    end;
  end;

  Result:=res;
end;

end.
