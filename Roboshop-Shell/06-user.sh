#!/bin/bash
LOGS_FOLDER="/var/log/roboshop"
sudo mkdir -p $LOGS_FOLDER
sudo chown ec2-user:ec2-user $LOGS_FOLDER
sudo chmod 755 $LOGS_FOLDER
LOGS_FILE="$LOGS_FOLDER/$0.log"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
SCRIPT_DIR=$PWD

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

USERID=$(id -u)
if [ $USERID -ne 0 ]; then
echo -e "$TIMESTAMP [ERROR] $R Run the script from the root user $N" | tee -a $LOGS_FILE
exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$TIMESTAMP [ERROR] $2 $R Failed $N" | tee -a $LOGS_FILE 
        exit 1
        else
        echo -e "$TIMESTAMP [INFO] $2 $G Success $N" | tee -a $LOGS_FILE
    fi
}

dnf module disable nodejs -y &>> $LOGS_FILE
dnf module enable nodejs:20 -y &>> $LOGS_FILE
VALIDATE $? "enable nodejs:20 version"

dnf install nodejs -y &>> $LOGS_FILE
VALIDATE $? "installing nodejs"

id roboshop
if [ $? -ne 0 ]; then
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $LOGS_FILE
VALIDATE $? "adding system user"
else
echo -e "$TIMESTAMP [INFO] $G roboshop user already exist $N" | tee -a $LOGS_FILE
fi

rm -rf /app
VALIDATE $? "Removing existing code"

rm -rf /tmp/user.zip
VALIDATE $? "Removed user zip"


mkdir -p /app 
VALIDATE $? "Creating APP Directory"

curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip 
cd /app
unzip /tmp/user.zip &>> $LOGS_FILE
VALIDATE $? "downloading and extracting code"

npm install &>> $LOGS_FILE
VALIDATE $? "Install dependencies"

cp $SCRIPT_DIR/user.service /etc/systemd/system/user.service &>> $LOGS_FILE
VALIDATE $? "creating service file"

systemctl daemon-reload &>> $LOGS_FILE
systemctl enable user  &>> $LOGS_FILE
systemctl start user &>> $LOGS_FILE
VALIDATE $? "enabling and starting user service"