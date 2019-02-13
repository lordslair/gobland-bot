# gobland-bot, the project :

This project is mainly a Tactical Interface (IT) for the game Gobland (GL).  
Its purpose is to parse data from GL from its API (Interface Externe - IE).  
It's done by a Perl backend to INSERT in SQLite, and a PHP frontend for the web intercace, served by an nginx.  
  
All of this inside Docker containers for portable purposes.  

Actually, as 3.0, it works this way :

 - (docker-perl) sequests GL IE every 3600s to fatch new data
 - (volume-db) stores the SQLite DB 
 - (docker-php) requests the DB
 - (docker-nginx) redirect visitors to their own docker-php (one container /clan)
