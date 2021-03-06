//+------------------------------------------------------------------+
//|                                                       String.mqh |
//|                   Copyright 2009-2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include <Object.mqh>
#include <Monitor/Item.mqh>

//+------------------------------------------------------------------+
//| Class CPCItem.                                                   |
//| Format:  MDG#EURUSD#D1#监控h4和h1了                                                  |
//+------------------------------------------------------------------+
class CMDGItem : public CItem
  {
private:
   double         lastHighVal;
   double         lastLowVal;
   datetime       lastCalcTime;
   double         macd[MAXCOUNT+5];
   double         signal[MAXCOUNT+5];//result to store macd & signal value for divergence.
   datetime       lastAlertTime;
   bool           lastresult;
   string         macdIndicatorName;

   void           recordMACDDivResultAndAlert(int shift,string symbol,int period,string msg,int startIndex);
   void           initMACDValue(string symbol,int period,int shift);
   int            findPrevMACDTrough(int shift);
   int            findPrevMACDPeak(int shift);
   bool           isMACDPeak(int shift);
   bool           isMACDTrough(int shift);
   void           drawMACDTrendLine(datetime x1,datetime x2,double y1,double y2,color lineColor,double style,string symbol,int period);
   void           delAllMACDObject();
protected:
   
public:
                    ~CMDGItem(void){delAllMACDObject();};
                     CMDGItem(void);
   //--- methods access
   bool              calc();
  };


CMDGItem::CMDGItem(void){
   m_type = TYPE_MDG;
   lastresult = false;
   this.macdIndicatorName ="MACD("+IntegerToString(QUICKEMA)+","+IntegerToString(SLOWEMA)+","+IntegerToString(MACDSMA)+")";
}
  
bool CMDGItem::calc(void) 
{
   int period = getPeriod(m_periodOrPrice);
   string symbol = m_symbo;
   int startIndex = 0;
    //has calculated
   double hValue = iHigh(symbol,period,startIndex);
   double lValue = iLow(symbol,period,startIndex);
   datetime time = iTime(symbol,period,startIndex);
   //因为根据高低点来计算是否发生了背离，因此只要之前计算股哦，就不再重复计算
   if(lastHighVal == hValue && lastLowVal == lValue && lastCalcTime == time){
       return lastresult;
   }
   //重新开始新的计算，结果是true吗？
   bool theresult = false;
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
              recordMACDDivResultAndAlert(i+startIndex,symbol,period,"发生了MACD顶背离,"+m_original_msg,startIndex);
              theresult = true;
            }
            //当前波峰的macd值大于前一个波峰的macd值，但是当前k线的最高值却小于前一个波峰k线的最大值，认为是一个顶背离态势。  
            if(signal[i]>signal[prevPeak] && iValue<prevValue && (signal[i]>=0||signal[prevPeak]>=0)){
              //printf("反转顶背离态势发生: ",i+msg);
              //DrawArrow(Time[currentShift],signal[currentShift],Black,STYLE_SOLID,"DOWN");
              drawMACDTrendLine(iTime(symbol,period,i+startIndex),iTime(symbol,period,prevPeak+startIndex),signal[i],signal[prevPeak],peakColor,STYLE_SOLID,symbol,period);
              recordMACDDivResultAndAlert(i+startIndex,symbol,period,"发生了MACD顶背离,"+m_original_msg,startIndex);
              theresult = true;
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
               recordMACDDivResultAndAlert(i+startIndex,symbol,period,"发生了MACD底背离,"+m_original_msg,startIndex);
               theresult = true;
            }
            
            if(signal[i]<signal[prevTrough] && iValue>prevValue && (signal[i]<=0||signal[prevTrough]<=0)){
               //printf("反转底背离态势发生: ",i+msg);
               drawMACDTrendLine(iTime(symbol,period,i+startIndex),iTime(symbol,period,prevTrough+startIndex),signal[i],signal[prevTrough],troughColor,STYLE_SOLID,symbol,period);
               recordMACDDivResultAndAlert(i+startIndex,symbol,period,"发生了MACD底背离,"+m_original_msg,startIndex);
               theresult = true;
            }
         }
      }
   }
   lastresult = theresult;
   return theresult;
}

void CMDGItem::recordMACDDivResultAndAlert(int shift,string symbol,int period,string msg,int startIndex){
   this.lastHighVal = iHigh(symbol,period,startIndex);
   this.lastLowVal = iLow(symbol,period,startIndex);
   this.lastCalcTime = iTime(symbol,period,startIndex);
   if(iTime(symbol,period,shift) > this.lastAlertTime){
       this.lastAlertTime =iTime(symbol,period,shift);
       m_msg = StringConcatenate(iTime(symbol,period,shift),"-->",symbol,getPeriodLabel(period),msg,",当前价格:"+MarketInfo(symbol,MODE_ASK));
   }
}

void CMDGItem::delAllMACDObject(){
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



void CMDGItem::initMACDValue(string symbol,int period,int shift){
   //计算向前4个K线的MACD值
   int count = MAXCOUNT+shift;
   ArrayResize(macd,count);
   ArrayResize(signal,count);
   for(int i=0;i<count;i++){
      macd[i]=iMACD(symbol,period,QUICKEMA,SLOWEMA,MACDSMA,PRICE_CLOSE,MODE_MAIN,i+shift);
      signal[i]=iMACD(symbol,period,QUICKEMA,SLOWEMA,MACDSMA,PRICE_CLOSE,MODE_SIGNAL,i+shift);
   }
}

int CMDGItem::findPrevMACDTrough(int shift){
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

int CMDGItem::findPrevMACDPeak(int shift){
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
bool CMDGItem::isMACDPeak(int shift){
   if(signal[shift]>=signal[shift+1] && signal[shift]>signal[shift+2] && 
      signal[shift]>signal[shift-1])
      return(true);
   else
      return(false);
}

//+------------------------------------------------------------------+
//| 是否是macd的谷底，判断条件：当前K线的macd值小于前2个k线，同时也小于后两个k线                                                                 |
//+------------------------------------------------------------------+
bool CMDGItem::isMACDTrough(int shift){
   if(signal[shift]<=signal[shift+1] && signal[shift]<signal[shift+2] && 
      signal[shift]<signal[shift-1])
      return(true);
   else
      return(false);
}



void CMDGItem::drawMACDTrendLine(datetime x1,datetime x2,double y1,double y2,color lineColor,double style,string symbol,int period){
   if(symbol == Symbol() && period == Period()){
      int indicatorWindow=WindowFind(this.macdIndicatorName);
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