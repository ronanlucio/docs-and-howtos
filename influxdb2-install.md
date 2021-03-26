# Install InfluxDB-2

For this tutorial, we'll install the docker version.


## Define data directory

We'll create an additional disk and mount it as /data. Create a subdir named influxdb/data and influxdb/config


## Run influxdb and generate a config file

```
$ cd /data/influxdb/data
$ docker run -p 8086:8086 \
      -v $PWD:/var/lib/influxdb2 \
      influxdb:2.0.4
```

Now run the command below:

```
$ docker run --rm influxdb:2.0 influxd print-config > /data/influxdb/config/config.yml
```

Stop the first container execution

## Create a start-container script

```
#!/bin/sh

INFLUXDB_DIR="/data/influxdb"

cd $INFLUXDB_DIR
docker run -d -p 8086:8086 \
	--name influxdb2 \
	--restart unless-stopped \
	-v $PWD/data:/var/lib/influxdb2 \
	-v $PWD/config/config.yml:/etc/influxdb2/config.yml \
	influxdb:2.0.4

```

Give execution permission to the script

```
$ chmod +x start-influxdb.sh
```

## Access URL at port 8086

Access InfluxDB via URL and walkthrough the config process

http://<SERVER>:8086


## Creating additional users

InfluxDB version 2.0.4 doen't allow creating user via UI, so you need to do it via command line.

First, still in the UI, click on "Data" -> "Tokens" and copy your admin's token.

Now, SSH to InfluDB server and execute the the command below:

```
$ docker ps
$ docker exec influxdb2 influx user create -n <username> -p <password> \
	-o <organization_name> -t <token>
```
