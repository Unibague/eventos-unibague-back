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
    supervisor \
    && docker-php-ext-install pdo pdo_pgsql zip

# Instala Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Define el directorio de trabajo
WORKDIR /var/www/html

# Copia el código fuente
COPY . .

# Instala dependencias de Laravel
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# Asigna permisos a Laravel
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 storage \
    && chmod -R 755 bootstrap/cache

# Copia configuración de NGINX
COPY nginx/002-eventosng.conf /etc/nginx/sites-available/default

# Copia archivo de configuración de supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Expone los puertos necesarios
EXPOSE 80 443

# Inicia ambos servicios usando supervisor
CMD ["/usr/bin/supervisord"]
