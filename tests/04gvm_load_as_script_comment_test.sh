##
## Load gvm as a function by sourcing it
##

##
## Test output messages for all commands
##

"${SANDBOX}/gvm2/bin/gvm" alias --help # status=0
"${SANDBOX}/gvm2/bin/gvm" cross --help # status=0
"${SANDBOX}/gvm2/bin/gvm" diff --help # status=0
"${SANDBOX}/gvm2/bin/gvm" help --help # status=0
"${SANDBOX}/gvm2/bin/gvm" implode --help # status=0
##"${SANDBOX}/gvm2/bin/gvm" install --help # status=0 ## @TODO: gvm install cli args are reversed
"${SANDBOX}/gvm2/bin/gvm" linkthis --help # status=0
"${SANDBOX}/gvm2/bin/gvm" list --help # status=0
"${SANDBOX}/gvm2/bin/gvm" listall --help # status=0
"${SANDBOX}/gvm2/bin/gvm" pkgenv --help # status=0
"${SANDBOX}/gvm2/bin/gvm" pkgset --help # status=0
"${SANDBOX}/gvm2/bin/gvm" uninstall --help # status=0
"${SANDBOX}/gvm2/bin/gvm" update --help # status=0
"${SANDBOX}/gvm2/bin/gvm" use --help # status=0
"${SANDBOX}/gvm2/bin/gvm" version --help # status=0

##
## pkgset sub-commands
##
"${SANDBOX}/gvm2/bin/gvm" pkgset create --help # status=0
"${SANDBOX}/gvm2/bin/gvm" pkgset delete --help # status=0
"${SANDBOX}/gvm2/bin/gvm" pkgset empty --help # status=0
"${SANDBOX}/gvm2/bin/gvm" pkgset list --help # status=0
"${SANDBOX}/gvm2/bin/gvm" pkgset use --help # status=0
