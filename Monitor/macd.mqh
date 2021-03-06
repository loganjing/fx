//+------------------------------------------------------------------+
//|                                                         macd.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include <Monitor/common.mqh>



//result to store macd & signal value for divergence.
double macd[MAXCOUNT+5];
double signal[MAXCOUNT+5];
//array to store result for every calculation
double lastMKHigh[];
double lastMKLow[];
datetime lastMCalcTime[];
datetime lastMAlertTime[];
void alertWhenMACDDivergence(string symbol,int period,string msg,int index,int startIndex,string& notifyMsg){
   //has calculated
   double hValue = iHigh(symbol,period,startIndex);
   double lValue = iLow(symbol,period,startIndex);
   datetime time = iTime(symbol,period,startIndex);
   if(lastMKHigh[index] == hValue && lastMKLow[index] == lValue && lastMCalcTime[index] == time){
       return;
   }
   delAllMACDObject();
   initMACDValue(symbol,period,startIndex);
   int count = MAXCOUNT - 5;
   for(int i=1;i<count;i++){
      bool peak = isMACDPeak(i);
      if(peak){
         //printf("macd peak:"+i);
         //DrawArrow(Time[i],signal[i],Yellow,STYLE_SOLID,"DOWN",true);
         int prevPeak = findPrevMACDPeak(i);
         if(prevPeak>-1){
            double iValue = iHigh(symbol,period,i);
            double prevValue = iHigh(symbol,period,prevPeak);
            //printf("macd peak:"+prevPeak);
            //当前波峰的macd值小于前一个波峰的macd值，但是当前k线的最高值却大于前一个波峰k线的最大值，认为是一个顶背离态势。
            if(signal[i]<signal[prevPeak] && iValue>prevValue && (signal[i]>=0||signal[prevPeak]>=0)){
              //printf("传统顶背离态势发生: ",i+msg);
              drawMACDTrendLine(iTime(symbol,period,i+startIndex),iTime(symbol,period,prevPeak+startIndex),signal[i],signal[prevPeak],peakColor,STYLE_SOLID,symbol,period);
              //最新计算的K线是从0开始的。
              recordMACDDivResultAndAlert(i+startIndex,index,symbol,period,"发生了MACD顶背离,"+msg,startIndex,notifyMsg);
            }
            //当前波峰的macd值大于前一个波峰的macd值，但是当前k线的最高值却小于前一个波峰k线的最大值，认为是一个顶背离态势。  
            if(signal[i]>signal[prevPeak] && iValue<prevValue && (signal[i]>=0||signal[prevPeak]>=0)){
              //printf("反转顶背离态势发生: ",i+msg);
              //DrawArrow(Time[currentShift],signal[currentShift],Black,STYLE_SOLID,"DOWN");
              drawMACDTrendLine(iTime(symbol,period,i+startIndex),iTime(symbol,period,prevPeak+startIndex),signal[i],signal[prevPeak],peakColor,STYLE_SOLID,symbol,period);
              recordMACDDivResultAndAlert(i+startIndex,index,symbol,period,"发生了MACD顶背离,"+msg,startIndex,notifyMsg);
            }
         }
      }
      
      bool trough = isMACDTrough(i);
      if(trough){
         //printf("macd trough:"+i);
         //DrawArrow(Time[i],signal[i],Green,STYLE_SOLID,"UP",true);
         int prevTrough = findPrevMACDTrough(i);
         if(prevTrough > -1){
            double iValue = iLow(symbol,period,i);
            double prevValue = iLow(symbol,period,prevTrough);
            //printf("macd trough:"+prevTrough);
            //yes, find a trough
            if(signal[i]>signal[prevTrough] && iValue<prevValue && (signal[i]<=0||signal[prevTrough]<=0)){
               //printf("传统底背离态势发生: ",i+msg);
               drawMACDTrendLine(iTime(symbol,period,i+startIndex),iTime(symbol,period,prevTrough+startIndex),signal[i],signal[prevTrough],troughColor,STYLE_SOLID,symbol,period);
               recordMACDDivResultAndAlert(i+startIndex,index,symbol,period,"发生了MACD底背离,"+msg,startIndex,notifyMsg);
            }
            
            if(signal[i]<signal[prevTrough] && iValue>prevValue && (signal[i]<=0||signal[prevTrough]<=0)){
               //printf("反转底背离态势发生: ",i+msg);
               drawMACDTrendLine(iTime(symbol,period,i+startIndex),iTime(symbol,period,prevTrough+startIndex),signal[i],signal[prevTrough],troughColor,STYLE_SOLID,symbol,period);
               recordMACDDivResultAndAlert(i+startIndex,index,symbol,period,"发生了MACD底背离,"+msg,startIndex,notifyMsg);
            }
         }
      }
   }
}

void recordMACDDivResultAndAlert(int shift,int index,string symbol,int period,string msg,int startIndex,string& notifyMsg){
   lastMKHigh[index] = iHigh(symbol,period,startIndex);
   lastMKLow[index] = iLow(symbol,period,startIndex);
   lastMCalcTime[index] = iTime(symbol,period,startIndex);
   if(iTime(symbol,period,shift) > lastMAlertTime[index]){
       lastMAlertTime[index] =iTime(symbol,period,shift);
       addToMsg(notifyMsg,StringConcatenate(iTime(symbol,period,shift),"-->",symbol,getPeriodLabel(period),msg,",当前价格:"+MarketInfo(symbol,MODE_ASK)),shift);
   }
}


