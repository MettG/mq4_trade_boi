void GetCommand() {
    int handle = FileOpen(COMMAND_PATH,FILE_READ|FILE_TXT);
    if(handle == INVALID_HANDLE) {
        Alert("Critical Error! Cannot read command file!");
        Error * e = new Error(TimeToString(TimeCurrent()));
        e.add("Error: Commands file cannot be read.");
        e.add("Status: Critical");
        e.add("Action: Ping_Abort");
        AddError(e);
    } else {
        if(FileSize(handle) == 0) {
            Print("No commands.");
            return;
        } 
        while(!FileIsEnding(handle)){
            str = FileReadString(handle);
            string sep="_";          
            ushort u_sep;
            string result[]; 
            u_sep=StringGetCharacter(sep,0);
            StringSplit(str,u_sep,result);
            CommandObject * c = new CommandObject(result[0]);
            for(int i = 1; i < ArraySize(result); i++) {
                c.AddArg(StrToDouble(result[i]));
            }
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
    int handle = FileOpen(DATA_PATH, FILE_READ|FILE_TXT);
    if(handle == INVALID_HANDLE) {
        Alert("Critical Error! Cannot read data file!");
        Error * e = new Error(TimeToString(TimeCurrent()));
        e.add("Error: Data file cannot be read.");
        e.add("Status: Critical");
        e.add("Action: Ping_Abort");
        AddError(e);
        return;
    }
    if(FileSize(handle) > 0) return;
    FileClose(handle);
    handle = FileOpen(DATA_PATH, FILE_WRITE|FILE_TXT);
    if(handle != INVALID_HANDLE) {
        for(int i = 0; i < ArraySize(data); i++) {
            FileWriteString(handle,data[i].FileStr());
        }
        FileClose(handle);
    }
}

void ErrorsToFile() {
    handle = FileOpen(ERROR_PATH, FILE_WRITE|FILE_TXT);
    if(handle != INVALID_HANDLE) {
        for(int i = 0; i < ArraySize(errors); i++) {
            for(int j=0; j < errors[i].Size(); j++) {
                FileWriteString(handle,errors[i].Next());
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