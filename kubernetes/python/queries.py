#!/usr/bin/python3
import os
import sys
import mysql.connector
from mysql.connector import Error

db_host   = 'gobland-it-mariadb';
db_user   = 'root'
db_pass   = os.environ['MARIADB_ROOT_PASSWORD']

# Meta Query using one parameter, and a fetchone()
def query_fetchone(db_name,SQL,param):
    if (db_pass):

        db        = mysql.connector.connect( host     = db_host,
                                             database = db_name,
                                             user     = db_user,
                                             password = db_pass)
        cursor    = db.cursor()

        cursor.execute(SQL, (param,))
        result = cursor.fetchone()

        if db.is_connected():
            cursor.close()
            db.close()

        return result
    else:
        return None;

# Meta Query using one parameter, and a fetchall()
def query_fetchall(db_name,SQL,param):
    if (db_pass):

        db        = mysql.connector.connect( host     = db_host,
                                             database = db_name,
                                             user     = db_user,
                                             password = db_pass)
        cursor    = db.cursor()

        cursor.execute(SQL, [param])
        result = cursor.fetchall()

        if db.is_connected():
            cursor.close()
            db.close()

        return result
    else:
        return None;

# Returns one line with position of requested PJ/PNJ
def oukilest(id,db_name):
    SQL    = "SELECT Id,Nom,Niveau,Type,Clan,X,Y,N,Z FROM Vue WHERE Id = %s"
    result = query_fetchone(db_name,SQL,id)

    if result: return result

# Returns one line with last stored CdM of requested PNJ
def cdm(id,db_name):
    SQL    = "SELECT * FROM CdM WHERE IdMob = %s ORDER BY Date ASC LIMIT 1"
    result = query_fetchone(db_name,SQL,id)

    if result: return result

# Returns kill line(s) from DB, since the date passed as param
def kills(then_str,db_name):
    SQL    = "SELECT IdGob,Gobelins.Gobelin,PMSubject,PMDate,PMText,Date \
              FROM `MPBot` \
              INNER JOIN Gobelins on MPBot.IdGob = Gobelins.Id \
              WHERE ( PMText LIKE '%débarrassé%' OR PMText LIKE '%Son cadavre%' ) \
              AND   Date > %s \
              ORDER BY PMDate DESC;"
    result = query_fetchall(db_name,SQL,then_str)

    if result: return result

# Returns baratin line(s) from DB, since the date passed as param
def baratins(then_str,db_name):
    SQL    = "SELECT IdGob,Gobelins.Gobelin,PMSubject,PMDate,PMText \
              FROM `MPBot` \
              INNER JOIN Gobelins on MPBot.IdGob = Gobelins.Id \
              WHERE PMSubject LIKE 'Résultat Baratin%' \
              AND   Date > %s \
              ORDER BY PMDate ASC;"
    result = query_fetchall(db_name,SQL,then_str)

    if result: return result

# Returns wounded Creatures line(s) from DB, since the date passed as param
def wounded(then_str,db_name):
    SQL    = "SELECT Id,IdGob,PMDate,PMSubject,PMText,Date \
              FROM `MPBot` \
              WHERE PMSubject LIKE 'Résultat CdM%' \
              AND PMText LIKE '%Blessure : 9%' \
              AND Date > %s \
              ORDER BY Date ASC;"
    result = query_fetchall(db_name,SQL,then_str)

    if result: return result

# Returns Gobelins deaths line(s) from DB, since the date passed as param
def death(then_str,db_name):
    SQL    = "SELECT IdGob,Gobelins.Gobelin,PMSubject,PMDate,PMText,Date \
              FROM `MPBot` \
              INNER JOIN Gobelins on MPBot.IdGob = Gobelins.Id \
              WHERE PMSubject LIKE 'Vous êtes Mort%' \
              AND   Date > %s \
              ORDER BY PMDate DESC;"
    result = query_fetchall(db_name,SQL,then_str)

    if result: return result

# Returns Coterie drops line(s) from DB, since the date passed as param
def drops(then_str,db_name):
    SQL    = "SELECT DISTINCT PMText \
              FROM `MPBot` \
              WHERE PMSubject = 'Dépôt d''objets' \
              AND   Date > %s \
              ORDER BY Date DESC;"
    result = query_fetchall(db_name,SQL,then_str)

    if result: return result

# Returns soin line(s) from DB, since the date passed as param
def soins(then_str,db_name):
    SQL    = "SELECT IdGob,Gobelins.Gobelin,PMSubject,PMDate,PMText,Date \
              FROM `MPBot` \
              INNER JOIN Gobelins on MPBot.IdGob = Gobelins.Id \
              WHERE PMText LIKE '%Vous avez soigné%' \
              AND   Date > %s \
              ORDER BY PMDate DESC;"
    result = query_fetchall(db_name,SQL,then_str)

    if result: return result

# Returns patates line(s) from DB, since the date passed as param
def patates(then_str,db_name):
    SQL    = "SELECT IdGob,Gobelins.Gobelin,PMSubject,PMDate,PMText,Date,Gobelins.PV,Gobelins2.PVMax \
              FROM `MPBot` \
              INNER JOIN Gobelins  on MPBot.IdGob = Gobelins.Id \
              INNER JOIN Gobelins2 on MPBot.IdGob = Gobelins2.Id \
              WHERE PMSubject LIKE 'Résultat Défense%' \
              AND   Date > %s \
              ORDER BY PMDate DESC;"

    result = query_fetchall(db_name,SQL,then_str)

    if result: return result
