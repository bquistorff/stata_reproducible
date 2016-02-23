sysdir set PLUS "ado/"
platformname
global S_ADO "PLUS;BASE;ado/`r(platformname)'"
net set ado PLUS
net set other PLUS

set scheme s2mono

*In log normalization, we piece together lines that split with "> " but some commands 
* (e.g. adoupdate) do their own line-splitting. Therefore make splitting unlikely.
set linesize 140

global DTA_DEFAULT_VERSION 13
global GPH_DEFAULT_VERSION 13
global OMIT_FIG_EXPORT = ("`c(os)'"!="Windows" | substr("`c(stata_version)'",1,2)!="13")

*Grab the project root. Roots should have "/" at end so if blank, path becomes relative
local pwd "`c(pwd)'"
cd ..
global PROJ_ROOT  "`c(pwd)'/"
cd "`pwd'"

* This will remove the location of the ado origin.
* This could be compiled into a project mlib or the next line makes sure it's not added twice
cap mata: mata drop rw_line_user()
mata:

/* R/Ws that would make PARALLEL output deterministic
s/^((Stata dir|PLL_DIR): *).+/\1-normalized-/g
s/^((Clusters *:|PLL_CLUSTERS:|numclusters:|. global numclusters|LAST_PLL_N:|N Clusters:) *).+/\1-normalized-/g
s/^((pll_id|ID|pid|LAST_PLL_ID) *: +).+/\1-normalized-/g
*/
string scalar rw_line_user(string scalar lcl_name, string scalar type){
	l = st_local(lcl_name)
	
	proj_root = st_global("PROJ_ROOT")
	l = subinstr(l, substr(proj_root,1,strlen(proj_root)-1), "-PROJ_BASE-")

	return(l)
}
end
