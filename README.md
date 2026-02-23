# Secure Dockerized Web Infrastructure: Apache/PHP with Automated TLS, Local DNS & iptables Firewall

Este proyecto despliega un servidor web Apache HTTPS seguro utilizando Docker y Docker Compose. Incluye automatización completa mediante scripts en Bash para la generación de certificados TLS/SSL autofirmados, resolución local de DNS y un firewall dinámico basado en `iptables` diseñado para proteger los contenedores.

Es un entorno ideal para pruebas de concepto (PoC), laboratorios de ciberseguridad y desarrollo web seguro.

## Características Principales

* **Servidor Web Apache 2.4:** Configurado con Virtual Hosts y redirección automática de HTTP a HTTPS.
* **PHP 8.2-FPM:** Backend separado en su propio contenedor para un mejor rendimiento y aislamiento.
* **Certificados TLS Automatizados:** Generación automática de llaves RSA de 2048 bits con soporte para Subject Alternative Name (SAN).
* **Gestión de DNS Local:** Script para modificar temporalmente `/etc/hosts` y resolver dominios personalizados de forma local.
* **Firewall Dinámico (iptables):** Script automatizado que detecta la interfaz de red activa y aplica reglas de limitación de tasa (Anti-DDoS básico), loopback, ICMP, SSH, puerto 80 (HTTP) y puerto 443 (HTTPS) para bloqueos y gestión de conexiones concurrentes para la cadena `DOCKER-USER`.

## Requisitos Previos

Para ejecutar este proyecto, tu máquina anfitriona debe cumplir con lo siguiente:
* **Sistema Operativo:** Distribución basada en Linux (Ubuntu, Debian, Kali Linux, etc.).
* **Herramientas:** `docker` y el plugin `docker compose` (v2).
* **Permisos:** Privilegios de administrador (`sudo`) para ejecutar los scripts de red y firewall.
* **Puertos libres:** Los puertos `80` (HTTP) y `443` (HTTPS) de tu máquina física no deben estar ocupados por otros servicios.

## Guía de Instalación y Uso (Paso a Paso)

Sigue este orden estricto para levantar el entorno de forma segura.

### 1. Generar los certificados TLS
Este script creará los certificados autofirmados .crt y .pem en la carpeta certs/.
`bash scripts/1ro-certs-TLS.sh`

### 2. Configurar la Resolución DNS Local
Temporalmente en el archivo /etc/hosts.
`sudo bash scripts/2do-setup-dns.sh`

### 3. Iptables de DOCKER-USER
Se carga antes las reglas de iptables antes de levantar los servicios web. El script detectará la interfaz de red automáticamente.
`sudo bash scripts/3ro-iptables-docker-start-stop.sh start`

### 4. Desplegar Docker
Con estos scripts ejecutandose se procede a construir y levantar los contenedores en segundo plano.
`docker compose up -d --build`

### 5. Probar el acceso
Abre tu navegador web y comprueba las dos paginas web:
* https://committedorganization.org
* https://www.committedorganization.org

### Clonar el repositorio
```bash
git clone [https://github.com/JulioVaLe546/docker-apache-https-server.git](https://github.com/JulioVaLe546/docker-apache-https-server.git)
cd docker-apache-https-server
