program CC;

uses
  Forms,
  Windows,
  SysUtils,
  MAIN in 'MAIN.PAS' {MainForm},
  CHILDWIN in 'CHILDWIN.PAS' {MDIChild},
  about in 'about.pas' {AboutBox},
  PerlRegEx in 'regex\PerlRegEx.pas',
  pcre in 'regex\pcre.pas',
  Colorer in 'Colorer.pas';

{$R *.RES}

var
  buffer:string;
  res:cardinal;

begin
  mypipe:=CreateFile(mypipename, GENERIC_WRITE, FILE_SHARE_READ, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  if mypipe=INVALID_HANDLE_VALUE then
  begin
    mypipe:=CreateNamedPipe(mypipename, PIPE_ACCESS_DUPLEX, PIPE_TYPE_BYTE, 1, 1000, 1000, 0, nil);
  end
  else
  begin
    if ParamCount=1 then
    begin
      buffer:=ExpandFileName(ParamStr(1))+#0;
      WriteFile(mypipe, buffer[1], Length(buffer), res, nil);
    end;
    CloseHandle(mypipe);
    exit;
  end;

  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TAboutBox, AboutBox);
  if ParamCount>0 then MainForm.CreateMDIChild(ParamStr(1));
  Application.Run;
end.
