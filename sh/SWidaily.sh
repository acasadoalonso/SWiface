#!/bin/bash
cd /nfs/OGN/SWdata
if [ $# -eq  0 ]; then
	server='localhost'
else
	server=$1
fi
hostname=$(hostname)
echo "Process SQLITE3 DB at server: "$hostname		>>SWproc.log
echo "select 'Number of fixes: on the DB:', count(*) from OGNDATA; select station, 'Kms.max.:',max(distance) as Distance,'        Flarmid :',idflarm, 'Date:',date, time, station from OGNDATA group by station; " | sqlite3 SWiface.db	>>SWproc.log
echo ".dump OGNDATA" |        sqlite3 SWiface.db >ogndata.dmp 
sed "s/CREATE TABLE/-- CREATE TABLE/g" ogndata.dmp | sed "s/CREATE INDEX/-- CREATE INDEX/g" | sqlite3  archive/SWiface.db >>SWproc.log
echo "delete from OGNDATA;" | sqlite3 SWiface.db        >>SWproc.log
echo "vacuum;"              | sqlite3 SWiface.db        >>SWproc.log
echo "select 'Number of fixes: on the DB:', count(*) from OGNDATA; select station, 'Kms.max.:',max(distance) as Distance,'        Flarmid :',idflarm, 'Date:',date, time, station from OGNDATA group by station; " | sqlite3 archive/SWiface.db			>>SWproc.log
rm ogndata.dmp
if [ -f /nfs/OGN/DISdata/SAROGN.db ]
then
	sqlite3 SWiface.db "drop table GLIDERS;" 
	sqlite3 /nfs/OGN/DIRdata/SAROGN.db ".dump GLIDERS" | sqlite3 SWiface.db
	sqlite3 SWiface.db "select count(*) from GLIDERS;" 
fi
echo "Process MYSQL DB." 				>>SWproc.log
mysqlcheck --login-path=SARogn -h $server SWIFACE   	>>SWproc.log
mysqlcheck --login-path=SARogn -h $server SWARCHIVE 	>>SWproc.log
echo "select 'Number of fixes: on the DB:', count(*) from OGNDATA; select station, 'Kms.max.:',max(distance),'        Flarmid :',idflarm, 'Date:',date, time, station from OGNDATA group by station; " | mysql --login-path=SARogn  -v -h $server SWIFACE	      >>SWproc.log
mysqldump                               --login-path=SARogn -t -h $server SWIFACE OGNDATA >ogndata.sql 
mysql                                   --login-path=SARogn    -h $server SWARCHIVE       <ogndata.sql >>SWproc.log
echo "delete from OGNDATA;" | mysql     --login-path=SARogn -v -h $server SWIFACE                      >>SWproc.log
mv ogndata.sql archive
echo "End of processes SQLITE3 & MYSQL DB at server: "$hostname 	>>SWproc.log
mutt -a "SWproc.log" -s $hostname$server"  SWS interface " -- angel@acasado.es
mv DATA*.log  archive		>/dev/null 2>&1
mv SWproc.log archive/SWproc$(date +%y%m%d).log
rm SWS.alive			>/dev/null 2>&1
rm SWS.sunset			>/dev/null 2>&1
cd /var/www/html/cuc
mv *.json archive		>/dev/null 2>&1
mv *.tsk archive		>/dev/null 2>&1
mv *.lst archive		>/dev/null 2>&1
sudo rm *.cuc 			>/dev/null 2>&1
cd
