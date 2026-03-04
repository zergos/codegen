//#property description "Советник сохраняет отчет о результатах тестирования [html + gif]"
//#property description "в формате отчета реальной истории сделок"
 
sinput bool   OrderByOpenTime = true;
int    FontSize = 7;     //размер шрифта для гафика, обычно 8-9 пунктов
string FontName = "Tahoma";
string BalanceHeader = "Баланс";
sinput color  bg = 0xF8F8F8;
extern int    ticketCounter=61819382;


//#property strict
#define OP_BALANCE 6
 
        // ширина рисунка для вызова  ChartScreenShot()
#define ScreenShotWidth  860
        // высота рисунка для вызова  ChartScreenShot()
#define ScreenShotHeight 240

        // имя файла шаблона, выходного ХТМЛ и картинки
#define TestFileName "DetailedStatement"


string dirname;
double equityMin;

void SaveTesterReport()
{
   dirname = "statements\\"+TimeToStr(TimeCurrent(),TIME_DATE)+"\\";
   drawChart();
   if(OrderByOpenTime)
      sortOrders();
   generateHTML();
}

//+------------------------------------------------------------------+
//| Cоздает прямоугольник по заданным координатам                    |
//+------------------------------------------------------------------+
bool RectangleCreate(const long            chart_ID=0,        // ID графика
                     const string          name="Rectangle",  // имя прямоугольника
                     const int             sub_window=0,      // номер подокна 
                     datetime              time1=0,           // время первой точки
                     double                price1=0,          // цена первой точки
                     datetime              time2=0,           // время второй точки
                     double                price2=0,          // цена второй точки
                     const color           clr=clrRed,        // цвет прямоугольника
                     const ENUM_LINE_STYLE style=STYLE_SOLID, // стиль линий прямоугольника
                     const int             width=1,           // толщина линий прямоугольника
                     const bool            fill=false,        // заливка прямоугольника цветом
                     const bool            back=false,        // на заднем плане
                     const bool            selection=false,    // выделить для перемещений
                     const bool            hidden=true,       // скрыт в списке объектов
                     const long            z_order=0)         // приоритет на нажатие мышью
{
//--- установим координаты точек привязки, если они не заданы
//   ChangeRectangleEmptyPoints(time1,price1,time2,price2);
//--- сбросим значение ошибки
   ResetLastError();
//--- создадим прямоугольник по заданным координатам
   if(!ObjectCreate(chart_ID,name,OBJ_RECTANGLE,sub_window,time1,price1,time2,price2))
     {
      Print(__FUNCTION__,
            ": не удалось создать прямоугольник! Код ошибки = ",GetLastError());
      return(false);
     }
//--- установим цвет прямоугольника
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- установим стиль линий прямоугольника
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- установим толщину линий прямоугольника
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- включим (true) или отключим (false) режим заливки прямоугольника
   ObjectSetInteger(chart_ID,name,OBJPROP_FILL,fill);
//--- отобразим на переднем (false) или заднем (true) плане
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- включим (true) или отключим (false) режим выделения прямоугольника для перемещений
//--- при создании графического объекта функцией ObjectCreate, по умолчанию объект
//--- нельзя выделить и перемещать. Внутри же этого метода параметр selection
//--- по умолчанию равен true, что позволяет выделять и перемещать этот объект
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- скроем (true) или отобразим (false) имя графического объекта в списке объектов
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- установим приоритет на получение события нажатия мыши на графике
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- успешное выполнение
   return(true);
}

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++//
void drawChart()
{
   ObjectsDeleteAll();
   Comment("");
   ChartSetInteger(0,CHART_COLOR_BACKGROUND, bg);
   ChartSetInteger(0,CHART_COLOR_FOREGROUND, bg);
   ChartSetInteger(0,CHART_SHOW_OHLC,0);
   ChartSetInteger(0,CHART_SHOW_BID_LINE,0);
   ChartSetInteger(0,CHART_SHOW_ASK_LINE,0);
   ChartSetInteger(0,CHART_SHOW_LAST_LINE,0);
   ChartSetInteger(0,CHART_SHOW_PERIOD_SEP,0);
   ChartSetInteger(0,CHART_SHOW_VOLUMES,0);
   ChartSetInteger(0,CHART_SHOW_GRID,false);
   ChartSetInteger(0,CHART_SHOW_GRID,0);
   ChartSetInteger(0,CHART_COLOR_CHART_LINE, clrBlue);
   ChartSetInteger(0,CHART_MODE,CHART_LINE);
   ChartSetInteger(0,CHART_SCALE,0);
   ChartNavigate(0,CHART_CURRENT_POS);
   
//--- отключим автопрокрутку графика
   ChartSetInteger(0,CHART_AUTOSCROLL,true);
//--- установим отступ правого края графика
   ChartSetInteger(0,CHART_SHIFT,false);
   
   ChartSetInteger(0,CHART_SCALEFIX, 1);
   ChartSetDouble(0,CHART_FIXED_MAX, 220);
   ChartSetDouble(0,CHART_FIXED_MIN, 1);
   

   int x, y;
   int totalTrades = (int)TesterStatistics(STAT_TRADES);
   double rulerXMax = totalTrades>32 ? totalTrades : 32;
   double stepX = rulerXMax/25.0;
   double low, high;
   double equity[];
   getEquityRange(low, high, equity);
   double bottomChartShift = 1.05;
   double range = (high - low)*bottomChartShift;
   if(low < (high*0.05))
   {
      bottomChartShift = 0;
      range = high;
   }
   double stepY = range/5.0;

   //Grid
   //Horizontal ruler
   double v=stepX;
   SetLabelText("gxv0", "0", 1, 181, clrBlack,0, FontName, FontSize);//минимальное значение шкалы
   for(x=46; x<814; x+=32, v+=stepX)
   {
      CreateLine("gx"+IntegerToString(x), x, 40, x, 220, 0xd0d0d0, 1, STYLE_DOT);//сетка
      CreateLine("gxr"+IntegerToString(x), x, 39, x, 40, clrBlack);//метки
      SetLabelText("gxv"+IntegerToString(x), DoubleToString(v,0), x-13, 181, clrBlack,0, FontName, FontSize,0,0, ANCHOR_RIGHT_UPPER);//значения шкалы
   }
   x-=32;
   SetLabelText("gxv"+IntegerToString(x), DoubleToString(rulerXMax,0), x-13, 181, clrBlack,0, FontName, FontSize,0,0, ANCHOR_RIGHT_UPPER); //максимальное значение шкалы

   //Vertical ruler
   SetLabelText("gyv0", DoubleToString(high,0), 776, 11, clrBlack,0, FontName, FontSize);//максимальное значение шкалы
   v=high-stepY;
   CreateLine("gyr", 42, 41, 43, 41, clrBlack); //метка
   for(y=73; y<220; y+=32, v-=stepY)
   {
      CreateLine("gy"+IntegerToString(y), 44, y, 813, y, 0xd0d0d0, 1, STYLE_DOT);//сетка
      CreateLine("gyr"+IntegerToString(y), 42, y, 43, y, clrBlack); //метка
      SetLabelText("gyv"+IntegerToString(y), DoubleToString(v,0), 776, y-30, clrBlack,0, FontName, FontSize);//значение шкалы
   }

   //Frame
   RectangleCreate(0,"frame",0,Time[43],40,Time[814],220,clrBlack);

   //label
   SetLabelText("BalanceHeader", BalanceHeader, 4, 3, clrBlack,0, FontName, FontSize);

   //BalanceHeader qurve
   int cnt = ArraySize(equity)-1;
   double kX = totalTrades>32 ? (770.0/cnt) : (770.0/32);
   double kY = 32.0*5/range;
   PrintFormat("kX=%.2f, kY=%.2f", kX, kY);
   for(int i=0; i<cnt;)
   {
      double a = equity[i++]-low+range*0.05;
      double b = equity[i]-low+range*0.05;
      int x1 = 814-(int)((i-1)*kX);
      double y1 = a*kY+40;
      int x2 = 814-(int)(i*kX);
      double y2 = b*kY+40;
      CreateLine("q"+IntegerToString(i), x1, y1, x2, y2, clrDarkBlue, 2);
      
      //PrintFormat("x:%d, y:%.1f; x2:%d, y2:%.1f", x1, y1, x2, y2);
   }


    ChartScreenShot(0,dirname+TestFileName+".gif",ScreenShotWidth,ScreenShotHeight,ALIGN_RIGHT);
 
   return;

}
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++//
void getEquityRange(double &low, double &high, double &equity[])
{
   int ordersHistoryCount = OrdersHistoryTotal();
   ArrayResize(equity, ordersHistoryCount+1);
   double balance = low = high =TesterStatistics(STAT_INITIAL_DEPOSIT);
   equity[0]=balance;
   int eq=0;
   for(int h=0; h<ordersHistoryCount;h++)
   {
      if(OrderSelect(h, SELECT_BY_POS, MODE_HISTORY))
      {
         if(OrderClosePrice()==0)
         {
            continue;
         }
      
         balance += OrderProfit();
         balance += OrderCommission();
         balance += OrderSwap();
         //balance += Taxes
         if(low>balance)  low = balance;
         if(high<balance) high = balance;
         equity[++eq]=balance;
      }
   }
   ArrayResize(equity, eq);
}
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++//
struct MiniOrder
{
   int ticket;
   datetime openTime;
   datetime closeTime;
   double lots;
   double profit;
   double comission;
   double swap;
};

