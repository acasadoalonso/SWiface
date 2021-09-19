create user root@'%' identified by 'ogn';
grant all privileges on *.* to root@'%';
create user ogn@'%' identified by 'ogn';
grant all privileges on *.* to ogn@'%';
flush privileges;
quit

