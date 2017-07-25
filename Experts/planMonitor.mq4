//+------------------------------------------------------------------+
//|                                                  weekMonitor.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#include <monitor\monitorlib.mqh>
//---- input parameters parsed
string configs[][SECDEMENSION];
int modeValue = 100;
int currentTick = 0;
bool calcing =false;
bool email = true;

  string plan1 = "DXY高波动机会@条件都达到了，紧急观察下@ATR#_DXY#H4#0.2423#出现了高波动";
 string plan2 = "EURUSD高波动机会@条件都达到了，紧急观察下@ATR#EURUSD#H4#0.0004#出现了高波动";
 string plan3;



//planName@xxx#xxx#xxx||xxx#xxx#xxx$xxx#xxx#xxx&&xxx#xxx#xxx$xxx#xxx#xxx&&xxx#xxx#xxx
//planName       firstStep                secondStep              thirdStep


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   parseOnePlan(plan1);
   parseOnePlan(plan2);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   delAllObject();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   if(currentTick % modeValue ==0){      
       if(!calcing){
          printf("execut one calculator when currentTick is "+IntegerToString(currentTick));          
          calcing = true;
          //execute(configs,0,email);
          execute(0,email);
          calcing = false;
       }else{
          printf("cannot calcing because of due date when currentTick is "+IntegerToString(currentTick));
       }      
    }    
    currentTick++;
  }
//+------------------------------------------------------------------+
