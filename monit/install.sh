#! /bin/bash

# 获取执行目录，脚本本身的目录
GetPath() {
    exec_path=$(pwd) # 执行目录
    script_path=$(cd $(dirname "${0}"); pwd) # 脚本本身目录
}
GetPath

. ${script_path}/common.sh

GetArchitecture(){
    uname -a | grep x86_64 > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        is_x64=true
    fi

    uname -a | grep -E 'arm|aarch' > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        is_arm=true
    fi
}
GetArchitecture

Main(){
    Exec "sudo chown -R ${USER}:${USER} ${script_path}/"
    Exec "sudo chmod a+x ${script_path}/*monit"
    Exec "sudo cp -p ${script_path}/*monit /usr/local/bin"

    if [[ ${is_x64} == true ]]; then
        Exec "sudo cp -p ${script_path}/monit-x64/monit /usr/local/bin/"
    elif [[ ${is_arm} == true ]]; then
        Exec "sudo cp -p ${script_path}/monit-aarch64/monit /usr/local/bin/"
    fi
    Exec "sudo chmod u+x /usr/local/bin/monit"

    Exec "sudo cp -p ${script_path}/conf/monitrc ~/.monitrc"
    Exec "sudo chmod 0700 ~/.monitrc"

    PrintGreen "Installation complete, please configurate ~/.monitrc"
    PrintGreen "Then monit"
}
Main "$@"