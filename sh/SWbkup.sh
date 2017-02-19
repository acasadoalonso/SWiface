#!/bin/bash
cd /home/pi

sudo mount -t nfs casadonfs:/nfs/NFS/Backups /bkups
if [  -d /bkups ]
then
        tar -czvf /bkups/BKUP_$(hostname)_$(date +%y.%m.%d).tar ~/  --exclude="~/google_drive"
	echo "Bkup SWdata"
	tar -czvf /bkups/BKUP_SWiface_$(hostname)_$(date +%y.%m.%d).tar /nfs/OGN/SWdata --exclude="lost+found"
fi
cd ..
