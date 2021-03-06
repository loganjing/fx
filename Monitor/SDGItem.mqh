//+------------------------------------------------------------------+
//|                                                       String.mqh |
//|                   Copyright 2009-2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include <Object.mqh>
#include <Monitor/Item.mqh>

//+------------------------------------------------------------------+
//| Class CPCItem.                                                   |
//| Format:  SDG#EURUSD#D1#监控h4和h1了                                                  |
//+------------------------------------------------------------------+
class CSDGItem : public CItem
  {
private:
   double         lastHighVal;
   double         lastLowVal;
   datetime       lastCalcTime;
   
   double         stochValue[MAXCOUNT+5];
   double         stochLineBuffer[MAXCOUNT+5];//result to store macd & signal value for divergence.
   
   datetime       lastAlertTime;
   bool           lastresult;
   string         stochIndicatorName;

   void           recordStochDivResultAndAlert(int shift,string symbol,int period,string msg,int startIndex);
   void           initStochValue(string symbol,int period,int shift);
   int            findPrevStochTrough(int shift);
   int            findPrevStochPeak(int shift);
   bool           isStochPeak(int shift);
   bool           isStochTrough(int shift);
   void           drawStochTrendLine(datetime x1,datetime x2,double y1,double y2,color lineColor,double style,string symbol,int period);
   void           delAllStochObject();
protected:
   
public:
                    ~CSDGItem(void){delAllStochObject();};
                     CSDGItem(void);
   //--- methods access
   bool              calc();
  };


CSDGItem::CSDGItem(void){
   m_type = TYPE_SDG;
   lastresult = false;   
   this.stochIndicatorName ="Stoch("+IntegerToString(QUICKPERIOD)+","+IntegerToString(SLOWEPERIOD)+","+IntegerToString(STOCHSLOW)+")";;
}
  
bool CSDGItem::calc(void) 
{
   int period = getPeriod(m_periodOrPrice);
   string symbol = m_symbo;
   int startIndex = 0;
   //应该产生最高价或者最低价时计算比较合适,同一个K线只有最高价和最低价发生变化时才重新计算。
   double hValue = iHigh(symbol,period,startIndex);
   double lValue = iLow(symbol,period,startIndex);
   datetime time = iTime(symbol,period,startIndex);
   if(lastHighVal == hValue && lastLowVal == lValue && lastCalcTime == time){
       return lastresult;
   }
   
   //重新开始新的计算，结果是true吗？
   bool theresult = false;   
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
              recordStochDivResultAndAlert(i+startIndex,symbol,period,"发生了随机指数顶背离,"+m_original_msg,startIndex);
              theresult = true;
            }
            //当前波峰的macd值大于前一个波峰的macd值，但是当前k线的最高值却小于前一个波峰k线的最大值，认为是一个顶背离态势。  
            if(stochValue[i]>stochValue[prevPeak] && iValue<prevValue && (stochValue[i]>=80 || stochValue[prevPeak]>=80 )){
              //printf("反转顶背离态势发生: ",i+msg);
              //DrawArrow(Time[currentShift],signal[currentShift],Black,STYLE_SOLID,"DOWN");
              drawStochTrendLine(iTime(symbol,period,i+startIndex),iTime(symbol,period,prevPeak+startIndex),stochValue[i],stochValue[prevPeak],peakColor,STYLE_SOLID,symbol,period);
              recordStochDivResultAndAlert(i+startIndex,symbol,period,"发生了随机指数顶背离,"+m_original_msg,startIndex);
              theresult = true;
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
               recordStochDivResultAndAlert(i+startIndex,symbol,period,"发生了随机指数底背离,"+m_original_msg,startIndex);
               theresult = true;
            }
            
            if(stochValue[i]<stochValue[prevTrough] && iValue>prevValue && (stochValue[i]<=20 || stochValue[prevTrough]<=20)){
               //printf("反转底背离态势发生: ",i+msg);
               drawStochTrendLine(iTime(symbol,period,i+startIndex),iTime(symbol,period,prevTrough+startIndex),stochValue[i],stochValue[prevTrough],troughColor,STYLE_SOLID,symbol,period);
               recordStochDivResultAndAlert(i+startIndex,symbol,period,"发生了随机指数底背离,"+m_original_msg,startIndex);
               theresult = true;
            }
         }
      }
   }
   lastresult = theresult;
   return theresult;
}

//最新计算的K线是从0开始的。
//在第i个K线计算时如果产生了背离，警告并且同时记录最后提醒时间，只提醒最新的一次。
//下次如果再次计算时，Time[i]有可能和最后提醒时间相同，那就不提醒了。
void CSDGItem::recordStochDivResultAndAlert(int shift,string symbol,int period,string msg,int startIndex){
   this.lastHighVal = iHigh(symbol,period,startIndex);
   this.lastLowVal = iLow(symbol,period,startIndex);
   this.lastCalcTime = iTime(symbol,period,startIndex);
   if(iTime(symbol,period,shift) > this.lastAlertTime){
       this.lastAlertTime = iTime(symbol,period,shift);
       m_msg=StringConcatenate(iTime(symbol,period,shift),"-->",symbol,getPeriodLabel(period),msg,",当前价格:"+MarketInfo(symbol,MODE_ASK));
   }
}


void CSDGItem::initStochValue(string symbol,int period,int shift){
   //计算向前4个K线的MACD值
   int count = MAXCOUNT+shift;
   for(int i=0;i<MAXCOUNT;i++){
     this.stochValue[i]=iStochastic(symbol,period,QUICKPERIOD,SLOWEPERIOD,STOCHSLOW,MODE_LWMA,0,MODE_MAIN,i+shift);
     this.stochLineBuffer[i] = stochValue[i];
   }
}

bool CSDGItem::isStochPeak(int shift){
   if(stochValue[shift]>=stochValue[shift+1] && stochValue[shift]>stochValue[shift+2] && 
      stochValue[shift]>stochValue[shift-1])
      return(true);
   else
      return(false);
}

bool CSDGItem::isStochTrough(int shift)
  {
   if(stochValue[shift]<=stochValue[shift+1] && stochValue[shift]<stochValue[shift+2] && 
      stochValue[shift]<stochValue[shift-1])
      return(true);
   else
      return(false);
  }
  

int CSDGItem::findPrevStochPeak(int shift){
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


int CSDGItem::findPrevStochTrough(int shift){
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


void CSDGItem::delAllStochObject(){
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
void CSDGItem::drawStochTrendLine(datetime x1,datetime x2,double y1,double y2,color lineColor,double style,string symbol,int period){
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