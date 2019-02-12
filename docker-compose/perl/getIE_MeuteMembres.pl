#!/usr/bin/perl
use strict;
use warnings;

use LWP;
use DBI;
use YAML::Tiny;

my $yaml_file = 'master.yaml';
my $yaml      = YAML::Tiny->read( $yaml_file );
my @db_list   = @{$yaml->[0]{db_list}};
my $db_path   = '/db';
my $driver_db = 'SQLite';
    
foreach my $db (@db_list)
{
    if ( -f "$db_path/$db" )
    {
        my $dsn       = "DBI:$driver_db:dbname=$db_path/$db";
        my $dbh = DBI->connect($dsn, '', '', { RaiseError => 1 }) or die $DBI::errstr;
        my %CREDENTIALS;

        my $sql = "SELECT Id,Hash FROM Credentials WHERE Type = 'meute';";
        my $sth = $dbh->prepare( "$sql" );
        $sth->execute();

        while (my @row = $sth->fetchrow_array) { $CREDENTIALS{$row[0]} = $row[1] }
        $sth->finish();

        if (%CREDENTIALS)
        {
            my @CREDENTIALS = keys %CREDENTIALS;               # Picking only a random Gobelin in the list to avoid
            my $gob_rand    = $CREDENTIALS[rand @CREDENTIALS]; # using same ID, or requsting from every Gobelin the same data
            print "DB: $db | Gob: $gob_rand | getIE_MeuteMembres\n";

            my $browser = new LWP::UserAgent;
            my $request = new HTTP::Request( GET => "http://ie.gobland.fr/IE_MeuteMembres?id=$gob_rand&passwd=$CREDENTIALS{$gob_rand}" );
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
                my @gobs_ids_db;
                my @gobs_ids_live;
                my %count;
                my $meute_id;

                foreach my $line (split(/\n/,$response->content))
                {
                    chomp ($line);
                    #"IdMeute";"NomMeute";"Id";"Nom";"Race";"Tribu";"Niveau";"X";"Y";"N";"Z";"DLA";"Etat";"PA";"PV";"PX";"PXPerso";"PI";"CT";"CARAC"
                    $line =~ s/"//g;
                    my @line = split /;/, $line;
                    if ( $line !~ /^#/)
                    {
                        my $meute = Encode::decode_utf8($line[1]);
                        my $sth   = $dbh->prepare( "INSERT OR REPLACE INTO Meutes VALUES( '$line[2]', \
                                                                                          '$line[3]', \
                                                                                          '$line[0]', \
                                                                                          '$meute',   \
                                                                                          '$line[5]', \
                                                                                          '$line[6]'  )" );
                        $sth->execute();
                        $sth->finish();
                        push @gobs_ids_live, $line[2];
                        $meute_id = $line[0];
                    }
                }

                # Find gobelins stored in DB
                my $req_gobs_ids = $dbh->prepare( "SELECT Id FROM Meutes WHERE IdMeute = '$meute_id'" );
                $req_gobs_ids->execute();

                while (my $lastline = $req_gobs_ids->fetchrow_array)
                {
                    push @gobs_ids_db, $lastline;
                }
                $req_gobs_ids->finish();

                # Find gobs stored in db which are no more into Meutes
                for my $gob_id (@gobs_ids_db, @gobs_ids_live) { $count{$gob_id}++ }
                for my $gob_id (keys %count)
                {
                    if ( $count{$gob_id} == 1 )
                    {
                        print "MeutesCleaner:$gob_id:$count{$gob_id}\n";
                        my $sth  = $dbh->prepare( "DELETE FROM Meutes WHERE Id IS '$gob_id'" );
                           $sth->execute();
                           $sth->finish();
                    }
                }
            }
        }
        $dbh->disconnect();
    }
    else
    {
        print "DB $db_path/$db doesn't exist, doin' nothin' [/!\ Run initDB.pl first]\n";
    }
}
