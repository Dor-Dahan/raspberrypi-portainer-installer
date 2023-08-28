#!/bin/bash
usage="$(basename "$0") [-h] [-s n] -- test 
where:
        -H|H|-h|h  show this help text
        -A|A|-a|a install all docker & portainer & argon40
        -D|D|-d|d install docker only
        -P|P|-p|p install portainer only"

for arg in "$@"
do
        case $arg in
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
        -h|-H|h|H)
                shift
                echo "$usage"
                shift
        esac
done
