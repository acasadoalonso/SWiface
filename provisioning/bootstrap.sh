#!/usr/bin/env bash

echo "======================================================================"
echo "                   begin of bootstrap                                 "
echo "======================================================================"
sudo apt-get update
if [ ! -d /home/vagrant/src ]
then 
   sudo -u vagrant mkdir /home/vagrant/src
   sudo -u vagrant ln -s /vagrant/public/main /home/vagrant/src/SWSsrc
fi
if [ -f /tmp/commoninstall.sh ]
then 
	echo "======================================================================="
	echo "Install the rest of the software running     bash /tmp/commoninstall.sh"
	echo "follow by running                            bash /tmp/install.sh"
	echo "======================================================================="
        sudo su vagrant --command="/bin/bash /tmp/commoninstall.sh"
        echo "DBpasswd:"$(cat /tmp/.DBpasswd) 
        sudo su vagrant --command="/bin/bash /tmp/install.sh VM"

fi
sudo apt-get dist-upgrade
sudo apt-get autoremove
sudo apt-get autoclean
sudo apt-get clean
echo "======================================================================"
echo "                   end of bootstrap                                   "
echo "======================================================================"
