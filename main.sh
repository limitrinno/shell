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

prometheus(){
    ch_prometheus=`ls /usr/local | grep 'prometheus' | wc -l`
    ch_prometheusenable=`ls /usr/lib/systemd/system | grep 'prometheus' | wc -l`
if [[ $ch_prometheus == '0' && $ch_prometheusenable == '0' ]];then
    cd ~ && yum -y install wget && wget  http://43.132.193.125:5550/https://github.com/prometheus/prometheus/releases/download/v2.34.0/prometheus-2.34.0.linux-amd64.tar.gz && tar -zxvf prometheus-2.34.0.linux-amd64.tar.gz && mv prometheus-2.34.0.linux-amd64 /usr/local/prometheus && rm -rf prometheus-2.34.0.linux-amd64.tar.gz
    cat >> /usr/lib/systemd/system/prometheus.service << EOF
[Unit]
Description=https://prometheus.io
[Service]
Restart=on-failure
ExecStart=/usr/local/prometheus/prometheus --config.file=/usr/local/prometheus/prometheus.yml
[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl restart prometheus.service && systemctl enable prometheus.service
else
    read -p "需要清理现存文件，默认删除/usr/local/prometheus*和/usr/lib/systemd/system/prometheus*和/root/下prometheus相关的文件，同意输入1，不同意输入0" prometheusnum
    case $prometheusnum in
    1)  rm -rf /usr/local/prometheus* && rm -rf /root/prometheus* && rm -rf /usr/lib/systemd/system/prometheus* && bash <(curl -sL http://43.132.193.125:5550/https://raw.githubusercontent.com/limitrinno/shell/master/systools.sh);;
    0)  exit;
    esac
fi
}

nodeexporter(){
    ch_node_exporter=`ls /usr/local | grep 'node_exporter' | wc -l`
    ch_node_exporter=`ls /usr/lib/systemd/system | grep 'node_exporter' | wc -l`
if [[ $ch_node_exporter == '0' && $ch_node_exporter == '0' ]];then
    cd ~ && yum -y install wget && wget http://43.132.193.125:5550/https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-amd64.tar.gz && tar -zxvf node_exporter-1.3.1.linux-amd64.tar.gz && mv node_exporter-1.3.1.linux-amd64 /usr/local/node_exporter && rm -rf node_exporter-1.3.1.linux-amd64.tar.gz
    cat >> /usr/lib/systemd/system/node_exporter.service << EOF
[Unit]
Description=node_export
Documentation=https://github.com/prometheus/node_exporter
After=network.target
[Service]
Type=simple
User=root
ExecStart=/usr/local/node_exporter/node_exporter --collector.disable-defaults --collector.cpu --collector.cpufreq --collector.diskstats --collector.meminfo --collector.netstat --collector.filesystem --collector.loadavg --collector.netdev --collector.time --collector.uname --collector.stat
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl restart node_exporter.service && systemctl enable node_exporter.service
else
    read -p "需要清理现存文件，默认删除/usr/local/node_exporter*和/usr/lib/systemd/system/node_exporter*和/root/下node_exporter相关的文件
    同意输入1，不同意输入0 : " nodeexporternum
    case $nodeexporternum in
    1)  rm -rf /usr/local/node_exporter* && rm -rf /root/node_exporter* && rm -rf /usr/lib/systemd/system/node_exporter* && bash <(curl -sL http://43.132.193.125:5550/https://raw.githubusercontent.com/limitrinno/shell/master/systools.sh);;
    0)  exit;
    esac
fi
}

pushgateway(){
    ch_pushgateway=`ls /usr/local | grep 'pushgateway' | wc -l`
    ch_pushgateway=`ls /usr/lib/systemd/system | grep 'pushgateway' | wc -l`
if [[ $ch_pushgateway == '0' && $ch_pushgateway == '0' ]];then
    cd ~ && yum -y install wget && wget http://43.132.193.125:5550/https://github.com/prometheus/pushgateway/releases/download/v1.4.2/pushgateway-1.4.2.linux-amd64.tar.gz && tar -zxvf pushgateway-1.4.2.linux-amd64.tar.gz && mv pushgateway-1.4.2.linux-amd64 /usr/local/pushgateway && mv pushgateway-1.4.2.linux-amd64.tar.gz /usr/local/pushgateway/ && rm -rf pushgateway-1.4.2.linux-amd64.tar.gz
    cat >> /usr/lib/systemd/system/pushgateway.service << EOF
[Unit]
Description=pushgateway
Documentation=https://github.com/prometheus/pushgateway
After=network.target
[Service]
Type=simple
User=root
ExecStart= /usr/local/pushgateway/pushgateway
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl restart pushgateway.service && systemctl enable pushgateway.service
else
    read -p "需要清理现存文件，默认删除/usr/local/pushgateway*和/usr/lib/systemd/system/pushgateway*和/root/下pushgateway相关的文件，同意输入1，不同意输入0" pushgatewaynum
    case $pushgatewaynum in
    1)  rm -rf /usr/local/pushgateway* && rm -rf /root/pushgateway* && rm -rf /usr/lib/systemd/system/pushgateway* && bash <(curl -sL http://43.132.193.125:5550/https://raw.githubusercontent.com/limitrinno/shell/master/systools.sh);;
    0)  exit;
    esac
fi
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

${green}21.${plain} 一键安装prometheus V2.34.0
${green}22.${plain} 一键安装nodeexporter V1.3.1
${green}23.${plain} 一键安装pushgateway V1.4.2

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
21)  prometheus;;
21)  nodeexporter;;
21)  pushgateway;;
*)  echo -e "${red} 选择不存在，重新进入脚本  ${plain}" && bash <(curl -sL http://43.132.193.125:5550/https://raw.githubusercontent.com/limitrinno/shell/master/main.sh);;
esac
# ===== 脚本主界面 =====
