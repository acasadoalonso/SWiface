#!/bin/bash
sunsetfile=$"/nfs/OGN/SWdata/SWS.sunset"
if [ -f $sunsetfile ]
	then
		ss=$(cat $sunsetfile)
	else
		city='Madrid'
		ss=$(/usr/local/bin/calcelestial -p sun -m set -q $city -H civil -f %s)
fi
alive=$"/nfs/OGN/SWdata/SWS.alive"
now=$(date +%s)
let "dif=$ss-$now-1800"
if [ $dif -lt 0 ]
then
        logger  -t $0 "SWS Repo Nothing to do: "$dif" Now: "$now" Sunset: "$ss
else
        if [ ! -f $alive ]
        then
                logger  -t $0 "SWS Repo is not alive"
                pnum=$(pgrep python)
                if [ $? -eq 0 ] # if OGN repo interface is  not running
                then
                        sudo kill $pnum
                fi
#               restart OGN data collector
                /bin/bash ~/src/SWlive.sh
                logger -t $0 "SWS repo seems down, restarting"
                date >>/nfs/OGN/SWdata/.SWSrestart.log
        else
                logger -t $0 "SWS Repo is alive"
                logger -t $0 "SWS repo seems up: "$dif" Now: "$now" Sunset: "$ss
        fi
fi
if [  -f $alive ]
        then
        rm $alive
fi
