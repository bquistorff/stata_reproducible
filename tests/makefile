test-linux:
	stata14-se -b do test.do
	git status
	stata13-se -b do test.do
	git status
 
test-windows:
	"/cygdrive/c/Program Files (x86)/Stata13/StataSE-64.exe" /e  do test.do
	git status
	"/cygdrive/c/Program Files (x86)/Stata14/StataSE-64.exe" /e  do test.do
	git status

# Test reproducibility
tests:
	git diff-files --quiet

#Test elements of full normalization that we expect to achieve
extra-tests:
	diff norm/auto-v13.dta  norm/auto-v13-from-v14.dta
	diff scatter-v13.gph  scatter-v13-from-v14.gph
