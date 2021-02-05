#!/bin/bash
echo "DROP TABLE GLIDERS" | mysql SWIFACE -h 172.17.0.2 -u root -pogn 
mysql SWIFACE -h 172.17.0.2 -u root -pogn </tmp/GLIDERS.sql
