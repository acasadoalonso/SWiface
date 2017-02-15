## Development Setup
1. Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads) and [Vagrant](https://www.vagrantup.com/)

2. Clone and run [Scotch Box](https://box.scotch.io/), a full-featured development environment for php
   ```
   git clone https://github.com/scotch-io/scotch-box.git SWIFACE
   cd SWIFACE
   vagrant up
   ```

3. Clone SWIFACE repository into the webroot of the Scotch Box
   ```
   rm ./public/index.php
   git clone https://github.com/glidernet/SWiface-PHP public
   git clone https://github.com/glidernet/SWiface     public/main
   vagrant ssh
   # The following commands get executed in the vm
   cd /var/www/public/main
   bash install.sh
   ```

4. Access your local SWIFACE instance at [192.168.33.10](http://192.168.33.10)

5. (optional, for email debugging) Run [MailCatcher](http://mailcatcher.me/), accessible at [192.168.33.10](http://192.168.33.10:1080)
   ```
   vagrant@scotchbox:~$ mailcatcher --http-ip=0.0.0.0
   composer update
   ```
