program save_all_figs
	syntax anything(name=base_name) [, nogph]
	
	if "`gph'"!="nogph" graph_save "fig/gph/`base_name'.gph", replace
	
	if "${OMIT_FIG_EXPORT}"!="1" exit
	
	graph_export "fig/pdf/`base_name'.pdf", replace
	graph_export "fig/eps/`base_name'.eps", replace
	
	gr_edit .title.draw_view.setstyle, style(no)
	graph_export "fig/pdf/cuts/`base_name'_notitle.pdf", replace
	graph_export "fig/eps/cuts/`base_name'_notitle.eps", replace
	
	gr_edit .note.draw_view.setstyle, style(no)
	graph_export "fig/pdf/cuts/`base_name'_bare.pdf", replace
	graph_export "fig/eps/cuts/`base_name'_bare.eps", replace
	
	/*gr_edit .title.draw_view.setstyle, style(yes)
	graph_export "fig/pdf/cuts/`base_name'_nonotes.pdf", replace
	graph_export "fig/eps/cuts/`base_name'_nonotes.eps", replace*/

end
