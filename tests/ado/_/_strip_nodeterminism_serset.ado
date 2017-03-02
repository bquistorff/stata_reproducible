* Looks like strings and strL's can't be written to sersets.
program _strip_nodeterminism_serset
	syntax anything(name=filename) [, offset(int 0)]
  
  local filename `filename' //get rid of quotes

	tempname out byteorder_num serset_vs k_vars n_obs
	file open `out' using "`filename'", read write binary
	
	file seek `out' `=`offset'+16'
	
	file read `out' %1bu `serset_vs'
	_assert(inlist(`serset_vs',2,3)), msg("Can only normalize sersets in version 2 or 3.")
	
	file read `out' %1bu `byteorder_num'
	file set `out' byteorder `=`byteorder_num''
	
	file read `out' %4bu `k_vars'
	file read `out' %4bu `n_obs'
	file seek `out' `=`offset'+26+`=`k_vars'''
	
	//zero-pad the varnames
	forval i=1/`=`k_vars''{
		_zero_padding `out' `=cond(`serset_vs'==2,54,150)'
	}
	//zero-pad the fmt list
	forval i=1/`=`k_vars''{
		_zero_padding `out' `=cond(`serset_vs'==2,49,57)'
	}
	
	file close `out'
end
