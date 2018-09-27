package GLB::HTML::createIndex;
use strict;
use warnings;

use Time::HiRes qw[gettimeofday tv_interval];

use lib '/home/gobland-bot/lib/';
use GLB::functions;
use GLB::variables;

my $gobs_ref   = $GLB::variables::gobs;
my %gobs       = %{$gobs_ref};
my $gobs2_ref  = $GLB::variables::gobs2;
my %gobs2      = %{$gobs2_ref};
my $clan_name  = $GLB::variables::clan_name;

sub main
{
    my $t_start  = [gettimeofday()]; 
    my $filename = '/var/www/localhost/htdocs/index.html';
    open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
    binmode($fh, ":utf8");

    print $fh $GLB::variables::begin;

    print $fh ' ' x 6, '<div id="content">'."\n";
    print $fh ' ' x 8, '<br><h1>'.$clan_name.'</h1><br>'."\n";
    print $fh ' ' x 8, '<table cellspacing="0" id="trollsList">'."\n";
    print $fh ' ' x10, '<tr>'."\n";
    print $fh ' ' x12, '<th>Pseudo</th>'."\n";
    print $fh ' ' x12, '<th>Num</th>'."\n";
    print $fh ' ' x12, '<th>Race</th>'."\n";
    print $fh ' ' x12, '<th>Niv.</th>'."\n";
    print $fh ' ' x12, '<th>Position</th>'."\n";
    print $fh ' ' x12, '<th>PV</th>'."\n";
    print $fh ' ' x12, '<th>PA</th>'."\n";
    print $fh ' ' x12, '<th>Dates</th>'."\n";
    print $fh ' ' x12, '<th>Action</th>'."\n";
    print $fh ' ' x10, '</tr>'."\n";

    my $ct_total   = 0;

    for my $gob_id ( sort keys %gobs )
    {
        my $position = $gobs{$gob_id}{'X'}.', '.$gobs{$gob_id}{'Y'}.', '.$gobs{$gob_id}{'N'};

        my $pad;
        if ( $gobs{$gob_id}{'PA'} > 0 )
        {
            $pad = ' class="PADispo"';
        } else { $pad = ' ' }

        my $color   = GLB::functions::GetColor($gobs{$gob_id}{'PV'},$gobs2{$gob_id}{'PVMax'});
        my $percent = ($gobs{$gob_id}{'PV'} / $gobs2{$gob_id}{'PVMax'}) * 100;
        my $lifebar = '<br><div class="vieContainer"><div style="background-color:'.$color.'; width: '.$percent.'%">&nbsp;</div></div>';

        $ct_total += $gobs{$gob_id}{'CT'};

        print $fh ' ' x10, '<tr>'."\n";
        print $fh ' ' x12, '<td>'."\n";
        print $fh ' ' x14, '<a href="http://games.gobland.fr/Profil.php?IdPJ='.$gob_id.'" target="_blank">'.$gobs{$gob_id}{'Nom'}.'</a>'."\n";
        print $fh ' ' x12, '</td>'."\n";
        print $fh ' ' x12, '<td>'.$gob_id.'</td>'."\n";
        print $fh ' ' x12, '<td>'.$gobs{$gob_id}{'Tribu'}.'</td>'."\n";
        print $fh ' ' x12, '<td>'.$gobs{$gob_id}{'Niveau'}.'</td>'."\n";
        print $fh ' ' x12, '<td>'.$position.'</td>'."\n";
        print $fh ' ' x12, '<td>'.$gobs{$gob_id}{'PV'}.' / '.$gobs2{$gob_id}{'PVMax'}.$lifebar.'</td>'."\n";
        print $fh ' ' x12, '<td'.$pad.'>'.$gobs{$gob_id}{'PA'}.'</td>'."\n";
        print $fh ' ' x12, '<td><span class="DLA"> DLA : '.$gobs{$gob_id}{'DLA'}.'</span><br><span class="pDLA">pDLA : [A CODER]</span></td>'."\n";
        print $fh ' ' x12, '<td>'."\n";
        print $fh ' ' x14, '/gobelins/'.$gob_id.'.html" title="Votre profil">PROFIL</a>'."\n";
        print $fh ' ' x14, '/vue/'.$gob_id.'.html" title="Votre vue">VUE</a>'."\n";
        print $fh ' ' x12, '</td>'."\n";
        print $fh ' ' x10, '</tr>'."\n";
    }

    print $fh ' ' x 8, '</table>'."\n";

    print $fh ' ' x 8, '<div>'."\n";
    print $fh ' ' x10, '<h3>Fortune : '.$ct_total.' CT (gobelins)</h3>'."\n";
    print $fh ' ' x 8, '</div>'."\n";

    my $t_elapsed = sprintf ("%0.3f", tv_interval($t_start));
    print $fh ' ' x 8, '<div class="footer">[HTML generated in '.$t_elapsed.' sec.] - [Updated @'.localtime.']</div>'."\n";

    print $fh $GLB::variables::end;
    close $fh;
}

1;
