#!/usr/bin/perl
use strict;
use warnings;
    
use DBI;
use YAML::Tiny;
use POSIX qw(strftime);

my $yaml_file = 'master.yaml';
my $yaml      = YAML::Tiny->read( $yaml_file );
my @db_list   = @{$yaml->[0]{db_list}};
my $db_path   = '/db';
    
foreach my $db (@db_list)
{
    print "DB: $db | setMP2Kills\n";
    
    if ( -f "$db_path/$db" )
    {
        my $dbh = DBI->connect(
            "dbi:SQLite:dbname=$db_path/$db",
            "",
            "",
            { RaiseError => 1 },
        ) or die $DBI::errstr;

        my $now     = strftime "%Y-%m-%d", localtime;

        my $req_mps = $dbh->prepare( "SELECT MPBot.Id,Gobelins.Id,Gobelins.Gobelin,PMSubject,PMDate,PMText \
                                      FROM Gobelins \
                                      INNER JOIN MPBot on Gobelins.Id = MPBot.IdGob \
                                      WHERE ( PMText LIKE '%débarrassé%' OR PMText LIKE '%Son cadavre%' ) \
                                      AND PMDate LIKE '$now%'");
        $req_mps->execute();

        while (my @row = $req_mps->fetchrow_array)
        {
            my $mp_id      = $row[0];
            my $gob_id     = $row[1];
            my $gob_name   = $row[2];
            my $mp_subject = $row[3];
            my $mp_date    = $row[4];
            my $mp_text    = $row[5];

            my $mob_id;
            my $mob_name;

            # DATA: Résultat Attaque - Orque (305855)
            # DATA: Résultat Attaque Suivant - Chauve-souris Géante (303448)
            if ( $mp_subject =~ / - ([-\P{Latin}\w\s\']*) \((\d*)\)/ )
            {
                $mob_name = $1;
                $mob_id   = $2;
                $mob_name =~ s/\'/\'\'/g;
            }
            # DATA: Résultat Potion
            elsif ( $mp_subject eq 'Résultat Potion' )
            {
                # DATA: sur [312463] Bondin
                if ( $mp_text =~ /sur \[(\d*)\] ([-\P{Latin}\w\s\']*)\.<P>/ )
                {
                    $mob_id   = $1;
                    $mob_name = $2;
                }
            }
            elsif ( $mp_subject eq 'Résultat Eclair' )
            {
                # Too complicated to parse for now
                next;
            }

print("$mp_id:$gob_id:$gob_name:$mob_id:$mob_name\n");

            my $sth  = $dbh->prepare( "INSERT OR IGNORE INTO Kills VALUES( '$mp_id'      , \
                                                                           '$mp_date'    , \
                                                                           '$mob_id'     , \
                                                                           '$mob_name'   , \
                                                                           '$gob_id'     , \
                                                                           '$gob_name'   , \
                                                                           \"$mp_subject\" , \
                                                                           \"$mp_text\"  )" );

            $sth->execute();
            $sth->finish();
        }
    }
    else
    {
        print "DB $db_path/$db doesn't exist, doin' nothin' [/!\ Run initDB.pl first]\n";
    }
}
