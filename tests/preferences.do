set scheme s2mono
global DTA_DEFAULT_VERSION 13
global GPH_DEFAULT_VERSION 13
global OMIT_FIG_EXPORT = ("`c(os)'"!="Windows" | substr("`c(stata_version)'",1,2)!="13")

sysdir set PLUS "ado/"
global S_ADO "PLUS;BASE"
net set ado PLUS

local pwd "`c(pwd)'"
cd ..
global PROJ_ROOT  "`c(pwd)'/"
cd "`pwd'"

*We piece together lines that split with "> " but some commands 
* (e.g. adoupdate) do their own line-splitting. Therefore make it unlikely.
set linesize 140

* This will remove the location of the ado origin.
* This could be compiled into a project mlib or the next line makes sure it's not added twice
cap mata: mata drop rw_line_user()
mata:
string scalar rw_line_user(string scalar lcl_name, string scalar type){
	l = st_local(lcl_name)
	proj_root = st_global("PROJ_ROOT")
	proj_base = substr(proj_root,1,strlen(proj_root)-1)
	l = subinstr(l, proj_base, "-PROJ_BASE-")
	return(l)
}
end
