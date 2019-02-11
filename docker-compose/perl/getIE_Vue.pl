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
        my $wal = $dbh->do("PRAGMA journal_mode=WAL;");
        my %CREDENTIALS;

        my $sql = "SELECT Id,Hash FROM Credentials WHERE Type = 'clan';";
        my $sth = $dbh->prepare( "$sql" );
        $sth->execute();

        while (my @row = $sth->fetchrow_array) { $CREDENTIALS{$row[0]} = $row[1] }
        $sth->finish();

        my @vue_ids_db;
        my @vue_ids_live;
        my %count;

        foreach my $gob_id ( sort keys %CREDENTIALS )
        {
            print "DB: $db | Gob: $gob_id | getIE_Vue\n";

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
                foreach my $line (split(/\n/,$response->content))
                {
                    chomp ($line);
                    #"Categorie";"Dist";"Id";"Nom";"Niveau";"Type";"Clan";"X";"Y";"N";"Z"
                    $line =~ s/"//g;
                    my @line = split /;/, $line;
                    if ( $line !~ /^#/)
                    {
                        $line[3]      =~ s/\'/\'\'/g;
                        $line[5]      =~ s/\'/\'\'/g;
                        if ( $line[4] eq '' ) { $line[4] = 0 }
                        $line[3] =~ s/Ã©/é/g;
                        $line[3] =~ s/Ã¯/ï/g;
                        $line[3] =~ s/Ã´/ô/g;
                        $line[3] =~ s/Ã¢/â/g;
                        $line[3] =~ s/Ãµ/ö/g;
                        $line[5] =~ s/Ã©/é/g;
                        $line[5] =~ s/Ã¯/ï/g;
                        $line[5] =~ s/Ã´/ô/g;
                        $line[5] =~ s/Ã¢/â/g;
                        $line[5] =~ s/Ãµ/ö/g;
                        if ( $line[5] =~ /Musculeux|Nodef|Trad|Yonnair|Zozo|Mentalo|Gobelin/ ) { $line[0] = 'G' }

                        # First query to UPDATE the line if not exists, or IGNORE
                        my $sth       = $dbh->prepare( "INSERT OR IGNORE INTO Vue VALUES( '$line[2]', \
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
                        $sth->finish();
                        push @vue_ids_live, $line[2];
                    }
                }
            }
        }

        # Find vue ids stored in DB
        my $req_vue_ids = $dbh->prepare( "SELECT Id FROM Vue" );
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
                print "VueCleaner:$vue_id:$count{$vue_id}\n";
                my $sth  = $dbh->prepare( "DELETE FROM Vue WHERE Id IS '$vue_id'" );
                   $sth->execute();
                   $sth->finish();
            }
        }
        $dbh->disconnect();
    }
    else
    {
        print "DB $db_path/$db doesn't exist, doin' nothin' [/!\ Run initDB.pl first]\n";
    }
}
