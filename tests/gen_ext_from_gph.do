include preferences.do

local flist : dir "fig/gph/" files "*.gph" , respectcase
foreach f of local flist{
	if regexm("`f'","(.+)\.[a-zA-Z0-9]*$") local f_base = regexs(1)
	graph use "fig/gph/`f_base'"
	save_all_figs `f_base', nogph
}
