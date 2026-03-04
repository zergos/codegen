unit Editors;

interface

uses Graphics, Controls, Classes, ExtCtrls, Types, SysUtils, Scripts, Globals;

type
  tsDrawTool = (dtArrow, dtLink, dtEntity);

  tsStatusEvent = procedure (status:string) of object;
  tsSelectEvent = procedure (ts:tsUnit) of object;
  tsChangeEvent = procedure of object;
  tsRepaint = procedure (ts:tsBoard) of object;

  teObject = class
  private
    Control:TPaintBox;
    Board:tsBoard;

    function Rect2(x1, y1, x2, y2:integer):TRect;
    procedure doNothing(status:string);
    procedure doNothing2(ts:tsUnit);
    procedure doNothing3(ts:tsBoard);
    procedure doNothing4;
  public
    OnStatus:tsStatusEvent;
    OnSelect:tsSelectEvent;
    OnChange:tsChangeEvent;
    DoRepaint:tsRepaint;

    constructor Create(ts:tsBoard; con:TPaintBox); virtual;

    procedure ProcessPos(var X,Y:integer);

    procedure MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer); virtual; abstract;
    procedure MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer); virtual; abstract;
    procedure MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer); virtual; abstract;
  end;

  teArrow = class (teObject)
  private
    ResizeMode:integer;
    Selected:tsUnit;

    DrawMode:boolean;
    MoveMode:integer;

    First, SavePoint, OldPoint:TPoint;
  public
    constructor Create(ts:tsBoard; con:TPaintBox); override;

    procedure MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  end;

  teEntity = class (teObject)
  private
    Ready, DrawMode:boolean;
    First, SavePoint, OldPoint:TPoint;
  public
    Source:tsObject;

    constructor Create(ts:tsBoard; con:TPaintBox); override;

    procedure MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  end;

  teChain = class (teObject)
  private
    Ready, DrawMode:boolean;
    First, OldPoint:TPoint;
    Selected:tsEntity;

    Ready2:boolean;
    Selected2:tsEntity;
  public
    constructor Create(ts:tsBoard; con:TPaintBox); override;

    procedure MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  end;

implementation

{ teObject }

constructor teObject.Create(ts: tsBoard; con: TPaintBox);
begin
  Board:=ts;
  Control:=con;
  OnStatus:=doNothing;
  OnSelect:=doNothing2;
  OnChange:=doNothing4;
  DoRepaint:=doNothing3;
end;

procedure teObject.doNothing(status: string);
begin
end;

procedure teObject.doNothing2(ts:tsUnit);
begin
end;

procedure teObject.doNothing3(ts: tsBoard);
begin
end;

procedure teObject.doNothing4;
begin
end;

// Нормализация координат
procedure teObject.ProcessPos(var X, Y: integer);
begin
  if GridSnap then
  begin
    dec(X,X mod GridX);
    dec(Y,Y mod GridY);
  end;
end;

function teObject.Rect2(x1, y1, x2, y2:integer):TRect;
begin
  if x1<x2 then
  begin
    Result.Left:=x1;
    Result.Right:=x2;
  end
  else
  begin
    Result.Left:=x2;
    Result.Right:=x1;
  end;
  if y1<y2 then
  begin
    Result.Top:=y1;
    Result.Bottom:=y2;
  end
  else
  begin
    Result.Top:=y2;
    Result.Bottom:=y1;
  end;

  if Result.Left<0 then Result.Left:=0;
  if Result.Right>Control.Width then Result.Right:=Control.Width;
  if Result.Top<0 then Result.Top:=0;
  if Result.Bottom>Control.Height then Result.Bottom:=Control.Height;
end;

{ teArrow }

constructor teArrow.Create(ts: tsBoard; con: TPaintBox);
begin
  inherited;

  ResizeMode:=0;
  DrawMode:=false;
  MoveMode:=0;
end;

procedure teArrow.MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  Tool:tsEntity;
  X1, Y1:integer;
