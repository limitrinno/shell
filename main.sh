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
        echo -e "${greenbg} Centos 系统环境正常！即将进入脚本 ${plain}"
    else
        sudo yum -y install wget curl && clear && echo -e "${greenbg} Centos的Curl和Wget更新完成!!! ${plain}"
    fi
elif [ $get_chos2 == 1 ]; then
    if [ $get_curlwget == '2' ]; then
        echo -e "${greenbg} Ubuntu 系统环境正常！即将进入脚本 ${plain}"
    else
        sudo apt-get -y install wget curl && clear && echo -e "${greenbg} Ubuntu的Curl和Wget更新完成!!! ${plain}"
    fi
else
    clear && echo -e "${redbg} 目前脚本大部分只支持Centos7.x和少量支持Ubuntu20.04,其他系统不兼容！！！ ${plain}" && exit
fi

# ===== 系统依赖检测 =====

# 检测服务器配置
get_freq=`awk -F'[ :]' '/cpu MHz/ {print $4;exit}' /proc/cpuinfo`
get_cpucache=`awk -F: '/cache size/ {cache=$2} END {print cache}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//'`
get_tram=`LANG=C; free -mh | awk '/Mem/ {print $2}'`
get_uram=`LANG=C; free -mh | awk '/Mem/ {print $3}'`
get_swap=`LANG=C; free -mh | awk '/Swap/ {print $2}'`
get_uswap=`LANG=C; free -mh | awk '/Swap/ {print $3}'`
get_up=$( awk '{a=$1/86400;b=($1%86400)/3600;c=($1%3600)/60} {printf("%d days, %d hour %d min\n",a,b,c)}' /proc/uptime )
get_cpunumber=`cat /proc/cpuinfo| grep "physical id"| sort| uniq| wc -l`
get_cpucores=`cat /proc/cpuinfo| grep "cpu cores"| uniq | awk '{ print $4}'`
get_processor=`cat /proc/cpuinfo| grep "processor" | wc -l`
get_networkinfo=`ip addr | awk '{if($0 ~ /^[0-9]\:(.*)$/){print $2}}' | cut -d ":" -f 1 | awk '{print " | "$0}'`
get_networkipaddress=`ip addr | grep -E 'inet\b' | awk '{print $2}' | cut -d "/" -f 1 | awk '{print " | "$0}'`
get_docker=`rpm -qa | grep docker | wc -l`

get_opsy() {
    [ -f /etc/redhat-release ] && awk '{print $0}' /etc/redhat-release && return
    [ -f /etc/os-release ] && awk -F'[= "]' '/PRETTY_NAME/{print $3,$4,$5}' /etc/os-release && return
    [ -f /etc/lsb-release ] && awk -F'[="]+' '/DESCRIPTION/{print $2}' /etc/lsb-release && return
}

_exists() {
    local cmd="$1"
    if eval type type > /dev/null 2>&1; then
        eval type "$cmd" > /dev/null 2>&1
    elif command > /dev/null 2>&1; then
        command -v "$cmd" > /dev/null 2>&1
    else
        which "$cmd" > /dev/null 2>&1
    fi
    local rt=$?
    return ${rt}
}

check_virt(){
    _exists "dmesg" && virtualx="$(dmesg 2>/dev/null)"
    if _exists "dmidecode"; then
        sys_manu="$(dmidecode -s system-manufacturer 2>/dev/null)"
        sys_product="$(dmidecode -s system-product-name 2>/dev/null)"
        sys_ver="$(dmidecode -s system-version 2>/dev/null)"
    else
        sys_manu=""
        sys_product=""
        sys_ver=""
    fi
    if   grep -qa docker /proc/1/cgroup; then
        virt="Docker"
    elif grep -qa lxc /proc/1/cgroup; then
        virt="LXC"
    elif grep -qa container=lxc /proc/1/environ; then
        virt="LXC"
    elif [[ -f /proc/user_beancounters ]]; then
        virt="OpenVZ"
    elif [[ "${virtualx}" == *kvm-clock* ]]; then
        virt="KVM"
    elif [[ "${cname}" == *KVM* ]]; then
        virt="KVM"
    elif [[ "${cname}" == *QEMU* ]]; then
        virt="KVM"
    elif [[ "${virtualx}" == *"VMware Virtual Platform"* ]]; then
        virt="VMware"
    elif [[ "${virtualx}" == *"Parallels Software International"* ]]; then
        virt="Parallels"
    elif [[ "${virtualx}" == *VirtualBox* ]]; then
        virt="VirtualBox"
    elif [[ -e /proc/xen ]]; then
        virt="Xen"
    elif [[ "${sys_manu}" == *"Microsoft Corporation"* ]]; then
        if [[ "${sys_product}" == *"Virtual Machine"* ]]; then
            if [[ "${sys_ver}" == *"7.0"* || "${sys_ver}" == *"Hyper-V" ]]; then
                virt="Hyper-V"
            else
                virt="Microsoft Virtual Machine"
            fi
        fi
    else
        virt="Dedicated"
    fi
}

check_virt && clear

calc_disk() {
    local total_size=0
    local array=$@
    for size in ${array[@]}
    do
        [ "${size}" == "0" ] && size_t=0 || size_t=`echo ${size:0:${#size}-1}`
        [ "`echo ${size:(-1)}`" == "K" ] && size=0
        [ "`echo ${size:(-1)}`" == "M" ] && size=$( awk 'BEGIN{printf "%.1f", '$size_t' / 1024}' )
        [ "`echo ${size:(-1)}`" == "T" ] && size=$( awk 'BEGIN{printf "%.1f", '$size_t' * 1024}' )
        [ "`echo ${size:(-1)}`" == "G" ] && size=${size_t}
        total_size=$( awk 'BEGIN{printf "%.1f", '$total_size' + '$size'}' )
    done
    echo ${total_size}
}

