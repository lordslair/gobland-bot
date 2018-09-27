package GLB::HTML::createCavernes;
use strict;
use warnings;

use Time::HiRes qw[gettimeofday tv_interval];

use lib '/home/gobland-bot/lib/';
use GLB::variables;

my $gobs_ref   = $GLB::variables::gobs;
my %gobs       = %{$gobs_ref};
my $stuff_ref  = $GLB::variables::cavernes;
my %stuff      = %{$stuff_ref};

sub main
{
    my $t_start  = [gettimeofday()];
    my $filename = '/var/www/localhost/htdocs/cavernes.html';
    open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
    binmode($fh, ":utf8");
    print $fh $GLB::variables::begin;

    print $fh ' ' x 6, '<div id="content">'."\n";
    print $fh ' ' x 6, '<link href="/style/tt_r.css"  rel="stylesheet" type="text/css"  />'."\n";
    print $fh ' ' x 6, '<link href="/style/equipement.css"  rel="stylesheet" type="text/css"  />'."\n";
    print $fh ' ' x 8, '<h1>Possessions</h1>'."\n";

    print $fh ' ' x 8, '<h2 class="expanded">Equipements Gobelins dans les Cavernes</h2>'."\n";
    print $fh ' ' x 8, '<table cellspacing="0" id="profilInfos">'."\n";

    #Equipement
    for my $c_id ( sort keys %stuff )
    {
        print $fh ' ' x10, '<tr class="expanded">'."\n";
        print $fh ' ' x12, '<th>Equipement(s) de '.$c_id.'</th>'."\n";
        print $fh ' ' x10, '</tr>'."\n";
        print $fh ' ' x10, '<tr>'."\n";
        print $fh ' ' x12, '<td>'."\n";
        print $fh ' ' x14, '<ul class="membreEquipementList">'."\n";
        foreach my $e ( sort keys %{$stuff{$c_id}} )
        {
            for my $type ( sort keys %{$stuff{$c_id}{$e}} )
            {
                $type = Encode::decode_utf8($type);
                my $png_done = 'DOING';
                for my $item_id ( sort keys %{$stuff{$c_id}{$e}{$type}} )
                {
                    if ( $type !~ /^Minerai$|Mat.riau|Composant|Roche/ )
                    {
                        my $min      = ', '.sprintf("%.1f", $stuff{$c_id}{$e}{$type}{$item_id}{'Poids'}/60) . ' min';
                        my $nom      = $stuff{$c_id}{$e}{$type}{$item_id}{'Nom'};
                        my $desc     = $stuff{$c_id}{$e}{$type}{$item_id}{'Desc'};
                        my $template = '<b>'.$stuff{$c_id}{$e}{$type}{$item_id}{'Magie'}.'</b>';
                        my $luxe     = GLB::functions::GetLuxe($type,$nom,$desc);

                        if ( $png_done ne 'DONE' )
                        {
                            my $item_png = GLB::functions::GetStuffIcon($type, $stuff{$c_id}{$e}{$type}{$item_id}{'Nom'});
                            print $fh ' ' x 16,'<div style="text-align:center; type="'.$type.'">'."\n";
                            print $fh ' ' x 18, '<br>'.$item_png.'<br>'."\n";
                            print $fh ' ' x 16,'</div>'."\n";
                        }
                        my $item_txt = '['.$item_id.'] '.$type.' : '.$nom.' '.$template.' ('.$desc.')'.$min.$luxe.'<br>';

                        print $fh ' ' x 16, '<li class="equipement'.$e.'">'."\n";
                        print $fh ' ' x 18, $item_txt."\n";
                        print $fh ' ' x 16, '</li>'."\n";
                    }
                    $png_done = 'DONE';
                }
            }
            if ( $e eq 'Equipe' ) { print $fh ' ' x 16, '<br>'."\n" }
        }
        print $fh ' ' x14, '</ul>'."\n";
        print $fh ' ' x12, '</td>'."\n";
        print $fh ' ' x10, '</tr>'."\n";
    }

    # Composants
    for my $c_id ( sort keys %stuff )
    {
        print $fh ' ' x10, '<tr class="expanded">'."\n";
        print $fh ' ' x12, '<th>Composant(s) de '.$c_id.'</th>'."\n";
        print $fh ' ' x10, '</tr>'."\n";
        print $fh ' ' x10, '<tr>'."\n";
        print $fh ' ' x12, '<td>'."\n";
        print $fh ' ' x14, '<ul class="membreEquipementList">'."\n";
        foreach my $e ( sort keys %{$stuff{$c_id}} )
        {
            for my $type ( sort keys %{$stuff{$c_id}{$e}} )
            {
                $type = Encode::decode_utf8($type);
                my $png_done = 'DOING';
                for my $item_id ( sort keys %{$stuff{$c_id}{$e}{$type}} )
                {
                    if ( $type eq 'Composant' )
                    {
                        my $min     = ', '.sprintf("%.1f", $stuff{$c_id}{$e}{$type}{$item_id}{'Poids'}/60) . ' min';
                        my $nom     = $stuff{$c_id}{$e}{$type}{$item_id}{'Nom'};
                        my $desc    = GLB::functions::GetQualite($type, $stuff{$c_id}{$e}{$type}{$item_id}{'Qualite'});

                        if ( $png_done ne 'DONE' )
                        {
                            my $item_png = GLB::functions::GetStuffIcon($type, $stuff{$c_id}{$e}{$type}{$item_id}{'Nom'});
                            print $fh ' ' x 16,'<div style="text-align:center;">'."\n";
                            print $fh ' ' x 18, '<br>'.$item_png.'<br>'."\n";
                            print $fh ' ' x 16,'</div>'."\n";
                        }

                        my $item_txt = '['.$item_id.'] '.$nom.' ('.$desc.')'.$min."\n";

                        print $fh ' ' x 16, '<li class="equipement'.$e.'">'."\n";
                        print $fh ' ' x 18, $item_txt."\n";
                        print $fh ' ' x 16, '</li>'."\n";
                    }
                    $png_done = 'DONE';
                }
            }
            if ( $e eq 'Equipe' ) { print $fh ' ' x 16, '<br>'."\n" }
        }
        print $fh ' ' x14, '</ul>'."\n";
        print $fh ' ' x12, '</td>'."\n";
        print $fh ' ' x10, '</tr>'."\n";
    }

    #Matériaux
    for my $c_id ( sort keys %stuff )
    {
        print $fh ' ' x10, '<tr class="expanded">'."\n";
        print $fh ' ' x12, '<th>Materiaux de '.$c_id.'</th>'."\n";
        print $fh ' ' x10, '</tr>'."\n";
        print $fh ' ' x10, '<tr>'."\n";
        print $fh ' ' x12, '<td>'."\n";
        print $fh ' ' x14, '<ul class="membreEquipementList">'."\n";
        foreach my $e ( sort keys %{$stuff{$c_id}} )
        {
            for my $type ( sort keys %{$stuff{$c_id}{$e}} )
            {
                my $png_done = 'DOING';
                for my $item_id ( sort keys %{$stuff{$c_id}{$e}{$type}} )
                {
                    if ( $stuff{$c_id}{$e}{$type}{$item_id}{'Type'} =~ /^Minerai$|Matériau|Roche/ )
                    {
                        my $nom     = Encode::decode_utf8($stuff{$c_id}{$e}{$type}{$item_id}{'Nom'});
                        my $min     = ', '.sprintf("%.1f", $stuff{$c_id}{$e}{$type}{$item_id}{'Poids'}/60) . ' min';
                        my $desc    = GLB::functions::GetQualite($type, $stuff{$c_id}{$e}{$type}{$item_id}{'Qualite'});
                        my $nbr     = $stuff{$c_id}{$e}{$type}{$item_id}{'Taille'};
                        my $carats  = $nbr * $stuff{$c_id}{$e}{$type}{$item_id}{'Qualite'};

                        if ( $png_done ne 'DONE' )
                        {
                            my $item_png = GLB::functions::GetMateriauIcon($nom);
                            print $fh ' ' x 16,'<div style="text-align:center; type="'.$type.'">'."\n";
                            print $fh ' ' x 18, '<br>'.$item_png.'<br>'."\n";
                            print $fh ' ' x 16,'</div>'."\n";
                        }

                        my $item_txt  = '<div class="tt_r">'."\n";
                           $item_txt .= ' ' x 20 . '['.$item_id.'] '.$nom.' de taille '.$nbr.' ('.$desc.')'.$min."\n";
                           $item_txt .= ' ' x 20 . '<span class="tt_r_text">'.$carats.' Carats</span>'."\n";
                           $item_txt .= ' ' x 18 . '</div>'."\n";

                        print $fh ' ' x 16, '<li class="equipement'.$e.'">'."\n";
                        print $fh ' ' x 18, $item_txt."\n";
                        print $fh ' ' x 16, '</li>'."\n";
                    }
                    $png_done = 'DONE';
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

    print $fh $GLB::variables::vuescript;
    print $fh $GLB::variables::end;
    close $fh;
}

1;
