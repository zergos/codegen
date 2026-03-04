// based on ScriptStudio by Bjarke Viksoe (viksoe.dk)
unit RoutePlanner;

interface

uses Types, Math, Globals;

const
  NODE_EDGE    = $FFFFFFFF;
  NODE_BLOCKED = $FFFFFFFF;
  NODE_TARGET  = $EEEEEEEE;
  NODE_OPEN    = $80000000;

type
  tsPlanNode = record
    lr, ud:cardinal;
  end;

  TPointsArray = array of TPoint;

  TRoutePlanner = class
    m_pNet:array of array of tsPlanNode;
    m_iScale:integer;
    m_sizeMaze:TSize;
    m_dwByteSize:integer;

    constructor Create;
    destructor Destroy; override;

    function Init(cx, cy, iScale:integer):boolean;
    function BlockNode(rcItem:TRect; wID:cardinal = NODE_BLOCKED):boolean;
    function BlockEdge(rcItem:TRect; wID:cardinal = NODE_BLOCKED):boolean;
    function BlockRoute(Points:TPointsArray; wID1, wID2:cardinal):boolean;
    function PlanRoute(ptSrc, ptDest:TPoint; wDestID1, wDestID2:cardinal; var pResult:TPointsArray; cchMax:integer):integer;
  end;

implementation

const
  ROUTE_ID_OFFSET = $4000;

constructor TRoutePlanner.Create;
begin
  SetLength(m_pNet,0,0);
end;

destructor TRoutePlanner.Destroy;
begin
  SetLength(m_pNet,0,0);
end;

function TRoutePlanner.Init(cx, cy, iScale:integer):boolean;
var
  x, y, dwSize:integer;
begin
  m_iScale:=iScale;
  m_sizeMaze.cx:=(cx div m_iScale) + 2;
  m_sizeMaze.cy:=(cy div m_iScale) + 2;

  SetLength(m_pNet, m_sizeMaze.cy, m_sizeMaze.cx);

  dwSize:=m_sizeMaze.cx * m_sizeMaze.cy;
  m_dwByteSize:=dwSize * sizeof(tsPlanNode);

  // Clear array
  // Block edges so route algorithm stays within borders
  // Note how size of maze is +2 to add these extra wall-nodes
  for y:=0 to m_sizeMaze.cy-1 do
    for x:=0 to m_sizeMaze.cx-1 do
    begin
      m_pNet[y,x].lr:=NODE_OPEN;
      m_pNet[y,x].ud:=NODE_OPEN;
    end;

  for x:=0 to m_sizeMaze.cx-1 do
  begin
    m_pNet[0,x].lr:=NODE_EDGE;
    m_pNet[0,x].ud:=NODE_EDGE;
    m_pNet[m_sizeMaze.cy-1, x].lr:=NODE_EDGE;
    m_pNet[m_sizeMaze.cy-1, x].ud:=NODE_EDGE;
  end;
  for y:=0 to m_sizeMaze.cy-1 do
  begin
    m_pNet[y,0].lr:=NODE_EDGE;
    m_pNet[y,0].ud:=NODE_EDGE;
    m_pNet[y,m_sizeMaze.cx-1].lr:=NODE_EDGE;
    m_pNet[y,m_sizeMaze.cx-1].ud:=NODE_EDGE;
  end;

  Result:=true;
end;

function TRoutePlanner.BlockNode(rcItem:TRect; wID:cardinal = NODE_BLOCKED):boolean;
var
  x,y:integer;
begin
  Result:=false;

  rcItem.left:=rcItem.left div m_iScale;
  rcItem.right:=rcItem.right div m_iScale;
  rcItem.top:=rcItem.top div m_iScale;
  rcItem.bottom:=rcItem.bottom div m_iScale;

   if (rcItem.left < 0) or (rcItem.top < 0) then exit;
   if (rcItem.right > m_sizeMaze.cx - 2) or (rcItem.bottom > m_sizeMaze.cy - 2) then exit;

   for x:=rcItem.left-1 to rcItem.right-1 do
   if (x>=0) and (x<=m_sizeMaze.cx-2) then
     for y:=rcItem.top to rcItem.bottom do
     if (y>=0) and (y<=m_sizeMaze.cy-2) then
     begin
       m_pNet[y+1,x+1].lr := wID;
       m_pNet[y+1,x+1].ud := wID;
     end;

  Result:=true;
end;

function TRoutePlanner.BlockEdge(rcItem:TRect; wID:cardinal = NODE_BLOCKED):boolean;
var
  iTemp,x,y:integer;

  procedure block_lr(x,y:integer);
  var l:integer;
  begin
    for l:=1 to GridY div 4 do
      if y+l < m_sizeMaze.cy then m_pNet[y+l,x+1].lr:=wID;
  end;

  procedure block_ud(x,y:integer);
  var l:integer;
  begin
    for l:=1 to GridX div 4 do
      if x+l < m_sizeMaze.cy then m_pNet[y+1,x+l].ud:=wID;
  end;

