#!/bin/bash
### Special variables ####
echo "All variables passed to the script: $@"
echo "Number of variable passed: $#"
echo "First Variable: $1
echo "script name: $0
echo "who is running the user: $USER"
echo "What is working directory: $PWD"
echo "PID of the current script: $$"
sleep 5 &
echo "PID of the background command running just now: $!"