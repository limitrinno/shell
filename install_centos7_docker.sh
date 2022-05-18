#!/bin/bash

if [ $get_docker -ne 0 ]; then
    echo -e "${green} Docker 已安装！ ${plain}"
else
    yum install -y yum-utils device-mapper-persistent-data lvm2
    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    yum install docker-ce docker-ce-cli containerd.io -y
    systemctl enable docker
    systemctl restart docker
    echo -e "${green} Docker 安装完成 ${plain}"
fi
