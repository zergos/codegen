unit SCompiler;

interface

uses Classes, Types, StrUtils, SysUtils, Globals, Scripts, LangHelper;

procedure SortChains(self:tsBoard);
function CompileScript(self:tsBoard):TStringList;
function CompileMultiScript(self:tsMultiBoard):TStringList;
procedure GenerateFiles(list:TStringList; filename:string);

implementation

function ListSortFunc(Item1,Item2:Pointer):Integer;
var obj1, obj2:integer;
begin
  with tsChain(item1) do
    obj1:=(Left.Obj.Index*50+Right.InOutInd)*1000+Right.Obj.Index;
  with tsChain(item2) do
    obj2:=(Left.Obj.Index*50+Right.InOutInd)*1000+Right.Obj.Index;

  if obj1>obj2 then Result:=1
  else if obj1=obj2 then Result:=0
  else Result:=-1;
end;

{ tsBoardCompiler }
procedure SortChains(self:tsBoard);
var
  List:TList;
  n:integer;
begin
  for n:=0 to Length(self.Entityes)-1 do
    self.Entityes[n].Index:=n;
  List:=TList.Create;
  for n:=0 to Length(self.Chains)-1 do
    List.Add(self.Chains[n]);
  List.Sort(ListSortFunc);
  for n:=0 to List.Count-1 do
    self.Chains[n]:=tsChain(List[n]);
end;

function CompileScript(self:tsBoard): TStringList;
const
  allow_char = ['a'..'z','A'..'Z','0'..'9','_'];

type
  TResolve = record
    Obj:tsEntity;
    TempIndex:integer;
  end;

