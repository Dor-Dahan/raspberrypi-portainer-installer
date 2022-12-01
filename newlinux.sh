echo "installing docker"

sudo apt install docker.io -y

sleep 5

echo "installing fan script"

curl https://download.argon40.com/argon1.sh | bash

sleep 5

echo "installing portainer in docker"

sleep 5

sudo docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest

sleep 5

echo "installing pihole"

sleep 5

read -p 'set pihole time zone: ' timezone

read -p 'set pihole password: ' password

sleep 5

echo $timezone

echo $password

sleep 5

sudo docker run -d --name pihole -p 53:53/tcp -p 53:53/udp -p 80:80 -p 443:443 -p 8080:8080 -p 67:67/udp -e TZ="$timezone" -e WEBPASSWORD="$password" -v "$(pwd)/etc-pihole/:/etc/pihole/" -v "$(pwd)/etc-dnsmasq.d/:/etc/dnsmasq.d/" --dns=127.0.0.1 --dns=1.1.1.1 --restart=unless-stopped pihole/pihole:latest

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

sleep 5

echo "finish updating static ip"

sleep 5

echo "updating linux"

sleep 5
sudo apt-get update -y && sudo apt-get upgrade -y && sudo apt-get dist-upgrade -y

sleep 5

sleep 30

echo "rebooting"

sleep 5

sudo reboot
