docker run --net mynetsql --ip 172.18.0.2 --name mariadb -e MYSQL_ROOT_PASSWORD=ogn -d mariadb:latest --log-bin --binlog-format=MIXED --restart unless-stopped


