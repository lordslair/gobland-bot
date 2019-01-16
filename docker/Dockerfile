FROM alpine:3.7
MAINTAINER @Lordslair

RUN apk update \
    && apk add --no-cache perl perl-libwww perl-dbi perl-dbd-sqlite \
    && apk add --no-cache --virtual .build-deps \
                                    curl make perl-dev libc-dev gcc bash tzdata \
    && curl -L https://cpanmin.us | perl - App::cpanminus --no-wget \
    && cpanm --no-wget YAML::Tiny \
                       File::Pid \
    && cp /usr/share/zoneinfo/Europe/Paris /etc/localtime \
    && apk del .build-deps \
    && rm -rf /root/.cpanm \
    && mkdir /home/gobland-bot/

COPY gobland-bot    /home/gobland-bot/gobland-bot
COPY oneshot        /home/gobland-bot/oneshot
COPY lib/           /home/gobland-bot/lib/
COPY data/          /home/gobland-bot/data/
COPY test/          /home/gobland-bot/test/
COPY gl-config.yaml /home/gobland-bot/

RUN perl /home/gobland-bot/data/initDB.pl
RUN perl /home/gobland-bot/data/initFP.pl

ENTRYPOINT ["/home/gobland-bot/gobland-bot"]
