!#/bin/bash
bash mariadbdbnet.sh
cd Mariadb.debian
bash mariadb.patch
make
cd ..
bash mariadb.sh
bash mariadbpma.sh
bash mariadb.start
echo "Create the MySQL database SWIFACE "			#
echo "Type the PASSword for the MySQL database SWIFACE "	#
echo "========================================================" #
echo "CREATE DATABASE SWIFACE" | mysql -h mariadb -u root -p	#
mysql -u root -p -h mariadb --database SWIFACE <DBschema.sql	#
echo " "							#
make