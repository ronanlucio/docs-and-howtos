# Installing GoCD Server on Ubuntu 20.04

## Add Repository

```
$ echo "deb https://download.gocd.org /" | sudo tee /etc/apt/sources.list.d/gocd.list
$ curl https://download.gocd.org/GOCD-GPG-KEY.asc | sudo apt-key add -
$ sudo apt-get update
$ sudo apt-get install go-server -y
```

## Start GoCD Server

```
$ sudo systemctl start go-server
$ sudo systemctl enable go-server
```

## Configuration

### Startup arguments and environment

You can customize startup arguments and environment edition files below:

- /usr/share/go-server/wrapper-config/wrapper-properties.conf
- /usr/share/go-server/wrapper-config/wrapper.conf

### Server Configuration

#### Artifacts

GoCD needs no configuration once installed. However, we recommend that you create a separate partition on your computer’s hard disk for GoCD server artifacts.

Once you have created a new disk partition, you need to tell GoCD where to find it.

Click on **Admin** tab -> **Server Configuration**, and click on **Artifacts Management** section. Type your new partition on the **Artificats Directory Location** field.

### Site URL

Click on **Server Management** session and type your server's URL in a way GoCD can send the right URL on email notifications.

### Email Server

Also configure your email server.

## Access Dashboard page

http://localhost:8153/go


## References

https://docs.gocd.org/current/installation/install/server/linux.html


