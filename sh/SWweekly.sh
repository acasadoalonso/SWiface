#!/bin/bash
echo "Sync GLIDERS table on databases"			     >>proc.log
cd    /nfs/OGN/DIRdata
echo ".dump GLIDERS" |        sqlite3 OGN.db >gliders.dmp
cd /nfs/OGN/SWdata
mv /nfs/OGN/DIRdata/gliders.dmp .
echo "delete from GLIDERS;" | sqlite3 SWiface.db              >>proc.log 
sqlite3                               SWiface.db <gliders.dmp >>proc.log
echo "vacuum;" |              sqlite3 SWiface.db              >>proc.log 
cd archive
echo "delete from GLIDERS;" | sqlite3 SWiface.db              >>../proc.log 
sqlite3                               SWiface.db <../gliders.dmp >>../proc.log
echo "vacuum;" |              sqlite3 SWiface.db              >>../proc.log 
echo "========================================="	      >>../proc.log
cd
