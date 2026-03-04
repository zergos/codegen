program CodeGen;

uses
  Forms,
  Main in 'Main.pas' {MainForm},
  MDIEditForm in 'MDIEditForm.pas' {EditForm},
  AboutForm in 'AboutForm.pas' {AboutBox},
  ConfirmFrm in 'ConfirmFrm.pas' {ConfirmForm},
  UseFull in 'UseFull.pas',
  Globals in 'Globals.pas',
  Scripts in 'Scripts.pas',
  Editors in 'Editors.pas',
  LogFrm in 'LogFrm.pas',
  SCompiler in 'SCompiler.pas',
  RoutePlanner in 'RoutePlanner.pas',
  PerlRegEx in '..\regex\PerlRegEx.pas',
  pcre in '..\regex\pcre.pas',
  Refactory in 'Refactory.pas' {RefactoryForm},
  NewObjectFrm in 'NewObjectFrm.pas' {NewObjectForm},
  LangHelper in 'LangHelper.pas';

{$R *.RES}

begin
  CoInitialize(nil);
  Application.Title := 'Code gen';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TAboutBox, AboutBox);
  Application.CreateForm(TConfirmForm, ConfirmForm);
  Application.CreateForm(TLogForm, LogForm);
  Application.CreateForm(TRefactoryForm, RefactoryForm);
  Application.CreateForm(TNewObjectForm, NewObjectForm);
  if ParamCount=1 then MainForm.OpenDatFile(ParamStr(1));
  Application.Run;
end.
