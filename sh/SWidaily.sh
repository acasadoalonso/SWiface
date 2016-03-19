#!/bin/bash
cd /nfs/OGN/SWdata
echo ".dump OGNDATA" |        sqlite3 SWiface.db >ogndata.dmp 
sqlite3                       archive/SWiface.db <ogndata.dmp >>proc.log
echo "delete from OGNDATA;" | sqlite3 SWiface.db              >>proc.log
echo "vacuum;"              | sqlite3 SWiface.db              >>proc.log
#rm ogndata.dmp
mv DATA*.log archive
sudo mount -t nfs casadonfs:/nfs/NFS/Backups /bkups
tar -czvf SWdata.daily.tar .
mv        SWdata.daily.tar /bkups
cd
