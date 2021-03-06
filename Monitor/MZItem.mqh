//+------------------------------------------------------------------+
//|                                                       String.mqh |
//|                   Copyright 2009-2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include <Object.mqh>
#include <Monitor/Item.mqh>

//+------------------------------------------------------------------+
//| Class CPCItem.                                                   |
//| Format:  MZ#EURUSD#D1#监控h4和h1了#UP                                                  |
//+------------------------------------------------------------------+
class CMZItem : public CItem
  {
protected:
   string            m_flag;
   bool              m_result;
   string            m_expectVal;
public:
                    ~CMZItem(void){};
                     CMZItem(void);
   //--- methods access
  
   bool              getResult(void)   {return m_result;};
   string            getFlag(void)   {return m_flag;};
   void              setResult(bool str)   {m_result = str;}
   void              setExpectVal(string str)   {m_expectVal = str;}
   bool              calc();
  };


CMZItem::CMZItem(void){
   m_type = TYPE_MZ;
   m_flag = DOWN;
}
  
bool CMZItem::calc(void) 
{
    int period = getPeriod(m_periodOrPrice);
    double main = iMACD(m_symbo,period,QUICKEMA,SLOWEMA,MACDSMA,PRICE_CLOSE,MODE_SIGNAL,0);
    if(main<0 && m_flag==UP){
      m_flag = DOWN;
      m_msg = StringConcatenate(iTime(m_symbo,period,0),"-->",m_symbo,getPeriodLabel(period),"的MACD向下穿越0轴， ",m_original_msg,",当前价格:"+MarketInfo(m_symbo,MODE_ASK));
    }
    if(main>0 && m_flag==DOWN){
      m_flag =UP;
      m_msg = StringConcatenate(iTime(m_symbo,period,0),"-->",m_symbo,getPeriodLabel(period),"的MACD向上穿越0轴， ",m_original_msg,",当前价格:"+MarketInfo(m_symbo,MODE_ASK));
    }
    
    //compare expect value
    m_result =( m_flag == m_expectVal);
    return m_result;
}
