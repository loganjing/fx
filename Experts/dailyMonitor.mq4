//+------------------------------------------------------------------+
//|                                                  customAlert.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.comV"
#property version   "1.00"
#property strict
#include <monitor\monitorlib.mqh>
//---- input parameters parsed
string configs[][SECDEMENSION];
int modeValue = 30;
int currentTick = 0;
bool calcing =false;
//---- input parameters
//PC#EURUSD#1.09246#昨日低点，需要继续观察，能否出现2B.&PC#EURUSD#1.0899#ssddd
//MZ#EURUSD#H1#可以考虑买入了
//FC20#EURUSD#H4#可以考虑买入了
//FC80#EURUSD#H4#可以考虑买入了
//FCS#EURUSD#H4#可以考虑买入了
//SDG#EURUSD#H1#Note
//MDG#EURUSD#H1#Note
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
input string val11;
input string val12;
input string val13;
input string val14;
input string val15;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){

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
   parseRulesAndFills(configs,val11);
   parseRulesAndFills(configs,val12);
   parseRulesAndFills(configs,val13);
   parseRulesAndFills(configs,val14);
   parseRulesAndFills(configs,val15);
   
   initConfig(configs);
   return(INIT_SUCCEEDED);
}



void OnDeinit(const int reason)
{
   delAllObject();
}

void OnTick()
{

    if(currentTick % modeValue ==0){      
       if(!calcing){
          printf("execut one calculator when currentTick is "+IntegerToString(currentTick));          
          calcing = true;
          execute(configs,0,true);
          calcing = false;
       }else{
          printf("cannot calcing because of due date when currentTick is "+IntegerToString(currentTick));
       }      
    }    
    currentTick++;
    
}
  

  