//array to store macd cross zero result.
string macdZero[];
void alertWhenCrossMacdZero(string symbol,int period,string msg,int index,int shift,string& notifyMsg){
   bool isTesting = shift > 0;
   double main = iMACD(symbol,period,QUICKEMA,SLOWEMA,MACDSMA,PRICE_CLOSE,MODE_SIGNAL,shift);
   string flag = macdZero[index];
   if(main<0 && flag==UP){
      macdZero[index] = DOWN;
      addToMsg(notifyMsg,StringConcatenate(iTime(symbol,period,shift),"-->",symbol,getPeriodLabel(period),"的MACD向下穿越0轴， ",msg,",当前价格:"+MarketInfo(symbol,MODE_ASK)),shift);
   }
   if(main>0 && flag==DOWN){
      macdZero[index] =UP;
      addToMsg(notifyMsg,StringConcatenate(iTime(symbol,period,shift),"-->",symbol,getPeriodLabel(period),"的MACD向上穿越0轴， ",msg,",当前价格:"+MarketInfo(symbol,MODE_ASK)),shift);
   }
}


void initMACDParams(int macdZeroSize,int macdDivergenceSize){
   initFlags(macdZero,macdZeroSize,DOWN);
   //背离的结果数组初始化
   initDateTimeArray(lastMAlertTime,macdDivergenceSize);
   initDateTimeArray(lastMCalcTime,macdDivergenceSize);
   initDoubleArray(lastMKHigh,macdDivergenceSize);
   initDoubleArray(lastMKLow,macdDivergenceSize);
}

void initMACDValue(string symbol,int period,int shift){
   //计算向前4个K线的MACD值
   int count = MAXCOUNT+shift;
   ArrayResize(macd,count);
   ArrayResize(signal,count);
   for(int i=0;i<count;i++){
      macd[i]=iMACD(symbol,period,QUICKEMA,SLOWEMA,MACDSMA,PRICE_CLOSE,MODE_MAIN,i+shift);
      signal[i]=iMACD(symbol,period,QUICKEMA,SLOWEMA,MACDSMA,PRICE_CLOSE,MODE_SIGNAL,i+shift);
   }
}

int findPrevMACDTrough(int shift){
   int count = MAXCOUNT-3;
   for(int i=shift+5;(i<count) && (i>1); i++)
     {
      if(signal[i] <= signal[i+1] && signal[i] <= signal[i+2] &&
         signal[i] <= signal[i-1] && signal[i] <= signal[i-2])
        {
          /** 
           for(int j=i;(j<MAXCOUNT-3) && (j>1); j++)
           {
            if(macd[j] <= macd[j+1] && macd[j] < macd[j+2] &&
               macd[j] <= macd[j-1] && macd[j] < macd[j-2])
               return(j);
           }**/
           return i;
        }
     }
   return(-1);
}

int findPrevMACDPeak(int shift){
   int count = MAXCOUNT-3;
   for(int i=shift+5;(i<count) && (i>1); i++)
     {
      if(signal[i] >= signal[i+1] && signal[i] >= signal[i+2] &&
         signal[i] >= signal[i-1] && signal[i] >= signal[i-2])
        {
           /**
           for(int j=i;(j<MAXCOUNT-3) && (j>1); j++)
           {
            if(macd[j] >= macd[j+1] && macd[j] > macd[j+2] &&
               macd[j] >= macd[j-1] && macd[j] > macd[j-2])
               return(j);
           }**/
           return i;
        }
     }
   return(-1);
}



//+------------------------------------------------------------------+
//| 是否是macd的顶端，判断条件：当前K线的macd值大于前2个k线，同时也大于后两个k线                                                                 |
//+------------------------------------------------------------------+
bool isMACDPeak(int shift){
   if(signal[shift]>=signal[shift+1] && signal[shift]>signal[shift+2] && 
      signal[shift]>signal[shift-1])
      return(true);
   else
      return(false);
}

//+------------------------------------------------------------------+
//| 是否是macd的谷底，判断条件：当前K线的macd值小于前2个k线，同时也小于后两个k线                                                                 |
//+------------------------------------------------------------------+
bool isMACDTrough(int shift){
   if(signal[shift]<=signal[shift+1] && signal[shift]<signal[shift+2] && 
      signal[shift]<signal[shift-1])
      return(true);
   else
      return(false);
}

void delAllMACDObject(){
  for(int i=ObjectsTotal()-1; i>=0; i--)
  {
   string label=ObjectName(i);
   if(StringSubstr(label,0,19)=="MACD_DivergenceLine"){
      ObjectDelete(label);
   }
   if(StringSubstr(label,0,20)=="Arrow_DivergenceLine"){
      ObjectDelete(label);
   }
   if(StringSubstr(label,0,9)=="Arrow_Tip"){
      ObjectDelete(label);
   }
  }
}


static string macdIndicatorName ="MACD("+IntegerToString(QUICKEMA)+","+IntegerToString(SLOWEMA)+","+IntegerToString(MACDSMA)+")";
void drawMACDTrendLine(datetime x1,datetime x2,double y1,double y2,color lineColor,double style,string symbol,int period){
   if(symbol == Symbol() && period == Period()){
      int indicatorWindow=WindowFind(macdIndicatorName);
      if(indicatorWindow<0)
         return;
      string label="MACD_DivergenceLine$# "+DoubleToStr(x1,0);
      ObjectDelete(label);
      ObjectCreate(label,OBJ_TREND,indicatorWindow,x1,y1,x2,y2,0,0);
      ObjectSet(label,OBJPROP_RAY,0);
      ObjectSet(label,OBJPROP_COLOR,lineColor);
      ObjectSet(label,OBJPROP_STYLE,style);
   }
}