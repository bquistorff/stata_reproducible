*! version 0.1.0 Brian Quistorff <bquistorff@gmail.com>
*! Makes gph files reproducible by removing any non-determinism (e.g. timestamps, randomness).
*Can't read/write in place because sometimes the identfiers are different length
program graph_saver
	syntax anything [, asis version(string) *]
	_assert "`asis'"=="", msg("Can not parse asis graphs")
	if "`version'"=="" local version $DEFAULT_OUT_VERSION
	_assert inlist("`version'","","13","14"), msg("Can only graph_save as older from v14 to v13")
	
	gettoken first second : anything
	if "`second'"!=""{
		local gphname `first'
		local filename `second'
	}
	else{
		local filename `first'
	}
	
	//$DEFAULT_OUT_DT -> SOURCE_DATE_EPOCH -> prog_default
	if length("$DEFAULT_OUT_DT")==17 local fake_dt_str "$DEFAULT_OUT_DT"
	if "`fake_dt_str'"==""{
		local sde_env : environment SOURCE_DATE_EPOCH
		if "`sde_env'"!="" {
			//unix uses seconds since 1970, Stata uses milliseconds since 1960
			local fake_dt_str : di %tcDD_Mon_CCYY_HH:MM `=`sde_env'*1000+clock("01 Jan 1970 00:00", "DMYhm")'
		}
	}
	if "`fake_dt_str'"=="" local fake_dt_str "01 Jan 2001 01:01"
	
	graph save `gphname' "`filename'" , `options'
	
	if ("`version'"=="13" & `c(stata_version)'>=14) local old3 old3
	_strip_nonreproducibility_gph "`filename'", fake_dt_str("`fake_dt_str'") `old3'
end

