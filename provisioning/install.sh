#!/bin/bash
# install the VM machine using Vagrant and ansible
if [ ! -f .DBpasswd    ]					#
then								#
   echo "Type DB password ..."					#
   read DBpasswd						#
   echo $DBpasswd > .DBpasswd					#
fi	
vagrant up

