#!/bin/sh

echo "`date +"%F %X"` Building PHP dependencies and system set-up ..."

apk update --no-cache \
    && apk add --no-cache --virtual .build-deps \
                                    tzdata \
    && cp /usr/share/zoneinfo/Europe/Paris /etc/localtime \
    && apk del .build-deps \
    && docker-php-ext-install mysqli

echo "`date +"%F %X"` Build done ..."

exec php-fpm
