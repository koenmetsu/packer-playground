#!/bin/bash
set -e

#DOCKERREPO=ubuntu-`lsb_release -c | awk '{print $2}'`
DOCKERREPO=ubuntu-zesty

# Docker
echo "Installing Docker"
echo deb https://apt.dockerproject.org/repo $DOCKERREPO main | sudo tee /etc/apt/sources.list.d/docker.list
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
sudo apt-get -qq update
sudo apt-get -qq install -y docker-engine
