# Terraform - Installing Manager and Worker Servers

We'll work with two servers:
- Docker Swarm Manager
- Docker Swarm Worker

## INSTALLING DOCKER ON DOCKER SWARM MANAGER

### Updating operational system
```
$ sudo yum update -y
```

### Uninstall old versions
```
$ sudo yum remove -y docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine
```

### Install Docker CE
```
$ sudo yum install -y yum-utils device-mapper-persistent-data lvm2
$ sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
$ sudo yum -y install docker-ce
```

### Start docker and enable it
```
$ sudo systemctl start docker && sudo systemctl enable docker
```

### Add user to docker group
```
$ sudo usermod -aG docker [username]
```

### check
```
$ docker --version
```

## INSTALLING DOCKER WORKER

You'll have to execute the same steps decribed on "Installing Docker on Docker Swarm Manager" to install docker

## CONFIGURING SWARM MANAGER NODE

### On the manager node, initialize the manager:
```
$ docker swarm init --advertise-addr [PRIVATE_IP]
```
writhe down the output and execute on the worker

### On the worker node, add worker to the cluster:
```
$ docker swarm join --token [TOKEN] [PRIVATE_IP]:2377
```

### Verify swarm cluster
```
$ docker node ls
```

## INSTALL TERRAFORM ON THE SWARM MANAGER

```
$ sudo curl \
   -O   https://releases.hashicorp.com/terraform/0.11.13/terraform_0.11.13_linux_amd64.zip
$ sudo yum install -y unzip
$ sudo unzip terraform_0.11.13_linux_amd64.zip -d /usr/local/bin/
$ terraform version
```
