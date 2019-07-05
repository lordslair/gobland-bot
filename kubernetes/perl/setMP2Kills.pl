#!/usr/bin/perl
use strict;
use warnings;
    
use DBI;
use POSIX qw(strftime);
use Encode;

my $logging   = 1;

my @db_list   = split(',', $ENV{'DBLIST'});
my $db_driver = 'mysql';
my $db_host   = 'gobland-it-mariadb';
my $db_port   = '3306';
my $db_pass   = $ENV{'MARIADB_ROOT_PASSWORD'};
my $dsn       = "DBI:$db_driver:host=$db_host;port=$db_port";
my $dbh       = DBI->connect($dsn, 'root', $db_pass, { RaiseError => 1 }) or die $DBI::errstr;

foreach my $db (@db_list)
{
    $dbh->do("USE `$db`");
    logEntry("[setMP2Kills] DB: $db");

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

        my $sth  = $dbh->prepare( "INSERT IGNORE INTO Kills VALUES( '$mp_id'      , \
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

# add a line to the log file
sub logEntry {
    my ($logText) = @_;
    my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = localtime(time);
    my $dateTime = sprintf "%4d-%02d-%02d %02d:%02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min, $sec;
    if ($logging) {
        binmode(STDERR, ":utf8");
        print STDERR "$dateTime $logText\n";
    }
}
