#!/bin/bash

ch_status_fw=`systemctl status firewalld | grep "active (running)" | wc -l`
ch_status_se=`cat /etc/sysconfig/selinux | grep "SELINUX=enforcing" | wc -l`
ch_start_fw=`systemctl status firewalld | grep 'Loaded' | cut -d';' -f 2 | sed 's/ //g'`

if [ $ch_status_fw == 1 ];then
	status_fw="Running"
else
	status_fw="Stop"
fi

if [ $ch_status_se == 1 ];then
	status_se="Running"
else
	status_se="Stop"
fi

if [ $ch_start_fw -eq "enabled" ];then
	start_fw="Yes"
else
	start_fw="No"
fi

while :
do
clear

echo -e "\n当前防火墙的状态为: $status_fw\n防火墙是否为开机自启动: $start_fw\n当前Selinux的状态为: $status_se"

read -p " 
1.开启防火墙
2.关闭防火墙
3.开启Selinux
4.关闭Selinux
5.防火墙开机自启
6.防火墙开机不启动

输入不是选项的值，即退出脚本" selinuxnum
case $selinuxnum in
1)  systemctl start firewalld;;
2)  systemctl stop firewalld;;
3)  sed -i 's/SELINUX=disabled/SELINUX=enforcing/g' /etc/sysconfig/selinux && setenforce 1;;
4)  sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux && setenforce 0;;
5)  systemctl enable firewalld;;
6)  systemctl disable firewalld;;
*)  clear && echo -e "${redbg} 脚本已退出 ${plain}" && exit;;
esac
done
