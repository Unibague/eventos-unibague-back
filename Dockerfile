# Etapa 1: Instala dependencias con Composer sin paquetes de desarrollo
FROM composer:2.7 AS composer_stage

WORKDIR /app

# Solo copiamos los archivos necesarios para instalar dependencias
COPY composer.json composer.lock ./

# Instala dependencias sin ejecutar scripts (evita errores de Collision)
RUN composer install --no-dev --prefer-dist --no-interaction --no-scripts

# Etapa 2: Imagen final con PHP y Apache
FROM php:8.2-apache

# Instala extensiones necesarias
RUN apt-get update && apt-get install -y \
    git curl unzip libpq-dev libzip-dev zip && \
    docker-php-ext-install pdo pdo_pgsql

# Habilita mod_rewrite
RUN a2enmod rewrite ssl

# Copia configuración de Apache y activa el sitio
COPY ./apache/002-eventos.conf /etc/apache2/sites-available/002-eventos.conf
RUN a2ensite 002-eventos.conf && \
    a2dissite 000-default.conf && \
    service apache2 reload || true

# Directorio de trabajo
WORKDIR /var/www/html

# Copia el código fuente del proyecto
COPY . .

# Copia las dependencias instaladas desde la etapa anterior
COPY --from=composer_stage /app/vendor /var/www/html/vendor

# Borra caché de Laravel para evitar errores de paquetes
RUN rm -rf bootstrap/cache/*.php

# Permisos correctos
RUN chown -R www-data:www-data storage bootstrap/cache

# Comando por defecto si usas php artisan serve (opcional)
# CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
