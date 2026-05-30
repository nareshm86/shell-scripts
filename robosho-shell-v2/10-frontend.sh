#!/bin/bash
LOGS_FOLDER="/var/log/roboshop"
sudo mkdir -p "$LOGS_FOLDER"
sudo chown -R ec2-user:ec2-user "$LOGS_FOLDER"
sudo chmod -R 755 "$LOGS_FOLDER"
LOGS_FILE="$LOGS_FOLDER/$0.log"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
SCRIPT_DIR=$PWD
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

USERID=$(id -u)
if [ "$USERID" -ne 0 ]; then
echo -e "$TIMESTAMP [ERROR] $R RUN the script with ROOT user $N"
exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$TIMESTAMP [ERROR] $2 $R FAILURE $N"
        exit 1
        else
        echo -e "$TIMESTAMP [INFO] $2 $G SUCCESS $N"
    fi
}

dnf module disable nginx -y &>> $LOGS_FILE
dnf module enable nginx:1.24 -y &>> $LOGS_FILE
dnf install nginx -y &>> $LOGS_FILE
VALIDATE $? "Installing nginx"

systemctl enable --now nginx &>> $LOGS_FILE
VALIDATE $? "Enable and Starting nginx service"

sudo rm -rf /usr/share/nginx/html/* &>> $LOGS_FILE
VALIDATE $? "removed default code"

sudo rm -rf /tmp/frontend.zip &>> $LOGS_FILE
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>> $LOGS_FILE
cd /usr/share/nginx/html  &>> $LOGS_FILE
unzip /tmp/frontend.zip &>> $LOGS_FILE
VALIDATE $? "downloading and extracting enginx code"

rm -rf /etc/nginx/nginx.conf
VALIDATE $? "Removed Default conf"

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf
VALIDATE $? "creating nginx service file"

systemctl restart nginx
VALIDATE $? "Restarting nginx"

