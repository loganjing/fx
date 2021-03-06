//+------------------------------------------------------------------+
//|                                                        stoch.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict
#include <Monitor/common.mqh>




//array to record fastCross20 result
string stoch20[];
void alertWhenStochFastCross20(string symbol,int period,string msg,int index,int shift,string& notifyMsg){
   bool isTesting = shift > 0;
   double vfast = iStochastic(symbol,period,QUICKPERIOD,SLOWEPERIOD,STOCHSLOW,MODE_LWMA,0,MODE_MAIN,shift);
   string flag = stoch20[index];
   if(vfast<20 && flag ==UP){
      stoch20[index] = DOWN;
      addToMsg(notifyMsg,StringConcatenate(iTime(symbol,period,shift),"-->",symbol,getPeriodLabel(period),"随机指数快线向下穿越了20， ",msg,",当前价格:"+MarketInfo(symbol,MODE_ASK)),shift);
   }
   
   if(vfast>20 && flag==DOWN){
      stoch20[index] = UP;
      addToMsg(notifyMsg,StringConcatenate(iTime(symbol,period,shift),"-->",symbol,getPeriodLabel(period),"随机指数快线先向下穿越了20，后又向上穿越20， ",msg,",当前价格:"+MarketInfo(symbol,MODE_ASK)),shift);
   }
   
}

//array to record fastCross80 result
string stoch80[];
void alertWhenStochFastCross80(string symbol,int period,string msg,int index,int shift,string& notifyMsg){
   bool isTesting = shift > 0;
   double vfast = iStochastic(symbol,period,QUICKPERIOD,SLOWEPERIOD,STOCHSLOW,MODE_LWMA,0,MODE_MAIN,0);
   string flag = stoch80[index];
   if(vfast<80 && flag ==UP){
      stoch80[index] = DOWN;
      addToMsg(notifyMsg,StringConcatenate(iTime(symbol,period,shift),"-->",symbol,getPeriodLabel(period),"随机指数快线先向上穿越了80，后又向下穿越了80， ",msg,",当前价格:"+MarketInfo(symbol,MODE_ASK)),shift);
   }
   
   if(vfast>80 && flag==DOWN){
      stoch80[index] = UP;
      addToMsg(notifyMsg,StringConcatenate(iTime(symbol,period,shift),"-->",symbol,getPeriodLabel(period),"随机指数快线向上穿越了80 ",msg,",当前价格:"+MarketInfo(symbol,MODE_ASK)),shift);
   }
   
}




//array to record fastCrossSlow result
string fastCrossSlow[];
void alertWhenStochFastCrossSlow(string symbol,int period,string msg,int index,int shift,string& notifyMsg){
   bool isTesting = shift > 0;
   double vfast = iStochastic(symbol,period,QUICKPERIOD,SLOWEPERIOD,STOCHSLOW,MODE_LWMA,0,MODE_MAIN,0);
   double vslow = iStochastic(symbol,period,QUICKPERIOD,SLOWEPERIOD,STOCHSLOW,MODE_LWMA,0,MODE_SIGNAL,0);
   string flag = fastCrossSlow[index];
   if(vfast<vslow && flag==UP){
      fastCrossSlow[index] = DOWN;
      addToMsg(notifyMsg,StringConcatenate(iTime(symbol,period,shift),"-->",symbol,getPeriodLabel(period),"随机指数快线向下穿越慢线， ",msg,",当前价格:"+MarketInfo(symbol,MODE_ASK)),shift);
   }
   
   if(vfast>vslow && flag==DOWN){
      fastCrossSlow[index] = UP;
      addToMsg(notifyMsg,StringConcatenate(iTime(symbol,period,shift),"-->",symbol,getPeriodLabel(period),"随机指数快线向上穿越慢线， ",msg,",当前价格:"+MarketInfo(symbol,MODE_ASK)),shift);
   }
   
}


