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
        my @CREDENTIALS = keys %CREDENTIALS;               # Picking only a random Gobelin in the list to avoid
        my $gob_rand    = $CREDENTIALS[rand @CREDENTIALS]; # using same ID, or requsting from every Gobelin the same data
        logEntry("[getIE_ClanCavernes] DB: $db | Gob: $gob_rand");

        my $browser = new LWP::UserAgent;
        my $request = new HTTP::Request( GET => "http://ie.gobland.fr/IE_ClanCavernes?id=$gob_rand&passwd=$CREDENTIALS{$gob_rand}" );
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
            my @item_ids_db;
            my @item_ids_live;
            my %count;

            foreach my $line (split(/\n/,$response->content))
            {
                chomp ($line);
                #"Id";"Type";"Identifie";"Nom";"Magie";"Desc";"Poids";"Taille";"Qualite";"Localisation";"Prix";"Reservation";"Matiere"
                $line =~ s/"//g;
                my @line = split /;/, $line;
                if ( $line !~ /^#/ )
                {
                    my $description   = Encode::decode_utf8('<b>Non identifié</b>');
                    if ( $line[2] eq 'VRAI' ) { $description = $line[5] }
                    if ( $line[3] =~ /'/    ) { $line[3]     =~ s/\'/\'\'/g}
                    if ( $line[4] =~ /'/    ) { $line[4]     =~ s/\'/\'\'/g}
                    if ( $line[7] eq ""     ) { $line[7]     = 1  } # Patch for Empty Baguette size
                    if ( $line[8] eq ""     ) { $line[8]     = 0  } # Patch for Empty Baguette quality
                    if ( $line[9] =~ /'/    ) { $line[9]     =~ s/\'/\'\'/g}
                    if ( !$line[12]         ) { $line[12]    = '' } # Patch for Empty Matiere

                    # First query to INSERT the line if not exists, or IGNORE
                    my $sth  = $dbh->prepare( "INSERT IGNORE INTO ItemsCavernes VALUES( '$line[0]',     \
                                                                                        '$line[1]',     \
                                                                                        '$line[2]',     \
                                                                                        '$line[3]',     \
                                                                                        '$line[4]',     \
                                                                                        '$description', \
                                                                                        '$line[6]',     \
                                                                                        '$line[7]',     \
                                                                                        '$line[8]',     \
                                                                                        '$line[9]',     \
                                                                                        'FAUX',         \
                                                                                        '$line[10]',    \
                                                                                        '$line[11]',    \
                                                                                        '$line[12]')"   );
                    $sth->execute();

                    # Second query to UPDATE data if the line exists
                    $sth       = $dbh->prepare( "UPDATE ItemsCavernes SET Reservation = '$line[11]' \
                                                 WHERE  Id = '$line[0]' ");

                    $sth->execute();

                    $sth->finish();
                    push @item_ids_live, $line[0];
                }
            }

            # Find items stored in DB
            my $req_item_ids = $dbh->prepare( "SELECT Id FROM ItemsCavernes" );
            $req_item_ids->execute();

            while (my $lastline = $req_item_ids->fetchrow_array)
            {
                push @item_ids_db, $lastline;
            }
            $req_item_ids->finish();

            # Find items stored in db which are no more into live inventory
            for my $item_id (@item_ids_db, @item_ids_live) { $count{$item_id}++ }
            for my $item_id (keys %count)
            {
                if ( $count{$item_id} == 1 )
                {
                    logEntry("[getIE_ClanCavernes]    ItemsCavernesCleaner:$item_id:$count{$item_id}");
                    my $sth  = $dbh->prepare( "DELETE FROM ItemsCavernes WHERE Id IS '$item_id'" );
                       $sth->execute();
                       $sth->finish();
                }
            }
        }
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
