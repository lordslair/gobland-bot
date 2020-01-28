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
            my $response_total = '';
            my $browser = new LWP::UserAgent;

            my ($per,$bpper,$bmper) = $dbh->selectrow_array("SELECT PER, BPPER, BMPER FROM Gobelins2 WHERE Id = '$gob_id';");
            my $portee = $per + $bpper + $bmper;

            if ( $portee < 30 )
            {
                print "DB: $db | Gob: $gob_id | getIE_Vue\n";
                logEntry("[getIE_Vue] DB: $db | Gob: $gob_id");

                my $request = new HTTP::Request( GET => "http://ie.gobland.fr/IE_Vue?id=$gob_id&passwd=$CREDENTIALS{$gob_id}" );
                my $headers = $request->headers();
                   $headers->header( 'User-Agent','Mozilla/5.0 (compatible; Konqueror/3.4; Linux) KHTML/3.4.2 (like Gecko)');
                   $headers->header( 'Accept', 'text/html, image/jpeg, image/png, text/*, image/*, */*');
                   $headers->header( 'Accept-Encoding','x-gzip, x-deflate, gzip, deflate');
                   $headers->header( 'Accept-Charset', 'iso-8859-15, utf-8;q=0.5, *;q=0.5');
                   $headers->header( 'Accept-Language', 'fr, en');
                   $headers->header( 'Referer', 'http://ie.gobland.fr');
                my $response = $browser->request($request);

                if ($response->is_success) { $response_total = $response->content }
            }
            elsif ( $portee > 30 and $portee < 80 )
            {
                print "DB: $db | Gob: $gob_id | getIE_Vue | Cases > 30\n";
                logEntry("[getIE_Vue] DB: $db | Gob: $gob_id");

                my $request = new HTTP::Request( GET => "http://ie.gobland.fr/IE_Vue?id=$gob_id&passwd=$CREDENTIALS{$gob_id}&dH=30&dV=15" );
                my $headers = $request->headers();
                   $headers->header( 'User-Agent','Mozilla/5.0 (compatible; Konqueror/3.4; Linux) KHTML/3.4.2 (like Gecko)');
                   $headers->header( 'Accept', 'text/html, image/jpeg, image/png, text/*, image/*, */*');
                   $headers->header( 'Accept-Encoding','x-gzip, x-deflate, gzip, deflate');
                   $headers->header( 'Accept-Charset', 'iso-8859-15, utf-8;q=0.5, *;q=0.5');
                   $headers->header( 'Accept-Language', 'fr, en');
                   $headers->header( 'Referer', 'http://ie.gobland.fr');
                my $response = $browser->request($request);

                if ($response->is_success) { $response_total = $response->content }

                $request = new HTTP::Request( GET => "http://ie.gobland.fr/IE_Vue?id=$gob_id&passwd=$CREDENTIALS{$gob_id}&filtre=1" );
                $headers = $request->headers();
                $headers->header( 'User-Agent','Mozilla/5.0 (compatible; Konqueror/3.4; Linux) KHTML/3.4.2 (like Gecko)');
                $headers->header( 'Accept', 'text/html, image/jpeg, image/png, text/*, image/*, */*');
                $headers->header( 'Accept-Encoding','x-gzip, x-deflate, gzip, deflate');
                $headers->header( 'Accept-Charset', 'iso-8859-15, utf-8;q=0.5, *;q=0.5');
                $headers->header( 'Accept-Language', 'fr, en');
                $headers->header( 'Referer', 'http://ie.gobland.fr');
                $response = $browser->request($request);

                if ($response->is_success) { $response_total .= $response_total."\n".$response->content }

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
            }
            elsif ( $portee > 80 )
            {
                print "DB: $db | Gob: $gob_id | getIE_Vue | Cases > 80\n";
                logEntry("[getIE_Vue] DB: $db | Gob: $gob_id");

                my $request = new HTTP::Request( GET => "http://ie.gobland.fr/IE_Vue?id=$gob_id&passwd=$CREDENTIALS{$gob_id}&dH=35&dV=15" );
                my $headers = $request->headers();
                   $headers->header( 'User-Agent','Mozilla/5.0 (compatible; Konqueror/3.4; Linux) KHTML/3.4.2 (like Gecko)');
                   $headers->header( 'Accept', 'text/html, image/jpeg, image/png, text/*, image/*, */*');
                   $headers->header( 'Accept-Encoding','x-gzip, x-deflate, gzip, deflate');
                   $headers->header( 'Accept-Charset', 'iso-8859-15, utf-8;q=0.5, *;q=0.5');
                   $headers->header( 'Accept-Language', 'fr, en');
                   $headers->header( 'Referer', 'http://ie.gobland.fr');
                my $response = $browser->request($request);

                if ($response->is_success) { $response_total = $response->content }
            }

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
                        if ( $line[4] eq '' ) { $line[4] = 0 }
                        if ( $line[5] =~ /Musculeux|Nodef|Trad|Yonnair|Zozo|Mentalo|Gobelin/ ) { $line[0] = 'G' }

                        if ( ($line[0] eq 'L') and ($line[3] ne 'Arbre') )
                        {
                            $sth       = $dbh->prepare( "UPDATE global.FP_Lieu \
                                                         SET \
                                                            Categorie = '$line[0]',  \
                                                            Nom       = ?,           \
                                                            Niveau    = '$line[4]',  \
                                                            X         = '$line[7]',  \
                                                            Y         = '$line[8]',  \
                                                            N         = '$line[9]',  \
                                                            Z         = '$line[10]', \
                                                            Date      = now()        \
                                                         WHERE \
                                                              IdLieu  = '$line[2]' ");
                            $sth->execute($line[3]);
                        }
                        elsif ( ($line[0] eq 'L') and ($line[3] eq 'Arbre') )
                        {
                            my $sth = $dbh->prepare( "INSERT IGNORE \
                                                      INTO global.FP_Lieu \
                                                            (idLieu, \
                                                            Categorie, \
                                                            Nom, \
                                                            Niveau, \
                                                            Type, \
                                                            mobile, \
                                                            X, \
                                                            Y, \
                                                            N, \
                                                            Z) \
                                                      VALUES
                                                            ('$line[2]', \
                                                             '$line[0]', \
                                                             ?, \
                                                             '$line[4]', \
                                                             ?, \
                                                             'FAUX', \
                                                             '$line[7]', \
                                                             '$line[8]', \
                                                             '$line[9]', \
                                                             '$line[10]'  ) ");
                            $sth->execute($line[3],$line[5]);
                        }
                        elsif ( ($line[0] eq 'C') or ($line[0] eq 'G') or ($line[0] eq 'P') or ($line[0] eq 'T') )
                        {
                            # First query to INSERT the line if not exists, or IGNORE
                            my $sth       = $dbh->prepare( "INSERT IGNORE \
                                                            INTO Vue
                                                            VALUES ( '$line[2]', \
                                                                     '$line[0]', \
                                                                     ?, \
                                                                     '$line[4]', \
                                                                     ?, \
                                                                     ?, \
                                                                     '$line[7]', \
                                                                     '$line[8]', \
                                                                     '$line[9]', \
                                                                     '$line[10]'  ) ");
                            $sth->execute($line[3],$line[5],$line[6]);

                            # Second query to UPDATE data if the line exists
                            $sth       = $dbh->prepare( "UPDATE Vue \
                                                         SET Niveau = '$line[4]', \
                                                             X      = '$line[7]', \
                                                             Y      = '$line[8]', \
                                                             N      = '$line[9]', \
                                                             Z      = '$line[10]' \
                                                             WHERE Id = '$line[2]' ");
                            $sth->execute();

                            $sth->finish();
                        }
                        push @vue_ids_live, $line[2];
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
