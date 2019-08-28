#!/usr/bin/perl
use strict;
use warnings;

use LWP;
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

    my %CREDENTIALS;
    my $sql = "SELECT Id,Hash FROM Credentials WHERE Type = 'clan';";
    my $sth = $dbh->prepare( "$sql" );
    $sth->execute();

    while (my @row = $sth->fetchrow_array) { $CREDENTIALS{$row[0]} = $row[1] }
    $sth->finish();

    my @vue_ids_db;
    my @vue_ids_live;
    my %count;

    if (%CREDENTIALS)
    {
        foreach my $gob_id ( sort keys %CREDENTIALS )
        {

            my ($per,$bpper,$bmper) = $dbh->selectrow_array("SELECT PER, BPPER, BMPER FROM Gobelins2 WHERE Id = '$gob_id';");
            my $portee = $per + $bpper + $bmper;

            if ( $portee < 30 )
            {
                print "DB: $db | Gob: $gob_id | getIE_Vue\n";
                logEntry("[getIE_Vue] DB: $db | Gob: $gob_id");

                my $browser = new LWP::UserAgent;
                my $request = new HTTP::Request( GET => "http://ie.gobland.fr/IE_Vue?id=$gob_id&passwd=$CREDENTIALS{$gob_id}" );
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
                    my $now     = strftime "%Y-%m-%d %H:%M:%S", localtime;
                    my $time    = time;
                    foreach my $line (split(/\n/,$response->content))
                    {
                        chomp ($line);
                        #"Categorie";"Dist";"Id";"Nom";"Niveau";"Type";"Clan";"X";"Y";"N";"Z"
                        $line =~ s/"//g;
                        my @line = split /;/, $line;
                        if ( ($line !~ /^#/) and ($line !~ /^$/) )
                        {
                            $line[3]      =~ s/\'/\'\'/g;
                            $line[5]      =~ s/\'/\'\'/g;
                            $line[6]      =~ s/\'/\'\'/g;
                            if ( $line[4] eq '' ) { $line[4] = 0 }
                            if ( $line[5] =~ /Musculeux|Nodef|Trad|Yonnair|Zozo|Mentalo|Gobelin/ ) { $line[0] = 'G' }

                            # First query to INSERT the line if not exists, or IGNORE
                            my $sth       = $dbh->prepare( "INSERT IGNORE INTO Vue VALUES( '$line[2]', \
                                                                                           '$line[0]', \
                                                                                           '$line[3]', \
                                                                                           '$line[4]', \
                                                                                           '$line[5]', \
                                                                                           '$line[6]', \
                                                                                           '$line[7]', \
                                                                                           '$line[8]', \
                                                                                           '$line[9]', \
                                                                                           '$line[10]'  ) ");
                            $sth->execute();

                            # Second query to UPDATE data if the line exists
                            $sth       = $dbh->prepare( "UPDATE Vue SET Niveau = '$line[4]', \
                                                                             X = '$line[7]', \
                                                                             Y = '$line[8]', \
                                                                             N = '$line[9]'  \
                                                         WHERE Id = '$line[2]' ");

                            $sth->execute();

                            # INSERT to keep the Vue into Carte
                            # Location won't be cleaned if no more in Vue
                            $sth       = $dbh->prepare( "INSERT IGNORE INTO Carte VALUES( '$line[2]', \
                                                                                          '$line[0]', \
                                                                                          '$line[3]', \
                                                                                          '$line[4]', \
                                                                                          '$line[5]', \
                                                                                          '$line[6]', \
                                                                                          '$line[7]', \
                                                                                          '$line[8]', \
                                                                                          '$line[9]', \
                                                                                          '$line[10]',\
                                                                                          '$time',    \
                                                                                          '$now'      ) ");
                            $sth->execute();
                            $sth       = $dbh->prepare( "UPDATE Carte SET Niveau = '$line[4]', \
                                                                               X = '$line[7]', \
                                                                               Y = '$line[8]', \
                                                                               N = '$line[9]', \
                                                                            Time = '$time', \
                                                                            Date = '$now'   \
                                                         WHERE Id = '$line[2]' ");

                            $sth->execute();

                            $sth->finish();
                            push @vue_ids_live, $line[2];
                        }
                    }
                }
            }
            else
            {
                print "DB: $db | Gob: $gob_id | getIE_Vue | Cases > 30\n";
                logEntry("[getIE_Vue] DB: $db | Gob: $gob_id");

                my $response_total = '';

                my $browser = new LWP::UserAgent;
                my $request = new HTTP::Request( GET => "http://ie.gobland.fr/IE_Vue?id=$gob_id&passwd=$CREDENTIALS{$gob_id}&filtre=4" );
                my $headers = $request->headers();
                   $headers->header( 'User-Agent','Mozilla/5.0 (compatible; Konqueror/3.4; Linux) KHTML/3.4.2 (like Gecko)');
                   $headers->header( 'Accept', 'text/html, image/jpeg, image/png, text/*, image/*, */*');
                   $headers->header( 'Accept-Encoding','x-gzip, x-deflate, gzip, deflate');
                   $headers->header( 'Accept-Charset', 'iso-8859-15, utf-8;q=0.5, *;q=0.5');
                   $headers->header( 'Accept-Language', 'fr, en');
                   $headers->header( 'Referer', 'http://ie.gobland.fr');
                my $response = $browser->request($request);

                if ($response->is_success) { $response_total = $response_total."\n".$response->content }

                $browser = new LWP::UserAgent;
                $request = new HTTP::Request( GET => "http://ie.gobland.fr/IE_Vue?id=$gob_id&passwd=$CREDENTIALS{$gob_id}&filtre=3" );
                $headers = $request->headers();
                $headers->header( 'User-Agent','Mozilla/5.0 (compatible; Konqueror/3.4; Linux) KHTML/3.4.2 (like Gecko)');
                $headers->header( 'Accept', 'text/html, image/jpeg, image/png, text/*, image/*, */*');
                $headers->header( 'Accept-Encoding','x-gzip, x-deflate, gzip, deflate');
                $headers->header( 'Accept-Charset', 'iso-8859-15, utf-8;q=0.5, *;q=0.5');
                $headers->header( 'Accept-Language', 'fr, en');
                $headers->header( 'Referer', 'http://ie.gobland.fr');
                $response = $browser->request($request);

                if ($response->is_success) { $response_total .= $response_total."\n".$response->content }

                $browser = new LWP::UserAgent;
                $request = new HTTP::Request( GET => "http://ie.gobland.fr/IE_Vue?id=$gob_id&passwd=$CREDENTIALS{$gob_id}&filtre=4" );
                $headers = $request->headers();
                $headers->header( 'User-Agent','Mozilla/5.0 (compatible; Konqueror/3.4; Linux) KHTML/3.4.2 (like Gecko)');
                $headers->header( 'Accept', 'text/html, image/jpeg, image/png, text/*, image/*, */*');
                $headers->header( 'Accept-Encoding','x-gzip, x-deflate, gzip, deflate');
                $headers->header( 'Accept-Charset', 'iso-8859-15, utf-8;q=0.5, *;q=0.5');
                $headers->header( 'Accept-Language', 'fr, en');
                $headers->header( 'Referer', 'http://ie.gobland.fr');
                $response = $browser->request($request);

                if ($response->is_success) { $response_total .= $response_total."\n".$response->content }

                if ($response_total)
                {
                    my $now     = strftime "%Y-%m-%d %H:%M:%S", localtime;
                    my $time    = time;
                    foreach my $line (split(/\n/,$response_total))
                    {
                        chomp ($line);
                        #"Categorie";"Dist";"Id";"Nom";"Niveau";"Type";"Clan";"X";"Y";"N";"Z"
                        $line =~ s/"//g;
                        my @line = split /;/, $line;
                        if ( ($line !~ /^#/) and ($line !~ /^$/) )
                        {
                            $line[3]      =~ s/\'/\'\'/g;
                            $line[5]      =~ s/\'/\'\'/g;
                            $line[6]      =~ s/\'/\'\'/g;
                            if ( $line[4] eq '' ) { $line[4] = 0 }
                            if ( $line[5] =~ /Musculeux|Nodef|Trad|Yonnair|Zozo|Mentalo|Gobelin/ ) { $line[0] = 'G' }

                            # First query to INSERT the line if not exists, or IGNORE
                            my $sth       = $dbh->prepare( "INSERT IGNORE INTO Vue VALUES( '$line[2]', \
                                                                                           '$line[0]', \
                                                                                           '$line[3]', \
                                                                                           '$line[4]', \
                                                                                           '$line[5]', \
                                                                                           '$line[6]', \
                                                                                           '$line[7]', \
                                                                                           '$line[8]', \
                                                                                           '$line[9]', \
                                                                                           '$line[10]'  ) ");
                            $sth->execute();

                            # Second query to UPDATE data if the line exists
                            $sth       = $dbh->prepare( "UPDATE Vue SET Niveau = '$line[4]', \
                                                                             X = '$line[7]', \
                                                                             Y = '$line[8]', \
                                                                             N = '$line[9]'  \
                                                         WHERE Id = '$line[2]' ");

                            $sth->execute();

                            # INSERT to keep the Vue into Carte
                            # Location won't be cleaned if no more in Vue
                            $sth       = $dbh->prepare( "INSERT IGNORE INTO Carte VALUES( '$line[2]', \
                                                                                          '$line[0]', \
                                                                                          '$line[3]', \
                                                                                          '$line[4]', \
                                                                                          '$line[5]', \
                                                                                          '$line[6]', \
                                                                                          '$line[7]', \
                                                                                          '$line[8]', \
                                                                                          '$line[9]', \
                                                                                          '$line[10]',\
                                                                                          '$time',    \
                                                                                          '$now'      ) ");
                            $sth->execute();
                            $sth       = $dbh->prepare( "UPDATE Carte SET Niveau = '$line[4]', \
                                                                               X = '$line[7]', \
                                                                               Y = '$line[8]', \
                                                                               N = '$line[9]', \
                                                                            Time = '$time', \
                                                                            Date = '$now'   \
                                                         WHERE Id = '$line[2]' ");

                            $sth->execute();

                            $sth->finish();
                            push @vue_ids_live, $line[2];
                        }
                    }
                }
            }
        }

        # Find vue ids stored in DB
        my $req_vue_ids = $dbh->prepare( "SELECT Id FROM Vue WHERE Id > 0" );
        $req_vue_ids->execute();

        while (my $lastline = $req_vue_ids->fetchrow_array)
        {
            push @vue_ids_db, $lastline;
        }
        $req_vue_ids->finish();

        # Find items stored in db which are no more into live inventory
        for my $vue_id (@vue_ids_db, @vue_ids_live) { $count{$vue_id}++ }
        for my $vue_id (keys %count)
        {
            if ( $count{$vue_id} == 1 )
            {
                logEntry("[getIE_Vue]     VueCleaner:$vue_id:$count{$vue_id}");
                my $sth  = $dbh->prepare( "DELETE FROM Vue WHERE Id = '$vue_id'" );
                   $sth->execute();
                   $sth->finish();
            }
        }
    }
    else
    {
        logEntry("[getIE_Vue] DB: $db | No credentials found");
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
