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
centos_install_docker(){
# 检查机器是否存在Docker
ls /bin/docker > /dev/null 2>&1
if [ $? -ne 0 ]; then
	echo -e "${red} 检查到机器没有安装,准备开始下载 ${plain}" && sleep 2
	yum install -y yum-utils device-mapper-persistent-data lvm2
        yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
        yum install docker-ce docker-ce-cli containerd.io -y
        systemctl enable docker
        systemctl restart docker
        echo -e "${green} Docker 安装完成 ${plain}"
else
	echo -e "${greenbg} 该机器已经安装了Docker ${plain}"
fi
}

# IPIPNeT 路由追踪
ipiptracert1(){
read -p "
    输入 1 选择官方源
    
    输入 2 选择Limit备份源 ：" tracertipip
case $tracertipip in
	1)  sudo mkdir -p /mnt/ipipnet && cd /mnt/ipipnet && sudo wget https://cdn.ipip.net/17mon/besttrace4linux.zip && unzip besttrace4linux.zip && sudo chmod +x /mnt/ipipnet/besttrace4linux/besttrace;;
	2)  sudo mkdir -p /mnt/ipipnet && cd /mnt/ipipnet && sudo wget wget http://43.132.193.125:5550/https://github.com/limitrinno/shell/blob/master/soft/besttrace4linux.zip
unzip besttrace4linux.zip
sudo chmod +x /mnt/ipipnet/besttrace4linux/besttrace;;
	*)  clear && echo -e "${redbg} 有内鬼终止交易！！！ ${plain}" && exit;;
esac
}
ipiptracert(){
    get_trac1=`ls /mnt/ipipnet/besttrace4linux | wc -l`
    yum -y install unzip && sudo apt install unzip
    clear
    
    if [ -d "/mnt/ipipnet/besttrace4linux" ];then
        if [ $get_trac1 == 2 ]; then
            echo "校验正确！继续运行！"
        else
	    rm -rf /mnt/ipipnet/*
            ipiptracert1
        fi
    else
	rm -rf /mnt/ipipnet/*
        ipiptracert1
    fi
    
    read -p "请输入需要进行路由测试的IP (默认:43.132.193.125)：" tracip
    tracip=${tracip:-43.132.193.125}
    sudo /mnt/ipipnet/besttrace4linux/besttrace -q 1 $tracip
}

# 临时系统代理
tempproxy(){
    echo "正在配置"
    read -p "请输入的局域网IP:(默认IP为:120.79.15.130)" ip
    ip=${ip:-120.79.15.130}
    read -p "请输入Socks5的端口:(默认端口为10808)" sport
    sport=${sport:-10808}
    read -p "请输入Http的端口:(默认端口为10809)" hport
    hport=${hport:-10809}
    #if [ -f ~/tempproxy.sh ]; then
    #    echo -e "${redbg} tempproxy.sh 文件存在自动删除 ${plain}" && rm -rf tempproxy.sh
    #else
    #    echo -e "${greenbg} 无内鬼，正常交易！ ${plain}"
    #fi
    #touch ~/tempproxy.sh && chmod o+x tempproxy.sh
    #echo "export ALL_PROXY=socks5://$ip:$sport" >> /root/tempproxy.sh && echo "export http_proxy="http://$ip:$hport"" >> /root/tempproxy.sh && echo "export https_proxy="https://$ip:$hport"" >> /root/tempproxy.sh
    echo -e "${greenbg} 临时代理的服务器IP为:$ip , socsk端口为:$sport , http/https端口为:$hport ${plain}"
    echo -e "${redbg} 手动执行更新系统代理 :  ${plain}"
    echo -e "${greenbg}export ALL_PROXY=socks5://$ip:$sport${plain}"
    echo -e "${greenbg}export http_proxy="http://$ip:$hport"${plain}"
    echo -e "${greenbg}export https_proxy="https://$ip:$hport"${plain}"
    echo -e "${redbg} 退出CLI界面或者exit到登录界面，自动失效，重新登录需要重新更新代理 ${plain}"
}

# ===== 脚本函数区  =====


# ===== 脚本主界面 =====
menu(){
echo -e "
${greenbg}==================== Limit Main V22.05.18 ====================${plain}

${green}1.${plain} 检查服务器系统配置
${green}2.${plain} Centos7 安装Docker
${green}3.${plain} Centos7 路由追踪中文版
${green}4.${plain} Linux 系统临时代理


${green}10.${plain} Linux系统工具箱

${green}0.${plain} 退出脚本输入0

${greenbg}==================== Limit Main V22.05.18 ====================${plain}
"
}
menu
read -p "请输入选择 [1-10]:" num
case $num in
0)  exit;;
1)  bash <(curl -sL http://43.132.193.125:5550/https://raw.githubusercontent.com/limitrinno/shell/master/check_server_information.sh);;
2)  centos_install_docker;;
3)  ipiptracert;;
4)  tempproxy;;
10)  bash <(curl -sL http://43.132.193.125:5550/https://raw.githubusercontent.com/limitrinno/shell/master/systools.sh);;
*)  echo -e "${red} 选择不存在，重新进入脚本  ${plain}" && bash <(curl -sL http://43.132.193.125:5550/https://raw.githubusercontent.com/limitrinno/shell/master/main.sh);;
esac
# ===== 脚本主界面 =====
