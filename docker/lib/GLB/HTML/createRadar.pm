package GLB::HTML::createRadar;
use strict;
use warnings;

use Time::HiRes qw[gettimeofday tv_interval];

use lib '/home/gobland-bot/lib/';
use GLB::variables;

my $sqlite_db = '/home/gobland-bot/gobland.db';
my $driver_db = 'SQLite';
my $dsn       = "DBI:$driver_db:dbname=$sqlite_db";

my $dbh = DBI->connect($dsn, '', '', { RaiseError => 1 }) or die $DBI::errstr;

sub main
{
    print "GLB::HTML::createRadar[";

    my $t_start  = [gettimeofday()];
    my $filename = '/var/www/localhost/htdocs/Radar.html';
    open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
    binmode($fh, ":utf8");
    print $fh $GLB::variables::begin;

    print $fh ' ' x 6, '<div id="content" style="text-align:center;">'."\n";
    print $fh ' ' x 6, '<link href="/style/gps.css"  rel="stylesheet" type="text/css"  />'."\n";
    print $fh ' ' x 8, '<h1>Radar de zone</h1>'."\n";
    print $fh ' ' x 8, '<h3>Passez la souris sur un point pour afficher l\'infobulle</h3>'."\n";

    print $fh ' ' x 8,'<div id="tooltip" display="none" style="position: absolute; display: none;"></div>'."\n";

    print $fh ' ' x 8, '<svg version="1.2" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" class="graph" role="img">'."\n";
    print $fh ' ' x10, '<g class="grid x-grid" id="xGrid"><line x1="300" x2="300" y1="000" y2="600"></line></g>'."\n";
    print $fh ' ' x10, '<g class="grid y-grid" id="yGrid"><line x1="000" x2="600" y1="300" y2="300"></line></g>'."\n";
    print $fh ' ' x10, '<g class="grid r-grid" id="rGrid"><line x1="600" x2="600" y1="000" y2="600"></line></g>'."\n";
    print $fh ' ' x10, '<g class="grid t-grid" id="tGrid"><line x1="000" x2="600" y1="000" y2="000"></line></g>'."\n";
    print $fh ' ' x10, '<g class="grid b-grid" id="bGrid"><line x1="000" x2="600" y1="600" y2="600"></line></g>'."\n";
    print $fh ' ' x10, '<g class="grid l-grid" id="lGrid"><line x1="000" x2="000" y1="000" y2="600"></line></g>'."\n";

    print $fh ' ' x10, '<text x="000" y="308" font-family="sans-serif" font-size="10px" fill="black">-200</text>'."\n";
    print $fh ' ' x10, '<text x="582" y="299" font-family="sans-serif" font-size="10px" fill="black"> 200</text>'."\n";
    print $fh ' ' x10, '<text x="279" y="599" font-family="sans-serif" font-size="10px" fill="black">-200</text>'."\n";
    print $fh ' ' x10, '<text x="301" y="009" font-family="sans-serif" font-size="10px" fill="black"> 200</text>'."\n";

    my @gob_ids = @GLB::variables::gob_ids;
    my @colors  = ("AliceBlue","AntiqueWhite","Aqua","Aquamarine","Azure","Beige","Bisque","Black","BlanchedAlmond","Blue","BlueViolet","Brown","BurlyWood","CadetBlue","Chartreuse","Chocolate","Coral","CornflowerBlue","Cornsilk","Crimson"

    for my $gob_id ( sort @gob_ids )
    {
        print '.';

        my $color = splice(@colors, rand @colors, 1);

        my $req_position = $dbh->prepare( "SELECT Gobelins.Id,Gobelins.Gobelin,X,Y,N,PER,BMPER,BPPER FROM Gobelins \
                                           INNER JOIN Gobelins2 on Gobelins.Id = Gobelins2.Id \
                                           WHERE Gobelins.Id ='$gob_id'" );
        $req_position->execute();
        while (my @row = $req_position->fetchrow_array)
        {
            my $X        = $row[2];
            my $Y        = $row[3];
            my $N        = $row[4];
            my $cases    = 1 + $row[5] + $row[6] + $row[7];
            my $position = "<b>X</b> = $X | <b>Y</b> = $Y | <b>N</b> = $N";
            my $tt       = '\''.'['.$gob_id.'] '.Encode::decode_utf8($row[1]).' ('.$position.')\'';

            my $cx       = ($X + 200) * 1.5;
            my $cy       = (200 - $Y) * 1.5;

            print $fh ' ' x10, '<g fill="'.$color.'">'."\n";
            print $fh ' ' x12, '<circle cx="'.$cx.'" cy="'.$cy.'" r="'.$cases.'" onmousemove="showTooltip(evt, '.$tt.')";" onmouseout="hideTooltip();"></circle>'."\n";
            print $fh ' ' x10, '</g>'."\n";

            print $fh ' ' x10, '<g stroke="black" fill="none">'."\n";
            print $fh ' ' x12, '<circle fill="none"  cx="'.$cx.'" cy="'.$cy.'" r="'.$cases.'"></circle>'."\n";
            print $fh ' ' x10, '</g>'."\n";
        }
        $req_position->finish();

        # Same thing, but for Suivants
        my $sql_suivants_ids = "SELECT Suivants.Id,Vue.Nom,Vue.X,Vue.Y,Vue.N \
                                FROM Suivants \
                                INNER JOIN Vue on Suivants.Id = Vue.Id \
                                WHERE Suivants.IdGob = '$gob_id' \
                                ORDER BY Suivants.Id";

        my $req_suivants = $dbh->prepare( "$sql_suivants_ids" );
        $req_suivants->execute();

        while (my @row = $req_suivants->fetchrow_array)
        {
            print '-';
            my $suivant_id  = $row[0];
            my $suivant_nom = $row[1];
            my $X           = $row[2];
            my $Y           = $row[3];
            my $N           = $row[4];
            my $cases       = 2;       # Hardcoded for now
            my $position = "<b>X</b> = $X | <b>Y</b> = $Y | <b>N</b> = $N";
            my $tt       = '\''.'['.$suivant_id.'] '.Encode::decode_utf8($row[1]).' ('.$position.')\'';

            my $cx       = ($X + 200) * 1.5;
            my $cy       = (200 - $Y) * 1.5;

            print $fh ' ' x10, '<g fill="'.$color.'">'."\n";
            print $fh ' ' x12, '<circle cx="'.$cx.'" cy="'.$cy.'" r="'.$cases.'" onmousemove="showTooltip(evt, '.$tt.')";" onmouseout="hideTooltip();"></circle>'."\n";
            print $fh ' ' x10, '</g>'."\n";

            print $fh ' ' x10, '<g stroke="black" fill="none">'."\n";
            print $fh ' ' x12, '<circle fill="none"  cx="'.$cx.'" cy="'.$cy.'" r="'.$cases.'"></circle>'."\n";
            print $fh ' ' x10, '</g>'."\n";

        }
    }

    print $fh ' ' x 8, '</svg>'."\n";
    print $fh ' ' x 6, '</div>'."\n";

    my $t_elapsed = sprintf ("%0.3f", tv_interval($t_start));
    print $fh ' ' x 6, '<div class="footer">[HTML generated in '.$t_elapsed.' sec.] - [Updated @'.localtime.']</div>'."\n";

    print $fh $GLB::variables::vuescript;
    print $fh $GLB::variables::end;
    close $fh;
    print "]\n";
}

1;
