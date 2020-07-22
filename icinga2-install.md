# General System Configuration

## Set timezone and hostname

```
$ sudo timedatectl set-timezone Pacific/Auckland
$ sudo hostnamectl set-hostname myserver
```

# Setting up Icinga 2 on Ubuntu

```
# apt update
# apt install -y apt-transport-https wget gnupg
# wget -O - https://packages.icinga.com/icinga.key | apt-key add -
# . /etc/os-release; if [ ! -z ${UBUNTU_CODENAME+x} ]; then DIST="${UBUNTU_CODENAME}"; else DIST="$(lsb_release -c| awk '{print $2}')"; fi; \
  echo "deb https://packages.icinga.com/ubuntu icinga-${DIST} main" > /etc/apt/sources.list.d/${DIST}-icinga.list
# echo "deb-src https://packages.icinga.com/ubuntu icinga-${DIST} main" >> /etc/apt/sources.list.d/${DIST}-icinga.list
# apt update
# apt install -y icinga2
```


## Setting up Check Plugins
```
# apt install -y monitoring-plugins
```


## Running Icinga 2
```
# systemctl status icinga2
# systemctl enable icinga2
```


## Configuration Syntax Highlighting
```
# apt install -y vim-icinga2 vim-addon-manager
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
# apt install -y icinga2-ido-mysql
```

Answer **Yes** when prompted "Enable Icinga 2's ido-mysql feature?".

Answer **Yes** when prompted for "Configure database for icinga2-ido-mysql with dbconfig-common?".

You'll be asked for a password, and so this will create:

- A database **icinga2**
- A db user **icinga2** with the password you typed

If you want to perform this configuration manually, os if your database has already been installed and configured, you should refuse this option.
Defatils on what needs to be done should most likely be provided in /usr/share/doc/icinga2-ido-mysql.


```
# icinga2 feature enable ido-mysql
# systemctl restart icinga2
```

To list enabled features, run the command:
```
# icinga2 feature list
```


**Setting up MySQL**

**ATTENTION**: Execute this step only if you choose to NOT configure database on the previous step

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
  password = "YOUR*PASSWORD*HERE"
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
# apt install -y icingaweb2 libapache2-mod-php icingacli
# apt install -y php-gd
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
CREATE USER 'icingaweb2'@'%' IDENTIFIED BY 'YOUR*DB*PASSWORD*HERE';
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


## Add Remote Host to Icinga2 for Monitoring

First, confirm the Icinga2 Server (master) has tcp port 5665 allowed on the firewall

```
$ sudo ufw allow 5665
$ sudo ufw reload
```

###  Configuring Master Server

Second, we need to prepare the master server to connect to host systems:

```
$ sudo icinga2 node wizard
```

Remmember to answer **N** when asked "if this is a satellite/client setup", and after this you can access default for all other fields.

Restart icinga2 server:

```
$ sudo systemctl restart icinga2
```

### Generate a ticket for the new host

```
$ sudo icinga2 pki ticket --cn remote-host.example.com
```

Take note of the generated ticket for later usage. This will be something like "9e26a5966cd6e2d6593448214cab8d5e7bd61d59"

### Install icinga2 on the remote host

We'll have to install icinga2 on the remote host, almost the same way we did for the master one:

#### Ubuntu

```
# apt update
# apt install -y apt-transport-https wget gnupg
# wget -O - https://packages.icinga.com/icinga.key | apt-key add -
# . /etc/os-release; if [ ! -z ${UBUNTU_CODENAME+x} ]; then DIST="${UBUNTU_CODENAME}"; else DIST="$(lsb_release -c| awk '{print $2}')"; fi; \
  echo "deb https://packages.icinga.com/ubuntu icinga-${DIST} main" > /etc/apt/sources.list.d/${DIST}-icinga.list
# echo "deb-src https://packages.icinga.com/ubuntu icinga-${DIST} main" >> /etc/apt/sources.list.d/${DIST}-icinga.list
# apt update
# apt install -y icinga2 monitoring-plugins
# systemctl start icinga2
# systemctl enable icinga2
```

#### Redhat 8

````
# dnf install https://packages.icinga.com/epel/icinga-rpm-release-8-latest.noarch.rpm
# ARCH=$( /bin/arch )
# subscription-manager repos --enable rhel-8-server-optional-rpms
# subscription-manager repos --enable "codeready-builder-for-rhel-8-${ARCH}-rpms"
# dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
# dnf install icinga2
# dnf install nagios-plugins-all
# systemctl enable icinga2
# systemctl start icinga2
````

