#!/bin/bash
dir='/nfs/OGN/DIRdata'
# test if directory is available
if [ ! -d $dir ]
then
	exit 1
fi
cd /nfs/OGN/SWdata
echo "Sync GLIDERS table on databases"			     >>proc.log
cd    /nfs/OGN/DIRdata
echo ".dump GLIDERS" |        sqlite3 OGN.db >gliders.dmp
cd /nfs/OGN/SWdata
mv /nfs/OGN/DIRdata/gliders.dmp .
echo "drop table GLIDERS;" | sqlite3 SWiface.db              >>proc.log 
sqlite3                               SWiface.db <gliders.dmp >>proc.log
echo "vacuum;" |              sqlite3 SWiface.db              >>proc.log 
cd archive
echo "drop table GLIDERS;" | sqlite3 SWiface.db              >>../proc.log 
sqlite3                               SWiface.db <../gliders.dmp >>../proc.log
echo "vacuum;" |              sqlite3 SWiface.db              >>../proc.log 
date                                                          >>../proc.log
echo "========================================="	      >>../proc.log
rm ../gliders.dmp
cd
