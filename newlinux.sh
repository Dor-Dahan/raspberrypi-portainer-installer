#!/bin/bash
usage="$(basename "$0") [-h] [-s n] -- test 
where:
        -H|H|-h|h  show this help text
        -A|A|-a|a install all docker & portainer & argon40
        -D|D|-d|d install docker only
        -P|P|-p|p install portainer only
        -ip|-IP|ip|IP set static ip address"

for arg in "$@"
do
        case $arg in
         -ip|-IP|ip|IP)
                 echo "set static interface"
                read static_interface
                echo "set static ip"
                read static_ip
                echo "set network "
                read network
                echo "set netmask "
                read netmask 
                echo "set static routers"
                read static_routers
                sudo echo " allow-hotplug $static_interface"  >> /etc/network/interfaces.d/$static_interface
                sudo echo " iface $static_interface inet static "  >> /etc/network/interfaces.d/$static_interface
                sleep 5
                sudo echo "address $static_ip"  >> /etc/network/interfaces.d/$static_interface
                sleep 5
                sudo echo "network  $network "  >> /etc/network/interfaces.d/$static_interface
                sleep 5
                sudo echo "netmask  $netmask "  >> /etc/network/interfaces.d/$static_interface
                sleep 5
                sudo echo "gateway $static_routers"  >> /etc/network/interfaces.d/$static_interface
                sleep 5
                sleep 10
                sudo reboot
                shift
        ;;
        -d|-D|d|D)
                sudo apt install docker.io -y
                shift
        ;;
        -p|-P|P|p)
                sudo docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest
                shift

        ;;
        -a|a|A|-A)
                sudo apt install docker.io -y
                sleep 5
                curl https://download.argon40.com/argon1.sh | bash
                sleep 5
                sudo docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest
                sleep 5
                 shift
        ;;
        -h|-H|h|H| )
                shift
                echo "$usage"
                shift
        esac
done
