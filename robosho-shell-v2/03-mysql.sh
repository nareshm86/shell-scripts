#!/bin/bash

source ./common.sh

dnf install mysql-server -y &>> $LOGS_FILE
VALIDATE $? "installing mysql-server"

systemctl enable --now mysqld &>> $LOGS_FILE
VALIDATE $? "Enabling and Starting mysqld"

mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOGS_FILE
VALIDATE $? "Setting ROOT password"

print_total_time