//array to store stoch values
double stochLineBuffer[MAXCOUNT+5];
double stochValue[MAXCOUNT+5];
//array to store result for every calculation
double lastSKHigh[];
double lastSKLow[];
datetime lastSCalcTime[];
datetime lastSAlertTime[];
void alertWhenStochDivergence(string symbol,int period,string msg,int index,int startIndex,string& notifyMsg){
   //应该产生最高价或者最低价时计算比较合适,同一个K线只有最高价和最低价发生变化时才重新计算。
   double hValue = iHigh(symbol,period,startIndex);
   double lValue = iLow(symbol,period,startIndex);
   datetime time = iTime(symbol,period,startIndex);
   if(lastSKHigh[index] == hValue && lastSKLow[index] == lValue && lastSCalcTime[index] == time){
       return;
   }
   delAllStochObject();
   initStochValue(symbol,period,startIndex);
   for(int i=1;i<MAXCOUNT;i++){
      bool peak = isStochPeak(i);
      //printf(" stoch Peak:"+i);
      if(peak){
         //DrawArrow(Time[i],stochDiv[i],peakColor,STYLE_SOLID,"DOWN",false,symbol);
         int prevPeak = findPrevStochPeak(i);
         if(prevPeak>-1){
            double iValue = iHigh(symbol,period,i);
            double prevValue = iHigh(symbol,period,prevPeak);
            //printf(" stoch Peak:"+prevPeak);
            //DrawArrow(Time[prevPeak],stochDiv[prevPeak],peakColor,STYLE_SOLID,"DOWN",false,symbol);
            //当前波峰的macd值小于前一个波峰的macd值，但是当前k线的最高值却大于前一个波峰k线的最大值，认为是一个顶背离态势。
            if(stochValue[i]<stochValue[prevPeak] && iValue>prevValue && (stochValue[i]>=80 || stochValue[prevPeak]>=80 )){
              //printf("传统顶背离态势发生: ",i+msg);
              drawStochTrendLine(iTime(symbol,period,i+startIndex),iTime(symbol,period,prevPeak+startIndex),stochValue[i],stochValue[prevPeak],peakColor,STYLE_SOLID,symbol,period);
              recordStochDivResultAndAlert(i+startIndex,index,symbol,period,"发生了随机指数顶背离,"+msg,startIndex,notifyMsg);
            }
            //当前波峰的macd值大于前一个波峰的macd值，但是当前k线的最高值却小于前一个波峰k线的最大值，认为是一个顶背离态势。  
            if(stochValue[i]>stochValue[prevPeak] && iValue<prevValue && (stochValue[i]>=80 || stochValue[prevPeak]>=80 )){
              //printf("反转顶背离态势发生: ",i+msg);
              //DrawArrow(Time[currentShift],signal[currentShift],Black,STYLE_SOLID,"DOWN");
              drawStochTrendLine(iTime(symbol,period,i+startIndex),iTime(symbol,period,prevPeak+startIndex),stochValue[i],stochValue[prevPeak],peakColor,STYLE_SOLID,symbol,period);
              recordStochDivResultAndAlert(i+startIndex,index,symbol,period,"发生了随机指数顶背离,"+msg,startIndex,notifyMsg);
            }
         }
      }
      
      bool trough = isStochTrough(i);
      if(trough){
         //printf(" stoch Trough:"+i);
         //DrawArrow(Time[i],stochDiv[i],troughColor,STYLE_SOLID,"UP",false,symbol);
         int prevTrough = findPrevStochTrough(i);
         if(prevTrough > -1){
            double iValue = iLow(symbol,period,i);
            double prevValue = iLow(symbol,period,prevTrough);
            //printf(" stoch Trough:"+prevTrough);
            //DrawArrow(Time[prevTrough],stochDiv[prevTrough],troughColor,STYLE_SOLID,"UP",false,symbol);
            //yes, find a trough
            if(stochValue[i]>stochValue[prevTrough] && iValue<prevValue && (stochValue[i]<=20 || stochValue[prevTrough]<=20)){
               //printf("传统底背离态势发生: ",i+msg);
               drawStochTrendLine(iTime(symbol,period,i+startIndex),iTime(symbol,period,prevTrough+startIndex),stochValue[i],stochValue[prevTrough],troughColor,STYLE_SOLID,symbol,period);
               recordStochDivResultAndAlert(i+startIndex,index,symbol,period,"发生了随机指数底背离,"+msg,startIndex,notifyMsg);
            }
            
            if(stochValue[i]<stochValue[prevTrough] && iValue>prevValue && (stochValue[i]<=20 || stochValue[prevTrough]<=20)){
               //printf("反转底背离态势发生: ",i+msg);
               drawStochTrendLine(iTime(symbol,period,i+startIndex),iTime(symbol,period,prevTrough+startIndex),stochValue[i],stochValue[prevTrough],troughColor,STYLE_SOLID,symbol,period);
               recordStochDivResultAndAlert(i+startIndex,index,symbol,period,"发生了随机指数底背离,"+msg,startIndex,notifyMsg);
            }
         }
      }
   }
}

//最新计算的K线是从0开始的。
//在第i个K线计算时如果产生了背离，警告并且同时记录最后提醒时间，只提醒最新的一次。
//下次如果再次计算时，Time[i]有可能和最后提醒时间相同，那就不提醒了。
void recordStochDivResultAndAlert(int shift,int index,string symbol,int period,string msg,int startIndex,string& notifyMsg){
   lastSKHigh[index] = iHigh(symbol,period,startIndex);
   lastSKLow[index] = iLow(symbol,period,startIndex);
   lastSCalcTime[index] = iTime(symbol,period,startIndex);
   if(iTime(symbol,period,shift) > lastSAlertTime[index]){
       lastSAlertTime[index] = iTime(symbol,period,shift);
       addToMsg(notifyMsg,StringConcatenate(iTime(symbol,period,shift),"-->",symbol,getPeriodLabel(period),msg,",当前价格:"+MarketInfo(symbol,MODE_ASK)),shift);
   }
}

