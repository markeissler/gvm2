. "${SANDBOX}/gvm2/scripts/function/locale_text.sh" || return 1

##
## find locale text
##
locales_dir="${SANDBOX}/gvm2/tests/locales"

## Setup expectation (target, startdir, finaldir, retval, retstatus)
expect_1=( "error"    "en-US"  "${locales_dir}"  "Error"      "0")
expect_2=( "warning"  "en-US"  "${locales_dir}"  "Warning"    "0")
expect_3=( "error"    "fr-FR"  "${locales_dir}"  "Erreur"     "0")
expect_4=( "warning"  "fr-FR"  "${locales_dir}"  "Attention"  "0")
expect_5=( "error"    "de"     "${locales_dir}"  "Fehler"     "0")
expect_6=( "warning"  "de"     "${locales_dir}"  "Warnung"    "0")

##
## find locale text (return status)
##

## Execute command
result_1="$(__gvm_locale_text_for_key "${expect_1[0]}" "${expect_1[1]}" "${expect_1[2]}" > /dev/null; echo $?)"
result_2="$(__gvm_locale_text_for_key "${expect_2[0]}" "${expect_2[1]}" "${expect_2[2]}" > /dev/null; echo $?)"
result_3="$(__gvm_locale_text_for_key "${expect_3[0]}" "${expect_3[1]}" "${expect_3[2]}" > /dev/null; echo $?)"
result_4="$(__gvm_locale_text_for_key "${expect_4[0]}" "${expect_4[1]}" "${expect_4[2]}" > /dev/null; echo $?)"
result_5="$(__gvm_locale_text_for_key "${expect_5[0]}" "${expect_5[1]}" "${expect_5[2]}" > /dev/null; echo $?)"
result_6="$(__gvm_locale_text_for_key "${expect_6[0]}" "${expect_6[1]}" "${expect_6[2]}" > /dev/null; echo $?)"

## Evaluate result
[[ "${result_1}" -eq "${expect_1[4]}" ]] # status=0
[[ "${result_2}" -eq "${expect_2[4]}" ]] # status=0
[[ "${result_3}" -eq "${expect_3[4]}" ]] # status=0
[[ "${result_4}" -eq "${expect_4[4]}" ]] # status=0
[[ "${result_5}" -eq "${expect_5[4]}" ]] # status=0
[[ "${result_6}" -eq "${expect_6[4]}" ]] # status=0

##
## find locale text (return value)
##

## Execute command
result_1="$(__gvm_locale_text_for_key "${expect_1[0]}" "${expect_1[1]}" "${expect_1[2]}")"
result_2="$(__gvm_locale_text_for_key "${expect_2[0]}" "${expect_2[1]}" "${expect_2[2]}")"
result_3="$(__gvm_locale_text_for_key "${expect_3[0]}" "${expect_3[1]}" "${expect_3[2]}")"
result_4="$(__gvm_locale_text_for_key "${expect_4[0]}" "${expect_4[1]}" "${expect_4[2]}")"
result_5="$(__gvm_locale_text_for_key "${expect_5[0]}" "${expect_5[1]}" "${expect_5[2]}")"
result_6="$(__gvm_locale_text_for_key "${expect_6[0]}" "${expect_6[1]}" "${expect_6[2]}")"

## Evaluate result
[[ "${result_1}" == "${expect_1[3]}" ]] # status=0
[[ "${result_2}" == "${expect_2[3]}" ]] # status=0
[[ "${result_3}" == "${expect_3[3]}" ]] # status=0
[[ "${result_4}" == "${expect_4[3]}" ]] # status=0
[[ "${result_5}" == "${expect_5[3]}" ]] # status=0
[[ "${result_6}" == "${expect_6[3]}" ]] # status=0

##
## find locale text (RETVAL value)
##

## Execute command
result_1="$(__gvm_locale_text_for_key "${expect_1[0]}" "${expect_1[1]}" "${expect_1[2]}" > /dev/null; echo "${RETVAL}")"
result_2="$(__gvm_locale_text_for_key "${expect_2[0]}" "${expect_2[1]}" "${expect_2[2]}" > /dev/null; echo "${RETVAL}")"
result_3="$(__gvm_locale_text_for_key "${expect_3[0]}" "${expect_3[1]}" "${expect_3[2]}" > /dev/null; echo "${RETVAL}")"
result_4="$(__gvm_locale_text_for_key "${expect_4[0]}" "${expect_4[1]}" "${expect_4[2]}" > /dev/null; echo "${RETVAL}")"
result_5="$(__gvm_locale_text_for_key "${expect_5[0]}" "${expect_5[1]}" "${expect_5[2]}" > /dev/null; echo "${RETVAL}")"
result_6="$(__gvm_locale_text_for_key "${expect_6[0]}" "${expect_6[1]}" "${expect_6[2]}" > /dev/null; echo "${RETVAL}")"

## Evaluate result
[[ "${result_1}" == "${expect_1[3]}" ]] # status=0
[[ "${result_2}" == "${expect_2[3]}" ]] # status=0
[[ "${result_3}" == "${expect_3[3]}" ]] # status=0
[[ "${result_4}" == "${expect_4[3]}" ]] # status=0
[[ "${result_5}" == "${expect_5[3]}" ]] # status=0
[[ "${result_6}" == "${expect_6[3]}" ]] # status=0
