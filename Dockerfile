FROM php:8.4-fpm

ARG USER=appuser
ARG UID=1000
ARG GID=1000

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libpq-dev \
    zip \
    unzip

# Install nodejs
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs

# Install PHP extensions
RUN docker-php-ext-install \
    pdo_pgsql \
    mbstring \
    exif \
    pcntl \
    bcmath \
    gd \
    sockets

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create system user to run Composer and Artisan Commands
RUN groupadd -g ${GID} ${USER} && \
    useradd -m -u ${UID} -g ${USER} -G www-data,root -d /home/${USER} ${USER} && \
    mkdir -p /home/${USER}/.composer && \
    chown -R ${USER}:${USER} /home/${USER} && \
    chown -R ${USER}:www-data /var/www

# Set working directory
WORKDIR /var/www

USER $USER

# Run startup script with bash (doesn't depend on executable bit from bind mount)
CMD ["bash", "/var/www/docker/start.sh"]
