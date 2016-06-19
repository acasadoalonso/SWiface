#!/bin/bash
ss=$(/usr/local/bin/calcelestial -p sun -m set -q Madrid -H civil -f %s)
alive=$"/nfs/OGN/SWdata/OGN.alive"
now=$(date +%s)
let "dif=$ss-$now"
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
                /bin/bash /home/pi/src/live.sh
                logger -t $0 "SWS repo seems down, restarting"
                date >>/nfs/OGN/SWdata/.restart.log
        else
                logger -t $0 "SWS Repo is alive"
                logger -t $0 "SWS repo seems up: "$dif" Now: "$now" Sunset: "$ss
        fi
fi
rm $alive

