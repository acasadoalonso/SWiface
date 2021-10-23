#!/bin/bash

if [ -z $CONFIGDIR ]
then 
     export CONFIGDIR=/etc/local/
fi
DBuser=$(echo    `grep '^DBuser '   $CONFIGDIR/SWSconfig.ini` | sed 's/=//g' | sed 's/^DBuser //g')
DBpasswd=$(echo  `grep '^DBpasswd ' $CONFIGDIR/SWSconfig.ini` | sed 's/=//g' | sed 's/^DBpasswd //g' | sed 's/ //g' )
DBpath=$(echo    `grep '^DBpath '   $CONFIGDIR/SWSconfig.ini` | sed 's/=//g' | sed 's/^DBpath //g' | sed 's/ //g' )

SCRIPT=$(readlink -f $0)
SCRIPTPATH=`dirname $SCRIPT`

echo "Create the MySQL OGN user "				#
echo "Type the PASSword for the MySQL database "	        #
echo "GRANT ALL PRIVILEGES ON *.* TO 'ogn'@'%' IDENTIFIED BY '$DBpasswd'; " | mysql -u root -p$1 -h mariadb    #
echo "GRANT SELECT ON *.* TO 'ognread'@'%'     IDENTIFIED BY '$DBpasswd'; " | mysql -u root -p$1 -h mariadb    #
echo " "							#
echo "Create the MySQL database SWIFACE "			#
echo "========================================================" #
echo "CREATE DATABASE SWIFACE" | mysql -h mariadb -u root -p$1	#
mysql -u root -p$1 -h mariadb --database SWIFACE <DBschema.sql	#
echo " "							#
