#!/bin/bash 
echo "DROP DATABASE IF EXISTS SWIFACE "       | mysql  -h 172.17.0.2 -u root -pogn 
echo "CREATE DATABASE IF NOT EXISTS SWIFACE " | mysql  -h 172.17.0.2 -u root -pogn 
mysql SWIFACE -h 172.17.0.2 -u root -pogn </tmp/DBschema.sql
