FROM httpd:2.4

# 1. Copiamos nuestra configuración de VirtualHosts al contenedor
COPY ./config/vhosts/ /usr/local/apache2/conf/extra/vhosts/

# 2. Copiamos los certificados al lugar seguro
COPY ./certs/ /usr/local/apache2/conf/certs/

# 3. Copiamos el código fuente de las webs
COPY ./www/ /usr/local/apache2/htdocs/

# 4. Modificamos httpd.conf usando sed para habilitar módulos necesarios
# Habilitar SSL (mod_ssl) y Cache
RUN sed -i \
    -e 's/^#\(Include .*httpd-ssl.conf\)/\1/' \
    -e 's/^#\(LoadModule ssl_module modules\/mod_ssl.so\)/\1/' \
    -e 's/^#\(LoadModule socache_shmcb_module modules\/mod_socache_shmcb.so\)/\1/' \
    conf/httpd.conf

# Habilitar Rewrite y Proxy (necesario si vas a usar PHP más adelante)
RUN sed -i \
    -e 's/^#\(LoadModule rewrite_module modules\/mod_rewrite.so\)/\1/' \
    -e 's/^#\(LoadModule proxy_module modules\/mod_proxy.so\)/\1/' \
    -e 's/^#\(LoadModule proxy_fcgi_module modules\/mod_proxy_fcgi.so\)/\1/' \
    conf/httpd.conf

# --- NUEVO PASO CRÍTICO ---
# Corregimos el archivo httpd-ssl.conf para que apunte a TUS certificados
# en lugar de buscar los "server.crt" que no existen.
RUN sed -i \
    -e 's|/usr/local/apache2/conf/server.crt|/usr/local/apache2/conf/certs/servercert.pem|g' \
    -e 's|/usr/local/apache2/conf/server.key|/usr/local/apache2/conf/certs/serverkey.pem|g' \
    conf/extra/httpd-ssl.conf
# --------------------------

# 5. Incluir nuestra configuración de VirtualHosts al final del archivo principal
RUN echo "Include conf/extra/vhosts/*.conf" >> conf/httpd.conf