begin
   Result:=false;

   if (rcItem.left>rcItem.right) then
   begin
     iTemp := rcItem.left;
     rcItem.left := rcItem.right;
     rcItem.right := iTemp;
   end;
   if (rcItem.top>rcItem.bottom) then
   begin
     iTemp := rcItem.top;
     rcItem.top := rcItem.bottom;
     rcItem.bottom := iTemp;
   end;

  rcItem.left:=rcItem.left div m_iScale;
  rcItem.right:=rcItem.right div m_iScale;
  rcItem.top:=rcItem.top div m_iScale;
  rcItem.bottom:=rcItem.bottom div m_iScale;

  if (rcItem.left<0) or (rcItem.top<0) then exit;
  if (rcItem.right>=m_sizeMaze.cx-2) or (rcItem.bottom>=m_sizeMaze.cy-2) then exit;

  for x:=rcItem.left to rcItem.right do
  if (x>=0) and (x<=m_sizeMaze.cx-2) then
    for y:=rcItem.top to rcItem.bottom do
    if (y>=0) and (y<=m_sizeMaze.cy-2) then
    begin
      if (rcItem.left<>rcItem.right) then m_pNet[y+1,x+1].lr := wID;
      if (rcItem.top<>rcItem.bottom) then m_pNet[y+1,x+1].ud := wID;
      {if (rcItem.left<>rcItem.right) then block_lr(x,y);
      if (rcItem.top<>rcItem.bottom) then block_ud(x,y);}
    end;

  Result:=true;
end;

function TRoutePlanner.BlockRoute(Points:TPointsArray; wID1, wID2:cardinal):boolean;
var
  i:integer;
  rc:TRect;
  wID:cardinal;
begin
  Result:=false;
  if (wID1=0) or (wID2=0) then exit;
  if Length(Points)<3 then exit;

  wID:=((wID2 shl 16) + wID1)+ROUTE_ID_OFFSET;

  for i:=1 to Length(Points) - 3 do
  begin
    rc.Left:=Points[i].x; rc.Top:=Points[i].y;
    rc.Right:=Points[i+1].x; rc.Bottom:=Points[i+1].y;
    BlockEdge(rc, wID);
    //BlockNode(rc, wID);
  end;

  Result:=true;
end;

function TRoutePlanner.PlanRoute(ptSrc, ptDest:TPoint; wDestID1, wDestID2:cardinal; var pResult:TPointsArray; cchMax:integer):integer;
type
  TQueue = record
    x,y:cardinal;
  end;

var
  i,j,old_i,old_j:integer;
  ptS, ptD:TPoint;
  pNet:array of array of tsPlanNode;
  q:array of TQueue;
  iMaxQueueSize,qt,qh:integer;
  v,d,dt:cardinal;
  bFound:boolean;
  aPoints:array of TPoint;
  pt:TPoint;
  cDir,cLastDir:char;
  nPoints:integer;
  ptFirst:TPoint;

const
  // Support-points: Start- and end-point + the first leg of the start-line!
  NUM_SUPPORT_POINTS = 3;

  procedure explore_lr(i, j:integer);
  begin
    v := pNet[j,i].lr;
    if v=NODE_TARGET then bFound := true
    else if (v=NODE_OPEN) or (v and $0000FFFF=wDestID1) or (v and $FFFF0000=wDestID2) then
    begin
      pNet[j,i].lr := cardinal(d+1);
      q[qt].x := cardinal(i);
      q[qt].y := cardinal(j);
      inc(qt);
    end;
  end;

  procedure explore_ud(i, j:integer);
  begin
    v := pNet[j,i].ud;
    if v=NODE_TARGET then bFound := true
    else if (v=NODE_OPEN) or (v and $0000FFFF=wDestID1) or (v and $FFFF0000=wDestID2) then
    begin
        pNet[j,i].ud := cardinal(d+1);
        q[qt].x := cardinal(i);
        q[qt].y := cardinal(j);
        inc(qt);
    end;
  end;