void initStochParams(int fastCrossSlowSize,int stoch20Size,int stoch80Size,int stochDivSize){
   initFlags(fastCrossSlow,fastCrossSlowSize,DOWN);
   initFlags(stoch20,stoch20Size,DOWN);
   initFlags(stoch80,stoch80Size,DOWN);
   //背离的结果数组初始化
   initDateTimeArray(lastSAlertTime,stochDivSize);
   initDateTimeArray(lastSCalcTime,stochDivSize);
   initDoubleArray(lastSKHigh,stochDivSize);
   initDoubleArray(lastSKLow,stochDivSize);
}

void initStochValue(string symbol,int period,int shift){
   //计算向前4个K线的MACD值
   int count = MAXCOUNT+shift;
   for(int i=0;i<MAXCOUNT;i++){
     stochValue[i]=iStochastic(symbol,period,QUICKPERIOD,SLOWEPERIOD,STOCHSLOW,MODE_LWMA,0,MODE_MAIN,i+shift);
     stochLineBuffer[i] = stochValue[i];
   }
}

bool isStochPeak(int shift){
   if(stochValue[shift]>=stochValue[shift+1] && stochValue[shift]>stochValue[shift+2] && 
      stochValue[shift]>stochValue[shift-1])
      return(true);
   else
      return(false);
}

bool isStochTrough(int shift)
  {
   if(stochValue[shift]<=stochValue[shift+1] && stochValue[shift]<stochValue[shift+2] && 
      stochValue[shift]<stochValue[shift-1])
      return(true);
   else
      return(false);
  }
  

int findPrevStochPeak(int shift){
   int count = MAXCOUNT-2;
   for(int i=shift+2; i<count; i++)
     {
      if(stochLineBuffer[i] >= stochLineBuffer[i+1] && stochLineBuffer[i] >= stochLineBuffer[i+2] &&
         stochLineBuffer[i] >= stochLineBuffer[i-1] && stochLineBuffer[i] >= stochLineBuffer[i-2])
        {
         for(int j=i; j<MAXCOUNT-2; j++)
           {
            if(stochValue[j] >= stochValue[j+1] && stochValue[j] > stochValue[j+2] &&
               stochValue[j] >= stochValue[j-1] && stochValue[j] > stochValue[j-2])
               return(j);
           }
        }
     }
   return(-1);
}


int findPrevStochTrough(int shift){
   int count = MAXCOUNT-2;
   for(int i=shift+2; i<count; i++){
      if(stochLineBuffer[i] <= stochLineBuffer[i+1] && stochLineBuffer[i] <= stochLineBuffer[i+2] &&
         stochLineBuffer[i] <= stochLineBuffer[i-1] && stochLineBuffer[i] <= stochLineBuffer[i-2]){
        
         for(int j=i; j<MAXCOUNT-2; j++)
           {
            if(stochValue[j] <= stochValue[j+1] && stochValue[j] < stochValue[j+2] &&
               stochValue[j] <= stochValue[j-1] && stochValue[j] < stochValue[j-2])
               return(j);
           }
        }
   }
   return(-1);
}  


void delAllStochObject(){
  for(int i=ObjectsTotal()-1; i>=0; i--)
  {
   string label=ObjectName(i);
   string tmp = StringSubstr(label,0,20);
   printf(tmp);
   if(StringSubstr(label,0,20)=="STOCH_DivergenceLine"){
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

//stoch indicate name
static string stochIndicatorName ="Stoch("+IntegerToString(QUICKPERIOD)+","+IntegerToString(SLOWEPERIOD)+","+IntegerToString(STOCHSLOW)+")";;
void drawStochTrendLine(datetime x1,datetime x2,double y1,double y2,color lineColor,double style,string symbol,int period){
   if(symbol == Symbol() && period == Period()){
      int indicatorWindow=WindowFind(stochIndicatorName);
      if(indicatorWindow<0)
         return;
      string label="STOCH_DivergenceLine_v1.0$# "+DoubleToStr(x1,0);
      ObjectDelete(label);
      ObjectCreate(label,OBJ_TREND,indicatorWindow,x1,y1,x2,y2,0,0);
      ObjectSet(label,OBJPROP_RAY,0);
      ObjectSet(label,OBJPROP_COLOR,lineColor);
      ObjectSet(label,OBJPROP_STYLE,style);
   }
}