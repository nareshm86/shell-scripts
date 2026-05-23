#!/bin/bash

NUMBER=$1

if [ $NUMBER -gt 10 ]; then
echo "The Given Number $NUMBER is greather than 10"
elif [$NUMBER -eq 10 ]; then
echo "The Given Number $NUMBER is equal to 10"
else 
echo "The Given Number $NUMBER is lessthan 10"
fi