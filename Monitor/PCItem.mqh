//+------------------------------------------------------------------+
//|                                                       String.mqh |
//|                   Copyright 2009-2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include <Object.mqh>
#include <Monitor/Item.mqh>

//+------------------------------------------------------------------+
//| Class CPCItem.                                                   |
//| Format:  PC#EURUSD#1.02303#监控h4和h1了#UP                                                  |
//+------------------------------------------------------------------+
class CPCItem : public CItem
  {
protected:
   string            m_flag;
   bool              m_result;
   string            m_expectVal;
public:
                    ~CPCItem(void){};
                     CPCItem(void);
   //--- methods access
  
   bool              getResult(void)   {return m_result;};
   string            getFlag(void)   {return m_flag;};
   void              setResult(bool str)   {m_result = str;}
   void              setExpectVal(string str)   {m_expectVal = str;}
   bool              calc();
  };

CPCItem::CPCItem(void){
   m_type = TYPE_PC;
   m_flag = DOWN;
}
  
bool CPCItem::calc(void) 
{
    double price = StringToDouble(m_periodOrPrice);
    double vask = MarketInfo(m_symbo,MODE_ASK);;
    if(vask < price && this.m_flag ==UP ){
        this.m_flag = DOWN;
        m_msg = StringConcatenate(m_symbo," 当前价格小于 ",price,",向下穿越,",m_original_msg,",当前价格:"+MarketInfo(m_symbo,MODE_ASK));
 
    }
    
    if(vask > price && this.m_flag ==DOWN){
        this.m_flag =UP;
        m_msg = StringConcatenate(m_symbo," 当前价格大于 ",price,",向上穿越,",m_original_msg,",当前价格:"+MarketInfo(m_symbo,MODE_ASK));
    }
    
    //compare expect value
    m_result =( m_flag == m_expectVal);
    return m_result;
}
