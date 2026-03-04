unit UseFull;

interface

uses Windows, Forms, Classes, SysUtils;

{$EXTERNALSYM CoInitialize}
function CoInitialize(pvReserved: Pointer): HResult; stdcall;
{$EXTERNALSYM CoUninitialize}
procedure CoUninitialize; stdcall;

// Диалог вопроса Win API
function Ask(s:string):boolean;

// Диалог ошибки Win API
procedure Warn(mes:string);

procedure ExecuteAndWait(const aCommando: string);

function HexToInt(s:string):integer;

function RandomColor:integer;

function NoExt(s:string):string;

function LoadFile(const fn: string): WideString;

implementation

const
  ole32    = 'ole32.dll';

function CoInitialize;                  external ole32 name 'CoInitialize';
procedure CoUninitialize;               external ole32 name 'CoUninitialize';

resourcestring
  RSConfirmation = 'Подтверждение';

function Ask(s:string):boolean;
begin
  Result:=Application.MessageBox(PChar(s), PChar(RSConfirmation), MB_YESNO)=IDOK;
end;

procedure Warn(mes:string);
begin
  Application.MessageBox(PChar(mes), PChar(RSConfirmation));
end;

procedure ExecuteAndWait(const aCommando: string);
var
  tmpStartupInfo: TStartupInfo;
  tmpProcessInformation: TProcessInformation;
  tmpProgram: String;
begin
  tmpProgram := trim(aCommando);
  FillChar(tmpStartupInfo, SizeOf(tmpStartupInfo), 0);
  with tmpStartupInfo do
  begin
    cb := SizeOf(TStartupInfo);
    wShowWindow := SW_HIDE;
  end;

  if CreateProcess(nil, pchar(tmpProgram), nil, nil, true, CREATE_NO_WINDOW,
    nil, nil, tmpStartupInfo, tmpProcessInformation) then
  begin
    while WaitForSingleObject(tmpProcessInformation.hProcess, 100) > 0 do
    begin
      Application.ProcessMessages;
    end;
    CloseHandle(tmpProcessInformation.hProcess);
    CloseHandle(tmpProcessInformation.hThread);
  end
  else
  begin
    RaiseLastOSError;
  end;
end;

function HexToInt(s:string):integer;
const hchars:string = '0123456789ABCDEF';
var n:integer;
begin
  Result:=0;
  for n:=1 to Length(s) do
    Result:=Result*16+Pos(s[n], hchars)-1;
end;

function RandomColor;
var r,g,b:integer;

  function get:byte;
  begin
    result:=random(16)*8+32;
  end;

begin
  r:=get;
  repeat
    g:=get;
  until g<>r;
  repeat
    b:=get;
  until (b<>r)and(b<>g);
  Result:=r+(g shl 8)+(b shl 16);
end;

function NoExt(s:string):string;
begin
  if Pos('.',s)>0 then
    result:=Copy(s, 1, Pos('.',s)-1);
end;

function LoadFile(const fn: string): WideString;
var
  f:TFileStream;
  src:AnsiString;
  wx:word;
  i,j:integer;
begin
  if FileExists(fn) then
   begin
    f:=TFileStream.Create(fn,fmOpenRead or fmShareDenyNone);
    try
      f.Read(wx,2);
      if wx=$FEFF then
       begin
        //UTF16
        i:=(f.Size div 2)-1;
        SetLength(Result,i);
        f.Read(Result[1],i*2);
        //detect NULL's
        for j:=1 to i do if Result[j]=#0 then Result[j]:=' ';//?
       end
      else
       begin
        i:=0;
        if wx=$BBEF then f.Read(i,1);
        if (wx=$BBEF) and (i=$BF) then
         begin
          //UTF-8
          i:=f.Size-3;
          SetLength(src,i);
          f.Read(src[1],i);
          //detect NULL's
          for j:=1 to i do if src[j]=#0 then src[j]:=' ';//?
          Result:=UTF8Decode(src);
         end
        else
         begin
          //assume current encoding
          f.Position:=0;
          i:=f.Size;
          SetLength(src,i);
          f.Read(src[1],i);
          //detect NULL's
          for j:=1 to i do if src[j]=#0 then src[j]:=' ';//?
          Result:=src;
         end;
       end;
    finally
      f.Free;
    end;
   end
  else
    Result:='';
end;

end.
