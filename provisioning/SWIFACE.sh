#!/bin/bash 
echo "DROP DATABASE IF EXISTS SWIFACE "       | mysql  -h 172.17.0.2 -u root -p$(cat /tmp/.DBpasswd) 
echo "CREATE DATABASE IF NOT EXISTS SWIFACE " | mysql  -h 172.17.0.2 -u root -p$(cat /tmp/.DBpasswd) 
mysql SWIFACE -h 172.17.0.2 -u root -p$(cat /tmp/.DBpasswd) </tmp/SWIFACE.sql
