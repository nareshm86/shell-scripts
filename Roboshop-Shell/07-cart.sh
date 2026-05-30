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

if [ $USERID -ne 0 ]; then
echo -e "$TIMESTAMP [ERROR] $R RUN the script with ROOT user $N" | tee -a $LOGS_FILE
exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$TIMESTAMP [ERROR] $2 $R FAILED $N" | tee -a $LOGS_FILE
        exit 1
        else
        echo -e "$TIMESTAMP [INFO] $2 $G SUCCESS $N" | tee -a $LOGS_FILE
    fi
    }

dnf module disable nodejs -y &>> $LOGS_FILE
dnf module enable nodejs:20 -y &>> $LOGS_FILE
VALIDATE $? "Enable nodejs:20"

dnf install nodejs -y &>> $LOGS_FILE
VALIDATE $? "Intsalling nodejs"

id roboshop &>> $LOGS_FILE
if [ $? -ne 0 ]; then
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $LOGS_FILE
VALIDATE $? "creating roboshop user"
else
echo -e "$TIMESTAMP $G roboshop user already present $N" | tee -a $LOGS_FILE
fi


rm -rf app &>> $LOGS_FILE
VALIDATE $? "removing app directory"

rm -rf /tmp/cart.zip &>> $LOGS_FILE
VALIDATE $? "removing cart zipfile"

mkdir -p /app &>> $LOGS_FILE
VALIDATE $? "Creating app directory"

curl -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip &>> $LOGS_FILE
cd app &>> $LOGS_FILE
unzip /tmp/cart.zip &>> $LOGS_FILE
VALIDATE $? "Downloading and Extracting code"

npm install &>> $LOGS_FILE
VALIDATE $? "Install Dependencies"

cp $SCRIPT_DIR/cart.service /etc/systemd/system/cart.service &>> $LOGS_FILE
VALIDATE $? "created cart service file"

systemctl daemon-reload &>> $LOGS_FILE
systemctl enable cart  &>> $LOGS_FILE
systemctl start cart &>> $LOGS_FILE
VALIDATE $? "Enable and Start the cart service"


