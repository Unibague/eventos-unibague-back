FROM php:8.2-apache

# Instalar extensiones necesarias y herramientas
RUN apt-get update && \
    apt-get install -y \
        git \
        curl \
        unzip \
        libpq-dev \
        libzip-dev \
        zip \
        openssl && \
    docker-php-ext-install pdo pdo_pgsql zip && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Habilitar mod_rewrite y mod_ssl para Apache
RUN a2enmod rewrite ssl

# Copiar virtualhost personalizado
COPY ./apache/002-eventos.conf /etc/apache2/sites-available/002-eventos.conf

# Activar el sitio
RUN a2ensite 002-eventos.conf && \
    a2dissite 000-default.conf && \
    service apache2 reload || true

# Establecer el directorio de trabajo
WORKDIR /var/www/html

# Copiar todos los archivos del proyecto
COPY . /var/www/html

# Permisos
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
