# Use the official PHP image as base (8.2 version)
FROM php:8.2-fpm

# Set working directory
WORKDIR /var/www

# Install system dependencies
RUN apt-get update && apt-get install -y \
    unzip \
    curl \
    netcat-openbsd \
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
    nginx \
    gettext-base \
    && docker-php-ext-configure gd \
    && docker-php-ext-install pdo pdo_mysql pdo_pgsql mbstring exif pcntl bcmath gd

RUN docker-php-ext-enable pdo_pgsql

# Install Composer globally _
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy Laravel application
COPY . /var/www
RUN chown -R www-data:www-data /var/www/public && chmod -R 755 /var/www/public

# ✅ Copy Nginx configuration
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/default.conf.template /etc/nginx/conf.d/default.conf.template

# Ensure public/index.php exists before proceeding
RUN if [ ! -f "/var/www/public/index.php" ]; then echo "<?php echo 'index.php missing!';" > /var/www/public/index.php; fi

# ✅ Create necessary directories and set permissions BEFORE composer install
RUN mkdir -p storage bootstrap/cache && \
    chmod -R 775 storage bootstrap/cache public && \
    chown -R www-data:www-data storage bootstrap/cache public

# ✅ Install PHP dependencies
RUN composer install --optimize-autoloader --no-dev

# ✅ Install Node.js dependencies and build frontend assets
RUN npm ci && npm run build

# ✅ Copy wait-for-db script & set permissions
COPY wait-for-db.sh /usr/local/bin/wait-for-db.sh
RUN chmod +x /usr/local/bin/wait-for-db.sh

# ✅ Copy cache clear script & set execute permissions
COPY clear_cache.sh /usr/local/bin/clear_cache.sh
RUN chmod +x /usr/local/bin/clear_cache.sh

# ✅ Expose port 8000 for Laravel & Nginx (80)
EXPOSE 8000 80

# ✅ Final CMD: Start PHP-FPM & Nginx
RUN ls -lah /var/www/public
CMD ["/bin/sh", "-c", "ls -lah /var/www/public && sleep 10 && wait-for-db.sh && php artisan config:clear && php artisan cache:clear && php artisan route:clear && php artisan view:clear && php-fpm -D && envsubst '$PORT' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"]
