#!/bin/bash
# Limitrinno Main Create V2022.05.18

# ===== 颜色控制区 =====
red='\033[0;31m'
redbg='\033[41m'
green='\033[0;32m'
greenbg='\033[42m'
yellow='\033[0;33m'
blue='\033[34m'
plain='\033[0m'
# ===== 颜色控制区 =====

# ===== 系统依赖检测 =====


# clear && echo -e "${greenbg} 正在检测系统依赖环境中,请稍后！！！ ${plain}"

# get_chos1=`cat /etc/os-release | grep PRETTY_NAME | grep CentOS | wc -l`
# get_chos2=`cat /etc/os-release | grep PRETTY_NAME | grep Ubuntu | wc -l`

# if [ $get_chos1 == 1 ]; then
#     sudo yum -y install wget >/dev/null 2>&1 && sudo yum -y install curl >/dev/null 2>&1
# elif [ $get_chos2 == 1 ]; then
#     sudo apt-get -y install wget >/dev/null 2>&1 && sudo apt-get -y install curl >/dev/null 2>&1
# else
#     clear && echo -e "${redbg} 目前脚本只支持Centos和Ubuntu ${plain}" && exit
# fi

clear && echo -e "${greenbg} 正在检测系统依赖环境中,请稍后！！！ ${plain}"

get_chos1=`cat /etc/os-release | grep PRETTY_NAME | grep CentOS | wc -l`
get_chos2=`cat /etc/os-release | grep PRETTY_NAME | grep Ubuntu | wc -l`
get_curlwget=`ls /usr/bin | grep -E "^curl|^wget" | wc -l`

if [ $get_chos1 == 1 ]; then
    if [ $get_curlwget == '2' ]; then
        echo -e "${greenbg} Centos 系统环境正常！ ${plain}"
    else
        sudo yum -y install wget curl && clear && echo -e "${greenbg} Centos的Curl和Wget更新完成!!! ${plain}"
    fi
elif [ $get_chos2 == 1 ]; then
    if [ $get_curlwget == '2' ]; then
        echo -e "${greenbg} Ubuntu 系统环境正常！ ${plain}"
    else
        sudo apt-get -y install wget curl && clear
    fi
else
    clear && echo -e "${redbg} 目前脚本大部分只支持Centos7.x和少量支持Ubuntu20.04,其他系统不兼容！！！ ${plain}" && exit
fi

# ===== 系统依赖检测 =====
