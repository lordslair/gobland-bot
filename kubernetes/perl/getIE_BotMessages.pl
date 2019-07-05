#!/usr/bin/perl
use strict;
use warnings;

use LWP;
use DBI;
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

    my %CREDENTIALS;
    my $sql = "SELECT Id,Hash FROM Credentials WHERE Type = 'clan';";
    my $sth = $dbh->prepare( "$sql" );
    $sth->execute();

    while (my @row = $sth->fetchrow_array) { $CREDENTIALS{$row[0]} = $row[1] }
    $sth->finish();

    if (%CREDENTIALS)
    {
        foreach my $gob_id ( sort keys %CREDENTIALS )
        {
            logEntry("[getIE_BotMessages] DB: $db | Gob: $gob_id");

            my $browser = new LWP::UserAgent;
            my $request = new HTTP::Request( GET => "http://ie.gobland.fr/IE_BotMessages?id=$gob_id&passwd=$CREDENTIALS{$gob_id}" );
            my $headers = $request->headers();
               $headers->header( 'User-Agent','Mozilla/5.0 (compatible; Konqueror/3.4; Linux) KHTML/3.4.2 (like Gecko)');
               $headers->header( 'Accept', 'text/html, image/jpeg, image/png, text/*, image/*, */*');
               $headers->header( 'Accept-Encoding','x-gzip, x-deflate, gzip, deflate');
               $headers->header( 'Accept-Charset', 'iso-8859-15, utf-8;q=0.5, *;q=0.5');
               $headers->header( 'Accept-Language', 'fr, en');
               $headers->header( 'Referer', 'http://ie.gobland.fr');
            my $response = $browser->request($request);

            if ($response->is_success)
            {
                foreach my $line (split(/\n/,$response->content))
                {
                    chomp ($line);
                    #IdPM;PMSubject;PMDate;PMStatus;PMExp;PMText
                    $line =~ s/"//g;
                    my @line = split /;/, $line;
                    if ( $line !~ /^#/)
                    {
                        if ( $line[1] =~ /'/ ) { $line[1] =~ s/\'/\'\'/g};
                        if ( $line[5] and $line[5] =~ /'/ )
                        {
                            $line[5]     =~ s/\'/\'\'/g;
                        } else { $line[5] = '' } # To force in case of "Résultat Parchemin" MPBot

                        my $sth  = $dbh->prepare( "INSERT IGNORE INTO MPBot VALUES( '$line[0]', \
                                                                                    '$gob_id' , \
                                                                                    '$line[1]', \
                                                                                    '$line[2]', \
                                                                                    '$line[3]', \
                                                                                    '$line[4]', \
                                                                                    '$line[5]'  )" );

                        $sth->execute();
                        $sth->finish();
                    }
                }
            }
        }
    }
    else
    {
        logEntry("[getIE_BotMessages] DB: $db | No credentials found");
    }
}
$dbh->disconnect();

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
