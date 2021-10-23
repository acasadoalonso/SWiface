#!/bin/sh
server='localhost'
if [ -z $CONFIGDIR ]
then 
     export CONFIGDIR=/etc/local/
fi
DBuser=$(echo    `grep '^DBuser '   $CONFIGDIR/SWSconfig.ini` | sed 's/=//g' | sed 's/^DBuser //g')
DBpasswd=$(echo  `grep '^DBpasswd ' $CONFIGDIR/SWSconfig.ini` | sed 's/=//g' | sed 's/^DBpasswd //g' | sed 's/ //g' )
DBpath=$(echo    `grep '^DBpath '   $CONFIGDIR/SWSconfig.ini` | sed 's/=//g' | sed 's/^DBpath //g' | sed 's/ //g' )

SCRIPT=$(readlink -f $0)
SCRIPTPATH=`dirname $SCRIPT`


cd $DBpath
echo "drop database SWiface;"                   | mysql -u $DBuser -p$DBpasswd -h $server 
echo "create database SWiface;"                 | mysql -u $DBuser -p$DBpasswd -h $server 
sqlite3 SWiface.db ".dump" |python3 ../src/sql* | mysql -u $DBuser -p$DBpasswd -h $server SWiface 
cd
