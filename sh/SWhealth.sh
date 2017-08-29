#!/bin/bash

# script to email logfiles 
# then delete the logfiles to save space

/sbin/ifconfig 		>  hc.log
df -v 			>> hc.log
lsusb	 		>> hc.log
/usr/bin/uptime	 	>> hc.log

# get the single digit of time, ie 0-9 for file extension
day=`date "+%a"`
DMY=`date "+%x"`
now=`date "+%R"`
taken=$day"_"$DMY"_"$now
hn=`hostname   `
gettime=`date "+%M"`
hc=$(ls ~/hc.log)
#insert healthcheck commands here
{
echo $taken
/usr/bin/uptime
/bin/cat /etc/hostname /etc/issue.net /etc/debian_version
hostnamectl
echo "####################   IP settings  ##################"
echo "           "
/sbin/ifconfig 
echo "           "
echo "####################   disk usage  ##################"
echo "           "
df -v
echo "           "
echo "####################   usb devices ##################"
echo "           "
lsusb
echo "           "
cd /nfs/OGN/SWdata
ls -lrt
} | mutt -a $hc -s $hn" SWS iface Health Check "$taken -- acasado@acm.org

rm -f ~/hc.log

