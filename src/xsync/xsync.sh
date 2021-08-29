#!/usr/bin/env bash
. target.properties
is_UseOnePassWd=${allUseOnePassWd}
target=${target_address}
IFS=","
target_arr=(${target})
source_file=$1
target_file=$2
input_arr=($@)
input_arg="-avz"
if [[ $# -gt 2 ]]; then
    for (( i = 2; i < $#; ++i )); do
        input_arg="${input_arg} ${input_arr[$i]}"
    done
fi
if [[ ${is_UseOnePassWd} = "true" ]]; then
    target_user_name=${target_user}
    target_password=${target_passWd}
    for (( i = 0; i < ${#target_arr[@]}; ++i )); do
        /usr/bin/expect <<EOF
        set timeout 120
        spawn rsync "${input_arg}" "${source_file}" "${target_user_name}@${target_arr[$i]}:${target_file}"
        expect {
            "*yes/no" { send "yes\n";exp_continue }
            "*password" { send "${target_password}\n" }
        }
        expect eof
EOF
    done
else
    target_user_name=${target_user}
    target_password=${target_passWd}
    IFS=","
    target_user_arr=(${target_user_name})
    target_password_arr=(${target_password})
    for (( i = 0; i < ${#target_arr[@]}; ++i )); do
        /usr/bin/expect <<EOF
        set timeout 120
        spawn rsync "${input_arg}" ${source_file} "${target_user_arr[$i]}@${target_arr[$i]}:${target_file}"
        expect {
            "*yes/no" { send "yes\n";exp_continue }
            "*password" { send "${target_password_arr[$i]}\n" }
        }
        expect eof
EOF
    done
fi
exit 0