begin
  //ProcessPos(X,Y);
  if not DrawMode and (MoveMode=0) then
  begin
    // над чем идёт мышь
    Selected:=Board.MousePress(Point(X,Y));
    if Selected<>nil then
    begin
      if Selected is tsEntity then
      begin
        Tool:=Selected as tsEntity;
        DoRepaint(Board);
        Tool.Draw(Control.Canvas, true);
        // проверить границы перемещения
        if (Abs(X-Tool.Rect.Right*GridX)<DragDistance) and (Abs(Y-Tool.Rect.Bottom*GridY)<DragDistance) then
        begin
          Control.Cursor:=crSizeNWSE;
          ResizeMode:=3;
        end
        else
        if Abs(X-Tool.Rect.Right*GridX)<DragDistance then
        begin
          Control.Cursor:=crSizeWE;
          ResizeMode:=1;
        end
        else
        if Abs(Y-Tool.Rect.Bottom*GridY)<DragDistance then
        begin
          Control.Cursor:=crSizeNS;
          ResizeMode:=2;
        end
        else
        begin
          Control.Cursor:=crArrow;
          ResizeMode:=0;
        end;

        OnStatus(Tool.Source.ObjectName+' -- '+Tool.Name);
      end
      else if Selected is tsChain then
      begin
        DoRepaint(Board);
        Selected.Draw(Control.Canvas, true);
        with Selected as tsChain do
          OnStatus(Format('%s.%s  ----->  %s.%s', [Left.Obj.Name,Left.Obj.Source.Output[Left.InOutInd].Name, Right.Obj.Name, Right.Obj.Source.Input[Right.InOutInd].Name]));
      end;
    end
      else //if Selected=nil then
      begin
        Control.Cursor:=crArrow;
        DoRepaint(Board);
        ResizeMode:=0;
      end;
  end
  else
  if DrawMode then
  begin
    ProcessPos(X,Y);
    with Control.Canvas do
    begin
      //затирание
      Pen.Color:=clOlive;
      Pen.Mode:=pmNotXor;
      Pen.Width:=2;
      Rectangle(Rect2(First.X, First.Y, OldPoint.X, OldPoint.Y));

      case ResizeMode of
        1: Y:=SavePoint.Y;
        2: X:=SavePoint.X;
      end;

      //прорисовка
      Rectangle(Rect2(First.X, First.Y, X, Y));
      OldPoint:=Point(X, Y);

      Pen.Mode:=pmCopy;
      Pen.Width:=0;
    end;
  end
  else // if MoveMode then // перемещение
  begin
    Selected.Selected:=true;
    ProcessPos(X,Y);
    X1:=X-OldPoint.X;
    Y1:=Y-OldPoint.Y;
    //ProcessPos(X1, Y1);
    Board.MoveSelected(X1, Y1);
    OldPoint:=Point(X,Y);
    DoRepaint(Board);
    MoveMode:=2;
    Control.Cursor:=crCross;
  end;

end;

procedure teArrow.MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  ts:tsEntity;
begin
  ProcessPos(X,Y);
  //if Button = mbLeft then
  begin
    if (ResizeMode>0) and (Selected is tsEntity) then
    // начало изменения размера
    begin
      ts:=Selected as tsEntity;
      First:=Types.Point(ts.Rect.Left*GridX, ts.Rect.Top*GridY);
      SavePoint:=Types.Point(ts.Rect.Right*GridY, ts.Rect.Bottom*GridY);
      Control.Canvas.DrawFocusRect(Rect2(First.X, First.Y, SavePoint.X, SavePoint.Y));
      OldPoint:=SavePoint;
      DrawMode:=True; //переход в режим редактирования объекта
    end
    else
    // начало выделения/перемещения
    if Selected<>nil then
    begin
      if not Selected.Selected and not (ssCtrl in Shift) then
      begin
        Board.ClearSelect;
      end;
      Selected.Selected:=true;//(Button=mbLeft) and not Selected.Selected or (Button=mbRight);//true;
      if not GridSnap or not (Selected is tsEntity) then
        First:=Point(X,Y)
      else
        First:=Point(X + X mod GridX, Y + Y mod GridY);//(Selected as tsEntity).Rect.Left*GridX, Y + (Selected as tsEntity).Rect.Top*GridY);
      SavePoint:=First;
      OldPoint:=First;
      MoveMode:=1;
      Control.Cursor:=crDrag;
    end
    else
    // начало группового выделения
    begin
      First:=Point(X,Y);
      SavePoint:=First;
      //Control.Canvas.DrawFocusRect(Rect2(First.X, First.Y, SavePoint.X, SavePoint.Y)); //одна точна
      OldPoint:=First;
      DrawMode:=true;
    end;
  end;