begin
  Result:=0;

  inc(wDestID1, ROUTE_ID_OFFSET);
  wDestID2:=wDestID2 shl 16;

  ptS.x := ptSrc.x div m_iScale;
  ptS.y := ptSrc.y div m_iScale;

  ptD.x := (ptDest.x div m_iScale) - 2;
  ptD.y := ptDest.y div m_iScale;

  if (ptS.x<0) or (ptS.x>m_sizeMaze.cx-2) then exit;
  if (ptS.y<0) or (ptS.y>m_sizeMaze.cy-2) then exit;
  if (ptD.x<0) or (ptD.x>m_sizeMaze.cx-2) then exit;
  if (ptD.y<0) or (ptD.y>m_sizeMaze.cy-2) then exit;

  SetLength(pNet, m_sizeMaze.cy, m_sizeMaze.cx);
  for i:=0 to m_sizeMaze.cy-1 do
    Move(m_pNet[i][0], pNet[i][0], m_sizeMaze.cx*sizeof(tsPlanNode));

  pNet[ptS.y+1, ptS.x+1].lr := 0;
  pNet[ptS.y+1, ptS.x+1].ud := 0;
  pNet[ptD.y+1, ptD.x+1].lr := NODE_TARGET;
  pNet[ptD.y+1, ptD.x+1].ud := NODE_TARGET;

  iMaxQueueSize:=m_sizeMaze.cx * m_sizeMaze.cy * 2;
  SetLength(q, iMaxQueueSize);
  q[0].x := cardinal(ptS.x + 1);
  q[0].y := cardinal(ptS.y + 1);

  // Wave Propagation
  bFound := false;
  d:=0;
  qh:=0;
  qt:=1;
  i:=0;
  j:=0;
  v:=0;
  while not bFound and (qh<qt) and (qt<iMaxQueueSize-4) do
  begin
    i := q[qh].x;
    j := q[qh].y;
    inc(qh);
    d := Min(pNet[j,i].lr, pNet[j,i].ud);
    explore_lr(i + 1, j);
    explore_lr(i - 1, j);
    explore_ud(i, j + 1);
    explore_ud(i, j - 1);
  end;

  // Collect shortest route
  if bFound then
  begin
    pt.x:=i; pt.y:=j;
    cDir:='0';
    cLastDir := '0';
    while d > 0 do
    begin
      old_i := i;
      old_j := j;
      if (pNet[j+1,i].lr = d-1) and (pNet[j+1,i].ud < ROUTE_ID_OFFSET) then
      begin
        inc(j); dec(d); cDir := 'v';
      end
      else if pNet[j+1,i].ud = d-1 then
      begin
        inc(j); dec(d); cDir := 'v';
      end
      else if (pNet[j-1,i].lr = d-1) and (pNet[j-1,i].ud < ROUTE_ID_OFFSET) then
      begin
        dec(j); dec(d); cDir := 'v';
      end
      else if pNet[j-1,i].ud = d-1 then
      begin
        dec(j); dec(d); cDir := 'v';
      end
      else if pNet[j,i-1].lr = d-1 then
      begin
        dec(i); dec(d); cDir := 'h';
      end
      else if (pNet[j,i-1].ud = d-1) and (pNet[j,i-1].lr < ROUTE_ID_OFFSET) then
      begin
        dec(i); dec(d); cDir := 'h';
      end
      else if pNet[j,i+1].lr = d-1 then
      begin
        inc(i); dec(d); cDir := 'h';
      end
      else if (pNet[j,i+1].ud = d-1) and (pNet[j,i+1].lr < ROUTE_ID_OFFSET) then
      begin
        inc(i); dec(d); cDir := 'h';
      end
      else
        // No route to be found...
        break;

      if cDir<>cLastDir then
      begin
        // Change of diretion = new edge
        pt.x := old_i;
        pt.y := old_j;
        SetLength(aPoints, Length(aPoints)+1);
        with aPoints[Length(aPoints)-1] do
        begin
          x:=pt.x; y:=pt.y;
        end;
        cLastDir:=cDir;
      end;
    end;
  end;

  SetLength(q,0);
  SetLength(pNet,0,0);

  nPoints := 0;

  if not bFound or (d>0) or (Length(aPoints) > cchMax-NUM_SUPPORT_POINTS) then
  begin
     // Fails...
  end
  else
  begin
    ptFirst.x:=i;
    ptFirst.y:=j;
    pResult[nPoints] := ptSrc;
    inc(nPoints);
    pResult[nPoints] := ptFirst;
    inc(nPoints);
    for j := Length(aPoints) - 1 downto 0 do
    begin
      pResult[nPoints] := aPoints[j];
      inc(nPoints);
    end;
    pResult[nPoints] := ptDest;
    inc(nPoints);

    // Scale coords back to view-coords
    for i := 1 to nPoints - 2 do
      with pResult[i] do
      begin
        x := ((x - 1) * m_iScale) + 7;// + (m_iScale div 2) + 3;
        y := ((y - 1) * m_iScale);// + (m_iScale div 2) + 3;
      end;

    // Adjust the y-coord for the first few points so
    // they align with the start-point.
    if nPoints >= 3 then
       for i:=1 to 2 do
          if abs(pResult[i].y - ptSrc.y) < 4 then
             pResult[i].y := ptSrc.y;
  end;

  Result:=nPoints;
end;


end.

