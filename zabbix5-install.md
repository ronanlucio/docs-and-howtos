# Set up Zabbix 5 on Ubuntu Focal (20.04)

## Install MySQL and create initial database
For the database server, execute
```
$ sudo apt install mysql-server -y
$ sudo systemctl start mysql

$ mysql -u root -p

mysql> create database zabbix character set utf8 collate utf8_bin;
mysql> create user zabbix@localhost identified by 'Z4bbix-AnythingRandom';
mysql> grant all privileges on zabbix.* to zabbix@localhost;
mysql> quit;
```

## Install Zabbix repository
```
# wget https://repo.zabbix.com/zabbix/5.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_5.0-1+focal_all.deb
# dpkg -i zabbix-release_5.0-1+focal_all.deb
# apt update
```

## Install Zabbix server, frontend, agent
```
# apt install zabbix-server-mysql zabbix-frontend-php zabbix-nginx-conf zabbix-agent
```

## Import initial database schema and data
On Zabbix server host import initial schema and data. You will be prompted to enter your newly created password.
```
zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | mysql -u zabbix -p --database=zabbix
```

## Configure database access
Edit zabbix_server.conf file and configure variables **DBHost** and **DBPassword**

```
$ sudo vi /etc/zabbix/zabbix_server.conf
```

## Configure PHP and Zabbix frontend
Edit file **/etc/nginx/conf.d/zabbix.conf**, uncomment and set 'listen' and 'server_name' directives
```
# listen 80;
# server_name example.com;
```

NOTE: If you want to make zabbix your default website, set **server_name _;** instead and remove the symbolic link "/etc/nginx/sites-enabled/default"

## Set timezone

```
$ sudo timedatectl set-timezone Pacfic/Auckland
```

Edit file **/etc/zabbix/php-fpm.conf** and configure timezone for
```
php_value[date.timezone] = [YOUR_TIMEZONE]]
```

## Start Zabbix server and agent processes
Start Zabbix server and agent processes and make it start at system boot.

```
# systemctl restart zabbix-server zabbix-agent nginx php7.4-fpm
# systemctl enable zabbix-server zabbix-agent nginx php7.4-fpm
```

## Configure Zabbix frontend
Connect to your newly installed Zabbix frontend: http://localhost and follow the steps

1. Follow steps to finish the installation
2. Log in to Zabbix. Default username is:
   1. Username: Admin
   2. Password: zabbix