program log_closer
	syntax anything(name=name) [, delete_line_user(string) ///
		rw_line_user_pre(string) rw_line_user_post(string) raw_dir(string)]
	
	qui log query `name'
	local filename "`r(filename)'"
	local type "`r(type)'"
	
	log close `name'
	
	_strip_nonreproducibility_log "`filename'", type(`type') combine delete_line_user(`delete_line_user') ///
		rw_line_user_pre(`rw_line_user_pre') rw_line_user_post(`rw_line_user_post') raw_dir(`raw_dir')
end


