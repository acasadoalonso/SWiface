#!/bin/sh
if [ -z $CONFIGDIR ]
then 
     export CONFIGDIR=/etc/local/
fi
DBuser=$(echo    `grep '^DBuser '   $CONFIGDIR/SWSconfig.ini` | sed 's/=//g' | sed 's/^DBuser //g')
DBpasswd=$(echo  `grep '^DBpasswd ' $CONFIGDIR/SWSconfig.ini` | sed 's/=//g' | sed 's/^DBpasswd //g' | sed 's/ //g' )
DBpath=$(echo    `grep '^DBpath '   $CONFIGDIR/SWSconfig.ini` | sed 's/=//g' | sed 's/^DBpath //g' | sed 's/ //g' )

SCRIPT=$(readlink -f $0)
SCRIPTPATH=`dirname $SCRIPT`

sunsetfile=$DBpath"/SWS.sunset"

if [ ! -d $DBpath ]
then
	echo "... no SWdata yet ..."
	sleep 180
	ls -la $DBpath
fi
cd $DBpath
echo $(hostname)" running SWlive.sh:" 		>>SWproc.log
date 						>>SWproc.log
cd /var/www/html/SWS
python3 genconfig.py
cd $DBpath
echo "Generated config.py :" 			>>SWproc.log
date 						>>SWproc.log
python3 $SCRIPTPATH/../SWcalsunrisesunset.py 	>>SWproc.log 
python3 $SCRIPTPATH/../SWiface.py   	 	>>SWproc.log &
