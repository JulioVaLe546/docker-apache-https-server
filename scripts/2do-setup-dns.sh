#!/bin/bash

# Dominios a configurar
DOMINIO_1="committedorganization.org"
DOMINIO_2="www.committedorganization.org"
IP_LOCAL="127.0.0.1"

# Archivo hosts del sistema
HOSTS_FILE="/etc/hosts"
BACKUP_FILE="/etc/hosts.bak.$(date +%F_%H-%M)"

# Colores
VERDE='\033[0;32m'
AMARILLO='\033[1;33m'
ROJO='\033[0;31m'
NC='\033[0m'

echo -e "${AMARILLO}--- Configurando DNS Local para el Proyecto ---${NC}"

# 1. Verificación de permisos (Sudo)
if [ "$EUID" -ne 0 ]; then
  echo -e "${ROJO}Por favor, ejecuta este script como root (sudo).${NC}"
  echo "Uso: sudo ./scripts/setup-dns.sh"
  exit
fi

# 2. Crear copia de seguridad
echo "Creando respaldo en $BACKUP_FILE..."
cp $HOSTS_FILE $BACKUP_FILE

# 3. Función para agregar dominio si no existe
agregar_host() {
    local dominio=$1
    if grep -q "$dominio" "$HOSTS_FILE"; then
        echo -e "${AMARILLO}⚠ El dominio $dominio ya existe en /etc/hosts. Se omite.${NC}"
    else
        echo -e "$IP_LOCAL\t$dominio" >> "$HOSTS_FILE"
        echo -e "${VERDE}✔ Agregado: $dominio -> $IP_LOCAL${NC}"
    fi
}

# 4. Ejecutar la configuración
agregar_host $DOMINIO_1
agregar_host $DOMINIO_2

echo -e "${VERDE}--- Configuración DNS Finalizada ---${NC}"
echo "Ahora tu navegador reconocerá los dominios localmente."
