#!/bin/bash

# script to email logfiles 
# then delete the logfiles to save space

/sbin/ifconfig eth0 	>  hc.log
/sbin/ifconfig wlan0 	>> hc.log
df -v 			>> hc.log
lsusb	 		>> hc.log
/usr/bin/uptime	 	>> hc.log

# get the single digit of time, ie 0-9 for file extension
day=`date "+%a"`
DMY=`date "+%x"`
now=`date "+%R"`
hn=`hostname   `
taken=$day"_"$DMY"_"$now
gettime=`date "+%M"`

#insert healthcheck commands here
{
echo $taken
/usr/bin/uptime
/bin/cat /etc/hostname /etc/issue.net /etc/debian_version

/usr/bin/hostnamectl
echo "####################   IP settings  ##################"
echo "           "
/sbin/ifconfig eth0
/sbin/ifconfig wlan0
echo "           "
echo "####################   disk usage  ##################"
echo "           "
df -v
echo "           "
echo "####################   usb devices ##################"
echo "           "
lsusb
echo "           "
cd /nfs/OGN/DIRdata
ls -lrt
} | mutt -a "~/hc.log" -s $hn" RPi Health Check "$taken -- acasado@acm.org

rm -f ~/hc.log

