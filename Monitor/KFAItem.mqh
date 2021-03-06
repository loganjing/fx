//+------------------------------------------------------------------+
//|                                                       String.mqh |
//|                   Copyright 2009-2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include <Object.mqh>
#include <Monitor/Item.mqh>

//+------------------------------------------------------------------+
//| Class CPCItem.                                                   |
//| Format:  KFA#EURUSD#H1#MSG                                                  |
//+------------------------------------------------------------------+
class CKFAItem : public CItem
  {
private:   
   datetime         lastAlertTime;
public:
                    ~CKFAItem(void){};
                     CKFAItem(void);
   //--- methods access
   void              calc();
};


CKFAItem::CKFAItem(void){
   m_type = TYPE_KFA;   
}
  
void CKFAItem::calc(void) 
{
    int period = getPeriod(m_periodOrPrice);
    datetime tmp = iTime(m_symbo,period,0);
    if(tmp > this.lastAlertTime){
       this.lastAlertTime =iTime(m_symbo,period,0);
       m_msg = StringConcatenate(iTime(m_symbo,period,0),"-->",m_symbo,getPeriodLabel(period),m_original_msg,",当前价格:"+MarketInfo(m_symbo,MODE_ASK));
       SendNotification(m_msg);
   }       
}
