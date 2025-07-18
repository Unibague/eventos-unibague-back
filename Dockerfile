FROM php:8.2-fpm

# Instala dependencias
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

# Establece el directorio de trabajo
WORKDIR /var/www/html

# Copia el código del proyecto al contenedor
COPY . .

# Copia archivo de configuración NGINX
COPY nginx/002-eventosng.conf /etc/nginx/sites-available/default

# Copia los certificados SSL
COPY ssl/unibague /etc/ssl/unibague

# Expone puertos necesarios
EXPOSE 443 80

# Comando por defecto
CMD service php8.2-fpm start && nginx -g "daemon off;"
