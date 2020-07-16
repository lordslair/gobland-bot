#!/bin/sh

echo "`date +"%F %X"` Building Python dependencies and system set-up ..."

apk update --no-cache \
    && apk add --no-cache python3 \
    && apk add --no-cache --virtual .build-deps \
                                    python3-dev \
                                    libffi-dev \
                                    gcc \
                                    libc-dev \
                                    tzdata \
    && pip3 --no-cache-dir install -U discord.py \
                                      mysql-connector-python \
    && cp /usr/share/zoneinfo/Europe/Paris /etc/localtime \
    && apk del .build-deps

echo "`date +"%F %X"` Build done ..."

echo "`date +"%F %X"` Loading Python scripts ..."
mkdir  /code && cd /code
wget   https://github.com/lordslair/gobland-bot/archive/master.zip -O /code/gobland-it.zip &&
unzip  /code/gobland-it.zip -d /code/ &&
cp -a  /code/gobland-bot-master/kubernetes/python/* /code/ &&
rm -rf /code/gobland-bot-master /code/gobland-it.zip
echo "`date +"%F %X"` Loading done ..."

exec /code/gobland-it-discord
