#official PHP image with Apache
FROM php:8.3-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libzip-dev \
    libpng-dev \
    libxml2-dev \
    libonig-dev \
    unzip \
    git \
    curl \
    && docker-php-ext-install pdo pdo_mysql zip mbstring gd dom


RUN a2enmod rewrite

#  work directory
WORKDIR /var/www/html

# Copy Yii2 code to container
COPY . /var/www/html

document root
ENV APACHE_DOCUMENT_ROOT /var/www/html/web

# Update Apache config
RUN sed -ri -e 's!/var/www/html!/var/www/html/web!g' /etc/apache2/sites-available/000-default.conf

# Writeable files with necessary permissions
RUN mkdir -p /var/www/html/runtime /var/www/html/web/assets \
    && chown -R www-data:www-data /var/www/html/runtime /var/www/html/web/assets \
    && chmod -R 775 /var/www/html/runtime /var/www/html/web/assets


EXPOSE 80

