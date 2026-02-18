#!/bin/bash

# Colores
VERDE='\033[0;32m'
ROJO='\033[0;31m'
AMARILLO='\033[1;33m'
NC='\033[0m'

IFACE = $(ip route get 8.8.8.8 | awk '{print $5}')

# ==========================================
# FUNCIÓN: DETENER (LIMPIEZA SEGURA)
# ==========================================
function detener_firewall() {
    echo -e "${AMARILLO}--- Iniciando Limpieza de Firewall ---${NC}"
    
    # Si borras reglas estando en DROP, te bloqueas a ti mismo.
    echo "Estableciendo políticas por defecto en ACCEPT..."
    iptables -P INPUT ACCEPT
    iptables -P FORWARD ACCEPT
    iptables -P OUTPUT ACCEPT

    # 2. Borrar todas las reglas (Flush)
    echo "Borrando reglas activas..."
    iptables -F
    iptables -X
    iptables -t nat -F
    iptables -t nat -X
    iptables -t mangle -F
    iptables -t mangle -X

    # 3. Reiniciar Docker (CRÍTICO)
    # Al borrar iptables, borramos los puentes de red de Docker.
    # Docker necesita reiniciarse para recrearlos.
    echo "Reiniciando servicio Docker para restaurar red nativa..."
    systemctl restart docker

    echo -e "${VERDE}✔ Firewall detenido y reglas limpiadas. Servidor expuesto.${NC}"
}

