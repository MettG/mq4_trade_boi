#include "variables.mqh"

void GetCommand() {
    int handle = FileOpen(COMMAND_PATH,FILE_READ|FILE_TXT);
    if(handle == INVALID_HANDLE) {
        Alert("Critical Error! Cannot read command file!");
        Error * e = new Error(TimeToString(TimeCurrent()));
        e.Add("Error: Commands file cannot be read.");
        e.Add("Status: Critical");
        e.Add("Action: Ping_Abort");
        AddError(e);
    } else {
        if(FileSize(handle) == 0) {
            Print("No commands.");
            return;
        } 
        while(!FileIsEnding(handle)){
            string str = FileReadString(handle);
            string sep="_";          
            ushort u_sep;
            string result[]; 
            u_sep=StringGetCharacter(sep,0);
            StringSplit(str,u_sep,result);
            CommandObject * c = new CommandObject(result[0]);
            for(int i = 1; i < ArraySize(result); i++) {
                c.AddArg(StrToDouble(result[i]));
            }
            AddCommand(c);
        }
        FileClose(handle);
        // Wipe the data file after recieving a command
        handle = FileOpen("./data/"+symbol+Period()+".txt", FILE_WRITE|FILE_TXT);
        if(handle != INVALID_HANDLE) {
            FileClose(handle);
        }
    }
}

void DataToFile() {
    int handle = FileOpen(DATA_PATH, FILE_WRITE|FILE_TXT);
    if(handle == INVALID_HANDLE) {
        Alert("Critical Error! Cannot read data file!");
        Print("Current Data path: ", DATA_PATH);
        Error * e = new Error(TimeToString(TimeCurrent()));
        e.Add("Error: Data file cannot be read.");
        e.Add("Status: Critical");
        e.Add("Action: Ping_Abort");
        AddError(e);
        return;
    }
    if(FileSize(handle) > 0) return;
    FileClose(handle);
    handle = FileOpen(DATA_PATH, FILE_WRITE|FILE_TXT);
    if(handle != INVALID_HANDLE) {
        data.Start();
        while(data.Loop()) {         
            //Print(CheckPointer(d) == POINTER_INVALID);
            FileWriteString(handle,data.Get().FileStr()+"\r\n");
        }
        FileClose(handle);
    }
}

void ErrorsToFile() {
    int handle = FileOpen(ERROR_PATH, FILE_WRITE|FILE_TXT);
    if(handle != INVALID_HANDLE) {
        errors.Start();
        while(errors.Loop()) {
            ErrorObject * error = errors.Get();
            for(int j=0; j < error.Size(); j++) {
                FileWriteString(handle,error.Next()+"\r\n");
            }
        }
        FileClose(handle);
    } else {
        Alert("Critical Error! Cannot write error file!");
        Sleep(3000);
        ErrorsToFile();
        return;
    }

}