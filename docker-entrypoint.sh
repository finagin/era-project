#!/usr/bin/env sh

set -e

if [ ! -f .env ]; then
    if [ -f .env.$APP_ENV ]; then
        cp .env.$APP_ENV .env
    else
        cp .env.example .env
    fi
fi

if [ "$APP_ENV" != "local" ]; then
    php artisan optimize
    php artisan db:show --silent && \
    php artisan migrate --force
else
    php artisan optimize:clear --except=cache
fi
php artisan storage:link

if [ "$#" -gt 0 ]; then
    exec php artisan "$@"
else
    exec php-fpm
fi
