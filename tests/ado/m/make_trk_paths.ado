* Pass in -net ado- since -net query- doesn't return programmatically
* Currently works with version 1.0.0 of trk file format (see line 2)
* NB: No need to normalize the U counters (also first line), just sync everyone on change.
program make_trk_paths
	syntax anything(name=new_type), net_ado(string)
	
	_assert inlist("`new_type'","relative","absolute"), msg("Need to specify relative or absolute")
	local net_ado `net_ado' //remove surrounding quotes
	
	tempname in out
	file open `in' using "`net_ado'/stata.trk", read text
	qui file open `out' using "`net_ado'/stata.trk.new", write text replace
	while 1 {
		file read `in' line
		local status "`r(status)'"
		if r(eof)==1 continue, break
		
		local linelen = strlen(`"`macval(line)'"')
		if `linelen'>=3 {
			if substr(`"`line'"',1,2)=="S "{
				local path = substr(`"`macval(line)'"',3,.)
				local pathlen = strlen(`"`macval(path)'"')
				
				local loc_abs = (substr("`path'",1,1)=="/" | substr("`path'",2,1)==":")
				local rem_abs = (substr("`path'",5,2)==":/" | substr("`path'",6,2)==":/") // http:/ https:/
				local loc_rel = (!`loc_abs' & !`rem_abs')
				local to_convert = (("`new_type'"=="relative" & `loc_abs') | ///
														("`new_type'"=="absolute" & `loc_rel'))
								
				if `to_convert'{
					if "`new_type'"=="relative" get_relative_path_from_absolute "`path'", local(new_path)
					else                        get_absolute_path_from_relative "`path'", local(new_path)
				
					file write `out' "S `new_path'" _n
					continue
				}
			}
		}
		file write `out' `"`macval(line)'"' _n
	}

	file close `in'
	file close `out'
	
	copy "`net_ado'/stata.trk.new" "`net_ado'/stata.trk", replace
	erase "`net_ado'/stata.trk.new"
end
