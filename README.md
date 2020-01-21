# gobland-bot, the project :

This project is mainly a Tactical Interface (IT) for the game Gobland (GL).  
Its purpose is to parse data from GL from its API (Interface Externe - IE).  
It's done by a Perl backend to INSERT in MySQL.  
And a PHP frontend, served by nginx to render these pages.  
Additional Python code can be used for a Discord bot.
  
All of this inside Docker containers for portable purposes.  
These containers are powered up by Kubernetes since v4.0 (summer 2019)

Actually, as 4.11, it works this way :

 - (gobland-it-perl) requests GL IE every 3600s to fetch new data
 - (gobland-it-php) requests the DB / generates HTML
 - (gobland-it-nginx) redirect visitors to the nginx layer
 - (gobland-it-mariadb) handles the DB (one /clan)
 - (gobland-it-python) runs the Discord bot (new v4.10 feature)
 - (gobland-it-backup) runs the rolling backups (new v4.11 feature)

### Which script does what ?

```
.
├── bash
│   └── cron-backup-sh.*              |  Shell scripts to automate backups with cron
├── k8s                               |  
│   ├── configmap-*.yaml              |  ConfigMap files
│   ├── deployment-*.yaml             |  Pods deployment files
│   ├── service-*.yaml                |  Services deployment files
│   └── volume-*.yaml                 |  Volumes deployment files
├── perl                              |  
│   ├── data                          |  
│   |    ├── initDB.pl                |  DB creation if needed
│   |    ├── initFP.pl                |  DB population using FP if needed
│   |    └── Lieux.csv                |  CSV containing already known location
|   ├── getIE_*.pl                    |  Scripts used to REQUEST IE and INSERT data in DB
│   ├── set*.pl                       |  Scripts used to modify data in DB
│   └── gobland-it                    |  Perl daemon for IE data collection
├── php                               |  
│   ├── *.php                         |  PHP to render the IT HTML pages
│   ├── images                        |  /images
│   ├── js                            |  /js
│   ├── sessions                      |  /sessions for new auth
│   └── style                         |  /style
└── python                            |  
    ├── gobland-it-discord            |  Python Discord daemon
    └── queries.py                    |  library to handle SQL layer
```

### Tech

I used mainy :

* Perl - as a lazy animal
* PHP
* MySQL/MariaDB
* [tristen/tablesort][tablesort] - One good JS to sort HTML tables
* [ariutta/svg-pan-zoom][svg-pan-zoom] - One good JS to zoom an SVG in HTML
* [docker/docker-ce][docker] to make it easy to maintain
* [kubernetes/kubernetes][kubernetes] to make everything smooth
* [Alpine][alpine] - probably the best/lighter base container to work with
* [Daemon exemple script][daemon] - gobland-it Perl daemon is based on this (Kudos)

And of course GitHub to store all these shenanigans. 

### Schematics

```
      +-----------------------------------------------+
      |                  LoadBalancer                 |
      +-+-------------------------------------------+-+
        |                                           |
+-------v-------+                           +-------v-------+
|     nginx     |                           |     nginx     |
+-------+-------+                           +-------+-------+
        |                                           |
+-------v-------+                           +-------v-------+
|      php      |                           |      php      |
+-------+-------+                           +-------+-------+
        |            +-----------------+            |
        +----------->+     mariadb     +<-----------+
                     +-^------^------^-+
                       |      |      |
         +-------------+-+    |    +-+---------------+
         |     python    |    |    |      perl       |
         +----+----------+    |    +----------+------+
              |               |               |
+-------------v-+     +-------+-------+     +-v-------------+
|  discord bot  |     |     backup    |     |   gobland.fr  |
+---------------+     +---------------+     +---------------+
```

### Installation

The core and its dependencies are meant to run in a Docker/k8s environment.  
Could work without it, but more practical to maintain this way.  

Every part is kept in a different k8s file separately for more details.  

```
$ git clone https://github.com/lordslair/gobland-bot
$ cd gobland-bot/kubernetes/k8s
$ kubectl apply -f *
```

This will create : 
- The 6+ pods : perl, python, php, mariadb, nginx, backup

```
$ kubectl get pods
NAME                                     READY   STATUS    RESTARTS   AGE
gobland-it-backup-7f57f8bb7c-nhj64       1/1     Running   0          13m
gobland-it-mariadb-67fd7658b-kcnfv       2/2     Running   2          121d
gobland-it-nginx-77c56fcf5b-p47th        1/1     Running   1          118d
gobland-it-nginx-77c56fcf5b-sqww4        1/1     Running   1          118d
gobland-it-perl-6db49459df-rcs79         1/1     Running   0          10d
gobland-it-php-b4f75dbfc-77rgb           1/1     Running   1          128d
gobland-it-php-b4f75dbfc-zptbp           1/1     Running   1          128d
gobland-it-python-5bdf47d9bc-bjhm2       1/1     Running   0          3h50m
```

- The 5 volumes : code-perl, code-python, code-php, mariadb-db, backup-db

```
$ kubectl get pvc
NAME                     STATUS   VOLUME                   CAPACITY   [...]
gobland-it-backup-db     Bound    pvc-[...]-5e59fec92f65   5Gi        [...]
gobland-it-code-perl     Bound    pvc-[...]-568d3b4f5a48   1Gi        [...]
gobland-it-code-php      Bound    pvc-[...]-568d3b4f5a48   1Gi        [...]
gobland-it-code-python   Bound    pvc-[...]-8674a639f663   1Gi        [...]
gobland-it-mariadb-db    Bound    pvc-[...]-568d3b4f5a48   1Gi        [...]
```

- The 4 services : php, mariadb, nginx & loadbalancer

```
$ kubectl get services
NAME                         TYPE           CLUSTER-IP     EXTERNAL-IP  PORT(S)     
gobland-it-lb                LoadBalancer   10.3.40.58     [...]        80:30632/TCP
gobland-it-mariadb           ClusterIP      10.3.51.95     <none>       3306/TCP    
gobland-it-nginx             ClusterIP      10.3.98.218    <none>       80/TCP      
gobland-it-php               ClusterIP      10.3.159.93    <none>       9000/TCP     
```

#### Disclaimer/Reminder

>The project is not mono-container, it requires at least 5 (perl/php/nginx/mariadb/python) + four volumes.  
>Each GL Clan has to be provisionned in its own DB for privacy reasons.  
>Meaning that on a long term it could have to deal with great numbers of DB, inside the same MariaDB container.  
>Only nginx/php needs to be scaled up to handle the load (and maybe MariaDB clusterized at some point).  

### Todos

 - ~~Add a container for backups~~ (v4.11)
 - Add a container php-public with consolidated DB for CdM/Locator purposes
 - ~~Add a container for Discord integration~~ (v4.10)
 - PHP Error logs accessible from outside the container (docker logs stuff)
 - ~~Plan the Kubernetes integration instead of Compose~~

---
   [daemon]: <http://www.andrewault.net/2010/05/27/creating-a-perl-daemon-in-ubuntu/>
   [tablesort]: <https://github.com/tristen/tablesort>
   [svg-pan-zoom]: <https://github.com/ariutta/svg-pan-zoom>
   [kubernetes]: <https://github.com/kubernetes/kubernetes>
   [docker]: <https://github.com/docker/docker-ce>
   [alpine]: <https://github.com/alpinelinux>