var
  First, Current:tsEntity;
  FirstPos:integer;

  // Template
  temp:TStringList;
  templist, templastlist, tempfirstlist:TStringDynArray;//array of string
  tempmap:TIntegerDynArray;
  tempnames:TStringList;

  // Special chars
  ParamChar:char;
  LocalChar:char;
  AskCharLeft, AskCharRight:char;

  // Identifiers
  localids, ids:TStringList;
  localvals:TStringList;
  paramids, paramvals:TStringList;

  // Current decoding string/pos
  p:integer;
  s:string;

  // Repeat mode
  RepeatMode:boolean;
  RepeatCheck:byte;
  RepLeftLink:tsChainLink;

  //Resolves
  CurTempIndex:integer;
  Resolves:array of TResolve;
  ResolveMode:boolean;

  // Translation
  Lang:TLangConverter;

  // Usage
  UseList:TStringList;

  procedure ProcessBlock; forward;
  function ProcessContent:string; forward;

  // извлечь букву без сдвига счётчика
  function test_c:word;
  var sc:set of char;
  begin
    sc:=['$',AskCharLeft,AskCharRight,ParamChar,LocalChar,'\'];
    if p>length(s) then result:=$FFFF
    else
    if not (s[p] in sc) then
      result:=ord(s[p])
    else
    if not ResolveMode and (s[p]='\') and (s[p+1] in sc) then
      result:=ord(s[p+1])
    else
      result:=ord(s[p]) shl 8;
  end;

  // извлечь букву со сдвигом
  function get_c:word;
  var sc:set of char;
  begin
    sc:=['$',AskCharLeft,AskCharRight,ParamChar,LocalChar,'\'];
    if p>length(s) then result:=$FFFF
    else
    if not (s[p] in sc) then
    begin
      result:=ord(s[p]);
      inc(p);
    end
    else
    if not ResolveMode and (s[p]='\') and (s[p+1] in sc) then
    begin
      result:=ord(s[p+1]);
      inc(p,2);
    end
    else
    begin
      result:=ord(s[p]) shl 8;
      inc(p);
    end;
  end;

  // расшифровка идентификатора
  function Decode(src:string):string;
  var
    saves:string;
    savep:integer;
  begin
    saves:=s;
    savep:=p;

    s:=src;
    p:=1;

    Result:=ProcessContent;

    s:=saves;
    p:=savep;
  end;

  // поиск входящих параметров по всей цепи
  function CheckPars(Current:tsEntity; parname:string):string;
  var l:integer;
  begin
    Result:='';

    if Current.ObjInput=nil then exit;

    with Current.ObjInput.Source do
    begin
      for l:=0 to Length(OutputPars)-1 do
        if OutputPars[l].Name=parname then
        begin
          Result:=Current.ObjInput.OutValues[l];//OutputPars[l].SymName;
          exit;
        end;
      Result:=CheckPars(Current.ObjInput, parname);
    end;

    if Result='' then
    begin
      SetLength(Resolves, Length(Resolves)+1);
      with Resolves[Length(Resolves)-1] do
      begin
        Obj:=Current;
        TempIndex:=CurTempIndex;
      end;
    end;
  end;

  // поиск значения параметра
  function FindParam(parname:string; ask:boolean=false):string;
  var
    n,k,l:integer;
  begin
    Result:='';

    // подсчёт индекса
    if (parname='index') or (parname='index1') then
    begin
      if RightStr(parname,1)='1' then k:=1
      else k:=0;
      for n:=0 to Length(self.Entityes)-1 do
      begin
        if self.Entityes[n]=Current then
        begin
          Result:=IntToStr(k);
          exit;
        end;
        if self.Entityes[n].Enabled and (self.Entityes[n].Source = Current.Source) then inc(k);
      end;
    end;

    if parname='name' then
    begin
      result:=Current.Name;
      exit;
    end;

    if parname='debug' then
    begin
      if CompileFullDebug or Current.Debug then Result:='1';
      exit;
    end;

    if parname='comments' then
    begin
      Result:=Current.Comments.Text;
      exit;
    end;

    if parname='version' then
    begin
      Result:=IntToStr(self.Version);
      exit;
    end;

    if parname='english' then
    begin
      Result:=IfThen(LangEnglish, '*', '');
      exit;
    end;

    if parname=First.Source.ScriptName then // совпадает с именем модуляра
    begin
      Result:='1';
      exit;
    end;

    if UpperCase(parname)=Self.sCollection.Name then
    begin
      Result:='1';
      exit;
    end;

    // поиск среди карт
    for n:=0 to Length(Current.Source.Maps)-1 do
      if UpperCase(Current.Source.Maps[n].Src)=UpperCase(parname) then
      begin
        Result:='$'+Current.Name+'.'+parname;
        exit;
      end;

    // поиск параметра
    for n:=0 to Length(Current.Source.Propertyes)-1 do
      if Current.Source.Propertyes[n].Name=parname then
      begin
        Result:=Current.PropValues[n];
        exit;
      end;

    // поиск среди входов
    for n:=0 to Length(Current.Source.Input)-1 do
    with Current.Source.Input[n] do
      if Name=parname then
      begin
        // режим повтора кода
        if RepeatMode and Current.Source.Input[n].Default then
        begin
          if Length(RepLeftLink.Obj.OutSymValues[RepLeftLink.InOutInd])>0 then Result:=RepLeftLink.Obj.OutSymValues[RepLeftLink.InOutInd]
          else Result:=Name;
          exit;
        end
        else

        // поиск по цепи
        for k:=0 to Length(self.Chains)-1 do
          if (self.Chains[k].Right.Obj=Current) and (self.Chains[k].Right.InOutInd=n) and (Self.Chains[k].Left.Obj.Enabled) then
          with self.Chains[k].Left.Obj do
          begin
            l:=self.Chains[k].Left.InOutInd;
            if Length(OutSymValues[l])>0 then Result:=OutSymValues[l]
            else
            if not ResolveMode then
            begin
              SetLength(Resolves, Length(Resolves)+1);
              with Resolves[Length(Resolves)-1] do
              begin
                Obj:=Current;
                TempIndex:=CurTempIndex;
              end;
              Result:='$'+ParName;
            end
            else
              Result:='$'+ParName;
            exit;
          end;
        exit;
      end;

    // поиск среди выходов
    for n:=0 to Length(Current.Source.Output)-1 do
    with Current.Source.Output[n] do
      if Name=parname then
      begin
        // поиск по цепи
        // * теперь достаточно просто проверить наличие выхода
        Result:=#255;
        for k:=0 to Length(self.Chains)-1 do
          if (self.Chains[k].Left.Obj=Current) and (self.Chains[k].Left.InOutInd=n) and (self.Chains[k].Right.Obj.Enabled) then
          //with self.Chains[k].Right.Obj.Source do
          begin
            Result:='';
            break;
          end;

        if Current.OutSymValues[n]<>'' then
          Result:=Result+Current.OutSymValues[n]
        else
          Result:=Result+Current.Name;

        exit;
      end;

    // поиск среди входящих параметров по ссылкам передачи контроля
    for n:=0 to Length(Current.Source.InputPars)-1 do
    with Current.Source.InputPars[n] do
      if Name=parname then
      begin
        Result:=CheckPars(Current, parname);
        break;
      end;

    if ResolveMode then
      Result:='$'+parname;
  end;

  var
    parname:string;

  // извлечь параметр перенаправления
  function GetMapped:string;
  var
    c:word;
    found:boolean;
    n,pnt:integer;
    a:string;
  begin
    // имя параметра
    result:='';
    parname:='';
    c:=test_c;
    if c=10 then
    begin
      result:=#13#10;
      inc(p, 2);
    end
    else
      inc(p);
    c:=test_c;
    while (c<>$FFFF) and (chr(lo(c)) in (allow_char+['.'])) do
    begin
      get_c;
      parname:=parname+UpperCase(chr(lo(c)));
      c:=test_c;
    end;

    if ResolveMode then
    begin
      Result:=Result+'$'+parname;
      exit;
    end;

    found:=false;
    for n:=0 to Length(Current.Source.Maps)-1 do
      if Current.Source.Maps[n].Src = parname then
      begin
        found:=true;
        break;
      end;

    if not found then
    begin
      SetLength(Current.Source.Maps, Length(Current.Source.Maps)+1);
      with Current.Source.Maps[Length(Current.Source.Maps)-1] do
      begin
        Src:=parname;
        pnt:=Pos('.', parname);
        if pnt=0 then
        begin
          Dest:='NEW';
          a:=parname;
        end
        else
        begin
          Dest:=copy(parname, pnt+1, length(parname));
          a:=LeftStr(parname, pnt-1);
        end;
        for n:=0 to Length(Current.Source.Output)-1 do
          if UpperCase(Current.Source.Output[n].Name)=a then
          begin
            OutInd:=n;
            break;
          end;
      end;
    end;

    Result:=Result+'$'+Current.Name+'.'+parname;
  end;

  // извлечь параметр
  function GetParam(Ask:boolean=false):string;
  var
    c:word;
    n:integer;
  begin
    // имя параметра
    parname:='';
    c:=test_c;
    while (c<>$FFFF) and (chr(lo(c)) in allow_char) do
    begin
      get_c;
      parname:=parname+chr(lo(c));
      c:=test_c;
    end;

    if parname='' then
    begin
      result:='';
      exit;
    end;

    //parname:=UpperCase(parname);

    n:=paramids.IndexOf(parname);
    if not ResolveMode and (n>=0) then
      Result:=paramvals[n]
    else
    begin
      result:=FindParam(parname,ask);
      paramids.Add(parname);
      paramvals.Add(result);
    end;

    if Result<>'' then
      if Result[1]=#255 then
      begin
        if Ask then Result:=''
        else Delete(Result,1,1);
      end;
  end;

  // извлечь локализованный параметр
  function GetLocal:string;
  var
    c:word;
    parname, newname:string;
    n:integer;
  begin
    // имя параметра
    parname:='';
    c:=test_c;
    while (c<>$FFFF) and (chr(lo(c)) in allow_char) do
    begin
      get_c;
      parname:=parname+chr(lo(c));
      c:=test_c;
    end;

    if parname='' then
    begin
      result:='';
      exit;
    end;

    //parname:=UpperCase(parname);

    n:=localids.IndexOf(parname);
    if n>=0 then Result:=localvals[n]
    else
    begin
      newname:=parname;
      while ids.IndexOf(newname)>=0 do newname:=IncName(newname);
      ids.Add(newname);
      localids.Add(parname);
      localvals.Add(newname);
      result:=newname;
    end;
  end;

  // извлечь раскодированное значение
  function GetSymbol(c:word):string;
  begin
    if copy(s,p-1,3)=#13#10+ParamChar then Result:=GetMapped
    else
    if chr(hi(c))=ParamChar then Result:=GetParam
    else
    if chr(hi(c))=LocalChar then Result:=GetLocal
    else Result:=chr(lo(c)+hi(c));
  end;

  // проверить наличие указанной строки
  function CheckWord(id:string; back:integer=0):boolean;
  begin
    if (length(id)+p-1-back>length(s)) or (p-back<=0) then result:=false
    else
    if MidStr(s, p-back, length(id))=id then
    begin
      inc(p, length(id)-back);
      result:=true
    end
    else
      Result:=false;
  end;

  var quest4code:boolean;

  // обработка условного блока
  function ProcessQuest:string;
  var
    c:word;
    ask,cmp,cur_par:string;
    needclose:integer;
    negative:boolean;
    mode:byte;
  begin
    negative:=false;
    result:='';
    if chr(lo(test_c))='!' then
    begin
      negative:=true;
      inc(p);
    end;

    ask:=GetParam(true);
    cur_par:=parname;

    cmp:='';
    if lo(get_c)=ord('=') then // условие сравнения
    begin
      c:=get_c;
      while (c<>$FFFF) and (hi(c)<>ord(AskCharRight)) do
      begin
        cmp:=cmp+chr(lo(c));
        c:=get_c;
      end;

      ask:=IfThen(ask=cmp,'1','');
    end;

    //inc(p); //пропуск '>'
    if (ask='') xor negative then mode:=1
    else mode:=2;
    needclose:=1;
    while (needclose>0) and (p<=length(s)) do
      if mode=1 then // пропустить блок
      begin
        while (needclose>0) and (p<=length(s)) do
          if CheckWord(AskCharLeft+'?') then inc(needclose)
          else
          if CheckWord(AskCharLeft+'/'+AskCharRight) then dec(needclose)
          else
          if CheckWord(AskCharLeft+'~'+AskCharRight) then
          begin
            if needclose=1 then begin mode:=2; break; end
          end
          else
            inc(p);
      end
      else // обработать блок
      begin
        if CompileWriteTags and quest4code then
          Result:=result+'/*'+IfThen(negative,'!','')+cur_par+IfThen(cmp='','','='+cmp)+'*/';
        c:=test_c;
        while (c<>$FFFF) and (needclose>0) do
        begin
          if CheckWord(AskCharLeft+'?') then result:=result+ProcessQuest
          else
          if CheckWord(AskCharLeft+'/'+AskCharRight) then dec(needclose)
          else
          if CheckWord(AskCharLeft+'~'+AskCharRight) then begin mode:=1; break; end
          else
            result:=result+GetSymbol(get_c);
          c:=test_c;
        end;
      end;
  end;

  // расшифровка кода внутри блока
  function ProcessContent:string;
  var
    c:word;
  begin
    // содержимое блока
    result:='';
    c:=test_c;
    while c<>$FFFF do
    begin
      if CheckWord(AskCharLeft+'?') or CheckWord(#13#10+AskCharLeft+'?',2) then result:=result+ProcessQuest
      else
      if CheckWord(#13#10'<',2) then ProcessBlock
      else
        result:=result+GetSymbol(get_c);
      c:=test_c;
    end;
  end;

  // чистка от пустых строк
  function FilterCarrier(par:string):string;
  var
    st:TStringList;
    n:integer;
  begin
    st:=TStringList.Create;
    st.Text:=par;
    n:=0;
    while n<st.Count do
      if Trim(st[n])='' then st.Delete(n)
      else inc(n);
    Result:=st.Text;
    st.Free;
  end;

  // расшифровка блока
  procedure ProcessBlock;
  var
    c:word;
    n:integer;
    blockname:string;
    res:string;
    add_last,add_first:boolean;
  begin
    // имя блока
    blockname:='';
    c:=get_c;
    while (chr(hi(c))<>'>') and (c<>$FFFF) do
    begin
      blockname:=blockname+chr(lo(c));
      c:=get_c;
    end;

    blockname:=UpperCase(blockname);

    add_last:=false;
    add_first:=false;
    if RightStr(blockname,1)='*' then
    begin
      blockname:=LeftStr(blockname, Length(blockname)-1);
      add_last:=true;
    end
    else
    if RightStr(blockname,1)='^' then
    begin
      blockname:=LeftStr(blockname, Length(blockname)-1);
      add_first:=true;
    end;

    n:=tempnames.IndexOf(blockname);
    if n>=0 then
    begin
      while n<>tempmap[n] do n:=tempmap[n];
      CurTempIndex:=n;
    end;

    if n<0 then // пропустить блок
    begin
      tempnames.Add(blockname);
      SetLength(tempmap, tempnames.Count);
      SetLength(templist, tempnames.Count);
      SetLength(templastlist, tempnames.Count);
      SetLength(tempfirstlist, tempnames.Count);
      n:=tempnames.Count-1;
      tempmap[n]:=n;
      CurTempIndex:=n;
    end;

    res:=ProcessContent;
    res:=FilterCarrier(res);
    if CompileWritePrints and (res<>'') and (Current.Source.oType <> totModel) then
    begin
      if blockname=UpperCase(self.sCollection.Env.Values['DebugBlock']) then
        res:=Format(self.sCollection.Env.Values['DebugLine'],[Current.Name])+#13#10+res;
    end;
    if CompileWriteTags and (res<>'') then
    begin
      res:=#13#10'// ------------------------------------ [ '+Current.Name+' ]'#13#10+res;
    end;

    // add to block last mode
    if add_last then
      templastlist[n]:=templastlist[n] + res
    else if add_first then
      tempfirstlist[n]:=tempfirstlist[n] + res
    else
      templist[n]:=templist[n] + res;
  end;

  // полная расшифровка кода
  procedure ProcessCode;
  var c:word;
  begin
    s:=Lang.Translate(s);
    c:=get_c;
    while c<>$FFFF do
    begin
      if chr(hi(c))='<' then ProcessBlock;
      c:=get_c;
    end;
  end;

  // компиляция вложений
  procedure DoCompile(Cur:tsEntity); forward;
  procedure CompileUsage(ref:tsEntity; objname:string);
  var
    k,l:integer;
    UseEnt:tsEntity;
    UseObj:tsObject;
  begin
    k:=self.sCollection.IndexOfScript(objname);
    if k>=0 then
    begin
      UseObj:=self.sCollection.Objects[k];

      // сбор подчиненных модулей
      if UseObj.sUses<>nil then
      for l:=0 to UseObj.sUses.Count-1 do
        if UseList.IndexOf(UseObj.sUses[l])=-1 then
        begin
          UseList.Add(UseObj.sUses[l]);

          CompileUsage(ref, UseObj.sUses[l]);
        end;

      UseEnt:=tsEntity.Create(UseObj);
      UseEnt.Enabled:=true;
      UseEnt.Debug:=ref.Debug;

      UseEnt.Source.Propertyes:=ref.Source.Propertyes;
      UseEnt.PropValues:=TStringList.Create;
      UseEnt.PropValues.AddStrings(ref.PropValues);

      UseEnt.Source.InputPars:=ref.Source.InputPars;
      UseEnt.ObjInput:=ref.ObjInput;

      DoCompile(UseEnt);

      UseEnt.Free;
    end;
  end;

  // компиляция одного объекта
  procedure DoCompile(Cur:tsEntity);
  var
    n, k, l, mapidx, outidx:integer;
    savemap:array of integer;
    name:string;
  begin
    if not Cur.Enabled then exit;

    // вложения
    if Cur.Source.sUses<>nil then
    for k:=0 to Cur.Source.sUses.Count-1 do
      if UseList.IndexOf(Cur.Source.sUses[k])=-1 then
      begin
        UseList.Add(Cur.Source.sUses[k]);
        CompileUsage(Cur, Cur.Source.sUses[k]);
      end;

    Current:=Cur;

    localids.Clear;
    localvals.Clear;
    paramids.Clear;
    paramvals.Clear;

    // вычисление выражений в выходящих потоках
    for k:=0 to Length(Current.Source.Output)-1 do
    begin
      s:=Current.Source.Output[k].SymName;
      p:=1;
      name:=ProcessContent;
      if (name<>'') and (name<>'*') then
      begin
        Current.OutSymValues[k]:=name;
      end
      else Current.OutSymValues[k]:=Current.Name;
    end;

    // расшифровка глобального кода
    quest4code:=true;
    if (Current.Source.sGlobal<>nil) and not Current.Source.GlobalUsed then
    begin
      Current.Source.GlobalUsed:=true;
      s:=Current.Source.sGlobal.Text;
      p:=1;
      ProcessCode;
    end;

    // расшифровка префикса
    if Current.Source.sPrefix<>nil then
    begin
      s:=Current.Source.sPrefix.Text;
      p:=1;
      ProcessCode;
    end;

    // расшифровка кода
    if Current.Source.sCode<>nil then
    begin
      RepeatMode:=false;
      RepeatCheck:=0;
      // поиск главного входа
      for l:=0 to Length(Current.Source.Input)-1 do
        if Current.Source.Input[l].Default then
        begin
          RepeatCheck:=1;
          break;
        end;

      if RepeatCheck>0 then
      for n:=0 to Length(self.Chains)-1 do
        if (self.Chains[n].Right.Obj = Current) and (self.Chains[n].Right.InOutInd = l) and self.Chains[n].Left.Obj.Enabled then
        begin
          inc(RepeatCheck);
          //if RepeatCheck>=3 then break;
        end;

      RepeatMode:=RepeatCheck>=3;

      if not RepeatMode then
      begin
        s:=Current.Source.sCode.Text; p:=1;
        ProcessCode;
      end
      else
      for n:=0 to Length(self.Chains)-1 do
        if (self.Chains[n].Right.Obj = Current) and (self.Chains[n].Right.InOutInd = l) and self.Chains[n].Left.Obj.Enabled then
        begin
          RepLeftLink:=self.Chains[n].Left;
          s:=Current.Source.sCode.Text; p:=1;
          ProcessCode;

          k:=paramids.IndexOf(Current.Source.Input[l].Name);
          if k>=0 then
          begin
            paramids.Delete(k);
            paramvals.Delete(k);
          end;
        end;

      RepeatMode:=false;
    end;

    // расшифровка постфикса
    if Current.Source.sPostfix<>nil then
    begin
      s:=Current.Source.sPostfix.Text; p:=1;
      ProcessCode;
    end;

    // заполнение выходящих параметров
    quest4code:=false;
    for k:=0 to Length(Current.Source.OutputPars)-1 do
    begin
      s:=Current.Source.OutputPars[k].SymName;
      p:=1;
      Current.OutValues[k]:=ProcessContent;
    end;

    SetLength(savemap, length(tempmap));

    // предварительное внесение карты новых блоков
    for k:=0 to Length(Cur.Source.Maps)-1 do
    begin
      l:=tempnames.IndexOf(Cur.Source.Maps[k].Dest);
      if l<0 then
      begin
        tempnames.Add(UpperCase(Cur.Source.Maps[k].Src));
        l:=tempnames.Count-1;
        SetLength(tempmap, l+1);
        tempmap[l]:=-1;
        //tempnames[mapidx]:=UpperCase(Cur.Source.Maps[k].Src);
      end;
    end;

    // если блок условный и уже обработан, то дальше управление передавать не нужно
    if (Cur.Source.oType <> totChoice) or not Cur.processed then

    // поиск передачи управления
    for n:=0 to Length(self.Chains)-1 do
      if not self.Chains[n].Lost then
      if (self.Chains[n].Left.Obj=Cur) and (Cur.Source.Output[self.Chains[n].Left.InOutInd].LinkType=ptControl) then
      begin
        // обработка условного объекта
        //if Cur.Source.ChoiceFlag then
        if Length(Cur.Source.Maps)>0 then
        begin
          outidx:=self.Chains[n].Left.InOutInd;
          // сохранение карты
          Move(tempmap[0], savemap[0], Length(savemap)*SizeOf(Integer));

          for k:=0 to Length(Cur.Source.Maps)-1 do
          if (Cur.Source.Maps[k].OutInd=outidx) or (Cur.Source.Maps[k].Dest='NEW') then
          begin
            // внесение карты
            mapidx:=tempnames.IndexOf(Cur.Name+'.'+UpperCase(Cur.Source.Maps[k].Src));
            if mapidx<0 then
            begin
              tempnames.Add(Cur.Name+'.'+UpperCase(Cur.Source.Maps[k].Src));
              mapidx:=tempnames.Count-1;
              SetLength(templist, mapidx+1);
              SetLength(templastlist, mapidx+1);
              SetLength(tempfirstlist, mapidx+1);
              SetLength(tempmap, mapidx+1);
              tempmap[mapidx]:=mapidx;
            end;
            l:=tempnames.IndexOf(Cur.Source.Maps[k].Dest);
            {if l<0 then
            begin
              tempnames.Add(UpperCase(Cur.Source.Maps[k].Src));
              l:=tempnames.Count-1;
              SetLength(tempmap, l+1);
              tempmap[l]:=mapidx;
              //tempnames[mapidx]:=UpperCase(Cur.Source.Maps[k].Src);
              continue;
            end;}
            if l<0 then l:=tempnames.IndexOf(Cur.Source.Maps[k].Src)
            else
            while tempmap[l]<>l do l:=tempmap[l];
            tempmap[l]:=mapidx;
          end;

          DoCompile(self.Chains[n].Right.Obj);

          // восстановление карты
          Move(savemap[0], tempmap[0], Length(savemap)*SizeOf(Integer));
        end
        else
          // обработка обычного объекта
          DoCompile(self.Chains[n].Right.Obj);
      end;

    SetLength(savemap, 0);
    Cur.processed:=true;
  end;

  // сборка шаблона
  function BuildTemplate(temp:TStringList):TStringList;
  var
    k,n:integer;
    st,ts:TStringList;
  begin
    st:=TStringList.Create;
    ts:=TStringList.Create;

    for n:=0 to temp.Count-1 do
    begin
      if Length(temp[n])=0 then
      begin
        st.Add('');
        Continue;
      end
      else
      if temp[n][1]='$' then
      begin
        k:=tempnames.IndexOf(Copy(temp[n], 2, Length(temp[n])));
        if k>=0 then
        begin
          if Length(tempfirstlist[k])>0 then
          begin
            ts.Text:=tempfirstlist[k];
            st.AddStrings(BuildTemplate(ts));
          end;
          if Length(templist[k])>0 then
          begin
            ts.Text:=templist[k];
            st.AddStrings(BuildTemplate(ts));
          end;
          if Length(templastlist[k])>0 then
          begin
            ts.Text:=templastlist[k];
            st.AddStrings(BuildTemplate(ts));
          end;
        end
      end
      else
        st.Add(temp[n]);
    end;

    ts.Free;
    Result:=st;
  end;

// основная программа
var
  n,k,l:integer;
  //UseRef:array of tsEntity;

begin
  inc(self.Version);

  // определение спец. символов
  if self.sCollection.Env.Values['ParamChar']<>'' then
    ParamChar:=self.sCollection.Env.Values['ParamChar'][1]
  else
    ParamChar:='$';
  if self.sCollection.Env.Values['LocalChar']<>'' then
    LocalChar:=self.sCollection.Env.Values['LocalChar'][1]
  else
    LocalChar:='@';
  if self.sCollection.Env.Values['AskChars']<>'' then
  begin
    AskCharLeft:=self.sCollection.Env.Values['AskChars'][1];
    AskCharRight:=self.sCollection.Env.Values['AskChars'][2];
  end
  else
  begin
    AskCharLeft:='<';
    AskCharRight:='>';
  end;

  // загрузка переводов
  Lang:=TLangConverter.Create(ScriptPath+'\'+self.sCollection.SchemePath+'\language.lst', self.sCollection.Env.Values['StringType'], ParamChar);

  // поиск модуляра
  First:=nil;
  FirstPos:=-1;
  for n:=0 to Length(self.Entityes)-1 do
    if self.Entityes[n].Source.oType = totModel then
    begin
      First:=self.Entityes[n];
      FirstPos:=n;
      break;
    end;

  if First=nil then
  begin
    Result:=TStringList.Create;
    exit;
  end;

  // подготовка цепей
  SortChains(self);

  // сброс флага глобального кода
  for n:=0 to self.sCollection.Count-1 do
    self.sCollection.Objects[n].GlobalUsed:=false;

  // сброс флага обработанности
  for n:=0 to Length(self.Entityes)-1 do
    self.Entityes[n].processed:=false;

  // сброс карт переназначения
  for n:=0 to self.sCollection.Count-1 do
    SetLength(self.sCollection.Objects[n].Maps, 0);

  // подготовка шаблонов
  temp:=First.Source.sTemplate;
  tempnames:=TStringList.Create;
  for n:=0 to temp.Count-1 do
  if Length(temp[n])>0 then
    if temp[n][1]='$' then
      tempnames.Add(UpperCase(MidStr(temp[n],2,Length(temp[n]))));
  SetLength(templist, tempnames.Count);
  SetLength(templastlist, tempnames.Count);
  SetLength(tempfirstlist, tempnames.Count);
  SetLength(tempmap, tempnames.Count);
  for n:=0 to tempnames.Count-1 do
    tempmap[n]:=n;

  // таблицы идентификаторов
  localids:=TStringList.Create;
  localids.CaseSensitive:=true;
  localvals:=TStringList.Create;
  localvals.CaseSensitive:=true;
  ids:=TStringList.Create;
  ids.CaseSensitive:=true;
  paramids:=TStringList.Create;
  paramids.CaseSensitive:=true;
  paramvals:=TStringList.Create;
  paramvals.CaseSensitive:=true;

  // сбор используемых неявно модулей
  UseList:=TStringList.Create;
  {
  for n:=0 to Length(self.Entityes)-1 do
    if self.Entityes[n].Enabled and (self.Entityes[n].Source.sUses<>nil) then
    begin
      for k:=0 to self.Entityes[n].Source.sUses.Count-1 do
        if UseList.IndexOf(self.Entityes[n].Source.sUses[k])=-1 then
        begin
          UseList.Add(self.Entityes[n].Source.sUses[k]);
          SetLength(UseRef, UseList.Count);
          UseRef[UseList.Count-1]:=self.Entityes[n];
        end;
    end;}

  // шаги компиляции
  ResolveMode:=false;
  RepeatMode:=false;

  // компиляция включенных модулей
  {for n:=0 to UseList.Count-1 do
    CompileUsage(UseRef[n], UseList[n]);}

  // компиляция модулей до модуляря
  //for n:=0 to FirstPos-1 do
  for n:=0 to Length(self.Entityes)-1 do
    if (self.Entityes[n].Source.oType = totUnit) and self.Entityes[n].Enabled then
      DoCompile(self.Entityes[n]);

  // компиляция по управляющим ссылкам
  DoCompile(First);

  // компиляция модулей после модуляря
  {for n:=FirstPos+1 to Length(self.Entityes)-1 do
    if self.Entityes[n].Source.UnitFlag and self.Entityes[n].Enabled then
      DoCompile(self.Entityes[n]);}

  // разрешение ссылок
  ResolveMode:=true;
  for n:=0 to Length(Resolves)-1 do
  with Resolves[n] do
  begin
    Current:=Obj;
    s:=templist[TempIndex];
    p:=1;
    templist[TempIndex]:=ProcessContent;
    s:=templastlist[TempIndex];
    p:=1;
    templastlist[TempIndex]:=ProcessContent;
    s:=tempfirstlist[TempIndex];
    p:=1;
    tempfirstlist[TempIndex]:=ProcessContent;
  end;

  // сборка
  Result:=BuildTemplate(temp);

  Lang.Free;
end;

procedure SplitBoard(b, res:tsBoard; parent:integer);
var
  i, shift:integer;
begin
  SetLength(res.Entityes, Length(res.Entityes)+Length(b.Entityes));
  shift:=Length(res.Entityes);
  for i:=0 to High(b.Entityes) do
  begin
    res.Entityes[i+shift]:=b.Entityes[i];
    res.Entityes[i+shift].ParentIndex:=parent;
  end;
  SetLength(res.Chains, Length(res.Chains)+Length(b.Chains));
  shift:=Length(res.Chains);
  for i:=0 to High(b.Chains) do
    res.Chains[i+shift]:=b.Chains[i];
end;

function CompileMultiScript(self:tsMultiBoard):TStringList;
type
  tStack = record
    host:tsBoard;
    node:tsEntity;
  end;
var
  i,k,l:integer;
  ts, lr:tsBoard;
  ch:tsChain;
  start:tsEntity;
  stack:array of tStack;
  spos:integer;
  s:string;
  redef:array of tsEntity;
  Rights:array of tsChainLink;

  procedure Add(ent:tsEntity);
  begin
    if not ent.processed then
    begin
      SetLength(ts.Entityes, Length(ts.Entityes)+1);
      ts.Entityes[Length(ts.Entityes)-1]:=ent;
      ent.processed:=true;
    end;
  end;

  procedure AddChain(ch:tsChain);
  var l:integer;
  begin
    l:=Length(ts.Chains);
    SetLength(ts.Chains, l+1);
    ts.Chains[l]:=ch;
  end;

  procedure Push(host:tsBoard; node:tsEntity);
  begin
    stack[spos].host:=host;
    stack[spos].node:=node;
    inc(spos);
  end;

  procedure Pop(var host:tsBoard; var node:tsEntity);
  begin
    dec(spos);
    host:=stack[spos].host;
    node:=stack[spos].node;
  end;

  procedure Process(ent:tsEntity; ch:tsChain; local:tsBoard);
  var
    n, k, l:integer;
    lr, host:tsBoard;
    node:tsEntity;
  begin
    if ent.Source.oType = totLayer then // вход в слой
    begin
      lr:=self.Layers[ent.Source.LayerIndex];
      s:=ent.Source.Input[ch.Right.InOutInd].Name;
      for k:=0 to High(lr.Chains) do
        if (lr.Chains[k].Left.Obj.Source.oType = totBlockIn)
          and (lr.Chains[k].Left.Obj.Name = s) then
          begin
            Push(local, ent);
            Process(lr.Chains[k].Right.Obj, lr.Chains[k], lr);
          end;
    end
    else if ent.Source.oType = totBlockOut then // выход из слоя
    begin
      Pop(host, node);
      for k:=0 to High(host.Chains) do
        if (host.Chains[k].Left.Obj = node)
          and (node.Source.Output[host.Chains[k].Left.InOutInd].Name = ent.Name) then
        begin
          Process(host.Chains[k].Right.Obj, host.Chains[k], host);
        end;
    end
    else // обычный блок
    begin
      Add(ent);

      for n:=0 to High(local.Chains) do
        with local.Chains[n] do
        if not Lost
          and (Left.Obj = ent)
          and Right.Obj.Enabled
          and (Left.Obj.Source.Output[Left.InOutInd].LinkType = ptControl) then
          Process(Right.Obj, local.Chains[n], local);
    end;
  end;

  procedure DoRedef(ts:tsBoard);
  var i,k:integer;
  begin
    for i:=0 to High(redef) do
      for k:=0 to High(ts.Chains) do
        if not ts.Chains[k].Lost
          and (ts.Chains[k].Right.Obj = redef[i])
          and (ts.Chains[k].Right.InOutInd = redef[i].ParsInput) then
        begin
          redef[i].ObjInput:=ts.Chains[k].Left.Obj;
          break;
        end;
  end;

  procedure GetRights(lr:integer; rin:array of tsChainLink);
  var
    r,i,k,l:integer;
    ent:tsEntity;
    local:tsBoard;
    li:integer;
    s:string;
    rout:array of tsChainLink;

    procedure AddRight(link:tsChainLink);
    begin
      SetLength(rout, Length(rout)+1);
      rout[Length(rout)-1]:=link;
    end;

  begin
    for r:=0 to High(rin) do
    begin
      if rin[r].Obj.Source.oType = totBlockOut then // поиск приемника данных из слоя
      begin
        ent:=nil;
        for i:=0 to High(self.Layers) do
          for k:=0 to High(self.Layers[i].Entityes) do
            with self.Layers[i].Entityes[k] do
              if Enabled and (Name = self[lr]) then
              begin
                ent:=self.Layers[i].Entityes[k];
                local:=self.Layers[i];
                li:=i;

                // поиск именного выхода из блока-слоя
                SetLength(rout, 0);
                for l:=0 to High(local.Chains) do
                  if not local.Chains[l].Lost
                    and (local.Chains[l].Left.Obj = ent)
                    and (ent.Source.Output[local.Chains[l].Left.InOutInd].Name = rin[r].Obj.Name) then
                      AddRight(local.Chains[l].Right);
                GetRights(li, rout);
              end;
      end
      else if rin[r].Obj.Source.oType = totLayer then // поиск приёмника данных внутри слоя
      begin
        // поиск именного получателя данных
        local:=self.Layers[rin[r].Obj.Source.LayerIndex];
        s:=rin[r].Obj.Source.Input[rin[r].InOutInd].Name;
        for k:=0 to High(local.Chains) do
          if not local.Chains[k].Lost
            and (local.Chains[k].Left.Obj.Source.oType = totBlockIn)
            and (local.Chains[k].Left.Obj.Name = s) then
              AddRight(local.Chains[k].Right);
         GetRights(rin[r].Obj.Source.LayerIndex, rout);
      end
      else
      begin
        SetLength(Rights, Length(Rights)+1);
        Rights[Length(Rights)-1]:=rin[r];
      end;
    end;
  end;

begin
  ts:=tsBoard.Create;
  ts.sCollection:=self.Layers[0].sCollection;
  ts.Host:=self;
  ts.Version:=self.Version;
  for i:=1 to High(self.Layers) do
    self.lObjects[i-1].LayerIndex:=i;

  // поиск модуляра
  start:=nil;
  for i:=0 to High(self.Layers[0].Entityes) do
    if self.Layers[0].Entityes[i].Source.oType=totModel then
    begin
      start:=self.Layers[0].Entityes[i];
      break;
    end;

  if start=nil then
  begin
    Result:=TStringList.Create;
    ts.Free;
    exit;
  end;

  for i:=1 to High(self.Layers) do
    self.lObjects[i-1].LayerIndex:=i;

  // добавление модулей со всех слоёв
  for i:=0 to High(self.Layers) do
    for k:=0 to High(self.Layers[i].Entityes) do
    begin
      self.Layers[i].Entityes[k].processed:=false;
      if self.Layers[i].Entityes[k].Source.oType=totUnit then
         Add(self.Layers[i].Entityes[k]);
    end;

  // сортировка связей по слоям
  for i:=0 to High(self.Layers) do
    SortChains(self.Layers[i]);

  // добавление в схему объектов по связям
  SetLength(stack, 1000);
  spos:=0;
  Process(start, nil, self.Layers[0]);
  SetLength(stack, 0);

  // добавление в схему всех связей
  for i:=0 to High(self.Layers) do
    for k:=0 to High(self.Layers[i].Chains) do
      with self.Layers[i].Chains[k] do
        if not Lost
          and Left.Obj.Enabled
          and Right.Obj.Enabled then
        // проскаем все связи от слоёв или от входов в слои
        if not (Left.Obj.Source.oType in [totBlockIn, totLayer]) then
        // связи к слою или к выходам из слоя
        if Right.Obj.Source.oType in [totBlockOut, totLayer] then
        begin
          SetLength(Rights, 0);
          GetRights(i, [Right]);
          for l:=0 to High(Rights) do
          begin
            ch:=tsChain.Create;
            ch.Left:=Left;
            ch.Right:=Rights[l];
            AddChain(ch);
          end;
        end
        else
          AddChain(self.Layers[i].Chains[k]);

  // переопределение источников параметров между схемами
  for i:=0 to High(ts.Entityes) do
    if (ts.Entityes[i].ObjInput<>nil)
      and (ts.Entityes[i].ObjInput.Source.oType in [totLayer, totBlockIn])
      and (ts.Entityes[i].ParsInput<Length(ts.Entityes[i].Source.Input)) then
    begin
      l:=Length(redef);
      SetLength(redef, l+1);
      redef[l]:=ts.Entityes[i];
    end;

  DoRedef(ts);
  
  Result:=CompileScript(ts);

  // восстановление источников параметров
  for i:=0 to High(self.Layers) do
    DoRedef(self.Layers[i]);

  self.Version:=ts.Version;

end;

procedure GenerateFiles(list:TStringList; filename:string);
const map:array ['0'..'F'] of byte = (0,1,2,3,4,5,6,7,8,9,0,0,0,0,0,0,0,10,11,12,13,14,15);
var
  n,k:integer;
  f:TFileStream;
  mode,b:byte;
  s,newname,crlf:string;
begin
  f:=TFileStream.Create(filename, fmCreate);
  mode:=0;
  crlf:=#13#10;
  for n:=0 to list.Count-1 do
  begin
    s:=list[n];
    if (s<>'') and (s[1]='=') then
    begin
      f.Free;
      if RightStr(s,1)='#' then
      begin
        mode:=1;
        s:=LeftStr(s, Length(s)-1);
      end
      else mode:=0;
      if s[2]='*' then newname:=LeftStr(filename, length(filename)-pos('.',ReverseString(filename))+1)+copy(s, 4, length(s))
      else newname:=ExtractFilePath(filename)+copy(s, 2, length(s));
      f:=TFileStream.Create(newname, fmCreate);
      Continue;
    end;

    if mode=0 then
    begin
      if s='' then continue;
      if s[1]='\' then s:=copy(s,2,Length(s)-1);
      f.Write(s[1], Length(s));
      f.Write(crlf[1], 2);
    end
    else
    begin
      k:=1;
      while k<=Length(s) do
      begin
        b:=map[s[k]]*16+map[s[k+1]];
        f.Write(b,1);
        inc(k,2);
      end;
    end;
  end;

  f.Free;
end;

end.

