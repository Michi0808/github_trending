# Use the official PHP image (8.2 version)
FROM php:8.2-fpm

# Install Node.js and npm
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

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
    && docker-php-ext-configure gd \
    && docker-php-ext-install pdo pdo_mysql pdo_pgsql mbstring exif pcntl bcmath gd

RUN docker-php-ext-enable pdo_pgsql

# Install Composer globally
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy existing application files
COPY . .

# Set permissions
RUN mkdir -p storage bootstrap/cache public/build && \
    chmod -R 775 storage bootstrap/cache public/build && \
    chown -R www-data:www-data storage bootstrap/cache public/build

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader

# ✅ Fix: Ensure Vite build is generated properly
RUN npm install && npm run build

# ✅ Fix: Ensure config cache is cleared before running the app
RUN php artisan config:clear && php artisan cache:clear && php artisan view:clear

# Expose port 8000 for Laravel
EXPOSE 8000

# Start Laravel application
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
