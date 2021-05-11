#!/bin/sh
server='ubuntu'
if [ -z $CONFIGDIR ]
then 
     export CONFIGDIR=/etc/local/
fi
DBuser=$(echo    `grep '^DBuser '   $CONFIGDIR/APRSconfig.ini` | sed 's/=//g' | sed 's/^DBuser //g')
DBpasswd=$(echo  `grep '^DBpasswd ' $CONFIGDIR/APRSconfig.ini` | sed 's/=//g' | sed 's/^DBpasswd //g' | sed 's/ //g' )
DBpath=$(echo    `grep '^DBpath '   $CONFIGDIR/APRSconfig.ini` | sed 's/=//g' | sed 's/^DBpath //g' | sed 's/ //g' )

SCRIPT=$(readlink -f $0)
SCRIPTPATH=`dirname $SCRIPT`


cd $DBpath
echo "drop database SWiface;"                   | mysql --login-path=SARogn -h $server 
echo "create database SWiface;"                 | mysql --login-path=SARogn -h $server 
sqlite3 SWiface.db ".dump" |python3 ../src/sql* | mysql --login-path=SARogn -h $server SWiface 
cd
