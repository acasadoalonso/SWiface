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

cd $DBpath
date >>SWproc.log
echo $(hostname)" running SWlive:"		>>SWproc.log
python3 $SCRIPTPATH/../SWcalsunrisesunset.py 	>>SWproc.log 
python3 $SCRIPTPATH/../SWiface.py   	 	>>SWproc.log &
