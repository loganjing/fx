//+------------------------------------------------------------------+
//|                                              strategyMonitor.mq4 |
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

input string paris;
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
   //默认监控:日图背离、周图背离、月图背离，周图MACD 0 轴，月图MACD 0 轴、周图随机指数20，月图随机指数20，周图随机指数80，月图随机指数80
   
   string fixSymbol = "_DXY,EURUSD,GBPUSD,USDJPY,AUDUSD,NZDUSD,USDCAD,XAUUSD,XAGUSD";
   parseSymboMonthMonitorRule(configs,fixSymbol);
   parseSymboMonthMonitorRule(configs,paris);

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


void parseSymboMonthMonitorRule(string& items[][SECDEMENSION],string rule){
   string tmp[];
   ushort sp = StringGetCharacter(",",0);
   StringSplit(rule,sp,tmp);
   int splitSize = ArraySize(tmp);
   
   for(int i=0;i<splitSize;i++){
       generateSymboMonitorItem(items,tmp[i]);
   }
}

void generateSymboMonitorItem(string& items[][SECDEMENSION],string symbo){
   //默认监控:日图背离、周图背离、月图背离，周图MACD 0 轴，月图MACD 0 轴、周图随机指数20，月图随机指数20，周图随机指数80，月图随机指数80
   if(symbo == NULL) return;
   //日图背离
   parseRulesAndFill(items,"SDG#"+symbo+"#D1#观察下");
   parseRulesAndFill(items,"MDG#"+symbo+"#D1#观察下");
   //周图背离
   parseRulesAndFill(items,"SDG#"+symbo+"#W1#观察下");
   parseRulesAndFill(items,"MDG#"+symbo+"#W1#观察下");
   //月图背离
   parseRulesAndFill(items,"SDG#"+symbo+"#MN#观察下");
   parseRulesAndFill(items,"MDG#"+symbo+"#MN#观察下");
   //日图MACD 0 轴
   parseRulesAndFill(items,"MZ#"+symbo+"#D1#观察下");
   //周图MACD 0 轴
   parseRulesAndFill(items,"MZ#"+symbo+"#W1#观察下");
   //月图MACD 0 轴
   parseRulesAndFill(items,"MZ#"+symbo+"#MN#观察下");
   //周图随机指数20 
   parseRulesAndFill(items,"FC20#"+symbo+"#W1#观察下");
   //月图随机指数20
   parseRulesAndFill(items,"FC20#"+symbo+"#MN#观察下");
   //周图随机指数80 
   parseRulesAndFill(items,"FC80#"+symbo+"#W1#观察下");
   //月图随机指数80
   parseRulesAndFill(items,"FC80#"+symbo+"#MN#观察下");
   //周图快线穿越慢线
   parseRulesAndFill(items,"FCS#"+symbo+"#W1#观察下");
   //月图快线穿越慢线
   parseRulesAndFill(items,"FCS#"+symbo+"#MN#观察下");
}