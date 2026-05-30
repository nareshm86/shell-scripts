#!/bin/bash
app_name=user
source ./common.sh
check_root
nodejs_setup
app_setup
systemd_setup
app_restart
print_total_time