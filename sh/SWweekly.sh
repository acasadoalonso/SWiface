#!/bin/bash
dir='/nfs/OGN/DIRdata'
server="casadonfs"
# test if directory is available
if [ ! -d $dir ]
then
	echo "---exiting---"
	exit 1
fi
cd /nfs/OGN/SWdata
echo "Sync GLIDERS table on databases"			     	>>SWproc.log
cd    /nfs/OGN/DIRdata
cp kglid.py ~/src/SWsrc
echo ".dump GLIDERS" |        sqlite3 OGN.db >gliders.dmp
cd /nfs/OGN/SWdata
mv /nfs/OGN/DIRdata/gliders.dmp .
echo "drop table GLIDERS;" |  sqlite3 SWiface.db              >>SWproc.log 
sqlite3                               SWiface.db <gliders.dmp >>SWproc.log
echo "select count(*) from GLIDERS;" | sqlite3 SWiface.db     >>SWproc.log 
echo "vacuum;" |              sqlite3 SWiface.db              >>SWproc.log 
cd archive
echo "drop table GLIDERS;" | sqlite3 SWiface.db              >>../SWproc.log 
sqlite3                               SWiface.db <../gliders.dmp >>../SWproc.log
echo "vacuum;" |              sqlite3 SWiface.db              >>../SWproc.log 
date                                                          >>../SWproc.log
echo "========================================="	      >>../SWproc.log
cd ..
echo "drop table GLIDERS;" | mysql -u ogn -pogn -h $server SWIFACE                       >>SWproc.log 
python /nfs/OGN/src/sql* <gliders.dmp >gliders.sql
mysql                              -u ogn -pogn -h $server SWIFACE  <gliders.sql         >>SWproc.log
date                                                          >>SWproc.log
echo "========================================="	      >>SWproc.log
rm gliders.dmp gliders.sql
cd
