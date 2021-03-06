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
CPlan* planInfo = new CPlan();

//string configs[][SECDEMENSION];
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
 string val1="PC#EURUSD#1.09246#昨日低点，需要继续观察，能否出现2B&2B#EURUSD#1.02303#xxxxx#UP&ATR#EURUSD#H1#1.02303#MSG#UP&MDG#EURUSD#H1#Note&SDG#EURUSD#H1#Note&FCS#EURUSD#H4#可以考虑买入了&FC80#EURUSD#H4#可以考虑买入了&MZ#EURUSD#H1#可以考虑买入了&FC20#EURUSD#H4#可以考虑买入了&KFA#EURUSD#H1#MSG";
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
   CPlanStep* fxStep = new CPlanStep();
   parsePlanStep(fxStep,val1);
   parsePlanStep(fxStep,val2);
   parsePlanStep(fxStep,val3);
   parsePlanStep(fxStep,val4);
   parsePlanStep(fxStep,val5);
   parsePlanStep(fxStep,val6);
   parsePlanStep(fxStep,val7);
   parsePlanStep(fxStep,val8);
   parsePlanStep(fxStep,val9);
   parsePlanStep(fxStep,val10);
   parsePlanStep(fxStep,val11);
   parsePlanStep(fxStep,val12);
   parsePlanStep(fxStep,val13);
   parsePlanStep(fxStep,val14);
   parsePlanStep(fxStep,val15);
   planInfo.setFirstStep(fxStep);
   //initConfig(fxStep);
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
          execute(planInfo,0,true);
          calcing = false;
       }else{
          printf("cannot calcing because of due date when currentTick is "+IntegerToString(currentTick));
       }      
    }    
    currentTick++;
    
}
  

  
