*! version 0.1.0 Brian Quistorff <bquistorff@gmail.com>
*! Makes pdf files reproducible by removing any non-determinism (e.g. timestamps, randomness).
program graph_exportr
	syntax anything(name=filename) [, as(string) *]
	local filename `filename' //remove quotes if any
		
	graph export "`filename'", as(`as') `options'
	
	if regexm("`filename'",`"\.([a-zA-Z0-9]*)"?$"') local ext = regexs(1)
	local fmt = cond("`as'"!="","`as'","`ext'")
	if "`fmt'"=="pdf"{
		_strip_nonreproducibility_pdf "`filename'"
	}
end