# ==========================================
# FUNCIÓN: INICIAR (TUS REGLAS)
# ==========================================
function iniciar_firewall() {
    echo -e "${VERDE}--- Aplicando Reglas de Seguridad ---${NC}"

    # ==========================================
    # 2. POLITICAS POR DEFECTO (HOST)
    # ==========================================
    # Primero limpiamos INPUT para evitar duplicados si se ejecuta dos veces
    iptables -F INPUT
    
    iptables -P INPUT DROP
    iptables -P FORWARD DROP
    iptables -P OUTPUT ACCEPT

    # Permitir loopback en el host
    iptables -A INPUT -i lo -j ACCEPT

    # Conexiones establecidas (Host)
    iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

    # Bloqueo de paquetes inválidos y fragmentados (Host)
    iptables -A INPUT -m conntrack --ctstate INVALID -j DROP
    iptables -A INPUT -f -j DROP
    iptables -A INPUT -p tcp --tcp-flags SYN,ACK,FIN,RST RST -m limit --limit 1/s --limit-burst 2 -j ACCEPT
    iptables -A INPUT -p tcp --tcp-flags SYN,ACK,FIN,RST RST -j DROP

    # ==========================================
    # 3. PROTECCIÓN DEL CONTENEDOR (CADENA DOCKER-USER)
    # ==========================================
    # Esta cadena protege lo que entra a Docker (Puertos 80 y 443)
    # IMPORTANTE: Aquí "-d" sería la IP interna del contenedor (que cambia). 
    # Filtramos por interfaz de entrada (-i ens33) y puerto (--dport).
    
    # Primero limpiamos la cadena DOCKER-USER para no duplicar reglas al reiniciar Docker
    iptables -F DOCKER-USER

    # Permitir establecidas/relacionadas hacia el contenedor
    iptables -I DOCKER-USER -m conntrack --ctstate ESTABLISHED,RELATED -j RETURN

    # ------------------------------------------
    # REGLAS PARA LA LAN (Confianza Media - Origen 192.168.1.0/24)
    # ------------------------------------------

    # HTTP (80) - LAN
    # Limitar conexiones nuevas: 50 en 60 seg
    iptables -A DOCKER-USER -i "$IFACE" -p tcp --dport 80 -s 192.168.1.0/24 -m conntrack --ctstate NEW -m recent --name http_lan --set
    iptables -A DOCKER-USER -i "$IFACE" -p tcp --dport 80 -s 192.168.1.0/24 -m conntrack --ctstate NEW -m recent --name http_lan --rcheck --seconds 60 --hitcount 51 -j DROP
    # Limite concurrente: 40
    iptables -A DOCKER-USER -i "$IFACE" -p tcp --dport 80 -s 192.168.1.0/24 -m connlimit --connlimit-above 40 --connlimit-mask 32 -j DROP
    # Aceptar tráfico LAN limpio
    iptables -A DOCKER-USER -i "$IFACE" -p tcp --dport 80 -s 192.168.1.0/24 -j RETURN

    # HTTPS (443) - LAN
    # Limitar conexiones nuevas: 60 en 60 seg
    iptables -A DOCKER-USER -i "$IFACE" -p tcp --dport 443 -s 192.168.1.0/24 -m conntrack --ctstate NEW -m recent --name https_lan --set
    iptables -A DOCKER-USER -i "$IFACE" -p tcp --dport 443 -s 192.168.1.0/24 -m conntrack --ctstate NEW -m recent --name https_lan --rcheck --seconds 60 --hitcount 61 -j DROP
    # Limite concurrente: 40
    iptables -A DOCKER-USER -i "$IFACE" -p tcp --dport 443 -s 192.168.1.0/24 -m connlimit --connlimit-above 40 --connlimit-mask 32 -j DROP
    # Aceptar tráfico LAN limpio
    iptables -A DOCKER-USER -i "$IFACE" -p tcp --dport 443 -s 192.168.1.0/24 -j RETURN

    # ------------------------------------------
    # REGLAS PÚBLICAS (Confianza Baja - Internet/Otros)
    # ------------------------------------------

    # HTTP (80) - PUBLICO
    # Excluye LAN (! -s 192.168.1.0/24)
    # Limitar conexiones nuevas: 80 en 60 seg
    iptables -A DOCKER-USER -i "$IFACE" -p tcp --dport 80 ! -s 192.168.1.0/24 -m conntrack --ctstate NEW -m recent --name http_public --set
    iptables -A DOCKER-USER -i "$IFACE" -p tcp --dport 80 ! -s 192.168.1.0/24 -m conntrack --ctstate NEW -m recent --name http_public --update --seconds 60 --hitcount 81 -j DROP
    # Limite concurrente: 30
    iptables -A DOCKER-USER -i "$IFACE" -p tcp --dport 80 ! -s 192.168.1.0/24 -m connlimit --connlimit-above 30 --connlimit-mask 32 -j DROP
    # Aceptar tráfico Público limpio
    iptables -A DOCKER-USER -i "$IFACE" -p tcp --dport 80 ! -s 192.168.1.0/24 -j RETURN

    # HTTPS (443) - PUBLICO
    # Limitar conexiones nuevas: 100 en 60 seg
    iptables -A DOCKER-USER -i "$IFACE" -p tcp --dport 443 ! -s 192.168.1.0/24 -m conntrack --ctstate NEW -m recent --name https_public --set
    iptables -A DOCKER-USER -i "$IFACE" -p tcp --dport 443 ! -s 192.168.1.0/24 -m conntrack --ctstate NEW -m recent --name https_public --update --seconds 60 --hitcount 101 -j DROP
    # Limite concurrente: 100
    iptables -A DOCKER-USER -i "$IFACE" -p tcp --dport 443 ! -s 192.168.1.0/24 -m connlimit --connlimit-above 100 --connlimit-mask 32 -j DROP
    # Aceptar tráfico Público limpio
    iptables -A DOCKER-USER -i "$IFACE" -p tcp --dport 443 ! -s 192.168.1.0/24 -j RETURN

    # Si el tráfico llega a DOCKER-USER y no hizo match con nada de arriba, Docker decidirá.
    # (Por defecto Docker permite, si quieres ser paranoico puedes agregar un DROP al final de DOCKER-USER,
    # pero cuidado con romper la comunicación interna de contenedores).

    # ==========================================
    # 4. REGLAS DE GESTIÓN DEL HOST (INPUT)
    # ==========================================

    # SSH (Acceso solo desde subred de gestión)
    iptables -A INPUT -p tcp --dport 22 -i "$IFACE" -s 10.30.22.0/23 -m conntrack --ctstate NEW -m recent --name ssh_pqte --set
    iptables -A INPUT -p tcp --dport 22 -i "$IFACE" -s 10.30.22.0/23 -m conntrack --ctstate NEW -m recent --name ssh_pqte --update --seconds 60 --hitcount 4 -j DROP
    iptables -A INPUT -p tcp --dport 22 -i "$IFACE" -s 10.30.22.0/23 -m conntrack --ctstate NEW -j ACCEPT

    # ICMP
    iptables -A INPUT -p icmp --icmp-type redirect -j DROP
    iptables -A INPUT -p icmp -i "$IFACE" -s 192.168.1.0/24 -m conntrack --ctstate NEW -m limit --limit 5/sec -j ACCEPT
    iptables -A INPUT -p icmp -i "$IFACE" -s 10.30.22.0/23 -m conntrack --ctstate NEW -m limit --limit 5/sec -j ACCEPT

    echo -e "${VERDE}✔ Reglas aplicadas correctamente.${NC}"
}

# ==========================================
# LÓGICA DE CONTROL
# ==========================================
case "$1" in
    start)
        iniciar_firewall
        ;;
    stop)
        detener_firewall
        ;;
    restart)
        detener_firewall
        iniciar_firewall
        ;;
    *)
        echo "Uso: sudo $0 {start|stop|restart}"
        exit 1
        ;;
esac
