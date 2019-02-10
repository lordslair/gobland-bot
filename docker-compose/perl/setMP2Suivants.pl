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
    print "DB: $db | setMP2Suivants\n";
    
    if ( -f "$db_path/$db" )
    {
        my $dbh = DBI->connect(
            "dbi:SQLite:dbname=$db_path/$db",
            "",
            "",
            { RaiseError => 1 },
        ) or die $DBI::errstr;

        my $now     = strftime "%Y-%m-%d", localtime;
        my $req_mps = $dbh->prepare( "SELECT Id,IdGob,PMDate,PMSubject,PMText \
                                      FROM MPBot \
                                      WHERE PMSubject LIKE 'Infos Suivant%' AND PMDate LIKE '$now%' \
                                      ORDER BY PMDate \
                                      LIMIT 100;" ); # To avoid a slow SELECT as MPBot can be huge
           $req_mps->execute();

        my %suivants;

        while (my @row = $req_mps->fetchrow_array)
        {
            if ( $row[3] =~ /Infos Suivant - (.*) \((\d*)\) - / )
            {
                $suivants{$2}{'Nom'}   = $1;
                $suivants{$2}{'IdGob'} = $row[1];
            }
        }

        foreach my $suivant_id ( sort keys %suivants )
        {
            $suivants{$suivant_id}{'Nom'} =~ s/\'/\'\'/g;
            my $sth  = $dbh->prepare( "INSERT OR IGNORE INTO Suivants VALUES( '$suivant_id', \
                                                                              '$suivants{$suivant_id}{'IdGob'}', \
                                                                              '$suivants{$suivant_id}{'Nom'}' )" );
            $sth->execute();
            $sth->finish();
        }
    }
    else
    {
        print "DB $db_path/$db doesn't exist, doin' nothin' [/!\ Run initDB.pl first]\n";
    }
}
