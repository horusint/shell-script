#!/bin/bash

# Script to install Ansible from PPA or EPEL
# If you want to improve it, just contribute!
# You can install with curl -s https://raw.githubusercontent.com/jonatasbaldin/shell-script/master/install_ansible.sh | sudo bash

# Verify root
if [ $(id -u) != 0 ] ; then
    echo "You must be root!"
    exit 1
fi

# Get OS
# Ubuntu/CentOS
if [ -f /etc/lsb-release ] ; then
    . /etc/lsb-release
    OS="$DISTRIB_ID"
    VER="$DISTRIB_RELEASE"
elif [ -f /etc/os-release ] ; then
    . /etc/os-release
    OS="$REDHAT_SUPPORT_PRODUCT" #centos 
    VER="$REDHAT_SUPPORT_PRODUCT_VERSION" #7
fi

if [ "$OS" = "LinuxMint" -o "$OS" = "Ubuntu" -o "elementary OS" ] ; then
    apt-get install software-properties-common
    apt-add-repository ppa:ansible/ansible -y
    apt-get update -o Acquire::ForceIPv4=true -y
    apt-get install ansible -o Acquire::ForceIPv4=true -y 
elif [ "$OS" = "centos" -a "$VER" -eq 7 ] ; then	
    rpm -i https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
    yum update -y
    yum install ansible -y
fi
