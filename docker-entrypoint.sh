#!/bin/bash
set -e  # Exit on error

echo "Starting Bagisto initialization..."

# Debug: Show environment variables
echo "Checking environment variables..."
echo "DB_HOST: $DB_HOST"
echo "DB_DATABASE: $DB_DATABASE"
echo "DB_USERNAME: $DB_USERNAME"
echo "APP_URL: $APP_URL"

# Debug: Check directory permissions
echo "Checking directory permissions..."
ls -la storage/
ls -la bootstrap/cache/

# Wait for database to be ready
echo "Waiting for database connection..."
while ! php artisan db:monitor > /dev/null 2>&1; do
    echo "Database not ready... waiting"
    sleep 1
done
echo "Database connection successful!"

# Initialize Bagisto if not already installed
if [ ! -f "storage/installed" ]; then
    echo "Starting fresh installation..."
    
    echo "Generating application key..."
    php artisan key:generate --force
    
    echo "Caching configuration..."
    php artisan config:cache
    
    echo "Running database migrations..."
    php artisan migrate --force
    
    echo "Seeding database..."
    php artisan db:seed --force
    
    echo "Creating storage link..."
    php artisan storage:link
    
    echo "Publishing vendor files..."
    php artisan vendor:publish --all --force
    
    echo "Clearing optimization cache..."
    php artisan optimize:clear
    
    echo "Creating installation flag..."
    touch storage/installed
    echo "Installation complete!"
else
    echo "Bagisto already installed, skipping initialization..."
fi

# Start Apache
echo "Starting Apache..."
apache2-foreground 