MiniOrder mOrders[];

void sortOrders()
{
   int i, j, h;
   int ordersHistoryCount = OrdersHistoryTotal();
   ArrayResize(mOrders, ordersHistoryCount);
//- сбор данных из истории ордеров
   for(h=0; h<ordersHistoryCount; h++)
   {
      if(OrderSelect(h, SELECT_BY_POS, MODE_HISTORY))
      {
         mOrders[h].ticket = OrderTicket();
         mOrders[h].openTime = OrderOpenTime();
         mOrders[h].closeTime = OrderCloseTime();
         mOrders[h].lots = OrderLots();
         mOrders[h].profit = OrderProfit();
         mOrders[h].comission = OrderCommission();
         mOrders[h].swap = OrderSwap();
      }
   }
//- сортировка ордеров по времени открытия
   for(i=0; i<ordersHistoryCount; i++)
   {
      for(j=i; j<ordersHistoryCount; j++)
      {
         if(mOrders[i].openTime > mOrders[j].openTime)
         {
            MiniOrder tmp = mOrders[i];
            mOrders[i] = mOrders[j];
            mOrders[j] = tmp;
         }
      }
   }
}

double getEquityMin(bool calculate=false)
{
   int ordersHistoryCount = OrdersHistoryTotal();
//- проход по барам и вычисляем просадку по суммарному лоту + комиссия + спред
   double balance = TesterStatistics(STAT_INITIAL_DEPOSIT);
   double minEquity = balance;
   int firstBar = MathMin(iBarShift(_Symbol, _Period, mOrders[0].openTime), (Bars(_Symbol, _Period)-1));
   int firstOpenedOrder = 0;
   for(int i=firstBar; i>=0; i--)
   {
      double dd=0;
      for(int h=firstOpenedOrder; h < ordersHistoryCount && mOrders[h].openTime <= Time[i]; h++)
      {
         if(mOrders[h].closeTime == Time[i])
         {
            balance += mOrders[h].profit;
            balance += mOrders[h].comission;
            balance += mOrders[h].swap;
         }
         else
         if(mOrders[h].openTime <= Time[i] && Time[i] < mOrders[h].closeTime)
         {
            dd += OrderLots() * MarketInfo(OrderSymbol(), MODE_TICKVALUE)
                              * (OrderOpenPrice()-Low[i])
                              + OrderCommission();
         }
      }
      if(minEquity > (balance - dd))
         minEquity = balance - dd;
         
      while(firstOpenedOrder < ordersHistoryCount && mOrders[firstOpenedOrder].closeTime <= Time[i]) firstOpenedOrder++;
   }
//- возвращаем наименьшее значение
   return minEquity;
}
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++//

