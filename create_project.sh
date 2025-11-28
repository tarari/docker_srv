#!/usr/bin/env bash
set -euo pipefail
if [ $# -eq 0 ]; then
    echo "Us: create_project.sh <alumne> <projecte>"
    exit 1
fi;

if [ "$EUID" -ne 0 ]; then
  echo "Cal que siguis sudo o root"
  exit 2
fi
if [[ -z $1 ]] || [[ -z $2 ]] ; then
  echo "create_project.sh <alumne> <projecte>"
  exit 3
fi;

ALUMNE="$1"
PROJECT="$2"
GROUP="alumnes"

if [ -z "$PROJECT" ] || [ -z "$ALUMNE" ]; then
  echo "Us: create_project.sh alumne projecte"
  exit 4
fi

DOMAIN="fpnuria.net"
DNS_FILE="/etc/bind/zones/db.fpnuria.net"
BASE="/var/www/alumnes"
PROJECT_DIR="$BASE/$ALUMNE/$PROJECT"
SUBDOMAIN="${PROJECT}.${ALUMNE}"
FQDN="${SUBDOMAIN}.${DOMAIN}"
sudo mkdir -p "$PROJECT_DIR/src"
sudo chown -R "${ALUMNE}":"${GROUP}" "$PROJECT_DIR"

# Desar backup de la zona
sudo cp $DNS_FILE ${DNS_FILE}.bak.$(date +%s)

# Afegir registre A en el arxiu de zona (vigilar  duplicats)
if grep -qE "^${SUBDOMAIN}\s+IN\s+A" $DNS_FILE; then
  echo "Registro ya existe en DNS. Abortando."
  exit 5
fi

echo "${SUBDOMAIN}   IN  A   192.168.0.250" | sudo tee -a $DNS_FILE > /dev/null

# Incrementar serial (simple: buscar 10 dígits i sumar 1)  no recomanable
sudo sed -i -E 's/([0-9]{10})/echo $((\1+1))/e' $DNS_FILE

sudo systemctl restart bind9

# Crear docker-compose desde plantilla (canviar valors si cal)
cat > "$PROJECT_DIR/docker-compose.yml" <<EOF
services:
  app:
    image: php:8.1-apache
    container_name: ${PROJECT}_${ALUMNE}
    volumes:
      - ./src:/var/www/html:rw
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.${PROJECT}.rule=Host(\`${FQDN}\`)"
      - "traefik.http.services.${PROJECT}.loadbalancer.server.port=80"
    networks:
      - proxy
networks:
  proxy:
    external: true
EOF

# inicial en src
cat > "$PROJECT_DIR/src/index.php" <<HTML
<?php
echo "<h1>$PROJECT ($ALUMNE)</h1>";
phpinfo();
HTML

# Levantar contenedor
cd "$PROJECT_DIR" && sudo docker compose up -d

echo "Projecte creat en: http://${FQDN}"
