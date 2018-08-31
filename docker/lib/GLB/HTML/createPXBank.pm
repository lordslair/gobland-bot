package GLB::HTML::createPXBank;
use strict;
use warnings;

use Time::HiRes qw[gettimeofday tv_interval];

use lib '/home/gobland-bot/lib/';
use GLB::variables;

my $gobs_ref   = $GLB::variables::gobs;
my %gobs       = %{$gobs_ref};
my $gobs2_ref  = $GLB::variables::gobs2;
my %gobs2      = %{$gobs2_ref};

sub main
{
    my $t_start  = [gettimeofday()];
    my $filename = '/var/www/localhost/htdocs/pxbank.html';
    open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
    binmode($fh, ":utf8");
    print $fh $GLB::variables::begin;

    print $fh ' ' x 6, '<div id="content">'."\n";
    print $fh ' ' x 8, '<h1>Banque PI/PX</h1>'."\n";
    print $fh ' ' x 8, '<h3>(Alias: Qui '.Encode::decode_utf8('à').' la plus grosse ...)</h3>'."\n";

    print $fh ' ' x 8, '<table cellspacing="0" id="trollsList">'."\n";
    print $fh ' ' x10, '<tr>'."\n";
    print $fh ' ' x12, '<th onclick="sortTable(0)">Pseudo</th>'."\n";
    print $fh ' ' x12, '<th onclick="sortTable(1)">Num</th>'."\n";
    print $fh ' ' x12, '<th onclick="sortTable(2)">Niv.</th>'."\n";
    print $fh ' ' x12, '<th onclick="sortTable(3)">PX Perso</th>'."\n";
    print $fh ' ' x12, '<th onclick="sortTable(4)">PX</th>'."\n";
    print $fh ' ' x12, '<th onclick="sortTable(5)">PI</th>'."\n";
    print $fh ' ' x12, '<th onclick="sortTable(6)">PI Totaux</th>'."\n";
    print $fh ' ' x12, '<th onclick="sortTable(7)">PX+PI Totaux</th>'."\n";
    print $fh ' ' x10, '</tr>'."\n";

    for my $gob_id ( sort keys %gobs )
    {
        my $total = $gobs{$gob_id}{'PXPerso'} + $gobs{$gob_id}{'PX'} + $gobs2{$gob_id}{'PITotal'};

        print $fh ' ' x10, '<tr>'."\n";
        print $fh ' ' x12, '<td>'.$gobs{$gob_id}{'Nom'}.'</td>'."\n";
        print $fh ' ' x12, '<td>'.$gob_id.'</td>'."\n";
        print $fh ' ' x12, '<td>'.$gobs{$gob_id}{'Niveau'}.'</td>'."\n";
        print $fh ' ' x12, '<td>'.$gobs{$gob_id}{'PXPerso'}.'</td>'."\n";
        print $fh ' ' x12, '<td>'.$gobs{$gob_id}{'PX'}.'</td>'."\n";
        print $fh ' ' x12, '<td>'.$gobs{$gob_id}{'PI'}.'</td>'."\n";
        print $fh ' ' x12, '<td>'.$gobs2{$gob_id}{'PITotal'}.'</td>'."\n";
        print $fh ' ' x12, '<td>'.$total.'</td>'."\n";
        print $fh ' ' x10, '</tr>'."\n";
    }

    print $fh ' ' x 8, '</table>'."\n";
    print $fh ' ' x 6, '</div>'."\n";

    my $t_elapsed = sprintf ("%0.3f", tv_interval($t_start));
    print $fh ' ' x 6, '<div class="footer">[HTML generated in '.$t_elapsed.' sec.] - [Updated @'.localtime.']</div>'."\n";

    print $fh $GLB::variables::sortscript;
    print $fh $GLB::variables::end;
    close $fh;
}

1;
