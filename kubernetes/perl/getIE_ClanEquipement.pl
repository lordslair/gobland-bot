#!/usr/bin/perl
use strict;
use warnings;

use LWP;
use DBI;
use Encode;

my $logging   = 1;

my @db_list   = split(',', $ENV{'DBLIST'});
my $db_driver = 'mysql';
my $db_host   = $ENV{'MARIADB_HOST'};
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
        my @item_ids_live;
        my @item_ids_db;
        my %count;

        my @CREDENTIALS = keys %CREDENTIALS;               # Picking only a random Gobelin in the list to avoid
        my $gob_rand    = $CREDENTIALS[rand @CREDENTIALS]; # using same ID, or requsting from every Gobelin the same data
        logEntry("[getIE_ClanEquipement] DB: $db | Gob: $gob_rand");

        my $browser = new LWP::UserAgent;
        my $request = new HTTP::Request( GET => "http://ie.gobland.fr/IE_ClanEquipement?id=$gob_rand&passwd=$CREDENTIALS{$gob_rand}" );
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
            my @item_ids_live;
            my @item_ids_db;
            my %count;

            foreach my $line (split(/\n/,$response->content))
            {
                chomp ($line);
                #"IdGob";"Id";"Type";"Identifie";"Nom";"Magie";"Desc";"Poids";"Taille";"Qualite";"Utilise";"Matiere"
                $line =~ s/"//g;
                my @line = split /;/, $line;
                if ( $line !~ /^#/ )
                {
                    my $description   = Encode::decode_utf8('<b>Non identifié</b>');
                    if ( $line[3] eq 'VRAI' ) { $description = $line[6] }
                    if ( $line[4] =~ /'/    ) { $line[4]     =~ s/\'/\'\'/g}
                    if ( $line[5] =~ /'/    ) { $line[5]     =~ s/\'/\'\'/g}
                    if ( $line[8] eq ""     ) { $line[8]     = 1  } # Patch for Empty Baguette size
                    if ( $line[9] eq ""     ) { $line[9]     = 0  } # Patch for Empty Baguette quality
                    if ( !$line[11]         ) { $line[11]    = '' } # Patch for Empty Matiere

                    my $sth  = $dbh->prepare( "REPLACE INTO ItemsGobelins VALUES( '$line[1]',     \
                                                                                  '$line[0]',     \
                                                                                  '$line[2]',     \
                                                                                  '$line[3]',     \
                                                                                  '$line[4]',     \
                                                                                  '$line[5]',     \
                                                                                  '$description', \
                                                                                  '$line[7]',     \
                                                                                  '$line[8]',     \
                                                                                  '$line[9]',     \
                                                                                  '$line[10]',    \
                                                                                  '$line[11]'  ) ");
                    $sth->execute();
                    $sth->finish();
                    push @item_ids_live, $line[1];
                }
            }

            # Find items stored in DB
            my $req_item_ids = $dbh->prepare( "SELECT Id FROM ItemsGobelins;" );
            $req_item_ids->execute();

            while (my $lastline = $req_item_ids->fetchrow_array)
            {
                push @item_ids_db, $lastline;
            }
            $req_item_ids->finish();

            # Find items stored in DB which are no more into live inventory
            for my $item_id (@item_ids_db, @item_ids_live) { $count{$item_id}++ }
            for my $item_id (keys %count)
            {
                if ( $count{$item_id} == 1 )
                {
                    logEntry("[getIE_ClanEquipement]    ItemsGobelinsCleaner:$item_id:$count{$item_id}");
                    my $sth  = $dbh->prepare( "DELETE FROM ItemsGobelins WHERE Id = '$item_id'" );
                       $sth->execute();
                       $sth->finish();
                }
            }
        }
    }
    else
    {
        logEntry("[getIE_ClanEquipement] DB: $db | No credentials found");

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
