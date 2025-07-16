FROM php:8.2-apache

RUN apt-get update && \
    apt-get install -y \
        git \
        curl \
        unzip \
        libpq-dev \
        libzip-dev \
        zip && \
    docker-php-ext-install pdo pdo_pgsql zip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Habilitar mod_rewrite de Apache
RUN a2enmod rewrite

# Copiar archivos al contenedor
COPY . /var/www/html

# Establecer permisos adecuados
RUN chown -R www-data:www-data /var/www/html
