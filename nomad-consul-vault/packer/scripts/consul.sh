#!/bin/bash
set -e

CONSULVERSION=1.0.1
CONSULARCH=linux_amd64
CONSULFILE=consul_${CONSULVERSION}_${CONSULARCH}.zip
CONSULDOWNLOAD=https://releases.hashicorp.com/consul/${CONSULVERSION}/${CONSULFILE}
CONSULCONFIGDIR=/etc/consul.d
CONSULDIR=/opt/

# Consul
echo "Getting consul binary"
sudo wget -q $CONSULDOWNLOAD -O /ops/${CONSULFILE}

## Install
echo "Installing consul binary"
sudo unzip -qq /ops/${CONSULFILE} -d /usr/local/bin
sudo chmod 0755 /usr/local/bin/consul
sudo chown root:root /usr/local/bin/consul

## Configure
echo "Configuring consul directories"
sudo mkdir -p $CONSULCONFIGDIR
sudo chmod 755 $CONSULCONFIGDIR
sudo mkdir -p $CONSULDIR
sudo chmod 755 $CONSULDIR

#sudo mkdir -p /var/log/consul
#sudo mkdir -p /etc/consul
#sudo mkdir -p /var/consul
