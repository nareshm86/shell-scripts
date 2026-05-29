#!/bin/bash
LOGS_FOLDER="/var/log/roboshop"
sudo mkdir -p $LOGS_FOLDER
sudo chown -R ec2-user:ec2-user $LOGS_FOLDER
sudo chmod -R 755 $LOGS_FOLDER
LOGS_FILES="$LOGS_FOLDER/$0.log"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
USERID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $USERID -ne 0 ]; then
echo -e "$TIMESTAMP [ERROR] $R RUn the script with root user $N" | tee -a $LOGS_FILE
exit 1
if

VALIDATE(){
if [ $1 -ne 0 ]; then
echo -e "$TIMESTAMP [ERROR] $2 $R FAILED $N" | tee -a $LOGS_FILE
exit 1
else 
echo -e "$TIMESTAMP [INFO] $2 $G SUCCESS $N" | tee -a $LOGS_FILE
fi
}

dnf module disable nodejs -y &>> $LOGS_FILE
VALIDATE $? "disable nodejs"

dnf module enable nodejs:20 -y &>> $LOGS_FILE
VALIDATE $? "enable nodejs"

dnf install nodejs -y &>> $LOGS_FILE
VALIDATE $? "Install nodejs"

id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
    VALIDATE $? "Creating roboshop system user"
else
    echo -e "System user roboshop already created ... $Y SKIPPING $N"
fi

rm -rf /app
VALIDATE $? "Removing existing code"

rm -rf /tmp/catalogue.zip
VALIDATE $? "Removed catalogue zip"

mkdir -p /app &>>$LOGS_FILE
VALIDATE $? "Creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip
cd /app 
unzip /tmp/catalogue.zip

VALIADATE $? "Downloading,Extracting and unziping catalogue service"

cd /app 
npm install
VALIADATE $? "Install dependencies"

cp catalogue.service /etc/systemd/system/catalogue.service


cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGS_FILE
VALIDATE $? "adding mongo repo"

dnf install mongodb-mongosh -y &>> $LOGS_FILE
VALIDATE $? "Installing MongoDB client "


INDEX=$(mongosh --host mongodb.nmarriaws.xyz --eval 'db.getMongo().getDBNames().indexOf("catalogue")')

if [ $INDEX -lt 0 ]; then
    mongosh --host mongodb.nmarriaws.xyz </app/db/master-data.js &>>$LOGS_FILE
    VALIDATE $? "Load Products"
else
    echo -e "Products already loaded ... $Y SKIPPING $N"
fi

systemctl daemon-reload
systemctl enable catalogue 
systemctl start catalogue
VALIDATE $? "Enable & Start the Catalogue Service"

