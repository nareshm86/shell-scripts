#!/bin/bash

# check the user before installing
#!/bin/bash

USERID=$(id -u)
LOG_DIR=/var/log/shell-script
LOG_FILE="$LOG_DIR/$0.log"

# Check root access or not
if [ $USERID -ne 0 ]; then
    echo "Please run this script with root access" | tee -a $LOG_FILE
    exit 1
fi

# first arg -> what are you trying to install
# second arg -> exit code
VALIDATE(){
    if [ $2 -ne 0 ]; then
        echo "Installing $1 is ... FAILED" | tee -a $LOG_FILE
        exit 1
    else
        echo "Installing $1 is ... SUCCESS" | tee -a $LOG_FILE
    fi
}

# echo "I am continuing..."
dnf list installed mysql &>> $LOG_FILE

if [ $? -eq 0 ]; then
    echo "MySQL is already installed ... SKIPPING" | tee -a $LOG_FILE
else
    echo "Installing MySQL" | tee -a $LOG_FILE
    dnf install mysql -y & >> $LOG_FILE
    VALIDATE MySQL $?
fi

dnf list installed nginx & >> $LOG_FILE
if [ $? -eq 0 ]; then
    echo "nginx is already installed ... SKIPPING" | tee -a $LOG_FILE
else
    echo "Installing nginx" | tee -a $LOG_FILE
    dnf install nginx -y & >> $LOG_FILE
    VALIDATE nginx $?
fi


