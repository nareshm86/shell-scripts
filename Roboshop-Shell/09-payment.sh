#!/bin/bash
LOGS_FOLDER="/var/log/roboshop"
sudo mkdir -p "$LOGS_FOLDER"
sudo chown -R ec2-user:ec2-user "$LOGS_FOLDER"
sudo chmod -R 755 "$LOGS_FOLDER"
LOGS_FILE="$LOGS_FOLDER/$0.log"
SCRIPT_DIR=$PWD

TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
SCRIPT_DIR=$PWD
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

USERID=$(id -u)
if [ "$USERID" -ne 0 ]; then
echo -e "$TIMESTAMP [INFO] $R Run the script with ROOT USER $N" | tee -a $LOGS_FILE
exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ]; then
    echo -e "$TIMESTAMP [ERROR] $2 $R FAILURE $N" | tee -a $LOGS_FILE
    exit 1
    else
    echo -e "$TIMESTAMP [INFO] $2 $G SUCCESS $N" | tee -a $LOGS_FILE
    fi
}

dnf install python3 gcc python3-devel -y &>>$LOGS_FILE
VALIDATE $? "Installing Python3" 


id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
VALIDATE $? "creating roboshop user"
else
echo -e "$TIMESTAMP $Y roboshop user already present $N" | tee -a $LOGS_FILE
fi

sudo rm -rf /app &>>$LOGS_FILE
VALIDATE $? "remove app directory"

sudo rm -rf /tmp/payment.zip &>>$LOGS_FILE
VALIDATE $? "remove payment zip file"

mkdir -p /app &>>$LOGS_FILE
VALIDATE $? "creating app directory"

cd /app
curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip  &>>$LOGS_FILE
unzip /tmp/payment.zip &>>$LOGS_FILE
VALIDATE $? "downloading and extracting code"

pip3 install -r requirements.txt &>>$LOGS_FILE
VALIDATE $? "Installing dependicies "

cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service
VALIDATE $? "creating payment service file"

systemctl daemon-reload &>>$LOGS_FILE
VALIDATE $? "loading payment service"


systemctl enable payment 
systemctl restart payment
VALIDATE $? "Enable and restarted payment"