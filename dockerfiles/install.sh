#!/bin/bash
#
# install SWS interface on a docker container
#
bash install.docker
bash install.portainer
make
if [ ! -f .DBpasswd    ]					#
then								#
   echo "Type DB password ..."					#
   read DBpasswd						#
   echo $DBpasswd > .DBpasswd					#
fi	
bash mariadbnet.sh
bash mariadbpma.sh
bash mariadb.sh
bash mariadb.start
bash create.SWIFACE.db.sh
bash swiface.standalone.sh
bash SSH.start.swiface.sh
