#!/bin/bash
LOGS_FOLDER="/var/log/roboshop"
sudo mkdir -p $LOGS_FOLDER
sudo chmod -R 755 $LOGS_FOLDER
sudo chown -R ec2-user:ec2-user $LOGS_FOLDER
LOGS_FILE="$LOGS_FOLDER/$0.log"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0"

USERID=$(id -u)

if [ $USERID -ne 0 ]; then
    echo -e "$TIMESTAMP [ERROR] $R Please run script with root user $N" | tee -a $LOGS_FILE
    exit 1
fi

VALIDATE(){
if [ $1 - ne 0 ]; then
    echo -e "$TIMESTAMP [ERROR] $2 $R Failed $N" | tee -a $LOGS_FILE
    exit 1
else
    echo "$TIMESTAMP [INFO] $2 $G Success $N" | tee -a $LOGS_FILE
fi
}


cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGS_FILE
VALIDATE $? "Adding mongo repo"

dnf install mongodb-org -y &>> $LOGS_FILE
VALIDATE $? "Installing mongodb"

systemctl enable --now mongod &>> $LOGS_FILE
VALIDATE $? "Enabling & starting Mongod"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $LOGS_FILE
VALIDATE $? "Allowing the remote connection to Mongodb"

systemctl restart mongod &>> $LOGS_FILE
VALIDATE $? "restarting mongod" 
