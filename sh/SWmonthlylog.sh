#!/bin/bash
MySQL='NO'
if [ $# -eq  0 ]; then
	server='localhost'
else
	server=$1
	MySQL='YES'
fi
if [ -z $CONFIGDIR ]
then 
     export CONFIGDIR=/etc/local/
fi
DBuser=$(echo    `grep '^DBuser '   $CONFIGDIR/APRSconfig.ini` | sed 's/=//g' | sed 's/^DBuser //g')
DBpasswd=$(echo  `grep '^DBpasswd ' $CONFIGDIR/APRSconfig.ini` | sed 's/=//g' | sed 's/^DBpasswd //g' | sed 's/ //g' )
DBpath=$(echo    `grep '^DBpath '   $CONFIGDIR/APRSconfig.ini` | sed 's/=//g' | sed 's/^DBpath //g' | sed 's/ //g' )

SCRIPT=$(readlink -f $0)
SCRIPTPATH=`dirname $SCRIPT`
cd $DBpath

echo "Process SW monthly process on server: "$(hostname) >>SWproc.log
mv SWproc.log   archive/SWproc$(date +%y%m).log	>/dev/null 2>&1
mv err.log      archive/Err$(date  +%y%m).log	>/dev/null 2>&1
cd archive
rm            db/SWiface.BKUP.db		>/dev/null 2>&1
cp SWiface.db db/SWiface.BKUP.db
sqlite3 -echo SWiface.db "vacuum;"
mv DATA$(date +%y)*.log Y$(date +%y) 
mv SW$(date +%y)*.log   Y$(date +%y) 
if [ $MySQL == 'YES' ]
then
	mysqldump                                --login-path=SARogn -h $server SWARCHIVE >db/SWARCHIVE.dmp
	echo "delete from OGNDATA;" | mysql      --login-path=SARogn -v -h $server SWARCHIVE                      >>SWproc.log
	mv ogndata.sql mondata.sql
fi
pwd
bash ./compress.sh   Y$(date +%y)
cd
