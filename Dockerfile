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

# Define el directorio de trabajo
WORKDIR /var/www/html

# Copia el código fuente
COPY . .

# Copia la configuración de NGINX
COPY nginx/002-eventosng.conf /etc/nginx/sites-available/default

# Expone puertos necesarios
EXPOSE 80 443

# Inicia servicios
CMD service php8.2-fpm start && nginx -g "daemon off;"
