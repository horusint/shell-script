# Copies my SSH key to the machine

# Put this on a webserver and use
# curl http://webserver/script | bash

key="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDFPeC7xLsGo7mjOLp0Rr/kpDG27XbEa886aLT4gFLJ2vUDtorcMbyGkoymuxF35PScf7DQf/0vtuoFgSrzRfaIEExze93xI3gw4jQaJ7blLVccaZDOHYKH2Q166YXAcik7r9z0nZMj3elZ6cYOXWJrN4nisa6oMmxjIHKAXqo/AzoelE2ysPLy9kGv/x1pI2VtLhJwp6I/ZfNMxAnGlQl0UShL+5Jvts/VycOtn6cYfkHZH1kMlcSV9Ye8TaRdpvT41eBGd/BZdrDPAVP4x61b4065r1v9vwpiQsFcLzIcFWIV5bndU6HdxrTPAtx7QB8Pamwf2E3NocDv4upL1piH jonatas@baldin"

keyfile=~/.ssh/authorized_keys

# Check the folder existence
if [ ! -d ~/.ssh ] ; then
	mkdir ~/.ssh
fi

# Check the file existence
if [ ! -f "$keyfile" ] ; then
	> "$keyfile" 
fi

# Copies the key
if grep "$key" "$keyfile"; then 
	exit 0 
else 
	echo "$key" >> "$keyfile" 
	exit 0
fi

exit 1
