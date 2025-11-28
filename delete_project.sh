#!/bin/bash
set -e

PROJECT=$2
ALUMNE=$1
DOMAIN="fpnuria.net"
DNS_FILE="/etc/bind/zones/db.fpnuria.net"
BASE="/var/www/alumnes"
PROJECT_DIR="$BASE/$ALUMNE/$PROJECT"
SUBDOMAIN="${PROJECT}"

if [ -z "$PROJECT" ] || [ -z "$ALUMNE" ]; then
  echo "Us: delete_project.sh <alumne> <projecte>"
  exit 1
fi

if [ -d "$PROJECT_DIR" ]; then
  cd "$PROJECT_DIR"
  sudo docker compose down
else
  echo "No existeix directori $PROJECT_DIR"
fi

# Backup
sudo cp $DNS_FILE ${DNS_FILE}.bak.$(date +%s)

# Eliminar registre DNS (linea exacta)
#sudo sed -i "/^${SUBDOMAIN}\s\+IN\s\+A/d" $DNS_FILE

# Incrementar serial (igual advertencia que arriba)
#sudo sed -i -E 's/([0-9]{10})/echo $((\1+1))/e' $DNS_FILE

sudo systemctl reload bind9

# Eliminar arxius
sudo rm -rf "$PROJECT_DIR"
echo "Projecte ${PROJECT} eliminat."
