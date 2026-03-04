unit ConfirmFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TConfirmForm = class(TForm)
    Bevel1: TBevel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Label1: TLabel;
  end;

var
  ConfirmForm: TConfirmForm;

implementation

{$R *.dfm}

end.
