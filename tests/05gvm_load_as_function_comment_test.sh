##
## Load gvm as a function by sourcing it
##
source "${SANDBOX}/gvm2/scripts/gvm"

##
## Test output messages for all commands
##

gvm alias --help # status=0
gvm cross --help # status=0
gvm diff --help # status=0
gvm help --help # status=0
gvm implode --help # status=0
##gvm install --help # status=0 ## @TODO: gvm install cli args are reversed
gvm linkthis --help # status=0
gvm list --help # status=0
gvm listall --help # status=0
gvm pkgenv --help # status=0
gvm pkgset --help # status=0
gvm uninstall --help # status=0
gvm update --help # status=0
gvm use --help # status=0
gvm version --help # status=0

##
## pkgset sub-commands
##
gvm pkgset create --help # status=0
gvm pkgset delete --help # status=0
gvm pkgset empty --help # status=0
gvm pkgset list --help # status=0
gvm pkgset use --help # status=0
