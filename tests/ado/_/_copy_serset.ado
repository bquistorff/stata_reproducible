//Appends to dest (so no offset_dest). Could add this feature
//If src and dest versions are the same, then dest byteorder is always machine's native (rather than src's)
//  (could redo stuff from write_serset2_from_serset3)
program _copy_serset
	syntax anything, [pass_of_local(string) offset_src(int 0) ensure_reproducible version(string)]
	gettoken filename_in filename_out : anything
  //get rid of quotes
  local filename_in `filename_in'
  local filename_out `filename_out'
	
	if "`version'"!=""{
		_assert(inlist("`version'","2","3")), msg("Can only specify serset version 2 or 3")
		_assert("`vesion'"=="2" | `c(stata_version)'>=14), msg("Can only save serset in older versions of stata (serset v2 in Stata v14)")
		
		//check if version is older than native
		tempname src_serset_vs src_fhandle
		file open  `src_fhandle' using "`filename_in'", read write binary
		file seek  `src_fhandle' `=`offset_src'+16'
		file read  `src_fhandle' %1bu `src_serset_vs'
		file close `src_fhandle'
		_assert(inlist(`src_serset_vs',2,3)), msg("Can only copy sersets in version 2 or 3.")
		if "`version'"=="2" & `src_serset_vs'==3 local old2 old2
	}
	
	if "`old2'"!=""{
		write_serset2_from_serset3 "`filename_in'" "`filename_out'", pass_of_local(pass_off_pos) offset_src(`offset_src')
	}
	else {
		tempname in out
		
		*Get the outline of the serset from Stata rather than parsing ourselves
		*Could parse the <series> tags above, but this is easier
		file open `in' using "`filename_in'", read binary
		file seek `in' `offset_src'
		file sersetread `in'
		file seek `in' query 
		local pass_off_pos = r(loc)
		file close `in'
		if "`pass_of_local'"!="" c_local `pass_of_local'     `pass_off_pos'
		
		if "`ensure_reproducible'"!=""{ //get the pos
			file open `out' using "`filename_out'", read text
			file seek `out' eof
			file seek `out' query 
			local pass_off_pos_out = r(loc)
			file close `out'
		}
		
		file open `out' using "`filename_out'", write append binary
		//sersetwrite always writes in native byteorder format. -file set <handle> byteorder- does not change this!
		file sersetwrite `out'
		file close `out'
		serset drop
		
		if "`ensure_reproducible'"!=""{
			_strip_nodeterminism_serset "`filename_out'", offset(`pass_off_pos_out')
		}
	}

	if "`pass_of_local'"!="" c_local `pass_of_local'     `pass_off_pos'
end

program write_serset2_from_serset3
	syntax anything, [pass_of_local(string) offset_src(int 0)]
	gettoken filename_in filename_out : anything
  //get rid of quotes
  local filename_in `filename_in'
  local filename_out `filename_out'
	
	tempname in out byteorder_num k_var n_obs vartype
	file open `in' using "`filename_in'", read binary
	file open `out' using "`filename_out'", write append binary
	
	file seek `in' `=`offset_src'+17'
	file write `out' %15s "sersetreadwrite"
	file write `out' %1bu (0) //null terminate string
	file write `out' %1bu (2) //version of serset13
	
	file read `in' %1bu `byteorder_num'
	file write `out' %1bu (`byteorder_num')
	file set `in'  byteorder `=`byteorder_num''
	file set `out' byteorder `=`byteorder_num''
	
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
	if "`pass_of_local'"!="" c_local `pass_of_local' `r(loc)'
	
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
