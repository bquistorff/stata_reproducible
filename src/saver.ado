*! version 0.1.0 Brian Quistorff <bquistorff@gmail.com>
*! Makes dta files reproducible by removing any non-determinism (e.g. timestamps, randomness).
* Don't use preserve/restore in here as that swaps the order of chars & val labels (and can 
* affect how they are written). 
* Using {it:version 13: save ...} will produce a different sized file than {it:save ...} on the same version, because characteristics, which are variable length, will differ.
program saver
	syntax [anything(name=filename)] [, VERsion(string) *]
	if "`version'"=="" local version $DEFAULT_OUT_VERSION
	local filename `filename' //remove quotes if any
	
	_assert `c(stata_version)'>=13, msg("Must have Stata version at least 13")
	_assert inlist("`version'","","13","14"), msg("version option must be either blank, '13', or '14'")
	_assert `c(stata_version)'>=14 | "`version'"=="13", msg("version must be less than or equal to Stata version")
	
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
	
	if "`:char _dta[datasignature_dt]'"!=""{
		local fake_dt : di %21x clock("`fake_dt_str'", "DMYhm")
		char _dta[datasignature_dt] "`fake_dt'"
	}
	
	if "`version'"=="13" & `c(stata_version)'>=14{
		saveold "`filename'", `options' version(`version')
	}
	else{
		if "`filename'"==""{
			save, `options'
			local filename "`c(filename)'"
		}
		else{
			save "`filename'", `options'
		}
	}
	
	_strip_nonreproducibility_dta "`filename'", fake_dt_str("`fake_dt_str'")

end


