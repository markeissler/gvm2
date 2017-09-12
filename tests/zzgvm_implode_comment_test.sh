source "${SANDBOX}/gvm2/scripts/gvm"
yes n | gvm implode # status=0; match=/Action cancelled/
yes y | gvm implode # status=0; match=/GVM2 successfully removed/
