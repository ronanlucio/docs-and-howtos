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
$ sudo vi /etc/icinga2/zones.d/master/agents.conf
```

Add the content to the file as below, adjusting your host's parameters:

```
// remote-host.example.com
object Endpoint "remote-host.example.com" {
}

object Zone "remote-host.example.com" {
  endpoints = [ "remote-host.example.com" ]
  parent = "master"
}

object Host "remote-host.example.com" {
  check_command = "hostalive"
  address = "192.168.50.5" // That's your client's host IP

  // check_disk
  vars.disks["disk /"] = {
    disk_partitions = "/"
  }

  // check_http
  vars.http_vhosts["http"] = {
    http_address = "remote-host.example.com"
    http_vhost = "remote-host.example.com"
    http_uri = "/"
  }

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
apply Service for (disk => config in host.vars.disks) {
  import "generic-service"

  check_command = "disk"

  vars += config
  command_endpoint = host.vars.agent_endpoint

  assign where host.vars.agent_endpoint
}

apply Service for (http_vhost => config in host.vars.http_vhosts) {
  import "generic-service"
  check_command = "http"

  vars += config
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


## Official documentation

- [Distributed Monitoring - Master with Agenst](https://icinga.com/docs/icinga2/latest/doc/06-distributed-monitoring/#master-with-agents)