#!/usr/bin/perl
use strict;
use warnings;

use DBI;

my @db_list   = split(',', $ENV{'DBLIST'});
my $db_file   = 'initDB.SQL';
my $db_driver = 'mysql';
my $db_host   = 'gobland-it-mariadb';
my $db_port   = '3306';
my $db_pass   = $ENV{'MARIADB_ROOT_PASSWORD'};
my $dsn       = "DBI:$db_driver:host=$db_host;port=$db_port";
my $dbh       = DBI->connect($dsn, 'root', $db_pass, { RaiseError => 1 }) or die $DBI::errstr;

foreach my $db (@db_list)
{
    my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = localtime(time);
    my $dateTime = sprintf "%4d-%02d-%02d %02d:%02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min, $sec;
    print STDERR "$dateTime [initDB] DB: $db\n";

    $dbh->do("CREATE DATABASE IF NOT EXISTS `$db`");
    $dbh->do("USE `$db`");

    $dbh->do("CREATE TABLE IF NOT EXISTS Credentials(Hash VARCHAR(32) PRIMARY KEY,
                                       Id   INT,
                                       Type TEXT)");

    $dbh->do("CREATE TABLE IF NOT EXISTS ItemsCavernes(Id INT PRIMARY KEY,
                                 Type TEXT,
                                 Identifie TEXT,
                                 Nom TEXT,
                                 Magie TEXT,
                                 `Desc` TEXT,
                                 Poids INT,
                                 Taille INT,
                                 Qualite INT,
                                 Localisation TEXT,
                                 Utilise TEXT,
                                 Prix NUMERIC,
                                 Reservation TEXT,
                                 Matiere TEXT)");

    $dbh->do("CREATE TABLE IF NOT EXISTS ItemsGobelins(Id INT PRIMARY KEY,
                                 Gobelin INT,
                                 Type TEXT,
                                 Identifie TEXT,
                                 Nom TEXT,
                                 Magie TEXT,
                                 `Desc` TEXT,
                                 Poids INT,
                                 Taille INT,
                                 Qualite INT,
                                 Utilise TEXT,
                                 Matiere TEXT)");

    $dbh->do("CREATE TABLE IF NOT EXISTS Gobelins(Id      INT PRIMARY KEY,
                                    Gobelin TEXT,
                                    Race    TEXT,
                                    Tribu   TEXT,
                                    Niveau  INT,
                                    X       INT,
                                    Y       INT,
                                    N       INT,
                                    Z       TEXT,
                                    DLA     TEXT,
                                    Etat    TEXT,
                                    PA      INT,
                                    PV      INT,
                                    PX      INT,
                                    PXPerso INT,
                                    PI      INT,
                                    CT      INT)");

    $dbh->do("CREATE TABLE IF NOT EXISTS MPBot (Id         INT PRIMARY KEY,
                                  IdGob      INT,
                                  PMSubject  TEXT,
                                  PMDate     TEXT,
                                  PMStatus   TEXT,
                                  PMExp      TEXT,
                                  PMText     TEXT)");

    $dbh->do("CREATE TABLE IF NOT EXISTS Meutes (Id       INT PRIMARY KEY,
                                   Nom      TEXT,
                                   IdMeute  INT,
                                   NomMeute TEXT,
                                   Tribu    TEXT,
                                   Niveau   INT)");

    $dbh->do("CREATE TABLE IF NOT EXISTS Cafards (IdCafard   INT PRIMARY KEY,
                                    Id         INT,
                                    Nom        TEXT,
                                    Effet      TEXT,
                                    Type       TEXT,
                                    Apparition TEXT,
                                    Etat       TEXT,
                                    PNG        TEXT)");

    $dbh->do("CREATE TABLE IF NOT EXISTS Skills (Id           VARCHAR(10) PRIMARY KEY,
                                   IdGob        INT,
                                   Type         TEXT,
                                   IdSkill      INT,
                                   Niveau       INT,
                                   Connaissance INT,
                                   Tooltip      TEXT)");

    $dbh->do("CREATE TABLE IF NOT EXISTS FP_C (IdSkill     INT PRIMARY KEY,
                                 NomSkill    TEXT,
                                 PASkill     INT,
                                 TypeSkill   TEXT,
                                 NiveauSkill INT,
                                 Type        TEXT,
                                 Affinite    TEXT)");

    $dbh->do("CREATE TABLE IF NOT EXISTS FP_T (IdSkill     INT PRIMARY KEY,
                                 NomSkill    TEXT,
                                 PASkill     INT,
                                 TypeSkill   TEXT,
                                 NiveauSkill INT,
                                 Type        TEXT,
                                 Affinite    TEXT)");

    $dbh->do("CREATE TABLE IF NOT EXISTS FP_Lieu (IdLieu         INT PRIMARY KEY,
                                    Nom            TEXT,
                                    Type           TEXT,
                                    IdProprietaire TEXT,
                                    architecture   TEXT,
                                    mobile         TEXT,
                                    X              TEXT,
                                    Y              TEXT,
                                    Z              TEXT)");

    $dbh->do("CREATE TABLE IF NOT EXISTS Vue  (Id        INT PRIMARY KEY,
                                 Categorie TEXT,
                                 Nom       TEXT,
                                 Niveau    INT,
                                 Type      TEXT,
                                 Clan      TEXT,
                                 X         INT,
                                 Y         INT,
                                 N         INT,
                                 Z         TEXT)");

    $dbh->do("CREATE TABLE IF NOT EXISTS Gobelins2 (Id      INT PRIMARY KEY,
                                      Nom     TEXT,
                                      DLA     TEXT,
                                      BPDLA   INT,
                                      BMDLA   INT,
                                      PVMax   INT,
                                      BPPVMax INT,
                                      BMPVMax INT,
                                      ATT     INT,
                                      BPATT   INT,
                                      BMATT   INT,
                                      ESQ     INT,
                                      BPESQ   INT,
                                      BMESQ   INT,
                                      DEG     INT,
                                      BPDEG   INT,
                                      BMDEG   INT,
                                      REG     INT,
                                      BPREG   INT,
                                      BMREG   INT,
                                      PER     INT,
                                      BPPER   INT,
                                      BMPER   INT,
                                      BPArm   INT,
                                      BMArm   INT,
                                      PITotal INT,
                                      Faim    INT,
                                      MM      INT,
                                      BMM     INT,
                                      BPMM    INT,
                                      BMMM    INT,
                                      RM      INT,
                                      BRM     INT,
                                      BPRM    INT,
                                      BMRM    INT,
                                      MT      INT,
                                      BMT     INT,
                                      BPMT    INT,
                                      BMMT    INT,
                                      RT      INT,
                                      BRT     INT,
                                      BPRT    INT,
                                      BMRT    INT,
                                      MR      INT,
                                      BMR     INT,
                                      BPMR    INT,
                                      BMMR    INT,
                                      RR      INT,
                                      BRR     INT,
                                      BPRR    INT,
                                      BMRR    INT,
                                      MS      INT,
                                      BMS     INT,
                                      BPMS    INT,
                                      BMMS    INT,
                                      RS      INT,
                                      BRS     INT,
                                      BPRS    INT,
                                      BMRS    INT,
                                      MC      INT,
                                      BMC     INT,
                                      BPMC    INT,
                                      BMMC    INT,
                                      RC      INT,
                                      BRC     INT,
                                      BPRC    INT,
                                      BMRC    INT,
                                      MP      INT,
                                      BMP     INT,
                                      BPMP    INT,
                                      BMMP    INT,
                                      RP      INT,
                                      BRP     INT,
                                      BPRP    INT,
                                      BMRP    INT)");

    $dbh->do("CREATE TABLE IF NOT EXISTS CdM  (Id       INT PRIMARY KEY,
                                 Date     TEXT,
                                 IdMob    INT,
                                 Name     TEXT,
                                 Type     TEXT,
                                 Niveau   INT,
                                 PVMin    INT,
                                 PVMax    INT,
                                 Blessure INT,
                                 ATTMin   INT,
                                 ATTMax   INT,
                                 ESQMin   INT,
                                 ESQMax   INT,
                                 DEGMin   INT,
                                 DEGMax   INT,
                                 REGMin   INT,
                                 REGMax   INT,
                                 ARMMin   INT,
                                 ARMmax   INT,
                                 PERMin   INT,
                                 PERMax   INT,
                                 Volante  TEXT,
                                 Pouvoir  TEXT,
                                 ATTDist  TEXT)");

    $dbh->do("CREATE TABLE IF NOT EXISTS Suivants (Id        INT PRIMARY KEY,
                                     IdGob     INT,
                                     Nom       TEXT)");

    $dbh->do("CREATE TABLE IF NOT EXISTS Kills (Id         INT PRIMARY KEY,
                                  Date       TEXT,
                                  IdMob      INT,
                                  NomMob     TEXT,
                                  IdGob      INT,
                                  NomGob     TEXT,
                                  PMSubject  TEXT,
                                  PMText     TEXT)");

    $dbh->do("CREATE TABLE IF NOT EXISTS Carte (Id        INT PRIMARY KEY,
                                  Categorie TEXT,
                                  Nom       TEXT,
                                  Niveau    INT,
                                  Type      TEXT,
                                  Clan      TEXT,
                                  X         INT,
                                  Y         INT,
                                  N         INT,
                                  Z         TEXT,
                                  Time      INT,
                                  Date      TEXT)");

    $dbh->do("CREATE TABLE IF NOT EXISTS Enchantements (Id        INT PRIMARY KEY,
                                          Item      TEXT,
                                          Plante    TEXT,
                                          PlanteQ   TEXT,
                                          Compo1    TEXT,
                                          Compo1Q   TEXT,
                                          Compo2    TEXT,
                                          Compo2Q   TEXT,
                                          Status    TEXT)");
}

$dbh->disconnect();
