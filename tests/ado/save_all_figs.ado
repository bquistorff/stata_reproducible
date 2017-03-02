program save_all_figs
	syntax anything(name=base_name) [, nogph]
	
	if "`gph'"!="nogph" graph_saver "fig/gph/`base_name'.gph", replace version(13)
	
	if "${OMIT_FIG_EXPORT}"=="1" exit
	
	graph_exportr "fig/pdf/`base_name'.pdf", replace
	graph_exportr "fig/eps/`base_name'.eps", replace
	
	gr_edit .title.draw_view.setstyle, style(no)
	graph_exportr "fig/pdf/cuts/`base_name'_notitle.pdf", replace
	graph_exportr "fig/eps/cuts/`base_name'_notitle.eps", replace
	
	gr_edit .note.draw_view.setstyle, style(no)
	graph_exportr "fig/pdf/cuts/`base_name'_bare.pdf", replace
	graph_exportr "fig/eps/cuts/`base_name'_bare.eps", replace
	
	/*gr_edit .title.draw_view.setstyle, style(yes)
	graph_exportr "fig/pdf/cuts/`base_name'_nonotes.pdf", replace
	graph_exportr "fig/eps/cuts/`base_name'_nonotes.eps", replace*/

end
