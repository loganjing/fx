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


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   //默认监控:H4 MACD背离,日图背离、周图背离、月图背离
   
   string fixSymbol = "_DXY,EURUSD,GBPUSD,USDJPY,AUDUSD,NZDUSD,USDCAD,XAUUSD,XAGUSD,GBPJPY,EURJPY,CADJPY,AUDJPY,NZDJPY,EURGBP,_WTI,GBPNZD,GBPAUD,GBPCAD,EURNZD,EURCAD,EURAUD";
   parseSymboMonthMonitorRule(configs,fixSymbol);
   //parseSymboMonthMonitorRule(configs,paris);

   //6月计划
   /**
   parseRulesAndFills(configs,"PC#NZDUSD#0.70018#价格到达月图第一支撑区域，可能存在简单的震荡交易机会&PC#NZDUSD#0.69100#价格到达月图第二支撑区域，可能存在简单的震荡交易机会。");
   parseRulesAndFills(configs,"PC#NZDUSD#0.72733#价格到达月图第一阻力区域，可能存在简单的震荡交易机会&PC#NZDUSD#0.73651#价格到达月图第二阻力区域，可能存在简单的震荡交易机会。");
   parseRulesAndFills(configs,"FC20#NZDUSD#D1#如果价格到达了月支撑区域，可以找机会做多&FC80#NZDUSD#D1#如果价格到达了月阻力区域，可以找机会做空。");
   parseRulesAndFills(configs,"PC#AUDUSD#0.72943#价格到达月图第一支撑区域，可能存在简单的震荡交易机会&PC#AUDUSD#0.71419#价格到达月图第二支撑区域，可能存在简单的震荡交易机会。");
   parseRulesAndFills(configs,"PC#AUDUSD#0.75991#价格到达月图第一阻力区域，可能存在简单的震荡交易机会&PC#AUDUSD#0.77149#价格到达月图第二阻力区域，可能存在简单的震荡交易机会。");
   parseRulesAndFills(configs,"FC20#AUDUSD#D1#如果价格到达了月支撑区域，可以找机会做多&FC80#AUDUSD#D1#如果价格到达了月阻力区域，可以找机会做空。");
   parseRulesAndFills(configs,"PC#GBPUSD#1.26764#价格到达月图第一支撑区域，可能存在简单的震荡交易机会&PC#GBPUSD#1.24547#价格到达月图第二支撑区域，可能存在简单的震荡交易机会。");
   parseRulesAndFills(configs,"PC#GBPUSD#1.32031#价格到达月图第一阻力区域，可能存在简单的震荡交易机会&PC#GBPUSD#1.34341#价格到达月图第二阻力区域，可能存在简单的震荡交易机会。");
   parseRulesAndFills(configs,"FC20#GBPUSD#D1#如果价格到达了月支撑区域，可以找机会做多&FC80#GBPUSD#D1#如果价格到达了月阻力区域，可以找机会做空。");
   parseRulesAndFills(configs,"PC#EURUSD#1.10767#价格到达月图第一支撑区域，可能存在简单的震荡交易机会&PC#EURUSD#1.09048#价格到达月图第二支撑区域，可能存在简单的震荡交易机会。");
   parseRulesAndFills(configs,"PC#EURUSD#1.14564#价格到达月图第一阻力区域，可能存在简单的震荡交易机会&PC#EURUSD#1.16068#价格到达月图第二阻力区域，可能存在简单的震荡交易机会。");
   parseRulesAndFills(configs,"FC20#EURUSD#D1#如果价格到达了月支撑区域，可以找机会做多&FC80#EURUSD#D1#如果价格到达了月阻力区域，可以找机会做空。");
   parseRulesAndFills(configs,"PC#_DXY#94.79#价格到达月图第一支撑区域，可能存在简单的震荡交易机会&PC#_DXY#92.6#价格到达月图第二支撑区域，可能存在简单的震荡交易机会。");
   parseRulesAndFills(configs,"PC#_DXY#99.26#价格到达月图第一阻力区域，可能存在简单的震荡交易机会&PC#_DXY#101.18#价格到达月图第二阻力区域，可能存在简单的震荡交易机会。");
   parseRulesAndFills(configs,"FC20#_DXY#D1#如果价格到达了月支撑区域，可以找机会做多&FC80#_DXY#D1#如果价格到达了月阻力区域，可以找机会做空。");   
   parseRulesAndFills(configs,"PC#USDJPY#105.895#微小客观止损位置&PC#USDJPY#108.187#微小客观止损位置&PC#USDJPY#110.104#微小客观止损位置&PC#USDJPY#112.259#微小客观止损位置&PC#USDJPY#114.518#微小客观止损位置&PC#USDJPY#115.612#微小客观止损位置");   
   **/
   
   
 
   //




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
   //默认监控:H4 MACD背离,日图背离、周图背离、月图背离
   if(symbo == NULL) return;
   //H4背离   
   //parseRulesAndFill(items,"SDG#"+symbo+"#H4#观察下");
   //parseRulesAndFill(items,"MDG#"+symbo+"#H4#观察下");
   //日图背离
   //parseRulesAndFill(items,"SDG#"+symbo+"#D1#观察下");
   parseRulesAndFill(items,"MDG#"+symbo+"#D1#观察下");
   if("_WTI" == symbo){return;}
   //周图背离
   parseRulesAndFill(items,"SDG#"+symbo+"#W1#观察下");
   parseRulesAndFill(items,"MDG#"+symbo+"#W1#观察下");
   //月图背离
   parseRulesAndFill(items,"SDG#"+symbo+"#MN#观察下");
   //parseRulesAndFill(items,"MDG#"+symbo+"#MN#观察下");
 
}