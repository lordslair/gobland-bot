#!/bin/sh

echo "`date +"%F %X"` Building shell dependencies and system set-up ..."

apk update \
    && apk add --no-cache bzip2 bash mysql-client \
    && apk add --no-cache --virtual .build-deps \
                                    tzdata \
    && cp /usr/share/zoneinfo/Europe/Paris /etc/localtime \
    && apk del .build-deps \
    && mv /backup/cron-backup-sh.hourly /etc/periodic/hourly/cron-backup-sh \
    && mv /backup/cron-backup-sh.daily   /etc/periodic/daily/cron-backup-sh \
    && mv /backup/cron-backup-sh.monthly /etc/periodic/monthly/cron-backup-sh \

echo "`date +"%F %X"` Build done ..."

exec /usr/sbin/crond -l2 -f
