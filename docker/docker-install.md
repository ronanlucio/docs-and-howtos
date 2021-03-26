# Docker Install

## Ubuntu

### apt update

```
sudo apt update
```

### Install dependency packages

```
sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release
```

### Add docker's official gpg

```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
```

### Add stable repository

```
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

### Install docker

```
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io
```

### Grep permissions to user

```
sudo usermod -aG docker $USER
```
