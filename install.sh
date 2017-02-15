#!/bin/bash 
echo
echo "Installing the Silent Wings Studio interface ...." 
echo
sudo apt-get update
sudo apt-get -y upgrade
cd /var/www/public/main/libfap-1.5/deb
sudo dpkg -i lib*amd64.deb
cd /var/www/public/main
sudo apt-get install -y python-dev python-pip
sudo pip install ephem pytz geopy configparser
if [ ! -d /etc/local ]
then
    sudo mkdir /etc/local
fi
sudo cp config.template /etc/local/SWSconfig.ini
cd /var/www/public/
cp configtail.template configtail.txt
python genconfig.py
rm      SWiface.db
sqlite3 SWiface.db         < main/DBschema.sql
mysql --database scotchbox < main/DBschema.sql
echo
echo "Optional steps ... "
echo
cd main
mailcatcher --http-ip=0.0.0.0
sudo /usr/local/bin/composer self-update
composer update
cd
touch SWinstallation.done
echo
echo "Installation done ..."
echo "Review the configuration file on /etc/local and the config tail file configtail.txt  ..."
echo
