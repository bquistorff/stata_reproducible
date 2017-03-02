program _strip_nonreproducibility_gph
	syntax anything(name=filename) , fake_dt_str(string) [old3]
  
  local filename `filename' //get rid of quotes
	
	tempname in out
	tempfile filename_nor
	//local filename_nor "`filename'.nor" //if using make sure to erase below
	file open `in' using "`filename'", read text
	file open `out' using "`filename_nor'", write text replace
	
	file read  `in'    line //Stata 13 & 14 say same
	file write `out' "`line'`=char(10)'" //char(10) is line-feed (\n). This is a Unix line ending
	file read  `in'    line //13 & 14 differ
	local rstatus = "`r(status)'"
	local nl_len = cond("`rstatus'"=="win",2,1)
	if "`old3'"!="" local line "00003:00003:"
	file write `out' "`line'`=char(10)'"
	file seek `in' query
	local pos =r(loc)
	file close `in'
	file close `out'
	
	local gversion = substr("`line'",5,1)
	_assert inlist(`gversion',3,4), msg("Only can parse gph format 3 (stata v13) or 4 (stata v14)")
	
	local date = substr("`fake_dt_str'",1,11)
	local hhmm = substr("`fake_dt_str'",13,5)
	local time "`hhmm':00"
	local date_time ="`date' `hhmm'"
	
	while 1{
		file open `in' using "`filename'", read text
		file seek `in' `pos'
		file open `out' using "`filename_nor'", write text append
		file read `in' line
		while `"`line'"'!="<BeginSersetData>" & r(eof)==0{
			
			if strpos(`"`line'"',"<BeginItem>"){
        loc items "`items' `: word 3 of `line''"
       }
			
			if strpos(`"`line'"',"*! command_date:")==1  loc line "*! command_date: `date'"
			if strpos(`"`line'"',"*! command_time:")==1  loc line "*! command_time: `time'"
			if strpos(`"`line'"',"*! datafile_date:")==1 loc line "*! datafile_date: `date_time'"
			if strpos(`"`line'"',".date = ")==1     loc line `".date = "`date'""'
			if strpos(`"`line'"',".time = ")==1     loc line `".time = "`time'""'
			if strpos(`"`line'"',".dta_date = ")==1 loc line `".dta_date = "`date_time'""'
			
			local new_line =`"`macval(line)'"'
			forval i=1/`: list sizeof items' {
				local item : word `i' of `items'
				*local len = length("`item'")
				local len=9
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
		
		file close `out'
		
		local serset_vs = cond("`old3'"!="","2","")
		_copy_serset "`filename'" "`filename_nor'", pass_of_local(pos) offset_src(`pass_off_pos') version(`serset_vs') ensure_reproducible 
	}
	
	file close `in'
	file close `out'
	copy "`filename_nor'" "`filename'", replace
	//erase "`filename_nor'" //not needed if using tempfile
end

