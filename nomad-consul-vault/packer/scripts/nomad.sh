#!/bin/bash
set -e

NOMADVERSION=0.7.0
NOMADARCH=linux_amd64
NOMADFILE=nomad_${NOMADVERSION}_${NOMADARCH}.zip
NOMADDOWNLOAD=https://releases.hashicorp.com/nomad/${NOMADVERSION}/${NOMADFILE}
NOMADCONFIGDIR=/etc/nomad.d
NOMADDIR=/opt/nomad

# Nomad
echo "Getting nomad binary"
sudo wget -q $NOMADDOWNLOAD -O /ops/${NOMADFILE}

## Install
echo "Installing nomad binary"
sudo unzip -qq /ops/${NOMADFILE} -d /usr/local/bin
sudo chmod 0755 /usr/local/bin/nomad
sudo chown root:root /usr/local/bin/nomad

## Configure
echo "Configuring nomad directories"
sudo mkdir -p $NOMADCONFIGDIR
sudo chmod 755 $NOMADCONFIGDIR
sudo mkdir -p $NOMADDIR
sudo chmod 755 $NOMADDIR

#sudo mkdir -p /var/log/nomad
#sudo mkdir -p /etc/nomad
#sudo mkdir -p /var/nomad
