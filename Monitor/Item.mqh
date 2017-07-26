//+------------------------------------------------------------------+
//|                                                       String.mqh |
//|                   Copyright 2009-2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include <Object.mqh>
#include <Monitor/common.mqh>



//+------------------------------------------------------------------+
//| Class CString.                                                   |
//| Appointment: Class-string.                                       |
//|              Derives from class CObject.                         |
//+------------------------------------------------------------------+
class CItem : public CObject
  {
protected:
   string            m_symbo;
   string            m_periodOrPrice;
   string            m_msg;
   string            m_type;
   string            m_original_msg;
public:
                     CItem(void);
                    ~CItem(void);
   //--- methods access
   string            getSymbo(void)              { return(m_symbo);                       };
   string            getPeriod(void)              { return(m_periodOrPrice);                       };
   string            getMsg(void)              { return(m_msg);                       };
   string            getType(void)              { return(m_type);                       };
   
   void              setSymbo(string str)    { m_symbo=str;                           };
   void              setPeriodOrPrice(string str)    { m_periodOrPrice=str;                           };
   void              setMsg(string str)    { m_msg=str;m_original_msg=str;  };
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CItem::CItem(void) 
  {
    m_symbo = "";
    m_periodOrPrice = "";
    m_msg = "";
    m_original_msg = "";
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CItem::~CItem(void)
  {
  }
