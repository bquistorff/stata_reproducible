*Can't read/write in place because sometimes the identfiers are different length
*NB: -version- does not affect graph saving/exporting
program graph_save
	syntax anything [, asis * version(string)]
	_assert "`asis'"=="", msg("Can not parse asis graphs")
	_assert inlist("`version'","","13","14"), msg("Can only graph_save as older from v14 to v13")
	
	gettoken first second : anything
	if "`second'"!=""{
		local gphname `first'
		local filename `second'
	}
	else{
		local filename `first'
	}
	
	graph save `gphname' "`filename'" , `options'
	if "`version'"=="" local version $GPH_DEFAULT_VERSION
	if ("`version'"=="13" & `c(stata_version)'>=14) local old13 old13
	strip_nodeterminism_gph `filename', `old13'
end

program strip_nodeterminism_gph
	syntax anything(name=filename) [, old13]
	
	tempname in out
	file open `in' using "`filename'", read text
	file open `out' using "`filename'.nor", write text replace
	file read  `in'    line //Stata 13 & 14 say same
	file write `out' "`line'`=char(10)'" //char(10) is line-feed (\n). This is a Unix line ending
	file read  `in'    line //13 & 14 differ
	local rstatus = "`r(status)'"
	local nl_len = cond("`rstatus'"=="win",2,1)
	if "`old13'"!="" local line "00003:00003:"
	file write `out' "`line'`=char(10)'"
	file seek `in' query
	local pos =r(loc)
	file close `in'
	file close `out'
	
	local gversion = substr("`line'",5,1)
	_assert inlist(`gversion',3,4), msg("Only can parse gph format 3 (stata v13) or 4 (stata v14)")
	
	local date "10 Jul 2013"
	local time_rough "14:23"
	local time "`time_rough':00"
	local date_time ="`date' `time_rough'"
	
	while 1{
		file open `in' using "`filename'", read text
		file seek `in' `pos'
		file open `out' using "`filename'.nor", write text append
		file read `in' line
		while `"`line'"'!="<BeginSersetData>" & r(eof)==0{
			
			if strpos(`"`line'"',"<BeginItem>") loc items "`items' `: word 3 of `line''"
			
			if strpos(`"`line'"',"*! command_date:")==1  loc line "*! command_date: `date'"
			if strpos(`"`line'"',"*! command_time:")==1  loc line "*! command_time: `time'"
			if strpos(`"`line'"',"*! datafile_date:")==1 loc line "*! datafile_date: `date_time'"
			if strpos(`"`line'"',".date = ")==1     loc line `".date = "`date'""'
			if strpos(`"`line'"',".time = ")==1     loc line `".time = "`time'""'
			if strpos(`"`line'"',".dta_date = ")==1 loc line `".dta_date = "`date_time'""'
			
			local new_line =`"`macval(line)'"'
			forval i=1/`: list sizeof items' {
				local item : word `i' of `items'
				*local len = length("`item'")
				local len=9
				local new_item = "K"+string(`i',"%0`=`len'-1'.0f")
				local new_line = subinstr(`"`macval(new_line)'"', "`item'","`new_item'",.)
			}
			file write `out' `"`macval(new_line)'`=char(10)'"'
			
			file read `in' line
		}
		if r(eof) continue, break
		file write `out' "`line'`=char(10)'"
		
		file seek `in' query 
		local pass_off_pos = r(loc)
		file close `in'
		
		file close `out'
		file open `out' using "`filename'.nor", read text
		file seek `out' eof
		file seek `out' query 
		local pass_off_pos_out = r(loc)
		file close `out'
		
		if "`old13'"!=""{
			write_serset13_from_serset14 `pass_off_pos' `pass_off_pos_out', filename_in(`filename') filename_out(`filename'.nor) pass_of_local(pos)
		}
		else{
			copy_serset `pass_off_pos' `pass_off_pos_out', filename_in(`filename') filename_out(`filename'.nor) pass_of_local(pos)
			strip_nodeterminism_serset , filename_out(`filename'.nor) pos_out(`pass_off_pos_out') vers(`gversion')
		}
	}
	
	file close `in'
	file close `out'
	copy "`filename'.nor" "`filename'", replace
	erase "`filename'.nor"
end

program write_serset13_from_serset14
	syntax anything, filename_in(string) filename_out(string) pass_of_local(string)
	gettoken pos pos_out: anything
	
	tempname in out n_obs k_var vartype
	file open `in' using "`filename_in'", read binary
	file open `out' using "`filename_out'", write append binary
	
	file seek `in' `=`pos'+18'
	file write `out' %15s "sersetreadwrite"
	file write `out' %1bu (0) //null terminate string
	file write `out' %1bu (2) //version of serset
	file write `out' %1bu (2) //lohi marker
	
	file read  `in'  %4bu   `k_var'
	file write `out' %4bu  (`k_var')
	file read  `in'  %4bu   `n_obs'
	file write `out' %4bu  (`n_obs')
	
	local obs_width = 0
	forval k=1/`=`k_var''{ //typlist
		file read  `in'  %1bu   `vartype'
		file write `out' %1bu  (`vartype')
		storage_size `=`vartype'' size
		local obs_width = `obs_width'+`size'
	}
	
	forval k=1/`=`k_var''{ //typlist
		copy_str_smaller `in' `out' 150 54
	}
	
	forval k=1/`=`k_var''{ //fmtlist
		copy_str_smaller `in' `out' 57 49
	}
	
	copy_bytes `in' `out' `=`k_var'*16' //maxs and mins
	
	copy_bytes `in' `out' `=`n_obs'*`obs_width'' //data
	
	file seek `in' query
	c_local `pass_of_local' `r(loc)'
	
	file close `out'
	file close `in'
end

program storage_size
	args vartype local
	if `vartype' <=244{
		c_local `local' `vartype'
	}
	else{
		if `vartype'== 251 c_local `local' 1
		if `vartype'== 252 c_local `local' 2
		if `vartype'== 253 c_local `local' 4
		if `vartype'== 254 c_local `local' 4
		if `vartype'== 255 c_local `local' 8
	}
end


program copy_str_smaller
	args in out in_width out_width
	tempname charval
	local found_null 0
	
	forval b=1/`out_width'{
		file read  `in' %1bu `charval'
		if `=`charval''==0 local found_null 1
		file write `out' %1bu (`=cond(`found_null',0,`charval')')
	}
	file read `in' %`=`in_width'-`out_width''s junk //so sync up pointers
end

*For now, not trusting raw data to go through locals
program copy_bytes
	args in out nbytes
	tempname data
	while `nbytes'>0 {
		local chunk = cond(`nbytes'>=4,4,cond(`nbytes'>=2,2,1))
		file read  `in'  %`chunk'bu  `data'
		file write `out' %`chunk'bu (`data')
		local nbytes = `nbytes'-`chunk'
	}
