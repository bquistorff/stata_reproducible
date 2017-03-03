# Comments that begin with ## will be shown from target help


.PHONY: list help
help : 
	@echo "Output comments:"
	@echo
	@sed -n 's/^##//p' makefile
	@printf "\nList of all targets: "
	@$(MAKE) -s list

# List targets (http://stackoverflow.com/a/26339924/3429373)
list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' | xargs

.PHONY: check_smcl check_version check
	

check : check_smcl inc_dist_date
	
inc_dist_date:
	sed -i "s/\(d Distribution-Date: \).\+/\1$$(date +%Y%m%d)/g" code/ado/synth_runner.pkg

#Smcl has problems displaying lines over 244 characters
check_smcl:
	@echo "Will display lines if error"
	-grep '.\{245\}' src/*.sthlp
	@echo ""