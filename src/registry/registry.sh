#!/usr/bin/env bash
. registry.properties
address=${registry_address}
target=${target_address}
IFS=","
target_arr=(${target})
target_usr=${target_user}
target_wd=${target_passWd}

function tips() {
    echo "-------------------------------------"
    echo ""
	echo "保证用户拥有无密码的sudo权限，你可以使用如下参数进行操作:"
	echo "-tag 镜像名称  -将镜像命名为可上传的镜像"
	echo "-push 镜像名称  -上传镜像到私人仓库"
	echo "-pull 镜像名称   -从私人仓库中拉取镜像"
	echo "-tagPush 镜像名称 -将镜像命名并上传到私人仓库"
	echo ""
	echo "-------------------------------------"
}

function tagImage() {
    source_name=$1
    sudo docker tag "${source_name}" "${address}/${source_name}"
    retturn $?
}

function pushImage() {
    source_name=$1
    sudo docker push "${source_name}"
    return $?
}

function pullImage() {
    source_name=$1
    for (( i = 0; i < ${#target_arr[@]}; ++i )); do
        /usr/bin/expect <<EOF
        set timeout 120
        spawn ssh ${target_usr}@${target_arr[$i]}
        expect {
            "*yes/no" { send "yes\n";exp_continue }
            "*password" { send "${target_wd}\n" }
        }
        expect "${target_usr}*" { send "sudo docker pull ${source_name}\r" }
        expect "${target_usr}*" { send "exit\r" }
        expect eof
EOF
    done
}

case $1 in
tag)
    tagImage $2
    ;;
push)
    pushImage $2
    ;;
pull)
    pullImage $2
    ;;
tagPush)
    image_name=$2
    tagImage ${image_name}
    pushImage "${address}/${image_name}"
    ;;
*)
    shift
    tips
esac