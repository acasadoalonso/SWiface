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
        sudo bash /tmp/commoninstall.sh
        sudo bash /tmp/install.sh
fi
sudo apt-get autoremove
sudo apt-get autoclean
sudo apt-get clean
echo "======================================================================"
echo "                   end of bootstrap                                   "
echo "======================================================================"
