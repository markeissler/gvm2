source $GVM_ROOT/scripts/gvm
gvm use go1.3.3 # status=0
go version # status=0; match=/go1\.3\.3/
gvm use go1.2.2 # status=0
go version # status=0; match=/go1\.2\.2/
gvm use go1.x.x # status=1
gvm use goBogusTag # status=1
