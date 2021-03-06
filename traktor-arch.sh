#!/bin/bash
clear

echo -e "Traktor-Arch v1.0\nTor will be automatically installed and configured…\n\n"

# Install Packages
sudo pacman -Sy
sudo pacman -S tor obfsproxy polipo dnscrypt-proxy  

# Update torrc
sudo wget https://archusers.github.io/traktor/torrc -O /etc/tor/torrc > /dev/null

# Write Polipo config
echo 'logSyslog = true
logFile = /var/log/polipo/polipo.log
proxyAddress = "::0"        # both IPv4 and IPv6
allowedClients = 127.0.0.1
socksParentProxy = "localhost:9050"
socksProxyType = socks5' | sudo tee /etc/polipo/config > /dev/null

sudo systemctl restart polipo

# Install Finish
echo "Installation Finished successfully…"
sudo systemctl start tor 1>/dev/null 2>&1
sudo systemctl enable tor 1>/dev/null 2>&1

# Wait for tor to establish connection
echo "Tor is trying to establish a connection. This may take long for some minutes. Please wait" 
bootstraped='n'
sudo systemctl restart tor 1>/dev/null 2>&1
while [ $bootstraped = 'n' ]; do
	if grep "Bootstrapped 100%: Done" <(systemctl status tor); then
		bootstraped='y'
	else
		sleep 1
	fi
done

echo -e "\nIf you want to configure other programs to use tor you have to manually set proxy to SOCKS5 127.0.0.1:9050 or HTTP 127.0.0.1:8123"
echo "Do you want to use tor on whole network? [y/N]"

read -n 1 SELECT
if [ "$SELECT" = "Y" -o "$SELECT" = "y" ]
then
	# Set IP and Port on HTTP and SOCKS
	gsettings set org.gnome.system.proxy mode 'manual'
	gsettings set org.gnome.system.proxy.http host 127.0.0.1
	gsettings set org.gnome.system.proxy.http port 8123
	gsettings set org.gnome.system.proxy.socks host 127.0.0.1
	gsettings set org.gnome.system.proxy.socks port 9050
	gsettings set org.gnome.system.proxy ignore-hosts "['localhost', '127.0.0.0/8', '::1', '192.168.0.0/16', '10.0.0.0/8', '172.16.0.0/12']"
fi

echo -e "\nDo you want to install tor-browser too? [y/N]"

read -n 1 SELECT
if [ "$SELECT" = "Y" -o "$SELECT" = "y" ]
then
yaourt -S tor-browser-en
fi

# update finished
echo -e "\nCongratulations!!! Your computer is using Tor."