end

program copy_serset
	syntax anything, filename_in(string) filename_out(string) pass_of_local(string)
	gettoken pos pos_out: anything
	tempname in out
	
	*Get the outline of the serset from Stata rather than parsing ourselves
	*Could parse the <series> tags above, but this is easier
	file open `in' using "`filename_in'", read binary
	file seek `in' `pos'
	file sersetread `in'
	file seek `in' query 
	local pass_off_pos = r(loc)
	file close `in'
	c_local `pass_of_local'     `pass_off_pos'
	
	file open `out' using "`filename_out'", write append binary
	file sersetwrite `out'
	file close `out'
	serset drop
	
end

program strip_nodeterminism_serset
	syntax , filename_out(string) pos_out(int) vers(int)
	tempname out k_vars n_obs
	file open `out' using "`filename_out'", read write binary
	file seek `out' `pos_out'
	
	file seek `out' `=`pos_out'+18'
	file read `out' %4bu `k_vars'
	file read `out' %4bu `n_obs'
	file seek `out' `=`pos_out'+26+`=`k_vars'''
	
	forval i=1/`=`k_vars''{
		zero_padding `out' `=cond(`vers'==3,54,150)'
	}
	forval i=1/`=`k_vars''{
		zero_padding `out' `=cond(`vers'==3,49,57)'
	}
	
	file close `out'
end
