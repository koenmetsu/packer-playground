#!/bin/bash

set -e

CONFIGDIR=/ops/config

CONSULCONFIGDIR=/etc/consul.d
VAULTCONFIGDIR=/etc/vault.d
NOMADCONFIGDIR=/etc/nomad.d
HOME_DIR=ubuntu

# Wait for network
sleep 15

# IP_ADDRESS=$(curl http://instance-data/latest/meta-data/local-ipv4)
IP_ADDRESS="$(/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')"
DOCKER_BRIDGE_IP_ADDRESS=(`ifconfig docker0 2>/dev/null|awk '/inet addr:/ {print $2}'|sed 's/addr://'`)
CLOUD=$1
SERVER_COUNT=$2
RETRY_JOIN=$3

# Consul
sed -i "s/IP_ADDRESS/$IP_ADDRESS/g" $CONFIGDIR/consul.json
sed -i "s/SERVER_COUNT/$SERVER_COUNT/g" $CONFIGDIR/consul.json
sed -i "s/RETRY_JOIN/$RETRY_JOIN/g" $CONFIGDIR/consul.json
sudo cp $CONFIGDIR/consul.json $CONSULCONFIGDIR
sudo cp $CONFIGDIR/consul_$CLOUD.service /etc/systemd/system/consul.service

sudo systemctl start consul.service
sleep 10
export CONSUL_HTTP_ADDR=$IP_ADDRESS:8500
export CONSUL_RPC_ADDR=$IP_ADDRESS:8400

# Vault
sed -i "s/IP_ADDRESS/$IP_ADDRESS/g" $CONFIGDIR/vault.hcl
sudo cp $CONFIGDIR/vault.hcl $VAULTCONFIGDIR
sudo cp $CONFIGDIR/vault.service /etc/systemd/system/vault.service

sudo systemctl start vault.service

# sleep 5
# export VAULT_ADDR=http://127.0.0.1:8200
# TOKEN=$(grep 'Root Token' /var/log/vault/out | tail -n1 | awk '{print $3}')
# echo $TOKEN | vault auth -
# vault token-create -id="1e9e1f5a-3c23-a5d2-d308-ed2c3dd541c4"
# vault auth 1e9e1f5a-3c23-a5d2-d308-ed2c3dd541c4
# vault policy-write secret /vagrant/acl.hcl
# vault write /auth/token/roles/nomad-cluster @/vagrant/nomad-cluster-role.json
# vault policy-write nomad-server /vagrant/nomad-server-policy.hcl
#echo -n "12345" | vault write secret/password value=-

# Nomad
sed -i "s/SERVER_COUNT/$SERVER_COUNT/g" $CONFIGDIR/nomad.hcl
sudo cp $CONFIGDIR/nomad.hcl $NOMADCONFIGDIR
sudo cp $CONFIGDIR/nomad.service /etc/systemd/system/nomad.service

sudo systemctl start nomad.service
sleep 10
export NOMAD_ADDR=http://$IP_ADDRESS:4646

# Add hostname to /etc/hosts
echo "127.0.0.1 $(hostname)" | sudo tee --append /etc/hosts

# Add Docker bridge network IP to /etc/resolv.conf (at the top)
echo "nameserver $DOCKER_BRIDGE_IP_ADDRESS" | sudo tee /etc/resolv.conf.new
cat /etc/resolv.conf | sudo tee --append /etc/resolv.conf.new
sudo mv /etc/resolv.conf.new /etc/resolv.conf

# Set env vars for tool CLIs
echo "export CONSUL_RPC_ADDR=$IP_ADDRESS:8400" | sudo tee --append /home/$HOME_DIR/.bashrc
echo "export CONSUL_HTTP_ADDR=$IP_ADDRESS:8500" | sudo tee --append /home/$HOME_DIR/.bashrc
echo "export VAULT_ADDR=http://$IP_ADDRESS:8200" | sudo tee --append /home/$HOME_DIR/.bashrc
echo "export NOMAD_ADDR=http://$IP_ADDRESS:4646" | sudo tee --append /home/$HOME_DIR/.bashrc
