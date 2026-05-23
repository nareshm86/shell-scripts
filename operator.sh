#!/bin/bash

NUMBER=$1

if [ $NUMBER -gt 20 ]; then
    echo "Given number $NUMBER is greater to 20"
elif [ $NUMBER -eq 20 ]; then
    echo "Given number $NUMBER is equal to 20"
else
    echo "Given number $NUMBER is less than 20"
fi
