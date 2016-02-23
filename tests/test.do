set tracedepth 1
set trace off
clear all
scalar drop _all
mac drop _all
program drop _all
qui include preferences.do
*closeallmatafiles

log close _all //remove after testing
log using log/test.log, replace name(test_log)
log using log/test.smcl, replace name(test_smcl)

******** Update package and test the stata.trk normalizer *******
*This is really only useful if you are installing an package from within the same project
cap make_trk_paths
if `=_rc'==199 { //doesn't exist
	* net {describe|from|get|install} don't accept relative paths, so use absolute
	net install stata_reproducible, from(`c(pwd)'/../)
	*But then stata.trk file can't be committed to VC if used in other places. So make relative
	make_trk_paths relative, net_ado(ado/)
}
else { //100 "syntax error" -> Exists
	* If you want to reinstall (possibly because of an update), then the following options have problems
	* Option 1: Manual reinstall
	*   -net install, from(<abs_path> replace- 
	*   a nearly identical entry is added to stata.trk since paths don't match and this can cause problems for program tools
	* Option 2: Auto-update
	*   -adoupdate, update- 
	*   fails because -net install- can't take relative. Also errors silently and without setting _rc !!!
	*
	* Instead, do one of the following:
	* Solution 1:
	*   -ado uninstall stata_reproducible-
	*   Then install as above
	* Solution 2: Temporarily convert stata.trk to using absolute paths
	make_trk_paths absolute, net_ado(ado/)
	adoupdate stata_reproducible, update
	* Or -net install <pkg>, from(<abs_path>) replace 
	*   <abs_path> must be normalized to remove any "<dir>/../" like we use above 
	*   (FWIW: -get_absolute_path_from_relative- returns this)
	make_trk_paths relative, net_ado(ado/)
}


******** Tests adostorer **************
*This will change the trk file, so preserve and restore for version control 
* (these are not normal daily operations)
if 1 { //turn if don't want to test (e.g. no network connection)
	tempfile trk_backup
	copy "ado/stata.trk" `trk_backup'
	adostorer remove synth, adofolder(ado)
	adostorer install synth, adofolder(ado) all
	sysuse smoking
	xtset state year
	qui synth cigsale beer(1984(1)1988) cigsale(1988), trunit(3) trperiod(1989)
	program drop _all //so that we don't hold onto the ado/<plat>/synthopt.plugin
	change_line using ado/stata.trk, ln(53) replace("d Distribution-Date: 20140127") //one day before currnt dist-date. This will trigger an update
	adostorer update, adofolder(ado)
	qui synth cigsale beer(1984(1)1988) cigsale(1988), trunit(3) trperiod(1989)
	program drop _all //so that we don't hold onto the ado/<plat>/synthopt.plugin
	copy `trk_backup' "ado/stata.trk", replace
}

*Setup for other
sysuse auto, clear
compress

*Use -quiet- before commands that display differently on different platforms 
* (e.g. use OMIT_FIG_EXP or use `main_version')

******** Export platform-version specific versions ********
* This is to see all the differences. Be specific about versions
local main_version = substr("`c(stata_version)'",1,2)

qui save raw/auto-v`main_version'-raw.dta, replace
if `main_version'==14 qui saver auto-v13-from-v14.dta, replace version(13)
*qui below because v13 vs v14 will show "data sig. set" vers "reset"
qui saver auto.dta, replace version(`main_version') //so graphs have same dataset location. 
copy auto.dta auto-v`main_version'.dta, replace
erase auto.dta

twoway (scatter mpg price), title("Title") note("Notes") //has to go after save as data path written
qui graph save raw/scatter-v`main_version'-`c(os)'-raw.gph, replace
if `main_version'==14 qui graph_saver scatter-v13-from-v14.gph, replace version(13)
qui graph_saver scatter-v`main_version'.gph, replace version(`main_version')

qui graph_exportr scatter-v`main_version'-`c(os)'.eps, replace
*Can't export to PDF on Unix for version <14 (sometimes Unix v14, but not always)
cap /*noi*/ graph_exportr scatter-v`main_version'-`c(os)'.pdf, replace

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
log_closer test_log, raw_dir(raw) rw_line_user_post(rw_line_user)
log_closer test_smcl, raw_dir(raw) rw_line_user_post(rw_line_user)
local main_version = substr("`c(stata_version)'",1,2)
copy log/test.log test-v`main_version'.log, replace
copy log/test.smcl test-v`main_version'.smcl, replace
copy raw/test.log raw/test-v`main_version'.log, replace
copy raw/test.smcl raw/test-v`main_version'.smcl, replace
erase raw/test.log
erase raw/test.smcl
