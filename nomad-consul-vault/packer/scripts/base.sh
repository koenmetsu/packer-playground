#!/bin/bash
set -e

# Dependencies
echo "Installing unzip, tree, jq"
sudo apt-get -qq update
sudo apt-get -qq install -y software-properties-common unzip tree jq 

# Disable the firewall
echo "Disabling firewall"
sudo ufw disable