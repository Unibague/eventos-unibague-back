# Etapa 1: Instala dependencias con Composer
FROM composer:2.7 AS composer_stage

WORKDIR /app

COPY composer.json composer.lock ./
RUN composer install --no-dev --prefer-dist --no-interaction --no-scripts

# Etapa 2: PHP + Apache con extensiones necesarias
FROM php:8.2-apache

# Instala extensiones de PHP necesarias
RUN apt-get update && apt-get install -y \
    git curl unzip libpq-dev libzip-dev zip && \
    docker-php-ext-install pdo pdo_pgsql

# Habilita módulos de Apache necesarios
RUN a2enmod rewrite ssl

# Copia el archivo del VirtualHost personalizado con SSL
COPY ./apache/002-eventos.conf /etc/apache2/sites-available/002-eventos.conf

# Activa el nuevo sitio y desactiva el default
RUN a2ensite 002-eventos.conf && \
    a2dissite 000-default.conf

# Copia certificados SSL locales (estos deben mapearse con volúmenes en docker-compose)
# Si los certificados se montan, no hace falta copiarlos desde el host

# Copia el proyecto
WORKDIR /var/www/html
COPY . .

# Copia dependencias Composer de la etapa anterior
COPY --from=composer_stage /app/vendor /var/www/html/vendor

# Limpieza de caché Laravel
RUN rm -rf bootstrap/cache/*.php

# Asigna permisos adecuados
RUN chown -R www-data:www-data storage bootstrap/cache

# Comando por defecto
CMD ["apache2-foreground"]
