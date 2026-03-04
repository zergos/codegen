unit AboutForm;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls;

type
  TMove = record
    Save:TPoint;
    Current:TPoint;
    Step:TPoint;
    Control:TLabel;
    end;

type
  TAboutBox = class(TForm)
    Panel1: TPanel;
    ProgramIcon: TImage;
    OKButton: TButton;
    Label1: TLabel;
    Timer1: TTimer;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    LabelVersion: TLabel;
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
    Moves:array of TMove;
  end;

var
  AboutBox: TAboutBox;

implementation

{$R *.DFM}

function GetModuleVersion(Instance: THandle; out iMajor, iMinor, iRelease, iBuild: Integer): Boolean;
var
    fileInformation: PVSFIXEDFILEINFO;
    verlen: Cardinal;
    rs: TResourceStream;
    m: TMemoryStream;
begin
  (*
  Source - https://stackoverflow.com/a/71574768
  Posted by Николай Невзоров
  Retrieved 2026-02-19, License - CC BY-SA 4.0
  *)

  result := false;

  m := TMemoryStream.Create;
  try
    try
      rs := TResourceStream.CreateFromID(Instance, 1, RT_VERSION);
      try
        m.CopyFrom(rs, rs.Size);
      finally
        rs.Free;
      end;
    except
      exit;
    end;

    m.Position:=0;
    if not VerQueryValue(m.Memory, '\', Pointer(fileInformation), verlen) then
    begin
      iMajor := 0;
      iMinor := 0;
      iRelease := 0;
      iBuild := 0;
      Exit;
    end;

    iMajor := fileInformation.dwFileVersionMS shr 16;
    iMinor := fileInformation.dwFileVersionMS and $FFFF;
    iRelease := fileInformation.dwFileVersionLS shr 16;
    iBuild := fileInformation.dwFileVersionLS and $FFFF;
  finally
    m.Free;
  end;

  Result := True;
end;

procedure TAboutBox.Timer1Timer(Sender: TObject);
const ind:integer = 0;
var n:integer;
begin
  for n:=0 to 2 do
  with Moves[n] do
  begin
    if (Current.X<>Save.X) then
      inc(Current.X, Step.X);
    if (Current.Y<>Save.Y) then
      inc(Current.Y, Step.Y);
    Control.Left:=Current.X;
    Control.Top:=Current.Y;
    inc(ind);
    if ind=40 then
    begin
      Control.Font.Color:=
        ($80-Random($30)) shl 16+
        ($B0-Random($30)) shl 8+
        ($B0+Random($30));
      ind:=0;
    end;
  end;
end;

procedure TAboutBox.FormCreate(Sender: TObject);
var
  iMajor, iMinor, iRelease, iBuild: integer;
  ProgramVersion: string;
begin
  SetLength(Moves,3);
  Moves[0].Control:=Label1;
  Moves[1].Control:=Label2;
  Moves[2].Control:=Label3;
  if GetModuleVersion(HInstance, iMajor, iMinor, iRelease, iBuild) then
  begin
    ProgramVersion := inttostr(iMajor)+'.'+inttostr(iMinor)+'.'+inttostr(iRelease)+'.'+inttostr(iBuild);
    LabelVersion.Caption:=ProgramVersion;
  end;
end;

procedure TAboutBox.FormActivate(Sender: TObject);
var n:integer;
begin
  // init
  for n:=0 to 2 do
  with Moves[n] do
  begin
    Save:=Point(Control.Left, Control.Top);
    Current:=Point(Save.X+200, Save.Y+100);
    Step:=Point(-2,-1);
  end;

  Timer1.Enabled:=true;
end;

procedure TAboutBox.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Timer1.Enabled:=false;
end;

end.

