#!/bin/sh
cd /nfs/OGN/SWdata
echo "drop database SWiface;"  | mysql -h ubuntu -u ogn -pogn 
echo "create database SWiface;"  | mysql -h ubuntu -u ogn -pogn 
sqlite3 SWiface.db ".dump" |python2 ../src/sql* | mysql -h ubuntu -u ogn -pogn SWiface 
cd
