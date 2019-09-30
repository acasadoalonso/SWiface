#!/bin/bash 
echo								#
echo " "							#
echo "Installing the Silent Wings Studio interface ...." 	#
echo "========================================================" #
echo " "							#
echo								#
# Update repository information
sudo apt-get update 
export LC_ALL=en_US.UTF-8 && export LANG=en_US.UTF-8		#
sudo apt-get install -y software-properties-common python3-software-properties
echo " "							#
echo								#
echo " lets update the operating system libraries  ...." 	#
echo "========================================================" #
echo " "							#
echo								#
sudo apt-get update						#
sudo apt-get install -y language-pack-en-base 			# 
export LC_ALL=en_US.UTF-8 && export LANG=en_US.UTF-8		#
echo " "							#
echo "export LC_ALL=en_US.UTF-8 && export LANG=en_US.UTF-8 " >>~/.profile #
echo "export LD_LIBRARY_PATH=/usr/local/lib" >>~/.profile 	#
echo " "							#
sudo apt-get -y upgrade						#
echo								#
echo " "							#
echo "Installing the packages required . (LAMP stack)..."	#
echo "========================================================" #
echo " "							#
echo								#
echo								#
sudo apt-get install -y mysql-server mysql-client sqlite3	#
sudo mysql_secure_installation					#
sudo apt-get install -y python3-dev python3-pip python3-mysqldb #
sudo apt-get install -y dos2unix libarchive-dev	 autoconf mc	#
sudo apt-get install -y pkg-config git mutt git-core		#
sudo apt-get install -y apache2 php php-mcrypt php-mysql php-cli #
sudo apt-get install -y php-mbstring php-gettext		#
sudo apt-get install -y mailutils ntpdate mutt	ssmtp		#
sudo apt-get install -y libcurl4-openssl-dev			#
sudo apt-get install -y libjson0 libjson0-dev			#
sudo apt-get install -y libjson-c-dev 				#
sudo apt-get install -y libfap-dev                              #
sudo apt-get install -y avahi-daemon 				#
sudo apt-get install -y php7.2	 				#
sudo a2enmod rewrite						#
sudo a2enmod cgi						#
sudo phpenmod mcrypt						#
sudo phpenmod mbstring						#
sudo a2enmod php7.2 						#
sudo cat /etc/apache2/apache2.conf html.dir 	>>temp.conf	#
sudo echo "ServerName SWserver  " >>temp.conf			#
sudo mv temp.conf /etc/apache2/apache2.conf			#
sudo service apache2 restart					#
echo								#
echo " "							#
echo "Installing phpmyadmin  ... "				#
echo "================================================" 	#
echo " "							#
echo								#
sudo apt-get install -y libmysqlclient-dev			#
sudo apt-get install -y phpmyadmin 				#
sudo service apache2 restart					#

cd /var/www/html/main						#
echo								#
echo " "							#
echo "Installing mysql "					#
echo "========================================================" #
echo " "							#
echo								#
echo "Type ROOT old password: "					#
echo " "							#
echo "========================================================" #
echo "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'ognognogn';" | sudo mysql -u root -p #
echo "Type ROOT new password: "					#
echo " "							#
echo "========================================================" #
echo "SELECT user,authentication_string,plugin,host FROM mysql.user; " | sudo mysql -u root -p 			#
echo								#
echo " "							#
echo "Installing python "					#
echo "========================================================" #
echo " "							#
echo								#
sudo apt-get install -y python3-dev python3-pip python3-mysqldb #
sudo apt-get install -y dos2unix libarchive-dev	 autoconf mc	#
sudo apt-get install -y pkg-config git  at			#
git config --global user.email "acasadoalonso@gmail.com"	#
git config --global user.name "Angel Casado"			#
echo								#
echo " "							#
echo "Installing apache2 "					#
echo "========================================================" #
echo " "							#
echo								#
sudo apt-get install -y apache2 				#
echo								#
echo " "							#
echo "Installing php "						#
echo "========================================================" #
echo " "							#
echo								#
sudo apt-get install -y php php-mcrypt 				#
sudo apt-get install -y php php-mysql php-cli 			#
sudo apt-get install -y php-mbstring php-gettext		#
sudo apt-get install -y php7.2 					#
echo								#
echo " "							#
echo "Installing mail "						#
echo "========================================================" #
echo " "							#
echo								#
sudo apt-get install -y mailutils ntpdate mutt	ssmtp		#
sudo apt-get install -y libcurl4-openssl-dev			#
sudo apt-get install -y goaccess				#
sudo apt-get install -y avahi-daemon                            #
echo								#
echo " "							#
echo "Installing apache2 modules "				#
echo "========================================================" #
echo " "							#
echo								#
sudo a2enmod rewrite						#
sudo a2enmod cgi						#
sudo phpenmod mcrypt						#
sudo phpenmod mbstring						#
sudo a2enmod proxy_fcgi setenvif				#
sudo a2enconf 							#
sudo cat /etc/apache2/apache2.conf html.dir 	>>temp.conf	#
sudo echo "ServerName SWiface " >>temp.conf			#
sudo mv temp.conf /etc/apache2/apache2.conf			#
echo								#
echo " "							#
echo "Installing apache2 conf "					#
echo "========================================================" #
echo " "							#
echo								#
cat /etc/apache2/apache2.conf					#
sudo service apache2 restart					#
echo " "							#
echo "------------- APACHE2 restarted -----------------------"  #
echo								#
echo " "							#
echo "Installing phpmyadmin  ... "				#
echo "========================================================" #
echo " "							#
echo								#
sudo apt-get install -y phpmyadmin 				#
sudo service apache2 restart					#
echo								#
echo " "							#
echo "Installing pyhon modules "				#
echo "========================================================" #
echo " "							#
echo								#
sudo -H pip3 install --upgrade pip                              #
sudo -H pip3 install ephem 					#
sudo -H pip3 install pytz 					#
sudo -H pip3 install geopy 					#
sudo -H pip3 install configparser 				#
sudo -H pip3 install pycountry 					#
sudo -H pip3 install requests 					#
sudo -H pip3 install pyopenssl 					#
sudo -H pip3 install uritemplate				#
sudo -H pip3 install pyMySQLdb					#
sudo apt-get install libmysqlclient-dev                         #
sudo -H pip3 install mysqlclient                                #
sudo -H pip3 install beeprint					#
sudo -H pip3 install ogn.client					#
if [ ! -d /etc/local ]						#
then								#
    sudo mkdir /etc/local					#
