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
    libpq-dev \
    nodejs \
    npm \
    && docker-php-ext-configure gd \
    && docker-php-ext-install pdo pdo_mysql pdo_pgsql mbstring exif pcntl bcmath gd

RUN docker-php-ext-enable pdo_pgsql

# Install Composer globally
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy existing application files
COPY . .

# ✅ Create necessary directories and set permissions BEFORE composer install
RUN mkdir -p storage bootstrap/cache public && \
    chmod -R 775 storage bootstrap/cache public && \
    chown -R www-data:www-data storage bootstrap/cache public

# ✅ Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader

# ✅ Install Node.js dependencies and build frontend assets
RUN npm ci && npm run build

# ✅ Expose port 8000 for Laravel
EXPOSE 8000

# ✅ Move config clear/cache to CMD so it runs at container startup
CMD ["sh", "-c", "php artisan config:clear && php artisan cache:clear && php artisan serve --host=0.0.0.0 --port=8000"]
