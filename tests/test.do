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
if `=_rc'==199 { //command not found
	net install stata_reproducible, from(`c(pwd)'/../)
}
else { //100 "syntax error" (didn't run with proper args) -> command found
	make_trk_paths absolute, adofolder(ado/)
	adoupdate stata_reproducible, update dir(ado/)
}
make_trk_paths relative, adofolder(ado/)


******** Tests adostorer **************
*This will change the trk file (inconsequentially), so preserve and restore for version control 
* (these are not normal daily operations)
if 0 { //turn if don't want to test (e.g. no network connection)
	tempfile trk_backup
	copy "ado/stata.trk" `trk_backup'
	adostorer remove synth, adofolder(ado)
	adostorer install synth, adofolder(ado) all mkdirs
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
datasig set, reset

*Use -quiet- before commands that display differently on different platforms 
* (e.g. use OMIT_FIG_EXP or use `main_version')

******** Export platform-version specific versions ********
* This is to see all the differences. Be specific about versions
local main_version = substr("`c(stata_version)'",1,2)

if 1{ //datasets
	qui save raw/auto-v`main_version'-raw.dta, replace
	if `main_version'==14 qui saver norm/auto-v13-from-v14.dta, replace version(13)
	qui saver norm/auto-v`main_version'.dta, replace version(`main_version')

	******** Check that everything wrote fine ********
	foreach dta in auto-v`main_version'.dta `=cond(`main_version'==14,"auto-v13-from-v14.dta","")' {
		qui use norm/`dta', clear
		qui datasignature confirm
	}  
}

if 1 { //graphs and exports
	save auto.dta //so graphs have same embeded dataset location.
	twoway (scatter mpg price), title("Title") note("Notes") //has to go after save as data path written
	
	qui graph save raw/scatter-v`main_version'-`c(os)'-raw.gph, replace
	if `main_version'==14 qui graph_saver norm/scatter-v13-from-v14.gph, replace version(13)
	qui graph_saver norm/scatter-v`main_version'.gph, replace version(`main_version')

	foreach fmt in ps eps pdf png tif /*emf wmf*/ {
		qui graph export raw/scatter-v`main_version'-`c(os)'-raw.`fmt', replace
		cap /*noi*/ graph_exportr norm/scatter-v`main_version'-`c(os)'.`fmt', replace
	}
	erase auto.dta
	
	******** Check that everything wrote fine ********
	graph use norm/scatter-v13.gph, nodraw
	graph use norm/scatter-v13-from-v14.gph, nodraw
	if `main_version'==14 qui graph use norm/scatter-v14.gph, nodraw
}

******** Simulate a workflow to get canonical versions **********
saver data/auto.dta, replace
qui save_all_figs scatter

*If another platform updates gphs,then run this
if "$OMIT_FIG_EXPORT"=="0"{
	qui do gen_ext_from_gph.do
}


******* Check the log normalization **************
local main_version ""
global OMIT_FIG_EXPORT ""
display_run_specs /*creturn list has too many things to null out*/
mac dir
tempfile tfile
save `tfile'

log_closer test_log, raw_dir(raw) rw_line_user_post(rw_line_user)
log_closer test_smcl, raw_dir(raw) rw_line_user_post(rw_line_user)
local main_version = substr("`c(stata_version)'",1,2) //reload
copy log/test.log norm/test-v`main_version'.log, replace
copy log/test.smcl norm/test-v`main_version'.smcl, replace

copy raw/test.log raw/test-v`main_version'.log, replace
copy raw/test.smcl raw/test-v`main_version'.smcl, replace
erase raw/test.log
erase raw/test.smcl
