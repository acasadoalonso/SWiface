#!/bin/sh
server='ubuntu'
cd /nfs/OGN/SWdata
echo "drop database SWiface;"                   | mysql --login-path=SARogn -h $server 
echo "create database SWiface;"                 | mysql --login-path=SARogn -h $server 
sqlite3 SWiface.db ".dump" |python3 ../src/sql* | mysql --login-path=SARogn -h $server SWiface 
cd
