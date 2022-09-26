#! /bin/bash


# 设置带颜色的打印函数
SetPrinter(){
    SetRed="echo -en \e[91m"
    SetGreen="echo -en \e[32m"
    SetYellow="echo -en \e[33m"
    SetBlue="echo -en \e[36m"
    UnsetColor="echo -en \e[0m"
    Print(){
        echo -e "${1}"
    }
    PrintRed(){
        $SetRed
        echo -e "${1}"
        $UnsetColor
    }
    PrintYellow(){
        $SetYellow
        echo -e "${1}"
        $UnsetColor
    }
    PrintGreen(){
        $SetGreen
        echo -e "${1}"
        $UnsetColor
    }
    PrintBlue(){
        $SetBlue
        echo -e "${1}"
        $UnsetColor
    }
}
SetPrinter

Exec(){
    # 如果2号参数有值，那么命令执行失败会打印错误信息，并退出脚本
    if [ -z "${2}" ]; then
        unset assertFlag
    else
        assertFlag=true
    fi

    PrintBlue "[ GO ] ${1}"
    eval "${1}"
    res=$?
    if [ $res -eq 0 ]; then
        PrintGreen  "[ OK ] ${1}"
    else
        PrintRed "[ FAILED ] ${1}"
        # 当设置assertFlag变量时，才退出
        if [ -n "${assertFlag}" ]; then
            exit 2
        else
            return $res
        fi
    fi
}

Confirm(){
    while true; do
        read -p '(y/n)' confirm
        case "${confirm}" in
            [Yy])
                return 0
                ;;
            [Nn])
                return 1
                ;;
            *)
                ;;
        esac
    done
}

CreateDir(){
    if [ -f "${1}" ]; then
        PrintRed "${1} is a file!";
        PrintYellow "Delete ${1}?"
        Confirm
        if [ "${?}" -eq 0 ]; then
            Exec "rm -f ${1}"
        else
            return
        fi
    fi
    if [ ! -d "${1}" ]; then
        Exec "mkdir -p "${1}""
    fi
}