#!/bin/bash

# check the user before installing
#!/bin/bash

USERID=$(id -u)

# Check root access or not
if [ $USERID -ne 0 ]; then
    echo "Please run this script with root access"
    exit 1
fi

# first arg -> what are you trying to install
# second arg -> exit code
VALIDATE(){
    if [ $2 -ne 0 ]; then
        echo "Installing $1 is ... FAILED"
        exit 1
    else
        echo "Installing $1 is ... SUCCESS"
    fi
}

# echo "I am continuing..."
dnf list installed mysql

if [ $? -eq 0 ]; then
    echo "MySQL is already installed ... SKIPPING"
else
    echo "Installing MySQL"
    dnf install mysql -y
    VALIDATE MySQL $?
fi

dnf list installed nginx
if [ $? -eq 0 ]; then
    echo "nginx is already installed ... SKIPPING"
else
    echo "Installing nginx"
    dnf install nginx -y
    VALIDATE nginx $?
fi


