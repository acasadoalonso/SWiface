!#/bin/bash
if [ -z $CONFIGDIR ]
then 
     export CONFIGDIR=/etc/local/
fi
DBuser=$(echo    `grep '^DBuser '   $CONFIGDIR/SWSconfig.ini` | sed 's/=//g' | sed 's/^DBuser //g')
DBpasswd=$(echo  `grep '^DBpasswd ' $CONFIGDIR/SWSconfig.ini` | sed 's/=//g' | sed 's/^DBpasswd //g' | sed 's/ //g' )
DBpath=$(echo    `grep '^DBpath '   $CONFIGDIR/SWSconfig.ini` | sed 's/=//g' | sed 's/^DBpath //g' | sed 's/ //g' )

SCRIPT=$(readlink -f $0)
SCRIPTPATH=`dirname $SCRIPT`

cho "Create the MySQL database SWIFACE "			#
echo "Type the PASSword for the MySQL database SWIFACE "	#
echo "========================================================" #
echo "CREATE DATABASE SWIFACE" | mysql -u root -p		#
mysql -u root -p --database SWIFACE < main/DBschema.sql		#
echo "Create the MySQL OGN user "				#
echo "GRANT ALL PRIVILEGES ON *.* TO 'ogn'@'localhost' IDENTIFIED BY '$DBpasswd'; " | mysql -u root -p     #
echo "GRANT SELECT ON *.* TO 'ognread'@'localhost'     IDENTIFIED BY '$DBpasswd'; " | mysql -u root -p     #
echo " "							#

