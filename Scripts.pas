unit Scripts;

interface

uses Windows, Classes, Registry, IniFiles, Globals, StrUtils, SysUtils, Types, Math, ZLib, Graphics, RoutePlanner, Usefull, idCoderMime;

type
  tsPropType = (ptNumber,ptFloat,ptString,ptDate,ptExtern,ptSwitch,ptRow,ptControl);

  tsCollection = class;

  tsType = class (TStringList)
  public
    ScriptName:string;
    //TypeID:string;
    Parent:tsCollection;
    Saved:boolean;
    procedure LoadScript(ScriptName:string);
    procedure SaveScript(st:TStringList);
  end;

  tsProperty = record
    Name:string;
    LabelName:string;
    Require:boolean;
    PropType:tsPropType;
    ExtType:string;
    ExtValues:tsType;
    Default:string;
  end;

  tsLink = record
    Name:string;
    LabelName:string;
    LinkType:tsPropType;
    SymName:string;
    Default:boolean;
  end;

  tsPars = record
    Name:string;
    SymName:string;
  end;

  tsMap = record
    Src, Dest:string;
    OutInd:integer;
  end;

  tsObjectTypes = (totNormal, totModel, totChoice, totUnit, totDeprecated, totLayer, totBlockIn, totBlockOut, totUsable);

  tsObject = class
  public
    ScriptName:string;
    ScriptFileName:string;
    ObjectName:string;
    GroupName:string;
    DefaultName:string;
    Size:integer;

    oType:tsObjectTypes;
    Custom:boolean;
    Propertyes:array of tsProperty;
    Input:array of tsLink;
    Output:array of tsLink;
    InputPars:array of tsPars;
    OutputPars:array of tsPars;
    sUses:TStringList;
    sGlobal:TStringList;
    sCode:TStringList;
    sTemplate:TStringList;
    sHelp:TStringList;
    sPrefix:TStringList;
    sPostfix:TStringList;
    Maps:array of tsMap;

    DestPath:string;
    Parent:tsCollection;

    // compile time
    GlobalUsed:boolean;
    LayerIndex:integer;
    Saved:boolean;

    constructor Create;
    destructor Destroy; override;
    procedure LoadScript(ScriptName: string); overload;
    procedure LoadScript(M:TStream; Size:integer); overload;
    procedure LoadScript(s:TStringList); overload;
    procedure SaveScript(M:TStream);
    function Copy:tsObject;
  end;

  tsCollection = class (TStringList)
  public
    Name, SchemePath:string;
    Objects:array of tsObject;
    Types:array of tsType;

    Env:TStringList;

    constructor Create(scheme_path, scheme:string);
    destructor Destroy; override;
    procedure ConnectTypes;
    function DecodeCmd(filename,cmd:string):string;
    function IndexOfScript(sname:string):integer;
  end;

  tsSchemes = class (TStringList)
  public
    Scheme:array of tsCollection;

    constructor Create;
    destructor Destroy; override;
  end;

  tsUnit = class
  public
    Selected:boolean;
    procedure Draw(dc:TCanvas; Light:boolean=false); virtual; abstract;
    procedure CheckSelect(SR:TRect); virtual; abstract;
  end;

  tsEntity = class (tsUnit)
    Index, PrioIndex, ParentIndex:integer;
    Name:string;
    Source:tsObject;
    PropValues:TStringList;
    OutValues, OutSymValues:TStringList;

    Rect:TRect;

    SelInOut:integer;  // индекс выделенного входа/выхода
    ParsInput:integer; // индекс входа для передачи параметров
    ObjInput:tsEntity; // ссылка на блок источник параметров

    poststring:string;

    Enabled:boolean;
    Debug:boolean;

    Comments:TStringList;

    IsLocal:boolean;
    IsProtected:boolean;

    processed:boolean;

    constructor Create(Src:tsObject);
    destructor Destroy; override;
    procedure SetRect(SR:TRect);
    procedure Draw(dc:TCanvas; Light:boolean=false); override;
    procedure CheckSelect(SR:TRect); override;
    function CheckOut(dc:TCanvas; Pos:TPoint):integer;
    function CheckIn(dc:TCanvas; Pos:TPoint):integer;
    function CalcOut:TPoint;
  end;

  tsChainLink = record
    Obj:tsEntity;
    InOutInd:integer;
    ResolveName:string;
  end;

  tsBoard = class;
  tsMultiBoard = class;

  tsChain = class (tsUnit)
    Left:tsChainLink;
    Right:tsChainLink;

    Color:TColor;

    Points:TPointsArray;

    Lost:boolean;

    destructor Destroy; override;
    procedure CheckSelect(SR:TRect); override;
    procedure Connect(Board:tsBoard);
    procedure Draw(dc:TCanvas; Light:boolean=false); override;
    function PtOnChain(Pos:TPoint):boolean;
  end;

  tsBoard = class
    Entityes:array of tsEntity;
    Chains:array of tsChain;
    Route:TRoutePlanner;

    sCollection:tsCollection;
    sLocal:tsCollection;

    ShowPrio:boolean;
    Host:tsMultiBoard;

    Version:integer;

    constructor Create;
    destructor Destroy; override;

    procedure CheckSelect(SR:TRect);
    procedure ClearSelect(Select:boolean=false);
    function IsChecked:boolean;
    function CheckName(name:string; SkipIndex:integer=-1; force_local:boolean=false):boolean;
    procedure Repaint(dc:TCanvas);
    procedure Merge(ts:tsBoard);

    function MousePress(Pos:TPoint; Select:boolean=false):tsUnit;
    procedure MoveSelected(dx, dy:integer);
    procedure ReducePos;

    function AddEntity(Source:tsObject):tsEntity;
    function AddChain(LeftObj, RightObj:tsEntity):tsChain;
    procedure ConnectChains;
    procedure DelSelect;

    procedure Compile(filename:string);
    function BoardBase:tsObject;

    procedure CalcPrioIndices(Calc:boolean=true);

    procedure SetProtect(ent:tsEntity);

    procedure UpdateObjects;

    procedure writeRAW(M:TStream; SelectedOnly:boolean=false; UseHeader:boolean=true; Collect:boolean = false);

    procedure ResolveChains();
  end;

  tsMultiBoard = class (TStringList)
    public
    Layers:array of tsBoard;
    lObjects:array of tsObject;

    Version:integer;

    procedure writeRAW(M:TStream; Collect:boolean);
    procedure UpdateLObjects;
    procedure Compile(filename:string);
  end;

function readRAW(M:TStream; scheme:tsCollection=nil; multi:tsMultiBoard=nil):tsBoard;
function readMultiRAW(M:TStream):tsMultiBoard;

var
  sSchemes:tsSchemes;

// делает идентификатор уникальным
function IncName(name:string):string;
// квадрат расстояния
function LengthPow2(P1,P2:TPoint):integer;
// текст с форматированием
procedure TextRectEx(dc:TCanvas; Rect:TRect; const Text:string; Align:TAlignment; Clip:boolean=false);
function TextRectGet(dc:TCanvas; Rect:TRect; const Text:string; Align:TAlignment):TRect;
//расстояние до отрезка (c)
function distance_Point_to_Segment(P, P0, P1:TPoint):integer;

implementation

uses SCompiler;

resourcestring
  RSSchemaIsUndefined = 'Схема неопределена';
  RSOpenError = 'Ошибка открытия';
  RSLayerRelatedBlock = 'Блок, предназначенный для интеграции слоя';
  RSMainLayer = 'главный';

function IncName(name:string):string;
var
  id,num:string;
  p,ind:integer;
begin
  p:=length(name);
  while (p>1) and (name[p] in ['0'..'9']) do dec(p);
  id:=LeftStr(name,p);
  num:=MidStr(name,p+1,length(name));
  if length(num)>0 then ind:=StrToInt(num)
  else ind:=0;
  result:=id+IntToStr(ind+1);
end;

function LengthPow2(P1,P2:TPoint):integer;
begin
  Result:=(p1.X-p2.X)*(p1.X-p2.X)+(p1.Y-p2.Y)*(p1.Y-p2.Y);
end;

procedure TextRectEx;
var w:integer;
begin
  w:=dc.TextWidth(Text)+2*TextIndentX;
  case Align of
  taLeftJustify:
    begin
      if not Clip then Rect.Right:=Rect.Left+Max(Rect.Right-Rect.Left, w);
      dc.Rectangle(Rect);
      dc.TextRect(Classes.Rect(Rect.Left+1,Rect.Top+1,Rect.Right-1,Rect.Bottom-1), Rect.Left+TextIndentX, Rect.Top+TextIndentY, Text);
    end;
  taRightJustify:
    begin
      Rect.Left:=Rect.Right-Max(Rect.Right-Rect.Left, w);
      dc.Rectangle(Rect);
      dc.TextRect(Classes.Rect(Rect.Left+1,Rect.Top+1,Rect.Right-1,Rect.Bottom-1), Rect.Right-w+TextIndentX, Rect.Top+TextIndentY, Text);
    end;
  taCenter:
    begin
      w:=(Rect.Right+Rect.Left-w) div 2;
      dc.Rectangle(Rect);
      dc.TextRect(Classes.Rect(Rect.Left+1,Rect.Top+1,Rect.Right-1,Rect.Bottom-1), w+TextIndentX, Rect.Top+TextIndentY, Text);
    end;
  end;
end;

function TextRectGet(dc:TCanvas; Rect:TRect; const Text:string; Align:TAlignment):TRect;
var w:integer;
begin
  w:=dc.TextWidth(Text)+2*TextIndentX;
  Result:=Rect;
  case Align of
  taLeftJustify: Result.Right:=Rect.Left+Max(Rect.Right-Rect.Left, w);
  taRightJustify: Result.Left:=Rect.Right-Max(Rect.Right-Rect.Left, w);
  taCenter: //no changes
  end;
end;

function distance_Point_to_Segment(P, P0, P1:TPoint):integer;
// Copyright 2001, softSurfer (www.softsurfer.com)
// This code may be freely used and modified for any purpose
// providing that this copyright notice is included with it.
// SoftSurfer makes no warranty for this code, and cannot be held
// liable for any real or imagined damage resulting from its use.
// Users of this code must verify correctness for their application.
var
  v,w,Pb:TPoint;
  c1,c2:integer;
  b:double;

  function dot(u, v:TPoint):integer;
  begin
    Result:=u.X*v.X+u.Y*v.Y;
  end;

  function d(u, v:TPoint):integer;
  begin
    Result:=Round(Sqrt((u.X-v.X)*(u.X-v.X)+(u.Y-v.Y)*(u.Y-v.Y)));
  end;

begin
  v.X := P1.X-P0.X; v.Y:=P1.Y-P0.Y;
  w.X := P.X-P0.X; w.Y:=P.Y-P0.Y;
  c1:=dot(v,w);
  if c1<=0 then
  begin
    Result:=d(P,P0);
    exit;
  end;
  c2:=dot(v,v);
  if c2<=c1 then
  begin
    Result:=d(P,P1);
    exit;
  end;
  b:=c1/c2;
  Pb.X := P0.X + Round(b*v.X); Pb.Y := P0.Y + Round(b*v.Y);
  Result:=d(P, Pb);
end;

{ tsType }

procedure tsType.LoadScript(ScriptName: string);
begin
  Self.ScriptName:=ScriptName;
  LoadFromFile(GetScriptName(Parent.Name, ScriptName, Parent.SchemePath, stEnum));
end;

procedure tsType.SaveScript(st:TStringList);
begin
  st.AddStrings(Self);
end;

{ tsObject }

constructor tsObject.Create;
begin
  sUses:=nil;
  sGlobal:=nil;
  sCode:=nil;
  sTemplate:=nil;
  sHelp:=nil;
  sPrefix:=nil;
  sPostfix:=nil;
  Parent:=nil;
  Size:=DefaultBlockWidth;
