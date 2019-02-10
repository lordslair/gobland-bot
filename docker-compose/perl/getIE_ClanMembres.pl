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

        my $sql = "SELECT Id,Hash FROM Credentials WHERE Type = 'clan';";
        my $sth = $dbh->prepare( "$sql" );
        $sth->execute();

        while (my @row = $sth->fetchrow_array) { $CREDENTIALS{$row[0]} = $row[1] }
        $sth->finish();

        if (%CREDENTIALS)
        {
            my @CREDENTIALS = keys %CREDENTIALS;               # Picking only a random Gobelin in the list to avoid
            my $gob_rand    = $CREDENTIALS[rand @CREDENTIALS]; # using same ID, or requsting from every Gobelin the same data
            print "DB: $db | Gob: $gob_rand | getIE_ClanMembres\n";

            my $browser = new LWP::UserAgent;
            my $request = new HTTP::Request( GET => "http://ie.gobland.fr/IE_ClanMembres?id=$gob_rand&passwd=$CREDENTIALS{$gob_rand}" );
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
                    #"Id";"Nom";"Race";"Tribu";"Niveau";"X";"Y";"N";"Z";"DLA";"Etat";"PA";"PV";"PX";"PXPerso";"PI";"CT";"CARAC"
                    $line =~ s/"//g;
                    my @line = split /;/, $line;
                    if ( $line !~ /^#/ )
                    {
                        my $nom  = Encode::decode_utf8($line[1]);
                        my $sth  = $dbh->prepare( "INSERT OR REPLACE INTO Gobelins VALUES( '$line[0]',  \
                                                                                           '$nom',      \
                                                                                           '$line[2]',  \
                                                                                           '$line[3]',  \
                                                                                           '$line[4]',  \
                                                                                           '$line[5]',  \
                                                                                           '$line[6]',  \
                                                                                           '$line[7]',  \
                                                                                           '$line[8]',  \
                                                                                           '$line[9]',  \
                                                                                           '$line[10]', \
                                                                                           '$line[11]', \
                                                                                           '$line[12]', \
                                                                                           '$line[13]', \
                                                                                           '$line[14]', \
                                                                                           '$line[15]', \
                                                                                           '$line[16]'  ) ");
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
