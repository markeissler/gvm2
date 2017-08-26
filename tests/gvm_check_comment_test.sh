source "${SANDBOX}/gvm2/scripts/gvm"

##
## Test output messages
##

gvm check -h # status=0; match=/Usage: gvm check \[option\]/
gvm check --help # status=0; match=/Usage: gvm check \[option\]/

## Test without flags (should fail as hg is not installed by default)
gvm check # status=1; match=/\[!!\] Could not find command: hg/

## Test with flags
gvm check --skip hg # status=0
gvm check --quiet --skip hg # status=0; match!=/All dependency checks passed/
