#! /bin/bash

GetPath() {
    # execPath=$(pwd) # 执行目录
    scriptPath=$(
        cd "$(dirname "${0}")" || exit 1
        pwd
    ) # 脚本本身目录
}
GetPath

. ./common.sh

IsCurrentRoot() {
    user=$(env | grep USER | cut -d "=" -f 2)
    if [ "$user"x == "root"x ]; then
        return 0
    fi
    return 1
}

CheckCurrentRoot() {
    if IsCurrentRoot; then
        PrintGreen "Is root"
        is_root=true
    else
        PrintYellow "Is not root"
        is_root=false
    fi
}

WriteRoot() {
    Exec 'cat ./bashrc >> /etc/bashrc'
    Exec 'cat ./inputrc >> /etc/inputrc'

    if [[ ${def_vim} == true ]]; then
        Exec 'cat ./vimrc >> /etc/vimrc'
    fi
}

WriteNotRoot() {
    Exec 'cat ./bashrc >> ~/.bashrc'
    Exec 'cat ./inputrc >> ~/.inputrc'

    if [[ ${def_vim} == true ]]; then
        Exec 'cat ./vimrc >> ~/.vimrc'
    fi
}

Write() {
    PrintBlue "Do you want to configure vim with default settings?"
    PrintYellow "Note: If you use new vim configuration, please type 'n'"
    if Confirm; then
        def_vim=true
    fi

    if [[ "$is_root" == true ]]; then
        Exec WriteRoot
        Exec WriteNotRoot
    else
        Exec WriteNotRoot
    fi
}

Main() {
    Exec "cd ${scriptPath}"
    Exec CheckCurrentRoot
    Exec Write
}

Main "$@"
