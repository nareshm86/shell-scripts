#!/bin/bash

# check the user before installing

USERID=$(id -u)

if [ $USERID -ne 0 ]; then
echo "run the script from root user"
exit 1
fi

dnf list installed mysql
if [ $? -eq 0 ]; then
   echo "mysql script already installed..skippig"
else
   echo "installing the mysql"
   dnf install mysql -y
 if [ $? -ne 0 ]; then
   echo "Installation is failed"
exit 1
 else
echo "mysql installation is successull"
 fi
fi



