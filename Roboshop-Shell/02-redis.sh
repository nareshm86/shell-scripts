#!/bin/bash
LOGS_FOLDER="/var/log/Roboshop"
sudo mkdir -p $LOGS_FOLDER
sudo chmod -R 755 $LOGS_FOLDER
sudo chown -R ec2-user:ec2-user $LOGS_FOLDER
LOGS_FILE="$LOGS_FOLDER/$0.log"

TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

USERID=$(id -u)

if [ $USERID -ne 0 ]; then
    echo -e "$TIMESTAMP [ERROR] Run the script with root user $N" | tee -a $LOGS_FILE
    exit 1
fi

VALIDATE(){
if [ $1 -ne 0 ]; then
echo -e "$TIMESTAMP [ERROR] $R $2 failed $N" | tee -a $LOGS_FILE
else
echo -e "$TIMESTAMP [INFO] $R $2 success $N" | tee -a $LOGS_FILE
fi
}

dnf module disable redis -y &>> $LOGS_FILE
dnf module enable redis:7 -y &>> $LOGS_FILE
VALIDATE $? "Enable reids 7 Version"

dnf install redis -y &>> $LOGS_FILE
VALIDATE $? "installed redis:7"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf
VALIDATE $? "Allowing remoting connection to redis"

systemctl enable --now redis &>> $LOGS_FILE
VALIDATE $? "Enable and starting redis" 

