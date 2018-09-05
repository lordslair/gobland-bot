package GLB::HTML::createMateriaux;
use strict;
use warnings;

use Time::HiRes qw[gettimeofday tv_interval];

use lib '/home/gobland-bot/lib/';
use GLB::variables;

my $gobs_ref   = $GLB::variables::gobs;
my %gobs       = %{$gobs_ref};
my $stuff_ref  = $GLB::variables::stuff;
my %stuff      = %{$stuff_ref};

sub main
{
    my $t_start  = [gettimeofday()];
    my $filename = '/var/www/localhost/htdocs/materiaux.html';
    open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
    binmode($fh, ":utf8");
    print $fh $GLB::variables::begin;

    print $fh ' ' x 6, '<div id="content">'."\n";
    print $fh ' ' x 6, '<link href="/style/tt_r.css"       rel="stylesheet" type="text/css" />'."\n";
    print $fh ' ' x 6, '<link href="/style/equipement.css" rel="stylesheet" type="text/css" />'."\n";
    print $fh ' ' x 8, '<h1>Possessions</h1>'."\n";

    print $fh ' ' x 8, '<h2 class="expanded">Materiaux Gobelins</h2>'."\n";
    print $fh ' ' x 8, '<table cellspacing="0" id="profilInfos">'."\n";

    for my $gob_id ( sort keys %stuff )
    {
        my $materiaux = '';
        foreach my $e ( sort keys %{$stuff{$gob_id}} )
        {
            for my $item_id ( sort keys %{$stuff{$gob_id}{$e}} )
            {
                if ( $stuff{$gob_id}{$e}{$item_id}{'Type'} =~ /^Minerai$|Matériau/)
                {
                    my $min     = ', '.sprintf("%.1f", $stuff{$gob_id}{$e}{$item_id}{'Poids'}/60) . ' min';
                    my $nom     = Encode::decode_utf8($stuff{$gob_id}{$e}{$item_id}{'Nom'});
                    my $desc    = GLB::functions::GetQualite($stuff{$gob_id}{$e}{$item_id}{'Type'}, $stuff{$gob_id}{$e}{$item_id}{'Qualite'});
                    my $nbr     = $stuff{$gob_id}{$e}{$item_id}{'Taille'};
                    my $m_png   = GLB::functions::GetMateriauIcon($nom);
                    my $carats  = $nbr * $stuff{$gob_id}{$e}{$item_id}{'Qualite'};
                    $materiaux .= ' ' x 16 . '<li class="equipementNonEquipe">'."\n";
                    $materiaux .= ' ' x 18 . '<div class="tt_r">'."\n";
                    $materiaux .= ' ' x 20 . $m_png . ' ['.$item_id.'] '.$nom.' de taille '.$nbr.' ('.$desc.')'.$min."\n";
                    $materiaux .= ' ' x 20 . '<span class="tt_r_text">'.$carats.' Carats</span>'."\n";
                    $materiaux .= ' ' x 18 . '</div>'."\n";
                    $materiaux .= ' ' x 16 . '</li>'."\n";
                }
            }
        }
        if ( $materiaux ne '' )
        {
            print $fh ' ' x10, '<tr class="expanded">'."\n";
            print $fh ' ' x12, '<th>Materiaux de '.$gobs{$gob_id}{'Nom'}.' ('.$gob_id.')</th>'."\n";
            print $fh ' ' x10, '</tr>'."\n";
            print $fh ' ' x10, '<tr>'."\n";
            print $fh ' ' x12, '<td>'."\n";
            print $fh ' ' x14, '<ul class="membreEquipementList">'."\n";
            print $fh $materiaux;
            print $fh ' ' x14, '</ul>'."\n";
            print $fh ' ' x12, '</td>'."\n";
            print $fh ' ' x10, '</tr>'."\n";
        }
    }
    print $fh ' ' x 8, '</table>'."\n";

    my $t_elapsed = sprintf ("%0.3f", tv_interval($t_start));
    print $fh ' ' x 8, '<div class="footer">[HTML generated in '.$t_elapsed.' sec.] - [Updated @'.localtime.']</div>'."\n";

    print $fh $GLB::variables::end;
    close $fh;
}

1;
