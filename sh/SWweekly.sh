#!/bin/bash
if [ -z $CONFIGDIR ]
then 
     export CONFIGDIR=/etc/local/
fi
dir=$(echo    `grep '^DBpath '   $CONFIGDIR/SARconfig.ini` | sed 's/=//g' | sed 's/^DBpath //g' | sed 's/ //g' )
db=$DBpath'/SAROGN.db'
if [ ! -d $dir ]
then
	echo "---exiting---"
	exit 1
fi
MySQL='NO'
if [ $# -eq  0 ]; then
	server='localhost'
else
	server=$1
	MySQL='YES'
fi

# test if directory is available
DBuser=$(echo    `grep '^DBuser '   $CONFIGDIR/SWSconfig.ini` | sed 's/=//g' | sed 's/^DBuser //g')
DBpasswd=$(echo  `grep '^DBpasswd ' $CONFIGDIR/SWSconfig.ini` | sed 's/=//g' | sed 's/^DBpasswd //g' | sed 's/ //g' )
DBpath=$(echo    `grep '^DBpath '   $CONFIGDIR/SWSconfig.ini` | sed 's/=//g' | sed 's/^DBpath //g' | sed 's/ //g' )

SCRIPT=$(readlink -f $0)
SCRIPTPATH=`dirname $SCRIPT`

echo "Sync GLIDERS table on databases at server: "$(hostname)  	>>SWproc.log
cd    /nfs/OGN/DIRdata
if [ -f 'kglid.py' ]
then
	cp kglid.py $SCRIPTPATH/../
fi
cd $DBpath
if [ -f $db ]
then
	echo ".dump GLIDERS" |        sqlite3  $db >GLIDERS.dump
else
	wget repoogn.ddns.net:60080/files/GLIDERS.dump -o GLIDERS.out
	rm GLIDERS.out
fi
echo "drop table GLIDERS;" |  sqlite3 -echo SWiface.db              	>>SWproc.log 
sqlite3                                     SWiface.db <GLIDERS.dump 	>>SWproc.log
echo "select count(*) from GLIDERS;" | sqlite3 -echo SWiface.db     	>>SWproc.log 
echo "vacuum;" |              sqlite3 -echo SWiface.db              	>>SWproc.log 
cd archive
echo "drop table GLIDERS;" | sqlite3 -echo SWiface.db              	>>../SWproc.log 
sqlite3                                    SWiface.db <../GLIDERS.dump >>../SWproc.log
echo "vacuum;" |             sqlite3 -echo SWiface.db              	>>../SWproc.log 
date                                                          	>>../SWproc.log
echo "============= end SQLite3 ============================" 	>>../SWproc.log
cd ..
if [ $MySQL  == 'YES' ]
then

	echo "drop table GLIDERS;" | mysql -u $DBuser -p$DBpasswd -h $server SWIFACE       >>SWproc.log 
	python3 /nfs/OGN/src/SARsrc/sql* <GLIDERS.dump >gliders.sql
	mysql -u $DBuser -p$DBpasswd -h $server SWIFACE   <gliders.sql                     >>SWproc.log
	mysql -u $DBuser -p$DBpasswd -h $server -e "select count(*) from GLIDERS" SWIFACE  >>SWproc.log
	date                                                    >>SWproc.log
	rm gliders.sql
	echo "============= end MySQL ============================" 	>>SWproc.log
fi
echo "=============="$(hostname)"==========================="         	>>SWproc.log
rm GLIDERS.dump  
cd

