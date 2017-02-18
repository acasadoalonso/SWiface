#!/bin/bash 
echo								#
echo "Installing the Silent Wings Studio interface ...." 	#
echo								#
sudo rm /etc/apt/sources.list.d/ondre*				#
sudo add-apt-repository ppa:ondrej/ppa				#
sudo apt-get update						#
sudo apt-get -y upgrade						#
cd /var/www/public/main/libfap-1.5/deb				#
sudo dpkg -i lib*amd64.deb					#
echo								#
echo "Installing the packages required ...." 			#
echo								#
cd /var/www/public/main						#
sudo apt-get install -y python-dev python-pip python-mysqldb	#
sudo apt-get install -y dos2unix libarchive-dev	 autoconf	#
sudo apt-get install -y language-pack-en-base 			# 
sudo apt-get install -y language-pack-es-base 			# 
export LC_ALL=en_US.UTF-8 && export LANG=en_US.UTF-8		#
sudo pip install ephem pytz geopy configparser			#
if [ ! -d /etc/local ]						#
then								#
    sudo mkdir /etc/local					#
fi								#
echo								#
echo "Installing the templates needed  ...." 			#
echo								#
sudo cp config.template /etc/local/SWSconfig.ini		#
cd /var/www/public/						#
cp configtail.template configtail.txt				#
python genconfig.py						#
if [ -f SWiface.db ]						#
then								#
	rm      SWiface.db					#
fi								#
sqlite3 SWiface.db         < main/DBschema.sql			#
mysql --database scotchbox < main/DBschema.sql			#
echo								#
echo "Optional steps ... "					#
echo								#
cd main								#
mailcatcher --http-ip=0.0.0.0					#
sudo /usr/local/bin/composer self-update			#
composer update							#
cd sh	 							#
crontab <crontab.data						#
crontab -l 							#
if [ ! -d ~/src  ]						#
then								#
	mkdir ~/src   						#
fi								#
cp *.sh ~/src  							#
ls -la ~/src 							#
cd								#
touch SWinstallation.done					#
echo								#
echo "Installation done ..."					#
echo "Review the configuration file on /etc/local and the config tail file configtail.txt  ..."			#
echo "Review the configuration of the crontab and the shell script on ~/src "  					#
echo "In order to execute the Silent Wings data crawler execute:  python /var/www/public/main/SWiface.py " 	#
echo								#
