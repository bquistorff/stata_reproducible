# Test reproducibility
tests:
	git diff-files --quiet

#Test elements of full normalization that we expect to achieve
extra-tests:
	diff norm/auto-v13.dta  norm/auto-v13-from-v14.dta
	diff scatter-v13.gph  scatter-v13-from-v14.gph
