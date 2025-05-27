ARG PHP_VERSION=8.2
ARG ALPINE_VERSION=3.20
FROM php:${PHP_VERSION}-fpm-alpine${ALPINE_VERSION} AS base

ENV APP_USER=www-data
ENV APP_ENV=production

RUN apk add --no-cache git bash imagemagick-dev libpng-dev libjpeg-turbo-dev icu-dev icu-data-full \
    && apk add --no-cache curl-dev imap-dev libxml2-dev libzip-dev bzip2-dev oniguruma-dev autoconf build-base linux-headers sqlite-dev \
    && docker-php-ext-install -j$(nproc) bcmath curl ftp gd imap intl mbstring pdo pdo_mysql pdo_sqlite soap xml zip \
    && pecl install imagick redis \
    && docker-php-ext-enable bcmath curl ftp gd imagick imap intl mbstring pdo pdo_mysql pdo_sqlite redis soap xml zip

COPY --from=composer:lts /usr/bin/composer /usr/bin/composer

COPY docker-entrypoint.sh /usr/local/bin/entrypoint
RUN chmod +x /usr/local/bin/entrypoint

WORKDIR /var/www

#COPY --chown=www-data . .

#RUN composer install --no-dev --prefer-dist --no-progress --no-interaction

ENTRYPOINT ["entrypoint"]


FROM base AS debug

ENV APP_ENV=local

RUN pecl install xdebug && docker-php-ext-enable xdebug;


FROM base
