#!/bin/bash
LOG_FOLDER="/var/log/roboshop"
sudo mkdir -p $LOG_FOLDER
sudo chown -R ec2-user:ec2-user $LOG_FOLDER
sudo chmod -R 755 $LOG_FOLDER
LOG_FILE="$LOG_FOLDER/$0.log"

TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"


USERID=$(id -u)
if [ $USERID -ne 0 ]; then
 echo -e "$R run the script with root access $N"| tee  &>> $LOG_FILE
 exit 1
fi

VALIDATE()
{
if [$1 -ne 0 ]; then
 echo -e "$TIMESTAMP [ERROR] $2 ... $R FAILURE $N" | tee -a $LOGS_FILE
 exit 1
 else 
 echo "$TIMESTAMP [info] $2 ..$R SUCCESS $N" | tee -a $LOG_FILE
fi
}
cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Adding Mongo repo"

dnf install mongodb-org -y
VALIDATE $? "Installing MongoDB"

systemctl enable --now mongod
VALIDATE $? "Starting and enabling MongoDB"


sed -i s/127.0.0.0/0.0.0.0/g /etc/mongod.conf
VALIDATE $? "Allowing remote connections to mongodb"

systemctl restart mongod
VALIDATE $? "restarting mongodb"

