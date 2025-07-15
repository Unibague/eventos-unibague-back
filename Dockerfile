FROM php:8.2-apache

# Establecer DNS dentro del contenedor (por si Docker no lo aplica bien)
RUN echo "nameserver 8.8.8.8" > /etc/resolv.conf && \
    apt-get update && \
    apt-get install -y \
        git \
        curl \
        unzip \
        libpq-dev \
        libzip-dev \
        zip \
    && docker-php-ext-install pdo pdo_pgsql zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copiar archivos del proyecto
COPY . /var/www/html

# Cambiar permisos de los archivos si es necesario
RUN chown -R www-data:www-data /var/www/html
