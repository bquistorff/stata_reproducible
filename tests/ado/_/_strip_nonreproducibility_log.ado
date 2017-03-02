mata:

real scalar delete_line_system(string scalar lcl_name, string scalar type){
	line = st_local(lcl_name)
	mac_num_del = 1
	if (type=="smcl") mac_num_del=3
	
	if (strpos(line,"LOGREMOVE")==1) return(1)
	/* Hardware details */
	if (strpos(line,"S_OSDTL:")==1) return(mac_num_del) /*sometimes appears*/
	if (strpos(line,"S_level:")==1) return(mac_num_del) /*Appears in different orders on different machines*/
	/* Stata details */
	if (regexm(line,"^S_(StataMP|StataSE|CONSOLE|MODE):")) return(mac_num_del) /*sometimes appear*/
	if (regexm(line,"^.*saving in Stata .. format.")) return(1) /*appears depending on version (v13 saving in v13)*/
	
	return(0)
}

string scalar rw_line_system(string scalar lcl_name, string scalar type){
	l = st_local(lcl_name)
	
	/*Time/speed-specific specific*/
	l = regexr(l, "[ 0-9][0-9] [A-Z][a-z][a-z] [0-9][0-9][0-9][0-9],? ..:..(:..)?","-normalized-")
	l = regexr(l, "[ 0-9][0-9] [A-Z][a-z][a-z] [0-9][0-9][0-9][0-9]","-normalized-")
	
	/**** Machine-specific ****/
	/**OS-dependent: file path**/
	/* make folder separators Unix-like */
	/* /normalizedroot/s/\\/\//g */
	tmpdir = c("tmpdir")
	if (substr(tmpdir,strlen(tmpdir),1)=="/") /* Windows adds this where linux doesn't */
		tmpdir = substr(tmpdir,1,strlen(tmpdir)-1)
	l = subinstr(l, tmpdir+"\"  , "-TMPDIR-/")
	l = subinstr(l, tmpdir      , "-TMPDIR-")
	l = subinstr(l, c("pwd")+"\", "-PWD-/")
	l = subinstr(l, c("pwd")    , "-PWD-")
	l = regexr(l,"St[0-9][0-9][0-9][0-9][0-9]\.[0-9][0-9][0-9][0-9][0-9][0-9]","-tempfile-")
	l = regexr(l,"ST_[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9].tmp", "-tempfile-")

	l = regexr(l,"c\(hostname\) = .+","c(hostname) = -normalized-")

	/* Other FS macros (these include paths not already normalized)*/
	if (regexm(l, "^(S_FN|S_ADO): *") )
		l=regexs(0)+"-normalized-"
	/** Other OS-dependent**/
	/* Optional*/
	if (regexm(l, "^S_OS: *"))
		l=regexs(0)+"-normalized-"
	
	/*Hardware details*/
	if (regexm(l, "^S_MACH: *")) 
		l=regexs(0)+"-normalized-"
	
	/*Stata details*/
	if (regexm(l, "^S_FLAVOR: *"))
		l=regexs(0)+"-normalized-"
	if (regexm(l, "Flavor = +")) /*This is from -display_run_specs- */
		l=regexs(0)+"-normalized-"
	if (regexm(l, "c\((os|osdtl|machine_type|byteorder|flavor|stata_version|processors)\) = "))
		l="c("+regexs(1)+") = -normalized-"
	/*smcl tags differ in v14 and v13 so strip*/
	if (regexm(l, "  (.*variable)? *({[^}]+})*([^{]+)({[^}]+})* was ({[^}]+})*([^{]+)({[^}]+})* now ({[^}]+})*([^{]+){?[^}]*}?")){ /*-compress- message changed v13->v14*/
		l="  "+regexs(3)+" was "+regexs(6)+" now "+regexs(9) 
	}
	if (regexm(l, ".+(file .+ saved)")){
		l=regexs(1)
	}
		

	return(l)
}

end

* 
* Sometimes quotes aren't fully closed. For Example
*  c(adopath) = "`"../src/"';`"BAS.."      (adopath)
* So that messes anything (like functions) that prints the string (e.g. strpos)
* so use mata string functions
* Also piece together broken lines so that search & replace works
program _strip_nonreproducibility_log
	syntax anything(name=filename), type(string) [combine delete_line_user(string) ///
		rw_line_user_pre(string) rw_line_user_post(string) raw_dir(string)]
  
  local filename `filename' //get rid of quotes
	if "`raw_dir'"!=""{
		_getfilename "`filename'"
		copy "`filename'" "`raw_dir'/`r(filename)'", replace
	}
	
	local mac_len_subcmd = cond(`c(version)'<14, "length", "strlen")
	tempname in out
	
	//local filename_nor "`filename'.nor" //if using remember to erase at the bottom
	//cap erase "`filename_nor'"
	tempfile filename_nor
	
	file open `in' using "`filename'", text read
	mata: st_numscalar("`out'", fopen("`filename_nor'", "w"))
	
	local skip_first_read 0
	while 1 {
		*Read in and construct a combined line
		if !`skip_first_read'{
			file read `in' line
			local status "`r(status)'"
		}
		if "`status'"=="eof" continue, break
		
		local whole_line : copy local line
		local skip_first_read 0
		local strlen : `mac_len_subcmd' local line
		while `strlen'==`c(linesize)' & "`combine'"!=""{
			file read `in' line
			local status "`r(status)'"
			local strlen : `mac_len_subcmd' local line
			mata: st_local("line_cont", strofreal(strpos(st_local("line"), "> ")==1))
			if `line_cont'{
				mata: st_local("whole_line", st_local("whole_line")+substr(st_local("line"), 3, .))
			}
			else{
				* Long macros that are split in the middle of the word (from -mac dir-), use the following continuations
				* Don't think this is needed
				/*mata: st_local("line_cont", strofreal(strpos(st_local("line"), "                > ")==1))
				if `line_cont'{
					mata: st_local("whole_line", st_local("whole_line")+substr(st_local("line"), 19, .))
					continue
				}*/
				local skip_first_read 1
				continue, break
			}
		}
		
		*Should I delete line?
		local delete_usr 0
		if "`delete_line_user'"!=""{
			mata: st_local("delete_usr", strofreal(`delete_line_user'("whole_line", "`type'")))
		}
		mata: st_local("delete_sys", strofreal(delete_line_system("whole_line", "`type'")))
		local delete_num = max(`delete_usr', `delete_sys')
		if `delete_num'>0{
			forval i=2/`delete_num' {
				file read `in' line
			}
			continue
		}
		
		*Should I make substitutions
		local new_line : copy local whole_line
		if "`rw_line_user_pre'"!="" mata: st_local("new_line", `rw_line_user_pre'("new_line", "`type'"))
		mata: st_local("new_line", rw_line_system("new_line", "`type'"))
		if "`rw_line_user_post'"!="" mata: st_local("new_line", `rw_line_user_post'("new_line", "`type'"))

		mata: fput(st_numscalar("`out'"), st_local("new_line"))
	}
	
	file close `in'
	mata: fclose(st_numscalar("`out'"))
	
	copy "`filename_nor'" "`filename'", replace
	//erase "`filename_nor'" //not necessary if using tempfiles
end
