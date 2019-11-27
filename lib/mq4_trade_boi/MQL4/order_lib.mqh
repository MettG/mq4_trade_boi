// All order methods for Trade Boi

double FlatDouble(double ValueToFlatten, int digs = 0)
{
   if(digs == 0) digs = Digits;
   double Power = pow(10, digs);
   double ReturnValue;
   
   ReturnValue = MathRound(Power * ValueToFlatten) / Power ;
   return (ReturnValue);
}

double LotValue(string symb, int stopPoints) {
    RefreshRates();
    double l = (AccountFreeMargin() * LEVERAGE *.5 / 100) / ( stopPoints * MarketInfo( symb, MODE_TICKVALUE ) );
    l = MathFloor( l / MarketInfo(symb,MODE_LOTSTEP)) * MarketInfo(symb,MODE_LOTSTEP);
    if(l < MarketInfo(symb,MODE_MINLOT)) l = MarketInfo(symb,MODE_MINLOT);
    return FlatDouble(l,2); 
}

int FindOrder(double open) {
    for(int i=0; i < OrdersTotal(); i++) {
        if(OrderSelect(i,SELECT_BY_POS)) {
            if(OrderSymbol() != Symbol()) continue;
            if(open == OrderOpenPrice()) return OrderTicket();
        }
    }
}

void EnterSell(double stop, double take) {
    //Enter sell two orders, one with no take
    int i = 0;
    int points = int(MathAbs(Ask - stop) / Point);
    // Print("Total stop pips: ", points);
    double lots = LotValue(symbol,points);
    while(i < 5) {
        ResetLastError();
        if(!OrderSend(symbol,1,lots,Ask,3,stop,take)) {
        } else {
            if(SymbolOrders() > 1) {
                Print("Orders completed!");
                return;
            }

            if(!OrderSend(symbol,1,lots,Ask,3,stop,0)) {}
            else {
            Print("Order Entered!");
            return;
            }
        }
        i++;
        Alert("Order Send failed retrying! Error: " + IntegerToString(GetLastError()));
        Sleep(2000);
    }
    Alert("Critical Error! Sell failed to enter!");
    Error * e = new Error(TimeToString(TimeCurrent()));
    e.add("Error: Sell failed.");
    e.add("Status: Urgent");
    e.add("Action: Abort_Ping");
    AddError(e);
}

void EnterBuy(double stop, double take) {
    //Enter buy two orders, one with no take
    int i = 0;
    int points = int(MathAbs(Bid - stop) / Point);
    // Print("Total stop pips: ", points);
    double lots = LotValue(symbol,points);
    while(i < 5) {
        ResetLastError();
        if(!OrderSend(symbol,0,lots,Bid,3,stop,take)) {
        } else {
            if(SymbolOrders() > 1) {
                Print("Orders completed!");
                return;
            }

            if(!OrderSend(symbol,0,lots,Bid,3,stop,0)) {}
            else {
            Print("Order Entered!");
            return;
            }
        }
        i++;
        Alert("Order Send failed retrying! Error: " + IntegerToString(GetLastError()));
        Sleep(2000);
    }
    Alert("Critical Error! Sell failed to enter!");
    Error * e = new Error(TimeToString(TimeCurrent()));
    e.add("Error: Sell failed.");
    e.add("Status: Urgent");
    e.add("Action: Abort_Ping");
    AddError(e);
}

int SymbolOrders() {
    int count = 0;
    for(int i = 0; i < OrdersTotal(); i++) {
        if(OrderSelect(i,SELECT_BY_POS)) {
            if(OrderSymbol() != symbol) continue;
            count++;
        }
    }
    return count;
}

void CloseOut(double open) {
    int id = FindOrder(open);
    //Close order
    if(!OrderSelect(id,SELECT_BY_TICKET)) {
        Alert("Critical Error! No such order id to close!");
        Error * e = new Error(TimeToString(TimeCurrent()));
        e.add("Error: No such id for order close.");
        e.add("Status: Urgent");
        e.add("Action: Abort_Ping");
        AddError(e);
    }
    else {
        int i = 0;
        while(i < 5) {
            ResetLastError();
            if(!OrderClose(id,lots,price,slippage)) {
                Alert(symbol + " Order close failed! Error: "+ IntegerToString(GetLastError()) + " retrying...");
                Sleep(2000);
            }else {
                Print("Order Successfully Closed.");
                Error * e = new Error(TimeToString(TimeCurrent()));
                e.add("Info: Order Closed!");
                e.add("Status: Success");
                e.add("Action: Ping");
                AddError(e);
                return;
            }
            i++;
        }
        Alert("Order Close timed out!");
        Error * e = new Error(TimeToString(TimeCurrent()));
        e.add("Error: Close Order failed!");
        e.add("Status: Critical");
        e.add("Action: Ping");
        AddError(e);
    }
}

void ModOrder(double open, double newStop) {
    int id = FindOrder(open);
    // Select order, make sure newStop is allowed, modify order
    if(!OrderSelect(id,SELECT_BY_TICKET)) {
        Alert("Critical Error! No such order id to modify!");
        Error * e = new Error(TimeToString(TimeCurrent()));
        e.add("Error: No such id for modification.");
        e.add("Status: Urgent");
        e.add("Action: Abort_Ping");
        AddError(e);
    } else {
        int type = OrderType();
        double stop = OrderStopLoss();
        double take = OrderTakeProfit();
        if(type == 0) {
            if(newStop <= stop || Bid - newStop <= MarketInfo(symbol, MODE_STOPLEVEL)) return;
        } else {
            if(newStop >= stop || newStop - Ask <= MarketInfo(symbol, MODE_STOPLEVEL)) return;
        }
        i = 0;
        while(i < 5) {
            ResetLastError();
            if(!OrderModify(id,open,newStop,take,0)) {
                Alert("Order Modification failed retrying! Error: " + IntegerToString(GetLastError()) + " " + DoubleToString(MathAbs(open - newStop) / Point,0) + " Pips.");
                Sleep(2000);
            }else {
                Print("Order Modified! ", DoubleToString(MathAbs(open - newStop) * Point,0) + " Pips.");
                Error * e = new Error(TimeToString(TimeCurrent()));
                e.add("Info: Order Modified! + " + DoubleToString(MathAbs(open - newStop) * Point,0) + " Pips.");
                e.add("Status: Success");
                e.add("Action: Ping");
                AddError(e);
                return;
            }
            i++;
        }
        Alert("Order Modification timed out! Too many failures.");
        Error * e = new Error(TimeToString(TimeCurrent()));
        e.add("Error: Modification failed!");
        e.add("Status: Critical");
        e.add("Action: Ping");
        AddError(e);
    }
}
