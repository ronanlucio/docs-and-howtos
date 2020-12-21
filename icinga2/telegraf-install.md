# Install InfluxDB + Telegraf + Grafana

## Adding Influx and Telegraf repositories

#### Ubuntu

```
$ wget -qO- https://repos.influxdata.com/influxdb.key | sudo apt-key add -
$ source /etc/lsb-release
$ echo "deb https://repos.influxdata.com/${DISTRIB_ID,,} ${DISTRIB_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/influxdb.list

$ sudo apt-get update
$ sudo apt-get install apt-transport-https
```

#### RedHat / CentOS

 ```
wget https://dl.influxdata.com/influxdb/releases/influxdb-1.8.3.x86_64.rpm
sudo yum localinstall influxdb-1.8.3.x86_64.rpm
 ```

## InfluxDB

### Install InfluxDB

```
$ sudo systemctl start influxdb
$ sudo systemctl enable influxdb
```

Confirm it's running

```
$ sudo lsof -i -P -n | grep LISTEN
```

### Create a database and user

```
$ influx

> create database telegraf
> create user telegraf with password 'YOUR-PASSWORD-HERE'
> show databases
> show users
```

### Confirm the HTTP and authentication are enabled

```
$ sudo vi /etc/influxdb/influxdb.conf
```

and confir parameteres below are set:

```
[http]
  # Determines whether HTTP endpoint is enabled.
  enabled = true

  # Determines whether the Flux query endpoint is enabled.
  flux-enabled = true

  # The bind address used by the HTTP service.
  bind-address = ":8086"

  # Determines whether user authentication is enabled over HTTP/HTTPS.
  auth-enabled = true
```

Restart InfluxDB

```
$ sudo systemctl restart influxdb
```

Try to run the unauthenticated request that we run during the installation process.
You're supposed to get an error

```
$ curl -G http://localhost:8086/query --data-urlencode "q=SHOW DATABASES" {"error":"unable to parse authentication credentials"}
```

And test it passing authentication parameters:

```
$ curl -G http://localhost:8086/query -u USERNAME:PASSWORD --data-urlencode "q=SHOW DATABASES"
```

## Telegraf

### Install Telegraf

```
$ sudo apt install telegraf -y
$ sudo systemctl start telegraf
$ sudo systemctl enable telegraf
```

### Configure Telegraf

#### Linux

```
$ cd /etc/telegraf/
$ mv telegraf.conf telegraf.conf.default
$ vim telegraf.conf
```

And paste the content below (just remember to adjust **hostname** and database's **username** and **password**):

```
# Global Agent Configuration
[agent]
  hostname = "node1"
  flush_interval = "15s"
  interval = "15s"


# Input Plugins
[[inputs.cpu]]
    percpu = true
    totalcpu = true
    collect_cpu_time = false
    report_active = false
[[inputs.disk]]
    ignore_fs = ["tmpfs", "devtmpfs", "devfs"]
[[inputs.io]]
[[inputs.mem]]
[[inputs.net]]
[[inputs.system]]
[[inputs.swap]]
[[inputs.netstat]]
[[inputs.processes]]
[[inputs.kernel]]

# Output Plugin InfluxDB
[[outputs.influxdb]]
  database = "telegraf"
  urls = [ "http://127.0.0.1:8086" ]
  username = "telegraf"
  password = "YOUR-PASSWORD-HERE"
```

Restart Telegraf

```
$ systemctl restart telegraf
```

And confirm it's sending data to InfluxDB (confirm there's no errors when restarting the service)

```
$ sudo journalctl -f -u telegraf.service
```

### Configure HTTPS on InfluxDB

This step aims to fonfigure a secure protocol for Telegraf and InfluxDB communication.

#### Create a private and public keys for your InfluxDB server

```
$ sudo apt-get install gnutls-utils
$ sudo mkdir /etc/ssl/influxdb && cd /etc/ssl/influxdb
$ sudo certtool --generate-privkey --outfile /etc/ssl/influxdb/influxdb-server-key.pem --bits 2048
```

And now, let's create a public key

```
$ sudo certtool --generate-self-signed --load-privkey /etc/ssl/influxdb/influxdb-server-key.pem --outfile /etc/ssl/influxdb/influxdb-server-cert.pem
$ sudo chown influxdb:influxdb /etc/ssl/influxdb/server-key.pem /etc/ssl/influxdb/server-cert.pem
```

#### Update influxdb.conf file

Edit file **/etc/influxdb/influxdb.conf** and adjust the following lines:

```
# Determines whether HTTPS is enabled.
  https-enabled = true

# The SSL certificate to use when HTTPS is enabled.
https-certificate = "/etc/ssl/influxdb/influxdb-server-cert.pem"

# Use a separate private key location.
https-private-key = "/etc/ssl/influxdb/influxdb-server-key.pem"
```

Restart the InfluxDB service and make sure that you are not getting any errors.

```
$ sudo systemctl restart influxdb
$ sudo journalctl -f -u influxdb.service
```

### Configure Telegraf for HTTPS

Edit file **/etc/telegraf/telegraf.conf** and modify the following lines:

```
# Configuration for sending metrics to InfluxDB
[[outputs.influxdb]]

# https, not http!
urls = ["https://127.0.0.1:8086"]

## Use TLS but skip chain & host verification
insecure_skip_verify = true
```

In this case, we're setting "insecure_skip_verify" to true because we're using a self-signed certificate.

Restart Telegraf, and again make sure that you are not getting any errors.

```
$ sudo systemctl restart telegraf
$ sudo journalctl -f -u telegraf.service
```