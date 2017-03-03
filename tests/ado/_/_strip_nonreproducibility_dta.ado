program _strip_nonreproducibility_dta
	syntax anything(name=filename), fake_dt_str(string)
  
  local filename `filename' //get rid of quotes
	
	tempname fhandle k N lbl_len additional time_len char_len val_lbl_len
	
	file open `fhandle' using "`filename'", read write binary
	
	file seek `fhandle' 28
	file read  `fhandle' %3s ver_str
	_assert inlist(`ver_str',117,118), msg("Option reproducible does not work for versions below 13 or those above 14.")
	
	local vname_len = cond(`ver_str'==117,33,129)
	
	
	file seek `fhandle' 52
	file read  `fhandle' %3s byteorder_str
	local byteorder_num = cond("`byteorder_str'"=="MSF",1, 2)
	//"MSF" (HILO, or 0x01 in v12) (SPARC), "LSF" (LOHI or 0x02 in v12) (Windows)
	file set `fhandle' byteorder `byteorder_num'
	
	file seek `fhandle' 70
	file read `fhandle' %2bu `k'
	
	file seek `fhandle' 79
	if `ver_str'==117 file read  `fhandle' %4bu `N'
	else   read_8byte_integer `fhandle', byteorder_num(`byteorder_num') scalar(`N')
	
	file seek `fhandle' `=cond(`ver_str'==117,94,98)'
	if `ver_str'==117 file read  `fhandle' %1bu `lbl_len'
	else              file read  `fhandle' %2bu `lbl_len'
	scalar `additional' = `lbl_len'
	
	file seek `fhandle' `=cond(`ver_str'==117,114,119)+`additional''
	file read  `fhandle' %1bu `time_len'
	scalar `additional' = `additional'+`time_len'
	
	if `time_len'==17{ //otherwise=0
		if length("`fake_dt_str'")!=17 local fake_dt_str "01 Jan 2001 01:01"
		file write `fhandle' %17s "`fake_dt_str'"
	}
	
	file seek `fhandle' `=cond(`ver_str'==117,141,146)+`additional'+8+8' //skip the knowns
	tempname variable_types varnames sortlist formats value_label_names variable_labels characteristics data strls value_labels
	*read_8byte_integer `fhandle', byteorder_num(`byteorder_num') local(begin_ds) //0!!
	*read_8byte_integer `fhandle', byteorder_num(`byteorder_num') local(map) //where I am!!
	read_8byte_integer `fhandle', byteorder_num(`byteorder_num') scalar(`variable_types')
	read_8byte_integer `fhandle', byteorder_num(`byteorder_num') scalar(`varnames')
	read_8byte_integer `fhandle', byteorder_num(`byteorder_num') scalar(`sortlist')
	read_8byte_integer `fhandle', byteorder_num(`byteorder_num') scalar(`formats')
	read_8byte_integer `fhandle', byteorder_num(`byteorder_num') scalar(`value_label_names')
	file seek `fhandle' query
	local prev_num_loc = r(loc)
	read_8byte_integer `fhandle', byteorder_num(`byteorder_num') scalar(`variable_labels')
	if `variable_labels'==0{ //sometimes on Windows v13
		scalar `variable_labels' = `value_label_names' + 19 + 33*`k' + 20
		file seek `fhandle' `prev_num_loc'
		write_8byte_integer `fhandle', byteorder_num(`byteorder_num') scalar(`variable_labels')
	}
	read_8byte_integer `fhandle', byteorder_num(`byteorder_num') scalar(`characteristics')
	read_8byte_integer `fhandle', byteorder_num(`byteorder_num') scalar(`data')
	read_8byte_integer `fhandle', byteorder_num(`byteorder_num') scalar(`strls')
	read_8byte_integer `fhandle', byteorder_num(`byteorder_num') scalar(`value_labels')
	*read_8byte_integer `fhandle', byteorder_num(`byteorder_num') local(end_ds)
	*read_8byte_integer `fhandle', byteorder_num(`byteorder_num') local(eof)
	
	file seek `fhandle' `=`variable_types'+14+2'
	tempname vartype
	forval i=1/`=`k''{
		file read `fhandle' %2bu `vartype'
		if `=`vartype'' <=2045{
			local vsizes "`vsizes' `=`vartype''"
			if `=`vartype''==1 local isstrs "`isstrs' 0" /*nothing to do for str1s*/
			else  local isstrs "`isstrs' 1"
			
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
		_zero_padding `fhandle' `vname_len'
	}
	
	file seek `fhandle' `=`sortlist'+8+2'
	_zero_padding `fhandle' `=`k'+1', chunk_size(2)
	
	file seek `fhandle' `=`formats'+7+2'
	forval i=1/`=`k''{
		_zero_padding `fhandle' `=cond(`ver_str'==117,49,57)'
	}
	
	file seek `fhandle' `=`value_label_names'+17+2'
	forval i=1/`=`k''{
		_zero_padding `fhandle' `vname_len'
	}
	
	file seek `fhandle' `=`variable_labels'+15+2'
	forval i=1/`=`k''{
		_zero_padding `fhandle' `=cond(`ver_str'==117,81,321)'
	}
	
	file seek `fhandle' `=`characteristics'+15+2'
	file read  `fhandle' %4s next_chunk
	while "`next_chunk'"=="<ch>"{
		file read  `fhandle' %4bu `char_len'
		_zero_padding `fhandle' `vname_len'
		_zero_padding `fhandle' `vname_len'
		_zero_padding `fhandle' `=`char_len'-2*`vname_len''
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
					_zero_padding `fhandle' `vsize'
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
		_zero_padding `fhandle' `vname_len'
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

//Reads in a 64bit (8 byte) unsigned integer
//Precision info: http://www.stata.com/statalist/archive/2009-08/msg00540.html
//Assumes that the byte order on the filehandle has been set (-file set byteorder-)
//2^(4*8)=4,294,967,296 (=2*(c(maxlong)+28))
program read_8byte_integer
	syntax anything(name=fhandle), byteorder_num(int) scalar(string)
	
	tempname i1 i2 i lo hi
	file read `fhandle' %4bu `i1'
	file read `fhandle' %4bu `i2'
	if `byteorder_num'==1{
		scalar `hi' = `i1'
		scalar `lo' = `i2'
	}
	else{
		scalar `hi' = `i2'
		scalar `lo' = `i1'
	}
	scalar `i' = `hi'*4294967296+`lo'
	
	//scalars are true doubles so 52bits for significand
	// (about 16 decimal digits of precision)
	// so if hi uses more than 20 (52-32) bits we can't accuractely capture it with a double
	// 2^21=2,097,152
	_assert `hi'<2097152, msg("Tried to read an 8 byte unsigned integer and couldn't store it perfectly in scalar given it's got double precision.")
	scalar `scalar' = `i'
	/*
	//Used to allow this, but can't accurately warn about loss of precision, so never better.
	if "`local'"!="" {
		//locals are at least 11 and usually 12 but not sure what that is in terms of bytes?!
		c_local `local' `=`i''
	}
	*/
end

program write_8byte_integer
	syntax anything(name=fhandle), byteorder_num(int) scalar(string)
	
	tempname lo hi
	scalar `lo' = mod(`scalar',4294967296)
	scalar `hi' = floor(`scalar'/4294967296)
	if `byteorder_num'==1{
		file write `fhandle' %4bu (`hi')
		file write `fhandle' %4bu (`lo')
	}
	else{
		file write `fhandle' %4bu (`lo')
		file write `fhandle' %4bu (`hi')
	}
end
