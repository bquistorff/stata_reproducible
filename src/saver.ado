*! version 0.0.8 Brian Quistorff <bquistorff@gmail.com>
*! Makes dta files reproducible by removing any non-determinism
*! (e.g. timestamps, randomness). Plus a few helper options.
*TODO: SOURCE_DATE_EPOCH
*NB: Using -version 13: save ...- will produce a different sized file than -save ...-
*   Because things like characteristics, which are variable length, will differ.
program saver
	syntax anything [, noDATAsig noCOMPress noREPROducible VERsion(string) *]
	
	if "`compress'"!="nocompress" compress
	
	if "`datasig'"!="nodatasig" {
		datasig set, reset
		*%tc date-time when set in %21x format
		char _dta[datasignature_dt] "+1.9bf54c4900000X+028"
	}
	
	cap unab temp: _*
	if `:list sizeof temp'>0 di "Warning: Saving with temporary (_*) vars"
	
	if "`version'"=="" local version $DTA_DEFAULT_VERSION
	if "`version'"=="13" & `c(stata_version)'>=14{
		saveold `anything', `options' version(`version')
	}
	else{
		save `anything', `options'
	}
	
	if ("`reproducible'"!="noreproducible") strip_nodeterminism_dta `anything'

end

program strip_nodeterminism_dta
	args filename
	
	tempname fhandle k lbl_len additional time_len char_len val_lbl_len
	
	file open `fhandle' using `filename', read write binary
	
	file seek `fhandle' 28
	file read  `fhandle' %3s ver_str
	
	if !inlist(`ver_str',117,118){
		di "Option reproducible does not work for versions below 13 or those at least 16."
		exit
	}
	
	local vname_len = cond(`ver_str'==117,33,129)
	
	file seek `fhandle' 70
	file read  `fhandle' %2bu `k'
	
	file seek `fhandle' `=cond(`ver_str'==117,94,98)'
	if `ver_str'==117 file read  `fhandle' %1bu `lbl_len'
	else              file read  `fhandle' %2bu `lbl_len'
	scalar `additional' = `lbl_len'
	
	file seek `fhandle' `=cond(`ver_str'==117,114,119)+`additional''
	file read  `fhandle' %1bu `time_len'
	scalar `additional' = `additional'+`time_len'
	
	if `time_len'==17{ //otherwise=0
		*read SOURCE_DATE_EPOCH () https://reproducible-builds.org/specs/source-date-epoch/
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
