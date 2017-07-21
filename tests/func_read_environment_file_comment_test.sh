. "${SANDBOX}/gvm2/scripts/function/read_environment_file" || return 1

hash=( $(__gvm_read_environment_file "${SANDBOX}/gvm2/tests/func_read_environment_file_comment_test_input.sh") )
echo "${hash[@]}"
expectedHashStr="GVM_ROOT:%2fUsers%2fme%2f.gvm gvm_go_name:go1.7.1 gvm_pkgset_name:global GOROOT:%24GVM_ROOT%2fgos%2fgo1.7.1"

[[ "${hash[@]}" == "${expectedHashStr}" ]] # status=0