end;

procedure teArrow.MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  ProcessPos(X,Y);
  //if Button = mbLeft then
  if DrawMode then //завершение изменения размера
  with Control.Canvas do
  begin
    //затирание
    Pen.Color:=clOlive;
    Pen.Mode:=pmNotXor;
    Pen.Width:=2;
    Rectangle(Rect2(First.X, First.Y, OldPoint.X, OldPoint.Y));
    Pen.Mode:=pmCopy;
    Pen.Width:=0;

    if ResizeMode>0 then
    begin
      (Selected as tsEntity).SetRect(Rect2(First.X, First.Y, OldPoint.X, OldPoint.Y));
      (Selected as tsEntity).Selected:=true;
      Board.ConnectChains;
      Self.OnChange;
    end
    else
    // массовое выделение
      Board.CheckSelect(Rect2(First.X, First.Y, OldPoint.X, OldPoint.Y));

    DoRepaint(Board);

    DrawMode:=FALSE;
    Selected:=nil;
    ResizeMode:=0;
  end
  else
  if MoveMode=1 then
  // простое выделение
  begin
    //Board.ClearSelect;
    //Selected.Selected:=true;
    Selected.Draw(Control.Canvas);
    MoveMode:=0;
    Control.Cursor:=crDefault;
    OnSelect(Selected);
  end
  else if MoveMode=2 then // завершение перемещения
  begin
    MoveMode:=0;
    Control.Cursor:=crDefault;
    Board.ConnectChains;
    OnSelect(Selected);
    Self.OnChange;
  end;
end;

{ teEntity }

constructor teEntity.Create(ts: tsBoard; con: TPaintBox);
begin
  inherited;
  DrawMode:=false;
  Ready:=false;
end;

procedure teEntity.MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  ProcessPos(X,Y);
  if Button=mbLeft then
  begin
    if Ready then
    begin
      First:=Point(X,Y);
      SavePoint:=First;
      //Control.Canvas.DrawFocusRect(Rect2(First.X, First.Y, SavePoint.X, SavePoint.Y));
      OldPoint:=SavePoint;
      DrawMode:=True; //переход в режим редактирования объекта
      Ready:=false;
    end;
  end;
end;

procedure teEntity.MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var obj:tsUnit;
begin
  ProcessPos(X,Y);
  if not DrawMode then
  begin
    obj:=Board.MousePress(Point(X,Y));
    if obj=nil then
    begin
      Control.Cursor:=crCross;
      Ready:=true;
    end
    else
    begin
      Control.Cursor:=crDefault;
      Ready:=false;
    end;
  end
  else //if DrawMode then
  with Control.Canvas do
  begin
    Pen.Color:=clOlive;
    Pen.Mode:=pmNotXor;
    Pen.Width:=2;
    Rectangle(Rect2(First.X, First.Y, OldPoint.X, OldPoint.Y));
    Rectangle(Rect2(First.X, First.Y, X, Y));
    Pen.Mode:=pmCopy;
    Pen.Width:=0;
    OldPoint:=Point(X,Y);
  end;
end;

procedure teEntity.MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  ts:tsEntity;
begin
  ProcessPos(X,Y);
  if Button=mbLeft then
  if DrawMode then
  with Control.Canvas do
  begin
    ts:=Board.AddEntity(Source);
    ts.SetRect(Rect2(First.X, First.Y, X, Y));
    Board.ClearSelect;
    ts.Selected:=true;
    DrawMode:=false;
    DoRepaint(Board);
    ts.Draw(Control.Canvas, true);
    OnSelect(ts);
    Self.OnChange;
  end;
end;

{ teChain }

