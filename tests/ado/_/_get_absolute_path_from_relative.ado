program _get_absolute_path_from_relative
	syntax anything(name=relative), local(string)
	local relative `relative' //remove possible surrounding quotes
	local orig_pwd "`c(pwd)'"
	cap cd "`relative'"
	local new_pwd "`c(pwd)'"
	qui cd "`orig_pwd'"
	_assert _rc==0, msg("Invalid relative path")
	c_local `local' `new_pwd'
end
