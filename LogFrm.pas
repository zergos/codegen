unit LogFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TLogForm = class(TForm)
    Memo: TMemo;
    btnClose: TButton;
    Label1: TLabel;
    stErrors: TStaticText;
    Timer1: TTimer;
    procedure btnCloseClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure MemoClick(Sender: TObject);
    procedure MemoKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
    CurTick:integer;
  end;

var
  LogForm: TLogForm;

implementation

{$R *.dfm}

resourcestring
  RSClose = 'Закрыть';

procedure TLogForm.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TLogForm.FormActivate(Sender: TObject);
begin
  if stErrors.Caption='0' then
  begin
    CurTick:=3;
    Timer1.Enabled:=true;
  end
  else
    btnClose.Caption:=RSClose;
end;

procedure TLogForm.Timer1Timer(Sender: TObject);
begin
  btnClose.Caption:=RSClose+' ('+IntToStr(CurTick)+')';
  if CurTick=0 then
  begin
    Timer1.Enabled:=false;
    Close;
  end
  else
    dec(CurTick);
end;

procedure TLogForm.MemoClick(Sender: TObject);
begin
  if Timer1.Enabled then
  begin
    Timer1.Enabled:=false;
    btnClose.Caption:=RSClose;
  end;
end;

procedure TLogForm.MemoKeyPress(Sender: TObject; var Key: Char);
begin
  if Key=#27 then Close;
end;

end.
