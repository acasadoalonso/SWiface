#!/bin/bash
cd /nfs/OGN/SWdata
if [ $# -eq  0 ]; then
	server='localhost'
else
	server=$1
fi
mv SWproc.log   log/SWproc$(date +%y%m).log	>/dev/null 2>&1
mv err.log    log/Err$(date  +%y%m).log		>/dev/null 2>&1
cd archive
rm            db/SWiface.BKUP.db		>/dev/null 2>&1
cp SWiface.db db/SWiface.BKUP.db
sqlite3 SWiface.db "vacuum;"
mv DATA$(date +%y)*.log Y$(date +%y) 
mysqldump                                --login-path=SARogn -h $server SWARCHIVE >db/SWARCHIVE.dmp
echo "delete from OGNDATA;" | mysql      --login-path=SARogn -v -h $server SWARCHIVE                      >>SWproc.log
mv ogndata.sql mondata.sql
bash ./compress.sh   Y$(date +%y)
cd
