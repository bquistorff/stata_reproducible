*! version 0.0.8 Brian Quistorff <bquistorff@gmail.com>
*! Makes dta files reproducible by removing any non-determinism
*! (e.g. timestamps, randomness). Plus a few helper options.
*NB: If you want to speed up, then don't include strF's
*NB: Using -version 13: save ...- will produce a different sized file than -save ...-
*   Because things like characteristics, which are variable length, will differ.
program saver
	syntax anything(name=filename) [, noDATAsig noCOMPress noREPROducible VERsion(string) *]
	local filename `filename' //remove quotes if any
	_assert inlist("`version'","","13","14"), msg("Can only save as older from v14 to v13")
	
	if "`compress'"!="nocompress" compress
	
	if "`datasig'"!="nodatasig" {
		datasig set, reset
		*di %21x Cmdyhms(07,10,2013,14,23,00)
		char _dta[datasignature_dt] "+1.894555e748000X+028"
	}
	
	cap unab temp: _*
	if `:list sizeof temp'>0 di "Warning: Saving with temporary (_*) vars"
	
	if "`version'"=="" local version $DTA_DEFAULT_VERSION
	if "`version'"=="13" & `c(stata_version)'>=14{
		saveold "`filename'", `options' version(`version')
	}
	else{
		save "`filename'", `options'
	}
	
	if ("`reproducible'"!="noreproducible") strip_nodeterminism_dta "`filename'"

end

