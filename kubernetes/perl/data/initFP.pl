#!/usr/bin/perl
use strict;
use warnings;
    
use DBI;
use YAML::Tiny;

my $source     = 'http://public.gobland.fr';
my $path       = '/code';
my $skills_csv = 'FP_Skill.csv';
my $techs_csv  = 'FP_Tech.csv';
my $lieux_csv  = 'FP_Lieu.csv';
my $lieux2_csv = 'Lieux.csv';
    
`wget "$source/$skills_csv" -O "$path/data/$skills_csv"`;
`wget "$source/$techs_csv"  -O "$path/data/$techs_csv"`;
`wget "$source/$lieux_csv"  -O "$path/data/$lieux_csv"`;
    
my $yaml_file = 'master.yaml';
my $yaml      = YAML::Tiny->read( $yaml_file );
my @db_list   = @{$yaml->[0]{db_list}};
my $db_path   = '/db';


my @db_list   = split(',', $ENV{'DBLIST'});
my $db_driver = 'mysql';
my $db_host   = 'gobland-it-mariadb';
my $db_port   = '3306';
my $db_pass   = $ENV{'MARIADB_ROOT_PASSWORD'};
my $dsn       = "DBI:$db_driver:host=$db_host;port=$db_port";
my $dbh       = DBI->connect($dsn, 'root', $db_pass, { RaiseError => 1 }) or die $DBI::errstr;

foreach my $db (@db_list)
{
    print STDERR "[initFP] DB: $db\n";
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
    
                        my $sth = $dbh->prepare( "INSERT OR REPLACE INTO FP_Lieu VALUES( '$row[0]', \
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
                        my $sth  = $dbh->prepare( "INSERT OR REPLACE INTO FP_C VALUES( '$row[0]', \
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
                        my $sth  = $dbh->prepare( "INSERT OR REPLACE INTO FP_T VALUES( '$row[0]', \
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
}
