#!/bin/bash
cd /home/pi
tar -czvf BKUP_$(hostname)_$(date +%y.%m.%d).tar /home/pi --exclude="/home/pi/google_drive"
mv        BKUP_$(hostname)_$(date +%y.%m.%d).tar ./google_drive
cd ./google_drive 
#./grive
sudo mount -t nfs casadonfs:/nfs/NFS/Backups /bkups
cp        BKUP_$(hostname)_$(date +%y.%m.%d).tar         /bkups
echo "Bkup SWdata"
tar -czvf BKUP_SWiface_$(hostname)_$(date +%y.%m.%d).tar /nfs/OGN/SWdata --exclude="lost+found"
mv        BKUP_SWiface_$(hostname)_$(date +%y.%m.%d).tar /bkups
cd ..
