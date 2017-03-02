*! version 0.1.0 Brian Quistorff <bquistorff@gmail.com>
*! Makes pdf files reproducible by removing any non-determinism (e.g. timestamps, randomness).
* For png/tif the width/height is the graph window, which might change between, so keep the Stata default
program graph_exportr
	syntax anything(name=filename) [, as(string) width(int 857) *]
	local filename `filename' //remove quotes if any
	
	if regexm("`filename'",`"\.([a-zA-Z0-9]*)"?$"') local ext = regexs(1)
	local fmt = cond("`as'"!="","`as'","`ext'")
	
	if inlist("`fmt'","png","tif") local rast_options "width(`width')"
	
	graph export "`filename'", as(`as') `options' `rast_options'
	
	if "`fmt'"=="pdf"{
		_strip_nonreproducibility_pdf "`filename'"
	}
end

