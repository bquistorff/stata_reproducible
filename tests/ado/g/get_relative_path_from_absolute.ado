*Performs case-sensitive match (so if on Windows or MacOS the strings should be pre-made lower case).
*Won't work with folder names that contain "`'
program get_relative_path_from_absolute
	syntax anything(name=absolute), local(string)
	local absolute `absolute' //remove possible surrounding quotes
	
	*Normalize absolute (remove "..", and ".")
	local orig_pwd "`c(pwd)'"
	qui cd "`absolute'"
	local absolute "`c(pwd)'"
	qui cd "`orig_pwd'"
	
	local abslen = strlen("`absolute'")
	local pwdlen = strlen("`c(pwd)'")
	
	*Strip off the prefix
	local absprefix_len = 1
	local pwdprefix_len = 1
	if substr("`absolute'",2,1)==":" local absprefix_len = 3
	if substr("`c(pwd)'"  ,2,1)==":" local pwdprefix_len = 3
	_assert `absprefix_len'==`pwdprefix_len', msg("Appears absolute path is on different system type")
	_assert substr("`absolute'",1,`absprefix_len')==substr("`c(pwd)'",1,`pwdprefix_len'), msg("Appears absolute path is on different system type")
	
	* On Windows the paths are with "\" but c(dirsep)=="/"
	local dirsep "`c(dirsep)'"
	if `absprefix_len' == 3 local dirsep = substr("`c(pwd)'",3,1)
	
	* pwd doesn't end in dirsep, so make sure abs doesn't
	if substr("`absolute'",`abslen',1)=="`dirsep'" loc absolute=substr("`absolute'",1, `=`abslen'-1')
	
	if "`absolute'"=="`c(pwd)'"{
		c_local `local' "."
		exit
	}
	
	*Split into list of quoted folder names
	local abs_main = substr("`absolute'",`=1+`absprefix_len'',`=`abslen'-`absprefix_len'')
	local pwd_main = substr("`c(pwd)'",  `=1+`pwdprefix_len'',`=`pwdlen'-`pwdprefix_len'')
	
	local abs_mainq `""`abs_main'""'
	local pwd_mainq `""`pwd_main'""'
	local abs_split : subinstr local abs_mainq "`dirsep'" `"" ""' , all
	local pwd_split : subinstr local pwd_mainq "`dirsep'" `"" ""' , all
	
	local n_abs_dirs : list sizeof abs_split
	local n_pwd_dirs : list sizeof pwd_split
	local n_dirs_min = min(`n_abs_dirs', `n_pwd_dirs')
	
	*Figure out the common start
	local dirs_matched = 0
	forval i=1/`n_dirs_min' {
		local abs_dir : word `i' of `abs_split'
		local pwd_dir : word `i' of `pwd_split'
		if "`abs_dir'"!="`pwd_dir'" continue, break
		local dirs_matched=`i'
	}
	
	forval i=`=`dirs_matched'+1'/`n_pwd_dirs' {
		local rel_path "`rel_path'..`dirsep'"
	}
	forval i=`=`dirs_matched'+1'/`n_abs_dirs' {
		local abs_dir : word `i' of `abs_split'
		*need this macval otherwise a previous "\" will mess up the macro expansion
		local rel_path "`macval(rel_path)'`abs_dir'`dirsep'"
	}
	*remove the last dirsep
	local rel_path = substr("`rel_path'",1, `=strlen("`rel_path'")-1')
	
	c_local `local' `rel_path'
end
