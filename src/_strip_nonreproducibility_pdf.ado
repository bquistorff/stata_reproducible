program _strip_nonreproducibility_pdf
	args filename
  
  local filename `filename' //get rid of quotes
	
	tempname fhandle
	file open `fhandle' using "`filename'", read write text
	
	file read `fhandle' line
	
	if "`line'"!="%PDF-1.5"{ //only works on JagPDF (on Stata 13 Win)
		file close `fhandle'
		exit
	}
	
	local rstatus = "`r(status)'"
	local nl_len = cond("`rstatus'"=="win",2,1)
	
	if length("$DEFAULT_OUT_DT")==17 local fake_dt_str : di %tcCCYYNNDDHHMMSS clock("$DEFAULT_OUT_DT", "DMYhm")
	if "`fake_dt_str'"==""{
		local sde_env : environment SOURCE_DATE_EPOCH
		if "`sde_env'"!="" {
			//unix uses seconds since 1970, Stata uses milliseconds since 1960
			local fake_dt_str : di %tcCCYYNNDDHHMMSS `=`sde_env'*1000+clock("01 Jan 1970 00:00", "DMYhm")'
		}
	}
	if "`fake_dt_str'"=="" local fake_dt_str "20010101010100"
	
	file read `fhandle' line
	while r(eof)==0 {
		file seek `fhandle' query
		local pos = r(loc)
		
		if regexm(`"`macval(line)'"',".+ obj<</Length ([0-9]+)/.+>>stream"){
			*skip over these because there are binary 0s and this messes up string functions below
			file seek `fhandle' `=`pos'+`=regexs(1)''
			file read `fhandle' line
			continue
		}
		
		local len : length local line
		
		local pos1 = strpos(`"`macval(line)'"',"/CreationDate (D:")
		if `pos1'>0{
			file seek `fhandle' `=`pos'-`len'+`pos1'-`nl_len'+16'
			file write `fhandle' "`fake_dt_str'"
		}
		
		local pos2 = strpos(`"`macval(line)'"',"/ID[<")
		if `pos2'>0{
			file seek `fhandle' `=`pos'-`len'+`pos2'-`nl_len'+4'
			*Totally random ID
			file write `fhandle' "0A3CB2BE6CA192C50EDBD15A1258B512> <0A3CB2BE6CA192C50EDBD15A1258B512"
		}
		
		file read `fhandle' line
	}
	
	file close `fhandle'
end
