#!/bin/sh

echo "`date +"%F %X"` Building PHP dependencies and system set-up ..."

apk update --no-cache \
    && apk add --no-cache python3 \
    && pip3 --no-cache-dir install -U discord.py \
    && apk add --no-cache --virtual .build-deps \
                                    tzdata \
    && cp /usr/share/zoneinfo/Europe/Paris /etc/localtime \
    && apk del .build-deps

echo "`date +"%F %X"` Build done ..."

exec /code/gobland-it-discord
