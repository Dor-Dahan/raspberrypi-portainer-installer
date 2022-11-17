echo "updating java"

sleep 5

sudo apt-get update -y && sudo apt-get install -y \
    unzip \
    wget \
    default-jre \
    nginx

sleep 5

echo "installing fan script"

curl https://download.argon40.com/argon1.sh | bash

sleep 5

echo "downloading docker script"

curl -fsSL https://get.docker.com -o get-docker.sh

sleep 5

echo "activating docker script"

sleep 5

sudo sh ./get-docker.sh

sleep 5

echo "installing portainer in docker"

sleep 5

sudo docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest

sleep 5

echo "updating linux"

sleep 5

sudo apt-get update && sudo apt-get upgrade && sudo apt-get dist-upgrade

sleep 5

ip r | grep default

grep "nameserver" /etc/resolv.conf

sleep 5

read -p 'set static ip address: ' ipaddress

read -p 'static routers: ' staticrouters

read -p 'set domin name server: ' domainserver

sleep 5

echo "updating static ip"

sleep 5

echo "interface wlan0" >> /etc/dhcpcd.conf

echo "static ip_address=$ipaddress/24" >> /etc/dhcpcd.conf

echo "static routers=$staticrouters" >> /etc/dhcpcd.conf

echo "static domain_name_servers=$domainserver" >> /etc/dhcpcd.conf

sleep 30
sudo reboot
