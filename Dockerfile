FROM php:8.2-apache

ENV DEBIAN_FRONTEND=noninteractive

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

COPY . /var/www/html

WORKDIR /var/www/html

EXPOSE 8000
