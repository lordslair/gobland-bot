#!/usr/bin/python3
import os
import sys
import mysql.connector

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

        if not stats:
            print('DEBUG @stats is empty', file=sys.stderr)
        else:
            print('DEBUG @stats: {}'.format(stats), file=sys.stderr)

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

        if not stats:
            print('DEBUG @stats is empty', file=sys.stderr)
        else:
            print('DEBUG @stats: {}'.format(stats), file=sys.stderr)

        if db.is_connected():
            cursor.close()
            db.close()

        return stats
    else:
        return None;
