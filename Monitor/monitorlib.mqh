//+------------------------------------------------------------------+
//|                                                      monitor.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

//monitor function definition
#define PC "PC"
#define MZ "MZ"
#define FC20 "FC20"
#define FC80 "FC80"
#define FCS "FCS"
#define SDG "SDG"
#define MDG "MDG"

//demension definition
#define SECDEMENSION 4

#include <Monitor/common.mqh>
#include <Monitor/macd.mqh>
#include <Monitor/stoch.mqh>
#include <Monitor/price.mqh>
#include <Monitor/Item.mqh>
#include <Monitor/PlanStep.mqh>
#include <Monitor/Plan.mqh>
#include <Monitor/PCItem.mqh>
#include <Monitor/MZItem.mqh>
#include <Monitor/FC20Item.mqh>
#include <Monitor/FC80Item.mqh>
#include <Monitor/FCSItem.mqh>
#include <Monitor/MDGItem.mqh>
#include <Monitor/SDGItem.mqh>
#include <Monitor/KFAItem.mqh>
#include <Monitor/2BItem.mqh>
#include <Monitor/ATRItem.mqh>

string lastNotificationMsg = "";
void execute(CPlan* node,int shift,bool isEmail){
   string notificationMsg = "";
   bool send = false;
   CPlanStep* firstStep = node.getFirstStep();
   bool nextStep = canContinue(firstStep);
   if(nextStep){
       send = true;
       StringAdd(notificationMsg,StringConcatenate(firstStep.getMsg(),"\n"));
   }       
   if(send){
       if(lastNotificationMsg!=notificationMsg){
          lastNotificationMsg = notificationMsg;
          alertMsg(notificationMsg,shift>0,shift,isEmail);
       }
   } 
}

/**
void initConfig(string& items[][SECDEMENSION]){
   int priceCrossSize=0,macdZeroSize =0,fastCrossSlowSize=0,stoch20Size=0,stoch80Size=0,stochDivergenceSize =0,macdDivergenceSize=0;
   int size = ArraySize(items);
   if(size == 0) return;
   int rowCount = size/SECDEMENSION;
   for(int i=0;i<rowCount;i++){
      string type = items[i,0];
      if(PC == type){
          priceCrossSize++;
      }else if(MZ == type){
          macdZeroSize ++;
      }else if(FC20 == type){
          stoch20Size++;
      }else if(FC80 == type){
          stoch80Size++;
      }else if(FCS == type){
          fastCrossSlowSize ++;
      }else if(SDG == type){
          stochDivergenceSize++;
      }else if(MDG == type){
          macdDivergenceSize++;
      }
   }
   //按照各个模块进行初始化
   initPriceParams(priceCrossSize);
   initMACDParams(macdZeroSize,macdDivergenceSize);
   initStochParams(fastCrossSlowSize,stoch20Size,stoch80Size,stochDivergenceSize);
}

void parseRulesAndFills(CPlanStep* step,string rule){
   if(rule == NULL) return;
   string tmp[];
   ushort sp = StringGetCharacter("&",0);
   StringSplit(rule,sp,tmp);
   int splitSize = ArraySize(tmp);
   if(splitSize>0){
      for(int i=0;i<splitSize;i++){
          parseRulesAndFill(step,tmp[i]);
      }
   }
}

void parseRulesAndFill(string& items[][SECDEMENSION],string rule){
   string tmp[];
   ushort sp = StringGetCharacter("#",0);
   StringSplit(rule,sp,tmp);
   int splitSize = ArraySize(tmp);
   
   int size = ArraySize(items);
   int row = size/SECDEMENSION;
   int count = ArrayResize(items,row+1);
   
   for(int i=0;i<splitSize;i++){
       items[row][i] = tmp[i];
   }
}**/


void delAllObject(){
   delAllMACDObject();
   delAllStochObject();
}

/*******************************************Releated methods of Plans,New Way*************************************************/

