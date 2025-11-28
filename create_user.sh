#!/bin/bash
set -e

# ===========================
# Script  crear usuaris
#  en /home/alumnes
# i acces SSH.
# ===========================

if [ "$EUID" -ne 0 ]; then
  echo "Cal que siguis sudo o root"
  exit 1
fi

USUARI=$1
PASSWORD=$2   # opcional, si no  genera automáticamente
GROUP="alumnes"

if [ -z "$USUARI" ]; then
  echo "Us: create_user.sh <usuari> [password]"
  exit 1
fi

BASE_HOME="/home/alumnes"
USER_HOME="${BASE_HOME}/${USUARI}"

# Crear contraseña aleatoria si no se proporciona
if [ -z "$PASSWORD" ]; then
  PASSWORD=$(openssl rand -base64 10)
fi

echo "Creant usuari: $USUARI"
echo "Home: $USER_HOME"

# Crear home base si no existeix
mkdir -p "$BASE_HOME"

# Crear usuari amb home personal i shell bash
useradd -m -g "$GROUP" -G docker -d "$USER_HOME" -s /bin/bash "$USUARI"

# Establir contrasenya
echo "${USUARI}:${PASSWORD}" | chpasswd

# Crear directoris adicionals (de moment no)
#mkdir -p "${USER_HOME}/projectes"
#mkdir -p "${USER_HOME}/src"

# Assegurar permisos correctes als usuaris
chown -R "${USUARI}:${GROUP}" "$USER_HOME"
chmod 750 "$USER_HOME"

# Ajustar permisos per SSH (si es req clau pública)
mkdir -p "${USER_HOME}/.ssh"
chmod 700 "${USER_HOME}/.ssh"
chown "${USUARI}:${GROUP}" "${USER_HOME}/.ssh"

# Activar SSH si estava desactivat
systemctl enable ssh --now >/dev/null 2>&1 || true

# Mostrar credencials
echo "====================================="
echo " Usuari creat correctament"
echo " Usuario : ${USUARI}"
echo " Home    : ${USER_HOME}"
echo " Password: ${PASSWORD}"
echo "====================================="
