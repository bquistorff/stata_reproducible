scalar drop _all
mac drop _all
discard
file close _all
set scheme s2mono

sysuse auto, clear
drop make //string variable and I don't normalize those

local ext = substr("`c(stata_version)'",1,2)

saver ../tests/auto.dta, replace
copy  ../tests/auto.dta  ../tests/auto-v`ext'.dta, replace
twoway (scatter mpg price)
graph_save ../tests/scatter-v`ext'.gph, replace
graph export ../tests/scatter-v`ext'-`c(os)'.eps, replace //nothing for eps
*Can't export to PDF on Unix for version <14
cap noi graph_export ../tests/scatter-v`ext'-`c(os)'.pdf, replace

if 0{
sleep 1000

saver ../tests/auto.dta, replace
copy  ../tests/auto.dta  ../tests/auto2-v`ext'.dta, replace
twoway (scatter mpg price)
graph_save ../tests/scatter2-v`ext'.gph, replace
graph export ../tests/scatter2-v`ext'-`c(os)'.eps, replace
cap noi graph_export ../tests/scatter2-v`ext'-`c(os)'.pdf, replace
}

erase ../tests/auto.dta