fi								#
if [ ! -d ~/src  ]						#
then								#
	mkdir ~/src   						#
	ln -s $(pwd) ~/src/SWsrc				#
fi								#
echo " "							#
echo " DIR: /src ..."						#
echo "================================================" 	#
ls -la ~/src							#
echo " DIR: /src/SWsrc ..."					#
echo "================================================" 	#
ls -la ~/src/SWsrc						#
echo " DIR: /src/SWsrc/sh ..."					#
echo "================================================" 	#
ls -la ~/src/SWsrc/sh						#
echo "================================================" 	#
echo " "							#
echo "Installing the templates needed  ...." 			#
echo "========================================================" #
echo " "							#
echo								#
cd /var/www/html/main						#
sudo cp config.template /etc/local/SWSconfig.ini		#
cd /var/www/html/						#
cp configtail.template configtail.txt				#
python3 genconfig.py						#
ls -la								#
echo								#
echo " "							#
echo "Setting the data bases       ...." 			#
echo "========================================================" #
echo " "							#
echo								#
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
cd /var/www/html/						#
sqlite3 SWiface.db         < main/DBschema.sqlite3		#
if [ -d /nfs/OGN/SWdata  ]					#
then								#
	mv      SWiface.db  	/nfs/OGN/SWdata			#
fi								#
echo " "							#
echo "========================================================" #
echo "Create the MySQL database SWIFACE "			#
echo "Type the PASSword for the MySQL database SWIFACE "	#
echo "========================================================" #
echo "CREATE DATABASE SWIFACE" | mysql -u root -p		#
mysql -u root -p --database SWIFACE < main/DBschema.sql		#
echo "Create the MySQL OGN user "				#
echo "GRANT ALL PRIVILEGES ON *.* TO 'ogn'@'localhost' IDENTIFIED BY 'yourpassword'; " | mysql -u root -p     #
echo "GRANT SELECT ON *.* TO 'ognread'@'localhost'     IDENTIFIED BY 'yourpassword'; " | mysql -u root -p     #
echo " "							#
echo "Optional steps ... "					#
echo "========================================================" #
echo " "							#
echo								#
cd main								#
cp aliases ~/.bash_aliases					#
if [ ! -f /usr/local/bin/mailcatcher ]				#
then								#
	sh sh/mailcatcher.install				#
	#mailcatcher --http-ip=0.0.0.0				#
	sudo /usr/local/bin/composer self-update		#
	composer update						#
fi								#
cd sh	 							#
crontab <crontab.data						#
crontab -l 							#
if [ ! -d ~/src  ]						#
then								#
	mkdir ~/src   						#
	mkdir ~/src/SWsrc					#
	ln -s /var/www/html/main ~/src/SWsrc			#
fi								#
ls  -la ~/src 							#
if [ ! -d /nfs  ]						#
then								#
	echo							#
	echo "Adding user ogn ...	"			#
	echo "=============== ...	"			#
	sudo adduser ogn 					#
	sudo mkdir /nfs						#
	sudo mkdir /nfs/OGN					#
	sudo mkdir /nfs/OGN/SWdata				#
	sudo chown ogn:ogn /nfs/OGN/SWdata			#
	sudo chmod 777 /nfs/OGN/SWdata				#
	cd /var/www/html/					#
	mv SWiface.db /nfs/OGN/SWdata				#
	sudo chown ogn:ogn *					# 
	sudo chmod 777 *					#
	sudo chown ogn:ogn */*					# 
	sudo chmod 777 */*					#
fi								#
echo " "							#
echo "========================================================" #
echo " "							#
cd /var/www/html 						#
rm kglid.py							#
cp  main/kglid.py .						# 
if [ ! -f /usr/local/bin/calcelestial ]				#
then								#
	cd main/sh						#
	sh calcelestial.sh					#
	calcelestial -h 					#
fi								#
cd								#
sudo dpkg-reconfigure tzdata					#
sudo apt-get -y dist-upgrade					#
sudo apt-get -y autoremove					#
sudo chmod 755 /var/log/syslog					#
tail /var/log/syslog						#
touch SWinstallation.done					#
echo " "							#
echo								#
echo "========================================================================================================"	#
echo "Installation done ..."											#
echo "Review the configuration file on /etc/local and the config tail file configtail.txt  ..."			#
echo "Review the configuration of the crontab and the shell scripts on ~/src " 					#
echo "In order to execute the Silent Wings data crawler execute:  bash ~/src/SWlive.sh " 			#
echo "Check the placement of the RootDocument on APACHE2 ... needs to be /var/www/html"				#
echo "If running in Windows under Virtual Box, run dos2unix on /var/www/html & ./main & ~/src"			#
echo "Run the utilities soa2sws.py and/or sgp2sws.py in order to extract the data from SoaringSpot.com or SGP"  #
echo "Install phpmyadmin if needed !!! "                                                                        #
echo "========================================================================================================"	#
echo								#
echo " "							#
