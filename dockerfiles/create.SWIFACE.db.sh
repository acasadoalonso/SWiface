!#/bin/bash
bash mariadbdbnet.sh
arch=$(uname -m)
if [ $arch != 'x84-64' ]
then
    cd Mariadb.debian
    bash mariadb.patch
    make
    bash mariadb.sh
    bash mariadbpma.sh
    cd ..
else
    bash mariadb.sh
    bash mariadbpma.sh
fi
bash mariadb.start
echo "Create the MySQL database SWIFACE "			#
echo "Type the PASSword for the MySQL database SWIFACE "	#
echo "========================================================" #
echo "CREATE DATABASE SWIFACE" | mysql -h mariadb -u root -p	#
mysql -u root -p -h mariadb --database SWIFACE <DBschema.sql	#
echo " "							#
echo "Make the swiface docker container "			#
make
