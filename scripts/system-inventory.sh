#!/bin/bash

echo "===== SYSTEM INFORMATION ====="

echo "Hostname:"
hostname

echo "Operating System:"
cat /etc/os-release | grep PRETTY_NAME

echo "Kernel Version:"
uname -r

echo "IP Address:"
ip addr

echo "Disk Usage:"
df -h

echo "Memory Usage:"
free -h
