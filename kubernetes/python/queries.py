#!/usr/bin/python
import sqlite3
import os

def oukilest(oukilest_id):
    if (os.environ['DBNAME']):
        sqlite_db = os.environ['DBNAME'];
        db       = sqlite3.connect('/db/' + sqlite_db)

        cursor   = db.cursor()
        SQL      = "SELECT Id,Nom,Niveau,Type,Clan,X,Y,N,Z FROM Vue WHERE Id = ?;"
        cursor.execute(SQL, [oukilest_id])

        stats  = cursor.fetchone()
        db.close()

#        if not stats:
#            print('DEBUG @stats is empty')
#        else:
#            print('DEBUG @stats: {}'.format(stats))
        return stats
    else:
        return None;


def cdm(cdm_id):
    if (os.environ['DBNAME']):
        sqlite_db = os.environ['DBNAME'];
        db       = sqlite3.connect('/db/' + sqlite_db)

        cursor   = db.cursor()
        SQL      = "SELECT * FROM CdM WHERE IdMob = ? ORDER BY Date ASC LIMIT 1;"
        cursor.execute(SQL, [cdm_id])

        stats  = cursor.fetchone()
        db.close()

#        if not stats:
#            print('DEBUG @stats is empty')
#        else:
#            print('DEBUG @stats: {}'.format(stats))
        return stats
    else:
        return None;
