unit Globals;

interface

uses Graphics;

type
  tsType = (stEnum, stObject);

var
  ScriptPath:string;
  FontSize:integer;
  GridX:integer;
  GridY:integer;

const
  DefaultWidth = 18;
  DefaultHeight = 20;

  SGridX:integer = 16;
  SGridY:integer = 16;
  TextIndentX:integer = 4;
  TextIndentY:integer = 1;
  DefaultBlockWidth = 6;

  ColorSelected:TColor = $00B0B0;//$50B050;
  ColorHighligt:TColor = $D0D000;//$FFFF00;

  LineDistance = 3;
  DragDistance = 5;

  GridSnap:boolean = true;
  HardChains:boolean = true;
  CompileWriteTags:boolean = false;
  CompileWritePrints:boolean = false;
  CompileFullDebug:boolean = false;
  ShowObjectsNames:boolean = true;

  LangEnglish:boolean = false;

  HistoryDepth = 128;

function GetScriptName(Scheme, Name, sName:string; sType:tsType):string;

implementation

uses Windows, SysUtils;

function GetScriptName;
begin
  if sType = stEnum then
    Result:=ScriptPath+sName+'\'+Name+'.'+Scheme+'.e'
  else
    Result:=ScriptPath+sName+'\'+Name+'.'+Scheme+'.o';
  if FileExists(Result) then exit;
  if sType = stEnum then
    Result:=ScriptPath+sName+'\'+Name+'.e'
  else
    Result:=ScriptPath+sName+'\'+Name+'.o';
end;

function GetDisplayScalingPercentage: integer;
var
  DC: HDC;
begin
  DC := GetDC(0);
  try
    Result := GetDeviceCaps(DC, LOGPIXELSX);
  finally
    ReleaseDC(0, DC);
  end;
end;

begin
  GridX:=SGridX*GetDisplayScalingPercentage div 96;
  GridY:=SGridY*GetDisplayScalingPercentage div 96;
  FontSize:=SGridX div 2;
end.
