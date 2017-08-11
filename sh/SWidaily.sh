#!/bin/bash
cd /nfs/OGN/SWdata
server="casadonfs"
hostname=$(hostname)
echo "Process SQLITE3 DB." >>SWproc.log
echo "select 'Number of fixes: on the DB:', count(*) from OGNDATA; select station, 'Kms.max.:',max(distance) as Distance,'        Flarmid :',idflarm, 'Date:',date, time, station from OGNDATA group by station; " | sqlite3 SWiface.db				>>SWproc.log
echo ".dump OGNDATA" |        sqlite3 SWiface.db >ogndata.dmp 
sed "s/CREATE TABLE/-- CREATE TABLE/g" ogndata.dmp | sed "s/CREATE INDEX/-- CREATE INDEX/g" | sqlite3  archive/SWiface.db >>SWproc.log
echo "delete from OGNDATA;" | sqlite3 SWiface.db              >>SWproc.log
echo "vacuum;"              | sqlite3 SWiface.db              >>SWproc.log
rm ogndata.dmp
echo "Process MYSQL DB." >>SWproc.log
mysqlcheck -u admin -padmin -h $server --all-databases >>SWproc.log
echo "select 'Number of fixes: on the DB:', count(*) from OGNDATA; select station, 'Kms.max.:',max(distance),'        Flarmid :',idflarm, 'Date:',date, time, station from OGNDATA group by station; " | mysql -v -h $server -u ogn -pogn  SWIFACE	>>SWproc.log
mysqldump                               -t -u ogn -pogn -h $server SWIFACE OGNDATA >ogndata.sql 
mysql                                      -u ogn -pogn -h $server SWARCHIVE       <ogndata.sql >>SWproc.log
echo "delete from OGNDATA;" | mysql     -v -u ogn -pogn -h $server SWIFACE                      >>SWproc.log
mv ogndata.sql archive
echo "End of processes SQLITE3 & MYSQL DB." >>SWproc.log
mutt -a "SWproc.log" -s $hostname$server"  SWS interface " -- acasado@acm.org
mv DATA*.log  archive
mv SWproc.log archive/PROC$(date +%y%m%d).log
rm SWS.alive			>/dev/null 2>&1
rm SWS.sunset			>/dev/null 2>&1
cd /var/www/html/cuc
mv *.json archive		>/dev/null 2>&1
mv *.tsk archive		>/dev/null 2>&1
mv *.lst archive		>/dev/null 2>&1
sudo rm *.cuc 			>/dev/null 2>&1
cd
