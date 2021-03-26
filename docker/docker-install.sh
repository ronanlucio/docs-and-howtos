#!/bin/bash

# apt update
sudo apt update

# install dependency packages
sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release

# add docker's official gpg
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# add stable repository
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# install docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io

# grep permissions to user
USER=$(echo $USER)
if [[ "$USER" != "root" ]]; then
    sudo usermod -aG docker $USER
fi
