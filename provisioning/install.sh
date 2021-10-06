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
vagrant vbox update
vagrant up

