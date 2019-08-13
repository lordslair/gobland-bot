#!/usr/bin/python3
import os
import sys
import mysql.connector
from mysql.connector import Error

db_name   = '32';
db_host   = 'gobland-it-mariadb';
db_user   = 'root'
db_pass   = os.environ['MARIADB_ROOT_PASSWORD']

db        = mysql.connector.connect( host     = db_host,
                                     database = db_name,
                                     user     = db_user,
                                     password = db_pass)

if db.is_connected():
    print("Connection initiated", file=sys.stderr)
    db_Info = db.get_server_info()
    print("Connected to MySQL Server version ", db_Info, file=sys.stderr)
    cursor = db.cursor()
    cursor.execute("select database();")
    record = cursor.fetchone()
    print ("Connected to MySQL DB ", record, file=sys.stderr)

def oukilest(oukilest_id):
    if (os.environ['MARIADB_ROOT_PASSWORD']):
        cursor   = db.cursor()
        SQL      = "SELECT Id,Nom,Niveau,Type,Clan,X,Y,N,Z FROM Vue WHERE Id = ?;"
        cursor.execute(SQL, [oukilest_id])

        stats  = cursor.fetchone()
        db.close()

        if not stats:
            print('DEBUG @stats is empty', file=sys.stderr)
        else:
            print('DEBUG @stats: {}'.format(stats), file=sys.stderr)
        return stats
    else:
        return None;

def cdm(cdm_id):
    if (os.environ['MARIADB_ROOT_PASSWORD']):
        cursor   = db.cursor()
        SQL      = "SELECT * FROM CdM WHERE IdMob = ? ORDER BY Date ASC LIMIT 1;"
        cursor.execute(SQL, [cdm_id])

        stats  = cursor.fetchone()
        db.close()

        if not stats:
            print('DEBUG @stats is empty', file=sys.stderr)
        else:
            print('DEBUG @stats: {}'.format(stats), file=sys.stderr)
        return stats
    else:
        return None;

if db.is_connected():
    cursor.close()
    db.close()
    print("Connection closed", file=sys.stderr)
