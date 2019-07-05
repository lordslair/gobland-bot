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
    logEntry("[setMP2Suivants] DB: $db");

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
        my $sth  = $dbh->prepare( "INSERT IGNORE INTO Suivants VALUES( '$suivant_id', \
                                                                       '$suivants{$suivant_id}{'IdGob'}', \
                                                                       '$suivants{$suivant_id}{'Nom'}' )" );
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
