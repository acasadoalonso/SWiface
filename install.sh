#!/bin/bash 
echo							#
echo "Installing the Silent Wings Studio interface ...." 							#
echo							#
sudo apt-get update							#
sudo apt-get -y upgrade							#
cd /var/www/public/main/libfap-1.5/deb							#
sudo dpkg -i lib*amd64.deb							#
echo							#
echo "Installing the packages required ...." 							#
echo							#
cd /var/www/public/main							#
sudo apt-get install -y python-dev python-pip python-mysqldb							#
sudo pip install ephem pytz geopy configparser							#
if [ ! -d /etc/local ]							#
then							#
    sudo mkdir /etc/local							#
fi							#
echo							#
echo "Installing the templates needed  ...." 							#
echo							#
sudo cp config.template /etc/local/SWSconfig.ini							#
cd /var/www/public/							#
cp configtail.template configtail.txt							#
python genconfig.py							#
if [ ! -f SWiface.db ]							#
then							#
	rm      SWiface.db							#
fi							#
sqlite3 SWiface.db         < main/DBschema.sql							#
mysql --database scotchbox < main/DBschema.sql							#
echo							#
echo "Optional steps ... "							#
echo							#
cd main							#
mailcatcher --http-ip=0.0.0.0							#
sudo /usr/local/bin/composer self-update							#
composer update							#
cd							#
touch SWinstallation.done							#
echo							#
echo "Installation done ..."							#
echo "Review the configuration file on /etc/local and the config tail file configtail.txt  ..."							#
echo "In order to execute the Silent Wings data crawler execute:  python /var/www/public/main/SWiface.py " 	#
echo							#
