#!/bin/bash
app_name=catalogue
source ./common.sh

check_root
app_setup
nodejs_setup

cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGS_FILES
VALIDATE $? "adding mongo repo"

dnf install mongodb-mongosh -y &>> $LOGS_FILES
VALIDATE $? "Installing MongoDB client "

INDEX=$(mongosh --host mongodb.nmarriaws.xyz --eval 'db.getMongo().getDBNames().indexOf("catalogue")')

if [ $INDEX -lt 0 ]; then
    mongosh --host mongodb.nmarriaws.xyz </app/db/master-data.js &>>$LOGS_FILES
    VALIDATE $? "Load Products"
else
    echo -e "Products already loaded ... $Y SKIPPING $N"
fi

systemctl daemon-reload
systemctl enable catalogue
systemctl start catalogue
VALIDATE $? "Enable and Start the Catalogue Service"

print_total_time