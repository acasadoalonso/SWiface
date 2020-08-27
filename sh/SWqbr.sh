#!/bin/sh
cd /nfs/OGN/DIRdata
echo "select * from GLIDERS where registration ='"$1"';" 
echo "select * from GLIDERS where registration ='"$1"';" | sqlite3 SAROGN.db
cd -
