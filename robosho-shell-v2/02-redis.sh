#!/bin/bash
source ./common.sh
checK_root


dnf module disable redis -y &>> $LOGS_FILE
dnf module enable redis:7 -y &>> $LOGS_FILE
VALIDATE $? "Enable reids 7 Version"

dnf install redis -y &>> $LOGS_FILE
VALIDATE $? "installed redis:7"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf
VALIDATE $? "Allowing remoting connection to redis"

systemctl enable --now redis &>> $LOGS_FILE
VALIDATE $? "Enable and starting redis" 

print_total_time