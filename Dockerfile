# Etapa 1: Composer con dependencias
FROM composer:2 as composer_stage

WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev --prefer-dist --no-interaction

# Etapa 2: Imagen final PHP con Apache
FROM php:8.2-apache

# Instala extensiones necesarias
RUN apt-get update && apt-get install -y \
    git curl unzip libpq-dev libzip-dev zip && \
    docker-php-ext-install pdo pdo_pgsql

# Habilita módulos de Apache
RUN a2enmod rewrite ssl

# Copia archivo de configuración Apache
COPY ./apache/002-eventos.conf /etc/apache2/sites-available/002-eventos.conf
RUN a2ensite 002-eventos.conf && a2dissite 000-default.conf && service apache2 reload || true

WORKDIR /var/www/html

# Copia el resto de la app
COPY . /var/www/html

# Copia los vendor desde la etapa de Composer
COPY --from=composer_stage /app/vendor /var/www/html/vendor

# Permisos para Laravel
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