program strip_nodeterminism_dta
	args filename
	
	tempname fhandle k N lbl_len additional time_len char_len val_lbl_len
	
	file open `fhandle' using "`filename'", read write binary
	
	file seek `fhandle' 28
	file read  `fhandle' %3s ver_str
	
	if !inlist(`ver_str',117,118){
		di "Option reproducible does not work for versions below 13 or those at least 16."
		exit
	}
	
	local vname_len = cond(`ver_str'==117,33,129)
	
	file seek `fhandle' 70
	file read  `fhandle' %2bu `k'
	
	file seek `fhandle' 79
	if `ver_str'==117 file read  `fhandle' %4bu `N'
	else{
		read_8byte_integer `fhandle', local(N_lcl)
		scalar `N' = `N_lcl'
	}
	
	file seek `fhandle' `=cond(`ver_str'==117,94,98)'
	if `ver_str'==117 file read  `fhandle' %1bu `lbl_len'
	else              file read  `fhandle' %2bu `lbl_len'
	scalar `additional' = `lbl_len'
	
	file seek `fhandle' `=cond(`ver_str'==117,114,119)+`additional''
	file read  `fhandle' %1bu `time_len'
	scalar `additional' = `additional'+`time_len'
	
	if `time_len'==17{ //otherwise=0
		file write `fhandle' %17s "10 Jul 2013 14:23"
	}
	
	file seek `fhandle' `=cond(`ver_str'==117,141,146)+`additional'+8+8' //skip the knowns
	*read_8byte_integer `fhandle', local(begin_ds) //0!
	*read_8byte_integer `fhandle', local(map) //where I am!
	read_8byte_integer `fhandle', local(variable_types)
	read_8byte_integer `fhandle', local(varnames)
	read_8byte_integer `fhandle', local(sortlist)
	read_8byte_integer `fhandle', local(formats)
	read_8byte_integer `fhandle', local(value_label_names)
	read_8byte_integer `fhandle', local(variable_labels)
	read_8byte_integer `fhandle', local(characteristics)
	read_8byte_integer `fhandle', local(data)
	read_8byte_integer `fhandle', local(strls)
	read_8byte_integer `fhandle', local(value_labels)
	*read_8byte_integer `fhandle', local(end_ds)
	*read_8byte_integer `fhandle', local(eof)
	
	file seek `fhandle' `=`variable_types'+14+2'
	tempname vartype
	forval i=1/`=`k''{
		file read `fhandle' %2bu `vartype'
		if `=`vartype'' <=2045{
			local vsizes "`vsizes' `=`vartype''"
			local isstrs "`isstrs' 1"
		}
		else{
			if `=`vartype''== 32768 local vsizes "`vsizes' 8"
			if `=`vartype''== 65526 local vsizes "`vsizes' 8"
			if `=`vartype''== 65527 local vsizes "`vsizes' 4"
			if `=`vartype''== 65528 local vsizes "`vsizes' 4"
			if `=`vartype''== 65529 local vsizes "`vsizes' 2"
			if `=`vartype''== 65530 local vsizes "`vsizes' 1"
			local isstrs "`isstrs' 0"
		}
	}
	*consolidate non-strF fields
	forval i=1/`=`k''{
		local curr_isstr : word `i' of `isstrs'
		local curr_size  : word `i' of `vsizes'
		
		if `curr_isstr'{
			if "`prev_nonstr_size'"!=""{
				local isstrs2 "`isstrs2' 0"
				local vsizes2 "`vsizes2' `prev_nonstr_size'"
			}
			local isstrs2 "`isstrs2' 1"
			local vsizes2 "`vsizes2' `curr_size'"
			local prev_nonstr_size ""
		}
		else{
			if "`prev_nonstr_size'"=="" local prev_nonstr_size  `curr_size'
			else    local prev_nonstr_size = `prev_nonstr_size'+`curr_size'
			if `i'==`=`k''{
				local isstrs2 "`isstrs2' 0"
				local vsizes2 "`vsizes2' `prev_nonstr_size'"			
			}
		}
	}
	
	file seek `fhandle' `=`varnames'+8+2'
	forval i=1/`=`k''{
		zero_padding `fhandle' `vname_len'
	}
	
	file seek `fhandle' `=`sortlist'+8+2'
	zero_padding `fhandle' `=`k'+1', chunk_size(2)
	
	file seek `fhandle' `=`formats'+7+2'
	forval i=1/`=`k''{
		zero_padding `fhandle' `=cond(`ver_str'==117,49,57)'
	}
	
	file seek `fhandle' `=`value_label_names'+17+2'
	forval i=1/`=`k''{
		zero_padding `fhandle' `vname_len'
	}
	
	file seek `fhandle' `=`variable_labels'+15+2'
	forval i=1/`=`k''{
		zero_padding `fhandle' `=cond(`ver_str'==117,81,321)'
	}
	
	file seek `fhandle' `=`characteristics'+15+2'
	file read  `fhandle' %4s next_chunk
	while "`next_chunk'"=="<ch>"{
		file read  `fhandle' %4bu `char_len'
		zero_padding `fhandle' `vname_len'
		zero_padding `fhandle' `vname_len'
		zero_padding `fhandle' `=`char_len'-2*`vname_len''
		file read  `fhandle' %5s next_chunk //end of last tag
		file read  `fhandle' %4s next_chunk
	}
	
	file seek `fhandle' `=`data'+4+2'
	if "`isstrs2'"!="0"{
		local curr_pos = `=`data''+4+2
		local vsizes2_len : list sizeof vsizes2
		forval i=1/`=`N''{
			forval j=1/`vsizes2_len'{
				local isstr : word `j' of `isstrs2'
				local vsize  : word `j' of `vsizes2'
				
				if `isstr'{
					zero_padding `fhandle' `vsize'
				}
				else{
					file seek `fhandle' `=`curr_pos'+`vsize''
				}
				local curr_pos=`curr_pos'+`vsize'
			}	
		}
	}
	
	*Nothing to do in strls
	
	*Stata makes compact value label tables, so no randomness in the strings.
	* Note, others may not.
	file seek `fhandle' `=`value_labels'+12+2'
	file read  `fhandle' %5s next_chunk
	while "`next_chunk'"=="<lbl>"{
		file read  `fhandle' %4bu `val_lbl_len'
		zero_padding `fhandle' `vname_len'
		file write `fhandle' %1bu (0)
		file write `fhandle' %1bu (0)
		file write `fhandle' %1bu (0)
		
		file seek `fhandle' query
		file seek `fhandle' `=r(loc)+`val_lbl_len''
		
		file read  `fhandle' %6s next_chunk //end of last tag
		file read  `fhandle' %5s next_chunk
	}
	
	file close `fhandle'
end


program read_8byte_integer
	syntax anything(name=fhandle), local(string)
	
	file seek `fhandle' query
	tempname i1 i2
	file read `fhandle' %4bu `i1'
	file read `fhandle' %4bu `i2'
	
	_assert `i2'==0, msg("Large files over 2gigs not supported yet")
	c_local `local' `=`i1''
end