### Setup icinga2 for the remote host

```
# icinga2 node wizard
```

- Answer **Y** when asked "if this is a satellite/client setup", and answer the next question, including the request ticket generated on the Icinga2 master.
- Type your icinga2 master **server's FQDN** for "Master/Satellite Common Name"
- Answer **Y** when asked "do you want to establish a connection to the parent from this node?"
- Type your icinga2 master **server's IP address** for "Master/Satellite endpoint host"
- Answer **Y** when asked "Accept config from parent node?"
- Answer **Y** when asked "Accept commands from parent node?"
- Accept default for all other questions

**NOTE:** Write down the values shown for "Local zone name" and "Parente zone name". You'll need this values to configure it on the master server.

Restart icinga2:

```
$ sudo systemctl restart icinga2
```

### Create host config on Icinga2 master

Switch to the **master** server and create a host file:

```
$ sudo mkdir /etc/icinga2/zones.d/master
$ sudo vi /etc/icinga2/zones.d/master/agents.conf
```

Add the content to the file as below, adjusting your host's parameters:

```
// remote-host.example.com
object Endpoint "ss-api-proxy.fingermark.co.nz" {
}

object Zone "remote-host.example.com" {
  endpoints = [ "remote-host.example.com" ]
  parent = "master"
}

object Host "remote-host.example.com" {
  check_command = "hostalive"
  address = "192.168.50.5" // That's your client's host IP

  vars.agent_endpoint = name //follows the convention that host name == endpoint name
}
```

Create a services configuration file for your clients:

```
$ sudo vi /etc/icinga2/zones.d/master/services.conf
```

And add the content as below:

```
// Check System Load
apply Service "System Load" {
  check_command = "load"
  command_endpoint = host.vars.agent_endpoint // Check executed on client node
  assign where host.vars.agent_endpoint
}

// Check number of running system Processes
apply Service "Process" {
  check_command = "procs"
  command_endpoint = host.vars.agent_endpoint
  assign where host.vars.agent_endpoint
}

// Check number of Logged in Users
apply Service "Users" {
  check_command = "users"
  command_endpoint = host.vars.agent_endpoint
  assign where host.vars.agent_endpoint
}

// Check System Disk Usage
apply Service "Disk" {
  check_command = "disk"
  command_endpoint = host.vars.agent_endpoint
  assign where host.vars.agent_endpoint
}

// Check for SWAP memory Usage
apply Service "SWAP" {
  check_command = "swap"
  command_endpoint = host.vars.agent_endpoint
  assign where host.vars.agent_endpoint
}

// SSH Service Check
apply Service "SSH Service" {
  check_command = "ssh"
  command_endpoint = host.vars.agent_endpoint
  assign where host.vars.agent_endpoint

}

apply Service "Ping" {
  check_command = "ping4"
  assign where host.address
}

// Agent health-check
apply Service "agent-health" {
  check_command = "cluster-zone"

  display_name = "cluster-health-" + host.name

  /* This follows the convention that the agent zone name is the FQDN which is the same as the host object name. */
  vars.cluster_zone = host.name

  assign where host.vars.agent_endpoint
}
```

Create a dependencies file:

```
$ sudo vi /etc/icinga2/zones.d/master/dependencies.conf
```

Add the content as below:

```
apply Dependency "agent-health-check" to Service {
  parent_service_name = "agent-health"

  states = [ OK ] // Fail if the parent service state switches to NOT-OK
  disable_notifications = true

  assign where host.vars.agent_endpoint // Automatically assigns all agent endpoint checks as child services on the matched host
  ignore where service.name == "agent-health" // Avoid a self reference from child to parent
}
```

Validate your configuration

```
$ sudo icinga2 daemon -C
```

Restart icinga2:

```
$ sudo systemctl restart icinga2
```


## Addons

- [Addons and Plugins](https://icinga.com/docs/icinga2/latest/doc/13-addons/#addons)


## Official documentation

- [Installation - Icinga 2](https://icinga.com/docs/icinga2/latest/doc/02-installation/)
- [Installation - Icinga Web 2](https://icinga.com/docs/icingaweb2/latest/doc/02-Installation/)
- [Icinga Plugins, Addon, and Modules](https://exchange.icinga.com/)
- [Distributed Monitoring - Master with Agenst](https://icinga.com/docs/icinga2/latest/doc/06-distributed-monitoring/#master-with-agents)