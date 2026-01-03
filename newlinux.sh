#!/bin/bash
set -e

UNIFI_DIR="/opt/unifi"
PIHOLE_DIR="/opt/pihole"
TZ="Asia/Jerusalem"
read -p "pihole password: " PIHOLE_PASS
read -p "mangodb password: " mangodb_PASS
SERVER_IP="$(hostname -I | awk '{print $1}')"

echo "=== Install Docker (official repo) ==="
apt update
apt install -y ca-certificates curl gnupg

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg \
  | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/debian \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
> /etc/apt/sources.list.d/docker.list

apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
systemctl enable docker
systemctl start docker

# =========================
# UniFi + Mongo + Portainer
# =========================
echo "=== Create UniFi folders ==="
mkdir -p $UNIFI_DIR/{db,data}
cd $UNIFI_DIR

echo "=== Create init-mongo.sh ==="
cat > init-mongo.sh <<'EOF'
#!/bin/bash
if which mongosh > /dev/null 2>&1; then
  mongo_bin='mongosh'
else
  mongo_bin='mongo'
fi

"$mongo_bin" <<EOF2
use admin
db.auth("root","$mangodb_PASS")
db.createUser({
  user: "unifi",
  pwd: "ddd",
  roles: [
    { db: "unifi", role: "dbOwner" },
    { db: "unifi_stat", role: "dbOwner" },
    { db: "unifi_audit", role: "dbOwner" }
  ]
})
EOF2
EOF

chmod +x init-mongo.sh

echo "=== Create UniFi docker-compose.yml ==="
cat > docker-compose.yml <<'EOF'
version: "3.9"

services:
  unifi-db:
    image: mongo:4.4.18
    container_name: unifi-db
    restart: unless-stopped
    environment:
      MONGO_INITDB_ROOT_USERNAME: root
      MONGO_INITDB_ROOT_PASSWORD: $mangodb_PASS
    volumes:
      - ./db:/data/db
      - ./init-mongo.sh:/docker-entrypoint-initdb.d/init-mongo.sh:ro

  unifi-network-application:
    image: lscr.io/linuxserver/unifi-network-application:latest
    container_name: unifi-network-application
    depends_on:
      - unifi-db
    restart: unless-stopped
    environment:
      PUID: 1000
      PGID: 1000
      TZ: Etc/UTC
      MONGO_USER: unifi
      MONGO_PASS: ddd
      MONGO_HOST: unifi-db
      MONGO_PORT: 27017
      MONGO_DBNAME: unifi
      MONGO_AUTHSOURCE: admin
    volumes:
      - ./data:/config
    ports:
      - "8443:8443"
      - "8080:8080"
      - "3478:3478/udp"
      - "10001:10001/udp"
      - "1900:1900/udp"
      - "8843:8843"
      - "8880:8880"
      - "6789:6789"
      - "5514:5514/udp"

  portainer:
    image: portainer/portainer-ce:latest
    container_name: portainer
    restart: unless-stopped
    ports:
      - "8000:8000"
      - "9443:9443"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - portainer_data:/data

volumes:
  portainer_data:
EOF

docker compose up -d

# =========================
# Pi-hole
# =========================
echo "=== Create Pi-hole folders ==="
mkdir -p $PIHOLE_DIR/{etc-pihole,etc-dnsmasq.d}
cd $PIHOLE_DIR

echo "=== Create Pi-hole docker-compose.yml ==="
cat > $BASE_DIR/docker-compose-pihole.yml <<'EOF'
version: "3.9"

services:
  pihole:
    image: pihole/pihole:latest
    container_name: pihole
    restart: unless-stopped
    environment:
      TZ: Asia/Jerusalem
      WEBPASSWORD: changeme
      ServerIP: 192.168.1.10   # לשנות ל-IP סטטי שלך
    ports:
      - "53:53/tcp"
      - "80:80/tcp"
      - "443:443/tcp"
      - "53:53/udp"
      - "67:67/udp"

    volumes:
      - pihole:/etc/pihole
      - dnsmasq.d:/etc/dnsmasq.d
    cap_add:
      - NET_ADMIN

volumes:
  pihole:
  dnsmasq.d:
EOF

echo "=== Start Pi-hole ==="
docker compose -f $BASE_DIR/docker-compose-pihole.yml up -d


docker compose up -d

# =========================
# Static IP (optional)
# =========================
echo "=== Static IP setup ==="
read -p "Interface: " static_interface
read -p "Static IP: " static_ip
read -p "Network: " network
read -p "Netmask: " netmask
read -p "Gateway: " static_routers

cat <<EOF2 >> /etc/network/interfaces.d/$static_interface
allow-hotplug $static_interface
iface $static_interface inet static
address $static_ip
network $network
netmask $netmask
gateway $static_routers
EOF2

echo "Rebooting..."
sleep 5
reboot