end;

destructor tsObject.Destroy;
begin
  SetLength(Propertyes, 0);
  SetLength(Input, 0);
  SetLength(Output, 0);
  SetLength(InputPars, 0);
  SetLength(OutputPars, 0);
  SetLength(Maps, 0);

  FreeAndNil(sGlobal);
  FreeAndNil(sCode);
  FreeAndNil(sTemplate);
  FreeAndNil(sHelp);
  FreeAndNil(sPrefix);
  FreeAndNil(sPostfix);

  inherited;
end;

procedure tsObject.LoadScript(s:TStringList);
var
  codes:TStringList;
  //s:TStringList;
  code:integer;
  ind:integer;
  line, sub, extra:string;
  p,n:integer;

  function Next(sym:char=','):string;
  begin
    if Length(extra)=0 then
    begin
      result:='';
      exit;
    end;

    result:='\';
    repeat
      Delete(result,Length(result),1);
      if Length(result)>0 then result:=result+sym;
      p:=Pos(sym, extra);
      if p=0 then p:=length(extra)+1;
      result:=result+MidStr(extra,1,p-1);
      extra:=MidStr(extra,p+1,Length(extra));
    until (extra='') or (RightStr(result,1)<>'\');
  end;

  function Prop:tsPropType;
  begin
    sub:=UpperCase(Next);
    if (length(sub)=0) or (sub='S') then result:=ptString
    else if sub='N' then result:=ptNumber
    else if sub='F' then result:=ptFloat
    else if sub='ROW' then result:=ptRow
    else if sub='T' then result:=ptSwitch
    else if sub='C' then result:=ptControl
    else if sub='D' then result:=ptDate
    else result:=ptExtern;
  end;

begin
  // Иниц по умолч.
  //Self.ScriptName:=ScriptName;
  sGlobal:=nil;
  sCode:=nil;
  sTemplate:=nil;
  sPrefix:=nil;
  sPostfix:=nil;

  codes:=TStringList.Create;
  codes.CommaText:=',MAIN,PROPERTY,INPUT,OUTPUT,INPUTPARS,OUTPUTPARS,CODE,TEMPLATE,HELP,MAP,GLOBAL,PREFIX,POSTFIX,USES';

  //s:=TStringList.Create;
  //s.LoadFromFile(GetScriptName(ScriptName, Parent.Name, stObject));
  code:=-1;
  ind:=-1;
  while (ind<s.Count-1) and (code>=-1) do
  begin
    inc(ind);
    line:=s[ind];

    if not (code in [7,8,9,11,12,13]) then
    begin
      if Length(line)=0 then continue;

      case line[1] of
        '[':code:=0;
        '#':continue;
      end;
    end
    else
      if Length(line)>0 then
        if line[1]='[' then code:=0;

    case code of
    0: //поиск раздела
      begin
        sub:=UpperCase(MidStr(line,2,Length(line)-2));
        code:=codes.IndexOf(sub);
      end;

    1: //MAIN
      begin
        p:=pos('=',line);
        if p=0 then
        begin
          if UpperCase(line)='MODULAR' then oType:=totModel
          else if UpperCase(line)='CHOICE' then oType:=totChoice
          else if UpperCase(line)='UNIT' then oType:=totUnit
          else if UpperCase(line)='DEPRECATED' then oType:=totDeprecated
          else if UpperCase(line)='BLOCKIN' then oType:=totBlockIn
          else if UpperCase(line)='BLOCKOUT' then oType:=totBlockOut
          else if UpperCase(line)='CUSTOM' then Custom:=true
          else if UpperCase(line)='USABLE' then oType:=totUsable;
        end
        else
        begin
          sub:=UpperCase(MidStr(line,1,p-1));
          extra:=MidStr(line,p+1,Length(line));
          if sub='TITLE' then ObjectName:=extra
          else
          if sub='GROUP' then GroupName:=extra
          else
          if sub='NAME' then DefaultName:=extra
          else
          if sub='SIZE' then Size:=StrToInt(extra);
        end;

        // добавление входов/выходов по умолчанию
        if not Custom and (oType<>totUsable) then
        begin
          // добавление входа Control
          if not (oType in [totModel,totUnit,totBlockIn,totBlockOut]) then
          begin
            SetLength(Input, 1);
            with Input[0] do
            begin
              Name:='CTRL';
              LabelName:=Name;
              LinkType:=ptControl;
            end;
          end;

          // добавление выхода Control (для объектов choice вручную)
          if not (oType in [totChoice,totUnit,totBlockIn,totBlockOut]) then
          begin
            SetLength(Output, 1);
            with Output[0] do
            begin
              Name:='CTRL';
              LabelName:=Name;
              LinkType:=ptControl;
            end;
          end;
        end;
      end;

    2: //PROPERTY
      begin
        if line='' then continue;
        n:=Length(Propertyes);
        SetLength(Propertyes, n+1);
        with Propertyes[n] do
        begin
          p:=pos('=',line);
          if p=0 then p:=length(line)+1;
          Name:=MidStr(line,1,p-1);
          extra:=MidStr(line,p+1,Length(line));
          // Тип
          PropType:=Prop;
          if PropType=ptExtern then ExtType:=sub;
          // Знач. по умолч.
          Default:=Next;
          // Расшифровка
          LabelName:=Next;
          if Length(LabelName)=0 then LabelName:=Name;
          // Обязательный
          if Default<>'' then Require:=true else Require:=false;
        end;
      end;

    3: //INPUT
      begin
        if line='' then continue;
        n:=Length(Input);
        SetLength(Input, n+1);
        with Input[n] do
        begin
          p:=pos('=',line);
          if p=0 then p:=length(line)+1;
          Name:=MidStr(line,1,p-1);
          extra:=MidStr(line,p+1,Length(line));
          // Тип
          LinkType:=Prop;
          // Симольное имя
          //SymName:=Next;
          // Расшифровка
          LabelName:=Next;
          if Length(LabelName)=0 then LabelName:=Name;
          // Вход для параметров
          Default:=Next='d';
        end;
      end;

    4: //OUTPUT
      begin
        if line='' then continue;
        n:=Length(Output);
        SetLength(Output, n+1);
        with Output[n] do
        begin
          p:=pos('=',line);
          if p=0 then p:=length(line)+1;
          Name:=MidStr(line,1,p-1);
          extra:=MidStr(line,p+1,Length(line));
          // Тип
          LinkType:=Prop;
          // Симольное имя
          SymName:=Next;
          // Расшифровка
          LabelName:=Next;
          if Length(LabelName)=0 then LabelName:=Name;
        end;
      end;

    5: //INPUTPARS
      begin
        if line='' then continue;
        n:=Length(InputPars);
        SetLength(InputPars, n+1);
        with InputPars[n] do
        begin
          p:=pos('=',line);
          if p=0 then p:=length(line)+1;
          Name:=MidStr(line,1,p-1);
          SymName:=MidStr(line,p+1,Length(line));
        end;
      end;

    6: //OUTPUTPARS
      begin
        if line='' then continue;
        n:=Length(OutputPars);
        SetLength(OutputPars, n+1);
        with OutputPars[n] do
        begin
          p:=pos('=',line);
          if p=0 then p:=length(line)+1;
          Name:=MidStr(line,1,p-1);
          SymName:=MidStr(line,p+1,Length(line));
        end;
      end;

    7: //CODE
      begin
        if sCode=nil then sCode:=TStringList.Create;
        sCode.Add(line);
      end;

    8: //TEMPLATE
      begin
        n:=Length(Output);
        if (n=0) and (oType=totModel) then // добавление выхода Control для объектов modular
        begin
          SetLength(Output, 1);
          with Output[0] do
          begin
            Name:='CTRL';
            LabelName:=Name;
            LinkType:=ptControl;
          end;
        end;

        if sTemplate=nil then sTemplate:=TStringList.Create;
        sTemplate.Add(line);
      end;

    9: //HELP
      begin
        if sHelp=nil then sHelp:=TStringList.Create;
        sHelp.Add(line);
      end;

    10: //MAP
      begin
        if line='' then continue;
        n:=Length(Maps);
        SetLength(Maps, n+1);
        with Maps[n] do
        begin
          extra:=line;
          Src:=UpperCase(Next('='));
          Dest:=UpperCase(Next);
          if extra='' then extra:='CTRL';
          for p:=0 to Length(Output)-1 do
            if Output[p].Name=extra then
            begin
              OutInd:=p;
              break;
            end;
        end;
      end;

    11: //GLOBAL
      begin
        if sGlobal=nil then sGlobal:=TStringList.Create;
        sGlobal.Add(line)
      end;

    12: //PREFIX
      begin
        if sPrefix=nil then sPrefix:=TStringList.Create;
        sPrefix.Add(line);
      end;

    13: //POSTFIX
      begin
        if sPostfix=nil then sPostfix:=TStringList.Create;
        sPostfix.Add(line);
      end;

    14: //USES
      begin
        if sUses=nil then sUses:=TStringList.Create;
        sUses.Add(line);
      end;
    end;
  end;

  // fix default inputs
  p:=0;
  while (p<Length(Input)) and (Input[p].LinkType = ptControl) do inc(p);
  if p<Length(Input) then
  begin
    for n:=0 to Length(Input)-1 do
      if Input[n].Default then begin p:=n; break end;
    Input[p].Default:=true;
  end;

  s.Free;
  codes.Free;
end;

procedure tsObject.SaveScript(M:TStream);
var
  st:TStringList;
  i:integer;

  function typename(t:tsPropType;ext:string):string;
  begin
    case t of
      ptNumber:result:='n';
      ptFloat:result:='f';
      ptString:result:='s';
      ptDate:result:='d';
      ptSwitch:result:='t';
      ptRow:result:='row';
      ptControl:result:='c';
      ptExtern:result:=ext;
      else result:='';
    end;
  end;

begin
  st:=TStringList.Create;
  st.Add('[Main]');
  st.Add('Custom');
  case oType of
    totModel:st.Add('Modular');
    totChoice:st.Add('Choice');
    totUnit:st.Add('Unit');
    totDeprecated:st.Add('Deprecated');
    totLayer:st.Add('Layer');
    totBlockIn:st.Add('BlockIn');
    totBlockOut:st.Add('BlockOut');
    totUsable:st.Add('Usable');
  end;
  st.Add('Name='+DefaultName);
  st.Add('Title='+ObjectName);
  st.Add('Group='+GroupName);
  st.Add('Size='+IntToStr(Size));
  if Length(Propertyes)>0 then
  begin
    st.Add('[Property]');
    for i:=0 to High(Propertyes) do
      st.Add(Format('%s=%s,%s,%s', [Propertyes[i].Name,typename(Propertyes[i].PropType, Propertyes[i].ExtType), Propertyes[i].Default, StringReplace(Propertyes[i].LabelName,',','\,',[rfReplaceAll])]));
  end;
  if Length(Input)>0 then
  begin
    st.Add('[Input]');
    for i:=0 to High(Input) do
      st.Add(Format('%s=%s,%s,%s', [Input[i].Name, typename(Input[i].LinkType, ''), Input[i].LabelName, IfThen(Input[i].Default,'d')]));
  end;
  if Length(Output)>0 then
  begin
    st.Add('[Output]');
    for i:=0 to High(Output) do
      st.Add(Format('%s=%s,%s,%s', [Output[i].Name, typename(Output[i].LinkType, ''), Output[i].SymName, Output[i].LabelName]));
  end;
  if Length(InputPars)>0 then
  begin
    st.Add('[InputPars]');
    for i:=0 to High(InputPars) do
      st.Add(Format('%s=%s',[InputPars[i].Name,InputPars[i].SymName]));
  end;
  if Length(OutputPars)>0 then
  begin
    st.Add('[OutputPars]');
    for i:=0 to High(OutputPars) do
      st.Add(Format('%s=%s',[OutputPars[i].Name,OutputPars[i].SymName]));
  end;

  // карты переходов больше не нужны

  if sUses<>nil then
  begin
    st.Add('[Uses]');
    st.AddStrings(sUses);
  end;

  if sGlobal<>nil then
  begin
    st.Add('[Global]');
    st.AddStrings(sGlobal);
  end;
  if sPrefix<>nil then
  begin
    st.Add('[Prefix]');
    st.AddStrings(sPrefix);
  end;
  if sCode<>nil then
  begin
    st.Add('[Code]');
    st.AddStrings(sCode);
  end;
  if sPostfix<>nil then
  begin
    st.Add('[Postfix]');
    st.AddStrings(sPostfix);
  end;
  if sTemplate<>nil then
  begin
    st.Add('[Template]');
    st.AddStrings(sTemplate);
  end;
  if sHelp<>nil then
  begin
    st.Add('[Help]');
    st.AddStrings(sHelp);
  end;

  st.SaveToStream(M);
  st.Free;
end;

function tsObject.Copy:tsObject;
var i:integer;
begin
  Result:=tsObject.Create;
  Result.ScriptName:=ScriptName;
  Result.ObjectName:=ObjectName;
  Result.GroupName:=GroupName;
  Result.DefaultName:=DefaultName;
  Result.oType:=oType;
  Result.DestPath:=DestPath;
  if sUses<>nil then
  begin
    Result.sUses:=TStringList.Create;
    Result.sUses.SetText(sUses.GetText);
  end;
  if sGlobal<>nil then
  begin
    Result.sGlobal:=TStringList.Create;
    Result.sGlobal.SetText(sGlobal.GetText);
  end;
  if sCode<>nil then
  begin
    Result.sCode:=TStringList.Create;
    Result.sCode.SetText(sCode.GetText);
  end;
  if sTemplate<>nil then
  begin
    Result.sTemplate:=TStringList.Create;
    Result.sTemplate.SetText(sTemplate.GetText);
  end;
  if sPrefix<>nil then
  begin
    Result.sPrefix:=TStringList.Create;
    Result.sPrefix.SetText(sPrefix.GetText);
  end;
  if sPostfix<>nil then
  begin
    Result.sPostfix:=TStringList.Create;
    Result.sPostfix.SetText(sPostfix.GetText);
  end;
  if sHelp<>nil then
  begin
    Result.sHelp:=TStringList.Create;
    Result.sHelp.SetText(sHelp.GetText);
  end;
  SetLength(Result.Propertyes, Length(Propertyes));
  for i:=0 to High(Propertyes) do
    Result.Propertyes[i]:=Propertyes[i];
  SetLength(Result.Input, Length(Input));
  for i:=0 to High(Input) do
    Result.Input[i]:=Input[i];
  SetLength(Result.Output, Length(Output));
  for i:=0 to High(Output) do
    Result.Output[i]:=Output[i];
  SetLength(Result.InputPars, Length(InputPars));
  for i:=0 to High(InputPars) do
    Result.InputPars[i]:=InputPars[i];
  SetLength(Result.OutputPars, Length(OutputPars));
  for i:=0 to High(OutputPars) do
    Result.OutputPars[i]:=OutputPars[i];
  SetLength(Result.Maps, Length(Maps));
  for i:=0 to High(Maps) do
    Result.Maps[i]:=Maps[i];
end;

procedure tsObject.LoadScript(M: TStream; Size:integer);
var
  s:TStringList;
  c:char;
  text:string;
begin
  s:=TStringList.Create;
  //s.LoadFromStream(M);
  text:='';
  while M.Position<Size do
  begin
    M.Read(c, 1);
    text:=text+c;
  end;
  s.Text:=text;
  LoadScript(s);
end;

procedure tsObject.LoadScript(ScriptName: string);
var
  s:TStringList;
begin
  s:=TStringList.Create;
  Self.ScriptFileName:=GetScriptName(Parent.Name, ScriptName, Parent.SchemePath, stObject);
  s.LoadFromFile(Self.ScriptFileName);
  Self.ScriptName:=ScriptName;
  LoadScript(s);
end;

{ tsEntity }

constructor tsEntity.Create;
begin
  inherited Create;

  Source:=Src;
  Name:=Src.DefaultName;
  Selected:=false;
  SelInOut:=-1;
end;

destructor tsEntity.Destroy;
begin
  FreeAndNil(PropValues);
  FreeAndNil(OutValues);
  FreeAndNil(OutSymValues);
  FreeAndNil(Comments);

  inherited;
end;

procedure tsEntity.CheckSelect(SR: TRect);
begin
  Selected:=(SR.Left<=Rect.Left * GridX) and (SR.Top<=Rect.Top * GridY) and (SR.Right>=Rect.Right * GridX) and (SR.Bottom>=Rect.Bottom * GridY);
end;

procedure tsEntity.Draw;
var
  i:integer;
  ZRect,R:TRect;
  s:string;
begin
  with dc do
  begin
    Pen.Color:=clBlack;
    Pen.Style:=psSolid;
    if Enabled then
    begin
      if not (Source.oType in [totLayer,totBlockIn,totBlockOut]) then Brush.Color:=$B0B0B0//clWindow;
      //else Brush.Color:=clYellow;
      else if (Source.oType=totBlockIn) and (Source.Output[0].LinkType=ptControl)
        or (Source.oType=totBlockOut) and (Source.Input[0].LinkType=ptControl) then Brush.Color:=$DDDDDD
      else if (Source.oType=totBlockIn) then Brush.Color:=$C080FF
      else if (Source.oType=totBlockOut) then Brush.Color:=$8080FF
      else
        Brush.Color:=RGB(232,235,118);
    end
      else Brush.Color:=$404040;

    ZRect:=Types.Rect(Rect.Left*GridX, Rect.Top*GridY, Rect.Right*GridX, Rect.Bottom*GridY);
    Rectangle(ZRect);

    // Имя
    if (Source.oType=totModel) then Brush.Color:=$80D0D0
    else if (Source.oType=totUnit) then Brush.Color:=$40CC40
    else if (Source.oType=totChoice) then Brush.Color:=$F0A040
    else
     Brush.Color:=$40A0F0;//$008080;//clYellow;
    if not Enabled then Font.Color:=$FFFFFF
    else if Debug then Font.Color:=$FF0040;
    {if not ShowObjectsNames then Font.Size:=GridX*8 div 16
    else Font.Size:=GridX div 2;}
    Font.Size:=FontSize;
    Font.Style:=Font.Style+[fsBold];
    if ShowObjectsNames and (Source.oType<>totLayer) or (Source.oType in [totBlockIn, totBlockOut]) then
      TextRectEx(dc, Classes.Rect(ZRect.Left, ZRect.Top, ZRect.Right, ZRect.Top+GridY), Name, taCenter)
    else
      TextRectEx(dc, Classes.Rect(ZRect.Left, ZRect.Top, ZRect.Right, ZRect.Top+GridY), Source.ObjectName, taLeftJustify, true);
    Font.Size:=FontSize;
    Font.Style:=Font.Style-[fsBold];
    Font.Color:=0;
    // Ввод
    for i:=0 to Length(Source.Input)-1 do
    begin
      if SelInOut=i then
      begin
        Pen.Color:=ColorHighligt;
        Pen.Width:=3;
      end
      else
      begin
        Pen.Color:=clBlack;
        Pen.Width:=1;
      end;

      if Source.Input[i].LinkType=ptControl then
        Brush.Color:=$DDDDDD//$FF80C0
      else if i=ParsInput then
        Brush.Color:=$FF80C0
      else
        Brush.Color:=$C080FF;

      TextRectEx(dc, Types.Rect(ZRect.Left, ZRect.Top+GridY*(i+1), ZRect.Left+GridX, ZRect.Top+GridY*(i+2)), Source.Input[i].Name, taLeftJustify);
    end;
    // Вывод
    for i:=0 to Length(Source.Output)-1 do
    begin
      if Source.Output[i].LinkType=ptControl then
        Brush.Color:=$dDDDDD//$FF80C0//clFuchsia;
      else
        Brush.Color:=$8080FF;//clFuchsia;

      if SelInOut=i+Length(Source.Input) then
      begin
        Pen.Color:=ColorHighligt;
        Pen.Width:=3;
      end
      else
      begin
        Pen.Color:=clBlack;
        Pen.Width:=1;
      end;

      TextRectEx(dc, Types.Rect(ZRect.Right-GridX, ZRect.Top+GridY*(i+1), ZRect.Right, ZRect.Top+GridY*(i+2)), Source.Output[i].Name, taRightJustify);
    end;

    // Рамка
    Pen.Color:=clNone;
    Pen.Width:=3;
    Brush.Color:=clNone;
    Brush.Style:=bsClear;
    if Light then Pen.Color:=ColorHighligt
    else
    if Selected then Pen.Color:=ColorSelected;
    Rectangle(ZRect);

    // признак защиты исходника
    s:='';
    if IsLocal then s:=s+#$71//#$98
    else
      if IsProtected then s:=s+#$CF;
    if s<>'' then
    with ZRect do
    begin
      //Brush.Color:=$A0A0A0;
      Font.Color:=$EEEEEE;//clYellow;
      Font.Name:='Webdings';
      Font.Charset:=SYMBOL_CHARSET;
      Font.Size:=FontSize div 5;
      {R.Left:=(Left+Right) div 2-5;
      R.Right:=R.Left+20;
      R.Top:=Top+17;
      R.Bottom:=Top+32;}
      R.Left:=Right-10*Length(s);
      R.Top:=Top;
      //TextRectEx(dc, R, s, taCenter);
      TextOut(R.Left, R.Top, s);
      Font.Name:='Tahoma';
      Font.Charset:=RUSSIAN_CHARSET;
      Font.Size:=FontSize;

      Font.Color:=0;
    end;

    // индекс
    if PrioIndex>0 then
    with ZRect do
    begin
      Brush.Color:=$A0A0A0;
      Font.Style:=[fsBold];
      Font.Color:=clYellow;

      R.Left:=(Left+Right) div 2-10;
      R.Right:=R.Left+20;
      R.Top:=Bottom-16;
      R.Bottom:=Bottom-1;
      {R.Top:=(Top+GridY+Bottom) div 2-9;
      R.Bottom:=R.Top+16;}
      TextRectEx(dc, R, IntToStr(PrioIndex), taCenter);

      Font.Color:=0;
    end;

    Pen.Width:=1;
  end;
end;

procedure tsEntity.SetRect(SR: TRect);
begin
  // Расчёт Rect от нуля
  Rect:=Types.Rect(SR.Left div GridX, SR.Top div GridY, SR.Left div GridX, SR.Top div GridY);

  // Ширина по умолчанию
  inc(Rect.Right, Max(Source.Size, (SR.Right-SR.Left) div GridX));

  // Отступ для имени
  inc(Rect.Bottom, 1);

  // Отступ для ввода/вывода
  inc(Rect.Bottom, Max(Length(Source.Input), Length(Source.Output)));
end;

function tsEntity.CheckOut(dc:TCanvas; Pos: TPoint): integer;
var
  n:integer;
  R:TRect;
begin
  Result:=-1;
  for n:=0 to Length(Source.Output)-1 do
  begin
    R.Top:=(Rect.Top+n+1)*GridY;
    R.Bottom:=(Rect.Top+n+2)*GridY;
    R.Right:=Rect.Right*GridX;
    R.Left:=(Rect.Right-1)*GridX;

    if PtInRect(TextRectGet(dc,R,Source.Output[n].Name,taRightJustify), Pos) then
    begin
      Result:=n;
      SelInOut:=Length(Source.Input)+n;
      break;
    end;
  end;
end;

function tsEntity.CheckIn(dc:TCanvas; Pos: TPoint): integer;
var
  n:integer;
  R:TRect;
begin
  Result:=-1;
  for n:=0 to Length(Source.Input)-1 do
  begin
    R.Top:=(Rect.Top+1+n)*GridY;
    R.Bottom:=(Rect.Top+n+2)*GridY;
    R.Left:=Rect.Left*GridX;
    R.Right:=(Rect.Left+1)*GridX;

    if PtInRect(TextRectGet(dc,R,Source.Input[n].Name,taLeftJustify), Pos) then
    begin
      Result:=n;
      SelInOut:=n;
      break;
    end;
  end;
end;

function tsEntity.CalcOut: TPoint;
begin
  Result:=Point(Rect.Left*GridX, Rect.Top*GridY);
  if SelInOut<0 then exit;
  if SelInOut<Length(Source.Input) then
    Result:=Point(Rect.Left*GridX, (Rect.Top+1+SelInOut)*GridY+GridY div 2)
  else
    Result:=Point(Rect.Right*GridX, (Rect.Top+1+SelInOut-Length(Source.Input))*GridY+GridY div 2);
end;

{ tsCollection }

procedure tsCollection.ConnectTypes;
var
  n,k,i:integer;
  st:TStringList;
begin
  st:=TStringList.Create;
  for n:=0 to Length(Types)-1 do
    st.Add(UpperCase(Types[n].ScriptName));

  for n:=0 to Length(Objects)-1 do
    for k:=0 to Length(Objects[n].Propertyes)-1 do
      with Objects[n].Propertyes[k] do
        if PropType=ptExtern then
        //add custom directory patch
          //ExtValues:=Types[st.IndexOf(ExtType)];
          if st.IndexOf(ExtType)>=0 then
            ExtValues:=Types[st.IndexOf(ExtType)]
          else
          for i:=0 to st.Count-1 do
            if Pos('\', st[i])>0 then
              if Copy(st[i], Pos('\', st[i])+1, 10000)=ExtType then
              begin
                ExtValues:=Types[i];
                break;
              end;

  st.Free;
end;

constructor tsCollection.Create;

  procedure LoadDir(path:string);
  var
    sr:TSearchRec;
    name,ext:string;
    p:integer;
    n:integer;
  begin
    if FindFirst(ScriptPath+scheme_path+'\'+path+'*.*', faAnyFile, sr)=0 then
    repeat
      if sr.Name[1]='.' then Continue;
      if sr.Attr and faDirectory>0 then
      begin
        LoadDir(path+ExtractFileName(sr.Name)+'\');
        Continue;
      end;

      name:=ExtractFileName(sr.Name);
      name:=LeftStr(name, length(name)-2);
      ext:=LowerCase(ExtractFileExt(sr.Name));

      if ext='.o' then
      begin
        // check scheme postfix
        p:=Pos('.', name);
        if p>0 then
        begin
          name:=LeftStr(name, p-1);
          ext:=UpperCase(Copy(name, p+1, Length(name)));
          if ext<>scheme then continue;
        end;

        n:=Length(Objects);
        SetLength(Objects, n+1);
        Objects[n]:=tsObject.Create;
        Objects[n].Parent:=Self;
        Objects[n].LoadScript(path+name);

        Add(Objects[n].GroupName+'\'+Objects[n].ObjectName);
      end
      else
      if ext='.e' then
      begin
        n:=Length(Types);
        SetLength(Types, n+1);
        Types[n]:=tsType.Create;
        Types[n].Parent:=Self;
        Types[n].LoadScript(path+name);
      end;
    until FindNext(sr)<>0;
  end;

begin
  inherited Create;
  if Scheme<>'' then
  begin
    Self.Name:=scheme;
    Self.SchemePath:=scheme_path;
    LoadDir('');

    Env:=TStringList.Create;

    ConnectTypes;
  end;
end;

destructor tsCollection.Destroy;
var n:integer;
begin
  for n:=0 to Length(Objects)-1 do
    Objects[n].Free;
  SetLength(Objects, 0);
  for n:=0 to Length(Types)-1 do
    Types[n].Free;
  SetLength(Types, 0);
  Env.Free;

  inherited;
end;

function tsCollection.DecodeCmd(filename, cmd:string): string;
var
  p:integer;
  log,exe,path:string;
begin
  Result:=Env.Values[cmd];

  Result:=StringReplace(Result, '~N~', filename, [rfReplaceAll]);

  p:=Pos('.', ReverseString(filename));
  log:=LeftStr(filename, Length(filename)-p)+'.log';
  Result:=StringReplace(Result, '~L~', log, [rfReplaceAll]);

  exe:=LeftStr(filename, Length(filename)-p)+'.'+Env.Values['BinExt'];
  Result:=StringReplace(Result, '~X~', exe, [rfReplaceAll]);

  p:=Pos(Env.Values['PathPostfix'], filename);
  path:=LeftStr(filename, p+Length(Env.Values['PathPostfix'])-1);
  Result:=StringReplace(Result, '~P~', path, [rfReplaceAll]);

  Result:=Result+'';
end;

function tsCollection.IndexOfScript;
var i:integer;
begin
  Result:=-1;
  for i:=0 to Length(Objects)-1 do
  if Objects[i].ScriptName=sname then
  begin
    Result:=i;
    exit;
  end;
end;

{ tsChain }

destructor tsChain.Destroy;
begin
  SetLength(Points, 0);
  inherited;
end;

procedure tsChain.CheckSelect(SR: TRect);
begin
  Selected:=PtInRect(SR,Points[0]) and PtInRect(SR, Points[Length(Points)-1]);
end;

procedure tsChain.Connect(Board: tsBoard);
begin
  SetLength(Points, 2);
  with Points[0], Left.Obj do
  begin
    X:=Rect.Right*GridX;
    Y:=(Rect.Top+1+Left.InOutInd)*GridY+(GridY div 2);
  end;
  with Points[1], Right.Obj do
  begin
    X:=Rect.Left*GridX;
    Y:=(Rect.Top+1+Right.InOutInd)*GridY+(GridY div 2);
  end;
end;

procedure tsChain.Draw(dc: TCanvas; Light:boolean=false);
var
  n,c:integer;
  dirs:TByteDynArray;
  dist:TWordDynArray;
  dir:byte;
begin
  with dc do
  begin
    Pen.Width:=2;
    if Light then Pen.Color:=ColorHighligt
    else
    if Selected then Pen.Color:=ColorSelected
    else
    if Left.Obj.Source.Output[Left.InOutInd].LinkType=ptControl then
    begin
      Pen.Color:=clBlack;//$808080;
    end
    else
    Pen.Color:=Color;//clBlack;

    {with Points[0] do
      Ellipse(X-3, Y-3, X+3, Y+3);}

    {//Pen.Color:=clRed;
    MoveTo(Points[0].X, Points[0].Y);
    for n:=1 to Length(Points)-1 do
      LineTo(Points[n].X, Points[n].Y);
    //Pen.Color:=clBlack;}

    SetLength(dirs, Length(Points)-1);
    SetLength(dist, Length(Points)-1);

    // 1..4 right, up, left, down
    for n:=0 to Length(Points)-2 do
    begin
      // определить текущее направление
      if Points[n].X = Points[n+1].X then
      begin
        Dist[n]:=Abs(Points[n+1].Y-Points[n].Y);
        if Points[n+1].Y > Points[n].Y then Dir:=4
        else Dir:=2;
      end
      else if Points[n].Y = Points[n+1].Y then
      begin
        Dist[n]:=Abs(Points[n+1].X-Points[n].X);
        if Points[n+1].X > Points[n].X then Dir:=1
        else Dir:=3;
      end
      else
      begin
        Dir:=0;
        Dist[n]:=0;
      end;

      Dirs[n]:=Dir;
    end;

    // выполняем движение
    {GridX:=GridX div 2;
    GridY:=GridY div 2;}
    MoveTo(Points[0].X, Points[0].Y);
    for n:=0 to Length(dirs)-1 do
    with Points[n+1] do
    begin
      if (Dirs[n]=Dirs[n+1]) or (Dirs[n+1]=0) then
      begin
        LineTo(X, Y);
      end
      else
      if Dirs[n]=5 then continue
      else
      begin
        if (dist[n]>GridX div 2) and (dist[n+1]>GridX div 2) then c:=2
        else c:=4;

        case Dirs[n] of
        1: LineTo(X-GridX div c, Y);
        2: LineTo(X, Y+GridY div c);
        3: LineTo(X+GridX div c, Y);
        4: LineTo(X, Y-GridY div c);
        end;

        if c=2 then
        begin
          if (Dirs[n]=1) and (Dirs[n+1]=4) or (Dirs[n]=2) and (Dirs[n+1]=3) then //r-d, u-l
            Arc(X-GridX, Y, X, Y+GridY, X, Y+GridY div 2, X-GridX div 2, Y)

          else if (Dirs[n]=1) and (Dirs[n+1]=2) or (Dirs[n]=4) and (Dirs[n+1]=3) then //r-u, d-l
            Arc(X-GridX, Y-GridY, X, Y, X-GridX div 2, Y, X, Y-GridY div 2)

          else if (Dirs[n]=4) and (Dirs[n+1]=1) or (Dirs[n]=3) and (Dirs[n+1]=2) then //d-r, l-u
            Arc(X, Y-GridY, X+GridX, Y, X, Y-GridY div 2, X+GridX div 2, Y)

          else if (Dirs[n]=2) and (Dirs[n+1]=1) or (Dirs[n]=3) and (Dirs[n+1]=4) then //u-r, l-d
            Arc(X, Y, X+GridX, Y+GridY, X+GridX div 2, Y, X, Y+GridY div 2);
        end
        else
        begin
          if (Dirs[n]=1) and (Dirs[n+1]=4) or (Dirs[n]=2) and (Dirs[n+1]=3) then //r-d, u-l
          begin
            MoveTo(X, Y+GridY div c);
            LineTo(X-GridX div c, Y);
          end
          else if (Dirs[n]=1) and (Dirs[n+1]=2) or (Dirs[n]=4) and (Dirs[n+1]=3) then //r-u, d-l
          begin
            MoveTo(X-GridX div c, Y);
            LineTo(X, Y-GridY div c);
          end
          else if (Dirs[n]=4) and (Dirs[n+1]=1) or (Dirs[n]=3) and (Dirs[n+1]=2) then //d-r, l-u
          begin
            MoveTo(X, Y-GridY div c);
            LineTo(X+GridX div c, Y);
          end
          else if (Dirs[n]=2) and (Dirs[n+1]=1) or (Dirs[n]=3) and (Dirs[n+1]=4) then //u-r, l-d
          begin
            MoveTo(X+GridX div c, Y);
            LineTo(X, Y+GridY div c);
          end
        end;

        case Dirs[n+1] of
        1: MoveTo(X+GridX div c, Y);
        2: MoveTo(X, Y-GridY div c);
        3: MoveTo(X-GridX div c, Y);
        4: MoveTo(X, Y+GridY div c);
        end;

      end;
    end;

    with Points[Length(Points)-2] do
      MoveTo(X, Y);
    with Points[Length(Points)-1] do
      LineTo(X, Y);

    SetLength(Dirs, 0);
    SetLength(Dist, 0);

    {GridX:=GridX*2;
    GridY:=GridY*2;}

    Brush.Style:=bsSolid;
    with Points[0] do
      Polygon([Point(X-3, Y), Point(X, Y-3), Point(X+3, Y), Point(X, Y+3)]);

    with Points[Length(Points)-1] do
      Ellipse(X-3, Y-3, X+3, Y+3);

    Pen.Width:=1;
  end;
end;

function tsChain.PtOnChain(Pos: TPoint): boolean;
var n:integer;
begin
  //Result:=LengthPow2(Points[0],Pos)*LengthPow2(Points[1],Pos) div LengthPow2(Points[0], Points[1])<=LineDistance;
  Result:=false;
  for n:=0 to Length(Points)-2 do
    Result:=Result or (distance_Point_to_Segment(Pos, Points[n], Points[n+1]) <= LineDistance);
end;

{ tsBoard }
constructor tsBoard.Create;
begin
  Route:=TRoutePlanner.Create;
  sLocal:=tsCollection.Create('','');
  Version:=0;
end;

destructor tsBoard.Destroy;
var n:integer;
begin
  Route.Free;

  for n:=0 to Length(Entityes)-1 do
    Entityes[n].Free;
  SetLength(Entityes, 0);

  for n:=0 to Length(Chains)-1 do
    Chains[n].Free;
  SetLength(Chains, 0);

  inherited;
end;

procedure tsBoard.CheckSelect(SR: TRect);
var n:integer;
begin
  for n:=0 to Length(Entityes)-1 do
    Entityes[n].CheckSelect(SR);
  for n:=0 to Length(Chains)-1 do
    Chains[n].CheckSelect(SR);
end;

procedure tsBoard.Repaint(dc: TCanvas);
var n:integer;
begin
  for n:=0 to Length(Entityes)-1 do
    Entityes[n].Draw(dc);
  for n:=0 to Length(Chains)-1 do
    if not Chains[n].Lost then
      Chains[n].Draw(dc);
end;

procedure tsBoard.writeRAW(M: TStream; SelectedOnly:boolean=false; UseHeader:boolean=true; Collect:boolean=false);
var
  n,k,p:integer;
  st:TStringList;
  line:string;
  enc:TIdEncoderMIME;
  UsesSaved:TStringList;

  procedure saveObject(o:tsObject);
  var
    comp:TCompressionStream;
    datas:TMemoryStream;
    size:longint;
  begin
    st.Add('//// '+o.ScriptName+'.o');
    datas:=TMemoryStream.Create;
    datas.Position:=4;
    comp:=TCompressionStream.Create(ZLib.clDefault, datas);
    o.SaveScript(comp);
    size:=comp.Position;
    comp.Free;

    datas.Position:=0;
    datas.Write(size, 4);
    datas.Position:=0;
    st.Add(enc.Encode(datas));
    datas.Free;
  end;

  procedure saveUses(sUses:TStringList);
  var k:integer;
  begin
    if sUses<>nil then
    for k:=0 to sUses.Count-1 do
    begin
      line:=Entityes[n].Source.sUses[k];
      if (line<>'') and (UsesSaved.IndexOf(line)=-1) then
      begin
        p:=sCollection.IndexOfScript(line);
        if p>=0 then
        begin
          UsesSaved.Add(line);
          saveObject(sCollection.Objects[p]);
          saveUses(sCollection.Objects[p].sUses);
        end;
      end;
    end;
  end;

begin
  if SelectedOnly then
  begin
    // необходимо оставить только связи выделенных объектов
    for n:=0 to High(Chains) do
      Chains[n].Selected:=Chains[n].Left.Obj.Selected and Chains[n].Right.Obj.Selected;
  end;

  st:=TStringList.Create;
  if UseHeader then
  begin
    // Версия
    st.Add('V3');
    // Заголовок
    st.Add(sCollection.Name);
    st.Add('<COMMON>');
    st.Add('Version='+IntToStr(Version));
  end;
  // Блоки
  st.Add('<BLOX>');
  for n:=0 to Length(Entityes)-1 do
  with Entityes[n] do
  begin
    if SelectedOnly and not Selected then Continue;
    // Запись базы
    line:=Name+'='+IfThen(IsProtected,'!')+Source.ScriptName+','+IntToStr(ParsInput)+','+BoolToStr(Enabled,true);
    if ObjInput<>nil then line:=line + ',' + ObjInput.Name;
    if Debug then line:=line + '*';
    st.Add(line);
    // Запись атрибутов
    for k:=0 to Length(Source.Propertyes)-1 do
    if PropValues[k]<>Source.Propertyes[k].Default then
      st.Add(Source.Propertyes[k].Name+'='+PropValues[k]);
    // Запись координат
    st.Add(Format('(%d,%d,%d,%d)',[Rect.Left,Rect.Top,Rect.Right,Rect.Bottom]));
    st.AddStrings(Comments);
    st.Add('-');
  end;

  // Связи
  st.Add('<LINX>');
  for n:=0 to Length(Chains)-1 do
  with Chains[n] do
  if SelectedOnly then
  begin
    if not Selected or not Left.Obj.Selected or not Right.Obj.Selected then Continue
    else
      st.Add(Format('%s.%s>%s.%s,%.6x', [Left.Obj.Name, Left.Obj.Source.Output[Left.InOutInd].Name, Right.Obj.Name, Right.Obj.Source.Input[Right.InOutInd].Name, Color]));
  end
  else if not Lost then
    st.Add(Format('%s.%s>%s.%s,%.6x', [Left.Obj.Name, Left.Obj.Source.Output[Left.InOutInd].Name, Right.Obj.Name, Right.Obj.Source.Input[Right.InOutInd].Name, Color]));

  // запись всех объектов
  for n:=0 to sCollection.Count-1 do
    sCollection.Objects[n].Saved:=false;
  for n:=0 to sLocal.Count-1 do
    sLocal.Objects[n].Saved:=false;
  for n:=0 to High(sCollection.Types) do
    sCollection.Types[n].Saved:=false;
  for n:=0 to High(sLocal.Types) do
    sLocal.Types[n].Saved:=false;

  st.Add('<TOUCH>');
  UsesSaved:=TStringList.Create;
  enc:=TIdEncoderMIME.Create(nil);
  for n:=0 to High(Entityes) do
  if not Entityes[n].Source.Saved and (Entityes[n].Source.oType<>totLayer) then
  if Collect or Entityes[n].IsProtected then
  begin
    Entityes[n].Source.Saved:=true;
    saveObject(Entityes[n].Source);

    for k:=0 to High(Entityes[n].Source.Propertyes) do
      if (Entityes[n].Source.Propertyes[k].PropType = ptExtern)
      and (Entityes[n].Source.Propertyes[k].ExtValues<>nil)
      and not Entityes[n].Source.Propertyes[k].ExtValues.Saved then
      begin
        st.Add('//// '+Entityes[n].Source.Propertyes[k].ExtValues.ScriptName+'.e');
        Entityes[n].Source.Propertyes[k].ExtValues.Saved:=true;
        Entityes[n].Source.Propertyes[k].ExtValues.SaveScript(st);
      end;

    // выгрузка используемых компонент
    saveUses(Entityes[n].Source.sUses);
  end;
  enc.Free;
  //if

  st.SaveToStream(M);
  //c:=#0;
  //M.Write(c, 1);
end;

procedure tsMultiBoard.writeRAW(M: TStream; Collect:boolean);
var
  i:integer;
  st:TStringList;
  s:string;
begin
  st:=TStringList.Create;
  st.Add('CodeGen3');
  st.Add(Layers[0].sCollection.Name);
  st.Add('<COMMON>');
  st.Add('Version='+IntToStr(Version));
  st.Add('<LAYERS>');
  st.AddStrings(Self);
  st.SaveToStream(M);
  st.Free;
  for i:=0 to Count-1 do
  begin
    s:='---- '+Strings[i]+#13#10;
    M.Write(s[1], Length(s));
    Layers[i].writeRAW(M, false, false, Collect);
  end;
end;

function readRAW(M: TStream; scheme:tsCollection=nil; multi:tsMultiBoard=nil):tsBoard;
var
  ts:tsBoard;
  ent:tsEntity;
  ind,code,n,k,i:integer;
  s,sub,name,ms:string;
  strs:TStringList;
  found:boolean;
  tmpChain:tsChain;
  ver:integer;
  prot:boolean;
  decode:TIdDecoderMIME;
  decomp:TDecompressionStream;
  datas:TMemoryStream;
  tp:tsType;

  function Next(sym:string='='):string;
  var p:integer;
  begin
    p:=Pos(sym, s);
    if p=0 then p:=length(s)+1;
    result:=MidStr(s,1,p-1);
    s:=MidStr(s,p+1,Length(s));
  end;

  procedure PreloadLocal;
  var
    ind:integer;
    bsize:longint;
  begin
    ind:=3;
    found:=false;
    while ind<strs.Count do
    begin
      if strs[ind]='<TOUCH>' then
      begin
        found:=true;
        break;
      end;
      inc(ind);
    end;

    if not found then exit;
    inc(ind);
    if ind=strs.Count then exit;
    s:=strs[ind];
    inc(ind);

    // считывание исходников
    decode:=TIdDecoderMIME.Create(nil);
    while (LeftStr(s, 4)='////') and (ind<strs.Count) do
    begin
      if RightStr(s, 1)='e' then // загрузка типа
      begin
        SetLength(ts.sLocal.Types, Length(ts.sLocal.Types)+1);
        ts.sLocal.Types[Length(ts.sLocal.Types)-1]:=tsType.Create;
        tp:=ts.sLocal.Types[Length(ts.sLocal.Types)-1];
        tp.ScriptName:=MidStr(s, 6, Length(s)-5-2);
        tp.Parent:=ts.sLocal;
        repeat
          tp.Add(strs[ind]);
          inc(ind);
          if ind<strs.Count then s:=strs[ind];
        until (LeftStr(s, 4)='////') or (ind=strs.Count);
        inc(ind);
      end
      else // загрузка объекта
      begin
        SetLength(ts.sLocal.Objects, Length(ts.sLocal.Objects)+1);
        ts.sLocal.Objects[Length(ts.sLocal.Objects)-1]:=tsObject.Create;
        ts.sLocal.Objects[Length(ts.sLocal.Objects)-1].ScriptName:=MidStr(s, 6, Length(s)-5-2);
        ts.sLocal.Objects[Length(ts.sLocal.Objects)-1].Parent:=ts.sLocal;
        //ms:='';
        //repeat
          ms:=strs[ind];
          inc(ind);
          if ind<strs.Count then s:=strs[ind];
        //until (LeftStr(s, 4)='////') or (ind=strs.Count);
        inc(ind);
        datas:=TMemoryStream.Create;
        decode.DecodeToStream(ms, datas);
        datas.Position:=0;
        datas.Read(bsize, 4);
        decomp:=TDecompressionStream.Create(datas);
        //decomp.Position:=0;
        //decomp.Seek(0, soFromBeginning);
        with ts.sLocal.Objects[Length(ts.sLocal.Objects)-1] do
        begin
          LoadScript(decomp, bsize);
          ts.sLocal.Add(GroupName+'\'+ObjectName);
        end;
        decomp.Free;
        datas.Free;
      end;
    end;
    ts.sLocal.ConnectTypes;
    decode.Free;
  end;

begin
  ts:=tsBoard.Create;
  tmpChain:=tsChain.Create;

  M.Position:=0;
  strs:=TStringList.Create;
  strs.LoadFromStream(M);

  if scheme=nil then
  begin
    s:=strs[0];
    if s = 'V3' then
    begin
      ver:=3;
      s:=strs[1];
      ind:=2;
    end
    else
    begin
      ver:=0;
      ind:=1;
    end;

    for n:=0 to sSchemes.Count-1 do
      if sSchemes.Scheme[n].Name = s then
      begin
        ts.sCollection:=sSchemes.Scheme[n];
        break;
      end;
  end
  else
  begin
    ind:=0;
    ts.sCollection:=scheme;
    ver:=3;
  end;

  PreloadLocal;

  code:=-1;
  while ind<strs.Count do
  begin
    s:=strs[ind];
    inc(ind);
    if length(s)=0 then continue;
    if s[1]='<' then code:=0;
    if (LeftStr(s,4)='----') or (LeftStr(s,4)='////') then break;
    case code of
    0:
      if s='<COMMON>' then code:=3
      else
      if s='<BLOX>' then
      begin
        code:=1;
        if ver=0 then ver:=1;
      end
      else
      if s='<BLOX2>' then
      begin
        code:=1;
        if ver=0 then ver:=2;
      end
      else if s='<LINX>' then code:=2
      else if s='<TOUCH>' then break;
    3:begin
        sub:=next;
        if UpperCase(sub)='VERSION' then ts.Version:=StrToInt(s);
      end;
    1:begin
        sub:=next;
        name:=Next(',');
        found:=false;
        prot:=false;
        i:=0;
        if ver<3 then
        begin
          for n:=0 to ts.sCollection.Count-1 do
            if ts.sCollection.Objects[n].ScriptName=sub then begin found:=true; break; end;
          if not found then // add custom directory patch
            for n:=0 to ts.sCollection.Count-1 do
            begin
              k:=pos('\', ts.sCollection.Objects[n].ScriptName);
              if k>0 then
                if Copy(ts.sCollection.Objects[n].ScriptName,k+1,10000)=sub then begin found:=true; break; end;
            end;
        end
        else
        begin
          if name[1]='!' then
          begin
            prot:=true;
            name:=MidStr(name, 2, Length(name));
          end;
          for n:=0 to ts.sLocal.Count-1 do
            if ts.sLocal.Objects[n].ScriptName=name then begin found:=true; i:=2; break; end;
          if not found then
          for n:=0 to ts.sCollection.Count-1 do
            if ts.sCollection.Objects[n].ScriptName=name then begin found:=true; i:=0; break; end;
          name:=sub;
          if not found and (multi<>nil) then
          begin
            for n:=0 to Length(multi.lObjects)-1 do
              if multi.lObjects[n].ScriptName=name then begin found:=true; i:=1; break; end;
          end;
        end;
        if not found then begin code:=14; continue; end;
        if i=0 then
          ent:=ts.AddEntity(ts.sCollection.Objects[n])
        else if i=1 then
          ent:=ts.AddEntity(multi.lObjects[n])
        else if i=2 then
          ent:=ts.AddEntity(ts.sLocal.Objects[n]);
        ent.IsProtected:=prot;
        ent.Name:=name;
        sub:=Next(',');
        if sub<>'' then ent.ParsInput:=StrToInt(sub)
        else ent.ParsInput:=1;

        if RightStr(s,1)='*' then
        begin
          ent.Debug:=true;
          Delete(s, Length(s), 1);
        end;

        sub:=Next(',');
        if sub<>'' then ent.Enabled:=StrToBool(sub);

        ent.poststring:=s;
        code:=11;
      end;
    11:with ent do
      begin
        if s[1]='(' then
        begin
          code:=12;
          dec(ind);
          continue;
        end;
        sub:=UpperCase(Next);
        for i:=0 to Length(Source.Propertyes)-1 do
          if UpperCase(Source.Propertyes[i].Name)=sub then
             PropValues[i]:=s;
      end;
    12:with ent do
      begin
        s:=MidStr(s,2,Length(s));
        if ver=1 then
        begin
          Rect.Left:=StrToInt(Next(',')) div 16;
          Rect.Top:=StrToInt(Next(',')) div 16;
          Rect.Right:=StrToInt(Next(',')) div 16;
          Rect.Bottom:=StrToInt(Next(')')) div 16;
        end
        else
        begin
          Rect.Left:=StrToInt(Next(','));
          Rect.Top:=StrToInt(Next(','));
          Rect.Right:=StrToInt(Next(','));
          Rect.Bottom:=StrToInt(Next(')'));
        end;
        code:=13;
      end;

    13:with ent do
      begin
        if s='-' then code:=1
        else
          Comments.Add(s);
      end;

    14: if s='-' then code:=1;

    2:begin
        with tmpChain do
        begin
          Left.Obj:=nil;
          Left.InOutInd:=-1;
          Right.Obj:=nil;
          Right.InOutInd:=-1;

          sub:=Next('.');
          found:=false;
          for i:=0 to Length(ts.Entityes)-1 do
            if ts.Entityes[i].Name=sub then begin found:=true; break; end;
          if found then
          begin
            Left.Obj:=ts.Entityes[i];
            sub:=UpperCase(Next('>'));
            found:=false;
            for k:=0 to Length(ts.Entityes[i].Source.Output)-1 do
              if UpperCase(ts.Entityes[i].Source.Output[k].Name)=sub then begin found:=true; break; end;
            if found then Left.InOutInd:=k
            else Left.ResolveName:=sub;
          end;

          sub:=Next('.');
          found:=false;
          for i:=0 to Length(ts.Entityes)-1 do
            if ts.Entityes[i].Name=sub then begin found:=true; break; end;
          if found then
          begin
            Right.Obj:=ts.Entityes[i];
            sub:=UpperCase(Next(','));
            found:=false;
            for k:=0 to Length(ts.Entityes[i].Source.Input)-1 do
              if UpperCase(ts.Entityes[i].Source.Input[k].Name)=sub then begin found:=true; break; end;
            if found then Right.InOutInd:=k
            else Right.ResolveName:=sub;
          end;

          if multi=nil then
          begin
            if (Left.Obj=nil) or (Left.InOutInd=-1) or (Right.Obj=nil) or (Right.InOutInd=-1) then
              Continue;

            if (Right.InOutInd = Right.Obj.ParsInput) and (Right.Obj.ObjInput=nil) then
              Right.Obj.ObjInput:=Left.Obj;
          end
          else
          begin
            if (Left.Obj=nil) or (Right.Obj=nil) then
              Continue
            else
            if (Right.InOutInd = Right.Obj.ParsInput) and (Right.Obj.ObjInput=nil) then
              Right.Obj.ObjInput:=Left.Obj;
          end;
        end;
        n:=Length(ts.Chains);
        SetLength(ts.Chains, n+1);
        ts.Chains[n]:=tsChain.Create;
        with ts.Chains[n] do
        begin
          Left:=tmpChain.Left;
          Right:=tmpChain.Right;
          if s='' then Color:=clBlack
          else Color:=HexToInt(s);
        end;
      end;
    end;
  end;

  // отметка признака локальности
  for i:=0 to High(ts.Entityes) do
   for k:=0 to High(ts.sLocal.Objects) do
   begin
     if ts.Entityes[i].Source.ScriptName = ts.sLocal.Objects[k].ScriptName then
     begin
      ts.Entityes[i].IsLocal:=true;
      ts.Entityes[i].Source:=ts.sLocal.Objects[k];
      break;
     end;
   end;

  // попытка воссоединить цепи при по локальным исходникам
  //if scheme=nil then ts.ResolveChains;

  // поиск источников данных
  for i:=0 to Length(ts.Entityes)-1 do
  if ts.Entityes[i].poststring<>'' then
  begin
    found:=false;
    for k:=0 to Length(ts.Entityes)-1 do
      if ts.Entityes[k].Name = ts.Entityes[i].poststring then
      begin
        ts.Entityes[i].ObjInput:=ts.Entityes[k];
        found:=true;
        break;
      end;
  end;

  strs.Free;
  tmpChain.Free;
  ts.ConnectChains;
  Result:=ts;
end;

function readMultiRAW(M:TStream):tsMultiBoard;
var
  n, code:integer;
  M2:TMemoryStream;
  st:TStringList;
  ts:tsMultiBoard;
  s:string;
  scheme:tsCollection;

  function Next(sym:string='='):string;
  var p:integer;
  begin
    p:=Pos(sym, s);
    if p=0 then p:=length(s)+1;
    result:=MidStr(s,1,p-1);
    s:=MidStr(s,p+1,Length(s));
  end;

  procedure GetChunk;
  var
    c:char;
    cnt:integer;
    pos:integer;
  begin
    pos:=M.Position;
    repeat
      repeat
        M.Read(c, 1);
      until (c='-') or (M.Position=M.Size);
      cnt:=0;
      while (c='-') and (M.Position<M.Size) do
      begin
        inc(cnt);
        M.Read(c, 1);
      end;
    until (cnt=4) or (M.Position=M.Size);
    cnt:=M.Position-pos;
    M.Position:=pos;
    M2.SetSize(0);
    M2.CopyFrom(M, cnt);
    M2.Position:=0;
  end;

  procedure ResolveSources;
  var
    i,k,n,l:integer;
    found:boolean;
  begin
    for l:=0 to High(ts.Layers) do
      for i:=0 to High(ts.Layers[l].Entityes) do
      if (ts.Layers[l].Entityes[i].ObjInput=nil) and (ts.Layers[l].Entityes[i].poststring<>'') then
      begin
        for n:=0 to High(ts.Layers) do
        begin
          for k:=0 to Length(ts.Layers[n].Entityes)-1 do
            if ts.Layers[n].Entityes[k].Name = ts.Layers[l].Entityes[i].poststring then
            begin
              ts.Layers[l].Entityes[i].ObjInput:=ts.Layers[n].Entityes[k];
              found:=true;
              break;
            end;
          if found then break;
        end;
      end;
  end;

begin
  M2:=TMemoryStream.Create;
  M.Position:=0;
  GetChunk;
  st:=TStringList.Create;
  st.LoadFromStream(M2);

  ts:=tsMultiBoard.Create;

  // старая версия
  if st[0]<>'CodeGen3' then
  begin
    ts.Add(RSMainLayer);
    SetLength(ts.Layers, 1);
    ts.Layers[0]:=readRAW(M);
    Result:=ts;
  end
  else
  // новая версия
  begin
    result:=nil;
    s:=st[1];
    scheme:=nil;
    for n:=0 to sSchemes.Count-1 do
      if sSchemes.Scheme[n].Name = s then
      begin
        scheme:=sSchemes.Scheme[n];
        break;
      end;

    if scheme=nil then
    begin
      MessageBox(0, PChar(RSSchemaIsUndefined), PChar(RSOpenError), MB_ICONERROR);
      exit;
    end;

    n:=2; code:=0;
    while n<st.Count do
    begin
      s:=st[n];
      inc(n);
      if s='<LAYERS>' then
      begin
        code:=1;
        Continue;
      end
      else
      if s='<COMMON>' then
      begin
        if UpperCase(next)='VERSION' then ts.Version:=StrToInt(s);
      end;

      if LeftStr(s, 4)='----' then break;

      if code=1 then ts.Add(s);
    end;

    SetLength(ts.Layers, ts.Count);
    for n:=0 to ts.Count-1 do
      ts.Layers[n]:=nil;

    ts.UpdateLObjects;

    for n:=0 to ts.Count-1 do
    begin
      GetChunk();
      ts.Layers[n]:=readRAW(M2, scheme, ts);
      ts.Layers[n].Host:=ts;
    end;

    // поиск источников данных
    ResolveSources;

    ts.UpdateLObjects;

    // воссоединение с блоками слоёв
    for n:=0 to ts.Count-1 do
      ts.Layers[n].ResolveChains;

    Result:=ts;
  end;

  st.Free;
  M2.Free;
end;

procedure tsMultiBoard.UpdateLObjects;
var
  i, k:integer;
  cin, cout:integer;
begin
  if Length(lObjects)=0 then
  begin
    SetLength(lObjects, Count-1);
    for i:=1 to Count-1 do
    begin
      lObjects[i-1]:=tsObject.Create;
      with lObjects[i-1] do
      begin
        SetLength(Propertyes, 0);
        ObjectName:=Strings[i];
        DefaultName:=Strings[i];
        ScriptName:=Strings[i];
        oType:=totLayer;
        LayerIndex:=i;
        sHelp:=TStringList.Create;
        sHelp.Text:=RSLayerRelatedBlock;
        //Parent:=Layers[0].sCollection;
      end;
    end;
  end;

  for i:=1 to Count-1 do
  begin
    cin:=0;
    cout:=0;
    SetLength(lObjects[i-1].Input, 0);
    SetLength(lObjects[i-1].Output, 0);

    if Layers[i]<>nil then
    for k:=0 to Length(Layers[i].Entityes)-1 do
    with Layers[i].Entityes[k] do
    begin
      if Enabled and (Source.oType=totBlockIn) then
      begin
        inc(cin);
        SetLength(lObjects[i-1].Input, cin);
        with lObjects[i-1].Input[cin-1] do
        begin
          Name:=Layers[i].Entityes[k].Name;
          LabelName:=Name;
          SymName:='';
          LinkType:=Source.Output[0].LinkType;
        end;
      end;
      if Enabled and (Source.oType=totBlockOut) then
      begin
        inc(cout);
        SetLength(lObjects[i-1].Output, cout);
        with lObjects[i-1].Output[cout-1] do
        begin
          Name:=Layers[i].Entityes[k].Name;
          LabelName:=Name;
          SymName:='';
          LinkType:=Source.Input[0].LinkType;
        end;
      end;
    end;
  end;
end;

function tsBoard.CheckName(name: string; SkipIndex:integer=-1; force_local:boolean=false): boolean;
var i,k:integer;
begin
  Result:=true;
  if (Host=nil) or force_local then
  begin
    for i:=0 to Length(Entityes)-1 do
    begin
      if i=SkipIndex then continue;
      if Entityes[i].Name=name then
      begin
        Result:=false;
        break
      end;
    end;
  end
  else
    for k:=0 to High(Host.Layers) do
    for i:=0 to Length(Host.Layers[k].Entityes)-1 do
    begin
      if (Host.Layers[k]=Self) and (i=SkipIndex) then continue;
      if Host.Layers[k].Entityes[i].Name=name then
      begin
        Result:=false;
        exit
      end;
    end;
end;

procedure tsBoard.SetProtect(ent: tsEntity);
var
  i:integer;
  found:boolean;
  o:tsObject;
begin
  // добавить копию локально
  found:=false;
  for i:=0 to sLocal.Count-1 do
    if sLocal.Objects[i].ScriptName = ent.Source.ScriptName then
    begin
      found:=true;
      break;
    end;
  if found then
  begin
    ent.Source:=sLocal.Objects[i];
  end
  else
  begin
    o:=ent.Source.Copy;
    SetLength(sLocal.Objects, sLocal.Count+1);
    sLocal.Objects[sLocal.Count]:=o;
    sLocal.Add(o.ObjectName);
  end;
end;

procedure tsBoard.Merge(ts: tsBoard);
var
  n,i:integer;
  name:string;

begin
  // настройка уникальности
  for i:=0 to Length(ts.Entityes)-1 do
  begin
    name:=ts.Entityes[i].Name;
    if (ts.Entityes[i].Source.oType in [totLayer,totBlockIn,totBlockOut]) then
    begin
      while not CheckName(name, -1, true) or not ts.CheckName(name, i, true) do name:=IncName(name);
    end
    else
    begin
      while not CheckName(name) or not ts.CheckName(name, i) do name:=IncName(name);
    end;
    ts.Entityes[i].Name:=name;
  end;

  // Добавление
  n:=Length(Entityes);
  SetLength(Entityes, Length(Entityes)+Length(ts.Entityes));
  for i:=0 to Length(ts.Entityes)-1 do
    Entityes[i+n]:=ts.Entityes[i];

  for i:=0 to High(ts.Entityes) do
    if Entityes[i+n].IsProtected then
      SetProtect(Entityes[n+i]);

  n:=Length(Chains);
  SetLength(Chains, Length(Chains)+Length(ts.Chains));
  for i:=0 to Length(ts.Chains)-1 do
    Chains[i+n]:=ts.Chains[i];

  // Очистка источника
  SetLength(ts.Entityes, 0);
  SetLength(ts.Chains, 0);
end;

function tsBoard.MousePress(Pos: TPoint; Select:boolean=false): tsUnit;
var
  i:integer;
begin
  Result:=nil;
  for i:=0 to Length(Entityes)-1 do
  with Entityes[i] do
    if PtInRect(Types.Rect(Rect.Left*GridX-DragDistance,Rect.Top*GridY-DragDistance,Rect.Right*GridX+DragDistance,Rect.Bottom*GridY), Pos) then
    begin
      if Select then
        Selected:=true;
      Result:=Entityes[i];
      break;
    end;

  if Result=nil then
  begin
    for i:=0 to Length(Chains)-1 do
      if Chains[i].PtOnChain(Pos) then
      begin
        if Select then
          Chains[i].Selected:=true;
        Result:=Chains[i];
        break;
      end;
  end;
end;

procedure tsBoard.MoveSelected(dx, dy: integer);
var
  i:integer;
  L:TList;
begin
  L:=TList.Create;
  for i:=0 to Length(Entityes)-1 do
  with Entityes[i] do
  if Selected then
  begin
    inc(Rect.Left, dx div GridX);
    inc(Rect.Right, dx div GridX);
    inc(Rect.Top, dy div GridY);
    inc(Rect.Bottom, dy div GridY);
    L.Add(Entityes[i]);
  end;
  for i:=0 to Length(Chains)-1 do
  with Chains[i] do
    if (L.IndexOf(Left.Obj)>=0)or(L.IndexOf(Right.Obj)>=0) then
      Connect(Self);
end;

procedure tsBoard.ClearSelect(Select:boolean=false);
var
  i:integer;
begin
  for i:=0 to Length(Entityes)-1 do
  begin
    Entityes[i].Selected:=Select;
    Entityes[i].SelInOut:=-1;
  end;
  for i:=0 to Length(Chains)-1 do
    Chains[i].Selected:=Select;
end;

function tsBoard.AddEntity(Source: tsObject):tsEntity;
var
  n,k:integer;
  TName:string;
begin
  n:=Length(Entityes);
  SetLength(Entityes, n+1);
  Entityes[n]:=tsEntity.Create(Source);
  with Entityes[n] do
  begin
    TName:=Source.DefaultName;
    if (Source.oType in [totLayer,totBlockIn,totBlockOut]) then
    begin
      while not CheckName(TName, n, true) do TName:=IncName(TName);
    end
    else
    begin
      while not CheckName(TName, n) do TName:=IncName(TName);
    end;
    Name:=TName;

    PropValues:=TStringList.Create;
    for k:=0 to Length(Source.Propertyes)-1 do
      PropValues.Add(Source.Propertyes[k].Default);

    OutValues:=TStringList.Create;
    for k:=0 to Length(Source.OutputPars)-1 do
      OutValues.Add('');

    OutSymValues:=TStringList.Create;
    for k:=0 to Length(Source.Output)-1 do
      OutSymValues.Add('');

    if Length(Source.Input)=1 then
      ParsInput:=0
    else
    begin
      ParsInput:=1;
      for k:=0 to Length(Source.Input)-1 do
        if Source.Input[k].Default then
        begin
          ParsInput:=k;
          break;
        end;
    end;
    ObjInput:=nil;

    Comments:=TStringList.Create;
    Enabled:=true;
  end;
  Result:=Entityes[n];
end;

function tsBoard.AddChain(LeftObj, RightObj: tsEntity):tsChain;
var n,k:integer;
begin
  n:=Length(Chains);
  SetLength(Chains, n+1);
  Chains[n]:=tsChain.Create;
  with Chains[n] do
  begin
    Left.Obj:=LeftObj;
    Right.Obj:=RightObj;
    Left.InOutInd:=LeftObj.SelInOut - Length(LeftObj.Source.Input);
    Right.InOutInd:=RightObj.SelInOut;

    Color:=RandomColor;
    if n>0 then
    for k:=0 to n-1 do
        if (Chains[k].Left.Obj=Left.Obj)and(Chains[k].Left.InOutInd=Left.InOutInd)
        or (Chains[k].Right.Obj=Right.Obj)and(Chains[k].Right.InOutInd=Right.InOutInd) then
        begin
          Color:=Chains[k].Color;
          break;
        end;

    if Right.InOutInd = Right.Obj.ParsInput then
      Right.Obj.ObjInput:=Left.Obj;

    Connect(Self);
  end;
  Result:=Chains[n];
end;

procedure tsBoard.DelSelect;
var i,k:integer;
begin
  for i:=0 to Length(Chains)-1 do
    if  Chains[i].Left.Obj.Selected or Chains[i].Right.Obj.Selected then
      Chains[i].Selected:=true;

  i:=0;
  while i<Length(Chains) do
  with Chains[i] do
    if Selected or Left.Obj.Selected or Right.Obj.Selected then //delete
    begin

      if Chains[i].Right.Obj.SelInOut = Chains[i].Right.InOutInd then // воостановить привязку к параметрам
      begin
        Chains[i].Right.Obj.ObjInput:=nil;
        for k:=0 to Length(Chains)-1 do
          if (Chains[k].Right.Obj = Chains[i].Right.Obj) and (Chains[k].Right.InOutInd = Chains[i].Right.InOutInd) then
          begin
            Chains[i].Right.Obj.ObjInput:=Chains[k].Left.Obj;
            break;
          end;
      end;

      Chains[i].Free;
      for k:=i+1 to Length(Chains)-1 do
        Chains[k-1]:=Chains[k];
      SetLength(Chains, Length(Chains)-1);
    end
    else inc(i);

  i:=0;
  while i<Length(Entityes) do
    if Entityes[i].Selected then //delete
    begin
      for k:=0 to Length(Entityes)-1 do
        if Entityes[k].ObjInput = Entityes[i] then Entityes[k].ObjInput:=nil;

      Entityes[i].Free;
      for k:=i+1 to Length(Entityes)-1 do
        Entityes[k-1]:=Entityes[k];
      SetLength(Entityes, Length(Entityes)-1);
    end
    else inc(i);
end;

procedure tsBoard.ReducePos;
var
  n:integer;
  minp:TPoint;
begin
  minp:=Point(High(Longint),High(Longint));
  for n:=0 to Length(Entityes)-1 do
  with Entityes[n].Rect do
  begin
    minp.X:=min(minp.X, Left);
    minp.Y:=min(minp.Y, Top);
  end;

  MoveSelected(-minp.X*GridX, -minp.Y*GridY);
end;

function tsBoard.IsChecked: boolean;
var n:integer;
begin
  Result:=false;
  for n:=0 to Length(Entityes)-1 do
    if Entityes[n].Selected then
    begin
      Result:=true;
      exit;
    end;

  for n:=0 to Length(Chains)-1 do
    if Chains[n].Selected then
    begin
      Result:=true;
      exit;
    end;
end;

procedure tsBoard.Compile;
var list:TStringList;
begin
  list:=CompileScript(self);
  GenerateFiles(list, filename);
end;

procedure tsMultiBoard.Compile;
var list:TStringList;
begin
  list:=CompileMultiScript(self);
  GenerateFiles(list, filename);
end;

// соединить все цепи
procedure tsBoard.ConnectChains;
const
  MaxCC = 256;
var
  n,ns,l,k,j:integer;
  s:TSize;
  chk:TPointsArray;
  p:integer;
begin
  if Length(Chains)=0 then exit;

  s.cx:=0; s.cy:=0;
  for n:=0 to Length(Entityes)-1 do
  begin
    Entityes[n].Index:=n;
    s.cx:=Max(s.cx, Entityes[n].Rect.Right*GridX);
    s.cy:=Max(s.cy, Entityes[n].Rect.Bottom*GridY);
  end;
  inc(s.cx, GridX*8);
  inc(s.cy, GridY*8);

  if HardChains then
  begin
    Route.Init(s.cx, s.cy, GridX div 2);

    for n:=0 to Length(Entityes)-1 do
      with Entityes[n].Rect do
        Route.BlockNode(Types.Rect(Left*GridX, Top*GridY, Right*GridX, Bottom*GridY));
  end;

  SetLength(chk, MaxCC);

  for n:=0 to Length(Chains)-1 do
  with Chains[n] do
  begin
    Connect(Self);

    if not HardChains then continue;

    //FillChar(chk[0], MaxCC, 0);
    chk[0]:=Points[0];
    p:=1;
    if n>0 then
    for k:=n-1 downto 0 do
      if (Chains[k].Left.Obj = Left.Obj) and (Chains[k].Left.InOutInd = Left.InOutInd) then
      begin
        if Length(Chains[k].Points)>=3 then
          for j:=1 to Length(Chains[k].Points)-2 do
          begin
            chk[p]:=Chains[k].Points[j];
            inc(p);
          end;
      end;

    SetLength(Points, MaxCC);
    ns:=0;
    for k:=0 to p-1 do
    begin
      Points[0]:=chk[k];
      ns:=Route.PlanRoute(Points[0], Points[1], Left.Obj.Index*16+Left.InOutInd+1, Right.Obj.Index*16+Right.InOutInd+1, Points, MaxCC);
      if ns>0 then break;
    end;

    if ns=0 then Connect(Self)
    else
    begin
      SetLength(Points, ns);
      Route.BlockRoute(Chains[n].Points, Left.Obj.Index*16+Left.InOutInd+1, Right.Obj.Index*16+Right.InOutInd+1);

      if p>1 then
      begin
        for l:=1 to ns-1 do
        begin
          j:=l;
          for k:=1 to p-2 do
            if (chk[k].X=chk[k+1].X) and (chk[k].X=Points[l].X) and (Abs(chk[k].Y+chk[k+1].Y-2*Points[l].Y)<=Abs(chk[k].Y-chk[k+1].Y)) or
               (chk[k].Y=chk[k+1].Y) and (chk[k].Y=Points[l].Y) and (Abs(chk[k].X+chk[k+1].X-2*Points[l].X)<=Abs(chk[k].X-chk[k+1].X)) then
            begin
              j:=0;
              break;
            end;
          if j>0 then break;
        end;

        if j>0 then
        begin
          dec(j);
          dec(ns, j);

          for l:=0 to ns-1 do
            Points[l]:=Points[l+j];
          //if q<p then
            //Points[0]:=chk[q];
          for k:=p-1 downto 0 do
            if (Points[0].X=Points[1].X) and (Points[0].X=chk[k].X) and (Abs(Points[0].Y+Points[1].Y-2*chk[k].Y)<=Abs(Points[0].Y-Points[1].Y)) or
               (Points[0].Y=Points[1].Y) and (Points[0].Y=chk[k].Y) and (Abs(Points[0].X+Points[1].X-2*chk[k].X)<=Abs(Points[0].X-Points[1].X)) then
            begin
              Points[0]:=chk[k];
              break;
            end;

          SetLength(Points, ns);
        end;

      end;

    end;
  end;

  if ShowPrio then CalcPrioIndices;
end;

function tsBoard.BoardBase: tsObject;
var
  n:integer;
  First:tsEntity;
begin
  First:=nil;
  for n:=0 to Length(Entityes)-1 do
    if Entityes[n].Source.oType=totModel then
    begin
      First:=Entityes[n];
      break;
    end;

  Result:=First.Source;
end;

procedure tsBoard.CalcPrioIndices(Calc:boolean=true);
var
  n,idx:integer;
  First:tsEntity;

  procedure Process(cur:tsEntity);
  var
    n:integer;
  begin
    cur.PrioIndex:=idx;
    inc(idx);

    //for k:=0 to High(cur.Source.Output) do
    //if cur.Source.Output[k].LinkType = ptControl then
      for n:=0 to High(Chains) do
      //if (Chains[n].Left.Obj = cur) and (Chains[n].Left.InOutInd=k) then
      if (Chains[n].Left.Obj = cur) and (Cur.Source.Output[Chains[n].Left.InOutInd].LinkType=ptControl) then
        if Chains[n].Right.Obj.Enabled then
          Process(Chains[n].Right.Obj);
  end;

begin
  ShowPrio:=Calc;

  // clear all
  for n:=0 to High(Entityes) do
    Entityes[n].PrioIndex:=0;
  if not Calc then exit;

  idx:=1;

  // sort prio
  SortChains(self);

  // units at first & find modular
  First:=nil;
  for n:=0 to High(Entityes) do
  if (Entityes[n].Source.oType=totUnit) and Entityes[n].Enabled then
  begin
    Entityes[n].PrioIndex:=idx;
    inc(idx);
  end
  else if (Entityes[n].Source.oType=totModel) then First:=Entityes[n]
  else
    if Entityes[n].Enabled and (Entityes[n].Source.oType=totBlockIn) then
      Process(Entityes[n]);

  // recurrent modulars
  if First<>nil then Process(First)


  {for n:=0 to High(Entityes) do
  if (Entityes[n].Source.UnitFlag or Entityes[n].Source.ModelFlag) and Entityes[n].Enabled then
    Process(Entityes[n]);}

end;

procedure tsBoard.UpdateObjects;
var
  i,k,l:integer;
  f:boolean;
begin
  sLocal.Clear;
  SetLength(sLocal.Objects, 0);
  SetLength(sLocal.Types, 0);

  // collect objects
  for i:=0 to Length(Entityes)-1 do
  begin
    if sLocal.IndexOf(Entityes[i].Source.ScriptName)<0 then
    begin
      sLocal.Add(Entityes[i].Source.ScriptName);
      k:=Length(Entityes);
      SetLength(sLocal.Objects, k+1);
      sLocal.Objects[k] := Entityes[i].Source;
    end;
  end;

  // collect types
  for i:=0 to Length(sLocal.Objects)-1 do
  begin
    for k:=0 to Length(sLocal.Objects[i].Propertyes)-1 do
    begin
      f:=false;
      for l:=0 to Length(sLocal.Types)-1 do
        if sLocal.Objects[i].Propertyes[k].PropType = ptExtern then
          if sLocal.Objects[i].Propertyes[k].ExtValues = sLocal.Types[l] then
          begin
            f:=true;
            break;
          end;
      if not f then
      begin
        SetLength(sLocal.Types, Length(sLocal.Types)+1);
        sLocal.Types[Length(sLocal.Types)-1]:=sLocal.Objects[i].Propertyes[k].ExtValues;
      end;
    end;
  end;
end;

procedure tsBoard.ResolveChains;
var i,k:integer;
begin
  for i:=0 to Length(Chains)-1 do
  with Chains[i] do
  begin
    if Left.InOutInd=-1 then // попытка найти выход
      for k:=0 to Length(Left.Obj.Source.Output)-1 do
        if UpperCase(Left.Obj.Source.Output[k].Name)=Left.ResolveName then
        begin
          Left.InOutInd:=k;
          break;
        end;
    if Right.InOutInd=-1 then // попытка найти вход
      for k:=0 to Length(Right.Obj.Source.Input)-1 do
        if UpperCase(Right.Obj.Source.Input[k].Name)=Right.ResolveName then
        begin
          Right.InOutInd:=k;
          break;
        end;

    if (Left.InOutInd=-1) or (Right.InOutInd=-1) then Chains[i].Lost:=true;
  end;
  ConnectChains;
end;

{ tsShemes }

constructor tsSchemes.Create;
var
  sr:TSearchRec;
  ts:tsCollection;
  r:TIniFile;
  l:TStringList;
  s:string;
  n,k:integer;
  env:TStringList;

  procedure Resolve(var s:string); forward;

  procedure ResolveVar(var s:string; p:integer);
  var
    q:integer;
    v,c:string;
  begin
    q:=p+1;
    while (s[q]<>'$')and(q<=length(s)) do inc(q);
    v:=copy(s, p+1, q-p-1);
    if UpperCase(v)='NAME' then
    begin
      s:=LeftStr(s,p-1)+'~N~'+Copy(s, q+1, Length(s));
      exit;
    end
    else if UpperCase(v)='LOG' then
    begin
      s:=LeftStr(s,p-1)+'~L~'+Copy(s, q+1, Length(s));
      exit;
    end
    else if UpperCase(v)='EXE' then
    begin
      s:=LeftStr(s,p-1)+'~X~'+Copy(s, q+1, Length(s));
      exit;
    end
    else if UpperCase(v)='PATH' then
    begin
      s:=LeftStr(s,p-1)+'~P~'+Copy(s, q+1, Length(s));
      exit;
    end;

    c:=env.Values[v];
    Resolve(c);
    env.Values[v]:=c;
    s:=LeftStr(s,p-1)+c+Copy(s, q+1, Length(s));
  end;

  procedure ResolveReg(var s:string; p:integer);
  var
    q,n:integer;
    v,rt,path,st:string;
    r:TRegistry;
  begin
    q:=p+1;
    while (s[q]<>']')and(q<=length(s)) do inc(q);
    v:=copy(s, p+1, q-p-1);

    n:=Length(v)-1;
    while (v[n]<>'\') and (n>0) do dec(n);
    rt:=LeftStr(v, 4);
    path:=MidStr(v, 6, n-6);
    st:=Copy(v, n+1, Length(v));

    r:=TRegistry.Create;
    if rt='HKCU' then r.RootKey:=HKEY_CURRENT_USER
    else if rt='HKLM' then r.RootKey:=HKEY_LOCAL_MACHINE;
    if r.OpenKey(path, false) then
      v:=r.ReadString(st);

    s:=LeftStr(s,p-1)+v+Copy(s, q+1, Length(s));
  end;

  procedure Resolve(var s:string);
  var n:integer;
  begin
    n:=Pos('$', s);
    while n>0 do
    begin
      ResolveVar(s, n);
      n:=Pos('$', s);
    end;
    n:=Pos('[', s);
    while n>0 do
    begin
      ResolveReg(s, n);
      n:=Pos('[', s);
    end;
  end;

  procedure ResolveEnv;
  var n:integer;
  begin
    for n:=0 to env.Count-1 do
    begin
      s:=env[n];
      Resolve(s);
      env[n]:=s;
    end;
  end;

begin
  inherited;

  l:=TStringList.Create;

  if FindFirst(ScriptPath+'*.ini', faAnyFile, sr)=0 then
  repeat
    // open and read ini
    r:=TIniFile.Create(ScriptPath+sr.Name);
    // Title
    Add(r.ReadString('Main', 'Title', 'No title'));
    // All other
    l.Clear;
    r.ReadSection('Main', l);
    Env:=TStringList.Create;
    for n:=0 to l.Count-1 do
      Env.Add(l[n]+'='+r.ReadString('Main', l[n], ''));

    // fix path & create instance
    s:=ExtractFileName(sr.Name);
    s:=LeftStr(s, Length(s)-4);
    // load scheme
    ts:=tsCollection.Create(Env.Values['Base'], UpperCase(s));
    ts.Env:=Env;

    k:=Length(Scheme);
    SetLength(Scheme, k+1);
    Scheme[k]:=ts;

    // Modulars
    l.Clear;
    r.ReadSections(l);
    for n:=0 to l.Count-1 do
    begin
      s:=UpperCase(l[n]);
      if s='MAIN' then Continue;
      for k:=0 to ts.Count-1 do
        if UpperCase(ts.Objects[k].ScriptName)=s then
          ts.Objects[k].DestPath:=r.ReadString(l[n], 'DestPath', '');
    end;
    r.Free;
  until FindNext(sr)<>0;

  // resolve params
  for k:=0 to Length(Scheme)-1 do
  begin
    env:=Scheme[k].Env;
    ResolveEnv;

    ts:=Scheme[k];
    for n:=0 to ts.Count-1 do
      if ts.Objects[n].DestPath<>'' then Resolve(ts.Objects[n].DestPath);
  end;
  l.Free;
end;

destructor tsSchemes.Destroy;
var n:integer;
begin
  for n:=0 to Length(Scheme)-1 do Scheme[n].Free;
  SetLength(Scheme, 0);

  inherited;
end;

end.
