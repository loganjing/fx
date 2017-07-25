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

input string val1;
input string val2;
input string val3;
input string val4;
input string val5;
input string val6;
input string val7;
input string val8;
input string val9;
input string val10;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   parseRulesAndFills(configs,val1);
   parseRulesAndFills(configs,val2);
   parseRulesAndFills(configs,val3);
   parseRulesAndFills(configs,val4);
   parseRulesAndFills(configs,val5);
   parseRulesAndFills(configs,val6);
   parseRulesAndFills(configs,val7);
   parseRulesAndFills(configs,val8);
   parseRulesAndFills(configs,val9);
   parseRulesAndFills(configs,val10);
   
   initConfig(configs);
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
          execute(configs,0,email);
          calcing = false;
       }else{
          printf("cannot calcing because of due date when currentTick is "+IntegerToString(currentTick));
       }      
    }    
    currentTick++;
  }
//+------------------------------------------------------------------+
