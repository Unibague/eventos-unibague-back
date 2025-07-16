# Etapa 1: Composer (solo para instalación de dependencias)
FROM composer:2.7 AS composer_stage

WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev --prefer-dist --no-interaction --no-scripts

# Etapa 2: Imagen final con PHP y Apache
FROM php:8.2-apache

# Instala dependencias del sistema
RUN apt-get update && apt-get install -y \
    git curl unzip libpq-dev libzip-dev zip && \
    docker-php-ext-install pdo pdo_pgsql

# Habilita mod_rewrite
RUN a2enmod rewrite ssl

# Copia configuración de Apache
COPY ./apache/002-eventos.conf /etc/apache2/sites-available/002-eventos.conf
RUN a2ensite 002-eventos.conf && \
    a2dissite 000-default.conf && \
    service apache2 reload || true

# Establece directorio de trabajo
WORKDIR /var/www/html

# Copia el código de la app
COPY . /var/www/html

# Copia dependencias instaladas desde la etapa composer
COPY --from=composer_stage /app/vendor /var/www/html/vendor

# Asigna permisos correctos
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Comando por defecto (usa Laravel con servidor embebido)
CMD php artisan migrate --force && php artisan serve --host=0.0.0.0 --port=8000
