#!/bin/bash

# check the user before installing

if [id -eq 0] then
echo "Installing the mysql from root user"
else
echo "Login as root user"
fi