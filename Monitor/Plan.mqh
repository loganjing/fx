//+------------------------------------------------------------------+
//|                                                       String.mqh |
//|                   Copyright 2009-2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include <Object.mqh>
#include <Arrays/List.mqh>
#include <Monitor/Item.mqh>
#include <Monitor/PlanStep.mqh>
//+------------------------------------------------------------------+
//| Class CString.                                                   |
//| Appointment: Class-string.                                       |
//|              Derives from class CObject.                         |
//+------------------------------------------------------------------+
class CPlan : public CObject
  {
protected:
   string            m_name;
   CPlanStep         *m_first;
   CPlanStep         *m_second;
   CPlanStep         *m_third;
   CPlanStep         *m_forth;
   string            m_msg;
   int               m_alertCount;
public:
                     CPlan(void);
                    ~CPlan(void);
   //--- methods access
   string            getName(void)              { return(m_name);                       };
   CPlanStep*            getFirstStep(void)              { return(m_first);                       };
   CPlanStep*            getSecondStep(void)              { return(m_second);                       };
   CPlanStep*            getThirdStep(void)              { return(m_third);                       };
   CPlanStep*            getForthStep(void)              { return(m_forth);                       };
   string            getMsg(void)              { return(m_msg);                       };
   int               getAlertCount(void)              { return(m_alertCount);                       };
   void              setName(string str)    { m_name=str;                           };
   void              setFirstStep(CPlanStep* str)    {m_first=str;                        };
   void              setSecondStep(CPlanStep* str)    {m_second=str;                        };
   void              setThirdStep(CPlanStep* str)    {m_third=str;                        };
   void              setForthStep(CPlanStep* str)    {m_forth=str;                        };
   void              setMsg(string str)    { m_msg=str;                           };
   void              setAlertCount(int count)    { m_alertCount=count;                           };
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CPlan::CPlan(void) 
  {
    m_name = "";
    m_alertCount = 0;
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CPlan::~CPlan(void)
  {
  }

