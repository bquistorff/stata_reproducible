scalar drop _all
mac drop _all
discard
file close _all
include preferences.do

local main_version = substr("`c(stata_version)'",1,2)
sysuse auto, clear

* Export platform-version specific versions
* This is to see all the differences
save raw/auto-v`main_version'-raw.dta, replace
saver auto-v`main_version'.dta, replace version(`main_version')

twoway (scatter mpg price), title("Title") note("Notes") //has to go after save as data path written

graph save raw/scatter-v`main_version'-`c(os)'-raw.gph, replace
graph_save scatter-v`main_version'.gph, replace

graph_export scatter-v`main_version'-`c(os)'.eps, replace
*Can't export to PDF on Unix for version <14 (sometimes Unix v14, but not always)
cap noi graph_export scatter-v`main_version'-`c(os)'.pdf, replace

* Now simulate a workflow to get canonical versions
* Currently, only works for same version.
if `main_version'==14{
	saver data/auto.dta, replace
	save_all_figs scatter
	
	*If another platform updates gphs,then run this
	if "$OMIT_FIG_EXPORT"=="0"{
		do gen_ext_from_gph.do
	}
}

