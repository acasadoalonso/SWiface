docker run --net mynetsql --ip 172.18.0.4 --name swiface --add-host mariadb:172.18.0.2 --restart unless-stopped -d swiface:latest
