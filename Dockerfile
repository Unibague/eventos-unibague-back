FROM php:8.2-apache

# Instala dependencias necesarias
RUN apt-get update && apt-get install -y \
    git curl unzip libpq-dev libzip-dev zip && \
    docker-php-ext-install pdo pdo_pgsql

# Habilita mod_rewrite
RUN a2enmod rewrite ssl

# Copia archivos de Apache y habilita el sitio
COPY ./apache/002-eventos.conf /etc/apache2/sites-available/002-eventos.conf
RUN a2ensite 002-eventos.conf && \
    a2dissite 000-default.conf && \
    service apache2 reload || true

WORKDIR /var/www/html

# Copia código fuente
COPY . /var/www/html

# Copia Composer desde imagen oficial y ejecuta install
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# Permisos
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
