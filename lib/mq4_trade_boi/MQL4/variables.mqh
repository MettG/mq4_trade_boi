#include "objects_lib.mqh"
#include "file_paths.mqh"

string symbol;
List * commands;
List * errors;
List * data;

void InitLists() {
    commands = new List();
    errors = new List();
    data = new List();
}

void AddError(Error & e) {
    ParentObject * p = (ParentObject*) GetPointer(e);
    errors.Add(p);
}

void AddData(string k, double v) {
    DataObject * d = new DataObject(k,v);
    ParentObject * p = (ParentObject*) d;
    data.Add(p);
}

void AddCommand(CommandObject &c) {
    ParentObject * p = (ParentObject*) GetPointer(c);
    commands.Add(p);
}