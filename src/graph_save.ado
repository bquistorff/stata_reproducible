*TODO: SOURCE_DATE_EPOCH
*Can't read/write in place because sometimes the identfiers are different length
program graph_save
	syntax anything [, asis *]
	_assert "`asis'"=="", msg("Can not parse asis graphs")
	gettoken first second : anything
	local filename = cond("`second'"=="","`first'", "`second'")
	
	graph save `anything' , `options'
	
	strip_nodeterminism_gph `filename'
end

program strip_nodeterminism_gph
	args filename
	
	tempname in out
	file open `in' using `filename', read text
	file open `out' using `filename'.nor, write text replace
	file read  `in'    line //Stata 13 & 14 say same
	file write `out' "`line'`=char(10)'"
	file read  `in'    line //13 & 14 differ
	local rstatus = "`r(status)'"
	local nl_len = cond("`rstatus'"=="win",2,1)
	file write `out' "`line'`=char(10)'"
	file seek `in' query
	local pos =r(loc)
	file close `in'
	file close `out'
	
	local gversion = substr("`line'",5,1)
	_assert inlist(`gversion',3,4), msg("Only can parse gph format 3 (stata v13) or 4 (stata v14)")
	
	local date "10 Jul 2013"
	local time_rough "14:23"
	local time "`time_rough':00"
	local date_time ="`date' `time_rough'"
	
	while 1{
		file open `in' using `filename', read text
		file seek `in' `pos'
		file open `out' using `filename'.nor, write text append
		file read `in' line
		while `"`line'"'!="<BeginSersetData>" & r(eof)==0{
			
			if strpos(`"`line'"',"<BeginItem>") loc items "`items' `: word 3 of `line''"
			
			if strpos(`"`line'"',"*! command_date:")==1  loc line "*! command_date: `date'"
			if strpos(`"`line'"',"*! command_time:")==1  loc line "*! command_time: `time'"
			if strpos(`"`line'"',"*! datafile_date:")==1 loc line "*! datafile_date: `date_time'"
			if strpos(`"`line'"',".date = ")==1     loc line `".date = "`date'""'
			if strpos(`"`line'"',".time = ")==1     loc line `".time = "`time'""'
			if strpos(`"`line'"',".dta_date = ")==1 loc line `".dta_date = "`date_time'""'
			
			local new_line =`"`macval(line)'"'
			forval i=1/`: list sizeof items' {
				local item : word `i' of `items'
				local len = length("`item'")
				local new_item = "K"+string(`i',"%0`=`len'-1'.0f")
				local new_line = subinstr(`"`macval(new_line)'"', "`item'","`new_item'",.)
			}
			file write `out' `"`macval(new_line)'`=char(10)'"'
			
			file read `in' line
		}
		if r(eof) continue, break
		file write `out' "`line'`=char(10)'"
		
		file seek `in' query 
		local pass_off_pos = r(loc)
		file close `in'
		local pass_off_pos_out = r(loc)
		file close `out'
		
		strip_nodeterminism_serset `pass_off_pos' `pass_off_pos_out', filename_in(`filename') filename_out(`filename'.nor) pass_of_local(pos) vers(`gversion')
	}
	
	file close `in'
	file close `out'
	copy `filename'.nor `filename', replace
	erase `filename'.nor
end

program strip_nodeterminism_serset
	syntax anything, filename_in(string) filename_out(string) pass_of_local(string) vers(int)
	gettoken pos pos_out: anything
	tempname in out
	
	*Get the outline of the serset from Stata rather than parsing ourselves
	*Could parse the <series> tags above, but this is easier
	file open `in' using `filename_in', read binary
	file seek `in' `=`pos''
	file sersetread `in'
	file seek `in' query 
	local pass_off_pos = r(loc)
	file close `in'
	c_local `pass_of_local'     `pass_off_pos'
	
	serset
	local nobs = `r(N)'
	local nvar = `r(k)'
	
	file open `out' using `filename_out', write append binary
	file sersetwrite `out'
	file close `out'
	serset drop
	
	file open `out' using `filename_out', read write binary
	file seek `out' `=`pos_out''
	
	zero_padding `out' 26
	
	file seek `out' query
	file seek `out' `=r(loc)+`nvar''
	
	forval i=1/`nvar'{
		zero_padding `out' `=cond(`vers'==3,54,150)'
	}
	forval i=1/`nvar'{
		zero_padding `out' `=cond(`vers'==3,49,57)'
	}
	
	file close `out'
end
