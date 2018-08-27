#!/usr/bin/perl
use strict;
use warnings;

use YAML::Tiny;

my %LIEUX;
my $lieux_csv  = '/home/gobland-bot/data/Lieux.csv';
my $lieux_yaml = '/home/gobland-bot/data/Lieux.yaml';

open (my $fh, '<:encoding(UTF-8)', $lieux_csv) or die "Could not open file '$lieux_csv' $!";
    while (my $row = <$fh>)
    {
        if ( $row !~ /^#/ )
        {
            $row =~ s/"//g;
            chomp ($row);
            my @row = split /;/, $row;
            #IdLieu;Nom;Type;X;Y;Z
            $LIEUX{$row[0]}{'Nom'}  = $row[1];
            $LIEUX{$row[0]}{'Type'} = $row[2];
            $LIEUX{$row[0]}{'X'}    = $row[3];
            $LIEUX{$row[0]}{'Y'}    = $row[4];
            $LIEUX{$row[0]}{'Z'}    = $row[5];
        }
    }
close($fh);

my $yaml = YAML::Tiny->read( $lieux_yaml );
foreach my $id_lieu (sort {$a<=>$b} keys %LIEUX)
{
    foreach my $key ( sort keys %{$LIEUX{$id_lieu}} )
    {
        $yaml->[0]->{$id_lieu}->{$key} = $LIEUX{$id_lieu}{$key};
    }
}
$yaml->write( $lieux_yaml );