CList* plans = new CList();
//planName@msg@xxx#xxx#xxx||xxx#xxx#xxx@xxx#xxx#xxx&&xxx#xxx#xxx@xxx#xxx#xxx&&xxx#xxx#xxx
//planName msg      firstStep                secondStep              thirdStep
void parseOnePlan(string plan){
   if(plan == NULL || plan == "") return;
   string tmp[];
   ushort sp = StringGetCharacter("@",0);
   StringSplit(plan,sp,tmp);
   int splitSize = ArraySize(tmp);
   
   CPlan* planInfo = new CPlan();   
   if(splitSize>0){
      planInfo.setName(tmp[0]);
      planInfo.setMsg(tmp[1]);
      if(splitSize>2){
         CPlanStep* step1 = new CPlanStep();
         parsePlanStep(step1,tmp[2]);
         planInfo.setFirstStep(step1);
      }
      if(splitSize>3){
         CPlanStep* step2 = new CPlanStep();
         parsePlanStep(step2,tmp[3]);
         planInfo.setSecondStep(step2);
      }
      if(splitSize>4){
         CPlanStep* step3 = new CPlanStep();
         parsePlanStep(step3,tmp[4]);
         planInfo.setThirdStep(step3);
      }
      plans.Add(planInfo);
   }
}

void parsePlanStep(CPlanStep* step,string stepStr){
   if(stepStr == NULL) return;
   //xxx#xxx#xxx&xxx#xxx#xxx
   string tmp[];
   ushort sp = StringGetCharacter("&",0);
   StringSplit(stepStr,sp,tmp);
   int splitSize = ArraySize(tmp);
   
   for(int i=0;i<splitSize;i++){
       parseRulesAndFill(step,tmp[i]);
   }
}

