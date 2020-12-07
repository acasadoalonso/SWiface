!#/bin/bash
sudo snap install docker
cho "Create the MySQL database SWIFACE "			#
echo "Type the PASSword for the MySQL database SWIFACE "	#
echo "========================================================" #
echo "CREATE DATABASE SWIFACE" | mysql -u root -p		#
mysql -u root -p --database SWIFACE < main/DBschema.sql		#
echo "Create the MySQL OGN user "				#
echo "GRANT ALL PRIVILEGES ON *.* TO 'ogn'@'localhost' IDENTIFIED BY 'yourpassword'; " | mysql -u root -p     #
echo "GRANT SELECT ON *.* TO 'ognread'@'localhost'     IDENTIFIED BY 'yourpassword'; " | mysql -u root -p     #
echo " "							#

