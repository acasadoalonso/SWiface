#!/bin/bash
echo " "
server="mariadb"
hostname=$(hostname)
city=$1
if [ -z $CONFIGDIR ]
then 
     export CONFIGDIR=/etc/local/
fi
DBuser=$(echo    `grep '^DBuser '   $CONFIGDIR/SWSconfig.ini` | sed 's/=//g' | sed 's/^DBuser //g')
DBpasswd=$(echo  `grep '^DBpasswd ' $CONFIGDIR/SWSconfig.ini` | sed 's/=//g' | sed 's/^DBpasswd //g' | sed 's/ //g' )
DBpath=$(echo    `grep '^DBpath '   $CONFIGDIR/SWSconfig.ini` | sed 's/=//g' | sed 's/^DBpath //g' | sed 's/ //g' )
cd $DBpath
SCRIPT=$(readlink -f $0)
SCRIPTPATH=`dirname $SCRIPT`
echo "                   " 				>>SWproc.docker.log
echo "Process Mariadb DB." 				>>SWproc.docker.log
echo "==================." 				>>SWproc.docker.log
echo "                   " 				>>SWproc.docker.log
docker stop swiface 	 				>>SWproc.docker.log
mysqlcheck -u $DBuser -p$DBpasswd -h $server SWIFACE   	>>SWproc.docker.log
mysqlcheck -u $DBuser -p$DBpasswd -h $server SWARCHIVE 	>>SWproc.docker.log
echo "Set session      " 				>>SWproc.docker.log
echo "set session sql_mode='STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION'; "| mysql   -v -h $server -u $DBuser -p$DBpasswd SWIFACE	      >>SWproc.docker.log
echo "select 'Number of fixes: on the DB:', count(*) from OGNDATA; select station, 'Kms.max.:',max(distance),'        Flarmid :',idflarm, 'Date:',date, time, station from OGNDATA group by station; "  | mysql   -v -h $server -u $DBuser -p$DBpasswd SWIFACE	   >>SWproc.docker.log
echo "mysqldump       " 				>>SWproc.docker.log
mysqldump  -u $DBuser -p$DBpasswd --add-drop-table -h $server SWIFACE OGNDATA >ogndata.sql 
mysql      -u $DBuser -p$DBpasswd                  -h $server SWARCHIVE       <ogndata.sql 	>>SWproc.docker.log
echo "delete from OGNDATA   " 									>>SWproc.docker.log
echo "delete from OGNDATA;" | mysql -u $DBuser -p$DBpasswd     -v -h $server SWIFACE       	>>SWproc.docker.log
mv ogndata.sql archive
docker logs --timestamps --details --since $(date +%Y-%m-%d) swiface 				>>SWproc.docker.log
echo "End of processes  Mariadb DB at server: "$hostname $(date) $HOSTNAME $city		>>SWproc.docker.log
mv SWproc.docker.log archive/SWiproc.docker$(date +%y%m%d).log
cd
