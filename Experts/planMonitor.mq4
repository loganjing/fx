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

 string plan1 ="11.17EURUSD震荡高位入场机会@来临了吗@FC80#EURUSD#D1#入场的机会已经到达#DOWN&FCS#EURUSD#D1#入场的机会已经到达#DOWN&FC80#EURUSD#H4#入场的机会已经到达#DOWN&FCS#EURUSD#H4#入场的机会已经到达#DOWN&2B#EURUSD#1.18514#2B产生了#DOWN";
 string plan2 ="";
 string plan3 ="";
 string plan4 ="";
 string plan5 ="";
 string plan6 = "";
 string plan7 = "";
 
 string plan8 = "";
 string plan9 = "";
 string plan10 = "";
 string plan11 = "";
 string plan12 = "";
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
   parseOnePlan(plan3);
   parseOnePlan(plan4);
   parseOnePlan(plan5);
   parseOnePlan(plan6);
   parseOnePlan(plan7);
   parseOnePlan(plan8);
   parseOnePlan(plan9);
   parseOnePlan(plan10);
   parseOnePlan(plan12);
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
