//+------------------------------------------------------------------+
//|                                                       String.mqh |
//|                   Copyright 2009-2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include <Object.mqh>
#include <Monitor/Item.mqh>

//+------------------------------------------------------------------+
//| Class CPCItem.                                                   |
//| Format:  FC20#EURUSD#D1#监控h4和h1了#UP                                                  |
//+------------------------------------------------------------------+
class CFC20Item : public CItem
  {
protected:
   string            m_flag;
   bool              m_result;
   string            m_expectVal;
   bool              m_reverseResult;
public:
                    ~CFC20Item(void){};
                     CFC20Item(void);
   //--- methods access
  
   bool              getResult(void)   {return m_result;};
   string            getFlag(void)   {return m_flag;};
   void              setResult(bool str)   {m_result = str;}
   void              setExpectVal(string str)   {m_expectVal = str;}
   bool              calc();
  };


CFC20Item::CFC20Item(void){
   m_type = TYPE_FC20;
   m_flag = DOWN;
   m_reverseResult = false;
}
  
bool CFC20Item::calc(void) 
{
    int period = getPeriod(m_periodOrPrice);
    
    double vfast = iStochastic(m_symbo,period,QUICKPERIOD,SLOWEPERIOD,STOCHSLOW,MODE_LWMA,0,MODE_MAIN,0);
    if(vfast<20 && m_flag ==UP){
       m_flag = DOWN;
       //m_msg = StringConcatenate(iTime(m_symbo,period,0),"-->",m_symbo,getPeriodLabel(period),"随机指数快线向下穿越了20， ",m_original_msg,",当前价格:"+MarketInfo(m_symbo,MODE_ASK));
    }
   
    if(vfast>20 && m_flag==DOWN){
       m_flag = UP;
    }
    
    //compare expect value
    if(m_reverseResult == false){
        string tmp = "";
        if(m_expectVal==UP){
           tmp = DOWN;
        }else{
           tmp = UP;
        }
        m_reverseResult =( m_flag == tmp);
    }else{
        m_result =( m_flag == m_expectVal);
        if(m_result == true){
           m_msg = StringConcatenate(iTime(m_symbo,period,0),"-->",m_symbo,getPeriodLabel(period),"随机指数快线先向下穿越了20，后又向上穿越20， ",m_original_msg,",当前价格:"+MarketInfo(m_symbo,MODE_ASK));
        }
    }
    return m_result;
}
