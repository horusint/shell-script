#!/bin/sh

# Script desenvolvido para automatizar a instalação do antivirus F-Secure
# Criado por: Jonatas Baldin de Oliveira
# Contato: jonatas dot baldin at gmail dot com
# Data de criação 09/11/15
# Ultima modificação 24/11/15

# Vars
F_LOG=/tmp/fsecure.log
F_PACKAGES="wget compat-libstdc++-33.i686 compat-libstdc++-33.x86_64 gcc glibc-devel glibc-headers kernel-devel make perl patch net-tools nano ntsysv system-config-firewall firewall-config"
F_ZONE=$(firewall-cmd --get-default-zone)
F_AGENT="https://download.f-secure.com/corpro/pm_linux/upcoming/fspmaua-8.36.67-1.x86_64.rpm"
F_SERVER="https://download.f-secure.com/corpro/pm_linux/upcoming/fspms-12.00.67239-1.x86_64.rpm"

# Verify root
if [[ $(id -u) != 0 ]] ; then
    echo "Must be run as root. Are you root?" >> $F_LOG
    exit 1
fi

# Disable SELinux
setenforce 0
sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/sysconfig/selinux

# Update distro
if ! yum update -q -y > /dev/null; then
    echo "Cannot update the distro, verify the connection to the repositories" >> $F_LOG
    exit 1
fi

# Install packages
if ! yum install -q -y $F_PACKAGES > /dev/null ; then
    echo "Cannot install packages, verify the packages name or network connection" >> $F_LOG
    exit 1
fi

# Configure firewall
for i in 90 9090 91 ; do
    if ! firewall-cmd --permanent --zone=$F_ZONE --add-port=$i/tcp > /dev/null; then
        echo "Cannot configure firewall, verify firewall-cmd configuration" >> $F_LOG
		exit 1
    fi
done

# Restart firewall
if ! firewall-cmd --complete-reload > /dev/null; then
    echo "Cannot restart firewall. Verify configuration" >> $F_LOG
	exit 1
fi

# Download and install F-Secure
for i in $F_AGENT $F_SERVER ; do
    if ! wget $i -O /tmp/${i##*/} > /dev/null ; then
        echo "Cannot download ${i##*/}. Verify network connection" >> $F_LOG
		exit 1
    fi
    if ! rpm --quiet -i /tmp/${i##*/} > /dev/null ; then
        echo "Cannot install ${i##*/}" >> $F_LOG
		exit 1
    fi
done

# Configure F-Secure
cd / && /opt/f-secure/fspms/bin/fspms-config

# Restart services
for i in fspms fsaua ; do
    if ! systemctl restart $i > /dev/null ; then
        echo "Cannot restart service $i. Verify the configuration" >> $F_LOG
    fi
done

# Bug, restart again
sleep 10
if ! systemctl restart fsaua > /dev/null ; then
    echo "Cannot restart service fsaua. Verify the configuration" >> $F_LOG
fi

exit 0

