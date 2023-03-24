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

echo "updating linux"

sleep 5
sudo apt-get update -y && sudo apt-get upgrade -y && sudo apt-get dist-upgrade -y

sleep 5

sleep 30
 echo "done"
