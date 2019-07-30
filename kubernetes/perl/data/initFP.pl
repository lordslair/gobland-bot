#!/usr/bin/perl
use strict;
use warnings;
    
use DBI;

my $source     = 'http://public.gobland.fr';
my $path       = '/code';
my $skills_csv = 'FP_Skill.csv';
my $techs_csv  = 'FP_Tech.csv';
my $lieux_csv  = 'FP_Lieu.csv';
my $clans_csv  = 'FP_Clan.csv';
my $lieux2_csv = 'Lieux.csv';
    
`wget --quiet "$source/$skills_csv" -O "$path/data/$skills_csv"`;
`wget --quiet "$source/$techs_csv"  -O "$path/data/$techs_csv"`;
`wget --quiet "$source/$lieux_csv"  -O "$path/data/$lieux_csv"`;
`wget --quiet "$source/$clans_csv"  -O "$path/data/$clans_csv"`;
    
my @db_list   = ('global');
my $db_driver = 'mysql';
my $db_host   = 'gobland-it-mariadb';
my $db_port   = '3306';
my $db_pass   = $ENV{'MARIADB_ROOT_PASSWORD'};
my $dsn       = "DBI:$db_driver:host=$db_host;port=$db_port";
my $dbh       = DBI->connect($dsn, 'root', $db_pass, { RaiseError => 1 }) or die $DBI::errstr;

foreach my $db (@db_list)
{
    my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = localtime(time);
    my $dateTime = sprintf "%4d-%02d-%02d %02d:%02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min, $sec;
    print STDERR "$dateTime [initFP] DB: $db\n";

    $dbh->do("USE `$db`");
    
        if ( -f "$path/data/$lieux_csv" )
        {
            open (my $fh, '<:encoding(Latin1)', "$path/data/$lieux_csv") or die "Could not open file '$path/data/$lieux_csv' $!";
                while (my $row = <$fh>)
                {
                    $row     =~ s/"//g;
                    my @row  = split /;/, $row;
    
                    if ( $row !~ /^#/ )
                    {
                        $row[1] =~ s/\'/\'\'/g;
                        $row[1] = Encode::decode_utf8($row[1]);
                        $row[4] = Encode::decode_utf8($row[4]);
    
                        my $sth = $dbh->prepare( "REPLACE INTO FP_Lieu VALUES( '$row[0]', \
                                                                               '$row[1]', \
                                                                               '$row[2]', \
                                                                               '$row[3]', \
                                                                               '$row[4]', \
                                                                               '$row[5]', \
                                                                               '',        \
                                                                               '',        \
                                                                               ''         ) ");
                        $sth->execute();
                        $sth->finish();
                    }
                }
            close($fh);
        }
        else
        {
            print "$path/data/$lieux_csv doesn't exist, doin' nothin'\n";
        }
    
        if ( -f "$path/data/$lieux2_csv" )
        {
            open (my $fh, '<:encoding(Latin1)', "$path/data/$lieux2_csv") or die "Could not open file '$path/data/$lieux2_csv' $!";
                while (my $row = <$fh>)
                {
                    $row     =~ s/"//g;
                    my @row  = split /;/, $row;
    
                    #IdLieu;Nom;Type;X;Y;Z
                    if ( $row !~ /^#/ )
                    {
                        my $sth = $dbh->prepare( "UPDATE FP_Lieu SET X = '$row[3]', Y = '$row[4]', Z = '$row[5]' WHERE IdLieu = '$row[0]' ");
    
                        $sth->execute();
                        $sth->finish();
                    }
                }
            close($fh);
        }
        else
        {
            print "$path/data/$lieux_csv doesn't exist, doin' nothin'\n";
        }
    
        if ( -f "$path/data/$skills_csv" )
        {
            open (my $fh, '<:encoding(UTF-8)', "$path/data/$skills_csv") or die "Could not open file '$path/data/$skills_csv' $!";
                while (my $row = <$fh>)
                {
                    $row     =~ s/"//g;
                    my @row  = split /;/, $row;
    
                    if ( $row !~ /^#/ )
                    {
                        $row[1] =~ s/\'/\'\'/g;
                        my $sth  = $dbh->prepare( "REPLACE INTO FP_Skill VALUES( '$row[0]', \
                                                                                 '$row[1]', \
                                                                                 '$row[2]', \
                                                                                 '$row[3]', \
                                                                                 '$row[4]', \
                                                                                 '$row[5]', \
                                                                                 '$row[6]'  ) ");
                        $sth->execute();
                        $sth->finish();
                    }
                }
            close($fh);
        }
        else
        {
            print "$path/data/$skills_csv doesn't exist, doin' nothin'\n";
        }
    
        if ( -f "$path/data/$techs_csv" )
        {
            open (my $fh, '<:encoding(UTF-8)', "$path/data/$techs_csv") or die "Could not open file '$path/data/$techs_csv' $!";
                while (my $row = <$fh>)
                {
                    $row     =~ s/"//g;
                    my @row  = split /;/, $row;
    
                    if ( $row !~ /^#/ )
                    {
                        $row[1] =~ s/\'/\'\'/g;
                        my $sth  = $dbh->prepare( "REPLACE INTO FP_Tech VALUES( '$row[0]', \
                                                                                '$row[1]', \
                                                                                '$row[2]', \
                                                                                '$row[3]', \
                                                                                '$row[4]', \
                                                                                '$row[5]', \
                                                                                '$row[6]'  ) ");
                        $sth->execute();
                        $sth->finish();
                    }
                }
            close($fh);
        }
        else
        {
            print "$path/data/$techs_csv doesn't exist, doin' nothin'\n";
        }

        if ( -f "$path/data/$clans_csv" )
        {
            open (my $fh, '<:encoding(UTF-8)', "$path/data/$clans_csv") or die "Could not open file '$path/data/$clans_csv' $!";
                while (my $row = <$fh>)
                {
                    $row     =~ s/"//g;
                    my @row  = split /;/, $row;

                    if ( $row !~ /^#/ )
                    {
                        $row[1] =~ s/\'/\'\'/g;
                        my $sth  = $dbh->prepare( "REPLACE INTO FP_Clan VALUES( '$row[0]', \
                                                                                '$row[1]', \
                                                                                '$row[2]', \
                                                                                '$row[3]', \
                                                                                '$row[4]', \
                                                                                '$row[5]', \
                                                                                '$row[6]'  ) ");
                        $sth->execute();
                        $sth->finish();
                    }
                }
            close($fh);
        }
        else
        {
            print "$path/data/$clans_csv doesn't exist, doin' nothin'\n";
        }
}

$dbh->disconnect();
