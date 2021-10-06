#!/bin/bash
# install the VM machine using Vagrant and ansible
if [ ! -f .DBpasswd    ]					#
then								#
   echo "Type DB password ..."					#
   read DBpasswd						#
   echo $DBpasswd > .DBpasswd					#
fi	
sudo apt install ansible
vagrant --version
vagrant box update
if [ ! -d /var/www/html/SWS ]
then
    git clone https://github.com/acasadoalonso/SWiface-PHP.git /var/www/html/SWS
    ls ../html
fi
vagrant up

