sudo apt-get update && sudo apt-get upgrade && sudo apt-get dist-upgrade

sudo apt-get update -y && sudo apt-get install -y \
    unzip \
    wget \
    default-jre \
    nginx

curl https://download.argon40.com/argon1.sh | bash

curl -fsSL https://get.docker.com -o get-docker.sh

sudo sh ./get-docker.sh

