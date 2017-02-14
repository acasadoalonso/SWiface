#!/bin/bash 
echo
echo "Installing the Silent Wings Studio interface ...." 
echo
sudo apt-get update
sudo apt-get -y upgrade
cd /var/www/public/main/libfap-1.5/deb
sudo dpkg -i lib*amd64.deb
cd /var/www/public/main
sudo apt-get install python-dev python-pip
sudo pip install ephem pytz geopy configparser
sudo mkdir /etc/local
sudo cp config.template /etc/local/SWSconfig.ini
cd /var/www/public/
cp configtail.template configtail.txt
python genconfig.py
rm      SWiface.db
sqlite3 SWiface.db         < main/DBschema.sql
mysql --database scotchbox < main/DBschema.sql
mailcatcher --http-ip=0.0.0.0
echo
echo "Installation done ..."
echo
