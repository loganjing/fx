//+------------------------------------------------------------------+
//|                                                       String.mqh |
//|                   Copyright 2009-2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include <Object.mqh>
#include <Monitor/Item.mqh>

//+------------------------------------------------------------------+
//| Class CPCItem.                                                   |
//| Format:  2B#EURUSD#1.02303#xxxxx#UP                                                  |
//+------------------------------------------------------------------+
class C2BItem : public CItem
  {
private:
   int               knum;//2b happened in three k.
   int               breakInSomeKbefore();
protected:
   string            m_flag;//cross price:down/up
   bool              m_result;//whether 2b is happened
   string            m_expectVal;//break-up or break-down
   string            m_period;
public:
                    ~C2BItem(void){};
                     C2BItem(void);
   //--- methods access
  
   bool              getResult(void)   {return m_result;};
   string            getFlag(void)   {return m_flag;};
   void              setResult(bool str)   {m_result = str;}
   void              setExpectVal(string str)   {m_expectVal = str;}
   void              setPeriod(string str){m_period = str;}
   bool              calc();
  };

C2BItem::C2BItem(void){
   m_type = TYPE_2B;
   m_flag = DOWN;
   knum = 3;
   m_period="D1";
}
  
bool C2BItem::calc(void) 
{
    double price = StringToDouble(m_periodOrPrice);
    double vask = MarketInfo(m_symbo,MODE_ASK);
    if(vask < price && this.m_flag ==UP ){
        this.m_flag = DOWN;
    }
    if(vask > price && this.m_flag ==DOWN){
        this.m_flag =UP;
    }
    
    //m_flag store the relation between current price and expect price.
    if(this.m_flag!=m_expectVal){
       //expect break-up,but the current flag is down, and if in three k, price had broken up the price, 2b is true.   
       //expect break-down,but the current flag is up, and if in three k, price had broken down the price, 2b is true.
       int val = breakInSomeKbefore();
       if(val>-1){
          int period = getPeriod(m_period);
          m_msg = StringConcatenate("价格于",iTime(m_symbo,period,val),(m_expectVal=="UP"?"向上":"向下"),"突破，但当前价格",(m_expectVal=="UP"?"跌破":"升破"),"这个价格，2B发生,",m_original_msg);
          return true;
       }else{
          return false;
       }
    }
    return false;
}

int C2BItem::breakInSomeKbefore(void){
    int period = getPeriod(m_period);
    double price = StringToDouble(m_periodOrPrice);
    
    for(int i=0;i<10;i++){
       //if the highPrice or the low price is first break up the price.
       if(m_expectVal == "UP"){
          //break-up
          double hVal1 = iHigh(m_symbo,m_period,i);
          double hVal2 = iHigh(m_symbo,m_period,i+1);
          if(hVal2<price&&hVal1>price){
              //k(i) break-up first;
              return i;
          }
       }else if(m_expectVal == "DOWN"){
          //break-down
          double hVal1 = iLow(m_symbo,m_period,i);
          double hVal2 = iLow(m_symbo,m_period,i+1);
          if(hVal2>price&&hVal1<price){
              //k(i) break-down first;
              return i;
          }
       }
    }
    return -1;
} 