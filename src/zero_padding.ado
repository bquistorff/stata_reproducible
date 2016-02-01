*Works with UTF-8 strings too (leave default chunk_size=1) since a valid UTF-8 char can't have an internal 0 byte.
program zero_padding
	syntax anything [, chunk_size(int 1)]
	gettoken fhandle total_size : anything
	tempname charval
	scalar `charval'=1
	
	forval b=1/`total_size'{
		if `=`charval''!=0 {
			file read  `fhandle' %`chunk_size'bu `charval'
		}
		else{
			file write `fhandle' %`chunk_size'bu (0)
		}
	}
end
