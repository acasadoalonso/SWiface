#!/bin/bash
dir='/nfs/OGN/DIRdata'
db='/nfs/OGN/DIRdata/SAROGN.db'
MySQL='YES'
server="localhost"
# test if directory is available
if [ ! -d $dir ]
then
	echo "---exiting---"
	exit 1
fi
cd /nfs/OGN/SWdata
echo "Sync GLIDERS table on databases"			    	>>SWproc.log
cd    /nfs/OGN/DIRdata
if [ -f 'kglid.py' ]
then
	cp kglid.py ~/src/SWsrc
fi
cd /nfs/OGN/SWdata
if [ -f $db ]
then
	echo ".dump GLIDERS" |        sqlite3 $db >GLIDERS.dump
else
	wget repoogn.ddns.net:60080/files/GLIDERS.dump -o GLIDERS.out
fi
echo "drop table GLIDERS;" |  sqlite3 SWiface.db              	>>SWproc.log 
sqlite3                               SWiface.db <GLIDERS.dump 	>>SWproc.log
echo "select count(*) from GLIDERS;" | sqlite3 SWiface.db     	>>SWproc.log 
echo "vacuum;" |              sqlite3 SWiface.db              	>>SWproc.log 
cd archive
echo "drop table GLIDERS;" | sqlite3 SWiface.db              	>>../SWproc.log 
sqlite3                               SWiface.db <../GLIDERS.dump >>../SWproc.log
echo "vacuum;" |              sqlite3 SWiface.db              	>>../SWproc.log 
date                                                          	>>../SWproc.log
echo "============= end SQLite3 ============================" 	>>../SWproc.log
cd ..
if [ $MySQL  == 'YES' ]
then

	echo "drop table GLIDERS;" | mysql --login-path=SARogn -h $server SWIFACE                       >>SWproc.log 
	python3 /nfs/OGN/src/SARsrc/sql* <GLIDERS.dump >gliders.sql
	mysql --login-path=SARogn -h $server SWIFACE  <gliders.sql                      >>SWproc.log
	mysql --login-path=SARogn -h $server -e "select count(*) from GLIDERS" SWIFACE  >>SWproc.log
	date                                                    >>SWproc.log
	rm gliders.sql
	echo "============= end MySQL ============================" 	>>SWproc.log
fi
echo "========================================="         	>>SWproc.log
rm GLIDERS.dump  GLIDERS.out
cd

