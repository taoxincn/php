FROM php:7.4-fpm-alpine

ENV  TIME_ZONE Asiz/Shanghai
# docker-entrypoint.sh dependencies
RUN apk add --no-cache \
    bash \
    tzdata

# install the PHP extensions we need
# postgresql-dev is needed for https://bugs.alpinelinux.org/issues/3642
RUN set -eux; \
    # sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories; \
    apk add --no-cache --virtual .build-deps \
        coreutils \
        freetype-dev \
        libjpeg-turbo-dev \
        libpng-dev \
        libzip-dev \
        postgresql-dev \
        bzip2-dev \
        libwebp-dev \
        libxpm-dev \
    ; \
    \
    docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp --with-xpm; \
    docker-php-ext-install -j "$(nproc)" \
        bz2 \
        gd \
        opcache \
        mysqli \
        pdo_mysql \
        pdo_pgsql \
        zip \
    ; \
    \
    runDeps="$( \
        scanelf --needed --nobanner --format '%n#p' --recursive /usr/local/lib/php/extensions \
            | tr ',' '\n' \
            | sort -u \
            | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
    )"; \
    apk add --virtual .my-phpexts-rundeps $runDeps; \
    apk del --no-network .build-deps

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN set -ex; \
    \
    { \
        echo 'opcache.memory_consumption=128'; \
        echo 'opcache.interned_strings_buffer=8'; \
        echo 'opcache.max_accelerated_files=4000'; \
        echo 'opcache.revalidate_freq=2'; \
        echo 'opcache.fast_shutdown=1'; \
    } > $PHP_INI_DIR/conf.d/opcache-recommended.ini; \
    \
    { \
        echo 'session.cookie_httponly = 1'; \
        echo 'session.use_strict_mode = 1'; \
    } > $PHP_INI_DIR/conf.d/session-strict.ini; \
    \
    { \
        echo 'allow_url_fopen = Off'; \
        echo 'max_execution_time = 600'; \
        echo 'memory_limit = 512M'; \
    } > $PHP_INI_DIR/conf.d/phpmyadmin-misc.ini

# Copy main script
COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT [ "docker-entrypoint.sh" ]
CMD ["php-fpm"]
