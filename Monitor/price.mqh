//+------------------------------------------------------------------+
//|                                                        price.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict
#include <Monitor/common.mqh>



//Alert when price cross price.
//array to store price cross result
string priceCross[];
void alertWhenPriceCross(string symbol,double price,string msg,int index,int shift,string& notifyMsg){
    double vask = 0;
    bool isTesting = false;
    if(shift>0){
       vask = Close[shift];
       isTesting = true;
    }else{
       vask = MarketInfo(symbol,MODE_ASK);
    }
    string flag = priceCross[index];
    if(vask < price && flag ==UP ){
        priceCross[index] = DOWN;
        addToMsg(notifyMsg,StringConcatenate(symbol," 当前价格小于 ",price,",向下穿越,",msg,",当前价格:"+MarketInfo(symbol,MODE_ASK)),shift);
    }
    
    if(vask > price && flag ==DOWN){
        priceCross[index] =UP;
        addToMsg(notifyMsg,StringConcatenate(symbol," 当前价格大于 ",price,",向上穿越,",msg,",当前价格:"+MarketInfo(symbol,MODE_ASK)),shift);
        //alertMsg(,isTesting,shift);
    }
}


void initPriceParams(int priceCrossSize){
    initFlags(priceCross,priceCrossSize,DOWN);
} 