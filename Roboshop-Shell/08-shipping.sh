#!/bin/bash
LOGS_FOLDER="/var/log/roboshop"
sudo mkdir -p "$LOGS_FOLDER"
sudo chown -R ec2-user:ec2-user "$LOGS_FOLDER"
sudo chmod -R 755 "$LOGS_FOLDER"
LOGS_FILE="$LOGS_FOLDER/$0.log"
SCRIPT_DIR=$PWD
MYSQL_HOST=mysql.nmarriaws.xyz

TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
SCRIPT_DIR=$PWD
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

USERID=$(id -u)
if [ $USERID -ne 0 ]; then
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

dnf install maven -y &>>$LOGS_FILE
VALIDATE $? "Installing maven" 


id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
VALIDATE $? "creating roboshop user"
else
echo -e "$TIMESTAMP $Y roboshop user already present $N" | tee -a $LOGS_FILE
fi

sudo rm -rf app &>>$LOGS_FILE
VALIDATE $? "remove app directory"

sudo rm -rf /tmp/shipping.zip &>>$LOGS_FILE
VALIDATE $? "remove shipping zip file"

mkdir -p /app &>>$LOGS_FILE
VALIDATE $? "creating app directory"

cd /app
curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>$LOGS_FILE
unzip /tmp/shipping.zip &>>$LOGS_FILE
VALIDATE $? "downloading and extracting code"

mvn clean package &>>$LOGS_FILE
mv target/shipping-1.0.jar shipping.jar &>>$LOGS_FILE
VALIDATE $? "Installing dependencie"

cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service
VALIDATE $? "creating shipping service file"

systemctl daemon-reload &>>$LOGS_FILE
VALIDATE $? "loading shipping service"

dnf install mysql -y &>>$LOGS_FILE
VALIDATE $? "installing mysql client"

mysql -h $MYSQL_HOST -u root -pRoboShop@1 -e "use cities" &>>$LOGS_FILE
if [ $? -ne 0 ]; then
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/schema.sql
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/app-user.sql
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/master-data.sql
    VALIDATE $? "Data loaded"
else
    echo -e "Data already loaded ... $Y SKIPPING $N"
fi

systemctl enable shipping 
systemctl restart shipping
VALIDATE $? "Enable and restarted shipping"