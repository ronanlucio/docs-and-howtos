# Setting up Icinga 2 on Ubuntu

```
# apt update
# apt install -y apt-transport-https wget gnupg
# wget -O - https://packages.icinga.com/icinga.key | apt-key add -
# . /etc/os-release; if [ ! -z ${UBUNTU_CODENAME+x} ]; then DIST="${UBUNTU_CODENAME}"; else DIST="$(lsb_release -c| awk '{print $2}')"; fi; \
  echo "deb https://packages.icinga.com/ubuntu icinga-${DIST} main" > \
  /etc/apt/sources.list.d/${DIST}-icinga.list
  echo "deb-src https://packages.icinga.com/ubuntu icinga-${DIST} main" >> \
  /etc/apt/sources.list.d/${DIST}-icinga.list
# apt update
# apt install icinga2
```


## Setting up Check Plugins
```
# apt install monitoring-plugins
```


## Running Icinga 2
```
# systemctl status icinga2
```


## Configuration Syntax Highlighting
```
# apt install vim-icinga2 vim-addon-manager
# vim-addon-manager -w install icinga2
```


## Setting up Icinga Web 2
**Installing MySQL**
```
# apt install mysql-server mysql-client
# mysql_secure_installation
```


**Installing IDO modules (Icinga Data Output) for MySQL**
```
# apt install icinga2-ido-mysql
```
Answer Yes when prompted, enable Icinga 2 to use MySQL as the backend database.
If not enabled, this feature can be enabled later by running the command:
```
# icinga2 feature enable ido-mysql
# systemctl restart icinga2
```

To list enabled features, run the command:
```
# icinga2 feature list
```


**Setting up MySQL**
```
# mysql -u root -p

CREATE DATABASE icinga2;
GRANT SELECT, INSERT, UPDATE, DELETE, DROP, CREATE VIEW, INDEX, EXECUTE ON icinga2.* TO 'icinga2'@'localhost' IDENTIFIED BY 'icinga2';
quit

# mysql -u root -p icinga < /usr/share/icinga2-ido-mysql/schema/mysql.sql
```


**Enabling the IDO MySQL module**

The package provides a new configuration file that is installed in /etc/icinga2/features-available/ido-mysql.conf. You can update the database credentials in this file.

All available attributes are explained in the [IdoMysqlConnection](https://icinga.com/docs/icinga2/latest/doc/09-object-types/#objecttype-idomysqlconnection) object chapter.

You can enable the ido-mysql feature configuration file using icinga2 feature enable:
```
# icinga2 feature enable ido-mysql
Module 'ido-mysql' was enabled.
Make sure to restart Icinga 2 for these changes to take effect.

# systemctl restart icinga2
```

**Installing Webserver**
```
# apt install apache2
```

**Allow port 80 or 443 in your firewall**


**Setting up Icinga REST API**
1. Enable api feature
2. Set up certificates
3. Setup new API user root with an auto-generated password
```
# icinga2 api setup
```

Edit /etc/icinga2/conf.d/api-users.conf file and add a new ApiUser object. Specify the permissions attribute with minimal permissions required by Icinga Web 2.
```
# vim /etc/icinga2/conf.d/api-users.conf

object ApiUser "icingaweb2" {
  password = "Wijsn8Z9eRs5E25d"
  permissions = [ "status/query", "actions/*", "objects/modify/*", "objects/query/*" ]
}
```

**Restart Icinga2 to activate the configuration**
```
# systemctl restart icinga2
```


## Installing Icinga Web 2
**Install Icinga Web 2**
```
# apt install icingaweb2 libapache2-mod-php icingacli
# apt install php-gd
```


**Prepareing Web Setup**
Generate a token for further authentication on Setup Wizard
```
# icingacli setup token create
```
If you need to get the token again, just execute:
```
# icingacli setup token show
```

**Create Icinga Web 2 Database**
```
# mysql -u root -p

CREATE DATABASE icingaweb2;
CREATE USER 'icinbaweb2'@'%' IDENTIFIED BY 'icingaweb2';
GRANT ALL PRIVILEGES ON icingaweb2.* TO 'icingaweb2'@'%';
quit
```


## Starting Web Setup 
Finally visit Icinga Web 2 in your browser to access the setup wizard and complete the installation: http://localhost/icingaweb2/setup

1. Type database settings to connect to icingaweb2 DB
2. Type database settings to connect to icinga2 DB
3. Inform username and password to authenticate on the web login
4. Inform IDO settings (located on file /etc/icinga2/conf.d/api-users.conf)

NOTE: Use the same database, user and password details created above when asked.


## Addons

- [Addons and Plugins](https://icinga.com/docs/icinga2/latest/doc/13-addons/#addons)


## Official documentation

- [Installation - Icinga 2](https://icinga.com/docs/icinga2/latest/doc/02-installation/)

- [Installation - Icinga Web 2](https://icinga.com/docs/icingaweb2/latest/doc/02-Installation/)