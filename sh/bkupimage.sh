#!/bin/bash 
mydate=$(date +%Y%m%d)
sudo mount -t nfs casadonfs:/nfs/NFS/Backups /bkups
sudo mount                  /dev/sda1        /home/pi/rpi
sudo /bin/bash /home/pi/src/buildimage.sh
sudo gzip     /home/pi/rpi/images/raspbian_basic_wheezy_$(date +%Y%m%d).img
sudo mv       /home/pi/rpi/images/raspbian_basic_wheezy_$(date +%Y%m%d).img.gz /home/pi/rpi/images/$(hostname)_raspbian_basic_wheezy_$(date +%Y%m%d).img.gz
sudo chown pi /home/pi/rpi/images/* 
sudo chgrp pi /home/pi/rpi/images/* 
sudo mv       /home/pi/rpi/images/*.img.gz /bkups
sudo rm -r    /home/pi/rpi/images/*
date | mutt -s $(hostname)"  Bkup image done" -- acasado@acm.org

