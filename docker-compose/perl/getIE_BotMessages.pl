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

        foreach my $gob_id ( sort keys %CREDENTIALS )
        {
            print "DB: $db | Gob: $gob_id | getIE_BotMessages\n";

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
                        if ( $line[1] =~ /'/    ) { $line[1]     =~ s/\'/\'\'/g};
                        if ( $line[5] =~ /'/    ) { $line[5]     =~ s/\'/\'\'/g}

                        my $sth  = $dbh->prepare( "INSERT OR IGNORE INTO MPBot VALUES( '$line[0]', \
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
        $dbh->disconnect();
    }
    else
    {
        print "DB $db_path/$db doesn't exist, doin' nothin' [/!\ Run initDB.pl first]\n";
    }
}
