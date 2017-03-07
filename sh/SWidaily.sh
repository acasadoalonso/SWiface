#!/bin/bash
cd /nfs/OGN/SWdata
server="casadonfs"
echo ".dump OGNDATA" |        sqlite3 SWiface.db >ogndata.dmp 
sed "s/CREATE TABLE/-- CREATE TABLE/g" ogndata.dmp | sed "s/CREATE INDEX/-- CREATE INDEX/g" | sqlite3  archive/SWiface.db >>proc.log
echo "delete from OGNDATA;" | sqlite3 SWiface.db              >>proc.log
echo "vacuum;"              | sqlite3 SWiface.db              >>proc.log
rm ogndata.dmp
echo "select 'Number of fixes: on the DB:', count(*) from OGNDATA; select station, 'Kms.max.:',max(distance),'        Flarmid :',idflarm, 'Date:',date, time, station from OGNDATA group by station; " | mysql -v -h $server -u ogn -pogn  SWIFACE				>>proc.log
mv DATA*.log archive
mutt -a "proc.log" -s $server"  SWS interface " -- acasado@acm.org
mysqldump                               -t -u ogn -pogn -h $server SWIFACE OGNDATA >ogndata.sql 
mysql                                      -u ogn -pogn -h $server SWARCHIVE       <ogndata.sql >>proc.log
echo "delete from OGNDATA;" | mysql     -v -u ogn -pogn -h $server SWIFACE                      >>proc.log
mv ogndata.sql archive
mv proc.log archive/PROC$(date +%y%m%d).log
rm SW.alive			>/dev/null 2>&1
cd /var/www/html/cuc
mv *.json archive		>/dev/null 2>&1
sudo rm *.cuc 			>/dev/null 2>&1
cd
