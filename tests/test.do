
set tracedepth 3
set trace off
clear all
scalar drop _all
mac drop _all
closeallmatafiles
program drop _all
qui include preferences.do
log close _all //remove after testing
log using log/test.log, replace name(test_log)
log using log/test.smcl, replace name(test_smcl)

*Final checks:
*   auto-v13.dta=   auto-v13-from-v14.dta
*scatter-v13.gph=scatter-v13-from-v14.gph

sysuse auto, clear
compress

*Use -quiet- before commands that display differently on different platforms 
* (e.g. use OMIT_FIG_EXP or use `main_version')

******** Export platform-version specific versions ********
* This is to see all the differences. Be specific about versions
local main_version = substr("`c(stata_version)'",1,2)

qui save raw/auto-v`main_version'-raw.dta, replace
if `main_version'==14 qui saver auto-v13-from-v14.dta, replace version(13)
saver auto.dta, replace version(`main_version') post_check //so graphs have same dataset location
copy auto.dta auto-v`main_version'.dta, replace
erase auto.dta

twoway (scatter mpg price), title("Title") note("Notes") //has to go after save as data path written
qui graph save raw/scatter-v`main_version'-`c(os)'-raw.gph, replace
if `main_version'==14 qui graph_save scatter-v13-from-v14.gph, replace version(13)
qui graph_save scatter-v`main_version'.gph, replace version(`main_version')

qui graph_export scatter-v`main_version'-`c(os)'.eps, replace
*Can't export to PDF on Unix for version <14 (sometimes Unix v14, but not always)
cap /*noi*/ graph_export scatter-v`main_version'-`c(os)'.pdf, replace

******** Simulate a workflow to get canonical versions **********
saver data/auto.dta, replace
qui save_all_figs scatter

*If another platform updates gphs,then run this
if "$OMIT_FIG_EXPORT"=="0"{
	qui do gen_ext_from_gph.do
}


******** Check that everything wrote fine ********
foreach dta in auto-v13.dta auto-v13-from-v14.dta `=cond(`main_version'==14,"auto-v14.dta","")' {
	qui use `dta', clear
	qui datasignature confirm
}

graph use scatter-v13.gph, nodraw
graph use scatter-v13-from-v14.gph, nodraw
if `main_version'==14 qui graph use scatter-v14.gph, nodraw


******* Check the log normalization **************
local main_version ""
global OMIT_FIG_EXPORT ""
display_run_specs /*creturn list has too many things to null out*/
mac dir
tempfile tfile
save `tfile'

*set trace on
log_close test_log, raw_dir(raw)
log_close test_smcl, raw_dir(raw)
local main_version = substr("`c(stata_version)'",1,2)
copy log/test.log test-v`main_version'.log, replace
copy log/test.smcl test-v`main_version'.smcl, replace
copy raw/test.log raw/test-v`main_version'.log, replace
copy raw/test.smcl raw/test-v`main_version'.smcl, replace
erase raw/test.log
erase raw/test.smcl
