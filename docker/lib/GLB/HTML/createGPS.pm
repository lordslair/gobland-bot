package GLB::HTML::createGPS;
use strict;
use warnings;

use Time::HiRes qw[gettimeofday tv_interval];

use lib '/home/gobland-bot/lib/';
use GLB::variables;

sub main
{
    use YAML::Tiny;
    my $t_start  = [gettimeofday()];
    my $filename = '/var/www/localhost/htdocs/GPS.html';
    open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
    binmode($fh, ":utf8");
    print $fh $GLB::variables::begin;

    my $lieux_yaml = '/home/gobland-bot/data/Lieux.yaml';
    my $yaml       = YAML::Tiny->read( $lieux_yaml );
    my %LIEUX_YAML = %{$yaml->[0]};

    print $fh ' ' x 6, '<div id="content" style="text-align:center;">'."\n";
    print $fh ' ' x 6, '<link href="/style/gps.css"  rel="stylesheet" type="text/css"  />'."\n";
    print $fh ' ' x 8, '<h1>GPS des Lieux</h1>'."\n";
    print $fh ' ' x 8, '<h3>Passez la souris sur un point pour afficher l\'infobulle</h3>'."\n";

    print $fh ' ' x 8,'<div id="tooltip" display="none" style="position: absolute; display: none;"></div>'."\n";

    print $fh ' ' x 8, '<svg version="1.2" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" class="graph" role="img">'."\n";
    print $fh ' ' x10, '<g class="grid x-grid" id="xGrid"><line x1="300" x2="300" y1="000" y2="600"></line></g>'."\n";
    print $fh ' ' x10, '<g class="grid y-grid" id="yGrid"><line x1="000" x2="600" y1="300" y2="300"></line></g>'."\n";
    print $fh ' ' x10, '<g class="grid r-grid" id="rGrid"><line x1="600" x2="600" y1="000" y2="600"></line></g>'."\n";
    print $fh ' ' x10, '<g class="grid t-grid" id="tGrid"><line x1="000" x2="600" y1="000" y2="000"></line></g>'."\n";
    print $fh ' ' x10, '<g class="grid b-grid" id="bGrid"><line x1="000" x2="600" y1="600" y2="600"></line></g>'."\n";
    print $fh ' ' x10, '<g class="grid l-grid" id="lGrid"><line x1="000" x2="000" y1="000" y2="600"></line></g>'."\n";

    foreach my $id_lieu (sort {$a<=>$b} keys %LIEUX_YAML)
    {
        my $position = "<b>X</b> = $LIEUX_YAML{$id_lieu}{'X'} | <b>Y</b> = $LIEUX_YAML{$id_lieu}{'Y'} | <b>N</b> = $LIEUX_YAML{$id_lieu}{'Z'}";
        my $cx = ($LIEUX_YAML{$id_lieu}{'X'} + 200) * 1.5;
        my $cy = (200 - $LIEUX_YAML{$id_lieu}{'Y'}) * 1.5;
        my $tt = '\''.$LIEUX_YAML{$id_lieu}{'Nom'}.' ('.$position.')\'';
        my $dv = $LIEUX_YAML{$id_lieu}{'Type'};
           $dv =~ s/^Amphi.*$/Amphitheatre/g;
           $dv =~ s/^.*cycle$/Hemicycle/g;
           $dv =~ s/^Mona.*$/Monastere/g;

        print $fh ' ' x10, '<g class="'.$dv.'">'."\n";
        print $fh ' ' x12, '<circle cx="'.$cx.'" cy="'.$cy.'" r="2" onmousemove="showTooltip(evt, '.$tt.')";" onmouseout="hideTooltip();"></circle>'."\n";
        print $fh ' ' x10, '</g>'."\n";
    }

    print $fh ' ' x 8, '</svg>'."\n";
    print $fh ' ' x 6, '</div>'."\n";

    print $fh ' ' x 6, '<br>'."\n";
    print $fh ' ' x 6, '<div style="text-align:center;">'."\n";
    print $fh ' ' x 8, '<svg version="1.2" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" class="leg" role="img">'."\n";
    print $fh ' ' x10, '<g class="grid r-grid" id="rGrid"><line x1="400" x2="400" y1="000" y2="050"></line></g>'."\n";
    print $fh ' ' x10, '<g class="grid t-grid" id="tGrid"><line x1="000" x2="400" y1="000" y2="000"></line></g>'."\n";
    print $fh ' ' x10, '<g class="grid b-grid" id="bGrid"><line x1="000" x2="400" y1="050" y2="050"></line></g>'."\n";
    print $fh ' ' x10, '<g class="grid l-grid" id="lGrid"><line x1="000" x2="000" y1="000" y2="050"></line></g>'."\n";

    print $fh ' ' x10, '<g class="Tour">        <circle cx="010" cy="10" r="5"</circle></g><text x="20"  y="15">Tour</text>'."\n";
    print $fh ' ' x10, '<g class="Laboratoire"> <circle cx="080" cy="10" r="5"</circle></g><text x="90"  y="15">Laboratoire</text>'."\n";
    print $fh ' ' x10, '<g class="Cercle">      <circle cx="160" cy="10" r="5"</circle></g><text x="170" y="15">Cercle</text>'."\n";
    print $fh ' ' x10, '<g class="Caverne">     <circle cx="240" cy="10" r="5"</circle></g><text x="250" y="15">Caverne</text>'."\n";
    print $fh ' ' x10, '<g class="Cabane">      <circle cx="320" cy="10" r="5"</circle></g><text x="330" y="15">Cabane</text>'."\n";

    print $fh ' ' x10, '<g class="Monastere">   <circle cx="010" cy="40" r="5"</circle></g><text x="020" y="45">Monastere</text>'."\n";
    print $fh ' ' x10, '<g class="Fosse">       <circle cx="080" cy="40" r="5"</circle></g><text x="090" y="45">Fosse</text>'."\n";
    print $fh ' ' x10, '<g class="Amphitheatre"><circle cx="160" cy="40" r="5"</circle></g><text x="170" y="45">Amphi.</text>'."\n";
    print $fh ' ' x10, '<g class="Hemicycle">   <circle cx="240" cy="40" r="5"</circle></g><text x="250" y="45">Hemicycle</text>'."\n";

    print $fh ' ' x 8, '</svg>'."\n";
    print $fh ' ' x 6, '</div>'."\n";
    print $fh ' ' x 6, '<br>'."\n";

    my $t_elapsed = sprintf ("%0.3f", tv_interval($t_start));
    print $fh ' ' x 6, '<div class="footer">[HTML generated in '.$t_elapsed.' sec.] - [Updated @'.localtime.']</div>'."\n";

    print $fh $GLB::variables::vuescript;
    print $fh $GLB::variables::end;
    close $fh;
}

1;
