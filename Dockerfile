FROM php:8.2-fpm

# Instala dependencias necesarias
RUN apt-get update && apt-get install -y \
    nginx \
    libpq-dev \
    git \
    unzip \
    curl \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    && docker-php-ext-install pdo pdo_pgsql

# Instala Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copia el código fuente
WORKDIR /var/www/html
COPY . .

# Copia la configuración de NGINX
COPY nginx/laravel.conf /etc/nginx/sites-available/default

# SSL Certs
COPY /etc/ssl/unibague /etc/ssl/unibague

# Expone puertos
EXPOSE 443 80

# Inicia servicios (PHP-FPM y NGINX)
CMD service php8.2-fpm start && nginx -g "daemon off;"
