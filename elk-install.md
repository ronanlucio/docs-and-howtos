# Setting up ELK Stack on Ubuntu

## ELASTICSEARCH

### Create firewall rules

- tcp/9200 (elasticsearch)
- tcp/5601 (kibana)

### Import   the Elasticsearch PGP Key

```
# wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
```

### Installing Elasticsearch

```
# sudo apt install apt-transport-https default-jre
# echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list
# sudo apt update 
# sudo apt install elasticsearch
```

### Edit /etc/elasticsearch.yml parameters

- cluster.name: elk
- node.name: noade-1
- network.host: 0.0.0.0
- cluster.initial_master_nodes: ["node-1"]

### Start Elasticsearch

```
$ sudo systemctl daemon-reload
$ sudo systemctl enable elasticsearch.service
```

### Checking that Elasticsearch is running

You can test that your Elasticsearch node is running by sending an HTTP request to port 9200 on localhost:
```
$ curl http://localhost:9200
```

## KIBANA

### Install Kibana

```
$ sudo apt install kibana
```

### Configure kibana to start automatically on system boot

```
$ sudo systemctl daemon-reload
$ sudo systemctl enable kibana.service
```

### Edit /etc/kibana/kibana.yml

```
server.host = 0.0.0.0
```

## LOGSTASH

### Edit /etc/logstash/logstash.yml

```
LS_NOME = /etc/logstash
```

### Configure LogStash to start automatically on system boot

```
$ sudo systemctl enable logstash.service
$ sudo systemctl start logstash
```

## Reference

https://www.elastic.co/guide/en/elastic-stack/current/installing-elastic-stack.html

## Debugging

For debudding purpose, enable journalctl login removing the option --quiet from the ExecStart command line in the elasticsearch.service file

```
$ sudo vi /ust/lib/systemd/system/elasticsearch.service
```

When systemd logging is enabled, the logging information are available using the journalctl commands:

To tail the journal
```
sudo journalctl -f
```

To list journal entries for the elasticsearch service:
```
sudo journalctl --unit elasticsearch
```

## Configuration

### Configure file /etc/elasticsearch and  specify another directory (not under default installation) for data, otherwise it's supposed to be deleted while upgrading Elasticsearch

```
path:
  data:
    - /mnt/elasticsearch
```

### Adjust system configuration

Disable swap
```
$ sudo swapoff -a
```

and edit /etc/fstab and and comment out swap lines

### Increase limit for mmapfs

```
$ sudo sysctl -w vm.max_map_count=262144
```

To set this value permanently, updade the vm.max_map_count setting int /etc/sysctl.conf.
To verify after rebooting, run sysctl vm.max_map_count

### Increase number of threads

Increase the number of threads to at least 4096 and set nproc to 4096 in /etc/security/limits.conf
```
$ sudo ulimit -u 4096
$ sudo vi /etc/security/limits.conf
```

## Secure Elastic Stack

https://www.elastic.co/guide/en/elasticsearch/reference/7.5/elasticsearch-security.html

## Enable Encrypted Communications

https://www.elastic.co/guide/en/elasticsearch/reference/7.5/encrypting-communications.html

## BEATS

### Install Filebeat

```
$ sudo apt install filebeat
$ sudo filebeat modules enable system
```

Edit and configure the files metricbeat.yml output.elasticsearch and setup.kibana

```
$ sudo filebeat setup
$ sudo systemctl start filebeat
```

### Install Metricbeat

```
$ wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
$ sudo apt-get install apt-transport-https
$ echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list

$ sudo apt update 
$ sudo apt install metricbeat
```

Edit and configure files metricbeat.yml output.elasticsearch and setup.kibana

```
$ metricbeat modules list
```

Monitor docker containers
```
$ sudo modules enable system docker auditd
```
and modify settings in the modules/docker.yml file

```
$ sudo metricbeat setup
$ sudo metricbeat -e
$ sudo systemctl enable metricbeat
```

For testing purpose
```
$ metricbeat test config
$ metricbeat test modules system cpu
$ metricbeat run -N
```

### Install Uptime Monitors

```
$ sudo apt install hearbeat
```

Edit /etc/heartbeat/heartbeat.yml and adjust output.elasticsearch, setup.kibana and add URL's to be monitored into heartbeat.monitors section

```
$ sudo heartbeat setup
$ sudo systemctl start heartbeat-elastic
```