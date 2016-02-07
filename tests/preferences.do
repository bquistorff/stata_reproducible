set scheme s2mono
global DTA_DEFAULT_VERSION 13
global GPH_DEFAULT_VERSION 13
global OMIT_FIG_EXPORT = ("`c(os)'"!="Windows" | substr("`c(stata_version)'",1,2)!="13")

sysdir set PLUS "../src/"
sysdir set PERSONAL "."
global S_ADO "PERSONAL;PLUS;BASE"

set linesize 59
