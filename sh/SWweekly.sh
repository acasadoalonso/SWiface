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
echo "Sync GLIDERS table on databases"			     >>proc.log
cd    /nfs/OGN/DIRdata
echo ".dump GLIDERS" |        sqlite3 OGN.db >gliders.dmp
cd /nfs/OGN/SWdata
mv /nfs/OGN/DIRdata/gliders.dmp .
echo "drop table GLIDERS;" |  sqlite3 SWiface.db              >>proc.log 
sqlite3                               SWiface.db <gliders.dmp >>proc.log
echo "select count(*) from GLIDERS;" | sqlite3 SWiface.db     >>proc.log 
echo "vacuum;" |              sqlite3 SWiface.db              >>proc.log 
cd archive
echo "drop table GLIDERS;" | sqlite3 SWiface.db              >>../proc.log 
sqlite3                               SWiface.db <../gliders.dmp >>../proc.log
echo "vacuum;" |              sqlite3 SWiface.db              >>../proc.log 
date                                                          >>../proc.log
echo "========================================="	      >>../proc.log
cd ..
echo "drop table GLIDERS;" | mysql -u ogn -pogn -h $server SWIFACE                       >>proc.log 
python /nfs/OGN/src/sql* <gliders.dmp >gliders.sql
mysql                              -u ogn -pogn -h $server SWIFACE  <gliders.sql         >>proc.log
date                                                          >>proc.log
echo "========================================="	      >>proc.log
rm gliders.dmp gliders.sql
cd
