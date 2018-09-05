package GLB::HTML::createEquipement;
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
    my $filename = '/var/www/localhost/htdocs/equipement.html';
    open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
    binmode($fh, ":utf8");
    print $fh $GLB::variables::begin;

    print $fh ' ' x 6, '<div id="content">'."\n";
    print $fh ' ' x 6, '<link href="/style/equipement.css"  rel="stylesheet" type="text/css"  />'."\n";
    print $fh ' ' x 8, '<h1>Possessions</h1>'."\n";

    print $fh ' ' x 8, '<h2 class="expanded">Equipements Gobelins</h2>'."\n";
    print $fh ' ' x 8, '<table cellspacing="0" id="profilInfos">'."\n";
    for my $gob_id ( sort keys %stuff )
    {
        print $fh ' ' x10, '<tr class="expanded">'."\n";
        print $fh ' ' x12, '<th>Equipement(s) de '.$gobs{$gob_id}{'Nom'}.' ('.$gob_id.') </th>'."\n";
        print $fh ' ' x10, '</tr>'."\n";
        print $fh ' ' x10, '<tr>'."\n";
        print $fh ' ' x12, '<td>'."\n";
        print $fh ' ' x14, '<ul class="membreEquipementList">'."\n";
        foreach my $e ( sort keys %{$stuff{$gob_id}} )
        {
            for my $item_id ( sort keys %{$stuff{$gob_id}{$e}} )
            {
                my $type     = Encode::decode_utf8($stuff{$gob_id}{$e}{$item_id}{'Type'});
                if ( $type !~ /^Minerai$|Mat.riau|Composant/ )
                {
                    my $item_txt = GLB::functions::GetStuff($stuff_ref,$gob_id,$e,$item_id,'full');

                    print $fh ' ' x 16, '<li class="equipement'.$e.'">'."\n";
                    print $fh ' ' x 18, $item_txt."\n";
                    print $fh ' ' x 16, '</li>'."\n";
                }
            }
            if ( $e eq 'Equipe' ) { print $fh ' ' x 16, '<br>'."\n" }
        }
        print $fh ' ' x14, '</ul>'."\n";
        print $fh ' ' x12, '</td>'."\n";
        print $fh ' ' x10, '</tr>'."\n";
    }
    print $fh ' ' x 8, '</table>'."\n";

    my $t_elapsed = sprintf ("%0.3f", tv_interval($t_start));
    print $fh ' ' x 8, '<div class="footer">[HTML generated in '.$t_elapsed.' sec.] - [Updated @'.localtime.']</div>'."\n";

    print $fh $GLB::variables::end;
    close $fh;
}

1;
