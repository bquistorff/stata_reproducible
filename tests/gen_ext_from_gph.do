include preferences.do

local flist : dir "fig/gph/" files "*.gph" , respectcase
foreach f of local flist{
	graph use "fig/gph/`f'"
	save_all_figs `f', nogph
}
