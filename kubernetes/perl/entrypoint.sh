#!/bin/sh

echo "`date +"%F %X"` Building Perl dependencies and system set-up ..."

apk update \
    && apk add --no-cache perl perl-libwww perl-dbi perl-dbd-mysql \
    && apk add --no-cache --virtual .build-deps \
                                    curl make perl-dev libc-dev gcc bash tzdata \
    && curl -L https://cpanmin.us | perl - App::cpanminus --no-wget \
    && cpanm --no-wget File::Pid \
    && cp /usr/share/zoneinfo/Europe/Paris /etc/localtime \
    && apk del .build-deps \
    && rm -rf /root/.cpanm

echo "`date +"%F %X"` Build done ..."

echo "`date +"%F %X"` Loading Perl scripts ..."
mkdir  /code && cd /code
wget   https://github.com/lordslair/gobland-bot/archive/master.zip -O /tmp/gobland-it.zip &&
unzip  /code/gobland-it.zip -d /code/ &&
cp -a  /code/gobland-bot-master/kubernetes/perl/* /code/ &&
rm -rf /code/gobland-bot-master /code/gobland-it.zip
echo "`date +"%F %X"` Loading done ..."

exec /code/gobland-it
