#!/bin/bash
if [ -z $CONFIGDIR ]
then 
     export CONFIGDIR=/etc/local/
fi
DBuser=$(echo    `grep '^DBuser '   $CONFIGDIR/SWSconfig.ini` | sed 's/=//g' | sed 's/^DBuser //g')
DBpasswd=$(echo  `grep '^DBpasswd ' $CONFIGDIR/SWSconfig.ini` | sed 's/=//g' | sed 's/^DBpasswd //g' | sed 's/ //g' )
DBpath=$(echo    `grep '^DBpath '   $CONFIGDIR/SWSconfig.ini` | sed 's/=//g' | sed 's/^DBpath //g' | sed 's/ //g' )

SCRIPT=$(readlink -f $0)
SCRIPTPATH=`dirname $SCRIPT`
if [ ! -d  /sys/fs/cgroup/systemd ]; then
   sudo mkdir /sys/fs/cgroup/systemd
   sudo mount -t cgroup -o none,name=systemd cgroup /sys/fs/cgroup/systemd
fi

#docker run --net mynetsql --ip 172.18.0.2 --name mariadb -e MYSQL_ROOT_PASSWORD=$DBpasswd  --log-bin --binlog-format=MIXED --restart unless-stopped -d mariadb:latest 
docker run --net mynetsql --ip 172.18.0.2 --name mariadb -e MYSQL_ROOT_PASSWORD=$DBpasswd  --restart unless-stopped -d mariadb:latest 


