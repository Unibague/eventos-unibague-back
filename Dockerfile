# Etapa 1: Composer
FROM composer:2.7 AS composer_stage
WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev --prefer-dist --no-interaction --no-scripts

# Etapa 2: PHP + Apache
FROM php:8.2-apache

# Dependencias
RUN apt-get update && apt-get install -y \
    git curl unzip libpq-dev libzip-dev zip libpng-dev && \
    docker-php-ext-install pdo pdo_pgsql zip

# Apache mods
RUN a2enmod rewrite ssl proxy proxy_http headers

# Copia VirtualHosts
COPY ./apache/002-eventos.conf /etc/apache2/sites-available/002-eventos.conf
COPY ./apache/003-frontend.conf /etc/apache2/sites-available/003-frontend.conf

# Activar sitios
RUN a2ensite 002-eventos.conf 003-frontend.conf && \
    a2dissite 000-default.conf

# Copia backend Laravel
WORKDIR /var/www/html
COPY . .

# Copia vendor de Composer
COPY --from=composer_stage /app/vendor /var/www/html/vendor

# Permisos
RUN chown -R www-data:www-data storage bootstrap/cache

# Comando default
CMD ["apache2-foreground"]
