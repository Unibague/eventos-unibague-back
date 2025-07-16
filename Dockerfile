FROM php:8.2-apache

# Establecer variables de entorno para evitar preguntas interactivas
ENV DEBIAN_FRONTEND=noninteractive

# Instalar dependencias necesarias
RUN apt-get update && \
    apt-get install -y \
        git \
        curl \
        unzip \
        libpq-dev \
        libzip-dev \
        zip && \
    docker-php-ext-install pdo pdo_pgsql zip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copiar el contenido del proyecto
COPY . /var/www/html

# Dar permisos (opcional si necesitas escritura)
RUN chown -R www-data:www-data /var/www/html

# Exponer el puerto por si usas php artisan serve (Laravel)
EXPOSE 8000
