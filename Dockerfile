# Etapa 1: Instalar dependencias de Composer
FROM composer:2.7 AS composer_stage

WORKDIR /app

# Copia todos los archivos necesarios para que composer funcione bien
COPY composer.json composer.lock ./
# Si no tienes composer.lock, puedes omitirlo, pero se recomienda tenerlo
RUN composer install --no-dev --prefer-dist --no-interaction --no-scripts

# Etapa 2: PHP + Apache con Laravel
FROM php:8.2-apache

# Instala extensiones necesarias
RUN apt-get update && apt-get install -y \
    git curl unzip libpq-dev libzip-dev zip \
    && docker-php-ext-install pdo pdo_pgsql

# Habilita módulos de Apache necesarios
RUN a2enmod rewrite ssl

# Copia el VirtualHost con SSL (debes tener este archivo en ./apache/)
COPY ./apache/002-eventos.conf /etc/apache2/sites-available/002-eventos.conf

# Activa el sitio y desactiva el default
RUN a2ensite 002-eventos.conf && \
    a2dissite 000-default.conf

# Establece el directorio de trabajo de Apache
WORKDIR /var/www/html

# Copia TODO el proyecto Laravel
COPY . .

# Copia la carpeta vendor desde la etapa anterior
COPY --from=composer_stage /app/vendor /var/www/html/vendor

# Ajusta permisos para Laravel
RUN chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

# Borra cachés de Laravel
RUN php artisan config:clear && php artisan cache:clear && php artisan route:clear

# Exponer el puerto 80 y 443 (HTTP y HTTPS)
EXPOSE 80 443

# Comando por defecto
CMD ["apache2-foreground"]
