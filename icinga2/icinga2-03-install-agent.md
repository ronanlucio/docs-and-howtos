# Installing an Agent for Remote Host Monitoring on Incinga2

## Add Remote Host to Icinga2 for Monitoring

First, confirm the Icinga2 Server (master) has tcp port 5665 allowed on the firewall

```
$ sudo ufw allow 5665
$ sudo ufw reload
```

###  Configuring Master Server

Second, we need to prepare the master server to connect to host systems.
If you've already done this for other clients, jump to next step **Generate a ticket for the new host**

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

QUESTIONS:

- Please specify if this is an agent/satellite setup ('n' installs a master setup) [Y/n]: **Y**
- Please specify the common name (CN) [YOUR_HOSTNAME]: **[ENTER]**
- Master/Satellite Common Name (CN from your master/satellite node): **your-master-server.your-domain.com**
- Do you want to establish a connection to the parent node from this node? [Y/n]: **Y**
- Master/Satellite endpoint host (IP address or FQDN): **your-master-server.your-domain.com**
- Master/Satellite endpoint port [5665]: **[ENTER]**
- Add more master/satellite endpoints? [y/N]: **N**
- Is this information correct? [y/N]: **Y**

- Please specify the request ticket generated on your Icinga 2 master (optional): **Paste the ticket generated on your icinga2 server**
- Bind Host []: **[ENTER]**
- Bind Port []: **[ENTER]**

- Accept config from parent node? [y/N]: **Y**
- Accept commands from parent node? [y/N]: **Y**

- Local zone name [YOUR HOSTNAME]: **[ENTER]**
- Parent zone name [master]: **[ENTER]**
- Do you want to specify additional global zones? [y/N]: **[ENTER]**
- Do you want to disable the inclusion of the conf.d directory [Y/n]: **[ENTER]**

**NOTE:** Write down the values shown for "Local zone name" and "Parente zone name". You'll need this values to configure it on the master server.

Restart icinga2:

```
$ sudo systemctl restart icinga2
```

### Create host config on Icinga2 master

Switch to the **master** server and create a host file:

```
$ sudo mkdir /etc/icinga2/zones.d/master
```

#### 1. Create your host file configuration

```
$ sudo vi /etc/icinga2/zones.d/master/hosts/YOUR-HOSTNAME.conf
```

Add the content to the file as below as in the file [host-remote-host.example.conf](./config/host-remote-host.example.com.conf), adjusting your host's parameters.

#### 2. Create a services files configuration

Create a services configuration file for your clients:

```
$ sudo vi /etc/icinga2/zones.d/master/services.conf
```

And add the content as below on file [services.conf](./config/services.conf)

#### 3. Create a dependencies file:

```
$ sudo vi /etc/icinga2/zones.d/master/dependencies.conf
```

Add the content as in file [dependencies.conf](./config/dependencies.conf)

#### 4. Validate your configuration

```
$ sudo icinga2 daemon -C
```

#### 5. Restart icinga2

```
$ sudo systemctl restart icinga2
```


## Official documentation

- [Distributed Monitoring - Master with Agenst](https://icinga.com/docs/icinga2/latest/doc/06-distributed-monitoring/#master-with-agents)