#!/bin/bash

# ==========================================
# CONFIGURACIÓN DEL USUARIO (EDITA ESTO)
# ==========================================
DOMINIO_PRINCIPAL="committedorganization.org"
DOMINIO_WWW="www.committedorganization.org"
PAIS="PE"
ESTADO="Arequipa"
CIUDAD="Arequipa"
ORGANIZACION="Committed Organization"
UNIDAD="TI"

# ==========================================
# LÓGICA DEL SCRIPT
# ==========================================
VERDE='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${VERDE}--- Generando Certificados para: $DOMINIO_PRINCIPAL ---${NC}"

mkdir -p ./certs

# 1. Generar para el Dominio Principal
# Añadimos "-addext" para que el certificado sirva también para localhost (Portabilidad)
echo "Creando par para: $DOMINIO_PRINCIPAL"
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout ./certs/serverkey.key \
  -out ./certs/servercert.crt \
  -subj "/C=$PAIS/ST=$ESTADO/L=$CIUDAD/O=$ORGANIZACION/OU=$UNIDAD/CN=$DOMINIO_PRINCIPAL" \
  -addext "subjectAltName=DNS:$DOMINIO_PRINCIPAL,DNS:localhost,IP:127.0.0.1"

echo -e "${VERDE}✔ Listo: certs/servercert.pem${NC}"

# 2. Generar para el Subdominio WWW
echo "Creando par para: $DOMINIO_WWW"
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout ./certs/privkey.key \
  -out ./certs/cert-tls.crt \
  -subj "/C=$PAIS/ST=$ESTADO/L=$CIUDAD/O=$ORGANIZACION/OU=$UNIDAD/CN=$DOMINIO_WWW" \
  -addext "subjectAltName=DNS:$DOMINIO_WWW,DNS:localhost,IP:127.0.0.1"

echo -e "${VERDE}✔ Listo: certs/certificadotls.crt${NC}"
echo -e "${VERDE}--- Proceso Finalizado ---${NC}"
