# gobland-bot, the project :

This project is mainly a Tactical Interface (IT) for the game Gobland (GL).  
Its purpose is to parse data from GL from its API (Interface Externe - IE).  
It's done by a Perl backend to INSERT in SQLite, and a PHP frontend for the web interface, served by nginx.  
  
All of this inside Docker containers for portable purposes.  

Actually, as 3.0, it works this way :

 - (docker-perl) requests GL IE every 3600s to fetch new data
 - (volume-db) stores the SQLite DB 
 - (docker-php) requests the DB
 - (docker-nginx) redirect visitors to their own docker-php (one container /clan)
 - (docker-backup) run hourly/daily/monthly crons for backup
 - (volume-backup) stores the backups

### Which script does what ?

```
├── docker-compose.yml                |  To start the project
├── Dockerfile-perl                   |  To build the gobland-it-perl
├── Dockerfile-backup                 |  To build the gobland-it-backup
├── perl
│   ├── data
│   |    ├── initDB.pl                |  DB creation if needed
│   |    ├── initFP.pl                |  DP population using FP if needed
│   |    └── Lieux.csv                |  CSV containing already known location
|   ├── getIE_*.pl                    |  Scripts used to REQUEST IE and INSERT data in DB
│   ├── set*.pl                       |  Scripts used to modify data in DB
│   ├── gobland-it                    |  Main Perl script, endpoint for gobland-it-perl
│   └── master.yaml                   |  
├── nginx                             |  DIR containig nginx conf
│   ├── XX.conf                       |  nginx conf file      for gobland-it-php-XX
│   └── XX.htpasswd                   |  nginx httpasswd file for gobland-it-php-XX
└── php                               |  
    ├── *.php                         |  PHP pages to render the IT
    ├── images                        |  /images
    ├── js                            |  /js
    └── style                         |  /style
```

### Tech

I used mainy :

* Perl - as a lazy animal
* PHP
* SQLite
* [YAML::Tiny] - THE easy way to deal with YAML files
* [tristen/tablesort][tablesort] - One good JS to sort HTML tables
* [ariutta/svg-pan-zoom][svg-pan-zoom] - One good JS to zoom an SVG in HTML
* Docker to make it easy to maintain
* Alipne - probably the best/lighter base container to work with

And of course GitHub to store all these shenanigans. 

### Schematics

```
                       +-------------+
                       |    Nginx    |
                       +--+---+---+--+
                          |   |   |
        +-----------------+   |   +-----------------+
        |                     |                     |
+-------v-------+     +-------v-------+     +-------v-------+
|    php==01    |     |    php==01    |     |    php==01    |
+-------+-------+     +-------+-------+     +-------+-------+
        |                     |                     |
        |            +--------v--------+            |
        +----------->+  vol:sqlite|db  +<-----------+
                     +--------^--------+
                              |
                     +--------+--------+    +---------------+
                     |      Perl       +--->+    Gobland    |
                     +-----------------+    +---------------+
```

### Installation

The script and dependencies is meant to run in a Docker environment. 
Could work without it, but more practical this way.  

```
$ git clone https://github.com/lordslair/gobland-bot
$ cd gobland-bot/docker-compose
$ docker-compose up --build
```

```
# docker images
REPOSITORY                    TAG                         SIZE
lordslair/gobland-it-perl     latest                      44.7MB
lordslair/gobland-it-backup   latest                      12.1MB
php                           fpm-alpine                  79.8MB
nginx                         stable-alpine               16MB
alpine                        latest                      5.53MB
```

```
$ docker-compose ps
      Name                     Command              State         Ports
------------------------------------------------------------------------------
gobland-it-backup   crond -l2 -f                    Up
gobland-it-nginx    nginx -g daemon off;            Up      0.0.0.0:80->80/tcp
gobland-it-perl     /code/gobland-it                Up
gobland-it-php-31   docker-php-entrypoint php-fpm   Up      9000/tcp
gobland-it-php-32   docker-php-entrypoint php-fpm   Up      9000/tcp
```

```
$ docker-compose up
Starting gobland-it-php-32
Starting gobland-it-php-31
Starting gobland-it-perl
Starting gobland-it-nginx
Starting gobland-it-backup
Attaching to gobland-it-php-31, gobland-it-php-32, gobland-it-perl, gobland-it-nginx, gobland-it-backup
gobland-it-php-31 | [14-Feb-2019 12:58:52] NOTICE: fpm is running, pid 1
gobland-it-php-31 | [14-Feb-2019 12:58:52] NOTICE: ready to handle connections
gobland-it-php-32 | [14-Feb-2019 12:58:52] NOTICE: fpm is running, pid 1
gobland-it-php-32 | [14-Feb-2019 12:58:52] NOTICE: ready to handle connections
gobland-it-perl   | 2019-02-14 13:58:53 Starting daemon
gobland-it-perl   | 2019-02-14 13:58:53 exec: initDB
gobland-it-perl   | 2019-02-14 13:58:53 exec: initFP
gobland-it-perl   | 2019-02-14 13:59:05 :o) Entering loop 1
gobland-it-php-32 | 172.19.0.4 - User 14/Feb/2019:12:59:34 +0000 "GET /index.php" 200
gobland-it-nginx  | 109.190.254.56 - User [14/Feb/2019:12:59:34 +0000] "GET /index.php HTTP/1.1" 200
gobland-it-backup | Dumping : /db/32.db
gobland-it-backup | Dumping : /db/31.db
gobland-it-perl   | 2017-10-06 09:40:00 Stopping daemon
```

#### Disclaimer/Reminder

>The project is not mono-container, it requires at least 4 (perl/php/nginx/backup) + two volumes.  
>Each GL Clan has to be provisionned in its own container and DB for privacy reasons.

>Meaning that on a long term it could have to deal with dozens of -php containers,
>but still using one -nginx, one -perl and one -backup. No need to scale them.

### Todos

 - ~~Add a container for backups~~
 - Add a container php-public with consolidated DB for CdM/Locator purposes
 - Add a container for Discord integration
 - PHP Error logs accessible from outside the container (docker logs stuff)
 - /data accessible from outside the container (docker volume stuff)
 - Plan the Kubernetes integration instead of Compose
 
### Useful stuff
   
   * [Daemon exemple script][daemon] : the gobland-it doemon is based on this (Kudos to you)

---
   [daemon]: <http://www.andrewault.net/2010/05/27/creating-a-perl-daemon-in-ubuntu/>
   [tablesort]: <https://github.com/tristen/tablesort>
   [svg-pan-zoom]: <https://github.com/ariutta/svg-pan-zoom>
