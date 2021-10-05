#!/bin/bash
echo "DROP TABLE GLIDERS" | mysql SWIFACE -h 172.17.0.2 -u root -p$(cat /tmp/.DBpasswd) 
mysql SWIFACE -h 172.17.0.2 -u root -p$(cat /tmp/.DBpasswd) </tmp/GLIDERS.sql
