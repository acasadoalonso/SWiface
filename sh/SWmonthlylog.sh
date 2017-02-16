#!/bin/bash
cd /nfs/OGN/SWdata
server="casadonfs"
bkserver="ubuntu"
mv proc.log   log/Proc$(date +%y%m).log
mv err.log    log/Err$(date    +%y%m).log
cd archive
rm            db/SWiface.BKUP.db
cp SWiface.db db/SWiface.BKUP.db
sqlite3 SWiface.db "vacuum;"
mv DATA$(date +%y)*.log Y$(date +%y) 
mysqldump                                  -u ogn -pogn -h $server SWARCHIVE >db/SWARCHIVE.dmp
echo "delete from OGNDATA;" | mysql     -v -u ogn -pogn -h $server SWARCHIVE                      >>proc.log
echo "delete from RECEIVERS;" | mysql   -v -u ogn -pogn -h $bkserver SWARCHIVE                    >>proc.log
mv ogndata.sql mondata.sql
cd
