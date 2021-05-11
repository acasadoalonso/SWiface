#!/bin/bash
if [ $# = 0 ]; then
	city='Madrid'
else
	city=$1
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

sunsetfile=$DBpath"/SWS.sunset"
if [ -f $sunsetfile ]
	then
		ss=$(cat $sunsetfile)
	else
		ss=$(/usr/local/bin/calcelestial -p sun -m set -q $city -H civil -f %s)
fi
alive=$DBpath"/SWS.alive"
pid=$(echo  `grep '^pid' $CONFIGDIR/SWSconfig.ini` | sed 's/=//g' | sed 's/^pid//g')
now=$(date +%s)
let "dif=$ss-$now-1800"
if [ $dif -lt 0 ]
then
        logger  -t $0 "SWS Repo Nothing to do: "$dif" Now: "$now" Sunset: "$ss
else
        if [ ! -f $alive ]
        then
                logger  -t $0 "SWS Repo is not alive"
                if [ -f $pid ] # if OGN repo interface is  not running
                then
                        pnum=$(cat $pid)
                        sudo kill $pnum
                        rm $pid
                fi
#               restart OGN data collector
                /bin/bash $SCRIPTPATH/SWlive.sh
                logger -t $0 "SWS repo seems down, restarting"
                date >>$DBpath/.SWSrestart.log
        else
                logger -t $0 "SWS Repo is alive at: "$city
                logger -t $0 "SWS repo seems up: "$dif" Now: "$now" Sunset: "$ss
        fi
fi
if [  -f $alive ]
        then
        rm $alive
fi
