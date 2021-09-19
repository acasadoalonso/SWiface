FROM debian
ENV DEBIAN_FRONTEND=noninteractive 
RUN apt-get update && apt-get -y upgrade 
RUN apt-get install -y apt-utils
RUN apt-get install -y software-properties-common 		
RUN apt-get install -y python3-software-properties 		
RUN apt-get install -y build-essential 			
RUN export LC_ALL=en_US.UTF-8 && export LANG=en_US.UTF-8	
RUN apt-get install -y python3 python3-pymysql python3-openssl python3-dev python3-pip python3-mysqldb
RUN apt-get install -y mutt wget python3-rsa python3-psutil iproute2 systemd git libarchive-dev  autoconf mc    
RUN apt-get install -y pkg-config vim git-core inetutils-ping mailutils at 
RUN apt-get install -y figlet libcurl4-openssl-dev libjson-c-dev ntpdate libsqlite3-dev ssh sudo openssh-server
RUN apt-get install -y mariadb-client percona-toolkit				

RUN mkdir -p /var/run/sshd
# authorize SSH connection with root account
RUN sed -i '/^#/!s/PermitRootLogin .*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sudo service ssh restart
# change password root
RUN echo "root:docker"|chpasswd
RUN git config --global user.email "acasadoalonso@gmail.com" 
RUN git config --global user.name "Angel Casado"     
RUN set -x \
    && pip3 install --upgrade pip \
    && pip3 install --upgrade setuptools \
    && pip3 install ephem pytz geopy configparser pycountry pyopenssl uritemplate \
    && pip3 install mysqlclient requests mysql-connector-python beeprint ogn.client \
    && pip3 install tqdm psutil rsa python-dateutil  				

RUN dpkg-reconfigure tzdata					
RUN apt-get -y dist-upgrade					
RUN apt-get -y autoremove	
WORKDIR /var/www/

RUN git clone https://github.com/acasadoalonso/SWiface		main
RUN mkdir -p /var/www/data
RUN mkdir -p /var/www/local
RUN mkdir -p /var/www/html
RUN mkdir -p /var/www/html/cuc/
RUN mkdir -p /var/www/src
RUN mkdir -p /etc/local 
RUN mkdir -p /nfs/
RUN mkdir -p /nfs/OGN
RUN mkdir -p /nfs/OGN/SWdata
VOLUME /var/www
VOLUME /etc/local
VOLUME /nfs
COPY config.docker /etc/local/SWSconfig.ini
COPY DBschema.sql .
RUN sed -i 's/DBhost/DBhost= mariadb #/i'            /etc/local/SWSconfig.ini
RUN sed -i 's/DBpasswd/DBpasswd=ogn #/i'             /etc/local/SWSconfig.ini
RUN sed -i 's/DBpasswdread/DBpasswdread=ogn #/i'     /etc/local/SWSconfig.ini
ARG USER=angel
ARG UID=1000
ARG GID=1000
# default password for user
ARG PW=docker
# Option1: Using unencrypted password/ specifying password
RUN useradd -m ${USER} --uid=${UID} --shell=/bin/bash && echo "${USER}:${PW}" | \
      chpasswd
RUN echo "Welcome to the SWS application container" > /etc/motd \
    && cp -a /root /root.orig
EXPOSE 80
EXPOSE 81
EXPOSE 22
RUN touch SWSinstallation.done	
RUN service ssh start 
WORKDIR /var/www/main/
#CMD /bin/bash /usr/bin/python3 SWiface.py >/nfs/OGN/SWdata/SWiface.log 2>/nfs/OGN/SWdata/SWiface.errorlog  &&  /usr/bin/tail -f /dev/null
CMD ["/usr/bin/python3", "SWiface.py" ] 