//+------------------------------------------------------------------+
//|  автор: Pozitif        mail: alex-w-@bk.ru                       |
//+------------------------------------------------------------------+
//| Создаёт текстовую метку                                          |
//+------------------------------------------------------------------+
//| параметры:                                                       |
//|   id  - идентификатор метки (уникальное имя)                     |
//|   tx  - текст метки                                              |
//|   x   - координата в пикселях, по горизонтали                    |
//|   y   - координата в пикселях по вертикали                       |
//|   cl  - цвет                                                     |
//|   bd  - Binding, угол привязки объекта 0-3                       |
//|   ft  - шрифт                                                    |
//|   sz  - размер шрифта                                            |
//|   wd  - номер окна в котором создавать метку                     |
//|   rt  - вращение объекта в градусах                              |
//+------------------------------------------------------------------+
void SetLabelText(string id, string tx, int x, int y, color cl=Black, int bd=0, string ft="Georgia", int sz=12, int wd=0, int rt=0, int anchor=ANCHOR_LEFT_UPPER){
   //--- Если метка уже есть но не переданы координаты то удаляем ---
   if(tx!="NULL"){
      if(ObjectFind(id)<0)ObjectCreate(id, OBJ_LABEL, wd, 0, 0);
      ObjectSetText(id, tx, sz, ft, cl);
      ObjectSet(id, OBJPROP_CORNER, bd);
      ObjectSet(id, OBJPROP_XDISTANCE, x);
      ObjectSet(id, OBJPROP_YDISTANCE, y);
      ObjectSet(id, OBJPROP_ANGLE,rt);
      ObjectSet(id, OBJPROP_ANCHOR, anchor);
   }else{
      if(tx=="NULL"&&ObjectFind(id)>=0)ObjectDelete(id);
   }
}  
  

