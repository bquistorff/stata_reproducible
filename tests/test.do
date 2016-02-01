scalar drop _all
mac drop _all
program drop _all
file close _all
include preferences.do

sysuse auto, clear

******** Export platform-version specific versions ********
* This is to see all the differences. Be specific about versions
local main_version = substr("`c(stata_version)'",1,2)

save raw/auto-v`main_version'-raw.dta, replace
if `main_version'==14 saver auto-v13-from-v14.dta, replace version(13)
saver auto.dta, replace version(`main_version') //so graphs have same dataset location
copy auto.dta auto-v`main_version'.dta, replace
erase auto.dta

twoway (scatter mpg price), title("Title") note("Notes") //has to go after save as data path written
graph save raw/scatter-v`main_version'-`c(os)'-raw.gph, replace
if `main_version'==14 graph_save scatter-v13-from-v14.gph, replace version(13)
graph_save scatter-v`main_version'.gph, replace version(`main_version')

graph_export scatter-v`main_version'-`c(os)'.eps, replace
*Can't export to PDF on Unix for version <14 (sometimes Unix v14, but not always)
cap noi graph_export scatter-v`main_version'-`c(os)'.pdf, replace

******** Simulate a workflow to get canonical versions **********
saver data/auto.dta, replace
save_all_figs scatter

*If another platform updates gphs,then run this
if "$OMIT_FIG_EXPORT"=="0"{
	do gen_ext_from_gph.do
}


******** Check that everything wrote fine ********
if `main_version'==14{
	use auto-v14.dta, replace
	graph use scatter-v14.gph, nodraw
}
use auto-v13.dta, replace
use auto-v13-from-v14.dta, replace
graph use scatter-v13.gph, nodraw
graph use scatter-v13-from-v14.gph, nodraw

*Final checks:
*   auto-v13.dta=   auto-v13-from-v14.dta
*scatter-v13.gph=scatter-v13-from-v14.gph

