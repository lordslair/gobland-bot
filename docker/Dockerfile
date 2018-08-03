FROM alpine:3.7
MAINTAINER @Lordslair

RUN apk update \
    && apk add --no-cache perl-libwww perl apache2 apache2-utils \
    && apk add --no-cache --virtual .build-deps \
                                    curl make perl-dev libc-dev librsvg-dev gcc bash \
    && curl -L https://cpanmin.us | perl - App::cpanminus --no-wget \
    && cpanm --no-wget YAML::Tiny \
    && apk del .build-deps \
    && rm -rf /root/.cpanm \

    && mkdir /run/apache2 \
    && sed -i 's#AllowOverride [Nn]one#AllowOverride All#' /etc/apache2/httpd.conf \
    && sed -i 's/^#ServerName.*/ServerName gobland.lordslair.net/' /etc/apache2/httpd.conf \

    && sed -i 's#/var/log/apache2/#/web/logs/#g' /etc/logrotate.d/apache2 \
    && sed -i 's/Options Indexes/Options /g' /etc/apache2/httpd.conf \
    && mkdir /home/gobland-bot/

COPY gobland-bot    /home/gobland-bot/gobland-bot
COPY lib/           /home/gobland-bot/lib/
COPY gl-config.yaml /home/gobland-bot/

COPY htdocs/        /var/www/localhost/htdocs/

EXPOSE 80

# Start the service
CMD ["-D", "FOREGROUND"]
ENTRYPOINT ["/usr/sbin/httpd"]
