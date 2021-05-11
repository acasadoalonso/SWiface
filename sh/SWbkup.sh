#!/bin/bash
cd ~/
if [ -z $CONFIGDIR ]
then 
     export CONFIGDIR=/etc/local/
fi
DBuser=$(echo    `grep '^DBuser '   $CONFIGDIR/APRSconfig.ini` | sed 's/=//g' | sed 's/^DBuser //g')
DBpasswd=$(echo  `grep '^DBpasswd ' $CONFIGDIR/APRSconfig.ini` | sed 's/=//g' | sed 's/^DBpasswd //g' | sed 's/ //g' )
DBpath=$(echo    `grep '^DBpath '   $CONFIGDIR/APRSconfig.ini` | sed 's/=//g' | sed 's/^DBpath //g' | sed 's/ //g' )

SCRIPT=$(readlink -f $0)
SCRIPTPATH=`dirname $SCRIPT`


sudo mount -t nfs casadonfs:/nfs/NFS/Backups /bkups
if [  -d /bkups ]
then
        tar -czvf /bkups/BKUP_$(hostname)_$(date +%y.%m.%d).tar ~/ --exclude="~/google_drive"
	echo "Bkup "$DBpath
	tar -czvf /bkups/BKUP_SWiface_$(hostname)_$(date +%y.%m.%d).tar $DBpath --exclude="lost+found"
fi
cd ..
