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


# ===== 脚本函数区  =====
sysfirewall(){
while :
do
ch_status_fw=`systemctl status firewalld | grep "active (running)" | wc -l`
ch_status_se=`cat /etc/sysconfig/selinux | grep "SELINUX=enforcing" | wc -l`
ch_start_fw=`systemctl status firewalld | grep 'Loaded' | cut -d';' -f 2 | sed 's/ //g'`

if [ $ch_status_fw == 1 ];then
        status_fw="${greenbg} Running ${plain}"
else
        status_fw="${redbg} Stop ${plain}"
fi

if [ $ch_status_se == 1 ];then
        status_se="${greenbg} Running ${plain}"
else
        status_se="${redbg} Stop ${plain}"
fi

if [[ $ch_start_fw == "enabled" ]];then
        start_fw="${greenbg} 开机自启 ${plain}"
else
        start_fw="${redbg} 不启动 ${plain}"
fi

clear

echo -e "\n当前防火墙的状态为:     $status_fw  \n防火墙是否为开机自启动: $start_fw  \n当前Selinux的状态为:    $status_se "

read -p " 
1.开启防火墙
2.关闭防火墙
3.防火墙开机自启
4.防火墙开机不启动
5.开启Selinux
6.关闭Selinux

输入0退出脚本 : " selinuxnum
case $selinuxnum in
1)  systemctl start firewalld;;
2)  systemctl stop firewalld;;
3)  systemctl enable firewalld;;
4)  systemctl disable firewalld;;
5)  sed -i 's/SELINUX=disabled/SELINUX=enforcing/g' /etc/sysconfig/selinux && setenforce 1;;
6)  sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux && setenforce 0;;
0)  exit;;
*)  echo -e "${redbg} 无效值 ${plain}";;
esac
done
}

systemdate(){
    yum -y install ntpdate && timedatectl set-timezone 'Asia/Shanghai' && ntpdate ntp1.aliyun.com && echo '* 1 * * * root ntpdate ntp1.aliyun.com' >> /etc/crontab
}

# ===== 脚本函数区  =====


# ===== 脚本主界面 =====
menu(){
echo -e "
${greenbg}==================== Limit Systools V22.05.18 ====================${plain}

${green}1.${plain} Selinux与Firewalld (Centos7)

${green}0.${plain} 退出脚本输入0

${greenbg}==================== Limit Systools V22.05.18 ====================${plain}
"
}
menu
read -p "请输入选择 [1-10]:" num
case $num in
0)  exit;;
1)  sysfirewall;;
*)  echo -e "${red} 选择不存在，重新进入脚本  ${plain}" && bash <(curl -sL http://43.132.193.125:5550/https://raw.githubusercontent.com/limitrinno/shell/master/systools.sh);;
esac
# ===== 脚本主界面 =====
