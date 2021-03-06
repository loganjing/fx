//+------------------------------------------------------------------+
//|                                                       String.mqh |
//|                   Copyright 2009-2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include <Object.mqh>
#include <Monitor/Item.mqh>

//+------------------------------------------------------------------+
//| Class CATRItem.                                                   |
//| Format:  ATR#EURUSD#H1#0.00017#监控h4和h1了                                                  |
//+------------------------------------------------------------------+
class CATRItem : public CItem
  {
protected:
   string            m_flag;
   bool              m_result;
   string            m_expectVal;
public:
                    ~CATRItem(void){};
                     CATRItem(void);
   //--- methods access
  
   bool              getResult(void)   {return m_result;};
   string            getFlag(void)   {return m_flag;};
   void              setResult(bool str)   {m_result = str;}
   void              setExpectVal(string str)   {m_expectVal = str;}
   bool              calc();
  };

CATRItem::CATRItem(void){
   m_type = TYPE_ATR;
}
  
bool CATRItem::calc(void) 
{
    //ATR#EURUSD#H1#0.00017#监控h4和h1了
    int period = getPeriod(m_periodOrPrice);
    double price = StringToDouble(m_expectVal);
    
    double atrValue = iATR(m_symbo,period,1,0);
    if(atrValue>price){
       m_result = true;
       m_msg = StringConcatenate(iTime(m_symbo,period,0),"-->",m_symbo,getPeriodLabel(period),"ATR发生高波动，大于平均值",m_expectVal,", ",m_original_msg,",当前价格:"+MarketInfo(m_symbo,MODE_ASK));
    }else{
       m_result = false;
       m_msg = "";
    }
    
    //compare expect value
    return m_result;
}