void parseRulesAndFill(CPlanStep* step,string rule){
   if(rule == NULL || rule == "") return ;
   string tmp[];
   ushort sp = StringGetCharacter("#",0);
   StringSplit(rule,sp,tmp);
   int splitSize = ArraySize(tmp);
   
   if(TYPE_PC == tmp[0]){
       //PC#EURUSD#1.02303#监控h4和h1了#UP
       CPCItem* pcItem = new CPCItem();
       pcItem.setSymbo(tmp[1]);
       pcItem.setPeriodOrPrice(tmp[2]);
       pcItem.setMsg(tmp[3]);
       if(splitSize>4){
          pcItem.setExpectVal(tmp[4]);
       }
       if(pcItem.getSymbo()!=NULL){
          step.addItem(pcItem);
       }
   }else if(TYPE_MZ == tmp[0]){
       CMZItem* mzItem = new CMZItem();
       mzItem.setSymbo(tmp[1]);
       mzItem.setPeriodOrPrice(tmp[2]);
       mzItem.setMsg(tmp[3]);
       if(splitSize>4){
          mzItem.setExpectVal(tmp[4]);
       }
       if(mzItem.getSymbo()!=NULL){
          step.addItem(mzItem);
       }
   }else if(TYPE_FC20 == tmp[0]){
       CFC20Item* fc20Item = new CFC20Item();
       fc20Item.setSymbo(tmp[1]);
       fc20Item.setPeriodOrPrice(tmp[2]);
       fc20Item.setMsg(tmp[3]);
       if(splitSize>4){
          fc20Item.setExpectVal(tmp[4]);
       }
       if(fc20Item.getSymbo()!=NULL){
          step.addItem(fc20Item);
       }
   }else if(TYPE_FC80 == tmp[0]){
       CFC80Item* fc80Item = new CFC80Item();
       fc80Item.setSymbo(tmp[1]);
       fc80Item.setPeriodOrPrice(tmp[2]);
       fc80Item.setMsg(tmp[3]);
       if(splitSize>4){
          fc80Item.setExpectVal(tmp[4]);
       }
       if(fc80Item.getSymbo()!=NULL){
          step.addItem(fc80Item);
       }
   }else if(TYPE_FCS == tmp[0]){
       CFCSItem* fcsItem = new CFCSItem();
       fcsItem.setSymbo(tmp[1]);
       fcsItem.setPeriodOrPrice(tmp[2]);
       fcsItem.setMsg(tmp[3]);
       if(splitSize>4){
          fcsItem.setExpectVal(tmp[4]);
       }
       if(fcsItem.getSymbo()!=NULL){
          step.addItem(fcsItem);
       }
   }else if(TYPE_MDG == tmp[0]){
       CMDGItem* mdgItem = new CMDGItem();
       mdgItem.setSymbo(tmp[1]);
       mdgItem.setPeriodOrPrice(tmp[2]);
       mdgItem.setMsg(tmp[3]);
       if(mdgItem.getSymbo()!=NULL){
          step.addItem(mdgItem);
       }
   }else if(TYPE_SDG == tmp[0]){
       CSDGItem* sdgItem = new CSDGItem();
       sdgItem.setSymbo(tmp[1]);
       sdgItem.setPeriodOrPrice(tmp[2]);
       sdgItem.setMsg(tmp[3]);
       if(sdgItem.getSymbo()!=NULL){
          step.addItem(sdgItem);
       }
   }else if(TYPE_KFA == tmp[0]){
       CKFAItem* kfaItem = new CKFAItem();
       kfaItem.setSymbo(tmp[1]);
       kfaItem.setPeriodOrPrice(tmp[2]);
       kfaItem.setMsg(tmp[3]);
       if(kfaItem.getSymbo()!=NULL){
          step.addItem(kfaItem);
       }
   }else if(TYPE_2B == tmp[0]){
       C2BItem* b2Item = new C2BItem();
       b2Item.setSymbo(tmp[1]);
       b2Item.setPeriodOrPrice(tmp[2]);
       b2Item.setMsg(tmp[3]);
       if(splitSize>4){
          b2Item.setExpectVal(tmp[4]);
       }
       if(b2Item.getSymbo()!=NULL){
          step.addItem(b2Item);
       }
   }else if(TYPE_ATR == tmp[0]){
       //ATR#EURUSD#H1#0.00017#监控h4和h1了  
       CATRItem* atrItem = new CATRItem();
       atrItem.setSymbo(tmp[1]);
       atrItem.setPeriodOrPrice(tmp[2]);
       atrItem.setExpectVal(tmp[3]);
       atrItem.setMsg(tmp[4]);
       if(atrItem.getSymbo()!=NULL){
          step.addItem(atrItem);
       }
   }
}

