#!/usr/bin/perl
use strict;
use warnings;

use DBI;
use YAML::Tiny;
use Data::Dumper;

my $yaml_file = 'master.yaml';
my $yaml      = YAML::Tiny->read( $yaml_file );
my @db_list   = @{$yaml->[0]{db_list}};
my $db_path   = '/db';

foreach my $db (@db_list)
{
    print "DB: $db | PATH: $db_path$db\n";
    
if ( ! -f "$db_path/$db" )
{
    my $dbh = DBI->connect(
        "dbi:SQLite:dbname=$db_path/$db",
        "",
        "",
        { RaiseError => 1 },
    ) or die $DBI::errstr;

    $dbh->do("CREATE TABLE Credentials(Hash TEXT PRIMARY KEY,
                                       Id   INT,
                                       Type TEXT)");

    $dbh->do("CREATE TABLE ItemsCavernes(Id INT PRIMARY KEY,
                                 Type TEXT,
                                 Identifie TEXT,
                                 Nom TEXT,
                                 Magie TEXT,
                                 Desc TEXT,
                                 Poids INT,
                                 Taille INT,
                                 Qualite INT,
                                 Localisation TEXT,
                                 Utilise TEXT,
                                 Prix NUMERIC,
                                 Reservation TEXT,
                                 Matiere TEXT)");

    $dbh->do("CREATE TABLE ItemsGobelins(Id INT PRIMARY KEY,
                                 Gobelin INT,
                                 Type TEXT,
                                 Identifie TEXT,
                                 Nom TEXT,
                                 Magie TEXT,
                                 Desc TEXT,
                                 Poids INT,
                                 Taille INT,
                                 Qualite INT,
                                 Utilise TEXT,
                                 Matiere TEXT)");

    $dbh->do("CREATE TABLE Gobelins(Id      INT PRIMARY KEY,
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

    $dbh->do("CREATE TABLE MPBot (Id         INT PRIMARY KEY,
                                  IdGob      INT,
                                  PMSubject  TEXT,
                                  PMDate     TEXT,
                                  PMStatus   TEXT,
                                  PMExp      TEXT,
                                  PMText     TEXT)");

    $dbh->do("CREATE TABLE Meutes (Id       INT PRIMARY KEY,
                                   Nom      TEXT,
                                   IdMeute  INT,
                                   NomMeute TEXT,
                                   Tribu    TEXT,
                                   Niveau   INT)");

    $dbh->do("CREATE TABLE Cafards (IdCafard   INT PRIMARY KEY,
                                    Id         INT,
                                    Nom        TEXT,
                                    Effet      TEXT,
                                    Type       TEXT,
                                    Apparition TEXT,
                                    Etat       TEXT,
                                    PNG        TEXT)");

    $dbh->do("CREATE TABLE Skills (Id           TEXT PRIMARY KEY,
                                   IdGob        INT,
                                   Type         TEXT,
                                   IdSkill      INT,
                                   Niveau       INT,
                                   Connaissance INT,
                                   Tooltip      TEXT)");

    $dbh->do("CREATE TABLE FP_C (IdSkill     INT PRIMARY KEY,
                                 NomSkill    TEXT,
                                 PASkill     INT,
                                 TypeSkill   TEXT,
                                 NiveauSkill INT,
                                 Type        TEXT,
                                 Affinite    TEXT)");

    $dbh->do("CREATE TABLE FP_T (IdSkill     INT PRIMARY KEY,
                                 NomSkill    TEXT,
                                 PASkill     INT,
                                 TypeSkill   TEXT,
                                 NiveauSkill INT,
                                 Type        TEXT,
                                 Affinite    TEXT)");

    $dbh->do("CREATE TABLE FP_Lieu (IdLieu         INT PRIMARY KEY,
                                    Nom            TEXT,
                                    Type           TEXT,
                                    IdProprietaire TEXT,
                                    architecture   TEXT,
                                    mobile         TEXT,
                                    X              INT,
                                    Y              INT,
                                    Z              INT)");

    $dbh->do("CREATE TABLE Vue  (Id        INT PRIMARY KEY,
                                 Categorie TEXT,
                                 Nom       TEXT,
                                 Niveau    INT,
                                 Type      TEXT,
                                 Clan      TEXT,
                                 X         INT,
                                 Y         INT,
                                 N         INT,
                                 Z         TEXT)");

    $dbh->do("CREATE TABLE Gobelins2 (Id      INT PRIMARY KEY,
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

    $dbh->do("CREATE TABLE CdM  (Id       INT PRIMARY KEY,
                                 Date     TEXT,
                                 IdMob    INT,
                                 Name     TEXT,
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
                                 PERMax   INT)");

    $dbh->do("CREATE TABLE Suivants (Id        INT PRIMARY KEY,
                                     IdGob     INT,
                                     Nom       TEXT)");

    $dbh->do("CREATE TABLE Kills (Id         INT PRIMARY KEY,
                                  Date       TEXT,
                                  IdMob      INT,
                                  NomMob     TEXT,
                                  IdGob      INT,
                                  NomGob     TEXT,
                                  PMSubject  TEXT,
                                  PMText     TEXT)");
}
else
{
    print "DB already exists, doin' nothin'\n";
}
}
