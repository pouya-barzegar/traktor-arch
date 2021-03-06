#!/bin/bash
sudo wget https://archusers.github.io/traktor/torrc -O /etc/tor/torrc > /dev/null

echo "Tor is trying to establish a connection. This may take long for some minutes. Please wait" | tee <(systemctl status tor)
bootstraped='n'
sudo systemctl restart tor
while [ $bootstraped == 'n' ]; do
	if grep "Bootstrapped 100%: Done" <(systemctl status tor); then
		bootstraped='y'
	else
		sleep 1
	fi
done

echo -e "\nCongratulations!!! Your computer is using Tor."