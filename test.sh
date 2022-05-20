#!/bin/bash

for ((i=1; i<=25; i++))
do
	echo "$i" >> /root/crontab.log
done

date >> /root/crontab.log
