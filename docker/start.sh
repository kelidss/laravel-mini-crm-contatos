#!/usr/bin/env bash
set -e

APP_ENV_VALUE="${APP_ENV:-local}"
echo "ENV: ${APP_ENV_VALUE}"

if [ "${APP_ENV_VALUE}" = "local" ]; then
    echo "Running composer install..."
    composer install

    echo "Running NPM install..."
    npm install

    echo "Running NPM dev in background..."
    npm run dev -- --host 0.0.0.0 &
else
    echo "Running composer install..."
    composer install --no-dev --optimize-autoloader --no-interaction --no-progress

    echo "Running NPM install..."
    npm install

    echo "Building frontend..."
    npm run build
fi

echo "Starting PHP-FPM..."
php-fpm