constructor teChain.Create(ts: tsBoard; con: TPaintBox);
begin
  inherited;
  Ready:=false;
  DrawMode:=false;
  Selected:=nil;
  Ready2:=false;
  Selected2:=nil;
end;

procedure teChain.MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  //ProcessPos(X,Y);
  if Button = mbLeft then
  begin
    if not DrawMode and Ready then
    begin
      First:=Selected.CalcOut;
      with Control.Canvas do
      begin
        Pen.Mode:=pmNotXor;
        MoveTo(First.X, First.Y);
        OldPoint:=First;
        LineTo(OldPoint.X, OldPoint.Y);
        Pen.Mode:=pmCopy;
        DrawMode:=true;
      end;
    end;
  end;
end;

procedure teChain.MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var i,k:integer;
begin
  //ProcessPos(X,Y);
  if not DrawMode then
  begin
    k:=-1;
    for i:=0 to Length(Board.Entityes)-1 do
    begin
      k:=Board.Entityes[i].CheckOut(Control.Canvas, Point(X,Y));
      if k>=0 then
      begin
        Selected:=Board.Entityes[i];
        break;
      end;
    end;
    if k>=0 then
    with Selected do
    begin
      Draw(Control.Canvas, true);
      Ready:=true;
      Control.Cursor:=crCross;
    end
    else
    begin
      if Selected<>nil then
      begin
        Selected.SelInOut:=-1;
        Selected.Draw(Control.Canvas, false);
      end;
      Selected:=nil;
      Ready:=false;
      Control.Cursor:=crDefault;
    end;
  end
  else //if DrawMode then
  with Control.Canvas do
  begin
    Pen.Mode:=pmNotXor;
    MoveTo(First.X, First.Y);
    LineTo(OldPoint.X, OldPoint.Y);
    OldPoint:=Point(X,Y);
    Pen.Mode:=pmCopy;

    for i:=0 to Length(Board.Entityes)-1 do
    begin
      k:=Board.Entityes[i].CheckIn(Control.Canvas, Point(X,Y));
      if (k>=0) and (Board.Entityes[i]<>Selected) then
      begin
        Selected2:=Board.Entityes[i];
        break;
      end;
    end;

    if k>=0 then
    with Selected2 do
    begin
      Draw(Control.Canvas, true);
      Ready2:=true;
    end
    else
    begin
      if Selected2<>nil then
      begin
        Selected2.SelInOut:=-1;
        Selected2.Draw(Control.Canvas, false);
      end;
      Selected2:=nil;
      Ready2:=false;
    end;

    Pen.Mode:=pmNotXor;
    MoveTo(First.X, First.Y);
    LineTo(X,Y);
    Pen.Mode:=pmCopy;
  end;
end;

procedure teChain.MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var ts:tsChain;
begin
  //ProcessPos(X,Y);
  if Button=mbLeft then
  begin
    if DrawMode then
    with Control.Canvas do
    begin
      if Ready2 then
      begin
        ts:=Board.AddChain(Selected, Selected2);
        ts.Selected:=true;
        Board.ConnectChains;

        if (ssCtrl in Shift) then
        begin
          DoRepaint(Board);
        end
        else
        begin
          Board.ClearSelect;
          DoRepaint(Board);
          ts.Selected:=true;
          ts.Draw(Control.Canvas, true);
          //Selected2.Draw(Control.Canvas);
          OnSelect(ts);
          Self.OnChange;
        end;

      end
      else
      begin
        Pen.Mode:=pmNotXor;
        MoveTo(First.X, First.Y);
        LineTo(OldPoint.X, OldPoint.Y);
        Pen.Mode:=pmCopy;
      end;
      
      if not (ssCtrl in Shift) then
      begin
        DrawMode:=false;
        Ready:=false;
        Selected:=nil;
      end
      else
      begin
        Pen.Mode:=pmNotXor;
        MoveTo(First.X, First.Y);
        LineTo(OldPoint.X, OldPoint.Y);
        Pen.Mode:=pmCopy;
      end;
      Ready2:=false;
      Selected2:=nil;
    end;
  end;
end;

end.
