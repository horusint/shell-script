#!/bin/sh 

# Script developed to bootstrap my personal computer in one command
# You can install with curl -s https://raw.githubusercontent.com/jonatasbaldin/shell-script/master/pc_deploy.sh | sudo bash

# Verify root
if [[ $(id -u) != 0 ]] ; then
    echo "Must be run as root. Are you root?"
    exit 1
fi

# Update repo
apt-get update -y

# Install git
apt-get install git -y

# Install ansible
curl -s https://raw.githubusercontent.com/jonatasbaldin/shell-script/master/install_ansible.sh | sudo bash

# Clone repo
cd $HOME && git clone https://github.com/jonatasbaldin/pc-deploy.git

# Runs ansbile-playbook
cd $HOME/pc-deploy && ansible-playbook -c local -b --ask-become-pass -i hosts site.yml

# Remove pc-deploy repo
cd $HOME && rm -rfv pc-deploy/