//+------------------------------------------------------------------+
void CreateLine(string name, int x0, double y0, int x1, double y1, int clr, int width=1, int style=STYLE_SOLID, bool ray=false)
{
   //y0/=2;
   //y1/=2;
   ObjectCreate(name,OBJ_TREND,0,Time[x0],y0,Time[x1], y1);
   ObjectSet(name,OBJPROP_RAY,ray);
   ObjectSet(name,OBJPROP_COLOR,clr);
   ObjectSet(name,OBJPROP_STYLE,style);
   ObjectSet(name,OBJPROP_WIDTH, width);
}

string month[] = {"January","February","March","April","May","June","July","August","September","October","November","December"};

void generateHTML()
{
   double sumComission=0, sumTax=0, sumSwap=0, sumProfit=0, closedPL=0, minBalance=AccountBalance();
   int fin = FileOpen("Statements\\"+TestFileName+".tmpl", FILE_ANSI|FILE_READ|FILE_TXT);
   if(fin!=INVALID_HANDLE)
   {
      int fout = FileOpen(dirname+TestFileName+".htm", FILE_ANSI|FILE_WRITE|FILE_TXT);
      if(fout!=INVALID_HANDLE)
      {
         while(!FileIsEnding(fin))
         {
            string sValue;
            string s = FileReadString(fin);

            if(s == "[CompanyName:]")
            {
               FileWrite(fout, "<div style=\"font: 20pt Times New Roman\"><b>"+AccountCompany()+"</b></div><br>");
            }
            else if(s == "[Statement:]")
            {
               FileWrite(fout, "    <title>Statement: ",AccountNumber()," - ", AccountName(),"</title>");
            }
            else if(s == "[Account:]")
            {
               FileWrite(fout, "    <td colspan=2><b>Account: "+IntegerToString(AccountNumber())+"</b></td>");
            }
            else if(s == "[Name:]")
            {
               FileWrite(fout, "    <td colspan=5><b>Name: "+AccountName()+"</b></td>");
            }
            else if(s == "[Currency:]")
            {
               FileWrite(fout, "    <td colspan=2><b>Currency: "+AccountCurrency()+"</b></td>");
            }
            else if(s == "[Leverage:]")
            {
               FileWrite(fout, "    <td colspan=2><b>Leverage: 1:"+AccountLeverage()+"</b></td>");
            }
            else if(s == "[Fulltime:]")
            {
               MqlDateTime  dt;
               TimeToStruct(TimeCurrent(), dt);
               FileWrite(fout, "    <td colspan=3 align=right><b>"+ StringFormat("%d %s %02d, %02d:%02d",dt.year, month[dt.mon-1], dt.day, dt.hour, dt.min)+"</b></td></tr>");
            }
            else if(s == "[Closed Transactions:]")
            {
               double lastKnownPrice=0;
               datetime lastOpenTime=0;
               //запишем начальный баланс,
               // тикет = первый в списке - 12345
               // дата = первая в списке - 12345 секунд
               if(OrderSelect(0, SELECT_BY_POS, MODE_HISTORY)) 
               {
                  FileWrite(fout, StringFormat("<tr align=right><td>%d</td><td nowrap>%s</td><td>balance</td><td colspan=10 align=left></td><td class=mspt>%000 000 000.2f</td></tr>",
                            ticketCounter, TimeToStr(OrderOpenTime()-rand()%123*100,TIME_DATE|TIME_MINUTES|TIME_SECONDS), TesterStatistics(STAT_INITIAL_DEPOSIT)));
                            ticketCounter+=rand()%123;
                            lastOpenTime = OrderOpenTime();
               }
               int ordersHistoryCount = OrdersHistoryTotal();
                     //FileWrite(fout, "<tr %s ><td title=\"%s\">%d</td><td class=msdate nowrap>%s</td><td>%s</td><td colspan=10 align=left>Deposit WM USD 8990393</td><td class=mspt>300.00</td></tr>",
                       //             h%2?"bgcolor=#E0E0E0 ":"", OrderComment(), OrderTicket(), TimeToStr(OrderOpenTime()),OrderType()==OP_BUY?"buy":"sell",
               for(int h=0; h<ordersHistoryCount; h++)
               {
                  
                  if((OrderByOpenTime && OrderSelect(mOrders[h].ticket, SELECT_BY_TICKET)) || OrderSelect(h, SELECT_BY_POS, MODE_HISTORY))
                  //if(OrderSelect(h, SELECT_BY_POS, MODE_HISTORY))
                  {
                     string sym = OrderSymbol();
                     string _sym = sym;
                     StringToLower(_sym);
                     sumComission += OrderCommission();
                     //sumTax+=
                     sumSwap += OrderSwap();
                     sumProfit += OrderProfit();
                     int op=OrderType();
                     string sOp;
                     switch(op)
                     {
                        case OP_BUY: sOp="buy"; break;
                        case OP_SELL: sOp="sell"; break;
                        case OP_BUYSTOP: sOp="buystop"; break;
                        case OP_SELLSTOP: sOp="sellstop"; break;
                        case OP_SELLLIMIT: sOp="selllimit"; break;
                        case OP_BUYLIMIT: sOp="buylimit"; break;
                        case OP_BALANCE: sOp="balance"; break;
                     }
                     
                      ticketCounter += fabs(OrderOpenTime()-lastOpenTime)+1;
                      
                     //<tr align=right><td title="#1          ">277428430</td><td class=msdate nowrap>2015.05.04 16:04:08</td><td>buy      </td><td class=mspt>0.01</td><td>eurusd</td><td style="mso-number-format:0\.00000;">1.11807</td><td style="mso-number-format:0\.00000;">0.00000</td><td style="mso-number-format:0\.00000;">1.11689</td><td class=msdate nowrap>2015.05.05 00:29:35</td><td style="mso-number-format:0\.00000;">1.11471</td><td class=mspt>0.00</td><td class=mspt>0.00</td><td class=mspt>-0.04</td><td class=mspt>-3.36</td></tr>
                     //<tr align=right><td title="#1 cancelled">277378931</td><td class=msdate nowrap>2015.05.04 10:16:37</td><td>buy limit</td><td class=mspt>0.09</td><td>eurusd</td><td style="mso-number-format:0\.00000;">1.10271</td><td style="mso-number-format:0\.00000;">0.00000</td><td style="mso-number-format:0\.00000;">1.11599</td><td class=msdate nowrap>2015.05.04 15:22:05</td><td style="mso-number-format:0\.00000;">1.11594</td><td colspan=4>cancelled</td></tr>
                     
                     //<tr align=right><td title="Deposit WM USD 8990393">61819364</td><td class=msdate nowrap>2014.09.24 12:02:40</td><td>balance</td><td colspan=10 align=left>Deposit WM USD 8990393</td><td class=mspt>300.00</td></tr>
                     //<tr align=right><td title="Deposit">253892122</td><td class=msdate nowrap>2014.11.18 19:02:33</td><td>balance</td><td colspan=10 align=left>Deposit</td><td class=mspt>50 000.00</td></tr>
                     //<tr align=right><td title="IR">255573340</td><td class=msdate nowrap>2014.12.01 00:00:57</td><td>balance</td><td colspan=10 align=left>IR</td><td class=mspt>17.49</td></tr>
                     if(op == OP_BALANCE)
                        FileWrite(fout, StringFormat("<tr %salign=right><td title=\"%s\">%d</td><td class=msdate nowrap>%s</td><td>%s</td><td colspan=10 align=left>%s</td><td class=mspt>%.2f</td></tr>",
                                  h%2==0?"bgcolor=#E0E0E0 ":"", OrderComment(), ticketCounter/*+OrderTicket()*/, TimeToStr(OrderOpenTime(),TIME_DATE|TIME_MINUTES|TIME_SECONDS), sOp, OrderProfit()));
                     else if(OrderCloseTime() != 0 && OrderClosePrice() == 0) // Cancelled order
                        FileWrite(fout, StringFormat("<tr %salign=right><td title=\"%s\">%d</td><td class=msdate nowrap>%s</td><td>%s</td><td class=mspt>%.2f</td><td>%s</td><td style=\"mso-number-format:0\.000;\">%s</td><td style=\"mso-number-format:0\.000;\">%s</td><td style=\"mso-number-format:0\.000;\">%s</td><td class=msdate nowrap>%s</td><td style=\"mso-number-format:0\.000;\">%s</td><td colspan=4>cancelled</td></tr>",
                                  h%2==0?"bgcolor=#E0E0E0 ":"", OrderComment(), ticketCounter/*+OrderTicket()*/, TimeToStr(OrderOpenTime(),TIME_DATE|TIME_MINUTES|TIME_SECONDS),
                                  sOp, OrderLots(), _sym,
                                  DoubleToStr(OrderOpenPrice(), (int)MarketInfo(sym, MODE_DIGITS)),
                                  DoubleToStr(OrderStopLoss(), (int)MarketInfo(sym, MODE_DIGITS)), 
                                  DoubleToStr(OrderTakeProfit(), (int)MarketInfo(sym, MODE_DIGITS)),
                                  TimeToStr(OrderCloseTime(),TIME_DATE|TIME_MINUTES|TIME_SECONDS),
                                  DoubleToStr(lastKnownPrice, (int)MarketInfo(sym, MODE_DIGITS))));
                     else{
                        FileWrite(fout, StringFormat("<tr %salign=right><td title=\"%s\">%d</td><td class=msdate nowrap>%s</td><td>%s</td><td class=mspt>%.2f</td><td>%s</td><td style=\"mso-number-format:0\.000;\">%s</td><td style=\"mso-number-format:0\.000;\">%s</td><td style=\"mso-number-format:0\.000;\">%s</td><td class=msdate nowrap>%s</td><td style=\"mso-number-format:0\.000;\">%s</td><td class=mspt>%.2f</td><td class=mspt>0.00</td><td class=mspt>%.2f</td><td class=mspt>%.2f</td></tr>",
                                  h%2==0?"bgcolor=#E0E0E0 ":"", OrderComment(), ticketCounter/*+OrderTicket()*/, TimeToStr(OrderOpenTime(),TIME_DATE|TIME_MINUTES|TIME_SECONDS),
                                  sOp, OrderLots(), _sym,
                                  DoubleToStr(OrderOpenPrice(), (int)MarketInfo(sym, MODE_DIGITS)),
                                  DoubleToStr(OrderStopLoss(), (int)MarketInfo(sym, MODE_DIGITS)), 
                                  DoubleToStr(OrderTakeProfit(), (int)MarketInfo(sym, MODE_DIGITS)),
                                  TimeToStr(OrderCloseTime(),TIME_DATE|TIME_MINUTES|TIME_SECONDS),
                                  DoubleToStr(OrderClosePrice(), (int)MarketInfo(sym, MODE_DIGITS)),
                                  OrderCommission(), /*Taxes, */OrderSwap(), OrderProfit()));
                     }
                     //double los = OrderLots()*MarketInfo(OrderSymbol(), MODE_TICKVALUE)*MarketInfo(OrderSymbol(), MODE_SPREAD);
                     //PrintFormat("OrderLots(%.2f)*MarketInfo(OrderSymbol(), MODE_TICKVALUE)(%.2f)*MarketInfo(OrderSymbol(), MODE_SPREAD)(%.2f);", 
                       //           OrderLots(), MarketInfo(OrderSymbol(), MODE_TICKVALUE), MarketInfo(OrderSymbol(), MODE_SPREAD));
                      lastKnownPrice = OrderClosePrice();
                      lastOpenTime = OrderOpenTime();
                  }
               }
               closedPL = sumComission + sumTax + sumSwap + sumProfit;
            }
            else if(s == "[sumComission:]")
            {
               FileWrite(fout, "    <td class=mspt>"+DoubleToStr(sumComission,2)+"</td>");
            }
            else if(s == "[sumTax:]")
            {
               FileWrite(fout, "    <td class=mspt>"+DoubleToStr(sumTax,2)+"</td>");
            }
            else if(s == "[sumSwap:]")
            {
               FileWrite(fout, "    <td class=mspt>"+DoubleToStr(sumSwap,2)+"</td>");
            }
            else if(s == "[sumProfit:]")
            {
               FileWrite(fout, "    <td class=mspt>"+DoubleToStr(sumProfit,2)+"</td>");
            }
            else if(s == "[closedPL:]")
            {
               FileWrite(fout, "    <td colspan=2 align=right title=\"Commission + Swap + Profit + Taxes\" class=mspt><b>"+DoubleToStr(closedPL,2)+"</b></td>");
            }
            else if(s == "[DepositWithdrawal:]")
            {
               FileWrite(fout, "    <td colspan=2 class=mspt><b>"+DoubleToStr(TesterStatistics(STAT_INITIAL_DEPOSIT)+TesterStatistics(STAT_WITHDRAWAL),2)+"</b></td>");
            }
            else if(s == "[ClosedTradePL:]")
            {
               FileWrite(fout, "    <td colspan=2 class=mspt><b>"+DoubleToStr(closedPL,2)+"</b></td>");
            }
            else if(s == "[Balance:]")
            {
               FileWrite(fout, "    <td colspan=2 class=mspt><b>"+DoubleToStr(AccountBalance(),2)+"</b></td>");
            }
            else if(s == "[Equity:]")
            {
               FileWrite(fout, "    <td class=mspt><b>"+DoubleToStr(AccountEquity(),2)+"</b></td>");
            }
            else if(s == "[FreeMargin:]")
            {
               FileWrite(fout, "    <td colspan=2 class=mspt><b>"+DoubleToStr(AccountFreeMargin(),2)+"</b></td></tr>");
            }
            else if(s == "[img:]")
            {
               FileWrite(fout, StringFormat("	<img src=\"%s.gif\" width=%d height=%d border=0 alt=\"Graph\"></b></td>", TestFileName, ScreenShotWidth, ScreenShotHeight));
            }
            else if(s == "[GrossProfit:]")
            {
               FileWrite(fout, "    <td colspan=2 class=mspt><b>"+DoubleToStr(TesterStatistics(STAT_GROSS_PROFIT),2)+"</b></td>");
            }
            else if(s == "[GrossLoss:]")
            {
               FileWrite(fout, "    <td class=mspt><b>"+DoubleToStr(TesterStatistics(STAT_GROSS_LOSS),2)+"</b></td>");
            }
            else if(s == "[TotalNetProfit:]")
            {
               FileWrite(fout, "    <td colspan=2 class=mspt><b>"+DoubleToStr(TesterStatistics(STAT_PROFIT),2)+"</b></td></tr>");
            }
            else if(s == "[ProfitFactor:]")
            {
               string pf="";
               if(TesterStatistics(STAT_GROSS_LOSS)!=0) pf = DoubleToStr(TesterStatistics(STAT_PROFIT_FACTOR),2);
               FileWrite(fout, "    <td colspan=2 class=mspt><b>"+pf+"</b></td>");
            }
            else if(s == "[ExpectedPayoff:]")
            {
               FileWrite(fout, "    <td class=mspt><b>"+DoubleToStr(TesterStatistics(STAT_EXPECTED_PAYOFF),2)+"</b></td>");
            }
            else if(s == "[AbsoluteDrawdown:]")
            {
               double em = TesterStatistics(STAT_EQUITYMIN);
               if(em == 0) em = getEquityMin();
               double absDD = TesterStatistics(STAT_INITIAL_DEPOSIT) - em;
               FileWrite(fout, "    <td colspan=2 class=mspt><b>"+DoubleToStr(absDD,2)+"</b></td>");
            }
            else if(s == "[MaximalDrawdown:]")
            {
               string maxdd = StringFormat("%.2f (%.2f%%)",TesterStatistics(STAT_EQUITY_DD),TesterStatistics(STAT_EQUITYDD_PERCENT));
               FileWrite(fout, "    <td class=mspt><b>"+maxdd+"</b></td>");
            }
            else if(s == "[RelativeDrawdown:]")
            {
               string reldd = StringFormat("%.2f%% (%.2f)",TesterStatistics(STAT_EQUITY_DDREL_PERCENT),TesterStatistics(STAT_EQUITY_DD_RELATIVE));
               FileWrite(fout, "    <td colspan=2 class=mspt><b>"+reldd+"</b></td></tr>");
            }
            else if(s == "[TotalTrades:]")
            {
               FileWrite(fout, "    <td colspan=2 class=mspt><b>"+IntegerToString((int)TesterStatistics(STAT_TRADES))+"</b></td>");
            }
            else if(s == "[ShortPositions:]")
            {
               sValue = TesterStatistics(STAT_SHORT_TRADES)>0
                      ? StringFormat("%d (%.2f%%)",(int)TesterStatistics(STAT_SHORT_TRADES),TesterStatistics(STAT_PROFIT_SHORTTRADES)/TesterStatistics(STAT_SHORT_TRADES)*100)
                      : "00.0(0.00%)";
               FileWrite(fout, "    <td class=mspt><b>"+sValue+"</b></td>");
            }
            else if(s == "[LongPositions:]")
            {
               sValue = TesterStatistics(STAT_LONG_TRADES)>0
                      ? StringFormat("%d (%.2f%%)",(int)TesterStatistics(STAT_LONG_TRADES),TesterStatistics(STAT_PROFIT_LONGTRADES)/TesterStatistics(STAT_LONG_TRADES)*100)
                      : "00.0(0.00%)";
               FileWrite(fout, "    <td colspan=2 class=mspt><b>"+sValue+"</b></td></tr>");
            }
            else if(s == "[ProfitTrades:]")
            {
               sValue = TesterStatistics(STAT_TRADES)>0
                      ? StringFormat("%d (%.2f%%)",(int)TesterStatistics(STAT_PROFIT_TRADES),TesterStatistics(STAT_PROFIT_TRADES)/TesterStatistics(STAT_TRADES)*100)
                      : "00.0(0.00%)";
               FileWrite(fout, "    <td class=mspt><b>"+sValue+"</b></td>");
            }
            else if(s == "[Losstrades:]")
            {
               sValue = TesterStatistics(STAT_TRADES)>0
                      ? StringFormat("%d (%.2f%%)",(int)TesterStatistics(STAT_LOSS_TRADES),TesterStatistics(STAT_LOSS_TRADES)/TesterStatistics(STAT_TRADES)*100)
                      : "00.0(0.00%)";
               FileWrite(fout, "    <td colspan=2 class=mspt><b>"+sValue+"</b></td>");
            }
            else if(s == "[LargestProfitTrades:]")
            {
               FileWrite(fout, "    <td class=mspt><b>"+DoubleToStr(TesterStatistics(STAT_MAX_PROFITTRADE),2)+"</b></td>");
            }
            else if(s == "[LargestLossTrades:]")
            {
               FileWrite(fout, "    <td colspan=2 class=mspt><b>"+DoubleToStr(TesterStatistics(STAT_MAX_LOSSTRADE),2)+"</b></td></tr>");
            }
            else if(s == "[AvarageProfitTrades:]")
            {
               double AvarageProfitTrades = 0;
               if(TesterStatistics(STAT_PROFIT_TRADES)!=0) AvarageProfitTrades = TesterStatistics(STAT_GROSS_PROFIT)/TesterStatistics(STAT_PROFIT_TRADES);
               FileWrite(fout, "    <td class=mspt><b>"+DoubleToStr(AvarageProfitTrades,2)+"</b></td>");
            }
            else if(s == "[AvarageLossTrades:]")
            {
               double AvarageLossTrades = 0;
               if(TesterStatistics(STAT_LOSS_TRADES)!=0) AvarageLossTrades = TesterStatistics(STAT_GROSS_LOSS)/TesterStatistics(STAT_LOSS_TRADES);
               FileWrite(fout, "    <td colspan=2 class=mspt><b>"+DoubleToStr(AvarageLossTrades,2)+"</b></td></tr>");
            }
            else if(s == "[MaximumConsecutiveWins:]")
            {
               sValue = StringFormat("%d (%.2f)", (int)TesterStatistics(STAT_MAX_CONPROFIT_TRADES), TesterStatistics(STAT_MAX_CONWINS));
               FileWrite(fout, "    <td class=mspt><b>"+sValue+"</b></td>");
            }
            else if(s == "[MaximumConsecutiveLosses:]")
            {
               sValue = StringFormat("%d (%.2f)", (int)TesterStatistics(STAT_MAX_CONLOSS_TRADES), TesterStatistics(STAT_MAX_CONLOSSES));
               FileWrite(fout, "    <td colspan=2 class=mspt><b>"+sValue+"</b></td></tr>");
            }
            else if(s == "[MaximalConsecutiveProfit:]")
            {
               sValue = StringFormat("%.2f (%d)", TesterStatistics(STAT_CONPROFITMAX), (int)TesterStatistics(STAT_CONPROFITMAX_TRADES));
               FileWrite(fout, "    <td class=mspt><b>"+sValue+"</b></td>");
            }
            else if(s == "[MaximalConsecutiveLoss:]")
            {
               sValue = StringFormat("%.2f (%d)", TesterStatistics(STAT_CONLOSSMAX), (int)TesterStatistics(STAT_CONLOSSMAX_TRADES));
               FileWrite(fout, "    <td colspan=2 class=mspt><b>"+sValue+"</b></td></tr>");
            }
            else if(s == "[AverageConsecutiveWins:]")
            {
               FileWrite(fout, "    <td class=mspt><b>"+DoubleToStr(TesterStatistics(STAT_PROFITTRADES_AVGCON),0)+"</b></td>");
            }
            else if(s == "[AverageConsecutiveLosses:]")
            {
               FileWrite(fout, "    <td colspan=2 class=mspt><b>"+DoubleToStr(TesterStatistics(STAT_LOSSTRADES_AVGCON),0)+"</b></td></tr>");
            }
            
            else
               FileWrite(fout, s);
         }
         FileClose(fout);
      }
      else PrintFormat("Can't open file "+dirname+TestFileName+".htm to write, %d", GetLastError());
      
      FileClose(fin);
   }
   else PrintFormat("Can't open file Statements\\"+TestFileName+".tmpl to read, %d", GetLastError());
}