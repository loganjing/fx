//+------------------------------------------------------------------+
//|                                                       String.mqh |
//|                   Copyright 2009-2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include <Object.mqh>
#include <Arrays/List.mqh>
#include <Monitor/Item.mqh>
//+------------------------------------------------------------------+
//| Class CString.                                                   |
//| Appointment: Class-string.                                       |
//|              Derives from class CObject.                         |
//+------------------------------------------------------------------+
class CPlanStep : public CObject
  {
protected:
   CList             *m_items;
   bool              m_result;
   string            m_msg;
public:
                     CPlanStep(void);
                    ~CPlanStep(void);
   //--- methods access
   CList*            getItems(void)              { return(m_items);};
   bool              getResult(void)  { return(m_result);};
   
   void              setItems(CList *str)    {m_items=str;                        };
   void              addItem(CItem *item);
   void              setResult(bool str) {m_result = str;};
   void              setMsg(string msg){m_msg = msg;}
   string            getMsg(void){return m_msg;};
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CPlanStep::CPlanStep(void) 
  {
   m_items = new CList();
   m_msg = "";
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CPlanStep::~CPlanStep(void)
  {
  }

CPlanStep::addItem(CItem *item){
   if(CheckPointer(item)==POINTER_INVALID) return;
   m_items.Add(item);
}