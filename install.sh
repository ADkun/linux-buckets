#! /bin/bash

. ./common.sh
. ./config.sh

# 获取执行目录，脚本本身的目录
GetPath() {
    execPath=$(pwd) # 执行目录
    scriptPath=$(cd $(dirname "${0}"); pwd) # 脚本本身目录

    PrintBlue "Execute path: ${execPath}"
    PrintBlue "Script path: ${scriptPath}"
}
GetPath

GetPackageManagerType(){
    which apt > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        is_apt=true
    fi

    which yum > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        is_yum=true
    fi

    if [ ! ${is_apt} ]; then
        if [ ! ${is_yum} ]; then
            PrintRed "No apt or yum found"
            exit 1
        fi
    fi
}
GetPackageManagerType

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

InstallApt(){
    PrintGreen "Will try to install these softwares: ${soft_list_apt[@]}"

    for item in ${soft_list_apt[@]}; do
        Exec "sudo apt-get install -y ${item}"
    done
}

InstallYum(){
    PrintGreen "Will try to install these softwares: ${soft_list_yum[@]}"

    for item in ${soft_list_yum[@]}; do
        Exec "sudo yum install -y ${item}"
    done
}

UpgradePip(){
    Exec 'sudo pip3 install --upgrade pip'
}

InstallPip(){
    UpgradePip

    PrintGreen "Will try to install these softwares: ${soft_list_pip[@]}"

    for item in ${soft_list_pip[@]}; do
        Exec "sudo pip3 install ${item}"
    done
}


InstallSoft(){
    if [[ ${is_apt} == true ]]; then
        InstallApt
    elif [[ ${is_yum} == true ]]; then
        InstallYum
    fi

    Exec InstallPip
}

ConfigureRanger(){
    if [ ! -d '~/.config' ]; then
        mkdir ~/.config > /dev/null 2>&1
    fi
    Exec 'sudo cp -rf ./ranger ~/.config'
}

ConfigureTldr(){
    if [ ! -d '~/.tldr' ]; then
        mkdir ~/.tldr > /dev/null 2>&1
    fi
    Exec 'sudo cp -rf ./tldr ~/.tldr/'
}

ConfigureVim(){
    Exec 'sudo find spf13 -name ".*" | while read -r line; do sudo cp -rf $line ~/; done'
    Exec 'sudo cp -rf ./spf13/etc/vim /etc/'
}

ConfigureOhMyZsh(){
    Exec 'sudo cp -rf ./.oh-my-zsh ~/'
    Exec 'bash ~/.oh-my-zsh/tools/install.sh'

}

ConfigureFzfArm(){
    Exec 'sudo cp -rf ./fzf/.fzf* ~/'
    Exec 'sudo cp -rf ./fzf/arm64/* /usr/local/bin/'
    Exec 'sudo chmod u+x /usr/local/bin/fzf*'
    echo "[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh" | sudo tee -a ~/.zshrc 1>/dev/null
}

ConfigureFzfX64(){
    Exec 'sudo cp -rf ./fzf/.fzf* ~/'
    Exec 'sudo cp -rf ./fzf/linux-x86_64/* /usr/local/bin/'
    echo "[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh" | sudo tee -a ~/.zshrc 1>/dev/null
}

ConfigureFzf(){
    if [[ ${is_x64} == true ]]; then
        ConfigureFzfX64
    elif [[ ${is_arm} == true ]]; then
        ConfigureFzfArm
    fi

    if [ ! -d ~/.fzf ]; then
        mkdir -p ~/.fzf > /dev/null 2>&1
    fi

    Exec 'sudo cp -rf ./fzf/shell ~/.fzf/'
}

ConfigureTmux(){
    Exec 'sudo cp -f ./tmux/tmux_fzf.conf ~/.tmux.conf'
    Exec 'sudo mkdir -p ~/.config/tmux/'
    Exec 'sudo cp -f ./tmux/fzf_panes.tmux ~/.config/tmux/'
}

InstallZoxide(){
    if [[ ${is_arm} == true ]]; then
        Exec 'sudo cp -rf ./zoxide/aarch64/* /usr/local/bin/'
    elif [[ ${is_x64} == true ]]; then
        Exec 'sudo cp -rf ./zoxide/x64/* /usr/local/bin/'
    fi

    Exec 'sudo chmod u+x /usr/local/bin/zoxide'
}

ConfigureZoxide(){
    Exec InstallZoxide
    Exec 'echo "" >> ~/.zshrc'
    echo "eval \"\$(zoxide init zsh)\"" >> ~/.zshrc
}

InstallLazygit(){
    if [[ ${is_arm} == true ]]; then
        Exec ' sudo cp -rf ./lazygit/aarch64/* /usr/local/bin/'
    elif [[ ${is_x64} == true ]]; then
        Exec ' sudo cp -rf ./lazygit/x64/* /usr/local/bin/'
    fi
    Exec 'sudo chmod u+x /usr/local/bin/lazygit'
}

ConfigureLazygit(){
    Exec InstallLazygit
}

InstallMonit(){
    Exec "${scriptPath}/monit/install.sh"
}

ConfigureMonit(){
    Exec InstallMonit
}

Configure(){
    Exec "cd ${scriptPath}"
    Exec ConfigureRanger
    Exec ConfigureTldr
    Exec ConfigureVim
    Exec ConfigureOhMyZsh
    Exec ConfigureFzf
    Exec ConfigureTmux
    Exec ConfigureZoxide
    Exec ConfigureLazygit
    Exec ConfigureMonit
}

Note(){
    PrintBlue "[ Note ] If you want to use autocompletion in vim for c++."
    PrintGreen "[ Solution ] Please install clangd manully."
    PrintBlue "[ Note ] If your vim or tmux version is too low, the configuration file may cause error."
    PrintGreen "[ Solution 1 ] Manually update vim or tmux."
    PrintGreen "[ Solution 2 ] Delete these lines that cause errors."
}

Main(){
    PrintBlue "Do you want to install softwares from apt/yum and pip?"
    Confirm
    if [ $? -eq 0 ]; then
        Exec InstallSoft
    fi

    PrintBlue "Do you want to do configuration and install local softwares?"
    Confirm
    if [ $? -eq 0 ]; then
        Exec Configure
    fi

    PrintBlue "Do you want to configurate bash?"
    Confirm
    if [ $? -eq 0 ]; then
        Exec "bash -c ./linux-configure/install.sh"
    fi

    Note
}
Main "$@"
