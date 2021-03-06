//+------------------------------------------------------------------+
//|                                                       String.mqh |
//|                   Copyright 2009-2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include <Object.mqh>
#include <Monitor/Item.mqh>

//+------------------------------------------------------------------+
//| Class CPCItem.                                                   |
//| Format:  FCS#EURUSD#D1#监控h4和h1了#UP                                                 |
//+------------------------------------------------------------------+
class CFCSItem : public CItem
  {
protected:
   string            m_flag;
   bool              m_result;
   string            m_expectVal;
public:
                    ~CFCSItem(void){};
                     CFCSItem(void);
   //--- methods access
  
   bool              getResult(void)   {return m_result;};
   string            getFlag(void)   {return m_flag;};
   void              setResult(bool str)   {m_result = str;}
   void              setExpectVal(string str)   {m_expectVal = str;}
   bool              calc();
  };


CFCSItem::CFCSItem(void){
   m_type = TYPE_FCS;
   m_flag = DOWN;
}
  
bool CFCSItem::calc(void) 
{
    int period = getPeriod(m_periodOrPrice);
    
    double vfast = iStochastic(m_symbo,period,QUICKPERIOD,SLOWEPERIOD,STOCHSLOW,MODE_LWMA,0,MODE_MAIN,0);
    double vslow = iStochastic(m_symbo,period,QUICKPERIOD,SLOWEPERIOD,STOCHSLOW,MODE_LWMA,0,MODE_SIGNAL,0);
    if(vfast<vslow && m_flag==UP){
       m_flag = DOWN;
       m_msg = StringConcatenate(iTime(m_symbo,period,0),"-->",m_symbo,getPeriodLabel(period),"随机指数快线向下穿越慢线， ",m_original_msg,",当前价格:"+MarketInfo(m_symbo,MODE_ASK));
    }
   
    if(vfast>vslow && m_flag==DOWN){
       m_flag = UP;
       m_msg = StringConcatenate(iTime(m_symbo,period,0),"-->",m_symbo,getPeriodLabel(period),"随机指数快线向上穿越慢线， ",m_original_msg,",当前价格:"+MarketInfo(m_symbo,MODE_ASK));
    }
    
    //compare expect value
    m_result =( m_flag == m_expectVal);
    return m_result;
}
