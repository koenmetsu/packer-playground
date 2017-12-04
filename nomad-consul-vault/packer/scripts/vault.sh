#!/bin/bash
set -e

VAULTVERSION=0.9.0
VAULTARCH=linux_amd64
VAULTFILE=vault_${VAULTVERSION}_${VAULTARCH}.zip
VAULTDOWNLOAD=https://releases.hashicorp.com/vault/${VAULTVERSION}/${VAULTFILE}
VAULTCONFIGDIR=/etc/vault.d
VAULTDIR=/opt/vault

# Vault
echo "Getting vault binary"
sudo wget -q $VAULTDOWNLOAD -O /ops/${VAULTFILE}

## Install
echo "Installing vault binary"
sudo unzip -qq /ops/${VAULTFILE} -d /usr/local/bin
sudo chmod 0755 /usr/local/bin/vault
sudo chown root:root /usr/local/bin/vault

## Configure
echo "Configuring vault directories"
sudo mkdir -p $VAULTCONFIGDIR
sudo chmod 755 $VAULTCONFIGDIR
sudo mkdir -p $VAULTDIR
sudo chmod 755 $VAULTDIR

#sudo mkdir -p /var/log/vault
#sudo mkdir -p /etc/vault
#sudo mkdir -p /var/vault
