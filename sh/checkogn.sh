#!/bin/bash
p1=$(pgrep ogn-rf)
if [ $? -eq 0 ]
then 
	logger -t $0 "OGN is running"
else
	p2=$(pgrep  /etc/init.d/rtlsdr-ogn )
	if [ $? -eq 0 ]
	then 
		exit
	else
		sudo ntpdate -u pool.ntp.org
		#sudo service rtlsdr-ogn restart
		echo service rtlsdr-ogn restart
		logger -t $0 "OGN is restarting"
	fi
fi
