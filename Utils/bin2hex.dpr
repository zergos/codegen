program bin2hex;

{$APPTYPE CONSOLE}

uses
  SysUtils, StrUtils;

var
  fin:file of byte;
  fout:TextFile;
  newname:string;
  cnt:integer;
  b:byte;
begin
  { TODO -oUser -cConsole Main : Insert code here }
  if ParamCount<1 then
  begin
    Writeln('Bin to hex file convertor');
    Writeln('Usage: bin2hex <filename>');
    exit;
  end;

  AssignFile(fin, ParamStr(1));
  FileMode:=fmOpenRead+fmShareDenyNone;
  Reset(fin);

  newname:=ParamStr(1);
  newname:=Copy(newname, 1, Length(newname)-Pos('.',ReverseString(newname)))+'.hex';
  AssignFile(fout, newname);
  Rewrite(fout);
  FileMode:=fmOpenWrite+fmShareDenyNone;

  cnt:=0;
  while not eof(fin) do
  begin
    Read(fin, b);
    Write(fout, Format('%.2X',[b]));
    inc(cnt);
    if cnt=60 then
    begin
      cnt:=0;
      Writeln(fout);
    end;
  end;
  Writeln(fout);

  CloseFile(fin);
  CloseFile(fout);
end.
