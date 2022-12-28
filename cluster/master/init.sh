#!/bin/bash

sudo DEBIAN_FRONTEND=noninteractive apt-get -y install git
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install python2
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install python3-virtualenv
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install default-jre
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install python2-pip-whl
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install python2-setuptools-whl

# docker
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update

sudo chmod a+r /etc/apt/keyrings/docker.gpg
sudo apt-get update

sudo DEBIAN_FRONTEND=noninteractive apt-get -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin

sudo usermod -aG docker ubuntu

sudo apt-get -y install sysbench
sudo apt-get -y install mysql-client

wget https://downloads.mysql.com/docs/sakila-db.tar.gz
sudo tar -xvf sakila-db.tar.gz -C /home/ubuntu

git clone https://github.com/mikface/cloud_assignment_final.git /home/ubuntu/cloud
docker compose -f /home/ubuntu/cloud/cluster/master/docker-compose.yml up -d

until sudo mysql -h 127.0.0.1 -u root -ppassword < /home/ubuntu/cloud/cluster/master/set-replication-user.sql
do
  echo 'retrying DB Master user setup'
done
