#!/bin/bash 
echo								#
echo "Installing the Silent Wings Studio interface ...." 	#
echo								#
export LC_ALL=en_US.UTF-8 && export LANG=en_US.UTF-8		#
sudo apt-get install -y software-properties-common python-software-properties #
sudo rm /etc/apt/sources.list.d/ondre*				#
sudo add-apt-repository ppa:ondrej/php				#
echo								#
echo " lets update the operating system libraries  ...." 	#
echo								#
sudo apt-get update						#
sudo apt-get install -y language-pack-en-base 			# 
export LC_ALL=en_US.UTF-8 && export LANG=en_US.UTF-8		#
echo "export LC_ALL=en_US.UTF-8 && export LANG=en_US.UTF-8 " >>~/.profile #
echo "export LD_LIBRARY_PATH=/usr/local/lib" >>~/.profile 	#
sudo apt-get -y upgrade						#
cd /var/www/public/main/libfap-1.5/deb				#
sudo dpkg -i lib*amd64.deb					#
echo								#
echo "Installing the packages required . (LAMP stack)..."	#
echo								#
cd /var/www/public/main						#
sudo apt-get install -y mysql-server mysql-client sqlite3	#
sudo apt-get install -y python-dev python-pip python-mysqldb    #
sudo apt-get install -y dos2unix libarchive-dev	 autoconf mc	#
sudo apt-get install -y pkg-config git mutt			#
sudo apt-get install -y apache2 php php-mcrypt php-mysql php-cli #
sudo apt-get install -y php-mbstring php-gettext		#
sudo apt-get install -y mailutils ntpdate mutt	ssmtp		#
sudo apt-get install -y libcurl4-openssl-dev			#
sudo apt-get install -y libjson0 libjson0-dev			#
sudo a2enmod rewrite						#
sudo a2enmod cgi						#
sudo phpenmod mcrypt						#
sudo phpenmod mbstring						#
sudo cat /etc/apache2/apache2.conf html.dir 	>>temp.conf	#
sudo echo "ServerName SWiface " >>temp.conf			#
sudo mv temp.conf /etc/apache2/apache2.conf			#
sudo service apache2 restart					#
echo								#
echo "Installing phpmyadmin  ... "				#
echo								#
sudo apt-get install -y phpmyadmin 				#
sudo service apache2 restart					#
sudo -H pip install --upgrade pip                               #
sudo -H pip install ephem 					#
sudo -H pip install pytz 					#
sudo -H pip install geopy 					#
sudo -H pip install configparser 				#
sudo -H pip install pycountry 					#

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
if [ ! -d cuc    ]						#
then								#
	mkdir cuc     						#
	chmod 777 cuc     					#
	mkdir cuc/TSKF  					#
	chmod 777 cuc/TSKF  					#
fi								#
sqlite3 SWiface.db         < main/DBschema.sql			#
echo "CREATE DATABASE SWIFACE" | mysql -u root -pogn		#
mysql -u root -pogn --database SWIFACE < main/DBschema.sql	#
echo								#
echo "Optional steps ... "					#
echo								#
cd main								#
cp aliases ~/.bash_aliases					#
mailcatcher --http-ip=0.0.0.0					#
sudo /usr/local/bin/composer self-update			#
composer update							#
cd sh	 							#
crontab <crontab.data						#
crontab -l 							#
if [ ! -d ~/src  ]						#
then								#
	mkdir ~/src   						#
	mkdir ~/src/SWsrc					#
	ln -s /var/www/html/main ~/src/SWsrc			#
fi								#
cp *.sh ~/src  							#
cd ..								#
cp *.py ~/src/SWsrc						#
ls  -la ~/src 							#
if [ ! -d /nfs  ]						#
then								#
	sudo mkdir /nfs						#
	sudo mkdir /nfs/OGN					#
	sudo mkdir /nfs/OGN/SWdata				#
	sudo chown ogn:ogn /nfs/OGN/SWdata			#
	sudo chmod 777 /nfs/OGN/SWdata				#
	cd /var/www/public/					#
	mv SWiface.db /nfs/OGN/SWdata				#
	sudo chown ogn:ogn *					# 
	sudo chmod 777 *					#
	sudo chown ogn:ogn */*					# 
	sudo chmod 777 */*					#
fi								#
cd /var/www/html 						#
rm kglid.py							#
ln main/kglid.py .						# 
cd								#
sudo dpkg-reconfigure tzdata					#
sudo apt-get -y dist-upgrade					#
mysqladmin -u root password ogn					#
sudo apt-get -y autoremove					#
touch SWinstallation.done					#
echo								#
echo "========================================================================================================"	#
echo "Installation done ..."					#
echo "Review the configuration file on /etc/local and the config tail file configtail.txt  ..."			#
echo "Review the configuration of the crontab and the shell scripts on ~/src " 					#
echo "In order to execute the Silent Wings data crawler execute:  bash ~/src/SWlive.sh " 			#
echo "Check the placement of the RootDocument on APACHE2 ... needs to be /var/www/html				#
echo "If running in Windows under Virtual Box, run dos2unix on /var/www/html & ./main & ~/src			#
echo "Run the utilities soa2sws.py and/or sgp2sws.py in order to extract the data from SoaringSpot.com or SGP   #
echo "Install phpmyadmin if needed !!!                                                                          #
echo "========================================================================================================"	#
echo								#
