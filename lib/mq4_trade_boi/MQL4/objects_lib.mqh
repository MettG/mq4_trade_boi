// All data objects for Trade Boi

double FlatDouble(double ValueToFlatten, int digs = 0)
{
   if(digs == 0) digs = Digits;
   double Power = pow(10, digs);
   double ReturnValue;
   
   ReturnValue = MathRound(Power * ValueToFlatten) / Power ;
   return (ReturnValue);
}

void AddError(Error & e) {
    Error * temp[];
    int newSize = ArraySize(errors)+1;
    ArrayResize(temp,newSize);
    ArrayCopy(errors,temp);
    temp[newSize-1] = e;
    ArrayCopy(temp,errors);
}

void AddData(string k, double v) {
    DataObject * d = new DataObject(k,v);
    Error * temp[];
    int newSize = ArraySize(data)+1;
    ArrayResize(temp,newSize);
    ArrayCopy(data,temp);
    temp[newSize-1] = d;
    ArrayCopy(temp,data);
}

void AddCommand(CommandObject & c) {
    Error * temp[];
    int newSize = ArraySize(commands)+1;
    ArrayResize(temp,newSize);
    ArrayCopy(commands,temp);
    temp[newSize-1] = c;
    ArrayCopy(temp,commands);
}

class Error {
    private:
        string err[1];
        int i;
    public:
        Error(string time) {
            err[0] = time;
            i = 0;
        }
        void Add(string s) {
            string temp[];
            int newSize = ArraySize(err)+1;
            ArrayResize(temp,newSize);
            ArrayCopy(err,temp);
            temp[newSize-1] = s;
            ArrayCopy(temp,err);
        }
        string Next() {
            if( i >= ArraySize(err)) {
                Print("Error Object empty.")
                return;
            }
            string s = err[i];
            i++;
            return s;
        }
        int Size() {
            return ArraySize(err);
        }
};


class DataObject {
    private:
        string key,add[];
        double val;
    public:
        DataObject(string k, double v) {
            key = k;
            val = FlatDouble(v);
        }

        void Add(double v) {
            string temp[];
            int newSize = ArraySize(add)+1;
            ArrayResize(temp,newSize);
            ArrayCopy(add,temp);
            temp[newSize-1] = DoubleToStr(v);
            ArrayCopy(temp,add);
        }

        string Key() {
            return key;
        }

        string Val() {
            return DoubleToStr(val);
        }
        string FileStr() {
            int addSize = ArraySize(add);
            if( addSize < 1)
                return Key() + "_" + Val();
            string info = Key() + "_" + Val();
            for(int i = 0; i < addSize; i++) {
                info += "_" + add[i];
            }
            return info;
        }
};

class CommandObject {
    private:
        string command;
        double args[];
        int i;
    public:
        CommandObject(string c) {
            command = c;
            i = 0;
        }
        void AddArg(double val) {
            double temp[];
            int newSize = ArraySize(args)+1;
            ArrayResize(temp,newSize);
            ArrayCopy(args,temp);
            temp[newSize-1] = FlatDouble(val);
            ArrayCopy(temp,args);
        }
        string Key() {
            return command;
        }
        double GetNextArg() {
            if(i >= ArraySize(args)) {
                alert("Critical Error! Trying to call more commands args than is possible!");
                Error * e = new Error(TimeToString(TimeCurrent()));
                e.add("Error: Commands call too many args.");
                e.add("Status: Critical");
                e.add("Action: Close_Abort");
                AddError(e);
                return;
            }
            double a = args[i];
            i++;
            return a;
        }
};
