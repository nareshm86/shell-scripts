#!/bin/bash

app_name=payment
souce ./common.sh
check_root
app_setup
python_setup
systemd_setup
app_restart
print_total_time