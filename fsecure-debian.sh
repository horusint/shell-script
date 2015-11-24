#!/bin/sh

# Script desenvolvido para automatizar a instalação do antivirus F-Secure
# Criado por: Jonatas Baldin de Oliveira
# Contato: jonatas dot baldin at gmail dot com
# Data de criação 14/11/15
# Ultima modificação 14/11/15

# Vars
F_LOG=/tmp/fsecure.log
F_PACKAGES="rpm ssh libstdc++5 libstdc++5:i386 make gcc wget nano patch iotop lynx linux-headers-`uname -r` iptables-persistent libstdc++6:i386 libgcc1:i386 zlib1g:i386 libncurses5:i386"
F_AGENT="download.f-secure.com/corpro/pm_linux/current/fspmaua_8.36.67_amd64.deb"
F_SERVER="download.f-secure.com/corpro/pm_linux/current/fspms_12.00.67239_amd64.deb"

# Verify root
if [ $(id -u) != 0 ] ; then
    echo "Must be run as root. Are you root?" >> $F_LOG
    exit 1
fi

# Add i386 Architecture
if ! dpkg --add-architecture i386 > /dev/null ; then
    echo "Cannot add architecture, verify the connection to the repositories" >> $F_LOG
    exit 1
fi

# Update distro
if ! apt-get update -qq -y > /dev/null; then
    echo "Cannot update the distro, verify the connection to the repositories" >> $F_LOG
    exit 1
fi

# Install packages
if ! apt-get install -qq -y $F_PACKAGES > /dev/null ; then
    echo "Cannot install packages, verify the packages name or network connection" >> $F_LOG
    exit 1
fi

# Configure firewall
for i in 80 8080 8081 ; do
    if ! iptables -A INPUT -p tcp --dport $i -j ACCEPT > /dev/null; then
        echo "Cannot configure firewall, verify iptables configuration" >> $F_LOG
	exit 1
    fi
done

# Save firewall
if ! iptables-save > /etc/iptables.up.rules > /dev/null; then
    echo "Cannot save firewall. Verify configuration" >> $F_LOG
    exit 1
fi

# Create firewall configuration
cat << EOF > /etc/network/if-pre-up.d/iptables
#!/bin/sh
/sbin/iptables-restore < /etc/iptables.up.rules
EOF

# Make firewall configuration executable
chmod +x /etc/network/if-pre-up.d/iptables

# Download and install F-Secure
for i in $F_AGENT $F_SERVER ; do
    if ! wget $i -O /tmp/${i##*/} > /dev/null ; then
        echo "Cannot download ${i##*/}. Verify network connection" >> $F_LOG
	exit 1
    fi
    if ! dpkg -i /tmp/${i##*/} > /dev/null ; then
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
