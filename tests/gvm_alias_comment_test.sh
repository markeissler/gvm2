source "${SANDBOX}/gvm2/scripts/gvm"

## Cleanup test objects
gvm alias delete foo
gvm alias delete bar
#######################

## Test output messages
gvm alias # status=1; match=/Unrecognized command: empty/
gvm alias --help # status=0; match=/Usage: gvm alias <command> \[option\]/
gvm alias create # status=1; match=/ERROR: Please specify the alias name/
gvm alias create --help # status=0; match=/Usage: gvm alias create \[option\] <alias-name>/
gvm alias delete # status=1; match=/ERROR: Please specify the alias name/
gvm alias delete --help # status=0; match=/Usage: gvm alias delete \[option\] <alias-name>/
gvm alias list --help # status=0; match=/Usage: gvm alias list \[option\]/

gvm alias create foo go1.3.3 # status=0
gvm alias create bar go1.2.2 # status=0
gvm alias list # status=0; match=/gvm go aliases/; match=/foo \(go1\.3\.3\)/; match=/bar \(go1\.2\.2\)/
gvm use foo # status=0
go version # status=0; match=/go1\.3\.3/
gvm use bar # status=0
go version # status=0; match=/go1\.2\.2/
gvm alias delete foo
gvm alias list # status=0; match=/gvm go aliases/; match!=/foo \(go1\.3\.3\)/; match=/bar \(go1\.2\.2\)/
gvm alias delete bar
gvm alias list # status=0; match=/gvm go aliases/; match!=/foo \(go1\.3\.3\)/; match!=/bar \(go1\.2\.2\)/
