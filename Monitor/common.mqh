//+------------------------------------------------------------------+
//|                                                       common.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+

//direction definition
#define UP   "UP"
#define DOWN   "DOWN"

#define TYPE_PC       "PC"     // PRICE CROSS      PC#EURUSD#1.02303#监控h4和h1了#UP
#define TYPE_FCS      "FCS"    //FAST CROSS SLOW FOR STOCH  FCS#EURUSD#D1#监控h4和h1了#UP
#define TYPE_FC20     "FC20"   //FAST CROSS 20 FOR STOCH   FC20#EURUSD#D1#监控h4和h1了#UP
#define TYPE_FC80     "FC80"   //FAST CROSS 80 FOR STOCH   FC80#EURUSD#D1#监控h4和h1了#UP
#define TYPE_MZ       "MZ"     //MACD CROSS ZERO  MZ#EURUSD#D1#监控h4和h1了#UP
#define TYPE_SDG      "SDG"    //STOCH DIRVERGENCE,8,5,3  SDG#EURUSD#D1#监控h4和h1了
#define TYPE_MDG      "MDG"    //MACD DIRVERGENCE 5,34,5  MDG#EURUSD#D1#监控h4和h1了
#define TYPE_KFA       "KFA"   //ALERT TO WATCH When EVERY K FINISHED   KFA#EURUSD#H1#MSG
#define TYPE_2B       "2B"     //2B   2B#EURUSD#1.02303#xxxxx#UP
#define TYPE_ATR       "ATR"   //ATR   ATR#EURUSD#H1#1.02303#MSG#UP

//macd parameters
#define QUICKEMA  5
#define SLOWEMA  34
#define MACDSMA  5

//stoch parameter
#define QUICKPERIOD  8
#define SLOWEPERIOD  5
#define STOCHSLOW  3

//max index of calc MACD & Stoch Divergence
#define MAXCOUNT 100
//LINE COLOR
color peakColor = Red;
color troughColor = Blue;

int getPeriod(string period){
   if("MN" == period){
       return PERIOD_MN1;
   }else if("W1" == period){
       return PERIOD_W1;
   }else if("D1" == period){
       return PERIOD_D1;
   }else if("H4" == period){
       return PERIOD_H4;
   }else if("H1" == period){
       return PERIOD_H1;
   }else if("M30" == period){
       return PERIOD_M30;
   }else if("M15" == period){
       return PERIOD_M15;
   }else if("M5" == period){
       return PERIOD_M5;
   }else if("M1" == period){
       return PERIOD_M1;
   }
   return PERIOD_D1;
}

string getPeriodLabel(int period){
   if(PERIOD_D1 == period){
       return " D1";
   }else if(PERIOD_H4 == period){
       return " H4";
   }else if(PERIOD_H1 == period){
       return " H1";
   }else if(PERIOD_M30 == period){
       return " M30";
   }else if(PERIOD_M15 == period){
       return " M15";
   }else if(PERIOD_M5 == period){
       return " M5";
   }else if(PERIOD_M1 == period){
       return " M1";
   }else if(PERIOD_W1 == period){
       return " W1";
   }else if(PERIOD_MN1 == period){
       return " MN";
   }
   return "";
}




void drawArrow(datetime x1,double y1,color lineColor,double style,string type,string symbol,int period,string indicatorName){
   if(symbol == Symbol() && period == Period()){
      int indicatorWindow=WindowFind(indicatorName);
      if(indicatorWindow<0)
         return;
      string label="Arrow_DivergenceLine$#"+DoubleToStr(x1,0);
      ObjectDelete(label);
      if(type == "DOWN"){
         ObjectCreate(label,OBJ_ARROW_DOWN,indicatorWindow,x1,y1);
      }else{
         ObjectCreate(label,OBJ_ARROW_UP,indicatorWindow,x1,y1);
      }
      ObjectSet(label,OBJPROP_COLOR,lineColor);
      ObjectSet(label,OBJPROP_STYLE,style);
   }
}

void drawTip(datetime x1,double y1,color lineColor,double style){
   string label="Arrow_Tip"+DoubleToStr(x1,0);
   ObjectDelete(label);
   ObjectCreate(label,OBJ_ARROW_UP,0,x1,y1);
   ObjectSet(label,OBJPROP_COLOR,lineColor);
   ObjectSet(label,OBJPROP_STYLE,style);
   ObjectSet(label,OBJPROP_ARROWCODE, SYMBOL_CHECKSIGN);
}

void initFlags(string& arr[],int size,string defVal){
   if(size == 0 ) return;
   ArrayResize(arr,size);
   for(int i=0;i<size;i++){
       arr[i] = defVal;
   }
}  

void initDateTimeArray(datetime& arr[],int size){
   if(size == 0 ) return;
   ArrayResize(arr,size);
   for(int i=0;i<size;i++){
       arr[i] = NULL;
   }
}

void initDoubleArray(double& arr[],int size){
   if(size == 0 ) return;
   ArrayResize(arr,size);
   for(int i=0;i<size;i++){
       arr[i] = 0;
   }
}

void alertMsg(string msg,bool isTesting,int shift,bool isEmail){
   if(!isTesting){
      if(isEmail){
         SendMail("ForexAlert",StringConcatenate(msg));
      }else{
         SendNotification(StringConcatenate(msg));
      }
      
   }else{
      drawTip(Time[shift],Close[shift],Blue,STYLE_SOLID);
      //Alert(Time[shift]+":-->"+msg);
      Alert(TimeToStr(Time[shift]),"-->",msg,Symbol());
      
   }
}

void addToMsg(string& notifiyMsg,string msg,int shift){
   StringAdd(notifiyMsg,StringConcatenate(msg,"\n"));
}