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
1)  bash <(curl -sL http://43.132.193.125:5550/https://raw.githubusercontent.com/limitrinno/shell/master/check_server_information.sh);;
*)  echo -e "${red} 选择不存在，重新进入脚本  ${plain}" && bash <(curl -sL http://43.132.193.125:5550/https://raw.githubusercontent.com/limitrinno/shell/master/main.sh);;
esac
# ===== 脚本主界面 =====