disk_size1=($( LANG=C df -hPl | grep -wvE '\-|none|tmpfs|devtmpfs|by-uuid|chroot|Filesystem|udev|docker' | awk '{print $2}' ))
disk_size2=($( LANG=C df -hPl | grep -wvE '\-|none|tmpfs|devtmpfs|by-uuid|chroot|Filesystem|udev|docker' | awk '{print $3}' ))
disk_total_size=$( calc_disk "${disk_size1[@]}" )
disk_used_size=$( calc_disk "${disk_size2[@]}" )

ipv4_info() {
    local org="$(wget -q -T10 -O- ipinfo.io/org)"
    local city="$(wget -q -T10 -O- ipinfo.io/city)"
    local country="$(wget -q -T10 -O- ipinfo.io/country)"
    local region="$(wget -q -T10 -O- ipinfo.io/region)"
    [[ -n "$org" ]] && echo -ne " ${blue}Organization${plain}	: " && echo "$org"
    [[ -n "$city" && -n "country" ]] && echo -ne " ${blue}Location${plain}	:" && echo " $city $country"
    [[ -n "$region" ]] && echo -ne " ${blue}Region${plain}		:" && echo " $region"
}

get_sysinfo(){
echo -e "----------------------------------------------------------------------------"
echo -ne "${blue} OS Name ${plain}	:" && echo -ne " " && get_opsy
echo -ne "${blue} OS type ${plain}	:" && echo -ne " " && uname -o | awk '{ print $0 }'
echo -ne "${blue} OS Arch ${plain}	:" && echo -ne " " && uname -o | uname -m | awk '{ print $0 }'
echo -ne "${blue} OS Kernel ${plain}	:" && echo -ne " " && uname -r | awk '{ print $0 }'
echo -ne "${blue} OS uptime ${plain}	:" && echo -ne " " && echo "$get_up"
echo -ne "${blue} Hostname ${plain}	:" && echo -ne " " && hostname | awk '{ print $0 }'
echo -ne "${blue} CPU Model ${plain}	:" && cat /proc/cpuinfo | grep name | cut -f2 -d: | uniq -d
echo -ne "${blue} CPU Frequency ${plain}	:" && echo " $get_freq MHz"
echo -ne "${blue} CPU Cache ${plain}	:" && echo " $get_cpucache"
echo -ne "${blue} CPU Number ${plain}	:" && echo -e " $get_cpunumber vCPU"
echo -ne "${blue} CPU Cores ${plain}	:" && echo -e " $get_cpucores Cores"
echo -ne "${blue} CPU Processor ${plain}	:" && echo -e " $get_processor Processor"
echo -ne "${blue} Total Disk ${plain}	:" && echo -ne " " && echo "$disk_total_size GB ($disk_used_size GB Used)"
echo -ne "${blue} Total Memory ${plain}	:" && echo -ne " " && echo "$get_tram MB ($get_uram MB Used))"
echo -ne "${blue} Total Swap ${plain}	:" && echo -ne " " && echo "$get_swap MB ($get_uswap MB Used))"
echo -ne "${blue} Virtualization ${plain}:" && echo -ne " " && echo "$virt"
echo -ne "${blue} Product number ${plain}:" && echo -ne " " && sudo dmidecode -s system-product-name
echo -ne "${blue} Product Serial ${plain}:" && echo -ne " " && sudo dmidecode -s system-serial-number

echo -e "----------------------------------------------------------------------------"
ipv4_info
echo -ne "${blue} IP Address ${plain}	:" && echo -ne " " && curl -s cip.cc | grep IP | cut -f 2 -d :
echo -e "${blue}-------------------------------Memory Info----------------------------------${plain}"
sudo lshw -short -C memory | grep GiB
echo -e "${blue}------------------------------- Disk Info ----------------------------------${plain}"
sudo lshw -short -C disk
echo -e "${blue}------------------------------- Raid Info ----------------------------------${plain}"
sudo lspci -v | grep -i Infiniband
echo -e "${blue}--------------------------------- Network Card -----------------------------${plain}"
echo -ne "${blue} Network Card Information ${plain}" && echo -e " " && echo "$get_networkinfo"
echo -ne "${blue} Network Card IP Address ${plain}" && echo -e " " && echo "$get_networkipaddress"
echo -e "${blue}----------------------------------------------------------------------------${plain}"
}

# ===== 脚本主界面 =====
menu(){
echo -e "
${greenbg}==================== Limit Main V22.05.18 ====================${plain}

${green}1.${plain} 检查服务器系统配置
${green}2.${plain} Centos7 简单安装Docker
${green}3.${plain} 临时系统代理(当国内的网络无法到达时使用)
${green}5.${plain} 路由测试脚本-IPIPnet

${green}0.${plain} 退出脚本输入0

${greenbg}==================== Limit Main V22.05.18 ====================${plain}
"
}
menu
read -p "请输入选择 [1-10]:" num
case $num in
0)  exit;;
1)  get_sysinfo;;
*)  echo -e "${red} 选择不存在，重新进入脚本  ${plain}" && bash <(curl -sL http://43.132.193.125:5550/https://github.com/limitrinno/shell/blob/master/main.sh);;
esac
# ===== 脚本主界面 =====
