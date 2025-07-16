# Etapa 1: Composer con PHP 8.2 (compatible con Laravel)
FROM composer:2.7 as composer_stage

WORKDIR /app

# Copiar todo el proyecto para que artisan esté disponible
COPY . .

# Instalar dependencias de Composer
RUN composer install --no-dev --prefer-dist --no-interaction


# Etapa 2: Imagen final PHP con Apache
FROM php:8.2-apache

# Instala dependencias necesarias
RUN apt-get update && apt-get install -y \
    git curl unzip libpq-dev libzip-dev zip && \
    docker-php-ext-install pdo pdo_pgsql

# Habilita mod_rewrite y SSL
RUN a2enmod rewrite ssl

# Copia configuración de Apache
COPY ./apache/002-eventos.conf /etc/apache2/sites-available/002-eventos.conf
RUN a2ensite 002-eventos.conf && \
    a2dissite 000-default.conf && \
    service apache2 reload || true

# Establece el directorio de trabajo
WORKDIR /var/www/html

# Copia el código fuente
COPY . .

# Copia vendor/ generado en la etapa anterior
COPY --from=composer_stage /app/vendor ./vendor

# Asigna permisos necesarios
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
