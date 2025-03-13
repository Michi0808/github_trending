# Use the official PHP image as base (8.2 version)
FROM php:8.2-fpm

# Set working directory
WORKDIR /var/www

# Install system dependencies
RUN apt-get update && apt-get install -y \
    unzip \
    curl \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    git \
    && docker-php-ext-configure gd \
    && docker-php-ext-install pdo pdo_mysql mbstring exif pcntl bcmath gd

# Install Composer globally
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy existing application files
COPY . .

# ✅ Create the bootstrap/cache directory if it doesn't exist
RUN mkdir -p /var/www/bootstrap/cache

# ✅ Set proper permissions
RUN chown -R www-data:www-data /var/www
RUN chown -R www-data:www-data /var/www/bootstrap/cache
RUN chmod -R 775 /var/www/bootstrap/cache

# ✅ Switch to a non-root user to avoid permission issues
USER www-data

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader

# Set file permissions
RUN chown -R www-data:www-data /var/www

# Expose port 9000 for PHP-FPM
EXPOSE 9000

# Start PHP-FPM server
CMD ["php-fpm"]
