*! version 0.1.0 Brian Quistorff <bquistorff@gmail.com>
*! Converts local paths in a trk file of an ado root between absolute and relative forms.
* Can't automatically determine -net ado- since -net query- doesn't return programmatically
program make_trk_paths
	syntax anything(name=new_type), adofolder(string)
	
	_assert inlist("`new_type'","relative","absolute"), msg("Need to specify relative or absolute")
	local adofolder `adofolder' //remove surrounding quotes
	
	tempname in out
	file open `in' using "`adofolder'/stata.trk", read text
  tempfile stata_trk_new
  //local stata_trk_new "`adofolder'/stata.trk.new" //if using, remember to erase below
	qui file open `out' using "`stata_trk_new'", write text replace
  
  file read `in' next_u_id_line
	file write `out' `"`macval(next_u_id_line)'"' _n
  
  file read `in' trk_version_line
  if "`trk_version_line'"!="*! version 1.0.0" di as err "make_trk_paths not test of trk files not version 1.0.0"
	file write `out' `"`macval(trk_version_line)'"' _n
  
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
					if "`new_type'"=="relative" _get_relative_path_from_absolute "`path'", local(new_path)
					else                        _get_absolute_path_from_relative "`path'", local(new_path)
				
					file write `out' "S `new_path'" _n
					continue
				}
			}
		}
		file write `out' `"`macval(line)'"' _n
	}

	file close `in'
	file close `out'
	
	copy "`stata_trk_new'" "`adofolder'/stata.trk", replace
	//erase "`stata_trk_new'" //not needed if using tempfile
end
