#include "variables.mqh"

const string PATH = Symbol()+"_"+Period();
const string ROOT_PATH = "TradeBoi//data//";
const string DATA_PATH = ROOT_PATH+PATH+"\\+"+PATH+".txt";
const string COMMAND_PATH = ROOT_PATH+PATH+"\\com_"+PATH+".txt";
const string ERROR_PATH = ROOT_PATH+PATH+"\\error_"+PATH+".txt";