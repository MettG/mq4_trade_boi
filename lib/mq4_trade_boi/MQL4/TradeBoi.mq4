#include "order_lib.mqh"
#include "file_lib.mqh"
#include "objects_lib.mqh"
extern int LEVERAGE = 7; // Leverage in percent
/*
    Note: All paths must be into the ruby application's data folder, then run the ruby at the same time this is running.
*/
string path = symbol+"_"+Period();
const string DATA_PATH = "./data/"+path+"/"+path+".txt";
const string COMMAND_PATH = "./data/"+path+"/com_"+path+".txt";
const string ERROR_PATH = "./data/"+path+"/error_"+path+".txt";
string symbol;
Error * errors;
CommandObject * commands;
DataObject * data;
int init() {
    symbol = Symbol();
}

int start() {
    if(TimeSeconds(TimeCurrent()) == 0) {
        Process();
    }
}

void Process() {
    GatherData();
    DataToFile();
    GetCommand();
    InterpretCommand();
}

void InterpretCommand() {
    if(ArraySize(commands) < 1) {
        Print("No commands, sleeping...");
        Sleep(5000);
    }
    for(i=0;i<ArraySize(commands);i++) {
        string val = commands[i].Key());
        // Buy and sell pass stop and take
        if(StringCompare("buy",val,false) == 0) {
            EnterBuy(commands[i].GetNextArg(),commands[i].GetNextArg());
            break;
        }
        else if(StringCompare("sell",val,false) == 0) {
            EnterSell(commands[i].GetNextArg(),commands[i].GetNextArg());
            break;
        }
        // Pass open to match order and then new stop
        else if(StringCompare("modify",val,false) == 0) {
            ModOrder(commands[i].GetNextArg(),commands[i].GetNextArg());
            break;
        }
        // Pass open to match for close order
        else if(StringCompare("close",val,false) == 0) {
            CloseOut(commands[i].GetNextArg());
            break;
        }
        // For emergencies
        else if(StringCompare("abort",val,false) == 0) {
            ExpertRemove();
            break;
        }
        
    }
}

void GatherData() {
    MathSrand(TimeCurrent());
    AddData("serial",rand());
    int secondsSince = TimeCurrent() - Time[1];
    AddData("secondssince",(double) secondsSince);
    AddData("low",Low[0]);
    AddData("lastlow",Low[1]);
    AddData("high",High[0]);
    AddData("lasthigh",High[1]);
    AddData("basis",iMA(symbol,0,20,0,MODE_SMA,PRICE_CLOSE,1));
    AddData("atr",iATR(symbol,0,14,1));
    AddData("ask",Ask);
    AddData("bid",Bid);
    AddData("pip",Point);

    if(SymbolCount() < 1)
        AddData("ordernumber",0.0);
    else {
        for(int i = 0; i < OrdersTotal(); i++) {
            if(OrderSelect(i,SELECT_BY_POS)) {
                if(OrderSymbol() != symbol) continue;
                if(OrderTakeProfit() == 0) continue;
                dir = 1;
                if(OrderType() == 1) dir = -1;
                AddData("ordernumber",dir);
                data[ArraySize(data)-1].add(OrderOpenPrice());
                data[ArraySize(data)-1].add(OrderStopLoss());
                data[ArraySize(data)-1].add(OrderTakeProfit());
                break;
            }
        }
    }

}
