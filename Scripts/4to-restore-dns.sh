#!/bin/bash
# Script para limpiar las entradas del hosts
DOMINIO_1="committedorganization.org"
DOMINIO_2="www.committedorganization.org"
HOSTS_FILE="/etc/hosts"

if [ "$EUID" -ne 0 ]; then
  echo "Por favor, ejecuta como root (sudo)."
  exit
fi

echo "Limpiando configuración del proyecto en /etc/hosts..."

# Sed busca las líneas que contienen los dominios y las borra
sed -i "/$DOMINIO_1/d" $HOSTS_FILE
sed -i "/$DOMINIO_2/d" $HOSTS_FILE

echo "✔ Entradas eliminadas correctamente."
