FROM php:8.2-apache

# Arguments defined in docker-compose.yml
ARG user=www-data
ARG uid=1000
ARG container_project_path=/var/www/html

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    libzip-dev \
    nodejs \
    npm && \
    curl -fsSL https://deb.nodesource.com/setup_16.x | bash - && apt-get install -y nodejs

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip intl calendar

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create system user (only if not www-data)
RUN if [ "${user}" != "www-data" ]; then \
    useradd -G www-data,root -u $uid -d /home/$user $user; \
    mkdir -p /home/$user/.composer; \
    chown -R $user:$user /home/$user; \
    fi

# Set working directory
WORKDIR $container_project_path

# Create necessary directories and set permissions
RUN mkdir -p storage/framework/{sessions,views,cache} \
    && mkdir -p storage/logs \
    && mkdir -p bootstrap/cache

# Copy project files
COPY . .

# Set proper ownership and permissions
USER root
RUN chown -R www-data:www-data . \
    && chmod -R 755 . \
    && chmod -R 775 storage bootstrap/cache public \
    && find storage bootstrap/cache -type d -exec chmod 775 {} \;

# Setup npm permissions
RUN mkdir -p /var/www/.npm && \
    chown -R www-data:www-data /var/www/.npm

# Copy apache configuration
COPY .configs/apache.conf /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite

# Install dependencies
USER $user
RUN composer install --no-dev --optimize-autoloader --ignore-platform-reqs
RUN npm install && npm run build

# Copy and set permissions for entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
USER root
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
USER $user

EXPOSE 80
CMD ["/usr/local/bin/docker-entrypoint.sh"] 