#!/bin/bash

redisfile=`ls | grep 'redis' | wc -l`
redisdir=`ls /usr/local/ | grep "redis" | wc -l`

redisinstall(){
        yum -y install gcc make build-essential
        cd ~
        wget https://download.redis.io/releases/redis-6.2.6.tar.gz
        tar -zxvf redis-6.2.6.tar.gz
        yum -y install gcc make tcl*
        cd redis-6.2.6
        make
        mkdir -p /usr/local/redis
        make install PREFIX=/usr/local/redis
        cd /usr/local/redis/bin/
        echo "vm.overcommit_memory = 1" >> /etc/sysctl.conf && sysctl -p
        cp ~/redis-6.2.6/redis.conf /usr/local/redis/bin/
        sed -i 's/daemonize no/daemonize yes/' /usr/local/redis/bin/redis.conf
        cat >> /etc/systemd/system/redis.service << EOF
[Unit]
Description=redis-server
After=network.target
        
[Service]
Type=forking
ExecStart=/usr/local/redis/bin/redis-server /usr/local/redis/bin/redis.conf
PrivateTmp=true
        
[Install]
WantedBy=multi-user.target
EOF
        systemctl daemon-reload
        systemctl start redis.service
        systemctl enable redis.service
        cd ~ && rm -rf redis-6.2.6*
        /usr/local/redis/bin/redis-server /usr/local/redis/bin/redis.conf
        ps -aux | grep redis
        echo "Redis安装完成，自启动完成，程序已在后台运行！"
}

redisyouwenjian(){
        echo "redis文件存在请删除后进行操作!"
        read -p "输入0退出程序，输入1自动清理redis文件，并且再次运行，自动清理当前目录redis字样的文件，以及/usr/local/redis文件夹" redisnum1
        case $redisnum1 in
            1)  rm -rf redis* && rm -rf /usr/local/redis && bash <(curl -sL http://43.132.193.125:5550/https://raw.githubusercontent.com/limitrinno/shell/master/centos7_redis.sh);;
            0)  exit;;
            *)  exit;;
        esac
}


if [ $redisdir == 0 ];then
    echo "未扫描到安装了Redis,开始安装"
    if [ $redisfile == 0 ];then
        redisinstall
    else
        redisyouwenjian
    fi
else
    redisyouwenjian
fi

