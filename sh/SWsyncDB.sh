#!/bin/sh
cd /nfs/OGN/SWdata
echo "drop database SWiface;"                   | mysql --login-path=SARogn -h ubuntu 
echo "create database SWiface;"                 | mysql --login-path=SARogn -h ubuntu 
sqlite3 SWiface.db ".dump" |python2 ../src/sql* | mysql --login-path=SARogn -h ubuntu SWiface 
cd