bool canContinue(CPlanStep* step){
   if(step == NULL || step.getItems()==NULL) return true;

   CItem* node = step.getItems().GetFirstNode();
   bool ret = false;
   string retMsg = "";
    for(int i = 0; node != NULL; i++, node = node.Next()){
       if(node.getType() == TYPE_PC){
           CPCItem* tmp = node; 
           bool result = tmp.calc();
           if(result!=NULL && result == true){
               StringAdd(retMsg,StringConcatenate(tmp.getMsg(),"\r\n"));
               if(ret == false){ ret = result;}
           }
       }else if(node.getType() == TYPE_MZ){
           CMZItem* tmp = node;
           bool result = tmp.calc();
           if(result!=NULL && result == true){
               StringAdd(retMsg,StringConcatenate(tmp.getMsg(),"\r\n"));
               if(ret == false){ ret = result;}
           }
       }else if(node.getType() == TYPE_FC20){
           CFC20Item* tmp = node;
           bool result = tmp.calc();
           if(result!=NULL && result == true){
               StringAdd(retMsg,StringConcatenate(tmp.getMsg(),"\r\n"));
               if(ret == false){ ret = result;}
           }
       }else if(node.getType() == TYPE_FC80){
           CFC80Item* tmp = node;
           bool result = tmp.calc();
           if(result!=NULL && result == true){
               StringAdd(retMsg,StringConcatenate(tmp.getMsg(),"\r\n"));
               if(ret == false){ ret = result;}
           }
       }else if(node.getType() == TYPE_FCS){
           CFCSItem* tmp = node;
           bool result = tmp.calc();
           if(result!=NULL && result == true){
               StringAdd(retMsg,StringConcatenate(tmp.getMsg(),"\r\n"));
               if(ret == false){ ret = result;}
           }
       }else if(node.getType() == TYPE_MDG){
           CMDGItem* tmp = node;
           bool result = tmp.calc();
           if(result!=NULL && result == true){
               StringAdd(retMsg,StringConcatenate(tmp.getMsg(),"\r\n"));
               if(ret == false){ ret = result;}
           }
       }else if(node.getType() == TYPE_SDG){
           CSDGItem* tmp = node;
           bool result = tmp.calc();
           if(result!=NULL && result == true){
               StringAdd(retMsg,StringConcatenate(tmp.getMsg(),"\r\n"));
               if(ret == false){ ret = result;}
           }
       }else if(node.getType() == TYPE_KFA){
           CKFAItem* tmp = node;
           tmp.calc();
       }else if(node.getType() == TYPE_2B){
           C2BItem* tmp = node;
           bool result = tmp.calc();
           if(result!=NULL && result == true){
               StringAdd(retMsg,StringConcatenate(tmp.getMsg(),"\r\n"));
               if(ret == false){ ret = result;}
           }
       }else if(node.getType() == TYPE_ATR){
           CATRItem* tmp = node;
           bool result = tmp.calc();
           if(result!=NULL && result == true){
               StringAdd(retMsg,StringConcatenate(tmp.getMsg(),"\r\n"));
               if(ret == false){ ret = result;}
           }
       }
   }
   step.setResult(ret);
   step.setMsg(retMsg);
   return ret;
}

void execute(int shift,bool isEmail){
   
   CPlan* node = plans.GetFirstNode();
   for(int i = 0; node != NULL; i++, node = node.Next()){
       string notificationMsg = "";
       bool send = false;
       StringAdd(notificationMsg,StringConcatenate("----------------",node.getName(),"----------------","\n"));
       //first step is full?
       CPlanStep* firstStep = node.getFirstStep();
       bool nextStep = canContinue(firstStep);
       if(nextStep){
           StringAdd(notificationMsg,StringConcatenate("第一步满足条件：",firstStep.getMsg(),"\n"));
           CPlanStep* secondStep = node.getSecondStep();
           if(secondStep == NULL){
               send = true;
               StringAdd(notificationMsg,StringConcatenate("所有条件已经满足：",node.getMsg()));
           }else{
               nextStep = canContinue(secondStep);
               if(nextStep){
                 StringAdd(notificationMsg,StringConcatenate("第二步满足条件：",secondStep.getMsg(),"\n"));
                 CPlanStep* thridStep = node.getThirdStep();
                 if(thridStep == NULL){
                    StringAdd(notificationMsg,StringConcatenate("所有条件已经满足：",node.getMsg()));
                    send = true;
                 }else{
                    nextStep = canContinue(thridStep);
                    if(nextStep){
                        StringAdd(notificationMsg,StringConcatenate("第三步满足条件：",thridStep.getMsg(),"\n"));
                        StringAdd(notificationMsg,StringConcatenate("所有条件已经满足：",node.getMsg()));
                        send = true;
                    }
                 }
               }
           }
       }
       if(send){
          if(node.getAlertCount()<3){
             StringAdd(notificationMsg,StringConcatenate("\n","----------------",node.getName(),"----------------","\n"));
             alertMsg(notificationMsg,shift>0,shift,isEmail);
             node.setAlertCount(node.getAlertCount()+1);
          }
          
       }
   }
}