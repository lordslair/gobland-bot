#!/usr/bin/python3
import os
import sys
import mysql.connector
from mysql.connector import Error

db_name   = '32';
db_host   = 'gobland-it-mariadb';
db_user   = 'root'
db_pass   = os.environ['MARIADB_ROOT_PASSWORD']

def oukilest(oukilest_id):
    if (db_pass):

        db        = mysql.connector.connect( host     = db_host,
                                             database = db_name,
                                             user     = db_user,
                                             password = db_pass)
        cursor   = db.cursor()
        SQL      = "SELECT Id,Nom,Niveau,Type,Clan,X,Y,N,Z FROM Vue WHERE Id = %s"

        cursor.execute(SQL, (oukilest_id,))
        stats  = cursor.fetchone()

        if db.is_connected():
            cursor.close()
            db.close()

        return stats
    else:
        return None;

def cdm(cdm_id):
    if (db_pass):

        db        = mysql.connector.connect( host     = db_host,
                                             database = db_name,
                                             user     = db_user,
                                             password = db_pass)
        cursor   = db.cursor()
        SQL      = "SELECT * FROM CdM WHERE IdMob = %s ORDER BY Date ASC LIMIT 1;"

        cursor.execute(SQL, [cdm_id])
        stats  = cursor.fetchone()

        if db.is_connected():
            cursor.close()
            db.close()

        return stats
    else:
        return None;

# Returns kill line(s) from DB, since the date passed as param
def kills(then_str):
    if (db_pass):

        db        = mysql.connector.connect( host     = db_host,
                                             database = db_name,
                                             user     = db_user,
                                             password = db_pass)
        cursor   = db.cursor()
        SQL      = "SELECT * FROM Kills WHERE Date > %s ORDER BY Date ASC;"

        cursor.execute(SQL, [then_str])
        infos  = cursor.fetchall()

        if db.is_connected():
            cursor.close()
            db.close()

        return infos
    else:
        return None;

# Returns baratin line(s) from DB, since the date passed as param
def baratins(then_str):
    if (db_pass):

        db        = mysql.connector.connect( host     = db_host,
                                             database = db_name,
                                             user     = db_user,
                                             password = db_pass)
        cursor   = db.cursor()
        SQL      = "SELECT IdGob,Gobelins.Gobelin,PMSubject,PMDate,PMText \
                    FROM `MPBot` \
                    INNER JOIN Gobelins on MPBot.IdGob = Gobelins.Id \
                    WHERE PMSubject LIKE 'Résultat Baratin%' \
                    AND   PMDate > %s \
                    ORDER BY PMDate ASC;"

        cursor.execute(SQL, [then_str])
        infos  = cursor.fetchall()

        if db.is_connected():
            cursor.close()
            db.close()

        return infos
    else:
        return None;
