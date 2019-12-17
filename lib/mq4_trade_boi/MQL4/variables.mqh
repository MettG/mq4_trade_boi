#include "objects_lib.mqh"
#include "file_paths.mqh"

string symbol;
List * commands;
List * errors;
List * data;

void AddError(Error* & e) {
    errors.Add(e);
}

void AddData(string k, double v) {
    DataObject * d = new DataObject(k,v);
    data.Add(e);
}

void AddCommand(CommandObject* &c) {
    commands.Add(e);
}