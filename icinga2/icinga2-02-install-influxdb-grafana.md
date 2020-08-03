# Setup InfluxDB + Grafana integration with Icinga2

## Requirements

1. For installing InfluxDB and Grafana, we're supposing icinga2 and icingaweb2 are already installed.
2. For this tutorial we're using Ubuntu-18.04 LTS

## Installing InfluxDB

### Install package

```
$ sudo apt install influxdb influxdb-client -y
$ sudo systemctl start influxdb
$ sudo systemctl enable influxdb
$ influx
```

### Create database and user

On influx console:
```
> CREATE DATABASE icinga2;
> CREATE USER icinga2 WITH PASSWORD 'your-icinga2-influxdb-pwd';
> quit
```

### Enable influxdb feature on icinga2

```
$ sudo icinga2 feature enable influxdb
```

### Configure icinga2 to send performance data to InfluxDB

```
$ sudo vim /etc/icinga2/features-enabled/influxdb.conf
```

and configure it as below:

```
object InfluxdbWriter "influxdb" {
  host = "127.0.0.1"
  port = 8086
  database = "icinga2"
  username = "icinga2"
  password = "your-icinga2-pwd"
  enable_send_thresholds = true
  enable_send_metadata = true
  flush_threshold = 1024
  flush_interval = 10s
  host_template = {
    measurement = "$host.check_command$"
    tags = {
      hostname = "$host.name$"
    }
  }
  service_template = {
    measurement = "$service.check_command$"
    tags = {
      hostname = "$host.name$"
      service = "$service.name$"
    }
  }
}
```

Tell Icinga2 to use InfluxDB for performance data

```
$ sudo icinga2 feature enable statusdata
$ sudo icinga2 feature enable perfdata
$ sudo icinga2 feature list
```

Restart icinga2

```
$ sudo restart icinga2
```

Check if InfluxDB is receiving data from icinga2:

```
$ influx
> USE icinga2
> SHOW MEASUREMENTS
```

it's expected to return something like

```
name
apt
disk
hostalive
http
icinga
load
ping4
ping6
procs
ssh
swap
users
```

and check if the command return any data

```
SELECT * FROM ping4
```

## Install Grafana

### Download and install

```
$ sudo apt-get install -y apt-transport-https
$ sudo apt-get install -y software-properties-common wget
$ wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
$ echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list 
$ sudo apt update
$ sudo apt install grafana
```

### Start the server

```
$ sudo systemctl daemon-reload
$ sudo systemctl start grafana-server
$ sudo systemctl status grafana-server
$ sudo systemctl enable grafana-server
```

### Configure Grafana

#### Navigate to Grafana web interface

http://YOUR-ICINGA2-SERVER:3000

Default username and password are admin/admin.

### Create new Grafana datasource

http://YOUR-ICINGA2-SERVER:3000/datasources/new?gettingstarted

- **Name:** InfluxDB-icinga2
- **Query Language:** InfluxQL
- **Default:** Yes

In "Http settings" set the access to the InfluxDB's API port, which is "http://localhost:8086" and has a "direct" access. 

- **URL:** http://127.0.0.1/8086
- **Access:** Server (default)

Grafana requires given user and password to connect to InfluxDB. Use the icinga2 user which was created above.

- **Database**: icinga2
- **User**: icinga2
- **Password**: your-icinga2-influxdb-pwd

#### Import Grafana dashboard

1. Import Dashboard: http://your-public-host.name:3000/dashboard/import
2. Paste JSON from https://raw.githubusercontent.com/Mikesch-mp/icingaweb2-module-grafana/v1.1.8/dashboards/influxdb/base-metrics.json
   or this another one:
   https://grafana.com/api/dashboards/381/revisions/1/download

#### Add Icinga Web Grafana module

**NOTE:** Directory name MUST be grafana and not icingaweb2-module-grafana or anything else

Replace the version number with the lates available version from [Latest Release](https://github.com/Mikesch-mp/icingaweb2-module-grafana/releases/latest)

```
# MODULE_VERSION="1.1.7"
# ICINGAWEB_MODULEPATH="/usr/share/icingaweb2/modules"
# REPO_URL="https://github.com/Mikesch-mp/icingaweb2-module-grafana"
# TARGET_DIR="${ICINGAWEB_MODULEPATH}/grafana"
# URL="${REPO_URL}/archive/v${MODULE_VERSION}.tar.gz"
# install -d -m 0755 "${TARGET_DIR}"
# wget -q -O - "$URL" | tar xfz - -C "${TARGET_DIR}" --strip-components 1
# mkdir /etc/icingaweb2/modules/grafana
```

#### Grafana preparation


Configure Grafana module as in the file [config.ini](files/icingaweb2-grafana-config.ini)

```
# vim /etc/icingaweb2/modules/grafana/config.ini
```

Configure graph.ini as in the file [graphs.ini](files/icingaweb2-grafana-graphs.ini)

```
# vim /etc/icingaweb2/modules/grafana/graphs.ini
```

Enable anonymous access (for icinga2 shows grafana's graphs)

```
# vim /etc/grafana/grafana.ini
```

and configure as below

```
[auth.anonymous]
# enable anonymous access
enabled = true

# specify organization name that should be used for unauthenticated users
org_name = YOUR_ORGANIZATION_NAME

# specify role for unauthenticated users
org_role = Viewer

# set to true if you want to allow browsers to render Grafana in a <frame>, <iframe>, <embed> or <object>. default is false.
allow_embedding = true
```

#### Restart Grafana

```
# systemctl restart grafana-server
```

#### Enable module

```
# icingacli module enable grafana
# chown -R www-data:icingaweb2 /etc/icingaweb2
```

Go to the service configuration and set the custom var grafana_graph_disable for all services, which have no Grafana graph: ssh, http, disk, and icinga.

```
# vim /etc/icinga2/zones.d/master/services.conf
```

Add `vars.grafana_graph_disable = true` to the services that don't have graphs

Restart Icinga

```
# systemctl restart icinga2
```

# Reference

This tutorial was based on

- https://github.com/chrisss404/icinga2-influxdb-grafana
- https://www.claudiokuenzler.com/blog/749/icinga2-graphing-influxdb-grafana#.W19_ddJKg2x
- https://github.com/Mikesch-mp/icingaweb2-module-grafana/blob/master/doc/02-installation.md
