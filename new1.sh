sudo apt-get update && sudo apt-get upgrade && sudo apt-get dist-upgrade

sudo apt-get update -y && sudo apt-get install -y \
    unzip \
    wget \
    default-jre \
    nginx

curl https://download.argon40.com/argon1.sh | bash

curl -fsSL https://get.docker.com -o get-docker.sh

sudo sh ./get-docker.sh

sudo docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest
