#!/bin/bash 

cd /var/www/public
cd main/libfap-1.5/deb
sudo dpkg - i lib*amd64.deb
cd /var/www/public
sudo apt-get install python-dev python-pip
sudo pip install ephem pytz geopy configparser
sudo mkdir /etc/local
sudo cp config.template /etc/local/SWSconfig.ini
sqlite3 SWiface.db <main/*.sql
