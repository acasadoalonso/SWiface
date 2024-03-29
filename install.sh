#!/bin/bash 
echo								#
echo " "							#
echo " "							#
echo "========================================================" #
echo "Installing the Silent Wings Studio interface ...." 	#
echo "========================================================" #
echo " "							#
echo " "							#
echo								#
if [ $# -eq  0 ]; then						#
	sql='NO'						#
else								#
	sql=$1						        #
fi								#
if   [ $sql = 'MySQL' ]; then					#
        server=localhost					#
elif [ $sql = 'Mariadb' ]; then					#
        server=localhost					#
elif [ $sql = 'VM' ]; then					#
        server=172.17.0.2					#
elif [ $sql = 'docker' ]; then					#
        server=MARIADB						#
else								#
        server=localhost					#
fi								#
echo "SQL option: "$sql" Server: "$server  			#
ping -c 5 $server 						#
ping -c 5 172.17.0.2 						#
sleep 5								#
if [ ! -f /tmp/commoninstall.sh ]				#
then								#
   echo "Installing the common software"			#
   echo "=============================="			#
   bash commoninstall.sh $sql					#
   echo "=============================="			#
fi								#
echo "========================================================" #
echo "Installing the specific parts of SWS interface ...." 	#
echo "========================================================" #
cd /var/www/html/main						#
echo "  -------------------- APACHE restarting ---------------"	#
sudo cat /etc/apache2/apache2.conf html.dir 	>>temp.conf	#
sudo echo "ServerName SWserver  "               >>temp.conf	#
sudo mv temp.conf /etc/apache2/apache2.conf			#
sudo service apache2 restart					#
echo "  -------------------- APACHE restarted ---------------"	#
cd /var/www/html/main						#
echo								#
echo " "							#
echo "========================================================" #
echo " "							#
echo								#
if [ ! -f .DBpasswd    ]					#
then								#
   cp /tmp/.DBpasswd .						#
fi								#
if [ ! -f .DBpasswd    ]					#
then								#
   echo "Type DB password ..."					#
   read DBpasswd						#
   echo $DBpasswd > .DBpasswd					#
fi								#
echo "DB passwd:"$(cat .DBpasswd)				#
if [ $sql = 'MySQL' ]						#
then								#	
   echo "Type ROOT old password: "				#
   echo " "							#
   echo "========================================================" #
   echo "ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY 'ognognogn';" | sudo mysql -u root -p #
   echo "Type ROOT new password: "				#
   echo " "							#
   echo "========================================================" #
   echo "SELECT user,authentication_string,plugin,host FROM mysql.user; " | sudo mysql -u root -p #
   echo								#
   echo " "							#
   mysql_config_editor print --all				#
fi								#
if [ ! -d /etc/local ]						#
then								#
    sudo mkdir /etc/local					#
fi								#
cd /var/www/html/main						#
if [ ! -d ~/src  ]						#
then								#
	mkdir ~/src   						#
        if [ ! -d ~/src/SWSsrc  ]				#
        then							#
	   ln -s $(pwd) ~/src/SWSsrc				#
        fi							#
fi								#
echo " "							#
echo " DIR: /src ..."						#
echo "================================================" 	#
ls -la ~/src							#
echo " DIR: /src/SWSsrc ..."					#
echo "================================================" 	#
ls -la ~/src/SWSsrc						#
echo " DIR: /src/SWSsrc/sh ..."					#
echo "================================================" 	#
ls -la ~/src/SWSsrc/sh						#
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
if [ ! -f /tmp/GLIDERS.sql ]					#
then								#
	cd /tmp							#
	wget acasado.es:60080/files/GLIDERS.sql 2>/dev/null	#
fi								#	
cd /var/www/html/						#
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
echo "========================================================" #
if [ $sql = 'MySQL' ]						#
then								#		
        echo "Create the APRSogn login-path: Type assigned password"	#
	mysql_config_editor set --login-path=APRSogn --user=ogn --password
fi								#
cd /var/www/html/main						#
cp doc/.my.cnf ~/						#
echo "Create DB user ogn ...DB:"$sql				#
echo "========================================================" #
if [ $sql = 'MySQL' ]						#
then								#
   sudo mysql  --login-path=APRSogn <doc/adduser.sql		#
   echo "CREATE DATABASE if not exists SWIFACE" | mysql --login-path=APRSogn	#
   mysql --login-path=APRSogn --database SWIFACE <DBschema.sql 	#
   mysql -u ogn -p$(cat .DBpasswd)  SWIFACE </tmp/GLIDERS.sql	#
else								#
   if [ $sql = 'mariadb' ]					#
   then 							#
      echo "Installing MariaDB"					#
      sudo apt-get install -y mariadb-server mariadb-client	#
      docker stop mariadb					#
      sudo service mariadb start				#
   fi								#
   if [ $sql = 'VM' ]						#
   then 							#
      echo "Installing MariaDB on a VM"				#
      sudo apt-get install -y mariadb-client			#
   fi								#
   if [ ! $sql = 'NO' ]						#
   then								#
      echo "Add user ogn ... with password: "$(cat .DBpasswd)   #
      sudo mysql -u root -p$(cat .DBpasswd)  -h $server  <doc/adduser.sql	#
      echo "CREATE DATABASE if not exists SWIFACE" | mysql  -h $server -u ogn -p$(cat .DBpasswd)
      mysql -u ogn -p$(cat .DBpasswd)  -h $server SWIFACE <SWIFACE.sql	#
      if [ -f /tmp/GLIDERS.sql ]				#
      then							#
         mysql -u ogn -p$(cat .DBpasswd)  -h $server SWIFACE </tmp/GLIDERS.sql	#
      fi							#
   fi 								#
fi								#
cd /var/www/html/main						#
if [ $sql = 'docker' ]						#		
then								#		
   echo "Create DB in docker ogn ..."				#
   echo "========================================================" #
   echo "CREATE DATABASE if not exists SWIFACE" | sudo mysql -u ogn -p$(cat .DBpasswd) -h MARIADB
   echo "SET GLOBAL log_bin_trust_function_creators = 1; " | sudo mysql -u ogn -p$(cat .DBpasswd) -h MARIADB
   sudo mysql -u ogn -p$(cat .DBpasswd) -h MARIADB --database SWIFACE <SWIFACE.sql 
   sudo mysql -u ogn -p$(cat .DBpasswd) -h MARIADB --database SWIFACE </tmp/GLIDERS.sql
fi								#
sudo rm /tmp/GLIDERS.sql*					#
echo " "							#
echo "Optional steps ... "					#
echo "========================================================" #
echo " "							#
echo								#
cd /var/www/html/main						#
if [ ! -f     ~/.bash_aliases ]					#
then								#
    cp aliases ~/.bash_aliases					#
fi								#
cd sh	 							#
if [  -f     crontab.data ]	 				#
then								#
    crontab <crontab.data					#
    crontab -l 							#
fi								#
if [ ! -d ~/src  ]						#
then								#
	mkdir ~/src   						#
fi								#
if [ ! -d ~/src/SWSsrc ]					#
then								#
	mkdir ~/src/SWSsrc					#
	ln -s /var/www/html/main ~/src/SWSsrc			#
fi								#
ls  -la ~/src 							#
if [ ! -d /nfs/OGN/SWdata  ]					#
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
        ls -la 							#
fi								#
echo " "							#
echo "========================================================" #
echo " "							#
cd /var/www/html 						#
if [ ! -f /usr/local/bin/calcelestial ]				#
then								#
	cd main/sh						#
	sh calcelestial.sh					#
	calcelestial -h 					#
fi								#
cd								#
sudo chmod 755 /var/log/syslog					#
tail /var/log/syslog						#
touch SWSinstallation.done					#
echo " "							#
sudo apt-get -y dist-upgrade					#
sudo apt-get -y autoremove					#
echo								#
echo "========================================================================================================"	#
echo "Installation done ..."											#
echo "Review the configuration file on /etc/local and the config tail file configtail.txt  ..."			#
echo "Review the configuration of the crontab and the shell scripts on ~/src " 					#
echo "In order to execute the Silent Wings data crawler execute:  bash ~/src/SWlive.sh " 			#
echo "Check the placement of the RootDocument on APACHE2 ... needs to be /var/www/html"				#
echo "If running in Windows under Virtual Box, run dos2unix on /var/www/html & ./main & ~/src"			#
echo "Run the utilities soa2sws.py and/or sgp2sws.py in order to extract the data from SoaringSpot.com or SGP"  #
echo "========================================================================================================"	#
echo								#
echo " "							#
echo " "							#
echo " "							#
echo " "							#
echo " "							#
echo " "							#
echo " "							#
echo " "							#
echo " "							#
echo " ======================= END ==========================="	#
