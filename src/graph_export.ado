*TODO: only do for PDFs. Check on the Lib Haru (PDF-1.6)
program graph_export
	syntax anything(name=filename) [, *]
	
	graph export `filename', `options'
	
	tempname fhandle
	file open `fhandle' using `filename', read write text
	file read `fhandle' line
	local rstatus = "`r(status)'"
	local nl_len = cond("`rstatus'"=="win",2,1)

	if "`line'"!="%PDF-1.5"{ //only works on JagPDF (on Stata 13)
		file close `fhandle'
		exit
	}
	
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
			file write `fhandle' "20130710142300"
		}
		
		local pos2 = strpos(`"`macval(line)'"',"/ID[<")
		if `pos2'>0{
			file seek `fhandle' `=`pos'-`len'+`pos2'-`nl_len'+4'
			file write `fhandle' "0A3CB2BE6CA192C50EDBD15A1258B512> <0A3CB2BE6CA192C50EDBD15A1258B512"
		}
		
		file read `fhandle' line
	}
	
	file close `fhandle'
end
