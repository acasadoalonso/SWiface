#!/bin/bash
if [ -z $CONFIGDIR ]
then 
     export CONFIGDIR=/etc/local/
fi
DBuser=$(echo    `grep '^DBuser '   $CONFIGDIR/SWSconfig.ini` | sed 's/=//g' | sed 's/^DBuser //g')
DBpasswd=$(echo  `grep '^DBpasswd ' $CONFIGDIR/SWSconfig.ini` | sed 's/=//g' | sed 's/^DBpasswd //g' | sed 's/ //g' )
DBpath=$(echo    `grep '^DBpath '   $CONFIGDIR/SWSconfig.ini` | sed 's/=//g' | sed 's/^DBpath //g' | sed 's/ //g' )
location=$(echo  `grep '^location_name '   $CONFIGDIR/SWSconfig.ini` | sed 's/=//g' | sed 's/^location_name //g' | sed 's/ //g' )
cd $DBpath
SCRIPT=$(readlink -f $0)
SCRIPTPATH=`dirname $SCRIPT`
city='Sisteron'
echo "Starting docker container swiface at: "$HOSTNAME $(date) 				>>SWproc.docker.log
echo "================================================================================"	>>SWproc.docker.log
echo "Location: "$location "City: "$city 						>>SWproc.docker.log
docker start swiface 									>>SWproc.docker.log
/bin/echo '/bin/bash ~/src/SWSsrc/dockerfiles/SWidaily.docker.sh '$city | at -M $(/usr/local/bin/calcelestial -n -p sun -m set -q $city ) - 15 minutes  >>SWproc.docker.log 2>&1
echo "Container scheduled ..."								>>SWproc.docker.log
