#include "list.mqh"
// All data objects for Trade Boi

class Error : ParentObj {
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
            ArrayCopy(temp,err);
            temp[newSize-1] = s;
            ArrayCopy(err,temp);
        }
        string Next() {
            if( i >= ArraySize(err)) {
                Print("Error Object empty.");
                return "";
            }
            string s = err[i];
            i++;
            return s;
        }
        int Size() {
            return ArraySize(err);
        }
};

class DataObject : ParentObj {
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
            ArrayCopy(temp,add);
            temp[newSize-1] = DoubleToStr(v);
            ArrayCopy(add,temp);
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

class CommandObject : ParentObj {
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
            ArrayCopy(temp,args);
            temp[newSize-1] = FlatDouble(val);
            ArrayCopy(args,temp);
        }
        string Key() {
            return command;
        }
        double GetNextArg() {
            if(i >= ArraySize(args)) {
                Alert("Critical Error! Trying to call more commands args than is possible!");
                return 0.0;
            }
            double a = args[i];
            i++;
            return a;
        }
};

double FlatDouble(double ValueToFlatten, int digs = 0)
{
   if(digs == 0) digs = Digits;
   double Power = pow(10, digs);
   double ReturnValue;
   
   ReturnValue = MathRound(Power * ValueToFlatten) / Power ;
   return (ReturnValue);
}







